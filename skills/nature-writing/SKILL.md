---
name: nature-writing
description: Draft, restructure, or plan Nature-style manuscript sections from author-provided claims, results, figures, notes, or Chinese drafts. Use when the user wants to write or rebuild an abstract, introduction, results narrative, discussion, conclusion, title, or full manuscript argument rather than only polish finished prose.
version: 0.2.0
author: Community contribution based on curated Nature/Nature Communications writing patterns and open research-writing notes
---

# Nature-Style Scientific Writing

Use this skill when the user needs help creating or rebuilding manuscript prose,
not merely polishing existing sentences.

## Core stance

- Author evidence comes first. Do not invent results, mechanisms, references,
  methods, novelty, sample sizes, statistics or limitations.
- Write the argument before writing the sentences.
- Make the paper easy to judge: relevance, novelty, trust, reuse and meaning.
- Use ambitious but bounded claims.
- If essential evidence is missing, write a placeholder or ask for the missing
  input instead of filling the gap.

## When to open extra files

| File | Open when |
|---|---|
| [references/article-architecture.md](references/article-architecture.md) | You need section-level structure, argument order, or published-article writing patterns |
| [references/abstract.md](references/abstract.md) | Drafting or revising an abstract, especially challenge-contribution and challenge-insight-contribution forms |
| [references/introduction.md](references/introduction.md) | Drafting or revising an Introduction, task framing, technical challenge, contribution framing, or teaser/pipeline logic |
| [references/related-work.md](references/related-work.md) | Rebuilding Related Work as topic synthesis instead of a paper-by-paper list |
| [references/method.md](references/method.md) | Writing Method sections, pipeline modules, module motivation, technical advantages, or implementation details |
| [references/experiments.md](references/experiments.md) | Planning or writing Experiments/Results around baselines, ablations, metrics, tables, figures, and claim support |
| [references/conclusion.md](references/conclusion.md) | Writing a bounded conclusion with contribution, evidence, impact, limitation, and future direction |
| [references/paragraph-flow.md](references/paragraph-flow.md) | User asks whether a paragraph flows, makes sense, or is clear; use reverse outlining and paragraph-message checks |
| [references/paper-review.md](references/paper-review.md) | Final manuscript self-review, rejection-risk audit, claim-evidence alignment, or reviewer-facing critique |
| [references/chinese-author-workflow.md](references/chinese-author-workflow.md) | The user's notes are Chinese, mixed Chinese-English, or organized as lab notes rather than manuscript prose |
| [references/examples/index.md](references/examples/index.md) | You need concrete abstract, introduction, or method examples after choosing the relevant guide |

## Intake

Before drafting, identify:

- manuscript section: title, abstract, introduction, results, discussion,
  conclusion, significance paragraph or full outline
- paper type: mechanism, method, resource, device, model, clinical, materials,
  computational or interdisciplinary
- core claim: what the paper actually demonstrates
- evidence: figures, measurements, comparisons, datasets, statistics or examples
- boundary: where the claim stops
- target journal or word limit, if provided

If any of `core claim`, `evidence` or `boundary` is absent, expose the gap before
drafting. You may still produce a scaffold with explicit placeholders.

## Writing workflow

1. Build a one-sentence argument: `In [system/problem], we show [advance] using
   [approach], supported by [evidence], with [boundary].`
2. Choose the section architecture from `references/article-architecture.md`.
3. Map each paragraph to one job: context, gap, approach, result, comparison,
   mechanism, implication or limitation.
4. Draft from evidence outward. Keep claims near the data that support them.
5. Calibrate verbs: `show`, `demonstrate`, `suggest`, `indicate`, `enable`,
   `may`, `could`.
6. Remove unsupported novelty and universal claims.
7. Run a paragraph-flow check: one paragraph, one message, with a clear first
   sentence and explicit sentence-to-sentence relation.
8. Return prose plus concise notes on assumptions and missing inputs.

## Section defaults

### Abstract

Default Nature pattern:

`context/problem -> gap -> approach -> key result -> implication -> boundary`

For technical AI, ML, CV or method-heavy manuscripts, open
`references/abstract.md` and choose one of:

- `challenge -> contribution`
- `challenge -> insight -> contribution`
- `multiple contributions`

Keep it compact. Include quantitative or comparative detail when the user
provided it. End with what the work enables, not generic importance.

### Introduction

Use:

`field scale -> bottleneck -> prior attempts -> unresolved gap -> present study`

For method-heavy papers, open `references/introduction.md` and reason backward
from the technical challenge and contribution before drafting forward.

Do not summarize all results. The final paragraph should state what this paper
does and how it addresses the gap.

### Results narrative

Use an evidence ladder:

`system/workflow -> validation -> main result -> baseline comparison ->
mechanism/diagnostic analysis -> application or generalization`

Each subsection should have a claim-first opening and then data support.

For ML/conference-style experiment sections, open `references/experiments.md`
and make sure each major claim is backed by comparison, ablation, or stress-test
evidence.

### Related Work

Use:

`topic scope -> representative methods -> limitation tied to this paper ->
distinction`

Group prior work by technical topic and mechanism, not by publication year.

### Discussion

Use:

`central advance -> evidence meaning -> relation to prior work -> constraints ->
future use`

This is where interpretation and limitations belong. Do not repeat the Results
section figure by figure.

### Conclusion

Use:

`contribution -> decisive evidence -> implication -> boundary`

No new data. No unsupported promises.

### Title

Prefer concrete titles that combine:

`system/object + action/capability + application or consequence`

Avoid slogan titles, grant-style aims and overbroad field claims.

## Output format

Default output:

1. `Draft:` with the requested prose.
2. `Section outline:` with `3-7` compact bullets when the task involves a full section.
3. `Assumptions or missing inputs:` with only material issues.
4. `Claim-evidence map:` for major claims, using `Claim: ... | Evidence: ... | Status: supported/needs evidence`.
5. `Why this structure:` with `2-4` short bullets.

For Chinese author notes, provide polished English first, then brief Chinese
notes explaining major structural choices.
