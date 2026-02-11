---
name: Research Ideation
description: This skill should be used when the user asks to "brainstorm research ideas", "use 5W1H framework", "identify research gaps", "conduct gap analysis", "start research project", "conduct literature review", "define research question", "select research method", "plan research", or mentions research project initiation phase. Provides comprehensive guidance for research startup workflow from idea generation to planning.
version: 0.1.0
---

# Research Ideation

Supports the complete workflow for the research project initiation phase, from literature review to research question definition, method selection, and research planning.

## Core Features

### 1. Idea Brainstorming (5W1H Framework)

Systematically brainstorm research ideas using the 5W1H framework:
- **What**: What problem or phenomenon to study
- **Why**: Why this problem is important
- **Who**: Target audience and stakeholders
- **When**: Time scope and context of the research
- **Where**: Application scenarios and domains
- **How**: Preliminary research methodology ideas

**Integration with superpowers:brainstorming**: Can invoke the superpowers:brainstorming skill for interactive brainstorming to help rapidly generate and evaluate research ideas.

### 2. Literature Review

Systematically search, analyze, and synthesize related literature:
- Build effective search keywords
- Select appropriate academic databases (arXiv, Semantic Scholar, Google Scholar)
- Screen and evaluate paper quality
- Identify research trends and gaps
- Generate structured literature reviews

### 3. Gap Analysis

Systematically identify and evaluate research gaps:
- **Literature gaps**: Identify topics or questions not yet sufficiently studied
- **Methodological gaps**: Discover limitations and improvement opportunities in existing methods
- **Application gaps**: Identify opportunities for theory-to-practice transfer
- **Interdisciplinary gaps**: Discover research opportunities at the intersection of different fields
- **Temporal gaps**: Identify new research needs arising from changes over time

**Analysis Dimensions:**
- Coverage of research topics
- Comparison of strengths and weaknesses of existing methods
- Completeness of experimental setups
- Availability of datasets and benchmarks
- Gap between theory and practice

### 4. Research Question Definition

Formulate specific research questions based on literature analysis:
- Identify research gaps and opportunities
- Apply SMART principles to formulate questions
- Evaluate importance, novelty, and feasibility
- Define research objectives and expected contributions

### 5. Method Selection

Select appropriate research methods:
- Analyze strengths and weaknesses of existing methods
- Evaluate method applicability
- Identify required technologies and resources
- Consider method feasibility

### 6. Research Planning

Develop detailed research plans:
- Plan research timeline
- Define milestones and deliverables
- Identify potential risks
- Assess resource requirements

## When to Use

### Scenarios for This Skill

Use the research-ideation skill in the following situations:

1. **Starting a new research project** - Have research interests but no clear research question yet
2. **Literature review** - Need to systematically understand a research field
3. **Research question formulation** - Need to transform vague ideas into specific research questions
4. **Method selection** - Need to choose appropriate research methods and technical approaches
5. **Research planning** - Need to plan research timeline and resources

### Typical Workflow

```
Research interest → Idea brainstorming (5W1H) → Literature review → Gap analysis → Define question → Select method → Create plan
```

**Output Files:**
- `literature-review.md` - Structured literature review
- `research-proposal.md` - Research proposal (including question, method, plan)
- `references.bib` - References in BibTeX format

## Integration with Other Systems

### Complete Research Workflow

```
research-ideation (Research initiation)
    ↓
Experiment execution (completed by user)
    ↓
results-analysis (Results analysis)
    ↓
ml-paper-writing (Paper writing)
```

### Data Flow

- **research-ideation output** → Guides experiment design and method selection
- **Experimental results** → results-analysis for statistical analysis
- **Analysis results** → Related Work and Methods sections of ml-paper-writing

### Key Configuration

- **Literature search scope**: Papers from the last 3 years by default, configurable
- **Output format**: Markdown format for easy editing and version control
- **Citation management**: Generates references in BibTeX format

## Additional Resources

### Reference Files

Detailed methodology guides, loaded on demand:

- **`references/5w1h-framework.md`** - 5W1H Framework Guide
  - What, Why, Who, When, Where, How — six dimensions
  - Systematic approach to brainstorming research ideas
  - Integration with superpowers:brainstorming
  - Usage examples and best practices

- **`references/literature-search-strategies.md`** - Literature Search Strategies
  - Keyword construction techniques
  - Academic database selection (arXiv, Semantic Scholar, Google Scholar)
  - Search tips and screening criteria
  - Paper quality evaluation methods

- **`references/gap-analysis-guide.md`** - Gap Analysis Guide
  - 5 types of Gap Analysis (literature, methodological, application, interdisciplinary, temporal)
  - 5 analysis dimensions
  - Systematic approach to identifying research opportunities
  - Usage examples and best practices

- **`references/research-question-formulation.md`** - Research Question Formulation
  - Applying SMART principles
  - Question type classification (exploratory, confirmatory, applied)
  - Evaluation criteria (importance, novelty, feasibility)
  - Defining research objectives and contributions

- **`references/method-selection-guide.md`** - Method Selection Guide
  - Common research method classification
  - Method applicability analysis
  - Strengths and weaknesses comparison
  - Resource requirement assessment

- **`references/research-planning.md`** - Research Planning
  - Timeline planning methods
  - Milestone definition techniques
  - Risk identification and mitigation
  - Resource allocation strategies

### Example Files

Complete working examples:

- **`examples/example-literature-review.md`** - Literature Review Example
  - Demonstrates structured literature review format
  - Includes research trend analysis and gap identification

- **`examples/example-research-proposal.md`** - Research Proposal Example
  - Demonstrates complete research proposal structure
  - Includes complete examples of question, method, and plan
