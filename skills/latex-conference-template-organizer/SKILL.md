---
name: latex-conference-template-organizer
description: 当用户要求"整理 LaTeX 会议模板"、"清理 .zip 模板文件"、"准备 Overleaf 投稿模板"，或提供会议模板 .zip 文件并提到需要整理/清理/预处理时使用此技能
---

# LaTeX 会议模板整理器

## 概述

将混乱的会议 LaTeX 模板 .zip 文件整理成适合 Overleaf 投稿的干净模板结构。会议官方提供的模板通常包含大量示例内容、说明注释和混乱的文件结构，本技能将其转换为可直接用于写作的模板。

## 工作模式

**分析后确认模式**：先分析问题并向用户展示，等待确认后再执行整理。

## 完整工作流程

```
接收 .zip 文件
    ↓
1. 解压并分析文件结构
    ↓
2. 识别主文件和依赖关系
    ↓
3. 诊断问题（向用户展示）
    ↓
4. 询问会议信息（链接/名称）
    ↓
5. 等待用户确认整理方案
    ↓
6. 执行整理，创建输出目录
    ↓
7. 生成 README（结合官网信息）
    ↓
8. 输出完成
```

## 步骤 1：解压与分析

### 解压文件

将 .zip 解压到临时目录：

```bash
unzip -q template.zip -d /tmp/latex-template-temp
cd /tmp/latex-template-temp
find . -type f -name "*.tex" -o -name "*.sty" -o -name "*.cls" -o -name "*.bib"
```

### 识别文件类型

| 文件类型 | 用途 |
|---------|------|
| `.tex` | LaTeX 源文件 |
| `.sty` / `.cls` | 样式文件 |
| `.bib` | 参考文献数据库 |
| `.pdf` / `.png` / `.jpg` | 图片文件 |

### 识别主文件

**常见主文件名**：
- `main.tex`
- `paper.tex`
- `document.tex`
- `sample-sigconf.tex`
- `template.tex`

**识别方法**：
1. 检查文件名是否匹配常见模式
2. 搜索包含 `\documentclass` 的文件
3. 如果有多个候选，向用户确认

```bash
# 查找包含 \documentclass 的文件
grep -l "\\documentclass" *.tex
```

## 步骤 2：诊断问题

向用户展示发现的问题：

### 文件结构混乱

- 多级目录嵌套
- .tex 文件散乱分布
- 不清楚主文件是哪个

### 冗余内容

检测以下模式并标记为需要清理：
- 文件名包含：`sample`, `example`, `demo`, `test`
- 注释包含：`sample`, `example`, `template`, `delete this`

### 依赖问题

- 引用的 `.sty`/`.cls` 文件缺失
- 图片/表格引用路径错误

## 步骤 3：询问会议信息

向用户询问以下信息：

```markdown
请提供以下信息（可选）：

1. **会议投稿链接**（推荐）：用于提取官方投稿要求
2. **会议名称**：如无链接
3. **其他特殊要求**：如页数限制、匿名要求等
```

## 步骤 4：展示整理计划

向用户展示整理计划并等待确认：

```markdown
## 整理计划

### 发现的问题
- [列出诊断发现的问题]

### 整理方案
1. 主文件：main.tex（清理示例内容）
2. 章节分离：text/ 目录
3. 资源目录：figures/, tables/, styles/

### 输出结构
[展示输出目录结构]

是否确认执行整理？[Y/n]
```

## 步骤 5：执行整理

### 创建输出目录结构

```bash
mkdir -p output/{text,figures,tables,styles}
```

### 整理主文件 (main.tex)

**保留**：
- `\documentclass` 声明
- 必要的包引用
- 核心配置（如匿名模式）

**清理**：
- 示例章节内容
- 冗长的说明注释
- 示例作者/标题信息

**添加**：
- 用 `\input{text/XX-section}` 导入章节

**示例 main.tex 结构**（ACM 模板标准格式）：
```latex
\documentclass[...]{...}  % 保留原模板的文档类

% 必要的包（保留原模板的包声明）

%% ============================================================================
%% Preamble: 在 \begin{document} 之前
%% ============================================================================

%% 标题和作者信息
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

%% 章节内容（从 text/ 导入）
\input{text/01-introduction}
\input{text/02-related-work}
\input{text/03-method}
\input{text/04-experiments}
\input{text/05-conclusion}

\bibliographystyle{...}
\bibliography{references}

\end{document}
```

