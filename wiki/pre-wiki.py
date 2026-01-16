#!/usr/bin/env python3
"""
Pre-processor to convert LaTeX citation commands to placeholders.
This prevents pandoc from stripping them.
"""

import re
import sys
from pathlib import Path


def main():
    if len(sys.argv) < 3:
        print("Usage: pre-wiki.py <input.tex> <output.tex>")
        sys.exit(1)

    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])

    content = input_path.read_text(encoding='utf-8')

    # Replace citation commands with placeholders
    # Handles: \cite{key}, \cite{key1,key2}, \textcite{key}, etc.

    # Pattern matches: \cite, \textcite, \parencite, \autocite, etc.
    # Captures the command type and citation keys
    def replace_cite(match):
        cmd_type = match.group(1) if match.group(1) else ''  # text, paren, auto, or empty
        keys = match.group(2)  # the keys
        if cmd_type == 'text':
            return f'<<<TEXTCITE:{keys}>>>'
        else:
            return f'<<<CITE:{keys}>>>'

    content = re.sub(
        r'\\(text|paren|auto)?cite\{([^}]+)\}',
        replace_cite,
        content
    )

    output_path.write_text(content, encoding='utf-8')
    print(f"Pre-processed {input_path.name} -> {output_path.name}")
    print(f"Converted LaTeX citations to placeholders")


if __name__ == '__main__':
    main()
