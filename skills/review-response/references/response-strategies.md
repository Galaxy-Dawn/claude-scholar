# 审稿响应策略库

本文档提供针对不同类型审稿意见的系统化回复策略，帮助撰写专业、有效的rebuttal。

## 四大核心策略

### 1. Accept（接受策略）

**适用场景**:
- 审稿人指出的确实是问题或不足
- 修改成本低且能改进论文质量
- Typos和格式问题
- 合理的改进建议

**回复模板**:
```
We thank the reviewer for this valuable suggestion. We have [具体修改行动].
```

**示例**:

**审稿意见**:
> "The related work section is too brief and misses several important recent papers."

**回复**:
> "We thank the reviewer for pointing this out. We have significantly expanded the related work section and added discussions of the suggested papers [X, Y, Z]. The revised section now provides a more comprehensive overview of the field."


---

### 2. Defend（辩护策略）

**适用场景**:
- 当前做法有充分理由
- 审稿人的建议不适用于本研究
- 需要解释设计选择的合理性

**关键原则**:
- 保持礼貌和尊重
- 提供充分的理由和证据
- 避免"The reviewer is wrong"这样的表述

**回复模板**:
```
We appreciate the reviewer's concern. However, we respectfully note that [解释理由]. This choice is motivated by [具体原因].
```

**示例**:

**审稿意见**:
> "The authors should use method X instead of method Y."

**回复**:
> "We appreciate the reviewer's suggestion. However, we respectfully note that method Y is more suitable for our specific setting because [理由1] and [理由2]. While method X has advantages in [场景A], our preliminary experiments showed that method Y achieves better performance in our task due to [具体原因]. We have added this discussion to Section 3.2."


---

### 3. Clarify（澄清策略）

**适用场景**:
- 审稿人误解了论文内容
- 论文中已有相关内容但审稿人未注意到
- 需要指出论文中已有的说明或实验

**关键原则**:
- 礼貌地指出论文中已有的内容
- 提供具体的位置引用（章节、页码、图表）
- 避免让审稿人感到尴尬
- 可以考虑改进表述使其更清晰

**回复模板**:
```
We thank the reviewer for raising this point. We would like to respectfully clarify that [已有内容的说明]. This is discussed in [具体位置]. To make this clearer, we have [改进措施].
```

**示例**:

**审稿意见**:
> "The authors did not compare their method with baseline X."

**回复**:
> "We thank the reviewer for this comment. We would like to respectfully clarify that we did include comparisons with baseline X in our experiments. These results are presented in Table 2 (page 6) and discussed in Section 4.2. To make this comparison more prominent, we have added a dedicated paragraph highlighting the key differences and added baseline X to Figure 3 for visual comparison."

**注意事项**:
- 即使审稿人误解了，也要保持礼貌和尊重
- 如果可能，承认论文表述可以更清晰，并做出改进
- 提供具体的引用位置，方便审稿人查找


---

### 4. Experiment（实验策略）

**适用场景**:
- 审稿人要求补充关键实验或对比
- 实验要求合理且可行
- 补充实验能显著增强论文说服力
- Major Issues 中的实验要求

**关键原则**:
- 明确承诺会进行补充实验
- 说明实验设计和预期时间
- 如果已经完成，直接展示结果
- 如果时间紧迫，说明初步结果或计划

**回复模板**:
```
We thank the reviewer for this valuable suggestion. We agree that [实验的重要性]. We have conducted additional experiments on [实验内容]. The results show that [主要发现]. These new results have been added to [位置].
```

**示例 1（已完成实验）**:

**审稿意见**:
> "The authors should compare their method with the recent state-of-the-art method Z."

**回复**:
> "We thank the reviewer for this excellent suggestion. We agree that comparing with method Z is important for a comprehensive evaluation. We have conducted additional experiments comparing our method with Z on all three datasets. The results show that our method achieves comparable or better performance (Dataset A: +2.3%, Dataset B: +1.1%, Dataset C: -0.5%). These new results have been added to Table 3 and discussed in Section 4.3. We also provide detailed analysis of the performance differences in the revised manuscript."

**示例 2（承诺进行实验）**:

**审稿意见**:
> "The authors should conduct ablation studies to verify the contribution of each component."

**回复**:
> "We thank the reviewer for this important suggestion. We agree that ablation studies are crucial for understanding the contribution of each component. We are currently conducting comprehensive ablation experiments and will include the results in the revised manuscript. Based on our preliminary analysis, we expect to show that [预期发现]. We will complete these experiments within the rebuttal period and update the manuscript accordingly."

