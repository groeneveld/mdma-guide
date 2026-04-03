# Style Guide for paper.tex

Derived from patterns in the edited sections. Use this as a reference for consistency.

## Voice and Person

- **"We"** for the authors' collective voice: "We think," "We recommend," "We speculate." Never "I" except inside personal accounts (quotation blocks attributed to M.G. or others).
- **"You"** for the reader: "you might," "you can," "your session."
- Refer to the authors by initials in the third person when needed: "M.G.'s experience," "T.H.'s professional experience."

## Tone

- Academic but accessible. Explain technical terms on first use or point to the glossary.
- Direct and practical when giving advice. Don't soften recommendations into mush.
- Honest about uncertainty — never overstate the evidence. This is a core value of the book.
- Occasional informality is fine when it serves clarity (e.g., "therapy hangover," "losing the magic").

## Epistemic Calibration

The book distinguishes carefully between levels of confidence. Use the right hedge for the right situation:

| Confidence | Phrasing |
|---|---|
| Established evidence | "X causes Y" (with citation) |
| Strong but incomplete evidence | "We think," "We recommend" |
| Reasonable inference | "We suspect," "This suggests" |
| Uncertain inference | "We speculate," "It's conceivable," "It's plausible" |
| Unknown | "We don't know," "It's unclear," "It's not clear," "We are not aware of" |
| Anecdotal | "Anecdotal reports indicate/suggest," "Personal experience and anecdotal reports suggest" |

- Always flag when evidence is low-quality, limited, or absent.
- When citing animal studies, note the gap to humans.
- When citing observational studies, note confounders.
- "Unfortunately" is used naturally when noting gaps in evidence or bad news.
- "To our knowledge" when you might be missing something.

### Avoiding Hedge Stacking

**Pick one hedge per sentence and commit to it.** When multiple hedges pile up — "it's conceivable that X may possibly cause Y in certain cases" — the sentence loses all meaning. The reader can't tell if you think this is plausible or nearly impossible.

Bad: "We speculate that this might conceivably show up in therapy as..."
Good: "We speculate that this shows up in therapy as..."

Bad: "It's conceivable that certain complex stuck schema networks may reconstitute certain components over time."
Good: "Some complex networks of stuck schemas may reconstitute components over time."

The hedge table above has one slot per confidence level. Use the one that best matches your actual confidence and don't dilute it with additional softeners.

## Preferred Terminology

Use these terms consistently:

