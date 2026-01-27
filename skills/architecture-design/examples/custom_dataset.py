"""
Example: Creating a Custom Dataset

This example shows how to add a new dataset following the project architecture.
"""

from torch.utils.data import Dataset
from typing import Dict
import torch
from src.data_module.dataset import register_dataset


@register_dataset("time_series")
class TimeSeriesDataset(Dataset):
    """
    Time series dataset for sequence modeling.

    Args:
        sequences: List of time series sequences
        seq_length: Fixed sequence length (pad or truncate if needed)
    """

    def __init__(self, sequences: list, seq_length: int = 100):
        self.sequences = sequences
        self.seq_length = seq_length

    def __len__(self) -> int:
        return len(self.sequences)

    def __getitem__(self, i: int) -> Dict[str, torch.Tensor]:
        sequence = self.sequences[i]

        # Pad or truncate to fixed length
        if len(sequence) < self.seq_length:
            padding = torch.zeros(self.seq_length - len(sequence))
            sequence = torch.cat([sequence, padding])
        else:
            sequence = sequence[:self.seq_length]

        return {
            "input": sequence,
            "label": sequence,  # For autoencoder, etc.
            "length": torch.tensor(min(len(self.sequences[i]), self.seq_length))
        }


# Usage in training:
# from src.data_module.dataset import DatasetFactory
# dataset = DatasetFactory("time_series")(sequences=training_data, seq_length=128)
# dataloader = DataLoader(dataset, batch_size=32, shuffle=True)
