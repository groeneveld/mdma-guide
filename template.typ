// Layout, helpers and glossary machinery for Open MDMA.
// The content lives in book.typ.

// LaTeX `rgb:red,0.5;green,0;blue,0.13` normalises by the weight sum (0.63).
#let link-color = rgb(79.366%, 0%, 20.636%)
#let sans = "Libertinus Sans"

// `typst compile --input readme=true` builds the README summary instead:
// author-year citations and the markdown-only text become visible.
#let readme = sys.inputs.at("readme", default: "false") == "true"

// Shorthand for "is this the HTML export?". Only valid inside `context`.
#let is-html() = target() == "html"

// --- Citations ---------------------------------------------------------------
// Numeric [n] citations come from auxillaryFiles/csl/book.csl via the bibliography. The
// helper styles render the prose parts:
//   auxillaryFiles/csl/author.csl: "Kozlowska et al."
//   auxillaryFiles/csl/title.csl:  the work's title, or (author form) its authors' full names.

// Authors and titles read as plain text; only the [n] is a link.
#let unlinked(body) = {
  show link: it => it.body
  show cite: set text(fill: black)
  body
}

#let textcite(key, supplement: none) = if readme {
  cite(key, form: "prose", supplement: supplement)
} else [#unlinked(cite(key, style: "auxillaryFiles/csl/author.csl"))~#cite(key, supplement: supplement)]

#let citetitle(key) = cite(key, style: "auxillaryFiles/csl/title.csl")
#let citefullauthor(key) = cite(key, style: "auxillaryFiles/csl/title.csl", form: "author")
#let prosecite(key) = [#unlinked[#citetitle(key) by #citefullauthor(key)]~#cite(key)]

// Citations and text that only appear in the README summary.
#let mdcite(..keys) = if readme { keys.pos().map(cite).join() }
#let mdonly(body) = if readme { body }

// --- Cross-references --------------------------------------------------------

// Labels can sit on headings or on invisible anchors in running text
// (`#metadata("anchor") <label>`). For an anchor, the enclosing heading counts.
#let heading-of(target) = {
  let el = query(target).first()
  if el.func() == heading { return el }
  query(selector(heading).before(el.location())).last()
}

// The heading's number, or none if it is unnumbered.
#let heading-number(h) = if h.numbering != none {
  numbering(h.numbering, ..counter(heading).at(h.location()))
}

// Title of the labelled heading, linked.
#let nameref(target) = context link(target, heading-of(target).body)

// "3.2 (Title)", like LaTeX's \ref plus \nameref.
#let combinedref(target) = context {
  let h = heading-of(target)
  let num = heading-number(h)
  link(target, if num == none { h.body } else [#num (#h.body)])
}

// --- Misc helpers ------------------------------------------------------------

// Rough running total of reconsolidation hours: 730 h/year since October 2023,
// rounded to the hundred.
#let reconsolidation-hours = {
  let today = datetime.today()
  let months = (today.year() - 2023) * 12 + (today.month() - 10)
  str(calc.round(730 * months / 12 / 100) * 100)
}

// --- Glossary ----------------------------------------------------------------
// The first mention of each term in every chapter/section is linked to its
// glossary entry, matched by the term's stems (case-insensitive, expanded to
// the whole word). Skipped: headings, citations, the term's own defining
// section, the contents, the bibliography and the glossary itself.
//
// Places that must not get links (headings, citations) set `hyphenate: false`
// on their text; the link rule checks for that flag.

#let gls-region-label(id) = label("gls-hit:" + id)
#let gls-entry-label(id) = label("glossary:" + id)

#let gls-hit(id, term, it) = context {
  if text.hyphenate == false { return it }
  let sections = query(
    heading.where(level: 1).or(heading.where(level: 2)).before(here()),
  )
  if sections.len() == 0 { return it }
  let section = sections.last()
  // Front matter (Abstract, Disclaimer, changelog) stays unlinked.
  if not query(heading.where(level: 1).before(here())).last().outlined { return it }
  if term.defined-in != none and section.at("label", default: none) == term.defined-in {
    return it
  }
  let earlier = query(
    selector(gls-region-label(id))
      .after(section.location())
      .before(here(), inclusive: false),
  )
  // Every mention is recorded; the value says whether it got the link.
  let first = earlier.len() == 0
  [#metadata(first)#gls-region-label(id)]
  if first { link(gls-entry-label(id), it) } else { it }
}

