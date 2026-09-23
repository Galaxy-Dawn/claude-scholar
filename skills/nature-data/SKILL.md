---
name: nature-data
description: >-
  Prepare, audit, or revise Nature-ready Data Availability statements, data repository plans,
  dataset citations, and FAIR metadata checklists for manuscripts. Use when the user asks about
  Nature data availability, research data sharing, repository selection, accession numbers,
  restricted or sensitive data, source data, supplementary datasets, DataCite-style dataset
  references, FAIR metadata for academic publication, or Chinese-to-English data availability
  wording for Chinese-speaking authors preparing Nature-family submissions.
---

# Nature Data Availability Skill

Use this skill to turn a manuscript's supporting data into a transparent, Nature-ready data
availability package: statement text, repository plan, dataset citations, and missing-information
flags.

The governing policy layer is Springer Nature / Nature Portfolio data policy. The implementation
layer is FAIR data practice and DataCite-style citation metadata.

For academic wording only, the active installed
`skills/ml-paper-writing/references/knowledge/paper-miner-writing-memory.md`
under the current client's skill home may offer relevant phrasing examples.
Use it only when it contains source-attributed availability language. Journal
policy and the author's actual data-access facts take precedence. If the memory
is absent or irrelevant, continue without it.

## Chinese-user operating mode

When the user writes in Chinese, provides a Chinese manuscript note, or asks for "中文对应",
"中英对照", "数据可用性声明", "数据获取声明", "原始数据", "数据存储库", or "受限数据":

- Accept Chinese input naturally, but draft the final submission-ready statement in English unless
  the user explicitly asks for Chinese only.
- Preserve a short Chinese explanation of unresolved decisions when it helps the author act.
- Translate intent, not wording. Chinese phrases such as "可向通讯作者索取" are usually too vague
  for Nature-style English unless the restriction and access process are specified.
- Convert Chinese repository/status descriptions into precise publication terms:
  `数据可用性声明` -> `Data Availability`; `原始数据` -> `raw data`;
  `处理后数据` -> `processed data`; `源数据` -> `source data`;
  `补充材料` -> `Supplementary Information`; `受限数据` -> `restricted data`;
  `合理请求` -> `reasonable request`, only with reason and review route.
- Use `references/chinese-author-alignment.md` for Chinese terminology, common CN-to-EN failure
  modes, and bilingual intake questions.

## Default stance

- Treat the Data Availability statement as a link between the paper's claims and the evidence
  needed to inspect, reproduce, or reuse them.
- Do not invent DOIs, accession numbers, repository names, licences, embargo dates, ethics
  approvals, access committees, or data-use conditions.
- Prefer public, discipline-specific repositories. Use generalist or institutional repositories
  only when no suitable community repository exists.
- Describe both newly generated data and reused third-party data.
- If data cannot be openly shared, state why, who controls access, how requests are evaluated,
  and what metadata or representative data can still be public.
- Separate data, code, materials, and protocols unless the journal asks for a combined
  availability section.
- Keep this skill focused on availability and metadata. Do not rewrite methods, analyze
  statistics, or polish the manuscript unless the user asks for those tasks separately.
- Flag "available upon request" as weak unless there is a specific legal, ethical, commercial, or
  third-party restriction.

## Workflow

1. Identify the target journal and article type. If journal-specific instructions conflict with
   this skill, follow the journal.
2. Inventory every dataset needed to support the main and supplementary results:
   generated raw data, processed data, figure source data, secondary data, software outputs,
   models, tables, images, and files underlying statistical analysis.
3. Classify each dataset into one access route:
   `public repository`, `controlled access repository`, `within paper or supplement`,
   `reused public source`, `third-party restricted`, `available on justified request`,
   or `not applicable`.
4. Choose repository and identifier strategy before drafting text. Prefer DOI, accession number,
   Handle, ARK, or stable repository record over personal websites and temporary cloud links.
5. Draft the Data Availability statement using explicit dataset-to-location mapping.
6. Add formal dataset citations for public data that support conclusions.
7. Run the FAIR and metadata audit before finalizing.
8. Return ready-to-paste statement text plus any unresolved fields the author must confirm.

## Output format

Unless the user asks for another format, return:

```text
Data Availability
[ready-to-paste statement]

Repository and citation actions
- [specific actions or "None"]

Missing information / risk flags
- [specific flags or "None"]

中文核对
- [用中文列出作者需要确认的字段或 "无"]
```

When auditing an existing statement, lead with blocking issues first, then provide a revised
version.

## Related files

| File | Open when |
|---|---|
| [references/policy-principles.md](references/policy-principles.md) | You need the governing Nature/Springer Nature data-sharing rules or edge-case policy logic |
| [references/chinese-author-alignment.md](references/chinese-author-alignment.md) | The user writes in Chinese, needs bilingual wording, or provides Chinese availability notes |
| [references/statement-patterns.md](references/statement-patterns.md) | You need ready-to-adapt Data Availability statement patterns |
| [references/repository-and-identifiers.md](references/repository-and-identifiers.md) | You need repository choice, accession, DOI, embargo, versioning, or dataset citation guidance |
| [references/fair-metadata-checklist.md](references/fair-metadata-checklist.md) | You need FAIR checks, README metadata, file organization, licences, provenance, or DataCite fields |
| [references/source-basis.md](references/source-basis.md) | You need to justify rules with official sources or check which source supports which rule |

## Source hierarchy

Use sources in this order:

1. Target journal instructions and submission system requirements.
2. Nature Portfolio / Springer Nature data, code, materials, and reporting policies.
3. Repository-specific requirements and domain community standards.
4. FAIR principles and DataCite metadata practice.

If a policy detail may have changed, verify the current journal page before giving final
submission advice.
