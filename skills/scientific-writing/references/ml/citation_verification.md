# Citation Verification Workflow

## ⚠️ CRITICAL: Never Hallucinate Citations

**This is the most important rule in academic writing with AI assistance.**

### The Problem

AI-generated citations have a **~40% error rate**. Hallucinated references—papers that don't exist, wrong authors, incorrect years, fabricated DOIs—are a serious form of academic misconduct that can result in desk rejection or retraction.

### The Golden Rule

```
NEVER generate BibTeX entries from memory. ALWAYS fetch programmatically.
```

| Action | ✅ Correct | ❌ Wrong |
|--------|-----------|----------|
| Adding a citation | Search API → verify → fetch BibTeX | Write BibTeX from memory |
| Uncertain about a paper | Mark as `[CITATION NEEDED]` | Guess the reference |
| Can't find exact paper | Note: "placeholder - verify" | Invent similar-sounding paper |

## Recommended: Install Exa MCP for Paper Search

For the best paper search experience, install **Exa MCP** which provides real-time academic search:

### Claude Code Installation
```bash
claude mcp add exa -- npx -y mcp-remote "https://mcp.exa.ai/mcp"
```

### Cursor / VS Code Installation
Add to MCP settings:
```json
{
  "mcpServers": {
    "exa": {
      "type": "http",
      "url": "https://mcp.exa.ai/mcp"
    }
  }
}
```

### Exa MCP Examples
Once installed, you can search like:
- "Find papers on RLHF for language models published after 2023"
- "Search for transformer architecture papers by Vaswani"
- "Get recent work on sparse autoencoders for interpretability"

Then verify results with Semantic Scholar API and fetch BibTeX via DOI.

## Citation Verification Workflow

### Step-by-Step Process

```
Citation Verification (MANDATORY for every citation):
- [ ] Step 1: Search using Exa MCP or Semantic Scholar API
- [ ] Step 2: Verify paper exists in 2+ sources (Semantic Scholar + arXiv/CrossRef)
- [ ] Step 3: Retrieve BibTeX via DOI (programmatically, not from memory)
- [ ] Step 4: Verify the claim you're citing actually appears in the paper
- [ ] Step 5: Add verified BibTeX to bibliography
- [ ] Step 6: If ANY step fails → mark as placeholder, inform scientist
```

### Step 0: Use Exa MCP for Initial Search

**Example searches:**
```
Search: "RLHF language model alignment 2023"
Search: "sparse autoencoders interpretability"
Search: "attention mechanism transformers Vaswani"
```

### Step 1: Search Semantic Scholar

**Python API:**
```python
from semanticscholar import SemanticScholar

sch = SemanticScholar()
results = sch.search_paper("attention mechanism transformers", limit=5)

for paper in results:
    print(f"{paper.title}")
    print(f"Paper ID: {paper.paperId}")
    print(f" DOI: {paper.externalIds.get('DOI', 'N/A')}")
    print(f" arXiv: {paper.externalIds.get('ArXiv', 'N/A')}")
    print()
```

**Output example:**
```
Attention Is All You Need
Paper ID: 1910e61c5a823d13f1b52368c8b88c8b51266449
 DOI: 10.1109/ICASSP.2017.7953489
 ArXiv: 1706.03762
```

### Step 2: Verify Existence

Confirm paper appears in at least **two sources**:

| Source | URL | Purpose |
|--------|-----|---------|
| Semantic Scholar | https://www.semanticscholar.org | Primary search |
| arXiv | https://arxiv.org | Preprint verification |
| CrossRef | https://api.crossref.org | DOI registry |
| Google Scholar | https://scholar.google.com | Backup verification |

**Verification checklist:**
- [ ] Paper title matches exactly
- [ ] Author list is correct
- [ ] Year/volume matches
- [ ] DOI or arXiv ID is valid

### Step 3: Retrieve BibTeX via DOI

**Python function:**
```python
import requests

def doi_to_bibtex(doi: str) -> str:
    """Get verified BibTeX from DOI via CrossRef."""
    response = requests.get(
        f"https://doi.org/{doi}",
        headers={"Accept": "application/x-bibtex"}
    )
    response.raise_for_status()
    return response.text

# Example usage
bibtex = doi_to_bibtex("10.48550/arXiv.1706.03762")
print(bibtex)
```

**Output:**
```bibtex
@article{Vaswani_2017,
    doi = {10.48550/arXiv.1706.03762},
    url = {https://arxiv.org/abs/1706.03762},
    author = {Vaswani, Ashish and Shazeer, Noam and Parmar, Niki and Uszkoreit, Jakob and Jones, Llion and Gomez, Aidan N. and Kaiser, {\L}ukasz and Polosukhin, Illia},
    title = {Attention Is All You Need},
    publisher = {arXiv},
    year = {2017},
    copyright = {arXiv.org perpetual, non-exclusive license}
}
```

### Step 4: Verify Claims

Before citing for a specific claim, **access the paper and confirm** the attributed claim actually appears.

**Common mistakes to avoid:**
- Citing a paper for a claim it doesn't make
- Attributing a method to the wrong paper
- Misrepresenting experimental results

**Example verification:**
```
Claim: "Transformers achieve state-of-the-art on machine translation"
Source: Vaswani et al., 2017
Verification: Check paper section 4 - Results confirm BLEU scores
Status: ✅ Verified
```

### Step 5: Handle Failures Explicitly

If you cannot verify a citation at ANY step:

