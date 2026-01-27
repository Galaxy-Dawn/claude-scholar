# .gitignore 规范

## 基本规则

```
# 空行：不匹配任何文件
# 注释：以 # 开头
# 目录：以 / 结尾
# 取反：以 ! 开头表示不忽略
# 根目录：以 / 开头表示项目根目录

*.log               # 忽略所有 .log 文件
node_modules/       # 忽略 node_modules 目录
/temp/              # 忽略根目录下的 temp 目录
**/.env             # 忽略所有目录下的 .env 文件
!.gitkeep           # 不忽略 .gitkeep 文件
```

## 通用 .gitignore

```
# ============================================
# 依赖目录
# ============================================
node_modules/
vendor/

# ============================================
# 构建产物
# ============================================
dist/
build/
target/

# ============================================
# 编辑器和 IDE
# ============================================
.idea/
.vscode/
*.sw?

# ============================================
# 环境配置
# ============================================
.env
.env.local
.env.*.local

# ============================================
# 日志文件
# ============================================
logs/
*.log
npm-debug.log*

# ============================================
# 系统文件
# ============================================
.DS_Store
Thumbs.db

# ============================================
# 缓存文件
# ============================================
.cache/
.eslintcache
.stylelintcache
```

## 项目特定配置

### 前端/文档项目补充

```
# VitePress
docs/.vitepress/dist
docs/.vitepress/cache

# Node.js
package-lock.json
yarn.lock
pnpm-lock.yaml
```

### 后端项目补充

```
# Maven
target/
pom.xml.tag
*.jar
!**/src/main/**/target/

# 敏感配置
application-local.yml
application-dev.yml
```

### Python 项目补充

```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/
.pytest_cache/

# Jupyter Notebook
.ipynb_checkpoints

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype
.pytype/
```

### Go 项目补充

```
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with `go test -c`
*.test

# Output of the go coverage tool
*.out

# Dependency directories
vendor/

# Go workspace file
go.work
```

### Rust 项目补充

```
# Rust
/target/
**/*.rs.bk
*.pdb
Cargo.lock
```

## .gitignore 技巧

### 忽略文件但保留目录

```
logs/*
!logs/.gitkeep
```

### 检查忽略规则

```bash
git check-ignore -v filename
```

### 清理已提交的忽略文件

```bash
git rm --cached filename
git commit -m "chore: 移除不应提交的文件"
```

### 调试 .gitignore

```bash
# 查看文件是否被忽略以及被哪条规则匹配
git check-ignore -v path/to/file

# 查看所有被忽略的文件
git ls-files --others --ignored --exclude-standard
```

## 常见模式

### 忽略特定文件

```
# 忽略特定文件
config/local.json
secrets.yaml
```

### 忽略特定类型

```
# 忽略所有 .log 文件
*.log

# 忽略所有临时文件
*.tmp
*.temp
```

### 忽略目录

```
# 忽略所有 node_modules 目录
node_modules/

# 忽略根目录下的 build 目录
/build/

# 忽略任何位置的 build 目录
**/build/
```

### 取反规则

```
# 忽略所有 .a 文件
*.a

# 但不忽略 lib.a
!lib.a

# 忽略所有 TODO 文件
TODO*

# 但不忽略 TODO.md
!TODO.md
```

### 通配符

```
# * 匹配任意字符
*.log

# ** 匹配任意目录
**/temp/

# ? 匹配单个字符
file?.txt

# [] 匹配括号内任意字符
file[0-9].txt
```

## .gitignore 优先级

1. 命令行指定的文件（如 `git add -f`）
2. `.git/info/exclude`（本地排除规则）
3. `.gitignore`（项目级别，提交到仓库）
4. `~/.gitignore_global`（全局级别）

### 本地排除规则

对于不想提交到仓库的本地忽略规则：

```bash
# 编辑本地排除文件
git config --global core.excludesfile ~/.gitignore_global

# 或者使用 .git/info/exclude（仅当前仓库）
echo "secrets.yaml" >> .git/info/exclude
```
