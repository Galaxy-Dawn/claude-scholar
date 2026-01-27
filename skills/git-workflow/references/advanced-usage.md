# Git 高级用法

## Tag管理

### Version Number规范

采用 **Semantic Versioning**（Semantic Versioning）：

```
主Version Number.次Version Number.Patch Version[-Prerelease Identifier]
MAJOR.MINOR.PATCH[-PRERELEASE]
```

| 版本变化 | 说明               | 示例              |
| :------- | :----------------- | :---------------- |
| 主Version Number | 不兼容的 API 修改  | `v1.0.0 → v2.0.0` |
| 次Version Number | 向下兼容的功能新增 | `v1.0.0 → v1.1.0` |
| Patch Version   | 向下兼容的问题修正 | `v1.0.0 → v1.0.1` |

### Prerelease Identifier

- `alpha` - 内测版本
- `beta` - 公测版本
- `rc` - 候选版本

```
v1.0.0-alpha.1    # 第一个内测版本
v1.0.0-beta.1     # 第一个公测版本
v1.0.0-rc.1       # 第一个候选版本
v1.0.0            # 正式版本
```

### Tag操作

#### 创建附注Tag（推荐）

```bash
git tag -a v1.0.0 -m "release: v1.0.0 正式版本

主要更新:
- 新增用户管理模块
- 新增支付功能
- 优化查询性能"
```

#### PushTag

```bash
# Push单个Tag
git push origin v1.0.0

# Push所有Tag
git push origin --tags
```

#### 查看Tag

```bash
git tag
git tag -l "v1.*"
git show v1.0.0
```

#### 删除Tag

```bash
# 删除本地Tag
git tag -d v1.0.0

# 删除远程Tag
git push origin :refs/tags/v1.0.0
```

## Git 性能优化

### 大型仓库优化

```bash
# 浅克隆（只Fetch最近的提交）
git clone --depth 1 https://github.com/repo/project.git

# 部分克隆（按需Fetch）
git clone --filter=blob:none https://github.com/repo/project.git

# 稀疏检出（只检出需要的目录）
git clone --filter=blob:none --sparse https://github.com/repo/project.git
cd project
git sparse-checkout init --cone
git sparse-checkout set src/frontend
```

### 清理仓库

```bash
# 查看仓库大小
git count-objects -vH

# 清理无用对象
git gc --aggressive --prune=now

# 清理远程已删除的分支引用
git remote prune origin

# 清理本地已合并的分支
git branch --merged master | grep -v "\\*\\|master\\|develop" | xargs -n 1 git branch -d
```

### 提升操作速度

```bash
# 启用文件系统缓存
git config --global core.fscache true

# 启用并行Fetch
git config --global fetch.parallel 4

# 启用未跟踪文件缓存
git config --global core.untrackedCache true
```

## Git 安全规范

### 敏感信息保护

```bash
# 检查历史提交中的敏感信息
git log -p | grep -E "(password|secret|api_key)"

# 从History中删除敏感文件
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch config/secrets.yml' \
  --prune-empty --tag-name-filter cat -- --all

# 使用 git-secrets 预防敏感信息提交
git secrets --install
git secrets --register-aws
```

### 签名验证

```bash
# 配置 GPG 签名
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true

# 创建签名提交
git commit -S -m "feat: 签名提交"

# 验证签名
git log --show-signature
```

### 仓库权限控制

