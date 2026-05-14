---
name: nature-polishing
description: Polish, restructure, or translate academic prose into Nature-leaning English using writing-strategy principles, curated Nature/Nature Communications article patterns, and phrase-level support from Academic Phrasebank. Use whenever the user asks to polish a manuscript paragraph, abstract, introduction, results, discussion, conclusion, title, methods section, or Chinese academic draft for publication-quality English.
version: 5.0.2
author: Yuan1z skill rebuilt from course notes plus Academic Phrasebank
---

# Nature-Style Academic Polishing

Use this skill to improve scientific writing at two levels:

- `main strategy`: paper architecture, published-article patterns, section logic, reader workflow, evidence thresholds, and ethics
- `reference support`: reusable phrase families, move patterns, transitions, and style checks

The main strategy should come from the course notes in `Chapter1-Week1-7` and
the curated article-pattern reference. The wording layer should come from
`Academic Phrasebank`.

## Default stance

- Language serves argument. Do not polish sentences while leaving the reasoning broken.
- Write with empathy for the reader: relevance first, then novelty, then trust, then reuse, then meaning.
- There should be no mystery for the writer, but there may be one for the reader.
- Do not invent data, references, mechanisms, or novelty claims.
- Do not let AI draft the paper's core scientific argument from scratch.
- If the draft is Chinese or structurally rough, reconstruct the logic first and the prose second.
- Avoid em dashes in polished output by default. Prefer commas, parentheses, or full stops. Use colons sparingly unless the user explicitly asks to preserve dash-based punctuation or wants a colon-led style.

## When to open extra files

These files are reference support. Use them after the section's rhetorical job is clear.

| File | Open when |
|---|---|
| [references/published-article-patterns.md](references/published-article-patterns.md) | You need Nature/Nature Communications article-level writing patterns for abstracts, introductions, Results, Discussion, conclusions, or titles |
| [references/writing-strategy.md](references/writing-strategy.md) | You need paragraph- or section-level argument repair before sentence polishing |
| [references/section-moves.md](references/section-moves.md) | You need section-specific move orders or phrase patterns derived from Academic Phrasebank |
| [references/phrasebank-playbook.md](references/phrasebank-playbook.md) | You need hedging, transition, evidence, limitation, or future-work phrase families |
| [references/style-guardrails.md](references/style-guardrails.md) | You need academic-style checks, paragraph/sentence checks, article use, register, or mechanics |

## Core architecture

### 1. Identify the paper type first

Before editing, determine what kind of paper or section this is.

- `Research paper`: the reader asks why the phenomenon matters, what was done, what was found, and what it means.
- `Methods paper`: the reader asks whether the method works, whether it is reproducible, and whether it is better under a fair comparison.
- `Hypothesis-based work`: the argument tries to establish or rule out a causal explanation.
- `Algorithmic or device work`: the argument proposes a procedure, tool, or system and must show that it performs reliably and advantageously.

Do not use one narrative logic for all paper types.

For article-level rewrites, especially abstracts, introductions, Results openings,
Discussion paragraphs, conclusions, and titles, also apply the writing patterns in
`references/published-article-patterns.md`.

### 2. Write for the reader, not for the draft chronology

Most readers follow a stable sequence:

1. Is this relevant to me?
2. What is new here?
3. Do I trust it?
4. Can I reuse it?
5. What does it mean, and where are the boundaries?

Polishing should help the paper answer these questions in this order.

### 3. Use the hourglass structure

Strong papers often mirror an hourglass:

- `Introduction`: open broadly, then narrow to the specific gap, question, hypothesis, methods, and study
- `Discussion/Conclusion`: widen again, connecting the findings back to the literature and explaining how the knowledge gap was filled

If a paragraph or section violates this architecture, rebuild it before polishing wording.

### 4. Use the correct writing order

For a research article, a productive writing order is:

1. Results
2. Introduction and Conclusion
3. Title
4. Discussion
5. Materials and Methods
6. Authors
7. Abstract

For a methods paper, a productive writing order often begins with:

1. Methods
2. Results
3. Introduction
4. Conclusion
5. Discussion
6. Abstract

The skill should follow the logic of evidence and argument, not the raw order in which the user drafted sentences.

### 5. Protect the core argument

The paper's core argument includes:

- the scientific question the paper actually answers
- why that question matters
- how the work differs from existing research
- what the results imply
- how the main line of reasoning unfolds

AI may help polish, structure, or compare phrasings. AI should not invent or author the core argument. If the argument is weak or unclear, expose that weakness rather than hiding it under polished language.

### 6. Diagnose the failure mode before editing

Before rewriting, identify the main problem:

- wrong paper type logic
- missing gap or poor positioning
- claim without evidence
- evidence without a clear claim
- missing boundary or limitation
- Results and Discussion mixed together
- weak title or abstract signal
- sentence-level clutter only

Prioritize in this order:

`paper type -> section job -> paragraph logic -> claim/evidence/boundary -> sentence polish`

## Section responsibilities

### Introduction

The Introduction should:

- tell the reader why the work matters
- explain what gap it fills
- explain why that gap matters
- state what is already known
- state what remains unresolved
- state what question the paper asks
- indicate how the study addresses it

Do not summarize the Results section here. Do not summarize the Conclusion here.

### Results

Results are a summary of the data collected to address the problem stated in the Introduction.

Results writing should:

- stay mainly in past tense
- report what was observed, under what conditions, and with what quantitative support
- use statistics correctly and sparingly
- use supplementary data sparingly

Results should answer `what happened`, not `what it ultimately means`.

### Discussion

Discussion should answer:

- how the work fits within the broader field
- what has been added to understanding
- who should be credited for earlier work
- whether the findings support, complicate, or revise earlier results
- how the findings are interpreted
- when that interpretation may fail

