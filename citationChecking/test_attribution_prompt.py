#!/usr/bin/env python3
"""
Script to test and improve the attribution unit marking prompt.
This script extracts paragraphs from paper.tex, calls Claude to mark attribution units,
and helps evaluate different prompt variations.
"""

import re
import subprocess
import json
import sys
from typing import List, Dict, Tuple

def extract_citations_from_text(text: str) -> List[Tuple[str, int]]:
    """Extract all citations and their positions from text."""
    citations = []
    # Match \cite{...} and \textcite{...}
    for match in re.finditer(r'\\(?:text)?cite\{([^}]+)\}', text):
        citation_keys = match.group(1)
        position = match.start()
        citations.append((citation_keys, position))
    return citations

def extract_paragraphs_with_citations(tex_file: str, max_paragraphs: int = 10) -> List[Dict]:
    """Extract paragraphs that contain citations from the LaTeX file."""
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split into paragraphs (double newline or section breaks)
    paragraphs = re.split(r'\n\s*\n', content)

    paragraphs_with_citations = []
    for para in paragraphs:
        # Skip if too short or doesn't contain citations
        if len(para) < 100 or not re.search(r'\\(?:text)?cite\{', para):
            continue

        # Skip LaTeX commands/preamble
        if para.strip().startswith('\\') and para.strip().startswith(('\\documentclass', '\\usepackage', '\\begin{document')):
            continue

        citations = extract_citations_from_text(para)
        if citations:
            # Get unique citation sets
            citation_sets = list(set([c[0] for c in citations]))
            paragraphs_with_citations.append({
                'text': para.strip(),
                'citations': citations,
                'citation_sets': citation_sets
            })

        if len(paragraphs_with_citations) >= max_paragraphs:
            break

    return paragraphs_with_citations

