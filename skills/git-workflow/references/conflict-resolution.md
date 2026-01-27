# 冲突处理详解

## 识别冲突

当 Git 无法Automatic合并时，会标记冲突：

```
<<<<<<< HEAD
// 当前分支的代码
const name = '张三'
=======
// 要合并的分支的代码
const name = '李四'
>>>>>>> feature/user-management
```

## 解决冲突步骤

### 1. 查看冲突文件

```bash
git status
```

### 2. Manual编辑文件，解决冲突

打开冲突文件，找到冲突标记（`<<<<<<<`、`=======`、`>>>>>>>`），Manual编辑选择保留的内容或合并两者。

### 3. 标记已解决

```bash
git add <file>
```

### 4. 完成合并

```bash
# 对于 merge 冲突
git commit

# 对于 rebase 冲突
git rebase --continue
```

## 冲突处理策略

### 保留当前分支版本

```bash
git checkout --ours <file>
git add <file>
```

### 保留传入分支版本

```bash
git checkout --theirs <file>
git add <file>
```

### 放弃合并

```bash
# 放弃 merge
git merge --abort

# 放弃 rebase
git rebase --abort
```

## 预防冲突的Best Practices

1. **及时同步代码** - 每天开始工作前Pull最新代码
2. **小步提交** - 频繁提交小的改动
3. **功能模块化** - 不同功能在不同文件中实现
4. **沟通协作** - 避免同时修改同一文件

## 常见冲突场景

### 场景1：同一文件不同位置修改

这种情况 Git 通常能Automatic合并，无需人工干预。

### 场景2：同一行不同修改

需要Manual决定保留哪个版本或合并两者。

### 场景3：文件重命名

Git 通常能智能识别，但如果一个分支重命名而另一个分支修改内容，可能需要Manual处理。

### 场景4：二进制文件冲突

对于图片、PDF 等二进制文件，需要决定保留哪个版本：

```bash
# 保留当前分支的版本
git checkout --ours image.png

# 或保留传入分支的版本
git checkout --theirs image.png
```

## 冲突解决工具

### 使用 merge 工具

```bash
# 配置合并工具
git config --global merge.tool vimdiff
git config --global mergetool.prompt false

# 使用合并工具
git mergetool
```

### 使用 diff 工具

```bash
# 查看详细差异
git diff --ours
git diff --theirs
git diff --base
```

## Rebase 冲突特殊处理

Rebase 时冲突会逐个提交出现，处理方式：

```bash
git rebase develop
# 冲突1 -> 解决 -> git add -> git rebase --continue
# 冲突2 -> 解决 -> git add -> git rebase --continue
# ...
# 直到完成
```

如果某一步想跳过：

```bash
git rebase --skip
```

如果整体想放弃：

```bash
git rebase --abort
```
