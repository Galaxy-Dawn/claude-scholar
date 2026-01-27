# Auto-Import Pattern

## Overview

The Auto-Import pattern automatically discovers and imports all submodules in a directory, ensuring all components are registered without manual imports.

## Structure

```python
# In module __init__.py (e.g., data_module/dataset/__init__.py)
import os
from src.utils.helpers import import_modules

models_dir = os.path.dirname(__file__)
import_modules(models_dir, "src.data_module.dataset")
```

## Helper Function

```python
# In src/utils/helpers.py
import os
import importlib
import pkgutil
from typing import List

def import_modules(models_dir: str, package_name: str) -> List[str]:
    """
    Import all Python modules in a directory.

    Args:
        models_dir: Directory path to scan
        package_name: Full package name for imports

    Returns:
        List of imported module names
    """
    imported = []
    for module_loader, name, ispkg in pkgutil.iter_modules([models_dir]):
        if not name.startswith('_'):
            full_name = f"{package_name}.{name}"
            importlib.import_module(full_name)
            imported.append(name)
    return imported
```

## Benefits

- **Zero maintenance**: Adding new file = auto-registration
- **No遗漏**: Cannot forget to import new component
- **Consistent**: All components follow same discovery path
- **Scalable**: Works for any number of submodules

## Implementation Details

1. Scan directory for `.py` files
2. Skip files starting with `_` (private)
3. Import each module using full package path
4. Import triggers decorator registration

## Directory Structure Example

```
dataset/
├── __init__.py          # Contains import_modules() call
├── simple_dataset.py    # Auto-imported, registers "simple"
├── custom_dataset.py    # Auto-imported, registers "custom"
└── _private.py          # NOT imported (starts with _)
```

## Best Practices

- **Skip private files**: Files starting with `_` are not imported
- **Full package paths**: Use dot-notation for correct imports
- **Idempotent**: Safe to call multiple times
- **Error handling**: Import errors propagate for debugging

## Common Patterns

### Conditional Import

```python
def import_modules(models_dir: str, package_name: str, skip: List[str] = None):
    skip = skip or []
    for module_loader, name, ispkg in pkgutil.iter_modules([models_dir]):
        if name not in skip and not name.startswith('_'):
            importlib.import_module(f"{package_name}.{name}")
```

### Recursive Import

```python
def import_modules_recursive(models_dir: str, package_name: str):
    """Import modules and subpackages recursively."""
    for importer, name, ispkg in pkgutil.walk_packages([models_dir], prefix=f"{package_name}."):
        if not name.split('.')[-1].startswith('_'):
            importlib.import_module(name)
```

### Dry-Run Mode

```python
def import_modules(models_dir: str, package_name: str, dry_run: bool = False):
    if dry_run:
        return [name for _, name, _ in pkgutil.iter_modules([models_dir])
                if not name.startswith('_')]
    # ... actual import logic
```

## Integration with Registry

The auto-import pattern is typically used WITH registry pattern:

1. **Import time**: `import_modules()` imports all files
2. **Decorator execution**: `@register_dataset()` runs
3. **Factory population**: `DATASET_FACTORY` dict populated
4. **Runtime**: `DatasetFactory()` looks up registered classes
