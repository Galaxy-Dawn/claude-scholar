# Code Style Rule

强制执行 ML 项目的代码风格规范，确保代码可维护性和一致性。

## 核心原则

### 小文件原则 (200-400 行)

- 每个文件保持在 200-400 行
- 超过 400 行时拆分为多个模块
- 相关功能组织在同一目录下

**示例结构：**
```
src/model_module/
├── brain_decoder/
│   ├── __init__.py          # Factory & Registry (50 行)
│   ├── base_model.py        # 基类 (200 行)
│   ├── transformer.py       # Transformer 实现 (300 行)
│   └── cnn.py               # CNN 实现 (250 行)
```

### 不可变性优先

- 配置使用 dataclass（不可变）
- 避免在函数内部修改输入参数
- 使用 `@dataclass(frozen=True)` 确保配置不可变

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class ModelConfig:
    hidden_dim: int
    num_layers: int
    dropout: float = 0.1
```

### 错误处理

- 使用 try/except 处理异常
- 捕获具体异常类型，避免裸 except
- 记录错误信息用于调试

```python
try:
    data = load_data(path)
except FileNotFoundError as e:
    logger.error(f"Data file not found: {path}")
    raise
```

### 类型提示

- 所有函数必须有类型提示
- 使用 typing 模块的类型
- 复杂类型使用 TypeVar

```python
from typing import Dict, List, Optional, TypeVar

T = TypeVar('T', bound=Dataset)

def process_data(data: List[Dict], config: Config) -> Optional[DataFrame]:
    ...
```

## Python 特定规范

### 导入顺序

```python
# 1. 标准库
import os
from pathlib import Path

# 2. 第三方库
import torch
import numpy as np
from hydra import compose, initialize

# 3. 本地模块
from src.data_module import DataLoader
from src.model_module import Model
```

### 命名规范

```python
# 类名：PascalCase
class DataLoader:
    pass

# 函数/变量：snake_case
def load_config():
    batch_size = 32

# 常量：UPPER_SNAKE_CASE
MAX_EPOCHS = 100
DEFAULT_LR = 0.001

# 私有：前缀下划线
def _internal_function():
    pass
```

### 文档字符串

```python
def train_model(cfg: Config) -> Model:
    """训练模型

    Args:
        cfg: 训练配置对象

    Returns:
        训练好的模型实例

    Raises:
        ValueError: 配置无效时
    """
    ...
```

## ML 项目特定规范

### Factory & Registry 模式

所有模块必须使用工厂和注册模式：

```python
# dataset/__init__.py
DATASET_FACTORY: Dict[str, Type[Dataset]] = {}

def register_dataset(name: str):
    def decorator(cls):
        DATASET_FACTORY[name] = cls
        return cls
    return decorator

def DatasetFactory(name: str) -> Type[Dataset]:
    return DATASET_FACTORY.get(name, SimpleDataset)
```

### Config-Driven 模型

模型 `__init__` 只接受 `cfg` 参数：

```python
@register_model('MyModel')
class MyModel(nn.Module):
    def __init__(self, cfg: Config):
        super().__init__()
        # 所有超参数从 cfg 获取
        self.hidden_dim = cfg.model.hidden_dim
```

### 目录结构规范

```
run/
├── conf/                    # Hydra 配置
├── pipeline/                # 工作流脚本
└── outputs/                 # 输出目录

src/
├── data_module/             # 数据模块
│   ├── dataset/
│   ├── augmentation/
│   └── utils.py
├── model_module/            # 模型模块
├── trainer_module/          # 训练模块
└── utils/                   # 共享工具
```

## 禁止模式

❌ **禁止：**
- 超过 800 行的文件
- 4 层以上的嵌套
- 可变默认参数：`def foo(a=[]):`
- 全局变量（使用配置代替）
- 裸 except：`except:`
- 硬编码的超参数（使用 cfg）
- 未使用的导入
- print() 调试语句（使用 logger）

✅ **推荐：**
- 拆分大文件
- 使用早期返回减少嵌套
- `def foo(a=None):`
- 配置驱动的参数
- 具体异常捕获
- 类型提示
- 文档字符串
- logger 记录

## 验证检查

在提交代码前确保：

```bash
# 类型检查
mypy src/

# 代码风格
ruff check .

# 测试
pytest
```

违反这些规则将被 code-reviewer agent 标记。
