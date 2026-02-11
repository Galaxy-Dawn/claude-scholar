---
name: architecture-design
description: |
  Use ONLY when creating NEW registrable components in ML projects that require Factory/Registry patterns.

  ✅ USE when:
  - Creating a new Dataset class (needs @register_dataset)
  - Creating a new Model class (needs @register_model)
  - Creating a new module directory with __init__.py factory
  - Initializing a new ML project structure from scratch
  - Adding new component types (Augmentation, CollateFunction, Metrics)

  ❌ DO NOT USE when:
  - Modifying existing functions or methods
  - Fixing bugs in existing code
  - Adding helper functions or utilities
  - Refactoring without adding new registrable components
  - Simple code changes to a single file
  - Modifying configuration files
  - Reading or understanding existing code

  Key indicator: Does the task require @register_* decorator or Factory pattern? If no, skip this skill.
version: 1.2.0
---

# Architecture Design - ML Project Template

This skill defines the standard code architecture for machine learning projects based on the template structure. When modifying or extending code, follow these patterns to maintain consistency.

## Overview

The project follows a modular, extensible architecture with clear separation of concerns. Each module (data, model, trainer, analysis) is independently organized using factory and registry patterns for maximum flexibility.

## Core Design Patterns

### Factory Pattern

Each module uses a factory to create instances dynamically:

```python
# Example from data_module/dataset/__init__.py
DATASET_FACTORY: Dict = {}

def DatasetFactory(data_name: str):
    dataset = DATASET_FACTORY.get(data_name, None)
    if dataset is None:
        print(f"{data_name} dataset is not implementation, use simple dataset")
        dataset = DATASET_FACTORY.get('simple')
    return dataset
```

For detailed guidance, refer to `references/factory_pattern.md`.

### Registry Pattern

Components register themselves via decorators:

```python
# Example from data_module/dataset/simple_dataset.py
@register_dataset("simple")
class SimpleDataset(Dataset):
    def __init__(self, data):
        self.data = data
```

For detailed guidance, refer to `references/registry_pattern.md`.

### Auto-Import Pattern

Modules automatically discover and import submodules:

```python
# Example from data_module/dataset/__init__.py
models_dir = os.path.dirname(__file__)
import_modules(models_dir, "src.data_module.dataset")
```

For detailed guidance, refer to `references/auto_import.md`.

## Directory Structure

```
project/
├── run/
│   ├── pipeline/            # Main workflow scripts
│   │   ├── training/        # Training pipelines
│   │   ├── prepare_data/    # Data preparation pipelines
│   │   └── analysis/        # Analysis pipelines
│   └── conf/                # Hydra configuration files
│       ├── training/        # Training configs
│       ├── dataset/         # Dataset configs
│       ├── model/           # Model configs
│       ├── prepare_data/    # Data prep configs
│       └── analysis/        # Analysis configs
│
├── src/
│   ├── data_module/         # Data processing module
│   │   ├── dataset/         # Dataset implementations
│   │   ├── augmentation/    # Data augmentation
│   │   ├── collate_fn/      # Collate functions
│   │   ├── compute_metrics/ # Metrics computation
│   │   ├── prepare_data/    # Data preparation logic
│   │   ├── data_func/       # Data utility functions
│   │   └── utils.py         # Module-specific utilities
│   │
│   ├── model_module/        # Model implementations
│   │   ├── brain_decoder/   # Brain decoder models
│   │   └── model/           # Alternative model location
│   │
│   ├── trainer_module/      # Training logic
│   ├── analysis_module/     # Analysis and evaluation
│   ├── llm/                 # LLM-related code
│   └── utils/               # Shared utilities
│
├── data/
│   ├── raw/                 # Original, immutable data
│   ├── processed/           # Cleaned, transformed data
│   └── external/            # Third-party data
│
├── outputs/
│   ├── logs/                # Training and evaluation logs
│   ├── checkpoints/         # Model checkpoints
│   ├── tables/              # Result tables
│   └── figures/             # Plots and visualizations
│
├── pyproject.toml           # Project configuration
├── uv.lock                  # Dependency lock file
├── TODO.md                  # Task tracking
├── README.md                # Project documentation
└── .gitignore               # Git ignore rules
```

