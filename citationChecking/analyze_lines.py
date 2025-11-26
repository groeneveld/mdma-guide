#!/usr/bin/env python3
"""
General-purpose LaTeX line analyzer using Claude.
Supports multiple analysis modes: citation checking and APA copyediting.
"""

import subprocess
import sys
import argparse
import re
from concurrent.futures import ProcessPoolExecutor, as_completed
from typing import List, Tuple, Optional

# ANSI color codes
class Colors:
    BLUE = '\033[94m'
    ORANGE = '\033[38;5;208m'
    GREEN = '\033[32m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    RESET = '\033[0m'

# Input file configuration
INPUT_FILE = 'paper.tex'

def colorize_response(response: str, use_colors: bool = True) -> str:
    """Apply simple color to response text."""
    if not use_colors:
        return response
    # Just apply orange color to the entire response
    return f'{Colors.ORANGE}{response}{Colors.RESET}'

PROMPTS = {
    'citations': """Analyze this text chunk from an academic paper. If it contains a factual claim that:
1. Is NOT common knowledge
2. Is NOT clearly an opinion/interpretation
3. Appears to lack a citation (no \\cite, or \\textcite, or \\ref)

Respond with ONLY:
- "NEEDS CITATION: [brief explanation]" if it needs a citation
- "OK" if it's fine

Text: """,
    'copyedit': """Review this text chunk from an academic paper written in LaTeX and identify any overly complicated or awkward wording.

Respond with ONLY:
- "OK" if the text is fine

Otherwise:
- A brief description of each issue

Don't introduce your list, just return the list.

Text: """
}

# Review this text chunk from an academic paper written in LaTeX and identify any overly complicated or awkward wording.

# Respond with ONLY:
# - "OK" if the text is fine

# Otherwise:
# - A brief description of each issue

# Don't introduce your list, just return the list.



# You are an APA copyeditor. Review this text chunk from an academic paper written in LaTeX and identify any issues that would be caught in an APA copyedit. Focus on:
# - APA style violations (formatting, punctuation, abbreviations, numbers, etc.)
# - Grammar and syntax errors
# - Word choice and clarity issues
# - Consistency problems

# Respond with ONLY:
# - "OK" if the text is fine

# Otherwise:
# - A brief description of each issue
# - If it's a simple fix, suggest the correction
# - Don't suggest corrections for sentence restructuring.)

# Ignore issues in quotes attributed to a reference.
# Ignore \\todo and any latex label issues.
# Don't introduce your list, just return the list.
# Ignore issues with backslashes.
# DON'T LIST ISSUES WITH FORMALITY.

def call_claude(line_nums: List[int], text: str, mode: str, model: str) -> Tuple[List[int], str, str]:
    """Call Claude CLI for a chunk of text and return result."""
    stripped = text.strip()

    # Common skips for all modes
    if not stripped or all(line.strip().startswith('%') for line in text.split('\n')):
        return (line_nums, text, "OK")

    # Mode-specific skip logic
    if mode == 'citations':
        # Skip pure LaTeX commands (all lines are commands)
        lines = [l.strip() for l in text.split('\n') if l.strip()]
        if all(l.startswith('\\') for l in lines):
            return (line_nums, text, "OK")
        # Skip chunks that already have citations
        if '\\cite' in text or '\\parencite' in text or '\\textcite' in text:
            return (line_nums, text, "OK")
        # Skip chunks with only references/labels
        if all(l.startswith('\\label') or l.startswith('\\ref') for l in lines):
            return (line_nums, text, "OK")

    elif mode == 'copyedit':
        # For copyedit, only skip pure structural commands
        pure_commands = ['\\begin{', '\\end{', '\\label{', '\\ref{',
                        '\\chapter{', '\\section{', '\\subsection{', '\\subsubsection{',
                        '\\includegraphics', '\\input{', '\\include{']
        lines = [l.strip() for l in text.split('\n') if l.strip()]
        if all(any(l.startswith(cmd) for cmd in pure_commands) for l in lines):
            return (line_nums, text, "OK")

    try:
        full_prompt = PROMPTS[mode] + text
        result = subprocess.run(
            ['claude', '--model', model, '-p', full_prompt],
            capture_output=True,
            text=True,
            timeout=30
        )
        response = result.stdout.strip()
        return (line_nums, text, response)
    except subprocess.TimeoutExpired:
        return (line_nums, text, "TIMEOUT")
    except Exception as e:
        return (line_nums, text, f"ERROR: {str(e)}")


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


def process_batch(chunks: List[Tuple[List[int], str]], mode: str, model: str) -> List[Tuple[List[int], str, str]]:
    """Process a batch of chunks in parallel."""
    results = []
    with ProcessPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(call_claude, line_nums, text, mode, model): (line_nums, text)
                   for line_nums, text in chunks}

        for future in as_completed(futures):
            try:
                result = future.result()
                results.append(result)
            except Exception as e:
                line_nums, text = futures[future]
                results.append((line_nums, text, f"ERROR: {str(e)}"))

    return results


