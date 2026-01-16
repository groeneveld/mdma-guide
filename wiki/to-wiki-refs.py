#!/usr/bin/env python3
"""
Post-processor to convert LaTeX citations to Wikipedia-style refs.
Parses BibTeX directly and converts to Citation Style 1 templates with list-defined references.
"""

import re
import sys
from pathlib import Path


def parse_bibtex_file(bib_path):
    """
    Parse references.bib to extract all fields for each entry.
    Returns a dict mapping cite keys to entry dictionaries.
    """
    bib_content = bib_path.read_text(encoding='utf-8')
    entries = {}

    # Match BibTeX entries: @Type{key, field=value, ...}
    entry_pattern = re.compile(
        r'@(\w+)\{([^,]+),\s*(.*?)\n\}',
        re.DOTALL
    )

    for match in entry_pattern.finditer(bib_content):
        entry_type = match.group(1).lower()
        cite_key = match.group(2).strip()
        fields_text = match.group(3)

        # Parse fields
        fields = {'ENTRYTYPE': entry_type}

        # Match field = {value} or field = "value"
        field_pattern = re.compile(r'(\w+)\s*=\s*[{"]([^}"]*)[}"]', re.DOTALL)
        for field_match in field_pattern.finditer(fields_text):
            field_name = field_match.group(1).lower()
            field_value = field_match.group(2).strip()
            # Clean up whitespace
            field_value = re.sub(r'\s+', ' ', field_value)
            fields[field_name] = field_value

        entries[cite_key] = fields

    return entries


def format_author_name(author_str):
    """
    Parse a single author name from BibTeX format.
    Handles: "Last, First", "First Last", or single names.
    Returns (last, first) tuple.
    """
    author_str = author_str.strip()

    # Remove any {...} wrappers (e.g., {Author Redacted})
    author_str = re.sub(r'^\{(.+)\}$', r'\1', author_str)

    # Check for "Last, First" format
    if ',' in author_str:
        parts = author_str.split(',', 1)
        last = parts[0].strip()
        first = parts[1].strip() if len(parts) > 1 else ''
        return (last, first)

    # Check for "First Last" format
    parts = author_str.split()
    if len(parts) >= 2:
        first = ' '.join(parts[:-1])
        last = parts[-1]
        return (last, first)

    # Single name
    return (author_str, '')


def parse_authors(author_field):
    """
    Parse BibTeX author field into list of (last, first) tuples.
    BibTeX uses " and " to separate multiple authors.
    """
    if not author_field:
        return []

    authors = []
    # Split on " and " (BibTeX standard)
    author_list = re.split(r'\s+and\s+', author_field)

    for author_str in author_list:
        if author_str.strip():
            authors.append(format_author_name(author_str))

    return authors


def entry_to_cs1(entry):
    """
    Convert a BibTeX entry to Wikipedia CS1 template.
    Returns a {{cite journal}}, {{cite book}}, {{cite web}}, etc. template string.
    """
    entry_type = entry.get('ENTRYTYPE', '')

    # Determine citation template type
    if entry_type in ('online', 'misc', 'unpublished', 'report'):
        template_type = 'cite web'
    elif entry_type == 'reference':
        template_type = 'cite book'
    elif entry_type in ('article', 'periodical'):
        # Article with journal field -> cite journal
        # Article without journal -> cite web
        if entry.get('journal') or entry.get('journaltitle'):
            template_type = 'cite journal'
        else:
            template_type = 'cite web'
    elif entry_type in ('book', 'inbook', 'incollection', 'thesis', 'manual'):
        template_type = 'cite book'
    else:
        # Fallback heuristic
        if entry.get('journal') or entry.get('journaltitle'):
            template_type = 'cite journal'
        else:
            template_type = 'cite web'

    # Build template
    template_parts = [f'{{{{{template_type}']

    # Authors
    if 'author' in entry:
        authors = parse_authors(entry['author'])
        for i, (last, first) in enumerate(authors[:10], 1):  # Limit to 10
            if last:
                template_parts.append(f'|last{i}={last}')
            if first:
                template_parts.append(f'|first{i}={first}')

    # Editors (for books, references)
    if 'editor' in entry and not entry.get('author'):
        editors = parse_authors(entry['editor'])
        for i, (last, first) in enumerate(editors[:10], 1):
            if last:
                template_parts.append(f'|editor{i}-last={last}')
            if first:
                template_parts.append(f'|editor{i}-first={first}')

    # Year
    if 'year' in entry:
        template_parts.append(f'|year={entry["year"]}')

    # Title
    if 'title' in entry:
        title = entry['title']
        # Remove LaTeX formatting
        title = re.sub(r'\\textit\{([^}]+)\}', r'\1', title)
        title = re.sub(r'\\emph\{([^}]+)\}', r'\1', title)
        template_parts.append(f'|title={title}')

    # Journal (article or journaltitle field)
    journal = entry.get('journal') or entry.get('journaltitle')
    if journal:
        template_parts.append(f'|journal={journal}')

    # Volume
    if 'volume' in entry:
        template_parts.append(f'|volume={entry["volume"]}')

    # Issue/Number
    if 'number' in entry:
        template_parts.append(f'|issue={entry["number"]}')
    elif 'issue' in entry:
        template_parts.append(f'|issue={entry["issue"]}')

    # Pages
    if 'pages' in entry:
        template_parts.append(f'|pages={entry["pages"]}')

    # Publisher
    if 'publisher' in entry:
        template_parts.append(f'|publisher={entry["publisher"]}')

    # Institution (for reports)
    if 'institution' in entry:
        template_parts.append(f'|publisher={entry["institution"]}')

    # DOI
    if 'doi' in entry:
        template_parts.append(f'|doi={entry["doi"]}')

    # URL (only if no DOI)
    if 'url' in entry and 'doi' not in entry:
        template_parts.append(f'|url={entry["url"]}')

    # ISBN
    if 'isbn' in entry:
        template_parts.append(f'|isbn={entry["isbn"]}')

    return ''.join(template_parts) + '}}'


