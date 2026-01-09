import re
import os

# Configuration: List of tags whose contents should be skipped
SKIP_TAGS = [
    'label',      # Skip \label{...}
    'ref',        # Skip \ref{...}
    'cite',       # Skip all citation commands 
    'todo',       # Skip \todo{...}
    'hyperref',   # Skip \hyperref{...}
    'url',        # Skip \url{...}
    'textcite',
    'nameref',
    'nameref*',
    'combinedref',
    'cref',
    'prosecite',
    # Add more tags here as needed
]

def extract_glossary_terms(glossary_file):
    """Extract term IDs, names, stems, and defined_in sections from glossary.tex"""
    with open(glossary_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Split by newglossaryentry to find the start of each entry
    parts = content.split('\\newglossaryentry{')
    
    # Dictionary to store term data
    glossary_terms = {}
    
    # Counters for debugging
    total_entries = 0
    entries_with_stems = 0
    total_stems = 0
    
    # Process each entry (skip the first part which is before any entry)
    for part in parts[1:]:
        if not part.strip():
            continue
            
        total_entries += 1
        
        # Extract term_id
        term_id_end = part.find('}')
        term_id = part[:term_id_end].strip()
        
        # Find the content between the first { after term_id and its matching }
        content_start = part.find('{', term_id_end + 1)
        
        # Count braces to find the matching closing brace
        brace_count = 1
        content_end = content_start + 1
        
        while brace_count > 0 and content_end < len(part):
            if part[content_end] == '{':
                brace_count += 1
            elif part[content_end] == '}':
                brace_count -= 1
            content_end += 1
        
        # Extract the entry content
        entry_content = part[content_start + 1:content_end - 1].strip()
        
        # Extract name
        name_match = re.search(r'name={([^}]+)}', entry_content)
        name = name_match.group(1) if name_match else None
        
        # Extract defined_in section (commented out)
        defined_in_match = re.search(r'%defined_in={([^}]+)}', entry_content)
        defined_in = defined_in_match.group(1) if defined_in_match else None
        
        # Extract stems (with % comment)
        stems_match = re.search(r'%stem={([^}]+)}', entry_content)
        
        # Process stems if they exist
        stems = []
        if stems_match:
            # Split stems by comma and strip whitespace
            stems = [f.strip() for f in stems_match.group(1).split(',')]
            entries_with_stems += 1
            total_stems += len(stems)
            print(f"Found {len(stems)} stems for {term_id}: {stems}")
        
        # Store the term data
        glossary_terms[term_id] = {
            'name': name,
            'defined_in': defined_in,
            'stems': stems
        }
    
    # Print summary
    print(f"\nGlossary Summary:")
    print(f"Total entries: {total_entries}")
    print(f"Entries with stems: {entries_with_stems}")
    print(f"Total stems: {total_stems}")
    
    return glossary_terms

def find_all_headings(content):
    """Find all section and subsection heading positions in the document"""
    heading_matches = []
    # Define the pattern for LaTeX section and subsection commands (including starred versions)
    heading_pattern = r'\\(chapter|section|subsection|subsubsection)\*?{[^}]*}'

    for match in re.finditer(heading_pattern, content):
        heading_matches.append((match.start(), match.end(), match.group()))

    return heading_matches

def find_all_skip_tag_positions(content, skip_tags):
    """Find all positions of content inside tags that should be skipped"""
    skip_positions = []
    
    # Escape each tag to handle special regex characters like * in nameref*
    escaped_tags = [re.escape(tag) for tag in skip_tags]
    
    # Create a pattern like: \\(label|ref|cite|todo){[^}]*}
    tags_pattern = f'\\\\({"|".join(escaped_tags)}){{[^}}]*}}'
    
    # Find all matches
    for match in re.finditer(tags_pattern, content):
        skip_positions.append((match.start(), match.end()))
    
    return skip_positions

def is_position_in_skip_zone(position, skip_positions):
    """Check if a position is within any skip zone"""
    for start, end in skip_positions:
        if start <= position < end:
            return True
    return False

def is_in_heading(position, headings):
    """Check if a position is within any heading"""
    for start, end, _ in headings:
        if start <= position < end:
            return True
    return False

def process_paper(paper_file, glossary_terms):
    """Process the paper file to replace first occurrences of glossary stems"""
    with open(paper_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all section, subsection, etc. headings
    all_headings = find_all_headings(content)
    
    # Find all positions that should be skipped (tag contents)
    skip_positions = find_all_skip_tag_positions(content, SKIP_TAGS)
    
    # Find all section boundaries
    section_matches = list(re.finditer(r'\\section{([^}]+)}', content))
    
    # Keep track of all replacements
    replacements = []
    
    # Count statistics
    stats = {
        'total_sections': 0,
        'skipped_quick_start': 0,
        'total_term_checks': 0,
        'skipped_defined_in': 0,
        'not_found': 0,
        'skipped_in_tag': 0,
        'skipped_heading': 0,
        'skipped_overlap': 0,
        'replaced': 0,
        'stems_matched': 0,
        'stems_searched': 0
    }
    
    # Debug log
    debug_log = []
    
    # Process each section
    for i, section_match in enumerate(section_matches):
        section_title = section_match.group(1)
        section_start = section_match.end()
        section_end = len(content) if i == len(section_matches) - 1 else section_matches[i+1].start()
        
        stats['total_sections'] += 1
        
        # Skip "Quick Start / Essentials" section
        if "Quick Start / Essentials" in section_title:
            stats['skipped_quick_start'] += 1
            debug_log.append(f"Skipping section: {section_title}")
            continue
        
        # Clean section title for comparison (remove ** and other markers)
        cleaned_section_title = section_title.lstrip('*').strip()
        
        debug_log.append(f"Processing section: '{section_title}' ({section_end - section_start} chars)")
        section_content = content[section_start:section_end]

        # Track which terms have been replaced in this section
        replaced_terms = set()
        # Track replacement positions in this section to prevent overlaps
        section_replacements = []
        
        # Process each glossary term
        for term_id, term_info in glossary_terms.items():
            stats['total_term_checks'] += 1
            defined_in = term_info['defined_in']
            stems = term_info['stems']
            
            # Skip if term is defined in this section - use EXACT matching
            if defined_in and defined_in == cleaned_section_title:
                stats['skipped_defined_in'] += 1
                debug_log.append(f"  Skipping '{term_id}' - defined in this section")
                continue
            
            # Skip if no stems defined
            if not stems:
                continue
            
            # Skip if this term has already been replaced in this section
            if term_id in replaced_terms:
                continue
            
            # Check each stem
            for stem in stems:
                stats['stems_searched'] += 1
                
                # Case-insensitive word boundary search
                stem_pattern = re.escape(stem)
                
                # Debug - show what we're searching for
                debug_log.append(f"  Searching for stem: '{stem}' with pattern: '{stem_pattern}'")
                
                # Find all matches (case-insensitive)
                matches = []
                for match in re.finditer(stem_pattern, section_content, re.IGNORECASE):
                    abs_start = section_start + match.start()
                    abs_end = section_start + match.end()
                    
                    # Expand the match to include the complete word
                    word_start = match.start()
                    word_end = match.end()
                    
                    # Look backward to find the start of the word
                    while word_start > 0 and re.match(r'[a-zA-Z0-9-]', section_content[word_start-1]):
                        word_start -= 1
                    
                    # Look forward to find the end of the word
                    while word_end < len(section_content) and re.match(r'[a-zA-Z0-9-]', section_content[word_end]):
                        word_end += 1
                    
                    # Get the complete word
                    complete_word = section_content[word_start:word_end]
                    
                    in_heading = is_in_heading(abs_start, all_headings)
                    in_skip_zone = is_position_in_skip_zone(abs_start, skip_positions)
                    
                    matches.append((
                        word_start,  # Use word_start instead of match.start()
                        word_end,    # Use word_end instead of match.end()
                        in_heading, 
                        in_skip_zone, 
                        complete_word  # Store the complete word
                    ))
                                
                if not matches:
                    debug_log.append(f"    No matches found for stem '{stem}'")
                    continue
                else:
                    debug_log.append(f"    Found {len(matches)} matches for stem '{stem}'")
                
                # Debug for all matches
                for idx, (start, end, in_hdg, in_skip, matched_text) in enumerate(matches):
                    debug_log.append(f"    Match {idx+1}: pos {start}-{end}, in_heading={in_hdg}, in_skip_tag={in_skip}")
                    debug_log.append(f"      Text: '{matched_text}'")
                
                # Find first valid match (not in heading, not in skip zone)
                valid_match = None
                for start, end, in_heading, in_skip_zone, matched_text in matches:
                    if not in_heading and not in_skip_zone:
                        valid_match = (start, end, matched_text)
                        break
                
                if valid_match:
                    start, end, matched_text = valid_match
                    abs_start = section_start + start
                    abs_end = section_start + end

                    # Check for overlap with existing replacements in this section
                    overlaps = False
                    for existing_start, existing_end, _ in section_replacements:
                        # Two ranges overlap if one doesn't end before the other starts
                        if not (abs_end <= existing_start or abs_start >= existing_end):
                            overlaps = True
                            debug_log.append(f"  Skipping stem '{stem}' - overlaps with existing replacement at {existing_start}-{existing_end}")
                            break

                    if not overlaps:
                        # Use the complete word in the replacement
                        replacement = f"\\glsdisp{{{term_id}}}{{{matched_text}}}"

                        replacements.append((abs_start, abs_end, replacement))
                        section_replacements.append((abs_start, abs_end, replacement))
                        stats['replaced'] += 1
                        stats['stems_matched'] += 1
                        replaced_terms.add(term_id)

                        debug_log.append(f"  Adding replacement: '{matched_text}' -> {replacement}")

                        # Successfully found and replaced a term in this section,
                        # continue to the next stem
                        break
                    else:
                        stats['skipped_overlap'] += 1
                else:
                    # All matches were in headings or skip zones
                    all_in_headings = all(in_heading for _, _, in_heading, _, _ in matches)
                    all_in_skip_zones = all(in_skip for _, _, _, in_skip, _ in matches)
                    
                    if all_in_headings:
                        stats['skipped_heading'] += 1
                        debug_log.append(f"  Skipping stem '{stem}' - only appears in headings in this section")
                    elif all_in_skip_zones:
                        stats['skipped_in_tag'] += 1
                        debug_log.append(f"  Skipping stem '{stem}' - only appears inside skipped tags in this section")
    
    # Sort replacements by position in reverse order
    replacements.sort(key=lambda x: x[0], reverse=True)
    
    # Apply replacements
    new_content = content
    for start, end, replacement in replacements:
        new_content = new_content[:start] + replacement + new_content[end:]
    
    # Write modified content
    with open('Open MDMA.tex', 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    # Write debug log
    # with open('glossary_debug.log', 'w', encoding='utf-8') as f:
    #     f.write('\n'.join(debug_log))
    
    # Print statistics
    print("\nProcessing Statistics:")
    print(f"Total sections: {stats['total_sections']}")
    print(f"Skipped 'Quick Start': {stats['skipped_quick_start']}")
    print(f"Total term checks: {stats['total_term_checks']}")
    print(f"Terms skipped (defined in section): {stats['skipped_defined_in']}")
    print(f"Terms not found in section: {stats['not_found']}")
    print(f"Terms skipped (in tags): {stats['skipped_in_tag']}")
    print(f"Terms skipped (in heading): {stats['skipped_heading']}")
    print(f"Terms skipped (overlapping): {stats['skipped_overlap']}")
    print(f"stems searched: {stats['stems_searched']}")
    print(f"stems matched: {stats['stems_matched']}")
    print(f"Terms replaced: {stats['replaced']}")
    
    return stats['replaced']

def main():
    glossary_file = 'glossary.tex'
    paper_file = 'paper.tex'
    
    # Check if files exist
    if not os.path.exists(glossary_file):
        print(f"Error: {glossary_file} not found")
        return
    
    if not os.path.exists(paper_file):
        print(f"Error: {paper_file} not found")
        return
    
    # Extract glossary terms
    glossary_terms = extract_glossary_terms(glossary_file)
    print(f"Found {len(glossary_terms)} glossary terms")
    
    # Process the paper
    replaced_count = process_paper(paper_file, glossary_terms)
    print(f"\nProcessing complete. Applied {replaced_count} glossary replacements.")
    print("Modified file saved as Open MDMA.tex")
    print("Debug information written to glossary_debug.log")
    print(f"\nSkipped tag types: {', '.join(SKIP_TAGS)}")

if __name__ == "__main__":
    main()