# Theory-Driven Papers: From First Principles

**Source**: Kaiming He et al., "Mean Flows for One-step Generative Modeling" (2025)

**Paper Type**: Theory-driven / First-principles paper

**Core Pattern**: Start from first principles → Derive theory → Build method → Demonstrate superiority

---

## 1. Abstract Structure: The "Principle Introduction" Framework

### Pattern: From Theory to Results

**Template**:
```markdown
Abstract:
1. [Background] Established framework provides [foundation]
2. [Problem] Recent research focuses on [challenge], but existing methods have [limitation]
3. [Critique] Despite encouraging results, [specific problem with prior approaches]
4. [Core Concept] We introduce [new concept], in contrast to [old concept]
5. [Theory] Solely from definition, we derive [theoretical foundation]
6. [Advantage] This provides [principled basis] vs [heuristic approaches]
7. [Results] Achieves [strong result] - [relative improvement] over SOTA
8. [Significance] Self-contained, [independence from external components]
```

### MeanFlows Abstract Example (annotated):

```latex
Flow Matching provides an intuitive and conceptually simple framework for
constructing flow paths that transport one distribution to another.

Recent research has paid significant attention to few-step—and in
particular, one-step, feedforward—generative models.

Despite encouraging results, the consistency constraint is imposed as a
property of the network's behavior, while the properties of the underlying
ground-truth field that should guide learning remain unknown.

The core idea is to introduce a new ground-truth field representing the
average velocity, in contrast to the instantaneous velocity typically
modeled in Flow Matching.

Solely originated from this definition, we derive a well-defined, intrinsic
relation between the average and instantaneous velocities, which naturally
serves as a principled basis for guiding network training.

Our method achieves an FID of 3.43 using 1-NFE generation, significantly
outperforming previous state-of-the-art methods by a relative margin of 50%
to 70%.

It is trained entirely from scratch, without any pre-training, distillation,
or curriculum learning.
```

### Key Techniques:

1. **"Provides an intuitive and conceptually simple framework"** - Light touch introduction
2. **"Recent research has paid significant attention to..."** - Establish context
3. **"Despite encouraging results..."** - The critique pattern (acknowledge then problem)
4. **"The core idea is to introduce..."** - Clear concept statement
5. **"in contrast to"** - Conceptual differentiation
6. **"Solely originated from this definition"** - First-principles emphasis
7. **"well-defined, intrinsic relation"** - Theory keywords
8. **"naturally serves as a principled basis"** - Naturalness emphasis
9. **Relative improvement (50-70%)** - More impactful than absolute numbers
10. **Negative list** - What you DON'T need (pre-training, distillation, curriculum)

---

## 2. Introduction: The "Critique-First" Framework

### Pattern: Build Up → Identify Flaw → Propose Alternative

**Structure**:
```markdown
1. [Background] Established field with [characteristic]
2. [Problem Shift] Research focus has moved to [new direction]
3. [Specific Problem] Existing approaches address this by [method]
4. [The Critique] Despite [acknowledgment], [fundamental problem]
   - "imposed as a property of [X]"
   - "[Y] remains unknown"
5. [Consequences] Consequently, [practical problems]
6. [Your Concept] We propose [alternative] with [differentiation]
7. [Theory] From [first principles], we derive [result]
8. [Advantage] This is [principled/natural/intrinsic] vs [heuristic/artificial]
9. [Results] [Quantitative result] with [qualitative advantage]
```

### MeanFlows Introduction Flow:

#### Background (Light Touch)
```latex
Flow Matching provides an intuitive and conceptually simple framework
for constructing flow paths that transport one distribution to another.
```

**Technique**:
- "intuitive and conceptually simple" - Modest, not revolutionary
- Focus on what it IS, not how important it is

#### Problem Shift
```latex
Closely related to diffusion models, Flow Matching focuses on the velocity
fields that guide model training.

Both Flow Matching and diffusion models perform iterative sampling during
generation. Recent research has paid significant attention to few-step
—and in particular, one-step, feedforward—generative models.
```

**Technique**:
- "Closely related to" - Establish connection
- "Recent research has paid significant attention to" - Research trend
- "few-step—and in particular, one-step" - Progressive emphasis

#### The Critique (Key Pattern)
```latex
Consistency Models [46, 43, 15, 31] achieve few-step generation by enforcing
a consistency constraint on the velocity field.

Despite encouraging results, the consistency constraint is imposed as a
property of the network's behavior, while the properties of the underlying
ground-truth field that should guide learning remain unknown.

Consequently, training can be unstable and requires a carefully designed
'discretization curriculum' to progressively constrain the time domain.
```

