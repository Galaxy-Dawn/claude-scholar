# Design Simplification Papers: Less Is More

**Source**: Kaiming He et al., "Exploring Plain Vision Transformer Backbones for Object Detection" (ViTDet, 2022)

**Paper Type**: Design simplification / Minimal adaptations paper

**Core Pattern**: Challenge design assumptions → Minimize changes → Surprising effectiveness → Fair comparison

---

## 1. Abstract Structure: The "Surprisingly" Framework

### Pattern: Conventional Practice → Simple Alternative → Unexpected Results

**Template**:
```markdown
Abstract:
1. [Context] Standard practice in [domain] is [conventional design]
2. [Challenge] With [new technology], this faces [challenges]
3. [Common Solution] Most work addresses this by [abandoning philosophy / adding complexity]
4. [Our Direction] We explore [different direction]: [minimal approach]
5. [Surprisingly 1] Surprisingly, we observe: (i) [simple finding 1]
   and (ii) [simple finding 2]
6. [Surprisingly 2] More surprisingly, [stronger claim under conditions]
7. [Implications] This enables [benefit] without [traditional requirement]
```

### ViTDet Abstract Example (annotated):

```latex
Modern object detectors consist of hierarchical backbone feature extractors
and detection-specific necks/heads (e.g., FPN, RPN).

With Vision Transformers (ViT) emerging as powerful backbones, their plain,
non-hierarchical nature poses challenges: How to address multi-scale objects?

One solution abandons the plain ViT philosophy, re-introducing hierarchical
designs (e.g., Swin).

We pursue a different direction: plain ViT backbones with minimal adaptations.

Surprisingly, we observe: (i) A simple feature pyramid from a single-scale map
is sufficient (without FPN), and (ii) Window attention without shifting is
sufficient (with a few propagation blocks).

More surprisingly, under some circumstances, our ViTDet can compete with
leading hierarchical detectors like Swin.

With MAE pre-training, ViTDet outperforms hierarchical counterparts,
especially for larger models.

This decouples pre-training from fine-tuning, maintaining independence of
upstream vs downstream tasks.
```

### Key Techniques:

1. **"Modern...consist of..."** - Establish conventional practice
2. **"With...emerging as..."** - New technology, new challenge
3. **"abandons the...philosophy"** - Critique common solutions
4. **"We pursue a different direction"** - Clear positioning
5. **"Surprisingly, we observe: (i)... and (ii)..."** - First surprise
6. **"More surprisingly..."** - Second, deeper surprise
7. **"under some circumstances"** - Measured claim
8. **"sufficient"** - Scientific (not "optimal")
9. **"without [common practice]"** - Negative emphasis

---

## 2. Introduction: The "Challenge Assumptions" Framework

### Pattern: Tradition → New Challenge → Common Compromise → Your Alternative → Philosophy

**Structure**:
```markdown
1. [Traditional Practice] Established design in [field]
2. [Evolution] How this emerged historically ("For a long while...")
3. [New Challenge] [New technology] with [different characteristics]
4. [Philosophy Clash] Original [tech] has "'minimalist' pursuit"
   - Questions: "How can we...?" "Is [X] too inefficient?"
5. [Common Solution] One solution: [abandon philosophy] → [revert to old design]
   - Acknowledge: "has shown successful results"
6. [Your Direction] "we pursue a different direction"
   - Motivation: "If successful, enables [benefit]"
7. [Philosophy] "in part follows the [philosophy] of '[concept]'"
8. [Surprising Findings] "Surprisingly, we observe..."
9. [Implications] "More surprisingly..." → Competitive results
```

### ViTDet Introduction Flow:

#### Traditional Practice (Establish Context)
```latex
Modern object detectors in general consist of a backbone feature extractor
that is agnostic to the detection task and a set of necks and heads that
incorporate detection-specific prior knowledge.

Common components in the necks/heads may include Region-of-Interest (RoI)
operations, Region Proposal Networks (RPN) or anchors, Feature Pyramid
Networks (FPN), etc.
```

