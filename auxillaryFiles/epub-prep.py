"""Prepare Typst HTML output for pandoc's EPUB writer.
Usage: epub-prep.py in.html out.html

- Mark Typst footnote references with role="doc-noteref" so pandoc's HTML
  reader turns them back into real notes instead of dropping the endnotes.
- Move inline SVGs into standalone files referenced by <img>; pandoc's HTML
  reader mangles inline SVG (lowercases viewBox, drops empty attribute
  values), which yields invalid XML in the EPUB."""
import os, re, sys
src, dst = sys.argv[1], sys.argv[2]
s = open(src).read()

notes = s[s.find('<section role="doc-endnotes">'):]
ids = set(re.findall(r'<li id="([^"]+)"', notes))
s = re.sub(r'<a href="#([^"]+)">',
           lambda m: f'<a href="#{m[1]}" role="doc-noteref">' if m[1] in ids else m[0], s)
# Unwrap the <sup> around footnote markers; pandoc adds its own styling.
s = re.sub(r'<sup[^>]*role="doc-noteref"[^>]*>(<a [^>]*>[^<]*</a>)</sup>', r'\1', s)
# Drop Typst's own backlink numbers; pandoc generates its own.
s = re.sub(r'<sup role="doc-backlink"><a href="#[^"]+">\d+</a></sup>', '', s)

svg_dir = os.path.join(os.path.dirname(dst) or '.', 'svg')
os.makedirs(svg_dir, exist_ok=True)
count = 0
def extract(m):
    global count
    count += 1
    name = f'svg/figure-{count}.svg'
    # Paint a white background so black text stays legible in dark mode.
    svg = re.sub(r'(<svg\b[^>]*>)', r'\1<rect width="100%" height="100%" fill="white"/>',
                 m[0], count=1)
    open(os.path.join(os.path.dirname(dst) or '.', name), 'w').write(
        '<?xml version="1.0" encoding="UTF-8"?>\n' + svg)
    return f'<img src="{name}" alt="" />'
s = re.sub(r'<svg\b.*?</svg>', extract, s, flags=re.S)

open(dst, 'w').write(s)