### KDD 2026 匿名投稿特殊配置

对于 KDD 2026（使用 ACM acmart 模板），需要在文档类中添加 `nonacm` 选项来移除脚注：

```latex
%% ============================================================================
%% Document Class - KDD 2026 匿名投稿配置
%% 投稿版本：\documentclass[sigconf,anonymous,review,nonacm]{acmart}
%% Camera-ready：\documentclass[sigconf]{acmart}
%% ============================================================================
\documentclass[sigconf,anonymous,review,nonacm]{acmart}

%% ============================================================================
%% 禁用 ACM 相关元数据（仅投稿版本需要）
%% ============================================================================
\settopmatter{printacmref=false}  % 禁用 ACM Reference Format
\setcopyright{none}               % 禁用版权声明
\acmConference[]{}{}{}            % 清空会议信息（移除脚注中的会议信息）
\acmYear{}                        % 清空年份
\acmISBN{}                        % 清空 ISBN
\acmDOI{}                         % 清空 DOI

%% Camera-ready 版本需要恢复的内容：
%% \acmConference[KDD '26]{Proceedings of the 30th ACM SIGKDD Conference on Knowledge Discovery and Data Mining}{August 09--13, 2026}{Jeju, Korea}
%% \acmISBN{978-1-4503-XXXX-X/26/08}
%% \acmDOI{10.1145/nnnnnnn.nnnnnnn}
```

### 创建章节文件 (text/)

为每个章节创建独立的 .tex 文件，**只包含章节内容**，不包含 `\begin{document}` 等：

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
- **text/ 目录中的文件只包含章节**，以 `\section{...}` 开头
- 不要在 text/ 文件中包含 `\begin{document}` 或其他包装

### 复制样式文件 (styles/)

从原模板复制所有 `.sty` 和 `.cls` 文件到 `styles/`：

```bash
find /tmp/latex-template-temp -type f \( -name "*.sty" -o -name "*.cls" \) -exec cp {} output/styles/ \;
```

**注意**：保持原模板的目录结构（如 `acmart/`），只移动到 `styles/` 下。

### 处理图片和表格

```bash
# 复制图片文件
find /tmp/latex-template-temp -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.pdf" \) -exec cp {} output/figures/ \;

# 复制表格文件（如有）
find /tmp/latex-template-temp -type f -name "*.tex" | grep -i table | while read f; do cp "$f" output/tables/; done
```

### 创建示例表格文件

**重要**：Overleaf 会自动删除空目录。为防止 `tables/` 目录被删除，需创建一个示例表格文件：

```bash
# 创建示例表格文件
cat > output/tables/example-table.tex << 'EOF'
% 示例表格文件
% 可以删除或替换为自己的表格

\begin{table}[h]
    \centering
    \caption{示例表格}
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
- 如果原模板已有表格文件，此步骤可跳过
- 示例表格仅供防止目录被删除，可删除或替换
- 在论文中引用表格使用 `\input{tables/example-table.tex}` 或将表格内容直接复制到章节文件中

### 复制参考文献

```bash
# 复制 .bib 文件
find /tmp/latex-template-temp -type f -name "*.bib" -exec cp {} output/ \;
```

## 步骤 6：生成 README

### 信息来源优先级

1. **用户提供的会议链接** → 使用 WebFetch 提取
2. **模板文件注释** → 从 .tex 文件提取
3. **默认推断** → 从 `\documentclass` 推断

### README 模板

```markdown
# [会议名称] 投稿模板

## 模板信息
- **会议**: [会议名称]
- **官网**: [会议链接]
- **模板版本**: [从模板或官网获取]
- **文档类**: [提取的 documentclass]

## 投稿要求

### 页面与格式
- **页数限制**: [从官网或模板提取]
- **双栏/单栏**: [检测 layout]
- **字体大小**: [10pt/11pt 等]

### 匿名要求
- **是否需要盲审**: [检测 template mode]
- **作者信息处理**: [说明如何填写]

