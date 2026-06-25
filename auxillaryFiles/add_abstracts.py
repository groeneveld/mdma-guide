#!/usr/bin/env python3
"""Fill in missing `abstract = {...}` fields in references.bib.

Runs in two passes, one local MLX model each (they don't fit in memory
together, so they never load at the same time):

  Pass 1 (default) fills abstracts from two cheap sources:
    1. Crossref  - look the DOI up in the Crossref REST API and use the
       publisher-deposited abstract (JATS XML, tags stripped). Fast, exact,
       no PDF needed.
    2. Local LLM (extract) - if there's no DOI or Crossref has no abstract,
       send the first two PDF pages to a small local MLX model (mlx-community/
       gemma-4-E4B-it-OptiQ-4bit) and let it pull the abstract out verbatim.

  Pass 2 (--gen) generates abstracts. For every entry that still lacks one but
  has an attached file (.pdf or .txt), a larger local model (mlx-community/
  gemma-4-12B-it-OptiQ-4bit) writes a fresh abstract from the document text.
  Generated abstracts are prefixed with a marker so they're distinguishable
  from real ones. Run this after pass 1.

Everything is local; nothing leaves the machine. The old algorithmic
ABSTRACT/Introduction marker scraping is gone; it was unreliable.

The .bib is edited by targeted insertion (not full re-serialization), so the
diff is limited to the lines actually added. Entries that can't be resolved are
logged to abstract_misses.txt.

Scanned/image-only PDFs (no text layer) are OCR'd with Tesseract before being
sent to the LLM; pass --no-ocr to skip that.

Usage:
    python3 add_abstracts.py [--dry-run] [--limit N] [--no-ocr]   # pass 1
    python3 add_abstracts.py --gen [--dry-run] [--limit N]        # pass 2

Run from the repo root or auxillaryFiles/; paths resolve relative to the script.
"""
import os
import re
import sys
import json
import pathlib
import unicodedata
import urllib.request
import urllib.parse

import fitz  # PyMuPDF

HERE = pathlib.Path(__file__).resolve().parent
REPO = HERE.parent
BIB = REPO / "references.bib"
MISSES = HERE / "abstract_misses.txt"

DRY_RUN = "--dry-run" in sys.argv
# Two passes, one model each (they don't fit in memory together):
#   default      -> Crossref + verbatim extraction (small model).
#   --gen        -> generate abstracts for any file-bearing entry still missing
#                   one (large model). Run this after the default pass.
GEN_PASS = "--gen" in sys.argv
LIMIT = None
if "--limit" in sys.argv:
    LIMIT = int(sys.argv[sys.argv.index("--limit") + 1])

MAX_PAGES = 2          # pages sent to the LLM for verbatim extraction
GEN_MAX_PAGES = 50     # pages read when generating an abstract from scratch
GEN_MAX_CHARS = 200000 # cap on text fed to the generator (~50 pages of prose)
GEN_MARKER = "[AI-generated abstract] "   # prefix flagging generated abstracts
MIN_WORDS = 20         # reject anything shorter as not-a-real-abstract
MAILTO = "mgroeneveld@protonmail.ch"   # Crossref polite-pool contact

# OCR fallback (for image-only / scanned PDFs with no text layer). Requires the
# `tesseract` binary; PyMuPDF shells out to it. Disable with --no-ocr.
OCR = "--no-ocr" not in sys.argv
OCR_MIN_CHARS = 200    # if the text layer yields fewer chars, OCR the pages
OCR_DPI = 300
# PyMuPDF needs TESSDATA_PREFIX pointing at the tessdata dir.
for _td in (os.environ.get("TESSDATA_PREFIX"),
            "/opt/homebrew/share/tessdata", "/usr/local/share/tessdata",
            "/usr/share/tessdata"):
    if _td and pathlib.Path(_td).is_dir():
        os.environ["TESSDATA_PREFIX"] = _td
        break

# Small model: pulls an existing abstract out of a PDF verbatim.
MLX_MODEL = "mlx-community/gemma-4-E4B-it-OptiQ-4bit"
# Larger model: writes a fresh abstract for documents that don't have one.
MLX_GEN_MODEL = "mlx-community/gemma-4-12B-it-OptiQ-4bit"
# These models are reasoning models: they emit chain-of-thought first, so the
# ceiling must cover both the reasoning and the answer. Generation reasons far
# more than extraction (it drafts and self-critiques), so it gets a much higher
# ceiling; too low and the answer is truncated before the model emits it.
MLX_MAX_TOKENS = 2048        # verbatim extraction (short reasoning)
MLX_GEN_MAX_TOKENS = 8192    # generation (long reasoning + ~200-word abstract)
_MLX = {}              # model_name -> (model, tokenizer), loaded lazily

