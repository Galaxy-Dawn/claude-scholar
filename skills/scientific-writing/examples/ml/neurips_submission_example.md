# NeurIPS Submission Example: Proactive Drafting Workflow

## Example Scenario

You have a research repository with:
- Code implementing a new contrastive learning method for graphs
- Experimental results on 5 datasets
- Some existing citations in README.md

## Step 1: Understand the Project

```bash
# Explore repo structure
ls -la
find . -name "*.py" | head -20
find . -name "*.md" | xargs grep -l -i "result\|conclusion"

# Key findings:
# - README describes "GraphContrast: Contrastive learning on graph structure"
# - results/ contains accuracy tables for 5 datasets
# - configs/ shows hyperparameters
# - references.bib has 15 existing citations
```

## Step 2: Verify the Narrative

**Before writing, confirm with the scientist:**

```
Based on my analysis of your repository, the main contribution appears to be:

"We demonstrate that contrastive learning on graph structure achieves
15% better representation quality than node features alone, enabling
transfer learning across graph domains without retraining."

Is this the correct framing? Should I emphasize different aspects?
```

## Step 3: Verify Citations

**For each citation needed:**

```python
# Search for paper
from semanticscholar import SemanticScholar
sch = SemanticScholar()
results = sch.search_paper("graph contrastive learning", limit=5)

# Verify paper exists
for paper in results:
    print(f"{paper.title}")
    print(f"DOI: {paper.externalIds.get('DOI', 'N/A')}")

# Fetch BibTeX via DOI
import requests
doi = "10.48550/arXiv.2010.13983"
response = requests.get(f"https://doi.org/{doi}",
                       headers={"Accept": "application/x-bibtex"})
bibtex = response.text
print(bibtex)
```

## Step 4: Write Complete First Draft

**Deliver full draft, not fragments:**

---

# GraphContrast: Contrastive Graph Representation Learning via Structure Encoding

## Abstract

We introduce GraphContrast, a contrastive learning framework for graph
representation learning that achieves state-of-the-art results on five
benchmark datasets. Graph structure is difficult to leverage effectively
due to the lack of natural data augmentation strategies. Our method learns
representations by contrasting node neighborhoods across multiple views
of the graph, using a novel graph-specific augmentation strategy. We
demonstrate state-of-the-art results on benchmark datasets ranging from
3K to 2M nodes. Our method achieves 92.1% accuracy on the largest
dataset, 15% better than the previous best approach.

## Introduction

Graph neural networks have achieved remarkable success on graph-structured
data [cite]. However, they typically require large amounts of labeled
data for training [cite]. Self-supervised learning offers a promising
alternative by learning from unlabeled graph structure [cite].

