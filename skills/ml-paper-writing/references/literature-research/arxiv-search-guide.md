# arXiv Literature Search Guide

## Overview

This guide provides workflows for discovering and evaluating recent ML research papers on arXiv. Use this when conducting literature reviews, finding related work, or staying updated on recent publications.

---

## Search Strategies

### 1. Keyword-Based Search

**arXiv Search URL Pattern:**
```
https://arxiv.org/search/?searchtype=all&query=KEYWORDS&abstracts=show&order=-announced_date_first
```

**Common ML Search Keywords:**
- **General ML**: `machine learning`, `deep learning`, `neural networks`
- **Specific Areas**: `reinforcement learning`, `transformer`, `attention mechanism`, `graph neural networks`
- **Applications**: `computer vision`, `natural language processing`, `reinforcement learning`
- **Methods**: `self-supervised learning`, `contrastive learning`, `foundation models`

**Tips:**
- Combine keywords with `+` for AND operation
- Use `|` for OR operation
- Put phrases in quotes for exact matches: `"attention is all you need"`

### 2. Category-Based Search

**Recommended arXiv Categories for ML:**
- `cs.LG` (Machine Learning)
- `cs.AI` (Artificial Intelligence)
- `cs.CV` (Computer Vision and Pattern Recognition)
- `cs.CL` (Computation and Language)
- `cs.NE` (Neural and Evolutionary Computing)
- `stat.ML` (Machine Learning - Statistics)

**Category Filter URL:**
```
https://arxiv.org/search/?cat:cs.LG+OR+cat:cs.AI+AND+all:transformer&abstracts=show&order=-announced_date_first
```

### 3. Time-Based Filtering

**Recent Papers (Last 3 Months):**
- Use `order=-announced_date_first` for newest first
- Manually filter by submission date
- Check paper metadata for submission date

---

## Using Chrome MCP for arXiv Search

When available, use Chrome MCP tools for automated arXiv searching:

1. **Navigate to arXiv search** using Chrome MCP navigation
2. **Extract paper information** from search results:
   - Paper title
   - Authors
   - arXiv ID
   - Abstract preview
   - Publication date

3. **Navigate to individual papers** for detailed review

---

## Paper Quality Evaluation

Evaluate papers using the 5-dimension criteria below:

| Dimension | Weight | Key Points |
|-----------|--------|------------|
| **Innovation** | 30% | Novelty of contribution |
| **Method Completeness** | 25% | Clarity and reproducibility |
| **Experimental Thoroughness** | 25% | Validation depth |
| **Writing Quality** | 10% | Clarity of expression |
| **Relevance & Impact** | 10% | Domain importance |

### Scoring Guidelines (1-5 scale)

**Innovation (30%):**
- 5: Breakthrough contribution, major impact
- 4: Significant improvement, new insights
- 3: Methodological innovation
- 2: Incremental improvement
- 1: Minor improvements

**Method Completeness (25%):**
- 5: Complete and rigorous, easily reproducible
- 4: Very detailed, mostly reproducible
- 3: Core method clear, basically reproducible
- 2: Lacks key details
- 1: Unclear description

**Experimental Thoroughness (25%):**
- 5: Comprehensive multi-dataset, ablation studies
- 4: Multiple datasets, reasonable ablations
- 3: Main experiments complete
- 2: Limited experiments
- 1: Minimal validation

**Writing Quality (10%):**
- 5: Excellent clarity and rigor
- 4: Clear and well-structured
- 3: Understandable
- 2: Some ambiguity
- 1: Confusing

**Relevance & Impact (10%):**
- 5: Solves important problem, wide impact
- 4: Important domain problem
- 3: Meaningful contribution
- 2: Niche problem
- 1: Limited impact

### Selection Process

1. **Screen by title/abstract** for relevance
2. **Navigate to full paper** for detailed review
3. **Score each dimension** (1-5)
4. **Calculate weighted total**
5. **Rank and select** top papers

---

## Extracting Paper Metadata

**From arXiv Abstract Page (`https://arxiv.org/abs/ARXIV_ID`):**

- Title (from `<h1>` tag)
- Authors (from `.authors` element)
- Abstract (from `blockquote.abstract`)
- Submission date (from `.dateline`)
- arXiv ID (from URL)
- Categories (from `.subjects`)
- Comments (if present)
- Code repository (check abstract for GitHub links)

---

## Integration with Citation Workflow

After finding relevant papers:

1. **Verify citations** using Semantic Scholar API (see `../citation-workflow.md`)
2. **Fetch BibTeX** programmatically via DOI
3. **Store in bibliography** with verification status

---

## Common Use Cases

### Finding Related Work

When writing a paper, use arXiv search to:
1. Find recent papers on your topic
2. Identify state-of-the-art methods
3. Discover competing approaches
4. Find baseline comparisons

### Staying Updated

Set up regular searches for:
- Your specific research area
- Competing labs/researchers
- New methods in your domain
- Conference proceedings (preprints)

### Literature Reviews

For comprehensive reviews:
1. Start with broad keyword searches
2. Filter by recent publications (last 1-3 years)
3. Use citation chaining (forward and backward)
4. Evaluate and select high-quality papers
5. Organize by theme/contribution

---

## Tips for Effective Searching

1. **Use specific keywords** rather than broad terms
2. **Combine techniques** (keywords + categories + time filters)
3. **Check code availability** (many arXiv papers link to GitHub)
4. **Look for citations** to understand impact
5. **Read abstracts carefully** before full papers
6. **Use paper metrics** (citation count, code stars) as indicators

---

## External Resources

- **arXiv**: https://arxiv.org/
- **Semantic Scholar**: https://www.semanticscholar.org/
- **Papers With Code**: https://paperswithcode.com/
- **Connected Papers**: https://www.connectedpapers.com/
- **arXiv API**: http://export.arxiv.org/api_help/
