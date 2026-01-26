# Writing Techniques and Patterns

This file contains actionable sentence patterns, transition phrases, and writing techniques extracted from successful ML conference papers.

---

## Transition Phrases

### Literature Review Transitions
**Source:** Various NeurIPS/ICML papers

**Introducing Problems:**
- "However, these methods suffer from [limitation]."
- "Despite recent progress, [challenge] remains unsolved."
- "While existing approaches address [aspect], they struggle with [issue]."

**Presenting Solutions:**
- "To address this, we propose..."
- "We overcome this limitation by..."
- "Our key insight is that..."

**Connecting to Related Work:**
- "Building on [prior work], we extend..."
- "Unlike approaches that [method], we instead..."
- "Following the success of [paper], we apply..."

### Methods Section Transitions
**Source:** "BERT: Pre-training of Deep Bidirectional Transformers", NAACL (2019)

**Describing Components:**
- "Our model consists of two main components: [A] and [B]."
- "We divide our approach into [N] stages: [list]."

**Explaining Rationale:**
- "We choose this architecture because..."
- "This formulation allows us to..."
- "Motivated by [intuition], we design..."

### Results Section Transitions
**Source:** "Attention Is All You Need", NeurIPS (2017)

**Presenting Findings:**
- "Our method achieves [result], outperforming baselines by [margin]."
- "As shown in Table 1, our approach..."
- "Figure 2 demonstrates that..."

**Analyzing Results:**
- "These results suggest that [insight]."
- "Notably, we observe that..."
- "This improvement indicates that..."

### Discussion Transitions
**Source:** "Language Models are Few-Shot Learners", GPT-3 (2020)

**Interpreting Findings:**
- "These findings reveal that..."
- "This performance gap suggests that..."
- "The strong correlation between...indicates..."

**Connecting to Broader Context:**
- "Beyond the specific task, our results imply..."
- "This has important implications for..."

**Acknowledging Limitations:**
- "It is important to note that our study is limited to..."
- "While these results are promising, several questions remain..."

---

## Sentence Patterns

### Claim Presentation
**Source:** "Attention Is All You Need", NeurIPS (2017)

**Strong Claims:**
- "We show that [approach] achieves [result]."
- "We demonstrate that [method] outperforms..."
- "We prove that [technique] converges to..."

**Nuanced Claims:**
- "Our results suggest that [factor] contributes to..."
- "We observe that [phenomenon] emerges when..."
- "Experiments indicate that [approach] is particularly effective for..."

### Technical Description
**Source:** "Adam: A Method for Stochastic Optimization", ICLR (2015)

**Algorithm Description:**
- "Formally, we optimize [objective] using [method]."
- "The update rule for [parameter] is given by..."
- "We modify the standard [approach] by..."

**Implementation Details:**
- "In practice, we implement [feature] as..."
- "For computational efficiency, we approximate..."
- "We initialize [parameters] using..."

### Results Presentation
**Source:** "BERT: Pre-training of Deep Bidirectional Transformers", NAACL (2019)

**Quantitative Results:**
- "Our model achieves [score] (±[std]), improving over..."
- "On [dataset], we obtain [result], compared to..."
- "We observe a [percentage]% improvement over baselines."

**Statistical Reporting:**
- "Results are averaged over N runs with different seeds."
- "Standard deviations are shown in parentheses."
- "The improvement is statistically significant (p<0.01)."

---

## Clarity Techniques

### Active Voice Usage
**Source:** Various well-written papers

**Passive (avoid):**
- "The model was trained using..."
- "Experiments were conducted on..."

**Active (prefer):**
- "We trained the model using..."
- "We conducted experiments on..."

**Guideline:** Use active voice for actions you performed. Use passive for general facts or when the actor is unclear.

### Specificity Over Generality
**Source:** "Attention Is All You Need", NeurIPS (2017)

**Vague (avoid):**
- "This approach improves performance."
- "The method learns good representations."

**Specific (prefer):**
- "This approach improves accuracy by 15%."
- "The method learns representations that transfer to downstream tasks."

**Guideline:** Be quantitative whenever possible. Use specific numbers and metrics.

### Signposting
**Source:** "BERT: Pre-training of Deep Bidirectional Transformers", NAACL (2019)

**Section Openings:**
- "We now describe our model architecture."
- "We evaluate on three tasks: [list]."
- "The results suggest three key insights:"

**Internal Structure:**
- "First, we [action]. Next, we [action]. Finally, we [action]."
- "Our approach has three stages: [A], [B], and [C]."

