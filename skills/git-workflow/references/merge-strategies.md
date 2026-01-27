# Merge Strategy详解

## Merge vs Rebase

| 特性     | Merge                      | Rebase                   |
| :------- | :------------------------- | :----------------------- |
| History | 保留Complete History，创建合并提交 | Linear History，不创建合并提交 |
| 适用场景 | 公共分支、需要Preserve History     | 私有分支、保持历史清晰   |
| 冲突处理 | 一次性处理所有冲突         | 逐个提交处理冲突         |
| 推荐用法 | 合并到Master Branch               | 同步上游代码             |

## 使用建议

### Feature Branch同步 develop：使用 rebase

```bash
git checkout feature/user-management
git rebase develop
```

### Feature Branch合并到 develop：使用 merge --no-ff

```bash
git checkout develop
git merge --no-ff feature/user-management
```

### develop 合并到 master：使用 merge --no-ff

```bash
git checkout master
git merge --no-ff develop
```

### 禁止在公共分支上 rebase

```bash
# ❌ 危险操作
git checkout develop
git rebase feature/xxx  # 会改写公共历史
```

## Fast-Forward vs No-Fast-Forward

### Fast-Forward 合并（不创建合并提交）

```bash
git merge feature/xxx
```

```
# A---B---C  (master)
#          \
#           D---E  (feature)
# 结果: A---B---C---D---E  (master)
```

### No-Fast-Forward 合并（创建合并提交）

```bash
git merge --no-ff feature/xxx
```

```
# A---B---C---------M  (master)
#          \       /
#           D---E    (feature)
```

**项目约定**：合并Feature Branch时使用 `--no-ff`，保留分支历史信息。

## Squash 合并

将多个提交压缩成一个：

```bash
git checkout develop
git merge --squash feature/user-management
git commit -m "feat(user): 添加用户管理功能"
```

### 适用场景

- Feature Branch有太多琐碎提交
- 想要保持Master Branch历史清晰
- 不需要保留开发过程中的细节

### Squash vs Merge --no-ff

| 策略        | 优点                     | 缺点                     | 适用场景               |
| :---------- | :----------------------- | :----------------------- | :--------------------- |
| merge --no-ff | 保留Complete History和开发过程   | 历史可能比较复杂         | Feature Branch、重要功能     |
| squash      | 历史清晰，一个提交一个功能 | 丢失开发过程信息         | 小功能、实验性功能     |
| rebase      | Linear History，易于理解       | 改写历史，可能引起问题   | 个人分支、同步上游     |

## Rebase 高级用法

### 交互式 Rebase

```bash
# 编辑最近5个提交
git rebase -i HEAD~5
```

在编辑器中可以使用以下命令：
- `pick` - 保留该提交
- `reword` - 修改Commit Message
- `edit` - 修改提交内容
- `squash` - 合并到前一个提交
- `drop` - 删除该提交

### Rebase 时解决冲突

```bash
git rebase develop
# 出现冲突后，编辑文件解决冲突
git add <file>
git rebase --continue
# 如果想放弃 rebase
git rebase --abort
```
