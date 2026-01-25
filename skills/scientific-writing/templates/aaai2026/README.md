# AAAI 2026 Template

## 📦 官方下载

**最新模板链接**: https://aaai.org/authorkit26/

**下载命令**:
```bash
wget https://aaai.org/authorkit26/aaai2026.zip
unzip aaai2026.zip
```

## 📋 模板文件清单

| 文件 | 说明 | 必须 |
|------|------|------|
| `aaai2026.sty` | 样式定义文件 | ✅ 必须 |
| `aaai2026-unified-template.tex` | 主文档示例 | ✅ 参考 |
| `README.md` | 使用说明 | ⚪ 推荐 |

## ⚠️ 重要警告

**AAAI 拥有最严格的格式合规性检查！**

- **不要修改** `aaai2026.sty` 文件
- **不要使用** `geometry` 包
- **不要使用** `fullpage` 包
- **不要修改** 页面布局参数

违反以上规则会导致**自动格式检查失败**，甚至直接拒稿。

## ⚙️ 核心配置

### 文档类声明
```latex
\documentclass{article}
\usepackage{aaai2026}
```

### 页面限制
- **7 页**主内容 + **1 页** camera-ready
- **双栏**格式
- **匿名评审**模式
- **最严格格式检查**

### 编译方法

```bash
# 方法 1: 使用 latexmk（推荐）
latexmk -pdf aaai2026-unified-template.tex

# 方法 2: 手动编译
pdflatex aaai6-unified-template.tex
bibtex aaai6-unified-template.tex
pdflatex aaai6-unified-template.tex
pdflatex aaai6-unified-template.tex
```

## 📝 快速开始

### 1. 基础模板结构

```latex
\documentclass{article}
\usepackage{aaai2026}
\usepackage{hyperref}
\usepackage{url}

\title{Your Paper Title}
\author{Anonymous Author}
\begin{document}

\maketitle

\section{Introduction}
Your content here...

\section{Related Work}
Your related work here...

\section{Method}
Your method here...

\section{Experiments}
Your results here...

\section{Conclusions}
Your conclusions here...

\bibliographystyle{aaai}
\bibliography{references}

\end{document}
```

### 2. 参考文献

AAAI 使用 `aaai` 参考文献样式：
```latex
\bibliographystyle{aaai}
\bibliography{references}
```

## ⚠️ 常见问题

### Q1: 格式检查失败

**A**: AAAI 会自动检查格式。常见问题：
- 使用了被禁止的包
- 修改了页边距
- 字体大小不符合要求

**解决方案**：
- 删除 `geometry` 包
- 删除 `fullpage` 包
- 不修改页面布局参数

### Q2: 页数超限

**A**: AAAI 限制 7 页（不含参考文献），camera-ready 可增加 1 页。**非常严格！**

### Q3: 编译错误

**A**: AAAI 模板非常严格。确保：
- 使用 `aaai2026.sty`（未修改）
- 不添加额外格式包
- 遵循模板示例

### Q4: 双盲评审

**A**: 提交时必须匿名：
- 无作者信息
- 无致谢
- 无基金号
- 引用格式使用第三人称

## 📚 相关资源

### Skill 内部文档
- `references/ml/ml_conferences.md` - AAAI 完整要求
- `references/ml/checklists.md` - 检查清单
- `references/ml/reviewer_guidelines.md` - 审稿标准

### 官方资源
- AAAI 官网: https://aaai.org
- 作者工具包: https://aaai.org/authorkit26/
- 投稿指南: https://aaai.org/conference/aaai-26/submit

## 💡 使用技巧

### 1. 严格遵守格式

AAAI 使用自动化格式检查，务必：
- 不要修改任何格式参数
- 使用官方模板
- 在提交前编译验证

### 2. 页面布局

模板已设置好所有页面参数：
```latex
% 不要添加这些：
% \usepackage{geometry}
% \usepackage{fullpage}
% \setlength{\oddsidemargin}{...}
```

### 3. 示例参考

官方模板 `aaai2026-unified-template.tex` 包含完整示例。

### 4. 提前验证

在提交前：
```bash
# 编译检查
latexmk -pdf aaai6-unified-template.tex

# 检查 PDF
pdfinfo aaai6-unified-template.pdf | grep Pages
```

---

**最后更新**: 2025-01-25
**模板年份**: AAAI 2026
**版本**: v1.0

**⚠️ 重要**: AAAI 拥有最严格的格式检查，务必遵守所有格式要求！
