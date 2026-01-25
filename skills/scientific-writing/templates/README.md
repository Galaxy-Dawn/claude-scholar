# LaTeX Templates Index

本目录包含 ML 顶会 LaTeX 模板的获取和使用指南。

## 📁 可用会议模板

| 会议 | 目录 | 状态 | 下载链接 |
|------|------|------|----------|
| **NeurIPS 2025** | `neurips2025/` | 📦 官方 | [下载](https://neurips.cc/Conferences/2025/PaperInformation/StyleFiles) |
| **ICML 2026** | `icml2026/` | 📦 官方 | [下载](https://icml.cc/Conferences/2025/AuthorInstructions) |
| **ICLR 2026** | `iclr2026/` | 📦 官方 | [下载](https://iclr.cc/Conferences/2026/AuthorGuide) |
| **ACL 2025** | `acl/` | 📦 官方 | [GitHub](https://github.com/acl-org/acl-style-files) |
| **AAAI 2026** | `aaai2026/` | 📦 官方 | [下载](https://aaai.org/authorkit26/) |
| **COLM 2025** | `colm2025/` | 📦 官方 | [GitHub](https://github.com/COLM-org/Template) |

## 🚀 快速开始

### 方法 1: 直接下载（推荐）

1. 访问目标会议的官方网站（见上表）
2. 下载最新的模板 .zip 文件
3. 解压到您的论文工作目录
4. 参考 `references/ml/latex_templates.md` 进行使用

### 方法 2: 使用本 skill 的指南

```bash
# 1. 查看目标会议的模板说明
cat ~/.claude/skills/scientific-writing/templates/neurips2025/README.md

# 2. 访问官方下载链接
wget [官方链接]

# 3. 解压并使用
unzip template.zip
cd template_directory
```

## 📖 各会议模板说明

点击下方会议名称查看详细模板信息：

- [NeurIPS 2025](neurips2025/) - 9页限制，严格要求
- [ICML 2026](icml2026/) - 8页限制，需要 Broader Impact
- [ICLR 2026](iclr2026/) - 9页限制，需要 LLM 披露
- [ACL 2025](acl/) - 8页限制，强制 Limitations 章节
- [AAAI 2026](aaai2026/) - 7页限制，最严格格式
- [COLM 2025](colm2025/) - 9页限制，语言模型焦点

## ⚠️ 重要提示

### 模板更新

会议模板**每年更新**，请务必从官方网站获取最新版本：

```
❌ 旧模板（过期）
✅ 新模板（当年版本）

示例：
- neurips_2024.sty → neurips_2025.sty
- icml2025.sty → icml2026.sty
```

### 必需文件清单

每个会议模板通常包含：

| 文件类型 | 说明 | 必须 |
|---------|------|------|
| `.sty` / `.cls` | 样式定义文件 | ✅ 必须 |
| `.tex` | 主文档 | ✅ 必须 |
| `.bst` | 参考文献样式 | ✅ 推荐 |
| `Makefile` | 编译脚本 | ⚪ 可选 |
| README.md | 说明文档 | ⚪ 推荐 |

### 编译验证

下载模板后，**立即验证**可以编译：

```bash
# 方法 1: 使用 latexmk（推荐）
latexmk -pdf main.tex

# 方法 2: 手动编译
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex

# 如果编译失败，请检查：
# - 缺少 .sty 文件
# - 缺少 TeX 包
# - 模板文件损坏
```

## 🔗 相关资源

### Skill 内部文档

- `references/ml/latex_templates.md` - LaTeX 模板使用完整指南
- `references/ml/templates_guide.md` - 模板获取快速指南
- `references/ml/ml_conferences.md` - 会议要求对比

### 外部工具

- **Overleaf**: https://overleaf.com - 在线 LaTeX 编辑器
- **TeX Live**: https://tug.org/texlive - 完整 TeX 发行版
- **TeX Stack Exchange**: https://tex.stackexchange.com - LaTeX 问题解答

## 📞 遇到问题？

### 常见问题

**Q: 下载的模板编译失败**
```
A: 1. 确认下载的是正确年份的模板
   2. 检查是否所有 .sty 文件都在同一目录
   3. 尝试使用 TeX Live 而非其他发行版
```

**Q: Overleaf 上模板编译错误**
```
A: 1. 上传整个模板目录，不只是 main.tex
   2. 设置编译器为 pdfLaTeX
   3. 确认 Menu → Compiler 设置正确
```

**Q: 如何在本地设置 LaTeX 环境**
```
A: 1. 安装 TeX Live（推荐）或 MacTeX
   2. 配置编辑器（VS Code + LaTeX Workshop）
   3. 使用 latexmk 自动编译
```

---

## 📋 模板使用检查清单

在开始写论文前：

```
- [ ] 确认目标会议和年份
- [ ] 下载最新版模板
- [ ] 验证模板能编译
- [ ] 阅读 template 的 README.md
- [ ] 了解页数限制和特殊要求
- [ ] 设置正确的匿名/非匿名模式
- [ ] 配置参考文献样式
```

---

**最后更新**: 2025-01-25
**Skill 版本**: scientific-writing v1.0.0
