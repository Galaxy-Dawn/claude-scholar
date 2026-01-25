# The Narrative Principle for ML Papers

## The Single Most Critical Insight

**Your paper is not a collection of experiments—it's a story with one clear contribution supported by evidence.**

Every successful ML paper centers on what Neel Nanda calls **"the narrative"**: a short, rigorous, evidence-based technical story with a takeaway readers care about.

> "A paper is a short, rigorous, evidence-based technical story with a takeaway readers care about."
> — Neel Nanda (Google DeepMind)

## The Three Pillars

**Every successful paper must have these three pillars crystal clear by the end of the introduction:**

| Pillar | Description | Example |
|--------|-------------|---------|
| **The What** | 1-3 specific novel claims within cohesive theme | "We prove that X achieves Y under condition Z" |
| **The Why** | Rigorous empirical evidence supporting claims | Strong baselines, experiments distinguishing hypotheses |
| **The So What** | Why readers should care | Connection to recognized community problems |

**If you cannot state your contribution in one sentence, you don't yet have a paper.**

## The What: Clear Novel Claims

### Characteristics of Good Claims

**Specific, not vague:**
```
❌ "We improve upon existing methods."
✅ "We demonstrate that sparse autoencoders can extract 95% of
   interpretable features from language models while using 10× less
   compute than previous approaches."
```

**Novel, not incremental:**
```
❌ "We combine method A and method B."
✅ "We introduce a novel architecture that combines the efficiency
   of A with the accuracy of B, achieving state-of-the-art results
   on X benchmark."
```

**Cohesive, not scattered:**
```
❌ "We contribute: (1) faster training, (2) better data augmentation,
   (3) improved optimizer, (4) new evaluation metric."
✅ "We introduce a unified framework for efficient training that
   jointly optimizes data augmentation and learning rate scheduling."
```

### One-Sentence Contribution Test

Before writing your paper, complete this sentence:

```
"We demonstrate that [WHAT] achieves [WHY], which matters because
[SO WHAT]."
```

**Example:**
```
"We demonstrate that contrastive learning on graph structure (WHAT)
achieves 15% better representation quality than node features alone
(WHY), which matters because it enables transfer learning across
graph domains without retraining (SO WHAT)."
```

## The Why: Rigorous Empirical Evidence

### What Counts as Evidence?

**Strong evidence:**
- Comparison to strong baselines (not just weak ones)
- Ablation studies showing component contributions
- Experiments that distinguish between hypotheses
- Statistical significance tests with proper methodology
- Multiple datasets/domains showing generality

**Weak evidence:**
- Only beating weak baselines
- No ablation studies
- Single dataset results
- No statistical analysis
- Cherry-picked results

### Designing Experiments for Evidence

**Each experiment must explicitly test a claim:**

```latex
% GOOD - explicit claim
Experiment 1 tests the hypothesis that sparse representations
improve generalization. We compare our method to dense baselines
on out-of-distribution test sets.

% BAD - no explicit claim
We evaluate our method on several datasets.
```

**Ablation study template:**
```
Ablation Study: Component Contributions

We ablate each component to measure its contribution:
- Full model: 92.1% accuracy
- Without component A: 87.3% (-4.8%)
- Without component B: 89.5% (-2.6%)
- Without both: 84.1% (-8.0%)

Component A contributes most to performance, particularly on
hard examples, while B provides consistent gains across all
datasets.
```

## The So What: Why It Matters

### Connecting to Community Problems

**Frame your contribution in terms of recognized problems:**

```
Existing Problem:
"Training large language models requires millions of dollars in
compute, limiting research to well-funded laboratories."

Our Contribution:
"We introduce efficient training techniques that reduce compute
requirements by 10×, democratizing access to LLM research."

So What:
"This enables researchers with limited resources to train and
study language models, accelerating progress in the field."
```

### Types of Impact

**Technical impact:**
- Enables new applications
- Achieves new state-of-the-art
- Provides theoretical insights
- Solves long-standing problem

**Societal impact:**
- Reduces computational barriers
- Improves safety/reliability
- Enables new use cases
- Addresses ethical concerns

**Scientific impact:**
- Advances understanding
- Provides new tools
- Challenges existing assumptions
- Opens new research directions

## Applying the Narrative Principle

### Step 1: Define Your Narrative

**Before writing, answer these questions:**

1. **What is the one sentence contribution?**
2. **What specific claims do you make?**
3. **What evidence supports each claim?**
4. **Why should the community care?**

### Step 2: Structure Around Narrative

**Organize your paper to tell the story:**

```
Introduction: Set up problem → Present narrative → Preview evidence
Methods: How you achieve the claim
Experiments: Evidence supporting the claim
Related Work: How your narrative fits into broader context
Conclusion: Restate narrative and its implications
```

### Step 3: Write with Narrative Focus

**Every section should support the narrative:**

```
Abstract: Summary of narrative (what, why, so what)
Introduction: Full narrative presentation
Methods: How narrative is achieved
Experiments: Evidence for narrative
Discussion: Interpret evidence through narrative lens
Conclusion: Restate narrative and future directions
```

## Common Narrative Mistakes

