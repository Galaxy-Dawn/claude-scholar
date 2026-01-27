---
name: bug-detective
description: This skill should be used when the user asks to "debug this", "fix this error", "investigate this bug", "troubleshoot this issue", "find the problem", "something is broken", "this isn't working", "why is this failing", or reports errors/exceptions/bugs. Provides systematic debugging workflow and common error patterns.
version: 0.1.0
---

# Bug Detective

系统化的DebugProcess，用于排查和解决CodeError、异常和故障。提供结构化的DebugMethod和常见ErrorPattern识别。

## 核心理念

Debug是科学问题的解决过程，需要：
1. **理解问题** - 清晰定义症状和预期行为
2. **收集证据** - GetErrorInformation、日志、堆栈跟踪
3. **形成假设** - 基于证据推断可能原因
4. **Verify假设** - 通过实验确认或排除原因
5. **解决问题** - 应用Fix并Verify

## DebugProcess

### 第一步：理解问题

在开始Debug前，明确以下Information：

**必须收集的Information：**
- Error消息的完整Content
- Error发生的具体位置（File名和行号）
- 复现Step（如何触发Error）
- 预期行为 vs 实际行为
- EnvironmentInformation（操作系统、Version、Dependency）

**提问模板：**
```
1. 具体的Error消息是什么？
2. Error发生在哪个File的哪一行？
3. 如何复现这个问题？请提供详细Step
4. 期望的Result是什么？实际发生了什么？
5. 最近有什么改动可能引入这个问题？
```

### 第二步：分析ErrorClass型

根据ErrorClass型选择Debug策略：

| ErrorClass型 | 特征 | DebugMethod |
|---------|------|---------|
| **语法Error** | Code无法Parse | Check语法、括号匹配、引号 |
| **导入Error** | ModuleNotFoundError | CheckModule安装、PathConfiguration |
| **Class型Error** | TypeError | CheckDataClass型、Class型Convert |
| **PropertyError** | AttributeError | CheckObjectProperty是否存在 |
| **KeyError** | KeyError | Check字典Key是否存在 |
| **索引Error** | IndexError | Check列表/数组索引范围 |
| **空指针** | NoneType/NullPointerException | CheckVariable是否为 None |
| **网络Error** | ConnectionError/Timeout | Check网络连接、URL、超时Set |
| **权限Error** | PermissionError | CheckFile权限、用户权限 |
| **资源Error** | FileNotFoundError | CheckFilePath是否存在 |

### 第三步：定位问题源头

使用以下Method定位问题：

**1. 二分法定位**
- Comment掉一半Code，Check问题是否仍然存在
- 逐步缩小范围直到找到问题Code

**2. 日志追踪**
- 在关Key位置Add print/logging 语句
- 追踪VariableValue的变化
- 确认CodeExecutePath

**3. 断点Debug**
- 使用Debug器的断点Feature
- 单步ExecuteCode
- CheckVariableStatus

**4. 堆栈跟踪分析**
- 从Error消息中的堆栈跟踪找到调用链
- 确定Error发生的直接原因
- 追溯到根本原因

### 第四步：形成假设并Verify

**假设框架：**
```
假设：[问题Description]导致[Error现象]

VerifyStep：
1. [VerifyMethod1]
2. [VerifyMethod2]

预期Result：
- 如果假设正确：[预期现象]
- 如果假设Error：[预期现象]
```

### 第五步：应用Fix

Fix后必须Verify：
1. 原始Error已解决
2. 没有引入新的Error
3. 相关Feature仍正常工作
4. AddTesting防止回归

## Python 常见ErrorPattern

### 1. 缩进Error
### 2. 可变默认Parameter
### 3. 循环中的闭Package问题
### 4. Modify正在迭代的列表
### 5. 字符串比较使用 is
### 6. 忘记调用 super().__init__()

## JavaScript/TypeScript 常见ErrorPattern

### 1. this 绑定问题
### 2. 异步ErrorProcess
### 3. Object引用比较

## Bash/Zsh 常见ErrorPattern

### 1. 空格问题

```bash
# ❌ 赋Value不能有空格
name = "John"  # Error：尝试Run name Command

# ✅ 正确的赋Value
name="John"

# ❌ 条件Testing缺少空格
if[$name -eq 1]; then  # Error

# ✅ 正确
if [ $name -eq 1 ]; then
```

