# Claude Scholar

<div align="center">
  <img src="LOGO.jpeg" alt="Claude Scholar Logo" width="100%"/>
</div>

**Language**: [English](README.md) | [中文](README.zh-CN.md)

Personal Claude Code configuration repository, optimized for academic research and software development - a complete working environment.

## News

- **2026-02-15**: Zotero MCP integration — added `/zotero-review` and `/zotero-notes` commands, updated `research-ideation` skill with Zotero integration guide, enhanced `literature-reviewer` agent with Zotero MCP support for automated paper import, collection management, full-text reading, and citation export
- **2026-02-14**: Hooks optimization — restructured `security-guard` to two-tier system (Block + Confirm), `skill-forced-eval` now groups skills into 6 categories with silent scan mode, `session-start` limits display to top 5, `session-summary` adds 30-day log auto-cleanup, `stop-summary` shows separate added/modified/deleted counts; removed deprecated shell scripts (lib/common.sh, lib/platform.sh)
- **2026-02-11**: Major update — added 10 new skills (research-ideation, results-analysis, citation-verification, review-response, paper-self-review, post-acceptance, daily-coding, frontend-design, ui-ux-pro-max, web-design-reviewer), 7 new agents, 8 research workflow commands, 2 new rules (security, experiment-reproducibility); restructured CLAUDE.md; 89 files changed
- **2026-01-26**: Rewrote all Hooks to cross-platform Node.js; completely rewrote README; expanded ML paper writing knowledge base; merged PR #1 (cross-platform support)
- **2026-01-25**: Project open-sourced, v1.0.0 released with 25 skills (architecture-design, bug-detective, git-workflow, kaggle-learner, scientific-writing, etc.), 2 agents (paper-miner, kaggle-miner), 30+ commands (including SuperClaude suite), 5 Shell Hooks, and 2 rules (coding-style, agents)

## Introduction

Claude Scholar is a personal configuration system for Claude Code CLI, providing rich skills, commands, agents, and hooks optimized for:
- **Academic Research** - Complete research lifecycle: idea generation → experimentation → results analysis → paper writing → review response → conference preparation
- **Software Development** - Git workflows, code review, test-driven development, ML project architecture
- **Plugin Development** - Skill, Command, Agent, Hook development guides with quality assessment
- **Project Management** - Planning documents, code standards, automated workflows with cross-platform hooks

## Quick Navigation

