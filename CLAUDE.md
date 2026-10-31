# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Open MDMA is a book (a practical manual for MDMA therapy) written in Typst. One source produces four outputs: `Open MDMA.pdf`, `index.html`, `Open MDMA.epub`, and `README.md`.

To check that an edit compiles without running the full build:
`typst compile --root . --font-path auxillaryFiles/fonts book.typ <scratch>/book.pdf`

## Build

`./build.sh` builds every output into the repo root. It works in `temp/` and deletes that folder when it finishes. Requirements: `typst`, `pandoc`, and Python with `pikepdf`, `fonttools`, and `brotli`.

- **PDF**: Typst compiles the PDF, then pikepdf repacks it into compressed object streams, which makes the file much smaller.
- **HTML**: Typst's HTML export (`--features html`), with subset WOFF2 Libertinus fonts inlined so `index.html` is self-contained. `auxillaryFiles/html.css` is embedded by `template.typ`, because Typst emits no CSS of its own.
- **EPUB**: `auxillaryFiles/epub-prep.py` fixes Typst's HTML for pandoc. It restores the footnote noteref roles and pulls inline SVGs out into files. pandoc then builds the EPUB with `auxillaryFiles/epub-styles.css` and subset OTF fonts.
- **README.md**: generated, so don't edit it by hand. The script extracts the text between `// BEGIN_ABSTRACT`/`// END_ABSTRACT` and `// BEGIN_PLAIN_SUMMARY`/`// END_PLAIN_SUMMARY` in `book.typ`. It compiles that text with `--input readme=true`, which switches to APA author-year citations and turns on `#mdcite`/`#mdonly`. pandoc then converts it to GFM.

All four outputs are committed build artifacts. Edit `book.typ` and `template.typ`.

## Source layout

- `book.typ`: all of the content. It starts with the `glossary` dictionary, then the front matter (title page, abstract, plain summary). After that come the `#show: mainmatter`, `#show: appendix`, and `#show: backmatter` sections.
- `template.typ`: page layout, citation and cross-reference helpers, glossary machinery, and the PDF and HTML differences. Use `is-html()` inside `context` to branch on the output format.
- `references.bib`: the bibliography (biblatex), exported automatically from Zotero. Don't edit it by hand; reference changes belong in Zotero, and hand edits get overwritten on the next export. Numeric `[n]` citations use `auxillaryFiles/csl/book.csl`. `author.csl` and `title.csl` exist only to render the author and title text for the helpers.
- `auxillaryFiles/fonts/`: Libertinus fonts. Always pass this folder with `--font-path`.
- The PDF's chapter openings carry a sumi-e plum spray from `@local/florilegium:0.1.0` (`headpiece`), which is a symlink in `~/Library/Application Support/typst/packages/local/florilegium/0.1.0` to `~/florilegiumTypst`; the build needs it there.
- Typst packages: `@preview/lilaq` (plots) and `@preview/alchemist` (the chemical structure). cetz-based drawings need `svg-in-html` to appear in HTML output.

## Authoring conventions (defined in template.typ)

- Citations: plain `@key` gives `[n]`. `#textcite(<key>)` gives "Author et al. [n]". `#prosecite(<key>)` gives "Title by Full Authors [n]". `#citetitle` and `#citefullauthor` are also available.
- README-only text: `#mdcite(<key>, ...)` adds a citation and `#mdonly[...]` adds text, and both appear only in the README build. Use `#mdcite` in the summary sections when the book text doesn't cite there but the README should.
- Cross-references: `@label` prints "Section 4.3" or "Chapter 4", or just the title for an unnumbered heading. `#nameref(<label>)` prints the linked title. `#combinedref(<label>)` prints "4.3 (Title)". Labels can sit on headings or on invisible anchors in running text (`#metadata("anchor") <label>`), and an anchor resolves to the heading that encloses it.
- Headings: only levels 1–2 are numbered and appear in the printed contents. Write subsections as plain `===`/`====`. They are unnumbered automatically but still get PDF bookmarks and EPUB/HTML nav entries. `#local-contents(<start>, <end>)` lists the level-3 headings between two labels (used at the top of Troubleshooting).
- Glossary: entries are in the `glossary` dict at the top of `book.typ` (`name`, `stems`, `defined-in`, `description`). No manual markup is needed. Within each level-1 or level-2 section, the first case-insensitive match of a term's stems is linked automatically. The link is skipped in headings, citations, the outline, the bibliography, the term's `defined-in` section, and unnumbered front matter. To add a term, add an entry here.
- Use `\u{202F}` (narrow no-break space) between numbers and units, and `~` for non-breaking spaces before citations.

## auxillaryFiles scripts

- `fix_bib.py`: checks and proofreads `references.bib`.
- `fetch_articles.py`: downloads the sources.

These scripts work only on `references.bib`. `toc.py` queries the headings of `book.typ` with `typst eval` (including ones with `outlined: false`) and writes them to `auxillaryFiles/tableofcontents.md`.
