<div align="center">
  <img src="LOGO.png" alt="Claude Scholar Logo" width="100%"/>

  <p>
    <a href="https://github.com/Galaxy-Dawn/claude-scholar/stargazers"><img src="https://img.shields.io/github/stars/Galaxy-Dawn/claude-scholar?style=flat-square&color=yellow" alt="Stars"/></a>
    <a href="https://gitcode.com/Dawngammad/claude-scholar"><img src="https://gitcode.com/Dawngammad/claude-scholar/star/badge.svg" alt="GitCode Stars"/></a>
    <a href="https://github.com/Galaxy-Dawn/claude-scholar/network/members"><img src="https://img.shields.io/github/forks/Galaxy-Dawn/claude-scholar?style=flat-square" alt="Forks"/></a>
    <img src="https://img.shields.io/github/last-commit/Galaxy-Dawn/claude-scholar?style=flat-square" alt="Last Commit"/>
    <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License"/>
  </p>

  <strong>Language</strong>: <a href="README.md">English</a> | <a href="README.zh-CN.md">中文</a> | <a href="README.ja-JP.md">日本語</a>
  <p><strong>Supported Platforms</strong>: <a href="https://github.com/Galaxy-Dawn/claude-scholar/tree/main">Claude Code</a> | <a href="https://github.com/Galaxy-Dawn/claude-scholar/tree/codex">Codex CLI</a> | <a href="https://github.com/Galaxy-Dawn/claude-scholar/tree/kimi">Kimi Code CLI</a> | <a href="https://github.com/Galaxy-Dawn/claude-scholar/tree/opencode">OpenCode</a></p>
</div>

