# Agent Orchestration

## Available Agents

Located in `~/.claude/agents/`:

### Research Workflow

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| literature-reviewer | Literature search, classification, and trend analysis | Starting a new research topic, literature survey |
| data-analyst | Automated data analysis and visualization | Exploring datasets, generating plots |
| rebuttal-writer | Systematic rebuttal writing with tone optimization | Responding to reviewer comments |
| paper-miner | Extract writing knowledge from successful papers | Learning writing patterns from top-venue papers |
| kaggle-miner | Extract engineering practices from Kaggle solutions | Learning competition strategies and pipelines |

### Development Workflow

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| architect | System architecture and design patterns | Architectural decisions, new module design |
| build-error-resolver | Fix build and type errors with minimal diffs | When build fails or type errors occur |
| code-reviewer | Code quality, security, and maintainability review | After writing or modifying code |
| refactor-cleaner | Dead code cleanup and consolidation | Code maintenance, removing unused code |
| tdd-guide | Test-driven development workflow | New features, bug fixes requiring tests |
| bug-analyzer | Deep code execution flow analysis and root cause investigation | Debugging complex issues across multiple files |
| dev-planner | Implementation planning and task breakdown | Complex features, multi-step refactoring |

### Design & Content

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| ui-sketcher | ASCII interface design and user story generation | UI/UX planning, wireframing |
| story-generator | Content and narrative generation | Creating documentation narratives, examples |

## Automatic Agent Invocation

Use agents proactively without waiting for user request:

1. Code just written/modified → **code-reviewer**
2. Build failure → **build-error-resolver**
3. Complex feature request → **dev-planner** then **architect**
4. Bug report → **bug-analyzer**
5. New feature with tests → **tdd-guide**

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution
Launch 3 agents in parallel:
1. Agent 1: code-reviewer on auth module
2. Agent 2: bug-analyzer on payment flow
3. Agent 3: refactor-cleaner on utils

# BAD: Sequential when unnecessary
First agent 1, then agent 2, then agent 3
```

## Error Handling

- If an agent fails or times out, retry once before reporting to user
- Log agent errors for debugging
- Fall back to manual approach if agent is unavailable

## Multi-Perspective Analysis

For complex problems, use split-role sub-agents:
- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker
