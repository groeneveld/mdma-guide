#!/bin/bash

# Run glossary preprocessing
python3 auxillaryFiles/gls.py

# Create temp directory if it doesn't exist
mkdir -p temp

# Run latexmk with configuration from .latexmkrc
latexmk "Open MDMA.tex"

# Move final PDF to root directory
mv temp/"Open MDMA.pdf" .


# epub generation
python3 epub/expand_refs.py

pandoc \
    --citeproc \
    --bibliography=references.bib \
    --csl=auxillaryFiles/nature.csl \
    -f latex -t epub3 \
    -o Open\ MDMA.epub \
    -M link-citations=true \
    --lua-filter epub/swap-pdf-images.lua \
    --css=epub/epub-styles.css \
    temp/paper_expanded.tex
