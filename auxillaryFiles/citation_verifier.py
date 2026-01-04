#!/usr/bin/env python3
"""
Citation Verifier and Validation Tool
======================================

A comprehensive tool for academic citation management that helps verify and validate
citations in LaTeX documents. This script provides two main functions:

1. **Citation Inventory Generation**: Creates a detailed inventory of all citations
   in your LaTeX paper, reading file paths directly from references.bib
2. **Citation Validation**: Uses Claude Code AI to verify that citations accurately
   support the claims made in your academic text

FEATURES:
---------
• Scans LaTeX files for \cite{} and \textcite{} patterns
• Reads file paths directly from references.bib file field
• Generates structured citation inventory with file availability status
• AI-powered validation of citation accuracy using Claude Code
• Parallel processing for improved performance

REQUIREMENTS:
-------------
• Python 3.6+
• Claude Code CLI (https://claude.ai/code) - for citation validation
• LaTeX project with references.bib and paper.tex files
• references.bib entries must include 'file' field with paths to PDFs

USAGE:
------
Basic citation inventory generation:
    python3 citation_verifier.py

Citation validation (requires Claude Code):
    python3 citation_verifier.py -verify

The script will:
1. Parse your references.bib file for citation keys and file paths
2. Extract citations from paper.tex
3. Generate citation_inventory.md with detailed citation information
4. (With -verify) Validate each citation using AI analysis

OUTPUT FORMAT:
--------------
Each citation entry shows:
- Status: READY (has files), MISSING_FILE (missing PDFs)
- Citation keys in parentheses
- Line numbers where citations appear

Example: READY (smith2020,jones2021) - 45,67,89

DIRECTORY STRUCTURE:
--------------------
Your project should have:
- paper.tex (your main LaTeX document)
- references.bib (your bibliography with file fields)
- citation_inventory.md (generated output)
These can be changed below.
======================
USER CONFIGURATION
======================
"""

import re
import os
import sys
import subprocess
from collections import defaultdict


# =============================================================================
# CONFIGURATION
# =============================================================================

class Config:
    """Configuration constants for the citation verifier."""
    
    # File paths
    PAPERS_DIR = '../papers'
    PAPER_TEX_FILE = '../paper.tex'
    REFERENCES_BIB_FILE = '../references.bib'
    OUTPUT_FILE = 'citation_inventory.md'
    ANALYSIS_FILE = 'citation_analysis.md'
    
    # Processing limits
    CLAUDE_TIMEOUT_PER_PARAGRAPH = 240  # 4 minutes per paragraph
    CLAUDE_TIMEOUT_VALIDATION = 600     # 10 minutes for validation
    MAX_PDF_SIZE_MB = 50                # Maximum PDF size to process
    
    # Process cleanup timeouts
    PROCESS_KILL_TIMEOUT = 5
    PROCESS_TERMINATE_TIMEOUT = 2


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

class FileUtils:
    """Utility functions for file path handling."""
    
    @staticmethod
    def normalize_path(path, base_dir=None):
        """Normalize file path to absolute path, handling relative paths consistently."""
        if not path:
            return None
        
        if os.path.isabs(path):
            return os.path.abspath(path)
        else:
            if base_dir:
                return os.path.abspath(os.path.join(base_dir, path))
            else:
                return os.path.abspath(path)


class ProcessUtils:
    """Utility functions for subprocess management."""
    
    @staticmethod
    def cleanup_processes(processes_to_cleanup, exclude_process=None):
        """Helper function to safely cleanup subprocess list."""
        for proc, _ in processes_to_cleanup:
            if proc != exclude_process and proc.poll() is None:
                try:
                    proc.kill()
                    proc.wait(timeout=Config.PROCESS_KILL_TIMEOUT)
                except subprocess.TimeoutExpired:
                    try:
                        proc.terminate()
                        proc.wait(timeout=Config.PROCESS_TERMINATE_TIMEOUT)
                    except subprocess.TimeoutExpired:
                        pass
                except Exception:
                    pass


# =============================================================================
# BIBTEX PROCESSING
# =============================================================================