**注意事项**:
- 只承诺可行的实验，不要过度承诺
- 如果实验不可行，需要解释原因（时间、资源、技术限制）
- 提供实验时间表，让审稿人了解进度
- 如果已完成，立即展示结果以增强说服力


---

## 成功模式（基于ICLR Spotlight论文）

从ICLR 2024 spotlight论文的成功rebuttal中提取的关键模式：

### 模式1: 认可优点，正面回应批评

**观察**:
- 审稿人通常会先认可论文的优点（novelty, impact, practical applicability）
- 即使是spotlight论文，也会收到建设性批评
- 约20%的论文在rebuttal后排名发生变化

**应用策略**:
```
We thank the reviewer for recognizing [acknowledged strength]. Regarding [concern], we have [specific action taken].
```

**示例**:
> "We thank the reviewer for recognizing the novelty of our game-theoretic formulation. Regarding the brevity of Section 2.2, we have expanded it with 2-3 additional paragraphs providing more intuition for readers without a game theory background."

---

### 模式2: 提供清晰度和直觉理解

**观察**:
- 高质量论文仍可能存在clarity问题
- 审稿人需要为不同背景的读者提供intuition
- 建议：expand sections, move technical details to appendix

**应用策略**:
```
We apologize for the confusion. We have [clarification action]. To make this clearer, we have [additional improvements].
```

**示例**:
> "We apologize for the confusion in Section 3.2. We have completely rewritten this section with detailed mathematical formulation and added Algorithm 1 with pseudocode. We have also moved some technical details to Appendix B to improve readability."

---

### 模式3: 充分论证实验设置

**观察**:
- 审稿人期望实验设置有充分的justification
- 需要考虑和讨论alternative metrics
- Comprehensive experiments是spotlight论文的共同特征

**应用策略**:
```
We chose [experimental setup] because [justification]. We have also considered [alternative approach], but [reason for current choice]. We have added [additional experiments] to strengthen our evaluation.
```

**示例**:
> "We chose dataset W because it better represents our target scenario [justification]. We have also considered dataset Z, but it focuses on static graphs while our work targets dynamic graphs. We have added ablation studies showing that our improvement comes from fundamental architectural innovations."

---

### 模式4: 主动讨论伦理考量

**观察**:
- 对于涉及隐私、安全等敏感话题的研究，ethical considerations至关重要
- 审稿人会特别关注ethical implications
- Spotlight论文通常有thorough ethical discussions

**应用策略**:
```
We appreciate the concern about ethical implications. We have [ethical consideration actions]. We have also added [ethical safeguards/discussions].
```

**示例**:
> "We appreciate the concern about privacy implications. We have added a comprehensive ethics section discussing potential risks and mitigation strategies. We have also included anonymization experiments and detailed our data handling procedures in Appendix C."

---

### 模式5: 强调实际应用价值

**观察**:
- 审稿人重视practical applicability和scalability
- "Easily applicable"和"scalable"是重要的优点
- Spotlight论文通常demonstrate practical benefits

**应用策略**:
```
Our method is [practical benefit]. It is easily applicable because [reason] and scales to [scale] without [limitation].
```

**示例**:
> "Our method is practical and easily applicable to large language models without extensive tuning. It scales efficiently to models with up to 540B parameters, as demonstrated by our experiments. The consistent performance improvements across different model sizes highlight its practical value."

---

## 策略组合使用

在实际rebuttal中，通常需要组合使用多种策略：

### 组合示例 1: Accept + Clarify

**审稿意见**:
> "The paper lacks discussion of limitation X, and the authors did not mention related work Y."

**回复**:
> "We thank the reviewer for these valuable comments. Regarding limitation X, we agree this is an important point and have added a dedicated discussion in Section 5.3 (**Accept**). Regarding related work Y, we would like to respectfully clarify that we did discuss this work in Section 2.2 (page 3, paragraph 2). To make this more prominent, we have expanded the discussion and added it to the comparison table (**Clarify**)."

### 组合示例 2: Defend + Experiment

**审稿意见**:
> "The authors should use dataset Z instead of dataset W, and should add experiments on task T."

**回复**:
> "We appreciate the reviewer's suggestions. Regarding dataset Z, we respectfully note that dataset W is more suitable for our research question because [理由]. Dataset Z focuses on [场景A], while our work targets [场景B] (**Defend**). However, we agree that experiments on task T would strengthen our evaluation. We have conducted additional experiments on task T, and the results show [发现]. These new results have been added to Section 4.4 (**Experiment**)."


---

## 使用指南

### 策略选择流程