| Topic | Description |
|-------|-------------|
| 🚀 [Quick Start](#quick-start) | Get up and running in minutes |
| 📚 [Core Workflows](#core-workflows) | Paper writing, code organization, skill evolution |
| 🛠️ [What's Included](#whats-included) | Skills, commands, agents overview |
| 📖 [Installation Guide](#installation-options) | Full, minimal, or selective setup |
| 🔧 [Project Rules](#project-rules) | Coding style and agent orchestration |

## Core Workflows

### Primary Workflows

Complete academic research lifecycle - 7 stages from idea to publication.

#### 1. Research Ideation (Zotero-Integrated)

End-to-end research startup from idea generation to literature management:

**Tools**: `research-ideation` skill + `literature-reviewer` agent + Zotero MCP

**Process**:
- **5W1H Brainstorming**: What, Why, Who, When, Where, How → structured thinking framework
- **Literature Search & Import**: WebSearch finds papers → extract DOIs → auto-import to Zotero via `add_items_by_doi` → classify into themed sub-collections (Core Papers, Methods, Applications, Baselines, To-Read)
- **PDF & Full-Text**: `find_and_attach_pdfs` batch-attaches open-access PDFs → `get_item_fulltext` reads full paper content for deep analysis (fallback: abstract + domain knowledge)
- **Gap Analysis**: 5 types (Literature, Methodological, Application, Interdisciplinary, Temporal) → identify 2-3 concrete research opportunities
- **Research Question**: SMART principles → formulate specific, measurable questions
- **Method Selection & Planning**: Evaluate method applicability → timeline, milestones, risk assessment

**Zotero Collection Structure**:
```
📁 Research-{Topic}-{YYYY-MM}
  ├── 📁 Core Papers
  ├── 📁 Methods
  ├── 📁 Applications
  ├── 📁 Baselines
  └── 📁 To-Read
```

**Output**: `literature-review.md` + `research-proposal.md` + `references.bib` (exported from Zotero) + organized Zotero collection with PDFs

**Commands**:
- `/research-init "topic"` → full workflow: create Zotero collection → search & import papers → full-text analysis → gap analysis → generate review & proposal
- `/zotero-review "collection"` → analyze an existing Zotero collection → generate literature review with comparison matrix
- `/zotero-notes "collection"` → batch read papers → generate structured reading notes (summary/detailed/comparison formats)

#### 2. ML Project Development

Maintainable ML project structure for experiment code:

**Tools**: `architecture-design` skill + `code-reviewer` agent + `git-workflow` skill

**Process**:
- **Structure**: Factory & Registry patterns → config-driven models (only `cfg` parameter) → enforced by `rules/coding-style.md`
- **Code Style**: 200-400 line files → type hints required → `@dataclass(frozen=True)` for configs → max 3-level nesting
- **Debug** (`bug-detective`): Error pattern matching for Python/Bash/JS → stack trace analysis → anti-pattern identification
- **Git**: Conventional Commits (`feat/scope: message`) → branch strategy (master/develop/feature) → merge with `--no-ff`

**Commands**: `/plan`, `/commit`, `/code-review`, `/tdd`

#### 3. Experiment Analysis

Statistical analysis and visualization of experimental results:

**Tools**: `results-analysis` skill + `data-analyst` agent

**Process**:
- **Data Processing**: Automated cleaning and preprocessing of experiment logs
- **Statistical Testing**: t-test, ANOVA, Wilcoxon signed-rank → validate significance
- **Visualization**: matplotlib/seaborn integration → publication-ready figures (line plots, bar charts, heatmaps)
- **Ablation Studies**: Systematic component analysis → understand contribution of each part

**Command**: `/analyze-results <experiment_dir>` → generates analysis report with figures and statistics

#### 4. Paper Writing

Systematic paper writing from template to final draft:

**Tools**: `ml-paper-writing` skill + `paper-miner` agent + `latex-conference-template-organizer` skill

**Process**:
- **Template Preparation**: Download conference .zip → extract main files → remove sample content → clean Overleaf-ready structure
- **Citation Verification** (`citation-verification`): Multi-layer validation (Format → API → Information → Content) → prevents hallucinations
- **Systematic Writing**: Narrative framing → 5-sentence abstract formula → section-by-section drafting with feedback cycles
- **Anti-AI Processing** (`writing-anti-ai`): Remove inflated symbolism, promotional language, vague attributions → add human voice and rhythm → bilingual support (EN/CN)

**Venues**: NeurIPS, ICML, ICLR, ACL, AAAI, COLM, Nature, Science, Cell, PNAS

#### 5. Paper Self-Review

Quality assurance before submission:

**Tools**: `paper-self-review` skill

**Process**:
- **Structure Check**: Logical flow, section balance, narrative coherence
- **Logic Validation**: Argument soundness, claim-evidence alignment, assumption clarity
- **Citation Audit**: Reference accuracy, proper attribution, citation completeness
- **Figure Quality**: Visual clarity, caption completeness, color accessibility
- **Writing Polish**: Grammar, clarity, conciseness, academic tone
- **Compliance**: Page limits, formatting requirements, ethical disclosures

**6-item checklist** → systematic quality assessment

#### 6. Submission & Rebuttal

Paper submission and review response:

**Tools**: `review-response` skill + `rebuttal-writer` agent

**Submission Process**:
- **Pre-submission**: Conference-specific checklists (NeurIPS 16-item, ICML Broader Impact, ICLR LLM disclosure)
- **Format Check**: Page limits, anonymization, supplementary materials
- **Final Review**: Proofread, check references, verify figures

**Rebuttal Process**:
- **Review Analysis**: Parse and classify comments (Major/Minor/Typo/Misunderstanding)
- **Response Strategy**: Accept/Defend/Clarify/Experiment → tailored approach per comment type
- **Rebuttal Writing**: Structured response with evidence and reasoning
- **Tone Management**: Professional, respectful, evidence-based language

**Command**: `/rebuttal <review_file>` → generates complete rebuttal document with experiment plan

#### 7. Post-Acceptance Processing

Conference preparation and research promotion:

**Tools**: `post-acceptance` skill

**Process**:
- **Presentation**: Slide creation guidance (15/20/30 min formats) → visual design principles → storytelling structure
- **Poster**: Academic poster templates (A0/A1 sizes) → layout optimization → visual hierarchy
- **Promotion**: Social media content (Twitter/X, LinkedIn) → blog posts → press releases → research summaries

**Commands**: `/presentation`, `/poster`, `/promote` → automated content generation

**Coverage**: 90% of academic research lifecycle (from idea to publication)

### Supporting Workflows

These workflows run in the background to enhance the primary workflows.

#### Automated Enforcement Workflow

Cross-platform hooks (Node.js) automate workflow enforcement:

```
Session Start → Skill Evaluation → Session End → Session Stop
```

- **skill-forced-eval** (`skill-forced-eval.js`): Before EVERY user prompt → groups all available skills (local + plugins) into 6 categories → silent scan mode, only outputs matched skills → requires activation before implementation → ensures no relevant skill is missed
- **session-start** (`session-start.js`): Session begins → displays Git status, pending todos, available commands (top 5 with fold count), package manager → shows project context at a glance
- **session-summary** (`session-summary.js`): Session ends → generates comprehensive work log → summarizes all changes made → provides smart recommendations for next steps → auto-cleans logs older than 30 days
- **stop-summary** (`stop-summary.js`): Session stops → quick status check with separate added/modified/deleted counts → groups temp files by folder (top 3 per folder) → shows actionable cleanup suggestions
- **security-guard** (`security-guard.js`): Two-tier security system — **Block tier**: immediately rejects catastrophic commands (rm -rf /, dd, mkfs, system dirs); **Confirm tier**: injects systemMessage forcing model to ask user before executing dangerous-but-legitimate operations (git push --force, git reset --hard, chmod 777, SQL DROP/DELETE/TRUNCATE, sensitive file writes)

**Cross-platform**: All hooks use Node.js (not shell scripts) ensuring Windows/macOS/Linux compatibility.

#### Knowledge Extraction Workflow

Two specialized mining agents continuously extract knowledge to improve skills:

- **paper-miner** (agent): Analyze research papers (PDF/DOCX/arXiv links) → extracts writing patterns, structure insights, venue requirements, rebuttal strategies → updates `ml-paper-writing/references/knowledge/` with categorized entries (structure.md, writing-techniques.md, submission-guides.md, review-response.md)
- **kaggle-miner** (agent): Study winning Kaggle competition solutions → extract competition briefs, front-runner detailed technical analysis, code templates, best practices → update the `kaggle-learner` skill's knowledge base (`references/knowledge/[domain]/` directories, categorized by NLP/CV/Time Series/Tabular/Multimodal)

**Knowledge feedback loop**: Each paper or solution analyzed enriches the knowledge base, creating a self-improving system that evolves with your research.

#### Skill Evolution System

3-step continuous improvement cycle for maintaining and improving skills:

```
skill-development → skill-quality-reviewer → skill-improver
```

1. **Develop** (`skill-development`): Create skills with proper YAML frontmatter → clear descriptions with trigger phrases → progressive disclosure (lean SKILL.md, details in `references/`)
2. **Review** (`skill-quality-reviewer`): 4-dimension quality assessment → Description Quality (25%), Content Organization (30%), Writing Style (20%), Structural Integrity (25%) → generates improvement plan with prioritized fixes
3. **Improve** (`skill-improver`): Merges suggested changes → updates documentation → iterates on feedback → reads improvement plans and applies changes automatically

## File Structure

```
claude-scholar/
├── hooks/               # Cross-platform JavaScript hooks (automated enforcement)
│   ├── hook-common.js           # Shared utilities (git diff, change analysis)
│   ├── session-start.js         # Session begin - Git status, todos, top 5 commands
│   ├── skill-forced-eval.js     # Silent scan, 6-category skill grouping
│   ├── session-summary.js       # Session end - work log, 30-day log auto-cleanup
│   ├── stop-summary.js          # Session stop - added/modified/deleted counts, grouped temp files
│   └── security-guard.js        # Two-tier security: Block (catastrophic) + Confirm (dangerous)
│
├── skills/              # 32 specialized skills (domain knowledge + workflows)
│   ├── ml-paper-writing/        # Full paper writing: NeurIPS, ICML, ICLR, ACL, AAAI, COLM
│   │   └── references/
│   │       └── knowledge/        # Extracted patterns from successful papers
│   │       ├── structure.md           # Paper organization patterns
│   │       ├── writing-techniques.md  # Sentence templates, transitions
│   │       ├── submission-guides.md   # Venue requirements (page limits, etc.)
│   │       └── review-response.md     # Rebuttal strategies
│   │
│   ├── research-ideation/        # Research startup: 5W1H, literature review, gap analysis
│   │   └── references/
│   │       ├── 5w1h-framework.md           # Systematic thinking tool
│   │       ├── gap-analysis-guide.md       # 5 types of research gaps
│   │       ├── literature-search-strategies.md
│   │       ├── research-question-formulation.md
│   │       ├── method-selection-guide.md
│   │       └── research-planning.md
│   │
│   ├── results-analysis/         # Experiment analysis: statistics, visualization, ablation
│   │   └── references/
│   │       ├── statistical-methods.md      # t-test, ANOVA, Wilcoxon
│   │       ├── visualization-best-practices.md  # matplotlib/seaborn
│   │       ├── results-writing-guide.md    # Writing results sections
│   │       └── common-pitfalls.md          # Common analysis mistakes
│   │
│   ├── review-response/          # Systematic rebuttal writing
│   │   └── references/
│   │       ├── review-classification.md    # Major/Minor/Typo/Misunderstanding
│   │       ├── response-strategies.md      # Accept/Defend/Clarify/Experiment
│   │       ├── rebuttal-templates.md       # Structured response templates
│   │       └── tone-guidelines.md          # Professional language
│   │
│   ├── paper-self-review/        # 6-item quality checklist
│   ├── post-acceptance/          # Conference preparation
│   │   └── references/
│   │       ├── presentation-templates/     # Slide creation (15/20/30 min)
│   │       ├── poster-templates/           # Academic poster design
│   │       ├── promotion-examples/         # Social media content
│   │       └── design-guidelines.md        # Visual design principles
│   │
│   ├── citation-verification/    # Multi-layer citation validation
│   ├── writing-anti-ai/         # Remove AI patterns: symbolism, promotional language
│   │   └── references/
│   │       ├── patterns-english.md    # English AI patterns to remove
│   │       └── patterns-chinese.md     # Chinese AI patterns to remove
│   │
│   ├── architecture-design/     # ML project patterns: Factory, Registry, Config-driven
│   ├── git-workflow/            # Git discipline: Conventional Commits, branching
│   ├── bug-detective/           # Debugging: Python, Bash, JS/TS error patterns
│   ├── code-review-excellence/  # Code review: security, performance, maintainability
│   ├── skill-development/       # Skill creation: YAML, progressive disclosure
│   ├── skill-quality-reviewer/  # Skill assessment: 4-dimension scoring
│   ├── skill-improver/          # Skill evolution: merge improvements
│   ├── kaggle-learner/          # Learn from Kaggle winning solutions
│   ├── doc-coauthoring/         # Document collaboration workflow
│   ├── latex-conference-template-organizer  # Template cleanup for Overleaf
│   └── ... (10+ more skills)
│
├── commands/            # 50+ slash commands (quick workflow execution)
│   ├── research-init.md         # Launch research startup workflow
│   ├── zotero-review.md         # Read Zotero papers, generate literature review
│   ├── zotero-notes.md          # Batch read Zotero papers, generate reading notes
│   ├── analyze-results.md       # Analyze experiment results
│   ├── rebuttal.md              # Generate systematic rebuttal document
│   ├── presentation.md          # Create conference presentation outline
│   ├── poster.md                # Generate academic poster design plan
│   ├── promote.md               # Generate promotion content
│   ├── plan.md                  # Implementation planning with agent delegation
│   ├── commit.md                # Conventional Commits: feat/fix/docs/refactor
│   ├── code-review.md           # Quality and security review workflow
│   ├── tdd.md                   # Test-driven development: Red-Green-Refactor
│   ├── build-fix.md             # Fix build errors automatically
│   ├── verify.md                # Run verification loops
│   ├── checkpoint.md            # Save verification state
│   ├── refactor-clean.md        # Remove dead code
│   ├── learn.md                 # Extract patterns from code
│   ├── update-github.md         # Commit and push to GitHub
│   ├── update-readme.md         # Update README documentation
│   ├── update-memory.md         # Check and update CLAUDE.md memory
│   ├── create_project.md        # Create new project from template
│   ├── setup-pm.md              # Configure package manager (uv/pnpm)
│   └── sc/                      # SuperClaude command suite (30 commands)
│       ├── sc-agent.md           # Agent management
│       ├── sc-estimate.md       # Development time estimation
│       ├── sc-improve.md         # Code improvement
│       └── ...
│
├── agents/              # 14 specialized agents (focused task delegation)
│   ├── literature-reviewer.md   # Literature search and trend analysis
│   ├── data-analyst.md          # Automated data analysis and visualization
│   ├── rebuttal-writer.md       # Systematic rebuttal writing
│   ├── paper-miner.md           # Extract paper knowledge: structure, techniques
│   ├── architect.md             # System design: architecture decisions
│   ├── code-reviewer.md         # Review code: quality, security, best practices
│   ├── tdd-guide.md             # Guide TDD: test-first development
│   ├── kaggle-miner.md          # Extract engineering practices from Kaggle
│   ├── build-error-resolver.md  # Fix build errors: analyze and resolve
│   ├── refactor-cleaner.md      # Remove dead code: detect and cleanup
│   ├── bug-analyzer.md          # Deep code execution flow analysis and root cause investigation
│   ├── dev-planner.md           # Implementation planning and task breakdown
│   ├── ui-sketcher.md           # UI blueprint design and interaction specs
│   └── story-generator.md       # User story and requirement generation
│
├── rules/               # Global guidelines (always-follow constraints)
│   ├── coding-style.md          # ML project standards: file size, immutability, types
│   ├── agents.md                # Agent orchestration: when to delegate, parallel execution
│   ├── security.md              # Secrets management, sensitive file protection
│   └── experiment-reproducibility.md  # Random seeds, config recording, checkpoints
│
├── CLAUDE.md            # Global configuration: project overview, preferences, rules
│
└── README.md            # This file - overview, installation, features
```

## Feature Highlights

### Skills (32 total)

**Web Design:**
- `frontend-design` - Create distinctive, production-grade frontend interfaces
- `ui-ux-pro-max` - UI/UX design intelligence (50+ styles, 97 palettes, 9 stacks)
- `web-design-reviewer` - Visual inspection and design issue fixing

**Writing & Academic:**
- `ml-paper-writing` - Full paper writing guidance for top conferences/journals
- `writing-anti-ai` - Remove AI writing patterns (bilingual support)
- `doc-coauthoring` - Structured document collaboration workflow
- `latex-conference-template-organizer` - LaTeX template management
- `daily-paper-generator` - Automated daily paper generation for research tracking

**Research Workflow:**
- `research-ideation` - Research startup: 5W1H brainstorming, literature review, gap analysis
- `results-analysis` - Experiment analysis: statistical testing, visualization, ablation studies
- `review-response` - Systematic rebuttal writing with tone management
- `paper-self-review` - 6-item quality checklist for paper self-assessment
- `post-acceptance` - Conference preparation: presentations, posters, promotion
- `citation-verification` - Multi-layer citation validation to prevent hallucinations

**Development:**
- `daily-coding` - Daily coding checklist (minimal, auto-triggered)
- `git-workflow` - Git best practices (Conventional Commits, branching)
- `code-review-excellence` - Code review guidelines
- `bug-detective` - Debugging for Python, Bash, JS/TS
- `architecture-design` - ML project design patterns
- `verification-loop` - Testing and validation

**Plugin Development:**
- `skill-development` - Skill creation guide
- `skill-improver` - Skill improvement tools
- `skill-quality-reviewer` - Quality assessment
- `command-development` - Slash command creation
- `agent-identifier` - Agent configuration
- `hook-development` - Hook development guide
- `mcp-integration` - MCP server integration

**Utilities:**
- `uv-package-manager` - Modern Python package management
- `planning-with-files` - Markdown-based planning
- `webapp-testing` - Local web application testing
- `kaggle-learner` - Learn from Kaggle solutions

### Commands (50+)

**Research Commands:**
| Command | Purpose |
|---------|---------|
| `/research-init` | Launch research startup workflow (5W1H, literature review, gap analysis) |
| `/zotero-review` | Read papers from Zotero collection, generate structured literature review |
| `/zotero-notes` | Batch read Zotero papers, generate structured reading notes |
| `/analyze-results` | Analyze experiment results (statistics, visualization, ablation) |
| `/rebuttal` | Generate systematic rebuttal document from review comments |
| `/presentation` | Create conference presentation outline |
| `/poster` | Generate academic poster design plan |
| `/promote` | Generate promotion content (Twitter, LinkedIn, blog) |

**Development Commands:**
| Command | Purpose |
|---------|---------|
| `/plan` | Create implementation plans |
| `/commit` | Commit with Conventional Commits |
| `/update-github` | Commit and push to GitHub |
| `/update-readme` | Update README documentation |
| `/update-memory` | Check and update CLAUDE.md memory |
| `/code-review` | Perform code review |
| `/tdd` | Test-driven development workflow |
| `/build-fix` | Fix build errors |
| `/verify` | Verify changes |
| `/checkpoint` | Create checkpoints |
| `/refactor-clean` | Refactor and cleanup |
| `/learn` | Extract reusable patterns |
| `/create_project` | Create new project from template |
| `/setup-pm` | Configure package manager (uv/pnpm) |
| `/sc` | SuperClaude command suite (30 commands) |

### Agents (14 specialized)

**Research Agents:**
- **literature-reviewer** - Literature search, classification, and trend analysis
- **data-analyst** - Automated data analysis and visualization
- **rebuttal-writer** - Systematic rebuttal writing with tone optimization
- **paper-miner** - Extract paper writing knowledge from successful publications

**Development Agents:**
- **architect** - System architecture design
- **build-error-resolver** - Fix build errors
- **code-reviewer** - Review code quality
- **refactor-cleaner** - Remove dead code
- **tdd-guide** - Guide TDD workflow
- **kaggle-miner** - Extract Kaggle engineering practices
- **bug-analyzer** - Deep code execution flow analysis and root cause investigation
- **dev-planner** - Implementation planning and task breakdown

**Design & Content Agents:**
- **ui-sketcher** - UI blueprint design and interaction specs
- **story-generator** - User story and requirement generation

## Quick Start

### Installation Options

Choose the installation method that fits your needs:

#### Option 1: Full Installation (Recommended)

Complete setup for data science, AI research, and academic writing:

```bash
# Clone the repository
git clone https://github.com/Galaxy-Dawn/claude-scholar.git ~/.claude

# Restart Claude Code CLI
```

**Includes**: All 32 skills, 50+ commands, 14 agents, 5 hooks, and project rules.

#### Option 2: Minimal Installation

Core hooks and essential skills only (faster load, less complexity):

```bash
# Clone repository
git clone https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar

# Copy only hooks and core skills
mkdir -p ~/.claude/hooks ~/.claude/skills
cp /tmp/claude-scholar/hooks/*.js ~/.claude/hooks/
cp -r /tmp/claude-scholar/skills/ml-paper-writing ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/research-ideation ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/results-analysis ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/review-response ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/writing-anti-ai ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/git-workflow ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/bug-detective ~/.claude/skills/

# Cleanup
rm -rf /tmp/claude-scholar
```

**Includes**: 5 hooks, 7 core skills (complete research workflow + essential development).

#### Option 3: Selective Installation

Pick and choose specific components:

```bash
# Clone repository
git clone https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
cd /tmp/claude-scholar

# Copy what you need, for example:
# - Hooks only
cp hooks/*.js ~/.claude/hooks/

# - Specific skills
cp -r skills/latex-conference-template-organizer ~/.claude/skills/
cp -r skills/architecture-design ~/.claude/skills/

# - Specific agents
cp agents/paper-miner.md ~/.claude/agents/

# - Project rules
cp rules/coding-style.md ~/.claude/rules/
cp rules/agents.md ~/.claude/rules/
```

**Recommended for**: Advanced users who want custom configurations.

### Requirements

- Claude Code CLI
- Git
- (Optional) Node.js (for hooks)
- (Optional) uv, Python (for Python development)

### First Run

After installation, the hooks provide automated workflow assistance:

1. **Every prompt** triggers `skill-forced-eval` → ensures applicable skills are considered
2. **Session starts** with `session-start` → displays project context
3. **Sessions end** with `session-summary` → generates work log with recommendations
4. **Session stops** with `stop-summary` → provides status check

## Project Rules

### Coding Style

Enforced by `rules/coding-style.md`:
- **File Size**: 200-400 lines maximum
- **Immutability**: Use `@dataclass(frozen=True)` for configs
- **Type Hints**: Required for all functions
- **Patterns**: Factory & Registry for all modules
- **Config-Driven**: Models accept only `cfg` parameter

### Agent Orchestration

Defined in `rules/agents.md`:
- Available agent types and purposes
- Parallel task execution
- Multi-perspective analysis

### Security

Defined in `rules/security.md`:
- Secrets management (environment variables, `.env` files)
- Sensitive file protection (never commit tokens, keys, credentials)
- Pre-commit security checks via hooks

### Experiment Reproducibility

Defined in `rules/experiment-reproducibility.md`:
- Random seed management for reproducibility
- Configuration recording (Hydra auto-save)
- Environment recording and checkpoint management

## Contributing

This is a personal configuration, but you're welcome to:
- Fork and adapt for your own research
- Submit issues for bugs
- Suggest improvements via issues

## License

MIT License

## Acknowledgments

Built with Claude Code CLI and enhanced by the open-source community.

### References

This project is inspired by and builds upon excellent work from the community:

- **[everything-claude-code](https://github.com/anthropics/everything-claude-code)** - Comprehensive resource for Claude Code CLI
- **[AI-research-SKILLs](https://github.com/zechenzhangAGI/AI-research-SKILLs)** - Research-focused skills and configurations

These projects provided valuable insights and foundations for the research-oriented features in Claude Scholar.

---

**For data science, AI research, and academic writing.**

Repository: [https://github.com/Galaxy-Dawn/claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar)
