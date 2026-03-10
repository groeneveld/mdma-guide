#!/usr/bin/env python3
"""Print BibTeX entry keys that have a broken file link in references.bib."""

import re
import os

BIB_PATH = os.path.join(os.path.dirname(__file__), '..', 'references.bib')

entry_pattern = re.compile(r'^@\w+\{(\S+),', re.MULTILINE)
file_field_pattern = re.compile(r'file\s*=\s*\{([^}]*)\}', re.IGNORECASE)

with open(BIB_PATH, encoding='utf-8') as f:
    content = f.read()

# Split into entries
entries = re.split(r'(?=^@)', content, flags=re.MULTILINE)

for entry in entries:
    key_match = entry_pattern.match(entry)
    if not key_match:
        continue
    key = key_match.group(1).rstrip(',')

    file_match = file_field_pattern.search(entry)
    if not file_match:
        continue

    raw = file_match.group(1)
    parts = raw.split(':')
    paths = [p.strip() for p in parts if '/' in p]

    for path in paths:
        if not os.path.exists(path):
            print(f"{key}")
            break
