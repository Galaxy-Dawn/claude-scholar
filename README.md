<div align="center">
  <img src="LOGO.png" alt="Claude Scholar Logo" width="100%"/>

  <p>
    <a href="https://github.com/Galaxy-Dawn/claude-scholar/stargazers"><img src="https://img.shields.io/github/stars/Galaxy-Dawn/claude-scholar?style=flat-square&color=yellow" alt="Stars"/></a>
    <a href="https://github.com/Galaxy-Dawn/claude-scholar/network/members"><img src="https://img.shields.io/github/forks/Galaxy-Dawn/claude-scholar?style=flat-square" alt="Forks"/></a>
    <img src="https://img.shields.io/github/last-commit/Galaxy-Dawn/claude-scholar?style=flat-square" alt="Last Commit"/>
    <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License"/>
  </p>

  <strong>Language</strong>: <a href="README.md">English</a> | <a href="README.zh-CN.md">中文</a> | <a href="README.ja-JP.md">日本語</a>
  <p><strong>Supported Platforms</strong>: <a href="https://github.com/Galaxy-Dawn/claude-scholar/tree/main">Claude Code</a> | <a href="https://github.com/Galaxy-Dawn/claude-scholar/tree/codex">Codex CLI</a> | <a href="https://github.com/Galaxy-Dawn/claude-scholar/tree/kimi">Kimi Code CLI</a> | <a href="https://github.com/Galaxy-Dawn/claude-scholar/tree/opencode">OpenCode</a></p>
</div>

