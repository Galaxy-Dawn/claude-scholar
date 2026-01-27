# Registry Pattern

## Overview

The Registry pattern allows components to register themselves via decorators, enabling automatic discovery and centralized management of available types.

## Structure

```python
# In module __init__.py (e.g., data_module/dataset/__init__.py)
from typing import Dict, Callable, TypeVar

T = TypeVar('T')

DATASET_FACTORY: Dict[str, type] = {}

def register_dataset(name: str) -> Callable[[T], T]:
    """Decorator to register dataset classes."""
    def decorator(cls: T) -> T:
        DATASET_FACTORY[name] = cls
        return cls
    return decorator
```

## Usage

```python
# In implementation file (e.g., simple_dataset.py)
from data_module.dataset import register_dataset

@register_dataset("simple")
class SimpleDataset(Dataset):
    def __init__(self, cfg):
        # Implementation
        pass
```

## Benefits

- **Automatic registration**: Components register themselves on import
- **Declarative**: Single decorator line replaces manual registration code
- **Import-time discovery**: Auto-import pattern finds all implementations
- **Type-safe**: Preserves original class type

## Implementation Details

1. Decorator returns the class unchanged (for immediate use)
2. Side effect: adds class to factory dict
3. Name parameter must be unique per module
4. Registration happens at module import time

## Advanced Patterns

### Registration with Config

```python
def register_model(name: str):
    def decorator(cls):
        MODEL_FACTORY[name] = cls
        # Add config validation
        cls._config_schema = getattr(cls, '_config_schema', {})
        return cls
    return decorator
```

### Conditional Registration

```python
def register_dataset(name: str, experimental: bool = False):
    def decorator(cls):
        if not experimental or cfg.enable_experimental:
            DATASET_FACTORY[name] = cls
        return cls
    return decorator
```

### Multi-Registry

```python
# Multiple registries in one module
DATASET_FACTORY = {}
AUGMENTATION_FACTORY = {}

def register_dataset(name: str):
    def decorator(cls):
        DATASET_FACTORY[name] = cls
        return cls
    return decorator

def register_augmentation(name: str):
    def decorator(fn):
        AUGMENTATION_FACTORY[name] = fn
        return fn
    return decorator
```

## Best Practices

- **Unique names**: Use descriptive, unique registration names
- **Documentation**: Document required parameters in class docstring
- **Validation**: Validate config in `__init__`, not in decorator
- **Consistency**: Use same naming convention across modules
