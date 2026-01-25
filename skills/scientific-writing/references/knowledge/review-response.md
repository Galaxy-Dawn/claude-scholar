# Review Response Knowledge Base

> Auto-updated by paper-miner agent
> Last updated: 2026-01-25
> Initial content from scientific-writing skill and ML conference best practices

---

## Addressing Technical Questions

### Strategy: Direct, Evidence-Based Responses
**Source:** ML Conference Best Practices
**Context:** Reviewers question methodology, results, or technical choices

**Key Principles:**
1. **Acknowledge the concern** first
2. **Provide evidence** from experiments or literature
3. **Be direct and specific**, avoid hedging
4. **Include additional analysis** if helpful (but don't overcommit)

**Example Template:**
```
Thank you for this insightful question.

[Direct answer to the question]

Our evidence for this comes from:
1. [Experimental result or citation]
2. [Additional analysis or comparison]
3. [Explanation of why our approach is valid]

We have added additional discussion in Section X to clarify this point.
```

**What Works:**
- Quantitative evidence ("We added experiments showing X% improvement")
- Literature support ("As noted by Smith et al. (2023), this approach...")
- Clear explanations without defensiveness
- Admitting limitations when appropriate

**What Doesn't Work:**
- Dismissing the concern ("This is beyond the scope")
- Vague promises ("We will look into this")
- Defensiveness ("The reviewer misunderstood...")
- Overcommitting to extensive new experiments

---

### Strategy: Handling Methodology Questions
**Source:** ML Conference Best Practices
**Context:** Reviewers question experimental setup, baselines, or metrics

**Key Principles:**
1. **Explain the rationale** behind your choices
2. **Provide ablation studies** if available
3. **Compare with alternatives** when relevant
4. **Clarify misconceptions** respectfully

**Example Template:**
```
We appreciate the opportunity to clarify our methodology.

[Rationale for the approach]
Comparison with alternative [method]:
- Our approach: [advantages]
- Alternative: [why we didn't choose it, or when it might be better]

We have added additional ablation studies in Table X to demonstrate...
```

---

### Strategy: Addressing Missing Baselines
**Source:** Common ML Conference Rebuttal Pattern
**Context:** Reviewers suggest additional comparisons

**Key Principles:**
1. **Acknowledge validity** of the suggestion
2. **Explain constraints** (time, compute, applicability)
3. **Add what's feasible** (even if limited)
4. **Discuss expected outcomes** based on literature

**Example Template:**
```
Thank you for suggesting this comparison. We agree that [baseline] is relevant.

[Explain why not originally included:
- Computational constraints
- Different problem setting
- Published after our submission]

We have added:
[Limited comparison or discussion based on available results/literature]

We believe our main claims still hold because [reasoning].
```

---

## Addressing Writing Issues

### Strategy: Clarity and Structure Improvements
**Source:** ML Conference Best Practices
**Context:** Reviewers find sections unclear, confusing, or poorly structured

**Key Principles:**
1. **Accept the feedback** graciously
2. **Specify exact changes** made
3. **Reorganize content** for better flow
4. **Add clarifying text** where needed

**Example Template:**
```
We appreciate the feedback on [section name].

Changes made to improve clarity:
1. [Specific change - restructured paragraph]
2. [Specific change - added definition]
3. [Specific change - moved content to appendix]

We have revised the section to better emphasize [main point].
```

**What Works:**
- Clear list of specific changes
- Page/line references when appropriate
- Before/after comparisons for major edits
- Honest acknowledgment of unclear writing

---

### Strategy: Expanding Limited Discussion
**Source:** Common ML Conference Rebuttal Pattern
**Context:** Reviewers want more depth on certain topics

**Key Principles:**
1. **Add substantive content** (not just promises)
2. **Include in main paper** if critical
3. **Use appendix** for supplementary details
4. **Cross-reference** new additions

**Example Template:**
```
Thank you for pointing out that this aspect needed more discussion.

We have expanded Section [X] to include:
- [Additional point 1 with details]
- [Additional point 2 with analysis]
- [Connection to related work]

We believe this expanded discussion better addresses [concern].
```

---

## Addressing Additional Experiments Requests

### Strategy: Selective and Strategic Acceptance
**Source:** ML Conference Best Practices
**Context:** Reviewers request new experiments or analyses

**Key Principles:**
1. **Prioritize requests** that best address concerns
2. **Decline politely** when requests are unreasonable
3. **Provide partial results** when full experiments aren't feasible
4. **Use literature** to support expected outcomes

**Example Template (Acceptance):**
```
Thank you for this suggestion. We agree that [experiment] would strengthen our claims.

We have conducted [experiment] with the following results:
[Summary of findings]

These results support our original conclusion that...
[Added discussion in Section Y]
```

**Example Template (Polite Decline):**
```
We appreciate the suggestion to [experiment].

Unfortunately, [explain constraint:
- Computational resources (would require X GPU-days)
- Data availability (dataset not publicly accessible)
- Time constraints (would require months of additional work)]

However, based on [related work/literature], we expect that...
[Provide theoretical discussion or limited analysis]

We have added discussion of this limitation in Section Z.
```

---

### Strategy: Managing Multiple Experiment Requests
**Source:** ML Conference Rebuttal Strategy
**Context:** Multiple reviewers request different experiments

**Key Principles:**
1. **Address highest-impact** requests first
2. **Group related requests** when possible
3. **Be transparent** about constraints
4. **Negotiate trade-offs** if needed

**Example Template:**
```
We received several suggestions for additional experiments. Given constraints, we prioritized:

Completed:
1. [Experiment A] - because [reason]
2. [Experiment B] - because [reason]

Not completed due to [constraints]:
- [Experiment C] - However, we added discussion based on [literature]

We believe these additions address the core concerns while remaining feasible.
```

---

## General Rebuttal Best Practices

### Do's ✅
- **Start with gratitude** ("Thank you for the thoughtful review")
- **Be specific** about changes made
- **Provide evidence** for claims
- **Admit limitations** honestly
- **Stay professional** even when frustrated
- **Reference specific comments** (e.g., "Reviewer 1, Comment 2")
- **Summarize major changes** at the beginning or end

### Don'ts ❌
- **Don't be defensive** ("The reviewer failed to understand...")
- **Don't dismiss concerns** ("This is not important...")
- **Don't overcommit** to infeasible work
- **Don't make promises** without following through
- **Don't argue** without evidence
- **Don't use vague responses** ("We will consider this...")
- **Don't ignore** any reviewer comment

---

## Rebuttal Structure Template

```markdown
# Rebuttal: [Paper Title]

## Summary of Changes
[Brief overview of major revisions - 2-3 sentences]

## Response to Reviewer 1

### Comment 1: [Brief summary]
Thank you for [feedback]. [Response]
→ Changes: [Specific modifications]

### Comment 2: [Brief summary]
[Response]
→ Changes: [Specific modifications]

## Response to Reviewer 2
[Continue for all reviewers...]

## Conclusion
We appreciate all feedback and believe these revisions have significantly strengthened the paper. The main improvements include:
1. [Major change 1]
2. [Major change 2]
3. [Major change 3]
```

---

## Common Phrases and Templates

### Opening
- "Thank you for this thoughtful review."
- "We appreciate the opportunity to clarify this point."
- "This is an excellent suggestion that has improved our paper."

### Agreeing
- "We agree with the reviewer that..."
- "This feedback helped us identify an important weakness."
- "We have incorporated this suggestion by..."

### Disagreeing Respectfully
- "While we understand the concern, we believe that..."
- "We respectfully disagree based on the following evidence..."
- "Our approach differs because..."

### Explaining Constraints
- "Due to computational constraints, we were unable to..."
- "This would require access to [resource] which is not available..."
- "Given the page limit, we expanded this discussion in the appendix..."

### Closing
- "We believe these revisions address all major concerns."
- "The paper has been significantly improved thanks to this feedback."
- "We hope the reviewers find these revisions satisfactory."

---

> **Note**: This knowledge base is continuously updated by the paper-miner agent as new papers and rebuttals are analyzed.