### Mistake 1: No Clear Narrative

```
❌ "We do A, B, C, D, and E. Here are results."

✅ "We introduce X, which achieves Y through mechanism Z. This
   matters because it enables [application]."
```

### Mistake 2: Narrative Doesn't Match Experiments

```
❌ Narrative: "Our method scales to large datasets."
   Experiments: Only tested on small datasets.

✅ Narrative: "Our method achieves state-of-the-art on benchmarks
   up to 1M samples."
   Experiments: Results on datasets from 10K to 1M samples.
```

### Mistake 3: Missing "So What"

```
❌ "We achieve 92% accuracy, 5% better than previous work."

✅ "We achieve 92% accuracy, 5% better than previous work, enabling
   real-world deployment where 90%+ accuracy is required for safety."
```

### Mistake 4: Too Many Claims

```
❌ "We contribute: 1) faster training, 2) better accuracy, 3) less
   memory, 4) interpretability, 5) theoretical analysis, 6) new
   benchmark, 7) open-source code."

✅ "We introduce efficient training that achieves state-of-the-art
   accuracy with 10× less compute, enabling practical deployment."
```

## Examples: Good vs Bad Narratives

### Example 1: Contrastive Learning

**Bad Narrative:**
```
"We propose a contrastive learning method. It achieves good results
on several datasets. We use ResNet-50 as backbone."
```

**Good Narrative:**
```
"We demonstrate that contrastive learning on graph structure (WHAT)
achieves 15% better representation quality than node features alone
(WHY), which matters because it enables transfer learning across
graph domains without retraining (SO WHAT)."
```

### Example 2: Model Compression

**Bad Narrative:**
```
"We compress neural networks using pruning. We evaluate on ImageNet
and CIFAR-10. Our method is fast."
```

**Good Narrative:**
```
"We introduce structured pruning that preserves 98% of accuracy
while reducing model size by 5× (WHAT), achieved through novel
pruning criteria that identify redundant neurons (WHY), enabling
deployment on edge devices with limited memory (SO WHAT)."
```

### Example 3: Attention Mechanisms

**Bad Narrative:**
```
"We study attention in transformers. We find that attention heads
have different roles. Some heads are more important than others."
```

**Good Narrative:**
```
"We show that 20% of attention heads contribute 80% of model
performance (WHAT), identified through a novel head importance
metric based on gradient flow (WHY), enabling efficient attention
pruning without accuracy loss (SO WHAT)."
```

## Testing Your Narrative

### The Abstract Test

Write your abstract. Does it clearly present:
- [ ] What you achieved
- [ ] How you achieved it (briefly)
- [ ] Why it works (evidence)
- [ ] Why it matters (impact)

### The Introduction Test

Read your introduction. Can you identify:
- [ ] One clear contribution statement
- [ ] 2-4 specific claims
- [ ] Preview of evidence
- [ ] Connection to broader impact

### The Title Test

Does your title reflect your narrative:
- [ ] Clear method or contribution
- [ ] Specific domain/application
- [ ] Follows NAME: Description pattern (64% of papers)

**Example:**
```
❌ "A Study of Contrastive Learning"
✅ "Contrastive Graph Representation Learning via Structure
   Encoding"
```

## Narrative Templates

### Template 1: Method-Achieves-Goal
```
We demonstrate that [METHOD] achieves [GOAL] through [MECHANISM],
enabling [APPLICATION].
```

**Example:**
```
We demonstrate that sparse autoencoders achieve interpretable
feature extraction through learned sparse representations, enabling
analysis of neural network internal representations.
```

### Template 2: Problem-Via-Solution
```
We address [PROBLEM] via [SOLUTION], achieving [RESULT].
```

**Example:**
```
We address catastrophic forgetting via continual learning with
memory replay, achieving 90% accuracy on all tasks without
retraining.
```

### Template 3: Framework-For-Application
```
We introduce [NAME], a framework for [APPLICATION] that achieves
[RESULT] through [MECHANISM].
```

**Example:**
```
We introduce GraphContrast, a framework for self-supervised graph
representation learning that achieves 15% improvement over
supervised methods through structure-based contrastive learning.
```

## Sources and Further Reading

**Primary Source:**
- Neel Nanda: [Highly Opinionated Advice on How to Write ML Papers](https://www.alignmentforum.org/posts/eJGptPbbFPZGLpjsp/highly-opinionated-advice-on-how-to-write-ml-papers)

**Related Sources:**
- Sebastian Farquhar: [How to Write ML Papers](https://sebastianfarquhar.com/on-research/2024/11/04/how_to_write_ml_papers/)
- Andrej Karpathy: [Recipe for Training Neural Networks](http://karpathy.github.io/2019/04/25/recipe/) (narrative focus)

## Summary

1. **One clear narrative**: What you achieved, why it works, why it matters
2. **Specific claims**: 2-4 concrete, novel contributions
3. **Strong evidence**: Rigorous experiments supporting each claim
4. **Clear impact**: Connection to community problems
5. **Consistent story**: Every section supports the narrative

**Remember: If you can't state your contribution in one sentence, you don't yet have a paper.**
