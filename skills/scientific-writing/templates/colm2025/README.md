# COLM 2025 Template

## 📦 官方下载

**最新模板链接**: https://github.com/COLM-org/Template

**下载命令**:
```bash
git clone https://github.com/COLM-org/Template.git
cd Template
```

或下载 ZIP：
```bash
wget https://github.com/COLM-org/Template/archive/refs/heads/main.zip
unzip main.zip
```

## 📋 模板文件清单

| 文件 | 说明 | 必须 |
|------|------|------|
| `colm2025_conference.sty` | 样式定义文件 | ✅ 必须 |
| `colm2025_conference.tex` | 主文档示例 | ✅ 参考 |
| `colm2025_conference.bib` | 参考文献示例 | ⚪ 参考 |

## ⚙️ 核心配置

### 文档类声明
```latex
\documentclass{article}
\usepackage{colm2025_conference}
```

### 页面限制
- **9 页**主内容 + **1 页** camera-ready
- **双栏**格式
- **匿名评审**模式
- **语言模型焦点**

### LLM 使用披露

COLM **必须**披露 LLM 使用（如果作为核心方法论组件）：

```latex
\section*{LLM Disclosure}
This work used LLMs for...
```

## 📝 快速开始

### 1. 基础模板结构

```latex
\documentclass{article}
\usepackage{colm2025_conference}
\usepackage{hyperref}
\usepackage{url}

\title{Your Paper Title}
\author{Anonymous Author}
\begin{document}

\maketitle

\section{Introduction}
Your content here...

\section{Method}
Your method here...

\section{Experiments}
Your results here...

\section*{Limitations}
Your limitations here...

\section*{Ethics Statement}
(If applicable)

\section*{LLM Disclosure}
(If applicable)

\bibliographystyle{colm2025_conference}
\bibliography{references}

\end{document}
```

### 2. 参考文献

COLM 使用 `colm2025_conference.bst` 样式：

```latex
\bibliographystyle{colm2025_conference}
\bibliography{references}
```

## ⚠️ 常见问题

### Q1: 编译错误 "File `colm2025_conference.sty` not found"

**A**: 确保 `colm2025_conference.sty` 与主文档在同一目录。

### Q2: 页数超限

**A**: COLM 限制 9 页（不含参考文献），camera-ready 可增加 1 页。解决方案：
- 将详细推导移至附录
- 精简相关工作
- 合并相似图表

### Q3: 语言模型焦点

**A**: COLM 关注语言模型，论文应：
- 与语言模型相关
- 或对 LM 社区有贡献
- 明确说明与 LM 的关联

### Q4: 与 ICLR 的区别

**A**: COLM 和 ICLR 使用类似的模板，但：
- COLM 更专注于语言模型
- COLM 的审稿流程可能不同
- 关注点在 LM 应用和研究

## 📚 相关资源

### Skill 内部文档
- `references/ml/ml_conferences.md` - COLM 完整要求
- `references/ml/checklists.md` - 检查清单
- `references/ml/reviewer_guidelines.md` - 审稿标准

### 官方资源
- COLM 官网: https://colm2025.org（或当年会议网站）
- 模板仓库: https://github.com/COLM-org/Template
- 投稿指南: https://colm2025.org/submit

## 💡 使用技巧

### 1. 论文焦点

确保论文聚焦语言模型：
- LM 架构
- LM 训练方法
- LM 评估
- LM 应用

### 2. 伦理声明

COLM 鼓励讨论：
- 数据偏见
- 双重用途
- 环境影响

### 3. 与 ICLR 模板的相似性

COLM 模板基于 ICLR，因此：
- 结构相似
- 引用格式相同
- LLM 披露要求相同

---

**最后更新**: 2025-01-25
**模板年份**: COLM 2025
**版本**: v1.0
