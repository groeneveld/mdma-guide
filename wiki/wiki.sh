#!/bin/bash

# Convert LaTeX to MediaWiki format using pandoc
# Usage: ./wiki.sh <input.tex> [output.wiki]

if [ -z "$1" ]; then
  echo "Error: Input file required"
  echo "Usage: ./wiki.sh <input.tex> [output.wiki]"
  exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-${INPUT_FILE%.tex}.wiki}"
TEMP_FILE="${INPUT_FILE%.tex}.temp.tex"

echo "Converting $INPUT_FILE to MediaWiki format..."
echo "Output will be written to $OUTPUT_FILE"

# Pre-process to convert citations to placeholders
echo "Pre-processing citations..."
python3 pre-wiki.py "$INPUT_FILE" "$TEMP_FILE"

if [ $? -ne 0 ]; then
  echo "Pre-processing failed"
  rm -f "$TEMP_FILE"
  exit 1
fi

# Convert to MediaWiki
pandoc \
  -f latex \
  -t mediawiki \
  -o "$OUTPUT_FILE" \
  "$TEMP_FILE"

# Clean up temp file
rm -f "$TEMP_FILE"

if [ $? -eq 0 ]; then
  echo "Conversion successful! Removing span id elements..."
  sed -i '' '/^<span id="[^"]*"><\/span>$/d' "$OUTPUT_FILE"
  echo "Converting citations to MediaWiki refs..."
  python3 to-wiki-refs.py "$OUTPUT_FILE"
  if [ $? -eq 0 ]; then
    echo "Done! Output saved to $OUTPUT_FILE"
  else
    echo "Warning: Citation conversion failed, but MediaWiki file was created"
  fi
else
  echo "Conversion failed. Please check the error messages above."
  exit 1
fi
