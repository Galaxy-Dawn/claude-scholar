# "Rethinking" Papers: Challenging Conventional Wisdom

**Source**: Kaiming He et al., "Autoregressive Image Generation without Vector Quantization" (NeurIPS 2024 Spotlight)

**Paper Type**: Paradigm-challenging / "Rethinking" paper

**Core Pattern**: Question deeply-held assumptions → Propose alternative → Demonstrate effectiveness

---

## 1. Abstract Structure: Challenging Conventional Wisdom

### Pattern: The "Conventional Wisdom" Opening

**Template**:
```markdown
Abstract:
1. [Hook] Conventional wisdom holds that [widely-believed assumption].
2. [Observation] We observe that [counter-point or nuance].
3. [Question] Is it necessary for [core assumption]?
4. [Proposal] In this work, we propose [alternative approach].
5. [Solution] Rather than [traditional method], we [novel method].
6. [Results] This approach [eliminates/enables] X, achieving [strong results].
7. [Vision] We hope this work will [broader impact statement].
```

### MAR Abstract Example (annotated):

```latex
Conventional wisdom holds that [autoregressive models for image generation
are typically accompanied by vector-quantized tokens].

We observe that while [discrete-valued space can facilitate representing
a categorical distribution], it is [not a necessity for autoregressive modeling].

In this work, we propose to [model the per-token probability distribution
using a diffusion procedure], which allows us to [apply autoregressive models
in a continuous-valued space].

Rather than using [categorical cross-entropy loss], we define a
[Diffusion Loss function] to model the per-token probability.

This approach [eliminates the need for discrete-valued tokenizers].

We evaluate its effectiveness across [a wide range of cases], including
[standard autoregressive models and generalized masked autoregressive (MAR) variants].

By removing vector quantization, our image generator achieves [strong results]
while enjoying [the speed advantage of sequence modeling].

We hope this work will motivate [the use of autoregressive generation in
other continuous-valued domains and applications].
```

### Key Techniques:

1. **"Conventional wisdom holds that..."** - Strong, respectful opening that acknowledges prevailing beliefs
2. **"We observe that..."** - Signals empirical insight rather than mere speculation
3. **"it is not a necessity for..."** - Gentle but direct challenge to the assumption
4. **"Rather than..."** - Clear alternative positioning
5. **"This approach eliminates the need for..."** - Practical benefit statement
6. **"We hope this work will..."** - Forward-looking vision

---

## 2. Introduction: The Question-Driven Framework

### Pattern: Start with the Question

**Traditional Introduction** (less effective):
- "Image generation is an important problem..."
- "Existing methods use VQ tokenizers..."
- "We propose a new method..."

**"Rethinking" Introduction** (Kaiming He style):
```markdown
1. [Establish Context] Domain context + prevailing approach
2. [Identify Assumption] The widely-held belief
3. [Formulate Question] "Is it necessary for..."
4. [Analyze Requirements] What is truly essential?
5. [Propose Alternative] If alternative model exists...
6. [Present Solution] Our specific proposal
7. [Broader Implications] What this enables
```

### MAR Introduction Structure (lines 20-79):

#### Part 1: Context and Prevailing Belief (lines 20-29)
```latex
Autoregressive models are currently the de facto solution to generative
models in natural language processing [38, 39, 3]. These models predict
the next word or token in a sequence based on the previous words as input.

Given the discrete nature of languages, the inputs and outputs of these
models are in a categorical, discrete-valued space.

This prevailing approach has led to a widespread belief that autoregressive
models are inherently linked to discrete representations.
```

**Technique**: Start from uncontroversial facts (NLP success) → Show how they led to a belief (AR ↔ discrete)

#### Part 2: Consequences of the Belief (lines 25-29)
```latex
As a result, research on generalizing autoregressive models to continuous-
valued domains—most notably, image generation—has intensely focused on
discretizing the data [6, 13, 40].

A commonly adopted strategy is to train a discrete-valued tokenizer on
images, which involves a finite vocabulary obtained by vector quantization
(VQ) [51, 41, 41].
```