def create_test_examples() -> List[Dict]:
    """Create hand-crafted test examples with expected outputs."""
    examples = [
        {
            'paragraph': 'A variety of risk factors reduce the capacity to bounce back and form healthy schemas for that situation. Post-trauma factors for children, adolescents, and presumably also adults to a large degree, include blaming others, thought suppression, distraction, low social support, social withdrawal, poor family functioning, and parental psychological problems \\cite{trickeyRiskFactors}. \\cite{tangRiskFactors} also found that female gender (this may function differently in different cultures), unemployment, and low education are risk factors for adults. Resilience to trauma is complex \\cite{bonanno2008loss}, but it may be that many of those items are risk factors because they are generally situations of broad resource (emotional, physical, social) insecurity, which are additional pieces of evidence reinforcing overly-general high-threat predictions like "I\'m in danger everywhere \\cite{berghSelfEvidencing}." The risk factors may also reduce circumstances that promote nuance (e.g. "My friendships remind me that I\'m safe in many circumstances" or "I am already emotionally secure") or may directly inhibit reconsolidation (e.g. thought suppression).',
            'citation_set': 'berghSelfEvidencing',
            'expected': 'A variety of risk factors reduce the capacity to bounce back and form healthy schemas for that situation. Post-trauma factors for children, adolescents, and presumably also adults to a large degree, include blaming others, thought suppression, distraction, low social support, social withdrawal, poor family functioning, and parental psychological problems \\cite{trickeyRiskFactors}. \\cite{tangRiskFactors} also found that female gender (this may function differently in different cultures), unemployment, and low education are risk factors for adults. Resilience to trauma is complex \\cite{bonanno2008loss}, ->but it may be that many of those items are risk factors because they are generally situations of broad resource (emotional, physical, social) insecurity, which are additional pieces of evidence reinforcing overly-general high-threat predictions like "I\'m in danger everywhere \\cite{berghSelfEvidencing}."<- The risk factors may also reduce circumstances that promote nuance (e.g. "My friendships remind me that I\'m safe in many circumstances" or "I am already emotionally secure") or may directly inhibit reconsolidation (e.g. thought suppression).',
            'note': 'Citation embedded in quoted text within larger paragraph with multiple other citations'
        },
        {
            'paragraph': 'Our potentially maladaptive schemas usually update when our ability to handle adversity increases (e.g. growing up) or when the original difficulty ends \\cite{eckerUnlocking}. As further discussed in the following section, the updating process is initiated by "prediction error." Prediction Error is a \\textit{consciously experienced, though not necessarily explicitly understood, contradiction} between the original prediction (e.g. "broccoli tastes bad" experienced as a child eating mushy broccoli) and a new experience (e.g "broccoli can taste good" experienced later an adult eating properly-cooked and seasoned broccoli). That prediction error updates your schemas over time with the new information. This new information can come from a variety of sources. A diverse array of sensory information continually enters the brain in the form of sight, sound, smell, touch, taste, a number of internal bodily senses like hunger, and mental senses like the ability to notice thoughts, emotions, and memories \\cite{berghSelfEvidencing}. This information is typically sufficient to reconsolidate schemas or create new schemas to adapt to new situations without a deliberate process like therapy.',
            'citation_set': 'eckerUnlocking',
            'expected': '->Our potentially maladaptive schemas usually update when our ability to handle adversity increases (e.g. growing up) or when the original difficulty ends \\cite{eckerUnlocking}. As further discussed in the following section, the updating process is initiated by "prediction error." Prediction Error is a \\textit{consciously experienced, though not necessarily explicitly understood, contradiction} between the original prediction (e.g. "broccoli tastes bad" experienced as a child eating mushy broccoli) and a new experience (e.g "broccoli can taste good" experienced later an adult eating properly-cooked and seasoned broccoli). That prediction error updates your schemas over time with the new information.<- This new information can come from a variety of sources. A diverse array of sensory information continually enters the brain in the form of sight, sound, smell, touch, taste, a number of internal bodily senses like hunger, and mental senses like the ability to notice thoughts, emotions, and memories \\cite{berghSelfEvidencing}. This information is typically sufficient to reconsolidate schemas or create new schemas to adapt to new situations without a deliberate process like therapy.',
            'note': 'Long multi-sentence elaboration on first citation, then new citation for different point'
        },
        {
            'paragraph': 'Schemas aren\'t just abstract beliefs about things, they also control actions and attention itself \\cite{clark2015surfing}. The phrase "the brain" in the previous list is shorthand for "a (possibly unconscious) schema or set of schemas that controls attention in a certain context." Attention control may be physical like orienting the eyes and head to certain objects, or internal like ruminating on certain things or not thinking about certain uncomfortable thoughts, emotions, or sensations. Attention control is flexible and can avoid specific abstract concepts in addition to broader categories of information or sensory input. A lot of symptoms and disorders look like internal avoidance from this attentional perspective. PTSD from assault often causes people to feel disconnected from their bodies \\cite{vanderKolkBody}. Alexithymia is basically disconnection from emotions \\cite{hogeveen2021alexithymia}. Mental illness frequently inhibits recall of autobiographical memories \\cite{berghSelfEvidencing}.',
            'citation_set': 'clark2015surfing',
            'expected': '->Schemas aren\'t just abstract beliefs about things, they also control actions and attention itself \\cite{clark2015surfing}. The phrase "the brain" in the previous list is shorthand for "a (possibly unconscious) schema or set of schemas that controls attention in a certain context." Attention control may be physical like orienting the eyes and head to certain objects, or internal like ruminating on certain things or not thinking about certain uncomfortable thoughts, emotions, or sensations. Attention control is flexible and can avoid specific abstract concepts in addition to broader categories of information or sensory input. A lot of symptoms and disorders look like internal avoidance from this attentional perspective.<- PTSD from assault often causes people to feel disconnected from their bodies \\cite{vanderKolkBody}. Alexithymia is basically disconnection from emotions \\cite{hogeveen2021alexithymia}. Mental illness frequently inhibits recall of autobiographical memories \\cite{berghSelfEvidencing}.',
            'note': 'Multi-sentence elaboration followed by three separate citations for specific examples'
        },
        {
            'paragraph': 'We posit that there are at least three practical ways of using MDMA to aid memory reconsolidation, though in reality, more than one of these may happen during any given MDMA therapy session: Using the mismatch facilitated by MDMA, whatever its exact source, to reconsolidate a maladaptive schema during the session by activating and staying present with the schema. This could be as simple as staying present with some fear-based schema, then noticing it dissipate over a span of minutes to 10s of minutes. This is common and the approach we advocate. Using the feelings of safety from MDMA to make your implicit ("I have this maladaptive behavior but don\'t understand why and don\'t know what the schema is") schemas explicit ("I do the maladaptive behavior because my schema says...."). Explicit schemas are often easier to mismatch through regular therapy after the session because finding a mismatch typically requires knowing what the schema is, absent extraordinary states of mind \\cite{eckerUnlocking}. MDMA may show you new knowledge (e.g. "I have an inner well of inviolable safety") that you can then use outside the session as a mismatch for a wide variety of maladaptive schemas. We\'re aware of a few anecdotes of this occurring.',
            'citation_set': 'eckerUnlocking',
            'expected': 'We posit that there are at least three practical ways of using MDMA to aid memory reconsolidation, though in reality, more than one of these may happen during any given MDMA therapy session: Using the mismatch facilitated by MDMA, whatever its exact source, to reconsolidate a maladaptive schema during the session by activating and staying present with the schema. This could be as simple as staying present with some fear-based schema, then noticing it dissipate over a span of minutes to 10s of minutes. This is common and the approach we advocate. Using the feelings of safety from MDMA to make your implicit ("I have this maladaptive behavior but don\'t understand why and don\'t know what the schema is") schemas explicit ("I do the maladaptive behavior because my schema says...."). ->Explicit schemas are often easier to mismatch through regular therapy after the session because finding a mismatch typically requires knowing what the schema is, absent extraordinary states of mind \\cite{eckerUnlocking}.<- MDMA may show you new knowledge (e.g. "I have an inner well of inviolable safety") that you can then use outside the session as a mismatch for a wide variety of maladaptive schemas. We\'re aware of a few anecdotes of this occurring.',
            'note': 'Citation in middle of list, author claims before and after'
        },
        {
            'paragraph': 'Presumably, in different situations therapeutic improvement may come from either 1) gradually making a maladaptive state less maladaptive, 2) a clear transition from one state to another existing state, 3) transition through a number of different states, or 4) destabilizing an entrenched maladaptive state then creating a new stable adaptive state or states. In simpler terms, therapy is a process of moving from stuck state(s) of mental illness to state(s) of mental health \\cite{hayes2020complex,friston2010free}. In this case stable mental health is defined as a system that quickly returns to an adaptive state when perturbed.',
            'citation_set': 'hayes2020complex,friston2010free',
            'expected': 'Presumably, in different situations therapeutic improvement may come from either 1) gradually making a maladaptive state less maladaptive, 2) a clear transition from one state to another existing state, 3) transition through a number of different states, or 4) destabilizing an entrenched maladaptive state then creating a new stable adaptive state or states. ->In simpler terms, therapy is a process of moving from stuck state(s) of mental illness to state(s) of mental health \\cite{hayes2020complex,friston2010free}. In this case stable mental health is defined as a system that quickly returns to an adaptive state when perturbed.<-',
            'note': 'Author speculation, then citation with elaboration in next sentence'
        },
        {
            'paragraph': 'It is difficult to jump from an entrenched state of mental illness to a weaker state of mental health \\cite{hayes2020complex}. Therapy can gradually weaken the entrenched state or strengthen weak states of mental health. Fluctuations between two states might become more frequent as the two states become more equal in strength and minor environmental changes are enough of a jolt to initiate a transition from one to the other. This destabilization might be distressing, but is often a sign of an immanent shift from the old maladaptive state being primary to the new adaptive state being primary. Further weakening of the old state or strengthening of the new state should resolve destabilization as the new state becomes even more stable and the old state becomes even harder to transition to. In simple terms, you can think of healing as standing up. Sitting and standing are both stable positions. The transition between the two is unstable, but must be passed through if you want to walk anywhere. This destabilization process could also theoretically signal an impending shift to an even more maladaptive state. However, a variety of experimental evidence indicates that destabilization during therapy tends to be marker of later therapeutic improvement rather than worsening \\cite{hayes2020complex,olthofDestabilization}.',
            'citation_set': 'hayes2020complex',
            'expected': '->It is difficult to jump from an entrenched state of mental illness to a weaker state of mental health \\cite{hayes2020complex}. Therapy can gradually weaken the entrenched state or strengthen weak states of mental health. Fluctuations between two states might become more frequent as the two states become more equal in strength and minor environmental changes are enough of a jolt to initiate a transition from one to the other. This destabilization might be distressing, but is often a sign of an immanent shift from the old maladaptive state being primary to the new adaptive state being primary. Further weakening of the old state or strengthening of the new state should resolve destabilization as the new state becomes even more stable and the old state becomes even harder to transition to. In simple terms, you can think of healing as standing up. Sitting and standing are both stable positions. The transition between the two is unstable, but must be passed through if you want to walk anywhere. This destabilization process could also theoretically signal an impending shift to an even more maladaptive state.<- However, a variety of experimental evidence indicates that destabilization during therapy tends to be marker of later therapeutic improvement rather than worsening \\cite{hayes2020complex,olthofDestabilization}.',
            'note': 'Long elaboration including metaphor, citation appears again at end with additional citation'
        },
        {
            'paragraph': 'We use the term "schema" to represent emotionally-significant beliefs that drive perception, attention, and behavior \\cite{eckerUnlocking}. But more broadly, all brain activity is functionally composed of innumerable schemas that model the world, interpret sensory information, and control action \\cite{clark2015surfing}. Perceived reality is largely a learned model that incoming sensory information just nudges into congruence with external reality. We never or only rarely consciously experience raw, unfiltered sensory information. For example, people don\'t perceive a gap in the visual field where the retinal nerve bundle passes through a hole in the retina. Thus, even healthy perception (e.g. feeling pain) and action (e.g. moving your limbs) schemas are not perfectly accurate, but are rather accurate-enough and useful-enough to efficiently accomplish tasks.',
            'citation_set': 'clark2015surfing',
            'expected': 'We use the term "schema" to represent emotionally-significant beliefs that drive perception, attention, and behavior \\cite{eckerUnlocking}. ->But more broadly, all brain activity is functionally composed of innumerable schemas that model the world, interpret sensory information, and control action \\cite{clark2015surfing}. Perceived reality is largely a learned model that incoming sensory information just nudges into congruence with external reality. We never or only rarely consciously experience raw, unfiltered sensory information. For example, people don\'t perceive a gap in the visual field where the retinal nerve bundle passes through a hole in the retina. Thus, even healthy perception (e.g. feeling pain) and action (e.g. moving your limbs) schemas are not perfectly accurate, but are rather accurate-enough and useful-enough to efficiently accomplish tasks.<-',
            'note': 'One citation, then new citation with multi-sentence elaboration including examples'
        },
        {
            'paragraph': 'In some cases sensory or action schemas predict significant symptoms or impairment (henceforth lumped in with symptoms) despite a total lack of current organ dysfunction or tissue damage \\cite{berghPsychogenic}.',
            'citation_set': 'berghPsychogenic',
            'expected': '->In some cases sensory or action schemas predict significant symptoms or impairment (henceforth lumped in with symptoms) despite a total lack of current organ dysfunction or tissue damage \\cite{berghPsychogenic}.<-',
            'note': 'Citation appears twice in same attribution unit with list items, then new citation'
        },
        {
            'paragraph': 'MDMA therapy has shown excellent results for PTSD in clinical trials \\cite{mitchellMDMAClinicalTrial,mitchellMDMAClinicalTrial2}. However, there is a great deal of controversy and confusion over certain aspects of those trials, and whether the FDA was correct in not approving MDMA until more data is gathered, as reported by the researcher Jules Evans on their blog \\textcite{evansBlame}. The Food and Drug Administration\'s response letter (\\textcite{crl}) lists the reasons they did not approve it. \\textcite{crlAlpha} analyses the response letter in detail. \\textcite{fdaVSdutch} discusses why a Dutch government commission came to the opposite conclusion and decided there actually was enough evidence of efficacy and safety to legalize MDMA therapy. We discuss some of these issues later in this section.',
            'citation_set': 'mitchellMDMAClinicalTrial,mitchellMDMAClinicalTrial2',
            'expected': '->MDMA therapy has shown excellent results for PTSD in clinical trials \\cite{mitchellMDMAClinicalTrial,mitchellMDMAClinicalTrial2}.<- However, there is a great deal of controversy and confusion over certain aspects of those trials, and whether the FDA was correct in not approving MDMA until more data is gathered, as reported by the researcher Jules Evans on their blog \\textcite{evansBlame}. The Food and Drug Administration\'s response letter (\\textcite{crl}) lists the reasons they did not approve it. \\textcite{crlAlpha} analyses the response letter in detail. \\textcite{fdaVSdutch} discusses why a Dutch government commission came to the opposite conclusion and decided there actually was enough evidence of efficacy and safety to legalize MDMA therapy. We discuss some of these issues later in this section.',
            'note': 'First citation only one sentence, then four more textcites in rapid succession with author framing'
        },
        {
            'paragraph': 'As previously mentioned, mental illness is a complex interaction of biology (genes and medical history), psychology (schemas, attention/avoidance), and social context \\cite{engel1977need}. We think reconsolidation can likely resolve the "psycho" part of "biopsychosocial \\cite{carhart2019rebus,eckerUnlocking}," which we suspect plays a major part in the majority of mental illness cases. Determining to what degree any particular issue is caused (either self-assessed or clinician-assessed) by maladaptive schemas is difficult, in no small part because the poor state of current mental health practice and science. For instance, the current categorization of mental illness in the DSM and ICD-CDDR are self-admittedly in large part just semi-arbitrary clustering of different symptoms \\cite{apaDSM,ICD}. They mostly do not attempt to determine causes.',
            'citation_set': 'engel1977need',
            'expected': '->As previously mentioned, mental illness is a complex interaction of biology (genes and medical history), psychology (schemas, attention/avoidance), and social context \\cite{engel1977need}.<- We think reconsolidation can likely resolve the "psycho" part of "biopsychosocial \\cite{carhart2019rebus,eckerUnlocking}," which we suspect plays a major part in the majority of mental illness cases. Determining to what degree any particular issue is caused (either self-assessed or clinician-assessed) by maladaptive schemas is difficult, in no small part because the poor state of current mental health practice and science. For instance, the current categorization of mental illness in the DSM and ICD-CDDR are self-admittedly in large part just semi-arbitrary clustering of different symptoms \\cite{apaDSM,ICD}. They mostly do not attempt to determine causes.',
            'note': 'Single sentence, then author opinion with embedded citations, then more citations'
        },
        {
            'paragraph': 'Robust scientific models are, as the pseudonymous blogger duo \\textcite{mechanisticModels} (one of whom is a cognitive scientist and statistician) state, is "a proposal for a set of entities, their features, and the rules by which they interact, that gives rise to the phenomena we observe." They also make a wide variety of accurate predictions in the area of their relevance. Physics represents an exceptionally high degree of alignment to this standard; it has such a complete model of atoms that their behavior can be predicted to many decimal points of precision. It also has a highly detailed and precise list of the entities involved (neutrons, protons, electrons, strong force, weak force, electromagnetic force) and the rules by which they interact. Few fields can match that level of completeness. In comparison, the political scientist Brian Klaas argues on their blog that the social sciences (psychology in our case) mostly use models that occasionally make good predictions in a narrow area, but rarely over a wide area \\cite{zombieSocialScience} (see also \\textcite{evidenceBasedPolicy}).',
            'citation_set': 'mechanisticModels',
            'expected': '->Robust scientific models are, as the pseudonymous blogger duo \\textcite{mechanisticModels} (one of whom is a cognitive scientist and statistician) state, is "a proposal for a set of entities, their features, and the rules by which they interact, that gives rise to the phenomena we observe." They also make a wide variety of accurate predictions in the area of their relevance.<- Physics represents an exceptionally high degree of alignment to this standard; it has such a complete model of atoms that their behavior can be predicted to many decimal points of precision. It also has a highly detailed and precise list of the entities involved (neutrons, protons, electrons, strong force, weak force, electromagnetic force) and the rules by which they interact. Few fields can match that level of completeness. In comparison, the political scientist Brian Klaas argues on their blog that the social sciences (psychology in our case) mostly use models that occasionally make good predictions in a narrow area, but rarely over a wide area \\cite{zombieSocialScience} (see also \\textcite{evidenceBasedPolicy}).',
            'note': 'Long block quote and elaboration from first citation, then contrasting citation from different source'
        },
        {
            'paragraph': 'These issues show up in a variety of ways in mental health science and practice: Mental illness is typically diagnosed according to somewhat arbitrary clusters of subjectively-assessed (either by the client or the clinician) symptoms \\cite{kotov2017hierarchical}. Mental illnesses are rarely objectively measurable or attributable to specific, well-understood causes. The current categorization of mental illnesses is significantly incorrect. The Hierarchical Taxonomy Of Psychopathology (HiTOP) offers a better clustering than the DSM or ICD-CDDR, but still doesn\'t explain what mental illness is or offer a convincing reason that categorization of most of the mental illnesses it investigates is even useful. Mental illness is hard to measure. Mental illness is mostly measured by questionnaires filled in by the client or clinician, which have uncertain and variable connections to the underlying phenomena that are labelled mental illness \\cite{uherRatingScales}.',
            'citation_set': 'kotov2017hierarchical',
            'expected': 'These issues show up in a variety of ways in mental health science and practice: ->Mental illness is typically diagnosed according to somewhat arbitrary clusters of subjectively-assessed (either by the client or the clinician) symptoms \\cite{kotov2017hierarchical}. Mental illnesses are rarely objectively measurable or attributable to specific, well-understood causes. The current categorization of mental illnesses is significantly incorrect. The Hierarchical Taxonomy Of Psychopathology (HiTOP) offers a better clustering than the DSM or ICD-CDDR, but still doesn\'t explain what mental illness is or offer a convincing reason that categorization of most of the mental illnesses it investigates is even useful.<- ',
            'note': 'List format with citation in first item, multi-sentence elaboration, then new list item with new citation'
        },
        {
            'paragraph': 'The brain is a complex adaptive system whose most-relevant elements include, but are not limited to, priors, attention, behavior, defense cascade activation, medical history, environment, genes, sleep quality, mental illness symptoms, and a variety of low-level neurobiological dynamics from which priors and attention emerge. Certainty - high. See \\textcite{friston2010free,clark2015surfing,berghSelfEvidencing,kozlowskaDefenseCascade}. Most of the dysfunctional attractor states categorized as mental illness are in large part caused by maladaptive priors, attention, and defense cascade activation. Certainty - high. Theorizing mental illness as a complex system of priors is well-established and convincing \\cite{friston2010free,hayes2020complex}. Attention/avoidance clearly play a major role \\cite{berghSelfEvidencing}. Defense cascade activation also clearly plays a large role \\cite{kozlowskaDefenseCascade}.',
            'citation_set': 'friston2010free,clark2015surfing,berghSelfEvidencing,kozlowskaDefenseCascade',
            'expected': '->The brain is a complex adaptive system whose most-relevant elements include, but are not limited to, priors, attention, behavior, defense cascade activation, medical history, environment, genes, sleep quality, mental illness symptoms, and a variety of low-level neurobiological dynamics from which priors and attention emerge. Certainty - high. See \\textcite{friston2010free,clark2015surfing,berghSelfEvidencing,kozlowskaDefenseCascade}.<- Most of the dysfunctional attractor states categorized as mental illness are in large part caused by maladaptive priors, attention, and defense cascade activation. Certainty - high. Theorizing mental illness as a complex system of priors is well-established and convincing \\cite{friston2010free,hayes2020complex}. Attention/avoidance clearly play a major role \\cite{berghSelfEvidencing}. Defense cascade activation also clearly plays a large role \\cite{kozlowskaDefenseCascade}.',
            'note': 'Statement with four citations as "See" reference, then new statement with overlapping and additional citations'
        },
        {
            'paragraph': 'Predictive processing explains the psychological elements of the complex system of mental illness. Certainty - high. Predictive processing is widely (though not universally) supported in neuroscience, has detailed mechanistic explanations for its functions, parts of it have been experimentally verified, and it seems to neatly explain a wide variety of phenomena \\cite{aizenbud2025neuralmechanismspredictiveprocessing,clark2015surfing,Clark_Watson_Friston_2018,eckerUnlocking}. It remains unclear how real neurons or collections of neurons create functional computation units, and there is a lot of debate about which formulation of predictive processing is correct. Memory reconsolidation can permanently unlearn maladaptive schemas. Certainty - high. Studies have established the protein-synthesis mechanism of memory reconsolidation in a variety of animals \\cite{eckerUnlocking,laneReconsolidation,elsey2018human}. Those experiments are not possible in humans because they are hazardous, but human studies have verified many of the purported behavioral signs of reconsolidation.',
            'citation_set': 'aizenbud2025neuralmechanismspredictiveprocessing,clark2015surfing,Clark_Watson_Friston_2018,eckerUnlocking',
            'expected': '->Predictive processing explains the psychological elements of the complex system of mental illness. Certainty - high. Predictive processing is widely (though not universally) supported in neuroscience, has detailed mechanistic explanations for its functions, parts of it have been experimentally verified, and it seems to neatly explain a wide variety of phenomena \\cite{aizenbud2025neuralmechanismspredictiveprocessing,clark2015surfing,Clark_Watson_Friston_2018,eckerUnlocking}. It remains unclear how real neurons or collections of neurons create functional computation units, and there is a lot of debate about which formulation of predictive processing is correct.<- Memory reconsolidation can permanently unlearn maladaptive schemas. Certainty - high. Studies have established the protein-synthesis mechanism of memory reconsolidation in a variety of animals \\cite{eckerUnlocking,laneReconsolidation,elsey2018human}. Those experiments are not possible in humans because they are hazardous, but human studies have verified many of the purported behavioral signs of reconsolidation.',
            'note': 'Core assumption format with multiple citations and nuanced elaboration, then new assumption with new citations'
        },
        {
            'paragraph': 'Adverse symptoms persisting after the post-acute period are largely caused by shifts in the complex system landscape of maladaptive schemas and subsequent defense cascade activation or therapy hangover from inadvertent reconsolidation. Certainty - medium/high. We personally think a large majority of adverse psychological effects of MDMA therapy appear highly compatible with destabilization. We\'ve seen that destabilized individuals often say their destabilization was caused by confronting too much avoided trauma all at once. We\'re not aware of any other issues that MDMA can cause when used safely, though that doesn\'t mean they don\'t exist. Acute physical injury from MDMA is almost always caused by mixing it with dangerous activities, certain other drugs, or certain medical conditions. Certainty - high. The primary causes of injury seem well-understood and there haven\'t been any significant reported adverse effects in trials, where dangerous activity and drug interactions are absent, and participants are screened for certain health issues \\textcite{wolfgang2025}. There could be rare exceptions that are poorly understood.',
            'citation_set': 'wolfgang2025',
            'expected': 'Adverse symptoms persisting after the post-acute period are largely caused by shifts in the complex system landscape of maladaptive schemas and subsequent defense cascade activation or therapy hangover from inadvertent reconsolidation. Certainty - medium/high. We personally think a large majority of adverse psychological effects of MDMA therapy appear highly compatible with destabilization. We\'ve seen that destabilized individuals often say their destabilization was caused by confronting too much avoided trauma all at once. We\'re not aware of any other issues that MDMA can cause when used safely, though that doesn\'t mean they don\'t exist. ->Acute physical injury from MDMA is almost always caused by mixing it with dangerous activities, certain other drugs, or certain medical conditions. Certainty - high. The primary causes of injury seem well-understood and there haven\'t been any significant reported adverse effects in trials, where dangerous activity and drug interactions are absent, and participants are screened for certain health issues \\textcite{wolfgang2025}. There could be rare exceptions that are poorly understood.<-',
            'note': 'Multiple author opinions/observations, then separate claim with citation and qualification'
        },
        {
            'paragraph': 'Mania: There is virtually no high quality experimental data because people with a history of mania (less-so hypomania) are usually excluded from clinical trials of psychedelics \\cite{gardBipolar}. The MDMA phase III trials did not exclude individuals with bipolar II and no manic episodes were reported \\cite{mitchellMDMAClinicalTrial2}. One small, uncontrolled study of psilocybin-assisted therapy for people with bipolar II but not currently in a hypomanic state showed good efficacy and safety when combined with a high level of support \\cite{aaronsonBipolarII}. We aren\'t sure how well that translates to MDMA therapy. Notably, we couldn\'t find a single case report of mania where MDMA was unambiguously involved in the recent past, and are therefore confused why MDMA and disorders involving mania are often considered a risky combination. Perhaps it is because bipolar I frequently also involves psychosis, which does have a link to MDMA use.',
            'citation_set': 'gardBipolar',
            'expected': '->Mania: There is virtually no high quality experimental data because people with a history of mania (less-so hypomania) are usually excluded from clinical trials of psychedelics \\cite{gardBipolar}.<- The MDMA phase III trials did not exclude individuals with bipolar II and no manic episodes were reported \\cite{mitchellMDMAClinicalTrial2}. One small, uncontrolled study of psilocybin-assisted therapy for people with bipolar II but not currently in a hypomanic state showed good efficacy and safety when combined with a high level of support \\cite{aaronsonBipolarII}. We aren\'t sure how well that translates to MDMA therapy. Notably, we couldn\'t find a single case report of mania where MDMA was unambiguously involved in the recent past, and are therefore confused why MDMA and disorders involving mania are often considered a risky combination. Perhaps it is because bipolar I frequently also involves psychosis, which does have a link to MDMA use.',
            'note': 'Single sentence, then three different citations with author commentary between each'
        },
        {
            'paragraph': 'Attachment theory is a model which posits that secure attachments formed in the first 18 months of life serve as the foundation for emotional and psychological development throughout one\'s life \\cite{brownAttachmentDisturbances}. It is one of the most empirically supported theories in psychology, with over 70 years of well-replicated research behind it. According to attachment theory, the presence of consistent, sensitive caregiving facilitates the development of secure attachment-and in its absence, individuals tend to develop anxious, avoidant, or disorganized styles of attachment. Researchers have identified five pillars of secure attachment. Cultivating secure attachment requires caregivers who are physically present, consistent, reliable, and interested in enacting these five pillars. That is to say-for the five pillars to be met, these additional conditions must also be met as their foundation.',
            'citation_set': 'brownAttachmentDisturbances',
            'expected': '->Attachment theory is a model which posits that secure attachments formed in the first 18 months of life serve as the foundation for emotional and psychological development throughout one\'s life \\cite{brownAttachmentDisturbances}. It is one of the most empirically supported theories in psychology, with over 70 years of well-replicated research behind it. According to attachment theory, the presence of consistent, sensitive caregiving facilitates the development of secure attachment-and in its absence, individuals tend to develop anxious, avoidant, or disorganized styles of attachment. Researchers have identified five pillars of secure attachment. Cultivating secure attachment requires caregivers who are physically present, consistent, reliable, and interested in enacting these five pillars. That is to say-for the five pillars to be met, these additional conditions must also be met as their foundation.<-',
            'note': 'Multi-sentence explanation of cited theory without repeating citation'
        },
        {
            'paragraph': 'Some people experience a temporary afterglow (wellbeing, positive mood, mindfulness, positive behaviors, less mental illness) for days-weeks after some non-MDMA psychedelic-therapy sessions \\cite{evansAfterglow}. We have seen a number of anecdotes that MDMA therapy sometimes also induces a 1-2 week afterglow period where regular therapy is more effective. We could not find any high-quality evidence of MDMA-induced post-session neuroplasticity. Two weeks is the length of time of a certain type of increased neuroplasticity that \\textcite{nardouMDMAPlasticity} found following MDMA dosing in mice. However, that lab\'s results with psilocybin failed to replicate in a large multi-site replication effort, calling their MDMA results into question too \\cite{Lu2025noplasticity}.',
            'citation_set': 'evansAfterglow',
            'expected': '->Some people experience a temporary afterglow (wellbeing, positive mood, mindfulness, positive behaviors, less mental illness) for days-weeks after some non-MDMA psychedelic-therapy sessions \\cite{evansAfterglow}.<- We have seen a number of anecdotes that MDMA therapy sometimes also induces a 1-2 week afterglow period where regular therapy is more effective. We could not find any high-quality evidence of MDMA-induced post-session neuroplasticity. Two weeks is the length of time of a certain type of increased neuroplasticity that \\textcite{nardouMDMAPlasticity} found following MDMA dosing in mice. However, that lab\'s results with psilocybin failed to replicate in a large multi-site replication effort, calling their MDMA results into question too \\cite{Lu2025noplasticity}.',
            'note': 'Single sentence, author anecdote, then two different citations with critical evaluation'
        },
        # {
        #     'paragraph': 'MDMA therapy is a powerful tool for healing mental illness. There is medium-quality clinical trial evidence that a limited course of MDMA therapy is highly effective for durably resolving PTSD \\cite{mitchellMDMAClinicalTrial}. However, there are good theoretical reasons and ample anecdotal evidence that MDMA therapy can also resolve CPTSD and attachment issues.',
        #     'citation_set': 'mitchellMDMAClinicalTrial',
        #     'expected': 'MDMA therapy is a powerful tool for healing mental illness. ->There is medium-quality clinical trial evidence that a limited course of MDMA therapy is highly effective for durably resolving PTSD \\cite{mitchellMDMAClinicalTrial}. However, there are good theoretical reasons and ample anecdotal evidence that MDMA therapy can also resolve CPTSD and attachment issues.<-',
        #     'note': 'First sentence is author opinion, not cited. Second and third sentences belong to the citation.'
        # },
        # {
        #     'paragraph': 'MDMA, and some other substances in the same class, create extraordinary feelings of compassion, connection, and safety. As described later, this state of mind is highly effective for processing difficult or unhelpful emotions or reactions. However, there are no quick fixes for all but the most simple issues. We think that, even in optimal conditions, MDMA therapy and the best cases of traditional psychotherapy can take multiple years to heal severe mental illness. Additionally, almost all models of MDMA therapy currently emphasize the necessity of between-session therapy or at-home therapeutic exercises to fully treat mental illness \\cite{bathje2022Integration}. We think MDMA can provide an on-ramp to these activities if they have traditionally been difficult or useless for you. Uncovering distressing previously-avoided memories and sensations can be psychologically destabilizing until the newly-surfaced content is processed \\cite{olthofDestabilization}. Destabilization can be intense for those with the severe early-childhood trauma or emotional neglect \\cite{studyingHarms}. Unfortunately, we think unconscious avoidance makes straightforward self-assessment of that difficult.',
        #     'citation_set': 'bathje2022Integration',
        #     'expected': 'MDMA, and some other substances in the same class, create extraordinary feelings of compassion, connection, and safety. As described later, this state of mind is highly effective for processing difficult or unhelpful emotions or reactions. However, there are no quick fixes for all but the most simple issues. We think that, even in optimal conditions, MDMA therapy and the best cases of traditional psychotherapy can take multiple years to heal severe mental illness. ->Additionally, almost all models of MDMA therapy currently emphasize the necessity of between-session therapy or at-home therapeutic exercises to fully treat mental illness \\cite{bathje2022Integration}.<- We think MDMA can provide an on-ramp to these activities if they have traditionally been difficult or useless for you. Uncovering distressing previously-avoided memories and sensations can be psychologically destabilizing until the newly-surfaced content is processed \\cite{olthofDestabilization}. Destabilization can be intense for those with the severe early-childhood trauma or emotional neglect \\cite{studyingHarms}. Unfortunately, we think unconscious avoidance makes straightforward self-assessment of that difficult.',
        #     'note': 'Multiple author opinions, three different citations in sequence, single sentence citation'
        # },
        # {
        #     'paragraph': 'As described in Chapter \\ref{science}, we think a limited course of MDMA therapy durably resolves a certain causal factor that plays a large role in most mental illnesses and many other issues. Unfortunately it\'s very difficult to determine which mental illnesses this applies to. Mental illness diagnoses from the Diagnostic and Statistical Manual (DSM) or the International Classification of Diseases - Clinical Descriptions and Diagnostic Guidelines (ICD - CDDR) are self-admittedly just semi-arbitrary symptom clusters \\cite{apaDSM,ICD}. They rarely attempt to attribute causes to these clusters. Aside from conditions whose biological origins are well-understood, many mental illnesses may actually be curable to some degree through the process outlined in this book. Of course this assumes that the clinical trials were reporting a repeatable effect rather than some sort of bias. Even if the MDMA therapy trials were all bias, the fundamental process is also often achievable through traditional therapy \\cite{eckerUnlocking}.',
        #     'citation_set': 'apaDSM,ICD',
        #     'expected': 'As described in Chapter \\ref{science}, we think a limited course of MDMA therapy durably resolves a certain causal factor that plays a large role in most mental illnesses and many other issues. Unfortunately it\'s very difficult to determine which mental illnesses this applies to. ->Mental illness diagnoses from the Diagnostic and Statistical Manual (DSM) or the International Classification of Diseases - Clinical Descriptions and Diagnostic Guidelines (ICD - CDDR) are self-admittedly just semi-arbitrary symptom clusters \\cite{apaDSM,ICD}. They rarely attempt to attribute causes to these clusters.<- Aside from conditions whose biological origins are well-understood, many mental illnesses may actually be curable to some degree through the process outlined in this book. Of course this assumes that the clinical trials were reporting a repeatable effect rather than some sort of bias. Even if the MDMA therapy trials were all bias, the fundamental process is also often achievable through traditional therapy \\cite{eckerUnlocking}.',
        #     'note': 'Author opinion first, two citations together, author speculation after, different citation later'
        # },
        # {
        #     'paragraph': 'Mental illness is one of the largest causes of suffering \\cite{mentalhealthpriority}. Besides being painful, difficult, and expensive for the people who experience it, it carries a heavy economic, emotional, and logistical cost for close companions of those who experience it. On top of all this, we hypothesize that the widespread prevalence of mental illness effects such as cognitive distortion, emotional rigidness, and emotions of deep insecurity and threat may be among the engines driving tribalism and political polarization across the globe. Even when mental illness isn\'t a factor in tribalism, we hypothesize that the learned maladaptive and false beliefs that are key components of humanity\'s tribal tendencies \\cite{klein2020Polarized,galefScoutMindset} can be unlearned by the same mechanism that mental illness can be unlearned. While some individuals are able to access effective mental healthcare, both access and effectiveness are inadequate for most of the vast population of individuals who experience mental illness.',
        #     'citation_set': 'mentalhealthpriority',
        #     'expected': '->Mental illness is one of the largest causes of suffering \\cite{mentalhealthpriority}. Besides being painful, difficult, and expensive for the people who experience it, it carries a heavy economic, emotional, and logistical cost for close companions of those who experience it.<- On top of all this, we hypothesize that the widespread prevalence of mental illness effects such as cognitive distortion, emotional rigidness, and emotions of deep insecurity and threat may be among the engines driving tribalism and political polarization across the globe. Even when mental illness isn\'t a factor in tribalism, we hypothesize that the learned maladaptive and false beliefs that are key components of humanity\'s tribal tendencies \\cite{klein2020Polarized,galefScoutMindset} can be unlearned by the same mechanism that mental illness can be unlearned. While some individuals are able to access effective mental healthcare, both access and effectiveness are inadequate for most of the vast population of individuals who experience mental illness.',
        #     'note': 'Citation continues to second sentence, then author hypothesis, then new citations, then general statement'
        # },
        # {
        #     'paragraph': 'Feelings of trust towards the therapeutic process are an important resource for getting individuals into mental health treatment who need it, and feelings of trust between therapists and clients are an essential mechanism for the effectiveness of therapy \\cite{wampoldCommonFactors}. One of the most exciting aspects of therapeutic MDMA usage is that it allows traumatized individuals to experience a sense of safety and connectedness that is otherwise physiologically and psychologically inaccessible to them, even in trustworthy circumstances \\cite{fedduciaMDMAMemoryReconsolidation}. Additionally, many cultures and subcultures experience a normalized hostility regarding even the acknowledgement of mental illness, creating a challenge for clients who are in need of care and for clinicians who attempt to provide effective care in these communities.',
        #     'citation_set': 'wampoldCommonFactors',
        #     'expected': '->Feelings of trust towards the therapeutic process are an important resource for getting individuals into mental health treatment who need it, and feelings of trust between therapists and clients are an essential mechanism for the effectiveness of therapy \\cite{wampoldCommonFactors}.<- One of the most exciting aspects of therapeutic MDMA usage is that it allows traumatized individuals to experience a sense of safety and connectedness that is otherwise physiologically and psychologically inaccessible to them, even in trustworthy circumstances \\cite{fedduciaMDMAMemoryReconsolidation}. Additionally, many cultures and subcultures experience a normalized hostility regarding even the acknowledgement of mental illness, creating a challenge for clients who are in need of care and for clinicians who attempt to provide effective care in these communities.',
        #     'note': 'Single sentence citation, then new citation, then general observation'
        # },
        # {
        #     'paragraph': '\\textcite{miller2014secrets} explores the concept of "supershrinks" - therapists who consistently achieve superior outcomes regardless of their theoretical orientation or specific techniques. The authors argue that exceptional performance in therapy, as in other fields, is primarily the result of deliberate practice and ongoing feedback rather than innate talent or experience alone. They propose a three-part formula for improving therapeutic effectiveness: determining one\'s baseline of effectiveness, engaging in deliberate practice, and consistently seeking and incorporating client feedback. By tracking outcomes, comparing performance to national norms, and actively working to improve skills through targeted practice and reflection, the authors suggest that all therapists can significantly enhance their effectiveness and client outcomes.',
        #     'citation_set': 'miller2014secrets',
        #     'expected': '->\\textcite{miller2014secrets} explores the concept of "supershrinks" - therapists who consistently achieve superior outcomes regardless of their theoretical orientation or specific techniques. The authors argue that exceptional performance in therapy, as in other fields, is primarily the result of deliberate practice and ongoing feedback rather than innate talent or experience alone. They propose a three-part formula for improving therapeutic effectiveness: determining one\'s baseline of effectiveness, engaging in deliberate practice, and consistently seeking and incorporating client feedback. By tracking outcomes, comparing performance to national norms, and actively working to improve skills through targeted practice and reflection, the authors suggest that all therapists can significantly enhance their effectiveness and client outcomes.<-',
        #     'note': 'All sentences describe the cited work using multiple "the authors" references'
        # },
        # {
        #     'paragraph': 'The Autonomic Nervous System governs a wide variety of involuntary bodily functions, such as heart rate and digestion \\cite{kozlowskaDefenseCascade}. In one of its roles, it activates a defense cascade—a sequence of responses—to shield us from threats. Increasing levels of perceived threat activate these responses, though the order of activation depends on individual variability and experience. Additionally, activation is proportional to our estimation of the threat and our ability to handle it. Children activate easily because the threshold of what constitutes a threat to their life is much lower than it is for healthy adults. Lack of parental support, attention, or attunement (see Appendix \\ref{attachment}) can be life-threatening situations for children.',
        #     'citation_set': 'kozlowskaDefenseCascade',
        #     'expected': '->The Autonomic Nervous System governs a wide variety of involuntary bodily functions, such as heart rate and digestion \\cite{kozlowskaDefenseCascade}. In one of its roles, it activates a defense cascade—a sequence of responses—to shield us from threats. Increasing levels of perceived threat activate these responses, though the order of activation depends on individual variability and experience. Additionally, activation is proportional to our estimation of the threat and our ability to handle it. Children activate easily because the threshold of what constitutes a threat to their life is much lower than it is for healthy adults. Lack of parental support, attention, or attunement (see Appendix \\ref{attachment}) can be life-threatening situations for children.<-',
        #     'note': 'Multiple sentences after citation all describe the cited framework'
        # },
        # {
        #     'paragraph': 'There is a lot of variability in individual responsiveness to trauma because all experiences and individuals are unique. A devastating event for one person may cause only temporary difficulty for someone else. Mentally healthy adults with sufficient resources are resilient to most traumas and usually develop appropriate schemas to manage those situations in the future \\cite{bonanno2008loss}. Secure attachment is also a major factor in resilience \\cite{attachmentPTSD}. Securely attached children are also resilient to trauma, especially when they have assistance from their parents. After the threat passes in these cases of resilience the individual may have a temporary period of distress about the experience, but this dissipates in a reasonable amount of time.',
        #     'citation_set': 'bonanno2008loss',
        #     'expected': 'There is a lot of variability in individual responsiveness to trauma because all experiences and individuals are unique. A devastating event for one person may cause only temporary difficulty for someone else. ->Mentally healthy adults with sufficient resources are resilient to most traumas and usually develop appropriate schemas to manage those situations in the future \\cite{bonanno2008loss}.<- Secure attachment is also a major factor in resilience \\cite{attachmentPTSD}. Securely attached children are also resilient to trauma, especially when they have assistance from their parents. After the threat passes in these cases of resilience the individual may have a temporary period of distress about the experience, but this dissipates in a reasonable amount of time.',
        #     'note': 'Common knowledge, single citation sentence, immediately followed by new citation'
        # },
        # {
        #     'paragraph': 'A variety of risk factors reduce the capacity to bounce back and form healthy schemas for that situation. Post-trauma factors for children, adolescents, and presumably also adults to a large degree, include blaming others, thought suppression, distraction, low social support, social withdrawal, poor family functioning, and parental psychological problems \\cite{trickeyRiskFactors}. \\cite{tangRiskFactors} also found that female gender (this may function differently in different cultures), unemployment, and low education are risk factors for adults. Resilience to trauma is complex \\cite{bonanno2008loss}, but it may be that many of those items are risk factors because they are generally situations of broad resource (emotional, physical, social) insecurity, which are additional pieces of evidence reinforcing overly-general high-threat predictions like "I\'m in danger everywhere \\cite{berghSelfEvidencing}."',
        #     'citation_set': 'trickeyRiskFactors',
        #     'expected': 'A variety of risk factors reduce the capacity to bounce back and form healthy schemas for that situation. ->Post-trauma factors for children, adolescents, and presumably also adults to a large degree, include blaming others, thought suppression, distraction, low social support, social withdrawal, poor family functioning, and parental psychological problems \\cite{trickeyRiskFactors}.<- \\cite{tangRiskFactors} also found that female gender (this may function differently in different cultures), unemployment, and low education are risk factors for adults. Resilience to trauma is complex \\cite{bonanno2008loss}, but it may be that many of those items are risk factors because they are generally situations of broad resource (emotional, physical, social) insecurity, which are additional pieces of evidence reinforcing overly-general high-threat predictions like "I\'m in danger everywhere \\cite{berghSelfEvidencing}."',
        #     'note': 'Four different citations in one paragraph with interpretations between them'
        # },
        # {
        #     'paragraph': 'As discussed in the previous section, a consciously experienced contradiction between an old schema and a new experience or existing knowledge creates prediction error \\cite{eckerUnlocking}. Prediction error triggers an updating process called memory reconsolidation. When schemas are first created, they are \\textit{consolidated}. After that, when a consciously experienced contradiction creates prediction error for that schema, the schema enters a state of plasticity where it can be changed. Maintaining that experience of contradiction over a period of time will then gradually update the schema to account for the contradiction. About 5 hours (in animal models) after the initial prediction error, the memory is \\textit{re-consolidated}, re-entering a stable state where it can no longer be changed without another consciously experienced contradiction. Throughout this book for convenience we will use "reconsolidate" in a slightly different way to denote the entire process of schema destabilization, updating, and restabilization.',
        #     'citation_set': 'eckerUnlocking',
        #     'expected': '->As discussed in the previous section, a consciously experienced contradiction between an old schema and a new experience or existing knowledge creates prediction error \\cite{eckerUnlocking}. Prediction error triggers an updating process called memory reconsolidation. When schemas are first created, they are \\textit{consolidated}. After that, when a consciously experienced contradiction creates prediction error for that schema, the schema enters a state of plasticity where it can be changed. Maintaining that experience of contradiction over a period of time will then gradually update the schema to account for the contradiction. About 5 hours (in animal models) after the initial prediction error, the memory is \\textit{re-consolidated}, re-entering a stable state where it can no longer be changed without another consciously experienced contradiction.<- Throughout this book for convenience we will use "reconsolidate" in a slightly different way to denote the entire process of schema destabilization, updating, and restabilization.',
        #     'note': 'Long multi-sentence description of cited theory, then author terminological choice'
        # },
        # {
        #     'paragraph': 'We\'ve personally observed and seen a number of anecdotes suggesting that in practice, MDMA often seems to facilitate or provide effective mismatches for most, if not all maladaptive schemas. \\textcite{carhart2019rebus} hypothesizes that MDMA relaxes all socially/relationally relevant schemas, which are typically the kind of schemas that trauma causes. Once those schemas are relaxed, all types of contradictory information have higher relative strength and are more liable to induce prediction error and reconsolidation. We don\'t know exactly what type of contradictory information one might encounter in any particular scenario, but we have a few somewhat overlapping hypotheses.',
        #     'citation_set': 'carhart2019rebus',
        #     'expected': 'We\'ve personally observed and seen a number of anecdotes suggesting that in practice, MDMA often seems to facilitate or provide effective mismatches for most, if not all maladaptive schemas. ->\\textcite{carhart2019rebus} hypothesizes that MDMA relaxes all socially/relationally relevant schemas, which are typically the kind of schemas that trauma causes. Once those schemas are relaxed, all types of contradictory information have higher relative strength and are more liable to induce prediction error and reconsolidation.<- We don\'t know exactly what type of contradictory information one might encounter in any particular scenario, but we have a few somewhat overlapping hypotheses.',
        #     'note': 'Author anecdote, citation hypothesis, author uncertainty'
        # },
        # {
        #     'paragraph': '\\textcite{hayes2020complex} summarizes a variety of research (citations 13, 17-26 in the original) on this complex-adaptive-systems modeling of mental illness: "...a dynamic system [mental states in this case] is a set of interconnected elements that evolve over time and self-organize into higher-order functional units, called attractor states [stable patterns of behavior, beliefs, and emotions], that are preferred and govern system behavior. Self-organization is the process by which lower-order processes [individual schemas, defense cascade activations, elements of life circumstances, gene variants, etc.] interact and higher-order patterns emerge and then influence the lower-order processes in a top-down manner."',
        #     'citation_set': 'hayes2020complex',
        #     'expected': '->\\textcite{hayes2020complex} summarizes a variety of research (citations 13, 17-26 in the original) on this complex-adaptive-systems modeling of mental illness: "...a dynamic system [mental states in this case] is a set of interconnected elements that evolve over time and self-organize into higher-order functional units, called attractor states [stable patterns of behavior, beliefs, and emotions], that are preferred and govern system behavior. Self-organization is the process by which lower-order processes [individual schemas, defense cascade activations, elements of life circumstances, gene variants, etc.] interact and higher-order patterns emerge and then influence the lower-order processes in a top-down manner."<-',
        #     'note': 'Long block quote from source with editorial additions in brackets'
        # },
        # {
        #     'paragraph': 'In simpler terms, therapy is a process of moving from stuck state(s) of mental illness to state(s) of mental health \\cite{hayes2020complex,friston2010free}. In this case stable mental health is defined as a system that quickly returns to an adaptive state when perturbed. Transitioning to mental health is accomplished through: reconsolidating the schemas that reinforce the state of mental illness, reducing the behavioral, social, or environmental elements that reinforce state(s) of mental illness, or shaking the system hard enough that you (hopefully) jump straight from the stable state of mental illness to an existing, but inactive and somewhat stable state of good mental health.',
        #     'citation_set': 'hayes2020complex,friston2010free',
        #     'expected': '->In simpler terms, therapy is a process of moving from stuck state(s) of mental illness to state(s) of mental health \\cite{hayes2020complex,friston2010free}. In this case stable mental health is defined as a system that quickly returns to an adaptive state when perturbed. Transitioning to mental health is accomplished through: reconsolidating the schemas that reinforce the state of mental illness, reducing the behavioral, social, or environmental elements that reinforce state(s) of mental illness, or shaking the system hard enough that you (hopefully) jump straight from the stable state of mental illness to an existing, but inactive and somewhat stable state of good mental health.<-',
        #     'note': 'Two citations together, multiple sentences elaborating on the cited framework'
        # },
        # {
        #     'paragraph': 'In practice, the first process of reconsolidation seems frequently necessary and sufficient to resolve the issue at hand \\cite{eckerUnlocking}. All the other processes can leave the maladaptive schemas reinforcing the state of mental illness inactive but intact. Relapse occurs when the right circumstances reactivate that old state. Additionally, constant effort may be needed to maintain the set of behavioral and environmental elements that maintain a state of mental health. Reconsolidation permanently dismantles many of the reinforcing elements of mental illness. There is no, or only a weakened, latent state of mental illness to relapse into. One other solution theoretically sufficient by itself to resolve mental illness are interventions which durably decrease avoidance to such a degree that the newly perceived information naturally reconsolidates all or most important maladaptive schemas over time \\cite{berghSelfEvidencing}.',
        #     'citation_set': 'eckerUnlocking',
        #     'expected': '->In practice, the first process of reconsolidation seems frequently necessary and sufficient to resolve the issue at hand \\cite{eckerUnlocking}. All the other processes can leave the maladaptive schemas reinforcing the state of mental illness inactive but intact. Relapse occurs when the right circumstances reactivate that old state. Additionally, constant effort may be needed to maintain the set of behavioral and environmental elements that maintain a state of mental health. Reconsolidation permanently dismantles many of the reinforcing elements of mental illness. There is no, or only a weakened, latent state of mental illness to relapse into.<- One other solution theoretically sufficient by itself to resolve mental illness are interventions which durably decrease avoidance to such a degree that the newly perceived information naturally reconsolidates all or most important maladaptive schemas over time \\cite{berghSelfEvidencing}.',
        #     'note': 'Long elaboration on first citation, then new citation at end'
        # },
        # {
        #     'paragraph': 'Therapeutic improvement frequently requires paying attention to and integrating previously-avoided distressing information like sensations, memories, or emotions \\cite{berghSelfEvidencing}. This newly-perceived information may activate a variety of distressing (either adaptive or maladaptive, and possibly latent) schemas related to the information\'s meaning or implications, and may activate panic or dissociation in severe cases. We think this new state of worsened symptoms is likely temporary because the previously-avoided information is precisely what was needed to reconsolidate some of the symptom-producing maladaptive schemas; avoiding this information was what prevented reconsolidation. These worsened symptoms may drag on longer than necessary if panic or dissociation inhibits the natural reconsolidation process the newly-perceived information would otherwise activate.',
        #     'citation_set': 'berghSelfEvidencing',
        #     'expected': '->Therapeutic improvement frequently requires paying attention to and integrating previously-avoided distressing information like sensations, memories, or emotions \\cite{berghSelfEvidencing}. This newly-perceived information may activate a variety of distressing (either adaptive or maladaptive, and possibly latent) schemas related to the information\'s meaning or implications, and may activate panic or dissociation in severe cases.<- We think this new state of worsened symptoms is likely temporary because the previously-avoided information is precisely what was needed to reconsolidate some of the symptom-producing maladaptive schemas; avoiding this information was what prevented reconsolidation. These worsened symptoms may drag on longer than necessary if panic or dissociation inhibits the natural reconsolidation process the newly-perceived information would otherwise activate.',
        #     'note': 'Citation continues to second sentence describing implications, then author opinion'
        # },
        # {
        #     'paragraph': 'While complex systems dynamics surely explain important parts of the therapeutic process, its practical applications are currently limited \\cite{hayes2020complex}. Complex systems are hard to model, the model architecture is unknown and might be significantly different for every individual, the architecture dynamically reorganizes all the time in complex ways, and almost all the parameters of the model are extremely difficult or impossible to measure. Furthermore, the "state space" these states exist in isn\'t just a simple one or two-dimensional landscape of valleys and hills that the "ball" of mental health rolls around in; it has as many dimensions as there are schemas, behaviors, and environmental elements. We don\'t know how many dimensions are of practical importance in any particular case, but it could easily be enough that many therapeutically relevant systems are too complicated for any human to comprehend. So while complex system dynamics succeeds at qualitatively describing some therapeutic dynamics, it doesn\'t offer a lot of practical advice on who will destabilize/worsen, when they will destabilize/worsen, how long they will be destabilized/worsened for, and which therapeutic tactic is best at any particular point of any specific case \\cite{helmich2024slow,hayes2020complex}.',
        #     'citation_set': 'hayes2020complex',
        #     'expected': '->While complex systems dynamics surely explain important parts of the therapeutic process, its practical applications are currently limited \\cite{hayes2020complex}. Complex systems are hard to model, the model architecture is unknown and might be significantly different for every individual, the architecture dynamically reorganizes all the time in complex ways, and almost all the parameters of the model are extremely difficult or impossible to measure. Furthermore, the "state space" these states exist in isn\'t just a simple one or two-dimensional landscape of valleys and hills that the "ball" of mental health rolls around in; it has as many dimensions as there are schemas, behaviors, and environmental elements.<- We don\'t know how many dimensions are of practical importance in any particular case, but it could easily be enough that many therapeutically relevant systems are too complicated for any human to comprehend. So while complex system dynamics succeeds at qualitatively describing some therapeutic dynamics, it doesn\'t offer a lot of practical advice on who will destabilize/worsen, when they will destabilize/worsen, how long they will be destabilized/worsened for, and which therapeutic tactic is best at any particular point of any specific case \\cite{helmich2024slow,hayes2020complex}.',
        #     'note': 'Long elaboration starting with first citation, ending with same citation plus another - all describes the cited limitations'
        # },
        # {
        #     'paragraph': 'Psychological destabilization (see Section \\ref{sec:complex}) is a common occurrence in therapy \\cite{olthofDestabilization}. It\'s associated with better outcomes later in therapy, but if it is intense enough and not managed well can severely interfere with your life. We are not aware of any papers demonstrating this, but we think it\'s likely that MDMA therapy tends to produce stronger destabilization (and more rapid therapeutic progress) than traditional psychotherapy. Severe early childhood trauma (including non-secure attachment) may be a major risk factor. The therapeutic alliance is a moderate mitigating factor when working with a mental health professional (see \\textcite{BRWAIdownload} for an assessment scale) \\cite{fluckiger2018alliance}.',
        #     'citation_set': 'olthofDestabilization',
        #     'expected': '->Psychological destabilization (see Section \\ref{sec:complex}) is a common occurrence in therapy \\cite{olthofDestabilization}. It\'s associated with better outcomes later in therapy, but if it is intense enough and not managed well can severely interfere with your life.<- We are not aware of any papers demonstrating this, but we think it\'s likely that MDMA therapy tends to produce stronger destabilization (and more rapid therapeutic progress) than traditional psychotherapy. Severe early childhood trauma (including non-secure attachment) may be a major risk factor. The therapeutic alliance is a moderate mitigating factor when working with a mental health professional (see \\textcite{BRWAIdownload} for an assessment scale) \\cite{fluckiger2018alliance}.',
        #     'note': 'Citation with continuation, author opinion admitting no evidence, general statements, new citation'
        # },
        # {
        #     'paragraph': 'Psychosis: There is virtually no high quality experimental data because people with a history of psychosis are usually excluded from clinical trials of psychedelics \\cite{la2022Psychosis}. Like other mental illness, psychosis is a complex biopsychosocial phenomenon. Therapy can often reduce the symptoms of psychosis \\cite{CBTp}, suggesting that maladaptive schemas often play some role, though it\'s not certain how strong that is compared to other factors. This implies that psychosis can start and stop at hard-to-predict points during the reconsolidation process, and in life in general, for people with some level of predisposition. We\'ve seen a collection of anecdotes congruent with this: A few self-reports from people stating that a single MDMA therapy session triggered a psychotic episode.',
        #     'citation_set': 'la2022Psychosis',
        #     'expected': '->Psychosis: There is virtually no high quality experimental data because people with a history of psychosis are usually excluded from clinical trials of psychedelics \\cite{la2022Psychosis}.<- Like other mental illness, psychosis is a complex biopsychosocial phenomenon. Therapy can often reduce the symptoms of psychosis \\cite{CBTp}, suggesting that maladaptive schemas often play some role, though it\'s not certain how strong that is compared to other factors. This implies that psychosis can start and stop at hard-to-predict points during the reconsolidation process, and in life in general, for people with some level of predisposition. We\'ve seen a collection of anecdotes congruent with this: A few self-reports from people stating that a single MDMA therapy session triggered a psychotic episode.',
        #     'note': 'Single sentence citation, general statement, new citation, author interpretation, author anecdotes'
        # },
        # {
        #     'paragraph': '\\textcite{evans2023extended} surveyed people who have experienced new, persistent negative symptoms after recreational, professional-therapeutic, and DIY-therapeutic psychedelic experiences. This data applies to all psychedelics, not just MDMA. Most symptoms dissipated with time, but 17\\% of respondents said theirs lasted more than 3 years. From most to least common, participants reported emotional (76\\%), self-perception (58\\%), cognitive (52\\%), social (52\\%), ontological (50\\%), spiritual (34\\%), perceptual (26\\%), and other (21\\%) difficulties. There is major uncertainty in how much these symptoms are due to surfacing of existing maladaptive schemas and subsequent defense cascade activation, a necessary and healthy part of the therapeutic process if managed well.',
        #     'citation_set': 'evans2023extended',
        #     'expected': '->\\textcite{evans2023extended} surveyed people who have experienced new, persistent negative symptoms after recreational, professional-therapeutic, and DIY-therapeutic psychedelic experiences. This data applies to all psychedelics, not just MDMA. Most symptoms dissipated with time, but 17\\% of respondents said theirs lasted more than 3 years. From most to least common, participants reported emotional (76\\%), self-perception (58\\%), cognitive (52\\%), social (52\\%), ontological (50\\%), spiritual (34\\%), perceptual (26\\%), and other (21\\%) difficulties.<- There is major uncertainty in how much these symptoms are due to surfacing of existing maladaptive schemas and subsequent defense cascade activation, a necessary and healthy part of the therapeutic process if managed well.',
        #     'note': 'Long description of survey findings, then author interpretation of uncertainty'
        # }
    ]
    return examples