def main():
    if len(sys.argv) < 2:
        print("Usage: to-wiki-refs.py <mediawiki-file>")
        sys.exit(1)

    file_path = Path(sys.argv[1]).resolve()
    content = file_path.read_text(encoding='utf-8')

    # Parse references.bib
    bib_path = file_path.parent.parent / 'references.bib'
    if not bib_path.exists():
        print(f"Error: {bib_path} not found")
        sys.exit(1)

    bib_entries = parse_bibtex_file(bib_path)
    print(f"Loaded {len(bib_entries)} BibTeX entries from {bib_path.name}")

    # Generate CS1 templates for all entries
    cs1_templates = {}
    for cite_key, entry in bib_entries.items():
        cs1_templates[cite_key] = entry_to_cs1(entry)

    # Track which citations are used
    cite_used = set()

    def format_author_display(entry):
        """Format author names for inline citation (e.g., 'Smith')."""
        if 'author' not in entry:
            return None

        authors = parse_authors(entry['author'])
        if not authors:
            return None

        if len(authors) == 1:
            return authors[0][0]  # Just last name
        elif len(authors) == 2:
            return f'{authors[0][0]} and {authors[1][0]}'
        else:
            return f'{authors[0][0]}'

    def replace_citation(match):
        """Replace <<<CITE:key>>> placeholders with <ref> tags."""
        cite_keys_str = match.group(1)

        # Split multiple keys
        cite_keys = [k.strip() for k in cite_keys_str.split(',')]

        # Generate ref tags
        refs = []
        for cite_key in cite_keys:
            if cite_key in bib_entries:
                cite_used.add(cite_key)
                refs.append(f'<ref name="{cite_key}" />')
            else:
                print(f"Warning: Citation key '{cite_key}' not found in bibliography")
                refs.append(f'<<<CITE:{cite_key}>>>')  # Leave as-is if not found

        return ''.join(refs)

    def replace_textcitation(match):
        """Replace <<<TEXTCITE:key>>> with inline author name + <ref> tag."""
        cite_keys_str = match.group(1)

        # Split multiple keys (though textcite typically uses single keys)
        cite_keys = [k.strip() for k in cite_keys_str.split(',')]

        # Generate inline citations
        results = []
        for cite_key in cite_keys:
            if cite_key in bib_entries:
                cite_used.add(cite_key)
                entry = bib_entries[cite_key]
                author_display = format_author_display(entry)

                if author_display:
                    # Include year if available (check both 'year' and 'date' fields)
                    year = entry.get('year', '') or entry.get('date', '')
                    if year:
                        results.append(f'{author_display} ({year})<ref name="{cite_key}" />')
                    else:
                        results.append(f'{author_display}<ref name="{cite_key}" />')
                else:
                    # Fallback if no author
                    results.append(f'<ref name="{cite_key}" />')
            else:
                print(f"Warning: Citation key '{cite_key}' not found in bibliography")
                results.append(f'<<<TEXTCITE:{cite_key}>>>')  # Leave as-is if not found

        return ' '.join(results)

    # Replace &lt;&lt;&lt;CITE:key&gt;&gt;&gt; placeholders (HTML-escaped by pandoc)
    # Matches: &lt;&lt;&lt;CITE:key&gt;&gt;&gt; or &lt;&lt;&lt;CITE:key1,key2&gt;&gt;&gt;
    content = re.sub(
        r'&lt;&lt;&lt;CITE:([^&]+)&gt;&gt;&gt;',
        replace_citation,
        content
    )

    # Replace &lt;&lt;&lt;TEXTCITE:key&gt;&gt;&gt; placeholders
    content = re.sub(
        r'&lt;&lt;&lt;TEXTCITE:([^&]+)&gt;&gt;&gt;',
        replace_textcitation,
        content
    )

    # Remove any existing <references /> placeholder
    content = re.sub(r'<references\s*/>', '', content)

    # Build list-defined references section
    if cite_used:
        refs_section = '\n\n== References ==\n<references>\n'
        for cite_key in sorted(cite_used):
            refs_section += f'<ref name="{cite_key}">{cs1_templates[cite_key]}</ref>\n'
        refs_section += '</references>\n'

        content = content.rstrip() + refs_section

    # Write output
    file_path.write_text(content, encoding='utf-8')
    print(f"Converted {len(cite_used)} unique citations to CS1 templates")
    print(f"Output written to {file_path}")


if __name__ == '__main__':
    main()
