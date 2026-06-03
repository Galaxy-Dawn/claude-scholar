---
name: obsidian-project-kb-core
description: Use this as the main Kimi Scholar skill for a vault-first, project-scoped Obsidian research knowledge base rooted at Research/{project-slug}/. It owns bootstrap, routing, daily logging, hub/plan/index maintenance, registry updates, lifecycle actions, and lint orchestration.
---

# Obsidian Project KB Core

This is the **main workflow authority** for project-scoped Obsidian knowledge maintenance.

Default project root:

```text
Research/{project-slug}/
```

Default structure:

```text
00-Hub.md
01-Plan.md
02-Index.md
Sources/
Knowledge/
Experiments/
Results/
  Reports/
Writing/
Daily/
Maps/
Archive/
_system/
```

## Core rules

- Keep all durable project knowledge inside the current `Research/{project-slug}/`.
- Keep repo-local `.kimi-code/project-memory/*` only as the runtime binding layer.
- `_system/registry.md` is the only visible project registry.
- `02-Index.md` is a human navigation note, not a registry mirror.
- `Maps/` is a derived-artifact area; do not generate non-essential canvases by default.
- `Results/Reports/` is the default subdirectory for round and batch experiment reports.

## Responsibilities

- detect and bind the current repo to a project root
- bootstrap the project skeleton
- route notes into `Sources / Knowledge / Experiments / Results / Results/Reports / Writing / Daily / Maps / Archive`
- update `00-Hub.md`, `01-Plan.md`, `02-Index.md`
- update `_system/registry.md`, `_system/schema.md`, `_system/lint-report.md`
- handle note lifecycle actions: create, update, rename, archive, purge, promote, and link repair
- run deterministic health checks through helper scripts

## Deterministic helpers

Use the scripts under `scripts/` for:
- scaffold
- registry consistency
- link checks
- index checks
- canvas checks
- lint aggregation

Use agents for:
- note routing
- daily promotion decisions
- source vs knowledge judgment
- stable-result judgment
- semantic Hub and Index updates

## Read next

- `references/DIRECTORY-SCHEMA.md`
- `references/HUB-PLAN-INDEX.md`
- `references/REGISTRY.md`
- `references/DAILY-PROMOTION.md`
- `references/LIFECYCLE.md`
- `references/LINT.md`
- `references/BINDING-LAYER.md`