### 编译要求
- **推荐编译器**: [XeLaTeX/pdfLaTeX/LuaLaTeX]
- **特殊包要求**: [如有]

## Overleaf 使用

### 上传步骤
1. 在 Overleaf 创建新项目
2. 上传整个 `output/` 目录
3. 设置编译器为 [指定编译器]
4. 点击 Recompile 测试

### 文件说明
- `main.tex` - 主文件，从这里开始
- `text/` - 章节内容，按需编辑
- `figures/` - 放置图片
- `tables/` - 放置表格
- `styles/` - 样式文件，无需修改
- `references.bib` - 参考文献数据库

## 常用操作

### 添加图片
```latex
\begin{figure}[h]
    \centering
    \includegraphics[width=0.8\linewidth]{figures/your-image.pdf}
    \caption{图片标题}
    \label{fig:your-label}
\end{figure}
```

### 添加表格
```latex
\begin{table}[h]
    \centering
    \begin{tabular}{|c|c|}
        \hline
        列1 & 列2 \\
        \hline
        内容1 & 内容2 \\
        \hline
    \end{tabular}
    \caption{表格标题}
    \label{tab:your-label}
\end{table}
```

### 添加参考文献
在 `references.bib` 中添加条目，在文中使用 `\cite{key}` 引用。

## 注意事项
- [从模板注释中提取的警告]
- [从官网提取的重要提示]
```

### 从网站提取信息（如果用户提供了链接）

使用 WebFetch 获取会议投稿页面内容，提取：
- 页数限制
- 匿名要求
- 格式要求
- 截稿日期

## 步骤 7：清理与输出

```bash
# 清理临时文件
rm -rf /tmp/latex-template-temp

# 输出完成信息
echo "模板整理完成！输出目录：output/"
echo "请将 output/ 目录上传到 Overleaf 测试编译。"
```

## 错误处理

| 错误情况 | 处理方式 |
|---------|---------|
| 找不到主文件 | 列出所有 .tex 文件，让用户选择 |
| 依赖文件缺失 | 警告用户，尝试从模板目录定位 |
| 无法提取会议信息 | 使用模板中的默认信息，标记为 [待确认] |
| 网站无法访问 | 回退到模板注释，提示用户手动补充 |
| 解压失败 | 提示用户检查 .zip 文件完整性 |

## 常见会议模板类型

| 会议 | 文档类 | 特点 |
|------|--------|------|
| **KDD (ACM SIGKDD)** | `acmart` | **匿名投稿需添加 `nonacm` 选项移除脚注** |
| ACM 会议 | `acmart` | 需要匿名模式 `\acmReview{anonymous}` |
| CVPR/ICCV | `cvpr` | 双栏，严格页数限制 |
| NeurIPS | `neurips_2025` | 匿名评审，无页数限制 |
| ICLR | `iclr2025_conference` | 双栏，需要会话信息 |
| AAAI | `aaai25` | 双栏，8页+参考文献 |

### KDD 匿名投稿配置说明

KDD 2026 使用 ACM acmart 模板，匿名投稿时需要特殊配置：

**投稿版本**（移除所有 ACM 元数据脚注）：
```latex
\documentclass[sigconf,anonymous,review,nonacm]{acmart}
\settopmatter{printacmref=false}
\setcopyright{none}
\acmConference[]{}{}{}
\acmYear{}
\acmISBN{}
\acmDOI{}
```

**Camera-ready 版本**（恢复 ACM 元数据）：
```latex
\documentclass[sigconf]{acmart}
\settopmatter{printacmref=true}
\setcopyright{acmcopyright}
\acmConference[KDD '26]{...}{...}{...}
\acmYear{2026}
\acmISBN{978-1-4503-XXXX-X/26/08}
\acmDOI{10.1145/nnnnnnn.nnnnnnn}
```

## 快速参考

### 检测文档类型
```bash
# 检测文档类
grep "\\documentclass" main.tex

# 检测匿名模式
grep -i "anonymous\|review\|blind" main.tex

# 检测页数设置
grep "pagelimit\|pageLimit\|page_limit" main.tex
```

### 常用清理模式
```bash
# 移除示例文件
rm -f sample-* example-* demo-* test-*

# 移除临时文件
rm -f *.aux *.log *.out *.bbl *.blg
```
