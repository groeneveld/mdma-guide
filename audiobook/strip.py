#!/usr/bin/env python3
"""
Strip footnotes, citations, and float environments from LaTeX for audiobook generation.

Removes:
- \footnote{...} (entire command and content, handles nested braces)
- \cite{...} (optional arguments also stripped: \cite[p. 12]{key})
- \begin{figure}...\end{figure}
- \begin{table}...\end{table}
- \begin{longtable}...\end{longtable}

Usage:
    python3 strip.py [input_file] [output_file]

    Default input:  temp/paper_expanded.tex
    Default output: temp/paper_audiobook.tex
"""

import re
import sys
from pathlib import Path


def strip_brace_command(text, command):
    """
    Remove all occurrences of \\command[...]{...} from text.
    Handles nested braces. Optional [...] argument is also removed.
    Returns the cleaned text and a count of removals.
    """
    result = []
    count = 0
    i = 0
    cmd = '\\' + command
    while i < len(text):
        idx = text.find(cmd, i)
        if idx == -1:
            result.append(text[i:])
            break

        # Make sure it's not a longer command (e.g. \citeauthor matching \cite)
        end_of_cmd = idx + len(cmd)
        if end_of_cmd < len(text) and text[end_of_cmd].isalpha():
            # Part of a longer command name, skip
            result.append(text[i:idx + 1])
            i = idx + 1
            continue

        result.append(text[i:idx])
        j = end_of_cmd

        # Skip optional argument [...] if present
        while j < len(text) and text[j] in ' \t':
            j += 1
        if j < len(text) and text[j] == '[':
            bracket_count = 1
            j += 1
            while j < len(text) and bracket_count > 0:
                if text[j] == '[':
                    bracket_count += 1
                elif text[j] == ']':
                    bracket_count -= 1
                j += 1

        # Skip whitespace before {
        while j < len(text) and text[j] in ' \t':
            j += 1

        # Skip required argument {...} if present
        if j < len(text) and text[j] == '{':
            brace_count = 1
            j += 1
            while j < len(text) and brace_count > 0:
                if text[j] == '{':
                    brace_count += 1
                elif text[j] == '}':
                    brace_count -= 1
                j += 1
            count += 1
            i = j
        else:
            # No braces — bare command (e.g. \multicitedelim), just remove the command name
            count += 1
            i = j

    return ''.join(result), count


def strip_environment(text, env_name):
    """
    Remove all occurrences of \\begin{env}...\\end{env} from text.
    Returns the cleaned text and a count of removals.
    """
    begin_tag = f'\\begin{{{env_name}}}'
    end_tag = f'\\end{{{env_name}}}'
    result = []
    count = 0
    i = 0
    while i < len(text):
        idx = text.find(begin_tag, i)
        if idx == -1:
            result.append(text[i:])
            break
        result.append(text[i:idx])
        end_idx = text.find(end_tag, idx)
        if end_idx == -1:
            # Unmatched \begin — leave the rest as-is
            result.append(text[idx:])
            break
        count += 1
        i = end_idx + len(end_tag)
    return ''.join(result), count


def process_file(input_path, output_path):
    input_path = Path(input_path)
    output_path = Path(output_path)

    if not input_path.exists():
        print(f"Error: Input file not found at {input_path}")
        sys.exit(1)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(input_path, 'r', encoding='utf-8') as f:
        content = f.read()

    total = 0

    content, n = strip_brace_command(content, 'footnote')
    print(f"  \\footnote: {n} removed")
    total += n

    content, n = strip_brace_command(content, 'cite')
    print(f"  \\cite: {n} removed")
    total += n

    content = content.replace('\\printbibliography', '')
    print(f"  \\printbibliography: removed")

    for env in ('figure', 'table', 'longtable'):
        content, n = strip_environment(content, env)
        print(f"  {env}: {n} removed")
        total += n

    # Clean up double spaces and space-before-punctuation left by removals
    content = re.sub(r'  +', ' ', content)
    content = re.sub(r' ([,\.;:])', r'\1', content)

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"\nTotal removed: {total}")
    print(f"Output written to: {output_path}")


def main():
    input_file = sys.argv[1] if len(sys.argv) > 1 else "temp/paper_expanded.tex"
    output_file = sys.argv[2] if len(sys.argv) > 2 else "temp/paper_audiobook.tex"

    print("Stripping footnotes and citations for audiobook")
    print("=" * 50)
    process_file(input_file, output_file)
    print("Done!")


if __name__ == "__main__":
    main()
