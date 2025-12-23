# Improved Attribution Unit Marking Prompt

## Analysis of Original Prompt

### Original Prompt Issues

Your original prompt had several weaknesses that likely contributed to the ~80% accuracy rate:

1. **Vague "opinion" criterion**: The phrase "or is an opinion" doesn't provide clear guidance for what constitutes an author opinion vs. inherited citation
2. **Lack of examples**: No concrete demonstrations of expected behavior
3. **No explanation of citation inheritance**: Doesn't clearly explain when sentences inherit citations vs. when they don't
4. **Missing edge case handling**: Doesn't address:
   - Multiple citations in a row
   - Transition sentences between attribution units
   - \textcite{} vs \cite{} differences
   - Sentences with no citation in the middle of a paragraph
5. **Ambiguous boundary rules**: "Markers should generally be on sentence or clause boundaries" - but what about complex sentences?
6. **Doesn't explain what NOT to mark**: Should uncited opinion sentences at the start be marked?

### What Makes Attribution Unit Identification Tricky

In APA academic writing:
- A citation applies to the sentence containing it
- Following sentences WITHOUT citations often inherit that citation IF they continue discussing that source
- A new citation marks the start of a new attribution unit
- Author opinions/interpretations typically have no citations
- The boundary between "continuing to discuss a source" and "author's own interpretation" can be ambiguous

**The key insight**: Context matters enormously. "The study showed X. This suggests Y." - does sentence 2 belong to the citation or is it the author's interpretation? It depends on the broader context and phrasing.

## Recommended Improved Prompt (Version 1 - Detailed)

```
You are analyzing an academic paragraph to identify "attribution units" - groups of consecutive sentences that share the same citation(s).

CONTEXT:
In APA academic writing, when an author cites a source, the following sentences often continue to describe or reference that same source until either:
1. A new citation appears (starting a new attribution unit)
2. The author shifts to their own interpretation/opinion (no citation needed)
3. The author makes a general statement not requiring citation

YOUR TASK:
Mark the attribution unit that uses EXACTLY the citation set: {citation_keys_text}

RULES:
1. Include ALL consecutive sentences that depend on this exact citation set
2. The citation set must match EXACTLY (same authors, same order doesn't matter if it's a set)
3. Sentences that continue describing the cited work should be included even if they don't repeat the citation
4. Stop when you encounter:
   - A different citation
   - Author's own opinion/interpretation (usually obvious from context like "we think", "we believe", or implied by assertive claims not attributed to a source)
   - A new topic that's clearly not from the cited source
5. Place markers '->' at the start and '<-' at the end of the attribution unit
6. Markers should be at sentence boundaries (after periods, not mid-sentence)
7. Preserve all original text, line numbers, and formatting

EXAMPLES:

Example 1 (all sentences inherit the citation):
Input: "The brain processes emotions in complex ways \cite{smith2020}. This processing involves multiple regions. The amygdala plays a central role."
Citation set: smith2020
Output: "->The brain processes emotions in complex ways \cite{smith2020}. This processing involves multiple regions. The amygdala plays a central role.<-"

Example 2 (opinion sentence before citation):
Input: "Mental health is important. Research shows therapy is effective \cite{jones2021}. The study included 200 participants."
Citation set: jones2021
Output: "Mental health is important. ->Research shows therapy is effective \cite{jones2021}. The study included 200 participants.<-"

Example 3 (citation changes mid-paragraph):
Input: "MDMA affects serotonin \cite{doe2019}. This leads to mood changes. However, other drugs work differently \cite{smith2020}."
Citation set: doe2019
Output: "->MDMA affects serotonin \cite{doe2019}. This leads to mood changes.<- However, other drugs work differently \cite{smith2020}."

OUTPUT REQUIREMENTS:
- Output ONLY the paragraph with markers added
- Do NOT add explanations, commentary, or any other text
- Preserve exact formatting including line numbers if present

PARAGRAPH TO ANALYZE:
{paragraph_text}

CITATION SET TO MARK: {citation_keys_text}
```

## Alternative Improved Prompt (Version 2 - Concise)

```
TASK: Mark sentences in this paragraph that attribute to citation set: {citation_keys_text}

In academic writing, citations apply to the sentence containing them AND following sentences that continue discussing that source, until either a new citation appears or the author adds their own interpretation.

INSTRUCTIONS:
1. Find all consecutive sentences using EXACTLY this citation set: {citation_keys_text}
2. Mark the start with '->' and end with '<-'
3. Include the sentence with the citation AND all following sentences that describe/discuss the same source
4. Stop when you hit: a different citation, author opinion ("we think"), or new uncited topic
5. Output ONLY the original text with markers added - no explanations

EXAMPLES:

Input: "Studies show X is true \cite{smith}. The researchers found Y. This suggests Z."
Mark: smith
Output: "->Studies show X is true \cite{smith}. The researchers found Y. This suggests Z.<-"

Input: "We believe therapy helps. Research confirms this \cite{jones}. The data is clear."
Mark: jones
Output: "We believe therapy helps. ->Research confirms this \cite{jones}. The data is clear.<-"

Input: "First study \cite{a}. More details. New study \cite{b}. Its findings."
Mark: a
Output: "->First study \cite{a}. More details.<- New study \cite{b}. Its findings."

NOW MARK THIS PARAGRAPH:
{paragraph_text}
```

## Key Improvements

Both improved versions address the original prompt's weaknesses:

1. **Clear context**: Explains how citation inheritance works in APA writing
2. **Concrete examples**: Shows 3 different scenarios with expected outputs
3. **Explicit rules**: Lists when to include sentences and when to stop
4. **Better edge case handling**: Examples show transitions between citations, opinions before citations, etc.
5. **Clearer output requirements**: Emphasizes "only output the marked text"

## Recommendation

I recommend **Version 1 (Detailed)** because:
- The additional structure and explanation will likely improve accuracy
- The numbered rules make it easier for Claude to follow systematically
- The more detailed context helps with edge cases

However, **Version 2 (Concise)** may work better if:
- Token limits are a concern
- You're processing many paragraphs
- The conciseness helps Claude focus on the core task

## Testing Script

I've created `test_attribution_prompt.py` which:
- Extracts paragraphs with citations from paper.tex
- Provides hand-crafted test examples with expected outputs
- Can call Claude in non-interactive mode to test prompts
- Compares actual outputs with expected outputs

To use it:
1. Edit the script and uncomment the test function calls at the bottom
2. Run: `python3 test_attribution_prompt.py`
3. Review the success rates for each prompt variation

## Additional Recommendations

To further improve accuracy:

1. **Add more examples** in the prompt showing:
   - Multiple citations in one \cite{} command
   - \textcite{} usage
   - Very long attribution units (5+ sentences)
   - Edge cases from your actual paper

2. **Iterative refinement**: When Claude makes mistakes:
   - Identify the pattern of errors
   - Add an example showing the correct handling of that pattern
   - Add a specific rule if needed

3. **Consider prompt chaining**: For very difficult cases:
   - First pass: Have Claude identify where each citation applies
   - Second pass: Have Claude mark the attribution units based on that analysis

4. **Validate with spot checks**: Run the prompt on a sample of paragraphs and manually verify the output before processing the entire document

## Expected Improvement

With these improved prompts, I expect accuracy to increase from ~80% to 90-95%. The remaining errors will likely be genuinely ambiguous cases where even humans might disagree about whether a sentence belongs to a citation or represents the author's interpretation.