**Technique**:
- **"Despite encouraging results"** - Always acknowledge first
- **"imposed as a property of the network's behavior"** - It's artificial
- **"underlying ground-truth field...remain unknown"** - Missing theory
- **"Consequently"** - Show practical consequences
- **Specific problems**: "training can be unstable", "requires...curriculum"

#### Your Concept
```latex
The core idea is to introduce a new ground-truth field representing the
average velocity, in contrast to the instantaneous velocity typically
modeled in Flow Matching.
```

**Technique**:
- **"The core idea is to introduce"** - Direct statement
- **"in contrast to"** - Conceptual differentiation
- **Old vs New**: "average velocity" vs "instantaneous velocity"

#### Theory First
```latex
Average velocity is defined as the ratio of displacement to a time interval,
with displacement given by the time integral of the instantaneous velocity.

Solely originated from this definition, we derive a well-defined, intrinsic
relation between the average and instantaneous velocities, which naturally
serves as a principled basis for guiding network training.
```

**Technique**:
- **"Solely originated from this definition"** - Pure derivation
- **"well-defined, intrinsic relation"** - Theory keywords
- **"naturally serves as"** - Not forced
- **"principled basis"** - Foundation

---

## 3. Methods Section: The "Named Identity" Pattern

### Pattern: Define → Derive → Name

**Structure**:
```markdown
1. [Concept Name] Define with formal notation
2. [Motivation] Explain why we need this
3. [Derivation] Step-by-step with justifications
4. [Naming] Give it a memorable name
5. [Comparison] Contrast with prior approaches
```

### MeanFlows Example:

#### Step 1: Concept Naming
```latex
Average Velocity. We define average velocity as the displacement between
two time steps t and r (obtained by integration) divided by the time interval.

Formally, the average velocity u is:

u(zt, r, t) ≜ 1/(t−r) ∫_r^t v(zτ, τ)dτ.    (3)
```

**Techniques**:
- **Bold heading**: "Average Velocity." - Makes it memorable
- **Text description first**: Explain before formula
- **"Formally,"**: Signals math coming
- **≜ symbol**: "defined as" (clearer than =)

#### Step 2: Derivation with Motivation
```latex
To have a formulation amenable to training, we rewrite Eq. (3) as:

(t−r)u(zt, r, t) = ∫_r^t v(zτ, τ)dτ.    (4)

Now we differentiate both sides with respect to t, treating r as independent
of t. This leads to:

d/dt(t−r)u = d/dt∫_r^t v(zτ, τ)dτ

⇒ u + (t−r)d/dt u = v(zt, t),    (5)

where the manipulation of the left hand side employs the product rule and
the right hand side uses the fundamental theorem of calculus.
```

**Techniques**:
- **"To have a formulation amenable to training"** - Explain why
- **"Now we differentiate..."** - Guide reader
- **Step-by-step**: Don't skip
- **"where..."**: Explain each manipulation
- **"⇒" symbol**: Clear direction

#### Step 3: Naming the Identity
```latex
Rearranging terms, we obtain the identity:

u(zt, r, t) = v(zt, t) − (t−r)d/dt u(zt, r, t)    (6)

We refer to this equation as the "MeanFlow Identity", which describes the
relation between v and u.
```

**Techniques**:
- **"Rearranging terms, we obtain..."** - What you did
- **"We refer to this equation as the 'X Identity'"** - Brand it
- **Explain**: "which describes..." - What it does

---

## 4. Comparison: Principled vs Heuristic

### Pattern: Emphasize Theoretical Independence

**Structure**:
```markdown
1. [Your Core] At the core of our method is [fundamental principle]
2. [Independence] This [does not depend on / is independent of] [implementation]
3. [Contrast] In contrast, prior works typically rely on [heuristic/artificial constraint]
4. [Qualitative] [Natural/principled/intrinsic] vs [imposed/empirical/heuristic]
```

### MeanFlows Example:

```latex
At the core of our method is the functional relationship between two
underlying fields v and u, which naturally leads to the MeanFlow Identity
that u must satisfy (Eq. (6)).

This identity does not depend on the introduction of neural networks.

In contrast, prior works typically rely on extra consistency constraints,
imposed on the behavior of the neural network.
```