def is_structural_command(line: str) -> bool:
    """Check if a line is a structural LaTeX command."""
    stripped = line.strip()
    structural_commands = [
        '\\chapter{', '\\section{', '\\subsection{', '\\subsubsection{',
        '\\chapter*{', '\\section*{', '\\subsection*{', '\\subsubsection*{'
    ]
    return any(stripped.startswith(cmd) for cmd in structural_commands)


def filter_content_lines(content: str) -> List[Tuple[int, str]]:
    """Filter out preamble and table content, return only document body content lines."""
    lines = content.split('\n')
    filtered_lines = []
    in_document = False
    in_table = False
    table_depth = 0

    for i, line in enumerate(lines, 1):
        # Track when we enter the document body
        if '\\begin{document}' in line:
            in_document = True
            continue

        # Skip everything before \begin{document}
        if not in_document:
            continue

        # Track table environments (can be nested)
        if '\\begin{table' in line or '\\begin{tabular' in line:
            table_depth += 1
            in_table = True
            continue

        if '\\end{table' in line or '\\end{tabular' in line:
            table_depth -= 1
            if table_depth <= 0:
                in_table = False
                table_depth = 0
            continue

        # Skip lines inside tables
        if in_table:
            continue

        filtered_lines.append((i, line))

    return filtered_lines


def chunk_lines_for_analysis(lines: List[Tuple[int, str]]) -> List[Tuple[List[int], str]]:
    """
    Group lines into chunks, combining itemize/enumerate lists and quotation blocks with adjacent paragraphs
    when they're not separated by blank lines.

    Returns list of (line_numbers, combined_text) tuples.
    """
    chunks = []
    i = 0

    while i < len(lines):
        line_num, line = lines[i]
        stripped = line.strip()

        # Check if this line starts a list or quotation environment
        if '\\begin{itemize}' in stripped or '\\begin{enumerate}' in stripped or '\\begin{quotation}' in stripped:
            # Find the start of the chunk by looking backward
            chunk_start = i
            # Look backward for adjacent paragraph text (no blank lines, no structural commands)
            j = i - 1
            while j >= 0:
                prev_line_num, prev_line = lines[j]
                prev_stripped = prev_line.strip()

                # Stop at blank lines
                if not prev_stripped:
                    break
                # Stop at structural commands
                if is_structural_command(prev_line):
                    break

                chunk_start = j
                j -= 1

            # Find the end of the environment
            if '\\begin{itemize}' in stripped:
                env_type = 'itemize'
            elif '\\begin{enumerate}' in stripped:
                env_type = 'enumerate'
            else:
                env_type = 'quotation'

            env_depth = 1
            chunk_end = i

            # Find matching \end{...}
            k = i + 1
            while k < len(lines) and env_depth > 0:
                end_line_num, end_line = lines[k]
                if f'\\begin{{{env_type}}}' in end_line:
                    env_depth += 1
                elif f'\\end{{{env_type}}}' in end_line:
                    env_depth -= 1
                chunk_end = k
                k += 1

            # Look forward for adjacent paragraph text after the environment
            k = chunk_end + 1
            while k < len(lines):
                next_line_num, next_line = lines[k]
                next_stripped = next_line.strip()

                # Stop at blank lines
                if not next_stripped:
                    break
                # Stop at structural commands
                if is_structural_command(next_line):
                    break

                chunk_end = k
                k += 1

            # Create the chunk
            chunk_lines = lines[chunk_start:chunk_end + 1]
            line_numbers = [ln for ln, _ in chunk_lines]
            combined_text = '\n'.join([l for _, l in chunk_lines])
            chunks.append((line_numbers, combined_text))

            # Skip past this chunk
            i = chunk_end + 1
        else:
            # Process individual line
            chunks.append(([line_num], line))
            i += 1

    return chunks


