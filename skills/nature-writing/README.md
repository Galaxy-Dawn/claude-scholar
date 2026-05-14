# `nature-writing` skill

A Nature-style manuscript writing skill for drafting or rebuilding sections from
author-provided claims, figures, results, notes, or Chinese drafts.

## What it does

`nature-writing` helps write:

- titles
- abstracts
- introductions
- results narratives
- discussions
- conclusions
- significance paragraphs
- manuscript outlines

It is for argument construction and section drafting. For sentence-level polish
of an existing draft, use `nature-polishing`.

## Built from

Close reading of curated Nature and Nature Communications research articles
across materials, energy systems, construction decarbonization and machine
learning, combined with the existing writing-strategy rules in this repository.

Section-level writing and reviewer-facing self-review guidance is also adapted
from Prof. Peng Sida's open research-writing notes:

- https://pengsida.notion.site/c1a22465a0fa4b15a12985223916048e
- https://github.com/pengsida/learning_research

## File structure

```text
nature-writing/
├── README.md
├── SKILL.md
└── references/
    ├── abstract.md
    ├── article-architecture.md
    ├── chinese-author-workflow.md
    ├── conclusion.md
    ├── experiments.md
    ├── introduction.md
    ├── method.md
    ├── paper-review.md
    ├── paragraph-flow.md
    ├── related-work.md
    └── examples/
```

## Key rules

| Domain | Core rule |
|---|---|
| Evidence first | Do not invent data, mechanisms, statistics, sample sizes or novelty |
| Abstract | Context, gap, approach, key result, implication, boundary |
| Introduction | Field scale, bottleneck, prior attempts, unresolved gap, present study |
| Method | Explain module motivation, design, forward process, and technical advantage |
| Results | Build an evidence ladder, not a chronological lab diary |
| Experiments | Tie every major claim to comparison, ablation, metric, or stress-test evidence |
| Discussion | Explain meaning, prior-work relation, constraints and future use |
| Review | Run adversarial self-review before submission |
| Chinese notes | Translate intent and argument, not clause order |
