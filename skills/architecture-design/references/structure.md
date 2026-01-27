# Detailed Directory Structure

This document provides a comprehensive breakdown of the ML project template directory structure.

## Root Level Files

| File | Purpose |
|------|---------|
| `README.md` | Project documentation, installation guide, usage examples |
| `TODO.md` | Task tracking with weekly focus and daily tasks |
| `.gitignore` | Git ignore patterns for Python, Jupyter, IDEs, logs, cache |
| `pyproject.toml` | Project configuration for build system and dependencies |
| `uv.lock` | Locked dependency versions for reproducibility |

## run/ - Execution Layer

### pipeline/

Main workflow scripts organized by stage:

| Directory | Purpose |
|-----------|---------|
| `training/` | Training execution scripts (training.sh, inference.sh) |
| `prepare_data/` | Data preparation and preprocessing pipelines |
| `analysis/` | Evaluation and analysis workflows |

### conf/

Hydra configuration files organized by module:

| Directory | Purpose |
|-----------|---------|
| `training/` | Training hyperparameters, model configs, optimizer settings |
| `dataset/` | Dataset configurations, data paths, preprocessing options |
| `model/` | Model architecture configurations |
| `prepare_data/` | Data preparation parameters |
| `analysis/` | Analysis and evaluation configurations |
| `dir/` | Directory path configurations |
| `analysis/` | Analysis-specific settings |

## src/ - Source Code Layer

### data_module/ - Data Processing Module

```
data_module/
├── __init__.py              # Module exports
├── utils.py                 # Data-specific utility functions
├── dataset/                 # Dataset implementations
│   ├── __init__.py          # Dataset factory and registry
│   └── simple_dataset.py    # Simple dataset example
├── augmentation/            # Data augmentation methods
│   ├── __init__.py
│   ├── mixup.py            # Mixup augmentation
│   ├── random_shift.py     # Random shifting
│   ├── channel_mask.py     # Channel masking
│   ├── time_masking.py     # Time masking
│   └── add_noise.py        # Noise injection
├── collate_fn/             # Batch collation functions
│   ├── __init__.py
│   └── simple_collate_fn.py
├── compute_metrics/        # Metrics computation
│   ├── __init__.py
│   └── simple_compute_metrics.py
├── prepare_data/           # Data preparation logic
│   ├── __init__.py
│   ├── prepare_data.py
│   └── generate_yaml.py
└── data_func/              # Data utility functions
    ├── __init__.py
    └── simple_data_func.py
```

### model_module/ - Model Module

```
model_module/
├── __init__.py             # Module exports
└── model/                  # Model implementations
    └── [model files]
```

### trainer_module/ - Training Module

Contains training loop logic, validation, and checkpoint management.

### analysis_module/ - Analysis Module

Contains evaluation, visualization, and result analysis code.

### llm/ - LLM Module

LLM-related code and integrations.

### utils/ - Shared Utilities

```
utils/
├── __init__.py
├── helpers.py              # Helper functions (import_modules, etc.)
├── logging.py              # Logging configuration
├── get_optimizer.py        # Optimizer factory
├── get_scheduler.py        # Learning rate scheduler factory
├── get_callback.py         # Training callbacks
├── get_activation.py       # Activation functions
└── get_checkpoint_aggregation.py  # Checkpoint handling
```

## data/ - Data Layer

Following the Cookiecutter Data Science standard:

| Directory | Purpose |
|-----------|---------|
| `raw/` | Original, immutable data dump |
| `processed/` | Cleaned, transformed data ready for use |
| `external/` | Data from third-party sources |

## outputs/ - Output Layer

| Directory | Purpose |
|-----------|---------|
| `logs/` | Training logs, tensorboard logs |
| `checkpoints/` | Model checkpoints for resuming training |
| `tables/` | Result tables, CSV outputs |
| `figures/` | Plots, visualizations, figures |

## Module Interaction Flow

```
run/pipeline/    ->  src/trainer_module/  ->  src/model_module/
                     src/data_module/         src/utils/
                     src/utils/

run/conf/        ->  Hydra config loader  ->  All modules
```

## File Naming Conventions

- **Modules**: `simple_dataset.py`, `custom_model.py`
- **Pipelines**: `training.sh`, `inference.sh`
- **Configs**: `config.yaml`, dataset-specific names
- **Utilities**: Descriptive names (`get_optimizer.py`, `helpers.py`)

## Python Package Structure

Each module is a proper Python package:
- Has `__init__.py` with factory/registry logic
- Can be imported as `from src.module import Component`
- Subpackages are automatically discovered via `import_modules()`
