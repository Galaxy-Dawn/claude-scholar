---
name: latex-conference-template-organizer
description: 当用户要求"整理 LaTeX 会议模板"、"清理 .zip 模板File"、"准备 Overleaf 投稿模板"，或提供会议模板 .zip File并提到需要整理/清理/预Process时使用此Skill
---

# LaTeX 会议模板整理器

## 概述

将混乱的会议 LaTeX 模板 .zip File整理成适合 Overleaf 投稿的干净模板结构。会议官方提供的模板通常Package含大量ExampleContent、说明Comment和混乱的File结构，本Skill将其Convert为可直接用于写作的模板。

## 工作Pattern

**分析后确认Pattern**：先分析问题并向用户展示，Wait确认后再Execute整理。

## 完整Workflow程

```
接收 .zip File
    ↓
1. 解压并分析File结构
    ↓
2. 识别主File和Dependency关系
    ↓
3. 诊断问题（向用户展示）
    ↓
4. 询问会议Information（链接/Name）
    ↓
5. Wait用户确认整理方案
    ↓
6. Execute整理，CreateOutputDirectory
    ↓
7. Generate README（结合官网Information）
    ↓
8. OutputComplete
```

## Step 1：解压与分析

### 解压File

将 .zip 解压到临时Directory：

```bash
unzip -q template.zip -d /tmp/latex-template-temp
cd /tmp/latex-template-temp
find . -type f -name "*.tex" -o -name "*.sty" -o -name "*.cls" -o -name "*.bib"
```

### 识别FileClass型

| FileClass型 | 用途 |
|---------|------|
| `.tex` | LaTeX 源File |
| `.sty` / `.cls` | 样式File |
| `.bib` | Reference文献Data库 |
| `.pdf` / `.png` / `.jpg` | 图片File |

### 识别主File

**常见主File名**：
- `main.tex`
- `paper.tex`
- `document.tex`
- `sample-sigconf.tex`
- `template.tex`

**识别Method**：
1. CheckFile名是否匹配常见Pattern
2. 搜索Package含 `\documentclass` 的File
3. 如果有多个候选，向用户确认

```bash
# 查找Package含 \documentclass 的File
grep -l "\\documentclass" *.tex
```

## Step 2：诊断问题

向用户展示发现的问题：

### File结构混乱

- 多级Directory嵌套
- .tex File散乱分布
- 不清楚主File是哪个

### 冗余Content

检测以下Pattern并标记为需要清理：
- File名Package含：`sample`, `example`, `demo`, `test`
- CommentPackage含：`sample`, `example`, `template`, `delete this`

### Dependency问题

- 引用的 `.sty`/`.cls` File缺失
- 图片/表格引用PathError

## Step 3：询问会议Information

向用户询问以下Information：

```markdown
请提供以下Information（可选）：

1. **会议投稿链接**（推荐）：用于提取官方投稿要求
2. **会议Name**：如无链接
3. **其他特殊要求**：如页数限制、匿名要求等
```

## Step 4：展示整理计划

向用户展示整理计划并Wait确认：

```markdown
## 整理计划

### 发现的问题
- [列出诊断发现的问题]

### 整理方案
1. 主File：main.tex（清理ExampleContent）
2. 章节分离：text/ Directory
3. 资源Directory：figures/, tables/, styles/

### Output结构
[展示OutputDirectory结构]

是否确认Execute整理？[Y/n]
```

## Step 5：Execute整理

### CreateOutputDirectory结构

```bash
mkdir -p output/{text,figures,tables,styles}
```

### 整理主File (main.tex)

**保留**：
- `\documentclass` 声明
- 必要的Package引用
- 核心Configuration（如匿名Pattern）

**清理**：
- Example章节Content
- 冗长的说明Comment
- Example作者/TitleInformation

**Add**：
- 用 `\input{text/XX-section}` 导入章节

