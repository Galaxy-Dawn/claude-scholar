---
name: git-workflow
description: This skill should be used when the user asks to "create git commit", "manage branches", "follow git workflow", "use Conventional Commits", "handle merge conflicts", or asks about git branching strategies, version control best practices, pull request workflows. Provides comprehensive Git workflow guidance for team collaboration.
version: 1.2.0
---

# Git Workflow Standards

This document defines the project's Git usage standards, including commit message format, branch management strategy, workflows, merge strategies, and more. Following these standards improves collaboration efficiency, enables traceability, supports automation, and reduces conflicts.

## Commit Message Standards

The project follows the **Conventional Commits** specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type Reference

| Type | Description | Example |
| :--- | :--- | :--- |
| `feat` | New feature | `feat(user): add user export functionality` |
| `fix` | Bug fix | `fix(login): fix captcha not refreshing` |
| `docs` | Documentation update | `docs(api): update API documentation` |
| `refactor` | Refactoring | `refactor(utils): refactor utility functions` |
| `perf` | Performance improvement | `perf(list): optimize list performance` |
| `test` | Test related | `test(user): add unit tests` |
| `chore` | Other changes | `chore: update dependency versions` |

### Subject Rules

- Start with a verb: add, fix, update, remove, optimize
- No more than 50 characters
- No period at the end

For more detailed conventions and examples, see `references/commit-conventions.md`.

## Branch Management Strategy

### Branch Types

| Branch Type | Naming Convention | Description | Lifecycle |
| :--- | :--- | :--- | :--- |
| master | `master` | Main branch, releasable state | Permanent |
| develop | `develop` | Development branch, latest integrated code | Permanent |
| feature | `feature/feature-name` | Feature branch | Delete after completion |
| bugfix | `bugfix/issue-description` | Bug fix branch | Delete after fix |
| hotfix | `hotfix/issue-description` | Emergency fix branch | Delete after fix |
| release | `release/version-number` | Release branch | Delete after release |

### Branch Naming Examples

```
feature/user-management          # User management feature
feature/123-add-export          # Issue-linked feature
bugfix/login-error              # Login error fix
hotfix/security-vulnerability   # Security vulnerability fix
release/v1.0.0                  # Version release
```

### Branch Protection Rules

**master branch:**
- No direct pushes allowed
- Must merge via Pull Request
- Must pass CI checks
- Requires at least one Code Review approval

**develop branch:**
- Direct pushes restricted
- Pull Request merges recommended
- Must pass CI checks

For detailed branch strategies and workflows, see `references/branching-strategies.md`.

## Workflows

### Daily Development Workflow

```bash
# 1. Sync latest code
git checkout develop
git pull origin develop

# 2. Create feature branch
git checkout -b feature/user-management

# 3. Develop and commit
git add .
git commit -m "feat(user): add user list page"

# 4. Push to remote
git push -u origin feature/user-management

# 5. Create Pull Request and request Code Review

# 6. Merge to develop (via PR)

# 7. Delete feature branch
git branch -d feature/user-management
git push origin -d feature/user-management
```

### Hotfix Workflow

```bash
# 1. Create fix branch from master
git checkout master
git pull origin master
git checkout -b hotfix/critical-bug

# 2. Fix and commit
git add .
git commit -m "fix(auth): fix authentication bypass vulnerability"

# 3. Merge to master
git checkout master
git merge --no-ff hotfix/critical-bug
git tag -a v1.0.1 -m "hotfix: fix authentication bypass vulnerability"
git push origin master --tags

# 4. Sync to develop
git checkout develop
git merge --no-ff hotfix/critical-bug
git push origin develop
```

### Release Workflow

```bash
# 1. Create release branch
git checkout develop
git checkout -b release/v1.0.0

# 2. Update version numbers and documentation

# 3. Commit version update
git add .
git commit -m "chore(release): prepare release v1.0.0"

# 4. Merge to master
git checkout master
git merge --no-ff release/v1.0.0
git tag -a v1.0.0 -m "release: v1.0.0 official release"
git push origin master --tags

# 5. Sync to develop
git checkout develop
git merge --no-ff release/v1.0.0
git push origin develop
```

## Merge Strategy

### Merge vs Rebase

| Feature | Merge | Rebase |
| :--- | :--- | :--- |
| History | Preserves complete history | Linear history |
| Use case | Public branches | Private branches |
| Recommended for | Merging to main branch | Syncing upstream code |

### Recommendations

- **Feature branch syncing develop**: Use `rebase`
- **Feature branch merging to develop**: Use `merge --no-ff`
- **develop merging to master**: Use `merge --no-ff`

```bash
# ✅ Recommended: Feature branch syncing develop
git checkout feature/user-management
git rebase develop

# ✅ Recommended: Merge feature branch to develop
git checkout develop
git merge --no-ff feature/user-management

# ❌ Not recommended: Rebase on public branch
git checkout develop
git rebase feature/xxx  # Dangerous operation
```

**Project convention**: Use `--no-ff` when merging feature branches to preserve branch history.

For detailed merge strategies and techniques, see `references/merge-strategies.md`.

## Conflict Resolution

### Identifying Conflicts

```
<<<<<<< HEAD
// Current branch code
const name = 'Alice'
=======
// Branch being merged
const name = 'Bob'
>>>>>>> feature/user-management
```

### Resolving Conflicts

```bash
# 1. View conflicting files
git status

# 2. Manually edit files to resolve conflicts

# 3. Mark as resolved
git add <file>

# 4. Complete the merge
git commit  # merge conflict
# or
git rebase --continue  # rebase conflict
```

### Conflict Resolution Strategies

