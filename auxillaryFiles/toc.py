#!/usr/bin/env python3
"""Generate auxillaryFiles/tableofcontents.md from book.typ.

Asks Typst for every heading in the compiled document, including the ones
with outlined: false, so headings hidden from the PDF TOC are listed as well.
"""

import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "book.typ"
FONTS = ROOT / "auxillaryFiles" / "fonts"
OUTPUT = ROOT / "auxillaryFiles" / "tableofcontents.md"


def query_headings():
    """Return the document's headings as Typst's JSON serialization."""
    result = subprocess.run(
        ["typst", "eval", "query(heading)", "--in", str(SOURCE),
         "--root", str(ROOT), "--font-path", str(FONTS)],
        check=True, capture_output=True, text=True,
    )
    return json.loads(result.stdout)


def plain(content):
    """Convert serialized Typst content to plain text."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "".join(plain(c) for c in content)
    if not isinstance(content, dict):
        return ""
    func = content.get("func")
    if func == "space":
        return " "
    if func == "smartquote":
        return '"' if content.get("double", True) else "'"
    if func in ("text", "symbol"):
        return content.get("text", "").replace(" ", " ").replace(" ", " ")
    for key in ("children", "body", "child"):
        if key in content:
            return plain(content[key])
    return ""


def main():
    lines = ["# Table of Contents", ""]
    parents = []  # levels of the enclosing headings, so skipped levels don't over-indent
    for heading in query_headings():
        level = heading["level"]
        while parents and parents[-1] >= level:
            parents.pop()
        title = " ".join(plain(heading["body"]).split())
        lines.append("  " * len(parents) + "- " + title)
        parents.append(level)

    OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
