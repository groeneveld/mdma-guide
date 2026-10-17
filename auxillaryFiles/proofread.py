#!/usr/bin/env python3
"""Proofread book.typ section by section with Claude Haiku and leave notes inline.

Each level-1/2 section is sent to `claude -p`. The model returns notes that each
carry a short quote copied from the text; the note is inserted as a Typst block
comment right after that quote, e.g. `/* LLM: comma splice. Suggest: "...; ..." */`.

Usage:
  python3 auxillaryFiles/proofread.py --section "The Defense Cascade"
  python3 auxillaryFiles/proofread.py            # every section
  python3 auxillaryFiles/proofread.py --dry-run  # print notes, don't edit

Remove all notes afterwards with:
  perl -0pi -e 's| ?/\\* LLM: .*? \\*/||g' book.typ
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

BOOK = Path(__file__).resolve().parent.parent / "book.typ"
TAG = "LLM:"

PROMPT = """You are proofreading one section of a book written in Typst markup.
Check the prose for grammar, spelling, punctuation, awkward or unclear phrasing,
and word repetition. Do not comment on content, argument, or citations.

Ignore Typst markup: `@key` and `~@key` are citations, `#textcite(<key>)` and similar
are function calls, `<label>` is a label, `_text_` is italics, `/ Term:` is a term list,
`//` starts a comment, and lines in `#let`/`#table` code are not prose. Never flag markup.

For each problem, return:
- quote: an exact, verbatim substring of the section (5-12 words) that ends right where the
  problem is. It must appear exactly once in the section. Copy it character for character.
- note: a brief description of the problem and a suggested fix (one sentence).

Only report real problems; an empty list is fine. Here is the section:

"""

SCHEMA = {
    "type": "object",
    "properties": {
        "notes": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "quote": {"type": "string"},
                    "note": {"type": "string"},
                },
                "required": ["quote", "note"],
            },
        }
    },
    "required": ["notes"],
}

HEADING = re.compile(r"^(=+) (.*?)\s*(<[^>]*>)?\s*$")


def sections(lines):
    """Yield (title, start, end) line ranges for each level-1/2 heading."""
    starts = []
    for i, line in enumerate(lines):
        m = HEADING.match(line)
        if m and len(m.group(1)) <= 2:
            starts.append((m.group(2), i))
    for n, (title, start) in enumerate(starts):
        end = starts[n + 1][1] if n + 1 < len(starts) else len(lines)
        yield title, start, end


def ask(text, model):
    result = subprocess.run(
        ["claude", "-p", "--model", model, "--output-format", "json",
         "--json-schema", json.dumps(SCHEMA), "--tools", "",
         "--no-session-persistence"],
        input=PROMPT + text, capture_output=True, text=True, check=True,
    )
    out = json.loads(result.stdout)
    data = out.get("structured_output") or json.loads(out["result"])
    return data["notes"]


def insert_notes(text, notes):
    """Insert each note after its quote. Returns (new_text, unplaced_notes)."""
    placed, unplaced = [], []
    for n in notes:
        quote = n["quote"].strip()
        if quote and text.count(quote) == 1:
            placed.append((text.index(quote) + len(quote), n["note"]))
        else:
            unplaced.append(n)
    # Insert from the end so earlier offsets stay valid.
    for pos, note in sorted(placed, reverse=True):
        note = note.replace("*/", "* /").replace("/*", "/ *").strip()
        text = text[:pos] + f" /* {TAG} {note} */" + text[pos:]
    return text, unplaced


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--section", help="only proofread the section with this exact title")
    ap.add_argument("--model", default="haiku")
    ap.add_argument("--dry-run", action="store_true", help="print notes without editing book.typ")
    args = ap.parse_args()

    lines = BOOK.read_text().splitlines(keepends=True)
    todo = [s for s in sections(lines) if args.section in (None, s[0])]
    if not todo:
        sys.exit(f"No section titled {args.section!r}")

    # Work from the last section backwards so earlier line ranges stay valid.
    for title, start, end in reversed(todo):
        body = "".join(lines[start:end])
        print(f"== {title} (lines {start + 1}-{end})", flush=True)
        notes = ask(body, args.model)
        new_body, unplaced = insert_notes(body, notes)
        for n in notes:
            mark = "  ?" if n in unplaced else "  -"
            print(f"{mark} \"{n['quote']}\": {n['note']}")
        if unplaced:
            print(f"  ({len(unplaced)} note(s) not placed: quote missing or ambiguous)")
        if not args.dry_run:
            lines[start:end] = [new_body]
            BOOK.write_text("".join(lines))


if __name__ == "__main__":
    main()
