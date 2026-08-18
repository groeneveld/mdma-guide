#import "@preview/lilaq:0.6.0" as lq

#set page(paper: "us-letter", margin: 1in)
#set text(font: "Libertinus Serif", size: 10pt)
#set par(justify: false)

// Figures don't break across pages unless their block is made breakable.
#show figure: set block(breakable: true)
#show figure.where(kind: table): set figure.caption(position: top)

// --- Load data -------------------------------------------------------------
// Columns: Sub scale, Group, mean, ymin, ymax, n
#let rows = csv("data-Table 1.csv").slice(1)

// Subscales in the order they first appear
#let subscales = ()
#for row in rows {
  if row.at(0) not in subscales { subscales.push(row.at(0)) }
}

#let groups = ("Psilocybin", "Ketamine", "MDMA")

// Pull (mean, lower error, upper error) per group, ordered like `subscales`
#let series-for(group) = {
  let means = ()
  let lo = ()
  let hi = ()
  for subscale in subscales {
    let row = rows.find(r => r.at(0) == subscale and r.at(1).starts-with(group))
    let mean = float(row.at(2))
    means.push(mean)
    lo.push(mean - float(row.at(3)))
    hi.push(float(row.at(4)) - mean)
  }
  (y: means, yerr: (m: lo, p: hi))
}

#let x = range(subscales.len()).map(i => i + 1)

// Tick labels rotated 45°, anchored by their top-right corner at the tick so
// they hang down-left instead of drifting off centre.
#let tick-label(name) = box(
  width: 0pt, height: 2.6cm,
  place(top + right, rotate(
    -45deg, origin: top + right,
    box(width: 4cm, align(right, text(size: 8pt, name))),
  )),
)

// --- Plot ------------------------------------------------------------------
#figure(
  caption: [OAV subscale scores by drug, as % of scale maximum.],
  lq.diagram(
    width: 11cm,
    height: 7cm,
    xlabel: [Factors],
    ylabel: [% of Scale Maximum],
    ylim: (0, 55),
    legend: (position: top + right),
    xaxis: (
      ticks: subscales.enumerate().map(((i, name)) => (i + 1, tick-label(name))),
      subticks: none,
    ),

    ..groups.map(group => {
      let s = series-for(group)
      lq.plot(
        x, s.y,
        yerr: s.yerr,
        label: group,
        stroke: none,
        mark: "o",
        mark-size: 4pt,
      )
    }),
  ),
) <fig:oav>

// === Long table ============================================================

// Compact bullet list for the cell bodies.
#let items(..entries) = list(
  tight: true,
  indent: 0pt,
  body-indent: 0.4em,
  marker: [•],
  ..entries,
)

// Category label: extra air above, tight below, like \addlinespace[1em].
#let cat(name) = table.cell(inset: (top: 12pt, bottom: 2pt))[*#name*]

#figure(
  caption: [
    Comparison of hyperarousal and dissociation [opioid dampening] signs.
    Cheetah House (cheetahSigns) compiled this from ogden2006sensorimotor,
    magyari2016teaching, and treleaven2018trauma. Reprinted with permission.
    I think that these are likely the signs of hyperarousal, opioid dampening,
    and the schemas that activate those states, not just signs of hyperarousal
    and opioid dampening themselves.
  ],
  kind: table,
  supplement: [Table],

  table(
    columns: (1fr, 1fr),
    align: left + top,
    inset: (x: 8pt, y: 4pt),
    stroke: none,

    // Booktabs-ish rules plus the single vertical divider. Both repeat on
    // every page the table spills onto.
    table.hline(y: 0, stroke: 1pt),
    table.hline(y: 1, stroke: 0.5pt),
    table.vline(x: 1, stroke: 0.5pt),

    // repeat: true is the default — this row reprints atop each new page.
    table.header(
      align(center)[*Signs of Hyperarousal*],
      align(center)[*Signs of Dissociation*],
    ),

    cat[Body/Somatic], cat[Body/Somatic],
    items(
      [Agitation, difficulty relaxing],
      [Psychomotor hyperactivity],
      [Tingling],
      [Twitching],
      [Hyperventilation, difficulty breathing],
      [Exaggerated startle],
      [Increased heart rate],
      [Hot flashes, flushing],
      [Sweating],
      [Cold hands + feet],
      [Muscle tension],
      [Chronic pain],
      [Insomnia],
    ),
    items(
      [Flaccid muscle tone],
      [Extremely still (frozen)],
      [Pale skin tone],
      [Fixed gaze ("thousand yard stare"), glassy eyes],
    ),

    cat[Cognitive], cat[Cognitive],
    items(
      [Racing, repetitive, obsessive, intrusive thoughts],
      [Worry, rumination],
      [Rapid or disorganized speech],
      [Jumping from topic to topic],
      [Executive dysfunction (memory, planning, decisions)],
    ),
    items(
      [Few thoughts, "mind is blank"],
      ["Can't think"],
      [Concept loss],
      [Slow responses],
      [Difficulty evaluating surroundings],
      [Executive dysfunction (memory, planning, decisions)],
      [Slowed/slurred or disorganized speech],
      ["Spacey," "ungrounded"],
      [Hypernowness, no past or future],
    ),

    table.cell(inset: (top: 12pt, bottom: 2pt))[], cat[Self],
    [],
    items(
      [Disconnected from body, emotions, thoughts],
      [Outside body or at distance],
      [Disownership],
      [Don't exist, not here],
    ),

    cat[Emotion], cat[Emotion/Motivation],
    items(
      [Emotional volatility, mood swings],
      [Euphoria, mania, grandiosity],
      [Anxiety, panic],
      [Reports of flashbacks, nightmares],
      [Irritability, anger],
    ),
    items(
      [Affective flattening, blunted emotions, loss of emotion],
      [Normal emotions but "can't feel them" or "not mine"],
      [Apathy, feel dead, nothing matters],
      [Lack of meaning, motivation],
    ),

    cat[Conative/Motivational], table.cell(inset: (top: 12pt, bottom: 2pt))[],
    items(
      [Excessive, obsessive striving/effort],
      [Scrupulosity/perfectionism],
      [Apathy/withdrawal],
    ),
    [],

    cat[Perception], cat[Perception],
    items(
      [Perceptual hypersensitivity],
      [Sounds too loud],
      [Light sensitivity],
    ),
    items(
      [World appears unreal or dreamlike],
      [Objects appear flat/2-dimensional; "cartoon-like"],
      [Distance distortions],
      [Visual hyper-clarity or fog],
    ),

    cat[Social], cat[Social + Occupational],
    items(
      [Social engagement dysregulated],
      [Inhibition/withdrawal (also disinhibition, disruptive, interrupting)],
      [Inability to make eye contact during interviews/interactions],
    ),
    items(
      [Social engagement system offline],
      [Not seeking social support],
      [Withdrawn/avoidant],
      [Eye contact difficulty],
    ),

    // No corresponding hyperarousal category.
    table.cell(inset: (top: 12pt, bottom: 2pt))[], cat[Dissociation vs. Meditative Calm],
    [],
    items(
      [Disconnected from thoughts, body, emotions, world, others],
      ["Not here"],
      [Immobility; frozen quality],
      [Sudden resolution of distress],
      ["Feel fine"],
      ["Nothing going on"],
    ),

    table.hline(stroke: 1pt),
  ),
) <sec:signsofdc>
