# Rebuttal 模板库

本文档提供系统化的rebuttal模板，帮助快速撰写专业、结构清晰的审稿响应。

## 基本结构

### 标准Rebuttal结构

```markdown
# Response to Reviewers

We sincerely thank all reviewers for their valuable feedback and constructive suggestions. We have carefully addressed all comments and made substantial revisions to improve the manuscript. Below, we provide detailed responses to each reviewer's comments.

---

## Response to Reviewer 1

### Major Comments

**Comment 1.1**: [审稿人的原始意见]

**Response**: [我们的回复]

**Changes**: [具体修改内容和位置]

---

**Comment 1.2**: [审稿人的原始意见]

**Response**: [我们的回复]

**Changes**: [具体修改内容和位置]

---

### Minor Comments

**Comment 1.3**: [审稿人的原始意见]

**Response**: [我们的回复]

**Changes**: [具体修改内容和位置]

---

## Response to Reviewer 2

[同样的结构]

---

## Response to Reviewer 3

[同样的结构]

---

## Summary of Major Changes

1. [主要修改1]
2. [主要修改2]
3. [主要修改3]

We believe these revisions have significantly strengthened the manuscript and addressed all concerns raised by the reviewers.
```

---

## 开场白模板

### 模板 1: 标准感谢

```
We sincerely thank all reviewers for their valuable feedback and constructive suggestions. We have carefully addressed all comments and made substantial revisions to improve the manuscript. Below, we provide detailed responses to each reviewer's comments.
```

### 模板 2: 强调改进

```
We are grateful to the reviewers for their thorough and insightful comments. Their feedback has helped us significantly improve the quality and clarity of our work. We have made extensive revisions to address all concerns, and we believe the manuscript is now substantially stronger.
```

### 模板 3: 突出重点

```
We thank the reviewers for their careful evaluation and constructive feedback. We have addressed all comments and made major revisions, including [关键改进1], [关键改进2], and [关键改进3]. We provide detailed responses below.
```


---

## 回复模板（按策略分类）

### Accept 策略模板

**模板 1: 简单接受**
```
We thank the reviewer for this valuable suggestion. We have [具体修改]. [修改位置].
```

**模板 2: 接受并扩展**
```
We appreciate this insightful comment. We agree that [问题描述] is important. We have [具体修改1] and [具体修改2]. These changes are reflected in [位置1] and [位置2].
```

**模板 3: 接受拼写/格式错误**
```
We thank the reviewer for catching this. We have corrected [错误类型] throughout the manuscript.
```

---

### Defend 策略模板

**模板 1: 礼貌辩护**
```
We appreciate the reviewer's concern. However, we respectfully note that [我们的做法] is motivated by [理由]. Specifically, [详细解释]. We have added this clarification to Section [X].
```

**模板 2: 对比说明**
```
We thank the reviewer for this suggestion. While [审稿人建议的方法] has advantages in [场景A], we chose [我们的方法] because [理由1] and [理由2]. Our preliminary experiments showed that [实验结果]. We have added this discussion to [位置].
```

**模板 3: 技术限制**
```
We appreciate this suggestion. However, [建议的方法] is not feasible in our setting due to [限制1] and [限制2]. Instead, we [我们的替代方案], which [优势]. We have clarified this in [位置].
```


---

### Clarify 策略模板

**模板 1: 礼貌澄清**
```
We thank the reviewer for raising this point. We would like to respectfully clarify that [已有内容]. This is discussed in [具体位置]. To make this clearer, we have [改进措施].
```

**模板 2: 指出已有内容**
```
We appreciate this comment. We would like to note that we did [已完成的工作] in our study. Specifically, [详细说明]. These results are presented in [位置]. To make this more prominent, we have [改进措施].
```

**模板 3: 承认表述不清**
```
We thank the reviewer for this comment. We apologize for the confusion. What we meant is [澄清说明]. We have revised [位置] to make this clearer.
```

