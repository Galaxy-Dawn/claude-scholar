# ML Writing Philosophy: Principles from Top Researchers

## Overview

This document synthesizes writing philosophy from researchers who have published extensively at top ML venues (NeurIPS, ICML, ICLR, etc.). These aren't optional style suggestions—they're what separates accepted papers from rejected ones.

## The Sources Behind This Guidance

This skill synthesizes writing philosophy from researchers who have published extensively at top venues:

| Source | Key Contribution | Link |
|--------|-----------------|------|
| **Neel Nanda** (Google DeepMind) | The Narrative Principle, What/Why/So What framework | [How to Write ML Papers](https://www.alignmentforum.org/posts/eJGptPbbFPZGLpjsp/highly-opinionated-advice-on-how-to-write-ml-papers) |
| **Sebastian Farquhar** (DeepMind) | 5-sentence abstract formula | [How to Write ML Papers](https://sebastianfarquhar.com/on-research/2024/11/04/how_to_write_ml_papers/) |
| **Gopen & Swan** | 7 principles of reader expectations | [Science of Scientific Writing](https://cseweb.ucsd.edu/~swanson/papers/science-of-writing.pdf) |
| **Zachary Lipton** | Word choice, eliminating hedging | [Heuristics for Scientific Writing](https://www.approximatelycorrect.com/2018/01/29/heuristics-technical-scientific-writing-machine-learning-perspective/) |
| **Jacob Steinhardt** (UC Berkeley) | Precision, consistent terminology | [Writing Tips](https://bounded-regret.ghost.io/) |
| **Ethan Perez** (Anthropic) | Micro-level clarity tips | [Easy Paper Writing Tips](https://ethanperez.net/easy-paper-writing-tips/) |
| **Andrej Karpathy** | Single contribution focus | Various lectures |

## Time Allocation (From Neel Nanda)

**Spend approximately equal time on each of:**

1. The abstract
2. The introduction
3. The figures
4. Everything else combined

**Why?** Most reviewers form judgments before reaching your methods.

**Reader encounter order:**
```
title → abstract → introduction → figures → maybe the rest
```

**Bottom line:** If your abstract and intro don't hook reviewers, they may never read your brilliant methods section.

## Writing Style Guidelines

### Sentence-Level Clarity (Gopen & Swan's 7 Principles)

**These principles are based on how readers actually process prose.** Violating them forces readers to spend cognitive effort on structure rather than content.

| Principle | Rule | Example |
|-----------|------|---------|
| **Subject-verb proximity** | Keep subject and verb close | ❌ "The model, which was trained on..., achieves" → ✅ "The model achieves... after training on..." |
| **Stress position** | Place emphasis at sentence ends | ❌ "Accuracy improves by 15% when using attention" → ✅ "When using attention, accuracy improves by **15%**" |
| **Topic position** | Put context first, new info after | ✅ "Given these constraints, we propose..." |
| **Old before new** | Familiar info → unfamiliar info | Link backward, then introduce new |
| **One unit, one function** | Each paragraph makes one point | Split multi-point paragraphs |
| **Action in verb** | Use verbs, not nominalizations | ❌ "We performed an analysis" → ✅ "We analyzed" |
| **Context before new** | Set stage before presenting | Explain before showing equation |

### Principle 1: Subject-Verb Proximity

**Readers expect subject and verb close together.**

```
❌ BAD: The model, which was trained on millions of examples using
       a novel optimization strategy that combines adaptive learning
       rates with momentum, achieves state-of-the-art performance.

✅ GOOD: The model achieves state-of-the-art performance after
       training on millions of examples using a novel optimization
       strategy that combines adaptive learning rates with momentum.
```

### Principle 2: Stress Position

**Place important information at sentence ends.**

```
❌ BAD: When using attention, accuracy improves by 15%, which is
       a significant result.

✅ GOOD: When using attention, accuracy improves by **15%**,
       demonstrating the importance of the attention mechanism.
```

### Principle 3: Topic Position

**Start sentences with familiar context.**

```
❌ BAD: Our proposed method achieves 92% accuracy.

✅ GOOD: Given the limitations of existing methods, our proposed
       approach achieves 92% accuracy.
```

### Principle 4: Old Before New

**Link to familiar information before introducing new concepts.**

```
❌ BAD: Sparse autoencoders extract interpretable features. This
       enables better understanding of neural networks.

✅ GOOD: Interpretable features are essential for understanding
       neural networks. Sparse autoencoders extract such features
       from trained models.
```

### Principle 5: One Unit, One Function

**Each paragraph should make one main point.**

```
❌ BAD: Our method has three advantages. First, it is faster.
       Second, it uses less memory. Third, it achieves better
       accuracy. We evaluate on three datasets. Dataset A shows...

✅ GOOD: Our method has three advantages. First, it is faster than
       baselines, reducing training time by 50%.

       Second, it uses less memory, enabling deployment on resource-
       constrained devices.

       Third, it achieves better accuracy across all evaluated
       datasets.
```

### Principle 6: Action in Verb

**Use strong verbs, not nominalizations.**

```
❌ "We performed an analysis"
✅ "We analyzed"

❌ "We conducted an investigation"
✅ "We investigated"

❌ "We made a determination"
✅ "We determined"
```

### Principle 7: Context Before New

**Provide context before presenting new information (equations, results, etc.).**

```
❌ BAD: \[ L(\theta) = \sum_{i=1}^{n} \log p_\theta(x_i) \]

       We optimize this objective using gradient descent.

✅ GOOD: We optimize the model parameters by maximizing the
       log-likelihood of the training data:

       \[ L(\theta) = \sum_{i=1}^{n} \log p_\theta(x_i) \]

       We optimize this objective using gradient descent.
```

## Micro-Level Tips (Ethan Perez)

**These small changes accumulate into significantly clearer prose:**

### Minimize Pronouns

```
❌ "This shows that the method is effective."
✅ "This result shows that the method is effective."

❌ "It achieves 92% accuracy."
✅ "The model achieves 92% accuracy."
```

### Put Verbs Early

```
❌ "In this paper, we demonstrate that..."
✅ "We demonstrate that..."

❌ "For the experiments, we used..."
✅ "We used..."
```

### Unfold Apostrophes (When Awkward)

```
❌ "The model's performance improved."
✅ "The performance of the model improved."

❌ "The method's advantages include..."
✅ "The advantages of the method include..."
```

**Note:** Don't overdo this. "X's Y" is fine when natural.

### Delete Filler Words

**Remove these words:**
- "actually"
- "a bit"
- "very"
- "really"
- "basically"
- "quite"
- "essentially"
- "somewhat"

```
❌ "The model actually achieves quite good performance."
✅ "The model achieves strong performance."

❌ "It's basically a bit faster than the baseline."
✅ "It's faster than the baseline."
```

## Word Choice (Zachary Lipton)

### Be Specific

```
❌ "The performance improves."
✅ "The accuracy improves." OR "The latency decreases."

❌ "We achieve good results."
✅ "We achieve 92% accuracy."
```

**Say what you mean.** Generic terms like "performance" and "results" obscure meaning.

### Eliminate Hedging

```
❌ "Our method may improve accuracy."
✅ "Our method improves accuracy."

❌ "This could potentially lead to better results."
✅ "This leads to better results."
```

**Use "may" and "can" only when genuinely uncertain.**

### Avoid Incremental Vocabulary

```
❌ "We combine method A and method B."
✅ "We integrate method A and method B."

❌ "We modify the existing approach."
✅ "We improve the existing approach."

❌ "We expand on prior work."
✅ "We build on prior work."
```

**Strong verbs:** develop, propose, introduce, achieve, demonstrate, show

**Weak verbs:** combine, modify, expand, attempt, try

### Delete Intensifiers

```
❌ "provides very tight approximation"
✅ "provides tight approximation"

❌ "extremely good performance"
✅ "excellent performance" OR "strong performance"
```

**If the result is good, say it's good. If it's not, find something else to praise.**

## Precision Over Brevity (Jacob Steinhardt)

### Consistent Terminology

**Different terms for same concept create confusion.**

```
❌ "Our method uses sparse representations. The sparsity enables...
     We leverage sparse coding. The sparse approach..."

✅ "Our method uses sparse representations. The sparsity enables...
     We leverage this representation. The sparse approach..."
```

**Pick one term and stick with it throughout the paper.**

### State Assumptions Formally

**Before theorems, list all assumptions explicitly.**

```
❌ We prove that the algorithm converges.

✅ We prove that the algorithm converges under the following
   assumptions:
   1. The objective function is convex
   2. The learning rate is sufficiently small
   3. The gradient is Lipschitz continuous

   Theorem 1: Under assumptions 1-3, the algorithm converges...
```

### Intuition + Rigor

**Provide intuitive explanations alongside formal proofs.**

```
✅ Intuitively, the sparse representation ensures that each feature
   is captured by only a few neurons, making the model more
   interpretable.

   Formally, we prove that sparsity implies...
```

## Abstract Writing (Sebastian Farquhar's 5-Sentence Formula)

**Every ML conference abstract should follow this structure:**

1. **What you achieved:** "We introduce...", "We prove...", "We demonstrate..."
2. **Why this is hard and important**
3. **How you do it** (with specialist keywords for discoverability)
4. **What evidence you have**
5. **Your most remarkable number/result**

**Example:**

```
(1) We introduce a contrastive learning framework for graph
    representation learning that achieves 15% improvement over
    supervised methods. (2) Graph structure is difficult to
    leverage effectively due to the lack of natural data
    augmentation strategies. (3) Our method learns representations
    by contrasting node neighborhoods across multiple views of
    the graph, using a novel graph-specific augmentation strategy.
    (4) We demonstrate state-of-the-art results on 5 benchmark
    datasets. (5) Our method achieves 92.1% accuracy on the
    largest dataset, 15% better than the previous best approach.
```

**Delete generic openings:** "Large language models have achieved remarkable success..." (could apply to any LLM paper)

## What Reviewers Actually Read

**Understanding reviewer behavior helps prioritize effort:**

| Paper Section | % Reviewers Who Read | Implication |
|---------------|---------------------|-------------|
| Abstract | 100% | Must be perfect |
| Introduction | 90%+ (skimmed) | Front-load contribution |
| Figures | Examined before methods | Figure 1 is critical |
| Methods | Only if interested | Don't bury the lede |
| Appendix | Rarely | Put only supplementary details |

**Implication:** Invest heavily in abstract, introduction, and figures.

## Common Writing Mistakes

### Mistake 1: Generic Opening

```
❌ "Deep learning has achieved remarkable success in computer
   vision."

✅ "We introduce a novel architecture that reduces the computational
   cost of vision transformers by 10× while maintaining accuracy."
```

### Mistake 2: Vague Claims

```
❌ "Our method achieves good results."
✅ "Our method achieves 92.1% accuracy, 15% better than the
   previous state-of-the-art."

❌ "We demonstrate effectiveness on several datasets."
✅ "We demonstrate state-of-the-art results on 5 benchmark
   datasets, ranging from 10K to 10M samples."
```

### Mistake 3: Missing Signposting

```
❌ [Proceeds directly into detailed method description]

✅ "We begin by introducing our method (Section 3), then describe
   the experimental setup (Section 4), and present results
   (Section 5)."
```

### Mistake 4: Inconsistent Terminology

```
❌ "Our model uses sparse representations. The sparsity enables...
     We leverage sparse coding. The sparse approach..."

✅ "Our model uses sparse representations. The sparsity enables...
     We leverage these representations. The approach..."
```

## Summary Checklist

Before submitting:

**Abstract:**
- [ ] Follows 5-sentence formula
- [ ] States specific achievement
- [ ] Includes most remarkable number
- [ ] No generic opening

**Introduction:**
- [ ] Clear contribution statement
- [ ] 2-4 bullet contributions
- [ ] Preview of evidence
- [ ] Connection to broader impact

**Methods:**
- [ ] Reproducible descriptions
- [ ] All hyperparameters listed
- [ ] Clear notation

**Experiments:**
- [ ] Each experiment tests a claim
- [ ] Strong baselines compared
- [ ] Ablation studies included
- [ ] Statistical analysis

**Writing:**
- [ ] Subject-verb proximity maintained
- [ ] Stress position used for emphasis
- [ ] Consistent terminology
- [ ] No filler words
- [ ] Specific, not vague

## Sources and Further Reading

**Primary Sources:**
- Neel Nanda: [Highly Opinionated Advice on How to Write ML Papers](https://www.alignmentforum.org/posts/eJGptPbbFPZGLpjsp/highly-opinionated-advice-on-how-to-write-ml-papers)
- Sebastian Farquhar: [How to Write ML Papers](https://sebastianfarquhar.com/on-research/2024/11/04/how_to_write_ml_papers/)
- Gopen & Swan: [The Science of Scientific Writing](https://cseweb.ucsd.edu/~swanson/papers/science-of-writing.pdf)
- Zachary Lipton: [Heuristics for Scientific Writing](https://www.approximatelycorrect.com/2018/01/29/heuristics-technical-scientific-writing-machine-learning-perspective/)
- Jacob Steinhardt: [Writing Tips](https://bounded-regret.ghost.io/)
- Ethan Perez: [Easy Paper Writing Tips](https://ethanperez.net/easy-paper-writing-tips/)

**See also:**
- `narrative_principle.md` - The What/Why/So What framework
- `collaborative_writing.md` - Proactive drafting philosophy
- `anti_ai_writing.md` - Avoiding AI-like patterns