#let glossary-links(terms, body) = {
  show heading: set text(hyphenate: false)
  show cite: set text(hyphenate: false)
  show outline: set text(hyphenate: false)
  show bibliography: set text(hyphenate: false)
  for (id, term) in terms {
    let pattern = "(?i)[\\w-]*(?:" + term.stems.join("|") + ")[\\w-]*"
    body = {
      show regex(pattern): it => gls-hit(id, term, it)
      body
    }
  }
  body
}

#let print-glossary(terms) = {
  [#heading(level: 1, numbering: none)[Glossary] <sec:glossary>]
  for (id, term) in terms.pairs().sorted(key: ((_, t)) => lower(t.name)) {
    [#block(below: 1.2em)[
      #set par(first-line-indent: 0pt)
      #set text(hyphenate: false)
      #strong(term.name) #sym.space.quad #term.description
    ]#gls-entry-label(id)]
  }
}

// --- Figures -----------------------------------------------------------------

// cetz drawings come out empty in HTML export (their canvas uses align(),
// which HTML drops together with its contents), so render them as inline SVG.
#let svg-in-html(body) = context if is-html() { html.frame(body) } else { body }

// --- Document structure --------------------------------------------------------

// Figure numbers prefixed with the chapter number in the given style (4.1, A.1).
#let chapter-figure-numbering(style) = n => numbering(style, counter(heading).get().first(), n)

// Linked list of the subsections between two labels, for long sections that
// readers look things up in.
#let local-contents(start, end) = {
  let body = outline(
    title: none,
    depth: 3,
    indent: 0pt,
    target: selector(heading.where(level: 3)).after(start).before(end),
  )
  context if is-html() { html.elem("div", attrs: (class: "local-toc"), body) } else { body }
}

// Bold label introducing a list or short passage; not a heading. As a block it
// gets no first-line indent, and sticky keeps it on the page with what follows.
#let lead(body) = block(above: 1.2em, below: 0.65em, sticky: true, strong(body))

// A page break in the PDF; nothing in HTML.
#let page-break() = context if not is-html() { pagebreak(weak: true) }

// Start of the main text: arabic page numbers, numbered chapters.
#let mainmatter(body) = {
  set heading(numbering: "1.1")
  context if is-html() { body } else {
    pagebreak(weak: true)
    counter(page).update(1)
    set page(numbering: "1")
    body
  }
}

// Appendices: chapters lettered A, B, …, referenced as "Appendix A".
#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  set figure(numbering: chapter-figure-numbering("A.1"))
  show heading.where(level: 1): set heading(supplement: [Appendix])
  // HTML/EPUB headings show only the number ("A Title"); spell out "Appendix A:".
  // This replaces the book's level-1 rule, so the figure counters reset here too.
  show heading.where(level: 1): it => context if is-html() and it.numbering != none {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    html.elem("h2")[#it.supplement #counter(heading).display(): #it.body]
  } else { it }
  body
}

// Bibliography and other end matter: unnumbered chapters.
#let backmatter(body) = {
  set heading(numbering: none)
  body
}

#let title-page(title: none, subtitle: none, author: none, date: none, body) = {
  context if is-html() {
    html.elem("h1", attrs: (class: "title"), title + [: ] + subtitle)
    html.elem("p", attrs: (class: "author"), author)
    html.elem("p", attrs: (class: "date"), date)
    body
  } else {
    set page(numbering: none)
    set par(first-line-indent: 0pt, justify: false)
    align(center, {
      v(1fr)
      text(font: sans, size: 22pt, weight: "bold", title)
      v(0.6em)
      text(font: sans, size: 13pt, subtitle)
      v(2em)
      text(size: 13pt, author)
      v(1.2em)
      block(width: 85%, text(size: 10pt, date))
      v(2fr)
    })
    pagebreak()
    align(center + horizon, block(width: 100%, {
      set par(justify: false, first-line-indent: 0pt, spacing: 1.4em)
      set align(center)
      body
    }))
  }
}

