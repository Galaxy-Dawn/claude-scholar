---
name: daily-coding
description: |
  Daily coding assistant that auto-triggers when writing/modifying code, providing a core checklist.

  ✅ Trigger scenarios:
  - Implementing new features, adding code, modifying existing code
  - User requests "write a...", "implement...", "add...", "modify..."
  - Any coding task involving Edit/Write tools

  ❌ Does not trigger:
  - Pure reading/understanding code (no modification intent)
  - Already covered by specialized skills (bug-detective, architecture-design, tdd-guide)
  - Configuration file changes, documentation writing
version: 1.0.0
tags: [Coding, Daily, Checklist]
---

# Daily Coding Checklist

A minimal coding quality assurance checklist ensuring every code modification follows best practices.

## Core Checklist

### Before Starting

- [ ] **Read before modify** - Must read target file with Read tool before making changes
- [ ] **Understand context** - Confirm understanding of existing code logic and design intent

### During Coding

- [ ] **Minimal changes** - Only change what's necessary, no over-engineering, no unrelated features
- [ ] **Type safety** - Add type hints for Python, avoid `any` in TypeScript
- [ ] **Security check** - Avoid command injection, XSS, SQL injection vulnerabilities

### After Completion

- [ ] **Verify execution** - Ensure code runs correctly with no syntax errors
- [ ] **Clean up** - Remove print/console.log debug statements and temporary files
- [ ] **Brief summary** - Inform user what was changed and the scope of impact

## Quick Reference

### Common Mistakes to Avoid

```python
# ❌ Don't
def process(data=[]):  # Mutable default argument
    pass

# ✅ Should
def process(data: list | None = None):
    data = data or []
```

```python
# ❌ Don't
except:  # Bare except
    pass

# ✅ Should
except ValueError as e:
    logger.error(f"Processing failed: {e}")
    raise
```

### Security Check Points

- User input must be validated/escaped
- Use pathlib for file paths, avoid path traversal
- Never hardcode sensitive info (API keys, passwords)