# IMPROVED_PROMPT_V1 = """You are analyzing an academic paragraph to identify "attribution units" - groups of consecutive sentences that share the same citation(s).

# CONTEXT:
# In APA academic writing, when an author cites a source, the following sentences often continue to describe or reference that same source until either:
# 1. A new citation appears (starting a new attribution unit)
# 2. The author shifts to their own interpretation/opinion (no citation needed)
# 3. The author makes a general statement not requiring citation

# YOUR TASK:
# Mark the attribution unit that uses EXACTLY the citation set: $CITATION_SET$

# RULES:
# 1. Include ALL consecutive sentences that depend on this exact citation set
# 2. The citation set must match EXACTLY (same authors, same order doesn't matter if it's a set)
# 3. Sentences that continue describing the cited work should be included even if they don't repeat the citation
# 4. Stop when you encounter:
#    - A different citation
#    - Author's own opinion/interpretation (usually obvious from context like "we think", "we believe", or implied by assertive claims not attributed to a source)
#    - A new topic that's clearly not from the cited source
# 5. Place markers '->' at the start and '<-' at the end of the attribution unit
# 6. Markers should be at sentence boundaries (after periods, not mid-sentence)
# 7. Preserve all original text, line numbers, and formatting, including the text outside the marked area

# EXAMPLES:
#     'citation_set': 'mitchellMDMAClinicalTrial',
#     'expected': 'MDMA therapy is a powerful tool for healing mental illness. ->There is medium-quality clinical trial evidence that a limited course of MDMA therapy is highly effective for durably resolving PTSD \\cite{mitchellMDMAClinicalTrial}. However, there are good theoretical reasons and ample anecdotal evidence that MDMA therapy can also resolve CPTSD and attachment issues.<-',
#     'note': 'First sentence is author opinion, not cited. Second and third sentences belong to the citation.'