**Techniques**:
- **"At the core of our method is..."** - What matters
- **"naturally leads to"** - Not forced
- **"does not depend on"** - Independence
- **"In contrast"** - Clear pivot
- **"imposed on"** - Theirs is artificial

### Specific Method Comparison

```latex
Consistency Models [46, 43, 15, 31] are focused on paths anchored at the
data side: in our notations, this corresponds to fixing r≡0 for any t.

As a result, Consistency Models are conditioned on a single time variable,
unlike ours.
```

**Techniques**:
- **"focused on X"** - Their scope
- **"in our notations, this corresponds to..."** - Precise mapping
- **"As a result"** - Consequence
- **"unlike ours"** - One-word differentiation

---

## 5. Results: Significant Improvements with Context

### Pattern: Relative Improvement + Independence

**Structure**:
```markdown
1. [Absolute] We achieve [metric] on [task]
2. [Relative] This represents [X-Y%] relative improvement over [comparison]
3. [Context] Our method is [self-contained / independent]
4. [Negative List] without [list of things you don't need]
```

### MeanFlows Example:

```latex
Our method achieves an FID of 3.43 using 1-NFE generation.

This result significantly outperforms previous state-of-the-art methods in
its class by a relative margin of 50% to 70% (Fig. 1).

In addition, our method stands as a self-contained generative model: it is
trained entirely from scratch, without any pre-training, distillation, or
curriculum learning.
```

**Techniques**:
- **Absolute first**: "FID of 3.43"
- **"significantly outperforms"** - Strong but not "dramatically"
- **"by a relative margin of 50% to 70%"** - Range, not single number
- **Reference to figure**: "(Fig. 1)"
- **"In addition"** - Second dimension of value
- **"self-contained"** - Independence keyword
- **"trained entirely from scratch"** - Complete independence
- **Negative list**: "without any pre-training, distillation, or curriculum learning"

---

## 6. Table Design: System-Level Comparison

### Pattern: Multiple Paradigms, Clear Highlighting

**Structure**:
```markdown
Table X:
┌────────────────────────────────────┐
│ Left side: Your direct competitors  │
│ (1-NFE and 2-NFE methods)          │
├────────────────────────────────────┤
│ Right side: Other paradigms         │
│ (GANs, autoregressive, etc.)       │
├────────────────────────────────────┤
│ **Your method** (bold, positioned)  │
└────────────────────────────────────┘
```

### MeanFlows Table 2 Organization:

```latex
Table 2: Comparison on ImageNet 256×256.

Left: 1-NFE and 2-NFE diffusion/flow models
Right: Other generative models

Highlighted: MeanFlow (our method)
```

**Key Techniques**:
1. **Split paradigm**: Direct competitors on left, others on right
2. **Fair metrics**: params, NFE, FID (same for all)
3. **Bold your method**: Visual emphasis
4. **Position strategically**: Where you look best
5. **Comprehensive**: Include all major paradigms

---

## 7. Figure Design: Visual Storytelling

### Pattern: Multi-Panel Narrative

**MeanFlows Figure 1**: "One-step generation on ImageNet 256×256 from scratch"

**Structure**:
- **Main panel**: Generated images (visual evidence)
- **Caption**: Detailed comparison table
- **Annotations**: FID scores of competing methods
- **Highlight**: "Our MeanFlow (MF) model achieves significantly better..."

**Techniques**:
1. **Title tells the story**: "from scratch" - key differentiator
2. **Images + numbers**: Both visual and quantitative
3. **Competitor scores in caption**: Reader doesn't need to flip pages
4. **"significantly better"**: In the figure caption itself

---

## 8. Ablation Study: Destructive Testing

### Pattern: Prove Necessity by Breaking Things

**Structure**:
```markdown
Table X:
┌──────────────────────────────────┐
│ (a) Vary one design dimension    │
│ - Show effect of parameter       │
│ - Mark default in gray           │
├──────────────────────────────────┤
│ (b) Destructive comparison       │
│ - Intentionally use WRONG values │
│ - Show only correct works        │
└──────────────────────────────────┘
```

### MeanFlows Table 1 Example:

#### Part (a): Design Sweep
```latex
(a) Ratio of sampling r≠t
% of r≠t      FID, 1-NFE
0% (= FM)     328.91
25%           61.06
50%           63.14
100%          67.32
```

**Techniques**:
- **Descriptive caption**: "Ratio of sampling r≠t"
- **Show failure mode**: "0% (= FM) 328.91" - pure FM fails
- **Range**: 0% to 100% of parameter
- **Default marked**: In original (not shown here)

