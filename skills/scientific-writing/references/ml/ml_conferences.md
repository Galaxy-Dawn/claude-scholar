# ML Conference Requirements Quick Reference

## Overview

This document provides comprehensive guidance for submitting to top ML/AI conferences: **NeurIPS, ICML, ICLR, ACL, AAAI, and COLM**.

## Conference Requirements Table

| Conference | Page Limit | Extra for Camera-Ready | Key Requirement | Accept Rate |
|------------|------------|------------------------|-----------------|-------------|
| **NeurIPS 2025** | 9 pages | +0 | Mandatory checklist, lay summary for accepted | ~20-25% |
| **ICML 2026** | 8 pages | +1 | Broader Impact Statement required | ~20-25% |
| **ICLR 2026** | 9 pages | +1 | LLM disclosure required, reciprocal reviewing | ~30-35% |
| **ACL 2025** | 8 pages (long) | varies | Limitations section mandatory | ~25-30% |
| **AAAI 2026** | 7 pages | +1 | Strict style file adherence | ~15-20% |
| **COLM 2025** | 9 pages | +1 | Focus on language models | ~30-35% |
| **KDD** | 10 pages | varies | Application-oriented, reproducibility | ~15-20% |
| **CVPR** | 8 pages | varies | Computer vision focus | ~20-25% |

## Universal Requirements

All ML conferences require:
- **Double-blind review** (anonymize submissions)
- **References don't count toward page limit**
- **Appendices unlimited** but reviewers not required to read
- **LaTeX required** for all venues
- **PDF submission only**

## NeurIPS-Specific Requirements

### Page Limit and Format
- **9 pages** for main content + unlimited pages for references
- **No extra pages** for camera-ready (unlike ICML/ICLR)
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
Reviewers assess on four dimensions:
- **Quality**: Technical soundness, well-supported claims
- **Clarity**: Clear writing, reproducible by experts
- **Significance**: Community impact, advances understanding
- **Originality**: New insights (doesn't require new method)

### Scoring Scale (6-point)
- 6: Strong Accept - Groundbreaking, flawless
- 5: Accept - Technically solid, high impact
- 4: Borderline Accept - Solid, limited evaluation
- 3: Borderline Reject - Solid but weaknesses outweigh
- 2: Reject - Technical flaws
- 1: Strong Reject - Known results or ethics issues

## ICML-Specific Requirements

### Page Limit and Format
- **8 pages** for main content + unlimited pages for references
- **+1 page** for camera-ready
- LaTeX template: `icml2026.sty`

### Required Sections
1. **Broader Impact Statement** (after conclusion): Discuss potential societal implications
2. **Reproducibility Checklist**: Code, data, hyperparameters disclosure

### Common Pitfalls
- Missing Broader Impact → desk rejection
- Incomplete reproducibility information → lower scores
- Not using official template → formatting rejection

## ICLR-Specific Requirements

### Page Limit and Format
- **9 pages** for main content + unlimited pages for references
- **+1 page** for camera-ready
- LaTeX template: `iclr2026_conference.sty`

### Required Sections
1. **LLM Usage Disclosure**: If LLMs were used in paper generation or experiments
2. **Reciprocal Reviewing Agreement**: Commitment to review for ICLR
3. **Limitations Section**: Required, not optional

### Unique Features
- **Open Reviewing**: Reviews and author responses are public
- **Rebuttal Phase**: Authors can respond to reviews before final decision
- **Double-blind**: Authors and reviewers anonymous to each other

### Common Pitfalls
- Missing LLM disclosure → ethics violation
- Not submitting rebuttal → missed opportunity
- Weak limitations section → reviewer criticism

## ACL/EMNLP-Specific Requirements

### Page Limit and Format
- **8 pages** for main content (long papers)
- **4 pages** for short papers
- Unlimited pages for references
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

## AAAI-Specific Requirements

### Page Limit and Format
- **7 pages** for main content + unlimited pages for references
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

## COLM-Specific Requirements

### Page Limit and Format
- **9 pages** for main content + unlimited pages for references
- **+1 page** for camera-ready
- LaTeX template: `colm2025_conference.sty`

### Language Model Focus
- Papers must focus on language models
- Empirical, theoretical, or conceptual contributions welcome
- Interdisciplinary work encouraged

### Required Sections
1. **LLM Usage Disclosure**: Similar to ICLR
2. **Limitations Section**: Required

## KDD-Specific Requirements

### Page Limit and Format
- **10 pages** for main content
- Varies by year
- Application-oriented track available

### Data Mining Focus
- **Real-world applications** valued
- **Reproducibility** strongly emphasized
- **Dataset availability** required where possible

### Required Sections
1. **Reproducibility Statement**: Code, data, experimental setup
2. **Application Description** (for applied track)

## CVPR-Specific Requirements

### Page Limit and Format
- **8 pages** for main content
- Varies by year
- Computer vision focus

### Vision-Specific Requirements
- **High-quality figures** essential
- **Visual results** in supplementary material
- **Dataset documentation** with image examples

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

## Supplementary Material

### What Goes in Appendix
- Additional proofs and derivations
- Extended experimental results
- Additional tables and figures
- Implementation details

### Reviewer Policy
- Reviewers are **not required** to read appendices
- Critical content must be in main paper
- Appendix is for supplementary details only

### Best Practices
- Reference appendix explicitly: "See Appendix A for full proof"
- Keep appendix organized with clear sections
- Don't put key results in appendix only

## Submission Workflow

### Pre-Submission Checklist
```
- [ ] Verify page limit for target venue
- [ ] Compile with correct LaTeX template
- [ ] Complete all required sections (checklist, impact statement, etc.)
- [ ] Anonymize all identifying information
- [ ] Verify citation formatting
- [ ] Check figure/table quality
- [ ] Test PDF compilation multiple times
- [ ] Review submission PDF for formatting issues
```

### Common Submission Errors
1. **Wrong template**: Using ICML template for NeurIPS
2. **Exceeded page limit**: Including references in page count
3. **Missing required sections**: No checklist or impact statement
4. **Broken anonymity**: Self-references reveal identity
5. **Compilation errors**: Missing .sty files or packages

### Camera-Ready Process
1. **Add author names**: Back-insert into final version
2. **Add acknowledgments**: Thank collaborators and funders
3. **Update references**: Add "under review" citations as published
4. **Fix reviewer feedback**: Address issues from reviews
5. **Submit additional materials**: Code, data, supplementary

## When Papers Get Rejected

### Resubmission Strategy
1. **Address reviewer concerns**: Major issues must be fixed
2. **Add requested experiments**: Reviewers often ask for additional baselines
3. **Adjust narrative**: Reframe contribution if suggested
4. **Convert format**: Use target venue's template
5. **Don't reference previous submission**: Maintain double-blind

### Format Conversion
See `conference_conversion.md` for detailed guidance on converting between conference formats.

## References

- **Official Conference Websites**:
  - NeurIPS: https://neurips.cc/Conferences/2025/PaperInformation/StyleFiles
  - ICML: https://icml.cc/Conferences/2025/AuthorInstructions
  - ICLR: https://iclr.cc/Conferences/2026/AuthorGuide
  - ACL: https://github.com/acl-org/acl-style-files
  - AAAI: https://aaai.org/conference/aaai/aaai-26-submit/

- **Reviewer Guidelines**:
  - See `reviewer_guidelines.md` for detailed evaluation criteria

- **Templates**:
  - See `latex_templates.md` for LaTeX template usage