**Technique**: Show concrete consequences of the belief (VQ tokenizers everywhere)

#### Part 3: The Research Question (lines 30-33)
```latex
In this work, we aim to address the following question:

Is it necessary for autoregressive models to be coupled with vector-
quantized representations?
```

**Technique**: Explicit question format. Bold, direct, centered.

#### Part 4: Analyzing What's Essential (lines 31-37)
```latex
We note that the autoregressive nature, i.e., "predicting next tokens based
on previous ones", is independent of whether the values are discrete or
continuous.

What is needed is to model the per-token probability distribution, which
can be measured by a loss function and used to draw samples from.

Discrete-valued representations can be conveniently modeled by a categorical
distribution, but it is not conceptually necessary.
```

**Technique**: Distinguish mechanism (autoregression) from implementation (discrete tokens)

#### Part 5: The "If..." Condition (lines 36-37)
```latex
If alternative models for per-token probability distributions are presented,
autoregressive models can be approached without vector quantization.
```

**Technique**: Logical bridge - "If X, then Y" sets up your contribution

#### Part 6: Your Solution (lines 38-58)
```latex
With this observation, we propose to model the per-token probability
distribution by a diffusion procedure operating on continuous-valued domains.

[Technical description of Diffusion Loss...]
```

#### Part 7: Benefits and Implications (lines 59-79)
```latex
Our approach eliminates the need for discrete-valued tokenizers. Vector-
quantized tokenizers are difficult to train and are sensitive to gradient
approximation strategies [51, 41, 40, 27]. Their reconstruction quality
often falls short compared to continuous-valued counterparts [42].

Our approach allows autoregressive models to enjoy the benefits of higher-
quality, non-quantized tokenizers.

[...]

The effectiveness of our method reveals a largely uncharted realm of image
generation: modeling the interdependence of tokens by autoregression,
jointly with the per-token distribution by diffusion.
```

**Technique**: Multiple benefit levels:
- **Eliminates pain points**: VQ is hard to train
- **Enables benefits**: Higher-quality tokenizers
- **Reveals new territory**: "uncharted realm"

---

## 3. Rethinking Section: Dissecting the Status Quo

### Pattern: "Rethinking X" Chapter

When challenging conventional wisdom, dedicate a section to re-examining the assumptions.

### MAR Section 3.1: "Rethinking Discrete-Valued Tokens"

**Structure**:
```markdown
1. [Setup] Define the conventional approach mathematically
2. [Analysis] Identify the essential properties (not the implementation)
3. [Insight] Show that the implementation is not necessary
4. [Conclusion] State what's actually needed
```

### MAR Example (lines 110-126):

#### Step 1: Define the Conventional Approach
```latex
To begin with, we revisit the roles of discrete-valued tokens in
autoregressive generation models.

Denote as x the ground-truth token to be predicted at the next position.
With a discrete tokenizer, x can be represented as an integer: 0 ≤ x < K,
with a vocabulary size K.

The autoregressive model produces a continuous-valued D-dim vector z ∈ R^D,
which is then projected by a K-way classifier matrix W ∈ R^(K×D).

Conceptually, this formulation models a categorical probability distribution
in the form of p(x|z) = softmax(Wz).
```

**Technique**: Mathematically precise setup. Shows you deeply understand the status quo.

#### Step 2: Identify Essential Properties
```latex
In the context of generative modeling, this probability distribution must
exhibit two essential properties.

(i) A loss function that can measure the difference between the estimated
and true distributions.

(ii) A sampler that can draw samples from the distribution x ~ p(x|z) at
inference time.
```

**Technique**: Abstract away from implementation to functional requirements

#### Step 3: Show Convention is Not Necessary
```latex
In the case of categorical distribution, this can be simply done by the
cross-entropy loss.

[...]

This analysis suggests that discrete-valued tokens are not necessary for
autoregressive models.
```

**Technique**: "This analysis suggests" - evidence-based conclusion

