# 常见错误模式

## 通用编程错误模式

### 1. Off-by-one Error（差一错误）

**描述**：循环或索引中出现 ±1 的偏差

**示例**：
```python
# ❌ 错误：范围应该是 range(n) 而不是 range(n+1)
for i in range(len(items) + 1):
    print(items[i])  # IndexError

# ✅ 正确
for i in range(len(items)):
    print(items[i])
```

### 2. Null/None 引用错误

**描述**：尝试访问 None 对象的属性或方法

**Python**：
```python
# ❌ 可能返回 None
result = get_data()
print(result.value)  # AttributeError

# ✅ 检查 None
result = get_data()
if result is not None:
    print(result.value)
```

**JavaScript**：
```javascript
// ❌ 可能是 null
const user = getUser();
console.log(user.name);  // TypeError

// ✅ 使用可选链
console.log(user?.name);
```

### 3. 资源泄漏

**描述**：打开的资源（文件、连接）未正确关闭

**Python**：
```python
# ❌ 文件可能未关闭
f = open("file.txt")
content = f.read()
# 如果发生异常，文件不会关闭

# ✅ 使用 with 语句
with open("file.txt") as f:
    content = f.read()
# 文件自动关闭
```

### 4. 竞态条件

**描述**：多线程/进程间的时序依赖问题

**示例**：
```python
# ❌ 检查后使用（TOCTOU）
if os.path.exists("file.txt"):
    # 其他进程可能在这之间删除文件
    with open("file.txt") as f:
        content = f.read()

# ✅ 直接尝试并处理异常
try:
    with open("file.txt") as f:
        content = f.read()
except FileNotFoundError:
    content = None
```

### 5. 忘记返回值

**描述**：函数没有显式返回值，导致返回 None

**示例**：
```python
# ❌ 忘记返回结果
def calculate(x, y):
    result = x + y
    # 忘记 return

# ✅ 正确返回
def calculate(x, y):
    return x + y
```

### 6. 错误的比较运算符

**描述**：使用 = 代替 ==，或混淆 is 和 ==

**Python**：
```python
# ❌ 赋值而不是比较
if x = 5:  # SyntaxError

# ❌ 使用 is 比较值
if x is 5:  # 不保证正确

# ✅ 正确
if x == 5:
```

### 7. 浮点数精度问题

**描述**：浮点数比较因精度问题失败

**示例**：
```python
# ❌ 直接比较浮点数
if 0.1 + 0.2 == 0.3:  # False
    print("相等")

# ✅ 使用容差比较
if abs((0.1 + 0.2) - 0.3) < 1e-9:
    print("相等")

# 或使用 math.isclose()
import math
if math.isclose(0.1 + 0.2, 0.3):
    print("相等")
```

### 8. 字符串拼接性能问题

**描述**：在循环中使用 + 拼接字符串

**示例**：
```python
# ❌ 低效：每次创建新字符串
result = ""
for item in items:
    result += str(item)

# ✅ 高效：使用列表和 join
result = "".join(str(item) for item in items)
```

## Python 特有模式

### 1. 可变默认参数

```python
# ❌ 所有调用共享同一个列表
def append(item, items=[]):
    items.append(item)
    return items

# ✅ 使用 None 作为默认值
def append(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### 2. 闭包变量绑定问题

```python
# ❌ 所有函数使用相同的 i 值
funcs = [lambda: i for i in range(3)]
# 所有函数都返回 2

# ✅ 使用默认参数捕获值
funcs = [lambda i=i: i for i in range(3)]
```

### 3. 修改正在迭代的序列

```python
# ❌ 迭代时修改列表
items = [1, 2, 3, 4]
for item in items:
    if item % 2 == 0:
        items.remove(item)

# ✅ 创建新列表或使用副本
items = [item for item in items if item % 2 != 0]

# 或
for item in items[:]:
    if item % 2 == 0:
        items.remove(item)
```

## JavaScript/TypeScript 特有模式

### 1. this 绑定问题

```javascript
// ❌ this 丢失上下文
class Counter {
  count = 0;
  increment() {
    setTimeout(function() {
      this.count++;  // this 不是 Counter 实例
    }, 100);
  }
}

// ✅ 使用箭头函数
class Counter {
  count = 0;
  increment() {
    setTimeout(() => {
      this.count++;  // this 正确绑定
    }, 100);
  }
}
```

### 2. 异步错误处理

```javascript
// ❌ 没有处理 Promise 错误
async function getData() {
  const response = await fetch(url);
  return response.json();  // 如果失败会抛出异常
}

// ✅ 使用 try-catch
async function getData() {
  try {
    const response = await fetch(url);
    return await response.json();
  } catch (error) {
    console.error("获取数据失败:", error);
    throw error;
  }
}
```

### 3. 数组/对象引用

```javascript
// ❌ 直接赋值会复制引用
const arr1 = [1, 2, 3];
const arr2 = arr1;
arr2.push(4);  // arr1 也会被修改

// ✅ 创建副本
const arr2 = [...arr1];  // 或 arr1.slice()

// 对象
const obj1 = { a: 1 };
const obj2 = { ...obj1 };  // 或 Object.assign({}, obj1)
```

## 并发错误模式

### 1. 死锁

```python
# ❌ 可能死锁
import threading

lock1 = threading.Lock()
lock2 = threading.Lock()

def thread1():
    with lock1:
        with lock2:
            # 操作

def thread2():
    with lock2:
        with lock1:  # 死锁
            # 操作
```

### 2. 数据竞争

```python
# ❌ 多个线程同时修改共享变量
counter = 0

def increment():
    global counter
    counter += 1  # 非原子操作

# ✅ 使用锁
counter = 0
lock = threading.Lock()

def increment():
    global counter
    with lock:
        counter += 1
```

## 预防措施

1. **使用类型检查**：TypeScript、Python 类型注解
2. **编写单元测试**：覆盖边界条件
3. **使用静态分析工具**：pylint、eslint
4. **代码审查**：让他人检查代码
5. **使用防御性编程**：验证输入、处理异常
