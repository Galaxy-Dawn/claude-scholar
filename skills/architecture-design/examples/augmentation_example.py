"""
Data Augmentation Example

Demonstrates how to create a custom data augmentation function
following the architecture design pattern.
"""

import torch
from typing import Dict
from src.data_module.augmentation import register_augmentation


@register_augmentation("time_shift")
def time_shift(signal: torch.Tensor, max_shift: int = 10) -> torch.Tensor:
    """Randomly shift signal in time.

    Args:
        signal: Input signal tensor of shape (channels, time_steps)
        max_shift: Maximum number of steps to shift

    Returns:
        Shifted signal tensor
    """
    shift = torch.randint(-max_shift, max_shift + 1, (1,)).item()
    return torch.roll(signal, shifts=shift, dims=-1)


@register_augmentation("amplitude_scale")
def amplitude_scale(
    signal: torch.Tensor,
    min_scale: float = 0.8,
    max_scale: float = 1.2
) -> torch.Tensor:
    """Randomly scale signal amplitude.

    Args:
        signal: Input signal tensor of shape (channels, time_steps)
        min_scale: Minimum scaling factor
        max_scale: Maximum scaling factor

    Returns:
        Scaled signal tensor
    """
    scale = torch.empty(1).uniform_(min_scale, max_scale).item()
    return signal * scale


@register_augmentation("gaussian_noise")
def add_gaussian_noise(
    signal: torch.Tensor,
    mean: float = 0.0,
    std: float = 0.1
) -> torch.Tensor:
    """Add Gaussian noise to signal.

    Args:
        signal: Input signal tensor of shape (channels, time_steps)
        mean: Mean of Gaussian noise
        std: Standard deviation of Gaussian noise

    Returns:
        Signal with added noise
    """
    noise = torch.randn_like(signal) * std + mean
    return signal + noise


# Example: Composed augmentation
@register_augmentation("composed")
def composed_augmentation(signal: torch.Tensor, cfg) -> torch.Tensor:
    """Apply multiple augmentations in sequence.

    Args:
        signal: Input signal tensor
        cfg: Configuration object with augmentation parameters

    Returns:
        Augmented signal tensor
    """
    # Apply each augmentation based on config
    if cfg.augmentation.time_shift:
        signal = time_shift(signal, cfg.augmentation.max_shift)

    if cfg.augmentation.amplitude_scale:
        signal = amplitude_scale(
            signal,
            cfg.augmentation.min_scale,
            cfg.augmentation.max_scale
        )

    if cfg.augmentation.gaussian_noise:
        signal = add_gaussian_noise(
            signal,
            cfg.augmentation.noise_mean,
            cfg.augmentation.noise_std
        )

    return signal


# Usage in dataset class
class AugmentedDataset:
    """Example dataset with augmentation support."""

    def __init__(self, cfg):
        self.cfg = cfg
        self.augmentation_fn = AugmentationFactory(cfg.augmentation.name)

    def __getitem__(self, idx: int) -> Dict[str, torch.Tensor]:
        # Load signal
        signal = self.load_signal(idx)

        # Apply augmentation (training mode only)
        if self.training and self.augmentation_fn:
            signal = self.augmentation_fn(signal, self.cfg)

        return {"signal": signal, "label": self.labels[idx]}
