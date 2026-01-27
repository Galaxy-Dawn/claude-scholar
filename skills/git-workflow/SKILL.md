---
name: git-workflow
description: This skill should be used when the user asks to "create git commit", "manage branches", "follow git workflow", "use Conventional Commits", "handle merge conflicts", or asks about git branching strategies, version control best practices, pull request workflows. Provides comprehensive Git workflow guidance for team collaboration.
version: 1.2.0
---

# Git Standard

本Documentation定义Project的 Git 使用Standard，Package括Commit消息格式、Branch管理策略、Workflow程、Merge策略等Content。遵循这些Standard可以提高协作效率、便于追溯、支持自动化、减少Conflict。

## Commit Message Standard

Project采用 **Conventional Commits** Standard：

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type Class型

| Class型 | 说明 | Example |
| :--- | :--- | :--- |
| `feat` | 新Feature | `feat(user): Add用户导出Feature` |
| `fix` | FixBug | `fix(login): FixVerify码不刷新问题` |
| `docs` | DocumentationUpdate | `docs(api): UpdateInterfaceDocumentation` |
| `refactor` | 重构 | `refactor(utils): 重构工具Function` |
| `perf` | PerformanceOptimize | `perf(list): Optimize列表Performance` |
| `test` | Testing相关 | `test(user): Add单元Testing` |
| `chore` | 其他Modify | `chore: UpdateDependencyVersion` |

### Subject Standard

- 使用动词开头：Add、Fix、Update、Remove、Optimize
- 不超过50个字符
- 不以句号结尾

更多详细Standard和Example，参见 `references/commit-conventions.md`。

## Branch管理策略

### BranchClass型

| BranchClass型 | 命名Standard | 说明 | 生命周期 |
| :--- | :--- | :--- | :--- |
| master | `master` | 主Branch，可ReleaseStatus | 永久 |
| develop | `develop` | DevelopmentBranch，集成最新Code | 永久 |
| feature | `feature/Feature名` | FeatureBranch | DevelopmentComplete后Delete |
| bugfix | `bugfix/问题Description` | BugFixBranch | FixComplete后Delete |
| hotfix | `hotfix/问题Description` | 紧急FixBranch | FixComplete后Delete |
| release | `release/Version号` | ReleaseBranch | ReleaseComplete后Delete |

### Branch命名Example

```
feature/user-management          # 用户管理Feature
feature/123-add-export          # 关联Issue的Feature
bugfix/login-error              # 登录ErrorFix
hotfix/security-vulnerability   # Security漏洞Fix
release/v1.0.0                  # VersionRelease
```

### Branch保护规则

**master Branch：**
- 禁止直接推送
- 必须通过 Pull Request Merge
- 必须通过 CI Check
- 必须至少一人 Code Review

**develop Branch：**
- 限制直接推送
- 建议通过 Pull Request Merge
- 必须通过 CI Check

详细的Branch策略和Workflow程，参见 `references/branching-strategies.md`。

## Workflow程

### 日常DevelopmentProcess

```bash
# 1. 同步最新Code
git checkout develop
git pull origin develop

# 2. CreateFeatureBranch
git checkout -b feature/user-management

# 3. Development并Commit
git add .
git commit -m "feat(user): Add用户列表页面"

# 4. 推送到远程
git push -u origin feature/user-management

# 5. Create Pull Request 并请求 Code Review

# 6. Merge到 develop（通过 PR）

# 7. DeleteFeatureBranch
git branch -d feature/user-management
git push origin -d feature/user-management
```

### 紧急FixProcess

```bash
# 1. 从 master CreateFixBranch
git checkout master
git pull origin master
git checkout -b hotfix/critical-bug

# 2. Fix并Commit
git add .
git commit -m "fix(auth): Fix认证绕过漏洞"

# 3. Merge到 master
git checkout master
git merge --no-ff hotfix/critical-bug
git tag -a v1.0.1 -m "hotfix: Fix认证绕过漏洞"
git push origin master --tags

# 4. 同步到 develop
git checkout develop
git merge --no-ff hotfix/critical-bug
git push origin develop
```

### VersionReleaseProcess

```bash
# 1. CreateReleaseBranch
git checkout develop
git checkout -b release/v1.0.0

# 2. UpdateVersion号和Documentation

# 3. CommitVersionUpdate
git add .
git commit -m "chore(release): 准备Release v1.0.0"

# 4. Merge到 master
git checkout master
git merge --no-ff release/v1.0.0
git tag -a v1.0.0 -m "release: v1.0.0 正式Version"
git push origin master --tags

# 5. 同步到 develop
git checkout develop
git merge --no-ff release/v1.0.0
git push origin develop
```

## Merge策略

### Merge vs Rebase

| 特性 | Merge | Rebase |
| :--- | :--- | :--- |
| 历史Log | 保留完整历史 | 线性历史 |
| 适用场景 | 公共Branch | 私有Branch |
| 推荐用法 | Merge到主Branch | 同步上游Code |

### 使用建议

- **FeatureBranch同步 develop**：使用 `rebase`
- **FeatureBranchMerge到 develop**：使用 `merge --no-ff`
- **develop Merge到 master**：使用 `merge --no-ff`

```bash
# ✅ 推荐: FeatureBranch同步 develop
git checkout feature/user-management
git rebase develop

# ✅ 推荐: MergeFeatureBranch到 develop
git checkout develop
git merge --no-ff feature/user-management

# ❌ 不推荐: 在公共Branch上 rebase
git checkout develop
git rebase feature/xxx  # 危险操作
```

**Project约定**：MergeFeatureBranch时使用 `--no-ff`，保留Branch历史Information。

详细的Merge策略和技巧，参见 `references/merge-strategies.md`。

