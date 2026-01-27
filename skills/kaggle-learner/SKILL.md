---
name: kaggle-learner
description: This skill should be used when the user asks to "learn from Kaggle", "study Kaggle solutions", "analyze Kaggle competitions", or mentions Kaggle competition URLs. Provides access to extracted knowledge from winning Kaggle solutions across NLP, CV, time series, tabular, and multimodal domains.
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

**File组织结构**：每个竞赛一个独立的 markdown File，按 domain 分Class到对应Directory。

Example：
- `time-series/birdclef-plus-2025.md`
- `nlp/aimo-2-2025.md`

## Quick Reference

**To learn from a competition:**
1. Provide the Kaggle competition URL
2. The kaggle-miner agent will extract the winning solution
3. Knowledge is automatically added to the relevant category
4. **前排方案详细技术分析** (Front-runner Detailed Technical Analysis) is automatically included

**To browse existing knowledge:**
- 浏览相关 domain Directory：`references/knowledge/[domain]/`
- 每个竞赛一个独立File，Package含：
  - Competition Brief (竞赛简介)
  - **前排方案详细技术分析** (前排方案详细技术分析) ⭐
  - Code Templates (Code模板)
  - Best Practices (最佳实践)

## Self-Evolving

This skill automatically updates its knowledge base when the kaggle-miner agent processes new competitions. The more you use it, the smarter it becomes.

## Knowledge Extraction Standard

每次从 Kaggle 竞赛提取知识时，**必须**Package含以下标准部分：

### 必需Content清单

| 部分 | 说明 | 必需性 |
|------|------|--------|
| **Competition Brief** | 竞赛背景、任务Description、Data规模、Evaluate指标 | ✅ 必需 |
| **Original Summaries** | 前排方案的简要概述 | ✅ 必需 |
| **前排方案详细技术分析** | Top 20 方案的核心技巧和Implementation细节 | ✅ **必需** ⭐ |
| **Code Templates** | 可复用的Code模板 | ✅ 必需 |
| **Best Practices** | 最佳实践和常见陷阱 | ✅ 必需 |
| **Metadata** | Data源标签和日期 | ✅ 必需 |

### 前排方案详细技术分析格式

每个前排方案应Package含：
- **排名和团队/作者**
- **核心技巧列表** (3-6 个关Key技术点)
- **Implementation细节** (具体的Parameter、Configuration、Data)

Example格式：
```markdown
**排名 Place - 核心技术Name (作者)**

核心技巧：
- **技巧1**: 简短说明
- **技巧2**: 简短说明

Implementation细节：
- 具体Parameter、模型、Configuration
- Data和实验Result
```

**建议覆盖 Top 20 方案，Get更多前排选手的创新技巧**

## Additional Resources

### Knowledge Directories
- **`references/knowledge/nlp/`** - NLP competition techniques
- **`references/knowledge/cv/`** - Computer vision techniques
- **`references/knowledge/time-series/`** - Time series methods
- **`references/knowledge/tabular/`** - Tabular data approaches
- **`references/knowledge/multimodal/`** - Multimodal solutions

### Competition Examples
- **BirdCLEF+ 2025** (`time-series/birdclef-plus-2025.md`) - Package含完整的 Top 14 前排方案详细技术分析
- **BirdCLEF 2024** (`time-series/birdclef-2024.md`) - Package含 Top 3 方案详细技术分析
- **AIMO-2** (`nlp/aimo-2-2025.md`) - Package含 Top 12+ 前排方案技术总结