**Option 1: Explicit placeholder in LaTeX**
```latex
% EXPLICIT PLACEHOLDER - requires human verification
\cite{PLACEHOLDER_author2024_verify_this} % TODO: Verify this citation exists
```

**Option 2: Note in text**
```latex
... as shown in prior work [CITATION NEEDED - could not verify Smith et al. 2023].
```

**Always inform the scientist:**
```
I could not verify the following citations and have marked them as placeholders:
- Smith et al. 2023 on reward hacking - could not find in Semantic Scholar
- Jones 2022 on scaling laws - found similar paper but different authors
Please verify these before submission.
```

## Summary: Citation Rules

| Situation | Action |
|-----------|--------|
| Found paper, got DOI, fetched BibTeX | ✅ Use the citation |
| Found paper, no DOI | ✅ Use arXiv BibTeX or manual entry from paper |
| Paper exists but can't fetch BibTeX | ⚠️ Mark placeholder, inform scientist |
| Uncertain if paper exists | ❌ Mark `[CITATION NEEDED]`, inform scientist |
| "I think there's a paper about X" | ❌ **NEVER cite** - search first or mark placeholder |

## 🚨 NEVER generate BibTeX from memory

**Always fetch programmatically.**

## API Documentation

### Semantic Scholar API

**Base URL:** https://api.semanticscholar.org/graph/v1

**Search endpoint:**
```http
GET https://api.semanticscholar.org/graph/v1/paper/search?query=attention+transformers&limit=5&fields=-paperId,title,authors,year,externalIds
```

**Python wrapper:**
```bash
pip install semanticscholar
```

**Rate limits:** 100 requests per 5 minutes (free tier)

### CrossRef API

**Base URL:** https://api.crossref.org

**DOI to BibTeX:**
```http
GET https://doi.org/{DOI}
Accept: application/x-bibtex
```

**Search works:**
```http
GET https://api.crossref.org/works?query=attention+is+all+you+need&rows=5
```

**Rate limits:** None for registered users (register for free API key)

### arXiv API

**Base URL:** http://export.arxiv.org/api/query

**Search query:**
```http
GET http://export.arxiv.org/api/query?search_query=all:attention+transformers&max_results=5
```

**Python wrapper:**
```bash
pip install arxiv
```

```python
import arxiv

search = arxiv.Search(
  query="attention transformers",
  max_results=5,
  sort_by=arxiv.SortCriterion.Relevance
)

for result in search.results():
    print(f"{result.title}")
    print(f"arXiv ID: {result.entry_id.split('/')[-1]}")
    print()
```

## Common Citation Pitfalls

### Pitfall 1: Self-Citation Breaking Anonymity
```latex
% BAD - reveals identity
As shown in our previous work [Smith2023]...

% GOOD - anonymized
As shown in prior work [cite]...
```

### Pitfall 2: Citing Unpublished Work
```latex
% BAD - reveals identity
As shown in our submitted paper [Smith2024]...

% GOOD - remove or anonymize
Related work [cite] has shown...
```

### Pitfall 3: Incorrect Author Names
```
WRONG: Vaswani et al., 2017
CORRECT: Vaswani, Shazeer, Parmar, et al., 2017
```

### Pitfall 4: Wrong Venue
```
WRONG: NeurIPS 2017
CORRECT: NeurIPS 2017 (actually published at NeurIPS 2017)
```

## Citation Management Best Practices

### BibTeX File Organization
```bibtex
% Organize by type or topic

% ============ Transformer Architecture ============
@article{Vaswani2017Attention,
    author = {Vaswani, Ashish and Shazeer, Noam and ...},
    title = {Attention Is All You Need},
    year = {2017},
    ...
}

% ============ Language Models ============
@article{Brown2020Language,
    author = {Brown, Tom and ...},
    title = {Language Models are Few-Shot Learners},
    year = {2020},
    ...
}
```

### Consistent Citation Keys
Use consistent format: `FirstAuthorLastTwoDigitsOfYear_Descriptor`

```
Vaswani2017_Attention
Brown2020_LanguageModels
Smith2024_OurMethod
```

### Citation Verification Checklist

Before submitting:
- [ ] All citations have verified BibTeX entries
- [ ] No `[CITATION NEEDED]` placeholders remain
- [ ] No self-citations break double-blind review
- [ ] All DOIs resolve correctly
- [ ] Author names are correct and complete
- [ ] Publication years and venues are accurate
- [ ] Claims attributed to citations are verified

## Tools and Resources

### Python Libraries
```bash
# Semantic Scholar API
pip install semanticscholar

# arXiv API
pip install arxiv

# CrossRef API (use requests directly)
pip install requests
```

### Online Tools
- **Semantic Scholar**: https://www.semanticscholar.org - Search and verify papers
- **Google Scholar**: https://scholar.google.com - Backup search
- **doi.org**: https://doi.org - DOI resolver
- **arXiv.org**: https://arxiv.org - Preprint verification

### LaTeX Citation Management
- **BibTeX**: Standard for LaTeX
- **BibLaTeX**: Modern alternative to BibTeX
- **JabRef**: GUI for managing .bib files
- **Zotero**: Reference manager with BibTeX export

## When You're Uncertain

If you're even slightly uncertain about a citation:
1. Mark it as `[CITATION NEEDED]` or `[PLACEHOLDER]`
2. Explain what you're uncertain about
3. Ask the scientist to verify
4. Never guess or invent

**Better to have a placeholder than a hallucinated citation.**
