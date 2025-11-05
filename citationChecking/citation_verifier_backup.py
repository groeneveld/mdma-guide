#!/usr/bin/env python3
"""
Citation Verifier and Validation Tool
======================================

A comprehensive tool for academic citation management that helps verify and validate
citations in LaTeX documents. This script provides two main functions:

1. **Citation Inventory Generation**: Creates a detailed inventory of all citations
   in your LaTeX paper, matching them to PDF files and DOIs
2. **Citation Validation**: Uses Claude Code AI to verify that citations accurately
   support the claims made in your academic text

FEATURES:
---------
• Scans LaTeX files for \cite{} and \textcite{} patterns
• Extracts DOIs from PDF files in your papers directory
• Matches citation keys to filenames automatically
• Generates structured citation inventory with file availability status
• AI-powered validation of citation accuracy using Claude Code
• Preserves previously analyzed citations to avoid duplicate work
• Parallel processing for improved performance

REQUIREMENTS:
-------------
• Python 3.6+
• PyMuPDF (pip install PyMuPDF) - for PDF DOI extraction
• Claude Code CLI (https://claude.ai/code) - for citation validation
• LaTeX project with references.bib and paper.tex files

USAGE:
------
Basic citation inventory generation:
    python3 citation_verifier.py

Citation validation (requires Claude Code):
    python3 citation_verifier.py -verify

The script will:
1. Parse your references.bib file for citation keys and DOIs
2. Scan your papers directory for PDF files and extract DOIs
3. Match files to citation keys by filename or DOI
4. Generate citation_inventory.md with detailed citation information
5. (With -verify) Validate each citation using AI analysis

OUTPUT FORMAT:
--------------
Each citation entry shows:
- Status: READY (has files), MISSING_FILE (missing PDFs), ANALYZED (verified)
- Citation keys in parentheses
- DOIs in parentheses (if available)
- Filenames in parentheses (if available)
- Line numbers where citations appear

Example: READY (smith2020,jones2021), (10.1000/abc123), (Smith2020.pdf) - 45,67,89

DIRECTORY STRUCTURE:
--------------------
Your project should have:
- paper.tex (your main LaTeX document)
- references.bib (your bibliography)
- papers/ (directory containing PDF files)
- citation_inventory.md (generated output)

======================
USER CONFIGURATION
======================
"""
# Directory containing PDF papers
PAPERS_DIR = 'papers' # Relative to the location of this script

# LaTeX source file to scan for citations
PAPER_TEX_FILE = 'paper.tex'

# BibTeX references file
REFERENCES_BIB_FILE = 'references.bib'

# Output file for citation inventory
OUTPUT_FILE = 'citation_inventory.md'

# Output file for citation analysis
ANALYSIS_FILE = 'citation_analysis.md'

# Timeout configurations (in seconds)
CLAUDE_TIMEOUT_PER_PARAGRAPH = 240  # 4 minutes per paragraph - allows time for Claude to process complex paragraphs
CLAUDE_TIMEOUT_VALIDATION = 600     # 10 minutes for validation - full paper analysis with multiple citations
MAX_PDF_SIZE_MB = 50                # Maximum PDF size to process - prevents memory issues with large files

# Process cleanup configurations (in seconds)
PROCESS_KILL_TIMEOUT = 5            # Time to wait for process termination after kill signal
PROCESS_TERMINATE_TIMEOUT = 2       # Time to wait for process termination after terminate signal

import re
import os
import sys
import subprocess
from collections import defaultdict
try:
    import fitz  # PyMuPDF
    PYMUPDF_AVAILABLE = True
except ImportError:
    PYMUPDF_AVAILABLE = False
    print("Warning: PyMuPDF not available. DOI extraction from PDFs will be skipped.")


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