#### Step 4: What's Actually Needed
```latex
Instead, it is the requirement of modeling a distribution that is essential.

A discrete-valued token space implies a categorical distribution, whose loss
function and sampler are simple to define.

What we actually need are a loss function and its corresponding sampler for
distribution modeling.
```

**Technique**: Reposition the problem - it's about distribution modeling, not discrete tokens

---

## 4. Unifying Different Methods: The "Generalized Framework" Pattern

### Pattern: Show Two Seemingly Different Methods Are Special Cases

**MAR Section 3.4**: "Unifying Autoregressive and Masked Generative Models"

**Structure**:
```markdown
1. [Observation] These methods seem different but share a core principle
2. [Insight] The core principle is X, not the surface differences
3. [Demonstration] Show how Method A fits the principle
4. [Demonstration] Show how Method B fits the principle
5. [Unification] Both are special cases of a general framework
6. [Benefit] This understanding enables new combinations/insights
```

### MAR Example (lines 181-259):

#### Opening Observation
```latex
We show that masked generative models, e.g., MaskGIT [4] and MAGE [29],
can be generalized under the broad concept of autoregression, i.e.,
next token prediction.
```

#### The Insight
```latex
Bidirectional attention can perform autoregression.

The concept of autoregression is orthogonal to network architectures:
autoregression can be done by RNNs [50], CNNs [49, 7], and
Transformers [38, 36, 6].

When using Transformers, although autoregressive models are popularly
implemented by causal attention, we show that they can also be done by
bidirectional attention.
```

**Technique**: "Orthogonal to" - shows independence of concepts

#### Visual Demonstration (Figure 2)
```latex
Note that the goal of autoregression is to predict the next token given
the previous tokens; it does not constrain how the previous tokens
communicate with the next token.

We can adopt the bidirectional attention implementation as done in Masked
Autoencoder (MAE) [21]. See Figure 2(b).
```

**Technique**: Use visualization to show "unexpected" equivalence

#### Generalization (Figure 3)
```latex
Autoregressive models in random orders...

Masked autoregressive models: In masked generative modeling [4, 29],
the models predict a random subset of tokens based on known/predicted
tokens.

This can be formulated as permuting the token sequence by a random order,
and then predicting multiple tokens based on previous tokens.

Conceptually, this is an autoregressive procedure...
```

**Technique**: Mathematical unification - same formula, different instantiations

#### Naming the Generalization
```latex
We refer to this variant as Masked Autoregressive (MAR) models.

MAR is a random-order autoregressive model that can predict multiple
tokens simultaneously.
```

**Technique**: Define new terminology to capture the unified concept

---

## 5. Flexibility Arguments: Demonstrating Generality

### Pattern: Show Your Method Works in Many Configurations

**MAR Section 5.1**: "Flexibility of Diffusion Loss"

**Structure**:
```markdown
1. [Claim] One significant advantage is flexibility with various X
2. [Demonstration 1] Works with configuration A
3. [Demonstration 2] Works with configuration B (even surprising case)
4. [Demonstration 3] Works with configuration C
5. [Insight] This flexibility enables Y
```

### MAR Example (lines 349-366, Table 2):

#### Opening Claim
```latex
One significant advantage of Diffusion Loss is its flexibility with
various tokenizers.
```

#### Surprising Case 1: VQ Tokenizers
```latex
Diffusion Loss can be easily used even given a VQ tokenizer.

We simply treat the continuous-valued latent before the VQ layer as the
tokens.

This variant gives us 7.82 FID (w/o CFG), compared favorably with 8.79
FID (Table 1) of cross-entropy loss using the same VQ tokenizer.
```

**Technique**: Show it works even with the "wrong" tokenizer type (VQ)

#### Surprising Case 2: Mismatched Stride
```latex
Interestingly, Diffusion Loss also enables us to use tokenizers with
mismatched strides.

In Table 2, we study a KL-8 tokenizer whose stride is 8 and output
sequence length is 32×32. Without increasing the sequence length of the
generator, we group 2×2 tokens into a new token.

Despite the mismatch, we are able to obtain decent results...
```

