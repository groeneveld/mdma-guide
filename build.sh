#!/bin/bash

# Run glossary preprocessing
python3 auxillaryFiles/gls.py

# Create temp directory if it doesn't exist
mkdir -p temp

# Run latexmk with configuration from .latexmkrc
latexmk "Open MDMA.tex"

# Move final PDF to root directory
mv temp/"Open MDMA.pdf" .