def extract_doi_from_pdf(pdf_path):
    """Extract DOI from the first page of a PDF with size limits."""
    if not PYMUPDF_AVAILABLE:
        return None
    
    try:
        # Check file size before processing
        file_size_mb = os.path.getsize(pdf_path) / (1024 * 1024)
        if file_size_mb > MAX_PDF_SIZE_MB:
            print(f"Warning: Skipping {pdf_path} - file too large ({file_size_mb:.1f}MB > {MAX_PDF_SIZE_MB}MB)")
            return None
            
        doc = fitz.open(pdf_path)
        if len(doc) == 0:
            doc.close()
            return None
        
        # Get text from first page only
        first_page = doc[0]
        text = first_page.get_text()
        doc.close()
        
        # Common DOI patterns
        doi_patterns = [
            r'doi[:\s]*([0-9]+\.[0-9]+\/[^\s]+)',
            r'DOI[:\s]*([0-9]+\.[0-9]+\/[^\s]+)',
            r'https?:\/\/doi\.org\/([0-9]+\.[0-9]+\/[^\s]+)',
            r'https?:\/\/dx\.doi\.org\/([0-9]+\.[0-9]+\/[^\s]+)',
            r'doi\.org\/([0-9]+\.[0-9]+\/[^\s]+)',
        ]
        
        for pattern in doi_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                doi = match.group(1).rstrip('.,;)')
                return doi
        
        return None
    except Exception as e:
        print(f"Error extracting DOI from {pdf_path}: {e}")
        return None