| 规则             | master | develop | feature/* |
| :--------------- | :----- | :------ | :-------- |
| 禁止强制Push     | ✅      | ✅       | ❌         |
| 禁止删除         | ✅      | ✅       | ❌         |
| 必须 Code Review | ✅      | ✅       | ❌         |
| 必须通过 CI      | ✅      | ✅       | ❌         |
| 必须签名提交     | ✅      | ❌       | ❌         |

## 子模块管理

### 添加子模块

```bash
git submodule add https://github.com/user/repo.git libs/repo

# 克隆包含子模块的项目
git clone --recurse-submodules https://github.com/user/project.git

# 初始化已有项目的子模块
git submodule init
git submodule update
```

### 更新子模块

```bash
# 更新单个子模块
cd libs/repo
git pull origin main

# 更新所有子模块
git submodule update --remote

# 提交子模块更新
cd ..
git add libs/repo
git commit -m "chore: 更新子模块版本"
```

### 删除子模块

```bash
# 删除子模块条目
git submodule deinit -f libs/repo

# 删除 .git/modules 中的缓存
rm -rf .git/modules/libs/repo

# 删除子模块目录
git rm -f libs/repo
```

## Common Issues解决

### 1. 修改最后一次提交

```bash
# 修改提交内容（未Push）
git add forgotten-file.ts
git commit --amend --no-edit

# 修改Commit Message
git commit --amend -m "新的Commit Message"

# 回滚最后一次提交，保留更改
git reset --soft HEAD~1
```

### 2. Push被拒绝

```bash
# 先Pull再Push
git pull origin master
git push origin master

# 使用 rebase 保持历史清晰
git pull --rebase origin master
git push origin master
```

### 3. 回滚到之前版本

```bash
# Reset到指定提交（Drop之后的提交）
git reset --hard abc123

# 创建反向提交（推荐，Preserve History）
git revert abc123
```

### 4. 恢复误删的分支

```bash
# 查看操作历史
git reflog

# 恢复分支
git checkout -b feature/xxx def456
```

### 5. 合并多个提交

```bash
# 交互式 rebase（只能合并未Push的提交）
git rebase -i HEAD~5

# 在编辑器中将要合并的提交标记为 squash
```

### 6. Stash当前工作

```bash
git stash save "工作进行中"
git stash list
git stash pop
git stash apply stash@{0}
```

### 7. 查看文件修改历史

```bash
git log -- <file>             # 提交历史
git log -p -- <file>          # 详细内容
git blame <file>              # 每行修改人
```

### 8. 处理大文件

```bash
# 使用 Git LFS
git lfs install
git lfs track "*.zip"
git add .gitattributes
```

## 实用技巧

### 配置别名

```bash
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --graph --oneline --all"
```

### 美化日志

```bash
# 图形化历史
git log --graph --oneline --all

# 搜索Commit Message
git log --grep="用户管理"

# 搜索代码变更
git log -S"function_name"
```

### 快速操作

```bash
# 放弃所有未提交更改
git reset --hard HEAD

# 放弃某个文件更改
git checkout -- filename

# 删除未跟踪文件
git clean -fd

# 批量删除已合并分支
git branch --merged master | grep -v "\* master" | xargs -n 1 git branch -d
```

### 安全操作

```bash
# 查看将要Push的内容
git push --dry-run

# 安全的强制Push
git push --force-with-lease

# 备份分支
git branch backup-master master
```

### 查找问题提交

```bash
# 二分查找引入Bug的提交
git bisect start
git bisect bad              # 标记当前有问题
git bisect good v1.0.0      # 标记某版本是好的
# Git会Automatic切换提交，测试后标记 good/bad
git bisect reset            # 结束查找
```

## CHANGELOG 管理

### Automatic生成 CHANGELOG

使用 `conventional-changelog` Automatic生成：

```bash
# 安装
pnpm install -D conventional-changelog-cli

# 生成 CHANGELOG
npx conventional-changelog -p angular -i CHANGELOG.md -s
```

### CHANGELOG 格式

```markdown
# 更新日志

## [1.2.0] - 2024-01-15

### 新增
- 新增用户导出功能 (#123)
- 新增数据备份模块

### 修复
- 修复登录验证码不刷新问题 (#456)
- 修复List分页异常

### 变更
- 优化用户查询性能
- 调整菜单权限校验逻辑

### 移除
- 移除废弃的API接口

## [1.1.0] - 2024-01-01
...
```
