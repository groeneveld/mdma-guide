#!/usr/bin/env python3
"""


USAGE:
    python citation_verifier.py             - Scan papers directory and update citation status file
    python citation_verifier.py verify      - Run citation verification with Claude Code on PENDING entries
    python citation_verifier.py verify test - Test mode (show what would be verified without running)
    python citation_verifier.py help        - Show help information

WORKFLOW:
    1. Run without arguments to scan the papers directory, extract DOIs/citation keys, and append new papers as entries in citation_analysis.md
    2. Use 'verify' command to analyze PENDING entries with Claude Code
    3. Review results in citation_analysis.md

REQUIREMENTS:
    - pdftotext (for DOI extraction from PDFs). Can be found in poppler (brew install poppler for Mac)
    - Claude Code CLI (for citation verification, install from https://claude.ai/code)
    - LaTeX project with references.bib and paper.tex files
    - Papers directory containing PDF files to analyze

CONFIGURATION:
    Update the user-defined variables below to match your project structure.
"""

# =============================================================================
# USER-DEFINED VARIABLES - Modify these to match your project structure
# =============================================================================
REFERENCES_BIB_FILE = "references.bib"  # Path to your bibliography file
PAPER_TEX_FILE = "paper.tex"            # Path to your main LaTeX document
PAPERS_DIRECTORY = "papers"             # Directory containing PDF papers to analyze
CITATION_ANALYSIS_FILE = "citation_analysis.md"  # Output file for tracking analysis
# =============================================================================

import os
import glob
import re
import subprocess
import json
import tempfile

def get_papers_filenames():
    """Get all filenames in the papers directory."""
    papers_dir = PAPERS_DIRECTORY
    if not os.path.exists(papers_dir):
        print(f"Warning: {papers_dir} directory does not exist")
        return []
    
    # Get all files in papers directory
    pattern = os.path.join(papers_dir, "*")
    files = glob.glob(pattern)
    
    # Extract just the filenames (not full paths)
    filenames = [os.path.basename(f) for f in files if os.path.isfile(f)]
    return filenames