**Technique**:
- **"in general consist of"** - Standard architecture
- **"agnostic to"** vs **"detection-specific"** - Clear division
- **"may include"** - Examples, not exhaustive

#### Historical Evolution
```latex
For a long while, these backbones have been multi-scale, hierarchical
architectures due to the de facto design of convolutional networks (ConvNet),
which has heavily influenced the neck/head design for detecting objects at
multiple scales (e.g., FPN).
```

**Technique**:
- **"For a long while"** - Historical dimension
- **"due to...which has heavily influenced"** - Causal chain
- **"de facto design"** - Established convention

#### New Technology Challenge
```latex
Over the past year, Vision Transformers (ViT) have been established as a
powerful backbone for visual recognition.

Unlike typical ConvNets, the original ViT is a plain, non-hierarchical
architecture that maintains a single-scale feature map throughout.

Its 'minimalist' pursuit is met with challenges when applied to object
detection—e.g., How can we address multi-scale objects in a downstream task
with a plain backbone from upstream pre-training? Is a plain ViT too
inefficient to use with high-resolution detection images?
```

**Technique**:
- **"Over the past year...have been established as"** - Timeframe
- **"Unlike typical ConvNets"** - Direct contrast
- **"plain, non-hierarchical"**, **"single-scale"** - Key characteristics
- **"'minimalist' pursuit"** - Philosophy (in quotes)
- **Two questions**: Challenge reader to think

#### Common Solution (Acknowledge then Pivot)
```latex
One solution, which abandons this pursuit, is to re-introduce hierarchical
designs into the backbone.

This solution, e.g., Swin Transformers and related works, can inherit the
ConvNet-based detector design and has shown successful results.
```

**Technique**:
- **"which abandons this pursuit"** - Critique (respectful)
- **"can inherit"** - Acknowledge advantage
- **"has shown successful results"** - Don't deny effectiveness

#### Your Different Direction
```latex
In this work, we pursue a different direction: we explore object detectors
that use only plain, non-hierarchical backbones.

If this direction is successful, it will enable the use of original ViT
backbones for object detection; this will decouple the pre-training design
from the fine-tuning demands, maintaining the independence of upstream vs.
downstream tasks, as has been the case for ConvNet-based research.
```

**Technique**:
- **"we pursue a different direction"** - Clear positioning
- **"If this direction is successful, it will enable..."** - Motivation
- **"decouple"**, **"independence"** - Philosophy keywords
- **"as has been the case for..."** - Historical precedent

#### Philosophy Elevation
```latex
This direction also in part follows the ViT philosophy of 'fewer inductive
biases' in the pursuit of universal features.

As the non-local self-attention computation can learn translation-equivariant
features, they may also learn scale-equivariant features from certain forms
of supervised or self-supervised pre-training.
```

**Technique**:
- **"in part follows the...philosophy of"** - Theoretical connection
- **"fewer inductive biases"** - Core concept
- **Analogy**: translation-equivariant → scale-equivariant
- **"may also learn"** - Speculation (honest)

#### Surprising Findings
```latex
Surprisingly, we observe: (i) it is sufficient to build a simple feature
pyramid from a single-scale feature map (without the common FPN design) and
(ii) it is sufficient to use window attention (without shifting) aided with
very few cross-window propagation blocks.
```

**Technique**:
- **"Surprisingly, we observe:"** - Marker
- **(i)** and **(ii)** - Structured list
- **"sufficient to"** - Not "optimal", scientific phrasing
- **"without the common [X]"** - Negative differentiation

#### Deeper Surprise
```latex
More surprisingly, under some circumstances, our plain-backbone detector,
named ViTDet, can compete with the leading hierarchical-backbone detectors
(e.g., Swin, MViT).

With Masked Autoencoder (MAE) pre-training, our plain-backbone detector can
outperform the hierarchical counterparts that are pre-trained on ImageNet-1K/21K
with supervision (Figure 3).

The gains are more prominent for larger model sizes.
```