---

### Experiment 策略模板

**模板 1: 已完成实验**
```
We thank the reviewer for this excellent suggestion. We have conducted additional experiments on [实验内容]. The results show that [主要发现]. Specifically, [详细结果]. These new results have been added to [位置] and discussed in [位置].
```

**模板 2: 承诺进行实验**
```
We appreciate this valuable suggestion. We agree that [实验的重要性]. We are currently conducting [实验内容] and will include the results in the revised manuscript. We expect to complete these experiments within [时间] and will update the manuscript accordingly.
```

**模板 3: 实验不可行但提供替代**
```
We thank the reviewer for this suggestion. While [建议的实验] would be valuable, it is not feasible due to [限制]. However, we have conducted [替代实验], which provides similar insights. The results show [发现]. These have been added to [位置].
```


---

## 特殊场景模板

### 多个审稿人提出相同意见

**模板**:
```
We thank Reviewers [X] and [Y] for raising this important point. We agree that [问题描述]. We have [具体修改]. These changes address both reviewers' concerns and are reflected in [位置].
```

**示例**:
```
We thank Reviewers 1 and 3 for raising this important point about the lack of ablation studies. We agree that ablation studies are crucial for understanding component contributions. We have conducted comprehensive ablation experiments examining [组件1], [组件2], and [组件3]. These changes address both reviewers' concerns and are reflected in Table 4 and Section 4.5.
```

---

### 审稿人意见相互矛盾

**模板**:
```
We appreciate both reviewers' perspectives on [问题]. Reviewer [X] suggests [建议X], while Reviewer [Y] suggests [建议Y]. After careful consideration, we have [我们的选择] because [理由]. We believe this approach [优势] while addressing [关注点].
```

**示例**:
```
We appreciate both reviewers' perspectives on the dataset choice. Reviewer 1 suggests using dataset A for broader applicability, while Reviewer 2 suggests using dataset B for more controlled evaluation. After careful consideration, we have added experiments on both datasets. We believe this approach provides both breadth (dataset A) and depth (dataset B) while addressing both reviewers' concerns. The new results are presented in Table 5.
```

---

### 无法完全满足要求

**模板**:
```
We thank the reviewer for this suggestion. While we agree that [建议的价值], [完全实现的困难]. However, we have [部分实现或替代方案], which [效果]. We acknowledge this limitation in [位置] and discuss it as future work.
```

**示例**:
```
We thank the reviewer for suggesting experiments on dataset X. While we agree that this would be valuable, dataset X is not publicly available and requires institutional access that we currently do not have. However, we have conducted experiments on dataset Y, which has similar characteristics and is widely used in the community. The results show [发现]. We acknowledge this limitation in Section 5.3 and discuss experiments on dataset X as future work.
```


---

## 结尾模板

### 单个审稿人的结尾

**模板 1: 标准结尾**
```
We hope our responses and revisions have adequately addressed all of your concerns. We are grateful for your valuable feedback, which has helped us improve the manuscript significantly.
```

**模板 2: 强调改进**
```
We believe the revisions we have made in response to your comments have substantially strengthened the manuscript. We thank you again for your thorough review and constructive suggestions.
```

---

### 整体Rebuttal的结尾

**模板 1: 总结主要修改**
```
## Summary of Major Changes

In response to the reviewers' feedback, we have made the following major revisions:

1. [主要修改1] (Reviewers [X, Y])
2. [主要修改2] (Reviewer [Z])
3. [主要修改3] (All reviewers)

We believe these revisions have significantly strengthened the manuscript and addressed all concerns raised by the reviewers. We are grateful for the reviewers' valuable feedback and hope that the revised manuscript is now suitable for publication.
```

**模板 2: 强调新增内容**
```
## Summary of Major Changes

We have made substantial revisions to address all reviewers' comments:

**New Experiments**: [新实验描述]
**Expanded Discussions**: [扩展讨论描述]
**Clarifications**: [澄清内容描述]

These changes have improved the manuscript's [质量方面], and we believe it now meets the high standards of [期刊/会议名称].
```


