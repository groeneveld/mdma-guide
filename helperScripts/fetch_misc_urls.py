#!/usr/bin/env python3
"""
Script to find @MISC entries in references.bib that have URLs but no DOIs,
fetch the webpages, convert to clean text using html2text, and save as files.
"""

import re
import os
import sys
import time
import requests
import html2text
from urllib.parse import urlparse
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def parse_bib_file(filepath):
    """Parse BibTeX file and extract @MISC entries with URLs but no DOIs."""
    misc_entries = []
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all @MISC entries
    misc_pattern = r'@MISC\{([^,]+),\s*(.*?)(?=@[A-Z]+\{|$)'
    misc_matches = re.findall(misc_pattern, content, re.DOTALL | re.IGNORECASE)
    
    for citation_key, entry_content in misc_matches:
        # Check if entry has URL but no DOI
        has_url = re.search(r'URL\s*=\s*\{([^}]+)\}', entry_content, re.IGNORECASE)
        has_doi = re.search(r'DOI\s*=', entry_content, re.IGNORECASE)
        
        if has_url and not has_doi:
            url = has_url.group(1)
            # Extract title for logging
            title_match = re.search(r'TITLE\s*=\s*\{([^}]+)\}', entry_content, re.IGNORECASE)
            title = title_match.group(1) if title_match else "No title"
            
            misc_entries.append({
                'citation_key': citation_key.strip(),
                'url': url.strip(),
                'title': title.strip()
            })
    
    return misc_entries

def fetch_and_convert_webpage(url, output_path, citation_key):
    """Fetch webpage and convert to clean text using html2text."""
    try:
        logger.info(f"Fetching: {url}")
        
        # Set up headers to mimic a real browser
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
        }
        
        # Fetch the webpage
        response = requests.get(url, headers=headers, timeout=30)
        response.raise_for_status()
        
        # Convert HTML to clean text using html2text
        h = html2text.HTML2Text()
        h.ignore_links = True  # Remove link URLs for cleaner text
        h.ignore_images = True  # Remove image references
        h.body_width = 0  # Don't wrap lines
        h.unicode_snob = True  # Use unicode characters
        
        text = h.handle(response.text)
        
        # Clean up excessive whitespace while preserving paragraph structure
        lines = text.split('\n')
        cleaned_lines = []
        prev_empty = False
        
        for line in lines:
            line = line.rstrip()
            if line.strip() == '':
                if not prev_empty:
                    cleaned_lines.append('')
                prev_empty = True
            else:
                cleaned_lines.append(line)
                prev_empty = False
        
        text = '\n'.join(cleaned_lines).strip()
        
        # Save to file
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(f"Citation Key: {citation_key}\n")
            f.write(f"URL: {url}\n")
            f.write(f"Fetched: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("-" * 80 + "\n\n")
            f.write(text)
        
        logger.info(f"Saved: {output_path}")
        return True
        
    except requests.exceptions.RequestException as e:
        logger.error(f"Error fetching {url}: {e}")
        return False
    except Exception as e:
        logger.error(f"Error processing {url}: {e}")
        return False

def main():
    """Main function."""
    bib_file = 'references.bib'
    papers_dir = 'papers'
    
    # Check if files/directories exist
    if not os.path.exists(bib_file):
        logger.error(f"BibTeX file not found: {bib_file}")
        sys.exit(1)
    
    if not os.path.exists(papers_dir):
        logger.info(f"Creating papers directory: {papers_dir}")
        os.makedirs(papers_dir)
    
    # Parse BibTeX file
    logger.info(f"Parsing {bib_file}...")
    misc_entries = parse_bib_file(bib_file)
    
    logger.info(f"Found {len(misc_entries)} @MISC entries with URLs but no DOIs")
    
    if not misc_entries:
        logger.info("No entries to process.")
        return
    
    # Process each entry
    successful = 0
    failed = 0
    
    for i, entry in enumerate(misc_entries, 1):
        citation_key = entry['citation_key']
        url = entry['url']
        title = entry['title']
        
        output_path = os.path.join(papers_dir, f"{citation_key}.txt")
        
        logger.info(f"Processing {i}/{len(misc_entries)}: {citation_key}")
        logger.info(f"  Title: {title}")
        
        # Skip if file already exists
        if os.path.exists(output_path):
            logger.info(f"  File already exists, skipping: {output_path}")
            continue
        
        # Fetch and save
        if fetch_and_convert_webpage(url, output_path, citation_key):
            successful += 1
        else:
            failed += 1
        
        # Be respectful to servers - add a small delay
        time.sleep(1)
    
    logger.info(f"Completed: {successful} successful, {failed} failed")

if __name__ == '__main__':
    main()