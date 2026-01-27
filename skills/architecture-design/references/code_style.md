# Code Style Guidelines

## Type Annotations

Always use type hints for function signatures and class attributes:

```python
from typing import Dict, List, Optional, Tuple
import torch

def __getitem__(self, i: int) -> Dict[str, torch.Tensor]:
    """Get item by index."""
    return self.data[i]

def compute_metrics(predictions: torch.Tensor, labels: torch.Tensor) -> Dict[str, float]:
    """Compute evaluation metrics."""
    pass

class MyModel(nn.Module):
    hidden_dim: int  # Class attribute type hints
    output_dim: int

    def __init__(self, cfg):
        self.hidden_dim: int = cfg.model.hidden_dim
        self.output_dim: int = cfg.model.output_dim
```

## Import Order

Organize imports in three sections with blank lines between:

```python
# 1. Standard library imports
import os
from typing import Dict, List, Optional
from pathlib import Path

# 2. Third-party imports
import torch
import torch.nn as nn
from torch.utils.data import Dataset
import numpy as np

# 3. Local imports
from src.data_module.dataset import register_dataset
from src.utils.helpers import import_modules
from src.model_module.brain_decoder import register_model
```

## __init__.py Files

### Module __init__.py (with factory)

Contains factory/registry logic and auto-import:

```python
# src/data_module/dataset/__init__.py
import os
from typing import Dict, Callable, TypeVar
from src.utils.helpers import import_modules

T = TypeVar('T')

DATASET_FACTORY: Dict[str, type] = {}

def register_dataset(name: str) -> Callable[[T], T]:
    """Decorator to register dataset classes."""
    def decorator(cls: T) -> T:
        DATASET_FACTORY[name] = cls
        return cls
    return decorator

def DatasetFactory(data_name: str):
    """Create dataset instance by name."""
    dataset = DATASET_FACTORY.get(data_name, None)
    if dataset is None:
        dataset = DATASET_FACTORY.get('simple')
    return dataset

# Auto-import all submodules
models_dir = os.path.dirname(__file__)
import_modules(models_dir, "src.data_module.dataset")
```

### Subpackage __init__.py (can be empty)

```python
# src/data_module/augmentation/__init__.py
# Empty file - just marks as package
```

Or with exports:

```python
# src/data_module/__init__.py
from .dataset import DatasetFactory, register_dataset
from .augmentation import AugmentationFactory
```

## Naming Conventions

### Files

- **Modules**: `simple_dataset.py`, `custom_model.py`
- **Pipelines**: `training.sh`, `inference.sh`
- **Configs**: `config.yaml`, `brain_decoder.yaml`
- **Utilities**: `get_optimizer.py`, `helpers.py`, `compute_metrics.py`

### Classes and Functions

```python
# Classes: PascalCase
class SimpleDataset(Dataset):
    pass

class MyCustomModel(nn.Module):
    pass

# Functions and variables: snake_case
def compute_accuracy(predictions, labels):
    pass

def get_optimizer(cfg):
    pass

learning_rate = 0.001
batch_size = 32
```

### Constants

```python
# Constants: UPPER_SNAKE_CASE
DEFAULT_HIDDEN_DIM = 256
MAX_EPOCHS = 100
LEARNING_RATE = 0.001
```

## Docstrings

Use Google-style docstrings:

```python
def DatasetFactory(data_name: str) -> type:
    """Create dataset class by name.

    Args:
        data_name: Name of the dataset to create.

    Returns:
        Dataset class if found, otherwise simple dataset.

    Raises:
        ValueError: If no dataset is found and no default exists.
    """
    pass
```

## Configuration-Driven Classes

Model classes must be config-driven:

```python
@register_model('MyModel')
class MyModel(nn.Module):
    def __init__(self, cfg):
        """Initialize model from config.

        Args:
            cfg: Hydra config object with model attributes.
        """
        super().__init__()
        self.cfg = cfg

        # ALL parameters from cfg
        self.hidden_dim = cfg.model.hidden_dim
        self.output_dim = cfg.dataset.target_size[cfg.dataset.task]
        self.dropout = cfg.model.dropout

    def forward(self, x, labels=None, **kwargs):
        """Forward pass.

        Args:
            x: Input tensor.
            labels: Ground truth labels (training mode).
            **kwargs: Additional arguments.

        Returns:
            Dict with loss, labels, and logits.
        """
        # Implementation
        return {"loss": loss, "labels": labels, "logits": logits}
```

## Error Handling

```python
def DatasetFactory(data_name: str) -> type:
    """Create dataset class by name."""
    dataset = DATASET_FACTORY.get(data_name)
    if dataset is None:
        available = ', '.join(DATASET_FACTORY.keys())
        raise ValueError(
            f"Dataset '{data_name}' not found. "
            f"Available: {available}"
        )
    return dataset
```

## Logging

```python
import logging

logger = logging.getLogger(__name__)

@register_dataset('custom')
class CustomDataset(Dataset):
    def __init__(self, cfg):
        self.cfg = cfg
        logger.info(f"Initializing {self.__class__.__name__}")
        logger.debug(f"Config: {cfg.dataset}")
```

## Code Review Checklist

- [ ] All functions have type hints
- [ ] Imports are correctly ordered
- [ ] Classes use PascalCase, functions use snake_case
- [ ] Docstrings follow Google style
- [ ] Model classes are config-driven
- [ ] Registration decorators are used
- [ ] Error messages are informative
- [ ] Logging is added for key operations