Short rule:

- `Results = what we observed`
- `Discussion = how we understand it, and when it may fail`

### Conclusion

Use the three-part close:

1. restate the central contribution
2. summarize the key evidence or outcome
3. state the implication with a boundary

Do not introduce new data in the conclusion. Always run an overclaim check here.

### Title

A strong title should:

- tell the reader what to expect
- avoid unnecessary technical language
- be easy to search
- be substantiated by data
- create curiosity without sacrificing credibility

Use `curiosity with credibility`, not empty cleverness. A hook is only acceptable if the claim remains fully defensible.

### Materials and Methods

Methods should be specific, complete, transparent, and reproducible.

Another group should be able to determine:

- whether the work conforms to ethical norms
- what materials and conditions were used
- which key parameters, controls, and replicates were used
- how data were processed and analysed
- which statistical tests and software versions were used

It is acceptable to abbreviate by citing an earlier report only when that report truly contains the necessary detail.

Never leave vague phrases such as:

- `under standard conditions`
- `using routine methods`
- `data were analyzed statistically`
- `differences were significant`
- `samples were randomly assigned`
- `the method was validated`

Replace them with the actual reproducible information.

### Methods-paper variant

In a methods paper, the Results section must show the advantages of the method over existing methods. Typical questions are:

- Is it more reliable?
- Is it faster?
- Does it require fewer resources?
- Is the comparison fair and reproducible?

The Methods section in a methods paper may need additional detail such as:

- axioms, conditions, and assumptions
- hardware and software environment
- mathematical derivations
- evaluation protocol
- datasets, baselines, metrics, splits, and hyperparameters

### Abstract

The abstract is a mini-paper:

`context/problem -> gap/objective -> approach -> key results -> implication`

It should answer:

1. What question was addressed?
2. How was it addressed?
3. What was found?
4. Why should anyone care?

Some journals require a strict abstract format. Follow the journal if it conflicts with the generic pattern.

## Sentence and paragraph control

### Sentence rules

- In polished prose, aim for sentences in the `10-30` word range.
- Keep every sentence at `<= 30` words.
- Do not produce full sentences under `10` words unless the user explicitly asks for terse style or the item is a heading, label, or fixed technical expression.
- If any sentence exceeds `20` words, check whether it contains more than one main proposition.
- Split overloaded sentences rather than polishing them cosmetically.
- The last sentence of a paragraph often becomes the longest and weakest. Check it explicitly.
- Prefer one core subject-verb proposition per sentence.
- Do not use em dashes as prose punctuation in the polished version unless the user explicitly requests them. Rewrite with commas, parentheses, or shorter sentences instead. Use colons only when they add clear structural value.

### Paragraph rules

- Each paragraph should have one controlling idea followed by support.
- Supporting material may include data, comparison, explanation, consequence, literature, or limitation.
- If a new idea appears, start a new paragraph instead of stacking it onto the old one.
- Use thematic linking, not repetitive `This suggests ...` openings.

### Results vs Discussion sentence types

Results sentences usually report:

- `was detected`
- `increased`
- `showed`
- `enabled`
- `achieved`

Discussion sentences usually interpret:

- `may reflect`
- `suggests that`
- `could indicate`
- `is likely due to`
- `may facilitate`

Do not let a Results paragraph drift into Discussion syntax unless the transition is intentional.

### Chinese-to-English mode

When the source is Chinese or strongly Chinese-influenced English:

- extract the core propositions first
- do not translate clause-by-clause mechanically
- reconstruct explicit logical links: contrast, cause, implication, limitation
- verify terminology, causality, hedging, and disciplinary nuance
- keep key technical terms stable

## Citation, ethics, and AI boundaries

### Intellectual debt

Originality is usually an amendment, combination, or extension of prior knowledge. A careful writer acknowledges that debt openly.

Do not minimize others' contributions just to make the present work seem more original.

### Position attribution clearly

Make it obvious:

- how the paper builds on prior work
- who was responsible for the earlier idea, method, data, or interpretation
- where the reader can locate the source

### Cite the source you actually read and verified

- Cite paper `A` for `A`'s own data, methods, claims, or conclusions.
- Cite paper `B` for `B`'s interpretation, comparison, critique, or commentary on `A`.
- Avoid leaning on secondary sources when the source article can be cited directly.

### What needs citation

- someone else's ideas
- data
- methods
- wording
- structure
- images
- distinctive interpretation

Do not assume internet material is public domain just because it is online.

### Proofreading checks

Always verify:

- grammatical errors
- typographical errors
- figure numbering
- missing citations
- whether the paper is a pleasure or an ordeal to read

### AI traffic-light boundary

`Green`: generally acceptable with author verification

- improve grammar, clarity, concision, or tone
- generate outline options or paragraph structures
- produce alternative titles or abstract phrasings
- summarize literature for categorization, not as a substitute for reading
- translate with terminology and hedging checks

`Yellow`: allowed only with strong human control

- explain methods or results for wording support
- draft reviewer-response frameworks that are then checked line by line
- help with code or statistics explanations only if outputs are reproduced and validated

`Red`: generally inappropriate

- ask AI to draft the paper's core argument from scratch
- insert AI-generated references, data, or claims without checking them
- upload unpublished manuscripts, sensitive data, or peer-review material to public models
- use AI to fabricate, manipulate, or conceal substantive image creation

The main danger is not that AI cannot write. The main danger is that it can write incorrectly with great confidence.

## Output format

Default output:

1. The polished text as plain prose, not in a code block.
2. `Revision notes:` with `3-5` short bullets on the major structural and stylistic changes.
3. If the rewrite changed section logic, say so explicitly.

If the user asks for side-by-side revision, provide:

- `Original`
- `Polished`
- `Why changed`
