#!/usr/bin/env python3
"""
Script to link PDFs from Zotero storage to the bib file.
Cross-references using DOI and title matching.
"""

import sqlite3
import re
import shutil
import os
from pathlib import Path

# Paths
ZOTERO_DB = "/Users/markgroeneveld/Zotero/zotero.sqlite"
ZOTERO_STORAGE = "/Users/markgroeneveld/Zotero/storage"
BIB_FILE = "/Users/markgroeneveld/Library/Mobile Documents/com~apple~CloudDocs/mdma-guide/references.bib"
PAPERS_DIR = "/Users/markgroeneveld/Library/Mobile Documents/com~apple~CloudDocs/Papers/"
UNMATCHED_DIR = "/Users/markgroeneveld/Library/Mobile Documents/com~apple~CloudDocs/mdma-guide/unmatched"

def normalize_string(s):
    """Normalize string for fuzzy matching."""
    if not s:
        return ""
    # Remove special LaTeX characters and normalize
    s = re.sub(r'[{}\\]', '', s)
    s = re.sub(r'\s+', ' ', s)
    return s.lower().strip()

def get_zotero_items_with_pdfs():
    """Query Zotero database for items with DOIs/titles and file attachments."""
    conn = sqlite3.connect(ZOTERO_DB)
    cursor = conn.cursor()

    # Query to get DOI, title, and attachment path for items
    query = """
    SELECT
        LOWER(TRIM(doi_value.value)) as doi,
        title_value.value as title,
        ia.path as attachment_path
    FROM items i
    LEFT JOIN itemData doi_data ON i.itemID = doi_data.itemID AND doi_data.fieldID = 59
    LEFT JOIN itemDataValues doi_value ON doi_data.valueID = doi_value.valueID
    LEFT JOIN itemData title_data ON i.itemID = title_data.itemID AND title_data.fieldID = 1
    LEFT JOIN itemDataValues title_value ON title_data.valueID = title_value.valueID
    LEFT JOIN itemAttachments ia ON i.itemID = ia.parentItemID
    WHERE ia.path IS NOT NULL
        AND ia.path LIKE 'storage:%'
        AND title_value.value IS NOT NULL
    """

    cursor.execute(query)
    results = cursor.fetchall()
    conn.close()

    # Process results
    items_by_doi = {}
    items_by_title = {}

    for doi, title, path in results:
        if not path or not title:
            continue

        # Parse path (format: "storage:filename.pdf")
        if not path.startswith("storage:"):
            continue

        filename = path.replace("storage:", "")

        item = {
            'title': title,
            'filename': filename,
            'doi': doi
        }

        # Index by DOI if available
        if doi:
            doi_clean = doi.strip().lower()
            doi_clean = re.sub(r'^https?://doi.org/', '', doi_clean)
            doi_clean = re.sub(r'^doi:', '', doi_clean)
            items_by_doi[doi_clean] = item

        # Also index by normalized title
        title_norm = normalize_string(title)
        if title_norm:
            items_by_title[title_norm] = item

    return items_by_doi, items_by_title

