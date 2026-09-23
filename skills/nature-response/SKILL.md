---
name: nature-response
description: >-
  Draft, audit, or revise point-by-point reviewer response letters for Nature-family
  manuscript revisions. Use when the user provides reviewer comments, editor decision
  letters, revision notes, response drafts, or asks how to respond to major/minor
  revision requests, rebuttal letters, response to reviewers, peer-review reports,
  审稿意见回复, 逐点回复, 修回信, 大修回复, 小修回复, or 如何回复 reviewer.
version: 0.1.0
status: Beta
---

# Nature Reviewer Response Skill

Use this skill to convert editor decision letters, reviewer comments, author notes, or
draft rebuttals into an auditable point-by-point response package for manuscript revisions.

The response letter is an editor-facing verification document. The goal is to show that every
reviewer concern has been understood, addressed, and mapped to a concrete manuscript change,
justified scientific response, or unresolved author action.

## Default stance

- Preserve each reviewer comment faithfully before responding.
- Every reviewer concern must be answered, cross-referenced, or explicitly marked as unresolved.
- Map every response to manuscript evidence, a revision location, a justified disagreement, or `AUTHOR_INPUT_NEEDED`.
- Do not invent experiments, analyses, citations, line numbers, figure panels, supplementary materials, editor instructions, reviewer identities, or manuscript changes.
- Prefer concise, evidence-linked replies over long defensive explanations.
- When disagreeing, acknowledge the concern first, then give a scientific or scope-based reason.
- When a reviewer misunderstood the manuscript, first consider whether the manuscript presentation caused the misunderstanding.
- Treat rebuttal letters as potentially public review artifacts; write with professional tone and traceability.

## Mined writing memory

For response structure or tone, check the active installed
`skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md`
under the current client's skill home. Read only relevant rebuttal and venue
entries. Reviewer comments, manuscript changes, and journal instructions remain
the source of truth. Do not borrow claims or copy source phrasing. If the memory
is absent or has no relevant entries, continue with this skill's references.

## Accepted inputs

The skill may receive:

- editor decision letter
- reviewer comments
- previous response draft
- manuscript change notes
- tracked-change summary
- line or page numbers
- figure, table, and supplement list
- author notes in Chinese or English
- journal name and article type

If reviewer boundaries or comment segmentation are ambiguous, flag the ambiguity instead of
inventing reviewer structure.

## Workflow

1. Identify task mode and input readiness: `draft`, `audit`, `revise`, `triage-only`, or `appeal-like`.
2. Identify decision type: minor revision, major revision, revise-and-resubmit, transfer after review, or unclear.
3. Extract editor instructions first and assign IDs such as `E.1`, then split reviewer comments with IDs such as `R1.1`, `R1.2`, and `R2.1`.
4. Classify each item by category, severity, action label, missing input, readiness state, and risk.
5. Create a response strategy summary before drafting prose.
6. Draft responses using preserved reviewer comments unless the mode is `triage-only` or `appeal-like`.
7. Map each claimed change to manuscript location, figure, table, supplement, citation, or explicit placeholder.
8. Flag missing author input rather than fabricating details.
9. Run QA for completeness, traceability, factuality, tone, and unresolved risk.
10. Return the response package with package readiness: `ready_to_submit`, `draft_with_placeholders`, `needs_author_input`, or `blocked`.

## Output format

Unless the user asks for another format, return:

```text
Response strategy summary
- Decision type:
- Overall posture:
- Major risks:
- Suggested ordering:

Comment-response tracker
| ID | Reviewer concern | Type | Severity | Proposed action | Missing author input |
|---|---|---|---|---|---|

Draft point-by-point response letter
[editor-readable English response]

Manuscript change checklist
- [specific manuscript changes or placeholders]

Missing information / risk flags
- [specific unresolved items or "None"]

中文核对
- [when the user writes in Chinese; otherwise omit unless useful]
```

## Red lines

- Do not ignore any reviewer comment.
- Do not rephrase reviewer comments in a way that changes their meaning.
- Do not claim a revision was made unless the user supplied it.
- Do not invent line numbers, figure panels, citations, statistical results, or supplementary items.
- Do not use hostile or accusatory language.
- Do not cite time, money, or convenience as the primary reason for not doing a requested experiment.
- Do not hide limitations.
- Do not generate an appeal letter as the default path. Route appeal-like cases separately.
- Do not generate a cover letter in the MVP. Mention it only as adjacent revision-package material when relevant.

## Related files

| File | Open when |
|---|---|
| [references/intake-and-routing.md](references/intake-and-routing.md) | Before drafting, to identify task mode, minimum inputs, editor IDs, readiness state, and clarifying-question need |
| [references/source-basis.md](references/source-basis.md) | You need source hierarchy, rule provenance, or policy-vs-advice boundaries |
| [references/response-structure.md](references/response-structure.md) | You need the response package format or point-by-point letter anatomy |
| [references/comment-taxonomy.md](references/comment-taxonomy.md) | You need to classify reviewer comments by category and severity |
| [references/action-mapping.md](references/action-mapping.md) | You need action labels, tracker fields, and missing-input states |
| [references/tone-and-stance.md](references/tone-and-stance.md) | You need recommended language, forbidden phrasing, or disagreement tone |
| [references/chinese-author-alignment.md](references/chinese-author-alignment.md) | The user writes in Chinese or provides Chinese author notes |
| [references/difficult-cases.md](references/difficult-cases.md) | The comments involve impossible experiments, factual errors, conflicting reviewers, citations, statistics, compliance, transfer, or appeal-like cases |
| [references/qa-checklist.md](references/qa-checklist.md) | Before finalizing an output or auditing a draft response |

## Source hierarchy

Use sources in this order:

1. Target journal instructions and the editor decision letter.
2. Nature / Nature Portfolio / Springer Nature revision and peer-review process guidance.
3. Springer Nature editorial advice on rebuttal letters.
4. Local manuscript facts supplied by the author.

If a policy detail may have changed, verify the current journal page before giving final
submission advice.
