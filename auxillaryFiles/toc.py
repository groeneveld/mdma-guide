#!/usr/bin/env python3
"""Generate tableofcontents.md from paper.tex.

Includes \\chapter, \\section, \\subsection, and \\subsubsection, both starred
and unstarred, so headings hidden from the PDF TOC are listed as well.
"""

import re

SOURCE = "paper.tex"
OUTPUT = "tableofcontents.md"

LEVELS = {"chapter": 0, "section": 1, "subsection": 2, "subsubsection": 3}
HEADING = re.compile(r"\\(chapter|section|subsection|subsubsection)\*?\s*(?:\[[^\]]*\])?\s*\{")


def strip_comment(line):
    """Remove an unescaped % comment from a line."""
    return re.sub(r"(?<!\\)%.*", "", line)


def read_group(text, start):
    """Return the contents of the brace group whose '{' is at text[start-1]."""
    depth = 1
    i = start
    while i < len(text) and depth:
        if text[i] == "\\":
            i += 2
            continue
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
        i += 1
    return text[start:i - 1]


def clean(title):
    """Convert simple LaTeX markup in a heading to plain text."""
    title = re.sub(r"\\(?:,|;|:|!|\s)", " ", title)
    title = title.replace("~", " ").replace("--", "–")
    command = re.compile(r"\\(?:[a-zA-Z]+)\*?(?:\[[^\]]*\])?\{([^{}]*)\}")
    while command.search(title):
        title = command.sub(r"\1", title)
    title = re.sub(r"\\([&%$#_{}])", r"\1", title)
    title = re.sub(r"\\[a-zA-Z]+\*?", "", title)
    title = title.replace("{", "").replace("}", "")
    return re.sub(r"\s+", " ", title).strip()


def main():
    with open(SOURCE, encoding="utf-8") as f:
        text = "\n".join(strip_comment(line) for line in f.read().splitlines())

    begin = text.find("\\begin{document}")
    end = text.find("\\end{document}")
    text = text[begin if begin >= 0 else 0:end if end >= 0 else len(text)]

    lines = ["# Table of Contents", ""]
    parents = []  # levels of the enclosing headings, so skipped levels don't over-indent
    for m in HEADING.finditer(text):
        level = LEVELS[m.group(1)]
        while parents and parents[-1] >= level:
            parents.pop()
        title = clean(read_group(text, m.end()))
        lines.append("  " * len(parents) + "- " + title)
        parents.append(level)

    with open(OUTPUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
