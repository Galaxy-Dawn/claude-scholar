# Claude Configuration

## Project Overview

**Claude Scholar** - A comprehensive configuration for data science, AI research, and academic writing.

**Mission**: Transform Claude into an effective research assistant, covering the complete workflow from data processing to model training to paper publication.

---

## Global Configuration

### Language Settings
- Responses in English
- Preserve technical terms (e.g., NeurIPS, RLHF, TDD, Git)
- Do not translate proper nouns or names

### Working Directory Standards
- Planning documents: `/plan` folder
- Temporary files: `/temp` folder
- Auto-create folders if they don't exist

### Git Workflow
- Commit convention: Conventional Commits
- Sync to remote repository

### Task Execution Principles
- For complex tasks: discuss first, then break down, then implement
- Test with examples after implementation
- Backup before changes, preserve existing functionality
- Clean up temporary files after completion

---

## Skills Directory Structure

### 📝 Writing & Academic (5 skills)

- **ml-paper-writing**: Academic paper writing assistance for top conferences (NeurIPS, ICML, ICLR, KDD) and high-impact journals (Nature, Science, Cell, PNAS). Includes logic analysis, anti-AI writing, reviewer perspective polishing.
- **writing-anti-ai**: Remove AI writing patterns (English & Chinese bilingual). Based on Wikipedia's "Signs of AI Writing" guide, detects and fixes inflated symbolism, promotional language, superficial analysis, vague attribution, AI vocabulary, negative parallelism.
- **doc-coauthoring**: Structured document collaboration workflow
- **daily-paper-generator**: Daily paper summary generation
- **latex-conference-template-organizer**: LaTeX conference template organization

### 💻 Development (7 skills)

- **git-workflow**: Git workflow standards (Conventional Commits, branching strategy)
- **bug-detective**: Debugging and error troubleshooting (Python, Bash/Zsh, JavaScript/TypeScript)
- **code-review-excellence**: Code review best practices
- **architecture-design**: ML project code framework and design patterns
- **uv-package-manager**: Modern Python package manager usage
- **code-simplifier**: Code simplification and refactoring
- **verification-loop**: Verification and testing

### 🔌 Plugin Development (7 skills)

- **skill-development**: Skill development guide
- **command-development**: Slash command development
- **agent-identifier**: Agent development and configuration
- **hook-development**: Hook development and event handling
- **mcp-integration**: MCP server integration
- **command-name**: Plugin structure and organization
- **skill-improver**: Skill improvement tools
- **skill-quality-reviewer**: Skill quality assessment

### 📊 Planning & Collaboration (2 skills)

- **planning-with-files**: Use Markdown files for planning and progress tracking
- **doc-coauthoring**: Document collaboration workflow

### 🧪 Utilities (3 skills)

- **kaggle-learner**: Learn from Kaggle competition solutions
- **latex-conference-template-organizer**: LaTeX template management
- **webapp-testing**: Local web application testing

---

## Technical Stack Preferences

### Python Ecosystem
- **Package Management**: `uv` - Modern Python package manager
- **Configuration**: Hydra + OmegaConf
  - Support for config composition and override
  - Type-safe configuration access
- **Model Training**: Transformers Trainer

### Git Standards
- **Commit Convention**: Conventional Commits
  ```
  Type: feat, fix, docs, style, refactor, perf, test, chore
  Scope: data, model, config, trainer, utils, workflow
  ```
- **Branching Strategy**: master/develop/feature/bugfix/hotfix/release
- **Merge Strategy**:
  - Feature branches: use rebase to sync
  - Merge with merge --no-ff

---

## Working Style

### Task Management
- Use TodoWrite tool to track task progress
- Plan before executing complex tasks
- Prioritize existing skills and tools

### Communication Style
- Ask for details when uncertain
- Confirm before executing important operations
- Follow hook-forced workflows (when activated)

### Code Style
- Python: Follow PEP 8
- Comments: Use English
- Naming: Functions and variables in English

---

## Naming Conventions

### Skill Naming
- Format: kebab-case (lowercase + hyphens)
- Form: Prefer gerund form (verb+ing)
- Examples: `ml-paper-writing`, `git-workflow`, `bug-detective`

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

**When a task is completed or user is preparing to leave, proactively provide a summary including:**

### 📋 Operation Review
- List main operations performed
- Which files were modified
- Which tools/commands were used

### 📊 Current Status
- Git status (if in repository): branch, number of changed files
- File system status: temporary files, new files
- Runtime status (if applicable): services, processes, etc.

### 💡 Next Steps
- Targeted suggestions based on actual operations
- Consider: whether to commit code, clean temp files, test verification, etc.
- Avoid generic "remember to backup" advice unless truly necessary

---

## Summary Format Example

```
---
📋 Operation Review
1. XXX
2. XXX

📊 Current Status
• XXX

💡 Next Steps
1. XXX
2. XXX
---
```