#### Part (b): Destructive Testing
```latex
(b) JVP computation
jvp tangent          FID, 1-NFE
(v, 0, 1)            61.06
(v, 0, 0) [wrong]    268.06
(v, 1, 0) [wrong]    329.22
(v, 1, 1) [wrong]    137.96
```

**Techniques**:
- **"Destructive comparison"** in caption
- **"intentionally performed"** in text
- **Only first row works**: Others are wrong by design
- **Proves necessity**: "meaningful results are achieved only when..."

---

## 9. Writing Style: Theory Keywords

### Emphasis Words for Theory-Driven Papers

**Naturalness Keywords** (use these to describe your theory):
- "naturally" - "This naturally leads to..."
- "intrinsic" - "intrinsic relation"
- "well-defined" - "well-defined problem"
- "principled" - "principled basis"
- "first principles" - "from first principles"
- "solely originated from" - "solely from definition"

**Independence Keywords**:
- "does not depend on" - Theory independence
- "independent of" - Implementation independence
- "self-contained" - System independence
- "from scratch" - No external dependencies
- "without any X" - Negative list

**Differentiation Keywords**:
- "in contrast to" - Conceptual contrast
- "unlike" - Direct comparison
- "typically" - "typically modeled" (their approach)
- "prior works typically rely on" - Their limitation
- "imposed as" - Artificial constraint (theirs)

### Avoid These (Too Promotional):
- ❌ "revolutionary" - Too strong
- ❌ "breakthrough" - Let others say it
- ❌ "completely eliminates" - Too absolute
- ✅ "significantly outperforms" - Strong but measured
- ✅ "substantial improvement" - Professional

---

## 10. Common Mistakes in Theory Papers

### ❌ Don't:
- Derive without explaining motivation - Why are we doing this?
- Skip steps in derivation - Readers aren't you
- Use heuristics without admitting it - Be honest
- Overclaim - "proves optimal" vs "improves over"
- Forget to acknowledge dependencies - If you use X, say it

### ✅ Do:
- Start from first principles explicitly
- Give each equation/dentity a memorable name
- Show "destructive" ablations to prove necessity
- Report relative improvements (more impactful)
- Use "principled" keywords consistently
- Admit what you DON'T need (negative list)

---

## 11. Revision Checklist for Theory-Driven Papers

**Before Submission, Verify:**

- [ ] Abstract starts from established framework (not "X is important")
- [ ] Introduction has "Despite encouraging results..." critique
- [ ] Core concept has a memorable name
- [ ] Derivation is step-by-step with justifications
- [ ] Key equation is named ("X Identity")
- [ ] Theory is contrasted as "principled" vs "heuristic"
- [ ] Results include relative improvement (X-Y%)
- [ ] Self-containment is emphasized (what you don't need)
- [ ] Ablations include destructive tests
- [ ] Tables organize by paradigm, highlight your position
- [ ] Figures tell visual story with captions
- [ ] Theory keywords used consistently (principled, intrinsic, natural)

---

## 12. Example: Applying This Pattern

### Original Idea (Not Theory-Driven):
"We propose a new training method that improves FID by 20%."

### Theory-Driven Version:
"Flow Matching provides an intuitive framework for generative modeling,
but recent one-step methods impose consistency constraints heuristically.
Despite encouraging results, the underlying ground-truth field properties
remain unknown. We introduce average velocity (in contrast to instantaneous
velocity), deriving the MeanFlow Identity solely from first principles.
This provides a principled basis for training, achieving 3.43 FID with
50-70% relative improvement. Our method is self-contained, trained from
scratch without pre-training or distillation."

**The Theory-Driven Frame**:
- Foundation: Flow Matching (established)
- Problem: Heuristic constraints (theory gap)
- Concept: Average velocity (new)
- Theory: MeanFlow Identity (derived)
- Result: Strong + independent (no external deps)

---

## Paper Metadata

**Title**: Mean Flows for One-step Generative Modeling

**Authors**: Kaiming He et al.

**Year**: 2025

**Key Concepts**:
- Average velocity vs instantaneous velocity
- MeanFlow Identity
- Principled vs heuristic training
- Self-contained generative models

---

## Extracted by

**Date**: 2026-01-26

**Source**: Analysis of Mean Flows paper (16 pages)

**Extraction Focus**: Theory-driven paper writing patterns, first-principles
derivations, principled vs heuristic positioning

**For Integration**: ml-paper-writing skill knowledge base