class BibtexParser:
    """Handles BibTeX file parsing."""
    
    @staticmethod
    def parse_all_citation_keys(bib_path):
        """Parse references.bib to get all citation keys."""
        all_citation_keys = set()
        
        try:
            with open(bib_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except FileNotFoundError:
            print(f"Warning: Bibliography file {bib_path} not found. Please ensure the file exists and the path is correct.")
            return set()
        
        entries = re.split(r'(?=@\w+\{)', content)
        
        for entry in entries:
            if not entry.strip():
                continue
                
            key_match = re.match(r'@\w+\{([^,]+),', entry)
            if key_match:
                citation_key = key_match.group(1).strip()
                all_citation_keys.add(citation_key)
        
        return all_citation_keys

    @staticmethod
    def parse_citation_metadata(bib_path):
        """Parse references.bib to extract citation keys with file paths."""
        citation_metadata = {}

        try:
            with open(bib_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except FileNotFoundError:
            print(f"Warning: Bibliography file {bib_path} not found. Please ensure the file exists and the path is correct.")
            return {}

        entries = re.split(r'(?=@\w+\{)', content)

        for entry in entries:
            if not entry.strip():
                continue

            key_match = re.match(r'@\w+\{([^,]+),', entry)
            if not key_match:
                continue

            citation_key = key_match.group(1).strip()
            metadata = {}

            # Extract file path
            file_match = re.search(r'file\s*=\s*\{([^}]+)\}', entry, re.IGNORECASE)
            if file_match:
                file_path = file_match.group(1).strip()
                # Strip leading and trailing colons (some reference managers wrap paths with colons)
                file_path = file_path.strip(':')
                # Convert to relative path from papers directory if it's an absolute path
                # Just use the basename for display
                metadata['filename'] = os.path.basename(file_path)
                metadata['filepath'] = file_path

            if metadata:
                citation_metadata[citation_key] = metadata

        return citation_metadata


# =============================================================================
# LATEX PROCESSING
# =============================================================================

class LatexProcessor:
    """Handles LaTeX file processing and citation extraction."""
    
    @staticmethod
    def extract_citations(file_path):
        """Extract citation patterns from LaTeX file and track line numbers."""
        citation_inventory = defaultdict(list)
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except FileNotFoundError:
            print(f"Error: LaTeX file {file_path} not found. Please ensure the file exists and PAPER_TEX_FILE configuration is correct.")
            return {}
        
        citation_pattern = r'\\(?:text)?cite\{([^}]+)\}'
        
        for line_num, line in enumerate(lines, 1):
            matches = re.finditer(citation_pattern, line)

            for match in matches:
                keys_string = match.group(1)
                # Filter out keys starting with # (LaTeX parameter placeholders)
                keys = [key.strip() for key in keys_string.split(',') if not key.strip().startswith('#')]

                # Only process if we have valid keys after filtering
                if keys:
                    keys_tuple = tuple(keys)

                    if line_num not in citation_inventory[keys_tuple]:
                        citation_inventory[keys_tuple].append(line_num)
        
        return citation_inventory
    
    @staticmethod
    def get_line_contents_from_paper(line_numbers, paper_file):
        """Fetch line contents from paper.tex for given line numbers."""
        line_info = []
        
        paper_file = FileUtils.normalize_path(paper_file)
        
        if not os.path.exists(paper_file):
            print(f"Error: Paper file {paper_file} not found. Please ensure your LaTeX file exists and PAPER_TEX_FILE configuration is correct.")
            return line_info
        
        try:
            with open(paper_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except Exception as e:
            print(f"Error reading {paper_file}: {e}")
            return line_info
        
        for line_num in line_numbers:
            if 1 <= line_num <= len(lines):
                line_content = lines[line_num - 1].strip()
                line_info.append((line_num, line_content))
        
        return line_info


# =============================================================================
# OUTPUT FORMATTING
# =============================================================================

class OutputFormatter:
    """Handles formatting of citation inventory and analysis output."""
    
    @staticmethod
    def format_citation_inventory(citation_inventory, citation_metadata=None):
        """Format the citation inventory for output."""
        sorted_citations = sorted(
            citation_inventory.items(),
            key=lambda x: (len(x[1]), x[0]),
            reverse=True
        )
        
        output_lines = []
        
        for keys, line_numbers in sorted_citations:
            keys_str = ','.join(keys)

            keys_with_files = 0

            if citation_metadata:
                for key in keys:
                    if key in citation_metadata:
                        metadata = citation_metadata[key]
                        if 'filename' in metadata:
                            keys_with_files += 1

            if len(keys) > 0 and keys_with_files == len(keys):
                prefix = "READY"
            else:
                prefix = "MISSING_FILE"

            line_numbers_str = ','.join(map(str, sorted(line_numbers)))

            output_line = f"{prefix} ({keys_str}) - {line_numbers_str}"
            output_lines.append(output_line)
        
        return '\n'.join(output_lines)


# =============================================================================
# CITATION VERIFICATION
# =============================================================================

class CitationVerifier:
    """Handles AI-powered citation verification using Claude Code."""
    
    @staticmethod
    def parse_citation_inventory(inventory_file):
        """Parse citation_inventory.md file to extract entries for verification."""
        entries = []
        
        inventory_file = FileUtils.normalize_path(inventory_file)
        
        if not os.path.exists(inventory_file):
            print(f"Error: Citation inventory file {inventory_file} not found. Please run the main script first to generate the inventory.")
            return entries
        
        try:
            with open(inventory_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except Exception as e:
            print(f"Error reading {inventory_file}: {e}")
            return entries
        
        for line in lines:
            line = line.strip()
            if not line:
                continue

            match = re.match(r'(\w+) \(([^)]+)\) - (.+)', line)
            if match:
                prefix = match.group(1)
                keys_str = match.group(2)
                line_numbers_str = match.group(3)

                citation_keys = [k.strip() for k in keys_str.split(',') if k.strip()]
                line_numbers = [int(n.strip()) for n in line_numbers_str.split(',') if n.strip().isdigit()]

                entries.append({
                    'prefix': prefix,
                    'citation_keys': citation_keys,
                    'line_numbers': line_numbers,
                    'raw_line': line
                })
        
        return entries
    
    @staticmethod
    def _resolve_file_path(filename, papers_dir):
        """Resolve filename to absolute path."""
        return FileUtils.normalize_path(filename, papers_dir)
    
    @staticmethod
    def _group_lines_into_paragraphs(line_info):
        """Group line info into paragraphs based on consecutive line numbers."""
        paragraphs = []
        current_paragraph = []
        
        for line_num, line_content in line_info:
            if current_paragraph and line_num > current_paragraph[-1][0] + 1:
                paragraphs.append(current_paragraph)
                current_paragraph = [(line_num, line_content)]
            else:
                current_paragraph.append((line_num, line_content))
        
        if current_paragraph:
            paragraphs.append(current_paragraph)
        
        return paragraphs
    
    @staticmethod
    def call_claude_for_verification(file_paths_or_names, citation_keys, line_info, papers_dir=Config.PAPERS_DIR):
        """Call Claude Code to verify citations using two sequential calls with parallelized first step."""
        if not file_paths_or_names:
            raise Exception("No file paths available for verification")

        # Prepare file paths - they could be full paths or just filenames
        file_paths = []
        for filepath in file_paths_or_names:
            # If it's already an absolute path, use it directly
            if os.path.isabs(filepath):
                if os.path.exists(filepath):
                    file_paths.append(filepath)
                else:
                    print(f"Warning: File not found at {filepath}. Skipping.")
            else:
                # Try to resolve relative to papers_dir
                resolved_path = CitationVerifier._resolve_file_path(filepath, papers_dir)
                if os.path.exists(resolved_path):
                    file_paths.append(resolved_path)
                else:
                    print(f"Warning: File {filepath} not found. Skipping.")

        if not file_paths:
            raise Exception("No valid files found for verification")

        paragraphs = CitationVerifier._group_lines_into_paragraphs(line_info)
        # Use basenames for display
        filenames_text = ', '.join([os.path.basename(fp) for fp in file_paths])
        citation_keys_text = ', '.join(citation_keys)
        
        try:
            # STEP 1: Mark attribution units in paragraphs (parallelized)
            print(f"     → Step 1: Marking attribution units in {len(paragraphs)} paragraphs...")
            
            paragraph_results = []
            processes = []
            
            for i, paragraph in enumerate(paragraphs):
                paragraph_text = ""
                for line_num, line_content in paragraph:
                    paragraph_text += f"Line {line_num}: {line_content}\n"
                
                split_prompt = f"""In academic writing in APA, paragraphs are split into 'attribution units' that each depend on a certain set of citations. So the first sentence has citation1, and the following sentences inherit that until a sentence starts that uses a different set of citations or is an opinion. Mark each attribution unit in the following paragraph that uses exactly this ({citation_keys_text}) particular set of citations by inserting '->' and '<-' around that set of sentences. Markers should generally be on sentence or clause boundaries. You're acting as a input/output function; you're *only* output is the original text (and line numbers) with the markers added. DO NOT ADD ANYTHING ELSE OR EXPLAIN WHAT YOU'RE DOING.
            
                PARAGRAPH: <<{paragraph_text}>>"""

                cmd = ['claude', '-p', split_prompt]
                
                process = subprocess.Popen(
                    cmd,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True
                )
                processes.append((process, i))
            
            # Collect results with proper cleanup
            try:
                for process, paragraph_index in processes:
                    try:
                        stdout, stderr = process.communicate(timeout=Config.CLAUDE_TIMEOUT_PER_PARAGRAPH)
                        if process.returncode != 0:
                            ProcessUtils.cleanup_processes(processes, exclude_process=process)
                            raise Exception(f"Claude call failed for paragraph {paragraph_index + 1}: {stderr}")
                        paragraph_results.append((paragraph_index, stdout.strip()))
                    except subprocess.TimeoutExpired:
                        process.kill()
                        ProcessUtils.cleanup_processes(processes, exclude_process=process)
                        raise Exception(f"Claude verification timed out for paragraph {paragraph_index + 1}")
            except Exception as e:
                ProcessUtils.cleanup_processes(processes)
                raise e
            
            paragraph_results.sort(key=lambda x: x[0])
            
            # STEP 2: Validate attribution units
            print("     → Step 2: Validating attribution units...")
            
            validation_prompt = f"""You are assessing whether attribution units (a section of a paragraph that relies on a particular set of citations) from an academic paper are reasonably justified by their citations.

            Citation keys: {citation_keys_text}
            Corresponding files: {filenames_text}

            First, read and understand the content of the cited papers. Then evaluate each attribution unit below.

            Here are the attribution units to evaluate. They are the sections of text between the -> and -< marks. There may be multiple units within a paragraph. The whole paragraph is provided for context. 
            {paragraph_results}

            For each attribution unit, provide your assessment in this format exactly:
            Line <line_number>: <✅ or ❌ or ⚠️> <analysis of one or more attribution units in that paragraph>

            Use ✅ if the cited papers support the claims or if they represent reasonable extrapolations. Use ❌ if the papers don't support the claims, explaining why in your own words for the analysis. Use ⚠️ for an in-between option.

            DO NOT ADD ANYTHING ELSE OR EXPLAIN WHAT YOU'RE DOING, unless you run into an error, which you can explain."""

            cmd2 = ['claude', '-p', validation_prompt] + file_paths
            
            result2 = subprocess.run(
                cmd2,
                capture_output=True,
                text=True,
                timeout=Config.CLAUDE_TIMEOUT_VALIDATION
            )
            
            if result2.returncode != 0:
                raise Exception(f"Second Claude call failed: {result2.stderr}")
            
            analysis_output = result2.stdout.strip()
            if not analysis_output:
                raise Exception("Second Claude call returned no output")
            
            return {
                'marked_paragraphs': [result for _, result in paragraph_results],
                'analysis': analysis_output
            }
            
        except subprocess.TimeoutExpired:
            raise Exception("Claude verification timed out")
        except FileNotFoundError:
            raise Exception("'claude' command not found. Please install Claude Code CLI from https://claude.ai/code and ensure it's in your PATH.")
        except Exception as e:
            raise Exception(f"Claude verification failed: {str(e)}")


# =============================================================================
# ANALYSIS OUTPUT
# =============================================================================

class AnalysisWriter:
    """Handles writing of analysis results to output file."""
    
    @staticmethod
    def write_analysis(entry, result, analysis_file):
        """Write analysis result to file."""
        try:
            with open(analysis_file, 'a', encoding='utf-8') as f:
                # Write entry header
                f.write(f"## {', '.join(entry['citation_keys'])}\n\n")
                f.write(f"**Files:** {', '.join(entry['filenames'])}\n")
                f.write(f"**Lines:** {', '.join(map(str, entry['line_numbers']))}\n\n")
                
                # Write verification result
                if isinstance(result, dict):
                    # Parse the analysis to extract line-specific assessments
                    analysis_lines = result['analysis'].split('\n')
                    line_analyses = {}
                    
                    # Extract line numbers and their analyses from Claude's output
                    for line in analysis_lines:
                        if line.strip().startswith('Line '):
                            match = re.match(r'Line (\d+): (.+)', line.strip())
                            if match:
                                line_num = int(match.group(1))
                                analysis_text = match.group(2)
                                line_analyses[line_num] = analysis_text
                    
                    # Write marked-up text with analysis for each line
                    for marked_paragraph in result['marked_paragraphs']:
                        paragraph_lines = marked_paragraph.split('\n')
                        for para_line in paragraph_lines:
                            if para_line.strip():
                                # Format the line: italic text with bold attribution units
                                formatted_line = para_line
                                # Replace -> text <- with **text** (bold) while keeping the rest italic
                                formatted_line = re.sub(r'->(.*?)<-', r'**\1**', formatted_line)
                                # Make the entire line italic
                                formatted_line = f"*{formatted_line}*"
                                
                                f.write(f"{formatted_line}\n")
                                
                                # Extract line number and add analysis
                                line_match = re.match(r'Line (\d+):', para_line)
                                if line_match:
                                    line_num = int(line_match.group(1))
                                    if line_num in line_analyses:
                                        f.write(f"  {line_analyses[line_num]}\n")
                                f.write("\n")
                        f.write("\n")
                
                f.write("---\n\n")
                f.flush()
                
        except Exception as e:
            raise Exception(f"Error writing analysis: {e}")


# =============================================================================
# MAIN APPLICATION
# =============================================================================

class CitationInventoryManager:
    """Main application class that orchestrates the citation verification process."""
    
    def __init__(self):
        self.config = Config()
    
    def generate_inventory(self):
        """Generate citation inventory from LaTeX and BibTeX files."""
        # Normalize all file paths
        input_file = FileUtils.normalize_path(self.config.PAPER_TEX_FILE)
        output_file = FileUtils.normalize_path(self.config.OUTPUT_FILE)
        bib_file = FileUtils.normalize_path(self.config.REFERENCES_BIB_FILE)

        print("=== Citation Verifier Enhanced ===")

        # Step 1: Parse references.bib for all citation metadata
        print("\n1. Parsing references.bib...")
        all_citation_keys = BibtexParser.parse_all_citation_keys(bib_file)
        citation_metadata = BibtexParser.parse_citation_metadata(bib_file)
        print(f"   Found {len(all_citation_keys)} total citation keys")
        print(f"   Found {len(citation_metadata)} citation keys with metadata (files)")

        # Check for citations without files
        citations_without_files = []
        citations_with_files = 0
        for key in all_citation_keys:
            if key in citation_metadata and 'filename' in citation_metadata[key]:
                citations_with_files += 1
            else:
                citations_without_files.append(key)

        print(f"   Citations with linked files: {citations_with_files}")
        if citations_without_files:
            print(f"\n\033[33mWarning: {len(citations_without_files)} citation(s) without linked files:\033[0m")
            for key in sorted(citations_without_files):
                print(f"      {key}")

        # Step 2: Extract citations from paper.tex
        print(f"\n2. Scanning {input_file} for citations...")
        citation_inventory = LatexProcessor.extract_citations(input_file)

        if not citation_inventory:
            print("No citations found or error reading file.")
            return

        print(f"   Found {len(citation_inventory)} unique citation key combinations")
        print(f"   Total citation instances: {sum(len(lines) for lines in citation_inventory.values())}")

        # Step 3: Format and write output
        print(f"\n3. Writing results to {output_file}...")
        formatted_output = OutputFormatter.format_citation_inventory(citation_inventory, citation_metadata)

        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(formatted_output)
            print(f"   Citation inventory written to {output_file}")
        except IOError as e:
            print(f"   Error writing to {output_file}: {e}")
            return

        # Step 4: Print summary
        self._print_summary(citation_metadata, citation_inventory)
    
    def run_verification(self):
        """Run verification process on citation inventory."""
        inventory_file = FileUtils.normalize_path(self.config.OUTPUT_FILE)
        analysis_file = FileUtils.normalize_path(self.config.ANALYSIS_FILE)
        bib_file = FileUtils.normalize_path(self.config.REFERENCES_BIB_FILE)

        print("=== Citation Verification Process ===")

        # Parse citation metadata from .bib to get file paths
        print(f"1. Loading citation metadata from {bib_file}...")
        citation_metadata = BibtexParser.parse_citation_metadata(bib_file)
        print(f"   Loaded metadata for {len(citation_metadata)} citations")

        # Parse citation inventory
        print(f"\n2. Parsing {inventory_file}...")
        entries = CitationVerifier.parse_citation_inventory(inventory_file)

        if not entries:
            print("No entries found in citation inventory.")
            return

        print(f"   Found {len(entries)} entries")

        # Process each entry
        for i, entry in enumerate(entries, 1):
            print(f"\n[{i}/{len(entries)}] Processing entry: {', '.join(entry['citation_keys'])}")

            # Only verify READY entries
            if entry['prefix'] != 'READY':
                print(f"   ⏭️  Skipping verification (status: {entry['prefix']})")
                continue

            # Get full file paths from citation metadata
            file_paths = []
            filenames = []
            for key in entry['citation_keys']:
                if key in citation_metadata and 'filepath' in citation_metadata[key]:
                    file_paths.append(citation_metadata[key]['filepath'])
                    if 'filename' in citation_metadata[key]:
                        filenames.append(citation_metadata[key]['filename'])

            if not file_paths:
                print("   ❌ No file paths found in metadata")
                continue

            # Store filenames in entry for use by AnalysisWriter
            entry['filenames'] = filenames

            # Get line contents from paper.tex
            line_info = LatexProcessor.get_line_contents_from_paper(entry['line_numbers'], self.config.PAPER_TEX_FILE)

            if not line_info:
                print("   ❌ No line contents found")
                continue

            # Run Claude verification
            try:
                result = CitationVerifier.call_claude_for_verification(
                    file_paths,
                    entry['citation_keys'],
                    line_info
                )
            except Exception as e:
                print(f"   ❌ Verification failed: {str(e)}")
                continue

            print(f"   ✅ Verification completed")

            # Write analysis
            try:
                AnalysisWriter.write_analysis(entry, result, analysis_file)
                print(f"   ✅ Analysis written to {analysis_file}")
            except Exception as e:
                print(f"   ❌ Error writing analysis: {e}")

        print(f"\n3. Processing complete! Results saved to {analysis_file}")
    
    def _print_summary(self, citation_metadata, citation_inventory):
        """Print summary statistics."""
        print("\n=== Summary ===")
        matched_files = sum(1 for metadata in citation_metadata.values() if 'filename' in metadata)
        print(f"Citation keys with linked files: {matched_files}/{len(citation_metadata)}")
        print(f"Unique citation combinations in paper.tex: {len(citation_inventory)}")
        print(f"Total citation instances: {sum(len(lines) for lines in citation_inventory.values())}")


# =============================================================================
# MAIN ENTRY POINT
# =============================================================================

def main():
    """Main entry point for the citation verifier."""
    app = CitationInventoryManager()
    app.generate_inventory()


def run_verify():
    """Entry point for citation verification."""
    app = CitationInventoryManager()
    app.run_verification()


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "-verify":
        run_verify()
    else:
        main()