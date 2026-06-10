#!/bin/bash

# Run glossary preprocessing (skip if inputs are older than output)
if [ paper.tex -nt "Open MDMA.tex" ] \
   || [ glossary.tex -nt "Open MDMA.tex" ] \
   || [ auxillaryFiles/gls.py -nt "Open MDMA.tex" ]; then
    python3 auxillaryFiles/gls.py
fi

# Create temp directory if it doesn't exist
mkdir -p temp

# Run latexmk with configuration from .latexmkrc
latexmk "Open MDMA.tex"

# Move final PDF to root directory
mv temp/"Open MDMA.pdf" .

# EPUB
python3 epub/expand_refs.py

LIBERTINUS_DIR=/usr/local/texlive/2026/texmf-dist/fonts/opentype/public/libertinus-fonts

pandoc \
    --citeproc \
    --bibliography=references.bib \
    --csl=auxillaryFiles/nature.csl \
    -f latex -t epub3 \
    -o Open\ MDMA.epub \
    -M link-citations=true \
    --lua-filter epub/swap-pdf-images.lua \
    --lua-filter epub/unwrap-adjustwidth.lua \
    --lua-filter epub/strip-longtable-continuation.lua \
    --css=epub/epub-styles.css \
    --epub-embed-font="$LIBERTINUS_DIR/LibertinusSerif-Regular.otf" \
    --epub-embed-font="$LIBERTINUS_DIR/LibertinusSerif-Italic.otf" \
    --epub-embed-font="$LIBERTINUS_DIR/LibertinusSerif-Bold.otf" \
    --epub-embed-font="$LIBERTINUS_DIR/LibertinusSerif-BoldItalic.otf" \
    --epub-embed-font="$LIBERTINUS_DIR/LibertinusSans-Regular.otf" \
    --epub-embed-font="$LIBERTINUS_DIR/LibertinusSans-Italic.otf" \
    --epub-embed-font="$LIBERTINUS_DIR/LibertinusSans-Bold.otf" \
    --epub-embed-font="$LIBERTINUS_DIR/LibertinusMono-Regular.otf" \
    temp/paper_expanded.tex

# HTML (self-contained single page for GitHub Pages)
# Prepend @font-face rules (machine-specific font paths) to the visual rules,
# then let pandoc --embed-resources inline the fonts, CSS and SVG images so the
# resulting index.html is fully portable.
cat > temp/html.css <<CSS
@font-face { font-family: "Libertinus Serif"; font-style: normal; font-weight: normal; src: url("$LIBERTINUS_DIR/LibertinusSerif-Regular.otf"); }
@font-face { font-family: "Libertinus Serif"; font-style: italic; font-weight: normal; src: url("$LIBERTINUS_DIR/LibertinusSerif-Italic.otf"); }
@font-face { font-family: "Libertinus Serif"; font-style: normal; font-weight: bold; src: url("$LIBERTINUS_DIR/LibertinusSerif-Bold.otf"); }
@font-face { font-family: "Libertinus Serif"; font-style: italic; font-weight: bold; src: url("$LIBERTINUS_DIR/LibertinusSerif-BoldItalic.otf"); }
@font-face { font-family: "Libertinus Sans"; font-style: normal; font-weight: normal; src: url("$LIBERTINUS_DIR/LibertinusSans-Regular.otf"); }
@font-face { font-family: "Libertinus Sans"; font-style: italic; font-weight: normal; src: url("$LIBERTINUS_DIR/LibertinusSans-Italic.otf"); }
@font-face { font-family: "Libertinus Sans"; font-style: normal; font-weight: bold; src: url("$LIBERTINUS_DIR/LibertinusSans-Bold.otf"); }
@font-face { font-family: "Libertinus Mono"; font-style: normal; font-weight: normal; src: url("$LIBERTINUS_DIR/LibertinusMono-Regular.otf"); }
CSS
cat html/html-styles.css >> temp/html.css

pandoc \
    --citeproc \
    --bibliography=references.bib \
    --csl=auxillaryFiles/nature.csl \
    -f latex -t html5 \
    --standalone \
    --embed-resources \
    --toc --toc-depth=2 \
    --mathjax \
    -M link-citations=true \
    --lua-filter epub/swap-pdf-images.lua \
    --lua-filter epub/unwrap-adjustwidth.lua \
    --lua-filter epub/strip-longtable-continuation.lua \
    --css=temp/html.css \
    --resource-path=. \
    -o index.html \
    temp/paper_expanded.tex

# MD
sed -n '/^% BEGIN_PLAIN_SUMMARY/,/^% END_PLAIN_SUMMARY/p' paper.tex \
  | sed '1d;$d' \
  | sed 's/\\mdcite{/\\citep{/g' \
  | perl -0pe 's/\\mdonly\{((?:[^{}]++|\{(?:[^{}]++|\{[^{}]*\})*\})*)\}/$1/g' \
  | pandoc \
      --citeproc \
      --bibliography=references.bib \
      --csl=auxillaryFiles/apa.csl \
      -f latex -t commonmark \
      -o README.md

sed -i '' -E '/^<\/div>$/d' README.md
sed -i '' -E '/^<div[^>]+>$/d' README.md
sed -i '' -E '/^<div[^>]*$/,/^[^<]*>$/d' README.md

# Prepend abstract (as Short Summary) above the existing summary (as Long Summary)
sed -n '/^\\frontsection{Abstract}/,/^\\clearpage/p' paper.tex \
  | sed '1d;$d' \
  | sed 's/\\mdcite{/\\citep{/g' \
  | perl -0pe 's/\\mdonly\{((?:[^{}]++|\{(?:[^{}]++|\{[^{}]*\})*\})*)\}/$1/g' \
  | pandoc \
      --citeproc \
      --bibliography=references.bib \
      --csl=auxillaryFiles/apa.csl \
      -f latex -t commonmark \
      -o temp/abstract.md

{
  printf '# Short Summary\n\n'
  cat temp/abstract.md
  printf '\n# Long Summary\n\n'
  cat README.md
} > temp/README.md.new
mv temp/README.md.new README.md