```
审稿意见 → 分类（Major/Minor/Typo/Misunderstanding）→ 选择策略
│
├─ Major Issues → Experiment (补充实验) 或 Defend (充分理由)
├─ Minor Issues → Accept (接受改进) 或 Clarify (澄清说明)
├─ Typos/Formatting → Accept (直接接受)
└─ Misunderstandings → Clarify (礼貌澄清)
```

### 策略优先级

1. **优先Accept**: 如果意见合理且改进成本低
2. **谨慎Defend**: 只在有充分理由时使用
3. **礼貌Clarify**: 即使审稿人误解，也要保持尊重
4. **诚实Experiment**: 只承诺可行的实验

### 语气原则

**始终保持**:
- ✅ 感谢审稿人的意见
- ✅ 尊重和礼貌的态度
- ✅ 具体的引用和证据
- ✅ 建设性的回应

**避免**:
- ❌ "The reviewer is wrong"
- ❌ "This is obvious"
- ❌ 防御性或攻击性语气
- ❌ 模糊或回避的回答

---

## 会议特定策略

不同顶会对rebuttal有不同的侧重点，了解这些差异可以帮助你更有针对性地回复。

### NeurIPS

**会议特点**:
- 强调概念新颖性和理论贡献
- 重视broader impact和社会影响
- 要求reproducibility checklist

**Rebuttal侧重点**:
1. **突出概念创新** - 强调你的方法在概念上的新颖性
2. **展示broader impact** - 说明研究的社会意义和潜在影响
3. **确保可复现性** - 承诺开源代码和数据

**示例开场**:
```markdown
We thank the reviewers for their constructive feedback. Our key contributions advance the field by [conceptual innovation]. We have strengthened the paper with [new experiments] and clarified [methodology]. All code and data will be released upon acceptance to ensure reproducibility.
```

**回复策略**:
- 当审稿人质疑新颖性时，强调概念上的突破而非仅仅是性能提升
- 主动讨论broader impact，即使审稿人没有明确要求
- 提供详细的实验设置和超参数，确保可复现

---

### ICML

**会议特点**:
- 强调方法论严谨性和理论基础
- 重视数学证明和理论分析
- 要求broader impact statement

**Rebuttal侧重点**:
1. **展示理论严谨性** - 提供数学证明和理论分析
2. **强调方法论贡献** - 说明方法的理论优势
3. **补充理论分析** - 添加定理、引理或理论保证

**示例开场**:
```markdown
We appreciate the reviewers' thorough evaluation. We have added theoretical analysis (Theorem 2, Appendix C) proving [property]. Our method's soundness is further validated by [experiments]. We have also expanded the broader impact statement to address [concern].
```

**回复策略**:
- 当审稿人质疑方法时，提供理论证明而非仅仅是实验结果
- 强调算法的理论复杂度和收敛性保证
- 将实验结果与理论预测联系起来

---

### ICLR

**会议特点**:
- 强调实验彻底性和全面评估
- 重视局限性的诚实讨论
- 要求LLM使用披露（如适用）

**Rebuttal侧重点**:
1. **补充实验** - 添加审稿人要求的对比实验和消融研究
2. **扩展局限性讨论** - 诚实承认方法的局限性
3. **披露LLM使用** - 如果使用了LLM，明确说明使用方式

**示例开场**:
```markdown
We thank the reviewers for their detailed comments. We have conducted additional experiments (Tables 4-6) addressing all concerns. We have also expanded the Limitations section (Section 5.2) and added LLM usage disclosure (Appendix D). These revisions significantly strengthen the empirical validation.
```

**回复策略**:
- 当审稿人要求更多实验时，优先添加而非辩解
- 主动扩展局限性讨论，展示对方法边界的清晰认识
- 如果使用了LLM辅助写作或实验，诚实披露并说明具体用途

**ICLR 2026特定策略**:

**1. 证据支持的澄清最有效**
- 研究表明，包含证据支持的澄清与分数提升最强相关
- 避免模糊或回避的回应，这些会维持或降低分数
- 明确引用原文中的具体章节或行号

**示例**:
```markdown
Thank you for this concern. We respectfully clarify that we did include this comparison in Section 4.2 (page 6, lines 234-245). To make this more prominent, we have added a dedicated paragraph and included the baseline in Figure 3 for visual comparison.
```

**2. 针对边界论文策略**
- Rebuttal对边界分数论文（5-6分范围）影响最大
- 如果论文处于边界，即使小的改进也可能影响最终决定
- 重点关注可以快速提升的方面

