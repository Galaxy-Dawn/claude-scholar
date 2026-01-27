"""
Example: Creating a Custom Model

This example shows how to add a new model following the project architecture.
IMPORTANT: Models use a config-driven pattern where __init__ only accepts cfg.

Key Requirements:
- Use @register_model('ModelName') decorator
- __init__ accepts ONLY cfg parameter
- All hyperparameters come from cfg (cfg.model.*, cfg.dataset.*, etc.)
- forward() returns dict: {"loss": loss, "labels": labels, "logits": logits}
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
from typing import Dict, Optional

# Import the register_model decorator
# Location may vary: src.model_module.brain_decoder or src.model_module.model
from src.model_module.brain_decoder import register_model


@register_model('SimpleMLP')
class SimpleMLP(nn.Module):
    """
    Simple Multi-Layer Perceptron for classification tasks.

    Config structure ( Hydra YAML ):
        model:
            input_dim: 100
            hidden_dim: 256
            output_dim: 10
            num_layers: 3
            dropout: 0.1
        dataset:
            task: classification  # Used to get target_size
            target_size:
                classification: 10
    """

    def __init__(self, cfg):
        super().__init__()

        # Store config
        self.cfg = cfg

        # Get task info from config
        self.task = cfg.dataset.task

        # Build model - ALL parameters from cfg
        self.input_dim = cfg.model.input_dim
        self.hidden_dim = cfg.model.get('hidden_dim', 256)
        self.output_dim = cfg.dataset.target_size[cfg.dataset.task]
        self.num_layers = cfg.model.get('num_layers', 3)
        self.dropout = cfg.model.get('dropout', 0.1)

        # Build layers
        layers = []
        in_dim = self.input_dim

        for i in range(self.num_layers):
            layers.extend([
                nn.Linear(in_dim, self.hidden_dim),
                nn.ReLU(),
                nn.Dropout(self.dropout)
            ])
            in_dim = self.hidden_dim

        # Output layer
        layers.append(nn.Linear(self.hidden_dim, self.output_dim))
        self.network = nn.Sequential(*layers)

        # Loss function
        self.loss_fn = nn.CrossEntropyLoss()

    def forward(
        self,
        x: torch.Tensor,
        labels: Optional[torch.Tensor] = None,
        **kwargs
    ) -> Dict[str, Optional[torch.Tensor]]:
        """
        Forward pass.

        Args:
            x: Input tensor of shape (batch_size, input_dim)
            labels: Ground truth labels (optional, for training)

        Returns:
            Dictionary with:
                - loss: Computed loss (None if labels not provided)
                - labels: Ground truth labels
                - logits: Model predictions
        """
        logits = self.network(x)

        loss = None
        if labels is not None:
            # Convert labels to long type if needed
            if labels.dtype != torch.long:
                labels = labels.long()
            loss = self.loss_fn(logits, labels)

        return {
            "loss": loss,
            "labels": labels,
            "logits": logits
        }


# ============================================
# Example with Training/Inference Modes
# ============================================

@register_model('SimpleMLPWithModes')
class SimpleMLPWithModes(nn.Module):
    """
    MLP with separate training and inference logic.
    Shows how to handle different modes using self.training.
    """

    def __init__(self, cfg):
        super().__init__()
        self.cfg = cfg
        self.task = cfg.dataset.task

        self.input_dim = cfg.model.input_dim
        self.hidden_dim = cfg.model.get('hidden_dim', 256)
        self.output_dim = cfg.dataset.target_size[cfg.dataset.task]

        self.fc_in = nn.Linear(self.input_dim, self.hidden_dim)
        self.ln = nn.LayerNorm(self.hidden_dim)
        self.fc_out = nn.Linear(self.hidden_dim, self.output_dim)
        self.loss_fn = nn.CrossEntropyLoss()

        # Test-time augmentation config
        self.tta_times = cfg.model.get('tta_times', 1)

    def forward(
        self,
        x: torch.Tensor,
        labels: Optional[torch.Tensor] = None,
        **kwargs
    ) -> Dict[str, Optional[torch.Tensor]]:
        """
        Forward pass with training/inference modes.
        """
        if self.training:
            # Training mode
            x = x.float()
            x = self.fc_in(x)
            x = self.ln(x)
            x = F.relu(x)
            logits = self.fc_out(x)

            loss = None
            if labels is not None:
                if labels.dtype != torch.long:
                    labels = labels.long()
                loss = self.loss_fn(logits, labels)

            return {
                "loss": loss,
                "labels": labels,
                "logits": logits
            }
        else:
            # Inference mode with TTA
            all_logits = []
            with torch.no_grad():
                x = x.float()
                for _ in range(self.tta_times):
                    x_aug = x.clone()
                    # Apply TTA transformations here if needed

                    x_aug = self.fc_in(x_aug)
                    x_aug = self.ln(x_aug)
                    x_aug = F.relu(x_aug)
                    logits = self.fc_out(x_aug)
                    all_logits.append(logits)

            # Average predictions
            avg_logits = torch.mean(torch.stack(all_logits), dim=0)

            loss = None
            if labels is not None:
                if labels.dtype != torch.long:
                    labels = labels.long()
                loss = self.loss_fn(avg_logits, labels)

            return {
                "loss": loss,
                "labels": labels,
                "logits": avg_logits
            }


# ============================================
# Config Example (Hydra YAML)
# ============================================
"""
# run/conf/model/simple_mlp.yaml

model:
  name: SimpleMLP
  input_dim: 100
  hidden_dim: 256
  output_dim: 10
  num_layers: 3
  dropout: 0.1
  tta_times: 1

# Then in training pipeline:
# from src.model_module.brain_decoder import ModelFactory
# model = ModelFactory(cfg.model.name)(cfg)
"""
