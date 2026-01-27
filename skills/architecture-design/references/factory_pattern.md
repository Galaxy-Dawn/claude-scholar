# Factory Pattern

## Overview

The Factory pattern allows dynamic creation of instances without specifying the exact class. Each module uses a factory to decouple creation from usage.

## Structure

```python
# In module __init__.py (e.g., data_module/dataset/__init__.py)
DATASET_FACTORY: Dict[str, type] = {}

def DatasetFactory(data_name: str):
    """Create dataset instance by name."""
    dataset = DATASET_FACTORY.get(data_name, None)
    if dataset is None:
        # Fallback to default
        dataset = DATASET_FACTORY.get('simple')
    return dataset
```

## Usage

```python
# Consumer code doesn't need to know concrete class
dataset = DatasetFactory(cfg.dataset.name)
```

## Benefits

- **Loose coupling**: Consumer doesn't import concrete classes
- **Extensibility**: Add new types without changing consumer code
- **Fallback handling**: Graceful degradation for unknown types
- **Centralized registry**: Single source of truth for available types

## Implementation Details

1. Define factory dict at module level
2. Factory function handles lookup and fallback
3. Return class (not instance) for deferred initialization
4. None result triggers fallback to default implementation

## Common Patterns

```python
# With config integration
def DatasetFactory(cfg):
    data_name = cfg.dataset.name
    dataset_cls = DATASET_FACTORY.get(data_name)
    if dataset_cls is None:
        raise ValueError(f"Unknown dataset: {data_name}")
    return dataset_cls(cfg)
```
