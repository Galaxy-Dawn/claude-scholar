---
description: Commit changes following Conventional Commits format (local only, no push).
---

# Commit

Stage and commit changes using Conventional Commits format.

## Instructions

1. **Check Git Status**
   - Run `git status` to review all changes
   - Run `git diff` to inspect modifications

2. **Analyze Changes**
   - Review changed files and their content
   - Determine commit type and scope
   - Draft a concise commit message

3. **Commit Type Reference**
   ```
   feat     - New feature
   fix      - Bug fix
   docs     - Documentation only
   style    - Code style (formatting, semicolons, etc.)
   refactor - Code refactoring (no feature/fix)
   perf     - Performance improvement
   test     - Adding or updating tests
   chore    - Build, CI, tooling, dependencies
   ```

4. **Commit Message Format**
   ```
   <type>(<scope>): <subject>

   <body>

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
   - Subject: imperative mood, no period, max 72 chars
   - Body: explain what and why (optional for small changes)
   - Scope: affected module (data, model, config, trainer, utils, workflow)

5. **Stage and Commit**
   - Stage relevant files with `git add`
   - Do NOT stage files containing secrets (.env, credentials, tokens)
   - Create commit with formatted message
   - Verify with `git log --oneline -1`

## Notes

- This command only commits locally. Use `/update-github` to also push.
- Always confirm the commit message with the user before committing.
- If unsure about type or scope, ask the user.