For detailed directory structure with file descriptions, refer to `references/structure.md`.

## Module Organization

### Creating a New Dataset

When adding a new dataset:

1. Create file in `src/data_module/dataset/`
2. Use `@register_dataset("name")` decorator
3. Inherit from `torch.utils.data.Dataset`
4. Implement `__init__`, `__len__`, `__getitem__`

```python
from torch.utils.data import Dataset
from typing import Dict
import torch
from src.data_module.dataset import register_dataset

@register_dataset("custom")
class CustomDataset(Dataset):
    def __init__(self, data):
        self.data = data

    def __len__(self):
        return len(self.data)

    def __getitem__(self, i: int) -> Dict[str, torch.Tensor]:
        return self.data[i]
```

### Creating a New Model

**CRITICAL: Models use config-driven pattern**

When adding a new model:

1. Create file in `src/model_module/model/` or appropriate module subdirectory
2. Use `@register_model('ModelName')` decorator
3. `__init__` accepts **ONLY** `cfg` parameter - all hyperparameters come from config
4. `forward()` returns dict: `{"loss": loss, "labels": labels, "logits": logits}`
5. Handle training vs inference modes using `self.training`

```python
from src.model_module.brain_decoder import register_model

@register_model('MyModel')
class MyModel(nn.Module):
    def __init__(self, cfg):
        super().__init__()
        self.cfg = cfg
        self.task = cfg.dataset.task

        # ALL parameters from cfg
        self.hidden_dim = cfg.model.hidden_dim
        self.output_dim = cfg.dataset.target_size[cfg.dataset.task]

    def forward(self, x, labels=None, **kwargs):
        if self.training:
            # Training logic
            pass
        else:
            # Inference logic
            pass

        return {"loss": loss, "labels": labels, "logits": logits}
```

### Adding Data Augmentation

When adding augmentation:

1. Create file in `src/data_module/augmentation/`
2. Implement transformation function
3. Register with factory if needed

## Code Style Guidelines

For comprehensive style guidelines, refer to `references/code_style.md`.

**Key principles:**
- Always use type hints for function signatures
- Follow import order: standard library → third-party → local
- Module `__init__.py` files contain factory/registry logic
- Model classes must be config-driven

## Configuration Management

The project uses Hydra for configuration management:

- Config files in `run/conf/` organize by module
- Each stage (training, analysis) has its own config structure
- Use YAML files for all configuration

## When Working on This Project

### Before Modifying Code

1. Read the relevant module's factory/registry pattern
2. Check existing implementations for consistency
3. Follow the established directory structure
4. Use registration decorators for new components

### Adding New Features

1. Determine which module the feature belongs to
2. Check if similar functionality exists
3. Follow factory/registry pattern if creating new component types
4. Add configuration files if needed
5. Update documentation

### Code Review Checklist

- [ ] Uses factory/registry pattern appropriately
- [ ] Follows module directory structure
- [ ] Has proper type annotations
- [ ] Imports are correctly ordered
- [ ] Registration decorator is used
- [ ] Configuration files are added if needed

## Additional Resources

### Reference Files

For detailed information, consult:
- **`references/structure.md`** - Detailed directory structure with file descriptions
- **`references/factory_pattern.md`** - Factory pattern in-depth explanation
- **`references/registry_pattern.md`** - Registry pattern in-depth explanation
- **`references/auto_import.md`** - Auto-import pattern in-depth explanation
- **`references/code_style.md`** - Comprehensive code style guidelines

### Example Files

Working examples in `examples/`:
- **`examples/custom_dataset.py`** - Custom dataset implementation
- **`examples/custom_model.py`** - Custom model implementation
- **`examples/augmentation_example.py`** - Data augmentation example
- **`examples/config_example.yaml`** - Configuration file example
- **`examples/pipeline_example.sh`** - Pipeline script example
