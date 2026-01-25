# ICLR 2026 Template

## 📦 官方下载

**最新模板链接**: https://iclr.cc/Conferences/2026/AuthorGuide

**下载命令**:
```bash
wget https://iclr.cc/Conferences/2026/AuthorGuide/iclr2026.zip
unzip iclr2026.zip
```

## 📋 模板文件清单

| 文件 | 说明 | 必须 |
|------|------|------|
| `iclr2026_conference.sty` | 样式定义文件 | ✅ 必须 |
| `iclr2026_conference.tex` | 主文档示例 | ✅ 参考 |
| `iclr2026_conference.bst` | 参考文献样式 | ✅ 推荐 |
| `math_commands.tex` | 数学命令宏包 | ⚪ 推荐 |
| `natbib.sty` | 参考文献管理 | ⚪ 自动加载 |

## ⚙️ 核心配置

### 文档类声明
```latex
\documentclass{article}
\usepackage{iclr2026_conference}
```

### 页面限制
- **9 页**主内容 + **1 页** camera-ready
- **双栏**格式
- **匿名评审**模式（提交时）

### LLM 使用披露

ICLR **必须**披露 LLM 使用（如果作为核心方法论组件）：

```latex
\section*{LLM Disclosure}
This work used LLMs for...
```

**何时需要披露**：
- LLM 用于研究构思
- LLM 用于实质性写作
- LLM 可被视为贡献者

**何时不需要**：
- 仅用于语法检查
- 仅用于代码补全

### 编译方法

```bash
# 方法 1: 使用 latexmk（推荐）
latexmk -pdf iclr2026_conference.tex

# 方法 2: 手动编译
pdflatex iclr2026_conference.tex
bibtex iclr2026_conference
pdflatex iclr2026_conference.tex
pdflatex iclr2026_conference.tex
```

## 📝 快速开始

### 1. 基础模板结构

```latex
\documentclass{article}
\usepackage{iclr2026_conference}
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

\section*{LLM Disclosure}
(If applicable)

\bibliographystyle{iclr2026_conference}
\bibliography{references}

\end{document}
```

### 2. 数学命令

ICLR 提供了 `math_commands.tex`，包含有用宏：

```latex
\input{math_commands.tex}

% 然后可以使用：
\E{\mathbb{E}}
\R{\mathbb{R}}
\independent{\perp \!\!\! \perp}
```

### 3. Limitations 章节

ICLR **必须**包含 Limitations 章节：

```latex
\section*{Limitations}
Our approach has several limitations:
1. Computational cost
2. Hyperparameter sensitivity
3. Domain applicability

Despite these, our method achieves strong empirical results...
```

### 4. 参考文献

ICLR 使用 `iclr2026_conference.bst` 样式：

```latex
\bibliographystyle{iclr2026_conference}
\bibliography{references}
```

## ⚠️ 常见问题

### Q1: 编译错误 "File `iclr2026_conference.sty` not found"

**A**: 确保 `iclr2026_conference.sty` 与主文档在同一目录。

### Q2: 页数超限

**A**: ICLR 限制 9 页（不含参考文献），camera-ready 可增加 1 页。解决方案：
- 将详细推导移至附录
- 精简相关工作
- 合并相似图表

### Q3: LLM 披露位置

**A**: LLM Disclosure 应该作为独立章节（通常在最后）：
```latex
\section*{Ethics Statement}
(替代标题)
或
\section*{LLM Disclosure}
```

### Q4: 缺少数学宏

**A**: 如果需要额外数学符号，包含：
```latex
\input{math_commands.tex}
```

### Q5: OpenReview 兼容性

**A**: ICLR 使用 OpenReview，投稿时需要注意：
- 匿名性要求
- 作者回复可见
- 公开评审（接受后）

## 📚 相关资源

### Skill 内部文档
- `references/ml/ml_conferences.md` - ICLR 完整要求
- `references/ml/checklists.md` - 检查清单
- `references/ml/reviewer_guidelines.md` - 审稿标准

### 官方资源
- ICLR 官网: https://iclr.cc
- 投稿指南: https://iclr.cc/Conferences/2026/AuthorGuide
- 样式文件: https://iclr.cc/Conferences/2026/AuthorGuide

## 💡 使用技巧

### 1. 标题页设置

```latex
\title{Your Title}
\author{Anonymous Author}
\begin{document}
\maketitle
```

### 2. Reciprocal Reviewing

ICLR 要求互评：
- 每篇论文至少 1 位作者注册为审稿人
- 注册审稿人需要审阅 ≥3 篇论文

### 3. 接受后处理

接受后需要：
- 添加作者信息
- 更新 "Submitted to" 为 "Appearing in"
- 添加最终版本号

### 4. 关键词格式

```latex
\iclrkeywords{machine learning, deep learning, ICLR 2026}
```

### 5. 数学公式示例

```latex
% 使用 math_commands.tex 后：
Our objective is:
\[
    \min_{\theta} \E_{(x,y) \sim \mathcal{D}} \loss(f_\theta(x), y)
\]

where $\loss$ is the loss function.
```

---

**最后更新**: 2025-01-25
**模板年份**: ICLR 2026
**版本**: v1.0
