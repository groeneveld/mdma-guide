# Book Map — Open MDMA

A digest of the whole manuscript for context-aware editing. Load this + the relevant
`cross-cutting-issues.md` entries + the section you're editing, instead of the whole book.

**Keep this current.** After editing a section, update its entry here in a line or two
(argument, any claims/numbers that changed, new/removed cross-references). See CLAUDE.md.

Source of truth is `paper.tex`. Line numbers below are approximate (as of the v6 draft,
2026-07-07) and drift as edits land — search by heading, don't trust the number.

---

## Global: voice, themes, conventions

**Author & stance.** Single primary author (M.G.), independent scholar, no formal training in
the fields drawn from, treated MDMA therapy for his own CPTSD / disorganized attachment /
childhood sexual abuse (~30 MDMA sessions + hundreds of hours of "internalized" reconsolidation).
Second contributor T.H. (therapist) wrote *How to Find a Practitioner* (`sec:howtofind`), most of
*Navigating Uncertain Memories* (`navigating`), and scattered parts. The book's persona is
rigor-first, autonomy-respecting, anti-"neurobabble," transparent about uncertainty and bias.

**Core theoretical spine** (repeated everywhere — the book's main selling point is the *synthesis*):
1. **Memory reconsolidation** (Ecker) — the single mechanism of durable change; stuck *schemas*
   update when activated + met with sufficient prediction error.
2. **Predictive processing** (Clark) — schemas = priors; prediction error = mismatch; framed as
   the same phenomenon as reconsolidation's "prediction error."
3. **Complex systems** (Hayes) — mental illness as attractor states; explains symptom worsening,
   "worse before better," nonlinearity, relapse.
4. **Defense cascade** (Kozlowska) — arousal → flight-or-fight → freeze → tonic/collapsed
   immobility; the last is reframed as **opioid dampening** (author's preferred mechanistic term
   over "dissociation").

MDMA's role: facilitates prediction error / reconsolidation for *any* activated stuck schema you
stay present with. Mechanism unknown (hypotheses in `ppHypotheses`).

**Recurring motifs / phrases** (watch for over-repetition — see cross-cutting issues):
- "activate a stuck schema and stay present with it" → it reconsolidates
- "skilled, ethical, and well-matched" (practitioner) — near-verbatim boilerplate, many occurrences
- "worse before it gets better" / symptom worsening as healthy-when-managed
- "I think / I believe" hedging to mark opinion vs. established science (a stated methodology choice)
- "opioid dampening and avoidance" as the paired session obstacles
- therapy hangover limits active reconsolidation to ~2 hrs/day
- "the present moment provides contradictory evidence you're not in danger"

**Style conventions.**
- LaTeX book class. Headings sans-serif. Extensive `\cref`/`\nameref` cross-referencing — the book
  is explicitly designed for both linear and reference reading, so cross-refs are load-bearing.
- `\cite`, `\textcite`, `\prosecite` (= "Title by Author [cite]"), `\citefullauthor`.
- `\mdcite`/`\mdonly` = content only for the Reddit/markdown export (invisible in PDF).
- `\writtenByDay{}` = authorship tracking wrapper, renders its content normally.
- `\todo{}` notes are disabled in output but litter the source — these are open questions to the
  author/reviewers, NOT prose. Many are genuine unresolved content questions (see issues file).
- `\claim{bold claim}{body}` used only in `sec:assumptions` (Core Assumptions appendix).
- Numbers use `\,` thin spaces (100\,mg, 6\,weeks). En-dashes for ranges.
- British/American spelling is mixed in places (see issues).
- Custom: `\reconsolidationhours{}` auto-computes the author's cumulative hours from the date.

**Audience.** Primarily the solo user / client (author's background); practitioners are a secondary
audience served by `practitionerSkills` + the practitioner-facing subsections. Explicitly says
aspiring practitioners can't learn to guide from this book alone.

**Key recurring numbers** (must stay consistent — see issues file for current conflicts):
- Standard dose: 100\,mg (<60\,kg / >75\,yr), 125\,mg (≥60\,kg); up to 200\,mg max total for high body mass.
- Booster: half-strength, taken ~1.5–2.5\,hr in.
- Session spacing: 6\,weeks (trial-based) as reasonable start; 2\,weeks absolute minimum.
- Water: max 0.5\,L during the (six-hour) session.
- "Always avoid": MAOIs/ayahuasca, ritonavir/cobicistat, >240 sessions, unmanaged hyperthyroidism.
- SSRIs/SNRIs: ideally off 2 months prior; efficacy halved even after 25 days.
- Antioxidant buffer recovery: LLM-estimated 2–10 days; author doubles upper end → spacing floor.
- Effect sizes (pooled phase III): PTSD symptoms d≈0.80 (CI 0.49–1.1); function d≈0.42 (CI 0.17–0.66).

---

## Front matter (lines ~189–383)
Title page, license (CC BY 4.0), abstract, disclaimer, per-version changelogs (v3→v6), author
contributions, AI disclosure, biases/COI table (M.G. vs T.H.). The **date field** (line ~195)
still says the book "needs to be reviewed and then substantively edited again" and safety recs are
"being refined" — decide whether that stays for this round. Changelog for v5→v6 describes this
round's predecessor. Abstract states the book's four-framework thesis + the "only manual to justify
recs from a mechanistic theory" claim.

## Preface (`preface`, ~293)
Personal origin story ("*Where There Is No Doctor* for mental health"), the recursive
theory↔experience method, thanks. Establishes tone and the novelty-of-synthesis claim.

## Ch. Summary (`summary`, ~386)
Plain-language whole-book summary (wrapped in `BEGIN/END_PLAIN_SUMMARY` markers — also used for the
standalone Reddit summary). Mirrors, in miniature, nearly every downstream section: how trauma
works, how MDMA works, the session, working with a practitioner, and the full safety lists
(Always Avoid / Use Caution / Take Precaution). **These safety lists are duplicated near-verbatim
in `sec:safety`** — a prime consistency-maintenance target. Cites the 41% non-secure-attachment
stat, the godes2023 list of client-reported experiences (also repeated in `session`).

## Ch. Introduction
- **How to Read this Book** (`essentials`, ~498): audience, what's covered, "most important
  sections" list, reference-reading design, the LLM-companion session prompt (excludes glossary/
  appendices via `\zref`). This is the "Quick Start/Essentials" section gls.py skips for glossary linking.
- **Approach…With Skepticism** (`howtoevaluate`, ~520): epistemic framing — psychology/psychiatry/
  neuroscience models are mostly non-mechanistic; calibrates trust, incl. in the book itself.
- **Methodology** (`methodology`, ~540): four source types; the "I think" convention; no neuroimaging
  cited (and why); reference-validity checks; **Major Unresolved Issues**, **Reasons to be
  Confident**, **Reasons to be Skeptical** (bulleted self-critique — recently trimmed per git log).
- **Efficacy** (`efficacy`, ~598): FDA-vs-Dutch dispute; ICER pooled effect sizes; `table:efficacy`
  (No Response / Clinically Meaningful / Loss of Diagnosis / Remission, MDMA vs placebo); each
  session adds durable benefit; clinical-vs-trial differences list.
- **Generalizes Beyond PTSD** (`biopsychosocial`, ~640): evidence for anxiety/alexithymia/etc.;
  biopsychosocial model; HiTOP clustering argument; reconsolidation argument; heritability caveat.
  Concludes MDMA likely helps the *psychological* component of most mental illness.

## Ch. Theoretical Model (`science`, ~663)
- **The Defense Cascade** (`sec:defensecascade`, ~665): the five states; associative (schema-driven)
  activation; **opioid dampening** definition & why it's preferred over "dissociation"; polyvagal-
  theory caution; big `sec:signsofdc` hyperarousal-vs-dissociation table (reprinted w/ permission).
- **Trauma, Insecurity, and their Effects** (`sec:trauma`, ~845): schemas as "true-enough"
  heuristics; definition of trauma; **stuck schemas** term; children learn inaccurate schemas;
  Amy example; schema outputs (emotion/belief/behavior/soma); intergenerational transmission.
- **How Schemas Update (Or Don't)** (`sec:mechanism`, ~900; also holds `attention` label):
  prediction error & the reconsolidation window; Brussels-sprouts example; sources of contradiction;
  why trauma schemas don't update (avoidance, precision/attention, opioid dampening) — the
  attention/avoidance material lives here.
- **How MDMA Helps Update Schemas** (~926, no section label): three ways to use MDMA for
  reconsolidation; Ecker's signs of a reconsolidated schema (block quote — **repeated in "Assessing
  Whether the Session Worked"**).
- **Somatic Symptoms** (`psychogenic`, ~949): van den Bergh psychogenic-symptoms model; author's
  chronic-itching case; not all symptoms are inaccurate perceptions; stress-pathway skepticism.
- **Complex Systems: Symptoms Can Get Worse Before They Get Better** (`sec:complex`, ~975):
  attractor-state / ball-in-landscape model; three kinds of symptom worsening; healing as complex
  change (3 modes); limitations of the complex-systems approach. Referenced constantly downstream.

## Ch. Safety (`sec:safety`, ~1019)
Opens with the three-tier summary lists (**duplicated from Summary**). Then:
- **Basic Pharmacology** (~1059): connectogen class, half-life 9\,hr, timing, storage, `fig:mdma`.
- **Acute Effects** (`acuteEffects`, ~1075): `table:sideeffects` (Liechti gender data, acute + 24\,hr),
  `consciousEffects` OAV figure (MDMA vs ketamine vs psilocybin), therapy hangover.
- **Testing and Measurement** (`testing`, ~1137): reagent vs lab testing; crystals vs pills;
  hydration/mass; volumetric dosing; the legal warning about dissolved-in-liquid mass.
- **Dosing** (`sec:dosing`, ~1153): dose–effect window; two dose sets (conservative Liechti vs
  clinical-trial) + My Recommendations (minimum effective dose); nonlinear PK above 125\,mg;
  oxidative-stress adjuncts (caffeine/heat/antioxidants/SSRIs). Several `\todo` speculation flags.
- **Session Frequency** (`frequency`, ~1196): antioxidant-buffer recovery (LLM-estimate, heavily
  caveated); short/long-term tolerance; 6-week start / 2-week floor; downsides & benefits of
  frequent sessions. Contains the prominent LLM-use disclosure.
- **Drug Interactions** (`interactions`, ~1241): general half-life rule; serotonin syndrome; CYP450;
  specific list (MAOIs, ritonavir/cobicistat, SSRIs/SNRIs, caffeine).
- **Medical Risks** (`medical`, ~1269): trial exclusion framing; cardiovascular, liver,
  hyperthyroidism; acute (hyponatremia, heat, seizures); chronic (valvular HD, oxidative damage,
  cognitive impairment); higher-risk groups (adolescents, pregnancy, breastfeeding).
- **Psychological Risks** (`psychologicalRisks`, ~1311): trial exclusion criteria; individualized-
  risk stance; ranked list — **Symptom Worsening** (`psychosis` label sits on the Psychosis item),
  Psychosis, Suicidal Ideation, Addiction, HPPD, Mania. Heavy anecdote+caveat style.
- **When to Seek Emergency Care** (~1380): serotonin-syndrome red flags; chest-pain guidance.
- **Common Concerns** (~1390): loss of control, drug stigma, synthetic-ness, unlearning healthy schemas.

## Ch. The Arc of Healing (`bigPicture`, ~1413)
The long-term journey: reconsolidation → decreased avoidance → reaction → repeat. Thousands of hours
for severe cases; MDMA as scarce resource → do bulk of work with sober reconsolidation exercises;
schema-inventory scale; when-you-think-you're-done advice; `sessionDecision` scheduling matrix.

## Ch. Working With or Without a Practitioner
- **Practitioner vs Self-Guidance** (`professionalVSSelf`, ~1462): factors each way; cost figures;
  four **Recommended Models** (guided→solo transition is the recommended default).
- **Involuntary Commitment** (`suicideCops`, ~1521): the risk that licensed providers call police;
  emanuelHospitalization finding that involuntary commitment *increases* suicide/violence risk.
- **[unedited] How to Find a Practitioner** (`sec:howtofind`, ~1525): **T.H.-authored, flagged
  `[unedited]` in the heading.** Long. Bad-therapy-worse-than-none; trust-your-experience; feedback;
  **Boundaries / AIT** (`def:ait` — adverse idealizing transference, referenced from practitioner ch.);
  targeted therapy; long-term-project framing; **Accreditation and Safety** (`sec:accreditation`);
  **MDMA-Specific Complications** (`sec:mdmaTherapistComplications`); **Individual Actions**
  (`individualActions` — license, fit, methodology, background check, accountability, flight plan,
  cultishness). This whole section is the least-edited and longest prose block; high priority and
  it's in T.H.'s voice (third-person "T.H. recommends").

## Ch. Prompts for Activating Stuck Schemas (`mapping`, ~1736)
- **Personal Schemas** (~1743): `mssProbes` — big table of schema-activation prompts by domain
  (the one place Claude generated content, per AI disclosure). Habit Mapping subsection (T.H. voice).
- **Social Schemas** (`socialPrompts`, ~1955): imagine being in an out-group; referenced by the
  cognitive-flexibility and ethics sections.
- **Existential Schemas** (~1969): imagine permanent loss of everything; equanimity framing.
- **Cognitive Flexibility and Truth-Seeking** (`cognitiveflexibility`, ~1974): tribalism/self-
  deception; MDMA to reconsolidate belief-defending schemas. Flagged "partially speculative."
- **Authentic Engagement… Ethical Reasoning** (`stopcycle`, ~2000): circle of moral consideration;
  contemplate beings' worth; animal/AI consciousness. Flagged "partially speculative."
- **Connection with Nature** (`sec:nature`, ~2046): safe outdoor session logistics; psilocybin aside.

## Ch. Pre- to Post-Session (~2074)
- **Pre-Session Checklist** (`prep`, ~2075): Mindset / Setting / Tools / Post-Session prep bullet lists.
- **Opioid Dampening and Avoidance During the Session** (`sec:sessionbarriers`, ~2121): the two
  paired obstacles; PSIP / selective inhibition (Razvi); Increasing Safety vs Paying Attention lists;
  cannabis-PSIP "Other Options." Referenced by nearly every troubleshooting item. Contains a
  commented-out naltrexone/opioid-antagonist paragraph (also parked in the top-of-file
  "Collected Paragraphs" comment block, lines ~264–291).
- **The Therapeutic MDMA Session** (`session`, ~2172): timing; when extra dosing is justified
  (3\,mg/kg or 200\,mg caution ceiling); Session Timeline (come-up/peak/comedown/after); Therapeutic
  Technique (activation methods — **overlaps `mapping` activation list**); Barriers to
  Reconsolidation (resistance, spiritual bypass, "message from the medicine," blankness); Crisis
  Management; Therapy Hangover; Precaution Against Life-Altering Decisions.
- **Troubleshooting** (`sec:troubleshooting`, ~2254): 13 subsections keyed to symptoms. Heavy
  cross-referencing back into `sec:sessionbarriers`, `sec:complex`, `frequency`, `afterglow`,
  `sectionManagement`. Several items **repeat text nearly verbatim** from `sec:sessionbarriers`
  and the top-of-file Collected Paragraphs block (numbness/immobility, soberness/boredom).
  `selfinsight` (Insight into Selfhood…) is a large subsection on contemplative/non-dual experiences
  with its own resource lists; flagged `\todo{Rewrite with mechanistic explanation?}`.

## Ch. Between Sessions (`sectionManagement`, ~2399)
- **Reconsolidation Tools** (`sec:moreReconsolidation`, ~2407; also holds `increasingAttention`):
  practitioner-led therapy + integration clinics; meditation; general DIY (juxtaposition — note an
  **empty bullet** at ~2432); Ideal Parent Figure (`def:ipf`); Internalized MDMA Therapy trajectory.
  Subsection **LLM Therapy** (~2443) with a long reusable session prompt.
- **Grounding Tools** (`grounding`, ~2460): grounding vs reconsolidation distinction.
- **Peer and Community Support** (~2475), **Medical/Psychiatric Support** (~2488, ends with a
  T.H.-voice `\writtenByDay` block).
- **Navigating Uncertain Memories** (`navigating`, ~2507): recovered-memory caution (M.G. note +
  long T.H.-voice block). **The M.G. recovered-memory note here duplicates the one in
  `individualActions`.**
- **Life Changes Associated with Improved Mental Health** (`sec:lifechanges`, ~2523): health habits,
  relationships, making-changes framework. Low-evidence, explicitly non-essential.

## Back matter — glossary, then appendices
- **Glossary** (`sec:glossary`, printed ~2571; defs in `glossary.tex`): 23 terms; gls.py auto-links
  first occurrence per section. Terms: schema, reconsolidation(-exhaustion), defense cascade + its
  states, opioid dampening, dissociation, trauma, connectogen, psychedelic, attachment, predictive
  processing, resistance, spiritual bypass, avoidance, biopsychosocial, complex system, attractor,
  destabilization, afterglow.
- **Core Assumptions** (`sec:assumptions`, ~2577): the foundational `\claim{}`s with Low/Medium/High
  certainty, grouped Complex Systems / Reconsolidation-PP / Defense Cascade & Safety. This is the
  "show your work" backbone the practical chapters point back to. Referenced from Preface, Methodology,
  Efficacy, Generalizes, and the mechanism sections.
- **Information for Practitioners** (`practitionerSkills`, ~2635): skills, ethics, treatment (no
  phased-treatment evidence), experience, recommended reading.
- **Reports of Internalized MDMA Therapy** (`internalizedReports`, ~2673): M.G.'s first-person
  account + a long Q&A interview with Anonymous. Referenced from `bigPicture`, `sec:moreReconsolidation`,
  the mechanism sections, and "Assessing Whether the Session Worked." Note large commented-out
  passages about "insight cycles"/non-duality (author is undecided whether to include).
- **Mechanism of Action Hypotheses** (`ppHypotheses`, ~2784): switches to predictive-processing
  vocabulary; 6 hypotheses w/ supporting/contradictory evidence; Duḥkha link.
- **Alternatives to MDMA** (~2843): methylone, 5-MAPB, custom analog blends.
- **Suggested Avenues of Future Research** (~2857): ~25 open questions (a good index of the book's
  acknowledged uncertainties).
- **Bibliography** (~2885).