def extract_citation_key_from_bib(doi):
    """Extract citation key from references.bib based on DOI match."""
    if not doi:
        return None
        
    bib_file = REFERENCES_BIB_FILE
    if not os.path.exists(bib_file):
        return None
    
    with open(bib_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find citation entries that match the DOI
    # Look for DOI field in bib entries
    citation_pattern = r'@\w+\{([^,]+),\s*\n(?:[^@]*?)DOI\s*=\s*\{([^}]+)\}'
    
    for match in re.finditer(citation_pattern, content, re.IGNORECASE | re.MULTILINE):
        citation_key = match.group(1)
        bib_doi = match.group(2).strip()
        
        # Clean up DOI for comparison (remove doi.org prefix if present)
        bib_doi_clean = re.sub(r'^(?:https?://)?(?:www\.)?doi\.org/', '', bib_doi)
        doi_clean = re.sub(r'^(?:https?://)?(?:www\.)?doi\.org/', '', doi)
        
        if bib_doi_clean.lower() == doi_clean.lower():
            return citation_key
    
    return None

def find_citation_line_info(citation_key, paper_file=PAPER_TEX_FILE):
    """Find all line numbers and contents in paper.tex where the given citation key is cited.
    
    Args:
        citation_key (str): The citation key to search for
        paper_file (str): Path to the paper file to search in
        
    Returns:
        list: List of tuples (line_number, line_content) where the citation is found
    """
    if not citation_key or citation_key == 'NO_CITATION_KEY':
        return []
        
    if not os.path.exists(paper_file):
        return []
    
    citation_info = []
    
    try:
        with open(paper_file, 'r', encoding='utf-8') as f:
            for line_num, line in enumerate(f, 1):
                # Look for \cite{citation_key} or \cite{...citation_key...} patterns
                # This matches various citation formats like:
                # \cite{citation_key}
                # \cite{other,citation_key}
                # \cite{citation_key,other}
                # \cite{some,citation_key,others}
                cite_pattern = r'\\cite(?:\[[^\]]*\])?\{[^}]*\b' + re.escape(citation_key) + r'\b[^}]*\}'
                if re.search(cite_pattern, line):
                    citation_info.append((line_num, line.strip()))
    except Exception as e:
        print(f"Warning: Error reading {paper_file}: {e}")
        return []
    
    return citation_info

def extract_doi_from_pdf(filename):
    """Extract DOI from the first page of a PDF using pdftotext."""
    papers_dir = PAPERS_DIRECTORY
    pdf_path = os.path.join(papers_dir, filename)
    
    if not os.path.exists(pdf_path):
        return None
    
    try:
        # Use pdftotext to extract text from first page only
        result = subprocess.run(
            ['pdftotext', '-f', '1', '-l', '1', pdf_path, '-'],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode != 0:
            print(f"Warning: pdftotext failed for {filename}")
            return None
        
        text = result.stdout
        
        # Look for DOI patterns in the text
        # Common DOI patterns: 10.xxxx/xxxxx or doi:10.xxxx/xxxxx or https://doi.org/10.xxxx/xxxxx
        doi_patterns = [
            r'(?:doi:?\s*)?(?:https?://(?:www\.)?doi\.org/)?(10\.\d+/[^\s\]\)>,]+)',
            r'DOI:?\s*(10\.\d+/[^\s\]\)>,]+)',
            r'doi\.org/(10\.\d+/[^\s\]\)>,]+)'
        ]
        
        for pattern in doi_patterns:
            matches = re.finditer(pattern, text, re.IGNORECASE)
            for match in matches:
                doi = match.group(1)
                # Clean up common trailing characters
                doi = re.sub(r'[.,;:\]\)}>]*$', '', doi)
                return doi
        
        return None
        
    except subprocess.TimeoutExpired:
        print(f"Warning: pdftotext timeout for {filename}")
        return None
    except Exception as e:
        print(f"Warning: Error processing {filename}: {e}")
        return None

def read_existing_citation_file():
    """Read existing citation_analysis.md and return dict of filename -> (status, citation_key, doi)."""
    citation_file = CITATION_ANALYSIS_FILE
    existing_files = {}
    
    if os.path.exists(citation_file):
        with open(citation_file, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Parse both old table format and new FILE_ENTRY format
        # Old table format: | filename | status | citation_key | doi |
        table_pattern = r'\|\s*([^|]+?)\s*\|\s*(PENDING|ANALYZED)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|'
        
        for match in re.finditer(table_pattern, content):
            filename = match.group(1).strip()
            status = match.group(2).strip()
            citation_key = match.group(3).strip() if match.group(3).strip() not in ['', 'NO_CITATION_KEY'] else None
            doi = match.group(4).strip() if match.group(4).strip() not in ['', 'NO_DOI'] else None
            
            existing_files[filename] = (status, citation_key, doi)
        
        # New FILE_ENTRY format: FILE_ENTRY: filename | status | citation_key | doi
        entry_pattern = r'FILE_ENTRY:\s*([^|]+?)\s*\|\s*(PENDING|ANALYZED)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)(?:\s*$|\s*\n)'
        
        for match in re.finditer(entry_pattern, content, re.MULTILINE):
            filename = match.group(1).strip()
            status = match.group(2).strip()
            citation_key = match.group(3).strip() if match.group(3).strip() not in ['', 'NO_CITATION_KEY'] else None
            doi = match.group(4).strip() if match.group(4).strip() not in ['', 'NO_DOI'] else None
            
            existing_files[filename] = (status, citation_key, doi)
    
    return existing_files

def write_citation_file(files_dict):
    """Write the citation_analysis.md file with all files using FILE_ENTRY format."""
    citation_file = CITATION_ANALYSIS_FILE
    
    with open(citation_file, 'w', encoding='utf-8') as f:
        f.write("# Citation Analysis Status\n\n")
        f.write("This file tracks the analysis status of papers in the `papers/` directory.\n\n")
        f.write("## Status Legend\n")
        f.write("- **PENDING**: Not yet analyzed\n")
        f.write("- **ANALYZED**: Analysis completed with Claude verification\n\n")
        f.write("## Papers\n\n")
        
        for filename in sorted(files_dict.keys()):
            status, citation_key, doi = files_dict[filename]
            
            safe_citation = citation_key or 'NO_CITATION_KEY'
            safe_doi = doi or 'NO_DOI'
            
            f.write(f"FILE_ENTRY: {filename} | {status} | {safe_citation} | {safe_doi}\n\n")

def append_new_entries_to_citation_file(new_files_dict):
    """Append only new entries to the citation_analysis.md file."""
    citation_file = CITATION_ANALYSIS_FILE
    
    with open(citation_file, 'a', encoding='utf-8') as f:
        for filename in sorted(new_files_dict.keys()):
            status, citation_key, doi = new_files_dict[filename]
            
            safe_citation = citation_key or 'NO_CITATION_KEY'
            safe_doi = doi or 'NO_DOI'
            
            f.write(f"FILE_ENTRY: {filename} | {status} | {safe_citation} | {safe_doi}\n\n")

def verify_citation_with_claude(filename, citation_key, doi, line_info):
    """
    Verify citations using Claude Code by calling 'claude -p' for each entry.
    
    Args:
        filename (str): PDF filename to analyze
        citation_key (str): Citation key from references.bib
        doi (str): DOI of the paper
        line_info (list): List of tuples (line_number, line_content) where citation appears
        
    Returns:
        str: Claude's analysis response, or None if verification fails
    """
    papers_dir = PAPERS_DIRECTORY
    pdf_path = os.path.join(papers_dir, filename)
    
    if not os.path.exists(pdf_path):
        return f"Error: PDF file {filename} not found"
    
    if not citation_key or citation_key == 'NO_CITATION_KEY':
        return "Error: No citation key available for verification"
    
    if not line_info:
        return "Error: No citation lines found in paper.tex"
    
    # Prepare the prompt for Claude
    citation_lines_text = ""
    for line_num, line_content in line_info:
        citation_lines_text += f"Line {line_num}: {line_content}\n"
    
    prompt = f"""You're going to be assessing whether claims from selected paragraphs of a paper are justified by their citation. First read the citation {filename}. Then break each paragraph of the paper here ***{citation_lines_text}*** into chunks based on which parts rely on the citation you read, as indicated by its citation key {citation_key}. The style is APA, so a chunk will typically start with the first sentence where that citation is used, and ends with the last sentence before a different citation is used or the prose switches to opinion. Sometimes the chunk will just be a clause if there are multiple citations at different points in a sentence. We're only looking at chunks that at least partially rely on this citation; don't include sentences and clauses that only rely on other citations, you can discard them and not include them in your response.

    Return results as a list with each line being '**Line <num>:** *Original unmodified chunk (including citations) starting with the sentence where the citation is first used, and including following sentences up until it switched to opinion or a different citation.*' Then on the next line '<✅ or ❌> <analysis>'. If the paper doesn't support the claim and it isn't a reasonable extrapolation tell me why in your own words for <analysis>. Don't return any <analysis> for well-supported chunks; that's too much clutter. The asterisks in this paragraph indicate markdown tags. Don't remove them.
    
    Don't say anything like 'now I'll do...', 'I've analyzed...', or anything except the previously specified list.

    If a chunk relies on multiple citations display ⚠️ instead of a check or x, then say which parts are supported and not supported as <analysis>.
     
    """
    
    try:
        # Create a temporary file for the prompt if needed
        result = subprocess.run(
            ['claude', '-p', prompt, pdf_path],
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )
        
        if result.returncode != 0:
            return f"Error running claude command: {result.stderr}"
        
        return result.stdout.strip()
        
    except subprocess.TimeoutExpired:
        return "Error: Claude verification timed out (5 minutes)"
    except FileNotFoundError:
        return "Error: 'claude' command not found. Please ensure Claude Code CLI is installed and in PATH"
    except Exception as e:
        return f"Error during Claude verification: {str(e)}"

def update_citation_file_with_verification(files_dict, verification_results):
    """
    Update the citation_analysis.md file with verification results using inline analysis format.
    
    Args:
        files_dict (dict): Dictionary of filename -> (status, citation_key, doi)
        verification_results (dict): Dictionary of filename -> verification_result_string
    """
    citation_file = CITATION_ANALYSIS_FILE
    
    with open(citation_file, 'w', encoding='utf-8') as f:
        f.write("# Citation Analysis Status\n\n")
        f.write("This file tracks the analysis status of papers in the `papers/` directory.\n\n")
        f.write("## Status Legend\n")
        f.write("- **PENDING**: Not yet analyzed\n")
        f.write("- **ANALYZED**: Analysis completed with Claude verification\n\n")
        f.write("## Papers\n\n")
        
        for filename in sorted(files_dict.keys()):
            status, citation_key, doi = files_dict[filename]
            
            safe_citation = citation_key or 'NO_CITATION_KEY'
            safe_doi = doi or 'NO_DOI'
            
            # Write FILE_ENTRY marker
            f.write(f"FILE_ENTRY: {filename} | {status} | {safe_citation} | {safe_doi}\n\n")
            
            # Add inline verification results if available
            if filename in verification_results:
                verification_text = verification_results[filename]
                f.write(f"{verification_text}\n\n")
            
            f.write("---\n\n")

def run_citation_verification(test_mode=False):
    """
    Run citation verification for all new (PENDING) entries using Claude Code.
    
    Args:
        test_mode (bool): If True, don't actually call Claude, just show what would be verified
    """
    print("Starting citation verification process...")
    
    # Read existing citation file
    existing_files = read_existing_citation_file()
    
    # Find all PENDING files that have citation keys and line info
    pending_files = []
    for filename, (status, citation_key, doi) in existing_files.items():
        if status == 'PENDING' and citation_key and citation_key != 'NO_CITATION_KEY':
            # Get line info for this citation
            line_info = find_citation_line_info(citation_key)
            if line_info:
                pending_files.append((filename, citation_key, doi, line_info))
    
    if not pending_files:
        print("No pending files with citation keys and line info found for verification.")
        return
    
    print(f"Found {len(pending_files)} files to verify:")
    
    if test_mode:
        print("\n🧪 Test mode - showing what would be verified:")
        for filename, citation_key, doi, line_info in pending_files:
            print(f"\nWould verify {filename}:")
            print(f"  Citation key: {citation_key}")
            print(f"  DOI: {doi}")
            print(f"  Citations found in paper.tex:")
            for line_num, line_content in line_info:
                print(f"    Line {line_num}: {line_content[:100]}...")
        return
    
    verification_results = {}
    
    # Process each pending file
    for i, (filename, citation_key, doi, line_info) in enumerate(pending_files, 1):
        print(f"\n[{i}/{len(pending_files)}] Verifying {filename}...")
        
        result = verify_citation_with_claude(filename, citation_key, doi, line_info)
        verification_results[filename] = result
        
        if result.startswith("Error:"):
            print(f"  ❌ Verification failed: {result}")
        else:
            print(f"  ✅ Verification completed")
        
        # Update status to ANALYZED
        existing_files[filename] = ('ANALYZED', citation_key, doi)
        
        # Write updated file with verification results after each entry
        update_citation_file_with_verification(existing_files, verification_results)
    
    print(f"All results have been written to {CITATION_ANALYSIS_FILE}")

def main():
    """Main function to manage citation analysis status file."""
    print("Scanning papers directory...")
    
    # Get current files in papers directory
    current_files = get_papers_filenames()
    print(f"Found {len(current_files)} files in papers directory")
    
    # Read existing citation file
    existing_files = read_existing_citation_file()
    print(f"Found {len(existing_files)} files in existing {CITATION_ANALYSIS_FILE}")
    
    
    # Track new files separately to avoid rewriting entire file
    new_files = {}
    new_files_count = 0
    
    # Add new files that aren't already tracked
    for filename in current_files:
        if filename not in existing_files:
            # Extract DOI from PDF first
            print(f"Extracting DOI from {filename}...")
            doi = extract_doi_from_pdf(filename)
            
            # Then try to find citation key based on DOI
            citation_key = extract_citation_key_from_bib(doi)
            
            new_files[filename] = ('PENDING', citation_key, doi)
            new_files_count += 1
            
            status_parts = []
            error_messages = []
            
            if doi:
                status_parts.append(f"DOI: {doi}")
            else:
                status_parts.append("no DOI found")
                error_messages.append(f"❌ NO DOI FOUND for {filename}")
                
            if citation_key:
                status_parts.append(f"citation: {citation_key}")
            else:
                status_parts.append("no citation key found")
                if doi:
                    error_messages.append(f"❌ NO CITATION KEY FOUND for {filename} (DOI: {doi}) - may need to be added to references.bib")
                else:
                    error_messages.append(f"❌ NO CITATION KEY FOUND for {filename} (no DOI extracted)")
            
            print(f"Added new file: {filename} ({', '.join(status_parts)})")
            
            # Show high visibility error messages
            for error_msg in error_messages:
                print(f"\n{'='*80}")
                print(f"  {error_msg}")
                print(f"{'='*80}\n")
    
    # Only append new entries if there were new files found
    if new_files_count > 0:
        append_new_entries_to_citation_file(new_files)
    
    # Calculate totals for summary
    all_files = {**existing_files, **new_files}
    
    print(f"\nSummary:")
    print(f"- Total files tracked: {len(all_files)}")
    print(f"- New files added: {new_files_count}")
    
    # Show status breakdown
    analyzed_count = sum(1 for status, _, _ in all_files.values() if status == 'ANALYZED')
    pending_count = sum(1 for status, _, _ in all_files.values() if status == 'PENDING')
    
    print(f"- Files analyzed: {analyzed_count}")
    print(f"- Files pending: {pending_count}")
    print(f"\nCitation analysis status file updated: {CITATION_ANALYSIS_FILE}")
    

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        if sys.argv[1] == "verify":
            if len(sys.argv) > 2 and sys.argv[2] == "test":
                run_citation_verification(test_mode=True)
            else:
                run_citation_verification()
        elif sys.argv[1] == "help":
            print("Citation Manager Commands:")
            print("  python citation_manager.py           - Update citation status file")
            print("  python citation_manager.py verify    - Run citation verification with Claude")
            print("  python citation_manager.py verify test - Test mode (show what would be verified)")
        else:
            print("Unknown command. Use 'help' for available commands.")
    else:
        main()