**Technique**:
- **"More surprisingly"** - Progressive emphasis
- **"under some circumstances"** - Measured claim
- **"named ViTDet"** - Brand at results
- **Specific comparison**: MAE vs ImageNet supervised
- **"The gains are more prominent for..."** - Pattern observation

---

## 3. Methods Section: The "Minimal Adaptations" Narrative

### Pattern: We Don't Aim to Invent, We Minimize

**Structure**:
```markdown
1. [Declaration] We do NOT aim to develop new components
2. [Philosophy] Instead, make minimal adaptations sufficient to overcome challenges
3. [Specific] In particular, [what we actually do]
4. [Abandonment] This abandons [traditional component]
5. [Decoupling] Adaptations only during fine-tuning, do not alter pre-training
6. [Contrast] This is in contrast to [recent methods] that [what they do]
7. [Benefit] Our scenario enables [benefit], without [cost]
```

### ViTDet Methods Narrative:

```latex
In our study, we do not aim to develop new components; instead, we make
minimal adaptations that are sufficient to overcome the aforementioned
challenges.

In particular, our detector builds a simple feature pyramid from only the
last feature map of a plain ViT backbone (Figure 1).

This abandons the FPN design and waives the requirement of a hierarchical
backbone.

These adaptations are made only during fine-tuning and do not alter pre-training.

This is in contrast to the recent methods that modify the attention computation
directly with backbone pre-training (e.g., Swin, MViT).

Our scenario enables us to use the original ViT backbone for detection, without
redesigning pre-training architectures.
```

**Techniques**:
- **"we do not aim to develop new components"** - Clear scope
- **"minimal adaptations"** - Philosophy
- **"sufficient to"** - Not maximal, necessary
- **"This abandons..."** - What you give up
- **"only during fine-tuning"** - Temporal boundary
- **"do not alter pre-training"** - Upstream independence
- **"This is in contrast to"** - Competitor positioning
- **"enables us to use"** - Practical benefit

---

## 4. Fair Comparison: The "Equal Effort" Declaration

### Pattern: Admit Complexity → Claim Effort → Demonstrate Fairness

**Structure**:
```markdown
1. [Admit] Modern systems involve [complexity]
2. [Claim] To compare as fairly as possible, we [effort]
3. [Specific 1] Use same [implementation] for all
4. [Specific 2] Different backbones get [appropriate treatment]
5. [Validation] Our results for [competitor] are [better/equal] to original
6. [Implication] Since we reproduce others well, comparisons are fair
```

### ViTDet Fair Comparison Statement:

```latex
Modern detection systems involve many implementation details and subtleties.

To focus on comparing backbones under as fair conditions as possible, we
incorporate the Swin and MViTv2 backbones into our implementation.

We use the same implementation of Mask R-CNN and Cascade Mask R-CNN for all
ViT, Swin, and MViTv2 backbones.

We use FPN for the hierarchical backbones of Swin/MViTv2.

We search for optimal hyper-parameters separately for each backbone.
```

**Techniques**:
- **"involve many implementation details and subtleties"** - Admit difficulty
- **"under as fair conditions as possible"** - Effort disclaimer
- **"incorporate...into our implementation"** - What we did
- **"use the same...for all"** - Unified framework
- **"search for optimal...separately"** - Equal effort

#### Self-Validation
```latex
Our Swin results are better than their counterparts in the original paper;
our MViTv2 results are better than or on par with those reported in the
original paper.
```

**Technique**:
- Report self-results → Show competence → Imply fairness

---

## 5. Results: Multi-Factor Analysis

### Pattern: Factors, Trends, Wall-Clock Time

**Structure**:
```markdown
1. [Acknowledge Complexity] Comparisons involve [factors]
2. [Identify Trend] Our method presents better [trend behavior]
3. [Qualify] When [condition], our method [advantage]
4. [Expand] Moreover, [second dimension advantage]
5. [Explain] as [reason related to simplicity]
```

### ViTDet Results Narrative:

