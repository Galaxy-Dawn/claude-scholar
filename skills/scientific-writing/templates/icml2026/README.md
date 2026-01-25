# ICML 2026 Template

## 📦 官方下载

**最新模板链接**: https://icml.cc/Conferences/2025/AuthorInstructions

**下载命令**:
```bash
wget https://icml.cc/Conferences/2025/AuthorInstructions/icml2026.zip
unzip icml2026.zip
```

## 📋 模板文件清单

| 文件 | 说明 | 必须 |
|------|------|------|
| `icml2026.sty` | 样式定义文件 | ✅ 必须 |
| `example_paper.tex` | 主文档示例 | ✅ 参考 |
| `icml2026.bst` | 参考文献样式 | ✅ 推荐 |
| `algorithm.sty` | 算法环境 | ⚪ 算法论文需要 |
| `algorithmic.sty` | 算法伪代码 | ⚪ 算法论文需要 |

## ⚙️ 核心配置

### 文档类声明
```latex
\documentclass{article}
\usepackage{icml2026}
```

### 页面限制
- **8 页**主内容 + **1 页** camera-ready
- **双栏**格式
- **匿名评审**模式（提交时）

### Broader Impact Statement

ICML **必须**包含 Broader Impact Statement（在结论后，参考文献前）：

```latex
\section*{Broader Impact Statement}
Your broader impact discussion here...
```

### 编译方法

```bash
# 方法 1: 使用 latexmk（推荐）
latexmk -pdf example_paper.tex

# 方法 2: 手动编译
pdflatex example_paper.tex
bibtex example_paper
pdflatex example_paper.tex
pdflatex example_paper.tex
```

## 📝 快速开始

### 1. 基础模板结构

```latex
\documentclass{article}
\usepackage{icml2026}
\usepackage{algorithm}
\usepackage{algorithmic}
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

\section*{Broader Impact Statement}
Discussion of broader impacts...

\bibliographystyle{icml2026}
\bibliography{example_paper}

\end{document}
```

### 2. 作者信息格式

ICML 使用特殊的作者格式（camera-ready 版本）：

```latex
\icmlauthor{First Author}%
  {affiliation}%
  {email@example.com}

\icmlauthor{Second Author}%
  {affiliation}%
  {email@example.com}
```

### 3. 算法伪代码

```latex
\begin{algorithm}[t]
\caption{Your Algorithm}
\label{alg:your-algorithm}
\begin{algorithmic}[1]
\REQUIRE Input
\ENSURE Output
\STATE Initialize
\FOR{each $i = 1$ to $n$}
    \STATE Process $i$
\ENDFOR
\RETURN Output
\end{algorithmic}
\end{algorithm}
```

### 4. 参考文献

ICML 使用 `icml2026.bst` 样式：

```latex
\bibliographystyle{icml2026}
\bibliography{example_paper}
```

## ⚠️ 常见问题

### Q1: 编译错误 "File `icml2026.sty` not found"

**A**: 确保 `icml2026.sty` 与主文档在同一目录。

### Q2: 页数超限

**A**: ICML 限制 8 页（不含参考文献），camera-ready 可增加 1 页。解决方案：
- 将详细推导移至附录
- 精简相关工作
- 合并相似图表

### Q3: 缺少算法包

**A**: 如果使用算法环境，确保包含：
```latex
\usepackage{algorithm}
\usepackage{algorithmic}
```

### Q4: Broader Impact Statement 位置

**A**: 必须在结论之后，参考文献之前：
```latex
\section{Conclusion}
...

\section*{Broader Impact Statement}
...

\bibliographystyle{icml2026}
\bibliography{references}
```

### Q5: 引用格式

**A**: ICML 使用 `icml2026.bst`：
```latex
\bibliographystyle{icml2026}  % 正确
% \bibliographystyle{plainnat}  % NeurIPS 风格
```

## 📚 相关资源

### Skill 内部文档
- `references/ml/ml_conferences.md` - ICML 完整要求
- `references/ml/checklists.md` - 检查清单
- `references/ml/reviewer_guidelines.md` - 审稿标准

### 官方资源
- ICML 官网: https://icml.cc
- 投稿指南: https://icml.cc/Conferences/2025/AuthorInstructions
- 样式文件: https://icml.cc/Conferences/2025/AuthorInstructions

## 💡 使用技巧

### 1. 运行标题

如果标题太长，使用：
```latex
\icmltitlerunning{Shorter Title for Running Head}
```

### 2. 多作者处理

```latex
\icmlauthor{Author One}%
  {University}%
  {email@university.edu}

\icmlauthor{Author Two}%
  {Company}%
  {email@company.com}
```

### 3. 预打印版本

如果需要上传到 arXiv，使用预打印模式：
```latex
\usepackage[preprint]{icml2026}
```

### 4. Camera Ready

接受后，切换到正式版本：
```latex
\usepackage[accepted]{icml2026}
```

### 5. 关键词设置

```latex
\icmlkeywords{keyword1, keyword2, keyword3}
```

---

**最后更新**: 2025-01-25
**模板年份**: ICML 2026
**版本**: v1.0