**Technique**: "Interestingly" + "Despite the mismatch" - emphasizes robustness

#### Surprising Case 3: Different Architecture
```latex
Further, this property allows us to investigate other tokenizers, e.g.,
Consistency Decoder [35], a non-VQ tokenizer of a different
architecture/stride designed for different goals.
```

**Technique**: Show applicability beyond original design space

#### Comprehiveness Check
```latex
For comprehensiveness, we also train a KL-16 tokenizer on ImageNet using
the code of [42]...
```

**Technique**: "For comprehensiveness" - signals thoroughness

---

## 6. Speed/Accuracy Trade-offs: Plotting the Pareto Frontier

### Pattern: Show Your Method Dominates or Expands the Frontier

**MAR Section 5.2**: "Speed/accuracy Trade-off" (Figure 6)

**Structure**:
```markdown
1. [Setup] We enjoy flexibility of X
2. [Visualization] Figure/plot showing trade-off curves
3. [Comparison 1] Compare within your variants
4. [Comparison 2] Compare to other methods
5. [Highlight] Notable point on the curve
```

### MAR Example (lines 425-474):

#### Setup
```latex
Following MaskGIT [4], our MAR enjoys the flexibility of predicting
multiple tokens at a time.

This is controlled by the number of autoregressive steps at inference time.
```

#### Comparison Within Family
```latex
Figure 6 plots the speed/accuracy trade-off.

MAR has a better trade-off than its AR counterpart, noting that AR is
with the efficient kv-cache.
```

**Technique**: "noting that..." - acknowledge AR's advantage, still win

#### Comparison to Other Methods
```latex
With Diffusion Loss, MAR also shows a favorable trade-off in comparison
with the recently popular Diffusion Transformer (DiT) [37].

As a latent diffusion model, DiT models the interdependence of all tokens
by the diffusion process. The speed/accuracy trade-off of DiT is mainly
controlled by its diffusion steps.

Unlike our diffusion process on a small MLP, the diffusion process of DiT
involves the entire Transformer architecture.

Our method is more accurate and faster.
```

**Technique**: Explain *why* you win (architectural difference)

#### Highlight Specific Point
```latex
Notably, our method can generate at a rate of <0.3 second per image with
a strong FID of <2.0.
```

**Technique**: "Notably" + impressive numbers - memorable takeaway

---

## 7. System-Level Comparison Tables: Organizing by Categories

### Pattern: Group Related Work, Highlight Your Position

**MAR Table 4**: "System-level comparison on ImageNet 256×256"

**Structure**:
```markdown
Table 4:
┌─────────────────────────────────┐
│ Category 1: pixel-based         │
│ - Method A                      │
│ - Method B                      │
├─────────────────────────────────┤
│ Category 2: vector-quantized     │
│ - Method C                      │
│ - Method D                      │
├─────────────────────────────────┤
│ Category 3: continuous-valued   │
│ - Method E                      │
│ - Method F                      │
├─────────────────────────────────┤
│ **Your Methods** (highlighted)  │
│ - Your Method B                 │
│ - Your Method L                 │
│ - Your Method H                 │
└─────────────────────────────────┘
```

### MAR Example (lines 448-470):