#     'citation_set': 'bathje2022Integration',
#     'expected': 'MDMA, and some other substances in the same class, create extraordinary feelings of compassion, connection, and safety. As described later, this state of mind is highly effective for processing difficult or unhelpful emotions or reactions. However, there are no quick fixes for all but the most simple issues. We think that, even in optimal conditions, MDMA therapy and the best cases of traditional psychotherapy can take multiple years to heal severe mental illness. ->Additionally, almost all models of MDMA therapy currently emphasize the necessity of between-session therapy or at-home therapeutic exercises to fully treat mental illness \\cite{bathje2022Integration}.<- We think MDMA can provide an on-ramp to these activities if they have traditionally been difficult or useless for you. Uncovering distressing previously-avoided memories and sensations can be psychologically destabilizing until the newly-surfaced content is processed \\cite{olthofDestabilization}. Destabilization can be intense for those with the severe early-childhood trauma or emotional neglect \\cite{studyingHarms}. Unfortunately, we think unconscious avoidance makes straightforward self-assessment of that difficult.',
#     'note': 'Multiple author opinions, three different citations in sequence, single sentence citation'

#     'citation_set': 'apaDSM,ICD',
#     'expected': 'As described in Chapter \\ref{science}, we think a limited course of MDMA therapy durably resolves a certain causal factor that plays a large role in most mental illnesses and many other issues. Unfortunately it\'s very difficult to determine which mental illnesses this applies to. ->Mental illness diagnoses from the Diagnostic and Statistical Manual (DSM) or the International Classification of Diseases - Clinical Descriptions and Diagnostic Guidelines (ICD - CDDR) are self-admittedly just semi-arbitrary symptom clusters \\cite{apaDSM,ICD}. They rarely attempt to attribute causes to these clusters.<- Aside from conditions whose biological origins are well-understood, many mental illnesses may actually be curable to some degree through the process outlined in this book. Of course this assumes that the clinical trials were reporting a repeatable effect rather than some sort of bias. Even if the MDMA therapy trials were all bias, the fundamental process is also often achievable through traditional therapy \\cite{eckerUnlocking}.',
#     'note': 'Author opinion first, two citations together, author speculation after, different citation later'

