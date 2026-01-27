# Verification Command

Run comprehensive verification on current codebase state.

## Instructions

Execute verification in this exact order:

1. **Type Check**
   - Run mypy src/
   - Report all errors with file:line

2. **Lint Check**
   - Run ruff check .
   - Report warnings and errors

3. **Test Suite**
   - Run pytest
   - Report pass/fail count
   - Report coverage percentage (pytest --cov)

4. **Security Check**
   - Run pip-audit
   - Check for hardcoded secrets (grep -r "sk-" etc.)

5. **Print Audit**
   - Search for print() in source files
   - Report locations

6. **Git Status**
   - Show uncommitted changes
   - Show files modified since last commit

## Output

Produce a concise verification report:

```
VERIFICATION: [PASS/FAIL]

Types:    [OK/X errors]
Lint:     [OK/X issues]
Tests:    [X/Y passed, Z% coverage]
Security: [OK/X vulnerabilities]
Secrets:  [OK/X found]
Prints:   [OK/X print() statements]

Ready for commit: [YES/NO]
```

If any critical issues, list them with fix suggestions.

## Arguments

$ARGUMENTS can be:
- `quick` - Only types + lint
- `full` - All checks (default)
- `pre-commit` - Checks relevant for commits
- `pre-pr` - Full checks plus security scan