> Semi-automated research assistant for academic research and software development, especially for computer science and AI researchers, adapted for [Codex CLI](https://github.com/openai/codex) across ideation, literature review, experiments, reporting, writing, and project knowledge management.
>
> **Branch note**: this is the **Codex CLI edition** of Claude Scholar. For the Claude Code version, see the [`main` branch](https://github.com/Galaxy-Dawn/claude-scholar/tree/main). For the Kimi Code CLI version, see the [`kimi` branch](https://github.com/Galaxy-Dawn/claude-scholar/tree/kimi). For the OpenCode version, see the [`opencode` branch](https://github.com/Galaxy-Dawn/claude-scholar/tree/opencode).


## Recent News

- **2026-06-03**: **Kimi Code CLI branch added with strong support from Kimi** — added the `kimi` branch as the Kimi Code CLI edition of Claude Scholar and thank the Kimi team for their strong support of this project.
- **2026-05-14**: **`expression-skill` made the communication core, `planning-with-files` restored as the default persistence layer, and the Nature writing stack expanded** — made [`expression-skill`](./skills/expression-skill/README.md) the explicit conclusion-first discipline for reporting, planning, file operations, and multi-step technical work; reintroduced [`planning-with-files`](./skills/planning-with-files/SKILL.md) as the default on-disk planning and progress-tracking workflow for complex tasks; introduced [`nature-writing`](./skills/nature-writing/README.md) for section drafting and argument construction; refreshed [`nature-polishing`](./skills/nature-polishing/README.md) to the latest upstream article-pattern release; and kept [`nature-response`](./skills/nature-response/README.md) plus [`nature-data`](./skills/nature-data/README.md) in the journal-writing stack.
- **2026-05-13**: **Evidence-gated research workflow and `Sources/Papers` routing tightened** — added a shared `research-contract.md` for Evidence Records, claim strength, and Claim Promotion Gates; connected research ideation, Zotero ingestion, literature synthesis, results reporting, writing, and rebuttal workflows to that contract; and clarified that project paper notes live under `Sources/Papers` before promoted claims move into `Knowledge` or `Writing`.
- **2026-04-25**: **Codex Obsidian KB lifecycle stabilized** — fixed rename, archive, purge, sync, and lint edge cases in the Codex project KB workflow, and made repo-local binding metadata consistent with the Codex runtime.
- **2026-04-24**: **Vault-first Obsidian KB workflow backported to Codex** — brought the new project-scoped Obsidian knowledge workflow to the Codex edition, consolidated the older memory skills into four focused skills, and kept project navigation human-first instead of a machine registry dump.
- **2026-04-22**: **Lightweight core and safe installer lifecycle** — replaced the large always-on `CLAUDE.md` / `AGENTS.md` files with compact core instructions, removed non-core default agents, added Chinese companion files, and added a manifest/state-based uninstall workflow so updates and removals only touch installer-owned files and config entries.
- **2026-04-15**: **pubfig and pubtab introduced** — introduced [`pubfig`](https://github.com/Galaxy-Dawn/pubfig), a Python package for publication-grade scientific figures, and [`pubtab`](https://github.com/Galaxy-Dawn/pubtab), a Python package for publication-ready tables and Excel↔LaTeX workflows. Together they provide a cleaner production stack for paper figures, benchmark tables, export control, and final artifact QA.

<details>
<summary>View older changelog</summary>

- **2026-04-15**: **[`publication-chart-skill`](./skills/publication-chart-skill/SKILL.md) integrated into Claude Scholar** — wrapped [`pubfig`](https://github.com/Galaxy-Dawn/pubfig) + [`pubtab`](https://github.com/Galaxy-Dawn/pubtab) into [`publication-chart-skill`](./skills/publication-chart-skill/SKILL.md), added the skill to the repository, and connected it to Claude Scholar's analysis and writing boundaries so publication-grade figure/table work now has an explicit handoff route instead of being mixed into general analysis or prose skills.
- **2026-03-31**: **Zotero smart-import workflow docs aligned** — updated Claude Scholar's research-facing docs around the latest `zotero-mcp` public surface: `zotero_add_items_by_identifier` is now the default paper-import path, `zotero_reconcile_collection_duplicates` is the standard post-import cleanup step, source-aware PDF cascade behavior is documented more accurately, and public vs internal diagnostics are now clearly separated.
- **2026-03-31**: **README onboarding refreshed** — clarified that Claude Scholar is especially well-suited to computer science and AI researchers, added practical getting-started scenarios after installation, improved prerequisite and branch guidance, and made the “existing local md files must be manually merged” expectation much more explicit.
- **2026-03-31**: **Installer and hook-emulation behavior tightened** — the installer now preserves existing local `AGENTS.md` while installing the repo-managed version as `AGENTS.scholar.md`, and the default emulation summaries were trimmed to reduce noisy temp-file / uncommitted-file output while keeping safer write-guard behavior.
- **2026-03-31**: **Japanese documentation added** — added Japanese docs for the main README plus `AGENTS`, `MCP_SETUP`, and `OBSIDIAN_SETUP`, so the Codex branch now has a more complete multilingual documentation surface.

- **2026-02-25**: **Codex CLI** support — added the `codex` branch for [OpenAI Codex CLI](https://github.com/openai/codex) with TOML config, Codex-native skills and agents, and sandbox security.
- **2026-02-23**: Added `setup.sh` installer — backup-aware incremental updates for existing `~/.codex`, auto-backup for Codex config, and additive merge of managed surfaces
- **2026-02-21**: **OpenCode** support — Claude Scholar now supports [OpenCode](https://github.com/opencode-ai/opencode) as an alternative CLI; switch to the `opencode` branch for OpenCode-compatible configuration
- **2026-02-20**: Bilingual docs — maintained English and Chinese entry documents for broader readability
- **2026-02-15**: Zotero MCP integration — added `/zotero-review` and `/zotero-notes` commands, updated `research-ideation` skill with Zotero integration guide, enhanced `literature-reviewer` agent with Zotero MCP support for automated paper import, collection management, full-text reading, and citation export
- **2026-02-14**: Hooks optimization — restructured `security-guard` to two-tier system (Block + Confirm), `skill-forced-eval` now groups skills into 6 categories with silent scan mode, `session-start` limits display to top 5, `session-summary` adds 30-day log auto-cleanup, `stop-summary` shows separate added/modified/deleted counts; removed deprecated shell scripts (lib/common.sh, lib/platform.sh)
- **2026-02-11**: Major update — added 10 new skills (research-ideation, results-analysis, citation-verification, review-response, paper-self-review, post-acceptance, daily-coding, frontend-design, ui-ux-pro-max, web-design-reviewer), 7 new agents, 8 research workflow commands, 2 new rules (security, experiment-reproducibility); restructured the main configuration docs; 89 files changed
- **2026-01-26**: Rewrote all Hooks to cross-platform Node.js; completely rewrote README; expanded ML paper writing knowledge base; merged PR #1 (cross-platform support)
- **2026-01-25**: Project open-sourced, v1.0.0 released with 25 skills (architecture-design, bug-detective, git-workflow, kaggle-learner, scientific-writing, etc.), 2 agents (paper-miner, kaggle-miner), 30+ commands (including SuperClaude suite), 5 Shell Hooks, and 2 rules (coding-style, agents)

</details>

## Quick Navigation

| Section | What it helps with |
|---|---|
| [Why Claude Scholar](#why-claude-scholar) | Understand the project positioning and target use cases. |
| [Core Workflow](#core-workflow) | See the staged research pipeline from ideation to publication. |
| [Quick Start](#quick-start) | Install Claude Scholar safely into an existing `~/.codex` setup. |
| [Getting Started Scenarios](#getting-started-scenarios) | See a few realistic first-use scenarios after installation. |
| [Platform Scope](#platform-scope) | See what this branch covers and where the other editions live. |
| [Integrations](#integrations) | Learn how Zotero and Obsidian fit into the Codex workflow. |
| [Primary Workflows](#primary-workflows) | Browse the main research and development workflows. |
| [Supporting Workflows](#supporting-workflows) | See the background systems that strengthen the main workflow. |
| [Documentation](#documentation) | Jump to setup docs, configuration, and installation guides. |
| [Citation](#citation) | Cite Claude Scholar in papers, reports, or project docs. |

## Why Claude Scholar

Claude Scholar is **not** an end-to-end autonomous research system that tries to replace the researcher.

Its core idea is simple:

> **human decision-making stays at the center; the assistant accelerates the workflow around it.**

That means the Codex edition is designed to help with the heavy, repetitive, and structure-sensitive parts of research — literature organization, note-taking, experiment analysis, reporting, and writing support — while still keeping the key judgments in human hands:

- which problem is worth pursuing,
- which papers actually matter,
- which hypotheses are worth testing,
- which results are convincing,
- and what should be written, submitted, or abandoned.

In other words, Claude Scholar is a **semi-automated research assistant**, not a fully automated scientist.

## Who This Is For

Claude Scholar is especially well-suited to:

- **computer science researchers** who move between literature review, coding, experiments, and paper writing,
- **AI / ML researchers** who need one assistant workflow spanning ideation, implementation, analysis, reporting, and rebuttal,
- **research engineers and graduate students** who want stronger workflow structure without giving up human judgment,
- and **software-heavy academic projects** that benefit from Zotero, Obsidian, CLI automation, and reproducible project memory.

It can still help in other research settings, but its current workflow design is most aligned with computer science, AI, and adjacent computational research.

## Core Workflow

- **Ideation**: turn a vague topic into concrete questions, research gaps, and an initial plan.
- **Literature**: search, import, organize, and read papers through Zotero collections.
- **Paper notes**: convert papers into structured reading notes and reusable claims.
- **Knowledge base**: route durable knowledge into Obsidian across `Sources/Papers / Knowledge / Experiments / Results / Results/Reports / Writing / Daily / Maps`.
- **Experiments**: track hypotheses, experiment lines, run history, findings, and next actions.
- **Analysis**: generate strict statistics, real scientific figures, and analysis artifacts with `results-analysis`.
- **Reporting**: produce a complete post-experiment report with `results-report`, then write it back into Obsidian.
- **Writing and publication**: carry stable findings into literature reviews, papers, rebuttals, slides, posters, and promotion.

## Quick Start

### Requirements

- [Codex CLI](https://github.com/openai/codex)
- Git
- (Optional) Python + [uv](https://docs.astral.sh/uv/) for Python development
- (Optional) [Zotero](https://www.zotero.org/) + [Galaxy-Dawn/zotero-mcp](https://github.com/Galaxy-Dawn/zotero-mcp) for literature workflows
- (Optional) [Obsidian](https://obsidian.md/) for project knowledge-base workflows

### Option 1: Full Installation (Recommended)

```bash
git clone -b codex https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
bash /tmp/claude-scholar/scripts/setup.sh
```

The installer is **backup-aware and incremental-update friendly**:
- syncs repo-managed `skills/`, `agents/`, `scripts/`, and `utils/`,
- merges Claude Scholar sections into an existing `~/.codex/config.toml` when you keep your current provider/model,
- backs up `config.toml` and `auth.json` before overwriting,
- preserves an existing `~/.codex/AGENTS.md` and installs the repo-managed version as `~/.codex/AGENTS.scholar.md`,
- preserves an existing `~/.codex/AGENTS.zh-CN.md` and installs the repo-managed Chinese version as `~/.codex/AGENTS.zh-CN.scholar.md`,
- preserves your existing provider/model/API key when you choose the incremental-update path,
- optionally enables the Zotero MCP block already present in the template config.

**Important AGENTS note**: if you already maintain your own `~/.codex/AGENTS.md`, review `~/.codex/AGENTS.scholar.md` and `~/.codex/AGENTS.zh-CN.scholar.md` after installation and manually merge the Claude Scholar sections you want into your own files. Do not assume the sidecar file is applied automatically.

To update later:

```bash
cd /tmp/claude-scholar
git pull --ff-only
bash scripts/setup.sh
```

To uninstall later:

```bash
cd /tmp/claude-scholar
bash scripts/uninstall.sh
```

The installer writes:
- `~/.codex/.codex-scholar-manifest.txt` for files managed by Codex Scholar
- `~/.codex/.codex-scholar-install-state` for safe uninstall metadata, including installed `AGENTS*.md` targets and added `config.toml` sections

The uninstaller removes only files and config sections recorded in that install state. It does not guess ownership from the current repo checkout.

**Windows**: please use Git Bash or WSL to run the installer.

### Option 2: Minimal Installation

Install only a small research-focused subset:

```bash
git clone -b codex https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
mkdir -p ~/.codex/skills ~/.codex/agents
cp -r /tmp/claude-scholar/skills/research-ideation ~/.codex/skills/
cp -r /tmp/claude-scholar/skills/results-analysis ~/.codex/skills/
cp -r /tmp/claude-scholar/skills/results-report ~/.codex/skills/
cp -r /tmp/claude-scholar/skills/ml-paper-writing ~/.codex/skills/
cp -r /tmp/claude-scholar/skills/review-response ~/.codex/skills/
cp -r /tmp/claude-scholar/agents/literature-reviewer ~/.codex/agents/
cp -r /tmp/claude-scholar/agents/paper-miner ~/.codex/agents/
cp /tmp/claude-scholar/AGENTS.md ~/.codex/AGENTS.md
cp /tmp/claude-scholar/AGENTS.zh-CN.md ~/.codex/AGENTS.zh-CN.md
```

**Post-install**: minimal/manual install does **not** auto-merge your `config.toml`; copy only the sections you need from the repository config and setup guides. If you already have your own `~/.codex/AGENTS.md`, merge the relevant sections from this repo's `AGENTS.md` into your file instead of blindly overwriting it.

### Option 3: Selective Installation

Copy only the pieces you want:

```bash
git clone -b codex https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
cp -r /tmp/claude-scholar/skills/<skill-name> ~/.codex/skills/
cp -r /tmp/claude-scholar/agents/<agent-name> ~/.codex/agents/
cp /tmp/claude-scholar/AGENTS.md ~/.codex/AGENTS.md
cp /tmp/claude-scholar/AGENTS.zh-CN.md ~/.codex/AGENTS.zh-CN.md
```

**Post-install**: selective/manual install does **not** auto-merge your `config.toml`, and if you already have your own `~/.codex/AGENTS.md`, merge the relevant sections from this repo's `AGENTS.md` into your file instead of blindly overwriting it.

**Important Codex note**:
- Codex does **not** show custom skills in `/...` menus.
- Use natural language prompts, or explicitly invoke a skill as `$skill-name` when needed.

## Getting Started Scenarios

After installation, the simplest way to begin is to describe your task in natural language. You do not need to memorize the whole system first, and Codex does not require slash-menu discovery for these workflows. Below are a few realistic starting points.

### 1. Start a New Research Topic
**You can say:**
> Help me start research on [your topic]. I want a literature-grounded plan, the key open questions, and the next concrete steps.

**What Claude Scholar will typically help with:**
- clarify the topic and narrow the research question,
- identify promising literature directions,
- suggest an initial plan or hypothesis list,
- optionally route the work into Zotero or Obsidian if you use them.

### 2. Review a Zotero Collection
**You can say:**
> Review my Zotero collection on brain foundation models and summarize the main directions, gaps, and promising next steps.

**Typical output:**
- paper grouping by theme,
- a short literature synthesis,
- gap analysis,
- candidate research directions worth pursuing next.

### 3. Analyze Finished Experiment Results
**You can say:**
> Analyze the results in this experiment folder, check what changed across runs, and write a decision-oriented summary.

**Typical output:**
- metric comparison,
- ablation or error-analysis suggestions,
- a result summary that highlights what is solid, what is weak, and what to run next.

### 4. Draft a Paper or Rebuttal Section
**You can say:**
> Help me draft the related work section for this project based on the current findings and paper notes.

or:

> Help me write a rebuttal draft for these reviewer comments.

**Typical output:**
- a structured section draft,
- improved argument flow,
- clearer claims and evidence mapping,
- follow-up points that still need support or verification.

### Practical Notes
- Start with one concrete task, not a vague request for "everything."
- In Codex, natural-language prompts are the default entrypoint; use `$skill-name` only when you want to force a specific skill.
- If you already maintain your own local `AGENTS.md` or `AGENTS.zh-CN.md`, merge the Claude Scholar sections you want from `AGENTS.scholar.md` or `AGENTS.zh-CN.scholar.md` instead of assuming sidecar files apply automatically.
- Zotero and Obsidian are optional, but they become much more useful when you want durable literature notes or project memory rather than one-off chat output.

## Platform Scope

This branch targets **Codex CLI**.

- **Codex CLI (`codex` branch)** — TOML config, AGENTS-based discipline, filesystem-first Obsidian workflow, and Codex-native installation docs
- **Claude Code (`main` branch)** — Claude Code setup, native hooks, and the main cross-platform documentation line
- **OpenCode (`opencode` branch)** — OpenCode-specific configuration and installation path

The research workflow is intentionally similar across branches, but the operational surface differs by platform.

## Integrations

### Zotero

Use Zotero when you want Claude Scholar to help with:
- paper import via DOI / arXiv / URL,
- collection-based reading workflows,
- full-text access through Zotero MCP,
- detailed paper notes and literature synthesis.

See [MCP_SETUP.md](./MCP_SETUP.md).

### Obsidian

Use Obsidian when you want Claude Scholar to maintain a filesystem-first research knowledge base:
- `Sources/Papers/`
- `Knowledge/`
- `Experiments/`
- `Results/`
- `Results/Reports/`
- `Writing/`
- `Daily/`

See [OBSIDIAN_SETUP.md](./OBSIDIAN_SETUP.md).

## Primary Workflows

Complete academic research lifecycle — 7 stages from idea to publication.

> **Codex entrypoint note**: this branch does not rely on repo slash commands. The normal entrypoint is natural language plus explicit skill invocation such as `$results-analysis` when needed.

### 1. Research Ideation (Zotero-Integrated)

Turn a vague topic into a structured research direction with literature support.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `research-ideation` | Turns a vague topic into structured questions, gap analysis, and an initial research plan. |
| Agent | `literature-reviewer` | Searches, classifies, and synthesizes papers into an actionable literature picture. |
| Skill | `zotero-obsidian-bridge` | Bridges Zotero collections into detailed paper notes and downstream Obsidian knowledge work. |

**How it works**
- **5W1H brainstorming**: turn vague interests into structured questions.
- **Literature search and import**: find papers, extract DOI/arXiv/URL, import them into Zotero, and organize them into themed collections.
- **PDF and full text**: attach PDFs when available and read full text when possible.
- **Gap analysis**: identify literature, methodological, application, interdisciplinary, and temporal gaps.
- **Research question and planning**: turn literature synthesis into concrete questions, first hypotheses, and next actions.

**Typical output**
- literature review notes
- structured Zotero collections
- research proposal or direction draft

### 2. ML Project Development

Maintainable ML project development for experiment code and repo hygiene.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `architecture-design` | Designs maintainable ML project structure when adding registrable components or new modules. |
| Skill | `git-workflow` | Enforces safer branching, commit discipline, and collaboration habits. |
| Skill | `bug-detective` | Systematically investigates stack traces, shell errors, and broken code paths. |
| Skill | `git-commit` | Creates Conventional Commit messages locally. |
| Skill | `git-push` | Stages, commits, and pushes using Conventional Commits. |
| Agent | `code-reviewer` | Reviews changed code for correctness, maintainability, and implementation quality. |
| Agent | `tdd-guide` | Provide focused test-driven implementation guidance when a TDD path is explicitly needed. |

**How it works**
- **Structure**: use Factory / Registry patterns where they actually help.
- **Code quality**: keep files readable, typed, and config-driven.
- **Debugging**: treat shell failures, traces, and path issues systematically.
- **Git discipline**: keep a safer branch and commit workflow around fast iteration.

### 3. Experiment Analysis

Strict experiment analysis workflow: statistics, scientific figures, analysis artifacts, and post-experiment reporting.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `results-analysis` | Produces strict statistics, real scientific figures, and analysis appendices. |
| Skill | `results-report` | Converts analysis artifacts into a complete post-experiment report with conclusions, limitations, and next actions. |

**How it works**
- **Data processing**: read experiment logs, metrics files, and result directories.
- **Statistical testing**: run strict tests under the right assumptions and report uncertainty clearly.
- **Visualization**: generate real scientific figures instead of vague plotting advice.
- **Ablation and comparison**: analyze component contribution, trade-offs, and stability.
- **Post-experiment reporting**: hand off to `results-report` for a complete retrospective tied to decisions.

**Typical output**
- `analysis-report.md`
- `stats-appendix.md`
- `figure-catalog.md`
- `figures/`
- an Obsidian write-back under `Results/Reports/`

### 4. Paper Writing

Systematic paper writing from template preparation to iterative drafting.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `ml-paper-writing` | Draft publication-oriented ML/AI papers from repo context, evidence, and literature. |
| Skill | [`nature-writing`](./skills/nature-writing/README.md) | Draft or rebuild Nature-style manuscript sections from claims, figures, results, notes, or Chinese drafts. |
| Skill | [`nature-polishing`](./skills/nature-polishing/README.md) | Polish, restructure, or translate manuscript prose into concise Nature-leaning English. |
| Skill | [`nature-response`](./skills/nature-response/README.md) | Draft, audit, or revise point-by-point reviewer response letters for Nature-family revisions. |
| Skill | [`nature-data`](./skills/nature-data/README.md) | Prepare Nature-ready Data Availability statements, repository plans, and FAIR metadata checks. |
| Skill | `citation-verification` | Check references, metadata, and claim-citation alignment to prevent citation mistakes. |
| Skill | `writing-anti-ai` | Reduce robotic phrasing and improve clarity, rhythm, and human academic tone. |
| Skill | `latex-conference-template-organizer` | Clean messy conference templates into an Overleaf-ready writing structure. |
| Agent | `paper-miner` | Mine strong papers for reusable writing patterns, structure, and venue expectations. |
| Command | `/mine-writing-patterns` | Read a paper and merge reusable writing knowledge into the active installed paper-miner writing memory. |

**How it works**
- **Template Preparation**: clean conference templates into an Overleaf-ready structure.
- **Journal-Style Polishing**: tighten paragraph logic, hedging, and section moves for Nature-leaning prose when needed.
- **Reviewer Response**: structure major/minor revision comments into an auditable point-by-point response package.
- **Data Availability**: prepare Nature-ready repository plans, dataset citations, and availability statements.
- **Citation Verification**: verify references, metadata, and claim-citation alignment.
- **Systematic Writing**: draft sections from repo context, experiment evidence, and literature notes, while keeping unsupported claims marked instead of polished.
- **Claim Ledger**: every contribution, result, and contrast should trace to evidence or remain explicitly speculative.
- **Style Refinement**: reduce robotic phrasing and improve rhythm, clarity, and tone.

### 5. Paper Self-Review

Quality assurance before submission.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `paper-self-review` | Checks structure, logic, citations, figures, and compliance before submission. |

**How it works**
- **Structure check**: inspect logical flow, section balance, and narrative coherence.
- **Logic validation**: inspect claim-evidence alignment and assumption clarity.
- **Citation audit**: verify reference accuracy and completeness.
- **Figure quality**: inspect readability, captions, and accessibility.
- **Compliance**: inspect page limits, formatting, and disclosure requirements.

### 6. Submission and Rebuttal

Submission preparation and reviewer response workflow.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `review-response` | Organizes reviewer comments into an evidence-based rebuttal workflow. |
| Agent | `rebuttal-writer` | Drafts professional, respectful, and well-structured rebuttal text. |

**How it works**
- **Pre-submission checks**: verify venue formatting, anonymization, and required checklist items.
- **Review analysis**: classify reviewer comments into actionable issues.
- **Response strategy**: decide whether to accept, defend, clarify, or run new experiments.
- **Rebuttal writing**: produce structured, evidence-based responses with professional tone.

### 7. Post-Acceptance Processing

Conference preparation and research communication after acceptance.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `post-acceptance` | Supports slides, posters, and outward-facing communication after acceptance. |

**How it works**
- **Presentation**: prepare talk structure and slide guidance.
- **Poster**: structure poster content hierarchy and layout.
- **Promotion**: produce concise outward-facing summaries, threads, and post-acceptance materials.

## Supporting Workflows

These workflows run behind the primary workflows to strengthen the overall Codex experience.

### Obsidian Project Knowledge Base

Use Obsidian as the project-scoped durable knowledge surface, not just as a note dump.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `obsidian-project-kb-core` | Main authority for project-scoped KB bootstrap, routing, registry, index, daily, and lifecycle updates. |
| Skill | `obsidian-source-ingestion` | Ingest external material into `Sources/Papers`, `Sources/Web`, `Sources/Docs`, `Sources/Data`, `Sources/Interviews`, or `Sources/Notes`. |
| Skill | `obsidian-literature-workflow` | Run the paper-note to synthesis workflow from `Sources/Papers` into `Knowledge`, `Writing`, and `Maps/literature.canvas`. |
| Skill | `obsidian-kb-artifacts` | Handle Obsidian-native artifacts such as wikilinks, registry tables, canvas files, optional Bases, and link repair. |
| Skill | `zotero-obsidian-bridge` | Connect Zotero collections to canonical paper notes and literature synthesis inside the project KB. |

**How it works**
- bind an existing repo to an Obsidian vault,
- route stable knowledge into `Sources / Knowledge / Experiments / Results / Results/Reports / Writing / Daily / Maps`,
- keep `Daily/` and repo-local binding metadata updated conservatively,
- ingest new source material into the correct canonical destination,
- only generate extra Bases or canvases on explicit request.

Legacy Codex-era Obsidian skill shims such as `obsidian-project-memory`, `obsidian-project-bootstrap`, and `obsidian-experiment-log` have been removed. Use `obsidian-project-kb-core`, `obsidian-source-ingestion`, `obsidian-literature-workflow`, and `obsidian-kb-artifacts` directly.

**Note language configuration**

Generated and synced Obsidian notes now resolve their language with this priority:
1. project config: `.codex/project-memory/registry.yaml` -> `note_language`
2. environment variable: `OBSIDIAN_NOTE_LANGUAGE`
3. default: `en`

Note: the file is currently named `registry.yaml` for historical reasons, but its on-disk format is JSON.

Per-project example:

```json
{
  "projects": {
    "my-project": {
      "project_id": "my-project",
      "vault_root": "/path/to/vault/Research/my-project",
      "note_language": "zh-CN"
    }
  }
}
```

English and Chinese section headings remain mutually compatible during sync, so older notes in either language can still be updated safely after switching configuration.

### Codex Session Discipline and Hook Emulation

Codex does not expose native Claude Code hooks, so this branch emulates the highest-value behaviors through AGENTS discipline and local helper scripts.

| Type | Name | One-line explanation |
|---|---|---|
| File | `AGENTS.md` | Encodes session discipline, skill evaluation rules, safety rules, and Codex-specific workflow instructions. |
| Script | `scripts/codex_hook_emulation.py` | Emulates session-start, preflight, post-edit, and session-end behaviors inside repo workflows. |
| Skill | `session-wrap-up` | Produces work logs, cleanup reminders, and closeout summaries at the end of a session. |

**How it works**
- **Session start surrogate**: inspect repo state, skills, TODOs, and project context.
- **Preflight surrogate**: check dangerous or irreversible commands before execution.
- **Post-edit surrogate**: decide verification needs and minimum Obsidian write-back after meaningful edits.
- **Session end surrogate**: summarize work and remind follow-up maintenance actions.

### Communication and Reporting Discipline

Use a reusable communication layer when the task needs conclusion-first reporting, concrete evidence, visible risk, or compact next-step guidance.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | [`expression-skill`](./skills/expression-skill/README.md) | Enforces conclusion-first, concrete, checkable communication for technical work, writing, documentation, file operations, and multi-step tasks. |
| Skill | [`planning-with-files`](./skills/planning-with-files/SKILL.md) | Makes complex work persistent on disk with `task_plan.md`, `notes.md`, and deliverable files instead of relying only on transient chat context. |

**How it works**
- lead with the conclusion instead of narration,
- prefer commands, paths, counts, checks, and observable behavior over abstract process language,
- ask clarifying questions only when ambiguity changes the outcome,
- surface risk, uncertainty, and destructive boundaries early,
- keep long-running work visible with step / checkpoint style roadmarks,
- persist multi-step work to disk with `task_plan.md` and `notes.md` instead of relying only on transient context.

### Knowledge Extraction Workflow

Specialized agents continuously mine reusable knowledge from papers and engineering solutions.

| Type | Name | One-line explanation |
|---|---|---|
| Agent | `paper-miner` | Extracts reusable writing patterns, structure signals, and response strategies from strong papers. |
| Agent | `kaggle-miner` | Extracts reusable engineering practices and solution patterns from strong Kaggle workflows. |

**How it works**
- mine writing patterns, venue expectations, and rebuttal strategies from papers,
- mine engineering patterns and solution structures from Kaggle workflows,
- feed that knowledge back into shared skills and references.

### Skill Evolution System

Claude Scholar also includes a self-improvement loop for its own skills.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `skill-development` | Creates new skills with clear triggers, structure, and progressive disclosure. |
| Skill | `skill-quality-reviewer` | Audits skills across content quality, organization, writing, and structural integrity. |
| Skill | `skill-improver` | Applies structured improvement plans to existing skills. |

**How it works**
- create new skills with clear trigger descriptions,
- review them across multiple quality dimensions,
- merge fixes and iterate over time.

## Documentation

- [MCP_SETUP.md](./MCP_SETUP.md) — Zotero MCP setup for Codex
- [OBSIDIAN_SETUP.md](./OBSIDIAN_SETUP.md) — Obsidian project knowledge base workflow
- [AGENTS.md](./AGENTS.md) — lightweight Codex core instructions
- [AGENTS.zh-CN.md](./AGENTS.zh-CN.md) — Chinese companion for the lightweight core instructions
- [README.ja-JP.md](./README.ja-JP.md) — Japanese version of this README
- [config.toml](./config.toml) — template Codex configuration with skills, agents, and MCP blocks

## Project Rules

Claude Scholar for Codex includes rules around:
- coding style,
- agent orchestration,
- security constraints,
- experiment reproducibility,
- and Codex-specific session discipline.

The always-on rules live primarily in `AGENTS.md`; detailed workflows remain in repo-managed skills and docs.

## Contributing

Issues, pull requests, and workflow improvement suggestions are welcome.

If you want to modify the installer, Zotero workflow, Obsidian routing, or Codex session discipline, it helps to describe:
- the user scenario,
- the current limitation,
- the expected behavior,
- and the compatibility impact.

## Citation

If Claude Scholar helps your research or engineering workflow, please cite it as:

```bibtex
@misc{claude_scholar_2026,
  title        = {Claude Scholar: Semi-automated research assistant for academic research and software development},
  author       = {Gaorui Zhang},
  year         = {2026},
  howpublished = {\url{https://github.com/Galaxy-Dawn/claude-scholar}},
  note         = {GitHub repository}
}
```

## License

MIT License.

## Acknowledgments

Built with Codex CLI workflows and extended through open-source research tooling.

### References

This project was inspired by and built on excellent community work:

- **[everything-claude-code](https://github.com/anthropics/everything-claude-code)** - comprehensive Claude Code CLI resources
- **[AI-research-SKILLs](https://github.com/zechenzhangAGI/AI-research-SKILLs)** - research-oriented skills and configuration patterns
- **[codex](https://github.com/openai/codex)** - the Codex CLI foundation used by this branch
- **[expression-skill](https://github.com/Galaxy-Dawn/expression-skill)** - Public conclusion-first communication skill reused here for reporting and response discipline
- **[nature-skills](https://github.com/Yuan1z0825/nature-skills)** - Nature-oriented writing, polishing, reviewer-response, and data-availability skills reused here with attribution

These projects helped shape the research and tooling direction of Claude Scholar.

---

**For academic research, software development, and durable project knowledge management.**

Repository: [https://github.com/Galaxy-Dawn/claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar)
