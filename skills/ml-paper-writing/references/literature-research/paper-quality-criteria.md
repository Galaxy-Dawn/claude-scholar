# ML Paper Quality Evaluation Criteria

## Overview

Use these criteria to evaluate ML research papers found during literature search or when selecting papers for detailed review. The 5-dimension framework provides structured assessment for paper selection and comparison.

---

## Evaluation Dimensions

| Dimension | Weight | Description |
|-----------|--------|-------------|
| **Innovation** | 30% | Novelty and originality of contribution |
| **Method Completeness** | 25% | Clarity, rigor, and reproducibility |
| **Experimental Thoroughness** | 25% | Validation depth and analysis quality |
| **Writing Quality** | 10% | Clarity and presentation |
| **Relevance & Impact** | 10% | Domain importance and potential impact |

---

## Detailed Scoring Rubrics

### 1. Innovation (30%)

**Score 5 - Breakthrough:**
- Proposes entirely new paradigm or framework
- Solves long-standing open problem
- Major impact expected on the field
- Challenges fundamental assumptions

**Score 4 - Significant Innovation:**
- Substantial improvement over existing methods
- New insights or perspectives
- Novel combination of techniques
- Clear advancement over state-of-the-art

**Score 3 - Methodological Innovation:**
- New method or architecture proposed
- Some novelty but incremental
- Reasonable contribution
- Standard type of innovation

**Score 2 - Incremental Improvement:**
- Minor improvements to existing methods
- Limited novelty
- Small advancement
- Mostly derivative

**Score 1 - Trivial:**
- Minimal contribution
- Obvious extension
- No real innovation
- Known results

**Evaluation Questions:**
- Does this paper propose something genuinely new?
- Does it advance the state-of-the-art?
- Will this influence future work?
- Is the contribution significant or marginal?

---

### 2. Method Completeness (25%)

**Score 5 - Complete and Rigorous:**
- Full mathematical derivation
- All hyperparameters specified
- Complete algorithmic details
- Easily reproducible
- Code available

**Score 4 - Very Complete:**
- Detailed method description
- Most important details included
- Mostly reproducible
- Minor gaps in documentation

**Score 3 - Reproducible:**
- Core method clearly described
- Key details present
- Can be reproduced with effort
- Some ambiguity in details

**Score 2 - Lacks Details:**
- Key details missing
- Difficult to reproduce
- Incomplete description
- Ambiguous in important areas

**Score 1 - Unclear:**
- Method description unclear
- Missing critical information
- Cannot determine validity
- Poorly explained

**Evaluation Questions:**
- Can another researcher reproduce this work?
- Are all important details specified?
- Is mathematical derivation sound?
- Is code available and documented?

---

### 3. Experimental Thoroughness (25%)

**Score 5 - Comprehensive:**
- Multiple diverse datasets
- Extensive ablation studies
- Statistical significance testing
- Thorough analysis and discussion
- Comparison with strong baselines

**Score 4 - Very Thorough:**
- Multiple datasets
- Reasonable ablation studies
- Proper baseline comparisons
- Good analysis

**Score 3 - Adequate:**
- Main experiments complete
- Standard datasets
- Basic baselines
- Results are credible

**Score 2 - Limited:**
- Limited experiments
- Few datasets
- Weak baselines
- Minimal analysis

**Score 1 - Insufficient:**
- Minimal validation
- Toy examples only
- No meaningful comparisons
- Results not convincing

**Evaluation Questions:**
- Are experiments comprehensive?
- Are baselines strong and appropriate?
- Are statistical tests used?
- Is there ablation analysis?
- Are results on standard datasets?

---

### 4. Writing Quality (10%)

**Score 5 - Excellent:**
- Clear, precise, well-structured
- Logical flow throughout
- Professional presentation
- High-quality figures
- No ambiguity

**Score 4 - Very Good:**
- Clear and well-written
- Mostly logical structure
- Good presentation
- Minor issues

**Score 3 - Understandable:**
- Basically clear
- Some organizational issues
- Acceptable presentation
- Understandable with effort

**Score 2 - Fair:**
- Some confusing sections
- Organization problems
- Presentation issues
- Hard to follow at times

**Score 1 - Poor:**
- Unclear or confusing
- Poor organization
- Difficult to understand
- Major presentation problems

**Evaluation Questions:**
- Is the paper easy to understand?
- Is the structure logical?
- Are figures/tables clear?
- Is the writing professional?

---

### 5. Relevance & Impact (10%)

**Score 5 - High Impact:**
- Solves important problem
- Broad applicability
- Expected wide influence
- Addresses fundamental challenge

**Score 4 - Domain Important:**
- Important problem in field
- Significant potential impact
- Relevant to many researchers

**Score 3 - Meaningful:**
- Meaningful contribution
- Moderate impact expected
- Relevant to subset of field

**Score 2 - Niche:**
- Specialized problem
- Limited applicability
- Narrow impact

**Score 1 - Limited:**
- Very narrow problem
- Minimal impact expected
- Limited relevance

**Evaluation Questions:**
- Is this an important problem?
- Will this influence future work?
- Is it relevant to current research needs?
- Does it address a significant challenge?

---

## Scoring Calculation

**Weighted Total:**
```
Total = (Innovation × 0.30) + (Method × 0.25) + (Experiments × 0.25) + (Writing × 0.10) + (Impact × 0.10)
```

**Example Calculation:**
- Innovation: 4/5
- Method: 3/5
- Experiments: 4/5
- Writing: 3/5
- Impact: 4/5

```
Total = (4 × 0.30) + (3 × 0.25) + (4 × 0.25) + (3 × 0.10) + (4 × 0.10)
      = 1.20 + 0.75 + 1.00 + 0.30 + 0.40
      = 3.65 / 5.0
```

---

## Selection Process

### For Literature Reviews

1. **Screen papers** by title/abstract for relevance
2. **Full review** of potentially relevant papers
3. **Score each paper** using all 5 dimensions
4. **Rank by total score**
5. **Select top papers** for detailed review

### Quality Thresholds

- **Excellent**: 4.0+ (include definitely)
- **Good**: 3.5-3.9 (include if relevant)
- **Fair**: 3.0-3.4 (include if highly relevant)
- **Poor**: <3.0 (exclude unless essential)

---

## Quick Screening Indicators

Before detailed review, check:

**Positive Indicators:**
- Published at top venue (NeurIPS, ICML, ICLR)
- Citations in top papers
- Code available with stars
- Authors from top labs
- Clear novelty in abstract

**Negative Indicators:**
- Vague abstract
- Limited experiments mentioned
- No baselines mentioned
- Poor writing in abstract
- incremental claims only

---

## Integration with Paper Discovery

When using arXiv search (`arxiv-search-guide.md`):

1. **Search** for relevant papers
2. **Extract metadata** from arXiv pages
3. **Quick screen** by abstract/relevance
4. **Detailed review** of promising papers
5. **Score using** these criteria
6. **Rank and select** top candidates

---

## Notes

- These criteria are designed for ML papers specifically
- Adjust weights based on your specific needs
- Use scores as relative comparisons, not absolute judgments
- Consider venue reputation as additional signal
- Code availability is increasingly important for reproducibility
