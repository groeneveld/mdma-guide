python3 auxillaryFiles/expand_refs.py

pandoc \
    --citeproc \
    --bibliography=references.bib \
    --csl=auxillaryFiles/nature.csl \
    -f latex -t epub3 \
    -o Open\ MDMA.epub \
    -M link-citations=true \
    --lua-filter auxillaryFiles/swap-pdf-images.lua \
    --css=auxillaryFiles/epub-styles.css \
    temp/paper_expanded.tex