| Use | Don't use |
|---|---|
| stuck schemas | maladaptive schemas |
| reconsolidation / reconsolidate | (no alternative — this is the precise term) |
| opioid dampening | dissociation (when referring to opioid-mediated states specifically) |
| flight-or-fight | fight-or-flight (flight first, per Kozlowska) |
| defense cascade | (no alternative) |
| therapy hangover | (no formal alternative — this is the informal but consistent term) |
| afterglow | (no alternative) |
| skilled, ethical, and well-matched | (this exact phrase, in this order, for describing ideal professionals) |
| mental illness | mental disorder, mental health condition (though "mental health" is fine in compound phrases like "mental health professional") |
| stuck schemas | parts, protectors (those are other frameworks' terms; use "schema" in this book) |
| guide or therapist | facilitator, shaman, healer |
| session | trip, journey (in therapeutic context) |
| medicine | drug (when referring to MDMA in therapeutic context; "drug" is fine in pharmacology sections and for other substances) |

"Dissociation" is acceptable when referring to the broad clinical phenomenon, but prefer "opioid dampening" when the mechanism is specifically opioid-mediated (immobility, freeze, derealization). The text explains this distinction in the Defense Cascade section.

## Sentence and Paragraph Style

- **One main idea per sentence.** If a sentence has a claim, a citation, a caveat, a parenthetical, AND a footnote, it's doing too much. Split it. The reader should be able to identify what a sentence is saying on first read.
- **One main topic per paragraph.** Start a new paragraph when you shift to a new point, even within a list item or subsection. Dense blocks of text are hard on readers — especially ones dealing with mental illness.
- **Topic sentences.** Open each paragraph by stating what it's about. Details and evidence come after. The reader should know where you're going before you take them there.
- **Transitions.** When starting a new section or shifting topic, a one-sentence bridge helps the reader orient. Why is this section here? How does it connect to what came before?
- Use semicolons to join related independent clauses.
- Short parenthetical clarifications are fine: "(roughly the amount used in \textcite{...})". Long parentheticals should be their own sentence.
- Avoid rhetorical questions. State things directly.

### Footnotes

- Footnotes are for tangential but useful information that would break the flow of the main text.
- If a footnote is more than ~3 sentences, it probably belongs in the main text or should be cut. A footnote that long signals that the information is either important enough to be in the text or not important enough to include.
- The reader should be able to skip every footnote without missing anything critical.

## Lists

- Very frequent. Use `\begin{itemize}` for unordered lists.
- **Bold labels** at the start of list items for categories: `\textbf{Ethical:} They should...`
- List items are typically complete sentences or substantial sentence fragments.
- Italicized commentary after a recommendation is used to add the authors' assessment: `\textit{We think this model is...}`
- Nested lists are used occasionally but don't over-nest.

## Citations

- Nearly every factual claim is cited. When in doubt, cite.
- `\cite{}` for parenthetical: "...(Author, year)"
- `\textcite{}` for inline/narrative: "Author (year) found..."
- `\prosecite{}` when recommending a resource for reading: produces "Title by Author (year)"
- `\mdcite{}` for citations that only appear in the markdown/Reddit version
- Multiple citations for the same claim are common: `\cite{source1,source2}`
- Personal communications are cited inline: "(Matthew Baggott, personal communication, November 24, 2025)"
- When citing a specific part: `\textcite[p. 14]{razviPSIP}` or `\textcite[sec. Methods]{source}`

## Cross-References

- Use `\cref{}` extensively to link sections. The book is designed as both a front-to-back read and a reference.
- "See \cref{sec:safety} for more information" is a common pattern.
- `\combinedref{}` in the How to Read section for "Section Number (Section Name)" format.

## Numbers, Units, and Formatting

- **Doses:** `100\,mg`, `2\,mg/kg` (thin space before unit, no space within compound unit)
- **Split doses:** `125\,+\,62.5\,mg`
- **Ranges:** en-dash with no spaces: `1--2\,weeks`, `3--14\,days`
- **Percentages:** `87\%` (no space before %)
- **Body mass:** `60\,kg (132\,lb)` — include both units
- **Temperature:** `100\,°C (212\,°F)` — include both units
- **Volume:** `0.5\,L`
- **Time spans:** "six-week spacing," "1.5--2.5\,hours later"
- Small numbers in prose can be spelled out ("three sessions," "two weeks") or use numerals — either is fine, but use numerals when precision matters or when adjacent to units.
- Use `\,` (thin space) between numbers and units in LaTeX.

## Emphasis and Quotation

- `\textit{}` for:
  - Introducing/defining terms: `\textit{connectogen}`, `\textit{minimum effective dose}`
  - Emphasis: `\textit{Destabilization is occasionally long...}`
  - Italicized author commentary in lists
- `\textbf{}` for bold labels in lists
- `\enquote{}` for inline quotations and scare quotes, not regular quotation marks
- `\begin{quotation}` for block quotes

## Section Structure

- Chapters (`\chapter{}`) are the major divisions.
- Sections (`\section{}`) are the main content units.
- Subsections are almost always unnumbered (`\subsection*{}`, `\subsubsection*{}`), used as organizational headers within sections.
- `\todo{}` marks for unresolved issues — these should be addressed during editing, not left in final text.

## Common Patterns

**Recommending a resource:**
> See \prosecite{eckerUnlocking} for further discussion.

**Flagging uncertainty:**
> We are not aware of any research or reliable reports indicating that...

**Presenting anecdotal evidence:**
> Anecdotal reports indicate that people frequently...

**Giving a recommendation with hedge:**
> We suggest / We recommend (for stronger) / We think (for opinions) / We speculate (for weak inferences)

**Noting clinical trial limitations:**
> Clinical trial exclusion criteria are conservative and designed to reduce unknown variables, regulatory scrutiny, and actual, if uncertain, harm.

**Presenting risk:**
> [Risk item in bold] followed by explanation, evidence, and practical recommendation. Often with the pattern: what the risk is → what the evidence says → how to mitigate.

## Tightening Wordy Phrasing

Prefer direct phrasing over roundabout constructions:

| Wordy | Tighter |
|---|---|
| "We have been able to find some evidence that" | "There is some evidence that" |
| "effective for durably improving" | "produces durable improvement in" |
| "It is important to note that" | (just state the thing) |
| "There is a possibility that X may" | "X may" |
| "In order to" | "To" |
| "Due to the fact that" | "Because" |
| "A significant amount of" | (use a specific quantity or "much/many") |

This doesn't mean stripping all personality or nuance. It means removing words that don't carry meaning.

## Avoiding Repetition Across Sections

When the same information appears in multiple places (e.g., safety lists in both the Summary and the Safety chapter), use cross-references rather than duplicating the content. The Summary is an exception since it needs to stand alone, but within the body of the book, "as discussed in \cref{...}" is better than restating.

Within a single section, watch for the same point being made twice in slightly different words. This often happens when a paragraph's last sentence restates its first sentence.

## Things to Avoid

- Don't use "fight-or-flight" (always flight-or-fight).
- Don't use "maladaptive schemas" (use "stuck schemas").
- Don't overstate evidence. If it's one study, say so. If it's anecdotal, say so.
- Don't use "the research shows" without specifying what research and its quality.
- Don't give advice without noting relevant limitations or uncertainties.
- Don't use "patient" (use "client," "participant" for trials, or "person/people").
- Don't use scare tactics or fear-based framing. Present risks matter-of-factly.
- Don't frame MDMA therapy as a quick fix. The book repeatedly emphasizes that it requires hard work over time.
- Don't use polyvagal theory terminology or mechanisms uncritically — the book explicitly notes its lack of empirical support.