**Example main.tex 结构**（ACM 模板标准格式）：
```latex
\documentclass[...]{...}  % 保留原模板的DocumentationClass

% 必要的Package（保留原模板的Package声明）

%% ============================================================================
%% Preamble: 在 \begin{document} 之前
%% ============================================================================

%% Title和作者Information
\title{Your Paper Title}
\author{Author Name}
\affiliation{...}

%% 摘要（在 preamble 中，\maketitle 之前）
\begin{abstract}
% TODO: Write abstract content
\end{abstract}

%% CCS Concepts 和 Keywords（在 preamble 中）
\begin{CCSXML}
<ccs2012>
   <concept>
       <concept_id>10010405.10010444.10010447</concept_id>
       <concept_desc>Applied computing~...</concept_desc>
       <concept_significance>500</concept_significance>
   </concept>
</ccs2012>
\end{CCSXML}

\ccsdesc[500]{Applied computing~...}
\keywords{keyword1, keyword2, keyword3}

%% ============================================================================
%% Document Body
%% ============================================================================
\begin{document}

\maketitle

%% 章节Content（从 text/ 导入）
\input{text/01-introduction}
\input{text/02-related-work}
\input{text/03-method}
\input{text/04-experiments}
\input{text/05-conclusion}

\bibliographystyle{...}
\bibliography{references}

\end{document}
```

### Create章节File (text/)

为每个章节Create独立的 .tex File，**只Package含章节Content**，不Package含 `\begin{document}` 等：

**text/01-introduction.tex**:
```latex
\section{Introduction}
% TODO: Write introduction content
```

**text/02-related-work.tex**:
```latex
\section{Related Work}
% TODO: Write related work content
```

**text/03-method.tex**:
```latex
\section{Method}
% TODO: Write method content
```

**text/04-experiments.tex**:
```latex
\section{Experiments}
% TODO: Write experiments content
```

**text/05-conclusion.tex**:
```latex
\section{Conclusion}
% TODO: Write conclusion content
```

**重要提示**：
- **摘要** 应该放在 main.tex 的 preamble 中（`\begin{document}` 之前），`\maketitle` 之后
- **text/ Directory中的File只Package含章节**，以 `\section{...}` 开头
- 不要在 text/ File中Package含 `\begin{document}` 或其他Package装

### 复制样式File (styles/)

从原模板复制所有 `.sty` 和 `.cls` File到 `styles/`：

```bash
find /tmp/latex-template-temp -type f \( -name "*.sty" -o -name "*.cls" \) -exec cp {} output/styles/ \;
```

**注意**：保持原模板的Directory结构（如 `acmart/`），只移动到 `styles/` 下。

### Process图片和表格

```bash
# 复制图片File
find /tmp/latex-template-temp -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.pdf" \) -exec cp {} output/figures/ \;

# 复制表格File（如有）
find /tmp/latex-template-temp -type f -name "*.tex" | grep -i table | while read f; do cp "$f" output/tables/; done
```

### CreateExample表格File

**重要**：Overleaf 会自动Delete空Directory。为防止 `tables/` Directory被Delete，需Create一个Example表格File：

```bash
# CreateExample表格File
cat > output/tables/example-table.tex << 'EOF'
% Example表格File
% 可以Delete或替换为自己的表格

\begin{table}[h]
    \centering
    \caption{Example表格}
    \label{tab:example}
    \begin{tabular}{lccc}
        \toprule
        Method & Metric 1 & Metric 2 & Metric 3 \\
        \midrule
        Baseline & 85.3 & 12.4 & 0.92 \\
        Method A & 87.1 & 11.8 & 0.95 \\
        \textbf{Ours} & \textbf{89.4} & \textbf{10.2} & \textbf{0.97} \\
        \bottomrule
    \end{tabular}
\end{table}
EOF
```

**注意**：
- 如果原模板已有表格File，此Step可Skip
- Example表格仅供防止Directory被Delete，可Delete或替换
- 在论文中引用表格使用 `\input{tables/example-table.tex}` 或将表格Content直接复制到章节File中

### 复制Reference文献

```bash
# 复制 .bib File
find /tmp/latex-template-temp -type f -name "*.bib" -exec cp {} output/ \;
```

## Step 6：Generate README

### Information来源优先级

