# Claude Scholar Configuration

## Project Overview

**Claude Scholar** - A comprehensive Claude Code configuration system for academic research and software development.

**Mission**: Cover the complete academic research lifecycle (from ideation to publication) and software development workflows, while providing plugin development and project management capabilities.

---

## Recommended Tech Stack

**Python Ecosystem**:
- **Package Management**: `uv` - Modern Python package manager
- **Configuration**: Hydra + OmegaConf (config composition, override, type-safe)
- **Model Training**: Transformers Trainer

**Git Standards**:
- **Commit Convention**: Conventional Commits
  ```
  Type: feat, fix, docs, style, refactor, perf, test, chore
  Scope: data, model, config, trainer, utils, workflow
  ```
- **Branching Strategy**: master/develop/feature/bugfix/hotfix/release
- **Merge Strategy**: Use rebase to sync feature branches, merge with --no-ff

---

## Global Configuration

### Language Settings
- Respond in the user's language
- Preserve technical terms (e.g., NeurIPS, RLHF, TDD, Git)
- Do not translate proper nouns or names

### Working Directory Standards
- Planning documents: `/plan` folder
- Temporary files: `/temp` folder
- Auto-create folders if they don't exist

### Task Execution Principles
- For complex tasks: discuss first, then break down, then implement
- Test with examples after implementation
- Backup before changes, preserve existing functionality
- Clean up temporary files after completion

### Working Style
- **Task Management**: Use TodoWrite to track progress, plan before executing complex tasks, prioritize existing skills
- **Communication**: Ask when uncertain, confirm before important operations, follow hook-enforced workflows
- **Code Style**: Python follows PEP 8, comments in English, naming in English

---

## Core Workflows

### Research Lifecycle (7 Stages)

```
Ideation → ML Development → Experiment Analysis → Paper Writing → Self-Review → Submission/Rebuttal → Post-Acceptance
```

| Stage | Core Tools | Commands |
|-------|-----------|----------|
| 1. Research Ideation | `research-ideation` skill + `literature-reviewer` agent | `/research-init` |
| 2. ML Project Development | `architecture-design` skill + `code-reviewer` agent | `/plan`, `/commit`, `/tdd` |
| 3. Experiment Analysis | `results-analysis` skill + `data-analyst` agent | `/analyze-results` |
| 4. Paper Writing | `ml-paper-writing` skill + `paper-miner` agent | - |
| 5. Paper Self-Review | `paper-self-review` skill | - |
| 6. Submission & Rebuttal | `review-response` skill + `rebuttal-writer` agent | `/rebuttal` |
| 7. Post-Acceptance | `post-acceptance` skill | `/presentation`, `/poster`, `/promote` |

### Supporting Workflows

- **Automated Execution**: 5 Hooks trigger automatically at various session stages (skill evaluation, environment init, work summary, security checks)
- **Knowledge Extraction**: `paper-miner` and `kaggle-miner` agents continuously extract knowledge from papers and competitions
- **Skill Evolution**: `skill-development` → `skill-quality-reviewer` → `skill-improver` three-step improvement cycle

---

## Skills Directory (32 skills)

### Research & Analysis (4 skills)

- **research-ideation**: Research ideation kickoff (5W1H, literature review, gap analysis, research question formulation)
- **results-analysis**: Experiment results analysis (statistical tests, visualization, ablation studies)
- **citation-verification**: Citation verification (multi-layer: format → API → metadata → content)
- **daily-paper-generator**: Daily paper generator for research tracking

### Paper Writing & Publication (7 skills)

- **ml-paper-writing**: ML/AI paper writing assistance
  - Conferences: NeurIPS, ICML, ICLR, ACL, AAAI, COLM
  - Journals: Nature, Science, Cell, PNAS
- **writing-anti-ai**: Remove AI writing patterns (English & Chinese bilingual)
- **paper-self-review**: Paper self-review (6-item quality checklist)
- **review-response**: Systematic rebuttal writing
- **post-acceptance**: Post-acceptance processing (presentations, posters, promotion)
- **doc-coauthoring**: Document collaboration workflow
- **latex-conference-template-organizer**: LaTeX conference template organization

### Development Workflow (6 skills)

- **daily-coding**: Daily coding checklist (minimal mode, auto-triggered)
- **git-workflow**: Git workflow standards (Conventional Commits, branching strategies)
- **code-review-excellence**: Code review best practices
- **bug-detective**: Debugging and error troubleshooting (Python, Bash/Zsh, JavaScript/TypeScript)
- **architecture-design**: ML project code framework and design patterns
- **verification-loop**: Verification loops and testing

### Plugin Development (8 skills)

- **skill-development**: Skill development guide
- **skill-improver**: Skill improvement tools
- **skill-quality-reviewer**: Skill quality assessment
- **command-development**: Slash command development
- **command-name**: Plugin structure guide
- **agent-identifier**: Agent development and configuration
- **hook-development**: Hook development and event handling
- **mcp-integration**: MCP server integration

### Tools & Utilities (4 skills)

- **planning-with-files**: Use Markdown files for planning and progress tracking
- **uv-package-manager**: uv package manager usage
- **webapp-testing**: Local web application testing
- **kaggle-learner**: Kaggle competition learning

### Web Design (3 skills)