// Unnumbered front-matter section heading that stays out of the contents.
#let front-section(title) = heading(level: 1, numbering: none, outlined: false, title)

#let book(glossary: (:), body) = {
  set document(title: "Open MDMA", author: "Mark Groeneveld")
  set text(font: "Libertinus Serif", size: 11pt, lang: "en", region: "US")
  set par(justify: true, first-line-indent: 1.5em, spacing: 0.65em)
  set list(indent: 0.5em)
  set enum(indent: 0.5em)
  show link: set text(fill: link-color)
  // Bare URL links (#link("https://...")) display without the scheme or
  // "www."; the link target keeps them.
  show link: it => {
    if type(it.dest) != str or it.body != text(it.dest) { return it }
    link(it.dest, it.dest.replace(regex("^(https?://)?(www\.)?"), ""))
  }
  show ref: set text(fill: link-color)
  show cite: set text(fill: link-color)
  show heading: set text(font: sans)
  show heading: set par(justify: false)
  set heading(supplement: [Section])
  // Only chapters and sections are numbered (1, 1.1). Subsections stay out of
  // the printed contents (outline depth 2) but keep their PDF bookmarks.
  show heading.where(level: 3): set heading(numbering: none)
  show heading.where(level: 4): set heading(numbering: none)
  show heading.where(level: 1): set heading(supplement: [Chapter])

  // References to anchors print the enclosing numbered heading ("Section
  // 4.3"), like cleveref; references to unnumbered headings print the title.
  show ref: it => {
    let el = it.element
    if el == none { return it }
    if el.func() == metadata {
      let h = query(selector(heading).before(el.location()))
        .filter(h => h.numbering != none)
        .last()
      let supplement = if h.level == 1 { h.supplement } else [Section]
      link(it.target)[#supplement~#heading-number(h)]
    } else if el.func() == heading and el.numbering == none {
      link(it.target, el.body)
    } else { it }
  }

  // Figures and tables are numbered per chapter (Figure 4.1) and may span pages.
  set figure(numbering: chapter-figure-numbering("1.1"))
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    it
  }
  show figure: set block(breakable: true, above: 1.4em, below: 1.4em)
  // A caption above a table stays on the same page as the table's start.
  show figure.caption.where(position: top): set block(sticky: true)
  show table: set par(justify: false)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: set text(size: 10pt)

  set outline(depth: 2)
  set bibliography(title: none, style: if readme { "apa" } else { "auxillaryFiles/csl/book.csl" })
  // Bibliography URLs and DOIs display without the scheme or "www."; the link
  // target keeps them.
  show bibliography: it => {
    show regex("https?://|www\."): []
    it
  }

  context if is-html() {
    // Typst emits no CSS of its own.
    html.elem("style", read("auxillaryFiles/html.css"))
    show: glossary-links.with(glossary)
    body
  } else {
    set page(
      width: 6in,
      height: 9in,
      margin: (x: 0.8in, top: 0.9in, bottom: 1in),
      numbering: "i",
    )

    // Front-matter sections: centred title, no page break.
    show heading.where(level: 1, outlined: false): it => {
      v(1.5em)
      align(center, text(size: 13pt, it.body))
      v(0.6em)
    }

    // Chapters open on a new page.
    show heading.where(level: 1, outlined: true): it => {
      pagebreak(weak: true)
      v(2.5em)
      set par(first-line-indent: 0pt)
      if it.numbering != none {
        text(size: 14pt, weight: "regular")[#it.supplement #counter(heading).display()]
        v(0.4em)
      }
      text(size: 20pt, it.body)
      v(1.4em)
    }

    show: glossary-links.with(glossary)
    body
  }
}
