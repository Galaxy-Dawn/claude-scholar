# Submission Guides Knowledge Base

> Auto-updated by paper-miner agent
> Last updated: 2026-01-25
> Initial content from scientific-writing skill references

---

## Conference Requirements Summary

| Conference | Page Limit | Camera-Ready Extra | Key Requirements | Accept Rate |
|------------|------------|--------------------|-----------------|-------------|
| **NeurIPS 2025** | 9 pages | +0 | Checklist, lay summary (accepted) | ~20-25% |
| **ICML 2026** | 8 pages | +1 | Broader Impact Statement | ~20-25% |
| **ICLR 2026** | 9 pages | +1 | LLM disclosure, limitations | ~30-35% |
| **ACL 2025** | 8 pages (long) | varies | Limitations mandatory | ~25-30% |
| **AAAI 2026** | 7 pages | +1 | Strict style compliance | ~15-20% |
| **COLM 2025** | 9 pages | +1 | Language model focus | ~30-35% |
| **KDD** | 10 pages | varies | Reproducibility emphasis | ~15-20% |

---

## NeurIPS

### Page Limit and Format
- **9 pages** main content + unlimited references
- **No extra pages** for camera-ready
- LaTeX template: `neurips_2025.sty`

### Required Sections
1. **Paper Checklist** (appendix): 16-item checklist covering reproducibility, code, data, ethics
2. **Broader Impact Statement**: For accepted papers only
3. **Lay Summary**: For accepted papers only, 200-word plain language summary

### Common Pitfalls
- Missing checklist → automatic rejection
- Not anonymizing code/data links → desk rejection
- Exceeding 9 pages (excluding references) → automatic rejection

### Reviewer Evaluation Criteria
- **Quality**: Technical soundness, well-supported claims
- **Clarity**: Clear writing, reproducible by experts
- **Significance**: Community impact, advances understanding
- **Originality**: New insights (doesn't require new method)

---

## ICML

### Page Limit and Format
- **8 pages** main content + unlimited references
- **+1 page** for camera-ready
- LaTeX template: `icml2026.sty`

### Required Sections
1. **Broader Impact Statement** (after conclusion): Discuss potential societal implications
2. **Reproducibility Checklist**: Code, data, hyperparameters disclosure

### Common Pitfalls
- Missing Broader Impact → desk rejection
- Incomplete reproducibility information → lower scores
- Not using official template → formatting rejection

---

## ICLR

### Page Limit and Format
- **9 pages** main content + unlimited references
- **+1 page** for camera-ready
- LaTeX template: `iclr2026_conference.sty`

### Required Sections
1. **LLM Usage Disclosure**: If LLMs were used in paper generation or experiments
2. **Reciprocal Reviewing Agreement**: Commitment to review for ICLR
3. **Limitations Section**: Required, not optional

### Unique Features
- **Open Reviewing**: Reviews and author responses are public
- **Rebuttal Phase**: Authors can respond to reviews before final decision

### Common Pitfalls
- Missing LLM disclosure → ethics violation
- Not submitting rebuttal → missed opportunity
- Weak limitations section → reviewer criticism

---

## ACL

### Page Limit and Format
- **8 pages** main content (long papers)
- **4 pages** for short papers
- Unlimited references
- LaTeX template: `acl.sty`

### Required Sections
1. **Limitations Section**: Mandatory, not optional
2. **Ethics Statement**: For papers involving human subjects or sensitive data

### NLP-Specific Requirements
- **Linguistic examples** must be glossed/translated
- **Dataset documentation** must include language, size, collection method
- **Evaluation metrics** appropriate for NLP tasks (BLEU, ROUGE, etc.)

### Common Pitfalls
- Missing limitations → automatic rejection
- Inadequate dataset documentation → poor scores
- Not using ACL style file → formatting issues

---

## AAAI

### Page Limit and Format
- **7 pages** main content + unlimited references
- **+1 page** for camera-ready
- LaTeX template: `aaai2026.sty`

### Strict Style Compliance
- **Very strict** adherence to style file
- No modifications to `aaai2026.sty` allowed
- Automatic formatting checks during submission

### Common Pitfalls
- Modifying style file → desk rejection
- Exceeding 7 pages → automatic rejection
- Wrong font size/margins → formatting rejection

---

## COLM

### Page Limit and Format
- **9 pages** main content + unlimited references
- **+1 page** for camera-ready
- LaTeX template: `colm2025_conference.sty`

### Language Model Focus
- Papers must focus on language models
- Empirical, theoretical, or conceptual contributions welcome
- Interdisciplinary work encouraged

### Required Sections
1. **LLM Usage Disclosure**: Similar to ICLR
2. **Limitations Section**: Required

---

## KDD

### Page Limit and Format
- **10 pages** main content
- Varies by year
- Application-oriented track available

### Data Mining Focus
- **Real-world applications** valued
- **Reproducibility** strongly emphasized
- **Dataset availability** required where possible

### Required Sections
1. **Reproducibility Statement**: Code, data, experimental setup
2. **Application Description** (for applied track)

---

## Universal Requirements

All ML conferences require:
- **Double-blind review** (anonymize submissions)
- **References don't count toward page limit**
- **Appendices unlimited** but reviewers not required to read
- **LaTeX required** for all venues
- **PDF submission only**

---

## Anonymization Requirements

### What Must Be Anonymized
- Author names and affiliations
- Acknowledgments section
- Funding sources
- Links to GitHub, personal websites
- Obvious self-references (e.g., "In our previous work [5]...")

### What Can Be Included
- Anonymous GitHub links (e.g., github.com/anonymous/repo)
- ArXiv links with anonymized versions
- Dataset links if publicly available before submission

### Code/Data Anonymization
```
Good: "Code is available at github.com/anonymous/project123"
Bad: "Code is at github.com/authorname/project"
Bad: "See our project website: authorname.edu/project"
```

---

## High-Impact Journals

### Nature

### Requirements
- **5-6 pages** main content
- **~8% acceptance rate**
- Significance statement explaining broad impact
- Introduction accessible to non-specialists
- Methods in supplementary material allowed

### What Works
- Clear conceptual advance
- Broad interest to scientific community
- Novel methods or insights
- Implications beyond immediate field

### Science

### Requirements
- **4500 words**
- **~7% acceptance rate**
- Clear statements of novelty
- Supplementary materials welcome
- Abstract must capture essence

### What Works
- Groundbreaking discoveries
- Cross-disciplinary appeal
- Technical innovation
- Strong narrative flow

### Cell

### Requirements
- **Variable length**
- **~10% acceptance rate**
- Biological focus
- Complete methods section
- Statistical rigor required

### What Works
- Novel biological insights
- Mechanistic understanding
- Therapeutic implications
- Robust validation

### PNAS

### Requirements
- **6 pages**
- **~20% acceptance rate**
- Multidisciplinary scope
- Direct submissions available
- Member-track communication

---

> **Note**: This knowledge base is continuously updated by the paper-miner agent as new papers are analyzed. For the most current venue-specific requirements, always check the official conference/journal website.