**[FLAG: I framed this as a self-supervised learning problem. Adjust if
you'd prefer to emphasize representation quality or transfer learning.]**

In this paper, we introduce GraphContrast, which learns representations
by contrasting node neighborhoods across multiple graph views. Our
contributions are:

- We introduce a novel graph augmentation strategy that preserves
  structural information while creating diverse views
- We demonstrate that contrastive learning on graph structure achieves
  15% better representation quality than methods using only node features
- We show transfer learning capabilities across domains without retraining

## Methods

### Architecture

Our method consists of three components: (1) graph view generation,
(2) encoder network, and (3) contrastive loss.

**[Include figure here showing architecture]**

### Graph Augmentation

We propose two augmentation strategies:

1. **Edge dropping**: Randomly remove edges with probability p
2. **Feature masking**: Randomly mask node features with probability q

These augmentations create diverse views while preserving structural
information.

### Contrastive Loss

We use the InfoNCE loss [cite]:

[LATEX EQUATION HERE]

## Experiments

### Experimental Setup

We evaluate on five benchmark datasets: Cora, CiteSeer, PubMed,
Reddit, and ogbn-arxiv. For each dataset, we compare against:

- GraphSAGE [cite]
- GAT [cite]
- GraphCL [cite]
- MVGRL [cite]

**[I highlighted these baselines—let me know if others are more
important to include.]**

### Main Results

Our method achieves state-of-the-art results on all datasets:

[LATEX TABLE HERE]

Key observations:
- GraphContrast consistently outperforms baselines by 10-20%
- Gains are larger on datasets with richer structure (Reddit, ogbn-arxiv)
- Performance gap increases with dataset size

### Ablation Study

We ablate each component to measure its contribution:

[LATEX TABLE HERE]

Component contributions:
- Full model: 92.1% accuracy
- Without edge dropping: 87.3% (-4.8%)
- Without feature masking: 89.5% (-2.6%)
- Without both: 84.1% (-8.0%)

Edge dropping contributes most to performance, particularly on datasets
with sparse structure.

### Transfer Learning

We evaluate transfer learning by training on one dataset and testing on
another in the same domain:

[LATEX TABLE HERE]

GraphContrast achieves 80%+ transfer accuracy, demonstrating that
learned representations generalize across domains.

## Related Work

### Graph Neural Networks

Graph neural networks aggregate information from node neighborhoods
[cite]. Methods include GraphSAGE [cite], which uses sampling for
scalability, and GAT [cite], which uses attention mechanisms.

Our work differs in that we use contrastive learning to learn
representations without labels, enabling better transfer learning.

### Self-Supervised Learning on Graphs

Self-supervised methods for graphs include prediction-based [cite] and
contrastive-based [cite] approaches. GraphCL [cite] and MVGRL [cite]
use contrastive learning with different augmentation strategies.

Our work introduces novel graph-specific augmentations that better
preserve structural information.

## Limitations

Our method has several limitations:

1. **Computational cost**: Generating multiple graph views requires
   additional computation compared to single-view methods
2. **Hyperparameter sensitivity**: Performance varies with augmentation
   probabilities (p, q), requiring careful tuning
3. **Dynamic graphs**: Current implementation doesn't handle graphs that
   change over time

Despite these limitations, GraphContrast achieves strong empirical
results and enables effective transfer learning.

## Conclusion

We introduced GraphContrast, a contrastive learning framework for
graphs that achieves state-of-the-art results by leveraging graph
structure through novel augmentation strategies. Our method enables
effective transfer learning across domains without retraining, advancing
self-supervised graph representation learning.

Future work includes extending to dynamic graphs and reducing
computational cost.

## Acknowledgments

[REMOVED FOR DOUBLE-BLIND REVIEW]

## References

[BIBLIOGRAPHY HERE]

---

## Step 5: Present for Feedback

**With the draft, ask:**

```
I've drafted a complete first draft of the paper. Key decisions I made:

- Framed contribution as self-supervised learning problem
- Highlighted results on 5 datasets (3K to 2M nodes)
- Organized related work by method (GNNs, SSL) not paper-by-paper
- Included ablation study showing component contributions
- Added transfer learning experiments

I may have missed:
- Relevant work in specific areas (please add)
- Important baselines (please let me know)
- Critical experiments to include

Please review and let me know what to adjust!
```

## Step 6: Iterate Based on Feedback

**After scientist feedback:**

```
I've revised based on your feedback:

Updated:
- Added comparison against [X] baseline
- Expanded related work to include [papers]
- Moved detailed proofs to appendix
- Added broader impact statement
- Fixed citations [A, B]

What else should I adjust?
```

## NeurIPS-Specific Checklist

Before submitting to NeurIPS:

```
- [ ] Page count: 9 pages main content (references unlimited)
- [ ] Paper checklist completed (16 items)
- [ ] Double-blind: No identifying information
- [ ] Figures are vector graphics (PDF/EPS)
- [ ] All citations verified via API
- [ ] Broader impact statement included
- [ ] Limitations section present
- [ ] Supplementary material prepared (if needed)
```

## Files Created

```
my-paper/
├── main.tex           # NeurIPS template
├── neurips.sty        # Style file
├── references.bib     # All citations verified
├── figures/
│   ├── architecture.pdf
│   └── results.pdf
└── appendix.tex       # Supplementary material
```

## Key Principles Demonstrated

1. **Proactive delivery**: Complete draft, not fragments
2. **Questions with draft**: Ask alongside content, not before
3. **Verified citations**: All fetched via API
4. **Clear narrative**: What/Why/So What framework
5. **Flagged decisions**: Explicit notes on choices made
6. **NeurIPS compliance**: Checklist, page limits, double-blind
