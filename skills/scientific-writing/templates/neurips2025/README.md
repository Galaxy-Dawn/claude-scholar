# NeurIPS 2025 Template

## 📦 官方下载

**最新模板链接**: https://neurips.cc/Conferences/2025/PaperInformation/StyleFiles

**下载命令**:
```bash
wget https://nips.cc/Conferences/2025/PaperInformation/StyleFiles/neurips2025.zip
unzip neurips2025.zip
```

## 📋 模板文件清单

| 文件 | 说明 | 必须 |
|------|------|------|
| `neurips.sty` | 样式定义文件 | ✅ 必须 |
| `main.tex` | 主文档示例 | ✅ 参考 |
| `Makefile` | 编译脚本 | ⚪ 推荐 |
| `extra_pkgs.tex` | 额外包声明 | ⚪ 可选 |

## ⚙️ 核心配置

### 文档类声明
```latex
\documentclass{article}
\usepackage[nonatbib, final]{neurips}
```

### 页面限制
- **9 页**主内容（不含参考文献）
- **双栏**格式
- **匿名评审**模式（提交时）

### 编译方法
```bash
# 方法 1: 使用 Makefile（推荐）
make

# 方法 2: 使用 latexmk
latexmk -pdf main.tex

# 方法 3: 手动编译
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

## 📝 快速开始

### 1. 基础模板结构

```latex
\documentclass{article}
\usepackage[nonatbib, final]{neurips}
\usepackage[numbers]{natbib}
\usepackage{hyperref}
\usepackage{url}

\title{Your Paper Title}
\author{Anonymous Authors}
\begin{document}

\maketitle

\section{Introduction}
Your content here...

\section{Method}
Your method here...

\section{Experiments}
Your results here...

\bibliographystyle{plainnat}
\bibliography{references}

\end{document}
```

### 2. 摘要格式

```latex
\begin{abstract}
Your abstract here. Keep it concise and specific.
\end{abstract}
```

### 3. 参考文献

创建 `references.bib` 文件：

```bibtex
@article{key2024,
  title={Paper Title},
  author={Author Name},
  journal={Journal},
  year={2024}
}
```

在文中引用：
```latex
\cite{key2024}
```

## ⚠️ 常见问题

### Q1: 编译错误 "File `neurips.sty` not found"

**A**: 确保 `neurips.sty` 与 `main.tex` 在同一目录。

### Q2: 页数超限

**A**: NeurIPS 限制 9 页（不含参考文献）。解决方案：
- 将详细推导移至附录
- 精简相关工作
- 合并相似图表

### Q3: 双盲评审设置

**A**: 提交版本需要匿名：
```latex
\title{Your Title}
\author{Anonymous Authors}
% 不要包含真实作者信息
```

### Q4: 引用格式错误

**A**: NeurIPS 使用 numbered 引用：
```latex
\bibliographystyle{plainnat}  % 正确
% \bibliographystyle{acl}    % 错误
```

## 📚 相关资源

### Skill 内部文档
- `references/ml/ml_conferences.md` - NeurIPS 完整要求
- `references/ml/checklists.md` - 16项检查清单
- `references/ml/reviewer_guidelines.md` - 审稿标准

### 官方资源
- NeurIPS 官网: https://neurips.cc
- 投稿指南: https://neurips.cc/Conferences/2025/PaperInformation
- 样式文件: https://neurips.cc/Conferences/2025/PaperInformation/StyleFiles

## 💡 使用技巧

### 1. 行号设置（提交时自动）

模板会自动添加行号（提交模式）。

### 2. 摘要位置

NeurIPS 的摘要应该在 `\maketitle` 之前：

```latex
\begin{abstract}
...
\end{abstract}

\title{...}
\author{...}

\begin{document}
\maketitle
```

### 3. 章节编号

NeurIPS 使用标准的 `\section`, `\subsection` 等。

### 4. 图表编号

```latex
\begin{figure}[t]
\caption{Figure caption}
\label{fig:label}
\end{figure}

引用: Figure~\ref{fig:label}
```

## 📝 摄要写作提示

### Sebastian Farquhar 的 5 句话公式

1. **What you achieved**: "We introduce..."
2. **Why this is hard**: "This problem is challenging because..."
3. **How you do it**: "We propose..." (include keywords)
4. **What evidence**: "We demonstrate..."
5. **Most remarkable result**: "Our method achieves..."

### 避免

❌ "Large language models have achieved remarkable success..."
✅ "We introduce a novel architecture that..."

---

**最后更新**: 2025-01-25
**模板年份**: NeurIPS 2025
**版本**: v1.0
