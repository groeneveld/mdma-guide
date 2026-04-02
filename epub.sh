python3 epub/expand_refs.py

pandoc \
    --citeproc \
    --bibliography=references.bib \
    --csl=epub/nature.csl \
    -f latex -t epub3 \
    -o Open\ MDMA.epub \
    -M link-citations=true \
    --lua-filter epub/swap-pdf-images.lua \
    --css=epub/epub-styles.css \
    temp/paper_expanded.tex