---

## 完整Rebuttal示例

### 示例场景

假设收到3位审稿人的意见：
- Reviewer 1: 2个Major comments, 3个Minor comments
- Reviewer 2: 1个Major comment, 2个Minor comments  
- Reviewer 3: 3个Minor comments

### 完整Rebuttal文档

```markdown
# Response to Reviewers

We sincerely thank all reviewers for their valuable feedback and constructive suggestions. We have carefully addressed all comments and made substantial revisions to improve the manuscript. Below, we provide detailed responses to each reviewer's comments.

---

## Response to Reviewer 1

We thank Reviewer 1 for the thorough review and insightful comments.

### Major Comments

**Comment 1.1**: The paper lacks comparison with recent state-of-the-art method X. This comparison is essential for evaluating the proposed method.

**Response**: We thank the reviewer for this excellent suggestion. We have conducted additional experiments comparing our method with X on all three datasets. The results show that our method achieves comparable or better performance (Dataset A: +2.3%, Dataset B: +1.1%, Dataset C: -0.5%). 

**Changes**: These new results have been added to Table 3 (page 7) and discussed in Section 4.3 (pages 7-8). We also provide detailed analysis of the performance differences.

---

**Comment 1.2**: The authors should provide more details about the training procedure, including hyperparameters and convergence criteria.

**Response**: We appreciate this comment and agree that more implementation details would be helpful. We have added a comprehensive description of our training procedure.

**Changes**: We have added Section 3.4 "Training Details" (page 5) which includes:
- Complete hyperparameter settings (Table 2)
- Convergence criteria and early stopping strategy
- Training time and computational resources
- Code availability statement


---

### Minor Comments

**Comment 1.3**: There are several typos in Section 2. For example, "recieve" should be "receive" on page 3.

**Response**: We thank the reviewer for catching these errors. We have carefully proofread the entire manuscript and corrected all typos.

**Changes**: All typos have been corrected throughout the manuscript.

---

**Comment 1.4**: Figure 2 is difficult to read. The font size should be increased.

**Response**: We appreciate this feedback. We have improved the figure quality.

**Changes**: Figure 2 has been redesigned with larger fonts and clearer labels (page 6).

---

**Comment 1.5**: The related work section should discuss paper Y, which is highly relevant.

**Response**: We thank the reviewer for this suggestion. We have expanded the related work section to include discussion of paper Y.

**Changes**: We have added a paragraph discussing paper Y in Section 2.2 (page 3) and included it in the comparison table (Table 1).

---

We hope our responses and revisions have adequately addressed all of your concerns. We are grateful for your valuable feedback.


---

## Response to Reviewer 2

We thank Reviewer 2 for the constructive feedback.

### Major Comments

**Comment 2.1**: The authors claim that their method is more efficient than baseline methods, but no runtime analysis is provided. Please add computational complexity analysis and runtime comparisons.

**Response**: We appreciate this important comment. We have added comprehensive efficiency analysis.

**Changes**: We have added Section 4.4 "Efficiency Analysis" (page 8) which includes:
- Theoretical computational complexity analysis (O-notation)
- Runtime comparison with baseline methods (Table 4)
- Memory consumption analysis (Figure 4)
- Discussion of efficiency-performance trade-offs

The results show that our method achieves 3.2x speedup compared to the previous state-of-the-art while maintaining comparable accuracy.

---

### Minor Comments

**Comment 2.2**: The notation in Equation 3 is inconsistent with the rest of the paper.

**Response**: We thank the reviewer for pointing this out. We have standardized the notation throughout the manuscript.

**Changes**: Equation 3 (page 4) has been revised to use consistent notation. We have also added a notation table in the appendix for clarity.

---

**Comment 2.3**: The discussion of limitations is too brief.

**Response**: We agree that a more thorough discussion of limitations would strengthen the paper.

**Changes**: We have expanded Section 5.3 "Limitations and Future Work" (page 10) to include:
- Detailed discussion of current limitations
- Potential failure cases
- Directions for future research

---

We believe the revisions we have made in response to your comments have substantially strengthened the manuscript. Thank you for your thorough review.


---

## Response to Reviewer 3

We thank Reviewer 3 for the careful review and helpful suggestions.

### Minor Comments

**Comment 3.1**: The abstract should be more concise and focus on the key contributions.

**Response**: We appreciate this feedback. We have revised the abstract to be more focused and concise.

**Changes**: The abstract has been rewritten (page 1) to highlight the three key contributions and remove unnecessary details.

---

**Comment 3.2**: Some figures are not referenced in the text.

**Response**: We thank the reviewer for catching this. We have ensured all figures are properly referenced.

**Changes**: We have added references to Figure 5 in Section 4.2 (page 7) and Figure 6 in Section 4.5 (page 9).

---

**Comment 3.3**: The conclusion should discuss broader impact and societal implications.

**Response**: We agree that discussing broader impact is important.

**Changes**: We have added Section 6 "Broader Impact" (page 11) discussing potential societal implications, ethical considerations, and responsible use of our method.

---

We are grateful for your valuable feedback, which has helped us improve the manuscript significantly.

---

## Summary of Major Changes

In response to the reviewers' feedback, we have made the following major revisions:

1. **Added comparison with state-of-the-art method X** (Reviewer 1) - New experiments on all datasets, results in Table 3 and Section 4.3

2. **Added comprehensive training details** (Reviewer 1) - New Section 3.4 with hyperparameters, convergence criteria, and code availability

3. **Added efficiency analysis** (Reviewer 2) - New Section 4.4 with complexity analysis, runtime comparisons (Table 4), and memory analysis (Figure 4)

4. **Expanded limitations discussion** (Reviewer 2) - Enhanced Section 5.3 with detailed limitations and future work

5. **Added broader impact section** (Reviewer 3) - New Section 6 discussing societal implications

6. **Improved figures and fixed typos** (Reviewers 1, 3) - Enhanced Figure 2, added figure references, corrected all typos

We believe these revisions have significantly strengthened the manuscript and addressed all concerns raised by the reviewers. We are grateful for the reviewers' valuable feedback and hope that the revised manuscript is now suitable for publication.
```