#     'citation_set': 'mentalhealthpriority',
#     'expected': '->Mental illness is one of the largest causes of suffering \\cite{mentalhealthpriority}. Besides being painful, difficult, and expensive for the people who experience it, it carries a heavy economic, emotional, and logistical cost for close companions of those who experience it.<- On top of all this, we hypothesize that the widespread prevalence of mental illness effects such as cognitive distortion, emotional rigidness, and emotions of deep insecurity and threat may be among the engines driving tribalism and political polarization across the globe. Even when mental illness isn\'t a factor in tribalism, we hypothesize that the learned maladaptive and false beliefs that are key components of humanity\'s tribal tendencies \\cite{klein2020Polarized,galefScoutMindset} can be unlearned by the same mechanism that mental illness can be unlearned. While some individuals are able to access effective mental healthcare, both access and effectiveness are inadequate for most of the vast population of individuals who experience mental illness.',
#     'note': 'Citation continues to second sentence, then author hypothesis, then new citations, then general statement'

#     'citation_set': 'wampoldCommonFactors',
#     'expected': '->Feelings of trust towards the therapeutic process are an important resource for getting individuals into mental health treatment who need it, and feelings of trust between therapists and clients are an essential mechanism for the effectiveness of therapy \\cite{wampoldCommonFactors}.<- One of the most exciting aspects of therapeutic MDMA usage is that it allows traumatized individuals to experience a sense of safety and connectedness that is otherwise physiologically and psychologically inaccessible to them, even in trustworthy circumstances \\cite{fedduciaMDMAMemoryReconsolidation}. Additionally, many cultures and subcultures experience a normalized hostility regarding even the acknowledgement of mental illness, creating a challenge for clients who are in need of care and for clinicians who attempt to provide effective care in these communities.',
#     'note': 'Single sentence citation, then new citation, then general observation'

