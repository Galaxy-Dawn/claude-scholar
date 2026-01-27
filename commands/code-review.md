# Code Review

Comprehensive security and quality review of uncommitted changes:

1. Get changed files: git diff --name-only HEAD

2. For each changed file, check for:

**Security Issues (CRITICAL):**
- Hardcoded credentials, API keys, tokens
- SQL injection vulnerabilities
- XSS vulnerabilities
- Missing input validation
- Insecure dependencies
- Path traversal risks
- Insecure deserialization (pickle)

**Code Quality (HIGH):**
- Functions > 50 lines
- Files > 800 lines
- Nesting depth > 4 levels
- Missing error handling (try/except)
- print() statements in production
- TODO/FIXME comments without tickets
- Missing docstrings for public APIs
- Missing type hints (Python 3.6+)

**Best Practices (MEDIUM):**
- Mutable default arguments
- Emoji usage in code/comments
- Missing tests for new code
- Missing `if __name__ == "__main__"` guards
- Unused imports (detect with ruff/pyflakes)

3. Generate report with:
   - Severity: CRITICAL, HIGH, MEDIUM, LOW
   - File location and line numbers
   - Issue description
   - Suggested fix

4. Block commit if CRITICAL or HIGH issues found

Never approve code with security vulnerabilities!
