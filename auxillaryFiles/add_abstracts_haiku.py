#!/usr/bin/env python3
"""Second pass: for entries logged as `no-abstract-marker` by add_abstracts.py,
send the first two PDF pages through `claude -p --model haiku` to extract the
abstract, then splice it into references.bib.

Token-efficient: the page text is processed by a separate Haiku subprocess, not
by the calling model's context. Entries where Haiku reports no abstract (NONE)
or errors are logged to abstract_misses_haiku.txt.

Usage:
    python3 add_abstracts_haiku.py [--limit N] [--dry-run]
"""
import re
import sys
import subprocess
import pathlib
import unicodedata

import fitz  # PyMuPDF

HERE = pathlib.Path(__file__).resolve().parent
REPO = HERE.parent
BIB = REPO / "references.bib"
MISSES_IN = HERE / "abstract_misses.txt"
MISSES_OUT = HERE / "abstract_misses_haiku.txt"

DRY_RUN = "--dry-run" in sys.argv
LIMIT = None
if "--limit" in sys.argv:
    LIMIT = int(sys.argv[sys.argv.index("--limit") + 1])

PROMPT = (
    "You are given the raw text of the first two pages of an academic paper or "
    "document. Extract the paper's abstract and output it verbatim as a single "
    "line with no line breaks. Correct obvious text-extraction artifacts such as "
    "ligatures mis-rendered as symbols (e.g. fi/fl shown as garbled characters), "
    "broken hyphenation, and stray spaces, but do NOT paraphrase, summarize, or "
    "add any words of your own. If the document has no abstract, output exactly: "
    "NONE. Output nothing except the abstract text or NONE."
)


def extract_pdf_path(file_field: str):
    for chunk in file_field.split(";"):
        m = re.match(r":?(.*?\.pdf):?[^:]*$", chunk.strip(), re.IGNORECASE)
        if m:
            return m.group(1)
    return None


def clean(text: str) -> str:
    text = "".join(c for c in text if unicodedata.category(c) not in ("Cf", "Cc")
                   or c in "\n\t")
    text = re.sub(r"\s+", " ", text).strip()
    text = text.replace("{", "").replace("}", "")
    for ch in ("\\", "&", "%", "#", "_", "$"):
        text = text.replace(ch, "\\" + ch)
    return text


def pages_text(pdf_path: str, n=5) -> str:
    doc = fitz.open(pdf_path)
    txt = "\n".join(doc.load_page(i).get_text("text")
                    for i in range(min(n, doc.page_count)))
    doc.close()
    return txt


def haiku_abstract(page_text: str):
    try:
        r = subprocess.run(
            ["claude", "-p", "--model", "haiku", PROMPT],
            input=page_text, capture_output=True, text=True, timeout=180,
        )
    except subprocess.TimeoutExpired:
        return None, "haiku-timeout"
    if r.returncode != 0:
        return None, f"haiku-rc{r.returncode}"
    out = r.stdout.strip()
    if not out or out.strip().upper() == "NONE":
        return None, "haiku-none"
    cleaned = clean(out)
    if len(cleaned.split()) < 20:
        return None, "too-short"
    return cleaned, None


# --- load the no-abstract-marker keys ---------------------------------------
targets = []
for line in MISSES_IN.read_text().splitlines():
    parts = line.split("\t")
    if len(parts) >= 2 and parts[1] == "no-abstract-marker":
        targets.append(parts[0])
if LIMIT:
    targets = targets[:LIMIT]

# --- locate each entry in the raw bib ---------------------------------------
raw = BIB.read_text(encoding="utf-8")
entry_re = re.compile(r"(@\w+\{([^,]+),)(.*?\n\})", re.DOTALL)
file_re = re.compile(r"\n[ \t]*file\s*=\s*\{(.+?)\}", re.DOTALL)

entries = {}  # key -> (header_end_pos, file_path, has_abstract)
for em in entry_re.finditer(raw):
    key = em.group(2).strip()
    fm = file_re.search(em.group(0))
    entries[key] = (
        em.start(1) + len(em.group(1)),
        extract_pdf_path(fm.group(1)) if fm else None,
        bool(re.search(r"\n[ \t]*abstract\s*=", em.group(0))),
    )

inserts = []
miss_log = []
n_ok = 0
for i, key in enumerate(targets, 1):
    info = entries.get(key)
    if not info:
        miss_log.append(f"{key}\tnot-in-bib")
        continue
    pos, pdf_path, has_abs = info
    if has_abs:
        continue
    if not pdf_path or not pathlib.Path(pdf_path).is_file():
        miss_log.append(f"{key}\tmissing-pdf")
        continue
    try:
        ptext = pages_text(pdf_path)
    except Exception as e:
        miss_log.append(f"{key}\tpdf-open: {e}")
        continue
    abstract, err = haiku_abstract(ptext)
    print(f"[{i}/{len(targets)}] {key}: "
          f"{'OK ' + str(len(abstract.split())) + 'w' if abstract else err}",
          flush=True)
    if abstract is None:
        miss_log.append(f"{key}\t{err}")
        continue
    inserts.append((pos, f"\n abstract = {{{abstract}}},"))
    n_ok += 1

for pos, txt in sorted(inserts, reverse=True):
    raw = raw[:pos] + txt + raw[pos:]

if not DRY_RUN:
    BIB.write_text(raw, encoding="utf-8")
MISSES_OUT.write_text("\n".join(miss_log) + "\n", encoding="utf-8")

print(f"\n{'[dry-run] ' if DRY_RUN else ''}done. inserted {n_ok} / {len(targets)} "
      f"| still missed {len(miss_log)} -> {MISSES_OUT.name}")