#     'citation_set': 'miller2014secrets',
#     'expected': '->\\textcite{miller2014secrets} explores the concept of "supershrinks" - therapists who consistently achieve superior outcomes regardless of their theoretical orientation or specific techniques. The authors argue that exceptional performance in therapy, as in other fields, is primarily the result of deliberate practice and ongoing feedback rather than innate talent or experience alone. They propose a three-part formula for improving therapeutic effectiveness: determining one\'s baseline of effectiveness, engaging in deliberate practice, and consistently seeking and incorporating client feedback. By tracking outcomes, comparing performance to national norms, and actively working to improve skills through targeted practice and reflection, the authors suggest that all therapists can significantly enhance their effectiveness and client outcomes.<-',
#     'note': 'All sentences describe the cited work using multiple "the authors" references'

#     'expected': '->The Autonomic Nervous System governs a wide variety of involuntary bodily functions, such as heart rate and digestion \\cite{kozlowskaDefenseCascade}. In one of its roles, it activates a defense cascade—a sequence of responses—to shield us from threats. Increasing levels of perceived threat activate these responses, though the order of activation depends on individual variability and experience. Additionally, activation is proportional to our estimation of the threat and our ability to handle it. Children activate easily because the threshold of what constitutes a threat to their life is much lower than it is for healthy adults. Lack of parental support, attention, or attunement (see Appendix \\ref{attachment}) can be life-threatening situations for children.<-',
#     'note': 'Multiple sentences after citation all describe the cited framework'

