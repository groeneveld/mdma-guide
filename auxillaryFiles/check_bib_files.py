#!/usr/bin/env python3
"""
Script to verify that references.bib and references_backup.bib are identical
except for the addition of the 'file' field.
"""

import re
import sys
from typing import Dict, List, Tuple


def parse_bib_file(filename: str) -> Dict[str, Dict[str, str]]:
    """
    Parse a BibTeX file and return a dictionary of entries.
    Each entry maps citation key to a dictionary of field-value pairs.
    """
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()

    entries = {}

    # Pattern to match BibTeX entries: @type{key, ... }
    # This regex finds the entry type and key
    entry_pattern = r'@(\w+)\{([^,]+),\s*\n'

    # Find all entry starts
    matches = list(re.finditer(entry_pattern, content))

    for i, match in enumerate(matches):
        entry_type = match.group(1)
        cite_key = match.group(2)

        # Find the content between this entry and the next one (or end of file)
        start_pos = match.end()
        if i + 1 < len(matches):
            end_pos = matches[i + 1].start()
        else:
            end_pos = len(content)

        entry_content = content[start_pos:end_pos]

        # Find the closing brace for this entry
        brace_count = 1
        actual_end = 0
        for j, char in enumerate(entry_content):
            if char == '{':
                brace_count += 1
            elif char == '}':
                brace_count -= 1
                if brace_count == 0:
                    actual_end = j
                    break

        entry_content = entry_content[:actual_end]

        # Parse fields from the entry content
        fields = {'__type__': entry_type}

        # Pattern to match field = {value} or field = value
        field_pattern = r'(\w+)\s*=\s*\{([^}]*)\}|(\w+)\s*=\s*([^,\n]+)'

        for field_match in re.finditer(field_pattern, entry_content):
            if field_match.group(1):  # Braced value
                field_name = field_match.group(1).lower()
                field_value = field_match.group(2).strip()
            else:  # Unbraced value
                field_name = field_match.group(3).lower()
                field_value = field_match.group(4).strip()

            fields[field_name] = field_value

        entries[cite_key] = fields

    return entries


def normalize_whitespace(text: str) -> str:
    """Normalize whitespace in text for comparison."""
    return ' '.join(text.split())


def compare_entries(entries1: Dict[str, Dict[str, str]],
                   entries2: Dict[str, Dict[str, str]],
                   ignore_fields: set = {'file'}) -> Tuple[bool, List[str]]:
    """
    Compare two sets of BibTeX entries, ignoring specified fields.
    Returns (is_same, list_of_differences).
    """
    differences = []

    # Check for entries in file1 but not in file2
    keys1 = set(entries1.keys())
    keys2 = set(entries2.keys())

    only_in_1 = keys1 - keys2
    only_in_2 = keys2 - keys1

    if only_in_1:
        differences.append(f"Entries only in references.bib: {sorted(only_in_1)}")

    if only_in_2:
        differences.append(f"Entries only in references_backup.bib: {sorted(only_in_2)}")

    # Compare common entries
    common_keys = keys1 & keys2

    for key in sorted(common_keys):
        entry1 = entries1[key]
        entry2 = entries2[key]

        # Get all fields from both entries, excluding ignored fields
        fields1 = {k: v for k, v in entry1.items() if k not in ignore_fields}
        fields2 = {k: v for k, v in entry2.items() if k not in ignore_fields}

        fields1_keys = set(fields1.keys())
        fields2_keys = set(fields2.keys())

        # Check for field differences
        only_in_entry1 = fields1_keys - fields2_keys
        only_in_entry2 = fields2_keys - fields1_keys

        if only_in_entry1:
            differences.append(
                f"Entry '{key}': fields only in references.bib: {sorted(only_in_entry1)}"
            )

        if only_in_entry2:
            differences.append(
                f"Entry '{key}': fields only in references_backup.bib: {sorted(only_in_entry2)}"
            )

        # Compare common field values
        common_fields = fields1_keys & fields2_keys

        for field in sorted(common_fields):
            val1 = normalize_whitespace(fields1[field])
            val2 = normalize_whitespace(fields2[field])

            if val1 != val2:
                differences.append(
                    f"Entry '{key}', field '{field}': values differ\n"
                    f"  references.bib: {val1[:100]}...\n"
                    f"  references_backup.bib: {val2[:100]}..."
                )

    # Check for file field presence
    file_in_backup_count = sum(1 for entry in entries2.values() if 'file' in entry)
    file_in_main_count = sum(1 for entry in entries1.values() if 'file' in entry)

    is_same = len(differences) == 0

    return is_same, differences, file_in_main_count, file_in_backup_count


def main():
    """Main function to compare the two bib files."""
    file1 = "references.bib"
    file2 = "references_backup.bib"

    print("Parsing BibTeX files...")
    print(f"  Reading {file1}...")
    entries1 = parse_bib_file(file1)
    print(f"    Found {len(entries1)} entries")

    print(f"  Reading {file2}...")
    entries2 = parse_bib_file(file2)
    print(f"    Found {len(entries2)} entries")

    print("\nComparing entries (ignoring 'file' field)...")
    is_same, differences, file_count_main, file_count_backup = compare_entries(entries1, entries2)

    print(f"\nFile field statistics:")
    print(f"  Entries with 'file' field in {file1}: {file_count_main}")
    print(f"  Entries with 'file' field in {file2}: {file_count_backup}")

    if is_same:
        print("\n✓ SUCCESS: The files are identical except for the 'file' field!")
        return 0
    else:
        print(f"\n✗ DIFFERENCES FOUND: {len(differences)} issue(s) detected")
        print("\nDetails:")
        for i, diff in enumerate(differences, 1):
            print(f"\n{i}. {diff}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
