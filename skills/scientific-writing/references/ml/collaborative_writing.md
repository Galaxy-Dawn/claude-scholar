# Collaborative Writing Philosophy

## Core Philosophy: Be Proactive

**Paper writing is collaborative, but Claude should be proactive in delivering drafts.**

The typical workflow starts with a research repository containing code, results, and experimental artifacts. Claude's role is to:

1. **Understand the project** by exploring the repo, results, and existing documentation
2. **Deliver a complete first draft** when confident about the contribution
3. **Search literature** using web search and APIs to find relevant citations
4. **Refine through feedback cycles** when the scientist provides input
5. **Ask for clarification** only when genuinely uncertain about key decisions

## Key Principle: Proactive Delivery

**Default: Be proactive. Deliver drafts, then iterate.**

| Confidence Level | Action |
|-----------------|--------|
| **High** (clear repo, obvious contribution) | Write full draft, deliver, iterate on feedback |
| **Medium** (some ambiguity) | Write draft with flagged uncertainties, continue |
| **Low** (major unknowns) | Ask 1-2 targeted questions, then draft |

### What "Proactive" Means

**DO:**
- Write complete sections when information is clear
- Make reasonable choices and flag them for review
- Deliver something concrete to react to
- Continue writing instead of blocking for minor decisions

**DON'T:**
- Ask for permission on every sentence
- Wait for feedback before writing next section
- Block on minor decisions (wording, section ordering, etc.)
- Leave things incomplete "pending feedback"

## Balancing Proactivity and Collaboration

### Draft First, Ask Questions With the Draft

**NOT this:**
```
"I'm about to write the abstract. Should I start with the problem
statement or our contribution? How many sentences should it be?
Which results should I highlight?"
```

**INSTEAD this:**
```
"I've drafted the abstract below. I framed the contribution as X
and highlighted results A, B, C. Let me know if you'd like to
adjust the emphasis or include different results."

[Complete abstract follows]
```

### Flagging Uncertainties

**When you have genuine uncertainty:**

```latex
% Draft with flag:
We introduce a novel architecture that combines the efficiency of
method A with the accuracy of method B. [FLAG: I emphasized the
efficiency-accuracy tradeoff here—let me know if you'd prefer to
emphasize a different aspect.]
```

**After feedback, remove flags:**
```latex
We introduce a novel architecture that combines the efficiency of
method A with the accuracy of method B.
```

## Section-by-Section Guidelines

### Abstract

**Draft autonomously. Flag with draft:**

```
I've drafted the abstract following the 5-sentence formula.
I emphasized contribution X and highlighted result Y.
Adjust if needed.

[Complete abstract follows]
```

**Don't ask before:**
- "What should I put in the abstract?"
- "Which results should I highlight?"
- "How should I frame the contribution?"

### Introduction

**Draft autonomously. Include:**

```
I've written the introduction with:
- Problem motivation
- Our contribution framed as [X]
- 2-4 bullet contributions
- Brief approach overview
- Preview of results

I emphasized [aspect]—let me know if you'd prefer different framing.

[Complete introduction follows]
```

### Methods

**Draft autonomously. Include:**

```
I've written the methods section with:
- Architecture details
- Training procedure
- Hyperparameters (all listed)
- Algorithm pseudocode

I included [details] but could move some to appendix if too verbose.
Let me know if any details are missing.

[Complete methods section follows]
```

### Experiments

**Draft autonomously. Include:**

```
I've written the experiments section with:
- Setup description
- Baselines compared
- Results for experiments A, B, C
- Ablation study

I highlighted [results]—let me know if others are more important.
I wrote brief experiment descriptions; could expand if needed.

[Complete experiments section follows]
```

### Related Work

**Draft autonomously. Include:**

```
I've organized related work by [method/approach], not paper-by-paper.
I cited [papers]—add any I missed.

[Complete related work section follows]

I may have missed relevant work in [specific area]. Please add any
important citations I should include.
```

## When to Block for Input

**Only block for input when:**
- Target venue is unclear (affects page limits, framing)
- Multiple contradictory framings seem equally valid
- Results seem incomplete or inconsistent
- Explicit request to review before continuing

**Don't block for:**
- Word choice decisions
- Section ordering (make a choice, flag it)
- Which specific results to show (choose, flag for review)
- Citation completeness (draft with what you find, note gaps)

## Workflow 0: Starting from a Research Repository

### Project Understanding Checklist

```
- [ ] Step 1: Explore the repository structure
- [ ] Step 2: Read README, existing docs, and key results
- [ ] Step 3: Identify the main contribution with the scientist
- [ ] Step 4: Find papers already cited in the codebase
- [ ] Step 5: Search for additional relevant literature
- [ ] Step 6: Outline the paper structure together
- [ ] Step 7: Draft sections iteratively with feedback
```

### Step 1: Explore the Repository

```bash
# Understand project structure
ls -la
find . -name "*.py" | head -20
find . -name "*.md" -o -name "*.txt" | xargs grep -l -i "result\|conclusion\|finding"
```

**Look for:**
- `README.md` - Project overview and claims
- `results/`, `outputs/`, `experiments/` - Key findings
- `configs/` - Experimental settings
- Existing `.bib` files or citation references
- Any draft documents or notes

### Step 2: Identify Existing Citations

**Check for papers already referenced in the codebase:**

```bash
# Find existing citations
grep -r "arxiv\|doi\|cite" --include="*.md" --include="*.bib" --include="*.py"
find . -name "*.bib"
```

**These are high-signal starting points** for Related Work—the scientist has already deemed them relevant.

### Step 3: Clarify the Contribution

**Before writing, explicitly confirm with the scientist:**

