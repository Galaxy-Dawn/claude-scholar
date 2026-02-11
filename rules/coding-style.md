# Code Style Rule

Enforce code style standards for ML projects to ensure maintainability and consistency.

## Core Principles

### Small File Principle (200-400 lines)

- Keep each file within 200-400 lines
- Split into multiple modules when exceeding 400 lines
- Organize related functionality under the same directory

**Example structure:**
```
src/model_module/
├── brain_decoder/
│   ├── __init__.py          # Factory & Registry (50 lines)
│   ├── base_model.py        # Base class (200 lines)
│   ├── transformer.py       # Transformer impl (300 lines)
│   └── cnn.py               # CNN impl (250 lines)
```

### Immutability First

- Use dataclass for configuration (immutable)
- Avoid mutating input parameters inside functions
- Use `@dataclass(frozen=True)` to ensure config immutability

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class ModelConfig:
    hidden_dim: int
    num_layers: int
    dropout: float = 0.1
```

### Error Handling

- Use try/except for exception handling
- Catch specific exception types, avoid bare except
- Log error information for debugging

```python
try:
    data = load_data(path)
except FileNotFoundError as e:
    logger.error(f"Data file not found: {path}")
    raise
```

### Type Hints

- All functions must have type hints
- Use types from the typing module
- Use TypeVar for complex types

```python
from typing import Dict, List, Optional, TypeVar

T = TypeVar('T', bound=Dataset)

def process_data(data: List[Dict], config: Config) -> Optional[DataFrame]:
    ...
```

## Python Specific Standards

### Import Order

```python
# 1. Standard library
import os
from pathlib import Path

# 2. Third-party libraries
import torch
import numpy as np
from hydra import compose, initialize

# 3. Local modules
from src.data_module import DataLoader
from src.model_module import Model
```

### Naming Conventions

```python
# Class names: PascalCase
class DataLoader:
    pass

# Functions/variables: snake_case
def load_config():
    batch_size = 32

# Constants: UPPER_SNAKE_CASE
MAX_EPOCHS = 100
DEFAULT_LR = 0.001

# Private: underscore prefix
def _internal_function():
    pass
```

### Docstrings

```python
def train_model(cfg: Config) -> Model:
    """Train the model.

    Args:
        cfg: Training configuration object.

    Returns:
        Trained model instance.

    Raises:
        ValueError: When configuration is invalid.
    """
    ...
```

## ML Project Specific Standards

### Factory & Registry Pattern

All modules must use factory and registry patterns:

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

### Config-Driven Models

Model `__init__` should only accept a `cfg` parameter:

```python
@register_model('MyModel')
class MyModel(nn.Module):
    def __init__(self, cfg: Config):
        super().__init__()
        # All hyperparameters from cfg
        self.hidden_dim = cfg.model.hidden_dim
```

### Directory Structure

```
run/
├── conf/                    # Hydra configs
├── pipeline/                # Workflow scripts
└── outputs/                 # Output directory

src/
├── data_module/             # Data module
│   ├── dataset/
│   ├── augmentation/
│   └── utils.py
├── model_module/            # Model module
├── trainer_module/          # Trainer module
└── utils/                   # Shared utilities
```

## Prohibited Patterns

❌ **Prohibited:**
- Files exceeding 800 lines
- Nesting deeper than 4 levels
- Mutable default arguments: `def foo(a=[]):`
- Global variables (use config instead)
- Bare except: `except:`
- Hardcoded hyperparameters (use cfg)
- Unused imports
- print() debug statements (use logger)

✅ **Recommended:**
- Split large files
- Use early returns to reduce nesting
- `def foo(a=None):`
- Config-driven parameters
- Specific exception catching
- Type hints
- Docstrings
- Logger for logging

## Verification Checklist

Before committing code, ensure:

```bash
# Type checking
mypy src/

# Code style
ruff check .

# Tests
pytest
```

Violations of these rules will be flagged by the code-reviewer agent.

## Logging Standards

### Logger Naming

```python
import logging

# Use module-level logger with __name__
logger = logging.getLogger(__name__)
```

### Log Levels

| Level | Usage |
|-------|-------|
| `DEBUG` | Detailed diagnostic info (tensor shapes, config values) |
| `INFO` | Training progress, epoch results, key milestones |
| `WARNING` | Recoverable issues (fallback behavior, deprecation) |
| `ERROR` | Failures that need attention but don't crash |
| `CRITICAL` | Unrecoverable errors |

## Module `__init__.py` Standards

Every package `__init__.py` must define `__all__` for explicit public API:

```python
# src/data_module/__init__.py
from .dataset import DatasetFactory, register_dataset
from .augmentation import AugmentationFactory

__all__ = [
    "DatasetFactory",
    "register_dataset",
    "AugmentationFactory",
]
```
