#!/bin/bash

# Use latexmk to clean LaTeX build artifacts
latexmk -C "Open MDMA.tex" 2>/dev/null || true

# Clean biber cache
rm -rf `biber --cache` 2>/dev/null || true

# Remove temp directory files
rm -rf temp/*

# Remove generated files
rm -f "Open MDMA.PDF"
rm -f "Open MDMA.tex"
rm -f "Open MDMA.pdf"
rm -f paper.pdf
rm -f plain-summary.md
rm -f "Open MDMA.epub"