1. **用户提供的会议链接** → 使用 WebFetch 提取
2. **模板FileComment** → 从 .tex File提取
3. **默认推断** → 从 `\documentclass` 推断

### README 模板

```markdown
# [会议Name] 投稿模板

## 模板Information
- **会议**: [会议Name]
- **官网**: [会议链接]
- **模板Version**: [从模板或官网Get]
- **DocumentationClass**: [提取的 documentclass]

## 投稿要求

### 页面与格式
- **页数限制**: [从官网或模板提取]
- **双栏/单栏**: [检测 layout]
- **字体大小**: [10pt/11pt 等]

### 匿名要求
- **是否需要盲审**: [检测 template mode]
- **作者InformationProcess**: [说明如何填写]

### 编译要求
- **推荐编译器**: [XeLaTeX/pdfLaTeX/LuaLaTeX]
- **特殊Package要求**: [如有]

## Overleaf 使用

### 上传Step
1. 在 Overleaf Create新Project
2. 上传整个 `output/` Directory
3. Set编译器为 [指定编译器]
4. 点击 Recompile Testing

### File说明
- `main.tex` - 主File，从这里开始
- `text/` - 章节Content，按需编辑
- `figures/` - 放置图片
- `tables/` - 放置表格
- `styles/` - 样式File，无需Modify
- `references.bib` - Reference文献Data库

## 常用操作

### Add图片
```latex
\begin{figure}[h]
    \centering
    \includegraphics[width=0.8\linewidth]{figures/your-image.pdf}
    \caption{图片Title}
    \label{fig:your-label}
\end{figure}
```

### Add表格
```latex
\begin{table}[h]
    \centering
    \begin{tabular}{|c|c|}
        \hline
        列1 & 列2 \\
        \hline
        Content1 & Content2 \\
        \hline
    \end{tabular}
    \caption{表格Title}
    \label{tab:your-label}
\end{table}
```

### AddReference文献
在 `references.bib` 中Add条目，在文中使用 `\cite{key}` 引用。

## 注意事项
- [从模板Comment中提取的警告]
- [从官网提取的重要提示]
```

### 从网站提取Information（如果用户提供了链接）

使用 WebFetch Get会议投稿页面Content，提取：
- 页数限制
- 匿名要求
- 格式要求
- 截稿日期

## Step 7：清理与Output

```bash
# 清理临时File
rm -rf /tmp/latex-template-temp

# OutputCompleteInformation
echo "模板整理Complete！OutputDirectory：output/"
echo "请将 output/ Directory上传到 Overleaf Testing编译。"
```

## ErrorProcess

| Error情况 | Process方式 |
|---------|---------|
| 找不到主File | 列出所有 .tex File，让用户选择 |
| DependencyFile缺失 | 警告用户，尝试从模板Directory定位 |
| 无法提取会议Information | 使用模板中的默认Information，标记为 [待确认] |
| 网站无法访问 | 回退到模板Comment，提示用户手动补充 |
| 解压Fail | 提示用户Check .zip File完整性 |

## 常见会议模板Class型

| 会议 | DocumentationClass | 特点 |
|------|--------|------|
| ACM 会议 | `acmart` | 需要匿名Pattern `\acmReview{anonymous}` |
| CVPR/ICCV | `cvpr` | 双栏，严格页数限制 |
| NeurIPS | `neurips_2025` | 匿名评审，无页数限制 |
| ICLR | `iclr2025_conference` | 双栏，需要会话Information |
| AAAI | `aaai25` | 双栏，8页+Reference文献 |

## 快速Reference

### 检测DocumentationClass型
```bash
# 检测DocumentationClass
grep "\\documentclass" main.tex

# 检测匿名Pattern
grep -i "anonymous\|review\|blind" main.tex

# 检测页数Set
grep "pagelimit\|pageLimit\|page_limit" main.tex
```

### 常用清理Pattern
```bash
# RemoveExampleFile
rm -f sample-* example-* demo-* test-*

# Remove临时File
rm -f *.aux *.log *.out *.bbl *.blg
```