```latex
Table 4: System-level comparison on ImageNet 256×256 conditional
generation. Diffusion Loss enables Masked Autoregression to achieve
leading results in comparison with previous systems.

†: LDM operates on continuous-valued tokens, though this result uses
a quantized tokenizer.

w/o CFG              w/ CFG
#params  FID↓  IS↑  Pre.↑  Rec.↑  FID↓  IS↑  Pre.↑  Rec.↑
────────────────────────────────────────────────────────────
pixel-based
ADM [10]      554M  10.94  101.0  0.69  0.63  4.59  186.7  0.82  0.52
VDM++ [26]    2B    2.40   225.3   -     -     2.12  267.7   -     -

vector-quantized tokens
Autoreg. w/ VQGAN [13]  1.4B  15.78  78.3   -     -     -     -      -     -
MaskGIT [4]             227M   6.18  182.1  0.80  0.51   -     -      -     -
MAGE [29]               230M   6.93  195.8   -     -     -     -      -     -
MAGVIT-v2 [55]          307M   3.65  200.5   -     -     1.78  319.4   -     -

continuous-valued tokens
LDM-4† [42]            400M  10.56  103.5  0.71  0.62  3.60  247.7  0.87  0.48
U-ViT-H/2-G [2]        501M    -     -      -     -     2.29  263.9  0.82  0.57
DiT-XL/2 [37]          675M   9.62  121.5  0.67  0.67  2.27  278.2  0.83  0.57
[... other methods ...]

MAR-B, Diff Loss       208M   3.48  192.4  0.78  0.58  2.31  281.7  0.82  0.57
MAR-L, Diff Loss       479M   2.60  221.4  0.79  0.60  1.78  296.0  0.81  0.60
MAR-H, Diff Loss       943M   2.35  227.8  0.79  0.62  1.55  303.7  0.81  0.62
```

**Key Techniques**:
1. **Group by paradigm**: pixel-based → VQ → continuous-valued
2. **Show progression**: Earlier methods → later methods → yours
3. **Multiple metrics**: FID, IS, Precision, Recall (comprehensive)
4. **Multiple configurations**: w/o CFG and w/ CFG (fair comparison)
5. **Model sizes**: Show efficiency (your 479M vs their 675M)
6. **Dagger (†)**: Clarify edge cases (LDM uses quantized despite continuous)
7. **Bold your methods**: Visual separation (here shown as last group)

---

## 8. Admitting Limitations: Honest and Specific

### Pattern: Acknowledge Weaknesses Proactively

**MAR Appendix A**: "Limitations and Broader Impacts"

**Structure**:
```markdown
Limitations:
1. [Specific artifact] Show example (Figure 8)
2. [Dependency] Acknowledge reliance on external components
3. [Scope] Be honest about what you haven't tested

Broader Impacts:
1. [Positive] How this advances the field
2. [Positive] Practical applications
3. [Negative] Potential misuse considerations
```

### MAR Limitations Example (lines 629-642):

#### Limitation 1: Visual Artifacts
```latex
First of all, our image generation system can produce images with
noticeable artifacts (Figure 8).

This limitation is commonly observed in existing methods, especially when
trained on controlled, academic data (e.g., ImageNet).

Research-driven models trained on ImageNet still have a noticeable gap
in visual quality in comparison with commercial models trained on
massive data.
```

**Techniques**:
- Show example (Figure 8) - transparency
- "commonly observed" - you're not uniquely bad
- Contextualize: academic vs. commercial data

#### Limitation 2: External Dependency
```latex
Second, our image generation system relies on existing pre-trained
tokenizers.

The quality of our system can be limited by the quality of these tokenizers.

Pre-training better tokenizers is beyond the scope of this paper.
```

**Techniques**:
- "relies on" - direct acknowledgment
- "can be limited by" - honest constraint
- "beyond the scope" - boundary setting

#### Limitation 3: Unexplored Territory
```latex
Last, we note that given the limited computational resources, we have
primarily tested our method on the ImageNet benchmark.

Further validation is needed to assess the scalability and robustness
of our approach in more diverse and real-world scenarios.
```

**Techniques**:
- "given limited computational resources" - context, not excuse
- "primarily tested" - honesty about scope
- "Further validation is needed" - explicit call for future work

---

## 9. Visionary Conclusion: The "We Hope" Pattern

### Pattern: End with Forward-Looking Impact Statement

**MAR Conclusion** (lines 482-488):

```latex
The effectiveness of Diffusion Loss on various autoregressive models
suggests new opportunities: modeling the interdependence of tokens by
autoregression, jointly with the per-token distribution by diffusion.

This is unlike the common usage of diffusion that models the joint
distribution of all tokens.

Our strong results on image generation suggest that autoregressive models
or their extensions are powerful tools beyond language modeling.

These models do not need to be constrained by vector-quantized
representations.

We hope our work will motivate the research community to explore sequence
models with continuous-valued representations in other domains.
```