```bash
# Keep current branch version
git checkout --ours <file>

# Keep incoming branch version
git checkout --theirs <file>

# Abort merge
git merge --abort
git rebase --abort
```

### Preventing Conflicts

1. **Sync code regularly** - Pull latest code before starting work each day
2. **Small commits** - Commit small changes frequently
3. **Modular features** - Implement different features in different files
4. **Communication** - Avoid modifying the same file simultaneously

For detailed conflict handling and advanced techniques, see `references/conflict-resolution.md`.

## .gitignore Standards

### Basic Rules

```
# Ignore all .log files
*.log

# Ignore directories
node_modules/

# Ignore directory at root
/temp/

# Ignore files in all directories
**/.env

# Don't ignore specific files
!.gitkeep
```

### Common .gitignore

```
node_modules/
dist/
build/
.idea/
.vscode/
.env
.env.local
logs/
*.log
.DS_Store
Thumbs.db
```

For detailed .gitignore patterns and project-specific configurations, see `references/gitignore-guide.md`.

## Tag Management

Uses **Semantic Versioning**:

```
MAJOR.MINOR.PATCH[-PRERELEASE]
```

### Version Change Rules

- **MAJOR**: Incompatible API changes (v1.0.0 → v2.0.0)
- **MINOR**: Backward-compatible new features (v1.0.0 → v1.1.0)
- **PATCH**: Backward-compatible bug fixes (v1.0.0 → v1.0.1)

### Tag Operations

```bash
# Create annotated tag (recommended)
git tag -a v1.0.0 -m "release: v1.0.0 official release"

# Push tags
git push origin v1.0.0
git push origin --tags

# View tags
git tag
git show v1.0.0

# Delete tag
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

## Team Collaboration Standards

### Pull Request Standards

PRs should include:

```markdown
## Change Description
<!-- Describe the content and purpose of this change -->

## Change Type
- [ ] New feature (feat)
- [ ] Bug fix (fix)
- [ ] Code refactoring (refactor)

## Testing Method
<!-- Describe how to test -->

## Related Issue
Closes #xxx

## Checklist
- [ ] Code has been self-tested
- [ ] Documentation has been updated
```

### Code Review Standards

Review focus areas:
- **Code quality**: Clear and readable, proper naming, no duplicate code
- **Logic correctness**: Business logic correct, edge cases handled
- **Security**: No security vulnerabilities, sensitive information protected
- **Performance**: No obvious performance issues, resources properly released

For detailed collaboration standards and best practices, see `references/collaboration.md`.

## Common Issues

### Amending the Last Commit

```bash
# Amend commit content (not yet pushed)
git add forgotten-file.ts
git commit --amend --no-edit

# Amend commit message
git commit --amend -m "new commit message"
```

### Push Rejected

```bash
# Pull then push
git pull origin master
git push origin master

# Use rebase for cleaner history
git pull --rebase origin master
git push origin master
```

### Rollback to Previous Version

```bash
# Reset to specific commit (discards subsequent commits)
git reset --hard abc123

# Create reverse commit (recommended, preserves history)
git revert abc123
```

### Stash Current Work

```bash
git stash save "work in progress"
git stash list
git stash pop
```

### View File Modification History

```bash
git log -- <file>             # Commit history
git log -p -- <file>          # Detailed content
git blame <file>              # Per-line author
```

## Best Practices Summary

### Commit Standards

✅ **Recommended**:
- Follow Conventional Commits specification
- Write clear commit messages describing changes
- One commit for one logical change
- Run code checks before committing

❌ **Prohibited**:
- Vague commit messages
- Multiple unrelated changes in one commit
- Committing sensitive information (passwords, keys)
- Developing directly on main branch

### Branch Management

✅ **Recommended**:
- Use feature branches for development
- Regularly sync main branch code
- Delete branches promptly after feature completion
- Use `--no-ff` merge to preserve history

❌ **Prohibited**:
- Developing directly on main branch
- Long-lived unmerged feature branches
- Non-standard branch naming
- Rebasing on public branches

### Code Review

✅ **Recommended**:
- All code goes through Pull Requests
- At least one reviewer approval before merging
- Provide constructive feedback

❌ **Prohibited**:
- Merging without review
- Reviewing your own code

## Additional Resources

### Reference Files

For detailed guidance on specific topics:

- **`references/commit-conventions.md`** - Commit message detailed conventions and examples
- **`references/branching-strategies.md`** - Comprehensive branch management strategies
- **`references/merge-strategies.md`** - Merge, rebase, and conflict resolution strategies
- **`references/conflict-resolution.md`** - Detailed conflict handling and prevention
- **`references/advanced-usage.md`** - Git performance optimization, security, submodules, and advanced techniques
- **`references/collaboration.md`** - Pull request and code review guidelines
- **`references/gitignore-guide.md`** - .gitignore patterns and project-specific configurations

### Example Files

Working examples in `examples/`:
- **`examples/commit-messages.txt`** - Good commit message examples
- **`examples/workflow-commands.sh`** - Common workflow command snippets

## Summary

This document defines the project's Git standards:

1. **Commit Messages** - Follow Conventional Commits specification
2. **Branch Management** - master/develop/feature/bugfix/hotfix/release branch strategy
3. **Workflows** - Standard processes for daily development, hotfixes, and releases
4. **Merge Strategy** - Use rebase to sync feature branches, merge --no-ff to merge
5. **Tag Management** - Semantic versioning, annotated tags
6. **Conflict Resolution** - Regular syncing, small commits, team communication

Following these standards improves collaboration efficiency, ensures code quality, and simplifies version management.