def parse_bib_file():
    """Parse the bib file to extract entries with their DOIs, titles, and citation keys."""
    with open(BIB_FILE, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split into entries - look for @type{key,
    entries = []

    # Find all entry starts
    entry_starts = []
    for match in re.finditer(r'@(\w+)\s*\{([^,\s]+)\s*,', content):
        entry_starts.append({
            'start': match.start(),
            'type': match.group(1),
            'key': match.group(2),
            'header_end': match.end()
        })

    # For each entry, find its closing brace
    for i, entry in enumerate(entry_starts):
        start = entry['start']

        # Find the matching closing brace
        # We need to count braces from the entry start
        brace_count = 0
        in_entry = False
        pos = start

        while pos < len(content):
            char = content[pos]

            if char == '{':
                brace_count += 1
                in_entry = True
            elif char == '}':
                brace_count -= 1
                if in_entry and brace_count == 0:
                    # Found the closing brace
                    entry['end'] = pos + 1
                    break

            pos += 1

        if 'end' not in entry:
            # Entry extends to end of file or next entry
            if i + 1 < len(entry_starts):
                entry['end'] = entry_starts[i + 1]['start']
            else:
                entry['end'] = len(content)

        # Extract the entry content
        entry_text = content[start:entry['end']]
        entry['full_text'] = entry_text

        # Extract fields
        entry_body = content[entry['header_end']:entry['end']]

        # Extract DOI
        doi_match = re.search(r'doi\s*=\s*\{([^}]+)\}', entry_body, re.IGNORECASE)
        entry['doi'] = None
        if doi_match:
            doi = doi_match.group(1).strip().lower()
            doi = re.sub(r'^https?://doi.org/', '', doi)
            doi = re.sub(r'^doi:', '', doi)
            entry['doi'] = doi

        # Extract title
        title_match = re.search(r'title\s*=\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}', entry_body, re.IGNORECASE)
        entry['title'] = None
        entry['title_normalized'] = None
        if title_match:
            entry['title'] = title_match.group(1)
            entry['title_normalized'] = normalize_string(title_match.group(1))

        # Check if file field already exists
        entry['has_file'] = bool(re.search(r'\bfile\s*=', entry_body, re.IGNORECASE))

        entries.append(entry)

    return entries, content

def find_pdf_in_storage(filename):
    """Find the actual PDF file in Zotero storage."""
    for subdir in os.listdir(ZOTERO_STORAGE):
        subdir_path = os.path.join(ZOTERO_STORAGE, subdir)
        if os.path.isdir(subdir_path):
            pdf_path = os.path.join(subdir_path, filename)
            if os.path.exists(pdf_path):
                return pdf_path
    return None

def sanitize_filename(filename):
    """Sanitize filename for safe copying."""
    filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
    return filename

def main():
    print("Fetching items from Zotero database...")
    zotero_by_doi, zotero_by_title = get_zotero_items_with_pdfs()
    print(f"Found {len(zotero_by_doi)} items with DOIs and attachments")
    print(f"Found {len(zotero_by_title)} items with titles and attachments")

    # Create a combined list of all unique Zotero items for tracking
    all_zotero_items = {}
    for doi, item in zotero_by_doi.items():
        all_zotero_items[item['filename']] = item
    for title, item in zotero_by_title.items():
        all_zotero_items[item['filename']] = item

    print("\nParsing bib file...")
    bib_entries, bib_content = parse_bib_file()
    print(f"Found {len(bib_entries)} entries in bib file")

    # Match and process
    matches = []
    matched_zotero = set()  # Track Zotero items that correspond to bib entries

    for entry in bib_entries:
        zotero_item = None
        match_method = None

        # Try DOI match first
        if entry['doi'] and entry['doi'] in zotero_by_doi:
            zotero_item = zotero_by_doi[entry['doi']]
            match_method = 'DOI'
        # Fall back to title match
        elif entry['title_normalized'] and entry['title_normalized'] in zotero_by_title:
            zotero_item = zotero_by_title[entry['title_normalized']]
            match_method = 'title'

        if zotero_item:
            # Track this Zotero item as matched (even if we're not processing it)
            pdf_key = zotero_item['filename']
            if pdf_key not in matched_zotero:
                matched_zotero.add(pdf_key)

            # Only process if it doesn't already have a file field
            if not entry['has_file']:
                matches.append({
                    'entry': entry,
                    'zotero_item': zotero_item,
                    'match_method': match_method
                })

    print(f"\nFound {len(matches)} matches to process")
    print(f"  - DOI matches: {sum(1 for m in matches if m['match_method'] == 'DOI')}")
    print(f"  - Title matches: {sum(1 for m in matches if m['match_method'] == 'title')}")

    # Copy files and prepare updates
    updates = []
    for match in matches:
        entry = match['entry']
        zotero_item = match['zotero_item']
        match_method = match['match_method']

        # Find file in storage
        file_source = find_pdf_in_storage(zotero_item['filename'])
        if not file_source:
            print(f"Warning: Could not find file for {entry['key']}: {zotero_item['filename']}")
            continue

        # Use the original filename from Zotero (sanitized for safety)
        safe_filename = sanitize_filename(zotero_item['filename'])
        file_dest = os.path.join(PAPERS_DIR, safe_filename)

        # Copy file
        try:
            shutil.copy2(file_source, file_dest)
            print(f"Copied ({match_method}): {entry['key']} -> papers/{safe_filename}")

            updates.append({
                'entry': entry,
                'filename': safe_filename
            })
        except Exception as e:
            print(f"Error copying {entry['key']}: {e}")

    # Update bib file
    if updates:
        print(f"\nUpdating bib file with {len(updates)} file links...")

        # Process updates in reverse order to maintain positions
        updates.sort(key=lambda x: x['entry']['start'], reverse=True)

        new_content = bib_content

        for update in updates:
            entry = update['entry']
            filename = update['filename']

            # Find where to insert the file field
            # We want to insert before the final closing brace
            entry_start = entry['start']
            entry_end = entry['end']

            # Get the entry text
            entry_text = new_content[entry_start:entry_end]

            # Find the last closing brace
            last_brace = entry_text.rfind('}')
            if last_brace == -1:
                print(f"Warning: Could not find closing brace for {entry['key']}, skipping")
                continue

            # Check what comes before the closing brace
            before_brace = entry_text[:last_brace].rstrip()

            # Determine if we need to add a comma
            needs_comma = before_brace and not before_brace.endswith(',')

            # Build the new entry content - strip trailing whitespace to avoid empty lines
            content_before_brace = entry_text[:last_brace].rstrip()

            # Use full path for file field
            file_path = ":" + PAPERS_DIR + filename + ":"

            if needs_comma:
                # Add comma to end of last line, then add file field
                new_entry = content_before_brace + ",\n  file = {" + file_path + "}\n}"
            else:
                # Just add file field without comma
                new_entry = content_before_brace + "\n  file = {" + file_path + "}\n}"

            # Update the content
            new_content = new_content[:entry_start] + new_entry + new_content[entry_end:]

        # Write updated bib file
        with open(BIB_FILE, 'w', encoding='utf-8') as f:
            f.write(new_content)

        print(f"Successfully updated {len(updates)} entries in bib file")
    else:
        print("\nNo updates to make")

    # Report unmatched Zotero items and copy to unmatched folder
    unmatched = []
    for filename, item in all_zotero_items.items():
        if filename not in matched_zotero:
            unmatched.append(item)

    if unmatched:
        # Create unmatched directory if it doesn't exist
        os.makedirs(UNMATCHED_DIR, exist_ok=True)

        print(f"\n{'='*80}")
        print(f"UNMATCHED ZOTERO ENTRIES ({len(unmatched)} items with PDFs not found in bib file):")
        print(f"{'='*80}")

        copied_count = 0
        for item in sorted(unmatched, key=lambda x: x['title'] or ''):
            print(f"\nTitle: {item['title']}")
            if item['doi']:
                print(f"  DOI: {item['doi']}")
            print(f"  File: {item['filename']}")

            # Find and copy the PDF to unmatched folder
            pdf_source = find_pdf_in_storage(item['filename'])
            if pdf_source:
                pdf_dest = os.path.join(UNMATCHED_DIR, item['filename'])
                try:
                    shutil.copy2(pdf_source, pdf_dest)
                    print(f"  -> Copied to unmatched/{item['filename']}")
                    copied_count += 1
                except Exception as e:
                    print(f"  -> Error copying: {e}")
            else:
                print(f"  -> Warning: Could not find PDF in storage")

        print(f"\n{'='*80}")
        print(f"Copied {copied_count}/{len(unmatched)} unmatched PDFs to unmatched/")
        print(f"{'='*80}")
    else:
        print("\nAll Zotero items with PDFs were matched!")

    print("\nDone!")

if __name__ == '__main__':
    main()
