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
