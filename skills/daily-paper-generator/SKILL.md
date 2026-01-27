---
name: daily-paper-generator
description: Use when the user asks to "generate daily paper", "search arXiv for EEG papers", "find EEG decoding papers", "review brain-computer interface papers", or wants to create paper summaries for EEG/brain decoding/speech decoding research. This skill automates searching arXiv for recent papers on EEG decoding, EEG speech decoding, or brain foundation models, reviewing paper quality, and generating structured Chinese/English summaries.
version: 0.4.0
---

# Daily Paper Generator

## Overview

Automate the workflow of discovering, reviewing, and summarizing recent research papers on arXiv related to EEG decoding, brain-computer interfaces, and neural foundation models.

**Core workflow:**
1. Search arXiv for recent papers (within 3 months) using Chrome browser
2. Retrieve paper metadata from arXiv pages
3. Evaluate paper quality using structured criteria
4. Select top 3 papers
5. Generate structured summaries with Chinese and English reviews
6. Save results as Markdown files in `daily paper/` directory

## When to Use

Use this skill when:
- User asks to "generate daily paper" or "find recent EEG papers"
- User wants to discover research on EEG decoding, speech decoding from EEG, or brain foundation models
- User needs paper reviews with both Chinese and English summaries
- User wants to track recent arXiv publications in neuro/AI intersection

## Output Format

Each paper summary follows this structure (see `example/daily paper example.md` for complete example):

### 1. Header Section
```markdown
# Paper Title

## 作者及单位
Author list
Institution

## arXiv 链接
https://arxiv.org/abs/ARXIV_ID

**发表日期**: YYYY-MM-DD
**arXiv ID**: XXXX.XXXXX
**分Class**: cs.LG, q-bio.NC, eess.SP
```

### 2. Review Sections

**中文评语** (~300 words):
- Background (1-2 sentences): Research context and importance
- Challenges (2-3 sentences): Problems with existing methods
- Contribution (1-2 sentences): Core contribution of this work
- Method (2-3 sentences): Key technical details
- Results (2-3 sentences): Main findings and metrics
- Analysis & Limitations (1-2 sentences): Significance and limitations

**English Review** (fluent academic English):
- Concise summary following the same structure as Chinese review
- Use natural academic prose (avoid AI-like patterns)
- Apply scientific writing best practices

### 3. Main Figure Section
```markdown
## 主图
[预留论文主图位置]
```

### 4. Metadata Table
```markdown
## 论文元Data

| Project | Content |
|------|------|
| **Title** | Paper Title |
| **第一作者** | First Author Name |
| **作者列表** | Full author list |
| **第一作者单位** | Institution |
| **发表日期** | YYYY-MM-DD |
| **arXiv 链接** | https://arxiv.org/abs/ID |
| **PDF 链接** | https://arxiv.org/pdf/ID |
| **分Class** | cs.LG, q-bio.NC, eess.SP |
```

### 5. Integrated Format (for publishing)
```markdown
## 整合格式

Daily Paper MMDD

Paper Title

https://arxiv.org/abs/ARXIV_ID

[Chinese Review]

[English Review]
```

### 6. Appendix
```markdown
## 附录

**github连接：** [Available/Not Available]

**补充说明**

[Key insights, impact points]

**Sources:**
- [arXiv Abstract](URL)
- [arXiv HTML](URL)
- [Paperverse Review](URL) (if available)
```

## Quick Reference

| Task | Method |
|------|--------|
| Search arXiv | Use Chrome MCP tools (chrome-mcp-helper) |
| Get paper details | Navigate to arXiv pages and extract metadata |
| Evaluate quality | Use criteria in `references/quality-criteria.md` |
| Write Chinese review | Follow style in `references/writing-style.md` |
| Write English review | Apply scientific-writing skill best practices |
| Create output | Use template in `example/daily paper example.md` |

## Workflow

### Step 1: Search arXiv Using Chrome

**Search keywords** (see `references/keywords.md` for full list):
- EEG decoding: `EEG decoding`, `brain decoding`, `neural decoding`
- Speech decoding: `speech decoding from EEG`, `EEG speech reconstruction`
- Foundation models: `EEG foundation model`, `large EEG model`, `brain foundation model`

**Method: Use Chrome browser with arXiv search**

1. **Navigate to arXiv search** using Chrome MCP tools:
   - URL: `https://arxiv.org/search/`
   - Add search parameters: `?searchtype=all&query=KEYWORDS&abstracts=show&order=-announced_date_first`

