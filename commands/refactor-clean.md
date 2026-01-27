# Refactor Clean

Safely identify and remove dead code with test verification:

1. Run dead code analysis tools:
   - vulture: Find unused Python code (functions, classes, variables)
   - pyflakes: Detect unused imports and variables
   - ruff check --select F401: Find unused imports
   - pip-audit: Check for security vulnerabilities

2. Generate comprehensive report in .reports/dead-code-analysis.md

3. Categorize findings by severity:
   - SAFE: Test files, unused utilities, unused imports
   - CAUTION: API routes, models, fixtures
   - DANGER: Config files, main entry points, registry decorators

4. Propose safe deletions only

5. Before each deletion:
   - Run full test suite (pytest)
   - Verify tests pass
   - Apply change
   - Re-run tests
   - Rollback if tests fail

6. Show summary of cleaned items

Never delete code without running tests first!
