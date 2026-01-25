# ACL 2025 Template

## 📦 官方下载

**最新模板链接**: https://github.com/acl-org/acl-style-files

**下载命令**:
```bash
git clone https://github.com/acl-org/acl-style-files.git
cd acl-style-files
```

或从官网下载：
```bash
wget https://github.com/acl-org/acl-style-files/archive/refs/heads/main.zip
unzip main.zip
```

## 📋 模板文件清单

| 文件 | 说明 | 必须 |
|------|------|------|
| `acl.sty` | 样式定义文件 | ✅ 必须 |
| `acl_latex.tex` | 主文档示例 | ✅ 参考 |
| `acl.bst` | 参考文献样式 | ✅ 推荐 |
| `README.md` | 使用说明 | ⚪ 推荐 |

## ⚙️ 核心配置

### 文档类声明
```latex
\documentclass{article}
\usepackage{acl}
```

### 页面限制
- **8 页**长论文
- **4 页**短论文
- **双栏**格式
- **匿名评审**模式

### Limitations 章节

ACL **必须**包含 Limitations 章节（不计页数）：

```latex
\section{Limitations}
Your limitations discussion here...
```

### 编译方法

```bash
# 方法 1: 使用 latexmk（推荐）
latexmk -pdf acl_latex.tex

# 方法 2: 手动编译
pdflatex acl_latex.tex
bibtex acl_latex
pdflatex acl_latex.tex
pdflatex acl_latex.tex
```

## 📝 快速开始

### 1. 基础模板结构

```latex
\documentclass{article}
\usepackage{acl}
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

\section{Limitations}
Your limitations here...

\bibliographystyle{acl}
\bibliography{references}

\end{document}
```

### 2. 摘要格式

```latex
\begin{abstract}
Your abstract here.
\end{abstract}
```

### 3. 参考文献

ACL 使用 `acl.bst` 样式：

```latex
\bibliographystyle{acl}
\bibliography{references}
```

## ⚠️ 常见问题

### Q1: 编译错误 "File `acl.sty` not found"

**A**: 确保 `acl.sty` 与主文档在同一目录。

### Q2: 页数超限

**A**: ACL 长论文限制 8 页（不含参考文献）。解决方案：
- 将详细推导移至附录
- 精简相关工作
- 移除冗余图表

### Q3: Limitations 章节

**A**: Limitations 章节**必须**存在且不计入页数：
```latex
\section{Limitations}
...
```

### Q4: 匿名评审

**A**: 提交时需要匿名：
- 移除所有作者信息
- 使用 "Anonymous Authors"
- 匿名 GitHub 链接
- 移除致谢部分

### Q5: NLP 特定要求

**A**: ACL 关注：
- 语言多样性
- 偏见公平性
- 双重用途关注
- 人类评估伦理

## 📚 相关资源

### Skill 内部文档
- `references/ml/ml_conferences.md` - ACL 完整要求
- `references/ml/checklists.md` - 检查清单
- `references/ml/reviewer_guidelines.md` - 审稿标准

### 官方资源
- ACL 官网: https://acl2025.org
- ACL Rolling Review: https://aclrollingreview.org/
- 样式文件: https://github.com/acl-org/acl-style-files

## 💡 使用技巧

### 1. 语言示例

如果有非英语示例：
```latex
\exg.{}{Chinese example}%
```

### 2. 伦理声明

如果涉及人类受试者：
```latex
\section*{Ethics Statement}
This study was approved by...
```

### 3. 多语言支持

ACL 鼓励：
- 多语言数据集
- 跨语言评估
- 翻译质量报告

---

**最后更新**: 2025-01-25
**模板年份**: ACL 2025
**版本**: v1.0