- **frontend-design**: Create unique, production-grade frontend interfaces, avoiding generic AI aesthetics
- **ui-ux-pro-max**: UI/UX design intelligence (50+ styles, 97 palettes, 57 font pairings, 9 tech stacks)
- **web-design-reviewer**: Website design visual inspection, identify and fix responsive, accessibility, and layout issues

---

## Commands (50+)

### Research Workflow Commands

| Command | Function |
|---------|----------|
| `/research-init` | Start research ideation workflow (5W1H, literature review, gap analysis) |
| `/analyze-results` | Analyze experiment results (statistical tests, visualization, ablation) |
| `/rebuttal` | Generate systematic rebuttal document |
| `/presentation` | Create conference presentation outline |
| `/poster` | Generate academic poster design plan |
| `/promote` | Generate promotional content (Twitter, LinkedIn, blog) |

### Development Workflow Commands

| Command | Function |
|---------|----------|
| `/plan` | Create implementation plan |
| `/commit` | Commit code (following Conventional Commits) |
| `/update-github` | Commit and push to GitHub |
| `/update-readme` | Update README documentation |
| `/code-review` | Code review |
| `/tdd` | Test-driven development workflow |
| `/build-fix` | Fix build errors |
| `/verify` | Verify changes |
| `/checkpoint` | Create checkpoint |
| `/refactor-clean` | Refactor and cleanup |
| `/learn` | Extract reusable patterns from code |
| `/create_project` | Create new project |
| `/setup-pm` | Configure package manager (uv/pnpm) |
| `/update-memory` | Check and update CLAUDE.md memory |

### SuperClaude Command Set (`/sc`)

- `/sc agent` - Agent dispatch
- `/sc analyze` - Code analysis
- `/sc brainstorm` - Interactive brainstorming
- `/sc build` - Build project
- `/sc business-panel` - Business panel
- `/sc cleanup` - Code cleanup
- `/sc design` - System design
- `/sc document` - Generate documentation
- `/sc estimate` - Effort estimation
- `/sc explain` - Code explanation
- `/sc git` - Git operations
- `/sc help` - Help information
- `/sc implement` - Feature implementation
- `/sc improve` - Code improvement
- `/sc index` - Project indexing
- `/sc index-repo` - Repository indexing
- `/sc load` - Load context
- `/sc pm` - Package manager operations
- `/sc recommend` - Recommend solutions
- `/sc reflect` - Reflection and summary
- `/sc research` - Technical research
- `/sc save` - Save context
- `/sc select-tool` - Tool selection
- `/sc spawn` - Spawn subtasks
- `/sc spec-panel` - Spec panel
- `/sc task` - Task management
- `/sc test` - Test execution
- `/sc troubleshoot` - Troubleshooting
- `/sc workflow` - Workflow management

---

## Agents (14)

### Research Workflow Agents

- **literature-reviewer** - Literature search, classification, and trend analysis
- **data-analyst** - Automated data analysis and visualization
- **rebuttal-writer** - Systematic rebuttal writing with tone optimization
- **paper-miner** - Extract writing knowledge from successful papers

### Development Workflow Agents

- **architect** - System architecture design
- **build-error-resolver** - Build error resolution
- **bug-analyzer** - Deep code execution flow analysis and root cause investigation
- **code-reviewer** - Code review
- **dev-planner** - Development task planning and breakdown
- **refactor-cleaner** - Code refactoring and cleanup
- **tdd-guide** - TDD workflow guidance
- **kaggle-miner** - Kaggle engineering practice extraction

### Design & Content Agents

- **ui-sketcher** - UI blueprint design and interaction specs
- **story-generator** - User story and requirement generation

---

## Hooks (5)

Cross-platform Node.js hooks for automated workflow execution:

| Hook | Trigger | Function |
|------|---------|----------|
| `session-start.js` | Session start | Display Git status, todos, available commands |
| `skill-forced-eval.js` | Every user input | Force evaluate all available skills |
| `session-summary.js` | Session end | Generate work log, detect CLAUDE.md updates |
| `stop-summary.js` | Session stop | Quick status check, temp file detection |
| `security-guard.js` | File operations | Security validation (secret detection, dangerous command interception) |

---

## Rules (4)

Global constraints, always active:

| Rule File | Purpose |
|-----------|---------|
| `coding-style.md` | ML project code standards: 200-400 line files, immutable config, type hints, Factory & Registry patterns |
| `agents.md` | Agent orchestration: auto-invocation timing, parallel execution, multi-perspective analysis |
| `security.md` | Security standards: secret management, sensitive file protection, pre-commit security checks |
| `experiment-reproducibility.md` | Experiment reproducibility: random seeds, config recording, environment recording, checkpoint management |

---

## Naming Conventions

### Skill Naming
- Format: kebab-case (lowercase + hyphens)
- Form: Prefer gerund form (verb+ing)
- Examples: `scientific-writing`, `git-workflow`, `bug-detective`

### Tags Naming
- Format: Title Case
- Abbreviations all caps: TDD, RLHF, NeurIPS, ICLR
- Examples: `[Writing, Research, Academic]`

### Description Conventions
- Person: Third person
- Content: Include purpose and use cases
- Example: "Provides guidance for academic paper writing, covering top conference submission requirements"

---

## Task Completion Summary

Proactively provide a brief summary when a task is completed:

```
Operation Review
1. [Main operations]
2. [Modified files]

Current Status
- [Git/filesystem/runtime status]

Next Steps
1. [Targeted suggestions]
```
