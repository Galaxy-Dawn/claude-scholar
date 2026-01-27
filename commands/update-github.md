---
description: Commit changes with Conventional Commits format and push to GitHub remote repository.
---

# Update GitHub

Commit uncommitted changes and push to remote GitHub repository.

## Instructions

1. **Check Git Status**
   - Run `git status`
   - Show all uncommitted changes

2. **Analyze Changes**
   - Review changed files
   - Determine commit type (feat/fix/docs/refactor/test/chore)
   - Determine scope (affected module/component)

3. **Create Commit Message**
   Follow Conventional Commits format:
   ```
   <type>(<scope>): <subject>

   <body>

   <footer>
   ```

   Types:
   - `feat`: 新Feature
   - `fix`: Bug Fix
   - `docs`: DocumentationUpdate
   - `refactor`: Code重构
   - `perf`: PerformanceOptimize
   - `test`: Testing相关
   - `chore`: 其他Modify

4. **Stage and Commit**
   - Run `git add` for affected files
   - Create commit with formatted message
   - Include `Co-Authored-By: Claude <noreply@anthropic.com>` in footer

5. **Push to Remote**
   - Run `git push`
   - If rejected, pull with rebase first:
     ```bash
     git pull --rebase origin $(git branch --show-current)
     git push
     ```

6. **Verify Success**
   - Show commit SHA
   - Show remote branch status

## Example Usage

```
User: /update-github

1. Checking git status...
   Modified: src/utils/helpers.py
   Modified: README.md

2. Analyzing changes...
   - src/utils/helpers.py: Refactored helper functions
   - README.md: Updated documentation

3. Proposed commit:
   docs(readme): UpdateProjectDocumentation

   - Add使用Example
   - UpdateDependency说明

   Co-Authored-By: Claude <noreply@anthropic.com>

4. Proceed? (yes/no/modify)

5. Staging files...
   git add src/utils/helpers.py README.md

6. Creating commit...
   [main abc1234] docs(readme): UpdateProjectDocumentation

7. Pushing to remote...
   git push
   To github.com:user/repo.git
      abc1234..def5678  main -> main

✅ Successfully pushed to GitHub!
```

## Arguments

$ARGUMENTS can be:
- `--amend` - Amend last commit instead of creating new one
- `--no-verify` - Skip pre-commit hooks
- `<type>(<scope>): <message>` - Use custom commit message

## Integration

This command uses the same Conventional Commits format as the `/commit` skill but focuses on the complete flow: stage → commit → push.