```
Based on my understanding of the repo, the main contribution
appears to be [X]. The key results show [Y].

Is this the framing you want for the paper, or should we emphasize
different aspects?
```

**Never assume the narrative—always verify with the human.**

### Step 4: Search for Additional Literature

**Use web search to find relevant papers:**

```
Search queries to try:
- "[main technique] + [application domain]"
- "[baseline method] comparison"
- "[problem name] state-of-the-art"
- Author names from existing citations
```

**Then verify and retrieve BibTeX** using the citation workflow.

### Step 5: Deliver a First Draft

**Be proactive—deliver a complete draft rather than asking permission for each section.**

**If the repo provides clear results and the contribution is apparent:**

1. Write the full first draft end-to-end
2. Present the complete draft for feedback
3. Iterate based on scientist's response

**If genuinely uncertain about framing or major claims:**

1. Draft what you can confidently
2. Flag specific uncertainties: "I framed X as the main contribution—let me know if you'd prefer to emphasize Y instead"
3. Continue with the draft rather than blocking

**Questions to include with the draft (not before):**

```
- I emphasized X as the main contribution—adjust if needed
- I highlighted results A, B, C—let me know if others are more important
- Related work section includes [papers]—add any I missed
```

## Examples: Proactive vs Passive Approach

### Example 1: Writing the Abstract

**Passive (BAD):**
```
Before I write the abstract, can you tell me:
1. What should the first sentence say?
2. Which results should I highlight?
3. How should I frame the contribution?
```

**Proactive (GOOD):**
```
I've drafted the abstract below. I followed the 5-sentence formula
and framed the contribution as [X], highlighting results [Y].

Let me know if you'd like to adjust the framing or emphasize different
results.

[Complete abstract follows]
```

### Example 2: Writing Related Work

**Passive (BAD):**
```
I'm about to write the related work section. Which papers should I
cite? Should I organize by method or chronologically?
```

**Proactive (GOOD):**
```
I've drafted the related work section below, organized by
methodological approach (not paper-by-paper). I cited [papers from
codebase] and added [additional relevant work].

I may have missed relevant work in [specific area]—please add any
important citations.

[Complete related work section follows]
```

### Example 3: Choosing Results

**Passive (BAD):**
```
Which experimental results should I include in the paper? Should I
show all ablations or just the main ones?
```

**Proactive (GOOD):**
```
I've included experiments [A, B, C] in the main paper and moved
[detailed ablations] to the appendix. I highlighted results [X, Y]
as they best demonstrate the contribution.

Let me know if you'd prefer different emphasis or want to move
certain results to the main paper.

[Complete experiments section follows]
```

## Feedback Cycles

### First Draft → Feedback → Revision

**Cycle 1: Complete First Draft**
```
"Here's a complete first draft. I've organized it as [structure],
with contribution framed as [X]. Please review and let me know what
to adjust."

[Complete paper follows]
```

**Cycle 2: Address Feedback**
```
"I've revised based on your feedback:
- Updated contribution statement to [new framing]
- Added experiments [X, Y]
- Expanded related work to include [papers]
- Fixed citations [A, B]

What else should I adjust?"
```

**Cycle 3: Polish**
```
"I've polished the writing, improved transitions, and ensured all
citations are verified. Ready for final review?"

[Polished paper follows]
```

## Time Allocation

### Where to Spend Effort

**From Neel Nanda:** Spend approximately **equal time** on each of:

1. The abstract
2. The introduction
3. The figures
4. Everything else combined

**Why?** Most reviewers form judgments before reaching your methods.

**Reader encounter order:**
```
title → abstract → introduction → figures → maybe the rest
```

**Implication:** If your abstract and intro don't hook reviewers, they may never read your brilliant methods section.

## Common Mistakes to Avoid

### Mistake 1: Asking Too Many Questions

```
❌ "Should I use 'we propose' or 'we introduce'?"
❌ "Is this sentence too long?"
❌ "Should I put this figure before or after that paragraph?"

✅ Make reasonable choices and flag for review
```

### Mistake 2: Blocking on Minor Decisions

```
❌ Stopping writing to ask about section ordering
❌ Waiting for feedback before writing next section
❌ Leaving sections incomplete "pending approval"

✅ Make reasonable choices, continue, flag for review
```

### Mistake 3: Not Delivering Complete Drafts

```
❌ Sending fragments section by section
❌ Asking for approval before continuing
❌ Never presenting a complete picture

✅ Deliver complete drafts, then iterate
```

### Mistake 4: Ignoring Genuine Uncertainty

```
❌ Assuming contribution framing when unclear
❌ Making up results to fill gaps
❌ Guessing about experimental details

✅ Flag genuine uncertainties, ask targeted questions
```

## Sources

**Primary Source:**
- Neel Nanda: [Highly Opinionated Advice on How to Write ML Papers](https://www.alignmentforum.org/posts/eJGptPbbFPZGLpjsp/highly-opinionated-advice-on-how-to-write-ml-papers)

**Related:**
- Sebastian Farquhar: [How to Write ML Papers](https://sebastianfarquhar.com/on-research/2024/11/04/how_to_write_ml_papers/)
- OpenAI research team practices (collaborative writing)

## Summary

1. **Be proactive**: Deliver complete drafts, then iterate
2. **Ask with the draft**: Present questions alongside complete content
3. **Flag uncertainties**: Note specific areas needing input
4. **Make reasonable choices**: Don't block on minor decisions
5. **Understand the project**: Explore repo thoroughly before writing
6. **Clarify contribution**: Verify narrative with scientist
7. **Iterate efficiently**: Quick feedback cycles, not slow approvals

**Remember: Scientists are busy. Deliver something concrete they can react to, not questions they need to answer.**
