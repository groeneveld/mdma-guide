#!/usr/bin/env python3
"""
Expand LaTeX custom reference commands for EPUB conversion.

This script takes paper.tex and expands:
- \cref{label} -> formatted reference (e.g., "Section 2.1")
- \cref{label1,label2} -> "Section 2.1 and Section 3.4"
- \combinedref{label} -> "number (title)"
- \combinedcref{label} -> "formatted (title)"
- \prosecite{key} -> "Title by Author [citation_number]"
- \textcite{key} -> "LastName \cite{key}" (for EPUB: "Smith [24]")
- \textcite{key1,key2,...} -> \parencite{key1,key2,...} (multi-key only)

Output is written to temp/paper_expanded.tex

Usage:
    python3 expand_refs.py [input_file] [output_file]

    Default input: paper.tex
    Default output: temp/paper_expanded.tex

The script requires:
    - temp/Open MDMA.aux (LaTeX auxiliary file with label information)
    - temp/Open MDMA.bbl (BibLaTeX bibliography file)

Example:
    ./build.sh                          # Generate .aux and .bbl files
    python3 expand_refs.py              # Expand references
    pandoc temp/paper_expanded.tex -o book.epub  # Convert to EPUB
"""

import re
import sys
from pathlib import Path


class AuxParser:
    """Parse LaTeX .aux file for label information."""

    def __init__(self, aux_path):
        self.aux_path = Path(aux_path)
        self.labels = {}  # label -> {number, page, title}
        self.cref_labels = {}  # label -> formatted reference

    def parse(self):
        """Parse the .aux file and extract label information."""
        if not self.aux_path.exists():
            print(f"Warning: .aux file not found at {self.aux_path}")
            return

        with open(self.aux_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Parse regular \newlabel entries
        # Format: \newlabel{label}{{number}{page}{title}{anchor}{}}
        label_pattern = r'\\newlabel\{([^}]+)\}\{\{([^}]*)\}\{([^}]*)\}\{([^}]*)\}'
        for match in re.finditer(label_pattern, content):
            label_name = match.group(1)
            if label_name.endswith('@cref'):
                continue  # Skip cref labels here

            number = match.group(2)
            page = match.group(3)
            title = match.group(4)

            self.labels[label_name] = {
                'number': number,
                'page': page,
                'title': title
            }

        # Parse \newlabel{label@cref} entries for cleveref
        # Format: \newlabel{label@cref}{{[type][num1][num2]number}{...}{title}{...}{}}
        # Example: \newlabel{essentials@cref}{{[section][1][2]2.1}{...}}
        # Example: \newlabel{internalizedReports@cref}{{[appendix][1][]A}{...}}
        cref_pattern = r'\\newlabel\{([^@}]+)@cref\}\{\{(\[([^\]]+)\][^\}]*?)([A-Z0-9]+(?:\.[0-9]+)*)\}'
        for match in re.finditer(cref_pattern, content):
            label_name = match.group(1)
            ref_type = match.group(3)  # e.g., "section", "chapter", "table", "appendix"
            number = match.group(4)     # e.g., "2.1", "3", "A", "B"

            # Format as "Section 2.1", "Chapter 3", "Table 1", "Appendix A", etc.
            formatted = f"{ref_type.capitalize()} {number}"
            self.cref_labels[label_name] = formatted

        print(f"Parsed {len(self.labels)} labels and {len(self.cref_labels)} cref labels from .aux file")


class BblParser:
    """Parse LaTeX .bbl file for bibliography information."""

    def __init__(self, bbl_path):
        self.bbl_path = Path(bbl_path)
        self.entries = {}  # key -> {title, authors, number, first_author_family}
        self.citation_counter = 0

    def _extract_field(self, field_name, content):
        """Extract a field value from bbl content, handling nested braces."""
        # Pattern to find: \field{fieldname}{
        pattern = f'\\field{{{field_name}}}{{'
        start_idx = content.find(pattern)
        if start_idx == -1:
            return None

        # Find the matching closing brace
        start_idx += len(pattern)
        brace_count = 1
        i = start_idx
        while i < len(content) and brace_count > 0:
            if content[i] == '{':
                brace_count += 1
            elif content[i] == '}':
                brace_count -= 1
            i += 1

        if brace_count == 0:
            return content[start_idx:i-1]
        return None

    def _clean_latex(self, text):
        """Remove LaTeX formatting from text."""
        if not text:
            return text
        # Remove braces used for case protection
        text = re.sub(r'\{([^}]*)\}', r'\1', text)
        # Remove common LaTeX commands but keep their content
        text = re.sub(r'\\textit\{([^}]*)\}', r'\1', text)
        text = re.sub(r'\\textbf\{([^}]*)\}', r'\1', text)
        text = re.sub(r'\\emph\{([^}]*)\}', r'\1', text)
        return text

    def parse(self):
        """Parse the .bbl file and extract bibliography entries."""
        if not self.bbl_path.exists():
            print(f"Warning: .bbl file not found at {self.bbl_path}")
            return

        with open(self.bbl_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Split into entry blocks
        entry_pattern = r'\\entry\{([^}]+)\}\{[^}]+\}\{[^}]*\}\{[^}]*\}(.*?)(?=\\entry\{|\\enddatalist|$)'

        for match in re.finditer(entry_pattern, content, re.DOTALL):
            key = match.group(1)
            entry_content = match.group(2)

            # Extract title
            title = self._extract_field('title', entry_content)
            title = self._clean_latex(title) if title else key

            # Extract authors (returns tuple: formatted_string, first_family_name)
            authors, first_family = self._extract_authors(entry_content)

            # Increment citation counter for each unique entry
            self.citation_counter += 1

            self.entries[key] = {
                'title': title,
                'authors': authors,
                'number': self.citation_counter,
                'first_author_family': first_family
            }

        print(f"Parsed {len(self.entries)} bibliography entries from .bbl file")

    def _extract_field_from_author(self, field_name, author_block):
        """Extract a field value from author block, handling nested braces."""
        pattern = f'{field_name}={{'
        start_idx = author_block.find(pattern)
        if start_idx == -1:
            return None

        # Find the matching closing brace
        start_idx += len(pattern)
        brace_count = 1
        i = start_idx
        while i < len(author_block) and brace_count > 0:
            if author_block[i] == '{':
                brace_count += 1
            elif author_block[i] == '}':
                brace_count -= 1
            i += 1

        if brace_count == 0:
            value = author_block[start_idx:i-1]
            # Remove outer braces if present (for institutional names like {{Psychedelics in Recovery}})
            if value.startswith('{') and value.endswith('}'):
                value = value[1:-1]
            return value
        return None

    def _extract_authors(self, entry_content):
        """Extract author names from a bibliography entry. Returns (formatted_string, first_family_name)."""
        authors = []
        first_family = None

        # Find the author name block
        author_block_match = re.search(r'\\name\{author\}\{(\d+)\}\{[^}]*\}\{(.*?)\}(?=\s*\\strng)',
                                       entry_content, re.DOTALL)
        if not author_block_match:
            return "Unknown Author", None

        num_authors = int(author_block_match.group(1))
        author_block = author_block_match.group(2)

        # Split into individual author entries by looking for hash= markers
        author_entries = re.split(r'(?=\{[^}]*hash=)', author_block)

        for i, entry in enumerate(author_entries):
            if not entry.strip():
                continue

            # Extract family and given names using nested brace handling
            family = self._extract_field_from_author('family', entry)
            given = self._extract_field_from_author('given', entry)

            if family:
                # Store first author's family name
                if first_family is None:
                    first_family = family

                if given:
                    # Regular author with given and family names
                    authors.append(f"{given} {family}")
                else:
                    # Institutional author (family only)
                    authors.append(family)

        if not authors:
            return "Unknown Author", None

        # Format author list
        if len(authors) == 1:
            formatted = authors[0]
        elif len(authors) == 2:
            formatted = f"{authors[0]} and {authors[1]}"
        else:
            # For 3+ authors, use first author et al.
            formatted = f"{authors[0]} et al."

        return formatted, first_family

    def get_first_author_lastname(self, key):
        """Get the last name of the first author for a bibliography entry."""
        if key not in self.entries:
            return None

        # Return the stored first author family name
        return self.entries[key].get('first_author_family')

    def get_citation_text(self, key):
        """Get the full citation text for a bibliography key."""
        if key not in self.entries:
            return f"[UNKNOWN: {key}]"

        entry = self.entries[key]
        return f"{entry['title']} by {entry['authors']} [{entry['number']}]"


class RefExpander:
    """Expand custom reference commands in LaTeX source."""

    def __init__(self, aux_parser, bbl_parser):
        self.aux = aux_parser
        self.bbl = bbl_parser

    def expand_cref(self, match):
        """Expand \cref{label} command, handling comma-separated references."""
        labels_str = match.group(1)
        labels = [l.strip() for l in labels_str.split(',')]

        if len(labels) == 1:
            # Single reference with hyperlink
            label = labels[0]
            if label in self.aux.cref_labels:
                text = self.aux.cref_labels[label]
                return f"\\hyperref[{label}]{{{text}}}"
            elif label in self.aux.labels:
                text = self.aux.labels[label]['number']
                return f"\\hyperref[{label}]{{{text}}}"
            else:
                return f"\\cref{{{label}}}"
        else:
            # Multiple references - expand each with hyperlinks and join
            expanded = []
            for label in labels:
                if label in self.aux.cref_labels:
                    text = self.aux.cref_labels[label]
                    expanded.append(f"\\hyperref[{label}]{{{text}}}")
                elif label in self.aux.labels:
                    text = self.aux.labels[label]['number']
                    expanded.append(f"\\hyperref[{label}]{{{text}}}")
                else:
                    expanded.append(f"[REF:{label}]")

            # Join with commas and "and" for the last one
            if len(expanded) == 2:
                return f"{expanded[0]} and {expanded[1]}"
            else:
                return ', '.join(expanded[:-1]) + f', and {expanded[-1]}'

    def expand_combinedref(self, match):
        """Expand \combinedref{label} command with hyperlink."""
        label = match.group(1)
        if label in self.aux.labels:
            info = self.aux.labels[label]
            number = info['number']
            title = info['title']
            return f"\\hyperref[{label}]{{{number} ({title})}}"
        else:
            return f"\\combinedref{{{label}}}"  # Keep original if not found

    def expand_combinedcref(self, match):
        """Expand \combinedcref{label} command with hyperlink."""
        label = match.group(1)
        formatted = self.aux.cref_labels.get(label, self.aux.labels.get(label, {}).get('number', label))
        title = self.aux.labels.get(label, {}).get('title', '')

        if title:
            return f"\\hyperref[{label}]{{{formatted} ({title})}}"
        else:
            return f"\\combinedcref{{{label}}}"  # Keep original if not found

    def expand_prosecite(self, match):
        """Expand \prosecite{key} command with regular citation."""
        key = match.group(1)
        if key not in self.bbl.entries:
            return f"[UNKNOWN: {key}]"

        entry = self.bbl.entries[key]
        # Use regular \cite for consistent citation formatting
        return f"{entry['title']} by {entry['authors']} \\cite{{{key}}}"

    def expand_textcite(self, match):
        """
        Expand \textcite{key1,key2,...} commands.

        Single-key textcite: Convert to "LastName \cite{key}" for EPUB
        Multi-key textcite: Convert to \parencite for proper parenthetical formatting
        """
        keys_str = match.group(1)
        keys = [k.strip() for k in keys_str.split(',')]

        if len(keys) == 1:
            # Single key - convert to "LastName \cite{key}"
            key = keys[0]
            lastname = self.bbl.get_first_author_lastname(key)
            if lastname:
                return f"{lastname} \\cite{{{key}}}"
            else:
                # Fallback if author not found
                return f"\\cite{{{key}}}"
        else:
            # Multiple keys - convert to parencite for proper formatting
            # This ensures proper linking and punctuation in EPUB output
            return f"\\parencite{{{keys_str}}}"

    def process_file(self, input_path, output_path):
        """Process input file and write expanded version to output."""
        input_path = Path(input_path)
        output_path = Path(output_path)

        if not input_path.exists():
            print(f"Error: Input file not found at {input_path}")
            sys.exit(1)

        with open(input_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Count replacements for reporting
        stats = {
            'cref': 0,
            'combinedref': 0,
            'combinedcref': 0,
            'prosecite': 0,
            'textcite': 0,
        }

        # Expand \cref{label}
        def count_cref(match):
            stats['cref'] += 1
            return self.expand_cref(match)
        content = re.sub(r'\\cref\{([^}]+)\}', count_cref, content)

        # Expand \combinedref{label}
        def count_combinedref(match):
            stats['combinedref'] += 1
            return self.expand_combinedref(match)
        content = re.sub(r'\\combinedref\{([^}]+)\}', count_combinedref, content)

        # Expand \combinedcref{label}
        def count_combinedcref(match):
            stats['combinedcref'] += 1
            return self.expand_combinedcref(match)
        content = re.sub(r'\\combinedcref\{([^}]+)\}', count_combinedcref, content)

        # Expand \prosecite{key}
        def count_prosecite(match):
            stats['prosecite'] += 1
            return self.expand_prosecite(match)
        content = re.sub(r'\\prosecite\{([^}]+)\}', count_prosecite, content)

        # Expand \textcite{key} - convert to "LastName \cite{key}" or \parencite for multi-key
        def count_textcite(match):
            stats['textcite'] += 1
            return self.expand_textcite(match)
        content = re.sub(r'\\textcite\{([^}]+)\}', count_textcite, content)

        # Remove non-breaking spaces before citation commands
        # This prevents awkward spacing with superscript citations in EPUB
        content = re.sub(r'~\\cite\{', r' \\cite{', content)
        content = re.sub(r'~\\parencite\{', r' \\parencite{', content)
        content = re.sub(r'~\\textcite\{', r' \\textcite{', content)

        # Write output
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(content)

        print(f"\nExpansion Statistics:")
        print(f"  \\cref: {stats['cref']} replacements")
        print(f"  \\combinedref: {stats['combinedref']} replacements")
        print(f"  \\combinedcref: {stats['combinedcref']} replacements")
        print(f"  \\prosecite: {stats['prosecite']} replacements")
        print(f"  \\textcite: {stats['textcite']} conversions")
        print(f"\nOutput written to: {output_path}")


def main():
    """Main entry point."""
    # Parse command line arguments or use defaults
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    else:
        input_file = "paper.tex"

    if len(sys.argv) > 2:
        output_file = sys.argv[2]
    else:
        output_file = "temp/paper_expanded.tex"

    # Determine aux and bbl file paths
    # They should be in temp/ directory based on the build process
    aux_file = "temp/Open MDMA.aux"
    bbl_file = "temp/Open MDMA.bbl"

    print("LaTeX Reference Expander for EPUB Conversion")
    print("=" * 50)

    # Parse auxiliary files
    aux_parser = AuxParser(aux_file)
    aux_parser.parse()

    bbl_parser = BblParser(bbl_file)
    bbl_parser.parse()

    # Expand references
    expander = RefExpander(aux_parser, bbl_parser)
    expander.process_file(input_file, output_file)

    print("\nDone!")


if __name__ == "__main__":
    main()
