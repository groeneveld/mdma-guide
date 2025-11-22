#!/usr/bin/env python3
"""
Citation checker - identifies potentially uncited claims in paper.tex
Uses Claude Haiku to analyze each line for claims that need citations.
"""

import subprocess
import sys
import argparse
import re
from concurrent.futures import ProcessPoolExecutor, as_completed
from typing import List, Tuple, Optional

PROMPT = """Analyze this line from an academic paper. If it contains a factual claim that:
1. Is NOT common knowledge
2. Is NOT clearly an opinion/interpretation
3. Appears to lack a citation (no \\cite, \\parencite, or \\textcite)

Respond with ONLY:
- "NEEDS CITATION: [brief explanation]" if it needs a citation
- "OK" if it's fine

Line: """

def call_claude(line_num: int, line: str) -> Tuple[int, str, str]:
    """Call Claude CLI for a single line and return result."""
    # Skip empty lines, comments, LaTeX commands (except text content)
    stripped = line.strip()
    if not stripped or stripped.startswith('%') or stripped.startswith('\\'):
        return (line_num, line, "OK")

    # Skip lines that already have citations
    if '\\cite' in line or '\\parencite' in line or '\\textcite' in line:
        return (line_num, line, "OK")

    # Skip lines with only references/labels
    if stripped.startswith('\\label') or stripped.startswith('\\ref'):
        return (line_num, line, "OK")

    try:
        full_prompt = PROMPT + line
        result = subprocess.run(
            ['claude', '--model', 'haiku', '-p', full_prompt],
            capture_output=True,
            text=True,
            timeout=30
        )
        response = result.stdout.strip()
        return (line_num, line, response)
    except subprocess.TimeoutExpired:
        return (line_num, line, "TIMEOUT")
    except Exception as e:
        return (line_num, line, f"ERROR: {str(e)}")


def extract_section(content: str, section_name: str) -> List[Tuple[int, str]]:
    """Extract lines from a specific section."""
    lines = content.split('\n')
    in_section = False
    section_lines = []
    section_level = None
    hierarchy = {'chapter': 0, 'section': 1, 'subsection': 2, 'subsubsection': 3}

    section_pattern = re.compile(r'\\(chapter|section|subsection|subsubsection)\{.*' + re.escape(section_name) + r'.*\}', re.IGNORECASE)
    heading_pattern = re.compile(r'\\(chapter|section|subsection|subsubsection)\{')

    for i, line in enumerate(lines, 1):
        match = section_pattern.search(line)
        if match and not in_section:
            in_section = True
            section_level = hierarchy[match.group(1)]
            continue

        if in_section:
            # Check if this is a heading
            heading_match = heading_pattern.search(line)
            if heading_match:
                # Stop at same or higher level (lower number = higher level)
                current_level = hierarchy[heading_match.group(1)]
                if current_level <= section_level:
                    break
            section_lines.append((i, line))

    return section_lines


def process_batch(lines: List[Tuple[int, str]]) -> List[Tuple[int, str, str]]:
    """Process a batch of lines in parallel."""
    results = []
    with ProcessPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(call_claude, line_num, line): (line_num, line)
                   for line_num, line in lines}

        for future in as_completed(futures):
            try:
                result = future.result()
                results.append(result)
            except Exception as e:
                line_num, line = futures[future]
                results.append((line_num, line, f"ERROR: {str(e)}"))

    return results


def main():
    parser = argparse.ArgumentParser(description='Check for uncited claims in paper.tex')
    parser.add_argument('--section', '-s', type=str, help='Process only this section name')
    parser.add_argument('--file', '-f', type=str, default='paper.tex', help='Input file (default: paper.tex)')
    args = parser.parse_args()

    # Read the file
    try:
        with open(args.file, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: Could not find {args.file}", file=sys.stderr)
        sys.exit(1)

    # Get lines to process
    if args.section:
        print(f"Processing section: {args.section}\n")
        lines_to_process = extract_section(content, args.section)
        if not lines_to_process:
            print(f"Warning: Section '{args.section}' not found", file=sys.stderr)
            sys.exit(1)
    else:
        lines_to_process = [(i, line) for i, line in enumerate(content.split('\n'), 1)]

    print(f"Analyzing {len(lines_to_process)} lines in batches of 10...\n")

    # Process in batches of 10
    batch_size = 10
    all_results = []

    for i in range(0, len(lines_to_process), batch_size):
        batch = lines_to_process[i:i+batch_size]
        print(f"Processing lines {batch[0][0]}-{batch[-1][0]}...", end='\r')
        results = process_batch(batch)
        all_results.extend(results)

    # Filter to only issues (not "OK" responses)
    issues = [(line_num, line, response) for line_num, line, response in all_results
              if not response.startswith("OK")]

    print("\n\n" + "="*80)
    print(f"CITATION ISSUES FOUND: {len(issues)}")
    print("="*80 + "\n")

    # Sort by line number and display issues only
    issues.sort(key=lambda x: x[0])

    for line_num, line, response in issues:
        print(f"Line {line_num}:")
        print(f"  Text: {line.strip()}")
        print(f"  {response}\n")

    if len(issues) == 0:
        print("No citation issues found!")
    else:
        print("="*80)
        print(f"Total issues: {len(issues)} out of {len(lines_to_process)} lines analyzed")


if __name__ == '__main__':
    main()