### Structure:
```markdown
1. [Synthesis] What your results suggest (new opportunities)
2. [Contrast] How this differs from common usage
3. [Generalization] Broader lesson (powerful tools beyond X)
4. [Freedom] Removing constraints (not limited by Y)
5. [Call to action] "We hope" - inspire future work
```

### Key Phrases:
- "suggests new opportunities"
- "unlike the common usage"
- "powerful tools beyond [original domain]"
- "do not need to be constrained by"
- "We hope our work will motivate..."

---

## 10. Writing Style: Kaiming He's Signature Techniques

### Tone Characteristics:

1. **Respectful but Firm Challenge**
   - "Conventional wisdom holds that..." (respect)
   - "...is not a necessity" (firm)
   - Never dismissive of prior work

2. **Empirically Grounded**
   - "We observe that..." (not "We believe that...")
   - "This analysis suggests..." (evidence-based)
   - Show, don't just tell

3. **Logical Precision**
   - Distinguish mechanism from implementation
   - "If X, then Y" formulations
   - Mathematical clarity in conceptual arguments

4. **Measured Claims**
   - "can be" not "is always"
   - "suggests" not "proves"
   - "enables" not "guarantees"

5. **Generous Citation**
   - Cite the methods you're challenging
   - Credit relevant prior work
   - "following [X]" for techniques you adopt

### Sentence Patterns:

**Challenge Patterns:**
- "Conventional wisdom holds that [X]. We observe that [Y]."
- "This prevailing approach has led to a widespread belief that [X]."
- "[X] is not a necessity for [Y]."
- "What is needed is [X], not [Y]."

**Insight Patterns:**
- "The concept of [X] is orthogonal to [Y]."
- "This is unlike the common usage of [X]."
- "These models do not need to be constrained by [X]."
- "This reveals a largely uncharted realm of [X]."

**Demonstration Patterns:**
- "Interestingly, [X] also enables us to..."
- "Despite [challenge], we are able to..."
- "For comprehensiveness, we also..."
- "Notably, [impressive result]."

**Vision Patterns:**
- "We hope this work will motivate..."
- "This suggests new opportunities for..."
- "We believe this will be beneficial to..."
- "Further validation is needed to assess..."

---

## 11. Figures: Making the Invisible Visible

### Pattern: Use Visualization to Show Conceptual Equivalence

**MAR Figure 2**: "Bidirectional attention can do autoregression"

**Purpose**: Challenge the assumption that autoregression requires causal attention

**Technique**: Side-by-side comparison
- (a) Causal attention (conventional)
- (b) Bidirectional attention (surprising but equivalent)

**Annotation Key Points**:
- "next token prediction" (highlight both do this)
- "loss on [all/unknown] tokens" (show the difference)
- Arrows showing attention flow

**MAR Figure 3**: "Generalized Autoregressive Models"

**Purpose**: Show AR, random-order AR, and MAR are special cases

**Technique**: Progressive generalization
- (a) AR, raster order (standard)
- (b) AR, random order (small variation)
- (c) Masked AR (generalization)

**Visual Language**:
- "unknown" vs "known/predicted" tokens
- Color coding for what's predicted at each step
- Consistent notation across panels

**Key**: Figures should make conceptual contributions visually obvious

---

## 12. Related Work: Positioning Within Traditions

### Pattern: Acknowledge Lineage, Show Departure

**MAR Section 2**: "Related Work" (lines 80-103)