**Guideline:** Use explicit signposting to help tired reviewers follow your paper.

---

## Common Phrase Templates

### Opening Abstract
**Good Examples:**
- "We introduce [method], a novel approach for [task]."
- "We present [method], which achieves [result] by [mechanism]."
- "We propose [framework] to address [challenge]."

**Avoid:**
- "In this paper, we study..." (generic)
- "Large language models have..." (overused opening)

### Introducing Related Work
**Good Examples:**
- "Recent work has shown promise in [area] [refs]."
- "Several approaches have been proposed for [task] [refs]."
- "The standard approach to [problem] is [method] [refs]."

### Describing Experiments
**Good Examples:**
- "We evaluate on [datasets], comparing against [baselines]."
- "We conduct ablation studies to validate [component]."
- "To verify [claim], we experiment with [variations]."

### Presenting Results
**Good Examples:**
- "Table 1 shows that our method outperforms all baselines."
- "As shown in Figure 3, performance improves as [factor] increases."
- "Our method achieves state-of-the-art on [task/metric]."

### Discussing Limitations
**Good Examples:**
- "Our approach has limitations: [constraint]."
- "We note that our method is currently restricted to [condition]."
- "A key limitation is [issue], which we leave for future work."

---

## Writing Principles

### From Top Papers

**Clarity First:**
- "Make it easy for reviewers to understand your contribution."
- "Use concrete examples and specific language."
- "Avoid vague or ambiguous statements."

**Rigorous Presentation:**
- "Provide enough detail for reproduction."
- "Include error bars and statistical tests."
- "Show negative results when relevant."

**Storytelling:**
- "Your paper tells a story: problem → approach → solution → impact."
- "Make the narrative clear in the introduction."
- "Each section should advance the story."

**Honesty:**
- "Acknowledge limitations explicitly."
- "Don't overclaim results."
- "Trust reviewers to appreciate honesty."

---

## Notes

- **Adapt patterns**: These templates can and should be adapted to your specific context
- **Venue matters**: Some venues prefer certain styles (check venue-specific guides)
- **Consistency**: Use consistent terminology throughout
- **Tone**: Maintain professional, objective tone
- **Length**: Keep transitions concise; don't over-explain

**Attribution:** All patterns extracted from analyzed papers with source citations for traceability.


---

## "Surprisingly" Findings: Multi-Level Reporting Pattern

**Source**: Kaiming He et al., "Exploring Plain Vision Transformer Backbones for Object Detection" (ViTDet, ECCV 2022), "Mean Flows" (2025)

**Paper Type**: Design simplification, unexpected findings

### The Three-Level "Surprisingly" Pattern

#### Level 1: Basic Surprise (Abstract/Opening)

**Pattern**:
```markdown
Surprisingly, we observe: (i) [simple sufficient without common practice]
and (ii) [simple sufficient without common practice]
```

**Example (ViTDet Abstract)**:
```latex
Surprisingly, we observe: (i) it is sufficient to build a simple feature
pyramid from a single-scale feature map (without the common FPN design) and
(ii) it is sufficient to use window attention (without shifting) aided with
very few cross-window propagation blocks.
```

**Key Techniques**:
- **Structured list**: Use (i) and (ii) to separate findings
- **"sufficient"**: Scientific phrasing (not "optimal")
- **"without [common practice]"**: Negative differentiation

#### Level 2: Competitive Surprise (Introduction)

**Pattern**:
```markdown
More surprisingly, under some circumstances, our [method] can compete
with the leading [competitors].
```

**Example (ViTDet Introduction)**:
```latex
More surprisingly, under some circumstances, our plain-backbone detector,
named ViTDet, can compete with the leading hierarchical-backbone detectors
(e.g., Swin, MViT).
```

**Key Techniques**:
- **"More surprisingly"**: Progressive emphasis
- **"under some circumstances"**: Measured claim
- **"can compete with"**: Not "beat", competitive
- **Name competitors**: Specific (Swin, MViT)

#### Level 3: Superiority Surprise (Results)

**Pattern**:
```markdown
With [specific condition], our [method] can outperform the [competitors]
that use [stronger condition]. The gains are more prominent for [condition].
```

**Example**:
```latex
With Masked Autoencoder (MAE) pre-training, our plain-backbone detector can
outperform the hierarchical counterparts that are pre-trained on ImageNet-1K/21K
with supervision (Figure 3). The gains are more prominent for larger model sizes.
```

**Key Techniques**:
- **Specific conditions compared**: MAE vs ImageNet supervised
- **"outperform"**: Stronger claim here (qualified by conditions)
- **"The gains are more prominent for..."**: Pattern observation

