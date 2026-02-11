---
name: rebuttal
description: Start systematic review response workflow for professional rebuttal writing
args:
  review_file:
    description: 审稿意见文件路径（可选）
    required: false
---

# /rebuttal - 审稿响应工作流

启动系统化的rebuttal撰写流程，从审稿意见分析到最终rebuttal文档生成。

## 用法

```bash
/rebuttal [review_file]
```

**参数**:
- `review_file` (可选): 包含审稿意见的文件路径
  - 如果不提供，将引导用户提供审稿意见

## 功能

此命令将启动完整的rebuttal撰写工作流：

1. **获取审稿意见** - 读取或接收审稿意见
2. **分析和分类** - 将意见分类为Major/Minor/Typo/Misunderstanding
3. **制定策略** - 为每条意见选择响应策略
4. **撰写rebuttal** - 生成结构化的回复文档
5. **语气优化** - 确保专业、礼貌的表达
6. **生成输出** - 保存最终的rebuttal文档


## 工作流程

### 步骤 1: 获取审稿意见

如果提供了`review_file`参数：
- 读取文件内容
- 识别审稿人数量和意见结构

如果未提供文件：
- 引导用户粘贴或描述审稿意见
- 确认审稿人数量

### 步骤 2: 分析和分类

使用`rebuttal-writer` agent进行分析：
- 按审稿人分组意见
- 分类为Major/Minor/Typo/Misunderstanding
- 识别优先级

### 步骤 3: 制定响应策略

为每条意见选择策略：
- **Accept** - 接受并改进
- **Defend** - 礼貌辩护
- **Clarify** - 澄清误解
- **Experiment** - 补充实验


### 步骤 4: 撰写Rebuttal

生成结构化的回复：
- 为每条意见撰写Response和Changes
- 包含具体的位置引用
- 提供证据和理由

### 步骤 5: 语气优化

检查和优化语气：
- 确保每个回复以感谢开始
- 避免防御性或攻击性表达
- 保持专业和尊重

### 步骤 6: 生成输出

保存最终文档：
- `rebuttal.md` - 完整的rebuttal文档
- `review-analysis.md` - 审稿意见分析（可选）
- `experiment-plan.md` - 补充实验计划（如果需要补充实验）


## 输出文件

执行此命令后，将生成以下文件：

### rebuttal.md
完整的rebuttal文档，包含：
- 开场白（感谢审稿人）
- 逐条回复（Response + Changes）
- 主要修改总结

### review-analysis.md（可选）
审稿意见分析文档，包含：
- 意见分类统计
- 策略选择说明
- 需要补充的实验列表

### experiment-plan.md（可选）
补充实验计划文档，包含：
- 需要补充的实验列表
- 每个实验的目的和预期结果
- 实验的优先级和时间估计

## 使用示例

### 示例 1: 提供审稿意见文件

```bash
/rebuttal reviews.txt
```

将读取`reviews.txt`文件中的审稿意见，并启动rebuttal撰写流程。

### 示例 2: 交互式输入

```bash
/rebuttal
```

将引导你粘贴或描述审稿意见，然后启动rebuttal撰写流程。


## 注意事项

### 重要原则

1. **不使用代码解析** - 审稿意见分析通过自然语言理解完成，不使用自动化脚本
2. **保持专业语气** - 所有回复都要礼貌、尊重、有理有据
3. **提供具体证据** - 每个回复都要包含具体的位置引用和证据
4. **完整性检查** - 确保所有审稿意见都得到回应

### 参考资源

此命令会自动使用以下参考文档：
- `review-classification.md` - 意见分类标准
- `response-strategies.md` - 响应策略指南
- `rebuttal-templates.md` - 回复模板库
- `tone-guidelines.md` - 语气优化指南

### Agent调用

此命令会自动调用`rebuttal-writer` agent来执行rebuttal撰写任务。

## 相关命令

- `/commit` - 提交修改后的论文
- `/code-review` - 审查代码质量

---

**提示**: 使用此命令前，建议先准备好审稿意见文件，并确保已经完成论文的必要修改。
