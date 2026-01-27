# Bash/Zsh 脚本错误详解

## 常见错误类型

### 1. Command Not Found

**特征**：bash: command: command not found

**常见原因**：
- 命令拼写错误
- 命令未安装
- PATH 环境变量不正确
- 脚本 shebang 错误

**示例**：
```bash
# 拼写错误
pyhon script.py  # command not found

# 正确拼写
python script.py

# PATH 问题
/usr/local/bin/mycommand  # 如果 PATH 不包含 /usr/local/bin

# 使用完整路径或添加到 PATH
export PATH="/usr/local/bin:$PATH"
mycommand
```

### 2. Syntax Error

**特征**：syntax error near unexpected token

**常见原因**：
- 缺少 then/fi/done/ esac
- 括号不匹配
- 操作符缺少空格

**示例**：
```bash
# 缺少 then
if [ 1 -eq 1 ]
echo "yes"  # syntax error

# 正确
if [ 1 -eq 1 ]; then
    echo "yes"
fi
```

### 3. Permission Denied

**特征**：bash: ./script.sh: Permission denied

**解决方案**：
```bash
# 添加执行权限
chmod +x script.sh

# 或使用 bash 运行
bash script.sh
```

## 调试技巧

### 1. 使用 set -x 追踪执行

```bash
#!/bin/bash
set -x  # 启用命令追踪

name="John"
echo "Hello $name"

# 输出：
# + name=John
# + echo 'Hello John'
# Hello John
```

### 2. 使用 set -e 遇错退出

```bash
#!/bin/bash
set -e  # 任何命令失败时退出

cd /nonexistent  # 脚本在此处退出
echo "This won't run"
```

### 3. 使用 set -u 检测未定义变量

```bash
#!/bin/bash
set -u  # 未定义变量时报错

echo $undefined_var  # 报错并退出
```

### 4. 组合使用调试选项

```bash
#!/bin/bash
set -xeuo pipefail  # 严格模式

# -x: 打印每个命令
# -e: 错误时退出
# -u: 未定义变量报错
# -o pipefail: 管道失败则失败
```

### 5. 使用 trap 捕获错误

```bash
#!/bin/bash
# 在脚本退出时执行清理
trap 'echo "Script exited with code $?"' EXIT

# 在错误时执行
trap 'echo "Error on line $LINENO"' ERR

# 在中断时执行
trap 'echo "Interrupted"; cleanup' INT
```

## 错误处理模式

### 1. 检查命令退出码

```bash
# 检查上一个命令是否成功
if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi

# 或使用 ||
command || { echo "Failed"; exit 1; }

# 或使用 &&
command && echo "Success" || echo "Failed"
```

### 2. 使用函数封装错误处理

```bash
# 定义错误处理函数
die() {
    local message=$1
    echo "Error: $message" >&2
    exit 1
}

# 使用
[ -f "$file" ] || die "File not found: $file"
```

### 3. 验证输入参数

```bash
#!/bin/bash
# 检查参数数量
[ $# -ge 1 ] || die "Usage: $0 <arg1> [arg2]"

# 检查文件存在
[ -f "$1" ] || die "File not found: $1"

# 检查目录存在
[ -d "$2" ] || die "Directory not found: $2"
```

## 最佳实践

### 1. 始终使用 shebang

```bash
#!/bin/bash
# 或
#!/usr/bin/env bash
```

### 2. 使用 set -euo pipefail

```bash
#!/bin/bash
set -euo pipefail
```

### 3. 引用所有变量

```bash
# 除非确定变量不包含空格或通配符
echo "$var"
```

### 4. 使用 [[ ]] 而不是 [ ]

```bash
# [[ 更强大且更安全
if [[ $name == "John" ]]; then
if [[ -f $file && $size -gt 100 ]]; then
```

### 5. 使用 $(command) 而不是反引号

```bash
# $() 更易读且可嵌套
result=$(command1 $(command2))
```

### 6. 使用函数组织代码

```bash
my_function() {
    local arg1=$1
    local arg2=$2
    # 函数体
}

my_function "value1" "value2"
```

## ShellCheck 静态分析

ShellCheck 是一个 Shell 脚本静态分析工具：

```bash
# 安装 ShellCheck
brew install shellcheck  # macOS
apt install shellcheck   # Ubuntu

# 使用
shellcheck script.sh
```