**Structure**:
```markdown
1. [Main tradition] Sequence Models for Image Generation
   - Pioneering work [citations]
   - Your position: "Related to our work, [X] also focuses on..."
   - Contrast: "In [X], [limitation]. In contrast, our method..."

2. [Adjacent tradition] Diffusion for Representation Learning
   - Prior work [citations]
   - Clarify difference: "These efforts have been focused on [X],
     rather than [Y]"
   - "In their scenarios, [goal] is not a goal"

3. [Conceptual connection] Diffusion for Policy Learning
   - "Our work is conceptually related to [X]"
   - Analogy: "In image generation, we can think of [X] as [Y]"
   - Difference: "Despite this conceptual connection, [key difference]"
```

### Key Techniques:

1. **"Related to our work..."** - Acknowledge contemporaries generously
2. **"In contrast..."** - Sharp differentiation
3. **"These efforts have been focused on..."** - Respectful boundary setting
4. **"In their scenarios..."** - Contextualize differences
5. **"Conceptually related to..."** - Find connections across domains
6. **"We can think of X as Y"** - Analogies for insight
7. **"Despite this conceptual connection..."** - Honest differences

---

## 13. Experiments: Ablation as Storytelling

### Pattern: Experiments Should Validate the "Rethinking"

**MAR Section 5**: Experiments organized to prove the rethinking

**Flow**:
```markdown
1. Properties of Diffusion Loss (prove the alternative works)
   - vs Cross-entropy (Table 1)
   - Flexibility (Table 2)
   - Ablations (Table 3, Figures 4-5)

2. Properties of Generalized AR (prove the unification)
   - From AR to MAR (Table 1)
   - Speed/accuracy trade-off (Figure 6)

3. Benchmarking (prove the results are strong)
   - System-level comparison (Table 4)
   - Qualitative results (Figure 7)
```

**Key**: Every experiment should map to a conceptual claim from the introduction

### Table Design Patterns:

**Comparison Tables** (Table 1):
- Group by variants (AR → MAR)
- Show progression (Cross-ent → Diff Loss)
- Multiple configurations (w/ and w/o CFG)
- Clear metrics (FID↓, IS↑)

**Flexibility Tables** (Table 2):
- "Flexibility of X" in caption
- Diverse configurations
- Architecture variations
- Stride mismatches
- rFID column (reconstruction quality)

**Ablation Tables** (Table 3):
- One dimension varied (MLP width)
- Show params and inference time
- Demonstrate efficiency
- Default row marked (implicit)

---

## 14. Summary: The "Rethinking" Paper Template

### When to Use This Pattern:

**Your paper is a "Rethinking" paper if:**
- You challenge a widely-held assumption in your field
- You show two seemingly different methods are equivalent
- You propose removing a "necessary" component
- You unify multiple approaches under one framework

**Not a "Rethinking" paper if:**
- You propose an incremental improvement
- You combine existing techniques without conceptual insight
- You're optimizing within an established paradigm

### Abstract Template:
```
Conventional wisdom holds that [assumption]. We observe that [nuance].
Is it necessary for [assumption]? In this work, we propose [alternative].
Rather than [traditional method], we [novel method]. This approach [benefits].
We hope this work will [vision].
```

### Introduction Template:
```
[Context] Domain X uses method Y widely.
[Belief] This has led to belief that Z.
[Question] Is Z necessary?
[Analysis] What's actually needed is W.
[Proposal] We propose alternative that achieves W.
[Results] Strong performance + [specific benefit].
[Vision] This opens new direction.
```

### Section Template ("Rethinking X"):
```
1. Define the conventional approach mathematically
2. Identify essential properties (2-3 items)
3. Show conventional is just one way to achieve these
4. State what's actually needed (abstract)
5. Position your method as satisfying these needs
```

### Unification Template:
```
[Observation] Methods A and B seem different.
[Insight] But they share core principle X.
[Demonstration] Show A = X + implementation Y
[Demonstration] Show B = X + implementation Z
[Generalization] Both are special cases of framework F
[Benefit] This understanding enables [new possibilities]
```

### Conclusion Template:
```
Our results suggest [new opportunity].
Unlike common usage that [old approach], we show [new insight].
This reveals [uncharted realm].
We hope this will motivate [future direction].
```

---

## 15. Common Pitfalls to Avoid

