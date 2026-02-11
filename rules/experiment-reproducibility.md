# Experiment Reproducibility

## Random Seed Management

Always set random seeds for reproducibility:

```python
import random
import numpy as np
import torch
import os

def set_seed(seed: int = 42) -> None:
    """Set random seeds for reproducibility."""
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    os.environ["PYTHONHASHSEED"] = str(seed)
    # For deterministic behavior (may impact performance)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
```

## Configuration Recording

### Hydra Auto-Save

Hydra automatically saves configs to `outputs/` directory:

```
outputs/
└── 2024-01-15/
    └── 14-30-00/
        ├── .hydra/
        │   ├── config.yaml        # Resolved config
        │   ├── hydra.yaml         # Hydra config
        │   └── overrides.yaml     # CLI overrides
        └── main.log
```

### Manual Config Logging

```python
import json
import logging

logger = logging.getLogger(__name__)

def log_config(cfg) -> None:
    """Log experiment configuration."""
    logger.info(f"Config:\n{json.dumps(cfg, indent=2, default=str)}")
```

## Environment Recording

Record environment info at experiment start:

```python
def log_environment() -> dict:
    """Record environment information for reproducibility."""
    import platform
    env_info = {
        "python_version": platform.python_version(),
        "torch_version": torch.__version__,
        "cuda_version": torch.version.cuda,
        "gpu_model": torch.cuda.get_device_name(0) if torch.cuda.is_available() else "N/A",
        "gpu_count": torch.cuda.device_count(),
    }
    return env_info
```

Save `pip freeze` output alongside experiment results:

```bash
pip freeze > outputs/${EXPERIMENT_NAME}/requirements.txt
```

## Output Directory Naming

Use consistent naming: `{experiment}_{timestamp}`

```
outputs/
├── baseline_20240115_143000/
├── ablation_no_aug_20240116_091500/
└── final_model_20240120_160000/
```

## Checkpoint Management

### Save Strategy

- Save best model (by validation metric)
- Save last N checkpoints for recovery
- Include optimizer state for training resumption

### Naming Convention

```
checkpoints/
├── best_model.pt
├── checkpoint_epoch_10.pt
├── checkpoint_epoch_20.pt
└── checkpoint_latest.pt
```

### Checkpoint Content

```python
torch.save({
    "epoch": epoch,
    "model_state_dict": model.state_dict(),
    "optimizer_state_dict": optimizer.state_dict(),
    "scheduler_state_dict": scheduler.state_dict(),
    "best_metric": best_metric,
    "config": cfg,
}, checkpoint_path)
```

## Dataset Version Tracking

- Record dataset hash or version tag in experiment logs
- Use DVC or similar tools for large dataset versioning
- Document any preprocessing steps applied

```python
import hashlib

def get_dataset_hash(file_path: str) -> str:
    """Compute SHA256 hash of dataset file."""
    sha256 = hashlib.sha256()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            sha256.update(chunk)
    return sha256.hexdigest()[:12]
```