```latex
Figure 3 plots the trade-offs.

The comparisons here involve two factors: the backbone and the pre-training
strategy.

Our plain-backbone detector, combined with MAE pre-training, presents better
scaling behavior.

When the models are large, our method outperforms the hierarchical
counterparts of Swin/MViTv2, including those using IN-21K supervised
pre-training.

Moreover, the plain ViT has a better wall-clock performance (Figure 3 right),
as the simpler blocks are more hardware-friendly.
```

**Techniques**:
- **"involve two factors"** - Analysis depth
- **"presents better scaling behavior"** - Trend, not just points
- **"When the models are large"** - Qualify claim
- **"Moreover"** - Second dimension
- **"better wall-clock performance"** - Practical metric
- **"simpler blocks are more hardware-friendly"** - Explain why

---

## 6. "Surprisingly" Usage: Multi-Level Pattern

### Level 1: Basic Surprise (Abstract)

```latex
Surprisingly, we observe: (i) [simple sufficient without common practice]
and (ii) [simple sufficient without common practice]
```

**Characteristics**:
- Two findings (i) and (ii)
- "sufficient" not "optimal"
- "without [common practice]"
- Structured presentation

### Level 2: Competitive Surprise (Introduction)

```latex
More surprisingly, under some circumstances, our [method] can compete
with the leading [competitors].
```

**Characteristics**:
- "More surprisingly" - Progressive
- "under some circumstances" - Measured
- "compete with" - Not "beat", competitive
- Name competitors specifically

### Level 3: Superiority Surprise (Introduction)

```latex
With [specific condition], our [method] can outperform the [competitors]
that use [stronger condition].

The gains are more prominent for [specific condition].
```

**Characteristics**:
- Specific conditions compared
- "outperform" - Stronger claim here
- Pattern observation: "more prominent for"
- Shows understanding of when/where

---

## 7. Ablation Study: Incremental + Destructive

### Pattern: Baseline → Incremental Additions → Sufficient

**Table Design**:
```markdown
Table X: [Component] Ablation
┌──────────────────────────────────────────┐
│ Baseline          | Metric  | Δ         │
├──────────────────────────────────────────┤
│ no [component]    | 47.8    | -         │
│ (a) [common]      | 50.3    | +2.5      │
│ (b) [variant]     | 50.9    | +3.1      │
│ (c) ours: simple  | 51.2    | +3.4 ✓   │
├──────────────────────────────────────────┤
│ Conclusion: Our simple [X] is sufficient  │
└──────────────────────────────────────────┘
```

### ViTDet Table 1 Example:

```latex
pyramid design              APbox   APmask
─────────────────────────────────────────
no feature pyramid          47.8    42.5
(a) FPN, 4-stage           50.3    44.9
(b) FPN, last-map          50.9    45.3
(c) simple feature pyramid  51.2    45.5
```

**Techniques**:
- **Baseline**: "no [X]" shows it's needed
- **(a), (b), (c)**: Progressive variations
- **Δ标注**: (+2.5) - Show incremental gains
- **Conclusion text**: "our simple pyramid is sufficient"

---

## 8. "Interestingly" Usage: Pattern + Explanation

### Pattern: Observation → Literature Support → Explanation

**Structure**:
```markdown
Interestingly, [observation].

This is in line with the observation in [paper] that [their finding].

[Additional explanation or hypothesis].
```

### ViTDet Example:

```latex
Interestingly, performing propagation in the last 4 blocks is nearly as
good as even placement.

This is in line with the observation in ViT [14] that ViT has longer
attention distance in later blocks and is more localized in earlier ones.
```

**Techniques**:
- **"Interestingly"** - Marker for unexpected
- **Observation**: Specific finding
- **"in line with the observation in"** - Literature support
- **Explanation**: Why it makes sense

---

## 9. Minimalism Keywords: Design Simplification Vocabulary

**Philosophy Keywords**:
- "minimal" - "minimal adaptations"
- "sufficient" - "is sufficient to" (not "optimal")
- "simple" - "simple feature pyramid"
- "plain" - "plain backbone"
- "decouple" - "decouple pre-training from fine-tuning"
- "independence" - "independence of upstream vs downstream"

