#!/usr/bin/env python3
"""Extract abstracts from the PDFs linked in references.bib and splice an
`abstract = {...}` field into each entry that lacks one.

Token-efficient by design: all PDF text is processed locally with PyMuPDF and
never leaves the machine. Entries whose abstract can't be confidently located
are skipped and logged to abstract_misses.txt for manual handling.

The .bib is edited by targeted text insertion (not full re-serialization), so
the diff is limited to the lines actually added.

Usage:
    python3 add_abstracts.py [--dry-run]

Run from the repo root or auxillaryFiles/; paths are resolved relative to the
script location.
"""
import re
import sys
import pathlib
import unicodedata

import fitz  # PyMuPDF

REPO = pathlib.Path(__file__).resolve().parent.parent
BIB = REPO / "references.bib"
MISSES = pathlib.Path(__file__).resolve().parent / "abstract_misses.txt"
DRY_RUN = "--dry-run" in sys.argv

MAX_PAGES = 3          # scan first N pages; covers cover-sheet/page-2 abstracts
MAX_WORDS = 350        # hard cap on captured abstract length

# Markers that signal the start of the abstract.
START_RE = re.compile(r"\b(A\s?B\s?S\s?T\s?R\s?A\s?C\s?T|Abstract|Summary)\b[\s:.\-—]*",
                      re.IGNORECASE)

# Markers that signal the end of the abstract (whichever comes first).
END_RE = re.compile(
    r"("
    r"\bKey\s?words?\b"
    r"|\bIntroduction\b"
    r"|\n\s*1[\.\s]+Introduction"
    r"|\n\s*1\s*\|"
    r"|©\s*\d{4}|©\s*Springer|©\s*Elsevier|©\s*The Author"
    r"|\bReceived:"
    r"|\bdoi:|\bhttps?://doi"
    r"|This article is protected"
    r")",
    re.IGNORECASE,
)


def extract_pdf_path(file_field: str):
    """JabRef stores file links as `:PATH:type` possibly ;-separated."""
    for chunk in file_field.split(";"):
        chunk = chunk.strip()
        # strip a leading ":" and a trailing ":<type>"
        m = re.match(r":?(.*?\.pdf):?[^:]*$", chunk, re.IGNORECASE)
        if m:
            return m.group(1)
    return None


def clean(text: str) -> str:
    text = text.replace("-\n", "")          # de-hyphenate line breaks
    # drop Unicode control/format chars (bidi marks, zero-width, etc.) that
    # some PDFs interleave into the text stream
    text = "".join(c for c in text if unicodedata.category(c) not in ("Cf", "Cc")
                   or c in "\n\t")
    text = re.sub(r"\s+", " ", text)         # collapse whitespace
    text = text.strip()
    # balance/strip braces and escape LaTeX specials (field is metadata, never typeset)
    text = text.replace("{", "").replace("}", "")
    for ch in ("\\", "&", "%", "#", "_", "$"):
        text = text.replace(ch, "\\" + ch)
    return text


def find_abstract(pdf_path: str):
    try:
        doc = fitz.open(pdf_path)
    except Exception as e:
        return None, f"open-failed: {e}"
    parts = []
    for i in range(min(MAX_PAGES, doc.page_count)):
        parts.append(doc.load_page(i).get_text("text"))
    doc.close()
    text = "\n".join(parts)

    m = START_RE.search(text)
    if not m:
        return None, "no-abstract-marker"
    body = text[m.end():]

    end = END_RE.search(body)
    body = body[:end.start()] if end else body

    body = clean(body)
    words = body.split()
    if len(words) < 20:
        return None, "too-short"
    if len(words) > MAX_WORDS:
        body = " ".join(words[:MAX_WORDS])
    return body, None


# --- iterate entries in the raw .bib ----------------------------------------
raw = BIB.read_text(encoding="utf-8")

# Match each entry from "@type{key," to the line-start "}" that closes it.
entry_re = re.compile(r"(@\w+\{([^,]+),)(.*?\n\})", re.DOTALL)
file_re = re.compile(r"\n[ \t]*file\s*=\s*\{(.+?)\}", re.DOTALL)

inserts = []   # (position_to_insert_at, text_to_insert)
stats = {"have_abstract": 0, "no_file": 0, "inserted": 0, "missed": 0}
miss_log = []

for em in entry_re.finditer(raw):
    header, key, body = em.group(1), em.group(2).strip(), em.group(3)
    entry_text = em.group(0)

    # skip @comment / jabref-meta blocks (not real entries)
    if em.group(0).lower().startswith("@comment") or ":" in key or " " in key:
        continue
    if re.search(r"\n[ \t]*abstract\s*=", entry_text):
        stats["have_abstract"] += 1
        continue
    fm = file_re.search(entry_text)
    if not fm:
        stats["no_file"] += 1
        continue
    pdf_path = extract_pdf_path(fm.group(1))
    if not pdf_path or not pathlib.Path(pdf_path).is_file():
        stats["missed"] += 1
        miss_log.append(f"{key}\tmissing-pdf\t{pdf_path}")
        continue

    abstract, err = find_abstract(pdf_path)
    if abstract is None:
        stats["missed"] += 1
        miss_log.append(f"{key}\t{err}\t{pathlib.Path(pdf_path).name}")
        continue

    # insert right after the "@type{key," header line
    insert_pos = em.start(1) + len(header)
    inserts.append((insert_pos, f"\n abstract = {{{abstract}}},"))
    stats["inserted"] += 1

# apply inserts back-to-front so offsets stay valid
for pos, txt in sorted(inserts, reverse=True):
    raw = raw[:pos] + txt + raw[pos:]

if not DRY_RUN:
    BIB.write_text(raw, encoding="utf-8")
MISSES.write_text("\n".join(miss_log) + "\n", encoding="utf-8")

print(f"{'[dry-run] ' if DRY_RUN else ''}done.")
print(f"  inserted abstracts : {stats['inserted']}")
print(f"  already had one    : {stats['have_abstract']}")
print(f"  no file field      : {stats['no_file']}")
print(f"  missed (logged)    : {stats['missed']}  -> {MISSES.name}")
