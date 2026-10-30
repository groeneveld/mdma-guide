#!/bin/bash
# Build the Typst edition: Open MDMA.pdf, index.html, Open MDMA.epub and
# README.md, all written to this folder.
set -euo pipefail
cd "$(dirname "$0")"

# Use the uv-managed environment (pikepdf, fonttools, brotli) over the system
# Python 3.9. The shell only reaches it through an alias, which scripts ignore.
if [ -x "$HOME/.venvs/main/bin/python3" ]; then PATH="$HOME/.venvs/main/bin:$PATH"; fi

FONTS=auxillaryFiles/fonts  # Libertinus, SIL Open Font License (auxillaryFiles/fonts/OFL.txt)
TYPST=(typst compile --root . --font-path "$FONTS")
mkdir -p temp

# Keep the LICENSE copyright year current.
sed -i '' -E "s/^(Copyright \(c\) )[0-9]{4}/\1$(date +%Y)/" LICENSE

# PDF. Typst writes the accessibility tag tree as thousands of uncompressed
# objects; repacking them into compressed object streams more than halves the
# file. Needs pikepdf (pip install pikepdf).
"${TYPST[@]}" book.typ temp/book.pdf
python3 - <<'PY'
import pikepdf
with pikepdf.open("temp/book.pdf") as pdf:
    pdf.save("Open MDMA.pdf",
             object_stream_mode=pikepdf.ObjectStreamMode.generate,
             compress_streams=True, recompress_flate=True)
PY

# HTML: Typst's export, plus the Libertinus fonts inlined as @font-face rules
# so index.html is self-contained. The fonts are subset to the characters the
# page uses (plus printable ASCII) and compressed as WOFF2 to keep it small.
# Needs fonttools and brotli (pip install fonttools brotli).
"${TYPST[@]}" --features html --format html book.typ temp/book.html
python3 - "$FONTS" <<'PY'
import base64, html, io, string, sys
from fontTools import subset
from fontTools.ttLib import TTFont
fonts = sys.argv[1]
page = open("temp/book.html").read()
chars = set(html.unescape(page)) | set(string.printable)

def woff2(path):
    font = TTFont(path)
    options = subset.Options()
    options.flavor = "woff2"
    subsetter = subset.Subsetter(options)
    subsetter.populate(text="".join(chars))
    subsetter.subset(font)
    out = io.BytesIO()
    font.save(out)
    return base64.b64encode(out.getvalue()).decode()

faces = [
    ("Libertinus Serif", "normal", "normal", "LibertinusSerif-Regular"),
    ("Libertinus Serif", "italic", "normal", "LibertinusSerif-Italic"),
    ("Libertinus Serif", "normal", "bold", "LibertinusSerif-Bold"),
    ("Libertinus Serif", "italic", "bold", "LibertinusSerif-BoldItalic"),
    ("Libertinus Sans", "normal", "normal", "LibertinusSans-Regular"),
    ("Libertinus Sans", "italic", "normal", "LibertinusSans-Italic"),
    ("Libertinus Sans", "normal", "bold", "LibertinusSans-Bold"),
    ("Libertinus Mono", "normal", "normal", "LibertinusMono-Regular"),
]
css = "".join(
    f'@font-face {{ font-family: "{family}"; font-style: {style}; font-weight: {weight}; '
    f'src: url(data:font/woff2;base64,{woff2(f"{fonts}/{file}.otf")}) format("woff2"); }}\n'
    for family, style, weight, file in faces
)
# GoatCounter page-view analytics (web edition only).
goatcounter = ('<script data-goatcounter="https://groeneveld.goatcounter.com/count" '
               'async src="//gc.zgo.at/count.js"></script>')
page = page.replace("</head>", f"<style>{css}</style>{goatcounter}</head>", 1)
open("index.html", "w").write(page)
PY

# EPUB: Typst HTML -> pandoc. The embedded fonts are subset to the characters
# the book uses (plus printable ASCII and pandoc's footnote backlink arrow);
# the full Libertinus files would otherwise make up most of the EPUB. They
# stay OTF, which EPUB readers support more widely than WOFF2.
python3 auxillaryFiles/epub-prep.py temp/book.html temp/epub.html
python3 - "$FONTS" <<'PY'
import glob, html, os, string, sys
from fontTools import subset
from fontTools.ttLib import TTFont
chars = set(html.unescape(open("temp/epub.html").read())) | set(string.printable) | {"↩", "︎"}
os.makedirs("temp/fonts", exist_ok=True)
for path in glob.glob(f"{sys.argv[1]}/*.otf"):
    font = TTFont(path)
    subsetter = subset.Subsetter(subset.Options())
    subsetter.populate(text="".join(chars))
    subsetter.subset(font)
    font.save(f"temp/fonts/{os.path.basename(path)}")
PY
(cd temp && pandoc epub.html -f html -t epub3 \
    --shift-heading-level-by=-1 \
    --metadata title="Open MDMA" --metadata author="Mark Groeneveld" \
    --css=../auxillaryFiles/epub-styles.css \
    --epub-embed-font="fonts/*.otf" \
    -o "../Open MDMA.epub")

# README.md: the abstract and plain-language summary, with author-year
# citations and the markdown-only text (#mdcite, #mdonly) switched on.
python3 - <<'PY'
src = open("book.typ").read()
def between(a, b):
    return src[src.index(a) + len(a):src.index(b)].strip()
open("temp/readme.typ", "w").write(f'''#import "../auxillaryFiles/template.typ": *
#show: book

= Short Summary

{between("// BEGIN_ABSTRACT", "// END_ABSTRACT")}

= Long Summary

{between("// BEGIN_PLAIN_SUMMARY", "// END_PLAIN_SUMMARY")}

= References
#bibliography("/references.bib")
''')
PY
"${TYPST[@]}" --input readme=true --features html --format html temp/readme.typ temp/readme.html
python3 auxillaryFiles/epub-prep.py temp/readme.html temp/readme-notes.html
pandoc temp/readme-notes.html -f html -t gfm-raw_html --wrap=none \
    --shift-heading-level-by=-1 -o README.md
# Typst's APA style leaves an empty month/day slot: "(2015,)" -> "(2015)"
sed -i '' -E 's/\(([0-9]{4}[a-z]?),\)/(\1)/g' README.md
# Citation links point at anchors GitHub strips; keep just the text.
sed -i '' -E 's/\[([^]]*)\]\(#loc-[0-9]+\)/\1/g' README.md

# Intermediate files are only needed during the build.
rm -rf temp


# Table of contents
python auxillaryFiles/toc.py