### 2. 引号问题

```bash
# ❌ 单引号内Variable不展开
echo 'The value is $var'  # Output: The value is $var

# ✅ 使用双引号
echo "The value is $var"  # Output: The value is actual_value

# ❌ Command替换使用反引号（易混淆）
result=`command`

# ✅ 使用 $()
result=$(command)
```

### 3. 未引用的Variable

```bash
# ❌ Variable未引用，空Value会导致Error
rm -rf $dir/*  # 如果 dir 为空，会Delete当前Directory所有File

# ✅ 始终引用Variable
[ -n "$dir" ] && rm -rf "$dir"/*

# 或使用 set -u 防止未定义Variable
set -u  # 或 set -o nounset
```

### 4. 循环中的Variable作用域

```bash
# ❌ 管道Create子 shell，外部Variable不改变
cat file.txt | while read line; do
    count=$((count + 1))  # 外部 count 不会改变
done
echo "Total: $count"  # Output 0

# ✅ 使用进程替换或重定向
while read line; do
    count=$((count + 1))
done < file.txt
echo "Total: $count"  # 正确Output
```

### 5. 数组操作

```bash
# ❌ Error的数组访问
arr=(1 2 3)
echo $arr[1]  # Output 1[1]

# ✅ 正确的数组访问
echo ${arr[1]}  # Output 2
echo ${arr[@]}  # Output所有元素
echo ${#arr[@]} # Output数组长度
```

### 6. 字符串比较

```bash
# ❌ 使用 = 比较字符串
if [ $name = "John" ]; then  # 在某些 shell 中不是标准

# ✅ 使用 = 或 ==
if [ "$name" = "John" ]; then
if [[ "$name" == "John" ]]; then

# ❌ 数字比较使用 -eq 不是 =
if [ $age = 18 ]; then  # Error

# ✅ 数字比较使用算术运算符
if [ $age -eq 18 ]; then
if (( age == 18 )); then
```

### 7. CommandFailContinueExecute

```bash
# ❌ CommandFail后ContinueExecute
cd /nonexistent
rm file.txt  # 会Delete当前Directory的 file.txt

# ✅ 使用 set -e 在Error时退出
set -e  # 或 set -o errexit
cd /nonexistent  # 脚本在此处退出
rm file.txt

# 或CheckCommand是否Success
cd /nonexistent || exit 1
```

## 常见DebugCommand

### Python pdb Debug器
### Node.js inspector
### Git Bisect

### Bash Debug

```bash
# DebugPatternRun脚本
bash -x script.sh  # 打印每个Command
bash -v script.sh  # 打印Command原文
bash -n script.sh  # 语法Check，不Execute

# 在脚本中启用Debug
set -x  # 启用Command追踪
set -v  # 启用 verbose Pattern
set -e  # Error时退出
set -u  # 未定义Variable报错
set -o pipefail  # 管道中任一CommandFail则Fail
```

## 预防性Debug

### 1. 使用Class型Check
### 2. InputVerify
### 3. 防御性编程
### 4. 日志Log

## DebugCheck清单

### 开始Debug前
- [ ] Get完整的Error消息
- [ ] LogError发生的堆栈跟踪
- [ ] 确认复现Step
- [ ] 了解预期行为

### Debug过程中
- [ ] Check最近的Code改动
- [ ] 使用二分法定位问题
- [ ] Add日志追踪Variable
- [ ] Verify假设

### 解决问题后
- [ ] 确认原始Error已Fix
- [ ] Testing相关Feature
- [ ] AddTesting防止回归
- [ ] Log问题和解决方案

## Additional Resources

### Reference Files

For detailed debugging techniques and patterns:
- **`references/python-errors.md`** - Python Error详解
- **`references/javascript-errors.md`** - JavaScript/TypeScript Error详解
- **`references/shell-errors.md`** - Bash/Zsh 脚本Error详解
- **`references/debugging-tools.md`** - Debug工具使用Guide
- **`references/common-patterns.md`** - 常见ErrorPattern

### Example Files

Working debugging examples:
- **`examples/debugging-workflow.py`** - 完整DebugProcessExample
- **`examples/error-handling-patterns.py`** - ErrorProcessPattern
- **`examples/debugging-workflow.sh`** - Shell 脚本DebugExample