**Direction Keywords**:
- "pursue a different direction" - Positioning
- "in contrast to" - Differentiation
- "abandons" - What you give up
- "enables" - What your approach allows

**Measured Claim Keywords**:
- "under some circumstances" - Not always
- "can compete with" - Competitive, not dominant
- "more prominent for" - When effect is stronger
- "is sufficient" - Necessary, not maximal

**Surprise Markers** (use in order):
1. "Surprisingly" - First finding
2. "More surprisingly" - Deeper finding
3. "Interestingly" - Pattern observation
4. "Notably" - Important detail
5. "It is worth noting that" - Caveat/clarification

---

## 10. Common Mistakes in Design Simplification Papers

### ❌ Don't:
- Claim your method is "optimal" - You're simplifying, not optimizing
- Attack common practices - Acknowledge their value first
- Overgeneralize - "under some circumstances" is honest
- Forget to show fair comparison - Prove you tried hard with baselines
- Hide complexity - Admit what you don't address

### ✅ Do:
- Use "sufficient" instead of "optimal"
- Say what you DON'T do ("do not aim to develop new components")
- Emphasize minimal changes ("minimal adaptations")
- Report when your method wins and when it doesn't
- Show "surprisingly" findings with proper qualification
- Demonstrate fair comparison effort
- Adapt only where necessary (fine-tuning, not pre-training)

---

## 11. Revision Checklist for Design Simplification Papers

**Before Submission, Verify:**

- [ ] Abstract has "Surprisingly, we observe: (i)... and (ii)..."
- [ ] Introduction establishes conventional practice first
- [ ] Common solution is acknowledged ("has shown successful results")
- [ ] "We pursue a different direction" is stated clearly
- [ ] Philosophy is elevated ("fewer inductive biases")
- [ ] "More surprisingly" used for deeper claim
- [ ] Methods section says "we do not aim to develop new components"
- [ ] "minimal adaptations" philosophy stated
- [ ] "only during fine-tuning" boundary specified
- [ ] Fair comparison effort described explicitly
- [ ] Self-validation shown (our reproduction of others is good)
- [ ] Multi-factor analysis in results (scaling, wall-clock)
- [ ] Ablations show incremental progression
- [ ] "sufficient" used, not "optimal"
- [ ] Under what conditions is stated ("under some circumstances")

---

## 12. Example: Applying This Pattern

### Original Idea (Not Design Simplification):
"We propose a new feature pyramid that improves detection AP by 3%."

### Design Simplification Version:
"Modern detectors use hierarchical backbones with FPN. With plain ViT
emerging as powerful backbones, a common solution re-introduces hierarchy
(abandoning the plain philosophy). We pursue a different direction: plain
backbones with minimal adaptations. Surprisingly, we observe a simple feature
pyramid from a single-scale map is sufficient (without FPN). More
surprisingly, with MAE pre-training, ViTDet competes with hierarchical
detectors, especially for larger models. This decouples pre-training from
fine-tuning, maintaining upstream/downstream independence."

**The Design Simplification Frame**:
- Conventional: Hierarchy + FPN
- Challenge: Plain ViT is...plain
- Common: Swin (abandons philosophy)
- Ours: Minimal adaptations
- Surprise: Simple is sufficient
- Philosophy: Decoupling, independence

---

## Paper Metadata

**Title**: Exploring Plain Vision Transformer Backbones for Object Detection (ViTDet)

**Authors**: Yanghao Li, Hanzi Mao, Kaiming He

**Venue**: ECCV 2022

**arXiv**: 2203.16527

**Key Concepts**:
- Plain ViT for detection (no hierarchy needed)
- Simple feature pyramid (no FPN needed)
- Minimal adaptations philosophy
- Decoupling pre-training from fine-tuning
- MAE pre-training synergy

---

## Extracted by

**Date**: 2026-01-26

**Source**: Analysis of ViTDet paper (21 pages)

**Extraction Focus**: Design simplification paper writing patterns, "surprisingly"
findings reporting, minimal adaptations philosophy, fair comparison strategies

**For Integration**: ml-paper-writing skill knowledge base