**3. 提交时机策略**
- 在rebuttal期间中期提交可能更有效
- 避免过早或最后一刻提交
- 中期提交可以提高审稿人参与度和分数变化

**4. 系统化回应结构**
每个回应应遵循三步结构：
1. **总结审稿人观点** - 展示你理解了他们的反馈
2. **陈述你的回应** - 清晰说明你的立场
3. **提供具体证据** - 给出实验、解释或修改计划

**示例**:
```markdown
**Reviewer's Concern**: The baseline comparison is insufficient.

**Our Response**: We appreciate this feedback. We understand the reviewer's concern about baseline coverage.

**Evidence**: We have added comparisons with three additional baselines (X, Y, Z) in Table 4 (Appendix). Results show our method achieves +2.3% improvement over the strongest baseline Z. We will integrate this into the main paper.
```

**5. 利用页面限制扩展**
- ICLR 2026将camera-ready版本从9页扩展到10页
- 可以利用额外的1页空间整合rebuttal中的新结果或讨论
- 在rebuttal中承诺将新内容添加到最终版本

**6. 可复现性声明**
- 强烈建议在主文本末尾（参考文献前）包含可复现性声明
- 讨论为确保可复现性所做的努力
- 引用论文、附录或补充材料中的相关部分

**7. ICLR 2026评分系统**
- 使用离散分数：{0, 2, 4, 6, 8, 10}
- 0=Strong Reject, 2=Reject, 4=Weak Reject, 6=Weak Accept, 8=Accept, 10=Strong Accept
- 理解评分系统有助于判断论文处于哪个范围

---

### CVPR

**会议特点**:
- 计算机视觉顶会，竞争激烈
- 严格的一页rebuttal限制
- 禁止外部链接和新的大规模实验
- 重视视觉效果和实验完整性

**Rebuttal侧重点**:
1. **识别"Champion"审稿人** - 找到支持你的审稿人，为他们提供强有力的论据
2. **重申核心贡献** - 在回应批评时，巧妙地提醒审稿人论文的重要贡献
3. **展示响应性** - 明确说明如何在最终版本中采纳建议

**示例开场**:
```markdown
We thank all reviewers for their valuable feedback. We are particularly grateful to R2 for recognizing our novel approach to [X]. Regarding the concerns raised, we provide clarifications below and will incorporate all valid suggestions in the camera-ready version.
```

**回复策略**:
- 识别持积极态度的审稿人，为他们提供论据帮助他们在讨论中辩护
- 在解决问题的同时，巧妙强化论文的核心优势
- 对关键概念的误解提供明确、有说服力的澄清
- 展示对审稿人建议的认真对待，列出具体改进计划

**特殊限制**:
- 必须使用官方模板，严格一页限制
- 不得包含外部链接（代码、视频、补充材料）
- 可以包含基于已有结果的图表和对比表格
- 审稿人不应要求大规模新实验

---

### ACL

**会议特点**:
- 自然语言处理顶会
- Best paper标准：fascinating, controversial, surprising, impressive, field-changing
- 重视方法的语言学意义和实际应用
- 要求Limitations和Ethics Statement

**Rebuttal侧重点**:
1. **小表格策略** - 如果审稿人要求额外结果，可以在rebuttal中包含小表格
2. **增强理解** - 目标是增强审稿人对论文的理解，而非大规模重写
3. **突出影响力** - 强调研究对NLP领域的潜在影响

**示例开场**:
```markdown
We thank the reviewers for their insightful comments. We have prepared additional analysis to address the raised concerns. Below we provide clarifications and include a small table (Table R1) demonstrating the requested comparison. These results will be integrated into the revised manuscript.
```

**回复策略**:
- 如果审稿人要求额外数据，可以在rebuttal中包含小表格展示
- 强调研究的语言学意义和对NLP社区的贡献
- 主动讨论伦理影响，特别是涉及偏见、公平性的研究
- 展示对不同语言和文化背景的考虑

**Best Paper考虑**:
- 论文是否"fascinating"（引人入胜）- 提出令人兴奋的新问题或视角
- 是否"controversial"（有争议性）- 挑战现有假设
- 是否"surprising"（令人惊讶）- 违反直觉但有说服力的发现
- 是否"impressive"（令人印象深刻）- 技术深度或实验规模
- 是否"field-changing"（改变领域）- 潜在的长期影响

---

## 参考资源

更多详细的成功案例和模板，请参考：
- `successful-cases.md` - 真实的成功rebuttal案例库
- `rebuttal-templates.md` - 完整的rebuttal模板
- `tone-guidelines.md` - 语气和表达指南