def main():
    parser = argparse.ArgumentParser(
        description='Analyze LaTeX files using Claude',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        usage='%(prog)s {citations,copyedit} [--section SECTION] [--model MODEL]',
        epilog="""
Available modes:
  citations  - Check for missing citations
  copyedit   - APA copyediting suggestions

Examples:
  python3 analyze_lines.py citations
  python3 analyze_lines.py copyedit --section "Introduction"
  python3 analyze_lines.py citations --model sonnet
        """
    )
    parser.add_argument('mode', type=str,
                       choices=['citations', 'copyedit'],
                       help='Analysis mode')
    parser.add_argument('--section', '-s', type=str, help='Process only this section name')
    parser.add_argument('--model', type=str, default='haiku',
                       help='Claude model to use (default: haiku)')
    parser.add_argument('--no-color', action='store_true',
                       help='Disable colored output')
    args = parser.parse_args()

    # Helper function to conditionally apply colors
    def c(color_code: str) -> str:
        return '' if args.no_color else color_code

    # Read the file
    try:
        with open(INPUT_FILE, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: Could not find {INPUT_FILE}", file=sys.stderr)
        sys.exit(1)

    # Get lines to process
    if args.section:
        print(f"{c(Colors.BOLD)}Processing section:{c(Colors.RESET)} {args.section}")
        print(f"{c(Colors.BOLD)}Mode:{c(Colors.RESET)} {args.mode}\n")
        lines_to_process = extract_section(content, args.section)
        if not lines_to_process:
            print(f"Warning: Section '{args.section}' not found", file=sys.stderr)
            sys.exit(1)
    else:
        print(f"{c(Colors.BOLD)}Mode:{c(Colors.RESET)} {args.mode}")
        lines_to_process = filter_content_lines(content)

    # Chunk the lines (group lists and quotation blocks with adjacent paragraphs)
    chunks_to_process = chunk_lines_for_analysis(lines_to_process)

    print(f"Analyzing {len(lines_to_process)} lines in {len(chunks_to_process)} chunks (batches of 10)...\n")

    # Process in batches of 10
    batch_size = 10
    all_results = []

    for i in range(0, len(chunks_to_process), batch_size):
        batch = chunks_to_process[i:i+batch_size]
        # Display progress with first and last line numbers in batch
        first_lines = batch[0][0]
        last_lines = batch[-1][0]
        print(f"Processing chunks covering lines {first_lines[0]}-{last_lines[-1]}...", end='\r')
        results = process_batch(batch, args.mode, args.model)
        all_results.extend(results)

    # Filter to only issues (not "OK" responses)
    issues = [(line_nums, text, response) for line_nums, text, response in all_results
              if not response.startswith("OK")]

    # Mode-specific output headers
    mode_titles = {
        'citations': 'CITATION ISSUES FOUND',
        'copyedit': 'COPYEDIT SUGGESTIONS'
    }
    mode_success = {
        'citations': 'No citation issues found!',
        'copyedit': 'No copyedit issues found!'
    }

    print("\n\n" + f"{c(Colors.BOLD)}{'='*80}")
    print(f"{mode_titles[args.mode]}: {len(issues)}")
    print("="*80 + f"{c(Colors.RESET)}\n")

    # Sort by first line number and display issues only
    issues.sort(key=lambda x: x[0][0])

    for line_nums, text, response in issues:
        # Format line number display
        if len(line_nums) == 1:
            line_display = f"Line {line_nums[0]}"
        else:
            line_display = f"Lines {line_nums[0]}-{line_nums[-1]}"

        print(f"{c(Colors.BOLD)}{c(Colors.BLUE)}{line_display}:{c(Colors.RESET)}")
        print(f"  {c(Colors.DIM)}Text:{c(Colors.RESET)} {text.strip()}")
        print(f"  {colorize_response(response, use_colors=not args.no_color)}\n")

    if len(issues) == 0:
        print(f"{c(Colors.GREEN)}{mode_success[args.mode]}{c(Colors.RESET)}")
    else:
        print(f"{c(Colors.BOLD)}{'='*80}{c(Colors.RESET)}")
        print(f"Total issues: {len(issues)} chunks with issues out of {len(chunks_to_process)} chunks analyzed ({len(lines_to_process)} total lines)")


if __name__ == '__main__':
    main()