---

## 使用指南

### 如何使用这些模板

1. **选择合适的结构**: 根据审稿人数量和意见复杂度选择基本结构
2. **分类意见**: 将每个审稿人的意见分为Major和Minor
3. **选择策略**: 根据意见类型选择Accept/Defend/Clarify/Experiment策略
4. **套用模板**: 使用对应策略的模板撰写回复
5. **添加具体内容**: 填充模板中的占位符（[具体修改]、[位置]等）
6. **检查一致性**: 确保所有回复的语气和格式一致

### 模板定制建议

**根据会议/期刊调整**:
- 顶会（NeurIPS, ICML）: 更注重技术细节和实验结果
- 期刊（Nature, Science）: 更注重broader impact和清晰表达
- 领域会议: 根据领域特点调整专业术语

**根据审稿轮次调整**:
- 第一轮: 更详细的解释和更多的新实验
- 第二轮: 重点回应未解决的问题，简洁明了
- 第三轮: 强调已做的改进，表达合作态度

### 常见错误

❌ **避免**:
- 过于简短的回复（"Done" 或 "Fixed"）
- 没有具体位置引用
- 防御性或攻击性语气
- 承诺无法完成的实验
- 忽略某些意见

✅ **推荐**:
- 每个回复都包含Response和Changes两部分
- 提供具体的章节、页码、表格、图表引用
- 保持礼貌和专业的语气
- 只承诺可行的改进
- 回应所有意见，即使是小的typo

