# Python 错误详解

## 常见内置异常类型

### 1. SyntaxError（语法错误）

**特征**：代码无法解析，在运行前就被检测到

**常见原因**：
- 括号不匹配
- 缺少冒号
- 缩进不正确
- 引号不匹配

**示例**：
```python
# ❌ 缺少冒号
if True
    print("missing colon")

# ✅ 正确
if True:
    print("has colon")
```

### 2. IndentationError（缩进错误）

**特征**：缩进不一致或使用错误的缩进

**常见原因**：
- 混用 Tab 和空格
- 缩进级别不正确

**示例**：
```python
# ❌ 混用空格和 Tab
def test():
	    print("mixed")  # Tab
    print("spaces")    # 空格

# ✅ 统一使用 4 个空格
def test():
    print("spaces")
    print("consistent")
```

### 3. NameError（名称错误）

**特征**：变量或函数名不存在

**常见原因**：
- 变量未定义就使用
- 函数名拼写错误
- 变量作用域问题

**示例**：
```python
# ❌ 变量未定义
print(undefined_var)

# ✅ 先定义再使用
my_var = 42
print(my_var)
```

### 4. TypeError（类型错误）

**特征**：操作或函数应用于错误的数据类型

**常见原因**：
- 拼接不同类型
- 函数参数类型错误
- 对不支持的操作使用运算符

**示例**：
```python
# ❌ 拼接字符串和数字
result = "Value: " + 42

# ✅ 转换类型
result = "Value: " + str(42)
# 或使用 f-string
result = f"Value: {42}"
```

### 5. AttributeError（属性错误）

**特征**：对象没有指定的属性或方法

**常见原因**：
- 属性名拼写错误
- 对象类型不是预期的
- 大小写错误

**示例**：
```python
# ❌ 列表没有 append 以外的方法
my_list = [1, 2, 3]
my_list.push(4)  # 列表没有 push 方法

# ✅ 使用正确的方法
my_list.append(4)
```

### 6. KeyError（键错误）

**特征**：字典中不存在指定的键

**常见原因**：
- 键名拼写错误
- 键不存在于字典中

**示例**：
```python
data = {"name": "Alice"}

# ❌ 直接访问不存在的键
age = data["age"]  # KeyError

# ✅ 使用 get() 方法
age = data.get("age", 0)  # 返回默认值 0
```

### 7. IndexError（索引错误）

**特征**：序列索引超出范围

**常见原因**：
- 索引为负数（除非是有意为之）
- 索引大于序列长度-1
- 序列为空时访问索引

**示例**：
```python
items = [1, 2, 3]

# ❌ 索引超出范围
item = items[5]  # IndexError

# ✅ 检查长度后再访问
if len(items) > 5:
    item = items[5]
else:
    item = None
```

### 8. ValueError（值错误）

**特征**：参数类型正确但值不合适

**常见原因**：
- 字符串转整数失败
- 数学运算值域错误
- 参数值不在允许范围内

**示例**：
```python
# ❌ 无法转换为整数
num = int("abc")

# ✅ 处理可能的错误
try:
    num = int(input())
except ValueError:
    num = 0
```

### 9. ImportError / ModuleNotFoundError（导入错误）

**特征**：无法导入模块

**常见原因**：
- 模块未安装
- 模块路径不在 PYTHONPATH 中
- 模块名拼写错误

**示例**：
```python
# ❌ 模块未安装
import missing_module

# 解决方法：安装模块
# pip install missing-module
```

### 10. FileNotFoundError（文件未找到错误）

**特征**：尝试打开不存在的文件

**常见原因**：
- 文件路径错误
- 文件不存在
- 相对路径使用错误

**示例**：
```python
# ❌ 文件不存在
with open("missing.txt") as f:
    content = f.read()

# ✅ 使用 try-except 或检查文件存在
try:
    with open("file.txt") as f:
        content = f.read()
except FileNotFoundError:
    content = ""
```

## 异常处理最佳实践

### 1. 捕获具体异常

```python
# ❌ 捕获所有异常（不良实践）
try:
    result = dangerous_operation()
except:
    pass

# ✅ 捕获具体异常
try:
    result = dangerous_operation()
except (ValueError, TypeError) as e:
    logger.error(f"操作失败: {e}")
```

### 2. 使用 finally 清理资源

```python
try:
    file = open("data.txt", "r")
    content = file.read()
except FileNotFoundError:
    content = ""
finally:
    # 无论是否发生异常都会执行
    if 'file' in locals():
        file.close()
```

### 3. 使用上下文管理器

```python
# ✅ 推荐：使用 with 语句
with open("data.txt", "r") as file:
    content = file.read()
# 文件会自动关闭
```

### 4. 链式异常

```python
try:
    process_data(data)
except ValueError as e:
    # 使用 raise from 保留原始异常
    raise RuntimeError("数据处理失败") from e
```

## 调试技巧

### 1. 使用 traceback 模块

```python
import traceback

try:
    risky_operation()
except Exception:
    # 打印完整的堆栈跟踪
    traceback.print_exc()
```

### 2. 使用 pdb 调试器

```python
import pdb

# 在代码中设置断点
pdb.set_trace()

# 或使用 breakpoint() (Python 3.7+)
breakpoint()
```

### 3. 使用 logging 模块

```python
import logging

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

logger.debug("调试信息")
logger.info("普通信息")
logger.warning("警告")
logger.error("错误")
logger.critical("严重错误")
```

## 常见错误排查清单

- [ ] 检查拼写（变量名、函数名、属性名）
- [ ] 检查数据类型（使用 type() 函数）
- [ ] 检查变量值（使用 print() 或调试器）
- [ ] 检查索引和键是否在范围内
- [ ] 检查文件路径是否正确
- [ ] 检查缩进是否一致
- [ ] 检查括号、引号是否匹配
- [ ] 检查是否正确导入了模块
- [ ] 检查异常是否被正确处理
