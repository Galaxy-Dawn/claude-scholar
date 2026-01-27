#!/bin/bash
# Git 工作流常用命令示例

# ============================================
# 日常开发流程
# ============================================

# 1. 同步最新代码
git checkout develop
git pull origin develop

# 2. 创建功能分支
git checkout -b feature/user-management

# 3. 开发并提交
git add .
git commit -m "feat(user): 添加用户列表页面"

# 4. 推送到远程
git push -u origin feature/user-management

# 5. 同步上游更新到功能分支
git fetch origin develop
git rebase origin/develop

# 6. 合并到 develop（通过 PR 或直接）
git checkout develop
git merge --no-ff feature/user-management
git push origin develop

# 7. 删除功能分支
git branch -d feature/user-management
git push origin -d feature/user-management

# ============================================
# 紧急修复流程
# ============================================

# 1. 从 master 创建修复分支
git checkout master
git pull origin master
git checkout -b hotfix/security-fix

# 2. 修复并提交
git add .
git commit -m "fix(auth): 修复认证绕过漏洞"

# 3. 合并到 master
git checkout master
git merge --no-ff hotfix/security-fix
git tag -a v1.0.1 -m "hotfix: 修复认证绕过漏洞"
git push origin master --tags

# 4. 同步到 develop
git checkout develop
git merge --no-ff hotfix/security-fix
git push origin develop

# 5. 删除修复分支
git branch -d hotfix/security-fix

# ============================================
# 版本发布流程
# ============================================

# 1. 创建发布分支
git checkout develop
git checkout -b release/v1.0.0

# 2. 更新版本号和文档
# 手动编辑 package.json、CHANGELOG.md 等

# 3. 提交版本更新
git add .
git commit -m "chore(release): 准备发布 v1.0.0"

# 4. 合并到 master
git checkout master
git merge --no-ff release/v1.0.0
git tag -a v1.0.0 -m "release: v1.0.0 正式版本"
git push origin master --tags

# 5. 同步到 develop
git checkout develop
git merge --no-ff release/v1.0.0
git push origin develop

# 6. 删除发布分支
git branch -d release/v1.0.0

# ============================================
# 冲突处理
# ============================================

# Merge 冲突处理
git merge feature/xxx
# 编辑冲突文件...
git add <file>
git commit

# Rebase 冲突处理
git rebase develop
# 编辑冲突文件...
git add <file>
git rebase --continue

# 放弃合并
git merge --abort
git rebase --abort

# ============================================
# 常用工具命令
# ============================================

# 查看状态
git status

# 查看日志
git log --oneline --graph --all

# 查看分支
git branch -a

# 暂存工作
git stash save "工作进行中"
git stash list
git stash pop

# 查看文件修改
git diff
git diff --staged
git log -p -- <file>
