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
# so index.html is self-contained. subset-fonts.py embeds only the faces the
# page uses, each subset to its own characters and compressed as WOFF2.
# Needs fonttools and brotli (pip install fonttools brotli).
"${TYPST[@]}" --features html --format html book.typ temp/book.html
python3 auxillaryFiles/subset-fonts.py html temp/book.html > temp/fonts.css
python3 - <<'PY'
page = open("temp/book.html").read()
css = open("temp/fonts.css").read()
# GoatCounter page-view analytics (web edition only).
goatcounter = ('<script data-goatcounter="https://groeneveld.goatcounter.com/count" '
               'async src="//gc.zgo.at/count.js"></script>')
# color-scheme lets the browser paint the right background before the CSS
# loads (no white flash in dark mode). text-scale makes 1rem follow the OS
# text-size setting (Chromium 146+; ignored elsewhere).
metas = ('<meta name="color-scheme" content="light dark">'
         '<meta name="text-scale" content="scale">')
page = page.replace('<meta charset="utf-8">', '<meta charset="utf-8">' + metas, 1)
page = page.replace("</head>", f"<style>{css}</style>{goatcounter}</head>", 1)
open("index.html", "w").write(page)
PY

# EPUB: Typst HTML -> pandoc. subset-fonts.py writes the faces the book uses,
# each subset to its own characters (the full Libertinus files would otherwise
# make up most of the EPUB), plus the @font-face rules that load them.
python3 auxillaryFiles/epub-prep.py temp/book.html temp/epub.html
python3 auxillaryFiles/subset-fonts.py epub temp/epub.html temp/fonts > temp/epub-fonts.css
(cd temp && pandoc epub.html -f html -t epub3 \
    --shift-heading-level-by=-1 \
    --metadata title="Open MDMA" --metadata author="Mark Groeneveld" \
    --css=epub-fonts.css \
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

# Reddit version of the Long Summary. Reddit has no footnote syntax: "[^n]"
# becomes the superscript "^(n)" and the definitions become a Notes list.
python3 - <<'PY'
import re
md = open("README.md").read()
md = md[md.index("# Long Summary\n") + len("# Long Summary\n"):]
notes = re.findall(r"^\[\^(\d+)\]: (.*)$", md, flags=re.M)
md = re.sub(r"^\[\^\d+\]: .*\n?", "", md, flags=re.M)
md = re.sub(r"\[\^(\d+)\]", r"^(\1)", md).strip()
if notes:
    md += "\n\n# Notes\n\n" + "\n".join(f"{n}. {t}" for n, t in notes)
from datetime import date
d = date.today()
md += f"\n\nUpdated {d:%B} {d.day}, {d.year}"
open("auxillaryFiles/reddit-long-summary.md", "w").write(md + "\n")
PY

# Intermediate files are only needed during the build.
rm -rf temp


# Table of contents
python auxillaryFiles/toc.py