---

### "Surprisingly" Variants

#### "Interestingly" - Pattern Observation + Explanation

**Pattern**:
```markdown
Interestingly, [observation]. This is in line with the observation in [paper]
that [their finding]. [Additional explanation].
```

**Example (ViTDet)**:
```latex
Interestingly, performing propagation in the last 4 blocks is nearly as
good as even placement. This is in line with the observation in ViT [14]
that ViT has longer attention distance in later blocks and is more localized
in earlier ones.
```

**Use when**: You have literature support for your observation

#### "Notably" - Important Detail

**Pattern**:
```markdown
Notably, [counter-intuitive result or impressive number].
```

**Examples**:
- "Notably, even embedding only the interval t−r yields reasonable results."
- "Notably, our method is self-contained and trained entirely from scratch."

**Use when**: Emphasizing importance or counter-intuitive finding

#### "It is worth noting that" - Caveat/Clarification

**Pattern**:
```markdown
It is worth noting that [technical caveat or clarification].
```

**Examples**:
- "It is worth noting that even when the conditional flows are designed to be straight ('rectified'), the marginal velocity field typically induces a curved trajectory."
- "It is worth noting that the 3.34× memory (49G) is estimated as if the same training implementation could be used, which is not practical and requires special memory optimization."

**Use when**: Preventing misunderstanding or clarifying technical details

---

### When to Use "Surprisingly"

**DO use**:
- When finding genuinely contradicts common practice
- When simple solution works as well as complex one
- When you have explanation (literature, hypothesis, theory)
- With measured claims ("under some circumstances", "can compete")
- With "sufficient" not "optimal"

**DON'T use**:
- For incremental improvements (use "additionally" instead)
- Without explanation/justification
- Overgeneralizing ("always", "proves")
- For expected results

---

## Ablation Study Writing Techniques

**Source**: Kaiming He papers (ViTDet, MeanFlows, MoCo v2)

### Table Design: Incremental Progression

**Pattern**:
```markdown
Table X: [Component] Ablation
┌──────────────────────────────────────────┐
│ no [component]        | AP     | Δ       │
│ (a) [common variant]  | AP     | +X.X    │
│ (b) [another variant] | AP     | +Y.Y    │
│ (c) ours: simple      | AP     | +Z.Z ✓  │
└──────────────────────────────────────────┘
```

**Example (ViTDet Table 1)**:
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
- **Correspondence**: "The entries (a-c) correspond to Figure X (a-c)"
- **Conclusion**: "our simple pyramid is sufficient"

---

### Destructive Ablation: Proving Necessity

**Pattern**:
```markdown
We conduct a destructive comparison in which [wrong choice] is intentionally
performed. Meaningful results are achieved only when [correct choice].
```

**Example (MeanFlows Table 1b)**:
```latex
In Tab. 1b, we conduct a destructive comparison in which incorrect JVP
computation is intentionally performed.

jvp tangent          FID, 1-NFE
(v, 0, 1) [correct]   61.06
(v, 0, 0) [wrong]     268.06
(v, 1, 0) [wrong]     329.22
(v, 1, 1) [wrong]     137.96

It shows that meaningful results are achieved only when the JVP computation
is correct.
```

**Use when**: You need to prove a design choice is necessary (not just optional)

---

### Ablation Narrative: Observation → Explanation

**Pattern 1: Observation + Literature Support**
```latex
We observe that [observation]. This is consistent with the observation in
[paper] that [their finding].
```

**Pattern 2: Observation + Hypothesis**
```latex
We hypothesize that this is because [reason 1] and also because [reason 2].
```

**Pattern 3: Observation + Theory**
```latex
[Observation]. This indicates that [theoretical explanation].
```

---

## Theory-Driven Paper Keywords

**Source**: Kaiming He et al., "Mean Flows for One-step Generative Modeling" (2025)

### Naturalness Keywords (use to describe your theory)

- **"naturally"** - "This naturally leads to..."
- **"intrinsic"** - "intrinsic relation between..."
- **"well-defined"** - "well-defined problem"
- **"principled"** - "principled basis for..."
- **"first principles"** - "from first principles"
- **"solely originated from"** - "solely from definition"

### Independence Keywords

