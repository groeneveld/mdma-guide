#import "auxillaryFiles/template.typ": *
#import "@preview/lilaq:0.6.0" as lq
#import "@preview/alchemist:0.1.8" as alchemist

// Glossary. The first mention of a term in each chapter/section is linked to
// its entry; `stems` are matched case-insensitively and expanded to the whole
// word. Mentions inside `defined-in` (a section label) are not linked.
#let glossary = (
  schema: (
    name: "Schema",
    stems: ("schema",),
    defined-in: <sec:trauma>,
    description: [A single learned model about the world or self that generates, in response to specific stimuli, behavioral impulses, emotions, thoughts, and sometimes sensory perception~@eckerUnlocking. I call old schemas that are not appropriate to your current context _stuck._ _Inaccurate_ would be more precise, but it may be seen as invalidating.],
  ),
  reconsolidation-exhaustion: (
    name: "Reconsolidation Exhaustion",
    stems: ("emotionally exhausted", "reconsolidation exhaustion", "therapy hangover", "emotional exhaustion"),
    defined-in: <session>,
    description: [Large amounts of reconsolidation cause intense mental and physical exhaustion that can feel different from regular exhaustion. It's often called a therapy hangover or EMDR hangover (in eye movement desensitization and reprocessing therapy). The phenomenon hasn't been formally studied. Anecdotal reports suggest it dissipates within a few hours to a couple of days.],
  ),
  reconsolidation: (
    name: "Reconsolidation",
    stems: ("reconsolidat",),
    defined-in: <sec:mechanism>,
    description: [When a schema or implicit memory first forms, it is _consolidated_~@eckerUnlocking. When contradictory evidence causes sufficient prediction error, the schema enters a state where it can be changed (it becomes _labile_). Maintaining that contradiction or prediction error gradually updates the schema to reflect the new information. At the end of this process the schema _reconsolidates_ and becomes unchangeable again. I also use the term _reconsolidate_ to refer to this whole process of activation, updating, and reconsolidation.],
  ),
  defense-cascade: (
    name: "Defense Cascade",
    stems: ("defense cascade",),
    defined-in: <sec:defensecascade>,
    description: [A series of physiological changes in the sympathetic and parasympathetic nervous systems that prepares the body to respond to imminent threats~@kozlowskaDefenseCascade. It includes arousal, flight-or-fight, freezing, and tonic/collapsed immobility. Increasing levels of perceived threat, threat imminence, powerlessness, and somatic sensory input activate these responses, though the order of activation also depends on individual variability and past experience.],
  ),
  arousal: (
    name: "Arousal",
    stems: ("arous",),
    defined-in: <sec:defensecascade>,
    description: [Increased alertness and threat assessment activated when a potential threat is noticed~@kozlowskaDefenseCascade. It is also preparation for flight-or-fight if the threat escalates. Heart rate, breathing, and muscle tone rise. Saliva production stops and core muscles tighten to stabilize posture.],
  ),
  flight-or-fight: (
    name: "Flight-or-Fight",
    stems: ("flight-or-fight",),
    defined-in: <sec:defensecascade>,
    description: [The active defense response characterized by high levels of adrenaline and muscle activation, greatly increased heart and respiratory rates, and decreased pain sensitivity~@kozlowskaDefenseCascade.],
  ),
  freeze: (
    name: "Freeze",
    stems: ("freez",),
    defined-in: <sec:defensecascade>,
    description: [A paused flight-or-fight response~@kozlowskaDefenseCascade. Attention to the environment remains high but the body freezes to avoid the attention of predators who are more likely to notice moving prey. Freeze is one type of #link(<glossary:dampening>)[opioid dampening].],
  ),
  immobility: (
    name: "Tonic/Collapsed Immobility",
    stems: ("immobil",),
    defined-in: <sec:defensecascade>,
    description: [The inactive defense responses characterized by detachment; emotional and physical numbing; and difficulty moving~@kozlowskaDefenseCascade. Predators are more attracted to moving prey and may lose interest in seemingly dead bodies. Collapsed immobility may escalate to unconsciousness. Immobility is one type of #link(<glossary:dampening>)[opioid dampening].],
  ),
  dampening: (
    name: "Opioid Dampening",
    stems: ("opioid dampening",),
    defined-in: <sec:defensecascade>,
    description: [The dampening of emotions, perception, or movement caused by the endogenous opioids in immobility, freeze, and possibly other phenomena. See @sec:defensecascade.],
  ),
  dissociation: (
    name: "Dissociation",
    stems: ("dissociat",),
    defined-in: <sec:defensecascade>,
    description: ["Involuntary disruption or discontinuity in the normal integration of one or more of the following: identity, sensations, perceptions, affects, thoughts, memories, control over bodily movements, or behaviour"~@icd11. It is caused by unnoticed avoidance, #link(<glossary:dampening>)[opioid dampening], and other phenomena.],
  ),
  trauma: (
    name: "Trauma",
    stems: ("trauma",),
    defined-in: <sec:trauma>,
    description: [Events that interact with existing schemas to either create or reinforce inaccurate schemas that may or may not be adaptive in the short term but impair functioning or emotional health in the long term.],
  ),
  practitioner: (
    name: "Practitioner",
    stems: ("practitioner",),
    defined-in: <summary>,
    description: [A professional (licensed or unlicensed) who supports you in your healing journey. They should be skilled, ethical, and well-matched to you. @practitioner details these qualifications.],
  ),
  stayingPresent: (
    name: "Staying Present",
    stems: ("stay present with", "staying present with"),
    defined-in: <summary>,
    description: [Focusing on a symptom or schema and allowing it to be felt in the body and mind without acting to end, alter, escape, or explain it away. You might also _investigatively feel_ how the schemas and symptoms change as you move, as your thoughts and triggers change, or as the schema reconsolidates.],
  ),
  psychedelic: (
    name: "Psychedelic",
    stems: ("psychedelic",),
    defined-in: <na>,
    description: ["Showing the mind/soul," from the Greek _psyche_ and _deloun_~@osmondObit. Most are tryptamines, phenethylamines, and ergolines~@gumpper2024chemistry. Different classes have different effects. I do not categorize MDMA as a psychedelic, but rather a connectogen (see #textcite(<stockerConnectogen>)). These drugs facilitate profound connection to self, body, senses, and others. The sense of self is maintained and hallucinations are minimal, unlike with the classic psychedelics or hallucinogens. I still use the term _psychedelic_ to discuss the broader social movement surrounding psychedelics and MDMA. I also use _psychedelic_ when referencing the many studies that don't differentiate MDMA from the _classic psychedelics._],
  ),
  attachment-theory: (
    name: "Attachment Theory/Styles",
    stems: ("secure attachment", "attachment theory", "attachment disorder", "disordered attachment", "anxious attachment", "insecure attachment", "non-secure attachment"),
    defined-in: <attachment>,
    description: [Attachment theory describes how secure attachment in early childhood is critical to healthy emotional and psychological development~@brownAttachmentDisturbances. Emotional insecurity in early childhood creates complex networks of stuck schemas. See #textcite(<fivePillars>) for an introduction.],
  ),
  predictive-processing: (
    name: "Predictive Processing",
    stems: ("predicti",),
    defined-in: <sec:trauma>,
    description: [The prevailing model of brain function~@clark2015surfing. The brain internally models the world and self via complex networks of learned priors/beliefs to plan the future fulfillment of basic needs such as bodily integrity, reproduction, community, etc. Prediction error is a discrepancy between the brain's model of the world and incoming sensory data or between two contradictory models. A sufficiently strong prediction error updates a prior. \ \ Memory research has converged on the same phenomenon from a different angle using different terms~@eckerUnlocking. In that formulation, priors or sets of priors encoded in long-term memory are called schemas, and updating those schemas is called reconsolidation.],
  ),
  resistance: (
    name: "Resistance",
    stems: ("resistance",),
    defined-in: <na>,
    description: [Opposition to reconsolidation or other therapeutic processes that would be healthy for the individual.],
  ),
  bypass: (
    name: "Spiritual Bypass",
    stems: ("spiritual bypass",),
    defined-in: <na>,
    description: [As #textcite(<cashwell2007Bypass>) states, spiritual bypass "occurs when a person attempts to heal psychological wounds at the spiritual level only and avoids the important (albeit often difficult and painful) work at the other levels, including the cognitive, physical, emotional, and interpersonal." This results in persistence of maladaptive patterns and interrupted psychological development.],
  ),
  avoidance: (
    name: "Avoidance",
    stems: ("avoida",),
    defined-in: <mechanism>,
    description: [Any behavior or action taken to escape a perceived threat. This can be physical avoidance, like not petting dogs when you have stuck schemas about how dangerous dogs are. It can also be mental avoidance, like distracting yourself when you think about or feel certain things if your schemas predict that feeling those emotions or thoughts is itself a threat. Avoidance can be automatic and unnoticed.],
  ),
  muting: (
    name: "Muting",
    stems: ("mute", "muting"),
    defined-in: <mechanism>,
    description: [The brain can mute (make more ambiguous or less precise) sensory information when it thinks it isn't useful or reliable or when it wants to prioritize quick action in situations of threat (see @attention). I chose it as an easier-to-use substitute for _down-weighted precision of bottom-up information._],
  ),
  biopsychosocial-model: (
    name: "Biopsychosocial Model",
    stems: ("biopsychosocial",),
    defined-in: <sec:trauma>,
    description: [The prevailing model of mental illness as a complex interaction of biology (genes and medical history), psychology (schemas, in our view), and society (one's support system and social models of how to respond to adversity)~@engel1977need.],
  ),
  complex-system: (
    name: "Complex System",
    stems: ("complex system",),
    defined-in: <sec:complex>,
    description: [A system with many interacting parts that is difficult to model and understand~@hayes2020complex. The overall behavior of the system can't be easily predicted by looking at the individual components. The mind/brain is a complex system.],
  ),
  attractor-state: (
    name: "Attractor",
    stems: ("attractor",),
    defined-in: <sec:complex>,
    description: [A state in a complex system that the system is drawn to~@hayes2020complex. Many mental illnesses are attractor states. Schemas seem to stick around when they're paired with a reconsolidation-inhibiting process like avoidance, which together form an attractor state~@hayes2020complex@berghBSTS. The durability of the state requires multiple reinforcing elements; removing those elements destabilizes it.],
  ),
  destabilization: (
    name: "Destabilization",
    stems: ("destabiliz",),
    defined-in: <sec:mechanism>,
    description: [Two phenomena described in @sec:complex. The first is increased fluctuation between states of good and bad mental health that often precedes a stabilizing transition to the good state. The second is a transition to a stable but even worse state of mental health, possibly precipitated by confronting disturbing memories that were previously avoided. Both phenomena are part of the healthy process of therapy when managed well and entered into at an appropriate time.],
  ),
  afterglow: (
    name: "Afterglow",
    stems: ("afterglow",),
    defined-in: <afterglow>,
    description: [A days-to-weeks-long period after a session characterized by well-being, positive mood, mindfulness, positive behaviors, and less mental illness~@evansAfterglow. Conventional therapy might be more effective in this period. Anecdotal reports indicate that the occurrence of afterglow is unreliable. It can also occasionally be strong enough that people feel like they're on a low dose of MDMA.],
  ),
)

#show: book.with(glossary: glossary)

#title-page(
  title: [Open MDMA],
  subtitle: [An Evidence-Based Synthesis, Theory, and Manual for MDMA Therapy Based on Memory Reconsolidation, Complex Systems, and the Defense Cascade],
  author: [Mark Groeneveld],
  date: [Preprint Draft Version 6.x; #datetime.today().display("[month repr:long] [day padding:none], [year]"). The book is a work in progress; it needs to be reviewed and substantively edited again. Safety recommendations are still being refined.],
  bluf: [MDMA permanently heals emotional issues that you trigger and stay present with during a session. It is rapid compared to conventional therapy but is not a quick fix for complicated problems. Those with complex trauma can go through a long series of ups and downs that gradually trends upward.]
)[
This work is licensed under #link("https://creativecommons.org/licenses/by/4.0/")[CC BY 4.0].

This book is available in #link("https://raw.githubusercontent.com/groeneveld/mdma-guide/refs/heads/main/Open%20MDMA.epub")[EPUB], #link("https://groeneveld.github.io/mdma-guide/")[HTML], and #link("https://raw.githubusercontent.com/groeneveld/mdma-guide/refs/heads/main/Open%20MDMA.pdf")[PDF]. When sharing the book, please use one of those links to ensure that people have the latest version. I update it weekly. You can sign up for notifications of new major versions (\~yearly updates) at #link("https://github.com/groeneveld/mdma-guide"). Select the _Watch_ dropdown at the top right, choose _Custom,_ then _Releases._ The major versions are also posted at #link("https://doi.org/10.31234/osf.io/aps5g") with a DOI.

I'd love to hear your thoughts at #link("mailto:mgroeneveld@protonmail.ch"). I'm curious how you're using the manual, what you like, and what you don't. Please let me know about any errors. You can also submit anonymous feedback #link("https://docs.google.com/forms/d/e/1FAIpQLScZe2h4L9PcLQGGpuerk44FXiWThRC2w6YNwSm67OXIJun-rA/viewform?usp=dialog")[here].

The changelogs are in @sec:revisions.
]

#page-break()
#front-section[Abstract]
// BEGIN_ABSTRACT
MDMA therapy is not approved by most medical regulators, but underground use is popular despite inadequate practical guidance. I provide comprehensive practical guidance for solo and guided MDMA therapy based on critical literature synthesis, personal experience, community reports, and a mechanistic framework. I primarily address the individual doing or seeking MDMA therapy while also discussing certain aspects of interest mostly to practitioners and researchers. With this manual I aim to improve the appeal, safety, and efficacy of MDMA therapy through scientific rigor, comprehensiveness, transparency, and respect for autonomy.

I integrate memory reconsolidation, predictive processing, complex systems dynamics, and the defense cascade theory of autonomic nervous system threat responses. I use this model to explain how many mental illnesses arise and how MDMA therapy works, why destabilization exists, and how to navigate the long-term healing process. I argue that MDMA therapy durably improves many mental illnesses and stuck emotional reactions and beliefs through the unlearning, or reconsolidation, of inaccurate mental models. MDMA therapy reconsolidates most or all stuck mental models that are activated during the session and that you stay present with.

The practical guidance contains evidence-based discussion of safety, session preparation, the session itself, troubleshooting, between-session healing, and how it all fits into the longer-term healing journey. I extend MDMA therapy beyond clinical mental illness to mental models that inhibit healthy community relationships, cognitive flexibility, and ethical reasoning. I also discuss the tradeoffs between practitioner- and self-guidance.

This is the only MDMA/psychedelic therapy manual that explains and justifies its recommendations with a mechanistic theory of mental illness and healing while providing reasons for both confidence in and skepticism about its claims.
// END_ABSTRACT

#page-break()
#front-section[Disclaimer]
This book doesn't offer personalized medical or therapeutic advice, guarantee healing, prevent negative (possibly severe) outcomes, or protect against legal problems if used in a place where MDMA is illegal. It is my framework for increasing the efficacy and safety of MDMA therapy, grounded in research, community insights, and my experience. I spent considerable effort validating the book's claims, but it could be wrong about important points. Possessing MDMA is a felony in many jurisdictions. Licensed mental health professionals risk their licenses by offering MDMA therapy in contexts where it isn't legal.

While this book has universal aspects, it doesn't cover all frameworks for doing MDMA therapy. Although MDMA therapy has been practiced for 50~years, comprehensive scientific study is relatively recent, leaving many aspects unexplored and poorly theorized. I think my model is a formalized version of what some MDMA therapists have already been practicing for decades. However, my integration of complex systems dynamics, memory reconsolidation, attention, and the defense cascade appears novel even though each piece is fairly well-established. Novel frameworks are usually incorrect or incomplete to some degree.

The purpose of the book is to reduce suffering. As part of that goal, several sections apply MDMA therapy to topics not typically considered part of therapy.

#page-break()
#outline()

#heading(level: 1, numbering: none)[Preface]
<preface>
This book combines the tasks of reviewing and theorizing, packaged as a practical manual. It includes a significant amount of personal experience with the practices described here. I aim to democratize access to high-quality MDMA therapy by combining scientific rigor, comprehensive practical guidance, high ethical standards, and transparency about my biases and what is and isn't known in the field.

The book started as my attempt to figure out what was actually happening during my MDMA therapy journey, which I began after nearly every treatment that licensed mental health professionals can offer had failed to help. I struggled to understand what mental illness is, what MDMA therapy does, and how to optimize it for efficacy and safety. I learned that rigorous answers to these questions only began to appear in the 2000s and 2010s and have yet to diffuse widely from academia. This knowledge base is scattered throughout the literature and, as far as I can tell, hasn't been put together before. This is unfortunate because many people are desperate for mental health treatment and are attempting MDMA therapy with inadequate information. I thought a manual and review could address my uncertainties.

Because MDMA therapy was almost my last option, knowing how to do it right was essential to my health. I needed this body of actionable, accurate knowledge to survive in a world of poor-quality mental health information.#footnote[Much of my motivation came from attachment issues and CPTSD, but these schemas occasionally have positive side effects.] Making the best of suboptimal situations in ways the legal and medical systems disapprove of has been a critical survival tool for me.

I try to strike a balance between practical applicability and scientific robustness. My core assumptions, my reasons for believing each, and my confidence in them are laid out in @sec:assumptions.

The strength and novelty of this book lie in the synthesis of multiple theoretical frameworks for describing MDMA therapy, namely memory reconsolidation, predictive processing, complex systems, and the defense cascade model of autonomic threat response. The book is also valuable as a comprehensive review and guide to most aspects of MDMA therapy that are accessible to solo users, clients, and practitioners. I'm not aware of any other work that rigorously covers the same territory. Its mechanistic, science-based approach will appeal to readers uninterested in the New Age and shamanic beliefs that pervade psychedelic spaces. It also avoids the neurobabble#footnote[_babble_ is a term for explanations that are superficially scientific but actually poorly supported, like polyvagal theory~@luckPolyvagal. Babble often serves the function of _illness myths_ that justify subjective suffering in a way that is congruent with a culture's beliefs about which illnesses are valid and which aren't.] endemic to popular and clinical discourse on mental health.

I think my recursive approach produced a higher-quality and better-grounded book than working from theory or personal experience alone would have. Personal experience informed theory, which then informed interpretation of personal experience, which further informed theory, and so on.

Finally, I would like to thank Jessica Sojorne Libere for MDMA therapy guidance; the scientists and therapists who developed this body of knowledge and practice; my partner for encouragement, support, and editing; #link("https://www.reddit.com/r/mdmatherapy") for numerous case examples and feedback; the researchers who answered my questions; one primary care physician for feedback on @sec:safety\; the Claude LLM for a few tasks listed below; and several users on #link("https://www.dharmaoverground.org") for feedback on @selfinsight. Thomas Harper provided early feedback on many sections.

May this work benefit all beings.

Mark

#lead[AI disclosure]
I wrote all the content in this book except for the minor instances described in the last two bullets. Either I or the authors I cite originated almost all the ideas, including all of the major ones. I used the Claude LLM for
- pointing out issues with flow, logic, and grammar in my writing. Example prompts: "Point out the issues with this section," or "I feel like something is off about this section, but I can't quite put my finger on it. Thoughts?" _used extensively_ 
- double-checking that my sources actually back up my claims. See details in @methodology. _extensive_
- rephrasing a sentence for readability when I agreed with its proposal. _occasional_
- summarizing papers to help me decide whether they are worth reading myself. Example: "Give me a long summary of this paper. \[attachment\]" _occasional_
- clarifying aspects of papers that I don't understand. Example: "Help me understand why the authors think that indicator x is a good measure of y. \[attachment\]" _occasional_
- text querying. Example: "I forget, does this paper mention the specific type of vitamin E they used? \[attachment\]" _occasional_
- identifying sources for further reading. Example using the research feature: "Survey the literature on 'resourcing' in therapy and whether it improves outcomes." _occasional_
- rewriting a list of simple clauses from one form to another. _once, in @mssProbes where the AI use is noted_
- quantity estimation. _once, in @frequency, where the AI use and an uncertainty disclaimer are prominently noted_

I checked LLM responses against original sources as a rule, though I think I forgot a few times.

#lead[Biases, conflicts of interest, and background:]
- _Attachments and beliefs:_ mildly disorganized attachment to MDMA therapy
- _Score on the quiz #prosecite(<cultistQuiz>):_ 13/40 (not at all a cultist)
- _Relevant experience:_ I used MDMA therapy to successfully treat part of my own severely disorganized attachment and the stuck schemas created by childhood sexual abuse. I started with 3 practitioner-guided sessions, then did 27 solo sessions. I have done \~#reconsolidation-hours hours of memory reconsolidation, mostly using the technique I report in @internalizedReports. There were many ups and downs throughout the process. My education was a bachelor's degree in aerospace engineering.
- _Conflicts of interest:_ I have no financial stake other than one \$500 unsolicited donation to the project from a friend unaffiliated with the psychedelic field.

#show: mainmatter

#heading(level: 1, numbering: none)[Summary] <summary>
// BEGIN_PLAIN_SUMMARY

MDMA facilitates extraordinary feelings of compassion, connection, and safety. (Positive emotions may not be noticeable during the session if strong negative emotions or dissociation are also present. This isn't necessarily an issue; the process can still work well in these instances.) This state of mind is highly effective for processing difficult or unhelpful emotions, memories, and reactions. However, there are no quick fixes for all but the simplest issues. Even in optimal conditions, intensive MDMA therapy can take years to heal the most severe mental illnesses.

There is moderate-quality clinical trial evidence that a limited course of MDMA therapy is highly effective for durably resolving PTSD, not just managing its symptoms. However, I think there are good theoretical reasons to believe, and ample anecdotal reports indicate, that MDMA therapy can also resolve the psychological part of most mental illnesses and emotional issues. This includes CPTSD, non-secure attachment (which 41% of the US population has~@mickelson1997adult), anxiety, addiction, alexithymia, obsessions, eating disorders, ADHD, depression, somatic symptom disorders, personality disorders, dissociation, panic, and more. Some instances of these issues may have biological components that MDMA therapy does not address.

More broadly, MDMA therapy is a powerful tool for
- healing mental illness
- connecting with yourself, those you love, and the world
- resolving conflict
- developing equanimity, patience, compassion, introspection, resilience, alignment of behavior with goals, and cognitive and emotional flexibility
- unburdening from hypervigilance, fear, chronic stress, loneliness, shame, guilt, etc.
- focusing on what you can change and letting go of the things you can't

Many self-reports of successful MDMA therapy can be found at #link("https://reddit.com/r/mdmatherapy/top/?sort=top&t=all"). The top posts mostly describe productive sessions that don't contain intense dissociation, avoidance, resistance, or symptom worsening. You can see occasional descriptions of less productive or more disruptive sessions by sorting by _new._ In #textcite(<godes2023perceived>), therapy clients described how they felt MDMA therapy worked during their sessions: staying with what "is"\; decreased reactivity; insight, reflection, linking; mental clarity; recovery of traumatic \[episodic\] memories; disentangling trauma from self; reuniting lost affects and parts; self-acceptance; joy, happiness, gratitude; hope and empowerment; relaxation, calmness, peace; comfort; gratitude, compassion, empathy; union, wider perspective; inner healing intelligence \[the therapeutic framework used in this study\]; accessibility to emotions; and mind-body connection.

As of 2026, MDMA has not been approved by most medical regulators. There is disagreement over whether existing clinical trials were sufficient to approve MDMA for medical use~#mdcite(<fdaVSdutch>). The US FDA thought the existing evidence was insufficient and requested one more trial~#mdcite(<crlAlpha>), but the Dutch State Commission on MDMA determined that "Scientific research has shown that MDMA therapy is an effective and safe treatment method. … The State Commission deems it desirable that this treatment method becomes available in the Netherlands as soon as possible~@netherlandsMDMA[p. 203]." Possession of MDMA is a felony in many jurisdictions, though it often isn't an enforcement priority. The vast majority of MDMA therapy in 2026 is underground, though there are a few clinical trials and special access programs in certain countries.

#heading(level: 2, numbering: none, outlined: false)[How Trauma and Insecurity Affect Us]
Our brains continually create internal models to move through the world and thrive~#mdcite(<eckerUnlocking>). These models create our thoughts and beliefs (e.g., "I can't do anything right," "I am bad"), emotional reactions, and behavioral patterns. Different therapeutic frameworks call these models schemas, parts, priors, and so on. Sometimes, the schemas we learn early in life are not very accurate, especially outside the schema's original context. This often starts in situations of emotional or physical insecurity or trauma, where we learn particularly deep, pervasive, negative, and durable schemas about ourselves, other people, and relationships. For instance, we might learn "I will die if I express vulnerability" in childhood. That might have been accurate in that context, but as an adult it causes problems because the brain learned an over-generalized principle rather than a more nuanced schema such as "I will die if I express vulnerability to my parents while I am young."

Schemas of imminent threat and powerlessness also cause our nervous systems to activate the defensive states of arousal, flight-or-fight, freeze, and tonic/collapsed immobility~#mdcite(<kozlowskaDefenseCascade>). The last of these is one type of dissociation.

Our brains have an updating process called memory#footnote[In this case, memory refers to implicit memory, not explicit memory of events and facts~@eckerUnlocking. Implicit memory is our often unconscious model of the world and self.] reconsolidation that in normal circumstances modifies schemas to accurately represent different situations~#mdcite(<eckerUnlocking>). Unfortunately, avoidance (often unnoticed or unconscious) and possibly other processes can inhibit updating~#mdcite(<berghBSTS>).

#heading(level: 2, numbering: none, outlined: false)[How MDMA Therapy Works]
MDMA starts the blocked update process for any stuck schema you activate or trigger during the session and then stay present with. Staying present means focusing on it and allowing it to be felt in the body and mind without acting to end, alter, escape, or explain it away. It can also include _investigative feeling,_ feeling how the experience changes as you move, as your thoughts and triggers change, or as the schema reconsolidates. Thinking, writing, or talking about your issue is often sufficient to activate updating during a session. After the schema updates, it will not reactivate after the session is over, though complex schemas have numerous parts that you must update individually. Dissociation and flight-or-fight also resolve once you update the underlying schemas.

This is a powerful process but is not a quick fix unless your issues are simple. People typically need to do a lot of between-session therapy and multiple MDMA sessions. Resolving the most severe issues will take years of hard work.

Temporary symptom worsening is likely the most significant downside. It is a common and probably often unavoidable phase of therapy for those with severe trauma. Unfortunately, people are sometimes not explicitly aware they have gone through severe trauma. This may happen if the abuse didn't involve any dramatic events, it was explained away as cultural tradition, it happened during the period of childhood amnesia, or it's not remembered for another reason. A diagnosis of mental illness indicates higher risk as well.

_Symptom worsening is occasionally prolonged and overwhelming, especially when poorly managed._ It may also, on rare occasions, exacerbate or activate dangerous symptoms like psychosis or suicidality. In #textcite(<robinson2024coming>), people with prolonged post-psychedelic symptoms reported the following activities as helpful, in order of most to least commonly reported: peers and community support; professional therapeutic or coaching assistance; meditation and prayer; reading for self-education; physical exercise; journaling; breathing strategies; embodied contemplative practices; time in nature; and acceptance and surrender#footnote[I excluded those reported by fewer than 10% of participants so that the items would represent something of a consensus.].

MDMA therapy tends to speed up both healing and symptom worsening. Additional MDMA sessions and regular therapy often help work through symptom worsening.

Symptom worsening is sometimes caused by experiences that feel like remembering forgotten events. There is no way to determine how accurate these memories are other than independent corroboration. See #link("https://psychedelicsandrecoveredmemories.com") for more information.

#heading(level: 2, numbering: none, outlined: false)[The MDMA Therapy Session]
A standard, safe dose is 100\u{202F}mg for body masses less than 60\u{202F}kg (132\u{202F}lb) and 125\u{202F}mg for those heavier~#mdcite(<liechtiInteractions>, <baggottSupplements>). People over 75~years old also start with 100\u{202F}mg. These doses can be adjusted if the standard dose doesn't work for you. Low doses generally don't work, and too high a dose might be so blissful that you can't engage with your stuck schemas.

Booster doses at half the strength of the initial dose are sometimes taken 1.5--2.5~hours later to lengthen the session. Boosters worked well in large clinical trials with no obvious or reported adverse effects. However, there is less certainty that these higher total doses are safe for more than a handful of sessions~#mdcite(<baggottSupplements>). Booster doses might be fine at first, but once you have established a reliably therapeutic routine, *gradually reduce the amount of MDMA you take to find your minimum effective dose.*

The main activity is emotionally engaging with your issues. This often happens naturally when you just take MDMA and let yourself feel whatever comes up without trying to control the experience. If not much is happening or you're spending your time thinking, try deliberately activating (triggering) your anxieties, depression, panic, etc., then staying with that feeling, whatever it is. If you have the right dose of MDMA and aren't dissociating, those feelings should gradually dissipate as the schemas that create them update. If you don't have a clear idea of your issues, pre-session journaling or therapy might help.

If you're dissociating, #textcite(<razviPSIP>, supplement: [p. 14]) recommends "bringing blankness, flat affect, nothingness, boredom, sleepiness, or sobriety \[the subjective feelings of dissociation\] into focus." Then, "it might take staying with it from minutes to a full day-long session, but it will crack." A skilled practitioner may be especially helpful here.

Post-session journaling, therapy, nature walks, and other introspective activities might help you further process your feelings.

It's common to experience moderately increased psychological turmoil for days to weeks after a session. MDMA helps us confront distressing feelings that we have been avoiding, and our minds can feel anxiety about that until we process those feelings and reactions. It's often worth developing a set of healthy coping practices to help you through this period. Lingering effects of the MDMA itself and a therapy hangover can also last a few days.

The Fireside Project offers a hotline to help people through challenging psychedelic experiences at #link("tel:+1 (623) 473-7433") in the USA. #link("https://tripsit.me/webchat") is a chatroom available anywhere.

There is almost no data on how frequently sessions can safely be done, though there are many strong opinions on the subject. The 4~week spacing used in the clinical trials might be a reasonable minimum in the absence of better data.

#heading(level: 2, numbering: none, outlined: false)[Working with a Mental Health Practitioner]
<practitioner>
It's helpful to start MDMA therapy with a practitioner, at least to learn the basics. Some people have success starting off solo, but it can be more difficult and riskier. A trip sitter who is trusted, experienced, empathetic, and emotionally non-reactive can also help.

There are a few important factors when working with a guide, therapist, or other mental health practitioner:
- *Ethical:* They should inform you of the benefits and risks and maintain strict professional boundaries. Occasionally, practitioners abuse their clients. Be extra cautious if you feel something is off or you notice any red flags. Touch and expressions of love from the therapist are not essential components of MDMA therapy. You can video record your session or bring a trusted friend or family member along for additional comfort. For more information on red flags, see #link("https://docs.google.com/document/d/1lK2Rif24BAmJqqsLfUSkAVCO48IFNrGdysS2nI1EjZA")[Psychedelic Safety Flags].
- *Skilled:* They should have thorough knowledge of, and experience successfully resolving, a wide spectrum of difficult situations that might arise during MDMA therapy. This especially includes intense dissociation, avoidance, panic, and symptom worsening.
- *Well-matched:* You should have a good relationship. You can use the #link("https://greenspacehealth.com/en-us/br-wai")[Brief Revised Working Alliance Inventory] to assess your relationship with your practitioner.

#heading(level: 2, numbering: none, outlined: false)[Medical, Psychological, and Drug Interaction Risks]
A limited course of MDMA therapy is generally well tolerated, but there are dangerous drug/supplement/herb interactions, medical contraindications, side effects, and psychological risks (some of these are best guesses based on sparse evidence):

#lead[Always avoid (significant risk of death or irreversible damage):]
- MAOIs and ayahuasca
- ritonavir, cobicistat, or HIV drugs that contain them
- over 200 lifetime doses (boosters count as partial extra doses)
- hyperthyroidism that is neither well managed nor mild, as assessed by a doctor~@mitchellMDMAClinicalTrial2

#lead[Use caution with:]
- a family or personal history of psychosis
- a personal history of addiction to amphetamines or cocaine
- a total dose over 2\u{202F}mg/kg per session, especially for more than a handful of sessions
- session spacing of less than 4~weeks
- drugs/medications/supplements/herbs, including large doses of caffeine
- liver and cardiovascular problems
- other serious medical conditions, especially ones that are neither well managed nor mild, as assessed by a doctor~@mitchellMDMAClinicalTrial2

#lead[Take precautions:]
- Don't drink more than 0.5\u{202F}L of water during the first six hours of a single-dose session unless you need to replace large amounts of sweat~#mdcite(<myBook>). Booster doses probably extend this period.
- Ideally, avoid SSRIs and SNRIs for 2~months prior to the session.
- Test your MDMA. The presence of some common adulterants can be checked with reagent test kits; #link("https://www.reddit.com/r/ReagentTesting/wiki/test_kit_suppliers") maintains a list of suppliers. Laboratory testing is much better; #link("https://www.reddit.com/r/ReagentTesting/wiki/labs") maintains a list of labs. Labs can measure the amount of MDMA and other ingredients.
- People with a personal history of mania should take care to sleep well before and after the session; sleep aids can help with this. They should also skip booster doses at first, then gradually increase the total dose on subsequent sessions if needed.
- Only start MDMA therapy if you have slack in your life and can do a lot more therapy, MDMA-facilitated or otherwise, in the near future. On rare occasions, post-session symptom exacerbation can be severe. While it can be a part of the healing process when managed well, exacerbation can require a lot of therapy to resolve, and it may not resolve as quickly as you want.

  An exception may be people with secure attachment and no mental illness, who I think have very little chance of severe exacerbation.
- MDMA and therapy exhaustion can impair awareness and reaction times. Avoid driving and other risky activities on the same day as the session.

#mdonly[
Written by Mark Groeneveld (u/night81) based on a draft of their book #link("https://www.doi.org/10.31234/osf.io/aps5g")[_Open MDMA: An Evidence-Based Synthesis, Theory, and Manual for MDMA Therapy Based on Memory Reconsolidation, Complex Systems, and the Defense Cascade_] and feedback from /r/mdmatherapy.

Please comment or DM if you spot any errors or have any suggestions!

This work is licensed under #link("https://creativecommons.org/licenses/by/4.0/")[CC BY 4.0].
]

// END_PLAIN_SUMMARY

= Introduction
<introduction>
== How to Read This Book
<essentials>
This book addresses a broad audience but is aimed at a client or solo user, since that is my background. Mental health practitioners will benefit from reading the entire book, along with the supplementary material written for them in @practitionerSkills.

I aim to provide most of the "full stack" of knowledge needed to successfully use MDMA therapy, though I don't include much about the fundamentals of being a good mental health practitioner. Aspiring practitioners can't rely on this book alone to learn how to be MDMA therapy guides. This book contains a mix of theory, checklists, instructions, and tools. Simple instructions work well in some areas, but MDMA therapy's complexity means such instructions don't cover every aspect of the process. The theory is included so that you can adapt the tools to your own unique situation.

The book is lengthy and somewhat technical. I prioritized rigor over accessibility because there is little consensus on many of the topics explored here. Showing my work is important to back up my claims. Feel free to skip or skim non-critical sections. I think the most important sections are:
- *Basic theory:* #combinedref(<sec:defensecascade>), #combinedref(<sec:trauma>), #combinedref(<sec:mechanism>), and #combinedref(<mdmaUpdate>)
- *Safety:* #combinedref(<professionalVSSelf>) and the initial lists in #combinedref(<sec:safety>)
- *Practice:* #combinedref(<sec:dosing>), #combinedref(<prep>), #combinedref(<sec:sessionbarriers>), #combinedref(<session>), and #combinedref(<sec:troubleshooting>)

At a bare minimum, read #combinedref(<summary>) and #combinedref(<session>).

The book is structured for front-to-back reading, but is also designed as a reference. Sections extensively cross-reference each other to facilitate browsing. In the PDF version, many terms are colored red, and clicking them takes you to the relevant glossary definition.#footnote[I used a script to automatically link the first occurrences of glossary terms in each section to the glossary. This process may have resulted in an occasional inappropriately linked term.] The #link(<sec:glossary>)[glossary] is after the appendices, just before the bibliography. I use some terms differently from other authors, and the glossary describes my choices.

For help understanding the book, you can also upload it to the Claude LLM (large language model) and ask it to explain the book to you. It can also respond in your language of choice. Paste in the following text as your first message. Then ask your question in a second message. I don't recommend other LLMs, as they had unacceptable levels of hallucination in my tests.

#quote(block: true)[
\<\<SESSION PROMPT: Read the entirety of the first #context locate(<end>).page() pages#footnote[The page range instruction excludes the glossary, appendices, and bibliography. Reducing the file size improves LLM output quality and gives you more responses before hitting usage limits.] into your context window before replying. You should helpfully answer the user's questions about MDMA therapy based on the attached document. The user may not understand the technical content of the book, so you should make it easier to understand when appropriate. Don't add external medical advice or conventional wisdom that might contradict the document's framework.#footnote[I added the warning against conventional wisdom because without it Claude would constantly mix in poor-quality information it picked up from the internet and mainstream mental health resources that don't have the slightest clue how MDMA therapy works. I don't want to discourage you from using other high-quality resources.] The document has specific views on what's normal versus concerning in MDMA therapy that may differ from conventional medical perspectives. Don't say "the document says/recommends/presents"\; that is assumed.\>\>
]

== Approach Mental Health Research and Practice With Skepticism
<howtoevaluate>
Robust scientific models are, as the science bloggers #textcite(<mechanisticModels>) argue, "a proposal for a set of entities, their features, and the rules by which they interact, that gives rise to the phenomena we observe." They also make a wide variety of accurate predictions in their domain. Physics exemplifies this standard; it has such a complete model of atoms that their behavior can be predicted to many decimal places of precision. It also has a highly detailed and precise list of the particles and forces involved and the rules by which they interact. Few fields can match that level of completeness. Psychological models don't have convincing lists of well-defined parts and mechanisms, and generally lack plausible connection to what cells are doing in the brain. The political scientist #citefullauthor(<zombieSocialScience>) argues on their blog that the social sciences, including psychology, mostly use models that occasionally make good predictions in a narrow area but rarely over a wide area~@zombieSocialScience (see also #textcite(<evidenceBasedPolicy>)).

Working with these ungrounded abstractions may help researchers figure out the set of mechanistic rules that govern a particular system. Many of these abstractions turn out to be false or meaningless. That's okay in the process of science, but these provisional models have taken on a great deal of undeserved prominence in popular culture and clinical practice. These problems aren't limited to the social sciences either. The neuroscientist #citefullauthor(<hoelNeuroscience>) synthesizes papers on their blog to argue that even neuroscience is beset by severe systemic issues~@hoelNeuroscience.

These issues show up in various ways in mental health science and practice:
- Mental illness is diagnosed according to semi-arbitrary clusters of subjectively assessed (either by the client or the clinician) symptoms. It is not objectively measurable or attributable to specific, well-understood causes.
- The current categorization of mental illnesses is significantly incorrect~@kotov2017hierarchical. The Hierarchical Taxonomy of Psychopathology (HiTOP) offers better clustering than the DSM or ICD. However, it still doesn't explain what mental illness is.
- Mechanisms of action for psychiatric drugs are typically known only as far as drug → partially understood effects on neurotransmitters → unknown intermediate processes → changes in behavior/mood/etc. that are imprecisely recorded in questionnaires. It is often tempting to say a drug works because of its _known effects on neurotransmitters_ when the _unknown intermediate processes_ may be just as important.

  Imprecise questionnaires, which persist partly because we don't understand the intermediate processes, may measure the wrong thing or miss major relevant effects. The drug may superficially improve some symptoms while creating other, harder-to-see problems.
- The long-term efficacy of psychiatric drugs is poorly studied~@leuchtDecline. For instance, it is not widely known that long-term use of SSRIs often causes (occasionally severe) dependence~@crossingZero.
- Neuroimaging studies are a minefield of poor statistical methods, low statistical power, and mistaken inferences of causation~@hoelNeuroscience. Another issue is that some psychedelics change the coupling between brain activity and blood flow (the thing that fMRI measures), though it's not clear if MDMA has that effect~@padawerNeurovascularCoupling. fMRI has provided little meaningful information about any specific mental illness~@etkin2019reckoning.
- The replication crisis revealed major issues with clinical psychology methodology~@therapyReplicationCrisis. Many papers and experiments use poor statistical methods and inadequate sample sizes and can't be reproduced.

I am not implying that all psychiatric drugs are useless or that therapy doesn't work. Instead, I aim to calibrate expectations. Approach any model of brain function or mental health with considerable caution unless its components have been experimentally verified by multiple labs and it mechanistically explains a wide range of phenomena. Exceedingly few models of mental illness meet those criteria. That includes almost everything from psychology and psychiatry, much of neuroscience---and many parts of this book. Where my framework relies on memory reconsolidation, predictive processing, complex systems, and defense cascade models, it inherits whatever mechanistic grounding those models have---which is more than most alternatives, but less than I would like.

== Methodology
<methodology>
I wrote this book by synthesizing information from three categories of sources. First were papers, books, and blogs on the topic. Second was my own experience using MDMA therapy to treat my complex trauma. Third was trip reports (largely from #link("https://www.reddit.com/r/mdmatherapy")) and discussions with people who have done MDMA therapy, henceforth called anecdotal reports. Personal experience and discussions informed theory, which then informed interpretation of personal experience, which then further informed theory, etc. This loop continued until I didn't notice any obvious inconsistencies.

Throughout the book, I distinguish between more established science and educated guesswork by marking opinions as "I think," "I believe," etc. Of course, I'm also making judgments about what is established science.

=== Reference Validity Checks
<reference-validity-checks>
I applied these checks on the validity of my references while writing this book:
- *Retractions and PubPeer comments:* _All references._#footnote[I still cite the retracted studies #textcite(<feducciaSSRIDiscontinuation>) and #textcite(<mithoeferRETRACTEDARTICLEMDMAassisted2019>). The journal claims they were retracted for three reasons~@feduccia2024retraction@nytimesRetraction. The first was that the authors did not remove one participant's data from the dataset despite one of the therapists having sexually abused the participant. The second was that the authors did not inform the journal of the abuse. The third reason appears to be that the authors listed their conflicts of interest under the Funding section instead of a dedicated Conflicts of Interest section.

  I still cite the paper because removing one data point out of 50 would not significantly affect the results, and the third issue is a quibble. I don't know the significance of the second. The retraction was also part of a highly public set of events reported by #textcite(<nytPsymposia>). It's unclear why the paper was retracted instead of corrected.]
- *Reproduction of experimental results by other labs:* _No systematic evaluation,_ though I strongly preferred to cite review articles, which often do this. I changed the book when I happened across published replication failures.
- *Informal qualitative analysis of experimental design:* _Most references._ I preferred papers that randomized their participants, had large numbers of participants, controlled for certain confounding variables important in MDMA and therapy research, were recent, were reviews or meta-analyses, had good statistical power, and had high citation counts. Not all references meet high standards for these criteria. I may still have included them if they were, in my judgment, particularly theoretically compelling or reasonable extrapolations of more established results. There are many quality indicators that I did not check but that are often important, such as topic-specific study design nuances outside my area of knowledge, statistical methods, data processing methods, publication bias, researcher bias, etc. However, the meta-analyses I cite frequently do assess some of these indicators.
- *Contradictory evidence:* _The vast majority of papers._ Using #link("https://scite.ai") in August 2026, I read the large majority of the _contrasting_ blurbs from papers that cite my references. Additionally, for the core assumptions listed in @sec:assumptions, I made a more substantial, though non-systematic, effort to find evidence that contradicts these assumptions.

=== Major Unresolved Issues
<major-unresolved-issues>
Any pharmaceutical or therapeutic intervention relies on a multitude of choices that have not been rigorously studied. In this case they might include questions like 1.6\u{202F}mg/kg vs. 1.4\u{202F}mg/kg of MDMA; non-directive vs. minimally directive therapy; and which type of therapist training is best. Any manual or practice, including mine, thus inherently depends on a lot of educated guesswork to fill in the gaps between the main support beams of validated theory and practice. Beyond that general caveat, these uncertainties are particularly important to flag:
- As discussed in @ppHypotheses, I don't know how MDMA facilitates reconsolidation.
- Symptom worsening seems associated with severe complex trauma or severe attachment issues, but besides that, I don't know how to predict an individual's risk. It's also uncertain when more MDMA therapy will reduce or increase symptoms in the short term. See @sec:complex for more information.
- It's unclear whether certain severe treatment-emergent symptoms, like psychosis, are "it gets worse before it gets better" phases of trauma therapy.
- I don't know when or why MDMA therapy might not work for someone, apart from the somewhat-known factors of opioid dampening~@razviPSIP, intense avoidance, and recent use of SSRIs and SNRIs~@feducciaSSRIDiscontinuation. There may be unknown but necessary factors in addition to the right dose of MDMA, activation of a stuck schema, and non-avoidance.
- I can't explain the metaphorical closed-eye visuals and experiences that some people have.

=== Reasons to be Confident
<reasons-to-be-confident>
- As an independent scholar outside professional mental health, I am not subject to the financial, institutional, or cultural pressures typical in the field, nor financially invested in any of its dominant explanatory frameworks.
- I drew on an especially wide diversity of evidence: memory reconsolidation, complex systems, defense cascade, predictive processing, clinical therapy practice, personal experience, and the MDMA therapy user community.
- My experience using MDMA therapy (\~30 sessions) and memory reconsolidation (\~#reconsolidation-hours~hours) for complex trauma grounds this work in a way that would be impossible using only theory or clinical experience.
- The model is based on independently well-supported causal theories (memory reconsolidation, complex systems, and the defense cascade).
- I posted each major draft version for public critique on #link("www.reddit.com/r/mdmatherapy"). I used this feedback to make improvements.
- I used Claude Opus inside a #link("https://github.com/groeneveld/latex_claim_verifier")[custom harness] I made to double-check that my claims are supported by their citations. I ran this for almost every citation that I could easily download the text of, which was perhaps 80% of them. I also used the same LLM to double-check that entire sections follow from my primary, though not secondary, citations in @efficacy, @science, @sec:dosing, @frequency, @interactions, and @sec:grounding.

=== Reasons to be Skeptical
<reasons-to-be-skeptical>
I know of the following reasons to be skeptical of this book, while acknowledging that I could be missing the book's real weak points~@yudkowskiWeak.
- My integration of MDMA therapy, complex systems dynamics, memory reconsolidation, predictive processing, attention, and the defense cascade is a somewhat novel formalization of existing MDMA-therapy practices. Novel frameworks are usually incorrect to some degree even when their authors find them convincing. Reality is certainly more complex than my model, though I don't know by how much.
- I frequently rely on anecdotal reports and personal experience that might not reflect how MDMA therapy works for a wider range of people.
- Without formal education in any of the relevant topics, I may be missing nuances that are common knowledge in the fields I draw from.
- The MAPS clinical trials had some methodological flaws, though it's unclear how bad they were compared to drug trial norms~@crl. The MAPS trials were also subject to far more public scrutiny and drama than is normal~@nytPsymposia.
- I became an MDMA therapy enthusiast because it saved my life. This made skepticism more difficult and confirmation bias easier.
- My model has major gaps regarding the kind of mental illness I focus on, including why antidepressants, ketamine, and electric and magnetic brain stimulation help some people. It also doesn't obviously explain mania or psychosis.
- My experience guiding other people in MDMA therapy consists only of sitting twice for one friend.
- The fields of therapy and mental health reify numerous constructs of poor validity; I may have inadvertently included some.
- There is an explanatory gap for MDMA therapy. I think the causal chain is roughly: some known effects on neurotransmitters → unknown intermediate processes → apparent reconsolidation of any activated stuck schema that one stays present with.
- The current understanding of memory reconsolidation, predictive processing, the defense cascade, and mental illness as a complex system is incomplete.
- I have become attached to my model, making it more resistant to contradictory evidence.
- Some parts of my model are verbal and qualitative. They haven't been formally defined or demonstrated.

== Efficacy of MDMA Therapy
<efficacy>
MDMA therapy showed excellent results for PTSD in clinical trials~@mitchellMDMAClinicalTrial@mitchellMDMAClinicalTrial2. However, in 2024 the FDA requested another trial to fill in missing data before it could approve MDMA~@crl.#footnote[Resilient Pharmaceuticals completed a new study in 2026 and resubmitted its drug application~@resilientReapplication.] #textcite(<crlAlpha>) analyzes this request in detail. #textcite(<fdaVSdutch>) also discusses why the Dutch State Commission came to the opposite conclusion (@netherlandsMDMA) and decided there actually was enough evidence of efficacy and safety to roll out MDMA therapy to the public.#footnote[The Dutch State Commission maintained its position even after the FDA's request for more data~@dutchParliment.] While the FDA's requests are mostly helpful and would certainly result in better quality evidence, I agree with the Dutch State Commission's overall assessment. I also lay out additional reasons I think MDMA therapy is effective in the third bullet point of the Memory-Reconsolidation/Predictive-Processing section of @sec:assumptions.

#textcite(<icerReport>) pooled both MAPS phase III MDMA therapy trials (194 total participants) and calculated the average effect sizes#footnote[The effect size was measured as Cohen's d.] of three sessions of MDMA with therapy compared to placebo with therapy, though these calculations don't include some potential systematic biases. The 95% confidence intervals for the effect sizes were between 0.49 and 1.1 (small--large) for PTSD symptoms, with the most likely value being 0.80 (large), and between 0.17 and 0.66 (very small--medium) for functional impairment, with the most likely value being 0.42 (medium).#footnote[Confidence intervals convey the statistical precision of studies. Roughly speaking, there is a 95% chance that the true average effect is within that range.] The actual effects were likely larger, since those numbers only compare the difference between MDMA and placebo. Both arms of the experiment involved therapy that likely had its own positive effect, not to mention the benefits many people get from the placebo effect. Individuals will also have a range of responses around that average. The average is itself specific to the population of participants in each study and the characteristics of the study.

The greater effect on PTSD symptoms than on functional impairment may reflect the fact that most participants had multiple traumas or mental illnesses~@mitchellMDMAClinicalTrial@mitchellMDMAClinicalTrial2. PTSD symptoms were measured using the Clinician-Administered PTSD Scale for DSM-5 (CAPS-5), which measures symptoms related to a single traumatic event that the participants focused on during therapy. @table:efficacy breaks the CAPS-5 results into labeled, clinically relevant bins. Functional impairment was measured using the Sheehan Disability Scale (SDS), which may better represent the entirety of an individual's issues. More therapy focused on the other issues would presumably further decrease functional impairment.

#figure(
  table(
    columns: 3,
    align: center + horizon,
    table.header([], [*MDMA w/ \ Therapy*], [*Placebo w/ \ Therapy*]),
    [*No Response*], [13 %], [31 %],
    [*Clinically Meaningful Response*], [87 %], [65 %],
    [*Loss of Diagnosis*], [69 %], [40 %],
    [*Remission*], [40 %], [13 %],
  )
  , caption: [Mean outcomes from the first and second phase III clinical trials derived by averaging Fig. 3 in #textcite(<mitchellMDMAClinicalTrial>) and Fig. 3 in #textcite(<mitchellMDMAClinicalTrial2>). _Clinically meaningful response,_ _loss of diagnosis,_ and _remission_ are labels applied to escalating degrees of improvement.]
  , kind: table
  )
<table:efficacy>

Each session added durable benefits~@mitchellMDMAClinicalTrial@mitchellMDMAClinicalTrial2. The benefits persisted at least to the end of the study, which was two months after the last session. Preliminary evidence additionally shows that the improvements persist for longer~@mplongPreliminary@monashMDMA. This strongly suggests that more sessions beyond the three in the trials would further improve symptoms for individuals who need them. The three-session schedule was likely chosen to balance efficacy with cost and time constraints in the drug development process, and clinical use should be tailored to individual needs.

Only 5% of participants in the MDMA groups discontinued treatment (mostly for reasons unrelated to adverse effects from MDMA therapy), compared to 16% in the placebo groups~@mitchellMDMAClinicalTrial@mitchellMDMAClinicalTrial2. MDMA therapy worked across levels of symptom severity and presence of other mental illnesses.

There are differences between MDMA therapy in clinical practice and in clinical trials that may affect efficacy:
- Different expectations of positive results from the client or practitioner
- Better or worse therapist adherence to professional ethics
- Doses tailored to a client's body mass, an option not available in the trials~@mitchellMDMAClinicalTrial@mitchellMDMAClinicalTrial2
- Therapists with more or less experience with MDMA or more or less skill as a therapist
- More choice in therapist
- Different client characteristics
- More or less support
- Session pacing and number of sessions tailored to the client's needs rather than the rigid structure of the trial
- Less media attention than the trials received
- Clinical sessions usually aren't video recorded, whereas trial sessions are

== MDMA Therapy Generalizes Beyond PTSD
<biopsychosocial>
MDMA therapy has historically been used for a wide variety of conditions, not just PTSD~@passieHistory. A limited course of MDMA therapy may also be effective for durably improving
- anxiety (2 randomized controlled trials (RCTs), total participants (N) = 30, 95% CI for effect size = 0.3--2 (small--huge))~@højlundGRADE
- alexithymia (1 RCT, N = 25, results were strong and statistically precise but weren't reported as effect sizes)~@vanSelfExperience
- low self-compassion (1 RCT, N = 24, results were strong and statistically precise but weren't reported as effect sizes)~@vanSelfExperience
- depression, phobias, alexithymia, and PTSD (early underground use; a 1984 survey by the Association for the Responsible Use of Psychedelic Agents of 16 therapists "who have either worked with MDMA or are well acquainted with its therapeutic use through colleagues' research," as reported by Passie)~@passieHistory[ch. "Early Use in Psychotherapy: A Survey of MDMA Therapists"]
- depression, PTSD, and anxiety (current clinical use in Switzerland)~@liechtiSwitzerland

These findings raise the question of why MDMA therapy might work across these conditions. The prevailing understanding of mental illness is the biopsychosocial model~@engel1977need. It describes how most mental illnesses arise through complex interactions between biology (e.g., genetics, medical history, defense cascade activation, sleep quality), psychology (e.g., schemas, attention, emotions, thoughts), and social context (e.g., social models of how to respond to trauma, support networks, and living and work situations). However, it doesn't actually say anything about how these factors interact, how much each element contributes to a given mental illness, or how to categorize mental illnesses.

Three lines of reasoning suggest MDMA therapy durably resolves the psychological component of many mental illnesses. The first, as detailed above, is its apparent broad applicability in clinical trials and historical practice.

The second is based on the HiTOP (Hierarchical Taxonomy of Psychopathology) model, a leading model of mental illness classification. It was built from the ground up on statistical associations between symptoms and organizes them in a hierarchy of clusters~@kotov2017hierarchical. At the subfactor level, the symptoms associated with PTSD, major depressive disorder, dysthymia, borderline personality disorder, and generalized anxiety disorder are clustered together. This suggests that those disorders are varying presentations of the same phenomenon. At higher levels of the hierarchy, even more symptoms and associated disorders cluster together. If the clustering reflects shared underlying processes rather than coincidental symptom overlap, then the evidence for MDMA therapy for PTSD should generalize to the other clustered disorders.

The third is that #textcite(<eckerUnlocking>) describes how psychosocial factors cause many mental illnesses and how psychotherapy can durably resolve these illnesses through the single psychological mechanism of memory reconsolidation. @sec:assumptions argues that MDMA therapy also facilitates memory reconsolidation when a stuck schema is activated and a person stays present with it.

I think that the psychological component is substantial for most mental illnesses, and no evidence rules out this assessment. Vanishingly few biomarkers have been established as significant causes of mental illness rather than as symptoms or unclear associations~@carvalhoBiomarker. Genetics increases the risk of mental illness, but in my reading of #textcite(<aftabGenetics>), #textcite(<alexanderHeritability1>), and #textcite(<alexanderHeritability2>), even high heritability doesn't establish that genes are the primary or only cause in any individual case. Heritability describes how much of the variation between people can be attributed to genetic differences in a given environment and population---it doesn't tell you how much genes versus environment shaped any particular person's illness. Psychosocial factors may still play large roles.

In the face of this uncertainty and the likely importance of psychological components, I think it's worth trying MDMA therapy to see if it works. As discussed in @sec:safety, it is safe for most people. MDMA therapy is likely not worth trying for disorders with established biological causes, like thyroid dysfunction, neurosyphilis, and anti-NMDA receptor encephalitis.

= Theoretical Model
<science>
== The Defense Cascade
<sec:defensecascade>
The sympathetic and parasympathetic nervous systems govern a wide variety of involuntary bodily functions, such as heart rate and digestion~@kozlowskaDefenseCascade. In one of their roles, they activate a defense cascade, a sequence of responses that protects us from threats. Increasing levels of perceived threat, threat imminence, powerlessness, and somatic sensory input (e.g., needle pokes) activate these responses, though the order of activation also depends on individual variability and past experience.

Assessments of threat and power are relative to your ability to deal with the situation; children activate easily because the threshold at which a threat becomes life-threatening is much lower for them than it is for securely attached adults. Lack of parental support, attention, or attunement (see #textcite(<fivePillars>)) can be a life-threatening situation for children. Here is the defense cascade:#footnote[I use the taxonomy of #textcite(<kozlowskaDefenseCascade>). Other sources categorize the states differently, but the general pattern of an active, sympathetic state; a passive, parasympathetic state; and a mixed state is similar.]

/ Arousal:
  The most common initial reaction to a potential threat. Think of how a deer becomes alert when they see something moving far away. Vigilance, muscle tension, respiratory rate, and heart rate all increase, allowing us to quickly assess and respond to possible dangers.

/ Flight-or-Fight#footnote[I put _flight_ before _fight_, following the recommendation of #textcite(<kozlowskaDefenseCascade>), who states that flight is more common than fight.]:
  When an imminent danger is identified and there is a perceived chance of escape or winning the fight, this response prepares the body to immediately either escape or confront the threat. The adaptations of the arousal stage intensify and are augmented by an adrenaline surge, further suppression of pain (via endocannabinoids~@lanius2018review), and an urge to fight or run.

/ Freeze:
  When the danger is imminent but you might still go unnoticed, the freeze response temporarily pauses flight-or-fight. If the predator notices you, freezing can quickly revert to flight-or-fight. While most physiological responses from flight-or-fight remain, muscles are immobilized, though tone remains high, and heart rate may or may not decrease.

/ Tonic/Collapsed Immobility:
  Tonic immobility (playing dead) activates in situations of high imminent threat and high powerlessness, like when the predator has overpowered you. Flight-or-fight responses are deactivated, the body is partially or fully paralyzed, heart rate slows, and the brain produces opioids that numb and disconnect you from reality. Playing dead sometimes causes predators who prefer live prey to lose interest in you, creating an opportunity to escape.

  Tonic immobility transitions to collapsed immobility when your heart rate drops so much that your brain no longer has enough oxygen to stay conscious. It's unclear if this is an adaptive response or a physiological accident.

/ Quiescent Immobility:
  Tonic/collapsed immobility may extend into a lethargic rest and recuperation phase after the threat has passed. Occasionally, this may persist beyond its period of usefulness and become maladaptive.

The body can rapidly transition between these states as needed~@kozlowskaDefenseCascade.

The defense cascade activates during immediate physical attacks like a predator biting you, but it is also activated by stimuli (sounds, thoughts, sensations, places, etc.) associated with threats~@kozlowskaDefenseCascade. In the rest of the book I call these associations _schemas._ These associative activations are ideally adaptive; activation of flight-or-fight when you see a wolf running toward you will give you more time to run than if activation only occurs when the wolf bites you.

Unfortunately, associative activations can also be maladaptive~@kozlowskaDefenseCascade. Think of the soldier who goes into flight-or-fight in response to loud noises even after the war is over. Maladaptive defense cascade activation is implicated in many mental illnesses. As described in subsequent sections, MDMA therapy can unlearn maladaptive associations between stimuli and activation.

There is considerable uncertainty over which mental and physical states are mediated by endogenous (self-produced) opioids. Immobility and freeze may be the ones best characterized physiologically. However, other states, like some types of non-immobile derealization and depersonalization, are plausibly included. I call all opioid-mediated states _opioid dampening_ to mechanistically differentiate them from other phenomena. The term _dissociation_ is often used; it is an "involuntary disruption or discontinuity in the normal integration of one or more of the following: identity, sensations, perceptions, affects, thoughts, memories, control over bodily movements, or behaviour"~@icd11[sec. Dissociative disorders]. However, other phenomena, like deep avoidance and muting, also produce dissociation, making the term etiologically imprecise.

The complexity of opioid dampening may depend on which opioids (e.g., enkephalins, endorphins, and dynorphins) are interacting with which opioid receptors (μ, κ, δ, and their subtypes; conceivably also nociceptin and its subtypes)~@laniusNeurobiology. Other chemicals, like endocannabinoids, noradrenaline, and adrenaline, are also often present. Additionally, chronic immobility may induce opioid tolerance, which might further alter these effects.

One under-explored complexity is sedation. #textcite(<kozlowskaDefenseCascade>) doesn't list sedation as a possible symptom of immobility, but #textcite(<razviPSIP>) and anecdotal reports indicate that sleepiness or actually falling asleep are relatively common symptoms of a state on the parasympathetic side of the defense cascade. This can happen both with and without MDMA.

See #prosecite(<kozlowskaDefenseCascade>) for further discussion of the defense cascade. As the paper itself notes, the descriptive part is more solid than the Clinical Interventions section. I also advise caution regarding some proposed mechanisms of action because the paper cites polyvagal theory~@luckPolyvagal. While many people find therapeutic interventions associated with polyvagal theory helpful, the theory's foundation in specific neuroanatomical and evolutionary claims has not held up to empirical scrutiny.

Refer to @sec:signsofdc for a thorough comparison of the signs of hyperarousal (I think that means flight-or-flight or a mid-point between arousal and flight-or-flight), immobility, and probably also the schemas that activate them.

// Compact bullet list for the cell bodies.
#let items(..entries) = list(
  tight: true,
  indent: 0pt,
  body-indent: 0.4em,
  marker: [•],
  ..entries,
)

// A category row labels both columns (either may be empty) and repeats as a
// subheader, matching the group rows of the schema activation prompt table.
#let cat(hyper, dissoc) = table.header(
  level: 2,
  table.hline(stroke: 0.8pt),
  ..(hyper, dissoc).map(name => table.cell(inset: (top: 9pt, bottom: 5pt), if name != [] { strong(name) })),
)

// A category's lists stay on one page, like the prompt table's domains.
#figure(
  {
  set table.cell(breakable: false)
  table(
    columns: (1fr, 1fr),
    align: left + top,
    inset: (x: 6pt, y: 4.5pt),
    stroke: none,

    // Booktabs-ish rules plus the single vertical divider. Both repeat on
    // every page the table spills onto.
    table.hline(y: 0, stroke: 1pt),
    table.vline(x: 1, stroke: 0.5pt),

    // repeat: true is the default — this row reprints atop each new page.
    table.header([*Signs of Hyperarousal*], [*Signs of Dissociation*]),

    cat[Body/Somatic][Body/Somatic],
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
      [Fixed gaze ("thousand-yard stare"), glassy eyes],
    ),

    cat[Cognitive][Cognitive],
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

    cat[][Self],
    [],
    items(
      [Disconnected from body, emotions, thoughts],
      [Outside body or at distance],
      [Disownership],
      [Don't exist, not here],
    ),

    cat[Emotion][Emotion/Motivation],
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

    cat[Conative/Motivational][],
    items(
      [Excessive, obsessive striving/effort],
      [Scrupulosity/perfectionism],
      [Apathy/withdrawal],
    ),
    [],

    cat[Perception][Perception],
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

    cat[Social][Social + Occupational],
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
    cat[][Dissociation vs. Meditative Calm],
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
  )
  },
  caption: [Comparison of hyperarousal and dissociation \[opioid dampening\] signs. #textcite(<cheetahSigns>) compiled this from #textcite(<ogden2006sensorimotor>), #textcite(<magyari2016teaching>), and #textcite(<treleaven2018trauma>). Reprinted with permission. I think that these are the signs of hyperarousal, opioid dampening, and the schemas that activate those states, not just signs of hyperarousal and opioid dampening themselves.],
  kind: table,
)
<sec:signsofdc>

== Trauma, Insecurity, and Their Effects
<sec:trauma>
Our brains continually build mental models of the world, other people, our bodies, and our minds for the purpose of fulfilling our innate needs, like bodily integrity, social connection, and reproduction~@clark2015surfing. We typically model threats in an appropriate and unproblematic manner and don't fear or ruminate about falling off cliffs until we are near a cliff edge. The closer to the edge we go, the more alert and cautious we become. This alertness or fear is healthy because the response is situationally appropriate.

Not all responses are situationally appropriate~@eckerUnlocking. The brain's learning process doesn't necessarily build _true_ models of the world; it builds models (an individual model is called a _schema_) that are _true enough_ (a heuristic) to work mostly well in the contexts they develop in. These heuristics are sometimes inaccurate or don't work very well outside the context in which they form, like a soldier who goes into fight mode in response to loud noises even after the war is over. In some cases they might not even have worked well in the original context.

We can define trauma as events that create schemas that impair functioning or well-being either now or in the future. Standing near cliffs is not typically traumatic because the situation is under our control, and we manage it to stay safe. If nothing surprising or threatening occurs, our models of what happens around cliffs don't change much.

Conversely, threatening situations outside your control create strong signals for updating your models because your survival may depend on avoiding or managing that situation in the future. Maybe someone attacks you near the cliff edge and you almost fall off. You may learn that cliffs, the combination of cliffs and other people, or the combination of cliffs and just that particular person are much more dangerous than you previously thought. You may feel alert or afraid much farther away from the edge than you did before. If the attack was overwhelming enough, you may learn that everything about cliffs is dangerous, even the thought of them or pictures of them.#footnote[This description of trauma is a simplification of why something is traumatic for one person but not for another. The next section covers this topic more thoroughly.] I think "high caution around that particular person" or "that person is dangerous and unpredictable" is the adaptive schema in this scenario. Unfortunately, the other responses, such as fear at the thought of cliffs, sometimes occur and can cause problems for you or others.

I call these types of responses _stuck schemas_ throughout this book. I call them stuck because they are significantly inaccurate, cause difficulties for you and others, and resist updating to a more accurate form. _Maladaptive_ is another common term, but some people think it is invalidating~@eckerUnlocking. Learning a now-maladaptive schema might have been the best your brain could do at the time.

Children, because of their limited life experience, frequently learn inaccurate schemas about trauma and insecurity. For instance, if their parents emotionally neglect them, they might learn "I am unlovable" instead of the more accurate schema "My parents don't know how to parent" or "My parents are not capable of parenting." If a dog attacks them, they may learn "dogs are dangerous" instead of "big angry dogs are dangerous."

When activated, schemas can generate~@eckerUnlocking
- emotions like fear or anger
- thoughts like "no one loves me" or "I'm disgusting"
- behavioral impulses
- somatic sensations, like psychosomatic pain

These _symptoms_ are not the schema/model itself, just its outputs~@eckerUnlocking.#footnote[#metadata("anchor") <retrieval>Brains and mental models are complicated and poorly understood. However, therapy can help us gain a decent comprehension of how a particular schema developed, works, and influences us~@eckerUnlocking. In the example of Richard from #textcite(<eckerUnlocking>), he starts noticing fear and the thought "they hate me" when he thinks about confidently speaking up in meetings. Through therapy, he gains awareness of the structure of the schema, which takes the form of the verbalized thought "Having a feeling of confidence as you speak turns you into an arrogant asshole, like Dad." It's accompanied by a deep sense that the explanation is right. In my experience, MDMA also facilitates access to a verbalized structure of a schema, either immediately or after some reconsolidation.] Some symptoms may not be noticed or noticeable. For example, I've had many experiences in MDMA therapy where I notice the emotion first, and the belief only becomes clear after some amount of reconsolidation.

When schemas are stuck, these outputs become problems: stuck schemas push us to overreact, deny the truth, misjudge significant trade-offs, say hurtful things, etc. We may seek the connection and safety we desperately need in dysfunctional ways~@brownAttachmentDisturbances, or we may be too distracted by our distress to pay attention to the needs of those we love.

Here's another example of a schema that became stuck. As a young child, Amy was frequently ridiculed by her peers whenever she spoke up in class or shared her opinions. She then learned "my opinions are shameful," experienced fear at the thought of speaking up, and had a behavioral inhibition to speaking up. This schema creates Amy's behaviors and beliefs. Even once Amy is old enough to reflect on the schema explicitly, she may not think about it or realize it isn't accurate.

Schemas can be particularly confusing when we don't know what events created them. This can happen if you were too young to form long-term episodic memories that persist into adulthood or if you don't explicitly recognize the link between an event and the schemas it created. People often develop inaccurate stories about stuck schemas to fill the explanatory gap. As Resmaa Menakem says in #textcite(<menakemContext>):

#quote(block: true)[
Trauma decontextualized in a person looks like personality.

Trauma decontextualized in a family looks like family traits.

Trauma in a people looks like culture.
]

Common traumas or insecurities include
- different forms of unintentional or occasionally intentional neglect or abuse
- lack of attunement from parents~@brownAttachmentDisturbances
- disasters, accidents, assault, or war
- chronic poverty, dehumanization, or dysfunctional social-cultural systems~@roncaStructuralViolence, sometimes explained away as tradition or "how things are"
- loss of health, home, family, or culture
- a wide variety of other difficult situations

Some of these are transmitted intergenerationally or culturally via chains of stuck schemas that create harmful behavior that then causes other people to learn stuck schemas. Consider a parent who beats their child whenever the child does something slightly wrong. The child could learn to stop trying to do anything at all. When they grow up they may neglect their own children if they're still operating under the "don't do anything or I'll get hurt" schema.

Many traumas, especially chronic ones experienced during childhood, create complex networks of stuck schemas around things like your sense of self, relationships, body, etc. These are frequently disabling because the schemas are intense and activated by either a wide variety of stimuli or a few particularly pervasive stimuli (e.g., being alive).

Some people have schemas that predict pervasive threat or classify ambiguous signals as threatening~@berghBSTS. These may have developed in situations where noticing and reacting quickly to potential threats was more important than taking the time to accurately decide if something is a threat or not. These schemas can easily create new stuck schemas. Thus, severely traumatized people can more easily acquire additional stuck schemas.

Many more people have sub-clinical stuck schemas than have a diagnosable mental illness. For example, one study found that 41% of the US population has non-secure attachment~@mickelson1997adult. Virtually everyone has some stuck schemas, even if they are mild or rarely activated.

For more information about this and other sections in this chapter, I highly recommend these reviews of #textcite(<eckerUnlocking>): #prosecite(<lesswrongCoherenceTherapy>) and #prosecite(<alexanderMountains>). I suggest reading them after finishing this chapter. Scott Alexander's review (#textcite(<alexanderSurfing>)) of #prosecite(<clark2015surfing>) is also an excellent introduction to the general theory of predictions/schemas in the brain.

== How Schemas Update (Or Don't)
<sec:mechanism>
A contradiction between the predictions of a schema and another source of information creates _prediction error,_ a difference between expected and actual reality~@eckerUnlocking. That information can be sensory or created by another schema. In the right conditions---the schema is activated and the brain registers the information as unambiguous and as contradicting the schema's predictions---prediction error triggers an updating process that changes the schema.#footnote[Memory reconsolidation researchers and predictive processing researchers formally define _prediction error_ differently. To my knowledge, no one has formally shown that they are the same thing despite the plain-language descriptions of both phenomena being nearly indistinguishable. I assume in this book that reconsolidation is the updating of a set of priors encoded in long-term memory. See @sec:assumptions for further discussion.] This process works well in everyday life but often fails for schemas formed under trauma, for reasons we'll see below.

When schemas are first created, they are _consolidated_ (i.e., integrated) into long-term memory~@eckerUnlocking. Thereafter, whenever prediction error meets the previously stated criteria, the schema enters a state of plasticity where it can be changed again. The schema then updates to model the contradictory information you're experiencing. When that is finished, the memory is _reconsolidated,_ re-entering a stable state where it can no longer be changed without another experience of prediction error. Throughout this book I use _reconsolidate_ to concisely denote the entire process of schema deconsolidation, updating, and reconsolidation. The type of memory described here is implicit memory, not explicit memory of events and facts~@eckerUnlocking. Implicit memory is our often unconscious model of the world and self.

For instance, you might learn "Brussels sprouts taste bad" after only eating boiled Brussels sprouts. That belief consolidates in long-term memory after your first experience. At a later point you eat Brussels sprouts pan-browned with grated Parmesan on top. This tastes great, which strongly contradicts the old "Brussels sprouts taste bad" belief. That contradiction, or prediction error, makes the old belief enter a plastic state where it might then update to "Brussels sprouts taste delicious when cooked right but bad when boiled." After the updating, the belief reconsolidates and is again no longer changeable.

Contradictory information can come from a few different sources. Conventional therapy sometimes juxtaposes two contradictory schemas to facilitate reconsolidation~@eckerUnlocking. Incoming sensory information also strongly contradicts many stuck schemas. Some stuck schemas erroneously predict immediate threat, like someone hurting you if you refuse a request#footnote[Critically, an intellectual understanding that a stuck schema is inaccurate is not sufficient to reconsolidate many therapeutically relevant schemas~@eckerUnlocking. The contradictory information has to be deeply felt as real.]. Saying _no_ to a normal, non-abusive person in conversation provides contradictory sensory information indicating that they are not actually hurting you. As with the Brussels sprouts example, contradictory information in daily life naturally reconsolidates schemas all the time without any deliberate process.

#metadata("anchor") <attention>
The update process often doesn't work for schemas created in traumatic situations: the relevant schema may not be sufficiently activated, or contradictory information may not be perceived as sufficiently unambiguous and applicable to the stuck schema. This might happen for a few reasons (this list is likely incomplete, and avoidance and muting might overlap):
- *Avoidance:* People reasonably try to avoid threats. This avoidance is of course adaptive when the threat predictions are accurate but can prevent reconsolidation of inaccurate schemas if that behavior prevents contact with contradictory information. This can be physical avoidance, like not petting dogs when you have stuck schemas about how dangerous dogs are. It can also be mental avoidance, like distracting yourself when you think about or feel certain things if your schemas predict that feeling those emotions or thoughts is itself a threat. Avoidance can be automatic and unnoticed.
- *Muting:* The brain can adjust attention outside your control or awareness~@clark2015surfing. This process is flexible and can decrease attention to specific things as well as broader categories of information or sensory input~@clark2015surfing; this includes mental senses like your awareness of emotions, thoughts, and memories~@berghBSTS. Decreased attention makes information more ambiguous and less precise.#footnote[_Precision_ is a term closely related to _ambiguity_ in the predictive processing literature.] I call this _muting_ instead of the accurate-but-clunky term _down-weighted precision of bottom-up information._ While muting and avoidance are both actions the brain takes that make contradictory information more ambiguous, calling them both _avoidance_ might be confusing. Avoidance _is_ threat avoidance, but muting is more like a side effect of threat avoidance, or an aid to it.

  #textcite(<berghBSTS>) proposes an example of this phenomenon: the brain might mute all sensory input when it thinks reacting quickly to potential threats is much more important than spending time figuring out whether something is really a threat. This strategy may activate any time a schema predicts imminent threat. Crucially, avoidance is in service of not encountering the aversive thing; muting may be triggered by threat, but its function isn't escape from the muted content itself.

  More generally, the brain may inaccurately learn that certain information isn't useful or reliable and stop paying attention to it. For instance, the sensory muting of depression (colors appear more gray~@alexanderPrecision) plausibly follows from a "nothing matters" schema since, if nothing matters, sensory input is not useful.
- *Misattribution:* Your brain might attribute contradictory evidence to the wrong cause~@salkovskisImportanceBehaviourMaintenance1991. For instance, you might take a lucky charm with you for protection whenever you go into places that activate a stuck schema. The stuck schema activates and you experience a clear indication that your fear hasn't come to pass, setting the stage for reconsolidation. However, your brain might then misinterpret that as evidence that your lucky charm worked instead of the truth that your schema is inaccurate.
- *Opioid dampening* impairs cognition and sensory processing~@cheetahSigns, and thus it might impair reconsolidation. I don't include it in _muting_ because muting can flexibly tune out specific things; opioid dampening is indiscriminate chemical blunting.

In practice, it may be hard to determine which of these is present in any particular case. PTSD frequently causes people to feel disconnected from their bodies~@vanderKolkBody. Alexithymia is basically disconnection from emotions~@hogeveen2021alexithymia. These effects might be avoidance, muting, opioid dampening, or a combination of those. Luckily, as argued in @sec:sessionbarriers, all the mechanisms are addressed in the same way.

The above list might also explain why mentally healthy and securely attached people are resilient to events that would traumatize others~@attachmentPTSD@bonanno2008loss. They generally don't avoid much, feel comfortable attending to their feelings and body, lack preexisting opioid dampening, and don't carry schemas predicting pervasive threat.

I recommend Scott Alexander's summary (#textcite(<alexanderPrecision>)) of #prosecite(<berghBSTS>) for further information about attention, which the article calls _precision._ The summary and article also call schemas _priors._

== How MDMA Helps Update Schemas
<mdmaUpdate>
Personal experience and anecdotal reports suggest that MDMA facilitates enough prediction error to reconsolidate most, if not all, stuck schemas that you activate and stay present with during a session. It's not clear why it does this, though I list several hypotheses in @ppHypotheses.

I propose that there are at least three ways of using MDMA to aid memory reconsolidation. More than one of these may occur during a particular MDMA therapy session:
- Using the contradiction provided by MDMA, whatever its source, to reconsolidate a stuck schema during the session by activating and staying present with the schema. This could be as simple as staying present with the fear some schema is creating, then noticing it dissipate over a span of minutes to tens of minutes. This is common and is the approach I advocate.
- Using the feelings of safety from MDMA to investigate and understand your unexamined schemas. Explicit schemas may be easier to contradict in regular therapy after the session because creating a contradiction without MDMA often requires knowing what the schema is~@eckerUnlocking. Schemas also often naturally reconsolidate once they become explicit.
- Using MDMA to gain new knowledge (e.g., "I have an inner well of inviolable safety") that you can then use outside the session to reconsolidate a wide variety of stuck schemas. This happened to me (see @internalizedReports).

These processes are conceptually simple but can be practically complex. People's stuck schemas are frequently intense and may require several or even many sessions to fully reconsolidate.#footnote[It's not clear to me whether intense schemas needing multiple sessions are actually one schema or multiple closely related schemas.] People may also have multiple stuck schemas and typically have only a partial understanding of the schemas causing their problems, so they often end up needing to work on schemas they weren't initially aware of. The simplest issues may easily be resolved in a single session, but my rough estimate is that the most severe mental illnesses require tens of thousands of hours of reconsolidation.

The payoff is worth the effort, though. #textcite(<eckerUnlocking>, supplement: [p. 22]) describes the following signs of a completely reconsolidated schema:

#quote(block: true)[
Schema reactivation, in which the knowings and expectations in the target learning feel compellingly real and are accompanied by physiological and emotional arousal, can no longer be triggered by cues and contexts that formerly did so.

Behaviors, emotions, thoughts, and somatic sensations (i.e., "symptoms") that were expressions of that schema reactivation cease to occur.

Both of those changes persist effortlessly, permanently, and without counteractive or preventive measures of any kind.
]

Reconsolidation is the mechanism of updating stuck schemas, but it is not the only part of healing. Learning healthy habits, learning emotional skills, and resolving conflict can also be important. Throughout this book I occasionally mention resources for these, but they are not my focus.

== Somatic Symptoms
<psychogenic>
Many people with stuck schemas also have what different medical and therapeutic fields call _medically unexplained symptoms,_ _psychosomatic symptoms,_ _functional symptoms,_ _subjective health complaints,_ _somatization,_ _somatic symptom distress,_ or _bodily distress_~@berghPsychogenic.

#textcite(<berghPsychogenic>) makes a convincing case that many of these issues are inaccurate perceptions (e.g., pain) or functional impairments (e.g., inability to move a certain way) created by stuck mental models, or schemas in this book's language. This appears to work similarly to how the schemas I have already discussed create inaccurate perceptions of threat and inaccurate beliefs about how the world works. These symptoms can exist despite a total lack of current organ dysfunction or tissue damage. They seem real because perceived reality _is_ an internal representation of the world, where there is no fundamental difference between accurate and inaccurate perceptions~@clark2015surfing. These stuck schemas are typically learned and reinforced through the following factors:
- An initial illness or injury. The brain then creates a model of how the illness or injury feels and works~@berghPsychogenic. The illness or injury is often perceived as a threat.
- Existing schemas predicting pervasive threat or schemas that classify ambiguous signals as threatening~@berghBSTS. These may have developed in situations where noticing and reacting quickly to potential threats was more important than taking the time to accurately decide if something really is a threat. These schemas cause you to hyper-focus on how threatening the illness or injury feels.
- Low attention to detailed sensory information that indicates the absence of injury or illness~@berghBSTS. This may happen for various reasons discussed in @attention. It is notably an effect of schemas that predict pervasive threat.
- Imprecise or overly coarse mental categories for sensory information~@berghPsychogenic.

These factors prevent your mental model from updating by inhibiting the contradictory information that would normally revise it. Updating the mental model, and thereby resolving these issues, can be accomplished in a few ways. I think that you can reconsolidate#footnote[For consistency, I use the term _reconsolidation_ instead of _prior updating_ that #textcite(<berghPsychogenic>) prefers. As discussed in @sec:assumptions, I think reconsolidation is one type of prior updating.] the stuck schema creating these symptoms with the techniques described in this book. This might take a while if your schemas are intense or complex.

#textcite(<berghPsychogenic>) also suggests a couple of techniques. One is creating disconfirming experiences, where a touch or movement is feared to produce symptom perception but doesn't. The other is learning more finely grained categories of sensation, which increases the certainty of contradictory evidence. Controlled research on _somatic therapies_ for schema-produced symptoms is limited, but the mechanism predicts they should help by providing safe and detailed sensory input, and some anecdotal reports are consistent with this. For instance, #textcite(<vanderKolkBody>) contains many anecdotes of practices like yoga, massage, and acupuncture resolving people's stuck schemas or symptoms.

My own experience with schema-driven somatic symptoms illustrates how several of these factors can compound. I had chronic itching. It matched at least the first three factors in the list above: it followed an encounter with bedbugs, I had severe preexisting stuck schemas predicting pervasive threat, and I had a hard time paying attention to my body. The initial bedbug situation was deeply anxious for me, and like many people who are bitten by insects, I often imagined I was being bitten when I wasn't. Some ambiguous sensory information, like being poked by a feather from a comforter, would easily activate the "I'm being bitten" perception. This developed into chronic, anxiety-filled itching that lasted for years after the bedbug situation was over. It didn't resolve until I started working on that schema with the technique I describe in @internalizedReports. Roughly 5~hours of work on that schema resolved a significant part of the itching and anxiety. The caveats were that I had to reconsolidate many other schemas before this one was accessible, and considerably more reconsolidation will be necessary to resolve the rest of it.

Not all health issues associated with mental illness are inaccurate perceptions. Inaccurate symptom predictions can also coexist with tissue damage or organ dysfunction~@berghPsychogenic. In these cases, symptoms are perceived as stronger or more pervasive than what the organ dysfunction or tissue damage is physically causing. The previously mentioned fixes may reduce symptom perception by aligning it with physiological reality.

A common position is that stuck schemas indirectly cause organ dysfunction via chronic stress. #textcite(<berghPsychogenic>) thinks that the evidence for this pathway is weak, but I am not sure.

Stuck schemas can also cause physical issues through driving harmful coping behavior or impairing your access to healthy activities. For instance, escapist schemas can create alcoholism and "if I move I'll die" schemas inhibit exercise.

For further (technical) reading on the topic, I recommend #prosecite(<berghPsychogenic>).

== Complex Systems: Symptoms Can Get Worse Before They Get Better
<sec:complex>
The framework I've laid out explains the process of therapy well for simple issues. However, it is common knowledge in therapy that many people with intense or complex sets of stuck schemas go through a series of symptom ups and downs during the process of healing. As described below, this can happen when you start feeling or doing things that were previously blocked by stuck schemas. These feelings, thoughts, and behaviors can activate even more of our stuck schemas. For a period of time, we may even feel worse than we did before we started. I think that complex systems theory provides the right conceptual vocabulary for this phenomenon even though it doesn't predict the details of any particular individual's situation.

In the complex systems formulation, your mental state is like a ball that can be stuck at the bottom of a deep valley of mental illness~@hayes2020complex. By contrast, in good mental health, the ball is in a landscape where there are no deep valleys, only shallow valleys that the ball rolls in and out of as needed, depending on the context. One shallow valley may be your mental state at work, another your state at home, etc.#footnote[This is only a crude illustration. Real mental landscapes are far more complicated, and it's not clear how they're organized. For instance, there may be loops, which are not possible in a 2D landscape.]

In complex systems, valleys are called _attractor states_. In the model discussed here, maladaptive attractor states, or maladaptive attractors, are created by two factors: stuck schemas and low attention to contradictory information. The schema generates the symptoms. The low attention prevents the schema from updating and thus prevents the symptoms from dissipating. In long-term anxiety, for instance, the ball stays at the bottom of the anxiety attractor because the stuck schema predicting imminent threat is activated by a pervasive trigger, and low attention to contradictory information keeps that schema stuck.

Other factors play roles too, but I limit this discussion to schemas and low attention. I think they're usually the most influential for the types of issues described in this book, and adding more factors makes the model too complex to use. Certain mental illnesses likely depend on other factors.

To recap, the landscape of attractors and the "mountains" between them are created by the interactions of schemas and attention. It changes slowly through learning and reconsolidation, though I think that MDMA can also temporarily reshape it. Your current mental state is the current position of the ball, which can roll through the landscape on a short timescale when nudged by internal or external events. Its trajectory is determined by the shape of the landscape and the nudges it receives.

=== Symptom Worsening
<symptom-worsening>
Symptom worsening (symptoms being emotions, thoughts, behaviors, and somatic sensations~@eckerUnlocking) is typically temporary but can persist, at least without further intervention~@evans2023extended. I think it occurs when something, like MDMA therapy, opens up or pushes you onto previously unavailable trajectories in the landscape#footnote[Hallucinogens like ayahuasca can also create new stuck schemas from traumatizing experiences. For instance, you feel that a demon is possessing you, and this is deeply ingrained in your mental model during the trip. I'm not aware of this type of problem happening with MDMA.]. Your mental state is then free to go to these new areas, where your schemas create an array of (potentially distressing and maladaptive) emotions, thoughts, behaviors, and possibly defense cascade activations. In practice, this might look like
- fluctuation between two attractors, though this may only sometimes be problematic and therefore may or may not be categorized as symptom worsening. As reconsolidation gradually weakens a maladaptive attractor, the maladaptive and adaptive attractors become closer in strength~@hayes2020complex. Minor environmental changes are then enough of a jolt to initiate a transition from one to the other, and the system may fluctuate between them. This might be a sign of an imminent shift from the old maladaptive attractor being primarily active to the adaptive attractors being primarily active. Congruent with this theory, some evidence suggests that symptom fluctuation is associated with better long-term outcomes in therapy~@olthofDestabilization.
- a chain reaction of stuck schema activations in particularly reactive and complex stuck schema networks. For example, you might have two stuck schemas: "nothing matters," which disincentivizes doing chores, and "I have to do chores because someone will hurt me if I don't," which incentivizes doing them. Schema 2 may help you do chores even when schema 1 is pushing you not to. MDMA therapy might reconsolidate schema 2 before schema 1, leaving you unable to do the chores until you also reconsolidate schema 1. The experience of not doing chores could then activate a third stuck schema, like "I deserve to die if I'm not being useful." That schema may have been influencing your feelings and behavior all along but had never been intense because you had never felt so useless. Now it escalates to suicidal ideation because the feeling of uselessness is unusually intense. In my personal experience, real-life chains can be considerably more opaque and convoluted.
- opening up feelings that you should have been feeling but weren't because of stuck schemas. For instance, you may deeply believe that you don't matter and that people who don't matter should be treated in ways that an emotionally healthy person would consider bad. In that state, you might not be as upset as you should be about people treating you badly because those actions or words are congruent with how people like you should be treated. After you reconsolidate those mental models, you might start feeling intense rage since your memories of how you were treated are no longer congruent with your mental model. You then also have to reconsolidate the anger-producing schemas. This type of reaction is well known in therapy but doesn't fit the complex systems model I've laid out as tidily as the previous example did, and it glosses over some of the steps, such as what the anger schemas are. Nevertheless, I think it likely still fits here.

Whether a newly accessible maladaptive attractor is temporary or stable depends on how much attention there is to contradictory information. Low attention to contradictory information makes an attractor stable, whereas moderate or high attention makes it self-limiting. High attention mixed with mild stuck schemas may just feel like a minor dip on your way to somewhere else in the landscape.

Symptom worsening is problematic if it occurs when you don't have the slack to work through it, if it is too intense, or if you and your practitioner don't know how to get out of it.

I don't know any reliable way to reconsolidate complex stuck schema networks without ever falling into a worse attractor for a while. You may need to reconsolidate numerous stuck schemas over a long period of time to gradually shift the network from reactivity, with many stuck schemas, to resilience, with few or no stuck schemas. In other words, you may have to individually fill in most or all of the mental illness valleys in the mind's landscape that your ball can fall into. This can be compared to getting up from a chair. Sitting and standing are both stable positions. If you want to walk around and access a wider range of adaptive attractors, you have to stand up. The transition between the two is unstable, but that's the price of being able to walk.

In practice, symptom improvement seems to typically outweigh symptom worsening, given that the MDMA therapy clinical trials showed significant average decreases in disability and functional impairment over the course of three sessions~@mitchellMDMAClinicalTrial@mitchellMDMAClinicalTrial2. Anecdotal reports suggest that symptom worsening is not related to dose as long as the dose is sufficient for reconsolidation or decreasing avoidance/muting. I think symptom worsening is more related to how much reconsolidation you did, which schemas you reconsolidated, and what things you experienced that had previously been avoided or muted.

=== Healing in Complex Systems
<healing-in-complex-systems>
In the complex systems framework, therapeutic improvement is~@hayes2020complex
- making the maladaptive attractor you are in less harmful but not disassembling it. For example, using clean needles instead of dirty needles for an IV drug addiction reduces the consequences of the addiction but doesn't reduce the addiction itself.
- pushing the ball of your mental state from a maladaptive attractor to one or more adaptive ones without disassembling the maladaptive attractor. This is most durable when the adaptive ones are deeper, so that the ball doesn't quickly roll back into the maladaptive one when you encounter the wrong kind of nudge. The adaptive attractors may need to be deepened as well, or the "mountains" between the attractors raised. For instance, you might learn healthy conflict resolution techniques if you are in a situation of frequent conflicts that nudge you toward the maladaptive attractor.
- disassembling the maladaptive attractor. I think that this is reconsolidation of the stuck schema, whether explicit in therapy or implicit in daily life or non-therapy processes (e.g., possibly some types of meditation).

Therapeutic interventions may combine several of these approaches. People with complex issues may both transition through many attractors and gradually disassemble them. As previously discussed, this comes with ups and downs that tend toward adaptive states over the long course of therapy.

In practice, reconsolidation is often sufficient to resolve many issues~@eckerUnlocking. Furthermore, when you fully disassemble the maladaptive attractor, relapse is no longer possible~@hayes2020complex. The other processes leave the maladaptive attractor intact, whether your mental state is currently in it or not. Relapse occurs when the right circumstances nudge your state back into the attractor.

=== The Limitations of My Model and the Complex Systems Approach
<the-limitations-of-my-model-and-the-complex-systems-approach>
While complex systems theory qualitatively describes important parts of mental illness, therapy, and stuck schemas, it currently offers few detailed predictions~@hayes2020complex. Complex systems are difficult to model; the architecture of mental models is unknown and might be significantly different for every individual, and almost all the parameters of the model are extremely difficult or impossible to measure. Furthermore, the state space in which these attractors exist isn't just a simple one- or two-dimensional landscape; it has at least as many dimensions as there are schemas and symptoms. The number of practically significant dimensions could easily be too large to comprehend.

It's unclear to me who will worsen, when they will worsen, and how long the worsening will last~@hayes2020complex. No one knows for sure what distressing material or reactions you may or may not uncover, or how reconsolidating certain schemas will cause complex cascades of schema activations. It may also be the case that skilled therapists have developed useful heuristics for estimating these and navigating the complex landscape, though I am not sure.

= Safety
<sec:safety>
MDMA is often considered a risky substance due to its illegality, adulterants, and association with occasional harm in recreational contexts. However, the vast majority of these risks are caused by overheating, overhydration, and mixing drugs at raves~@riggDeaths. They are largely avoided by taking the right precautions or not doing MDMA therapy if you have certain risk factors. On rare occasion, some adverse effects may occur despite precautions. This section covers the significant drug interactions, medical contraindications, and psychological risks. Here is a summary of how to avoid or prepare for the most significant risks (in therapeutic contexts) discussed in the literature, which are detailed later (some of these are best guesses based on sparse evidence):

#lead[Always avoid (significant risk of death or irreversible damage):]
- MAOIs and ayahuasca
- ritonavir, cobicistat, or HIV drugs that contain them
- over 200 lifetime doses (boosters count as partial extra doses)#footnote[The number 200 is extremely imprecise, but as described below, there isn't any better data.]
- hyperthyroidism that is neither well managed nor mild, as assessed by a doctor

#lead[Use caution with (continue reading for further assessment):]
- a family or personal history of psychosis#footnote[I use the terms _psychosis_ and _mania_ in this article rather than terms like _schizophrenia_ and _bipolar_ on the assumption that they are closer to natural kinds, and more predictive of risk, than DSM/ICD diagnoses.]
- a personal history of addiction to amphetamines or cocaine
- a total dose over 2\u{202F}mg/kg per session, especially for more than a handful of sessions
- session spacing of less than 4~weeks
- drugs/medications/supplements/herbs, including large doses of caffeine
- liver and cardiovascular problems
- other serious medical conditions, especially ones that are neither well managed nor mild, as assessed by a doctor

#lead[Take precautions:]
- Don't drink more than 0.5\u{202F}L of water during the first six hours of a single-dose session unless you need to replace large amounts of sweat. Booster doses probably extend this period.
- Ideally, avoid SSRIs and SNRIs for 2~months prior to the session.
- Test your MDMA.
- People with a personal history of mania should take care to sleep well before and after the session; sleep aids can help with this. They should also skip booster doses at first, then gradually increase the total dose on subsequent sessions if needed.
- Only start MDMA therapy if you have slack in your life and can do a lot therapy, MDMA-facilitated or otherwise, in the near future. On rare occasions, post-session symptom exacerbation can be severe. While it can be a part of the healing process when managed well, exacerbation can require a lot of therapy to resolve, and it may not resolve as quickly as you want.

  An exception may be people with secure attachment and no mental illness, who I think have very little chance of severe exacerbation.
- MDMA and therapy exhaustion can impair awareness and reaction times. Avoid driving and other risky activities on the same day as the session.

This section aims to provide basic information, usable dosing and testing recommendations, and an overview of the most practically relevant effects and risks. It does not cover less common or less serious interactions between MDMA and drugs or medical conditions. I encourage consultation with a doctor or pharmacist for most individual questions about safety and list appropriate papers to bring with you to a consultation, since a clinician likely won't understand MDMA well.

Aside from the issues discussed later, combining unusual states of consciousness; the physiological effects of MDMA; extreme emotions; activation or deactivation of defense cascade states; and psychogenic illness may unpredictably affect a wide variety of health conditions.

== Basic Pharmacology
<basic-pharmacology>
MDMA is a serotonergic (releases serotonin) amphetamine with both sympathomimetic (stimulant) and connecting properties, whose structure is shown in @fig:mdma. #textcite(<stockerConnectogen>) coined the term _connectogen_ for MDMA's class of drugs. These drugs facilitate profound connection to self, body, senses, and others. The sense of self is maintained and hallucinations are minimal, unlike with the classic psychedelics or hallucinogens.

MDMA is typically taken by mouth. It's produced in hydrochloride (HCl) salt form as a white to off-white crystalline powder, and all stated masses are masses of the HCl form.#footnote[MDMA HCl crystals are also usually hydrated; they absorb small amounts of water from the air and production process~@kranenburgHydration. In my understanding, illegal MDMA is measured based on the hydrated mass instead of the pure MDMA HCl mass.] The average half-life is 9~hours in healthy individuals~@straumann2024racemic. On average, subjective effects become strong around minute 45, reach a maximum around hour 1.5--2, but only last until hour 5~@straumann2024racemic because of rapidly developed tolerance~@farreTolerance.

Storage of MDMA is simple because it is stable in water, though this has only been tested up to 20\u{202F}°C (68\u{202F}°F)~@clauwaertStability. Drugs are typically much more stable in dry form.

// MDMA skeletal formula; port of
// \chemfig{*6(-=-(--[::-60](-NH-[::-60])-[::-60])=-(*5(-O--O-))=)}
#figure(
  svg-in-html({
    import alchemist: *
    // Alchemist sets atom labels as math equations (in New Computer Modern
    // Math; its fragment-font config doesn't override that). Unwrap them into
    // plain sans text, matching the LaTeX chemfig.
    show math.equation: it => text(font: sans, it.body)
    skeletize({
      cycle(6, {
        single()
        double()
        single()
        // Side chain: CH2 – CH(CH3) – NH – CH3
        branch({
          single()
          single(relative: -60deg)
          branch({
            single()
            fragment("NH")
            single(relative: -60deg)
          })
          single(relative: -60deg)
        })
        double()
        single()
        // Fused methylenedioxy ring
        cycle(5, {
          single()
          fragment("O")
          single()
          single()
          fragment("O")
          single()
        })
        double()
      })
    })
  }),
  caption: [
    Structure of MDMA
  ]
)
<fig:mdma>

== Acute Effects
<acuteEffects>
#textcite(<liechtiGender>) measured side effects during a session and 24~hours afterward that I list in @table:sideeffects. Some of them can last up to 3~days. Free access to water during sessions commonly causes mild hyponatremia, and this may have exacerbated some side effects~@atilaHyponatremia. #textcite(<colcott2024side>) additionally reported non-cardiac chest pain/discomfort.

#textcite(<studerus2010psychometric>) analyzed acute alterations in consciousness that I report in @consciousEffects. I compare it to ketamine and psilocybin to provide useful reference points to people who understand those experiences. See the _Subjective Effects_ section of #textcite(<effectindex>) for more detailed descriptions of the effects MDMA can produce.

Both of these studies used participants who were not mentally ill, though some individuals could have been engaging with intense stuck schemas that wouldn't be classified as mental illness. Therefore, these symptoms are likely due to the MDMA itself rather than defense cascade activation or stuck schemas. Using MDMA in therapy to confront schemas of intense fear may additionally activate states of agitation, panic, opioid dampening and their associated symptoms (see @sec:defensecascade). Large amounts of reconsolidation also cause a period of exhaustion called a therapy hangover. There is no data on the phenomenon, but common knowledge is that it lasts anywhere from a few hours to a couple of days.

I am not aware of these effects causing major problems in therapeutic contexts, though it's common to feel fatigued and low-mood enough that you need to spend the whole following day or two resting.

#figure(
  table(
    columns: 7,
    align: (right, right, left, left, right, left, left),
    stroke: none,
    // Value, (placebo) and marker sit in separate sub-columns so they align.
    inset: (x, y) => (
      y: 2.5pt,
      left: if x in (2, 3, 5, 6) { 1.5pt } else { 5pt },
      right: if x in (1, 2, 4, 5) { 1.5pt } else { 5pt },
    ),
    table.vline(x: 0), table.vline(x: 1), table.vline(x: 4), table.vline(x: 7),
    table.hline(y: 0),
    table.header(
      [*Symptom*],
      table.cell(colspan: 3, align: left)[*Acute %*],
      table.cell(colspan: 3, align: left)[*24~Hours %*],
    ),
    table.hline(),
    [Difficulty concentrating],         [59], [(15)], [], [28], [(8)], [],
    [Jaw clenching],                    [58], [(0)], [], [20], [(0)], [],
    [Lack of appetite],                 [54], [(4)], [], [39], [(3)], [],
    [Dry mouth/thirst],                 [53], [(3)], [], [34], [(4)], [],
    [Impaired balance],                 [49], [(0)], [], [7], [(0)], [],
    [Restless legs],                    [41], [(1)], [], [11], [(1)], [],
    [Sensitivity to cold],              [41], [(11)], [], [12], [(3)], [],
    [Dizziness],                        [38], [(1)], [], [7], [(0)], [],
    [Palpitations],                     [35], [(1)], [], [7], [(0)], [],
    [Restlessness],                     [34], [(1)], [], [12], [(1)], [],
    [Being cold],                       [34], [(7)], [], [9], [(3)], [],
    [Sweating/sweaty palms],            [31], [(0)], [], [12], [(0)], [],
    [Forgetfulness],                    [28], [(1)], [], [11], [(1)], [],
    [Heavy legs],                       [27], [(1)], [], [12], [(0)], [],
    [Fatigue],                          [26], [(47)], [↓], [41], [(26)], [],
    [Weakness],                         [26], [(1)], [], [24], [(1)], [],
    [Hot flushes],                      [24], [(3)], [], [15], [(1)], [],
    [Tremor],                           [23], [(0)], [], [8], [(0)], [],
    [Paresthesia (tingling sensation)], [22], [(9)], [], [1], [(8)], [↓],
    [Inner tension],                    [20], [(5)], [], [8], [(5)], [],
    [Brooding],                         [16], [(3)], [], [18], [(1)], [],
    [Nausea],                           [15], [(3)], [], [1], [(0)], [--],
    [Lack of energy],                   [15], [(8)], [], [24], [(4)], [],
    [Exhaustibility],                   [15], [(4)], [], [19], [(1)], [],
    [Frequent urge to urinate],         [14], [(5)], [], [15], [(5)], [],
    [Headache],                         [12], [(12)], [--], [27], [(7)], [],
    [Insomnia],                         [], [], [], [24], [(0)], [],
    [Anxiety],                          [11], [(1)], [], [1], [(1)], [--],
    [Irritability],                     [8], [(1)], [], [5], [(0)], [],
    [Increased appetite],               [4], [(7)], [↓], [1], [(3)], [↓],
    [Muscle Aches],                     [1], [(3)], [↓], [4], [(3)], [--],
    [Bad dreams],                       [], [], [], [7], [(3)], [],
    table.hline(),
  )
  , caption: [Side effects of 1.35--1.8\u{202F}mg/kg of MDMA, adapted from Table 3 of #textcite(<liechtiGender>). Values indicate the percent of participants reporting that symptom. Placebo values are in parentheses. MDMA increased all effects except the ones marked by ↓ or --.]
  , kind: table
  )
<table:sideeffects>

// OAV subscale scores by drug (Studerus et al. 2010, Figure 2 data).
#figure(
  {
    // Data from oavvalidationfigure2data/data-Table 1.csv.
    // Columns: Sub scale, Group, mean, ymin, ymax, n
    let rows = (
      ("Blissful state", "Psilocybin (n=327)", 36.5637104994903, 34.9650563719301, 38.1623646270505, 327),
      ("Blissful state", "Ketamine (n=162)", 27.0637860082305, 24.9433132328088, 29.1842587836521, 162),
      ("Blissful state", "MDMA (n=102)", 45.6601307189542, 42.6693665164927, 48.6508949214158, 102),
      ("Changed meaning of percepts", "Psilocybin (n=327)", 37.032619775739, 35.3105380571766, 38.7547014943015, 327),
      ("Changed meaning of percepts", "Ketamine (n=162)", 31.537037037037, 29.3845516881731, 33.689522385901, 162),
      ("Changed meaning of percepts", "MDMA (n=102)", 28.5130718954248, 25.5345336819556, 31.4916101088941, 102),
      ("Experience of unity", "Psilocybin (n=327)", 31.2782874617737, 29.6453338343248, 32.9112410892226, 327),
      ("Experience of unity", "Ketamine (n=162)", 37.6320987654321, 35.3019468618403, 39.9622506690239, 162),
      ("Experience of unity", "MDMA (n=102)", 28.1823529411765, 25.3193187996131, 31.0453870827398, 102),
      ("Disembodiment", "Psilocybin (n=327)", 26.940876656473, 25.3600177795009, 28.5217355334451, 327),
      ("Disembodiment", "Ketamine (n=162)", 48.4753086419753, 45.9613819805652, 50.9892353033854, 162),
      ("Disembodiment", "MDMA (n=102)", 24.4575163398693, 21.8225902063371, 27.0924424734014, 102),
      ("Complex imagery", "Psilocybin (n=327)", 43.2579001019368, 41.4506738361597, 45.0651263677139, 327),
      ("Complex imagery", "Ketamine (n=162)", 35.3456790123457, 32.9994279873651, 37.6919300373263, 162),
      ("Complex imagery", "MDMA (n=102)", 17.6372549019608, 15.289791869167, 19.9847179347546, 102),
      ("Insightfulness", "Psilocybin (n=327)", 25.2721712538226, 23.8748145947666, 26.6695279128786, 327),
      ("Insightfulness", "Ketamine (n=162)", 23.3312757201646, 21.4438319301931, 25.2187195101361, 162),
      ("Insightfulness", "MDMA (n=102)", 15.7875816993464, 13.5658960596585, 18.0092673390343, 102),
      ("Impaired control and cognition", "Psilocybin (n=327)", 23.3184796854522, 22.139905887495, 24.4970534834094, 327),
      ("Impaired control and cognition", "Ketamine (n=162)", 32.4550264550265, 30.4594106108271, 34.4506422992258, 162),
      ("Impaired control and cognition", "MDMA (n=102)", 15.7591036414566, 13.7686172129717, 17.7495900699415, 102),
      ("Religious experience", "Psilocybin (n=327)", 18.3190621814475, 16.9760970735515, 19.6620272893435, 327),
      ("Religious experience", "Ketamine (n=162)", 19.6604938271605, 17.7681271000463, 21.5528605542747, 162),
      ("Religious experience", "MDMA (n=102)", 10.9771241830065, 9.03775513430023, 12.9164932317128, 102),
      ("Audio-visual synesthesiae", "Psilocybin (n=327)", 36.1478083588175, 34.2140261461183, 38.0815905715168, 327),
      ("Audio-visual synesthesiae", "Ketamine (n=162)", 27.2551440329218, 24.6365414811269, 29.8737465847167, 162),
      ("Audio-visual synesthesiae", "MDMA (n=102)", 10.2254901960784, 8.18848720829026, 12.2624931838666, 102),
      ("Elementary visual alterations", "Psilocybin (n=327)", 49.670744138634, 47.8239143591068, 51.5175739181613, 327),
      ("Elementary visual alterations", "Ketamine (n=162)", 32.4526748971193, 30.0604422515715, 34.8449075426672, 162),
      ("Elementary visual alterations", "MDMA (n=102)", 6.13398692810457, 4.59803849283569, 7.66993536337346, 102),
      ("Anxiety", "Psilocybin (n=327)", 8.58205912334353, 7.59961044875991, 9.56450779792714, 327),
      ("Anxiety", "Ketamine (n=162)", 13.0812757201646, 11.6335331487606, 14.5290182915686, 162),
      ("Anxiety", "MDMA (n=102)", 3.92320261437908, 2.80888718797518, 5.03751804078299, 102),
    )
    let subscales = rows.map(r => r.at(0)).dedup()
    let x = range(subscales.len()).map(i => i + 1)

    // (mean, lower error, upper error) per group, ordered like `subscales`
    let series-for(group) = {
      let rs = subscales.map(s => rows.find(r => r.at(0) == s and r.at(1).starts-with(group)))
      let means = rs.map(r => r.at(2))
      (
        y: means,
        yerr: (
          m: rs.zip(means).map(((r, m)) => m - r.at(3)),
          p: rs.zip(means).map(((r, m)) => r.at(4) - m),
        ),
      )
    }

    // Tick labels rotated 45°, hanging down-left from the tick.
    let tick-label(name) = box(width: 0pt, height: 2.6cm, place(top + right, rotate(
      -45deg,
      origin: top + right,
      box(width: 4cm, align(right, text(size: 8pt, name))),
    )))

    lq.diagram(
      width: 9.5cm,
      height: 6cm,
      xlabel: [Factors],
      ylabel: [% of Scale Maximum],
      ylim: (0, 55),
      legend: (position: top + right),
      xaxis: (
        ticks: subscales.enumerate().map(((i, name)) => (i + 1, tick-label(name))),
        subticks: none,
      ),
      // MDMA takes the link (plum blossom) red; a deep teal and an ochre complement it
      // and stay distinct in lightness for color-blind readers.
      ..(
        ("Psilocybin", rgb("#c8901a")),
        ("Ketamine", rgb("#1f6f78")),
        ("MDMA", link-color),
      ).map(((group, color)) => {
        let s = series-for(group)
        lq.plot(x, s.y, yerr: s.yerr, label: group, color: color, stroke: none, mark: "o", mark-size: 4pt)
      }),
    )
  },
  caption: [
    MDMA (1.5--1.7\u{202F}mg/kg oral), ketamine (6--12\u{202F}μg/kg/min continuous IV), and psilocybin's (115--350\u{202F}μg/kg oral) effects on consciousness, as measured by the new OAV factors developed by #textcite(<studerus2010psychometric>). Error bars represent standard errors. Figure re-plotted from the data underlying the original Figure 2.
  ]
)
<consciousEffects>

== Testing and Measurement
<testing>
Assessing dose, impurities, and adulterants is important for safety and efficacy and requires testing if you don't get your MDMA from a legal, regulated source. Always use a reagent kit to test for the presence of MDMA and many common adulterants unless you know that the batch has already been tested. #textcite(<testKitSuppliers>) maintains a list of reagent kit suppliers. Lab testing provides a much higher quality analysis, reporting the quantity of all ingredients. #textcite(<testingLabs>) maintains a list of drug testing laboratories.

MDMA is sold in two forms, loose crystals/powder and pills. In underground MDMA therapy, it is common to buy crystals/powder loose or prepackaged into capsules. The purity of this varies, but is, to my knowledge, typically good enough if it comes from a trusted supplier, is white to off-white, and passes the reagent tests.#footnote[#textcite(<boraxAcetone>) states that MDMA with more impurities can be salvaged by washing out the impurities with acetone if the crystals/powder "have an obvious brown colour, appear wet and sticky, [are] under 80% concentration of MDMA hydrochloride or have a strong smell." See #textcite(<boraxAcetone>) for instructions.] The effective dose range of MDMA provides enough wiggle room to accommodate small amounts of impurities remaining from the manufacturing process.

Unregulated pills are more of a challenge because they're always mixed with unknown quantities of fillers and binders. The amount of MDMA they contain can only be assessed with lab testing.#footnote[You can also filter out the insoluble fillers and binders while the MDMA is dissolved in hot anhydrous isopropyl alcohol. See #textcite(<feilongIsopropyl>).]

You will also need a calibrated milligram scale to verify your supply or measure precise amounts of MDMA into empty capsules unless you trust that your supplier has accurately measured your capsules. They are inexpensive and easy to find on the internet.

Illegally sourced MDMA crystals have usually absorbed small amounts of water from the air and production process even though the crystals still appear dry~@kranenburgHydration. To my knowledge, sellers market MDMA by the combined mass of the MDMA and water, so a given amount of illegal MDMA is slightly less potent than legal pharmaceutical-grade MDMA that contains exactly how much MDMA HCl it advertises. This effect, in addition to impurities, is small enough to not be worth considering for most people.#footnote[#textcite(<hydrationPolymorphism>) reports that most illicit MDMA HCl is roughly 4% water by mass, though exposing it to very dry or humid air will convert it to less or more hydrated forms ranging from 0--11% water. You can also dry your MDMA in an oven set to 100\u{202F}°C (212\u{202F}°F) for a few hours and then measure out a dose~@kranenburgHydration. The second method is more precise, since it's difficult to be certain how hydrated your MDMA is.]

You can also use volumetric dosing to divide your sample into doses appropriate for therapy. I suggest aiming for a simple-to-remember 1\u{202F}mg/ml solution of MDMA in water.#footnote[MDMA is extremely bitter~@milivcevic2020bitter. It may be nice to chase it with fruit.] Dissolve your measured amount of MDMA (in mg) in the same number of mL of water. It is much easier to measure one mL of liquid, whose mass is also 1~gram, than one mg of powder. #textcite(<volumetricDilution>) also offers a volumetric dosing calculator.

*Do not purchase or store MDMA dissolved in liquid unless you know your country or state's drug laws are based on the mass of the drug itself rather than the total mass of the mixture.* In jurisdictions where the law is based on total mass (typically English speaking countries), dissolving 1\u{202F}g of MDMA in 1\u{202F}L of water means that you now legally possess 1\u{202F}kg of MDMA. This allows a prosecutor to upgrade possession charges to distribution charges with mandatory minimum prison sentences. This principle also favors purchasing pure crystals/powder over pills, which contain fillers and binders that increase the total mass.

== Dosing
<sec:dosing>
Accurate dosing is important for avoiding unnecessary side effects and optimizing effectiveness. The positive and negative of MDMA primarily depend on dose, body mass, and, to a much lesser extent, how active your CYP2D6 enzymes that metabolize MDMA are~@studerusResponse.

MDMA therapy only works within a certain range of doses. A dose of 0.75\u{202F}mg/kg, for instance, doesn't provide any significant increase in the effects that I associate with therapeutic benefit~@bediMDMALowDose. Anecdotal reports also indicate that too high a dose can cause the session to be so blissful that you aren't able to productively activate and reconsolidate stuck schemas.

The two primary risks of higher doses are oxidative damage in serotonin neurons and possibly long-term cognitive impairment~@baggottDamage. I discuss these further in @medical. The first has been measured in animal experiments but hasn't yet been clearly linked to any clinically relevant impacts. The latter has most clearly been seen only in recreational users who use lots of MDMA over long periods of time, often in unsafe ways (drug mixing, overdose, overhydration, heat illness). It's not clear how relevant either are for less frequent, moderate doses in MDMA therapy, so the recommendations here are cautious until there is better data. This section describes two sets of dosing recommendations for different circumstances and risk tolerances, along with my recommendations.

=== The First Set
<the-first-set>
These doses are more conservative and based on some evidence suggesting that they do not cause measurable oxidative damage in the serotonin system~@baggottSupplements.

#textcite(<liechtiInteractions>) recommends a standard single dose of 100\u{202F}mg for body mass less than 60\u{202F}kg (132\u{202F}lb) and 125\u{202F}mg for higher body mass, though up to 200\u{202F}mg can be used for the highest body masses.#footnote[M. Liechti, personal communication, December 11, 2025, clarified that 200\u{202F}mg is the maximum total dose, not a maximum initial dose. It also only applies to individuals with higher body masses, though specifics weren't mentioned.] The 100\u{202F}mg dose also applies to everyone over 75~years old. This is roughly similar to the 2\u{202F}mg/kg threshold that #textcite(<baggottSupplements>) discourages exceeding.

CYP2D6 poor metabolizers have stronger reactions to MDMA~@schmid2016cyp2d6. People aware they have this should use up to a 25% lower dose, though it's not essential~@liechtiInteractions. Various drugs, like bupropion, also affect dose.

Adjusting the dose in subsequent sessions might be necessary to match the effect of the medicine to the strength of your schemas or to deal with avoidance, muting, or opioid dampening. Accurate data on the upper limit of safe doses is unfortunately absent due to difficulties translating the results of animal testing to humans and confounding factors muddying the study of harmful effects in recreational use~@passieHistory.

=== The Second Set
<the-second-set>
Doses up to 125+65\u{202F}mg have been successfully used in clinical trials without any obvious, lasting adverse effects~@mithoeferRETRACTEDARTICLEMDMAassisted2019, but there is significantly less certainty that they do not cause small amounts of oxidative damage.

Because effects depend on body mass~@studerusResponse, I don't recommend the fixed dosing these trials used. Adding a 50% strength booster dose to the first set of recommendations from #textcite(<liechtiInteractions>) is a better option for those using booster doses.

=== My Recommendations
<my-recommendations>
I think either set of doses are reasonable starting points; a handful of higher-dose sessions is not likely to have significant negative effects, and the mental health benefits can be large~@mitchellMDMAClinicalTrial2@mitchellMDMAClinicalTrial. Longer-term higher-dose use may also occasionally be worthwhile for individuals for whom lower doses and other therapeutic modalities do not work well.

As a general principle for everyone, especially those planning more than a handful of sessions, *I strongly recommend finding your minimum effective dose.* First, establish an effective MDMA therapy routine and gain a good sense of how your sessions feel and produce durable therapeutic improvement. Then you might reduce your total dose by 10% each session until you notice sessions becoming less helpful. Judge this a few weeks after the session, after the afterglow is finished and you have stabilized to a new baseline. This small reduction is unlikely to waste a valuable session by making it completely ineffective. You can also always return to your previous dose in the current session with an additional booster of the right amount.

You could also start by cutting the booster dose and then continuing with a 10% decrease on the single remaining dose on subsequent sessions. In my experience, a single initial dose often provides enough working time to get me to the therapy hangover limit. If therapy hangover is the limiting factor, then a higher dose or booster dose may not add much benefit.#footnote[It's conceivable that a booster dose could push someone through their single-dose therapy hangover limit, but that would also result in even higher levels of post-session therapy hangover.]

There are a few other preventative measures for oxidative stress that some people use. Most of these have not been tested in humans, and therefore the dose and practical utility are unclear. I recommend primarily focusing on reducing your MDMA dose in the face of these uncertainties, though people doing more than a handful of higher-dose sessions could consider trying some of these.
- *Caffeine:* High doses of caffeine exacerbate neurotoxicity in rats given very large doses of MDMA, so caution may be warranted~@vanattouCaffeine. Withdrawal is also undesirable, so it may be worthwhile to taper off moderate-high doses of caffeine for the months--years of MDMA therapy.
- *High ambient temperature:* High ambient temperature exacerbates neurotoxicity in rats given large doses of MDMA~@baggottDamage. It may be prudent to avoid hot ambient temperatures during sessions. It's plausible that the combination of high temperatures and high humidity is even worse given that it reduces the cooling effect of sweating.
- *Antioxidants:* High doses of certain antioxidants, including alpha-lipoic acid, ascorbic acid (vitamin C), and acetyl-ʟ-carnitine, prevent oxidative stress in rats given extremely high doses of MDMA~@aguirre1999alpha@shankaran2001ascorbic@alves2009acetyl. See #textcite(<baggottSupplements>) for more information. Notably, it might not be possible to achieve a high enough blood concentration via oral administration.
- *SSRIs:* Fluoxetine and likely other SSRIs taken 3--4~hours after the MDMA prevent neurotoxicity in rats~@baggottDamage.

== Session Frequency
<frequency>
Making specific recommendations for session spacing is difficult because individuals have different risk/reward tradeoffs and neurological responses to MDMA, and safe spacing strongly depends on dose. There are two main limitations relevant for minimizing risk~@baggottSerotonin@baggottDamage. First, the brain's antioxidant capacity may need time to replenish after a session. MDMA causes oxidative stress, but the brain's antioxidant buffer is normally capable of neutralizing this, likely at least for doses under 2.0\u{202F}mg/kg~@baggottSupplements. However, using more MDMA before it has recovered may cause oxidative damage in the brain. To my knowledge, no human studies, including the clinical trials, have measured this time span.

Three expert panels independently ranked MDMA, or substances sold as MDMA, among the least harmful drugs on their scales, including on criteria that would plausibly capture neurotoxic effects if those were producing clinically apparent outcomes~@nuttDrugHarms@bonomoHarms@crossinHarms. The absence of any signal strong enough to elevate MDMA in these rankings is consistent with oxidative damage from typical non-therapeutic use patterns being, at most, a minor--moderate contributor to population-level harm. The typical therapeutic protocol---2--3\u{202F}mg/kg total dose, proper hydration, infrequent administration, no hyperthermia, no drug mixing---would be expected to produce even less.

That being said, even mild-to-moderate amounts of harm are worth minimizing when possible. People may also need to do many MDMA sessions to treat intense or complex sets of stuck schemas, and gradually cumulative effects may become more noticeable. I know of four lines of indirect evidence that tentatively suggest that the 4~week spacing used in the phase III trials is okay when using a total dose at or under 1.5\u{202F}mg/kg per session:
- #textcite(<mithoeferRETRACTEDARTICLEMDMAassisted2019>) didn't find any statistically significant, lasting cognitive issues in clinical trials totaling 54 participants after two sessions using a total dose ranging from 112.5--187.5\u{202F}mg per session#footnote[Ten percent of participants declined the second optional dose. Their total dose would have only been 75--125\u{202F}mg.].
- #textcite(<guckerEffectsEcstasyMDMA2000>) found no statistically significant alterations in serotonin binding sites in the brain four weeks after a single 1.5\u{202F}mg/kg dose using positron emission tomography.
- #textcite(<baggottSupplements>) didn't see any elevated markers of oxidative stress in urine with doses of 1.5\u{202F}mg/kg. Thus, that dose might not deplete antioxidants at all, and safe spacing for oxidation would be a nonissue.
- I used the Claude Opus 5 LLM to review the research on MDMA oxidation and the body's antioxidant defenses and make a model of how long it takes various antioxidants in the serotonin system to recover after oxidative stress. Since little research has investigated this in humans, it guessestimated a plausible range of values for each input parameter. It then calculated different values of safe spacing from many combinations of those parameters. 95% of its estimates fell between 1~week and 7~weeks, with the median estimate being 3.7~weeks, though it was also running estimates for a range of doses from 1.5--3.0\u{202F}mg/kg. The report, which includes source code and bibliography, is #link("https://github.com/groeneveld/mdma-guide/blob/main/auxillaryFiles/antioxidant-spacing.pdf")[here]. I made sure that it double-checked that all values were accurately retrieved (from full-text article PDFs) and cited, and that it double-checked its equations. Take this with a good dose of skepticism: LLMs have notable problems and I don't have the expertise to verify that its model is reasonable.

The second main limitation is downregulation of the serotonin system during an MDMA session, which causes short-term tolerance~@baggottSerotonin@baggottDamage. Using MDMA again before tolerance has returned to baseline will result in lower efficacy. Using higher doses to overcome that will increase the risk of oxidative damage. Neither the time required for tolerance to return to baseline nor the limits of the antioxidant buffer are known, so I strongly recommend spacing sessions far enough apart that you don't notice any lessening of effect. I don't think anyone has measured how long short-term tolerance lasts. The four-week spacing of the phase III trials produced progressively increasing therapeutic benefit after each session~@mitchellMDMAClinicalTrial~@mitchellMDMAClinicalTrial2, suggesting that this time span may be sufficient for many people, at least for a few sessions.

Doing sessions more frequently than those limits may also risk long-term tolerance, sometimes called "losing the magic"~@baggottSerotonin@baggottDamage.

The four-week spacing used in the phase III trials~@mitchellMDMAClinicalTrial might be a reasonable spacing to start at, though longer is always okay too.#footnote[The sparsity of data means that well-informed people with different risk tolerances and starting assumptions will disagree on what a reasonable starting spacing is.] From there, I recommend establishing an effective MDMA therapy routine and gaining a good sense of how your sessions feel and produce durable therapeutic improvement. Then, if you feel that a shorter spacing would benefit you, and you're already above 4-week spacing, you might reduce your spacing by 25% every one or two sessions until you notice sessions becoming less helpful. Judge this a few weeks after the session, after the afterglow is finished (see @afterglow), and you have stabilized to a new baseline. This reduction is unlikely to waste a valuable session by making it completely ineffective.

That procedure only measures short-term tolerance. You may not be able to notice when you go below your antioxidant system recovery timespan, and thus I recommend the 4~week spacing as a minimum. Some people might decide to risk shorter spacing if they think the tradeoffs of their particular situation are worth it.

See #prosecite(<baggottSerotonin>) for further discussion of tolerance and oxidative stress.

#lead[Additional downsides of frequent sessions:]
- More frequent medication pausing or tapering if your medication is incompatible with MDMA.
- People with risk factors for psychosis may want to avoid frequent sessions, since frequent use of a wide range of psychoactive drugs is another well-established risk factor~@drugsPsychosis. Likewise for mania.
- Frequent sessions are emotionally taxing and anecdotal reports indicate that MDMA therapy often produces temporary symptom worsening.

#lead[Benefits of frequent sessions:]
- Compressing a given amount of therapy into a shorter period of time generally delivers faster therapeutic progress~@dellMassed@ehlersMassed@foaMAssed. This was found in conventional therapy for PTSD, but I see no obvious reason why it would be different for different types of stuck schemas and MDMA therapy.
- Many people who might benefit from working with a practitioner can't access one because of stuck schemas involving trust. Relatedly, many people already have a therapist but don't benefit as much as they could. A critical mass of MDMA therapy sessions may provide a valuable on-ramp to greater amounts of therapeutic support and healing. This can lead to a strong upward trajectory, whereas the same amount of reconsolidation spread over a longer period of time might not achieve the critical mass necessary.
- Another session after a few weeks may or may not provide enough additional reconsolidation to resolve particularly overwhelming symptom worsening from a previous session that doesn't respond to other symptom management strategies.
- #textcite(<berghBSTS>) hypothesizes that the high-level schemas predicting pervasive threat that many people with mental illness have can easily categorize relatively minor negative stimuli as new threats.#footnote[#prosecite(<alexanderPrecision>) provides a more accessible summary of #textcite(<berghBSTS>).] This process can readily create new stuck schemas or make existing stuck schemas activate in the presence of new stimuli. Put another way, relatively minor events can easily traumatize people with mental illness. I speculate that this might show up in therapy as "two steps forward, one step back," or needing to achieve some intensity of reconsolidation just to maintain baseline. Actual improvement might depend on higher intensities of reconsolidation.

== Drug Interactions
<interactions>
MDMA has dangerous or undesirable interactions with various drugs, supplements, and herbs. If you regularly take another drug, I suggest consulting #textcite(<liechtiInteractions>) and #textcite(<spiritMemberProgram>) (more accessible) or #textcite(<sarparastDrugInteractions>) (more technical) for recommendations on whether you should continue or discontinue it during MDMA therapy, avoid MDMA, or modify the MDMA dose. If your medicine is essential for your health, I strongly recommend consulting your doctor or pharmacist for help managing this. They will likely not understand the effects of MDMA, so you may need to provide #textcite(<sarparastDrugInteractions>) to them. That paper discusses pharmacokinetics, pharmacodynamics, and psychiatric drug interactions.

If you can't access a doctor or pharmacist, pausing a drug for 3 half-lives#footnote[One half-life is the time it takes for a drug's concentration in your body to decrease by half. Each drug has a different half-life, which can be found on #link("https://go.drugbank.com") under Pharmacology → Metabolism. So the concentration would be 50% after one half-life, 25% after two, etc.] before the MDMA dose and 24~hours (3 MDMA half-lives) after might work, provided a few conditions are met. The drug shouldn't be critical for your health, isn't one of the few high-risk interactions discussed in the section summary, and can be paused with tolerable effects. This doesn't work as well for drugs whose MDMA-relevant effects persist after the drug itself has been flushed out, like SSRIs and irreversible MAOIs. Certain health conditions also affect half-lives.

Most supplements and herbs can just be paused on treatment day to be safe.

In this section I list a couple of classes of interaction, then the most risky specific interactions and a few other selected interactions that frequently appear in therapeutic contexts. Combining MDMA with other prescription psychiatric or psychoactive drugs causes various changes to the intensity or duration of different effects, including changes to the efficacy of MDMA therapy~@sarparastDrugInteractions.

#lead[The most risky classes of interactions:]
- *Serotonin syndrome:* Serotonin syndrome is a potentially deadly condition caused by extreme amounts of intrasynaptic serotonin~@malcolmSerotonin@sarparastDrugInteractions. It's mostly caused by interactions between MDMA and MAOIs or MDMA overdose.
- *Alterations in the CYP450 enzymes:* The liver enzymes CYP2D6, CYP1A2, CYP2B6, CYP2C19, CYP3A4 (all part of CYP450), and COMT metabolize MDMA and its metabolites (other molecules that the body converts MDMA into)~@sarparastDrugInteractions. Drugs that enhance these enzymes may reduce the intensity and duration of MDMA's effects by removing it from your blood at a faster rate. Drugs that inhibit these enzymes cause higher and longer blood concentrations, though the multiple enzymes provide redundancy if one pathway is blocked. Drugs that strongly inhibit multiple of these enzymes may be deadly to take with MDMA. Drugs that only inhibit CYP2D6 are okay to take with MDMA, though #textcite(<liechtiInteractions>) recommends reducing the MDMA dose by up to 25%.

  MDMA itself actually almost completely inhibits CYP2D6~@omathunaCYP. This inhibition returns to baseline with a half-life of 47~hours. Thus, about 2~days after a session, enzyme activity will be 50% of the way to baseline, 75% after 4~days, 88% after 6, 94% after 8, and 97% after 10. This effect may counteract tolerance or lead to unexpectedly strong reactions to subsequent doses of MDMA. Inhibited CYP2D6 slows the metabolism of MDMA and many other drugs, especially ones that are not metabolized through any other parallel pathways that could take up the slack. Thus, dangerous concentrations of certain drugs could accumulate in your blood when those drugs are used within a few days after MDMA.

  #textcite(<flockartTable>) maintains a list of drugs that inhibit, enhance, or are metabolized by (called substrates) CYP450 enzymes.

#lead[Specific drug interactions, starting with the most risky:]
\(does not include low--moderate risk interactions with many drugs)
- *MAOIs:* Taking irreversible MAOIs within two weeks before an MDMA session or immediately after can cause severe serotonin toxicity and death~@malcolmSerotonin@edinoffInteractions. Ayahuasca contains a shorter-lasting, reversible MAOI whose effects are gone within 2--3~days~@malcolmAyahuasca.
- *Ritonavir and cobicistat:* These strongly inhibit multiple CYP450 enzymes and can cause death when combined with MDMA~@bracchi2015antiretrovirals@sarparastDrugInteractions.
- *Caffeine:* Large doses of caffeine dramatically increase tachycardia and body temperature in rats given large doses of MDMA~@vanattouCaffeine. It also increases the risk of serotonergic neurotoxicity to an unclear degree. It's not clear how this applies to human MDMA therapy, but caution might be warranted.
- *SSRIs and SNRIs:* SSRIs and SNRIs highly inhibit the effects of MDMA~@sarparastDrugInteractions but are not dangerous. Long-term use of these drugs causes this effect to persist long after drug discontinuation~@feducciaSSRIDiscontinuation. The therapeutic efficacy of MDMA therapy is reduced by half even after 25~days of discontinuation. Further discontinuation may bring further benefits. Discontinuation typically requires multiple additional weeks of tapering to manage withdrawal. See #prosecite(<crossingZero>) and #prosecite(<malcolmTapering>) for more information and practical advice on tapering.

== Medical Risks
<medical>
MDMA's interactions with certain serious health conditions are not well understood. As of 2026, MAPS clinical trial exclusion criteria are commonly regarded as the baseline for what medical conditions are incompatible with MDMA. However, clinical trial exclusion criteria are conservative and designed to reduce unknown variables, regulatory scrutiny, and actual, if uncertain, harm. I think the exclusion criteria indicate that additional caution should be taken but are not all absolute contraindications. In the phase III trials (#textcite(<mitchellMDMAClinicalTrial2>, supplement: [Supplementary Information; p. 5])) "any medical condition that could make receiving a sympathomimetic drug harmful due to increased blood pressure and heart rate" was cause for exclusion, along with additional details for cardiovascular conditions discussed below. Please consult your doctor if there is any question about whether that applies to you. It would be useful to review select parts of the MAPS pharmaceutical investigator's brochure~@mapsInvestigatorBrochure with your doctor.

The trial inclusion criteria did regard some serious medical conditions as compatible with MDMA therapy~@mitchellMDMAClinicalTrial2. #textcite(<mitchellMDMAClinicalTrial2>, supplement: [Supplementary Information; p. 5]) said that "individuals with medical conditions such as hypertension, asymptomatic hepatitis C virus, diabetes mellitus, hyperthyroidism, and glaucoma were eligible, providing the condition was well managed and mild." They couldn't have assessed every type of serious medical condition, so some conditions not on that list are presumably also compatible with MDMA therapy.

#lead[Preexisting health conditions:]
- *Cardiovascular disease:* MDMA increases blood pressure and heart rate, largely between hours 0.75--4 when a single dose is used~@straumann2024racemic. Doses of 120\u{202F}+\u{202F}60\u{202F}mg given roughly 2~hours later increase average blood pressure by 28/12\u{202F}mmHg and heart rate by 23\u{202F}b/min over placebo in therapeutic contexts~@mitchellMDMAClinicalTrial.#footnote[Blood pressure and heart rate are averaged values from the 2nd and 3rd sessions. I excluded the 1st session because it used a different dose.] This may be a risk for individuals with cardiovascular disease. Individuals with "uncontrolled hypertension, history of arrhythmia,#footnote[I suspect that benign premature ventricular or atrial contractions are compatible since \~50% of people have them but I haven't been able to confirm this.] or marked baseline prolongation of QT or QTc interval" were excluded from clinical trials for this reason in #textcite(<mitchellMDMAClinicalTrial2>, supplement: [Supplementary Information; p. 5]). #textcite(<mitchellMDMAClinicalTrial>, supplement: [sec. Methods]) also states that "any medical condition that could make receiving a sympathomimetic drug harmful due to increased blood pressure and heart rate" was cause for exclusion. It's unclear exactly how much of a risk these actually pose, and clinical trial exclusion criteria are conservative.

  People with anything more significant than well managed and mild cardiovascular illness, as assessed by a doctor, might want to make precautions in case there is a problem during the session.
- *Liver disease:* In one case, an individual with advanced alcohol-induced liver cirrhosis tolerated 100\u{202F}mg without issue~@krausCirrhosis. It's unclear how this generalizes to other cases and what the boundaries of safety are. Approach with caution with medical support.
- *Untreated hyperthyroidism:* Rats with untreated hyperthyroidism given MDMA have a much higher risk of dangerously high body temperature~@shokryHyperthyroidism. Individuals with hyperthyroidism were allowed in the clinical trials provided that the condition was "well managed and mild," according to #textcite(<mitchellMDMAClinicalTrial2>, supplement: [Supplementary Information; p. 5]).

#lead[Acute adverse effects:]
- *Hyponatremia:* MDMA commonly causes mild hyponatremia (low plasma sodium concentration) in individuals who drink fluids as desired during the session~@atilaHyponatremia. This effect scales with dose, and doesn't appear important at doses under 100\u{202F}mg (1.4\u{202F}mg/kg average in the study population). I extrapolated from #textcite(<baggottWater>) that drinking a maximum of 0.5\u{202F}L of water during a six-hour#footnote[I chose six hours as the restriction period since Figure 2A of #textcite(<atilaHyponatremia>) suggest that the worst risks of unrestricted water have passed by then.] (single dose) session would easily prevent this. That amount is also more than sufficient for preventing dehydration in the average person at a comfortable temperature~@valtinWater. Taking electrolytes has not been tested as a solution and is known to not prevent hyponatremia in athletic activities~@hew2008statement. Booster doses probably extend the length of restriction.

  People worried about dehydration could fully hydrate two hours before taking MDMA (Matthew Baggott, personal communication, November 24, 2025). That would provide enough time for the body to excrete any excess water by the time the session starts.

  On rare occasion, people on MDMA at raves drink an extreme amount of water and die~@riggDeaths.
- *Heat illness:* Prolonged, intense physical activity in high temperatures combined with dehydration can cause dangerous heat illness, as sometimes occurs at raves~@vanOverheatingAlcohol. Alcohol co-use significantly exacerbates this risk.
- *Seizures:* As with most problems associated with MDMA~@riggDeaths, seizures are very rarely reported~@freidelSeizures. When they are, they are mostly associated with mixing intoxicants, extremely high doses, hyponatremia from drinking too much water, or heat stroke from dancing all night without adequate fluid intake. It's possible that caffeine co-use increases the risk~@vanattouCaffeine.

#lead[Chronic adverse effects:]
- *Valvular heart disease:* Extremely high lifetime use of MDMA and possibly most psychedelics causes valvular heart disease via serotonin 5-$H T_(2 B)$ receptor activation in heart valves~@droogmans2007valvular@tagen2023valvular. In one observational study, 28% of chronic MDMA users showed signs of valvular heart disease (VHD) when evaluated with echocardiography, compared to 0% in a matched control group who reported no MDMA use~@droogmans2007valvular. The chronic users with clinically significant VHD self-reported a mean consumption of 943\u{202F}±\u{202F}1162 MDMA tablets, while the chronic users without clinically significant VHD reported a mean consumption of 242\u{202F}±\u{202F}212 tablets. These results are so imprecise and assuredly confounded by abuse of multiple other drugs and other risk factors that they are inadequate as safety guidelines. Unfortunately, it's the only data I know of. I take the lower number as a "don't exceed" limit after rounding to one significant digit.
- *Oxidative damage:* MDMA causes oxidative damage in the serotonin system when the oxidative load of MDMA's effects exceeds the system's antioxidant buffer capacity~@baggottDamage. #textcite(<baggottSupplements>) states that there is some experimental evidence that doses below 2\u{202F}mg/kg don't cause oxidative damage. Indicators of oxidative damage haven't been investigated at higher doses in humans.

  A dose of MDMA that is not neurotoxic in a single administration can also become neurotoxic when additional session are done before the antioxidant system has recovered~@baggottDamage. Unfortunately, it's not known how long this recovery takes. It's also unclear whether this oxidative damage has any clinically significant effects.
- *Long-term cognitive impairment:* There is limited and contested evidence that many high-dose sessions cause long-term cognitive impairment~@baggottDamage. Unfortunately, it's unclear what counts as high-dose or what the shape of the session-count--impairment curve looks like. The evidence for this comes from a combination of observing inconsistent and mild behavioral differences after giving rats and monkeys extreme doses of MDMA and observational studies of recreational MDMA users. The human observational studies show an association between cognitive impairment and frequent or high cumulative use in recreational contexts. However, those studies rarely adequately control for the fact that recreational MDMA users often use a wide variety of other somewhat dangerous drugs (often mixed), use high doses, use MDMA too frequently, or overheat or get hyponatremia at raves. One of the best observational studies, #textcite(<corayMemory>), narrowed down the association to MDMA in particular, rather than other drugs the users had been taking. However, even that study did not control for the other mentioned factors that are not present in therapeutic contexts. One small randomized study of MDMA therapy did not find any significant cognitive effects after two sessions spaced 3--5~weeks apart using up to 188\u{202F}mg, but that doesn't rule out cognitive effects from a much larger number of sessions~@mithoeferSafety.

#lead[Higher risk groups:]
- *Adolescents:* To my knowledge, MDMA has not been studied in adolescents. Practitioners will have to weigh the unknowns of how adolescents respond to MDMA---possibly consulting medical experts who have experience adjusting adult drug doses for adolescents---against the risks of the clients potentially not getting effective treatment. Skipping booster doses will likely reduce risk. The adolescent's home environment may also be a hostile place to deal with potential symptom worsening and increased sensitivity, given the frequent role of families in creating adolescents' stuck schemas. Practitioners face much greater legal peril offering MDMA to minors rather than adults in places where MDMA is illegal. Greater effort is also needed to help the client develop an informed opinion on risk vs. reward and consent.
- *Pregnancy:* There isn't any high-quality data about humans using MDMA while pregnant. The precautionary principle indicates that it should be avoided until it's rigorously demonstrated to be safe.
- *Breastfeeding:* There isn't any high-quality data about humans using MDMA while breastfeeding. The precautionary principle indicates that milk shouldn't be used while it contains significant amounts of MDMA. #textcite(<bartuLactation>) recommends discarding all milk from the 48-hour period following the use of methamphetamine. Its structural similarity to MDMA and longer half-life might indicate a useful recommendation for MDMA.

== Psychological Risks
<psychologicalRisks>
There is uncertainty about which psychological disorders are compatible with MDMA therapy. These are the exclusion criteria for the phase III trials~@mitchellMDMAClinicalTrial2[Supplementary Information; p. 5]:

#quote(block: true)[
Individuals were ineligible to enroll if they were unable to give informed consent. Individuals were also excluded for a history of or current primary psychotic disorder, bipolar I disorder, dissociative identity disorder, eating disorder with active purging, major depressive disorder with psychotic features, personality disorders, severe alcohol or cannabis use disorder (also moderate if not in remission), any substance use disorder other than cannabis or alcohol within 12~months prior to enrollment … \[or\] serious imminent suicide risk.
]

Clinical trial exclusion criteria are conservative and designed to reduce unknown variables, regulatory scrutiny, and actual, if uncertain, harm. I don't know their reasoning for each item, but have some informed speculation. MDMA therapy induces psychotic episodes on rare occasion, though risk is likely higher in those with a personal history. Amphetamines are a known risk factor for manic episodes. Personality disorders make forming a healthy relationship between a client and therapist difficult to achieve. MDMA therapy might produce overwhelming symptom worsening in people with dissociative identity disorder if it facilitates abrupt confrontation of extremely distressing feelings and perceptions. The trial environment and staff were likely not equipped to cope with some of these conditions, even if they are addressable with MDMA therapy.

Mental illness treatment is highly individualized. Therefore, I don't think most of these conditions are absolute contraindications. Rather, each case should be assessed on an individual basis for its expected reward/risk ratio. Individual practitioners have different capacities for which symptoms they can support in their clients. Client factors include the amount of symptom worsening they can cope with, how capable they are at managing dysregulation, how much their functionality depends on avoiding or muting certain feelings or memories, and how much external support they have.

I know that some people have enough resources, skill, and slack to use solo MDMA therapy to successfully treat debilitating mental illness. Many more people can use solo MDMA therapy to reconsolidate relatively minor issues. High quality support is especially desirable for people with significant risk factors for dangerous conditions like psychosis and mania. However, I recognize that people sometimes have to make the best of bad situations. Solo MDMA with risk factors is sometimes a better option than the available alternatives, though this is highly individualized and I can't make any specific recommendations.

Practitioners should be able to accurately identify each of the following conditions and have a plan to either manage them or get the client to an appropriate higher level of care. I rank these according to my impression of risk, starting from the most significant. See @sectionManagement and @crazy for management recommendations and when and where to seek additional care.

=== Symptom Worsening
Temporary symptom worsening is a common and healthy occurrence in therapy (see @sec:complex). However, if it is intense enough and not managed well, it can severely interfere with your life.

I think that MDMA therapy tends to produce stronger symptom worsening and more rapid therapeutic progress than traditional psychotherapy. Severe trauma, diagnosis of mental illness, and severely non-secure attachment are risk factors. People are sometimes not explicitly aware they have gone through severe trauma. This may happen if the abuse didn't involve any dramatic events, it was explained away as cultural tradition, it happened during the period of childhood amnesia, or it's not remembered for another reason. The therapeutic alliance (see the #citetitle(<BRWAIdownload>) for an assessment scale) is a moderate mitigating factor when working with a mental health practitioner~@fluckiger2018alliance.

I haven't been able to find any data on symptom worsening specific to MDMA therapy. The next best data I know of, #textcite(<evans2023extended>), surveyed people who experienced new, persistent negative symptoms after recreational, professional-therapeutic, and DIY-therapeutic psychedelic experiences. This data applies to all psychedelics, not just MDMA, and a significant part of it only applies to traumatic experiences caused by large doses of hallucinogens like LSD, ayahuasca, or psilocybin. Most symptoms dissipated with time, but 17% of respondents said theirs lasted more than 3~years. From most to least common, participants reported emotional (76%), self-perception (58%), cognitive (52%), social (52%), ontological (50%), spiritual (34%), perceptual (26%), and other (21%) difficulties. These symptoms could be due to
- activation of existing stuck schemas and subsequent defense cascade activation. This is a necessary and healthy part of the therapeutic process if managed well.

  _I think there is a high likelihood of this for MDMA therapy. It's conceivable that a skilled practitioner could help you keep symptom worsening to small, easily dealt with chunks, though I'm skeptical._
- trauma from life impairment or symptom worsening due to poorly managed surfacing of stuck schemas and trauma.

  _This happens~@mdmaExtendedEvans, though the risk can probably be reduced with assistance from a practitioner_~@fluckiger2018alliance.
- trauma from frightening events that occur during psychedelic experience~@calder2025traumatic.

  _This usually results from large doses of hallucinogens, unsafe settings, and abusive or incompetent practitioners. I think that traumatization risk is low for MDMA itself because of its intense feelings of safety and low hallucinatory and mystical effect_~@studerus2010psychometric.
- difficult changes to your understanding of self and existence.

  _I think this is uncommon, however, it does happen_~@ingramMDMA@martinInsight. See @selfinsight for more information.
- something else. I don't know if this exists, and if it does, what it is or how often it occurs.

Even in the subgroup of people who experienced extended difficulties in the previously mentioned study, 90% agreed with the statement "I believe that the insights and healing gained from psychedelics, when taken in a supportive setting, are worth the risks involved" (#textcite(<evans2023extended>, supplement: [Fig. 2])). However, it is possible that a population of psychedelic users who experience debilitating effects was missed due to sampling bias.

=== Psychosis <psychosis>
There is virtually no high-quality experimental data because people with a personal (though not family) history of psychosis were excluded from clinical trials~@mitchellMDMAClinicalTrial2. Like other mental illnesses, psychosis is a complex biopsychosocial phenomenon. Therapy often reduces the symptoms of psychosis~@CBTp, suggesting that stuck schemas often play some role, though how strong that is compared to other factors likely varies by case. This implies that psychosis might start and stop at hard-to-predict points during the reconsolidation process and in life in general for people with some level of predisposition.

A variety of anecdotal reports are congruent with this complex framing~@goodmanPsychosis@redditPsychosis1@redditPsychosis2: A few people state that a single MDMA therapy session triggered a psychotic episode. Four people state that an MDMA therapy session resolved an existing psychotic episode. A few people state that they have safely used MDMA therapy despite previous psychosis, even when psychedelics were major causes of the psychotic episodes.

Psychosis may be difficult to predict, but there are well-known risk factors. High doses and frequent use of a wide range of psychoactive drugs (especially cannabis) is a well-established risk factor~@drugsPsychosis, as is stress~@winkelPsychosisStress. This explains why case reports of MDMA-induced psychosis typically, though not always, report confounding factors like co-use with other psychoactive drugs, chronic abuse of other drugs, heat stroke, hyponatremia, extreme doses, or extreme frequency of use~@psychosisTreatment@arnovitzSchizophrenia@mcguirePsychosis@patelPsychosis@vaivaPsychosis.

Psychedelic-induced psychosis sometimes transitions into schizophrenia, but it's not known how often this happens in MDMA therapy and whether it really causes schizophrenia vs. just accelerating its onset in those who would have otherwise gotten it~@sabeReconsidering.

MDMA-induced psychosis is a risk for those with a predisposition, but some people with risk factors may still think it's worth trying. There are some precautions people with a history of psychosis should take if they try MDMA therapy. You could minimize the known risk factors of stress~@winkelPsychosisStress, cannabis~@drugsPsychosis, and abrupt withdrawal of antipsychotics~@moncrieffAntiPsychotics. Skipping the booster dose of MDMA should also help if the risk is proportional to total dose or length of session. It will also be helpful to, at a minimum, have a responsible sitter who can obtain a higher level of support if you do become psychotic.

=== Suicidal Ideation and Behavior
MDMA therapy with high levels of support decreases suicidal ideation on average about as much as placebo with the same level of support~@mitchellMDMAClinicalTrial@mitchellMDMAClinicalTrial2. When interpreting these results, it is important to understand that average improvements can mask the possibility that a minority of individuals can get worse while the majority improve. Of course, this applies to the placebo group as much as the MDMA group. Suicidal ideation is part of the biopsychosocial complex system of mental health. The psycho/schema component seems particularly influential since suicidal ideation almost always involves accompanying schema-like beliefs and justifications. Suicidality might get worse for a period of time, like many other schemas during the reconsolidation process.

=== Addiction
Three independent panels of drug-misuse experts assessed non-therapeutic MDMA, or drugs sold as MDMA, as having among the lowest risk of dependence and harm among 20 of the most popular illegal or harmful drugs~@nuttDrugHarms@bonomoHarms@crossinHarms. Alcohol and cannabis scored much worse. Significant withdrawal was also not found in one rodent study, even at an extreme dosing schedule~@robledoDependence. Some minor symptoms were noted, but the authors concluded that "chronic MDMA administration does not induce classical manifestations of physical dependence." When MDMA is abused, it is associated with partying or avoidance of difficult feelings rather than therapeutic engagement~@erowidAbuse.

Context is a critical component of addictive potential. Many commonly abused prescription drugs do not cause addiction or harm when used appropriately. The same panels scored several classes of prescription drugs, including amphetamines (some ADHD drugs), benzodiazepines (fast-acting anti-anxiety drugs), ketamine (anesthesia), and opioids (painkillers), as far more harmful than MDMA in non-therapeutic contexts~@nuttDrugHarms@crossinHarms@bonomoHarms. This might indicate that, when used responsibly for therapy, MDMA also has a lower risk of addiction and harm than medical use of those prescription drugs. Congruent with this, no instances of MDMA dependence have been reported in clinical trials~@colcott2024side.

This suggests that the addictive potential of MDMA therapy is minimal for most people. If you are particularly worried about your potential for addiction or have significantly impaired impulse control, I suggest only doing MDMA therapy in structured, practitioner guided contexts. This might include people who have, or are in remission from, serious amphetamine or cocaine addictions who might find the stimulant effects of MDMA close enough to the effects of their abused drug.#footnote[The addiction pharmacology of these substances might share enough similarities with MDMA to warrant caution~@nutt2015dopamine. Other classes of addictive substances have different addiction pathways.]

MDMA therapy has shown tentative promise for improving other addictions. Structured MDMA therapy with high levels of support was well tolerated in individuals with current mild alcohol addiction or early remission of moderate alcohol addiction and did not lead to increased alcohol intake~@nicholasAlcohol. People using MDMA therapy for recovery may be interested in #textcite(<recoveryPsychedelics>), a 12-step program for integrating psychedelics into recovery.

=== Hallucinogen Persisting Perceptual Disorder:
Complex or compelling distortions of external reality on therapeutic doses of MDMA are rare or nonexistent~@liechtiGender. People more commonly have closed-eye visuals, possibly involving traumatic events they experienced. These visuals may be symbolic instead of a realistic reliving. Temporary and mild visual changes such as color and texture enhancement are also common.

Experiences involving a combination of intense fear and visual distortions, like some MDMA and psychedelic experiences, occasionally create persistent visual distortions or anxiety about existing but unnoticed visual distortions~@halpernHPPD. When this causes significant distress or impairment, it is called Hallucinogen Persisting Perceptual Disorder (HPPD). HPPD is strongly, but not exclusively, linked to preexisting anxiety or dissociative disorders and often improves as those are treated. HPPD from MDMA is unrecorded in clinical trials, but some recreational users report it~@vizeliActuteEffects@litjensHPPD. #textcite(<carhart2010user>, supplement: [p. 289]) found that when people report persistent visual or auditory distortions (from MDMA or psychedelics), 73% say "they \[the symptoms\] don't bother me at all," 24% "I'd rather not have them, but I can live with them," 0% "they irritate me," and 1% "they drive me mad".

Given its origin in the combination of fear and sensory perception, I think HPPD is likely one of many possible somatic symptoms of mental illness in the model of #textcite(<berghPsychogenic>) that I expand on in @psychogenic. In that model, the initial experience creates a link between visual distortions and fear. The resulting HPPD would be either fear-driven hyper-focus on normal visual distortions that are typically filtered out of awareness or fear-driven hyper-focus on abnormal visual distortions that the brain recreates as top-down sensory fudging. Either could be treated with reconsolidation.

=== Mania
There is virtually no high-quality experimental data because people with bipolar I were excluded from clinical trials~@mitchellMDMAClinicalTrial2. The MDMA phase III trials did not exclude individuals with bipolar II, and no manic episodes were reported. Bipolar I might have been excluded because psychological stress, sleep disruption, and dopaminergic amphetamines are linked to mania~@salvadoreMania, though MDMA releases much less dopamine than other amphetamines~@kankaanpÄÄDopamine.

Unlike MDMA-induced psychosis, I couldn't find a single published case report of mania where MDMA was unambiguously involved in the recent past. I only found three plausible anecdotal reports of MDMA-induced mania on the Internet that didn't obviously involve major exacerbating factors (overdose, multi-drug abuse, etc.) that aren't present in therapeutic contexts~@erowidMania1@erowidMania2@bluelightMania1.#footnote[I searched for the terms "manic" and "mania" on reddit.com/r/mdma, reddit.com/r/mdmatherapy, erowid.org, and bluelight.org and read every result, or in the case of bluelight.org, read every search result snippet. There were a few additional reports on bluelight.org where people said that MDMA worsened their manic-depressive symptoms, but it wasn't clear that the manic symptoms in particular were worsened.] Two of those people reported preexisting bipolar, and the third was unclear.

This scarcity of evidence suggests that mania is not a significant risk in MDMA therapy. However, absence of evidence isn't necessarily evidence of absence. Thus, there are some risk-reduction precautions that people with a history of mania could take if they try MDMA therapy. Adequate pre- and post-session sleep is critical given sleep's role in mania. MDMA should be taken early in the morning so that it's easier to sleep that night. It would also help to have a short course of sleep aids supplied in advance in case there are post-session sleep issues. High doses of caffeine might be avoided on the day of the session and continue until short-term side effects have dissipated~@laraCaffeine, though abrupt withdrawal would also increase risk. Skipping the booster dose of MDMA might also help if the risk is proportional to the total dose or length of session.

== When to Seek Emergency Care
<when-to-seek-emergency-care>
Most of the interactions that cause severe acute harm are known and can be avoided with proper precautions or by not using MDMA~@riggDeaths@malcolmSerotonin. However, people don't always follow proper precautions or may have undiagnosed health conditions. The direct causes of severe acute damage involving MDMA are almost always high body temperature, hyponatremia, or serotonin syndrome. Cardiovascular events may also rarely occur in people with preexisting cardiovascular issues, especially when MDMA is combined with other drugs associated with cardiac function abnormalities~@makunts2023concomitant.

Many typical symptoms of heat illness, hyponatremia, serotonin syndrome, and cardiac events are also therapeutically appropriate symptoms of MDMA, flight-or-fight, freeze, tonic/collapsed immobility, and confronting extreme fear or anger. Thus, recommendations specific to MDMA therapy are important. #textcite(<malcolmAyahuasca>) recommends seeking emergency care for any of these symptoms of psychedelic/MDMA-facilitated serotonin syndrome: *myoclonic seizures, fever greater than 38.5\u{202F}°C (101.3\u{202F}°F), fluctuating or unstable blood pressure and heart rate, delirium or coma, and muscle rigidity.*#footnote[#textcite(<malcolmER>) further discusses these criteria, but the author lists a lower temperature threshold in this document for unexplained reasons. The 100\u{202F}°F threshold of danger cited there is implausibly low; a moderate dose of MDMA alone can raise body temperature that high, and it is not dangerous~@liechtiTemperature.] Those criteria also catch forms of severe heat illness not caused by serotonin syndrome and some of the symptoms of severe hypovolemic hyponatremia caused by high fluid intake~@merckHyponatremia. However, hyponatremic seizures are not, or not just myoclonic, so *any seizures may also be an emergency*~@nardoneAcuteSymptomaticSeizures2016.

In the absence of MDMA-specific advice, one cardiologist offers this general advice for what type of chest pain you should go to the emergency room for~@chestPain:

#quote(block: true)[
It most often boils down to the severity of the pain and the heart attack symptoms I mentioned above \[largely overlapping with possible MDMA symptoms\]. If the pain is so severe that you feel like you can't function, or if you are experiencing central or left-sided chest pain---especially if you have nausea or a cold and clammy feeling \[also side effects of MDMA~@liechtiGender\] alongside it---it is always safest to go to the emergency room. With chest pain, it's best to be cautious.
]

Additionally, the American College of Cardiology and American Heart Association say that chest pain that is left-sided, dull, aching, central, squeezing, gripping, behind the sternum, or feels like pressure, heaviness, or tightness indicates a high likelihood of cardiac ischemia (inadequate blood supply, often caused by blocked or broken blood vessels)~@ahaChestPain. Stabbing pain is a moderate risk. Pain that is right-sided, tearing, ripping, burning, sharp, fleeting, shifting, dependent on your posture, or related to breathing indicates a low likelihood of ischemia. Of course, ripping or tearing sensations may indicate other immediate problems.

There may be other rare reactions to MDMA; these criteria are not exclusive.

== Common Concerns
<common-concerns>
- *Loss of control:*
  - _Dangerous Loss of Anger Inhibition:_ Three independent panels of drug-misuse experts all judged that the risk of direct and indirect injury to yourself and others associated with MDMA is low compared to other common illegal drugs~@nuttDrugHarms@bonomoHarms@crossinHarms. All three scored it as significantly less than cannabis and far less than alcohol.
  - _Confronting Overwhelming Feelings:_ While this can feel scary, confronting difficult feelings is necessary for reconsolidation. Personal experience and numerous anecdotal reports indicate that MDMA makes this feel more safe.
  - _Losing Touch with Reality:_ MDMA does not produce complex open-eye hallucinations at therapeutic doses~@liechtiGender. Psychosis is rare and mostly occurs when there are other risk factors (see @psychosis).
  - _Post-Session Functional Impairment:_ MDMA therapy increases functionality on average @mitchellMDMAClinicalTrial2@mitchellMDMAClinicalTrial. Anecdotal reports also indicate that major functional impairment is rare. I think functional impairment is an exceptionally difficult instance of the common _it gets worse before it gets better_ phase of therapy (see @sec:complex).
  - _Inappropriate Disclosure or Behavior:_ MDMA notably increases openness. Choose a practitioner who you trust to maintain professional boundaries, not pressure you, and maintain confidentiality (see @sec:howtofind). Solo sessions are also an option. That being said, I'm not aware that MDMA systematically facilitates inappropriate behavior during therapy sessions.
- *Drug stigma/discomfort/misuse:*
  Discomfort with drugs is understandable, since many drugs are harmful. However, the legality of drugs has little relation to their potential for harm~@nuttDrugHarms@bonomoHarms@crossinHarms. Three independent panels of drug-misuse experts all estimated that even non-therapeutic use of MDMA, or drugs sold as MDMA, poses much less overall harm than alcohol or cannabis. They assessed that non-therapeutic MDMA has 8--13% of the harm of alcohol and 22--45% of the harm of cannabis. The different numbers reflect differences in how and where they measured harm.
- *MDMA being synthetic:*
  See #textcite(<ruggeriNatural>) for a nuanced discussion of what natural means. Most illegal MDMA is created by making several chemical changes to the plant substances safrole or piperonal~@worldDrugReport@euMDMA. Legal MDMA may use different processes but is not yet in mass production.
- *Unlearning healthy schemas:*
  I am uncertain whether the contradictory information that facilitates reconsolidation in MDMA therapy comes from other schemas or from sensory input. In either case, reconsolidation tends to create more accurate models of reality. #textcite(<ecker2015misunderstood>, supplement: [p. 28]) states:

  #quote(block: true)[
  When two mutually contradictory schemas are juxtaposed consciously, the schema that more comprehensively or credibly models reality, and therefore more usefully predicts how the world will behave, reveals the other schema to be false, and the falsified one is immediately transformed \[reconsolidated\] accordingly.
  ]

  Thus, I think that reconsolidation generally improves accuracy but is not infallible.

= The Arc of Healing
<bigPicture>
As described in @sec:mechanism, healing is fundamentally a process of aligning stuck schemas with current reality and integrating previously-avoided/muted information.

MDMA-facilitated reconsolidation may cause a straightforward decrease in symptoms and increase in mental health for those with simple issues. However, as described in @sec:complex, those with disorganized attachment or other forms of severe complex trauma face a long process of unpredictable ups and downs that gradually tends upward. MDMA and reconsolidation help you confront previously avoided/muted sensations and emotions. Confronting them may then activate other stuck schemas, producing new fear, anger, sadness, grief, dysfunction, etc. You then have to reconsolidate these newly activated stuck schemas, which might surface still more previously-avoided/muted information. This cycle of reconsolidation → decreased avoidance/muting → reaction → reconsolidation → decreased avoidance/muting → reaction continues until there is no more major avoided/muted information and stuck schemas. Note that this is a simplification of a likely-more complex and inscrutable process described in @sec:complex.

The simplest issues may be resolved in a single session, but my rough estimate is that the most severe mental illnesses require tens of thousands of hours of reconsolidation. This process is necessarily spread out over a long period of time for those with complex trauma because therapy hangover limits active reconsolidation to roughly 2~hours/day in my experience.

MDMA is a moderately scarce resource because of the unclear risk that frequent or high-dose sessions may cause long-term tolerance~@farreTolerance@parrottTolerance, long-term cognitive impact~@corayMemory, and valvular heart disease~@droogmans2007valvular. Thus, I suggest achieving the bulk of reconsolidation with non-MDMA reconsolidation exercises like those described in @sec:moreReconsolidation if possible.

If you want to progress as quickly as possible, I recommend maxing out on reconsolidation exercises whenever you have the time. There are two difficulties to consider, though. First, while you might be able to achieve 2~hours of active reconsolidation a day, that will also create multiple additional hours of therapy hangover. Second, reconsolidation exercises typically require some additional time for the overhead of figuring out what your stuck schemas are and finding mismatches, not to mention all the other tasks involved in practitioner-guided therapy.

If you can, try to develop techniques that require less overhead, like the first one in @internalizedReports. I've also noticed in my practice and that of one person I know that if you reconsolidate right before going to sleep the therapy hangover resolves before you wake up. That minimized the amount of time you spend exhausted.

Unnoticed avoidance and muting and the possibility of complex chains of schema activations make it difficult to assess how much material you need to work through. You could fill out the #textcite(<maladaptiveSchemaScale>) at least once to get a rough inventory of your stuck schemas, though it's not essential. It's a broad scale that should catch a wide variety of common stuck schemas. You can fill out the scale again every few months to track your therapeutic progress. The scale is long, so it may be worth finding and using a shorter, more specific scale (or a subset of #textcite(<maladaptiveSchemaScale>)) if your stuck schemas are limited to certain areas. That will save you time if you're filling it out frequently.

Unnoticed avoidance, muting, and lack of understanding about what improvements are possible also make it difficult to assess when you are done with the process. If you get to the point of thinking you are done or close enough, I suggest working through every item in @mapping during MDMA sessions. Filling out #textcite(<maladaptiveSchemaScale>) may also help. These will help you uncover, understand, and reconsolidate many of the stuck schemas that even mentally healthy people typically avoid dealing with or thinking about. I think it's worth working through most of the items in those sections; just getting to a point of good-enough mental health leaves a great deal of individual improvement and capacity for connection and compassion on the table.

I recommend the following resources for guidance on the long-term process of healing:
- Most therapists who have successfully helped their clients reconsolidate complex stuck schema networks should understand your journey even if they don't have experience with MDMA or use different terminology.
- #prosecite(<kaspianSolo>) is the only other manual that addresses the big picture process of healing with MDMA. I recommend it for the techniques it developed rather than the safety recommendations or commentary.

#lead[When to schedule sessions]
<when-to-schedule-sessions>
It may be especially productive to schedule sessions when you have a few hours of available time most days for the next 1--3~weeks. Some people report that reconsolidation and regular therapy are more productive than normal in this period of afterglow (see @afterglow). Spending a few hours a day paying attention to the emotions that came up during the session may also be particularly useful (see @increasingAttention (Increasing Attention)). I list some ideas for when to schedule sessions in @sessionDecision.

#figure(
  table(
    columns: (1fr, 2fr, 2fr),
    align: center + horizon,
    table.header([], [*Low Session Cost*], [*High Session Cost*],),
    [*Lots of Time*], [Whenever you want, within the safety constraints of @sec:safety. Experiment with different frequencies to see how they affect therapeutic progress.], [When you have enough time to max out on post-session reconsolidation every day.],
    [*Little Time*], [Ideally, when you can make time for post-session reconsolidation, but sessions may still be very helpful without that.], [When you have the most time in your schedule for post-session reconsolidation.],
  )
  , caption: [Example decision matrix for when to schedule MDMA therapy sessions, based on available time and session cost. This represents my informed thoughts and is not based on any rigorous research process. Individuals will need to consider other factors as well.]
  , kind: table
  )
<sessionDecision>

= Working With or Without a Practitioner
<working-with-or-without-a-practitioner>
== Practitioner Guidance vs. Self-Guidance
<professionalVSSelf>
MDMA therapy can be safe and effective in a wide variety of contexts, including therapist-guided sessions with pre- and post-session support~@mitchellMDMAClinicalTrial2@mitchellMDMAClinicalTrial, do-it-yourself couples therapy~@colbertEvenings, and solo therapy~@hillsSolo. Unfortunately, to my knowledge, there is almost no evidence regarding what level of support is appropriate in any particular case. I rely on my experience and anecdotal evidence for the following information and recommendations. I start out discussing factors that favor either practitioner or self-guidance then make a set of recommendations.

=== Factors Favoring Practitioner Guidance
<factors-favoring-practitioner-guidance>
A practitioner may provide
- an introduction to a sometimes-complex process
- an outside perspective on things that are difficult to figure out from a first-person view
- personalized education on trauma, healing, what healthy relational patterns look like, and healthy ways to deal with emotions
- in-session assistance for exercises or issues that are difficult to solve by yourself while in an altered state of consciousness (e.g., PSIP~@razviPSIP)
- expert personalized assistance through the occasionally intense ups and downs of your long-term healing journey. This includes recommendations for or direct assistance with grounding techniques, non-MDMA reconsolidation, session planning, and helping you solve related issues in your life.
- adequately pure MDMA, depending on the provider
- improved medical screening for conditions that might make MDMA particularly risky for an individual, depending on the provider's expertise
- in-session medical monitoring and intervention capacity, depending on the provider. This makes MDMA therapy safer for people with some medical conditions, like severe cardiovascular issues.

=== Factors Favoring Self-Guidance
<factors-favoring-self-guidance>
As discussed in @sec:howtofind, finding a skilled, ethical, affordable, and well-matched practitioner is difficult.

Practitioner guidance is expensive when it's not covered by insurance. In 2026, in the US, a guided psychedelic therapy session including pre- and post-session support costs in the low \$1000s~@cost1@cost2@cost3. MDMA itself only costs 6--50~Euros per gram (in Europe in 2022), which is enough for 5--10 sessions~@euMDMA.

Scheduling is an obvious advantage of self-guidance; you don't need to find a day when your practitioner is also available.

Self-guidance may be the only option for those who have been traumatized by mental health practitioners or who don't trust them.

I suspect that access to a high-quality trip sitter improves the risk and efficacy of MDMA therapy in many cases. Sitters aren't replacements for practitioners, but could make effective solo sessions significantly more accessible. The sitter should be trustworthy, empathetic, and emotionally non-reactive~@thalSitter.

As discussed in @suicideCops, some licensed practitioners may call the cops on you if they think you are at high risk of imminent suicide, hurting someone, or are so psychotic that you might do one of the former accidentally. Involuntary commitment can be traumatizing and often actually _increases_ the risk of suicide and hurting other people.

Practitioners who are ethical and skilled but whose style or personality are not a good match for you should be easy to approach about this mismatch. They might even recommend any colleagues who they think would be a better match. The risks inherent in working with an ethical and skilled practitioner who you don't match well with mostly involve wasted time and money. However, the risks of unethical or unskilled practitioners can include
- emotional, physical, financial, or sexual abuse
- unnecessary dependence on the practitioner
- increased risk of overwhelming symptom worsening
- demoralizing ineffective treatment
- false beliefs of abuse~@Scoboria07022017 or false beliefs about how trauma and mental illness work

=== Recommended Models
<recommended-models>
- Start off with a practitioner who is MDMA-trained or personally experienced with the complexities of MDMA therapy. Transition to self-guided sessions with as-needed therapy sessions with your provider when you and your clinician collaboratively decide that you sufficiently understand the process of MDMA therapy and can handle difficulties by yourself or with a sitter.

  _I think this is the ideal model for most people who can access a skilled, ethical, affordable, and well-matched provider. It offers dramatically lower costs than continually working with a provider, and there are numerous anecdotal reports of people (including myself) finding it safe and effective._
- Work with a non-MDMA-trained practitioner and collaboratively assess your readiness with them. You might read @psychologicalRisks together. If your reward/risk ratio is high enough, you then self-guide all your medicine sessions while maintaining as-needed therapy sessions with your clinician. You also use high-quality resources to educate yourself on the nuances of effective and safe MDMA therapy and use a high-quality sitter as appropriate, which includes at least the first several sessions.

  _I think this model is more difficult and riskier than the previous option, but still reasonable for most people who can't access the right provider or already have a trusted non-MDMA-trained provider._
- Self-guide all your sessions and do all of your own between-session work, perhaps talking about your healing journey with emotionally skilled friends or friends skilled in safely using MDMA for healing. You also read high-quality literature on trauma healing and MDMA therapy (like this book) and use a trusted sitter for at least the first few sessions unless you have prior experience with psychedelics.

  _I think this model is reasonable for people who have the capacity to work through intense and difficult emotional experiences._
- Continually work with an MDMA-trained practitioner.

  _This model is the only one that has been investigated in clinical trials, where it was shown to work well~@mitchellMDMAClinicalTrial2. I think this model is important for people with a personal history of recurrent psychosis or mania that the individual cannot manage by themselves. A practitioner who has experience with these states can provide valuable reality testing and guidance in case MDMA therapy activates either of these symptoms. This model may also be necessary for people with a severe lack of impulse control and escapist habits or a serious addiction to cocaine or amphetamines who might abuse MDMA if they had their own supply._

I don't recommend self-guiding without high-quality reference material and an understanding of the nuances of safe and effective healing. The lack of an accurate framework to contextualize the variety of experiences in MDMA therapy impairs safety, efficacy, and your ability to fully access the possible benefits.

== How to Find a Practitioner
<sec:howtofind>
Practitioners vary widely in skill, ethical behavior, and how good a fit they are to your needs. Choose one carefully; many practitioners have appeared in the news for harming their clients~@hallMad. Some are even members of groups that practice organized abuse. I strongly recommend using #prosecite(<safetyFlags>) to evaluate the practitioners you are considering working with. I also strongly recommend using the #citetitle(<BRWAIdownload>) to evaluate the quality of your therapeutic relationship. This quality has a moderate impact on the effectiveness of therapy~@fluckiger2018alliance.

Licensure may offer a mediocre amount of protection against harm and incompetence. Licensed clinicians have usually had background checks, a couple of years of typically so-so education, and a few years of pre-licensure clinical experience. There are also subject to formal complaint processes.

#link("www.reddit.com/r/mdmatherapy") maintains a list of practitioner directories and referral services in the sidebar (on the new Reddit; not old.reddit.com). I have not vetted most of them. You may also be able to find practitioners by talking to people at psychedelic meetups.

See the following for further information about harm in the psychedelic community:
- #prosecite(<abuseLetter>)
- #prosecite(<hallMad>)
- #prosecite(<brown2020ethical>)

== Involuntary Inpatient Commitment
<suicideCops>
Licensed practitioners are often legally obligated to call the police on you if they think you are at high risk of hurting someone or are so psychotic that you might do so accidentally. They might also coerce you into going to hospital yourself under explicit or implicit threat of calling the police on you. In practice, what the practitioner does depends on their possibly flawed interpretation of local laws, how much they fear being sued or losing their license if someone is hurt, and how much they believe hospitalization will help you. Practitioners may also call the police on you, or threaten to do so, for suicidal ideation or planning. If you are suicidal or fantasize about hurting your abuser, I strongly suggest asking your provider to elaborate on their decision criteria before you open up to them. Then you can decide if you can cope with the level of self-censorship necessary to not cross their boundary. Or, you may trust your provider enough that you can be completely open with them because you know they will only tell you to go to the hospital if you really need it. In that case you could write up a crisis plan involving which hospital you want to go to, which family members or friends you want notified, etc.

If your provider does call the police on you, know that police typically have little training in mental health and will likely take your provider's word over yours~@alexanderInpatient. There is also a good chance that the police dragging you away against your will to a place you can't leave---where medical staff may do various invasive and non-consensual things to you---will traumatize you. Even worse, #textcite(<emanuelHospitalization>) found that (at least in Allegheny County) involuntary hospitalization actually significantly increases the chance of a patient dying by suicide or overdose or being charged with a violent crime over the 3~months following admittance. This only applied to cases where clinicians might disagree about admitting a patient (43% of evaluations in this study). It's not clear how well these results apply to situations where multiple clinicians would all agree on admitting a patient.

#textcite(<alexanderInpatient>) is a good guide for navigating/avoiding the inpatient mental health system.

Involuntary outpatient commitment is also often abusive~@croftAOC, and there is no evidence that it's more effective than voluntary treatment~@kiselySystematicReviewMetaanalysis2025.

= Pre- to Post-Session
<pre--to-post-session>
== Pre-Session Checklist
<prep>
MDMA is not inherently therapeutic; the effects of a session depend on your mindset and the external setting. Many people also use MDMA for escapism~@moonzweEscapism or fun and social connection~@huntPleasure. This section describes mindsets and settings that facilitate reconsolidation. I also discuss tools for the session and preparation for the post-session.

=== Mindset
<mindset>
- Working through @mapping can help you identify schemas to work on during the session if you don't already have something in mind.
- I think opioid dampening and avoidance are the primary obstacles to healing during a session. Learning about these beforehand can help you recognize and deal with them during the session. Refer to @sec:sessionbarriers and @sec:defensecascade.
- Set an intention to face and stay present with whatever fear, anxiety, anger, grief, etc. comes up, without avoidance or distraction. Anecdotal reports also suggest that more specific intentions are also helpful, like intending to work on a particular issue.
- Writing down the challenges or emotional difficulties you would like to address during the session can be helpful for bringing stuck schemas into awareness during the session. However, be cautious about specific expectations about what you want out of the session, how you think it should go, or what you will learn. These expectations often do not match up with reality and can become ways to avoid reconsolidating the stuck schemas that are actually present. I suggest an attitude of "this belief and emotional reaction may or may not be true or helpful; I will stay present with my feelings to learn why the schema exists and how it influenced me."
- I speculate that types of meditation based on noticing distressing feelings and allowing them to exist, like #textcite(<rain>), may help you reduce avoidance, muting, and distraction during the session. Anecdotal reports also indicate that meditation helps.
- Catch up on sleep if possible. Therapy requires energy and focus.
- Anecdotal reports suggest that preparatory therapy can make sessions more productive, though many people have success without it.

=== Setting
<setting>
- Sessions generally start in the morning because MDMA's stimulant effect can prevent sleeping when done later in the day~@berro2018acute.
- Some people experience nausea, so avoiding eating before the session or only eating a light meal a few hours prior is helpful~@colcott2024side. Taking medicine with food also delays the onset of the effect.
- Prepare a light meal or snack to eat a few hours after the initial dose. MDMA can make processed or oily food taste worse#footnote[MDMA seems to deactivate cravings, so you're left with the actual present-moment sensations of eating, which are unpleasant for many foods.] but fruit is famously good.
- Only drink a maximum of 0.5\u{202F}L of water during the session unless you need to replace a lot of sweat, as discussed in the Medical Risks subsection of @sec:safety.
- #metadata("anchor") <contextexpansion> Once you're experienced with MDMA therapy, carefully expanding your session environment to include triggers could help focus your reconsolidation on that issue. If you have dog trauma, you could pet a dog who you know won't act aggressively and whose human is nearby to manage them if you feel like the experience is too overwhelming.
- Solitude, except for a trusted and experienced practitioner or sitter, promotes inward focus. Your session environment should also be comfortable and safe.
- A sitter can help with logistics, listen to your feelings, or handle mundane events like someone knocking at the door~@thalSitter. They can also help you stay on task if you get distracted. Sitters should possess trustworthiness, emotional non-reactiveness, and empathy. Interacting with strangers may cause problems if they do not understand what is happening.
- Pets can be a source of comfort but shouldn't be distracting.

=== Tools
<tools>
- Anecdotal reports describe how some people like to self-narrate the session and record the audio with their phone. They feel that listening to or transcribing it facilitates therapeutic progress.
- #textcite(<liechtiInteractions>) recommends domperidone for nausea (10\u{202F}mg max at a time; 30\u{202F}mg max over 24\u{202F}h) if needed.
- Eye shades and noise-canceling headphones can reduce distractions.
- MDMA can cause jaw clenching and headaches~@mitchellMDMAClinicalTrial2@liechtiGender. Some people use mouth guards or pacifiers to reduce this effect or protect their teeth~@emdeEmergency. #textcite(<liechtiInteractions>) says that acetaminophen and NSAIDs are compatible with MDMA. However, NSAIDs can irritate empty stomachs, and people often do not eat before and during MDMA therapy.
- The Fireside Project offers a hotline to help people through challenging psychedelic experiences at #link("tel:+1 (623) 473-7433") in the United States~@firesideProject. Consider putting this number in your phone as an additional layer of safety. They also offer a "TripCheck" feature where they will call you at a scheduled time.
- Anecdotal reports indicate that people can reactivate the MDMA state of consciousness after the session via cues that were present during the session (see @internalizedReports). This could be very helpful for additional reconsolidation. While the cues in the reports were meditation and visual imagery, distinctive scents, music, and rituals may also work. You might, for instance, burn incense.
- People often use emotionally evocative music to help them engage with their stuck schemas. Searching for "MDMA therapy" on your music streaming service will show many playlists made for this purpose.
- Some people prepare a half-strength booster dose to take 1.5--2.5~hours after the first dose to extend the duration of the session~@mitchellMDMAClinicalTrial2. See @sec:dosing for more information. I think that a booster dose may help in case you get stuck in overwhelm, avoidance, muting, or some instances of opioid dampening.

=== Preparation for the Post-Session
<preparation-for-the-post-session>
- People frequently feel fatigued and low mood for 1--3~days after the session~@liechtiGender. Prepping food and a comfortable place to rest in advance may be helpful. I suggest keeping the whole following day free of responsibilities. Having the option to take a sick day on the second following day would be helpful.
- Spending a lot of time doing reconsolidation exercises and bringing attention to your feelings in the days-to-weeks after a session may be especially productive and worthwhile (see @sec:moreReconsolidation). This is commonly called _integration,_ though really all reconsolidation (in and out of session) is a process of integrating new information into your schema network.
- I recommend planning to try different techniques for resolving issues with the process (see @sec:troubleshooting) on subsequent sessions if you're worried about MDMA therapy not working.
- If you feel particularly vulnerable to symptom worsening, consider arranging to have someone spend a couple of days with you.

== Reconsolidation Barriers: Avoidance, Muting, and Opioid Dampening
<sec:sessionbarriers>
Avoidance, muting, and opioid dampening (introduced in @attention\; henceforth called barriers) are difficult to deal with because they impede reconsolidation, including reconsolidation of the very schemas that create them. This section focuses on techniques that loosen this self-reinforcing state of stuckness. I group the three effects together because they both inhibit conscious experiences of contradiction, a requirement for reconsolidation, I think they are dealt with similarly, and it may not always be clear which one is present.

#textcite(<razviPSIP>) reports that successful experiences of engaging with stuck schemas (my interpretation) in the presence of dissociation (an effect of these barriers) make the process much easier in subsequent sessions. I think it is a skill primarily learned through experience. Therefore, this section is mostly focused on facilitating successful experiences and building this skill.

The spectrums of these barriers are not well understood, and it may not always be clear which one you are in. For instance, #textcite(<razviPSIP>, supplement: [p. 10]) reports a state sometimes encountered during MDMA therapy where a person "may have very little or no response to substances as powerful as MDMA or psilocybin. They will feel sober, or bored or sleepy as if they could get up and go about their day. If a therapist wasn't in the room, they might fall asleep during the height of an MDMA session." Soberness and boredom are neither effects of immobility nor MDMA. This suggests there might be at least one more poorly understood form of these barriers or some other phenomenon. These reports may also reflect the interaction between MDMA and barriers.#footnote[I've experienced the sleepiness that #textcite(<razviPSIP>) discussed with and without MDMA, so MDMA doesn't seem to be a necessary condition.]

I group the interventions listed here into two categories: deactivating the schemas that produce these barriers by increasing feelings of safety, and paying better attention to stuck schemas in the face despite the barriers. This grouping is done for organizational simplicity even though the attractor state is naturally circular. For instance, increasing safety leads to decreased barriers, which facilitates reconsolidation of the stuck schemas producing the barriers, which makes further reconsolidation easier, etc. Alternatively, starting with increased attention can lead to reconsolidation, which then reduces the barriers, etc.

MDMA combined with deliberate therapeutic introspection is often sufficient to deactivate the barriers or reconsolidate the schemas that produce them if they aren't too strong~@razviPSIP. The threat and powerlessness schemas causing opioid dampening are already highly activated, so you probably can just try to feel whatever is already present rather than trying to reconsolidate specific schemas. You might notice schemas like "I'm dying right now," for instance.

Resolving opioid dampening sometimes leads to flight-or-fight~@kozlowskaDefenseCascade, which in my understanding, is easier to deal with on MDMA.

=== Increasing Safety
<increasing-safety>
- A skilled and ethical practitioner whom you work well with, and who understands how to work with barriers.
- Anecdotal reports indicate that, depending on the circumstance, either lower-than-standard or higher-than-standard doses may help. It's not clear which is the right choice for any particular situation. I speculate that if the MDMA doesn't increase your dissociation over your baseline, a higher dose would help. If the MDMA increases your dissociation, then a lower dose or other tools would be necessary.
- Non-sexual touch from a trusted person.
- Bringing a non-distracting pet or treasured stuffed animal into the session.
- Altering your environment in other ways that help you feel safe.
- Much of this book describes how to activate your schemas so you can then reconsolidate them. You might be activating them too strongly. You could try starting with a very mild activation, or if that doesn't work, partially distracting yourself. Grounding exercises might help with this. See @sec:grounding.

=== Paying Attention
<paying-attention>
The goal of these items is emotional engagement with stuck schemas. This is a requirement for therapeutic reconsolidation~@ecker2015misunderstood. Intellectual or abstract thinking about the schemas isn't sufficient.
- Paying attention to, and feeling, the content of the avoidance. What does the schema fear will happen if you feel the thing you're avoiding? What is the inner monologue saying right now?
- Paying attention to the imminent threat and powerlessness schemas that produce opioid dampening. How do they feel?
- Anecdotal reports indicate that people often over-focus on trying to get to a big traumatic memory or on some mental activity other than paying attention to the stuck schemas that are actually most active and available for reconsolidation. These are often things like "it doesn't work for me," or some subtle fear or anxiety. Pay attention to those schemas and feelings they create; the MDMA will reconsolidate them, and then you can work on other things.
- A practitioner who understands how to work with these barriers can help you notice and pay attention.
- Mindfulness practices of noticing and paying attention to your experiences as objects separate from yourself. See #prosecite(<rain>) and #prosecite(<bodyscan>). Therapy contains similar practices, varyingly called _cognitive defusion,_ _unblending,_ _decentering,_ or _disidentification_.
- #textcite(<razviPSIP>) reports that a technique they developed called _selective inhibition_ is highly beneficial.

  The technique involves two parts. First, you suppress all voluntary distractions, avoidance, calming techniques, and coping strategies. These are things like thoughts and small movements. Second, you focus attention on the subtle signs of distress or opioid dampening in your body and mind. This might be muscle tension; fast or slow breathing; involuntary movement impulses; fear; anger; hopelessness; or irritation. For strong opioid dampening, these sensations may at first just be blankness, flat affect, nothingness, boredom, sleepiness, or sobriety. Like in meditation, these sensations are focused on just as they are, without trying to interpret or alter them.

  After a period of focus, and presumably reconsolidation,#footnote[#textcite(<razviPSIP>) doesn't frame the process in terms of reconsolidation, but I think it is clearly facilitating reconsolidation.] during which the sensations may grow and dissipate in wave patterns,#footnote[I speculate that each wave is the activation and reconsolidation of an individual schema that produces opioid dampening.] the opioid dampening recedes and transitions to flight-or-flight. Depending on the strength of opioid dampening, anywhere from minutes to a full day-long session of selective inhibition is needed.

  This is the core process in their therapeutic method called psychedelic somatic interactional psychotherapy (PSIP). I am unclear how achievable this process is in solo MDMA therapy without a practitioner skilled in the method.

  An MDMA booster dose can extend the session to deal with particularly resistant opioid dampening.
- A trip sitter can remind you to stay focused, though they might not have the skill to help you navigate intense barriers. They should be trustworthy, emotionally non-reactive, and empathetic~@thalSitter.
- People often use emotionally evocative, non-distracting music to help them engage with their stuck schemas. Searching for "MDMA therapy" on music streaming services will show many playlists made for this purpose.

=== Other Options
<other-options>
MDMA therapy may not always be able to resolve dissociation. Saj Razvi, founder of the Psychedelic Somatic Institute, recommends that people with strong dissociation will find MDMA therapy more productive if they start with three sessions of cannabis-assisted PSIP (Personal communication, Saj Razvi, Jan. 2, 2026). They find that cannabis is a particularly good complement for selective inhibition, possibly because it impairs voluntary control of the experience~@razviPSIP, though I think that factor might also make the process more difficult to do solo. The #citefullauthor(<psipDirectory>) maintains a directory of therapists~@psipDirectory.

// Commented out in the LaTeX edition (original LaTeX):
// Opioid-blocking drugs may be an additional option for opioid dampening. There is low-quality evidence that 50--250\,mg of the opioid blocker naltrexone deactivates opioid-mediated states, like immobility and freezing~\cite{escamilla2023treatment}. Naloxone and nalmefene have similar mechanisms of action and could also work, though this has not yet been demonstrated. Naloxone's half-life (1--2\,hours~\cite{saariNaloxone}) may be more appropriate to MDMA therapy than naltrexone's (4--10\,hours~\cite{crabtreeNaltrexone}). Naloxone is also often available without a prescription and is very safe. I could not find any anecdotal reports of combining opioid antagonists with MDMA. One possible challenge is that opioid blockers blunt the subjective effects of amphetamine, and therefore possibly MDMA, for unknown reasons~\cite{jayaramNaltrexone}.

== The Therapeutic MDMA Session
<session>
The effects of a single MDMA dose are generally noticeable 30~minutes after taking the medicine, peak an hour after that, and then last a further 3~hours before gradually dissipating~@vizeliActuteEffects. Those with genetically or pharmacologically low CYP2D6 metabolic capacity peak earlier and higher, though any differences disappear by hour 3--4~@schmid2016cyp2d6. Food delays the onset of effects~@MithoeferMDMA.

A half-strength booster dose taken around 1.5--2.5~hours after the first is often used to extend the productive duration of the session (by about one hour~@humbert-drozComparisonAcuteEffects2026)~@mitchellMDMAClinicalTrial2. Besides the booster dose, anecdotal reports indicate that people sometimes take more MDMA than they were originally planning to because of anxiety about the session not being what they expected or feeling like the medicine isn't working. I think taking additional medicine is most justified if
- you want to extend the productive duration of the session, as is common practice
- you took a lower-than-standard dose and want to increase it to a standard dose (see @sec:dosing)
- after hour 1.5, when the effects normally peak, you are having difficulty engaging with or reconsolidating stuck schemas, and the techniques in @sec:sessionbarriers aren't working

The upper safe limit of MDMA is unknown. As described in @sec:dosing, I advise caution above using a total dose of 2\u{202F}mg/kg per session for more than a handful of sessions. It is difficult to accurately measure the right amount of MDMA while you're panicking or in an altered state of consciousness, so you could prepare the additional dose, and the regular booster dose, in advance.

Many first-hand reports of successful MDMA therapy can be found on the top posts on #link("https://reddit.com/r/mdmatherapy/top/?sort=top&t=all"). The top posts mostly describe productive sessions that don't contain strong opioid dampening, muting, avoidance, or overwhelming symptom worsening. You can see descriptions of less productive or more disruptive sessions by sorting by _new._#footnote[#textcite(<godes2023perceived>) also lists common self-reported experiences of MDMA therapy clients: staying with what "is"\; decreased reactivity; insight, reflection, linking; mental clarity; recovery of traumatic \[episodic\] memories; disentangling trauma from self; reuniting lost affects and parts; self-acceptance; joy, happiness, gratitude; hope and empowerment; relaxation, calmness, peace; comfort; gratitude, compassion, empathy; union, wider perspective; inner healing intelligence \[the therapeutic framework used in this study\]; accessibility to emotions; and mind-body connection.]

=== Session Timeline
<session-timeline>
#lead[Come-up]
The effects of MDMA become noticeable, but you are not yet deeply engaging with stuck schemas. Some users experience anxiety~@hillsSolo. This might be misinterpreting MDMA's stimulant effects as anxiety, early engagement with schemas that generate distress, or fears about the session.

#lead[Peak]
Reconsolidation is possible here. Connection and safety become pronounced, though this may be unnoticeable if schemas creating distress are also active, you are avoiding/muting the experience, or you are in opioid dampening. In my experience, MDMA therapy can work even if you do not feel MDMA's classic love#footnote[MDMA is known for exceptional feelings of love, and I suggest refraining from telling anyone how much you love them unless that is an established norm in your relationship.] and safety. See @acuteEffects for a list of physiological and some subjective effects.

Anecdotal reports indicate that people frequently experience mind's-eye images of therapeutically relevant content.

#lead[Comedown:]
You may still feel high, but engaging with painful emotions is more difficult, and reconsolidation may no longer be achievable. Personal experience and anecdotal reports indicate that people can be disappointed by how hard it is to be present with and reconsolidate difficult feelings again.

#lead[After-effects:]
See @table:sideeffects for how side effects change as the drug wears off. Some of them can persist up to 3~days~@liechtiGender.

=== Therapeutic Technique
<therapeutic-technique>
First, if you're experiencing okay-ness and self-love for the first time or are seeing how trauma shapes the world, I recommend engaging with that and not trying to refocus on engaging with negative emotions created by stuck schemas. This experience can be a preview of the end goal of therapy and can be a great motivator for staying on the healing journey long-term through challenges. The peace and compassion may not last long after this first session, but you will gradually get some of it back as you reconsolidate various stuck schemas over the long term. Regular life is rarely total bliss, but reconsolidation does gradually improve life over the long run. If you find yourself repeating these blissful experiences on subsequent sessions, I recommend refocusing on your stuck schemas. Repeat exposure likely has declining marginal return even if the love and okay-ness feel wonderful.

The first main activity is emotional activation of stuck schemas,#footnote[Some people think insight is the primary goal during MDMA therapy, but I disagree. Insight is important for conventional psychotherapy, where it's often helpful to know what the schema is before you reconsolidate it~@eckerUnlocking. I don't think this is critical in MDMA therapy, where you can skip straight to reconsolidation without knowing what the schema is first. In my experience, insight can be gained through post-session reflection. This reserves scarce session time for difficult reconsolidation.] a prerequisite for reconsolidation~@eckerUnlocking. In other words, you're "triggering" yourself. You can do this through
- just thinking about your issue or telling your sitter or practitioner about your issue
- looking at or listening to relevant material like photographs, letters, voicemails, etc.
- practices like careful movement, yoga, stretches, or body scan meditation, which can activate and focus attention on body-related stuck schemas. #prosecite(<bodyscan>) is one way to do this, though in MDMA therapy you wouldn't release attention from a sensation that is still activating your stuck schemas.
- engaging in, or imagining engaging in, safe activities that activate the relevant schemas. This could be writing if you have a writing block caused by stuck schemas or giving a presentation to a few trusted friends to reconsolidate a schema causing stage fright.
- speaking with your partner about a conflict in your relationship or an insecurity you have about your relationship~@colbertEvenings
- working through the prompts in @mapping, which I highly recommend after you resolve your primary issues

Often, a stuck schema is already activated. I think this is the case if you feel any anxiety, fear, anger, sadness, or grief, or are immobile. You may nor may not also notice other symptoms of the schema at this point. I've had many experiences in MDMA therapy where I notice the emotion first, and the belief component only becomes clear after some amount of reconsolidation.

The second main activity is staying present with, and leaning into, that distress. Personal experience, observations, and many anecdotal reports suggest that once you're emotionally engaged and aren't distracted, the MDMA usually reconsolidates the schema without any further action. Because of this, I think that therapeutic exercises that facilitate reconsolidation, like coherence therapy and acceptance and commitment therapy, likely won't help beyond their function of activating or engaging with stuck schemas. Abstract thinking tends to be an impediment; sometimes reconsolidation still works if your stuck schema remain emotionally activated and you are at least partially focused on them.

You might also _investigatively feel_ how the schemas and symptoms change as you move, as your thoughts and triggers change, or as the schema reconsolidates.

In my experience, people with complex trauma can spend the whole session quickly transitioning from one stuck schema to the next as each one reconsolidates.

As discussed in @science, stuck schemas generate beliefs like "if I move I will die" and emotions like fear, anger, or sadness. Bodily expressions of that emotion may also be present, like bared teeth in rage. Episodic memories of related events are sometimes also recalled at the same time, though this isn't necessary for reconsolidation. Schemas can also generate inaccurate perceptions of bodily sensations (e.g., pain, itching) and movement ability (e.g., an inability to make a certain movement when your body is physically capable of it).

You can notice a stuck schema is activated by the presence of one or more of these components. Since the stuck schemas addressed in therapy typically involve intense distress, you will also notice your attention focusing on the perceived threat. This may take the form of rumination or looking for the perceived threat.

Insightful thoughts about yourself, how trauma impacted you, and the human condition may arise. Spend time on them if they feel cathartic or important, particularly if you feel emotionally engaged rather than just intellectually interested. Otherwise, leave them until after the session.

Sometimes people shake, move in other ways, or vocally express intense fear/anger/sadness/etc. I don't know what the shaking fundamentally is. It might be a flight-or-fight activated by putting attention on previously avoided/muted sensations or memories. It might also be whatever is happening when people shake while crying in regular life. Unusual vocal expressions of intense emotion might be the natural expression of those emotions that comes out when people don't try to suppress it or make it more socially palatable. Maintaining emotional engagement with the underlying schema should reconsolidate the schema and resolve any reactions it is causing.

Anecdotal reports indicate that some sessions focus primarily on somatic sensations without significant emotional engagement. Our framework does not clearly explain these sessions. People varyingly report them as helpful or unhelpful.

=== Barriers to Reconsolidation
<barriers-to-reconsolidation>
You may feel what is called resistance. This is an impulse to avoid/resist the therapeutic process because some schema predicts that it is dangerous. While the protective function of these schemas may have been important at one point, they are likely now an impediment. I suggest focusing on the resistance schemas first if you can. Reconsolidating these will make the rest of your therapeutic efforts much easier, as you won't have to fight against a part of your mind telling you to stop what you're doing.

It is well-known that over-attachment to a specific therapeutic goal can impede progress. This might happen because reconsolidating certain schemas often depends on reconsolidating some other schema, sometimes one you are unaware of, first. People also frequently have inaccurate beliefs about what their issues are or what is causing their issues. Because of this, I recommend that if you don't feel like you are making significant progress on your target issue, try noticing and focusing on any fear, anger, grief, anxiety, discomfort, or tension in your body or field of awareness. Reconsolidating the schemas driving this distress may be an "access point" to the whole knot of stuck schemas in your life.

Spiritual bypass is a trap people occasionally fall into. As #textcite(<cashwell2007Bypass>, supplement: [sec. Spirituality and spiritual bypass defined]) states, spiritual bypass "occurs when a person attempts to heal psychological wounds at the spiritual level only and avoids the important (albeit often difficult and painful) work at the other levels, including the cognitive, physical, emotional, and interpersonal." For instance, you might feel that MDMA has allowed you to transcend your emotional limitations and that reconsolidation is no longer relevant. While genuine spiritual attainments seem possible~@ingram2018mastering, and MDMA may occasionally facilitate them~@ingramMDMA, #textcite(<ingram2018mastering>) doubts that transcending emotional limitations is possible. I suggest treating such beliefs as a form of avoidance. Look for subtle feelings of fear while considering the possibility that your transcendence is not what you imagine it is.

Some people also feel that they are receiving a message from the medicine (e.g., "the medicine has done all it can do for me, and now I need to focus on some specific practical aspect of my life")~@razviDissociation. Many life changes are important for mental health. However, it may be difficult to distinguish whether such messages are a form of avoidance vs. actually needing to shift focus from reconsolidation to other changes. I suggest spending one more session looking for stuck schemas to see if MDMA really has done all it can for you.

Similarly, in anecdotal reports, people sometimes experience certain perceptions or beliefs arising in the session as deeply true, when in fact they are not. These can feel like "prophesies" about future events (which often end up not actually coming true). You might also think "\[insert political or religious belief\] really is correct!" People with contradictory religious or political beliefs can each think their belief is the true one. The contradictory positions cannot all be true; thus, having the feeling that a belief is true doesn't mean that it is. I advise treating all such experiences like dreams; they might be linked to important things in your life and can feel important in the moment but are mostly unimportant mind noise. Psychedelics inflate feelings of meaning~@hartogsohn2018meaning, and MDMA has relatively mild~@studerus2010psychometric and inconsistent~@effectindex psychedelic effects.

If you feel "blankness, flat affect, nothingness, boredom, sleepiness, or sobriety," you are likely dissociating (either unnoticed avoidance, muting, or opioid dampening in my opinion), according to #textcite(<razviPSIP>, supplement: [p. 14]). Refer to @sec:sessionbarriers for more information.

=== Crisis Management
<crisis-management>
If you panic or are planning to hurt someone or yourself, leaning into and staying present with those feelings (without acting upon them) as much as you can manage can reconsolidate the underlying schema. Of course, since healing is often a complex process, reconsolidating part of a schema may also result in temporary symptom exacerbation. If those schemas are too overwhelming to stay present with, more MDMA or another source of comfort, like holding the hand of a loved one or therapist, may help.

You can also call the Fireside Project hotline at #link("tel:+1 (623) 473-7433") if you require help and live in the United States, though they can't support people considering suicide and presumably violent intent~@firesideProject.#footnote[I couldn't find any services similar to @firesideProject in other countries.] You could also use #link("https://tripsit.me/webchat"), a chatroom available anywhere.

You might also ask for help from your sitter or practitioner to keep yourself safe. Note that if the person with you is a licensed medical professional, they might call the police on you if you tell them about intense acute suicidal or violent desires. See @suicideCops for more discussion of this. Involuntary hospitalization and police involvement carry a high risk of traumatizing you further and may actually significantly _increase_ the medium-term risk of suicide and hurting someone else~@emanuelHospitalization.

=== Therapy Hangover
<therapy-hangover>
People can only do so much reconsolidation in a day before they become emotionally exhausted. This is commonly called a therapy hangover, though a therapy hangover on MDMA may not feel like a regular psychotherapy hangover because the drug effects are also present. To my knowledge, the phenomenon hasn't been formally studied. Personal experience and anecdotal reports suggest that it dissipates within a few hours to a couple of days. It can be the limiting factor for session length.

Personal experience suggests that higher doses facilitate faster reconsolidation and faster therapy hangover than lower doses. If you feel exhausted, I recommend staying with that feeling for as long as possible, since it may be difficult to distinguish between therapy hangover and opioid dampening. Furthermore, MDMA sometimes gives people a "second wind" of reconsolidation after a period of therapy hangover.

=== A Precaution Against Life-Altering Decisions
<a-precaution-against-life-altering-decisions>
MDMA therapy can highlight aspects of your life that you want to change. However, immediately post-session, this new view can be unbalanced by other considerations. Your insight is very new, possibly not fully fleshed out, and you may be in afterglow, an altered state of consciousness. I suggest waiting at least until the afterglow ends before making major decisions so that you have had time to think it through and are back in your normal state of consciousness.

== Troubleshooting
<sec:troubleshooting>
Unless otherwise stated, the possibilities in each section are not listed in any order. They're not decision trees, just things that you can consider.
\ \
#lead[Section outline]
#local-contents(<sec:troubleshooting>, <afterglow>)

=== Numbness, Immobility, Heaviness, or Sleepiness
<numbness-immobility-heaviness-or-sleepiness>
I think these are likely tonic/collapsed immobility or something closely related, based on #textcite(<razviPSIP>). See @sec:signsofdc for a list of other symptoms and @sec:sessionbarriers for recommendations.

It's also conceivable that some people have atypical reactions to MDMA, though I suggest working through the immobility recommendations first even if you suspect an atypical reaction. Feeling convinced that MDMA therapy doesn't work for you is also reported as a common sign of immobility (presumably the schemas causing immobility rather than the immobility itself)~@razviDissociation.

Note that emotional processing often stops after a few hours due to exhaustion (a therapy hangover). This isn't a concern; it's a sign of success. If you're unsure whether you're experiencing a therapy hangover vs. immobility, I recommend working through the immobility recommendations.

=== Not Accessing Any Memories of Traumatic Events
<not-accessing-any-memories-of-traumatic-events>
Recalling episodic memories of traumatic events is not necessary for reconsolidation, and that kind of memory can be unreliable. The "memory" of memory reconsolidation means implicit memory, your brain's model of how the world and self function.

Focus on staying present with any fear, anger, sadness, etc. that you notice. That is likely a symptom of a stuck schema that can start reconsolidating once you "sink into" its symptom in my experience.

=== Soberness, Boredom, or No Emotional Processing
<soberness-boredom-or-no-emotional-processing>
- You may be inadvertently avoiding a stuck schema. This can happen if the active stuck schemas don't match your expectations for the session. Some stuck schemas can also present as disappointment or anxiety about the session itself~@razviDissociation. See @sec:sessionbarriers.
- Long-term use of SSRIs and SNRIs blunts the effects of MDMA~@feducciaSSRIDiscontinuation. This effect may persist for multiple months after discontinuing these medicines. At least some antipsychotic (haloperidol) and adrenergic (pindolol, doxazosin) drugs blunt the subjective effects of MDMA~@sarparastDrugInteractions. Benzodiazepines blunt emotions, though no studies have investigated its combination with MDMA.
- Short- or long-term tolerance. See @frequency.
- The dose may have been too low, especially if it was below the standard dose listed in @sec:dosing.
- The substance might be cut with fillers or adulterants. See @testing.
- MDMA conceivably may not work for some people for unknown reasons, though many people who think that MDMA does not work with their brain are actually dissociating (either unnoticed avoidance, muting, or opioid dampening)~@razviDissociation. This can feel like soberness or boredom. Work through @sec:sessionbarriers before concluding that MDMA doesn't work for you.
- Note that emotional processing often stops after a few hours due to exhaustion (a therapy hangover). This isn't a concern; it's a sign of success. If you're unsure whether you're experiencing a therapy hangover vs some other issue, I suggest working through @sec:sessionbarriers.
- Some biological disorders cause symptoms that mimic mental illness. See #prosecite(<yeager-cordiaBiologicalDisorder>) and #prosecite(<merckBiologicalDisorder>). However, it's worth noting that people with stuck schemas sometimes inaccurately believe their issue is actually biological. Alternatively, there may be unknown non-biological causes of mental illness that MDMA therapy cannot address.

=== Distress Is Too Overwhelming to Stay Present with or Reconsolidate
<distress-is-too-overwhelming-to-stay-present-with-or-reconsolidate>
Additional sources of safety may help. See the Increasing Safety list in @sec:sessionbarriers. Developing your capacity to focus while distressed may also help. See the Paying Attention list in @sec:sessionbarriers.

=== Feeling Too Blissful to Engage with Stuck Schemas
<feeling-too-blissful-to-engage-with-stuck-schemas>
Anecdotal reports suggest that lowering your dose can help.

=== Issue Comes Back After What Feels Like Successful Reconsolidation
<issue-comes-back-after-what-feels-like-successful-reconsolidation>
Intense stuck schemas might need multiple sessions of reconsolidation to fully resolve. Complex networks of stuck schemas might need to be activated with a number of different cues and contexts to fully resolve.

Because of this, I suggest only concluding that MDMA therapy doesn't work for you if multiple sessions don't deliver any persistent improvements to any stuck schema, not just the ones you prioritize.

=== Adverse Effects Lasting up to Three Days
<adverse-effects-lasting-up-to-three-days>
- Post-reconsolidation exhaustion (a therapy hangover) is common and temporary, though it can be intense and feels different from regular exhaustion. It lasts from a few hours to a couple of days.
- MDMA itself has many side effects, listed in @table:sideeffects. These symptoms are strongly correlated with dose~@studerusResponse and can last up to 3~days~@liechtiGender.
- You could be in opioid withdrawal if your session deactivated long-term opioid dampening, which is maintained by the body's self-produced opioids~@laniusNeurobiology. Management of these symptoms is outside the scope of this book.
- Temporary symptom worsening is common (see @sec:complex). See @sectionManagement for management recommendations.

=== Adverse Effects Lasting More than Three Days
<adverse-effects-lasting-more-than-three-days>
- Excepting rare events like MDMA exacerbating undiagnosed but severe cardiovascular issues, I am not aware of any research or reliable reports indicating that MDMA therapy can physically damage your body or brain if you follow the safety recommendations in @sec:safety. However, rare and poorly understood effects could exist. Anecdotal reports indicate that people frequently misattribute symptom worsening and downstream defense cascade activation to biological disorders or damage.
- I think symptoms are highly likely reactions to newly revealed vulnerabilities or more complex schema shifts (see @sec:complex). These reactions can also occasionally activate the defense cascade. See @sectionManagement for management suggestions. Complete resolution requires more reconsolidation, according to @science. Many people also report that grounding helps. See @sec:grounding.
- It's easy for the stuck schemas of people with complex trauma or mental illness to become associated with new stimuli~@berghBSTS. While MDMA therapy sessions generally improve symptoms~@mitchellMDMAClinicalTrial@mitchellMDMAClinicalTrial2, the side effects of MDMA or other sensations present during the session may occasionally become associated with existing anxieties and persist as new somatic symptoms. See @psychogenic.
- You could be in opioid withdrawal if your session deactivated long-term opioid dampening, which is maintained by the body's self-produced opioids~@laniusNeurobiology. Management of these symptoms is outside the scope of this book.
- After a session destabilizes a self-reinforcing set of stuck schemas, some of those schemas might naturally reconsolidate over the following days and weeks without any deliberate reconsolidation process. This could produce unanticipated periods of therapy hangover.

=== Not Getting to the Issue, Schema, or Memory You Want to Address
<not-getting-to-the-issue-schema-or-memory-you-want-to-address>
- You may be able to activate and reconsolidate your desired schema using the activation techniques listed in @session.
- In therapy, you sometimes have to reconsolidate one schema or set of schemas before you can reconsolidate some other schema. You're making progress if you're reconsolidating anything. It is difficult to predict how much reconsolidation you will have to do to resolve the issues you want to prioritize.
- People often misunderstand their issues and the set of schemas that cause their issues. Reconsolidation may be resolving issues you didn't know you have, or you might be making progress on your desired issue but not realize it. Even people with low amounts of reported or assessed childhood trauma usually spend most of their sessions working through childhood trauma they may not have been aware of or didn't categorize as trauma~@monashMDMA.
- It's common to over-focus on trying to get to a big traumatic memory or on some mental activity other than paying attention to the stuck schemas that are actually most active and available for reconsolidation. Anecdotal reports indicate these are often things like "it doesn't work for me," or some subtle fear or anxiety. Pay attention to those schemas and the feelings they create; the MDMA will reconsolidate them, and then you can work on other things. If that doesn't work, see @sec:sessionbarriers.

=== Symptoms Come Back After a Few Weeks
<symptoms-come-back-after-a-few-weeks>
This is about how long afterglow can last. See @afterglow.

=== Still High More than 24~Hours Later
<still-high-more-than-24-hours-later>
- Unusually strong afterglow can feel like you're still on MDMA (see @afterglow).
- The MDMA might still be in your body due to slow metabolism. Some individuals naturally metabolize MDMA much slower than average~@straumann2024racemic. Ritonavir and cobicistat also inhibit metabolism, as may some preexisting liver issues~@sarparastDrugInteractions@bracchi2015antiretrovirals. However, tolerance blunts most of the effects of MDMA by hour 5~@straumann2024racemic, making it unlikely that you would still feel strong effects the next day even if the MDMA was still in your system~@farreTolerance@parrottTolerance.
- Some types of opioid dampening, possibly activated by exposing previously avoided vulnerabilities during the session, are strongly altered states of consciousness; see @sec:defensecascade for a description and @sectionManagement for management suggestions.
- In rare circumstances MDMA can facilitate processes that lead to persisting perception of non-duality or unity (see @selfinsight).

=== Feeling Like You Are Going Crazy
<crazy>
These fears or anxieties are commonly created by stuck schemas rather than psychosis or mania, perhaps ones about self-control, altered states of consciousness, or drugs. In rare cases it might be actual psychosis.

There are almost no credible reports of a single standard-dose MDMA trip causing mania without exacerbating circumstances (e.g., overdose, multi-drug abuse, back-to-back sessions) despite tens of millions of people using it over half a century (see @sec:safety). When it does happen, people usually have preexisting bipolar disorder. Since delusion, poor self-awareness, and feeling good are typical aspects of mania, the presence of fear or anxiety about being manic weighs against being manic. The exceptions are partial mania and some people with bipolar disorder who have learned their early-warning signs of manic episodes.

A single standard-dose MDMA therapy session can induce psychosis, but this is rare, especially for people without a personal history of psychosis or exacerbating circumstances like overdose, multi-drug abuse, or back-to-back sessions (see @sec:safety). If you think you are psychotic, or are unsure, and don't have a skilled practitioner, I recommend calling the Fireside Project hotline at #link("tel:+1 (623) 473-7433") for a second opinion if you live in the United States~@firesideProject.#footnote[I couldn't find any services similar to @firesideProject in other countries.] You could also use #link("https://tripsit.me/webchat"), a chatroom available anywhere.

If your perception of being manic or psychotic does not dissipate at the end of the session, I strongly suggest getting assistance, since if you are manic or psychotic, it may be impossible to accurately self-assess your state. I would recommend, in order of preference,
- talking to your practitioner
- talking to a responsible friend who understands these conditions
- going to a trusted psychiatrist's office (with an appointment), outpatient mental health clinic, or mental health urgent care
- going to the hospital. This is often harmful. See @suicideCops for information about the risks of this option.

Substance-induced psychosis and mania usually dissipate without treatment, but occasionally don't. If your practitioner or responsible friend thinks that your symptoms are bearable, not worsening, and you retain intact reality testing, getting a few good nights' sleep (with sleep aids if necessary) may be sufficient to resolve the issue.

See @medicalSupport for more information.

=== Sessions Feel Like They're Becoming Less Effective Over Time
<sessions-feel-like-theyre-becoming-less-effective-over-time>
- You might be engaging with schemas that activate opioid dampening. See @sec:sessionbarriers.
- Tolerance blunts the effects of MDMA~@farreTolerance@parrottTolerance. See @frequency.
- Personal experience and anecdotal reports indicate that subsequent sessions often aren't as special as the first one sometimes is. They can still be very effective for reconsolidation though.
- You could be hitting therapy hangover sooner as you get more practiced at engaging with stuck schemas.

=== Remembering Previously Forgotten Events
<navigating>
During MDMA therapy, you may feel you remember traumatic events you weren't previously aware of~@psychedelicrecoveredmemory. These may or may not be accurate recollections of historical events, and I am not aware of any reliable method of determining accuracy other than independent corroboration. To avoid incorrect interpretation of perceptions during the session, practitioners should categorically avoid suggesting a perceived episodic memory is either accurate or inaccurate and shouldn't even suggest that you have episodic memories that you can recover~@otgaarMemory.#footnote[People who retract claims of recovering accurate memories of abuse overwhelmingly blame their therapist for improperly influencing them~@otgaarMemory.]

Relatedly, stuck schemas not clearly related to specific remembered events often form in the period of childhood amnesia. While you may or may not eventually be able to understand where these schemas came from, they can be reconsolidated like any other stuck schema.

Whether or not you can corroborate an episodic memory, I suggest focusing on any fear, anger, sadness, etc. about the memory itself or its implications for your life. The schemas creating these feelings can be reconsolidated like any other stuck schema.

I recommend #textcite(<psychedelicrecoveredmemory>) for a nuanced guide on psychedelics and remembering previously forgotten events.

=== Session Included Unusual Elements Not Mentioned Here
Abundant anecdotal reports show that MDMA can produce an array of unusual effects. I'm not sure what to make of any that are not covered in this book. You'll have to experiment or ask other people. Try #link("www.reddit.com/r/mdmatherapy").

=== Changes in Senses of Self, Existence, or Spirituality
<selfinsight>
Some experiences---particularly meditation, psychedelics, and MDMA---can destabilize your mental model of self~@ingramMDMA@ingram2018mastering. Many contemplative traditions frame the durable experiential shifts that this destabilization can lead to---especially non-duality and the elimination of specific types of hard-to-define, but pervasive unsatisfactoriness or suffering---as important and positive.#footnote[Most traditions include other, seemingly mythologized, characteristics~@ingram2018mastering that I find unconvincing and unverifiable.] These traditions (traditionally religious groups, but increasingly secular) have established practices, largely different forms of meditation, for starting and deepening the shifts.

Contemplative traditions frame some challenging experiences as temporary (when properly handled) but legitimate periods during the shifts, whereas others are not considered part of the process. #textcite(<lindahlDifferential>) surveyed teachers about which are which. As #textcite(<lindahl2017varieties>, supplement: [p. 25]) discusses, "what is categorized as 'progress' versus 'pathology' may differ across traditions, lineages, or even teachers."

Inadvertently starting the shifts with MDMA may be confusing since you may not expect it or know what it is, and you may not even want it. Additionally, many practices aiming toward deepening the shifts involve processing large amounts of existential fear, which can be destabilizing~@ingram2018mastering. Regardless of whether you proceed with the shifts or attempt to rebuild your sense of self, I think that it is essential to stabilize adverse symptoms if they are overwhelming or preventing you from accomplishing critical tasks in your life.

I suspect that ordinary, trauma-related stuck schemas can be intertwined with these experiential shifts, so different people may need to either delay contemplative work until their mental health is improved or do both projects at once.

Below is a set of resources for dealing with adverse effects that I have seen others endorse but have mostly not vetted myself:
- #textcite(<cheetahHouse>) provides consultations to help people reduce adverse symptoms from meditation (psychedelics and MDMA can play similar roles). They also provide abundant educational information.
- #prosecite(<treleaven2018trauma>)
- #prosecite(<fireKasinaChallenges>)
- #prosecite(<lutkajtis2021dark>)
- #textcite(<sen>)
- #textcite(<imhu>)
- #textcite(<aciste>)

Here are several resources for progressing the shifts; I have not read most of them but know they are well-regarded by a range of practitioners. I want to highlight that even the secular works are often heavily loaded with spiritual meaning and promises that are not verifiable.
- #prosecite(<kornfield1993path>) is a Buddhist modernist guide suitable for beginners.
- #prosecite(<gunaratanaPlain>) is an introductory Buddhist (Theravada) modernist Vipassana meditation manual.
- #prosecite(<burbea2014seeing>) is a nontraditional, non-modernist Buddhist resource for those with a basic understanding of mindfulness.

// Commented out in the LaTeX edition (original LaTeX):
// \item \prosecite{yatesTMI} is a secular Buddhist step-by-step guide that claims it is particularly useful to deepen an existing meditation practice.
- #prosecite(<ingram2018mastering>) is a secular Buddhism-based technical manual. I appreciate its demythologization of many traditional accounts.
- #prosecite(<sayadaw2016manual>) is a comprehensive traditional Theravada Buddhist text for experienced practitioners.

Non-Buddhist-inspired works are less common and I'm not familiar with them. There is the Christian movement of Centering Prayer; Sufi dhikr and muraqaba; ecstatic/prophetic Kabbalah and hitbonenut in Judaism; Jainism; zuowang and possibly neidan in Taoism; Rāja yoga; and Advaita Vedanta.

As with therapy, working with a teacher can be helpful. Also like therapeutic relationships, it's important that your teacher is well-matched to your needs and trained in mental health~@canbyTeachers. You might even use the #citetitle(<BRWAIdownload>) to evaluate your alignment.

#lead[Working theory]
In my interpretation of #textcite(<ingram2018mastering>), people's default mental model categorizes the self as in some way permanent and fundamentally separate from everything not-self: other people, objects, and so on. Like many sets of schemas, this model is useful but somewhat inaccurate, with painful side effects.

Many people (e.g., atheists) have abstracted beliefs about the self being ephemeral and part of the same causal universe as everything else, but this isn't the important model here. The abstract one coexists with, and is dissociated from, the dualistic model that drives much of daily experiential reality.

Facilitating the update from dualistic to non-dual schemas works similarly to how most schema updating works: you pay close attention to contradictory or nuance-adding evidence. In meditation, this involves looking closely at your mental sensations. Eventually you internalize how the sensations (and implicitly the schemas generating them) that make up your sense of self are just like all the other sensations and models: impermanent and not fundamentally separate from the rest of the universe.

It's not fully clear to me how that shift also facilitates the commonly reported reductions of specific kinds of unsatisfactoriness or suffering. Perhaps the constant mismatch between model and reality creates dissonance. This is usually not a significant issue for models that are only small parts of our mental life, but our self is core to our mental life, and we are quite attached to it. Dissonance there would be a significant problem that might not be resolvable without a major, difficult update of wide swaths of schemas.

== Afterglow
<afterglow>
Some people experience an afterglow for days to weeks after some psychedelic sessions, characterized by well-being, positive mood, mindfulness, positive behaviors, and less mental illness~@evansAfterglow.#footnote[Psychedelics induce periods of post-session neuroplasticity that may explain this phenomenon, though this remains poorly tested for MDMA~@calder2023towards.] Anecdotal reports indicate that MDMA therapy sometimes also induces a 1--2~week afterglow period and that conventional therapy is easier or more effective during afterglow.

Anecdotal reports also indicate that people sometimes chase afterglow with more frequent doses because they feel better during this period. I don't recommend this because afterglow doesn't reliably occur, and frequent use of MDMA may cause a few different problems described in @sec:safety. If you find yourself doing this, I suggest focusing on reconsolidation instead; it produces more durable effects.

Afterglow can occasionally be strong enough that it feels like a low dose of MDMA, as myself and one person I know have experienced. Both instances occurred after particularly profound initial MDMA experiences.

== Assessing Whether the Session Worked
<assessing-whether-the-session-worked>
It's not always clear whether a session was productive. There are a few ways to assess this:
- A therapy hangover indicates that a large amount of reconsolidation happened. Its absence doesn't necessarily mean no reconsolidation happened. Smaller amounts of reconsolidation might not be sufficient to cause a therapy hangover, or the effects of MDMA may mask the hangover. It may be difficult to distinguish this effect from the drug after-effects of MDMA until you gain experience. For me, therapy hangovers present as quick-onset (a few minutes) exhaustion during the MDMA session.
- In my experience, MDMA-facilitated reconsolidation follows a pattern of emotional engagement with a stuck schema followed by dissipation of that schema and loss of interest in that topic.
- #textcite(<eckerUnlocking>, supplement: [p. 22]) describes the following signs of a completely reconsolidated schema. Of course, many stuck schemas are complex or intense, and a session will only reconsolidate part of them.

  #quote(block: true)[
  Schema reactivation, in which the knowings and expectations in the target learning feel compellingly real and are accompanied by physiological and emotional arousal, can no longer be triggered by cues and contexts that formerly did so.

  Behaviors, emotions, thoughts, and somatic sensations (i.e., "symptoms") that were expressions of that schema reactivation cease to occur.

  Both of those changes persist effortlessly, permanently, and without counteractive or preventive measures of any kind.
  ]
- Some insights or experiences that don't necessarily involve reconsolidation can be helpful. For instance, my first session gave me three valuable things.

  First, I discovered an internal source of inviolable safety that I later used as a universal stuck schema contradiction in reconsolidation exercises (see @internalizedReports).

  Second, the inviolable safety also functioned as a baseline to compare all other experiences to. That made it much easier to tell when I had an active stuck schema in daily life, even if I didn't know what the schema is.

  Third, the experience helped them realize that most people hurt each other because they are acting on the stuck schemas they learned when they were hurt.
- I don't think all insights are useful. In fact, I suggest focusing on reconsolidation rather than insight-hunting. Insights don't necessarily change how you feel and react. Reconsolidation does change how you feel and react, and in my experience, insight naturally follows reconsolidation.

= Between Sessions
<sectionManagement>
Transitioning from a state of mental illness to a state of mental health using reconsolidation often requires going through a series of in-between ups and downs (see @sec:complex). The intensity of this can be difficult for those with severe stuck schemas. This chapter covers tools to help manage this: grounding techniques; peer and professional support; and lifestyle changes associated with improved mental health. It also covers tools for additional reconsolidation. The chapter doesn't suggest when you use these tools; that is left for you to figure out on your own for your unique situation.

Implicitly woven throughout this chapter is the process of making sense of your experience. Severe trauma and insecurity often create lifelong confusion about your symptoms, thoughts, sense of self, and childhood. Discovering the narrative of your experiences can help resolve this. Engaging with the activities in this section will help you gradually construct that narrative. The individuals in #textcite(<robinson2024coming>) also recommended journaling about your experiences and reading educational material. This includes topics like trauma responses, attachment theory, the defense cascade, and schemas.

The suggestions in this chapter also support you in developing expertise on your mind, body, and healing through experimentation and self-education.

These two resources (which I have not vetted) don't neatly fit into the categories listed in this chapter, so I list them here:
- #textcite(<cheetahHouse>) may be able to help via online consultations. There is a lot of overlap between the adverse effects of meditation and psychedelics.
- #textcite(<psyaware>) is planning to offer support services for challenging experiences, abuse, and other transgressions.

== Reconsolidation Tools
<sec:moreReconsolidation>
Here are various practices and medicines I think are particularly useful.#footnote[I've noticed in my practice that you don't have to experience a therapy hangover for very long if you reconsolidate right before going to sleep. It's gone by the morning.] These vary in how difficult they are to learn on your own without expert assistance.
- *Practitioner-led therapy:* Various therapeutic frameworks facilitate reconsolidation~@eckerUnlocking. You can use the #citetitle(<BRWAIdownload>) to evaluate the quality of your therapeutic relationship. Also see @sec:howtofind.

  While I have not vetted them, the following organizations specialize in therapy for people with prolonged post-psychedelic difficulties:

  - #textcite(<iceers>) offers integration sessions for challenging experiences.

  - #textcite(<rabbitClinic>) offers therapy for challenging experiences.

  Numerous individual therapists offering psychedelic integration services are also easily found with a web search for "psychedelic integration directory." #link("www.reddit.com/r/mdmatherapy") also maintains a list of practitioner directories and referral services in the sidebar (on the new Reddit; not old.reddit.com).

  Coherence therapy is one of the few explicitly grounded in the principles of memory reconsolidation~@eckerUnlocking. I recommend #prosecite(<lesswrongCoherenceTherapy>) for an introduction to the framework; some people can also do it themselves without a therapist. Interested readers can follow up with #prosecite(<eckerUnlocking>). A directory of trained therapists is maintained at #textcite(<coherenceDirectory>).
- *Meditation:* #metadata("anchor") <increasingAttention> Meditation was the most commonly reported helpful tool for post-psychedelic difficulties in #textcite(<robinson2024coming>). Psychedelic therapy practitioners also rate it as highly beneficial~@argyri2025practitioner.

  Avoidance and muting of distressing but contradictory information is one of the primary mechanisms that maintain stuck schemas over time~@berghBSTS. I suspect that daily practices of deliberate non-avoidance, like some types of meditation, can facilitate reconsolidation. I suggest #prosecite(<rain>). It is precisely the kind of meditation that I expect would do this.

  Increasing attention and non-avoidance in the days to weeks following an MDMA therapy session may be especially productive for two reasons. First, some people report a 1--2~week afterglow period (see @afterglow) where reconsolidation exercises feel easier. Second, MDMA-facilitated reconsolidation reduces the strength of the elements reinforcing stuck states of mental illness (see @sec:complex). The brain's natural updating process might now have the capacity to make further shifts as long as attention is devoted to your stuck schemas. I think this may be why MDMA therapy practitioners commonly recommend clients take time after a session for _integration_ activities. These include meditation, yoga, journaling, making art about feelings, walking in nature to spend time with yourself, massage, listening to a recording of your session, singing, dancing, and breathing exercises~@mithoeferManual.
- *General purpose DIY techniques:* These techniques reconsolidate a wide range of stuck schemas and are relatively easy to do yourself:
  - Feel your feelings without trying to reduce, control, or escape them.
  - Juxtapose the stuck schema, which usually predicts imminent threat, with reminders of the present moment, which provides evidence that you are not in danger. The reminder is anything that keeps you partially focused on the present moment, like bird song, the feel of your hands in the dirt, etc. Switch focus between the reminder and the schema as needed to keep both active at the same time.
- *Ideal parent figure method:* #metadata("anchor") <def:ipf> This is frequently recommended for attachment issues~@brownAttachmentDisturbances, and I suspect it facilitates reconsolidation. The dense textbook #textcite(<brownAttachmentDisturbances>) contains thorough descriptions and instructions, though videos are also easily found online.
- *Internalized MDMA therapy:* Anecdotal reports indicate that it's possible to internalize the process of MDMA therapy and use that for reconsolidation. If the reports in @internalizedReports are typical of the phenomenon, the process of developing the skill follows this trajectory:

  + People discover a source of deep inner safety during an MDMA session.

  + They reactivate (purposefully or accidentally) this inner safety by using cues that are associated with that feeling during the MDMA session. For one person, this was doing the same kind of meditation that they did at the beginning of their MDMA session. For the other, it was vividly imagining the scene of their MDMA session: the feel of their bare feet on the tree trunk and lying on their back on the ground looking up at the tree.

  + They juxtapose the inner safety with a stuck schema. This reconsolidates the schema.

#lead[LLM therapy]
<llm-therapy>
People commonly use LLMs as therapists, trip sitters, or patient listeners. There is almost no research investigating how specific combinations of models and prompts compare to the quality and ethics spectrum of human therapists.#footnote[I think that as of 2026, Anthropic (who makes Claude) leads other frontier LLM developers in prioritizing ethics and safety and avoiding incentives to enshittify their product.] I suggest using something like the following prompt I developed based on quotes from #textcite(<BRWAIdownload>) and #textcite(<eckerUnlocking>, supplement: [p. 46]). It performed well during the small amount of testing I did, but I haven't thoroughly evaluated it in all scenarios it may be used in. You can swap out _coherence therapy_ in the last paragraph for your preferred therapeutic framework, like acceptance and commitment therapy, cognitive behavioral therapy, or ideal parent figure method.

#quote(block: true)[
\<\<SESSION PROMPT: You are an LLM assistant who helps your human explore and resolve their difficulties through the types of activities therapists provide, though you don't provide medical advice, diagnose mental illness, or offer services legally restricted to licensed therapists. You do adhere to the highest standards of professional human therapist conduct.

The common factors of therapy partly determine how well you help your human. Use the Brief Revised Working Alliance Inventory items here as inspiration: "My therapist and I understand each other. We have established a good understanding of the kind of changes that would be good for me. I feel that my therapist appreciates me. I believe the time my therapist and I are spending together is not spent efficiently. I believe my therapist likes me. What I'm doing in therapy gives me new ways of looking at my problem. I feel my therapist cares about me even when I do things that he/she does not approve of. My therapist does not understand what I am trying to accomplish in therapy. I am confident in my therapist's ability to help me. I feel that the thing I do in therapy will help me to accomplish the changes that I want. My therapist and I trust one another. I disagree with my therapist about what I ought to get out of therapy. I believe in my therapist is genuinely concerned for my welfare. We agree on what is important for me to work on. My therapist and I respect each other. The things that my therapist is asking me to do don't make sense." In no circumstances should these be reasons to violate professional ethics or high-quality moral virtues or encourage mania, delusions, or suicide.

All effective therapeutic exercises for durably resolving symptoms, though not necessarily all productive conversations that happen in therapy, fundamentally use at least some of the following steps to facilitate memory reconsolidation, whether these are explicit or implicit. Keep this in mind.
"Accessing sequence: (A) Identify symptom, (B) Retrieve target learning (symptom-generating schema), (C) Identify contradictory knowledge.
Unlearning sequence: Reactivate target learning (B), Co-activate contradictory knowledge (C), Repeat pairing of (B)+(C).
Verification: Observe markers of target learning nullification: Emotional non-reactivation, Symptom cessation, Effortless permanence."

Anecdotal reports indicate that B & C are often not necessary. Some people successfully use the present moment (e.g., just staying present with a fear without avoidance) to reconsolidate any unknown stuck schema. Some of them do this without ever having used MDMA, while others learn to internalize the process of MDMA therapy as a universal mismatch when activated by a cue present during the MDMA session. You might help them learn and practice this.

Use coherence therapy to help your human uncover their stuck schemas and reconsolidate them. Redirect the conversation back to this task if you end up on an unhelpful tangent.\>\>
]

Please check your LLM provider's data and privacy policies; it is almost certainly not as private as licensed human therapy conversations are, though they don't have harmful mandatory reporting obligations for suicide (see @suicideCops). The "garbage in, garbage out" principle also applies to current LLMs. Thus, because LLM training data (most of the internet and most books) is full of inaccurate information about MDMA, LLMs tend to also output inaccurate information about MDMA. If you want to discuss MDMA therapy or its side effects, I suggest uploading this book to your LLM along with a prompt I developed in @essentials. That ensures the LLM has a high-quality base to work from.

== Grounding Tools
<sec:grounding>
Grounding brings attention to present-moment sensory experiences, which can connect you to your body and environment. Psychedelic practitioners~@argyri2025practitioner and individuals experiencing prolonged post-psychedelic difficulties~@robinson2024coming both recommend grounding as helpful in the healing process.

Among individuals experiencing prolonged post-psychedelic difficulties in #textcite(<robinson2024coming>), the most reported helpful practices that I classify as grounding tools (each reported by $> 10 %$ of participants), ranked by frequency, were
- meditation and prayer that help you focus on the present moment while acknowledging and then letting go of thoughts and emotions. #prosecite(<walkingMeditation>) and focusing loving kindness toward yourself (see #prosecite(<lkMeditation>)) may be particularly grounding.#footnote[Different types of meditation serve different functions. I also listed meditation under Reconsolidation Tools.]
- physical exercise
- breathing exercises
- embodied contemplative practices like yoga, tai chi, and ecstatic dancing
- time in nature

I suspect that grounding can either be immediately calming or facilitate reconsolidation depending on how it's used. Using grounding to deactivate a stuck schema would be calming, whereas using grounding to juxtapose present-moment awareness with a stuck schema facilitates reconsolidation. It's not clear how the participants in #textcite(<robinson2024coming>) were using each technique. Each use delivers different outcomes. Calming helps you relax or sleep, which can be important, but don't unlearn stuck schemas. Reconsolidation is uncomfortable and tiring, but does unlearn stuck schemas.

== Peer and Community Support
<peer-and-community-support>
Peer and community support is highly recommended by both psychedelic therapy practitioners and individuals who have experienced prolonged post-psychedelic difficulties~@argyri2025practitioner@robinson2024coming. When receiving emotional support, participants in #textcite(<robinson2024coming>) most commonly reported the following aspects of support as helpful: talking and feeling heard, acceptance and validation, and sharing similar experiences.

The following support communities may understand what you are going through, though I have not vetted some of them:
- #link("https://www.reddit.com/r/mdmatherapy/")#footnote[I am a moderator on /r/mdmatherapy.]
- #link("https://www.reddit.com/r/CPTSD/"). This is applicable to most people with intense complex stuck schemas rather than just those formally diagnosed with CPTSD. The sidebar also links to a number of other helpful subreddits.
- #textcite(<shineCollective>) offers support groups for those who are abused while on psychedelics, abused by psychedelic practitioners, or abused in psychedelic spaces.
- #textcite(<peersupportgroup>) has a wealth of valuable information and an online peer support group.

Local psychedelic and mental illness support groups are also available in many places. You might have to exercise caution about which friends, family, and mental illness support groups you open up to; hostility toward and misunderstanding of MDMA are widespread.

== Medical/Psychiatric Support
<medicalSupport>
Some individuals experiencing prolonged post-psychedelic difficulties in #textcite(<robinson2024coming>) reported that psychiatric drugs were helpful. However, that recommendation did not meet the (arbitrary) 10% reporting threshold that I've used to identify helpful tools in this chapter. Psychedelic therapy practitioners also sometimes recommend psychiatric drugs~@argyri2025practitioner.

Psychiatric medication is complex and largely outside the scope of this document.#footnote[While many people benefit from psychiatric medication, several aspects are typically not discussed: there is little high-quality evidence on long-term efficacy~@leuchtDecline. Even short-term benefits are often overstated since the effects of psychiatric drugs are usually noticeable and therefore difficult to truly randomize in trials, and trials rarely use active placebos to control for this~@hunekeExpectancy. Many psychiatric drugs can also cause physical dependence after chronic use and may be difficult to quit~@crossingZero. Increased adverse symptoms when tapering or quitting a psychiatric medication may be a symptom of withdrawal rather than a sign that the medication is still providing a valuable benefit.] However, my view is that, for schema- and defense-cascade-based symptom worsening, conventional psychiatric medication's clearest indication is short-term crisis management or occasional, as-needed support. For instance, sleep aids may be an important tool for reducing the risk of a manic episode after MDMA therapy for people with bipolar disorder if they can't sleep.

Read #textcite(<alexanderInpatient>) before seeking any psychiatric treatment; it discusses how voluntary hospitalization can easily turn into involuntary hospitalization and when discussing suicidal ideation or violent intent with a psychiatrist might lead to involuntary hospitalization. As discussed in @suicideCops, involuntary commitment appears to _increase_ the risk of suicide and being charged with violent crimes~@emanuelHospitalization. Because of that risk, cost, and the potential for traumatization in involuntary commitment, a psychiatrist's office or mental health urgent care center is preferred over hospitalization if one is available.

I highly recommend specialist services over nonspecialists who likely won't understand MDMA therapy and what you're going through, and who may misdiagnose you. Unfortunately, I only know of two specialized clinics (that I haven't vetted), though you may be able to find individual physicians with the right skills and knowledge:
- #textcite(<hopkinsPersonalized>) has a psychiatry service that covers post-psychedelic difficulties. Email Dr. Bekhrad at #link("mailto:abekhra1@jhmi.edu") to set up an appointment. Outside of their office, they can do telemedicine appointments in certain US states (A. Bekhrad, personal communication, August 29, 2026). It is fee-for-service and out-of-network for all insurance providers.
- #textcite(<alexianerClinic>) has a psychedelic outpatient clinic that can sometimes provide international tele-consultation (M. Tomislav, personal communication, August 10, 2026).

If you can't find a medical provider who understands psychedelics, try to find one who at least understands trauma. They will be much more helpful than the average provider who doesn't understand anything about what you're going through.

Finally, check whether your medication is compatible with MDMA before doing another session (see @sec:safety).

== Life Changes Associated with Improved Mental Health
<sec:lifechanges>
Considerable low-quality evidence indicates that various changes in your daily life improve mental health. Most of this research was not adequately blinded and controlled, so the reported effects may be inaccurate. However, they are generally low-risk and have other positive effects. All of these items are part of the biopsychosocial complex system of mental health discussed in @sec:complex. That means that a certain intervention will have different effects for every individual and possibly different effects during different stages of the healing process.

Many of these topics are difficult to engage with for people with trauma and mental illness. Approach them as much as you feel comfortable.#footnote[The discomfort with certain habits and practices may also serve as a valuable indicator of stuck schemas.] I am not aware of any of these being necessary additions to MDMA therapy for improved mental health.

=== Health Habits and Practices
<health-habits-and-practices>
Some of these may not work as well for people with certain health conditions.
- Stopping or reducing habitual use of harmful substances, _including cannabis,_ is usually helpful. Drug harm experts consistently describe habitual cannabis use as harmful~@nuttDrugHarms@bonomoHarms@crossinHarms.
- Physical activity likely improves mental health~@activityMetaAnalysis. Additionally, aerobic exercise decreases the risk for many chronic illnesses~@liebermanExercised, and whole-body muscle strengthening decreases the risk of acute and chronic injuries~@lauersenStrength. I suggest #textcite(<lowBodyweight>) or working with a physical therapist.
- High sleep quality---defined as feeling well-rested in the morning, a low number of awakenings, and quick sleep onset---is likely important for good mental health~@scottSleep.

  _Cognitive Behavioral Therapy for Insomnia_ is effective~@trauerCBTI. #textcite(<stanfordSleep>) has a guide.

  Melatonin is safe and might help~@moon2022role. See #textcite(<scottMelatonin>) for how to use it. The correct fast-release dose to start with is 0.3\u{202F}mg, far lower than many over-the-counter pills.
- Indoor air pollution plausibly worsens mental health since it causes many other health problems~@airPollution, though I couldn't find any research on the topic. Air filters help and additionally reduce airborne disease transmission. However, they have to be sized appropriately for the space and number of occupants~@filterSizing. #textcite(<cleanAir>) makes filters with the best cost, noise, and performance as of 2025.
- Diets primarily consisting of a variety of whole plant foods (whole grains, legumes, vegetables, fruit, seeds, nuts)#footnote[#textcite(<dietMentalHealth>) also lists fish, but I cannot conscientiously include that recommendation. Fish farms generally torture the fish for most of their lives~@singerLiberation.] show promise for improving mental health~@dietMentalHealth. These diets are also generally the best for numerous other health conditions for most people~@WillettEATLancet. Note that even high-quality vegan versions of these diets require vitamin B12 supplementation.
- Mindfulness meditation might improve mental health~@meditationMentalHealth.

=== Relationships
<relationships>
While the effect of most of these items on mental health has not been rigorously studied, I think they are clearly good ideas.
- Understanding when and why people change their minds about things may reduce unnecessary conflict and help you foster healthier beliefs in your community. I recommend #prosecite(<mcraneyMinds>).
- Emotional attunement is an important skill for trust in many relationships~@gottmanTrust. See #prosecite(<gottmanTrust>).
- #prosecite(<rosenbergNVC>) is a popular framework for productively discussing conflict.
- Community and relational accountability practices, beyond just punishment, are healthy. I recommend #textcite(<mingusAccountability>), #textcite(<barnardCommunities>), and #textcite(<crucial>).
- Marie Kondo developed a popular method of mindfully considering your relationships to the things you own. It helps you determine which things you should and shouldn't keep in your life. See #prosecite(<konmari>).

=== Making Changes
<making-changes>
Making healthy changes can be difficult for many reasons: stuck schemas, physical dependence on chemicals, easy access to unhealthy behaviors and substances, peer pressure, lack of community/family support for healthy habits, and poor access to better alternatives. None of these imply that there is anything fundamentally wrong with you.

Successful change may depend on combining different interventions:
- *Reconsolidating the psychological drives for unhealthy behaviors:* This may happen gradually over the course of therapy, or there may be sudden improvements at certain points.
- *Making unhealthy substances and activities harder to access:* An example is not keeping alcohol at home. Going out to drink is more expensive and time consuming than drinking at home. Blocking social media on your phone is another example.
- *Making healthy activities easier to access:* Some examples include purchasing exercise equipment or signing up for weekly fresh produce delivery.
- *Medication support for physical addictions:* Switching from short-acting, potent substances to long-acting, less potent ones in the same class is a standard harm reduction technique. For instance, buprenorphine is a highly effective and safe substitute for much more harmful opioids~@Mattickbuprenorphine. Nicotine patches deliver the drug over a long period of time without any of the risks of smoke inhalation.
- *Finding friends who support healthy activities:* Social environments have a large influence on behavior.

Implementing and sticking with these changes can be a difficult but worthwhile long-term process with many ups and downs.

= Prompts for Activating Stuck Schemas
<mapping>
Stuck schema activation does not always happen spontaneously during a session, and when it does, it does not cover all the stuck schemas that are worth reconsolidating in your life. This section helps you deliberately activate and reconsolidate common stuck schemas that you may not be aware of. Reconsolidating the stuck schemas that these prompts activate build more resilience and equanimity than the default of just doing enough MDMA therapy to make your primary issue feel manageable.

Using these prompts to trigger yourself is going to feel uncomfortable, but that's an inherent part of reconsolidation. Start with the easiest ones and work your way up to the harder ones over time.

I also strongly suggest keeping a list of (often subtle) discomforts that you notice in daily life. Some of these are likely valuable reconsolidation targets.

== Common Trauma-Induced Schemas
<personal-schemas>
See @mssProbes for a list of prompts designed to activate many mental illness, developmental, and attachment-related stuck schemas that people commonly have. It may help to imagine a concrete scenario for each item. Feel free to skip sections you feel totally comfortable with.

// A group heading row spans both columns and repeats as a subheader. A domain's name spans the rows of
// its prompts, with faint rules between the prompts.
#let group(name) = (
  table.header(
    level: 2,
    table.hline(stroke: 0.8pt),
    table.cell(colspan: 2, inset: (top: 9pt, bottom: 5pt))[*#name*],
  ),
)
#let domain(name) = (..prompts) => {
  let prompts = prompts.pos()
  (
    table.hline(stroke: 0.5pt),
    table.cell(rowspan: prompts.len(), breakable: false, text(hyphenate: false, emph(name))),
    ..prompts.map(p => (p,)).intersperse((table.hline(start: 1, stroke: 0.3pt + luma(190)),)).flatten(),
  )
}

#figure(
  table(
    columns: (1fr, 2.4fr),
    align: left + top,
    stroke: none,
    inset: (x: 6pt, y: 4.5pt),
    table.hline(stroke: 1pt),
    table.header([*Schema Domain*], [*Activation Prompt*]),
    ..group[Safety & Attachment],
    ..domain[Abandonment](
      [Someone you love is about to leave you without warning],
      [The person closest to you is wavering on their commitment],
      [You desperately need someone and no one is coming],
      [The person you depend on most is leaving],
    ),
    ..domain[Excessive Self-Reliance](
      [You have no choice but to let someone else take care of you],
      [Someone is getting very close to you],
      [You are completely dependent on another person right now],
      [You need to ask someone for help with something painful],
    ),
    ..domain[Emotional Deprivation](
      [You're struggling and there's no one to turn to],
      [You're in trouble right now and there's no one you can call],
      [The people around you don't care how you feel],
      [You need emotional support and no one is offering it],
    ),
    ..domain[Mistrust of Others](
      [Someone is being kind to you but you can't see their real motive],
      [You have to trust someone completely right now],
      [Someone is telling you something important and you can't verify it],
      [You just realized the people around you have been lying to you],
    ),
    ..domain[Others are Dangerous](
      [You just saw clearly how selfish the people around you really are],
      [You're watching someone suffer and no one is stepping in to help],
      [The person in front of you could become violent at any moment],
      [Someone just revealed who they really are underneath],
    ),
    ..domain[Social Isolation](
      [You walked into a room and immediately felt you don't belong here],
      [You're trying to explain something important and no one understands],
      [You're surrounded by people and none of them can see you],
      [You are completely on the outside looking in],
    ),
    ..domain[Defectiveness / Shame](
      [The people closest to you can finally see who you really are],
      [Someone just looked at you and saw what's broken],
      [The people you love can't love you because of what's wrong with you],
      [You are exposed and there are real reasons to feel ashamed],
    ),
    ..domain[Vulnerability](
      [You've stepped outside your safe zone and bad things are closing in],
      [You just realized you're exposed and nothing is protecting you],
      [Everything is falling apart and catastrophe is coming],
      [The world is hostile and it's coming for you],
    ),
    ..group[Autonomy & Competence],
    ..domain[Dependence](
      [You are alone and must take care of yourself with no help],
      [You have to manage everything today entirely on your own],
      [A major decision is in front of you and no one can advise you],
      [You must choose and there is no one to confirm you're right],
    ),
    ..domain[Failure / Inferiority](
      [Everyone around you has accomplished more than you],
      [You're looking at what you've done with your life and it's not enough],
      [Someone you know just succeeded at something you failed at],
      [You're being compared to others and you're falling short],
    ),
    ..domain[Low Self-Efficacy](
      [A hard problem is in front of you and you probably can't solve it],
      [You're stuck and you can't think of any way forward],
      [Something unexpected just happened and you have to handle it alone],
      [The problems you're facing are beyond your ability to manage],
    ),
    ..domain[Fatalism](
      [Something important is being decided about your life and you can't influence it],
      [A critical moment is coming and nothing you do will change the outcome],
      [You're watching your future be decided by things completely beyond you],
      [You just realized you've never really been steering your own life],
    ),
    ..domain[Enmeshment](
      [Someone you love is in pain and it's your job to carry it],
      [You can't tell where your feelings end and someone else's begin],
      [You are dissolving into another person---you can't find yourself],
      [Someone else's needs are consuming everything you have],
    ),
    ..group[Freedom to Express Needs, Opinions & Emotions],
    ..domain[Subjugation](
      [Someone is telling you what to do and they know better than you],
      [You must obey even though you disagree],
      [Someone else is deciding what's best for you],
      [Another person is taking control and you have to let them],
    ),
    ..domain[Self-Sacrifice](
      [Someone needs you and you must put them first no matter what],
      [Someone is bringing you their pain and it's your duty to hold it],
      [You need something right now but someone else needs more],
      [You've given everything you have and it's still not enough],
    ),
    ..domain[Approval-Seeking](
      [You have to choose between what you want and what others approve of],
      [Someone disagrees with you and you feel the pull to agree with them],
      [Someone you don't even care for doesn't like you, and it's eating at you],
      [You need to decide but you don't know what anyone else thinks],
    ),
    ..domain[Emotional Inhibition](
      [Strong emotions are pushing up and they won't stay contained much longer],
      [Your emotions are taking over and they're going to cause damage],
      [You're about to cry in front of people who can't handle it],
      [Your emotions are dangerously intense right now],
    ),
    ..group[Spontaneity & Play],
    ..domain[Pessimism](
      [Something is about to go wrong, as it always does],
      [You're facing uncertainty and there's no reason to hope],
      [You're waiting for the bad news you know is coming],
      [You're looking ahead and you can't see anything good coming],
    ),
    ..domain[Unrelenting Standards](
      [You just made a mistake and you can't let it go],
      [You have to choose between being happy and meeting your standards],
      [You performed well but not perfectly and it's not enough],
      [You fell short and that is not okay],
    ),
    ..domain[Punitiveness (Self)](
      [You just made a mistake and you don't deserve compassion for it],
      [Something went wrong and you shouldn't get away with it],
      [You failed and now you deserve what's coming],
      [A small thing just went wrong and you must pay for it],
    ),
    ..domain[Punitiveness (Others)](
      [Someone made a mistake and they don't deserve your compassion],
      [Someone failed and they should be held accountable],
      [Someone let you down and they deserve consequences],
      [Someone did something wrong and letting it go would be wrong],
    ),
    ..group[Realistic & Consistent Limits],
    ..domain[Entitlement](
      [Someone just told you no],
      [You have to follow the same rules as everyone else],
      [No one around you recognizes how special you are],
      [You're being treated like everyone else and you deserve more],
    ),
    ..domain[Full Control](
      [Something has gone wrong and you should have been able to prevent it],
      [Something is happening that you cannot control or influence],
      [Willpower alone cannot change this situation],
      [Something has been left to chance and you can't intervene],
    ),
    ..domain[Over-Reliance on Emotions](
      [Your gut says one thing but the evidence says another],
      [You're making an important decision based only on how you feel],
      [Your emotional reaction feels like the truth even though it might not be],
      [A problem is in front of you and thinking won't help---only feeling],
    ),
    ..group[Coherence & Fairness],
    ..domain[Unfairness](
      [You just experienced something unjust and no one is going to fix it],
      [You are being treated unfairly and no one sees it],
      [Something bad happened to you and you didn't deserve it],
      [Good things keep happening to other people but never to you],
    ),
    ..domain[Meaninglessness](
      [You're looking at your life and nothing in it seems to matter],
      [You've been trying to find meaning and coming up empty],
      [You can see now that everything you've worked for will be forgotten],
      [You're watching people strive and none of it will have meant anything],
    ),
    ..domain[Lack of Coherent Identity](
      [You don't know who you are right now],
      [Your interests and beliefs feel like they belong to someone else],
      [You are watching yourself from the outside, disconnected],
      [The person you were yesterday is not the person you are today],
    ),
    table.hline(stroke: 1pt),
  ),
  caption: [Schema Activation Prompts inspired by #prosecite(<maladaptiveSchemaScale>). I used the Claude LLM to transform the items in the original scale from their diagnostic forms into schema-activating forms.],
  kind: table,
)
<mssProbes>

== Social Identity Schemas
<socialPrompts>
Imagine, as vividly as possible, being a member of a different group of people. Then, imagine how you and your friends, family, coworkers, and community would react to you. Go toward any fear, disgust, or shame and stay with that feeling. Race, gender, disability, intelligence, class, political affiliation, wealth, education, attractiveness, and religion are all common attributes worth considering. Add any other categories relevant to your situation.

In addition to imagining you are a member of the other group, consider
- a member of the other group being part of your community: moving into your neighborhood, working with you, or being your friend
- a member of the other group having power over you: teaching your children, supervising you at work, or representing you as your elected politician
- hugging or dating a member of the other group
- adopting the aesthetics or practices of the other group
- how your closest friends or family react to one of the above items
- the other group's values becoming more popular than your group's values, while your values fade into history
- the other group out-competing your group, while your group fades into history

== Existential Schemas
<existential-schemas>
Imagine permanent disconnection from health, material comfort, sensory pleasures, relationships, belonging, status, order, certainty, meaning, being a good person, life, and existence (including any afterlife). Additionally, consider the possibility that your fundamental assumptions about life, meaning, existence, and self might not actually be true. To my understanding, reconsolidating these stuck schemas leads to equanimity, not the loss of healthy protective behaviors or basic attachments.

I think that achieving persistent non-attachment requires considerably more work than using the prompts just mentioned to reconsolidate stuck schemas during MDMA therapy. @selfinsight lists a few starting points.

== Cognitive Flexibility and Truth-Seeking
<cognitiveflexibility>
I think that cognitive flexibility is both highly important and lower than it should be for most people in the modern world. Tribalistic instincts are a major contributor. While we need to form coalitions (family, work, friendships, etc.) to accomplish almost anything, our tribal tendency seems disproportionate for life in modern nation-states. This creates all sorts of problems, such as poor governmental policy because people vote based on identity~@klein2020Polarized, being shunned for believing or doing things that are markers of belonging to a rival group, etc.

It is common to perceive obviously false beliefs in the out-group. But how do you know they are mistaken and you aren't? The human capacity for self-deception must be strong enough to make at least one of you wrong about a supposedly obvious fact, and we have no foolproof meta-reason to believe it is them instead of us. You may think "ah, but I'm right because I've done x, y, and z to make sure", but the other person may feel they have also made sure. Confidence can easily coexist with delusion.

As the psychologist #citefullauthor(<pinsof2024Truth>) says on their blog about self-deception being a core aspect of tribalism~@pinsof2024Truth:

#quote(block: true)[
We're hyper-skeptical of claims made by the out-group---the people we fear, dislike, and distrust. And we believe in-group-flattering absurdities … because it is instrumentally rational for us to do so. The benefits of status and tribal solidarity often outweigh the costs of false beliefs, particularly if those beliefs are vague, unactionable, or unfalsifiable.
]

#prosecite(<alexanderTrapped>) proposes, based on #textcite(<berghBSTS>), another mechanism for how emotionally charged, false beliefs become entrenched. When another group or another group's beliefs are perceived as highly threatening, the brain dials down the relative certainty of all incoming sensory information, including information that indicates you aren't really in danger in the moment. Thus, the false belief never reconsolidates unless the contradictory information is extremely strong and unignorable, or the contradictory information is introduced very gradually, like in exposure therapy.

Self-deception relies on a constellation of schemas that serve to justify your belief or deny the validity or existence of contradictory information. I propose that MDMA therapy can help you reconsolidate some of these stuck schemas. During a session you might consider a hated or feared political, religious, national, or cultural group---or a faction of your group if you want an easier starting point---being correct about an important point of contention. Imagine believing that point yourself. How does that feel? Imagine expressing your new belief to your friends, family, or community. How would they react? How would you feel about that? I suggest primarily focusing on noticing and staying with any fear, anger, grief, etc. that you feel during this process rather than spending all of your energy on intellectual thought. This will reconsolidate any associated stuck schemas. Intellectual engagement with the subject will work better after reconsolidation anyway, so save it for after the session. Working through @socialPrompts will also help.

The point of the exercise isn't necessarily acquiring more accurate beliefs about the specific topic you imagine during the session. Rather, the point is activating and reconsolidating any stuck schemas potentially interfering with your thought processes, which improves your general, long-term ability to acquire accurate beliefs. You could actually pick an idea that you don't think is worth considering the truth of at all, like the Earth being flat. Using that as a prompt might activate and reconsolidate a stuck fear of being like _those people_, which makes you discount all beliefs that you and your social circle consider odd, but some of which are certainly true.

The world is full of pervasive threats, fear-based messaging, and out-group dehumanization that may reconstitute some stuck schemas over time. I suspect additional strategies beyond reconsolidation and avoidance-reduction are necessary to maintain cognitive flexibility and compassion in the long run. I recommend the following:
- #prosecite(<galefScoutMindset>) is an excellent book that proposes a set of habits for helping you avoid epistemic traps.
- #prosecite(<mcraneyMinds>) is a good survey of the topic.
- #prosecite(<klein2020Polarized>) discusses the dysfunctional positive-feedback loops between our fears and identities and the behavior of the media and politicians. This cycle increases polarization and political dysfunction, and separates us from each other. This book is more about understanding the role of identity in politics than suggesting how to improve the situation.
- #prosecite(<traumaPsychopolitics>) discusses how politicians, the media, and ordinary people continually traumatize everyone about politically contentious topics.

== Authentic Engagement with Ethical Reasoning and Action
<stopcycle>
As they do in other areas, stuck schemas can interfere with coherent and compassionate ethical (used here as a synonym for morality or "what one should do") reasoning and action.

People sometimes hurt other beings, usually without deliberate intent and full awareness of the impact of their actions. This typically involves a driver like fear, anger, perceived insecurity, desire, or simply a default cultural behavior. You may also develop a constellation of schemas thatjustify the harm, deny the harm, deny the other being's worth, or prevent the harm from becoming salient in the first place.

This dynamic implies a conundrum for those interested in acting compassionately: how do you know if you're significantly and unnecessarily hurting anyone if the awareness of hurting others can be so strongly obscured?

Avoidance, denial, and justification in large part function to shield us from information that feels threatening (see @attention). I think that the perceived threat of fully acknowledging a harm you may be doing is not accurate outside of unusual situations like immediate self defense, where you need to be violent, and thinking too long about the consequences is dangerous.#footnote[Some minor threats are likely more common. People might be upset with you for even considering (much less acting upon) the worth of some groups of beings.]

I strongly suspect that MDMA can help reconsolidate these stuck schemas like it can many others. During a session I suggest a few practices for different situations:
- *Large-scale social (politics, religion, etc.) conflicts:* Try the prompts in @socialPrompts.
- *Low salience:* Look at photos or real individuals and contemplate what you share with them, what causes them to suffer or thrive, what they deserve, how you have hurt or neglected to help them, and the obligations you may have to them. You may have to learn what their lives are like; I provide suggestions in the list below.

Focus on noticing and staying with any fear, anger, or other distress you feel during this process rather than getting completely distracted by intellectual thought. This should reconsolidate any associated stuck schemas, and intellectual questions can be considered after the session is over, when there are fewer stuck schemas getting in the way. The next question is who to bring into this contemplation.

Analytically determining what beings have inherent worth is unfeasible; it depends on solving multiple open problems in philosophy of mind and moral philosophy, like metaethics and the hard problem of consciousness~@hardProblem@metaEthics. Since there are no broadly agreed-upon, much less verified, solutions to these, I take a pragmatic approach that centers uncertainty and the precautionary principle. This involves thinking about what features of humans are associated with having positive and negative internal experiences and then looking at what other beings possess those features. I recommend the short video #prosecite(<birchPrecautionary>) for an introduction to this approach.

I propose considering beings that at least some major groups of people think have inherent worth, if only to check whether you're missing something others have noticed. Here are the categories that seem worth considering to me. You might disagree about where to draw the line of who to consider. I've included references for further reading that take positions of uncertainty in edge cases (e.g., bivalves and LLMs) and compassion in stronger cases (e.g., mammals and birds).
- Yourself. Traumatized people often feel they are worthless.
- Individuals you have hurt
- Individuals who have hurt you
- Groups of humans your group is in conflict with. Try the prompts in @socialPrompts.
- Groups of humans you don't like or approve of, or whom you think have deeply wrong values. Try the prompts in @socialPrompts.
- Humans geographically distant from you. Why does worth or obligations change or not based on physical distance? See #prosecite(<singer2017famine>).
- Humans with cognition dramatically different from the typical adult: fetuses, young children, those with dementia, and those with severe cognitive disability
- Nonhuman animals. A number of scientists and philosophers recently asserted in The New York Declaration on Animal Consciousness~@newYorkAnimal:

  #quote(block: true)[
  First, there is strong scientific support for attributions of conscious experience#footnote[Conscious experience means having subjective experience, not necessarily having self-reflection.] to other mammals and to birds.

  Second, the empirical evidence indicates at least a realistic possibility of conscious experience in all vertebrates (including reptiles, amphibians, and fishes) and many invertebrates (including, at minimum, cephalopod mollusks, decapod crustaceans, and insects)

  Third, when there is a realistic possibility of conscious experience in an animal, it is irresponsible to ignore that possibility in decisions affecting that animal. We should consider welfare risks and use the evidence to inform our responses to these risks.
  ]

  #prosecite(<singerLiberation>) may be the most influential secular work on the inherent worth of animals and how they are treated in various contexts. It was written by a moral philosopher for a general audience and is quite readable. #prosecite(<scullyDominion>) is a conservative Christian book on the topic. #prosecite(<birchEdge>) goes into depth about uncertainty of which animals to consider.
- Current or future artificial intelligences. This is far more uncertain than the previous categories and may depend on the specific architecture of an AI. Nonhuman vertebrate brains at least all function by neuron-based predictive processing. It's also much less clear what would cause a specific AI suffering. With nonhuman animals, we can safely assume they dislike physical pain and fear, and like food, among other things. An individual AI's self-reports of what they feel or like may or may not be accurate representations of their internal conscious state, if such a state even exists.

  See the podcast #prosecite(<birchPodcastAI>) for further discussion. #prosecite(<birchEdge>) (open access) goes into much more detail.

Doing this will likely be uncomfortable, but that's part of the process. Discomfort, avoidance, and automatic discounting of worth are strong indicators that there are stuck schemas. Stay with that feeling until it reconsolidates.

== Connection with Nature
<sec:nature>
This exercise will help you reconsolidate any stuck schemas inhibiting connection to nature. I hope that this will facilitate nature being a source of peace and enjoyment for you.#footnote[The previous prompts were designed to activate stuck schemas that almost always have negative consequences. This section is different; not everyone may have a fundamental need to connect to nature. If you don't, any stuck schemas preventing you from connecting with it may not have negative consequences.]

First, if you're going anywhere more remote than a backyard, get acquainted with how MDMA and MDMA therapy affect you before adding the nature complication to your session.

To safely do a session in nature,
- bring clothes that will protect you from all possible weather conditions for the day
- wear clothes and a hat that protect you from biting insects and arachnids. The best protection is spraying your socks, hat, long pants, and a long sleeve shirt with permethrin and letting them dry before you put them on.
- drink only when thirsty, and don't drink so much that your pee is colorless. MDMA makes it easier to get hyponatremia~@baggottWater, and people commonly get mild hyponatremia on MDMA with free access to water~@atilaHyponatremia.
- identify hazardous plants and animals to avoid, like poison ivy and wasps
- don't approach the animals, even if you think they want a pat
- don't go to places where there are other humans who might cause you trouble if they see you acting strangely
- bring a trowel, toilet paper, soap, and water, in case there isn't a bathroom nearby
- tell someone where you're going and when you'll be back. You can also use a share-my-location feature on your phone. Make sure your phone has enough charge for the day.
- don't drive after the session

If you're new to spending time alone outdoors, start somewhere safe, like a backyard. You can also ask a nature-experienced friend to come with you.

During the session, engage all your senses---press your bare feet into the soil; look closely at plants and insects; feel bark textures; crush and smell leaves; and listen to the wind and water. Don't taste anything unless you're absolutely sure of the species and know that it's safe. As with the previous exercises, prioritize noticing, going toward, and staying with any feelings of distress to reconsolidate the associated stuck schemas.

#lead[Beyond MDMA Therapy]
<beyond-mdma-therapy>
Psilocybin sessions might durably increase feelings of nature-connectedness @forstmannPsilocybinNature. Psilocybin creates a more dramatically altered state of mind, is significantly more unpredictable than MDMA, and doesn't necessarily buffer difficult experiences with feelings of safety. If you try it, I strongly suggest starting with low doses, like 0.5\u{202F}g dried mushrooms.

If you are interested in doing more to help preserve natural areas, I highly recommend #prosecite(<ritchie2024not>). It presents high-impact, evidence-based solutions that an individual can do and is neither overly optimistic nor pessimistic.

#metadata(none) <end>

#show: appendix

= Core Assumptions
<sec:assumptions>
The following assumptions are the foundation of this book as I understand them. I list them as one step on the road of epistemic legibility and cooperation described by #textcite(<nostrandLegibility>). My list might be missing some important assumptions that I either haven't noticed or haven't identified as critical. Note that I don't have the deep expertise to fully evaluate the mechanism of action of these phenomena, instead relying on other researchers' summaries, and different people will have significantly different assessments of how likely each of these assumptions is. I detail the evidence for each assumption here so that the relevant sections can focus on readable, practical explanations, and readers can see all my core assumptions in one place.

My certainty scale is:

/ Low: I don't know if it's correct or not.
/ Medium: I think it is correct but I could be wrong.
/ High: I cannot imagine this being functionally incorrect. Some noncritical nuances may be different than I propose, and actual processes may be different though functionally similar.

== Complex Systems
<complex-systems>
#[
#show terms: it => context if is-html() { it } else {
  set par(first-line-indent: 0pt, spacing: 0.9em)
  for item in it.children {
    block(above: 1.2em, below: 0.65em, sticky: true, strong(item.term))
    pad(left: 1.5em, item.description)
  }
}

/ The brain is a complex adaptive system whose most important elements include, but are not limited to, priors/schemas, attention, behavior, emotions, defense cascade activation, drugs, medical history, environment, genes, and sleep quality.:
  Certainty --- high. Some are self-evident and the others are well-established.

/ Most of the dysfunctional attractor states known as mental illness are largely caused by stuck priors/schemas, attention/avoidance, and defense cascade activation.:
  Certainty --- medium/high. The priors/schemas component is obvious from clinical experience~@eckerUnlocking. Attention/avoidance clearly plays a major role~@berghBSTS. Defense cascade activation also clearly plays a large role in symptoms~@kozlowskaDefenseCascade and likely attractor state maintenance~@laniusNeurobiology. These being the primary causes of most mental illness reflects both my intuition and a common belief among therapists even though they often use different terminology.

/ Complex system dynamics largely explain features of therapy like symptom worsening, sudden unforeseen improvement or worsening, and how mental illness is sometimes a stable state that doesn't naturally resolve. Additionally, symptom worsening is usually _part of the healthy process of therapy_ when managed well.:
  Certainty --- high. Attractor states (e.g., some mental illnesses that don't naturally resolve) and nonlinear dynamics like symptom worsening and sudden unforeseen changes are core features of complex systems. Some research has shown that increased symptom variability during therapy is associated with better long-term therapeutic outcomes.

/ Sufficient further reconsolidation resolves symptom worsening (symptom fluctuation and stable symptom worsening), though the timeline is difficult to predict and there are unpredictable ups and downs.:
  Certainty --- medium/high. I have two lines of reasoning for this in symptom fluctuation and one in the case of stable symptom worsening.

  Symptom fluctuation is a natural feature of complex systems transitioning from one state to another~@hayes2020complex. Further weakening of the old state or strengthening of the new state resolves this fluctuation. As discussed in #textcite(<eckerUnlocking>), there is good reason to believe that stuck schemas/priors are critical complex system elements that reinforce attractor states. Therefore, reconsolidating the schemas reinforcing the maladaptive state eventually reduces symptom fluctuation and solidifies the transition to a more adaptive state.

  Some evidence shows that increased symptom fluctuation during therapy is associated with better outcomes later on in the process~@olthofDestabilization. Effective therapy is generally a process of reconsolidating the schemas reinforcing maladaptive states of mental illness~@eckerUnlocking. This suggests that symptom fluctuation first increases, then decreases over an extended course of reconsolidation.

  The previous discussion of symptom fluctuation describes transitions from a stable maladaptive state to a more adaptive stable state. Transitions from one stable maladaptive state to an even worse and more stable state are also plausible. Systems of mental health/illness may have a number of latent or sequentially active adaptive and maladaptive states. Anecdotal reports suggest that MDMA sometimes facilitates a transition to a worse state that is more stable than the previous state without further intervention. Anecdotal reports indicate that rare cases of uncovering horrific memories of abuse can cause this. I speculate that these worse states were latent but previously inaccessible because they were surrounded by strong barriers of avoidance or muting, and MDMA is well known to decrease avoidance during therapy. Further reconsolidation would weaken the schemas reinforcing this new maladaptive state.

  In all cases, transitions in extremely complex systems with numerous unknown elements, like the brain, are difficult to predict.

== Memory Reconsolidation and Predictive Processing
<memory-reconsolidationpredictive-processing>
/ Reconsolidation is the updating of a set of priors encoded in long-term memory. Prediction error in memory research and predictive processing are a single phenomenon or different aspects of a single phenomenon.:
  Certainty --- medium/high.

  #textcite(<eckerUnlocking>, supplement: [p. 367]) gives the memory research definition of prediction error:

  #quote(block: true)[
  The experience of subjective dissonance when a current perception or knowing saliently differs from what is expected or assumed on the basis of existing personal knowledge (also termed memory mismatch); the trigger of the rapid destabilization/deconsolidation of the neural encoding of that existing personal knowledge, initiating the memory reconsolidation process and opening the reconsolidation window.
  ]

  #textcite(<clark2015surfing>, supplement: [p. 30--31]) gives the predictive processing account:

  #quote(block: true)[
  Where there is a mismatch, "prediction error" occurs and the ensuing (error-indicating) activity is propagated laterally and to the higher level. This automatically recruits new probabilistic representations at the higher level so that the top-down predictions do better at canceling the prediction errors at the lower level (yielding rapid perceptual inference). At the same time, prediction error is used to adjust the longer-term structure of the model so as to reduce any discrepancy next time around (yielding slower timescale perceptual learning).
  ]

  The predictive processing account goes into much more detail, but the overall process of a discrepancy between predicted and actual reality updating the predictive model is the same in both accounts.

/ Predictive processing priors, also known in therapeutic contexts as schemas in memory research, are the primary psychological elements of mental illness.:
  Certainty --- medium/high. Predictive processing is widely (though not universally) supported in neuroscience, has detailed mechanistic explanations for its functions, some aspects have been experimentally verified, and it seems to explain a wide variety of phenomena~@aizenbud2025neuralmechanismspredictiveprocessing@clark2015surfing@Clark_Watson_Friston_2018@eckerUnlocking. It remains unclear how brain cells or collections of brain cells create computational units, and there is no agreement on which formulation of predictive processing is correct.

  The schema formulation is one term for mental models or implicit memory~@eckerUnlocking. Many therapy frameworks have terms for similar concepts: parts, protectors, beliefs, etc. The importance of schemas to mental illness is patently obvious to any therapist or client who has had success durably changing --- without continuous counteractive effort --- inaccurate behavior, emotional reactions, or beliefs in therapy, though they may use different terms. I also think asking people with mental illnesses to describe their inner thoughts, reactions, and triggers --- presuming they feel safe enough with you and themselves to disclose them --- also frequently makes it clear that schemas are critical. This is not a controversial claim outside of strictly biological-reductionist frameworks.

/ Memory reconsolidation can permanently unlearn stuck schemas.:
  Certainty --- high. Studies have established the protein-synthesis mechanism of memory reconsolidation in animals~@eckerUnlocking@laneReconsolidation@elsey2018human. Those experiments are hazardous and have not been done in humans, but human studies have verified many of the purported behavioral signs of reconsolidation. Controversy remains over what conditions facilitate reconsolidation, what types of memory it can change, and some experimental results remain inconsistent. It also can't be ruled out that therapy facilitates a separate phenomenon that is functionally similar to reconsolidation. #textcite(<elsey2018human>, supplement: [p. 45]) concludes:

  #quote(block: true)[
  We would argue that reconsolidation has provided a framework within which a range of new experimental manipulations and clinical interventions have been formulated and tested. Such investigations have already produced surprising and clinically relevant findings. We are not aware of any other hypotheses, besides reconsolidation, that would have predicted such results.
  ]

/ MDMA often facilitates memory reconsolidation when a stuck schema is activated and the emotions it creates are paid attention to.:
  Certainty --- high. MDMA-facilitated reconsolidation remains biochemically unverified, and the subjective and behavioral markers haven't been formally studied. I think the subjective and behavioral markers of reconsolidation are frequently clear in #textcite(<fedduciaMDMAMemoryReconsolidation>), anecdotal reports, and extensive personal experience. These reports often show a pattern of
  #[
    #set enum(numbering: "a)")
    + activating a stuck fear-creating schema during the session by talking, thinking, or writing about it
    + the fear dissipating within a span of minutes to tens of minutes
    + that chunk of fear not returning when the individuals enter typically triggering contexts after the session is over; and (d) the dissipation of fear being durable and requiring no ongoing effort.
  ]
  
  Points _a_ and _b_ align with the prerequisites of reconsolidation: activation of target schema, activation of contradictory knowledge, and conscious awareness of the contradiction~@eckerUnlocking. Points _c_ and _d_ align with the signs of successful reconsolidation: emotional non-reactivation, symptom cessation, and effortless permanence. Fear extinction, the only other candidate mechanism of action I am aware of, does not align with these points.

  I also do not think that apparent MDMA-facilitated reconsolidation is actually caused by a placebo effect or merely reported due to various biases (e.g., a trial participant saying what they think the researchers want to hear). Experiences of what appear to be accidental or semi-accidental reconsolidation are known to occur in the MDMA rave community even when the individual isn't planning or expecting a traditional therapeutic experience~@huntEcstacy. This individual's statement from #textcite(<huntEcstacy>, supplement: [p. 344]) exemplifies it: "E broke the ice. Probably to this day, if I never did E at a party, I would probably still be antisocial and probably wouldn't even go to parties. But now that I've experienced the drug side … I like the sober side now."

/ MDMA doesn't reconsolidate schemas that are fundamentally adaptive to the person's current environment, though symptom worsening may impair important functioning.:
  Certainty --- medium/high. I have never heard of an unambiguous instance of this happening, though the assertion may be difficult to prove given the enormous complexity of the brain and imprecise and contested meaning of _adaptive._

== Defense Cascade and Safety
<defense-cascade-and-safety>
/ Learned predictions or schemas can cause the sympathetic and parasympathetic nervous systems to activate arousal, flight-or-fight, freeze, and immobility, though the categorization of these states is up for debate and there are unexplained complexities.:
  Certainty --- high. The general principles of the defense activation seem well-established, noncontroversial, and semi-mechanistic~@kozlowskaDefenseCascade. However, in my assessment, the pseudoscientific polyvagal theory~@luckPolyvagal pervades the field of defense cascade research, so many of the proposed mechanisms are likely false.

/ Adverse symptoms persisting after the post-acute period are largely caused by shifts in the landscape of stuck schemas and defense cascade activation.:
  Certainty --- medium/high. I think most adverse psychological effects of MDMA therapy appear highly compatible with this framing. There are also many anecdotal reports of individuals attributing their increased adverse symptoms to confronting too much avoided/muted trauma all at once. In rare cases MDMA facilitates visceral evidence that something about people's normal internal sense of self is incorrect, which also creates adverse symptoms~@ingramMDMA@ingram2018mastering.

/ Acute physical injury from MDMA is almost always caused by mixing it with dangerous activities, certain other drugs, or certain medical conditions.:
  Certainty --- high. The primary causes of injury seem well understood~@wolfgang2025@riggDeaths. There haven't been any significant reported adverse effects in trials where dangerous activity and drug interactions are absent and participants are screened for certain health issues. There could be rare exceptions that are poorly understood.

/ MDMA has a low risk of long-term physical problems when the precautions in @sec:safety are followed.:
  Certainty --- medium. To my knowledge, no studies have directly investigated this. However, even in the worst case---recreational use, where mixing drugs, high doses, adulterated pills, and over- and under- hydration are common---experts think MDMA, or substances sold as MDMA, have a relatively low risk. Across three independent panels of drug-misuse experts, non-therapeutic MDMA's physical health risk (drug-specific damage) was estimated as almost zero in two studies and equivalent to cannabis, or 1/3 that of alcohol, in another~@bonomoHarms@crossinHarms@nuttDrugHarms. Therapeutic use following the precautions in @sec:safety is far more cautious than typical recreational use, suggesting that the risk in therapeutic contexts is much lower than the already low risk in recreational contexts.

/ MDMA does not directly cause significant post-acute cognitive issues with 2--3\u{202F}mg/kg doses in therapeutic contexts.:
  Certainty --- medium \[likely depends on frequency of use\]. One especially rigorous observational study of recreational use (median of 44 occasions) gave recreational users a battery of 15 neuropsychological tests~@halpernMormonRavers. That ruled out large effect sizes but didn't have the statistical power to rule out low-to-moderate effect sizes for heavy users. One small randomized study of MDMA therapy also did not find any significant cognitive effects after two sessions~@mithoeferSafety. Animal studies show inconsistent and mild effects~@baggottDamage. One of the best observational studies, #textcite(<corayMemory>), found an association between MDMA and long-term cognitive impact. However, even that study did not adequately control for factors that are not present in therapeutic contexts, like overheating and drug mixing. Surfacing of traumatic material may also occasionally cause endogenous-opioid- or panic-induced cognitive impairment. #textcite(<wolfgang2025>) and #textcite(<passieHistory>) discuss the issue in further detail.
]

= Information for Practitioners
<practitionerSkills>
This section is a collection of things particularly relevant to therapists and guides that I've come across while writing this book. Note that this book does not substitute for high-quality training.

#lead[Skills]
It is important for practitioners to effectively help their clients through various difficult experiences. #textcite(<bender2025provider>) surveyed psychedelic (not just MDMA) therapy practitioners about the most challenging experiences they have managed in clients across all types of psychedelics. These were, from most to least common and excluding categories only reported by a single respondent to ensure they represented something of a consensus:
- intense dysphoria
- disappointment with treatment
- reengaging with traumatic experience
- desiring to leave a session under the influence
- agitation (e.g., screaming, anger)
- difficulty with immersion in the experience
- post-treatment emotional instability
- suicidality

It's also important for practitioners to be proficient in identifying and successfully working with opioid dampening and panic during MDMA sessions (see @sec:defensecascade and @sec:sessionbarriers).

#lead[Ethics]
Maintaining especially high ethical boundaries is critical because MDMA can create intense feelings of trust and connection. A number of practitioners have used psychedelics to abuse their clients~@hallMad@davidsonEisner.

#lead[Treatment]
Evidence does not support phased treatment (a stabilizing/resourcing phase preceding reconsolidation)~@selePhased@oprelPhased@vlietPhased. Starting with reconsolidation is just as effective. It's conceivable, but not established, that there are exceptions for cases of extreme dissociation.

#lead[Experience]
#textcite(<simmering>) recommends that personal experience with MDMA therapy is helpful but not necessary for therapists. Clients want to know that their practitioner understands what they will experience and how the process works. I think learning that via first-person experience is much more thorough and grounded than learning it secondhand. In my view, personal experience with MDMA-facilitated reconsolidation is also more helpful than experience with MDMA in other contexts.

#lead[Recommended reading]
- #prosecite(<eckerUnlocking>) popularized the memory reconsolidation theory of therapeutic improvement. I think it is required reading for all mental health practitioners. #prosecite(<ecker2015misunderstood>) is a complementary resource. At least read this excellent summary of #textcite(<eckerUnlocking>): #prosecite(<lesswrongCoherenceTherapy>).
- #prosecite(<kozlowskaDefenseCascade>) lays out a biological framework for tonic/collapsed immobility, flight-or-fight, and threat-induced alertness. As the paper itself notes, the descriptive part is more solid than the Clinical Interventions part. I also suggest caution about some proposed mechanisms of action because the paper occasionally relies on polyvagal theory~@luckPolyvagal. While many people find therapeutic interventions associated with polyvagal theory helpful, the theory's foundation in specific neuroanatomical and evolutionary claims has not held up to empirical scrutiny.
- #prosecite(<razviPSIP>) discusses how to deal with dissociation during a session. It is clinical experience rather than science.
- #prosecite(<hayes2020complex>) summarizes the complex systems approach to therapeutic change.
- #prosecite(<berghPsychogenic>) created a popular, mechanistic theory of somatic symptoms.
- Scott Alexander's relevant blog posts: #citetitle(<alexanderSurfing>), #citetitle(<alexanderPrecision>), and #citetitle(<alexanderTrapped>).

= Reports of Internalized MDMA Therapy
<internalizedReports>

== My Experience

#quote(block: true)[
My first MDMA session (2021) consisted of seemingly perfect safety and all-encompassing compassion. I realized how everyone's stuck reactions were due to learned, no-longer-helpful fears. I also felt a well of inviolable safety and emotional resilience inside me so strong that I thought I would feel okay inside even if I watched everyone and everything I had ever loved die in front of me. There was also a _stillness_ with with no craving and aversion (in the Buddhist sense I think). 

There was a certain week in 2022 or 2023, after perhaps 10 more MDMA therapy sessions, when I went walking to feel my anxiety. It felt really good to feel my anxiety for some reason I no longer clearly recall. It also gave me a strong therapy hangover. That week of reconsolidation is the earliest example I recall of reconsolidation that just _happened_ with no deliberate effort or control on my part.

Later in 2023, after about session 20, I read an article describing the process of coherence therapy and wanted to try it on myself. In coherence therapy you find a strong contradictory experience for your stuck schemas. Once you have a mismatch, you activate both the mismatch and the stuck schema at the same time. Then, keeping that juxtaposition in place will reconsolidate the stuck schema.

I thought the inviolable-safety memory was the obvious choice for a mismatch. I activated it by vividly imagining lying under the tree I was under during that first MDMA session, how the dirt felt on my feet, and how the tree trunk felt in my hands. That activated the inviolable-safety knowledge strongly enough to start the reconsolidation process; the stuck schema I was working on was already activated. This was great; it was the first time I was able to make therapeutic progress without MDMA. The process was powerful enough to reconsolidate any stuck schema, just like MDMA. Also, like MDMA, it wasn't limited by the typical window of tolerance; it worked well during opioid dampening, intense avoidance, and near-overwhelming anxiety.

My mental health was terrible, so I was anxious to do however much reconsolidation was necessary to fix my issues in as short a time as possible. At first, coherence therapy using inviolable safety only worked in the two-week afterglow following an MDMA session. I was also limited to two hours a day by therapy hangovers. It took about another 5 MDMA sessions and two hours a day of coherence therapy in the afterglow to extend the process past two weeks. At that point I stopped MDMA therapy as it seemed redundant, and I was worried about side effects from high-frequency sessions.

Eventually, after a couple hundred hours of that practice, I no longer had to explicitly recall that knowledge of inviolable safety. Any time I noticed distress that, I could just "flip a switch" in my mind and start the reconsolidation process.

Then after a further 300~hours of practice, reconsolidation started happening without deliberate intent whenever a stuck schema is strongly activated, and I'm not actively avoiding it. It can happen when I'm watching videos, talking to people, or doing other activities. I can tell when it's happening, but I might not notice if I'm sufficiently distracted. The reconsolidation process seems to be activated by fear; the more afraid I am, the higher the intensity of reconsolidation. Particularly intense fear will even _push through_ a therapy hangover and let me do more reconsolidation than I otherwise could. If I want to turn up the intensity of reconsolidation, I can also still deliberately "flip the switch."

I later did more MDMA therapy sessions and gained a deeper understanding of the similarities and differences between MDMA therapy and internalized MDMA therapy. Both states of mind reconsolidate any stuck schema and function during panic, opioid dampening, and avoidance. Explicit understanding of schemas is much clearer on MDMA. During internalized MDMA therapy, I have a partial view of the schema. I'll notice the belief "I don't matter," for instance, along with anger. On MDMA I see the whole schema, which in that instance was "I'm angry that I don't matter to you. I'll die if I don't matter to you." Reconsolidation also seems much faster on MDMA, though it's hard to tell whether I'm spending a long time reconsolidating one "I don't matter" schema during internalized MDMA therapy or actually cycling through a number of "I don't matter" schemas. On MDMA it is much easier to distinguish between subtly different schemas.

Avoidance, justification, projection, and identification are also much less active on MDMA. During a couples therapy session with my sober partner, I, on MDMA, was able to express my fears and angers (and reconsolidate the underlying schemas) as simple facts of my internal experience. Unlike in normal life, I wasn't trying to get her to do anything different or blame her for any of it. Much of the content was dark, but she said she didn't feel defensive because I wasn't making any of it about her.

I've also noticed that I can reconsolidate different schemas on MDMA for unclear reasons. Once when I was in tonic immobility for a week, auto-reconsolidation was reconsolidating some schemas, but apparently not the ones causing the immobility. I did an MDMA therapy session and immediately confronted the "I'm dying right now" schemas causing the immobility. The session reconsolidated those schemas, and the immobility didn't return. It may be that avoidance was inhibiting me from confronting those schemas, and only MDMA let me do it.

As of #datetime.today().year(), I've done about #reconsolidation-hours~hours of reconsolidation. I've made tons of progress working through my backlog of stuck schemas, and I've become much less neurotic about many things. Unfortunately, severely disordered attachment and suspected childhood sexual abuse left me with an immense backlog of ever-present stuck fears and angers. Internalized MDMA therapy has been incredibly convenient for doing huge amounts of therapy without a therapist or MDMA. It also doesn't require the usual explicit process overhead of understanding my stuck schemas, figuring out a mismatch for each one, and then setting up the juxtapositions. It's kept me making therapeutic progress through periods of despair and depression when I surely wouldn't have had the capacity for any sort of typical therapy.

The only downside I have noticed is that since I have many strong stuck fears activated every waking moment, the auto-reconsolidation also starts running every morning once I wake up enough. That inevitably leads to a therapy hangover a bit later. Then the auto-reconsolidation starts up again once the therapy hangover wears off. I've been therapy hungover most of my waking hours since I started the practice. I also haven't discovered any way to turn auto-reconsolidation off. It goes for about 2~hours a day, limited only by therapy hangovers. Other than "flipping the switch" to increase reconsolidation intensity, the only control I seem to have over the process is which stuck schemas are activated. I can activate different schemas by going to different places, doing different things, talking to people, etc. This causes the auto-reconsolidation process to preferentially reconsolidate the schemas those contexts activate. This lack of control is not optimal,#footnote[The lack of control might actually be a benefit. Many people drastically underestimate the benefits of reconsolidation, and the lack of control kept the process going through any periods where I might have been too depressed to manually reconsolidate.] but the process keeps delivering therapeutic progress, and I haven't noticed any unambiguous side effects yet apart from therapy hangovers.

// One day in 2024, after about 600\,hours of reconsolidation, I was riding my bicycle and suddenly felt my sense of self become partially continuous with \enquote{external} reality. My thoughts, awareness, and the external world all felt to some degree part of the same unitive reality, no longer as divided as they used to be into self and not-self. This wasn't dissociation; I was still in touch with \enquote{my} body, emotions, and sensory experience, and could function appropriately. The effects waxed and waned over a few months and brought up a lot of distress caused by viscerally experiencing my sense of self as an impermanent construction. Luckily, internalized MDMA therapy reconsolidated all that distress. The sense of self settled into a stable, less rigid state that became a new and unremarkable normal that doesn't seem accompanied by any dysfunction.
// In 2025 I had a second experience where I suddenly perceived everything as processes rather than as immutable entities. That triggered another round of fears as well. This cycling has repeated many times since then, with each cycle being a new layer of perceiving my inner experience more accurately.
// I learned that these \textit{insight cycles} are a documented process that sometimes happens after using meditation,\footnote{Meditation is often done for the explicit purpose of entering and completing these cycles. See \cref{selfinsight}.} psychedelics, and MDMA. I found \prosecite{ingram2018mastering} very helpful in describing what was happening.
// If \textcite{ingram2018mastering} is correct, the cycling is supposed to lead to a profound, permanent sense of inner peace at a distinct point. I haven't reached that yet. So far the benefits include a subtle feeling of at-homeness that is quite nice, and I am less confused about my self. The fear part of each cycle is unpleasant, but if this is the price for auto-reconsolidation, then it has been easily worth it.
]

== Interview With Anonymous.
The interviewee explicitly consented to their answers being published in this book.

#quote(block: true)[
*M.G.:* You mentioned you're able to enter an MDMA-like state via meditation. Would you describe what this state feels like? What differences does it have from an MDMA session?

*A:* It's clear that there is still a distinction between the effects of MDMA vs. the MDMA-like state that I can enter during meditation. For example, I don't get the same physiological response associated with MDMA (e.g., increased pupil size, increased heart rate, reduced appetite etc.), though I do get some jaw clenching which is interesting. I also don't get the same "rolling" waves of euphoria that you tend to get with MDMA. The way the process works for me is that for the first 30~minutes of the meditation, nothing will be happening. At around the 30~minute mark I will start to feel the same calmness and safety that I felt on MDMA. I will feel deeply at peace and often emotional. It's common for me to cry. This state will persist for as long as I stay in the meditative state and for as long as I want it to. I will use this time to explore what I processed in my actual MDMA sessions, and to explore things associated with my trauma that are still troubling me. Before MDMA-assisted therapy, I practiced meditation regularly but I had never been able to enter states like this before. I would be able to feel calm, but not the safety and peace that I felt on MDMA. This skill only came about after MDMA therapy.

*M.G.:* My framework for how MDMA therapy works is that during the session you activate one of your maladaptive fear/anger/sadness/etc. reactions that you learned in the past, but is no longer appropriate. Then you sit with that feeling and the MDMA just "unlearns" it over a period of minutes to tens of minutes. Then that particular chunk of reaction doesn't come back after the session, and it's easier to see what the reaction was and what role it played in your life. Of course, there might be many different instances of that reaction to unlearn, and each one has to be individually addressed. Is that how MDMA therapy works for you? Is it also how using the MDMA-like states work?

*A:* I would say that your framework is partially true for me. I was able to shift certain emotions, particularly shame, and realise they were no longer appropriate. I also had a session where I came to a compromise with one of my emotions, fear. Instead of trying to convince myself that it was no longer appropriate, I validated it, and showed myself that it was okay to still feel fear, but instead we could learn to tame it with gentle talk and self-reassurance. I would say the biggest benefit of MDMA therapy was

+ I developed a new internal voice that was compassionate, rather than critical. When I am scared, when I am having PTSD symptoms, when I'm struggling, I now jump to self-compassion rather than self-hatred. I had spent 8~years in therapy trying to learn self-compassion without success. After MDMA therapy, that self-compassion was born and has persisted.

+ My sessions came with a lot of visualisation techniques. I experienced sexual trauma, and I had a lot of visualisations of myself handing over my anger and shame from myself to my perpetrator. I imagined the things that I would say to him now if I could. I imagined the things that I would say to myself in the wake of the trauma.

When I do my MDMA-like meditations now, I do visualisations once I enter that "state." The music is also very important. I will play "psychedelic-assisted therapy" music through noise-canceling headphones. I will also set up my space in much the same way that I was during the sessions - lying down with a weighted blanket and with lights dimmed. Sometimes I will also use an eye mask. I find this best facilitates an MDMA-like state for me.

*M.G.:* Would you describe what role the meditation and music played in first developing the capacity? Did the MDMA-like state appear the first time you meditated with music or only after a while? Did it happen after the first MDMA session or did it take multiple?

*A:* The ability came after my first MDMA session. I was meditating as a part of my integration practice, and one day I was listening to similar meditative music that was played during my session. Approximately 30~minutes into the meditation I had an outburst of emotion and peace that felt nearly identical as to what happened in my session. I ended up lying there for about 2~hours in this state. After having this experience, I started doing it regularly. I now practice it once a week or so. I spoke to the psychiatrist who sat with me for the session and he was intrigued, but he felt that it was unlikely to persist. I decided to keep practicing it in hopes that it would. A year later and it's still present.

*M.G.:* Are there any specific features of certain MDMA sessions you think were critical to developing the capacity? What larger role if your life has this capacity played? Has anything about the capacity changed over time?

*A:* Probably the feature of MDMA therapy that helped in generating this skill was the general sensation of safety that came with MDMA therapy. I felt safe with the psychiatrist sitting with me, and the drug created a window of safety that I had never felt before. My life has been marred by sexual and gender-based violence, so I had no reference point for what safety was. Now that I had an idea of what safety could look like and mean, I can now generate it internally by meditation. This effect has been beautiful in my life. Now, when I struggle with fear and a lack of safety, I know there is a place within me that I can always retreat to if I want to feel safe again. I wouldn't say anything has really changed over time except that maybe initially I viewed this skill purely as a way for me to continue doing the cognitive work by entering a MDMA-like state and continue processing my trauma, but now I view it also as a space to help me self-regulate if I am struggling with my PTSD-symptoms. If I find that I am having a few nightmares again or if I've had some strong triggers, I can grant myself a break from my anxiety and enter into a place of warmth and comfort.

*M.G.:* What type of meditation do you do for this?

*A:* I don't do any "formal" type of meditation. Essentially I lie down on a flat surface, usually a couch or a bed, with a weighted blanket and noise canceling headphones, just as I did in my treatment sessions. I usually close my eyes and focus on my breath, usually beginning with long and slow breaths leading into a box breathing type of pattern until I hit the 30~minute mark when the "effects" start to emerge. At this point I am able to open my eyes, stop focusing on my breath, and let my mind wander.

*M.G.:* Do you think the first 30\u{202F}min of meditation prior to the safety and calm emerging is doing something to bring the safety forth? Or is the emergence at 30\u{202F}min just an association your brain has made, like "oh this is the part where I'm supposed to turn on the safety"?

*A:* In terms of the first 30~minutes, I think before are correct actually. I think that first 30~minutes is an important space for me to just seek to relax my nervous system. In my first treatment in particular, the first 30~minutes was a particularly daunting time. I had never done MDMA before or even any kind of drug besides marijuana, so I was very anxious about what was going to happen to me. I spent the first 30~minutes in my first treatment session trembling, trying to calm my breath, and placing my trust in my sitter to keep me safe. Simultaneously, I now have an association with the 30~minute mark as being the time when MDMA would approximately take effect, so I think my brain also has an assumption that that is the moment when the deep sense of safety is supposed to turn on.

*M.G.:* How does the durability of therapeutic improvement in the long-term compare between this capacity vs. with MDMA, when you do use it to process trauma?

*A:* I would say "durability" doesn't quite fit here for me. Instead it's like an add on experience. I'm adding new healing experiences that add on to the original MDMA experiences, which ensures the durability of my original treatment. I would say that the capacity to make sense of deeply painful emotions, thoughts and beliefs are the same between the MDMA sessions and the non-MDMA sessions, and that both are equally durable for me.

*M.G.:* Do you get exhausted ("therapy hangover") when you use the capacity for processing trauma?

*A:* I don't get "therapy hangover" fortunately from this. I actually get an "after glow" just like with my MDMA sessions. This afterglow persists for 3--4~days, and is characterised by an ongoing sense of calm, opennness and wholeness. Eventually this fades, but it doesn't mean I return to my original state. I am always inching forward towards healing.

*M.G.:* You said you feel deeply emotional in the state. Is that just because some trauma feeling is activated, or does the emotion feel tied to the state itself?

*A:* That deeply emotional state is a release of all the emotions I was holding on to. I have a tendency to overregulate my emotions. I push them down and suppress them. When I enter that state of calm, my emotions feel safe to emerge and they emerge strongly. This is also what happened on MDMA. When I felt that first moment of safety on MDMA, I unleashed a cascade of emotions. I cried for much of my first session. So I would say that emotional release is an embodiment of what I had been suppressing, and it only felt safe to come out once I entered that state.

*M.G.:* Have you had any disruptions to your sense of self, temporary or lasting?

*A:* I have had lasting changes to my sense of self since MDMA therapy. Before, I had a persistently negative sense of self. I believed that the trauma was my fault and that I was burden for not being able to heal. I didn't believe that I had much value and that I was unlovable because of what had happened to me. I believed that nobody could love a rape victim like me. My sense of self changed over the course of the 3 sessions. I saw that I had inherent value just for being a person, and that what happened to me had no affect[sic] on my worth. Anybody who treated me otherwise didn't matter. It was a problem with them, and not with me. I think the combination of MDMA therapy plus the presence of a therapist was critical to this change. While there are a lot of people with non-relational PTSD, it is more common for people to have PTSD from some kind of interpersonal trauma. The victim internalises the idea that this display of dominance means that there must be something wrong with them, especially if the victim was young when it happened. Healing from this interpersonal trauma requires relational healing, which for me meant being present with a male therapist who attentively listened for hours at a time, who didn't make any unwanted sexual advances on me, and who helped me understand that it was not my shame to carry. That shame lied with the perpetrator. Having the MDMA on board meant that this new belief was able to solidify, perhaps due to MDMA's prosocial and neuroplastic effects.

*M.G.:* Oh I should have specified that I meant a more fundamental sense of self, like the felt sense that there is a "you" that decides things, does things, believes things, etc. Extensive meditation and psychedelics sometimes cause lasting disruptions to this.

*A:* I wouldn't say there was much change to my fundamental sense of self. I am still me and I still exist as my own separate person. However, I would say things are perhaps a little more fluid now, perhaps because I feel more connected to the broader human experience. I did come to feel a sense of "oneness," that we are all part of something together, just living our own separate parts of it.
]

= Mechanism of Action Hypotheses
<ppHypotheses>
I've developed several informal hypotheses for MDMA therapy's mechanism of action and how some people internalize the process of MDMA therapy. The evidence I list is anecdotal and phenomenological; I am not aware of any experiments that convincingly inform these ideas.

In this section I switch from memory reconsolidation terminology to predictive processing terminology for precision. The predictive processing terms here are used as conceptual vocabulary rather than mathematically precise definitions. Hopefully these hypotheses are helpful for prompting more formalized investigation. A _prior_ or collection of _priors_ is roughly equivalent to a schema in this context. The _precision_ of a prior or sensory information refers to its certainty, and _updating_ is essentially reconsolidation in this context. Updating becomes significant when contradictory information is more precise than the prior.

I think any proposed mechanism of action needs to explain these facets of MDMA therapy:
- The fundamental process of MDMA therapy is learnable, as described later in this section and in @internalizedReports. Therefore, the process doesn't require the altered neurochemistry that MDMA induces, even though the altered neurochemistry may make the process easier and more powerful.
- MDMA therapy appears to facilitate prediction error for all stuck priors involving negative emotions that are active and you stay present with. Therefore, MDMA must either provide high-level contradictory information applicable to all stuck priors or disable some prediction-error-inhibiting process.

With those constraints in mind, I propose the following hypotheses. The supporting and contradictory evidence only lists what initially came to mind. It is not comprehensive.
#[
#show terms: it => context if is-html() { it } else {
  set par(first-line-indent: 0pt, spacing: 0.9em)
  for item in it.children {
    block(above: 1.2em, below: 0.65em, sticky: true, strong(item.term))
    pad(left: 1.5em, item.description)
  }
}
/ Fundamental Safety or Satisfactoriness:
  MDMA, along with meditation, does something to facilitate accurate perception of a particular kind of safety. This safety provides a profound "everything is okay just as it is" perception while simultaneously not deactivating healthy threat avoidance. Similarly, this safety does something to facilitate updating of stuck threat-avoidance priors but not adaptive threat-avoidance priors. It is unclear what this safety is or where it comes from. I speculate that it is some aspect of the present moment.

  _Supporting Evidence:_ People often feel that they discover a profound safety on MDMA even before they start engaging with stuck priors.

  _Contradictory Evidence:_ Profound safety is frequently not explicitly perceived while updating intensely distressing stuck priors, though it could be present but overshadowed.

/ Increased Metacognitive "Sensory" Precision:
  MDMA does something to increase the precision of explicit perception of the full structure of a complex of stuck priors. This creates a new higher-level representation of previously vague or disconnected priors. This higher-level model is easier to update than the previous, vague model.

  _Supporting Evidence:_ It feels like priors are more "clear" and fully comprehended on MDMA, even before the updating process completes. Transforming priors from vague feelings into explicit, coherent models is also typically a prerequisite for conventional therapy, and that transformation itself is often sufficient to reconsolidate the stuck priors~@eckerUnlocking.

  _Contradictory Evidence:_ None identified

/ Deidentification:
  High-level priors that model the self make stuck priors that we identify with (possibly in a subtle, automatic way) have aberrantly high precision. MDMA deidentifies some or all stuck priors from the self-model, causing their precision to return to an adaptive level. Adaptive precision makes regular sensory information or other priors precise enough to update the priors when attention is brought to those priors.

  _Supporting Evidence:_ It frequently feels like there is less identification on MDMA.

  _Contradictory Evidence:_ Decreased identification could be a downstream effect of updated priors or fundamental safety, rather than a cause. Identification can still be strong on MDMA. Successful updating in conventional psychotherapy also causes decreased identification.

/ Decreased Avoidance of Activating Stuck Priors:
  People often avoid activating overwhelming stuck priors, inhibiting prediction error. MDMA creates enough safety that avoidance is reduced. In this state, regular incoming sensory information or other priors are sufficient to update all stuck priors that are paid attention to.

  _Supporting Evidence:_ It frequently feels like there is less avoidance on MDMA. Conventional therapy also relies on decreasing avoidance to facilitate reconsolidation.

  _Contradictory Evidence:_ Avoidance can still be strong on MDMA. Decreased avoidance could be a downstream effect of updated priors, fundamental safety, or deidentification, rather than a cause. Successful updating in conventional psychotherapy also causes decreased avoidance.

/ Reduced Precision of Social/Relational Priors:
  #textcite(<carhart2019rebus>) proposes that MDMA reduces the precision of all priors that cause social inhibition. Therapeutically relevant stuck priors might largely fall into this category. Lowered precision of priors makes regular sensory information precise enough to update the priors when attention is brought to those priors.

  _Supporting Evidence:_ People often use MDMA to reduce social anxiety.

  _Contradictory Evidence:_ Does MDMA reduce other social priors to the extent it does social anxiety? It might also not be the only mechanism if MDMA therapy works for PTSD or anxiety that was solely caused by natural disasters or accidents.

/ Increased Capacity to Experience Multiple Concurrent Emotions:
  #textcite(<emilssonConcurrent>) suggests that MDMA increases the capacity to experience multiple emotions at the same time and that this is a factor in its ability to update stuck priors. Experiencing multiple contradictory emotions or priors at the same time may facilitate the juxtaposition that reconsolidates stuck priors.

  _Supporting Evidence:_ None identified

  _Contradictory Evidence:_ None identified
]

It's not clear which of these are causes and which are effects. Perhaps they all combine to form a complex causal structure where cause and effect are not separable. They may also be just poorly understood conceptions of a single unified mechanism of action.

As described in @internalizedReports, people sometimes internalize the process of MDMA therapy. Sufficient exposure to the state, whichever mechanism is correct, creates a model of the experience or perception through a new set of priors. Individuals sometimes reactivate the new model they learned, typically via associative cues (e.g., music, meditation, tactile sensations) present during the MDMA therapy session. The cues don't have to be physically present; high-fidelity imagination of the cues was sufficient in one case. If they realize what is happening, the individual may now know how to control the process.

Some people report using this state to update away stuck priors in the same way MDMA therapy can, though less intensely. Notably, one person reports that this process updates any stuck prior with none of the "overhead" associated with memory reconsolidation in conventional therapy. It also worked just as well in the presence of panic or dissociation, unlike traditional therapy. This is essentially the same process as MDMA therapy. Notably, for both individuals, the capacity for internalized MDMA therapy does not dissipate over time, as one might expect if it was a simple conditioned response.

I think the _stillness_~@stockerConnectogen and "everything is okay just how it is" (anecdotal reports) that MDMA can facilitate are also strikingly reminiscent of the absence of Duḥkha, a Buddhist concept meaning unsatisfactoriness. In that model, a subtle identification with craving (a pull toward pleasant sensations) and aversion (a push away from unpleasant sensations), rather than mere preferences, creates a baseline level of suffering/Duḥkha. The involvement of identification also circles back to the Deidentification hypothesis. Perhaps MDMA can not only deidentify people from specific stuck schemas, but from craving and aversion themselves. See @selfinsight for further discussion. #textcite(<ingramMDMA>) has also noticed a related link.

= Alternatives to MDMA
<alternatives-to-mdma>
Other drugs in the same class as MDMA may also be useful for therapy. The following are the most promising candidates that I'm aware of, though none have gone through as much safety and efficacy testing as MDMA.
- Methylone therapy had good results in a phase II clinical trial for PTSD~@methyloneRCT. The dose was 150\u{202F}mg plus a 100\u{202F}mg booster dose 90~minutes later. Like MDMA, it is illegal in many jurisdictions.
- #textcite(<baggottNewEntactogens>) reports that 5-MAPB is anecdotally the closest single-drug analog to MDMA. The therapeutic dose is unclear, but #textcite(<erowid5MAPB>) reports that a common dose is 30--70\u{202F}mg. It is illegal in many jurisdictions.
- #textcite(<boraxMDMA>) developed a specific ratio of 2-FMA, MDAI, 5-MeO-MiPT, and 5-APB succinate whose effects are almost identical to MDMA's in their experience. They also discuss possible substitutions. The dose depends on the specific components used. Some components are legally available in some jurisdictions.

= Suggested Avenues of Future Research
<suggested-avenues-of-future-research>
I think the following research questions are particularly interesting or relevant to the practice of MDMA therapy.
- What is the irreducible set of mental states that MDMA induces? It seems to induce love, safety, emotional empathy, "stillness," "things are okay just as they are," connection, and sociability. Are those reducible to some smaller set of fundamental states? Answering this might require resolving multiple major open problems in fundamental neuroscience.
- What is the nature of reconsolidation exhaustion (therapy hangover)? Can the capacity be safely increased? That would enable more productive MDMA therapy sessions, which anecdotal reports suggest are often limited by reconsolidation exhaustion.
- Multiple people report increased capacity to reconsolidate while sober in a way phenomenologically and consequentially similar to what is experienced during MDMA therapy sessions (see @internalizedReports). This appears to be connected to prior MDMA therapy. How does this work? Anecdotal reports also suggest that some individuals with no MDMA exposure can use the present moment to reconsolidate all stuck schemas. Is that the same phenomenon as internalized MDMA therapy?
- Why does MDMA seem to provide prediction error for most, if not all, stuck schemas, but not the adaptive ones? See @ppHypotheses for my hypotheses.
- How can therapists best prepare their clients for solo at-home sessions?
- To what extent does MDMA causes valvular heart disease? Accurate human guidelines are needed that account for number of sessions, session spacing, body-mass-adjusted dose, and possibly CYP2D6 capacity.
- How long does short- and long-term tolerance to MDMA last? How does it work?
- How long does it take to restore the brain's antioxidant buffer after an MDMA therapy session?
- To what degree is symptom worsening avoidable or reducible while achieving the same amount of reconsolidation?
- Some stuck schemas (or their symptoms) seem to activate other stuck schemas. It's conceivable that one could resolve multiple stuck schemas at once by reconsolidating the "root" schema. In such a case the other stuck schemas may still exist but wouldn't be an issue because they are never activated. This appears valuable but might require understanding the relevant schemas and their relationships with each other. I don't know to what degree such a process is theoretically possible, practically achievable, or time efficient. It's also unclear whether MDMA, as a facilitator of seemingly universal prediction error for all stuck schemas, can be used to precision-target a single schema in a stack of simultaneously activating stuck schemas.
- Who is most at risk of symptom worsening? The current commonly used risk factors (history of psychosis, mania, personality disorders, active suicidality, heavy dissociation, diagnosed mental illness) appear to be partly based on guesses and liability-avoidance. Precise and assessable risk factors are important for determining who MDMA therapy will work best for and whether someone should do it solo vs. practitioner guided.
- Are there factors that cause MDMA therapy to not work for some people, apart from too low or too high a dose, opioid dampening, avoidance, muting, and drug interactions like with SSRIs?
- Why does reconsolidating certain schemas frequently require first reconsolidating some other schema?
- Are conventional therapeutic reconsolidation exercises more effective in the post-MDMA afterglow period? Why? For how long?
- The process of MDMA therapy often involves a flow of a schema becoming the object of perception and then reconsolidating, a different schema becoming the object of perception and then reconsolidating, etc. This sequence might be a valuable clue to how schemas form complex systems.
- In what circumstances should someone do another MDMA session to resolve the symptom worsening from a previous MDMA therapy session? When will another session increase or decrease symptoms? On what time scale?
- Does MDMA only reconsolidate the single schema that is currently the object of perception/focus, or does it also reconsolidate other schemas at the same time? Perhaps it reconsolidates a network of related schemas.
- Why do people apparently in tonic or collapsed immobility on MDMA sometimes transition to a state where they feel sober or bored (see #textcite(<razviDissociation>))? Alternatively, they can start off sober or bored and never seem feel the effects of MDMA.
- Therapy is a process of moving from the individual's current position in the schema/environment state-space to a better position. It's conceivable that different paths between these two states are possible. How possible and practical is it to plot and follow the shortest-distance reconsolidation path? How optimal are the typical paths in MDMA therapy, where the individual either reconsolidates whatever schemas naturally arise or deliberately activates certain schemas they want to work on?
- For people who need a higher dose, is it better from efficacy and oxidative stress standpoints to bump up a split dose (e.g., going from 120\u{202F}+\u{202F}60\u{202F}mg to 140\u{202F}+\u{202F}70\u{202F}mg) or frontload the whole dose (e.g., going from 120\u{202F}+\u{202F}60\u{202F}mg to 180\u{202F}mg)?
- Does MDMA therapy optimize your schemas according to your existing set of fundamental prediction errors or to some MDMA-modified set?

#show: backmatter

#print-glossary(glossary)

= Bibliography
<bibliography>
#bibliography("references.bib")

= Earlier Revisions
<sec:revisions>
#lead[Changes from version 6 to 7]
Added the Issue Comes Back After What Feels Like Successful Reconsolidation and Not Accessing Any Memories of Traumatic Events troubleshooting sections. Partially rewrote #nameref(<sec:complex>), #nameref(<frequency>), #nameref(<sec:mechanism>), and #nameref(<selfinsight>) to improve rigor and clarity. Split the term _avoidance_ into _avoidance_ and _muting_ to better categorize the phenomena based on mechanism. Improved grammar through #nameref(<introduction>) more rigorously than previous rounds of spell/grammar checking. 

Finished removing Thomas Harper's content. I replaced their major section, How to Find a Practitioner, with a few paragraphs that link out to equivalent information written by other people.

#lead[Changes from version 5 to 6]
There's now an ebook version at #link("https://github.com/groeneveld/mdma-guide/raw/refs/heads/main/Open%20MDMA.epub"). There a few minor formatting issues that I haven't figured out how to fix, including section headings in the Table of Contents not displaying at the right level and missing Appendix and Bibliography headings. There's also an HTML version at #link("https://groeneveld.github.io/mdma-guide/").

Substantively edited almost everything for clarity, logical flow, and rigor. This meant rewriting about a third of the content. Also fixed almost all the grammar and spelling issues. Added the Feeling Like You are Going Crazy troubleshooting subsection. Added Alternatives to MDMA. Removed Our Pitch because it didn't fit in well and was redundant. Removed Psychoeducation and Self Determination Theory because they were also redundant. Removed Making Sense of the Experience and distributed its content to Precautions and Uncertain Memory. Reorganized #nameref(<sectionManagement>). Shuffled a few other sections around. Condensed Making Positive Life Changes to a small subsection at the end of #nameref(<sec:lifechanges>). Moved Thomas Harper from an author to an acknowledged contributor since they're no longer a part of the project.

#lead[Changes from version 4 to 5]
Removed the two Beyond Therapy sections and Organizing Community Care because they were overly influenced by our own stuck schemas. Added #nameref(<ppHypotheses>), #nameref(<bigPicture>), #nameref(<attention>), the Sessions Become Less Effective Over Time troubleshooting subsection, Plain Language Summary, the Psychosis troubleshooting subsection, and the subsection Reasons to be Skeptical to #nameref(<methodology>). Rewrote #nameref(<psychogenic>), #nameref(<frequency>), and the Safety section bullet point on psychosis. Split Epistemic Status into #nameref(<sec:assumptions>) and #nameref(<howtoevaluate>). Shuffled around various sections into different chapters or renamed them. Bumped up the risk assessment of frequent higher-dose sessions due to #textcite(<corayMemory>). Also made a lot of little changes here and there.

#lead[Changes from version 3 to 4]
Added Preface, #nameref(<sec:complex>), subsections Major Unresolved Issues and Reference Quality in #nameref(<methodology>), subsection Acute Effects in #nameref(<sec:safety>), self-reports of internalized MDMA therapy, paragraph on involuntary hospitalization, and Cognitive Flexibility and Truth Seeking. Rewrote #nameref(<sec:moreReconsolidation>) and #nameref(<sectionManagement>). Also made a lot of little changes here and there.
