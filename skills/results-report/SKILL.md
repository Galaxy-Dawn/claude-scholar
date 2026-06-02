---
name: results-report
description: This skill should be used when the user asks to "write an experiment report", "summarize experimental results", "do experiment retrospection", "write a results report", "写实验总结报告", "写实验复盘", or mentions turning completed experiment artifacts into a structured, decision-oriented research report. It assumes strict analysis should come from `results-analysis` first.
version: 0.1.0
tags: [Research, Reporting, Experiments, Obsidian]
---

# Results Report

Write the **complete post-experiment summary report** after analysis artifacts are ready.

This skill is for the stage **after** `results-analysis`.

## Role boundary

### `results-analysis` does
- strict statistics,
- real figures,
- figure interpretation scaffolding,
- stats appendix.

### `results-report` does
- complete experiment wrap-up report,
- decision-oriented narrative,
- figure-by-figure interpretation inside a coherent structure,
- limitations, failure cases, and next actions,
- Obsidian write-back into `Results/Reports/`.

When the task is to create or redesign paper-ready figures/tables themselves, rely on `publication-chart-skill` instead of expanding `results-report` into figure/table production.

Do not replace strict analysis with confident prose. If the analysis bundle is missing, first identify the blocker and request or produce the missing bundle.

Hard gate: do not write a complete report when `analysis-report.md`, `stats-appendix.md`, `figure-catalog.md`, provenance, or the primary comparison question is missing. In that case, write only a blocker summary and route back to `results-analysis`.

## Default output

The default report is an **internal research report**, not manuscript prose.

It should be named as:

```text
YYYY-MM-DD--{experiment-line}--r{round}--{purpose}.md
```

Example:
- `2026-03-18--freezing--r03--transfer-summary.md`
- `2026-03-18--contrastive-adversarial--r02--ablation-report.md`

The note title should be:

```text
{Experiment Line} / Round {N} / {Purpose} / {YYYY-MM-DD}
```

Read `references/report-naming.md` before finalizing the filename or note title.

## Required frontmatter

```yaml
---
type: results-report
date: 2026-03-18
experiment_line: freezing
round: 3
purpose: transfer-summary
status: active
source_artifacts:
  - analysis-output/analysis-report.md
  - analysis-output/stats-appendix.md
linked_experiments:
  - Experiments/Freezing-Study.md
linked_results:
  - Results/Freezing-vs-Adapter.md
---
```

## Default report structure

The report must include all sections below.

1. **Executive Summary**
2. **Experiment Identity and Decision Context**
3. **Setup and Evaluation Protocol**
4. **Main Findings**
5. **Statistical Validation**
6. **Figure-by-Figure Interpretation**
7. **Failure Cases / Negative Results / Limitations**
8. **What Changed Our Belief**
9. **Next Actions**
10. **Artifact and Reproducibility Index**

Read `references/report-structure.md` before writing.

## Workflow

### 1. Confirm the report object

Lock these fields first:
- date,
- experiment line,
- round,
- purpose,
- linked experiment note,
- linked durable result note if one already exists.

If round is unknown, do not silently invent a semantic round. Use `r00` only as a temporary placeholder and state that it should be normalized later.

### 2. Read the strict analysis bundle

Minimum required inputs:
- `analysis-report.md`
- `stats-appendix.md`
- `figure-catalog.md`
- actual figures, if available

If these are missing, either generate them first with `results-analysis` or explicitly state which claims cannot be supported.
Do not turn loose CSV/Markdown artifacts into a polished report unless the strict analysis bundle has already validated unit of analysis, primary metric, and claim wording.

### 3. Write the report as a decision object

This report is not a transcript of outputs.

Each section must answer a real question:
- What did we test?
- What changed numerically?
- What is actually supported?
- What failed or remains uncertain?
- What should we do next?

Read `references/decision-oriented-analysis.md` for the expected reasoning depth.

### 4. Interpret figures inside the report

Do not only attach figures.

For each main figure:
- introduce why it is included,
- state the key observation,
- explain the supported interpretation,
- explain the decision implication.

Read `references/figure-interpretation.md` and `references/statistical-completeness.md` as needed.

### 5. Choose the write target explicitly

If the current repo is bound to an Obsidian project knowledge base:
- create or update `Results/Reports/{report-name}.md`,
- link back to the relevant `Experiments/` note,
- update the matching canonical `Results/` note when a durable conclusion is now supported,
- append a short trace to today's `Daily/` note,
- update `.kimi/project-memory/<project_id>.md`.

If the repo is **not** bound:
- write the report as a local markdown artifact in the requested output location or next to the analysis bundle,
- keep the same filename contract,
- explicitly say that no Obsidian write-back was attempted.

Use `obsidian-project-kb-core` conventions only for bound repos. Internal experiment reports belong in `Results/Reports/`, not `Writing/`.

### 6. End with explicit next actions

The report must end with operational decisions, for example:
- stop a weak branch,
- schedule one missing ablation,
- promote a stable finding into manuscript-facing writing,
- update the active plan.

## Required quality bar

- The report must be dateable, searchable, and attributable to one experiment line and one round.
- The report must cite actual evidence from the analysis bundle.
- The report must include negative results when they matter.
- The report must separate stable conclusion from tentative interpretation.
- The report must say what changed in project belief and what should happen next.
- The report must preserve Claim Candidate wording and must not promote `speculative` or `observed` claims into decisive conclusions.

## Reference files

Load only what is needed:
- `references/report-structure.md`
- `references/report-naming.md`
- `references/figure-interpretation.md`
- `references/statistical-completeness.md`
- `references/decision-oriented-analysis.md`
- `references/EVIDENCE-PROPAGATION.md`
- `examples/example-results-report.md`