2. **Search URL pattern**:
   ```
   https://arxiv.org/search/?searchtype=all&query=EEG+decoding&abstracts=show&order=-announced_date_first
   https://arxiv.org/search/?searchtype=all&query=EEG+foundation+model&abstracts=show&order=-announced_date_first
   ```

3. **Time filtering**: Use date filters or sort by `announced_date_first` to get recent papers

4. **Extract paper information** from search results:
   - Paper title
   - Authors
   - arXiv ID
   - Abstract preview
   - Publication date

### Step 2: Retrieve Paper Details

For each candidate paper, navigate to its arXiv abs page and extract:

**URL pattern**: `https://arxiv.org/abs/ARXIV_ID`

**Extract from page**:
- Title (from `<h1>` tag)
- Authors (from `.authors` element)
- Abstract (from `blockquote.abstract`)
- Submission date (from `.dateline`)
- arXiv ID (from URL or page)
- Categories (from `.subjects`)
- Comments (if present)
- First author institution (if available in comments or author affiliations)

### Step 3: Evaluate Paper Quality

Review each paper using the 5-dimension criteria in `references/quality-criteria.md`:

| Dimension | Weight | Key Points |
|-----------|--------|------------|
| Innovation | 30% | Novelty of contribution |
| Method Completeness | 25% | Clarity and reproducibility |
| Experimental Thoroughness | 25% | Validation depth |
| Writing Quality | 10% | Clarity of expression |
| Relevance & Impact | 10% | Domain importance |

**Scoring:** Rate each dimension 1-5, calculate weighted sum.

**Process:**
1. Screen by title/abstract for relevance
2. Navigate to full paper page for detailed review
3. Score each dimension
4. Rank by total score
5. Select top 3

### Step 4: Generate Paper Summaries

For each selected paper, create a summary following the structure in `example/daily paper example.md`:

**Required sections:**
1. Title (H1 heading)
2. 作者及单位 (Authors and Institution)
3. arXiv 链接 (with metadata: date, ID, categories)
4. 中文评语 (Chinese review, ~300 words)
5. English Review (fluent academic English)
6. 主图 (placeholder for main figure)
7. 论文元Data (metadata table)
8. 整合格式 (integrated format for publishing)
9. 附录 (appendix with github link,补充说明, sources)

**Writing Chinese review** (see `references/writing-style.md`):
- Background: 研究背景和重要性
- Challenges: 现有Method的不足
- Contribution: 本工作的核心贡献
- Method: 关Key技术细节
- Results: 主要发现和指标
- Analysis & Limitations: 意义和局限性

**Writing English review**:
- Apply scientific-writing skill best practices
- Use anti-AI writing principles (natural, varied sentence structure)
- Keep concise and direct
- Avoid formulaic transitions ("furthermore", "moreover", "additionally")

### Step 5: Save Output

Create Markdown files in the `daily paper/` directory:

```
daily paper/
├── 2025-01-26-1430-paper-1.md
├── 2025-01-26-1430-paper-2.md
└── 2025-01-26-1430-paper-3.md
```

**Filename format:** `YYYY-MM-DD-HHMM-paper-N.md`

**Important:** 使用时间戳（精确到分钟）避免覆盖之前Generate的File。

## Example Output

See `example/daily paper example.md` for a complete example of the DeeperBrain paper summary with all sections properly formatted.

## Additional Resources

### Reference Files

- **`references/keywords.md`** - Complete search keyword list and arXiv URL patterns
- **`references/quality-criteria.md`** - Detailed 5-dimension evaluation criteria with scoring rubrics
- **`references/writing-style.md`** - Chinese review structure, templates, and example analysis

### Example Files

- **`example/daily paper example.md`** - Complete output example with all sections
- **`scripts/arxiv_search.py`** - Legacy Python script (deprecated, use Chrome instead)

### Chrome MCP Tools

Use Chrome MCP tools for browser automation:
- **Navigation**: Open arXiv search and paper pages
- **Screenshot**: Capture pages for analysis
- **Tabs**: Manage multiple arXiv pages
- **Content extraction**: Parse paper metadata from HTML

## Important Notes

1. **Time range:** Search focuses on papers from the last 3 months (check submission dates)
2. **Link format:** Use arXiv abs page links (https://arxiv.org/abs/ID), not direct PDF links
3. **Review length:** Chinese reviews should be approximately 300 words
4. **Quality focus:** Prioritize content quality (innovation, method, experiments) over quantitative metrics
5. **Bilingual output:** Both Chinese and English reviews are required for each paper
6. **Chrome required:** This workflow uses Chrome browser automation via MCP tools
7. **Complete format:** Ensure all 9 sections are included in each summary
8. **Consistent naming:** Use Daily Paper MMDD format in integrated section
