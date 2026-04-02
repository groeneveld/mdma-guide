python3 audiobook/expand_refs.py paper.tex temp/paper_expanded_audiobook.tex

python3 audiobook/strip.py \
    temp/paper_expanded_audiobook.tex \
    temp/paper_audiobook.tex

pandoc \
    -f latex -t epub3 \
    -o audiobook/Open\ MDMA.epub \
    -M link-citations=false \
    --lua-filter audiobook/swap-pdf-images.lua \
    --css=audiobook/epub-styles.css \
    temp/paper_audiobook.tex
