---
name: session-wrap-up
description: Generate session work log, check for AGENTS.md updates, and clean up temporary files. Replaces session-summary and stop-summary hooks.
tags: [Workflow, Session, Productivity]
---

# Session Wrap-Up

Generate a comprehensive session summary and perform cleanup tasks.

## When to Use

Trigger this skill when:
- User says "wrap up", "总结", "session end", or similar
- Before ending a work session
- When switching between major tasks

## Instructions

Kimi Code CLI runs `session-summary` and `stop-summary` hooks automatically at session end. Use their output as the deterministic foundation before writing the final human-readable summary.

### 1. Generate Work Log

Summarize the session:

```
📋 本次操作回顾
1. [List main operations performed]
2. [List files modified/created]

📊 当前状态
• Git: [branch, uncommitted changes count]
• Tests: [pass/fail status if applicable]
• Build: [status if applicable]

💡 下一步建议
1. [Actionable next steps]
```

### 2. Check AGENTS.md Updates

Scan for changes that might require AGENTS.md updates:
- New skills added or modified
- New agents configured
- Configuration changes

If updates are needed, propose specific changes.

### 3. Temporary File Cleanup

Check for temporary files that should be cleaned:
- `/temp/` directory contents
- `/plan/` directory - completed plans
- Orphaned test files
- Debug/log files

Report findings and ask before deleting.

### 4. Git Status Check

Show:
- Current branch
- Uncommitted changes
- Unpushed commits
- Stash entries

## Output Format

Always use the structured format above. Keep summaries concise but complete.