PROMPT = (
    "You are given the raw text of the first two pages of an academic paper or "
    "document. Extract the paper's abstract and output it verbatim as a single "
    "line with no line breaks. Correct obvious text-extraction artifacts such as "
    "ligatures mis-rendered as symbols (e.g. fi/fl shown as garbled characters), "
    "broken hyphenation, and stray spaces, but do NOT paraphrase, summarize, or "
    "add any words of your own. If the document has no abstract, output exactly: "
    "NONE. Output nothing except the abstract text or NONE."
)

GEN_PROMPT = (
    "You are given the raw text of a document that has no "
    "abstract of its own. Write a single-paragraph abstract of roughly 150-250 "
    "words summarizing the document's purpose, methods, key findings, and "
    "conclusions, in the neutral style of a journal abstract. Base it only on "
    "the text provided; do not invent results. Output the abstract as a single "
    "line with no line breaks and nothing else - no preamble, no heading, no "
    "quotation marks."
)


# --- helpers ----------------------------------------------------------------
def extract_file_path(file_field: str):
    """JabRef stores file links as `:PATH:type`, possibly ;-separated. Return
    the first attached .pdf or .txt path."""
    for chunk in file_field.split(";"):
        m = re.match(r":?(.*?\.(?:pdf|txt)):?[^:]*$", chunk.strip(), re.IGNORECASE)
        if m:
            return m.group(1)
    return None


def clean(text: str) -> str:
    """Normalize whitespace and escape LaTeX specials (field is metadata)."""
    text = text.replace("-\n", "")
    text = "".join(c for c in text if unicodedata.category(c) not in ("Cf", "Cc")
                   or c in "\n\t")
    text = re.sub(r"\s+", " ", text).strip()
    text = text.replace("{", "").replace("}", "")
    for ch in ("\\", "&", "%", "#", "_", "$"):
        text = text.replace(ch, "\\" + ch)
    return text


def accept(text: str):
    """Clean an abstract candidate; return (text, None) or (None, reason)."""
    cleaned = clean(text)
    if len(cleaned.split()) < MIN_WORDS:
        return None, "too-short"
    return cleaned, None


def pages_text(pdf_path: str, n=MAX_PAGES) -> str:
    doc = fitz.open(pdf_path)
    pages = [doc.load_page(i) for i in range(min(n, doc.page_count))]
    txt = "\n".join(p.get_text("text") for p in pages)
    # Image-only / scanned PDF: little or no embedded text -> OCR the page images
    # so the LLM has something to read.
    if OCR and len(txt.strip()) < OCR_MIN_CHARS:
        try:
            ocr = []
            for p in pages:
                tp = p.get_textpage_ocr(flags=0, full=True, dpi=OCR_DPI)
                ocr.append(p.get_text("text", textpage=tp))
            ocr_txt = "\n".join(ocr)
            if len(ocr_txt.strip()) > len(txt.strip()):
                txt = ocr_txt
        except Exception as e:
            print(f"    ocr-failed: {e}", flush=True)
    doc.close()
    return txt


# --- source 1: Crossref -----------------------------------------------------
def crossref_abstract(doi: str):
    url = (f"https://api.crossref.org/works/{urllib.parse.quote(doi, safe='')}"
           f"?mailto={MAILTO}")
    req = urllib.request.Request(
        url, headers={"User-Agent": f"add_abstracts/1.0 (mailto:{MAILTO})"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            data = json.load(r)
    except Exception as e:
        return None, f"crossref-error: {e}"
    xml = data.get("message", {}).get("abstract")
    if not xml:
        return None, "crossref-no-abstract"
    text = re.sub(r"<[^>]+>", " ", xml)          # strip JATS tags
    text = re.sub(r"^\s*Abstract[:\s.\-]*", "", text, flags=re.IGNORECASE)
    return accept(text)


# --- source 2: local LLM ----------------------------------------------------
def ensure_mlx(model_name: str):
    """Load an MLX model + tokenizer once, on first use, caching per model.
    Loading is a few seconds and a few GB of RAM, so we skip it entirely when
    every entry is resolved by Crossref. Returns (model, tokenizer) or None on
    failure."""
    if model_name not in _MLX:
        try:
            from mlx_lm import load
        except Exception as e:
            print(f"    mlx-import-failed: {e}", flush=True)
            return None
        print(f"loading {model_name}...", flush=True)
        _MLX[model_name] = load(model_name)
    return _MLX[model_name]


def strip_reasoning(text: str):
    """Drop this model's chain-of-thought and return only the final answer.
    Reasoning is wrapped in plain-text channel delimiters, e.g.
    `<|channel>thought ...reasoning... <channel|>ANSWER`; the answer follows the
    final closing `<channel|>`. If a reasoning channel was opened (`<|channel>`)
    but never closed, the answer was cut off by the token limit -> return
    (None, 'truncated') so the caller rejects it instead of mistaking the raw
    chain-of-thought for the abstract. Returns (answer, None) or (None, reason)."""
    if "<channel|>" in text:                       # closed -> answer present
        text = text.rsplit("<channel|>", 1)[-1]
    elif "<|channel>" in text:                      # opened, never closed
        return None, "truncated"
    text = re.sub(r"<\|?/?(channel|tool_call|tool_response|turn)\|?>", "", text)
    return text.strip(), None


def mlx_run(model_name: str, prompt: str, doc_text: str, max_tokens: int):
    """Run one chat completion. Returns (text, None) or (None, reason)."""
    loaded = ensure_mlx(model_name)
    if loaded is None:
        return None, "mlx-unavailable"
    model, tok = loaded
    from mlx_lm import generate
    from mlx_lm.sample_utils import make_sampler
    messages = [{"role": "user",
                 "content": f"{prompt}\n\n--- BEGIN TEXT ---\n"
                            f"{doc_text}\n--- END TEXT ---"}]
    prompt_ids = tok.apply_chat_template(messages, add_generation_prompt=True)
    try:
        out = generate(model, tok, prompt=prompt_ids, max_tokens=max_tokens,
                       sampler=make_sampler(temp=0.0))
    except Exception as e:
        return None, f"mlx-error: {e}"
    return strip_reasoning(out)


def mlx_extract_abstract(page_text: str):
    """Pull an existing abstract out verbatim with the small model."""
    out, err = mlx_run(MLX_MODEL, PROMPT, page_text, MLX_MAX_TOKENS)
    if err:
        return None, err
    if not out or out.upper() == "NONE":
        return None, "llm-none"
    return accept(out)


def mlx_generate_abstract(doc_text: str):
    """Write a fresh abstract with the larger model, for documents that have
    none of their own."""
    out, err = mlx_run(MLX_GEN_MODEL, GEN_PROMPT, doc_text[:GEN_MAX_CHARS],
                       MLX_GEN_MAX_TOKENS)
    if err:
        return None, err
    if not out or out.upper() == "NONE":
        return None, "gen-empty"
    cleaned, reason = accept(out)
    if cleaned is None:
        return None, reason
    return GEN_MARKER + cleaned, None


# Pass 1: verbatim extraction from a PDF (small model).
def extract_from_pdf(pdf_path: str):
    """Pull an existing abstract out of a PDF verbatim. Returns (abstract, err)."""
    try:
        ptext = pages_text(pdf_path)
    except Exception as e:
        return None, f"pdf-open: {e}"
    return mlx_extract_abstract(ptext)


# Pass 2: generate a fresh abstract from a file's full text (large model).
def generate_from_file(file_path: str):
    """Write an abstract for a .pdf or .txt document. Returns (abstract, err)."""
    try:
        if file_path.lower().endswith(".txt"):
            doc_text = pathlib.Path(file_path).read_text(
                encoding="utf-8", errors="replace")
        else:
            doc_text = pages_text(file_path, n=GEN_MAX_PAGES)
    except Exception as e:
        return None, f"file-open: {e}"
    return mlx_generate_abstract(doc_text)


# --- iterate entries in the raw .bib ----------------------------------------
raw = BIB.read_text(encoding="utf-8")
entry_re = re.compile(r"(@\w+\{([^,]+),)(.*?\n\})", re.DOTALL)
file_re = re.compile(r"\n[ \t]*file\s*=\s*\{(.+?)\}", re.DOTALL)
doi_re = re.compile(r"\n[ \t]*doi\s*=\s*\{(.+?)\}", re.IGNORECASE | re.DOTALL)

# collect candidate entries first so --limit is meaningful
candidates = []   # (key, insert_pos, doi, file_path)
stats = {"have_abstract": 0, "no_source": 0,
         "crossref": 0, "llm": 0, "llm_gen": 0, "missed": 0}

for em in entry_re.finditer(raw):
    header, key = em.group(1), em.group(2).strip()
    entry_text = em.group(0)
    if entry_text.lower().startswith("@comment") or ":" in key or " " in key:
        continue
    if re.search(r"\n[ \t]*abstract\s*=", entry_text):
        stats["have_abstract"] += 1
        continue

    dm = doi_re.search(entry_text)
    doi = dm.group(1).strip() if dm else None
    if doi:
        doi = re.sub(r"^https?://(dx\.)?doi\.org/", "", doi, flags=re.IGNORECASE)
    fm = file_re.search(entry_text)
    file_path = extract_file_path(fm.group(1)) if fm else None
    if file_path and not pathlib.Path(file_path).is_file():
        file_path = None

    insert_pos = em.start(1) + len(header)
    candidates.append((key, insert_pos, doi, file_path))

if LIMIT:
    candidates = candidates[:LIMIT]

def atomic_write(path: pathlib.Path, text: str):
    """Write via a temp file + os.replace so a crash mid-write can't leave the
    target half-written / corrupted."""
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    os.replace(tmp, path)


miss_log = []
# Candidates are in ascending file order; we insert as we go, front-to-back,
# and track a running offset so each new entry's stored position stays valid
# after earlier insertions have grown `raw`. The .bib and miss log are flushed
# to disk after every resolved entry, so a crash only loses the entry in flight.
offset = 0
for i, (key, pos, doi, file_path) in enumerate(candidates, 1):
    errs = []
    abstract = None
    source = None

    if GEN_PASS:
        # Generate one for any file-bearing entry that still lacks an abstract.
        if not file_path:
            continue                  # nothing to generate from; skip silently
        abstract, err = generate_from_file(file_path)
        if abstract:
            source = "llm_gen"
        else:
            errs.append(err)
    else:
        if not doi and not file_path:
            stats["no_source"] += 1
            miss_log.append(f"{key}\tno-doi-no-file")
            MISSES.write_text("\n".join(miss_log) + "\n", encoding="utf-8")
            continue

        if doi:
            abstract, err = crossref_abstract(doi)
            if abstract:
                source = "crossref"
            else:
                errs.append(err)

        if abstract is None and file_path:
            if file_path.lower().endswith(".txt"):
                errs.append("txt-needs-gen-pass")   # left for the --gen pass
            else:
                abstract, err = extract_from_pdf(file_path)
                if abstract:
                    source = "llm"
                else:
                    errs.append(err)

    print(f"[{i}/{len(candidates)}] {key}: "
          f"{source.upper() + ' ' + str(len(abstract.split())) + 'w' if abstract else '; '.join(errs)}",
          flush=True)

    if abstract is None:
        stats["missed"] += 1
        miss_log.append(f"{key}\t{'; '.join(errs)}")
        MISSES.write_text("\n".join(miss_log) + "\n", encoding="utf-8")
        continue

    stats[source] += 1
    txt = f"\n abstract = {{{abstract}}},"
    at = pos + offset
    raw = raw[:at] + txt + raw[at:]
    offset += len(txt)
    if not DRY_RUN:
        atomic_write(BIB, raw)

MISSES.write_text("\n".join(miss_log) + "\n", encoding="utf-8")

pass_name = "gen pass" if GEN_PASS else "extract pass"
model = MLX_GEN_MODEL if GEN_PASS else MLX_MODEL
print(f"\n{'[dry-run] ' if DRY_RUN else ''}done ({pass_name}, model: {model}).")
if GEN_PASS:
    print(f"  from llm (gen)    : {stats['llm_gen']}")
else:
    print(f"  from crossref     : {stats['crossref']}")
    print(f"  from llm (extract): {stats['llm']}")
    print(f"  no doi / no file  : {stats['no_source']}")
print(f"  already had one   : {stats['have_abstract']}")
print(f"  missed (logged)   : {stats['missed']}  -> {MISSES.name}")
