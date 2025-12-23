python3 auxillaryFiles/expand_refs.py

pandoc \
    --citeproc \
    --bibliography=references.bib \
    --csl=auxillaryFiles/nature.csl \
    -f latex -t epub3 \
    -o book.epub \
    -M link-citations=true \
    --css=auxillaryFiles/epub-styles.css \
    --lua-filter=auxillaryFiles/swap-pdf-images.lua \
    temp/paper_expanded.tex