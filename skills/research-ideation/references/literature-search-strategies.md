# 文献搜索策略

系统化的文献搜索方法，帮助研究者高效地找到相关文献。

## 1. 关键词构建

### 1.1 核心概念识别

从研究兴趣中提取核心概念：

**示例**：研究兴趣 "Transformer 模型的可解释性"
- 核心概念 1：Transformer
- 核心概念 2：Interpretability / Explainability

### 1.2 同义词和变体

为每个核心概念列出同义词和变体：

| 核心概念 | 同义词/变体 |
|---------|------------|
| Transformer | Attention mechanism, Self-attention, BERT, GPT |
| Interpretability | Explainability, Transparency, Understanding |

### 1.3 布尔运算符

使用布尔运算符组合关键词：

```
(Transformer OR "attention mechanism" OR BERT OR GPT)
AND
(interpretability OR explainability OR transparency)
```

### 1.4 领域特定术语

添加领域特定的术语：

- **方法术语**：probing, attention visualization, saliency maps
- **应用领域**：NLP, computer vision, speech recognition
- **评估指标**：faithfulness, plausibility, human evaluation

## 2. 学术数据库选择

### 2.1 主要数据库

| 数据库 | 特点 | 适用场景 |
|--------|------|---------|
| **arXiv** | 预印本，更新快 | 获取最新研究进展 |
| **Semantic Scholar** | AI 驱动，引用分析 | 发现相关论文，分析影响力 |
| **Google Scholar** | 覆盖面广 | 全面搜索，找遗漏论文 |
| **ACL Anthology** | NLP 专业 | NLP 领域深度搜索 |
| **IEEE Xplore** | 工程技术 | 计算机视觉、硬件相关 |

### 2.2 搜索策略

**arXiv 搜索**：
```
cat:cs.LG AND (transformer OR attention) AND (interpretability OR explainability)
```

**Semantic Scholar 搜索**：
- 使用自然语言查询
- 利用"Highly Influential Citations"筛选
- 查看"Related Papers"发现相关工作

**Google Scholar 搜索**：
- 使用引号精确匹配："transformer interpretability"
- 限制时间范围：2020-2024
- 排除专利：-patent

## 3. 搜索技巧

### 3.1 迭代搜索

1. **初始搜索** - 使用核心关键词
2. **分析结果** - 查看高引用论文的关键词
3. **优化查询** - 添加新发现的术语
4. **重复迭代** - 直到找到足够相关的论文

### 3.2 引用追踪

**前向引用**（Forward Citation）：
- 查看哪些新论文引用了这篇论文
- 了解研究的后续发展

**后向引用**（Backward Citation）：
- 查看这篇论文引用了哪些论文
- 了解研究的基础和背景

### 3.3 作者追踪

- 识别领域内的关键研究者
- 查看他们的其他相关工作
- 关注他们的最新研究

## 4. 论文筛选标准

### 4.1 初步筛选（基于标题和摘要）

**包含标准**：
- 直接相关于研究主题
- 发表在顶级会议/期刊（NeurIPS, ICML, ICLR, ACL, AAAI）
- 引用次数较高（相对于发表时间）
- 作者来自知名机构或研究组

**排除标准**：
- 与研究主题无关
- 发表在低质量会议/期刊
- 明显过时的方法（除非是经典论文）

### 4.2 深度筛选（基于全文）

**质量评估**：
1. **方法创新性** - 是否提出新方法或新视角
2. **实验充分性** - 实验设计是否合理，结果是否可信
3. **写作质量** - 论文是否清晰易懂
4. **可重现性** - 是否提供代码和数据

**相关性评估**：
1. **直接相关** - 核心方法或问题直接相关
2. **间接相关** - 相关技术或应用场景
3. **背景知识** - 提供必要的背景和基础

### 4.3 文献管理

**推荐工具**：
- Zotero - 开源，支持浏览器插件
- Mendeley - 社交功能，PDF 标注
- Papers - Mac 专用，界面优雅

**组织策略**：
- 按主题分类（方法、应用、评估）
- 按重要性标记（必读、重要、参考）
- 添加标签和笔记