> Semi-automated research assistant for academic research and software development, especially for computer science and AI researchers, adapted for [OpenCode](https://github.com/opencode-ai/opencode) across ideation, literature review, experiments, reporting, writing, and project knowledge management.
>
> **Branch note**: this is the **OpenCode edition** of Claude Scholar. For the Claude Code version, see the [`main` branch](https://github.com/Galaxy-Dawn/claude-scholar/tree/main). For the Codex CLI version, see the [`codex` branch](https://github.com/Galaxy-Dawn/claude-scholar/tree/codex). For the Kimi Code CLI version, see the [`kimi` branch](https://github.com/Galaxy-Dawn/claude-scholar/tree/kimi).


## Recent News

- **2026-06-03**: **Kimi Code CLI branch added to the supported platform line** — documented the `kimi` branch as the Kimi Code CLI edition of Claude Scholar, placing it after Claude Code and Codex CLI and before OpenCode in the shared platform order.
- **2026-05-14**: **`expression-skill` made the communication core, `planning-with-files` restored as the default persistence layer, and the Nature writing stack expanded** — made [`expression-skill`](./skills/expression-skill/README.md) the explicit conclusion-first discipline for reporting, planning, file operations, and multi-step technical work; reintroduced [`planning-with-files`](./skills/planning-with-files/SKILL.md) as the default on-disk planning and progress-tracking workflow for complex tasks; introduced [`nature-writing`](./skills/nature-writing/README.md) for section drafting and argument construction; refreshed [`nature-polishing`](./skills/nature-polishing/README.md) to the latest upstream article-pattern release; and kept [`nature-response`](./skills/nature-response/README.md) plus [`nature-data`](./skills/nature-data/README.md) in the journal-writing stack.
- **2026-05-13**: **Evidence-gated research workflow and `Sources/Papers` routing tightened** — added a shared `research-contract.md` for Evidence Records, claim strength, and Claim Promotion Gates; connected research ideation, Zotero ingestion, literature synthesis, results reporting, writing, and rebuttal workflows to that contract; and clarified that project paper notes live under `Sources/Papers` before promoted claims move into `Knowledge` or `Writing`.
- **2026-04-25**: **OpenCode Obsidian KB lifecycle stabilized** — fixed rename, archive, purge, sync, and lint edge cases in the OpenCode project KB workflow, and made the `/kb-*` commands the primary entrypoints.
- **2026-04-24**: **Vault-first Obsidian KB workflow backported to OpenCode** — brought the new project-scoped Obsidian knowledge workflow to the OpenCode edition, consolidated the older memory skills into four focused skills, and made `/kb-*` commands the only Obsidian command surface.
- **2026-04-22**: **Lightweight core and safe installer lifecycle** — replaced the large always-on `CLAUDE.md` / `AGENTS.md` files with compact core instructions, removed non-core default agents, added Chinese companion files, and added a manifest/state-based uninstall workflow so updates and removals only touch installer-owned files and config entries.
- **2026-04-15**: **pubfig and pubtab introduced** — introduced [`pubfig`](https://github.com/Galaxy-Dawn/pubfig), a Python package for publication-grade scientific figures, and [`pubtab`](https://github.com/Galaxy-Dawn/pubtab), a Python package for publication-ready tables and Excel↔LaTeX workflows. Together they provide a cleaner production stack for paper figures, benchmark tables, export control, and final artifact QA.

<details>
<summary>View older changelog</summary>

- **2026-04-15**: **[`publication-chart-skill`](./skills/publication-chart-skill/SKILL.md) integrated into Claude Scholar** — wrapped [`pubfig`](https://github.com/Galaxy-Dawn/pubfig) + [`pubtab`](https://github.com/Galaxy-Dawn/pubtab) into [`publication-chart-skill`](./skills/publication-chart-skill/SKILL.md), added the skill to the repository, and connected it to Claude Scholar's analysis and writing boundaries so publication-grade figure/table work now has an explicit handoff route instead of being mixed into general analysis or prose skills.
- **2026-03-31**: **Zotero smart-import workflow docs aligned** — updated Claude Scholar's research-facing docs around the latest `zotero-mcp` public surface: `zotero_add_items_by_identifier` is now the default paper-import path, `zotero_reconcile_collection_duplicates` is the standard post-import cleanup step, source-aware PDF cascade behavior is documented more accurately, and public vs internal diagnostics are now clearly separated.
- **2026-03-31**: **README onboarding refreshed** — clarified that Claude Scholar is especially well-suited to computer science and AI researchers, added practical getting-started scenarios after installation, improved prerequisite and branch guidance, and made the “existing local md files must be manually merged” expectation much more explicit.
- **2026-03-31**: **Installer and runtime guard behavior tightened** — the installer now preserves existing local `AGENTS.md` while installing the repo-managed version as `AGENTS.scholar.md`, and the default OpenCode guard summaries were trimmed to reduce noisy temp-file / uncommitted-file output while keeping safer write-guard behavior.
- **2026-03-31**: **Japanese documentation added** — added Japanese docs for the main README plus `AGENTS`, `MCP_SETUP`, and `OBSIDIAN_SETUP`, so the OpenCode branch now has a more complete multilingual documentation surface.

- **2026-02-25**: **Codex CLI** support — added the `codex` branch for [OpenAI Codex CLI](https://github.com/openai/codex) with Codex-native configuration, workflow surfaces, and sandbox security.
- **2026-02-23**: Added `setup.sh` installer — backup-aware incremental updates for existing `~/.opencode`, auto-backup `opencode.jsonc`, additive `agent/mcp/permission/plugin` merge
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
| [Core Workflow](#core-workflow) | See the end-to-end research pipeline from ideation to publication. |
| [Quick Start](#quick-start) | Install Claude Scholar in full, minimal, or selective mode. |
| [Getting Started Scenarios](#getting-started-scenarios) | See a few realistic first-use scenarios after installation. |
| [Integrations](#integrations) | Learn how Zotero and Obsidian fit into the workflow. |
| [Primary Workflows](#primary-workflows) | Browse the main research and development workflows. |
| [Supporting Workflows](#supporting-workflows) | See the background systems that strengthen the main workflow. |
| [Documentation](#documentation) | Jump to setup docs, configuration, and templates. |
| [Citation](#citation) | Cite Claude Scholar in papers, reports, or project docs. |

## Why Claude Scholar

Claude Scholar is **not** an end-to-end autonomous research system that tries to replace the researcher.

Its core idea is simple:

> **human decision-making stays at the center; the assistant accelerates the workflow around it.**

That means Claude Scholar is designed to help with the heavy, repetitive, and structure-sensitive parts of research — literature organization, note-taking, experiment analysis, reporting, and writing support — while still keeping the key judgments in human hands:

- which problem is worth pursuing,
- which papers actually matter,
- which hypotheses are worth testing,
- which results are convincing,
- and what should be written, submitted, or abandoned.

In other words, Claude Scholar is a **semi-automated research assistant**, not a “fully automated scientist.”

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
- **Knowledge base**: route durable knowledge into Obsidian across `Sources / Knowledge / Experiments / Results / Results/Reports / Writing / Daily / Maps`.
- **Experiments**: track hypotheses, experiment lines, run history, findings, and next actions.
- **Analysis**: generate strict statistics, real scientific figures, and analysis artifacts with `results-analysis`.
- **Reporting**: produce a complete post-experiment report with `results-report`, then write it back into Obsidian.
- **Writing and publication**: carry stable findings into literature reviews, papers, rebuttals, slides, posters, and promotion.

## Quick Start

### Requirements

- [OpenCode](https://github.com/sst/opencode)
- Git
- (Optional) Python + [uv](https://docs.astral.sh/uv/) for Python development
- (Optional) [Zotero](https://www.zotero.org/) + [Galaxy-Dawn/zotero-mcp](https://github.com/Galaxy-Dawn/zotero-mcp) for literature workflows
- (Optional) [Obsidian](https://obsidian.md/) for project knowledge-base workflows

### Option 1: Full Installation (Recommended)

```bash
git clone -b opencode https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
bash /tmp/claude-scholar/scripts/setup.sh
```

The installer is **backup-aware and incremental-update friendly**:
- updates repo-managed `skills/commands/plugins/scripts/utils/`,
- backs up overwritten files to `~/.opencode/.opencode-scholar-backups/<timestamp>/`,
- backs up `opencode.jsonc` to `opencode.jsonc.bak`,
- preserves an existing `~/.opencode/AGENTS.md` and installs the repo-managed version as `~/.opencode/AGENTS.scholar.md`,
- preserves an existing `~/.opencode/AGENTS.zh-CN.md` and installs the repo-managed Chinese version as `~/.opencode/AGENTS.zh-CN.scholar.md`,
- preserves your existing `env`, model/provider settings, API keys, permissions, auth, and current `mcp` values,
- adds missing repo-managed `agent/mcp/permission/plugin` entries instead of replacing your entire config.

**Important AGENTS note**: if you already maintain your own `~/.opencode/AGENTS.md`, review `~/.opencode/AGENTS.scholar.md` and `~/.opencode/AGENTS.zh-CN.scholar.md` after installation and manually merge the Claude Scholar sections you want into your own files. Do not assume the sidecar file is applied automatically.

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
- `~/.opencode/.opencode-scholar-manifest.txt` for files managed by Claude Scholar
- `~/.opencode/.opencode-scholar-install-state` for safe uninstall metadata, including installed `AGENTS*.md` targets and added `opencode.jsonc` entries

The uninstaller removes only files and config entries recorded in that install state. It does not guess ownership from the current repo checkout.

**Windows**: please use Git Bash or WSL to run the installer.

### Option 2: Minimal Installation

Install only a small research-focused subset:

```bash
git clone -b opencode https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
mkdir -p ~/.opencode/plugins/lib ~/.opencode/skills
cp /tmp/claude-scholar/plugins/*.ts ~/.opencode/plugins/
cp /tmp/claude-scholar/plugins/lib/common.ts ~/.opencode/plugins/lib/
cp -r /tmp/claude-scholar/skills/ml-paper-writing ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/research-ideation ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/results-analysis ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/results-report ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/review-response ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/writing-anti-ai ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/git-workflow ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/bug-detective ~/.opencode/skills/
```

**Post-install**: minimal/manual install does **not** auto-merge `opencode.jsonc`; copy only the plugin or MCP entries you want from `opencode.jsonc`. If you already have your own `~/.opencode/AGENTS.md`, merge the relevant sections from this repo's `AGENTS.md` into your file instead of blindly overwriting it.

### Option 3: Selective Installation

Copy only the parts you need:

```bash
git clone -b opencode https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
cd /tmp/claude-scholar

cp plugins/*.ts ~/.opencode/plugins/
cp -r skills/latex-conference-template-organizer ~/.opencode/skills/
cp -r skills/architecture-design ~/.opencode/skills/
cp AGENTS.md ~/.opencode/AGENTS.md
cp AGENTS.zh-CN.md ~/.opencode/AGENTS.zh-CN.md
```

**Post-install**: selective/manual install does **not** auto-merge `opencode.jsonc`; copy only the plugin or MCP entries you actually want from `opencode.jsonc`. If you already have your own `~/.opencode/AGENTS.md`, merge the relevant sections from this repo's `AGENTS.md` into your file instead of blindly overwriting it.

## Getting Started Scenarios

After installation, the simplest way to begin is to describe your task in natural language. You do not need to memorize the whole system first. Below are a few realistic starting points.

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
- If you already maintain your own local `AGENTS.md` or `AGENTS.zh-CN.md`, merge the Claude Scholar sections you want from `AGENTS.scholar.md` or `AGENTS.zh-CN.scholar.md` instead of assuming sidecar files apply automatically.
- Zotero and Obsidian are optional, but they become much more useful when you want durable literature notes or project memory rather than one-off chat output.

## Platform Support

Claude Scholar is maintained for:

- **OpenCode** — the primary installation target for this branch.
- **Claude Code** — use the `main` branch.
- **Codex CLI** — use the `codex` branch.

The top-level workflow is the same: research, coding, experiments, reporting, and project knowledge management.

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
- `Sources/`
- `Knowledge/`
- `Experiments/`
- `Results/`
- `Results/Reports/`
- `Writing/`
- `Daily/`
- `Maps/`

See [OBSIDIAN_SETUP.md](./OBSIDIAN_SETUP.md).

## Primary Workflows

Complete academic research lifecycle — 7 stages from idea to publication.

### 1. Research Ideation (Zotero-Integrated)

End-to-end research startup from idea generation to literature management.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `research-ideation` | Turn vague topics into structured questions, gap analysis, and an initial research plan. |
| Agent | `literature-reviewer` | Search, classify, and synthesize papers into an actionable literature picture. |
| Command | `/research-init` | Start a new topic from literature search to Zotero organization and proposal drafting. |
| Command | `/zotero-review` | Review an existing Zotero collection and generate a structured literature synthesis. |
| Command | `/zotero-notes` | Batch-read a Zotero collection and create structured paper reading notes. |

**How it works**
- **5W1H Brainstorming**: turn a vague topic into structured questions (`What / Why / Who / When / Where / How`).
- **Literature Search & Import**: search papers, extract DOI/arXiv/URLs, import them into Zotero, and organize them into themed collections.
- **PDF & Full Text**: attach PDFs when available, read full text when possible, and fall back to abstract-level analysis when necessary.
- **Gap Analysis**: identify literature, methodological, application, interdisciplinary, or temporal gaps.
- **Research Question & Planning**: convert the review into concrete questions, initial hypotheses, and next-step planning.

**Typical output**
- literature review notes
- structured Zotero collection
- project proposal / research direction draft

### 2. ML Project Development

Maintainable ML project structure for experiment code and iteration.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `architecture-design` | Define maintainable ML project structure when new registrable components or modules are introduced. |
| Skill | `git-workflow` | Enforce branch hygiene, commit conventions, and safer collaboration workflows. |
| Skill | `bug-detective` | Debug stack traces, shell failures, and code-path issues systematically. |
| Agent | `code-reviewer` | Review modified code for correctness, maintainability, and implementation quality. |
| Agent | `tdd-guide` | Provide focused test-driven implementation guidance when a TDD path is explicitly needed. |
| Command | `/plan` | Create or refine an implementation plan before coding. |
| Command | `/commit` | Prepare a conventional commit for the current changes. |
| Command | `/code-review` | Run a focused review on the current code changes. |
| Command | `/tdd` | Drive feature work through small, test-backed implementation steps. |

**How it works**
- **Structure**: use Factory / Registry patterns for new ML components when appropriate.
- **Code Quality**: keep files maintainable, typed, and config-driven.
- **Debugging**: inspect stack traces, shell failures, and code-path issues systematically.
- **Git Discipline**: use branch hygiene, conventional commits, and safer merge/rebase workflows.

### 3. Experiment Analysis

Strict analysis of experimental results with scientific figures and report-ready artifacts.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `results-analysis` | Produce a strict analysis bundle with rigorous statistics, real scientific figures, and analysis artifacts. |
| Skill | `results-report` | Turn analysis artifacts into a complete post-experiment report with decisions, limitations, and next actions. |
| Command | `/analyze-results` | Run the full experiment workflow in one shot: strict analysis first, then final report generation. |

**How it works**
- **Data Processing**: read experiment logs, metrics files, and result directories.
- **Statistical Testing**: run strict statistical checks such as t-test / ANOVA / Wilcoxon where appropriate.
- **Visualization**: generate real scientific figures with interpretation guidance, not just vague plotting suggestions.
- **Ablation & Comparison**: analyze component contribution, performance tradeoffs, and stability.
- **Post-Experiment Reporting**: turn the analysis bundle into a full retrospective report with conclusions, limitations, and next actions.

**Typical output**
- `analysis-report.md`
- `stats-appendix.md`
- `figure-catalog.md`
- `figures/`
- post-experiment summary report in Obsidian `Results/Reports/`

### 4. Paper Writing

Systematic academic writing from structure setup to draft refinement.

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
- **Systematic Writing**: draft sections from repo context, experiment evidence, and literature notes.
- **Style Refinement**: reduce robotic phrasing and improve rhythm, clarity, and tone.

### 5. Paper Self-Review

Quality assurance before submission.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `paper-self-review` | Audit structure, logic, citations, figures, and compliance before submission. |

**How it works**
- **Structure Check**: logical flow, section balance, and narrative coherence.
- **Logic Validation**: claim-evidence alignment, assumption clarity, and argument consistency.
- **Citation Audit**: reference correctness and completeness.
- **Figure Quality**: caption completeness, readability, and accessibility.
- **Compliance**: page limits, formatting, and disclosure requirements.

### 6. Submission & Rebuttal

Submission preparation and review response workflow.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `review-response` | Structure reviewer comments into an evidence-based rebuttal workflow. |
| Agent | `rebuttal-writer` | Draft professional, respectful, and strategically organized rebuttal text. |
| Command | `/rebuttal` | Generate a complete rebuttal draft from review comments and evidence. |

**How it works**
- **Pre-submission Checks**: venue-specific formatting, anonymization, and checklist requirements.
- **Review Analysis**: classify reviewer comments into actionable categories.
- **Response Strategy**: decide whether to accept, defend, clarify, or propose new experiments.
- **Rebuttal Writing**: generate structured, evidence-based responses with professional tone.

### 7. Post-Acceptance Processing

Conference preparation and research promotion after acceptance.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `post-acceptance` | Support talks, posters, and research promotion after acceptance. |
| Command | `/presentation` | Generate presentation structure and speaking guidance for the accepted work. |
| Command | `/poster` | Organize the work into poster-ready content and layout guidance. |
| Command | `/promote` | Draft public-facing promotion content such as summaries, posts, or threads. |

**How it works**
- **Presentation**: prepare talk structure and slide guidance.
- **Poster**: organize content into poster-ready layout and hierarchy.
- **Promotion**: generate social media, blog, or summary material for broader communication.

## Supporting Workflows

These workflows run in the background to strengthen the primary workflows.

### Obsidian Project Knowledge Base

Use Obsidian as the project-scoped durable knowledge surface, not just as a note dump.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `obsidian-project-kb-core` | Main authority for project-scoped KB bootstrap, routing, registry, index, daily, and lifecycle updates. |
| Skill | `obsidian-source-ingestion` | Ingest external material into `Sources/Papers`, `Sources/Web`, `Sources/Docs`, `Sources/Data`, `Sources/Interviews`, or `Sources/Notes`. |
| Skill | `obsidian-literature-workflow` | Run the paper-note to synthesis workflow from `Sources/Papers` into `Knowledge`, `Writing`, and `Maps/literature.canvas`. |
| Skill | `obsidian-kb-artifacts` | Handle Obsidian-native artifacts such as wikilinks, registry tables, canvas files, optional Bases, and link repair. |
| Command | `/kb-init` | Initialize the vault-first KB under `Research/{project-slug}/`. |
| Command | `/kb-status` | Summarize the current KB state from the bound project root. |
| Command | `/kb-ingest` | Route new source material into the correct canonical KB destination. |
| Command | `/kb-log` | Update the current Daily note and related project surfaces conservatively. |
| Command | `/kb-sync` | Run deterministic KB maintenance to refresh registry, index, daily, and runtime binding state. |
| Command | `/kb-links` | Repair or strengthen wikilinks among canonical KB notes. |
| Command | `/kb-promote` | Promote durable content from Daily or source notes into canonical notes. |
| Command | `/kb-index` | Regenerate `02-Index.md` as the human-readable project navigator. |
| Command | `/kb-lint` | Run deterministic KB health checks and update `_system/lint-report.md`. |
| Command | `/kb-archive` | Archive, detach, purge, or rename KB objects while keeping links and registry consistent. |
| Command | `/kb-map` | Generate or repair explicit-only KB artifacts beyond the default literature canvas. |
| Command | `/kb-literature-review` | Generate literature synthesis from `Sources/Papers` into `Knowledge`, `Writing`, and `Maps/literature.canvas`. |

Old Obsidian command aliases have been removed. Use the `/kb-*` command surface for all Obsidian KB work.

**How it works**
- bind an existing repo to an Obsidian vault,
- route stable knowledge into `Sources / Knowledge / Experiments / Results / Results/Reports / Writing / Daily / Maps`,
- keep `Daily/` and repo-local binding metadata updated conservatively,
- ingest new source material into the correct canonical destination,
- only generate extra Bases or canvases on explicit request.
- use `/kb-sync` for deterministic resyncs and `/kb-links` for standalone link repair.

**Note language configuration**

Generated and synced Obsidian notes resolve their language with this priority:
1. project config: `.opencode/project-memory/registry.yaml` -> `note_language`
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

### Automated Enforcement Workflow

OpenCode plugins provide routine workflow checks and reminders through runtime guards.

**Plugins**
- `skill-eval.ts`
- `session-start.ts`
- `session-summary.ts`
- `stop-summary.ts`
- `security-guard.ts`

**How it works**
- **Before prompts**: evaluate applicable skills and surface relevant workflow hints.
- **At session start**: show Git state, available commands, and project-memory context.
- **At session end/stop**: summarize work and remind the user about minimum maintenance tasks.
- **Security**: block catastrophic commands and require confirmation for dangerous but legitimate ones.

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

Specialized agents can mine reusable knowledge from papers and competitions.

| Type | Name | One-line explanation |
|---|---|---|
| Agent | `paper-miner` | Extract reusable writing knowledge, structure patterns, and venue heuristics from strong papers. |
| Agent | `kaggle-miner` | Extract engineering practices and solution patterns from strong Kaggle workflows. |

**How it works**
- extract writing patterns, venue expectations, and rebuttal strategies from papers,
- extract engineering patterns and solution structure from Kaggle workflows,
- feed those insights back into skills and reference material.

### Skill Evolution System

Claude Scholar also contains a self-improvement loop for its own skills.

| Type | Name | One-line explanation |
|---|---|---|
| Skill | `skill-development` | Create new skills with clear triggers, structure, and progressive disclosure. |
| Skill | `skill-quality-reviewer` | Review skills across content quality, organization, style, and structural integrity. |
| Skill | `skill-improver` | Apply structured improvement plans to evolve existing skills. |

**How it works**
- create new skills with clear trigger descriptions,
- review them across quality dimensions,
- apply structured improvements and iterate.

## Documentation

- [MCP_SETUP.md](./MCP_SETUP.md) — Zotero/browser MCP setup
- [OBSIDIAN_SETUP.md](./OBSIDIAN_SETUP.md) — Obsidian knowledge base workflow
- [AGENTS.md](./AGENTS.md) — lightweight OpenCode core instructions
- [AGENTS.zh-CN.md](./AGENTS.zh-CN.md) — Chinese companion for the lightweight core instructions
- [README.zh-CN.md](./README.zh-CN.md) — Chinese version of this README
- [README.ja-JP.md](./README.ja-JP.md) — Japanese version of this README
- [opencode.jsonc](./opencode.jsonc) — optional OpenCode config template for plugin/MCP/agent/permission entries
## Project Rules

Claude Scholar includes project rules for:
- coding style,
- agent orchestration,
- security,
- experiment reproducibility.

The always-on rules live primarily in `AGENTS.md`; detailed workflows remain in repo-managed skills and docs.

## Contributing

Issues, PRs, and workflow improvements are welcome.

If you propose changes to installer behavior, Zotero workflows, or Obsidian routing, please include:
- the user scenario,
- the current limitation,
- the expected behavior,
- and any compatibility concerns.

## License

MIT License.

## Citation

If Claude Scholar helps your research or engineering workflow, you can cite the repository as:

```bibtex
@misc{claude_scholar_2026,
  title        = {Claude Scholar: Semi-automated research assistant for academic research and software development},
  author       = {Gaorui Zhang},
  year         = {2026},
  howpublished = {\url{https://github.com/Galaxy-Dawn/claude-scholar}},
  note         = {GitHub repository}
}
```

## Acknowledgments

Built for OpenCode and aligned with the broader Claude Scholar ecosystem.

### References

This project is inspired by and builds upon excellent work from the community:

- **[everything-claude-code](https://github.com/anthropics/everything-claude-code)** - Comprehensive resource for Claude Code CLI
- **[AI-research-SKILLs](https://github.com/zechenzhangAGI/AI-research-SKILLs)** - Research-focused skills and configurations
- **[expression-skill](https://github.com/Galaxy-Dawn/expression-skill)** - Public conclusion-first communication skill reused here for reporting and response discipline
- **[nature-skills](https://github.com/Yuan1z0825/nature-skills)** - Nature-oriented writing, polishing, reviewer-response, and data-availability skills reused here with attribution

These projects provided valuable insights and foundations for the research-oriented features in Claude Scholar.

---

**For data science, AI research, and academic writing.**

Repository: [https://github.com/Galaxy-Dawn/claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar)