## ConflictProcess

### 识别Conflict

```
<<<<<<< HEAD
// 当前Branch的Code
const name = '张三'
=======
// 要Merge的Branch的Code
const name = '李四'
>>>>>>> feature/user-management
```

### 解决Conflict

```bash
# 1. 查看ConflictFile
git status

# 2. 手动编辑File，解决Conflict

# 3. 标记已解决
git add <file>

# 4. CompleteMerge
git commit  # merge Conflict
# 或
git rebase --continue  # rebase Conflict
```

### ConflictProcess策略

```bash
# 保留当前BranchVersion
git checkout --ours <file>

# 保留传入BranchVersion
git checkout --theirs <file>

# 放弃Merge
git merge --abort
git rebase --abort
```

### 预防Conflict

1. **及时同步Code** - 每天开始工作前拉取最新Code
2. **小步Commit** - 频繁Commit小的改动
3. **FeatureModule化** - 不同Feature在不同File中Implementation
4. **沟通协作** - 避免同时Modify同一File

详细的ConflictProcess和高级技巧，参见 `references/conflict-resolution.md`。

## .gitignore Standard

### 基本规则

```
# Ignore所有 .log File
*.log

# IgnoreDirectory
node_modules/

# Ignore根Directory下的Directory
/temp/

# Ignore所有Directory下的File
**/.env

# 不Ignore特定File
!.gitkeep
```

### 通用 .gitignore

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

详细的 .gitignore Pattern和Project特定Configuration，参见 `references/gitignore-guide.md`。

## 标签管理

采用 **语义化Version**（Semantic Versioning）：

```
主Version号.次Version号.修订号[-预Release标识]
MAJOR.MINOR.PATCH[-PRERELEASE]
```

### Version变化说明

- **主Version号**：不兼容的 API Modify（v1.0.0 → v2.0.0）
- **次Version号**：向下兼容的Feature新增（v1.0.0 → v1.1.0）
- **修订号**：向下兼容的问题修正（v1.0.0 → v1.0.1）

### 标签操作

```bash
# Create附注标签（推荐）
git tag -a v1.0.0 -m "release: v1.0.0 正式Version"

# 推送标签
git push origin v1.0.0
git push origin --tags

# 查看标签
git tag
git show v1.0.0

# Delete标签
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

## 多人协作Standard

### Pull Request Standard

Create PR 时应Package含：

```markdown
## 变更说明
<!-- Description本次变更的Content和目的 -->

## 变更Class型
- [ ] 新Feature (feat)
- [ ] Bug Fix (fix)
- [ ] Code重构 (refactor)

## Testing方式
<!-- Description如何Testing -->

## 关联 Issue
Closes #xxx

## Check清单
- [ ] Code已自测
- [ ] Documentation已Update
```

### Code Review Standard

Review要点：
- **Code质量**：清晰易读、命名Standard、无重复Code
- **逻辑正确性**：业务逻辑正确、边界条件Process
- **Security性**：无Security漏洞、敏感Information保护
- **Performance**：无明显Performance问题、资源正确释放

详细的协作Standard和最佳实践，参见 `references/collaboration.md`。

## 常见问题

### Modify最后一次Commit

```bash
# ModifyCommitContent（未推送）
git add forgotten-file.ts
git commit --amend --no-edit

# ModifyCommit消息
git commit --amend -m "新的Commit消息"
```

### 推送被拒绝

```bash
# 先拉取再推送
git pull origin master
git push origin master

# 使用 rebase 保持历史清晰
git pull --rebase origin master
git push origin master
```

### 回滚到之前Version

```bash
# 重置到指定Commit（丢弃之后的Commit）
git reset --hard abc123

# Create反向Commit（推荐，保留历史）
git revert abc123
```

### 暂存当前工作

```bash
git stash save "工作进行中"
git stash list
git stash pop
```

### 查看FileModify历史

```bash
git log -- <file>             # Commit历史
git log -p -- <file>          # 详细Content
git blame <file>              # 每行Modify人
```

## 最佳实践总结

### CommitStandard

✅ **推荐**：
- 使用 Conventional Commits Standard
- Commit消息清晰Description改动
- 一次Commit只做一件事
- Commit前进行CodeCheck

❌ **禁止**：
- Commit消息模糊不清
- 一次Commit多个不相关改动
- Commit敏感Information（密码、密钥）
- 直接在主BranchDevelopment

遵循这些Standard可以提高协作效率、便于追溯、支持自动化、减少Conflict。

### Branch管理

✅ **推荐**：
- 使用 feature BranchDevelopment
- 定期同步主BranchCode
- FeatureComplete后及时DeleteBranch
- 使用 `--no-ff` Merge保留历史

❌ **禁止**：
- 在主Branch直接Development
- 长期不Merge的FeatureBranch
- Branch命名不Standard
- 在公共Branch上 rebase

### CodeReview

✅ **推荐**：
- 所有Code通过 Pull Request
- 至少一人审核通过才能Merge
- 提供建设性反馈

❌ **禁止**：
- 未经Review直接Merge
- 自己Review自己的Code

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

本Documentation定义了Project的 Git Standard：

1. **Commit Message** - 采用 Conventional Commits Standard
2. **Branch管理** - master/develop/feature/bugfix/hotfix/release Branch策略
3. **Workflow程** - 日常Development、紧急Fix、VersionRelease的标准Process
4. **Merge策略** - FeatureBranch用 rebase 同步，用 merge --no-ff Merge
5. **标签管理** - 语义化Version，附注标签
6. **ConflictProcess** - 及时同步、小步Commit、沟通协作

遵循这些Standard可以提高协作效率、保证Code质量、简化Version管理。