- **"does not depend on"** - Theory independence from implementation
- **"independent of"** - Independent of specific choices
- **"self-contained"** - System independence
- **"from scratch"** - No external dependencies
- **"without any X"** - Negative list (what you don't need)

### Differentiation Keywords

- **"in contrast to"** - Conceptual contrast
- **"unlike"** - Direct comparison
- **"typically"** - "typically modeled" (their approach)
- **"prior works typically rely on"** - Their limitation
- **"imposed as"** - Artificial constraint (theirs)

### Avoid (Too Promotional)

- ❌ "revolutionary" - Let others say it
- ❌ "breakthrough" - Overused
- ❌ "completely eliminates" - Too absolute
- ✅ "significantly outperforms" - Strong but measured
- ✅ "substantial improvement" - Professional

---

## Design Simplification Paper Keywords

**Source**: Kaiming He et al., "Exploring Plain Vision Transformer Backbones for Object Detection" (ViTDet, 2022)

### Philosophy Keywords

- **"minimal"** - "minimal adaptations"
- **"sufficient"** - "is sufficient to" (not "optimal")
- **"simple"** - "simple feature pyramid"
- **"plain"** - "plain backbone"
- **"decouple"** - "decouple pre-training from fine-tuning"
- **"independence"** - "independence of upstream vs downstream"

### Direction Keywords

- **"pursue a different direction"** - Clear positioning
- **"in contrast to"** - Differentiation
- **"abandons"** - What you give up (respectfully)
- **"enables"** - What your approach allows

### Measured Claim Keywords

- **"under some circumstances"** - Not always
- **"can compete with"** - Competitive, not dominant
- **"more prominent for"** - When effect is stronger
- **"is sufficient"** - Necessary, not maximal


---

## Updated: 何凯明的写作技巧

> 来源: 分析了何凯明的 11 篇代表性论文（扩展分析，包括 MeanFlows、ViTDet、MAR 等）
> 添加时间: 2026-01-26

> 扩展内容包括：
> - "Surprisingly" 发现的多层次报告模式
> - Ablation Study 的增量式和破坏性实验设计
> - 理论驱动型论文的关键词策略
> - 设计简化型论文的关键词策略

### 句子结构偏好

**主动语态优先** (被动语态仅 9.3%)
何凯明偏好使用主动、直接的陈述：

**✅ 推荐 (何凯明的风格):**
- "We present a framework for [task]"
- "Our method achieves [result]"
- "This formulation enables [benefit]"

**❌ 避免:**
- "A framework is presented for [task]"
- "Results are achieved by our method"

### 贡献表达方式

何凯明常用的贡献表达模式：

**模式 1: 直接陈述**
```
We propose [method] that [feature].
We demonstrate [result] on [dataset].
```

**模式 2: 对比强调**
```
Unlike [previous work], our approach [difference].
This leads to [improvement] in [metric].
```

**模式 3: 问题-解决方案**
```
[Challenge] remains difficult. We address this by [solution].
```

### 技术术语使用

何凯明论文中的高频术语组合：

| 术语类别 | 常用术语 |
|---------|---------|
| **网络架构** | deep neural networks, convolutional, residual, activation |
| **训练过程** | training, validation, optimization, convergence |
| **性能评估** | outperforms, achieves, improves, surpasses |
| **方法定位** | state-of-the-art, baseline, framework, algorithm |
| **所有权** | our method, our approach, our framework |

### 过渡短语

何凯明论文中常用的过渡短语（按频率排序）：

1. **however** - 用于对比不同观点
2. **in addition/additionally** - 补充信息
3. **furthermore** - 递进说明
4. **therefore/thus** - 得出结论
5. **specifically** - 举例说明
6. **conversely** - 对比说明

### 数值结果呈现

何凯明在呈现数值结果时的模式：

**精确性优先:**
```
Our method achieves 76.4% accuracy (Table X).
This represents a 28% relative improvement.
```

**对比式呈现:**
```
Compared to baseline (73.2%), our method (76.4%) improves
by 3.2 percentage points.
```

**强调意义:**
```
This result won the 1st place in [competition/task].
```

### 图表引用模式

何凯明引用图表的标准格式：

**图表引入:**
- "Fig. X shows [现象]"
- "Table Y summarizes [结果]"
- "As shown in Fig. Z, [结论]"

**图表描述:**
- "The solid line denotes [条件 A], the dashed line [条件 B]"
- "The blue curve shows [指标], while the red curve shows [指标]"

### 网络架构描述

何凯明在描述网络架构时的特点：

1. **表格化呈现** - 使用表格列出层配置
2. **可视化辅助** - 配合架构图
3. **简洁符号** - 使用清晰的数学符号
4. **示例:**
```
layer name | output size | configuration
conv1      | 112×112   | 7×7, 64, /2
```
