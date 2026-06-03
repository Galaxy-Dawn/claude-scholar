---
name: kaggle-learner
description: This skill should be used when the user asks to "learn from Kaggle", "study Kaggle solutions", "analyze Kaggle competitions", "learn from code", "extract patterns", or mentions Kaggle competition URLs. Also covers extracting reusable patterns from coding sessions.
version: 0.1.0
---

# Kaggle Learner

Extract and apply knowledge from Kaggle competition winning solutions. This skill provides access to a continuously updated knowledge base of techniques, code patterns, and best practices from top Kaggle competitors.

## Overview

Kaggle competitions are at the forefront of practical machine learning. Winning solutions often innovate with novel techniques, clever feature engineering, and optimized pipelines. This skill captures that knowledge and makes it accessible for your projects.

## When to Use

Use this skill when:
- Studying for a Kaggle competition
- Looking for proven techniques in a specific domain (NLP, CV, etc.)
- Need code templates for common ML tasks
- Want to learn from competition winners

## Knowledge Categories

| Category | Focus | Directory |
|----------|-------|-----------|
| **NLP** | Text classification, NER, translation, LLM applications | `references/knowledge/nlp/` |
| **CV** | Image classification, detection, segmentation, generation | `references/knowledge/cv/` |
| **Time Series** | Forecasting, anomaly detection, sequence modeling | `references/knowledge/time-series/` |
| **Tabular** | Feature engineering, traditional ML, structured data | `references/knowledge/tabular/` |
| **Multimodal** | Cross-modal tasks, vision-language models | `references/knowledge/multimodal/` |

**文件组织结构**：每个竞赛一个独立的 markdown 文件，按 domain 分类到对应目录。

示例：
- `time-series/birdclef-plus-2025.md`
- `nlp/aimo-2-2025.md`

## Quick Reference

**To learn from a competition:**
1. Provide the Kaggle competition URL
2. The kaggle-miner agent will extract the winning solution
3. Knowledge is automatically added to the relevant category
4. **前排方案详细技术分析** (Front-runner Detailed Technical Analysis) is automatically included

**To browse existing knowledge:**
- 浏览相关 domain 目录：`references/knowledge/[domain]/`
- 每个竞赛一个独立文件，包含：
  - Competition Brief (竞赛简介)
  - **前排方案详细技术分析** (前排方案详细技术分析) ⭐
  - Code Templates (代码模板)
  - Best Practices (最佳实践)

## Self-Evolving

This skill automatically updates its knowledge base when the kaggle-miner agent processes new competitions. The more you use it, the smarter it becomes.

## Knowledge Extraction Standard

每次从 Kaggle 竞赛提取知识时，**必须**包含以下标准部分：

### 必需内容清单

| 部分 | 说明 | 必需性 |
|------|------|--------|
| **Competition Brief** | 竞赛背景、任务描述、数据规模、评估指标 | ✅ 必需 |
| **Original Summaries** | 前排方案的简要概述 | ✅ 必需 |
| **前排方案详细技术分析** | Top 20 方案的核心技巧和实现细节 | ✅ **必需** ⭐ |
| **Code Templates** | 可复用的代码模板 | ✅ 必需 |
| **Best Practices** | 最佳实践和常见陷阱 | ✅ 必需 |
| **Metadata** | 数据源标签和日期 | ✅ 必需 |

### 前排方案详细技术分析格式

每个前排方案应包含：
- **排名和团队/作者**
- **核心技巧列表** (3-6 个关键技术点)
- **实现细节** (具体的参数、配置、数据)

示例格式：
```markdown
**排名 Place - 核心技术名称 (作者)**

核心技巧：
- **技巧1**: 简短说明
- **技巧2**: 简短说明

实现细节：
- 具体参数、模型、配置
- 数据和实验结果
```

**建议覆盖 Top 20 方案，获取更多前排选手的创新技巧**

## Additional Resources

### Knowledge Directories
- **`references/knowledge/nlp/`** - NLP competition techniques
- **`references/knowledge/cv/`** - Computer vision techniques
- **`references/knowledge/time-series/`** - Time series methods
- **`references/knowledge/tabular/`** - Tabular data approaches
- **`references/knowledge/multimodal/`** - Multimodal solutions

### Competition Examples
- **BirdCLEF+ 2025** (`time-series/birdclef-plus-2025.md`) - 包含完整的 Top 14 前排方案详细技术分析
- **BirdCLEF 2024** (`time-series/birdclef-2024.md`) - 包含 Top 3 方案详细技术分析
- **AIMO-2** (`nlp/aimo-2-2025.md`) - 包含 Top 12+ 前排方案技术总结

---

## Pattern Learning (from /learn command)

Extract reusable patterns from coding sessions.

### When to Extract

Run pattern learning when you've solved a non-trivial problem during a session.

### What to Extract

1. **Error Resolution Patterns** - Root cause and fix for recurring errors
2. **Debugging Techniques** - Non-obvious diagnostic steps
3. **Workarounds** - Library quirks, API limitations, version-specific fixes
4. **Project-Specific Patterns** - Codebase conventions, architecture decisions

### Output Format

Save extracted patterns to `~/.kimi-code/skills/learned/[pattern-name].md`:

```markdown
# [Descriptive Pattern Name]

**Extracted:** [Date]
**Context:** [When this applies]

## Problem
[What problem this solves]

## Solution
[The pattern/technique/workaround]

## Example
[Code example if applicable]

## When to Use
[Trigger conditions]
```

### Guidelines

- Don't extract trivial fixes (typos, simple syntax errors)
- Don't extract one-time issues (specific API outages)
- Focus on patterns that save time in future sessions
- Keep skills focused - one pattern per skill
