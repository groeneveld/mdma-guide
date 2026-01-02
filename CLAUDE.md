# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an academic book project titled "Open MDMA: An Evidence-Based Synthesis, Theory, and Manual for MDMA Therapy Based on Predictive Processing, Complex Systems, and the Defense Cascade" by Mark Groeneveld and Thomas Harper. The project produces a comprehensive manual for MDMA-assisted psychotherapy using LaTeX for document preparation.

## Build Commands

### Primary Build Process
```bash
./build.sh
```
This runs the complete LaTeX build pipeline:
1. `python3 gls.py` - Processes glossary terms and replaces first occurrences with `\glsdisp` commands
2. `pdflatex "Open MDMA.tex"` - Initial LaTeX compilation
3. `biber "Open MDMA"` - Bibliography processing
4. `makeglossaries "Open MDMA"` - Glossary generation
5. Multiple `pdflatex` passes for cross-references and final formatting

### Alternative Formats
- **EPUB generation**: `./epub.sh` - Uses tex4ebook to create EPUB3 format
- **Clean build artifacts**: `./clear.sh` - Removes all generated files (.log, .aux, .pdf, etc.)

### Manual Build Steps
If `build.sh` fails, run `clear.sh` then try `build.sh` again.

## File Structure & Workflow

### Core Files
- `paper.tex` - Source LaTeX document that gets processed
- `Open MDMA.tex` - Generated output file from gls.py (gets overwritten on each build)
- `glossary.tex` - Contains all glossary term definitions with stems for automatic replacement
- `references.bib` - Bibliography database
- `cover.pdf` - Book cover included in final PDF

### Python Processing
The `gls.py` script is central to the build process:
- Reads `glossary.tex` to extract term definitions and stems
- Processes `paper.tex` section by section
- Automatically replaces first occurrences of glossary terms with LaTeX `\glsdisp` commands
- Generates `Open MDMA.tex` as the processed output
- Creates `glossary_debug.log` for debugging glossary replacements

### LaTeX Architecture
- Uses `book` document class with APA citation style
- Custom glossaries package configuration for term management
- Biblatex with biber backend for bibliography
- Hyperref for internal/external linking
- Custom environments for tables and formatting

## Common Issues

### Build Dependencies
The build process requires:
- LaTeX distribution with pdflatex, biber, makeglossaries
- Python 3 for gls.py script
- pandoc for EPUB generation (optional)

### Glossary Processing
- Terms are only replaced once per section
- Replacements skip content in headings, citations, labels, and other specified tags
- The "Quick Start / Essentials" section is entirely skipped for glossary processing
- Terms defined in a section are not replaced within that same section