### ❌ Don't:
- Dismiss prior work as "wrong" - it led to the belief for good reasons
- Overstate your case - "completely eliminates" vs "reduces the need for"
- Ignore implementation realities - VQ was solving real problems
- Be vague about alternatives - show concrete alternatives
- Forget to cite the methods you're challenging

### ✅ Do:
- Acknowledge why the conventional wisdom emerged
- Show limitations respectfully
- Provide rigorous comparisons
- Admit when your method doesn't help
- Credit relevant work extensively
- Use precise language ("can be" not "is always")

---

## 16. Citation Integration Examples

### How MAR Cites Challenges:

**Citing the method you're improving:**
```latex
Discrete tokenizers are difficult to train [51, 41, 40, 27].
```
- Multiple citations show it's a known problem
- Recent citations ([27]) show it's still active

**Citing contemporaries:**
```latex
Related to our work, the recent work on GIVT [48] also focuses on
continuous-valued tokens in sequence models.

GIVT and our work both reveal the significance and potential of this
direction.

In GIVT, [limitation]. In contrast, our method [advantage].
```
- "Related to our work" - generous positioning
- "both reveal" - shared progress
- "In contrast" - clear differentiation

**Citing the technique you adapt:**
```latex
We can adopt the bidirectional attention implementation as done in
Masked Autoencoder (MAE) [21].

See Figure 2(b).
```
- "as done in" - giving credit
- Reference to figure for transparency

---

## 17. Revision Checklist for "Rethinking" Papers

**Before Submission, Verify:**

- [ ] Abstract clearly states the challenged assumption
- [ ] Introduction asks an explicit question ("Is it necessary...")
- [ ] "Rethinking" section dissects the status quo rigorously
- [ ] Unification section shows mathematical/conceptual equivalence
- [ ] Experiments directly test the rethinking claims
- [ ] Flexibility/robustness experiments included
- [ ] Limitations acknowledge remaining challenges
- [ ] Related work cites challenged methods generously
- [ ] Conclusion frames work as opening new territory
- [ ] Figures make conceptual contributions visible
- [ ] Tone is respectful but firm
- [ ] Claims are measured ("can be", "suggests", not "proves")
- [ ] Vision statement inspires without overpromising

---

## 18. Example: Applying This Pattern

### Original Idea (Not "Rethinking"):
"We propose a new tokenizer that improves image quality by 10%."

### Rethinking Version:
"Conventional wisdom holds that autoregressive models require
vector-quantized tokenizers. We observe that VQ introduces artifacts and
training difficulties. Is quantization necessary for autoregressive
image generation? We propose Diffusion Loss that enables continuous-valued
tokens, eliminating VQ while achieving SOTA results. We hope this will
motivate continuous-valued modeling in other domains."

**The Rethinking Frame:**
- Assumption: AR ↔ VQ (challenged)
- Insight: What's needed is distribution modeling, not discreteness
- Alternative: Diffusion Loss for continuous tokens
- Benefit: Eliminates VQ artifacts + enables better tokenizers
- Vision: Continuous-valued AR beyond images

---

## Paper Metadata

**Title**: Autoregressive Image Generation without Vector Quantization

**Authors**: Tianhong Li, Yonglong Tian, He Li, Mingyang Deng, Kaiming He

**Venue**: NeurIPS 2024 (Spotlight)

**arXiv**: 2406.11838

**Code**: https://github.com/LTH14/mar

**Key Citations**:
- VQ-VAE [51]: Original VQ paper
- MaskGIT [4], MAGE [29]: Masked generative models
- MAE [21]: Bidirectional attention implementation
- DiT [37]: Speed/accuracy comparison
- LDM [42]: Tokenizer source

---

## Extracted by

**Date**: 2025-01-26

**Source**: Full PDF analysis of arXiv:2406.11838v3

**Extraction Focus**: Writing patterns for challenging conventional wisdom,
unifying methods, and structuring "rethinking" papers

**For Integration**: ml-paper-writing skill knowledge base
