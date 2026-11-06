"""Subset the Libertinus fonts to what a built HTML page actually renders.

    subset-fonts.py html PAGE           print @font-face CSS with inline WOFF2
    subset-fonts.py epub PAGE OUTDIR    write OTFs to OUTDIR, print @font-face CSS

Each text node is assigned to a face (family x weight x style) by the tags
around it, mirroring auxillaryFiles/html.css and epub-styles.css. Each face
is subset to its own characters, and faces with no text are left out, so a
style the book starts using (an italic heading, a code span) brings its face
back on the next build. Only the regular face also gets printable ASCII, as
the catch-all; padding every face with it would triple the rarely used ones.
A mismatch between these rules and the CSS therefore shows up as fallback
glyphs, so keep the tables below in step with the CSS.
"""
import base64, io, os, sys
from html.parser import HTMLParser
from fontTools import subset
from fontTools.ttLib import TTFont

FONTS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fonts")

SANS = {"h1", "h2", "h3", "h4", "h5", "h6"}
SANS_CLASSES = {"theme-toggle", "toc-button"}
MONO = {"code", "pre", "tt", "kbd", "samp"}
BOLD = SANS | {"strong", "b", "th", "dt"}
BOLD_CLASSES = {"toc-drawer-head"}
ITALIC = {"em", "i", "cite", "var", "dfn", "address"}
SKIP = {"head", "script", "style"}
VOID = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link",
        "meta", "source", "track", "wbr"}

# (family, bold, italic) -> font file. Combinations Libertinus doesn't ship
# map to the nearest face; the browser synthesizes the rest, as it would anyway.
FILES = {
    ("Serif", False, False): "LibertinusSerif-Regular",
    ("Serif", False, True): "LibertinusSerif-Italic",
    ("Serif", True, False): "LibertinusSerif-Bold",
    ("Serif", True, True): "LibertinusSerif-BoldItalic",
    ("Sans", False, False): "LibertinusSans-Regular",
    ("Sans", False, True): "LibertinusSans-Italic",
    ("Sans", True, False): "LibertinusSans-Bold",
    ("Sans", True, True): "LibertinusSans-Bold",
}
FACES = {  # font file -> (CSS family, style, weight)
    "LibertinusSerif-Regular": ("Libertinus Serif", "normal", "normal"),
    "LibertinusSerif-Italic": ("Libertinus Serif", "italic", "normal"),
    "LibertinusSerif-Bold": ("Libertinus Serif", "normal", "bold"),
    "LibertinusSerif-BoldItalic": ("Libertinus Serif", "italic", "bold"),
    "LibertinusSans-Regular": ("Libertinus Sans", "normal", "normal"),
    "LibertinusSans-Italic": ("Libertinus Sans", "italic", "normal"),
    "LibertinusSans-Bold": ("Libertinus Sans", "normal", "bold"),
    "LibertinusMono-Regular": ("Libertinus Mono", "normal", "normal"),
}
# OpenType features browsers and EPUB readers apply by default; the rest
# (small caps, old-style figures, stylistic sets...) is never switched on.
FEATURES = ["kern", "liga", "clig", "calt", "rlig", "ccmp", "locl", "mark", "mkmk"]
ASCII = "".join(map(chr, range(32, 127)))


class Faces(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack = []  # (tag, sans, mono, bold, italic, skip) per open element
        self.chars = {}

    def state(self):
        return self.stack[-1][1:] if self.stack else (False, False, False, False, False)

    def handle_starttag(self, tag, attrs):
        if tag in VOID:
            return
        sans, mono, bold, italic, skip = self.state()
        attrs = dict(attrs)
        classes = set((attrs.get("class") or "").split())
        style = (attrs.get("style") or "").replace(" ", "")
        sans = (sans or tag in SANS or bool(classes & SANS_CLASSES)) and tag not in MONO
        mono = mono or tag in MONO
        bold = bold or tag in BOLD or bool(classes & BOLD_CLASSES) or "font-weight:bold" in style
        italic = italic or tag in ITALIC or "font-style:italic" in style
        self.stack.append((tag, sans, mono, bold, italic, skip or tag in SKIP))

    def handle_endtag(self, tag):
        if any(t == tag for t, *_ in self.stack):
            while self.stack.pop()[0] != tag:
                pass

    def handle_data(self, data):
        sans, mono, bold, italic, skip = self.state()
        if skip or not data.strip():
            return
        face = "LibertinusMono-Regular" if mono else FILES[("Sans" if sans else "Serif", bold, italic)]
        self.chars.setdefault(face, set()).update(data)


def subset_font(face, chars, flavor=None):
    font = TTFont(os.path.join(FONTS, face + ".otf"))
    options = subset.Options()
    options.layout_features = FEATURES
    # Hints barely matter on screen, and flattened charstrings compress
    # better than subroutines; together they shave about a quarter off.
    options.hinting = False
    options.desubroutinize = True
    subsetter = subset.Subsetter(options)
    subsetter.populate(text="".join(chars))
    subsetter.subset(font)
    font.flavor = flavor  # the Options.flavor field is only read by the CLI
    out = io.BytesIO()
    font.save(out)
    return out.getvalue()


def font_face(face, src):
    family, style, weight = FACES[face]
    return (f'@font-face {{ font-family: "{family}"; font-style: {style}; '
            f'font-weight: {weight}; src: {src}; }}\n')


def main():
    mode, page = sys.argv[1], sys.argv[2]
    parser = Faces()
    parser.feed(open(page, encoding="utf-8").read())
    faces = parser.chars
    # Body text is the fallback for anything these rules misjudge, and
    # pandoc adds its own text (footnote backlinks, the nav page) in it.
    regular = faces.setdefault("LibertinusSerif-Regular", set())
    for chars in list(faces.values()):
        regular |= chars
    regular |= set(ASCII)
    if mode == "epub":
        regular |= set("↩︎")

    css = ""
    for face in FACES:  # fixed order keeps the output stable between builds
        if face not in faces:
            continue
        chars = faces[face]
        if mode == "html":
            data = base64.b64encode(subset_font(face, chars, "woff2")).decode()
            css += font_face(face, f'url(data:font/woff2;base64,{data}) format("woff2")')
        else:
            # EPUB keeps OTF, which readers support more widely than WOFF2.
            outdir = sys.argv[3]
            os.makedirs(outdir, exist_ok=True)
            with open(os.path.join(outdir, face + ".otf"), "wb") as f:
                f.write(subset_font(face, chars))
            css += font_face(face, f'url("../fonts/{face}.otf")')
    sys.stdout.write(css)


if __name__ == "__main__":
    main()