def parse_all_citation_keys(bib_path):
    """Parse references.bib to get all citation keys."""
    all_citation_keys = set()
    
    try:
        with open(bib_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Warning: Bibliography file {bib_path} not found. Please ensure the file exists and the path is correct.")
        return set()
    
    # Split content into individual entries
    entries = re.split(r'(?=@\w+\{)', content)
    
    for entry in entries:
        if not entry.strip():
            continue
            
        # Extract citation key from the entry
        key_match = re.match(r'@\w+\{([^,]+),', entry)
        if key_match:
            citation_key = key_match.group(1).strip()
            all_citation_keys.add(citation_key)
    
    return all_citation_keys


def parse_bibtex_file(bib_path):
    """Parse references.bib to create mapping of citation keys to DOIs."""
    citation_to_doi = {}
    
    try:
        with open(bib_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Warning: Bibliography file {bib_path} not found. Please ensure the file exists and the path is correct.")
        return {}
    
    # Split content into individual entries
    entries = re.split(r'(?=@\w+\{)', content)
    
    for entry in entries:
        if not entry.strip():
            continue
            
        # Extract citation key from the entry
        key_match = re.match(r'@\w+\{([^,]+),', entry)
        if not key_match:
            continue
        
        citation_key = key_match.group(1).strip()
        
        # Look for DOI within this specific entry
        doi_match = re.search(r'DOI\s*=\s*\{([^}]+)\}', entry, re.IGNORECASE)
        if doi_match:
            doi = doi_match.group(1).strip()
            citation_to_doi[citation_key] = doi
    
    return citation_to_doi


def scan_papers_directory(papers_dir, all_citation_keys=None):
    """Scan papers directory for all files, extracting DOIs from PDFs and checking filenames for citation key matches."""
    file_to_doi = {}
    file_to_citation_key = {}
    documents_without_matches = []
    
    # Normalize papers_dir to absolute path
    papers_dir = normalize_path(papers_dir)
    
    if not os.path.exists(papers_dir):
        print(f"Warning: Papers directory {papers_dir} not found. Please create the directory and add your PDF files, or update PAPERS_DIR configuration.")
        return file_to_doi, file_to_citation_key, documents_without_matches
    
    print(f"Scanning papers directory recursively: {papers_dir}")
    for root, dirs, files in os.walk(papers_dir):
        # Skip hidden directories
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        
        for filename in files:
            # Skip hidden files
            if filename.startswith('.'):
                continue
                
            file_path = os.path.join(root, filename)
            # Show relative path for better readability (always relative to papers_dir)
            relative_path = os.path.relpath(file_path, papers_dir)
            print(f"  Processing: {relative_path}")
            
            doi_found = False
            
            # First try to extract DOI from PDF files only
            if filename.lower().endswith('.pdf'):
                doi = extract_doi_from_pdf(file_path)
                if doi:
                    file_to_doi[relative_path] = doi
                    print(f"    Found DOI: {doi}")
                    doi_found = True
            
            # If no DOI found (or not a PDF), check if filename (without extension) is a citation key
            if not doi_found:
                filename_without_ext = os.path.splitext(filename)[0]
                if all_citation_keys and filename_without_ext in all_citation_keys:
                    file_to_citation_key[relative_path] = filename_without_ext
                    print(f"    Filename matches citation key: {filename_without_ext}")
                else:
                    file_type = "PDF" if filename.lower().endswith('.pdf') else "file"
                    print(f"    No DOI found in {file_type} and filename doesn't match any citation key")
                    documents_without_matches.append(relative_path)
    
    return file_to_doi, file_to_citation_key, documents_without_matches


def create_citation_metadata(citation_to_doi, file_to_doi, file_to_citation_key):
    """Create mapping from citation keys to metadata including DOI and filename."""
    citation_metadata = {}
    
    # Create reverse mapping: DOI -> filename
    doi_to_file = {doi: filename for filename, doi in file_to_doi.items()}
    
    # Build citation metadata from DOI matches
    for citation_key, doi in citation_to_doi.items():
        metadata = {'doi': doi}
        if doi in doi_to_file:
            metadata['filename'] = doi_to_file[doi]
        citation_metadata[citation_key] = metadata
    
    # Add metadata for filename-based matches (files without DOIs but with matching citation keys)
    for filename, citation_key in file_to_citation_key.items():
        if citation_key in citation_metadata:
            # Citation key already has metadata from DOI match, add filename if not present
            if 'filename' not in citation_metadata[citation_key]:
                citation_metadata[citation_key]['filename'] = filename
        else:
            # Citation key only matched by filename
            citation_metadata[citation_key] = {
                'filename': filename,
                'doi': citation_to_doi.get(citation_key, '')
            }
    
    return citation_metadata


def extract_citations(file_path):
    """Extract citation patterns from LaTeX file and track line numbers."""
    citation_inventory = defaultdict(list)
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: LaTeX file {file_path} not found. Please ensure the file exists and PAPER_TEX_FILE configuration is correct.")
        return {}
    
    # Pattern to match \cite{...} and \textcite{...}
    citation_pattern = r'\\(?:text)?cite\{([^}]+)\}'
    
    for line_num, line in enumerate(lines, 1):
        # Find all citation matches in the line
        matches = re.finditer(citation_pattern, line)
        
        for match in matches:
            # Extract citation keys from the match
            keys_string = match.group(1)
            # Split by comma and clean up whitespace
            keys = [key.strip() for key in keys_string.split(',')]
            keys_tuple = tuple(keys)
            
            # Add line number to this key combination (avoid duplicates)
            if line_num not in citation_inventory[keys_tuple]:
                citation_inventory[keys_tuple].append(line_num)
    
    return citation_inventory


def format_citation_inventory(citation_inventory, citation_metadata=None):
    """Format the citation inventory for output."""
    # Sort by number of occurrences (lines), then by keys for consistency
    sorted_citations = sorted(
        citation_inventory.items(),
        key=lambda x: (len(x[1]), x[0]),
        reverse=True
    )
    
    output_lines = []
    
    for keys, line_numbers in sorted_citations:
        # Format keys - comma separated without parentheses
        keys_str = ','.join(keys)
        
        # Collect DOIs and filenames for all keys
        dois = []
        filenames = []
        keys_with_files = 0
        
        if citation_metadata:
            for key in keys:
                if key in citation_metadata:
                    metadata = citation_metadata[key]
                    if 'doi' in metadata:
                        dois.append(metadata['doi'])
                    if 'filename' in metadata:
                        filenames.append(metadata['filename'])
                        keys_with_files += 1
        
        # Determine if all keys have files available
        # READY: all keys have files, MISSING_FILE: at least one key missing file
        if len(keys) > 0 and keys_with_files == len(keys):
            prefix = "READY"
        else:
            prefix = "MISSING_FILE"
        
        # Format DOIs and filenames as comma-separated lists
        dois_str = ','.join(dois) if dois else ''
        filenames_str = ','.join(filenames) if filenames else ''
        
        # Format line numbers
        line_numbers_str = ','.join(map(str, sorted(line_numbers)))
        
        # Create output line with prefix: PREFIX (keys), (dois), (filenames) - line numbers
        output_line = f"{prefix} ({keys_str}), ({dois_str}), ({filenames_str}) - {line_numbers_str}"
        
        output_lines.append(output_line)
    
    return '\n'.join(output_lines)


def parse_citation_inventory(inventory_file):
    """Parse citation_inventory.md file to extract entries for verification."""
    entries = []
    
    # Normalize inventory_file to absolute path
    inventory_file = normalize_path(inventory_file)
    
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
        
        # Parse format: PREFIX (keys), (dois), (filenames) - line_numbers
        # Example: READY (berghSelfEvidencing), (10.1177/1745691620950690), (den Bergh et al. - 2021.pdf) - 478,502,509
        match = re.match(r'(\w+) \(([^)]+)\), \(([^)]*)\), \(([^)]*)\) - (.+)', line)
        if match:
            prefix = match.group(1)
            keys_str = match.group(2)
            dois_str = match.group(3)
            filenames_str = match.group(4)
            line_numbers_str = match.group(5)
            
            # Split keys, DOIs, filenames by comma
            citation_keys = [k.strip() for k in keys_str.split(',') if k.strip()]
            dois = [d.strip() for d in dois_str.split(',') if d.strip()]
            filenames = [f.strip() for f in filenames_str.split(',') if f.strip()]
            line_numbers = [int(n.strip()) for n in line_numbers_str.split(',') if n.strip().isdigit()]
            
            entries.append({
                'prefix': prefix,
                'citation_keys': citation_keys,
                'dois': dois,
                'filenames': filenames,
                'line_numbers': line_numbers,
                'raw_line': line
            })
    
    return entries


def get_line_contents_from_paper(line_numbers, paper_file=PAPER_TEX_FILE):
    """Fetch line contents from paper.tex for given line numbers."""
    line_info = []
    
    # Normalize paper_file to absolute path
    paper_file = normalize_path(paper_file)
    
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


def _resolve_file_path(filename, papers_dir):
    """Resolve filename to absolute path, handling both relative and absolute paths."""
    return normalize_path(filename, papers_dir)

def call_claude_for_verification(filenames, citation_keys, line_info, papers_dir=PAPERS_DIR):
    """Call Claude Code to verify citations using two sequential calls with parallelized first step."""
    if not filenames:
        raise Exception("No filenames available for verification")
    
    # Prepare file paths for Claude - normalize all to absolute paths
    file_paths = []
    for filename in filenames:
        file_path = _resolve_file_path(filename, papers_dir)
        
        if os.path.exists(file_path):
            file_paths.append(file_path)
        else:
            print(f"Warning: PDF file {filename} not found at {file_path}. Check file path or move file to papers directory.")
    
    if not file_paths:
        raise Exception("No valid files found for verification")
    
    # Group line info into paragraphs (consecutive lines form paragraphs)
    paragraphs = []
    current_paragraph = []
    
    for line_num, line_content in line_info:
        if current_paragraph and line_num > current_paragraph[-1][0] + 1:
            # Gap in line numbers - start new paragraph
            paragraphs.append(current_paragraph)
            current_paragraph = [(line_num, line_content)]
        else:
            current_paragraph.append((line_num, line_content))
    
    if current_paragraph:
        paragraphs.append(current_paragraph)
    
    # Remove unused original_paragraphs variable
    
    # Format filenames and citation keys for the prompt
    filenames_text = ', '.join(filenames)
    citation_keys_text = ', '.join(citation_keys)
    
    try:
        # FIRST CLAUDE CALLS: Split each paragraph into Attribution Units (parallelized)
        print(f"     → Step 1: Marking attribution units in {len(paragraphs)} paragraphs...")
        
        paragraph_results = []
        processes = []
        
        # Create a separate Claude call for each paragraph
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
        
        # Collect results from all parallel processes with proper cleanup
        def cleanup_processes(processes_to_cleanup, exclude_process=None):
            """Helper function to safely cleanup subprocess list."""
            for proc, _ in processes_to_cleanup:
                if proc != exclude_process and proc.poll() is None:
                    try:
                        proc.kill()
                        proc.wait(timeout=PROCESS_KILL_TIMEOUT)
                    except subprocess.TimeoutExpired:
                        try:
                            proc.terminate()
                            proc.wait(timeout=PROCESS_TERMINATE_TIMEOUT)
                        except subprocess.TimeoutExpired:
                            pass  # Process cleanup failed, but we've done our best
                    except Exception:
                        pass  # Ignore cleanup errors
        
        try:
            for process, paragraph_index in processes:
                try:
                    stdout, stderr = process.communicate(timeout=CLAUDE_TIMEOUT_PER_PARAGRAPH)
                    if process.returncode != 0:
                        cleanup_processes(processes, exclude_process=process)
                        raise Exception(f"Claude call failed for paragraph {paragraph_index + 1}: {stderr}")
                    paragraph_results.append((paragraph_index, stdout.strip()))
                except subprocess.TimeoutExpired:
                    process.kill()
                    cleanup_processes(processes, exclude_process=process)
                    raise Exception(f"Claude verification timed out for paragraph {paragraph_index + 1}")
        except Exception as e:
            # Final cleanup attempt for any remaining processes
            cleanup_processes(processes)
            raise e
        
        # Sort results by paragraph index to maintain original order
        paragraph_results.sort(key=lambda x: x[0])
        
        # SECOND CLAUDE CALL: Validate each Attribution Unit against the cited papers
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
            timeout=CLAUDE_TIMEOUT_VALIDATION
        )
        
        if result2.returncode != 0:
            raise Exception(f"Second Claude call failed: {result2.stderr}")
        
        analysis_output = result2.stdout.strip()
        if not analysis_output:
            raise Exception("Second Claude call returned no output")
        
        # Return both marked-up paragraphs (from first Claude stage) and analysis
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


def run_verify(inventory_file=OUTPUT_FILE, analysis_file=ANALYSIS_FILE):
    """Run verification process on citation inventory, appending results to analysis file."""
    print("=== Citation Verification Process ===")
    
    # Normalize file paths to absolute paths
    inventory_file = normalize_path(inventory_file)
    analysis_file = normalize_path(analysis_file)
    
    # Parse citation inventory
    print(f"1. Parsing {inventory_file}...")
    entries = parse_citation_inventory(inventory_file)
    
    if not entries:
        print("No entries found in citation inventory.")
        return
    
    print(f"   Found {len(entries)} entries")
    
    # Process each entry
    for i, entry in enumerate(entries, 1):
        print(f"\n[{i}/{len(entries)}] Processing entry: {', '.join(entry['citation_keys'])}")
        
        # Only verify READY entries that have filenames
        if entry['prefix'] != 'READY' or not entry['filenames']:
            print(f"   ⏭️  Skipping verification (status: {entry['prefix']})")
            continue
        
        # Get line contents from paper.tex
        line_info = get_line_contents_from_paper(entry['line_numbers'])
        
        if not line_info:
            print("   ❌ No line contents found")
            continue
        
        # Run Claude verification
        try:
            result = call_claude_for_verification(
                entry['filenames'], 
                entry['citation_keys'], 
                line_info
            )
        except Exception as e:
            print(f"   ❌ Verification failed: {str(e)}")
            continue
        
        print(f"   ✅ Verification completed")
        
        # Append results to analysis file
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
            
            print(f"   ✅ Analysis written to {analysis_file}")
            
        except Exception as e:
            print(f"   ❌ Error writing analysis: {e}")
    
    print(f"\n2. Processing complete! Results saved to {analysis_file}")


def main():
    # Normalize all file paths to absolute paths
    input_file = normalize_path(PAPER_TEX_FILE)
    output_file = normalize_path(OUTPUT_FILE)
    bib_file = normalize_path(REFERENCES_BIB_FILE)
    papers_dir = normalize_path(PAPERS_DIR)
    
    print("=== Citation Verifier Enhanced ===")
    
    # Step 1: Parse references.bib for all citation keys and DOI mapping
    print("\n1. Parsing references.bib...")
    all_citation_keys = parse_all_citation_keys(bib_file)
    citation_to_doi = parse_bibtex_file(bib_file)
    print(f"   Found {len(all_citation_keys)} total citation keys")
    print(f"   Found {len(citation_to_doi)} citation keys with DOIs")
    
    # Step 2: Extract DOIs from PDFs and process all files in papers directory
    print("\n2. Processing files in papers directory...")
    file_to_doi, file_to_citation_key, documents_without_matches = scan_papers_directory(papers_dir, all_citation_keys)
    print(f"   Found DOIs in {len(file_to_doi)} PDF files")
    print(f"   Found {len(file_to_citation_key)} files matched by filename to citation keys")
    
    # Display documents without DOIs or citation key matches
    if documents_without_matches:
        print(f"\n\033[31mCan't find DOI's or citation key matches for the following files. Manually change filenames to citation keys so the files can be properly indexed.\033[0m")
        for filename in documents_without_matches:
            print(f"  {filename}")
    else:
        print("\n   All files have extractable DOIs or filename matches")
    
    # Step 3: Create citation metadata
    citation_metadata = create_citation_metadata(citation_to_doi, file_to_doi, file_to_citation_key)
    
    # Step 4: Extract citations from paper.tex
    print(f"\n3. Scanning {input_file} for citations...")
    citation_inventory = extract_citations(input_file)
    
    if not citation_inventory:
        print("No citations found or error reading file.")
        return
    
    print(f"   Found {len(citation_inventory)} unique citation key combinations")
    print(f"   Total citation instances: {sum(len(lines) for lines in citation_inventory.values())}")
    
    # Step 5: Format and write output
    print(f"\n4. Writing results to {output_file}...")
    formatted_output = format_citation_inventory(citation_inventory, citation_metadata)
    
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(formatted_output)
        print(f"   Citation inventory written to {output_file}")
    except IOError as e:
        print(f"   Error writing to {output_file}: {e}")
        return
    
    # Step 6: Print summary to console
    print("\n=== Summary ===")
    print(f"Files processed: {len(file_to_doi) + len(file_to_citation_key) + len(documents_without_matches)}")
    print(f"Files with extractable DOIs: {len(file_to_doi)}")
    print(f"Files matched by filename: {len(file_to_citation_key)}")
    print(f"Citation keys in references.bib: {len(citation_to_doi)}")
    matched_files = sum(1 for metadata in citation_metadata.values() if 'filename' in metadata)
    print(f"Citation keys matched to files: {matched_files}")
    print(f"Unique citation combinations in paper.tex: {len(citation_inventory)}")
    print(f"Total citation instances: {sum(len(lines) for lines in citation_inventory.values())}")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "-verify":
        run_verify()
    else:
        main()