#     'expected': 'There is a lot of variability in individual responsiveness to trauma because all experiences and individuals are unique. A devastating event for one person may cause only temporary difficulty for someone else. ->Mentally healthy adults with sufficient resources are resilient to most traumas and usually develop appropriate schemas to manage those situations in the future \\cite{bonanno2008loss}.<- Secure attachment is also a major factor in resilience \\cite{attachmentPTSD}. Securely attached children are also resilient to trauma, especially when they have assistance from their parents. After the threat passes in these cases of resilience the individual may have a temporary period of distress about the experience, but this dissipates in a reasonable amount of time.',
#     'note': 'Common knowledge, single citation sentence, immediately followed by new citation'

#     'expected': 'A variety of risk factors reduce the capacity to bounce back and form healthy schemas for that situation. ->Post-trauma factors for children, adolescents, and presumably also adults to a large degree, include blaming others, thought suppression, distraction, low social support, social withdrawal, poor family functioning, and parental psychological problems \\cite{trickeyRiskFactors}.<- \\cite{tangRiskFactors} also found that female gender (this may function differently in different cultures), unemployment, and low education are risk factors for adults. Resilience to trauma is complex \\cite{bonanno2008loss}, but it may be that many of those items are risk factors because they are generally situations of broad resource (emotional, physical, social) insecurity, which are additional pieces of evidence reinforcing overly-general high-threat predictions like "I\'m in danger everywhere \\cite{berghSelfEvidencing}."',
#     'note': 'Four different citations in one paragraph with interpretations between them'

#     'citation_set': 'eckerUnlocking',
#     'expected': '->As discussed in the previous section, a consciously experienced contradiction between an old schema and a new experience or existing knowledge creates prediction error \\cite{eckerUnlocking}. Prediction error triggers an updating process called memory reconsolidation. When schemas are first created, they are \\textit{consolidated}. After that, when a consciously experienced contradiction creates prediction error for that schema, the schema enters a state of plasticity where it can be changed. Maintaining that experience of contradiction over a period of time will then gradually update the schema to account for the contradiction. About 5 hours (in animal models) after the initial prediction error, the memory is \\textit{re-consolidated}, re-entering a stable state where it can no longer be changed without another consciously experienced contradiction.<- Throughout this book for convenience we will use "reconsolidate" in a slightly different way to denote the entire process of schema destabilization, updating, and restabilization.',
#     'note': 'Long multi-sentence description of cited theory, then author terminological choice'

#     'citation_set': 'carhart2019rebus',
#     'expected': 'We\'ve personally observed and seen a number of anecdotes suggesting that in practice, MDMA often seems to facilitate or provide effective mismatches for most, if not all maladaptive schemas. ->\\textcite{carhart2019rebus} hypothesizes that MDMA relaxes all socially/relationally relevant schemas, which are typically the kind of schemas that trauma causes. Once those schemas are relaxed, all types of contradictory information have higher relative strength and are more liable to induce prediction error and reconsolidation.<- We don\'t know exactly what type of contradictory information one might encounter in any particular scenario, but we have a few somewhat overlapping hypotheses.',
#     'note': 'Author anecdote, citation hypothesis, author uncertainty'

#     'citation_set': 'hayes2020complex',
#     'expected': '->\\textcite{hayes2020complex} summarizes a variety of research (citations 13, 17-26 in the original) on this complex-adaptive-systems modeling of mental illness: "...a dynamic system [mental states in this case] is a set of interconnected elements that evolve over time and self-organize into higher-order functional units, called attractor states [stable patterns of behavior, beliefs, and emotions], that are preferred and govern system behavior. Self-organization is the process by which lower-order processes [individual schemas, defense cascade activations, elements of life circumstances, gene variants, etc.] interact and higher-order patterns emerge and then influence the lower-order processes in a top-down manner."<-',
#     'note': 'Long block quote from source with editorial additions in brackets'

#     'citation_set': 'hayes2020complex,friston2010free',
#     'expected': '->In simpler terms, therapy is a process of moving from stuck state(s) of mental illness to state(s) of mental health \\cite{hayes2020complex,friston2010free}. In this case stable mental health is defined as a system that quickly returns to an adaptive state when perturbed. Transitioning to mental health is accomplished through: reconsolidating the schemas that reinforce the state of mental illness, reducing the behavioral, social, or environmental elements that reinforce state(s) of mental illness, or shaking the system hard enough that you (hopefully) jump straight from the stable state of mental illness to an existing, but inactive and somewhat stable state of good mental health.<-',
#     'note': 'Two citations together, multiple sentences elaborating on the cited framework'

#     'citation_set': 'eckerUnlocking',
#     'expected': '->In practice, the first process of reconsolidation seems frequently necessary and sufficient to resolve the issue at hand \\cite{eckerUnlocking}. All the other processes can leave the maladaptive schemas reinforcing the state of mental illness inactive but intact. Relapse occurs when the right circumstances reactivate that old state. Additionally, constant effort may be needed to maintain the set of behavioral and environmental elements that maintain a state of mental health. Reconsolidation permanently dismantles many of the reinforcing elements of mental illness. There is no, or only a weakened, latent state of mental illness to relapse into.<- One other solution theoretically sufficient by itself to resolve mental illness are interventions which durably decrease avoidance to such a degree that the newly perceived information naturally reconsolidates all or most important maladaptive schemas over time \\cite{berghSelfEvidencing}.',
#     'note': 'Long elaboration on first citation, then new citation at end'

#     'citation_set': 'berghSelfEvidencing',
#     'expected': '->Therapeutic improvement frequently requires paying attention to and integrating previously-avoided distressing information like sensations, memories, or emotions \\cite{berghSelfEvidencing}. This newly-perceived information may activate a variety of distressing (either adaptive or maladaptive, and possibly latent) schemas related to the information\'s meaning or implications, and may activate panic or dissociation in severe cases.<- We think this new state of worsened symptoms is likely temporary because the previously-avoided information is precisely what was needed to reconsolidate some of the symptom-producing maladaptive schemas; avoiding this information was what prevented reconsolidation. These worsened symptoms may drag on longer than necessary if panic or dissociation inhibits the natural reconsolidation process the newly-perceived information would otherwise activate.',
#     'note': 'Citation continues to second sentence describing implications, then author opinion'

#     'citation_set': 'hayes2020complex',
#     'expected': '->While complex systems dynamics surely explain important parts of the therapeutic process, its practical applications are currently limited \\cite{hayes2020complex}. Complex systems are hard to model, the model architecture is unknown and might be significantly different for every individual, the architecture dynamically reorganizes all the time in complex ways, and almost all the parameters of the model are extremely difficult or impossible to measure. Furthermore, the "state space" these states exist in isn\'t just a simple one or two-dimensional landscape of valleys and hills that the "ball" of mental health rolls around in; it has as many dimensions as there are schemas, behaviors, and environmental elements.<- We don\'t know how many dimensions are of practical importance in any particular case, but it could easily be enough that many therapeutically relevant systems are too complicated for any human to comprehend. So while complex system dynamics succeeds at qualitatively describing some therapeutic dynamics, it doesn\'t offer a lot of practical advice on who will destabilize/worsen, when they will destabilize/worsen, how long they will be destabilized/worsened for, and which therapeutic tactic is best at any particular point of any specific case \\cite{helmich2024slow,hayes2020complex}.',
#     'note': 'Long elaboration starting with first citation, ending with same citation plus another - all describes the cited limitations'

#     'citation_set': 'olthofDestabilization',
#     'expected': '->Psychological destabilization (see Section \\ref{sec:complex}) is a common occurrence in therapy \\cite{olthofDestabilization}. It\'s associated with better outcomes later in therapy, but if it is intense enough and not managed well can severely interfere with your life.<- We are not aware of any papers demonstrating this, but we think it\'s likely that MDMA therapy tends to produce stronger destabilization (and more rapid therapeutic progress) than traditional psychotherapy. Severe early childhood trauma (including non-secure attachment) may be a major risk factor. The therapeutic alliance is a moderate mitigating factor when working with a mental health professional (see \\textcite{BRWAIdownload} for an assessment scale) \\cite{fluckiger2018alliance}.',
#     'note': 'Citation with continuation, author opinion admitting no evidence, general statements, new citation'

#     'citation_set': 'la2022Psychosis',
#     'expected': '->Psychosis: There is virtually no high quality experimental data because people with a history of psychosis are usually excluded from clinical trials of psychedelics \\cite{la2022Psychosis}.<- Like other mental illness, psychosis is a complex biopsychosocial phenomenon. Therapy can often reduce the symptoms of psychosis \\cite{CBTp}, suggesting that maladaptive schemas often play some role, though it\'s not certain how strong that is compared to other factors. This implies that psychosis can start and stop at hard-to-predict points during the reconsolidation process, and in life in general, for people with some level of predisposition. We\'ve seen a collection of anecdotes congruent with this: A few self-reports from people stating that a single MDMA therapy session triggered a psychotic episode.',
#     'note': 'Single sentence citation, general statement, new citation, author interpretation, author anecdotes'

#     'citation_set': 'evans2023extended',
#     'expected': '->\\textcite{evans2023extended} surveyed people who have experienced new, persistent negative symptoms after recreational, professional-therapeutic, and DIY-therapeutic psychedelic experiences. This data applies to all psychedelics, not just MDMA. Most symptoms dissipated with time, but 17\\% of respondents said theirs lasted more than 3 years. From most to least common, participants reported emotional (76\\%), self-perception (58\\%), cognitive (52\\%), social (52\\%), ontological (50\\%), spiritual (34\\%), perceptual (26\\%), and other (21\\%) difficulties.<- There is major uncertainty in how much these symptoms are due to surfacing of existing maladaptive schemas and subsequent defense cascade activation, a necessary and healthy part of the therapeutic process if managed well.',
#     'note': 'Long description of survey findings, then author interpretation of uncertainty'
# OUTPUT REQUIREMENTS:
# - Output ONLY the paragraph with markers added
# - Do NOT add explanations, commentary, or any other text
# - Preserve exact formatting including line numbers if present

# PARAGRAPH TO ANALYZE:
# $PARAGRAPH$

# CITATION SET TO MARK: $CITATION_SET$
# """

# IMPROVED_PROMPT_V1 = """You are analyzing an academic paragraph to identify "attribution units" - groups of consecutive sentences that share the same citation(s).

# CONTEXT:
# In APA academic writing, when an author cites a source, the following sentences often continue to describe or reference that same source until either:
# 1. A new citation appears (starting a new attribution unit)
# 2. The author shifts to their own interpretation/opinion (no citation needed)
# 3. The author makes a general statement not requiring citation

# YOUR TASK:
# Mark the attribution unit that uses EXACTLY the citation set: $CITATION_SET$

# RULES:
# 1. Include ALL consecutive sentences that depend on this exact citation set
# 2. The citation set must match EXACTLY (same authors, same order doesn't matter if it's a set)
# 3. Sentences that continue describing the cited work should be included even if they don't repeat the citation
# 4. Stop when you encounter:
#    - A different citation
#    - Author's own opinion/interpretation (usually obvious from context like "we think", "we believe", or implied by assertive claims not attributed to a source)
#    - A new topic that's clearly not from the cited source
# 5. Place markers '->' at the start and '<-' at the end of the attribution unit
# 6. Markers should be at sentence boundaries (after periods, not mid-sentence)
# 7. Preserve all original text, line numbers, and formatting

# EXAMPLES:

# Example 1 (all sentences inherit the citation):
# Input: "The brain processes emotions in complex ways \\cite{smith2020}. This processing involves multiple regions. The amygdala plays a central role."
# Citation set: smith2020
# Output: "->The brain processes emotions in complex ways \\cite{smith2020}. This processing involves multiple regions. The amygdala plays a central role.<-"

# Example 2 (opinion sentence before citation):
# Input: "Mental health is important. Research shows therapy is effective \\cite{jones2021}. The study included 200 participants."
# Citation set: jones2021
# Output: "Mental health is important. ->Research shows therapy is effective \\cite{jones2021}. The study included 200 participants.<-"

# Example 3 (citation changes mid-paragraph):
# Input: "MDMA affects serotonin \\cite{doe2019}. This leads to mood changes. However, other drugs work differently \\cite{smith2020}."
# Citation set: doe2019
# Output: "->MDMA affects serotonin \\cite{doe2019}. This leads to mood changes.<- However, other drugs work differently \\cite{smith2020}."

# OUTPUT REQUIREMENTS:
# - Output ONLY the paragraph with markers added
# - Do NOT add explanations, commentary, or any other text
# - Preserve exact formatting including line numbers if present

# PARAGRAPH TO ANALYZE:
# $PARAGRAPH$

# CITATION SET TO MARK: $CITATION_SET$
# """

IMPROVED_PROMPT_V1 = """In academic writing in APA, paragraphs are split into 'attribution units' that each depend on a certain set of citations. So the first sentence has citation1, and the following sentences inherit that until a sentence starts that uses a different set of citations or is an opinion. Mark each attribution unit in the following paragraph that uses exactly this ($CITATION_SET$) particular set of citations by inserting '->' and '<-' around that set of sentences. Markers should generally be on sentence or clause boundaries. You're acting as a input/output function; you're *only* output is the original text (and line numbers) with the markers added. DO NOT ADD ANYTHING ELSE OR EXPLAIN WHAT YOU'RE DOING.
            
                PARAGRAPH: <<$PARAGRAPH$>>"""

IMPROVED_PROMPT_V2 = """TASK: Mark sentences in this paragraph that attribute to citation set: $CITATION_SET$

In academic writing, citations apply to the sentence containing them AND following sentences that continue discussing that source, until either a new citation appears or the author adds their own interpretation.

INSTRUCTIONS:
1. Find all consecutive sentences using EXACTLY this citation set: $CITATION_SET$
2. Mark the start with '->' and end with '<-'
3. Include the sentence with the citation AND all following sentences that describe/discuss the same source
4. Stop when you hit: a different citation, author opinion ("we think"), or new uncited topic
5. Output ONLY the original text with markers added - no explanations

EXAMPLES:

Input: "Studies show X is true \\cite{smith}. The researchers found Y. This suggests Z."
Mark: smith
Output: "->Studies show X is true \\cite{smith}. The researchers found Y. This suggests Z.<-"

Input: "We believe therapy helps. Research confirms this \\cite{jones}. The data is clear."
Mark: jones
Output: "We believe therapy helps. ->Research confirms this \\cite{jones}. The data is clear.<-"

Input: "First study \\cite{a}. More details. New study \\cite{b}. Its findings."
Mark: a
Output: "->First study \\cite{a}. More details.<- New study \\cite{b}. Its findings."

NOW MARK THIS PARAGRAPH:
$PARAGRAPH$
"""

def call_claude(prompt: str, debug=False) -> str:
    """Call Claude via the command line in non-interactive mode."""
    # Use subprocess to call claude with the prompt
    # Uses --print flag for non-interactive output
    try:
        result = subprocess.run(
            ['claude', '--model', 'haiku', '--print'],
            input=prompt,
            capture_output=True,
            text=True,
            timeout=60  # Increased timeout for potentially long responses
        )

        if debug:
            print(f"Return code: {result.returncode}")
            if result.stderr:
                print(f"Stderr: {result.stderr[:200]}")

        if result.returncode != 0:
            return f"ERROR: Claude exited with code {result.returncode}. Stderr: {result.stderr}"

        return result.stdout.strip()
    except subprocess.TimeoutExpired:
        return "ERROR: Claude call timed out"
    except FileNotFoundError:
        return "ERROR: 'claude' command not found. Make sure it's in your PATH."
    except Exception as e:
        return f"ERROR: {str(e)}"

def test_prompt_on_examples(prompt_template: str, examples: List[Dict], debug=True) -> Dict:
    """Test a prompt template on hand-crafted examples."""
    results = []
    for i, ex in enumerate(examples):
        prompt = prompt_template.replace('$CITATION_SET$', ex['citation_set'])
        prompt = prompt.replace('$PARAGRAPH$', ex['paragraph'])

        if debug:
            print(f"\n{'='*60}")
            print(f"Example {i+1}: {ex['citation_set']}")
            print('='*60)

        response = call_claude(prompt, debug=debug)

        matches_expected = (response.strip() == ex['expected'].strip())

        if debug:
            print(f"\nExpected ({len(ex['expected'])} chars):")
            print(ex['expected'])
            print(f"\nActual ({len(response)} chars):")
            print(response)
            print(f"\n✓ MATCH" if matches_expected else "✗ NO MATCH")

        results.append({
            'input': ex['paragraph'][:100] + '...',
            'expected': ex['expected'][:100] + '...',
            'actual': response[:100] + '...' if len(response) > 100 else response,
            'full_actual': response,  # Store full response for debugging
            'match': matches_expected,
            'note': ex.get('note', '')
        })

    success_rate = sum(1 for r in results if r['match']) / len(results) if results else 0
    return {
        'prompt_name': 'Test',
        'success_rate': success_rate,
        'results': results
    }

def test_prompt_on_real_paragraphs(prompt_template: str, paragraphs: List[Dict], num_tests: int = 5) -> Dict:
    """Test a prompt template on real paragraphs from paper.tex."""
    results = []

    for i, para_data in enumerate(paragraphs[:num_tests]):
        # Test with the first citation set in the paragraph
        if not para_data['citation_sets']:
            continue

        citation_set = para_data['citation_sets'][0]

        prompt = prompt_template.format(
            citation_keys_text=citation_set,
            paragraph_text=para_data['text']
        )

        response = call_claude(prompt)

        results.append({
            'paragraph_num': i + 1,
            'citation_set': citation_set,
            'input_length': len(para_data['text']),
            'output': response,
            'has_markers': '->' in response and '<-' in response
        })

    success_rate = sum(1 for r in results if r['has_markers']) / len(results) if results else 0

    return {
        'prompt_name': 'Real paragraphs',
        'success_rate': success_rate,
        'results': results
    }

def main():
    import argparse
    parser = argparse.ArgumentParser(description='Test attribution unit marking prompts')
    parser.add_argument('--test-one', type=int, help='Test only one example (1, 2, or 3)', choices=[1, 2, 3])
    parser.add_argument('--prompt', choices=['v1', 'v2', 'both'], default='both', help='Which prompt to test')
    parser.add_argument('--no-debug', action='store_true', help='Disable debug output')
    args = parser.parse_args()

    print("Attribution Unit Prompt Testing Script")
    print("=" * 60)

    # Create test examples
    print("\n1. Creating hand-crafted test examples...")
    all_examples = create_test_examples()
    if args.test_one:
        examples = [all_examples[args.test_one - 1]]
        print(f"   Testing only example {args.test_one}")
    else:
        examples = all_examples
        print(f"   Created {len(examples)} test examples")

    # Extract real paragraphs from paper.tex
    print("\n2. Extracting paragraphs from paper.tex...")
    tex_file = 'paper.tex'
    try:
        paragraphs = extract_paragraphs_with_citations(tex_file, max_paragraphs=10)
        print(f"   Extracted {len(paragraphs)} paragraphs with citations")
    except FileNotFoundError:
        print(f"   ERROR: {tex_file} not found")
        paragraphs = []

    # Test prompts
    print("\n3. Testing prompt variations...")
    debug = not args.no_debug

    # print("\n" + "=" * 60)
    # print("IMPROVED PROMPT V1:")
    # print("=" * 60)
    # # Use str.replace to show the template with placeholders
    # display_v1 = IMPROVED_PROMPT_V1.replace("{{citation_keys_text}}", "{CITATION_SET}")
    # display_v1 = display_v1.replace("{{paragraph_text}}", "{PARAGRAPH_TEXT}")
    # print(display_v1)

    # print("\n" + "=" * 60)
    # print("IMPROVED PROMPT V2 (More Concise):")
    # print("=" * 60)
    # display_v2 = IMPROVED_PROMPT_V2.replace("{{citation_keys_text}}", "{CITATION_SET}")
    # display_v2 = display_v2.replace("{{paragraph_text}}", "{PARAGRAPH_TEXT}")
    # print(display_v2)

    # print("\n" + "=" * 60)
    # print("TEST EXAMPLES:")
    # print("=" * 60)
    # for i, ex in enumerate(examples, 1):
    #     print(f"\nExample {i}:")
    #     print(f"  Citation set: {ex['citation_set']}")
    #     print(f"  Input: {ex['paragraph'][:100]}...")
    #     print(f"  Expected: {ex['expected'][:100]}...")
    #     print(f"  Note: {ex['note']}")

    # Test with Claude
    results = {}

    if args.prompt in ['v1', 'both']:
        print("\n" + "="*60)
        print("4. Testing IMPROVED_PROMPT_V1 on examples...")
        print("="*60)
        results['v1'] = test_prompt_on_examples(IMPROVED_PROMPT_V1, examples, debug=debug)
        print(f"\n{'='*60}")
        print(f"PROMPT V1 Success rate: {results['v1']['success_rate']:.1%}")
        print('='*60)

    # if args.prompt in ['v2', 'both']:
    #     print("\n" + "="*60)
    #     print("5. Testing IMPROVED_PROMPT_V2 on examples...")
    #     print("="*60)
    #     results['v2'] = test_prompt_on_examples(IMPROVED_PROMPT_V2, examples, debug=debug)
    #     print(f"\n{'='*60}")
    #     print(f"PROMPT V2 Success rate: {results['v2']['success_rate']:.1%}")
    #     print('='*60)

    # Print summary
    if len(results) > 0:
        print("\n" + "="*60)
        print("SUMMARY")
        print("="*60)
        if 'v1' in results:
            print(f"Prompt V1 (Detailed): {results['v1']['success_rate']:.1%}")
        if 'v2' in results:
            print(f"Prompt V2 (Concise): {results['v2']['success_rate']:.1%}")

        min_success = min(r['success_rate'] for r in results.values())
        if min_success < 0.5:
            print("\nLow success rate detected. Common issues:")
            print("- Claude might be adding explanations despite instructions")
            print("- Minor formatting differences causing mismatches")
            print("- Review the 'Actual' outputs above to see what Claude returned")
            print("\nTips:")
            print("- Try: python3 test_attribution_prompt.py --test-one 1 --prompt v1")
            print("- This tests just one example with one prompt to debug faster")

    # print("\n" + "=" * 60)
    # print("To actually run tests with Claude, edit this script and uncomment")
    # print("the test_prompt_on_examples() and test_prompt_on_real_paragraphs() calls.")
    # print("=" * 60)

if __name__ == '__main__':
    main()
