# BirdCLEF\+ 2025
> Last updated: 2026-01-23
> Source count: 1
---

### Mel-Spectrogram 特征提取（BirdCLEF+ 2025）

基于前排方案，统一的 mel-spectrogram 提取流程：

```python
import torch
import torchaudio
import torch.nn as nn
import numpy as np

class MelSpectrogramExtractor:
    """统一的 Mel-Spectrogram 提取器"""

    def __init__(
        self,
        sample_rate: int = 32000,
        n_mels: int = 128,
        n_fft: int = 2048,
        hop_length: int = 512,
        fmin: float = 0.0,
        fmax: float = 16000.0,
        power: float = 2.0,
        normalize: bool = True,
    ):
        self.sample_rate = sample_rate
        self.n_mels = n_mels
        self.n_fft = n_fft
        self.hop_length = hop_length
        self.fmin = fmin
        self.fmax = fmax

        # 使用 torchaudio 的 MelSpectrogram
        self.mel_transform = torchaudio.transforms.MelSpectrogram(
            sample_rate=sample_rate,
            n_fft=n_fft,
            hop_length=hop_length,
            n_mels=n_mels,
            f_min=fmin,
            f_max=fmax,
            power=power,
            normalized=normalize,
        )

    def extract(self, waveform: torch.Tensor) -> torch.Tensor:
        """
        提取 mel-spectrogram

        Args:
            waveform: (num_samples,) 或 (batch, num_samples)

        Returns:
            mel_spec: (n_mels, time) 或 (batch, n_mels, time)
        """
        if waveform.dim() == 1:
            waveform = waveform.unsqueeze(0)

        mel_spec = self.mel_transform(waveform)

        # 转换为对数尺度
        mel_spec = torch.log(mel_spec + 1e-9)

        return mel_spec

    def extract_fixed_length(
        self, waveform: torch.Tensor, target_length: int
    ) -> torch.Tensor:
        """
        提取固定长度的 mel-spectrogram（用于 5 秒音频）

        Args:
            waveform: (num_samples,)
            target_length: 目标时间维度

        Returns:
            mel_spec: (n_mels, target_length)
        """
        mel_spec = self.extract(waveform).squeeze(0)

        # 调整到固定长度
        if mel_spec.shape[1] < target_length:
            # 填充
            pad_length = target_length - mel_spec.shape[1]
            mel_spec = nn.functional.pad(mel_spec, (0, pad_length))
        else:
            # 裁剪（从中心）
            start = (mel_spec.shape[1] - target_length) // 2
            mel_spec = mel_spec[:, start:start + target_length]

        return mel_spec


# 常用配置（前排方案）
CONFIGS = {
    "config_128": {  # tf_efficientnet 系列
        "n_mels": 128,
        "n_fft": 2048,
        "hop_length": 512,
        "fmin": 0.0,
        "fmax": 16000.0,
    },
    "config_96": {  # 轻量级模型
        "n_mels": 96,
        "n_fft": 2048,
        "hop_length": 512,
        "fmin": 0.0,
        "fmax": 16000.0,
    },
    "config_256": {  # 高分辨率
        "n_mels": 256,
        "n_fft": 4096,
        "hop_length": 1024,
        "fmin": 0.0,
        "fmax": 16000.0,
    },
}

# 使用示例
extractor = MelSpectrogramExtractor(**CONFIGS["config_128"])
waveform, sr = torchaudio.load("audio.wav")
mel_spec = extractor.extract_fixed_length(waveform.squeeze(0), target_length=313)  # 5秒 -> 313帧
```

### 伪标签生成（BirdCLEF+ 2025）

```python
import torch
import torch.nn as nn
import numpy as np
from pathlib import Path

class PseudoLabelGenerator:
    """伪标签生成器 - 基于前排方案"""

    def __init__(
        self,
        model: nn.Module,
        threshold: float = 0.4,
        use_segmentwise: bool = True,
        power_transform: float = 1.0,
    ):
        """
        Args:
            model: 训练好的模型
            threshold: 置信度阈值（前排方案使用 0.3-0.5）
            use_segmentwise: 是否使用 segmentwise_logit（更细粒度）
            power_transform: 幂次变换参数（1st Place 使用）
        """
        self.model = model
        self.model.eval()
        self.threshold = threshold
        self.use_segmentwise = use_segmentwise
        self.power_transform = power_transform

    @torch.no_grad()
    def generate_pseudo_labels(
        self,
        audio_path: str,
        segment_duration: int = 5,
        overlap: float = 0.5,
    ) -> list[dict]:
        """
        生成伪标签

        Returns:
            List of {"start": float, "end": float, "labels": np.ndarray}
        """
        # 加载音频
        waveform, sr = torchaudio.load(audio_path)

        # 分段处理
        samples_per_segment = int(segment_duration * sr)
        hop_length = int(samples_per_segment * (1 - overlap))

        pseudo_labels = []

        for start_idx in range(0, len(waveform) - samples_per_segment, hop_length):
            end_idx = start_idx + samples_per_segment
            segment = waveform[:, start_idx:end_idx]

            # 提取特征
            mel_spec = self.extract_mel(segment)

            # 模型预测
            if self.use_segmentwise:
                # segmentwise_logit: 更细粒度的预测
                logits = self.model(mel_spec, return_segmentwise=True)
                # 时间维度平均
                logits = logits.mean(dim=1)  # (batch, num_classes)
            else:
                logits = self.model(mel_spec)

            # Sigmoid 激活
            probs = torch.sigmoid(logits).squeeze(0).cpu().numpy()

            # 幂次变换（1st Place 创新）
            if self.power_transform != 1.0:
                probs = np.power(probs, self.power_transform)

            # 高低阈值筛选（10th Place 方法）
            mask = self._apply_threshold(probs)

            if mask.sum() > 0:
                pseudo_labels.append({
                    "start": start_idx / sr,
                    "end": end_idx / sr,
                    "labels": probs,
                    "mask": mask,
                })

        return pseudo_labels

    def _apply_threshold(self, probs: np.ndarray) -> np.ndarray:
        """应用高低阈值筛选"""
        # 高阈值：正样本
        high_threshold = 0.7
        # 低阈值：负样本
        low_threshold = 0.3

        mask = np.zeros_like(probs, dtype=bool)
        mask[probs >= high_threshold] = True  # 高置信度正样本
        mask[probs <= low_threshold] = True   # 低置信度负样本

        return mask

    def extract_mel(self, waveform: torch.Tensor) -> torch.Tensor:
        """提取 mel-spectrogram（简化版本）"""
        # 实际使用中应该与训练时的提取器一致
        pass


# 使用示例（前排方案风格）
generator = PseudoLabelGenerator(
    model=model,
    threshold=0.4,
    use_segmentwise=True,  # 6th Place 关键
    power_transform=1.5,   # 1st Place 幂次变换
)

pseudo_labels = generator.generate_pseudo_labels("train_soundscape_01.wav")
```

### MixUp 数据增强（BirdCLEF+ 2025）

```python
import torch
import torch.nn as nn
import numpy as np

class AudioMixUp:
    """音频 MixUp 增强 - 前排方案风格"""

    def __init__(
        self,
        alpha: float = 0.5,
        mixup_type: str = "hard",  # "hard" 或 "soft"
        probability: float = 0.5,
    ):
        """
        Args:
            alpha: Beta 分布参数
            mixup_type:
                - "soft": 标准混合标签（MixUp）
                - "hard": 硬混合标签（8th Place 创新）
            probability: 应用 MixUp 的概率
        """
        self.alpha = alpha
        self.mixup_type = mixup_type
        self.probability = probability

    def __call__(
        self,
        batch: dict,
    ) -> dict:
        """
        应用 MixUp

        Args:
            batch: {"mel": (B, C, H, W), "labels": (B, num_classes)}

        Returns:
            Mixed batch
        """
        if torch.rand(1).item() > self.probability:
            return batch

        mel = batch["mel"]
        labels = batch["labels"]

        batch_size = mel.size(0)

        # 生成混合权重
        lam = np.random.beta(self.alpha, self.alpha)

        # 随机排列
        index = torch.randperm(batch_size)

        # 混合特征
        mixed_mel = lam * mel + (1 - lam) * mel[index]

        # 混合标签
        if self.mixup_type == "soft":
            # 标准 MixUp: 软标签混合
            mixed_labels = lam * labels + (1 - lam) * labels[index]
        elif self.mixup_type == "hard":
            # 硬 MixUp (8th Place): 混合标签的最大值
            mixed_labels = torch.maximum(labels, labels[index])
        else:
            raise ValueError(f"Unknown mixup_type: {self.mixup_type}")

        return {
            "mel": mixed_mel,
            "labels": mixed_labels,
            "lam": lam,  # 可能用于损失调整
        }


# Sumix 增强（13th Place 使用）
class Sumix:
    """Sumix: 原始信号上的 MixUp"""

    def __init__(self, alpha: float = 0.5, probability: float = 1.0):
        self.alpha = alpha
        self.probability = probability

    def __call__(
        self,
        waveform: torch.Tensor,
        labels: torch.Tensor,
    ) -> tuple[torch.Tensor, torch.Tensor]:
        """
        在原始波形上应用 Sumix

        Args:
            waveform: (batch, num_samples)
            labels: (batch, num_classes)

        Returns:
            Mixed waveform and labels
        """
        if torch.rand(1).item() > self.probability:
            return waveform, labels

        batch_size = waveform.size(0)
        lam = np.random.beta(self.alpha, self.alpha)
        index = torch.randperm(batch_size)

        # 混合波形
        mixed_waveform = lam * waveform + (1 - lam) * waveform[index]

        # 混合标签（最大值）
        mixed_labels = torch.maximum(labels, labels[index])

        return mixed_waveform, mixed_labels


# 使用示例
mixup = AudioMixUp(alpha=0.5, mixup_type="hard", probability=0.5)
sumix = Sumix(alpha=0.5, probability=1.0)

# 训练循环中
for batch in dataloader:
    # Sumix 在原始波形
    waveform, labels = sumix(batch["waveform"], batch["labels"])

    # 提取 mel-spectrogram
    mel = extract_mel(waveform)

    # MixUp 在 mel-spectrogram
    batch = mixup({"mel": mel, "labels": labels})
```

### Soft AUC Loss（BirdCLEF+ 2025 - 4th Place）

支持软标签的 AUC 损失函数：

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class SoftAUCLoss(nn.Module):
    """
    Soft AUC Loss - 4th Place 创新

    支持 soft labels，适用于知识蒸馏和半监督学习
    """

    def __init__(self, reduction: str = "mean"):
        super().__init__()
        self.reduction = reduction

    def forward(
        self,
        predictions: torch.Tensor,
        targets: torch.Tensor,
    ) -> torch.Tensor:
        """
        Args:
            predictions: (batch, num_classes) - 原始 logits
            targets: (batch, num_classes) - 软标签 [0, 1]

        Returns:
            AUC loss
        """
        # Sigmoid 激活
        probs = torch.sigmoid(predictions)

        # 计算 AUC loss
        # 对每个类别独立计算
        num_classes = predictions.size(1)
        losses = []

        for c in range(num_classes):
            # 当前类别的预测和目标
            prob_c = probs[:, c]
            target_c = targets[:, c]

            # 按目标值排序（软标签）
            sorted_indices = torch.argsort(target_c, descending=True)

            # 计算正负样本的得分差异
            # 对于软标签，我们需要加权处理
            positive_scores = prob_c[sorted_indices[:len(sorted_indices)//2]]
            negative_scores = prob_c[sorted_indices[len(sorted_indices)//2:]]

            # AUC 近似：正样本得分应该高于负样本
            # 使用 sigmoid 差异
            diff = positive_scores.unsqueeze(1) - negative_scores.unsqueeze(0)
            loss_c = torch.sigmoid(-diff).mean()

            losses.append(loss_c)

        losses = torch.stack(losses)

        if self.reduction == "mean":
            return losses.mean()
        elif self.reduction == "sum":
            return losses.sum()
        else:
            return losses


# 改进的 AUC Loss（更稳定）
class ImprovedAUCLoss(nn.Module):
    """
    改进的 AUC Loss - 更稳定且支持软标签
    """

    def __init__(self, margin: float = 1.0):
        super().__init__()
        self.margin = margin

    def forward(
        self,
        predictions: torch.Tensor,
        targets: torch.Tensor,
    ) -> torch.Tensor:
        """
        Args:
            predictions: (batch, num_classes)
            targets: (batch, num_classes) - 软标签
        """
        probs = torch.sigmoid(predictions)
        num_classes = predictions.size(1)

        losses = []
        for c in range(num_classes):
            prob_c = probs[:, c]
            target_c = targets[:, c]

            # 计算成对损失
            # 对于每个样本对 (i, j):
            # 如果 target_i > target_j，则希望 prob_i > prob_j
            n = prob_c.size(0)
            if n < 2:
                continue

            # 创建样本对矩阵
            target_diff = target_c.unsqueeze(1) - target_c.unsqueeze(0)
            prob_diff = prob_c.unsqueeze(1) - prob_c.unsqueeze(0)

            # 只考虑 target_i > target_j 的对
            mask = target_diff > 0

            if mask.sum() > 0:
                # Hinge loss: max(0, margin - (prob_i - prob_j))
                loss_c = F.relu(self.margin - prob_diff)[mask].mean()
                losses.append(loss_c)

        if len(losses) == 0:
            return torch.tensor(0.0, device=predictions.device)

        return torch.stack(losses).mean()


# 使用示例
criterion = SoftAUCLoss(reduction="mean")

# 训练循环
for batch in dataloader:
    predictions = model(batch["mel"])

    # 支持软标签
    loss = criterion(predictions, batch["labels"])

    loss.backward()
    optimizer.step()
```

### 滑动窗口推理（BirdCLEF+ 2025 - 1st Place）

```python
import torch
import torch.nn as nn
from scipy.ndimage import gaussian_filter1d

class SlidingWindowInference:
    """
    滑动窗口推理 - 1st Place 创新

    使用帧预测的平均值，而不是仅使用中心窗口的最大值
    """

    def __init__(
        self,
        model: nn.Module,
        window_size: int = 5,  # 秒
        hop_size: int = 5,     # 秒（步长）
        sample_rate: int = 32000,
        smoothing_sigma: float = 1.0,
    ):
        self.model = model
        self.model.eval()
        self.window_size = window_size
        self.hop_size = hop_size
        self.sample_rate = sample_rate
        self.smoothing_sigma = smoothing_sigma

    @torch.no_grad()
    def predict(
        self,
        audio_path: str,
    ) -> dict[str, float]:
        """
        对整个音频进行预测，返回 5 秒窗口的预测

        Returns:
            Dict of {row_id: {species_id: probability}}
        """
        # 加载音频
        waveform, sr = torchaudio.load(audio_path)

        # 计算窗口参数
        samples_per_window = int(self.window_size * sr)
        samples_per_hop = int(self.hop_size * sr)

        # 存储所有帧预测
        all_frame_predictions = []

        # 滑动窗口
        window_id = 0
        for start_idx in range(0, len(waveform) - samples_per_window, samples_per_hop):
            end_idx = start_idx + samples_per_window
            window = waveform[:, start_idx:end_idx]

            # 提取特征
            mel_spec = self.extract_mel(window)

            # 模型预测
            frame_output = self.model(mel_spec)

            # 如果是 SED 模型，可能有 clipwise 和 segmentwise 输出
            if isinstance(frame_output, dict):
                frame_pred = frame_output["clipwise_output"]
            else:
                frame_pred = frame_output

            all_frame_predictions.append(frame_pred.cpu().numpy())

            window_id += 1

        # 转换为 numpy array
        all_frame_predictions = np.array(all_frame_predictions)  # (num_windows, num_classes)

        # 1st Place 创新: 相邻窗口帧预测平均
        # 这是一种 1D 滑动窗口分割，类似于大图像的 2D 滑动窗口分割
        smoothed_predictions = self._smooth_predictions(all_frame_predictions)

        # 生成最终预测
        predictions = {}
        for window_id in range(len(smoothed_predictions)):
            row_id = f"soundscape_{window_id}_{self.window_size}"
            predictions[row_id] = {
                f"species_{i}": float(prob)
                for i, prob in enumerate(smoothed_predictions[window_id])
            }

        return predictions

    def _smooth_predictions(
        self,
        predictions: np.ndarray,
    ) -> np.ndarray:
        """
        平滑预测 - 使用高斯滤波和时间平均

        Args:
            predictions: (num_windows, num_classes)

        Returns:
            Smoothed predictions
        """
        # 1. 时间维度高斯平滑
        if self.smoothing_sigma > 0:
            smoothed = gaussian_filter1d(
                predictions,
                sigma=self.smoothing_sigma,
                axis=0,
                mode="nearest",
            )
        else:
            smoothed = predictions

        # 2. 相邻窗口平均（1st Place 创新）
        # 使用相邻 3 个窗口的平均
        kernel_size = 3
        if len(smoothed) >= kernel_size:
            # Padding
            padded = np.pad(
                smoothed,
                ((kernel_size // 2, kernel_size // 2), (0, 0)),
                mode="edge",
            )

            # 一维卷积平均
            kernel = np.ones(kernel_size) / kernel_size
            averaged = np.zeros_like(smoothed)

            for c in range(smoothed.shape[1]):
                averaged[:, c] = np.convolve(
                    padded[:, c],
                    kernel,
                    mode="valid",
                )

            return averaged
        else:
            return smoothed

    def extract_mel(self, waveform: torch.Tensor) -> torch.Tensor:
        """提取 mel-spectrogram"""
        # 实际使用中应该与训练时的提取器一致
        pass


# 使用示例
inference = SlidingWindowInference(
    model=model,
    window_size=5,
    hop_size=5,
    smoothing_sigma=1.0,
)

predictions = inference.predict("test_soundscape_01.wav")

# 后处理（可选）
# - Delta shift: 调整低置信度类别的概率
# - Min-max 缩放
# - 频率范围调整
```

### SED 模型架构（BirdCLEF+ 2025 标准）

前排方案广泛使用的 SED (Sound Event Detection) 模型架构：

```python
import torch
import torch.nn as nn
import timm

class SEDModel(nn.Module):
    """
    Sound Event Detection 模型

    参考 BirdCLEF 2023 2nd Place 和 BirdCLEF+ 2025 前排方案
    """

    def __init__(
        self,
        backbone: str = "tf_efficientnetv2_s.in21k",
        num_classes: int = 206,
        in_channels: int = 1,
        pretrained: bool = True,
    ):
        super().__init__()

        self.num_classes = num_classes

        # 使用 timm 的 EfficientNet 作为 backbone
        self.backbone = timm.create_model(
            backbone,
            pretrained=pretrained,
            in_chans=in_channels,
            num_classes=0,  # 移除分类头
        )

        # 获取 backbone 输出特征维度
        self.features_dim = self.backbone.num_features

        # 自定义注意力块 (6th Place AttBlockV2)
        self.att_block = AttBlockV2(
            self.features_dim,
            num_classes,
            activation="sigmoid",
        )

    def forward(self, x, return_segmentwise=False):
        """
        Args:
            x: (batch, in_channels, n_mels, time)
            return_segmentwise: 是否返回 segmentwise_logit

        Returns:
            如果 return_segmentwise=False:
                clipwise_output: (batch, num_classes)
            如果 return_segmentwise=True:
                dict with:
                    clipwise_output: (batch, num_classes)
                    segmentwise_output: (batch, num_classes, time_frames)
        """
        # Backbone 特征提取
        features = self.backbone(x)  # (batch, features_dim, time_frames)

        # 全局池化
        pooled_features = features.mean(dim=[2])  # (batch, features_dim)

        # 片级预测
        clipwise_output = self.att_block(pooled_features)  # (batch, num_classes)

        if not return_segmentwise:
            return clipwise_output

        # 帧级预测（用于伪标签生成）
        segmentwise_output = self.att_block(features)  # (batch, num_classes, time_frames)

        return {
            "clipwise_output": clipwise_output,
            "segmentwise_output": segmentwise_output,
        }


class AttBlockV2(nn.Module):
    """
    自定义注意力块 - 6th Place 创新

    使用 softmax 和 tanh 进行归一化，结合非线性变换
    """

    def __init__(
        self,
        in_features: int,
        out_features: int,
        activation: str = "sigmoid",
    ):
        super().__init__()

        self.activation = activation
        self.att = nn.Conv1d(in_features, out_features, kernel_size=1)
        self.cla = nn.Conv1d(in_features, out_features, kernel_size=1)

        # 初始化权重（6th Place 关键）
        self.apply(self._init_weights)

    def _init_weights(self, m):
        if isinstance(m, nn.Conv1d):
            nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
            if m.bias is not None:
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        """
        Args:
            x: (batch, in_features, time_frames) 或 (batch, in_features)

        Returns:
            output: (batch, out_features) 或 (batch, out_features, time_frames)
        """
        if x.dim() == 2:
            # 全局池化特征
            x = x.unsqueeze(-1)  # (batch, in_features, 1)

        # 注意力权重
        att = self.att(x)
        att = torch.softmax(att, dim=1)  # 时间维度归一化

        # 分类特征
        cla = self.cla(x)

        # 加权求和
        output = torch.clamp(torch.clamp((cla * att).sum(dim=-1), min=1e-7, max=1-1e-7), min=1e-7)

        # 激活函数
        if self.activation == "sigmoid":
            output = torch.sigmoid(output)
        elif self.activation == "none":
            pass
        else:
            raise ValueError(f"Unknown activation: {self.activation}")

        return output.squeeze(-1) if output.size(-1) == 1 else output


# 常用 backbone 配置（前排方案）
BACKBONES = {
    "tf_efficientnetv2_s.in21k": {
        "features_dim": 1280,
        "description": "2nd Place 使用，平衡性能和速度",
    },
    "tf_efficientnetv2_b3.in21k": {
        "features_dim": 1536,
        "description": "6th Place 使用，更强性能",
    },
    "tf_efficientnetv2_m.in21k": {
        "features_dim": 2048,
        "description": "14th Place 使用，更高精度",
    },
    "eca_nfnet_l0": {
        "features_dim": 2304,
        "description": "2nd Place 使用，增加多样性",
    },
}

# 使用示例
model = SEDModel(
    backbone="tf_efficientnetv2_s.in21k",
    num_classes=206,
    in_channels=1,
    pretrained=True,
)

# 训练时：片级预测
clipwise_output = model(mel_spec)
loss = criterion(clipwise_output, labels)

# 伪标签生成时：帧级预测
output = model(mel_spec, return_segmentwise=True)
segmentwise_logits = output["segmentwise_output"]  # (batch, 206, time_frames)
segmentwise_probs = torch.sigmoid(segmentwise_logits)
# 时间维度平均得到更稳定的伪标签
avg_segmentwise_probs = segmentwise_probs.mean(dim=-1)  # (batch, 206)
```

### 前排方案详细技术分析

#### 2nd Place - Xeno-Canto 预训练详细流程

**作者**: Volodymyr Vialactea
**核心创新**: 使用外部数据预训练 + 5秒音频片段训练

**完整流程：**

```python
import torch
import torchaudio
import pandas as pd
from pathlib import Path

class XenoCantoPretraining:
    """
    2nd Place 方案：Xeno-Canto 预训练流程

    关键点：
    1. 下载额外的 Xeno-Canto 数据
    2. 数据清洗和预处理
    3. 预训练
    4. 在主数据集上微调
    """

    def __init__(
        self,
        species_list: list,
        target_sample_rate: int = 32000,
        segment_duration: int = 5,
    ):
        self.species_list = species_list
        self.target_sample_rate = target_sample_rate
        self.segment_duration = segment_duration

    def download_xeno_canto_data(self, output_dir: str = "data/xeno_canto"):
        """
        步骤 1: 从 Xeno-Canto 下载数据

        注意事项：
        - 过滤掉当年比赛中的物种（避免数据泄漏）
        - 只下载高质量录音（评分 ≥ 3.0）
        - 限制每个物种的下载量（避免数据不平衡）
        """
        # 使用 xeno-canto-api 或手动下载
        # 这里提供框架代码

        xc_species = [s for s in self.species_list if self._should_download(s)]

        for species in xc_species:
            # 调用 Xeno-Canto API
            # 下载音频文件
            # 保存到 output_dir/species_name/
            pass

    def _should_download(self, species: str) -> bool:
        """检查物种是否应该下载（避免数据泄漏）"""
        # 过滤比赛数据集中的物种
        competition_species = set(self._get_competition_species())
        return species not in competition_species

    def preprocess_xeno_canto(self, audio_dir: str):
        """
        步骤 2: 数据清洗和预处理

        2nd Place 的关键步骤：
        1. 去除人声（如果可能）
        2. 统一采样率到 32kHz
        3. 音频归一化
        4. 质量检查（SNR、时长等）
        """
        audio_files = list(Path(audio_dir).rglob("*.mp3"))

        cleaned_data = []

        for audio_file in audio_files:
            # 加载音频
            waveform, sr = torchaudio.load(audio_file)

            # 重采样到 32kHz
            if sr != self.target_sample_rate:
                resampler = torchaudio.transforms.Resample(sr, self.target_sample_rate)
                waveform = resampler(waveform)

            # 质量检查
            if self._check_quality(waveform):
                # 提取 5 秒片段
                segments = self._extract_segments(waveform)

                for segment in segments:
                    cleaned_data.append({
                        "file_path": str(audio_file),
                        "species": audio_file.parent.name,
                        "waveform": segment,
                    })

        return cleaned_data

    def _check_quality(self, waveform: torch.Tensor) -> bool:
        """质量检查"""
        # 检查 1: 时长至少 5 秒
        if waveform.shape[1] < self.target_sample_rate * self.segment_duration:
            return False

        # 检查 2: SNR（信噪比）
        # snr = self._calculate_snr(waveform)
        # if snr < 10:  # 最低 10dB
        #     return False

        # 检查 3: 削波检测
        if torch.abs(waveform).max() > 0.99:
            return False

        return True

    def _extract_segments(self, waveform: torch.Tensor) -> list:
        """
        提取 5 秒音频片段

        2nd Place 使用了多种采样策略：
        1. 随机采样
        2. 基于能量的采样（RMS）
        3. 重叠采样
        """
        segment_samples = self.segment_duration * self.target_sample_rate

        if waveform.shape[1] <= segment_samples:
            # 填充到 5 秒
            padding = segment_samples - waveform.shape[1]
            waveform = torch.nn.functional.pad(waveform, (0, padding))
            return [waveform]

        # 方法 1: 随机采样
        # 2nd Place 尝试了多种方法，最终发现随机采样效果最好

        # 方法 2: 基于能量的采样（RMS）
        # 计算每个 5 秒窗口的 RMS 能量
        # 选择能量最高的窗口

        # 方法 3: 重叠采样
        # 滑动窗口，hop_size = 2.5 秒

        # 这里实现随机采样
        max_start = waveform.shape[1] - segment_samples
        start_idx = torch.randint(0, max_start, (1,)).item()

        segment = waveform[:, start_idx:start_idx + segment_samples]
        return [segment]

    def pretrain(self, xc_data, model, save_path: str = "checkpoints/pretrained.pth"):
        """
        步骤 3: 预训练

        2nd Place 的预训练策略：
        - 使用 Xeno-Canto 数据训练
        - BCE Loss
        - SpecAugment 增强
        - 50-100 epochs
        """
        # 创建 dataloader
        train_loader = self._create_dataloader(xc_data)

        # 优化器
        optimizer = torch.optim.AdamW(model.parameters(), lr=1e-3)

        # 学习率调度器
        scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(
            optimizer, T_max=50, eta_min=1e-6
        )

        # 损失函数
        criterion = nn.BCEWithLogitsLoss()

        # 训练循环
        model.train()
        for epoch in range(50):  # 50 epochs
            for batch in train_loader:
                mel_spec = self._extract_mel(batch["waveform"])
                labels = batch["labels"]

                # 前向传播
                logits = model(mel_spec)
                loss = criterion(logits, labels)

                # 反向传播
                optimizer.zero_grad()
                loss.backward()
                optimizer.step()

            scheduler.step()

            print(f"Epoch {epoch+1}/50, Loss: {loss.item():.4f}")

        # 保存预训练模型
        torch.save(model.state_dict(), save_path)
        print(f"Pretrained model saved to {save_path}")

    def finetune(self, model, train_data, val_data, pretrained_path: str):
        """
        步骤 4: 微调

        2nd Place 的微调策略：
        - 加载预训练权重
        - 使用更小的学习率
        - 选择最佳 checkpoint（不是最后一个）
        - 关键：AUC 从 0.83-0.84 跳升至 0.86-0.87
        """
        # 加载预训练权重
        model.load_state_dict(torch.load(pretrained_path))

        # 优化器（更小的学习率）
        optimizer = torch.optim.AdamW(model.parameters(), lr=1e-4)

        # 学习率调度器
        scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(
            optimizer, T_max=30, eta_min=1e-7
        )

        # 损失函数
        criterion = nn.BCEWithLogitsLoss()

        best_val_score = 0
        best_epoch = 0

        # 微调循环
        model.train()
        for epoch in range(30):  # 30 epochs
            # 训练
            for batch in train_data:
                mel_spec = self._extract_mel(batch["waveform"])
                labels = batch["labels"]

                logits = model(mel_spec)
                loss = criterion(logits, labels)

                optimizer.zero_grad()
                loss.backward()
                optimizer.step()

            # 验证
            val_score = self._validate(model, val_data)

            print(f"Epoch {epoch+1}/30, Val AUC: {val_score:.4f}")

            # 保存最佳模型
            if val_score > best_val_score:
                best_val_score = val_score
                best_epoch = epoch
                torch.save(model.state_dict(), f"checkpoints/best_finetuned_epoch{epoch}.pth")

            scheduler.step()

        print(f"Best epoch: {best_epoch}, Best Val AUC: {best_val_score:.4f}")

    def _extract_mel(self, waveform: torch.Tensor) -> torch.Tensor:
        """提取 mel-spectrogram（应该与训练时一致）"""
        # 实现 mel-spectrogram 提取
        pass

    def _create_dataloader(self, data):
        """创建 dataloader"""
        pass

    def _validate(self, model, val_data):
        """验证"""
        pass

    def _get_competition_species(self) -> list:
        """获取竞赛数据集中的物种（避免数据泄漏）"""
        pass

    def _calculate_snr(self, waveform: torch.Tensor) -> float:
        """计算 SNR"""
        pass


# 2nd Place 关键技术总结
"""
关键发现（来自 2nd Place writeup）：

1. **预训练效果显著**：
   - 无预训练：AUC 0.83-0.84
   - 有预训练：AUC 0.86-0.87
   - 提升：+0.02-0.03 AUC

2. **Checkpoint 选择很重要**：
   - 不是最后一个 epoch 最好
   - 需要验证集选择最佳 checkpoint
   - 通常在 epoch 10-20 之间

3. **采样策略**：
   - 随机采样效果最好
   - 基于能量的采样没有明显优势
   - 5 秒片段是最佳长度

4. **数据增强**：
   - SpecAugment 必须保留
   - RandomFiltering 有效
   - 即使关闭略微提高 CV，但保留确保 LB 稳定性
"""
```

#### 5th Place - Self-Distillation 详细实现

**作者**: Noir
**核心创新**: 三阶段自蒸馏 + Silero VAD 数据清洗

**完整流程：**

```python
import torch
import torch.nn as nn
import numpy as np

class SelfDistillationTrainer:
    """
    5th Place 方案：Self-Distillation 三阶段训练

    核心思想：
    1. 使用 Silero VAD 去除人声
    2. 三阶段自蒸馏训练
    3. 迭代丰富次要标签
    """

    def __init__(
        self,
        model: nn.Module,
        num_classes: int = 206,
    ):
        self.model = model
        self.num_classes = num_classes

    def stage1_initial_training(self, train_loader, val_loader, epochs=30):
        """
        阶段 1: 初始训练

        使用清洗后的训练音频（train_audio）进行初始训练
        """
        print("=== Stage 1: Initial Training ===")

        optimizer = torch.optim.AdamW(self.model.parameters(), lr=1e-3)
        scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(
            optimizer, T_max=epochs, eta_min=1e-6
        )
        criterion = nn.BCEWithLogitsLoss()

        best_val_loss = float('inf')

        for epoch in range(epochs):
            self.model.train()
            train_loss = 0

            for batch in train_loader:
                mel_spec = batch['mel_spec']
                labels = batch['labels']

                # 前向传播
                logits = self.model(mel_spec)
                loss = criterion(logits, labels)

                # 反向传播
                optimizer.zero_grad()
                loss.backward()
                optimizer.step()

                train_loss += loss.item()

            # 验证
            val_loss = self._validate(self.model, val_loader, criterion)

            # 学习率更新
            scheduler.step()

            print(f"Epoch {epoch+1}/{epochs}, Train Loss: {train_loss/len(train_loader):.4f}, "
                  f"Val Loss: {val_loss:.4f}")

            # 保存最佳模型
            if val_loss < best_val_loss:
                best_val_loss = val_loss
                torch.save(self.model.state_dict(), "checkpoints/stage1_best.pth")

        print(f"Stage 1 complete. Best Val Loss: {best_val_loss:.4f}")

        # 加载最佳模型用于下一阶段
        self.model.load_state_dict(torch.load("checkpoints/stage1_best.pth"))

    def stage2_self_distillation_train_audio(
        self,
        train_loader,
        epochs=20,
        temperature=3.0,
        alpha=0.7,
    ):
        """
        阶段 2: 使用 train_audio 的自蒸馏

        使用 stage 1 模型的预测作为软标签进行蒸馏
        """
        print("=== Stage 2: Self-Distillation on train_audio ===")

        # stage 1 模型作为教师
        teacher_model = type(self.model)(
            backbone=self.model.backbone,
            num_classes=self.num_classes,
        )
        teacher_model.load_state_dict(torch.load("checkpoints/stage1_best.pth"))
        teacher_model.eval()

        # 学生模型（可以重置权重或继续训练）
        # 5th Place 选择继续训练

        optimizer = torch.optim.AdamW(self.model.parameters(), lr=5e-4)  # 更小的学习率
        scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(
            optimizer, T_max=epochs, eta_min=1e-7
        )

        # 蒸馏损失
        distillation_criterion = nn.KLDivLoss(reduction="batchmean")
        bce_criterion = nn.BCEWithLogitsLoss()

        best_val_loss = float('inf')

        for epoch in range(epochs):
            self.model.train()
            train_loss = 0

            for batch in train_loader:
                mel_spec = batch['mel_spec']
                hard_labels = batch['labels']

                with torch.no_grad():
                    # 教师模型预测（软标签）
                    teacher_logits = teacher_model(mel_spec)
                    teacher_probs = torch.sigmoid(teacher_logits / temperature)

                # 学生模型预测
                student_logits = self.model(mel_spec)
                student_log_probs = torch.log_softmax(student_logits / temperature, dim=-1)

                # 蒸馏损失
                distill_loss = distillation_criterion(student_log_probs, teacher_probs)

                # 硬标签损失
                bce_loss = bce_criterion(student_logits, hard_labels)

                # 组合损失
                loss = alpha * (temperature ** 2) * distill_loss + (1 - alpha) * bce_loss

                # 反向传播
                optimizer.zero_grad()
                loss.backward()
                optimizer.step()

                train_loss += loss.item()

            # 验证
            val_loss = self._validate(self.model, train_loader, bce_criterion)  # 用训练集验证

            scheduler.step()

            print(f"Epoch {epoch+1}/{epochs}, Train Loss: {train_loss/len(train_loader):.4f}, "
                  f"Val Loss: {val_loss:.4f}")

            if val_loss < best_val_loss:
                best_val_loss = val_loss
                torch.save(self.model.state_dict(), "checkpoints/stage2_best.pth")

        print(f"Stage 2 complete. Best Val Loss: {best_val_loss:.4f}")

        self.model.load_state_dict(torch.load("checkpoints/stage2_best.pth"))

    def stage3_self_distillation_soundscape(
        self,
        train_audio_loader,
        soundscape_files,
        epochs=20,
        temperature=3.0,
        alpha=0.5,  # 更重视伪标签
    ):
        """
        阶段 3: 结合 train_audio 和 train_soundscapes 的自蒸馏

        关键创新：丰富次要标签
        - 许多音频包含未标注的鸟叫声
        - 通过自蒸馏发现这些次要标签
        """
        print("=== Stage 3: Self-Distillation with soundscape ===")

        # stage 2 模型作为教师
        teacher_model = type(self.model)(
            backbone=self.model.backbone,
            num_classes=self.num_classes,
        )
        teacher_model.load_state_dict(torch.load("checkpoints/stage2_best.pth"))
        teacher_model.eval()

        optimizer = torch.optim.AdamW(self.model.parameters(), lr=3e-4)
        scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(
            optimizer, T_max=epochs, eta_min=1e-7
        )

        distillation_criterion = nn.KLDivLoss(reduction="batchmean")
        bce_criterion = nn.BCEWithLogitsLoss()

        # 生成 soundscape 的伪标签
        soundscape_pseudo_labels = self._generate_pseudo_labels(
            teacher_model, soundscape_files
        )

        # 合并 train_audio 和 soundscape 数据
        # 50% train_audio + 50% soundscape

        best_val_loss = float('inf')

        for epoch in range(epochs):
            self.model.train()
            train_loss = 0

            # 训练 train_audio（带硬标签）
            for batch in train_audio_loader:
                if np.random.rand() > 0.5:
                    continue  # 50% 概率使用 train_audio

                mel_spec = batch['mel_spec']
                hard_labels = batch['labels']

                with torch.no_grad():
                    teacher_logits = teacher_model(mel_spec)
                    teacher_probs = torch.sigmoid(teacher_logits / temperature)

                student_logits = self.model(mel_spec)
                student_log_probs = torch.log_softmax(student_logits / temperature, dim=-1)

                distill_loss = distillation_criterion(student_log_probs, teacher_probs)
                bce_loss = bce_criterion(student_logits, hard_labels)
                loss = alpha * (temperature ** 2) * distill_loss + (1 - alpha) * bce_loss

                optimizer.zero_grad()
                loss.backward()
                optimizer.step()

                train_loss += loss.item()

            # 训练 soundscape（伪标签）
            for batch in soundscape_pseudo_labels:
                if np.random.rand() <= 0.5:
                    continue  # 50% 概率使用 soundscape

                mel_spec = batch['mel_spec']
                pseudo_labels = batch['labels']  # 软标签

                with torch.no_grad():
                    teacher_logits = teacher_model(mel_spec)
                    teacher_probs = torch.sigmoid(teacher_logits / temperature)

                student_logits = self.model(mel_spec)
                student_log_probs = torch.log_softmax(student_logits / temperature, dim=-1)

                # 只使用蒸馏损失（没有硬标签）
                distill_loss = distillation_criterion(student_log_probs, teacher_probs)

                optimizer.zero_grad()
                distill_loss.backward()
                optimizer.step()

                train_loss += distill_loss.item()

            scheduler.step()

            print(f"Epoch {epoch+1}/{epochs}, Train Loss: {train_loss:.4f}")

            # 保存检查点
            if epoch % 5 == 0:
                torch.save(self.model.state_dict(), f"checkpoints/stage3_epoch{epoch}.pth")

        print("Stage 3 complete")

    def _generate_pseudo_labels(
        self,
        model: nn.Module,
        audio_files: list,
    ) -> list:
        """
        生成 soundscape 的伪标签

        关键：丰富次要标签
        - 使用帧级预测（segmentwise）
        - 时间维度平均
        """
        model.eval()
        pseudo_labels = []

        with torch.no_grad():
            for audio_file in audio_files:
                # 加载音频
                waveform, sr = torchaudio.load(audio_file)

                # 分段处理（5秒窗口）
                segments = self._split_audio(waveform, sr)

                for segment in segments:
                    mel_spec = self._extract_mel(segment)

                    # 获取帧级预测
                    output = model(mel_spec, return_segmentwise=True)
                    segmentwise_logits = output["segmentwise_output"]  # (1, 206, time)
                    segmentwise_probs = torch.sigmoid(segmentwise_logits)

                    # 时间维度平均（关键：丰富次要标签）
                    avg_probs = segmentwise_probs.mean(dim=-1).squeeze(0)  # (206,)

                    pseudo_labels.append({
                        "mel_spec": mel_spec,
                        "labels": avg_probs,
                    })

        return pseudo_labels

    def _split_audio(self, waveform: torch.Tensor, sr: int) -> list:
        """分段处理音频"""
        segment_samples = 5 * sr
        segments = []

        for i in range(0, waveform.shape[1], segment_samples):
            segment = waveform[:, i:i+segment_samples]
            if segment.shape[1] == segment_samples:
                segments.append(segment)
            else:
                # 填充
                padding = segment_samples - segment.shape[1]
                segment = torch.nn.functional.pad(segment, (0, padding))
                segments.append(segment)

        return segments

    def _extract_mel(self, waveform: torch.Tensor) -> torch.Tensor:
        """提取 mel-spectrogram"""
        pass

    def _validate(self, model, val_loader, criterion):
        """验证"""
        model.eval()
        total_loss = 0

        with torch.no_grad():
            for batch in val_loader:
                mel_spec = batch['mel_spec']
                labels = batch['labels']

                logits = model(mel_spec)
                loss = criterion(logits, labels)
                total_loss += loss.item()

        return total_loss / len(val_loader)


class SileroVADDataCleaner:
    """
    Silero VAD 数据清洗

    5th Place 使用 Silero VAD 检测并去除人声片段
    """

    def __init__(self):
        # 加载 Silero VAD 模型
        self.model, utils = torch.hub.load(
            repo_or_dir='snakers4/silero-vad',
            model='silero_vad',
            force_reload=False,
            onnx=False
        )
        self.model.eval()

    def clean_audio(self, audio_path: str, output_path: str):
        """
        去除包含人声的音频片段

        Returns:
            清洗后的音频（去除人声部分）
        """
        waveform, sr = torchaudio.load(audio_path)

        # 转换为单声道
        if waveform.shape[0] > 1:
            waveform = waveform.mean(dim=0, keepdim=True)

        # 重采样到 16kHz（Silero VAD 要求）
        if sr != 16000:
            resampler = torchaudio.transforms.Resample(sr, 16000)
            waveform = resampler(waveform)
            sr = 16000

        # VAD 检测
        speech_chunks = self._detect_speech(waveform, sr)

        # 如果检测到人声，去除这些片段
        if speech_chunks:
            cleaned_waveform = self._remove_speech_chunks(waveform, speech_chunks)
        else:
            cleaned_waveform = waveform

        # 保存清洗后的音频
        torchaudio.save(output_path, cleaned_waveform, sr)

        return cleaned_waveform

    def _detect_speech(self, waveform: torch.Tensor, sr: int) -> list:
        """
        检测人声片段

        Returns:
            List of (start_ms, end_ms) tuples
        """
        # 获取语音概率
        speech_probs = []
        window_size = 512  # 32ms at 16kHz

        for i in range(0, waveform.shape[1], window_size):
            chunk = waveform[:, i:i+window_size]
            if chunk.shape[1] < window_size:
                continue

            with torch.no_grad():
                speech_prob = self.model(chunk, sr).item()
                speech_probs.append(speech_prob)

        # 阈值检测（人声概率 > 0.5）
        speech_chunks = []
        in_speech = False
        start_idx = 0

        for i, prob in enumerate(speech_probs):
            if prob > 0.5 and not in_speech:
                in_speech = True
                start_idx = i * window_size
            elif prob <= 0.5 and in_speech:
                in_speech = False
                end_idx = i * window_size
                speech_chunks.append((start_idx, end_idx))

        # 转换为毫秒
        speech_chunks_ms = [(s * 1000 / sr, e * 1000 / sr) for s, e in speech_chunks]

        return speech_chunks_ms

    def _remove_speech_chunks(
        self,
        waveform: torch.Tensor,
        speech_chunks: list,
    ) -> torch.Tensor:
        """去除人声片段"""
        sr = 16000

        # 将时间转换为样本索引
        speech_ranges = [(int(s * sr / 1000), int(e * sr / 1000)) for s, e in speech_chunks]

        # 创建掩码（True 表示保留）
        mask = torch.ones(waveform.shape[1], dtype=torch.bool)

        for start, end in speech_ranges:
            mask[start:end] = False

        # 应用掩码
        cleaned_waveform = waveform[:, mask]

        return cleaned_waveform


# 5th Place 关键技术总结
"""
关键发现（来自 5th Place writeup）：

1. **Silero VAD 有效**：
   - 去除人声减少误检
   - 清洗后数据质量提升

2. **三阶段自蒸馏**：
   - Stage 1: 基础训练
   - Stage 2: train_audio 自蒸馏
   - Stage 3: 加入 soundscape 伪标签
   - 每个阶段都带来提升

3. **丰富次要标签**：
   - 许多音频包含未标注的鸟叫声
   - 使用帧级预测和时间平均
   - 迭代训练发现更多标签

4. **数据平衡重要**：
   - 样本 <20 的类别复制到 20
   - 样本 <30 的类别手动筛选
   - 使用前 30/60 秒数据
"""
```

#### 1st Place - Multi-Iterative Noisy Student 详细流程

**作者**: Nikita Babych
**核心创新**: 多迭代 Noisy Student + MixUp + 幂次变换

**完整流程：**

```python
import torch
import torch.nn as nn
import numpy as np

class MultiIterativeNoisyStudent:
    """
    1st Place 方案：多迭代 Noisy Student 自训练

    核心创新：
    1. 多迭代自训练，每次使用 MixUp
    2. 伪标签幂次变换减少噪声
    3. 滑动窗口推理，帧预测平均
    """

    def __init__(
        self,
        model: nn.Module,
        num_classes: int = 206,
        num_iterations: int = 3,
    ):
        self.model = model
        self.num_classes = num_classes
        self.num_iterations = num_iterations

        # 1st Place 关键参数
        self.mixup_alpha = 0.5
        self.power_transform = 1.5  # 幂次变换参数（减少伪标签噪声）

    def train_iteration(
        self,
        train_audio_loader,
        train_soundscape_files,
        iteration: int,
        epochs=30,
    ):
        """
        执行一次 Noisy Student 迭代

        Args:
            iteration: 当前迭代编号（0, 1, 2, ...）
        """
        print(f"=== Noisy Student Iteration {iteration + 1} ===")

        # 准备数据
        # 50% train_audio + 50% 伪标签 soundscape
        if iteration == 0:
            # 第一次迭代：只使用 train_audio
            train_loader = train_audio_loader
        else:
            # 后续迭代：混合 train_audio 和伪标签
            train_loader = self._prepare_mixed_data(
                train_audio_loader,
                train_soundscape_files,
                iteration,
            )

        # 优化器
        optimizer = torch.optim.AdamW(self.model.parameters(), lr=1e-3)
        scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(
            optimizer, T_max=epochs, eta_min=1e-6
        )
        criterion = nn.BCEWithLogitsLoss()

        best_val_loss = float('inf')

        for epoch in range(epochs):
            self.model.train()
            train_loss = 0

            for batch in train_loader:
                mel_spec = batch['mel_spec']
                labels = batch['labels']

                # MixUp 数据增强（1st Place 关键）
                if np.random.rand() < 0.5:  # 50% 概率应用 MixUp
                    mel_spec, labels = self._apply_mixup(mel_spec, labels)

                # 前向传播
                logits = self.model(mel_spec)
                loss = criterion(logits, labels)

                # 反向传播
                optimizer.zero_grad()
                loss.backward()
                optimizer.step()

                train_loss += loss.item()

            # 验证（使用训练集的一个子集）
            val_loss = self._quick_validate(train_audio_loader, criterion)

            scheduler.step()

            print(f"Iteration {iteration+1}, Epoch {epoch+1}/{epochs}, "
                  f"Train Loss: {train_loss/len(train_loader):.4f}, "
                  f"Val Loss: {val_loss:.4f}")

            if val_loss < best_val_loss:
                best_val_loss = val_loss
                torch.save(self.model.state_dict(),
                          f"checkpoints/noisy_student_iter{iteration}_best.pth")

        print(f"Iteration {iteration+1} complete. Best Val Loss: {best_val_loss:.4f}")

    def _prepare_mixed_data(
        self,
        train_audio_loader,
        soundscape_files,
        iteration: int,
    ):
        """
        准备混合数据：train_audio + 伪标签 soundscape

        关键：幂次变换减少伪标签噪声（1st Place 创新）
        """
        # 生成伪标签
        pseudo_labels = self._generate_pseudo_labels_power_transform(
            soundscape_files,
            self.power_transform,
        )

        # 创建混合 dataloader
        mixed_data = []

        # 添加 train_audio
        for batch in train_audio_loader:
            mixed_data.append(batch)

        # 添加伪标签 soundscape
        for item in pseudo_labels:
            mixed_data.append(item)

        # 打乱顺序
        np.random.shuffle(mixed_data)

        return mixed_data

    def _generate_pseudo_labels_power_transform(
        self,
        audio_files: list,
        power: float = 1.5,
    ) -> list:
        """
        生成伪标签并应用幂次变换

        1st Place 关键创新：幂次变换减少噪声

        原理：
        - 直接对概率进行温度缩放会提高噪声的概率
        - 通过幂次变换，防止噪声的放大，并保留重要的标签信号
        """
        self.model.eval()
        pseudo_labels = []

        with torch.no_grad():
            for audio_file in audio_files:
                waveform, sr = torchaudio.load(audio_file)

                # 分段处理（5秒窗口）
                segments = self._split_audio(waveform, sr)

                for segment in segments:
                    mel_spec = self._extract_mel(segment)

                    # 获取预测
                    logits = self.model(mel_spec)
                    probs = torch.sigmoid(logits).squeeze(0).cpu().numpy()  # (206,)

                    # 幂次变换（1st Place 创新）
                    # power > 1: 压缩低概率，扩展高概率
                    # power < 1: 扩展低概率，压缩高概率
                    probs_transformed = np.power(probs, power)

                    pseudo_labels.append({
                        "mel_spec": mel_spec,
                        "labels": torch.tensor(probs_transformed, dtype=torch.float32),
                    })

        return pseudo_labels

    def _apply_mixup(
        self,
        mel_spec: torch.Tensor,
        labels: torch.Tensor,
    ) -> tuple:
        """
        MixUp 数据增强

        1st Place 关键：使用固定混合权重 0.5
        """
        batch_size = mel_spec.size(0)

        # 生成混合权重
        lam = np.random.beta(self.mixup_alpha, self.mixup_alpha)
        # 1st Place 发现固定权重 0.5 效果更好
        # lam = 0.5

        # 随机排列
        index = torch.randperm(batch_size)

        # 混合特征
        mixed_mel = lam * mel_spec + (1 - lam) * mel_spec[index]

        # 混合标签（取最大值）
        mixed_labels = torch.maximum(labels, labels[index])

        return mixed_mel, mixed_labels

    def _split_audio(self, waveform: torch.Tensor, sr: int) -> list:
        """分段处理音频"""
        segment_samples = 5 * sr
        segments = []

        for i in range(0, waveform.shape[1], segment_samples):
            segment = waveform[:, i:i+segment_samples]
            if segment.shape[1] == segment_samples:
                segments.append(segment)
            else:
                padding = segment_samples - segment.shape[1]
                segment = torch.nn.functional.pad(segment, (0, padding))
                segments.append(segment)

        return segments

    def _extract_mel(self, waveform: torch.Tensor) -> torch.Tensor:
        """提取 mel-spectrogram"""
        pass

    def _quick_validate(self, val_loader, criterion):
        """快速验证"""
        self.model.eval()
        total_loss = 0
        count = 0

        with torch.no_grad():
            for i, batch in enumerate(val_loader):
                if i >= 10:  # 只验证前 10 个 batch
                    break

                mel_spec = batch['mel_spec']
                labels = batch['labels']

                logits = self.model(mel_spec)
                loss = criterion(logits, labels)
                total_loss += loss.item()
                count += 1

        return total_loss / max(count, 1)


# 1st Place 关键技术总结
"""
关键发现（来自 1st Place writeup）：

1. **多迭代 Noisy Student 有效**：
   - 每次迭代都带来提升
   - 3 次迭代是最优的
   - 更多迭代可能导致噪声累积

2. **幂次变换是关键**：
   - 直接使用伪标签：性能提升有限
   - 幂次变换（power=1.5）：显著提升
   - 防止噪声放大，保留信号

3. **MixUp 策略**：
   - 固定权重 0.5 比随机权重更稳定
   - 迫使模型学习更鲁棒的特征
   - 减少过拟合

4. **滑动窗口推理**：
   - 使用帧预测的平均值
   - 避免丢弃有价值的预测数据
   - 类似图像的 2D 滑动窗口分割
"""


# 1st Place 完整训练流程示例
def train_noisy_student_full_pipeline():
    """
    完整的 Noisy Student 训练流程
    """
    # 初始化
    model = SEDModel(num_classes=206)
    trainer = MultiIterativeNoisyStudent(model, num_iterations=3)

    # 准备数据
    train_audio_loader = ...  # 训练音频 loader
    soundscape_files = ...    # soundscape 文件列表

    # 迭代 0: 只使用 train_audio
    print("=== Iteration 0: Training on train_audio only ===")
    trainer.train_iteration(train_audio_loader, soundscape_files, iteration=0, epochs=30)

    # 迭代 1: 加入伪标签 soundscape
    print("=== Iteration 1: Adding pseudo-labeled soundscape ===")
    trainer.train_iteration(train_audio_loader, soundscape_files, iteration=1, epochs=30)

    # 迭代 2: 使用新的伪标签
    print("=== Iteration 2: Refreshing pseudo labels ===")
    trainer.train_iteration(train_audio_loader, soundscape_files, iteration=2, epochs=30)

    # 最终集成：使用不同迭代的模型
    model_iter0 = SEDModel(num_classes=206)
    model_iter0.load_state_dict(torch.load("checkpoints/noisy_student_iter0_best.pth"))

    model_iter1 = SEDModel(num_classes=206)
    model_iter1.load_state_dict(torch.load("checkpoints/noisy_student_iter1_best.pth"))

    model_iter2 = SEDModel(num_classes=206)
    model_iter2.load_state_dict(torch.load("checkpoints/noisy_student_iter2_best.pth"))

    # 集成预测
    def ensemble_predict(mel_spec):
        pred0 = torch.sigmoid(model_iter0(mel_spec))
        pred1 = torch.sigmoid(model_iter1(mel_spec))
        pred2 = torch.sigmoid(model_iter2(mel_spec))

        # 简单平均
        ensemble_pred = (pred0 + pred1 + pred2) / 3
        return ensemble_pred

    return ensemble_predict
```

#### 4th Place - Soft AUC Loss 详细分析

**作者**: dylan.liu
**核心创新**: 支持软标签的 AUC 损失函数

**问题背景：**
- 标准 AUC 损失函数不支持软标签（适用于知识蒸馏和半监督学习）
- 4th Place 通过自定义 soft AUC loss 解决这个问题
- 效果：从 11 名跃升至 4 名（LB 从 0.850 → 0.901）

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class SoftAUCLoss_v4(nn.Module):
    """
    4th Place Soft AUC Loss 实现

    参考：4th Place writeup
    效果：LB 从 0.850 → 0.901（显著提升）

    核心思想：
    1. 支持 soft labels（适用于知识蒸馏和半监督学习）
    2. 通过正负样本对的排序关系优化 AUC
    3. 减少 overfitting
    """

    def __init__(
        self,
        margin: float = 1.0,
        reduction: str = "mean",
    ):
        super().__init__()
        self.margin = margin
        self.reduction = reduction

    def forward(
        self,
        predictions: torch.Tensor,
        targets: torch.Tensor,
    ) -> torch.Tensor:
        """
        Args:
            predictions: (batch, num_classes) - 原始 logits
            targets: (batch, num_classes) - 软标签 [0, 1]

        Returns:
            AUC loss
        """
        probs = torch.sigmoid(predictions)
        num_classes = predictions.size(1)
        losses = []

        for c in range(num_classes):
            prob_c = probs[:, c]      # (batch,)
            target_c = targets[:, c]  # (batch,)

            # 计算所有样本对的差异
            # 对于软标签，我们需要加权处理

            # 创建样本对矩阵
            # target_diff > 0 表示 target_i > target_j
            target_diff = target_c.unsqueeze(1) - target_c.unsqueeze(0)  # (batch, batch)
            prob_diff = prob_c.unsqueeze(1) - prob_c.unsqueeze(0)        # (batch, batch)

            # 只考虑 target_i > target_j 的对
            # 即正样本（高 target）应该有更高的预测概率
            mask = target_diff > 0

            if mask.sum() > 0:
                # Hinge loss: max(0, margin - (prob_i - prob_j))
                # 理想情况：prob_i > prob_j（正样本预测高于负样本）
                # margin - (prob_i - prob_j) 应该 <= 0
                # 如果 > 0，说明违反了排序关系

                loss_c = F.relu(self.margin - prob_diff)[mask].mean()

                # 4th Place 发现加权版本更有效
                # 使用 target_diff 作为权重
                # weight = target_diff[mask]
                # weighted_loss = F.relu(self.margin - prob_diff)[mask] * weight
                # loss_c = weighted_loss.sum() / weight.sum()

                losses.append(loss_c)

        if len(losses) == 0:
            return torch.tensor(0.0, device=predictions.device, requires_grad=True)

        losses = torch.stack(losses)

        if self.reduction == "mean":
            return losses.mean()
        elif self.reduction == "sum":
            return losses.sum()
        else:
            return losses


class SoftAUCLoss_Advanced(nn.Module):
    """
    改进的 Soft AUC Loss

    结合 4th Place 的发现和其他优化：
    1. 温度缩放
    2. 自适应 margin
    3. 类别加权
    """

    def __init__(
        self,
        margin: float = 1.0,
        temperature: float = 1.0,
        use_class_weighting: bool = True,
    ):
        super().__init__()
        self.margin = margin
        self.temperature = temperature
        self.use_class_weighting = use_class_weighting

    def forward(
        self,
        predictions: torch.Tensor,
        targets: torch.Tensor,
    ) -> torch.Tensor:
        """
        Args:
            predictions: (batch, num_classes)
            targets: (batch, num_classes) - 软标签
        """
        # 温度缩放
        probs = torch.sigmoid(predictions / self.temperature)
        num_classes = predictions.size(1)

        losses = []

        for c in range(num_classes):
            prob_c = probs[:, c]
            target_c = targets[:, c]

            # 样本对矩阵
            target_diff = target_c.unsqueeze(1) - target_c.unsqueeze(0)
            prob_diff = prob_c.unsqueeze(1) - prob_c.unsqueeze(0)

            # mask: target_i > target_j
            mask = target_diff > 0

            if mask.sum() > 0:
                # Hinge loss
                base_loss = F.relu(self.margin - prob_diff)[mask]

                # 可选：使用 target_diff 作为权重
                # 这给予高 target 差异的样本对更高权重
                weights = target_diff[mask]
                weighted_loss = base_loss * weights

                loss_c = weighted_loss.sum() / weights.sum()

                # 可选：类别权重（处理长尾分布）
                if self.use_class_weighting:
                    # 稀有类别更高权重
                    class_weight = self._get_class_weight(c, num_classes)
                    loss_c = loss_c * class_weight

                losses.append(loss_c)

        if len(losses) == 0:
            return torch.tensor(0.0, device=predictions.device, requires_grad=True)

        return torch.stack(losses).mean()

    def _get_class_weight(self, class_idx: int, num_classes: int) -> float:
        """
        计算类别权重（处理长尾分布）

        简单版本：可以基于样本频率
        """
        # 这里使用简单策略：可以替换为实际的类别频率
        #稀有类获得更高权重
        return 1.0  # 可以自定义


# 4th Place 关键发现总结
"""
关键发现（来自 4th Place writeup）：

1. **Soft AUC Loss 显著提升性能**：
   - LB 从 0.850 → 0.901
   - 排名从 11 名 → 4 名
   - +0.05 AUC 提升是巨大的

2. **为什么 Soft AUC Loss 有效**：
   - 标准 AUC loss 只支持硬标签（0 或 1）
   - Soft AUC Loss 支持软标签（0 到 1 之间）
   - 适用于知识蒸馏和半监督学习
   - 减少 overfitting

3. **实现细节**：
   - 使用样本对的排序关系
   - Hinge loss: max(0, margin - (prob_i - prob_j))
   - 只考虑 target_i > target_j 的对
   - margin 通常设为 1.0

4. **适用场景**：
   - 半监督学习（伪标签）
   - 知识蒸馏（软标签）
   - 长尾分布（稀有类别）
   - 标签噪声（软标签更鲁棒）

5. **与其他损失函数对比**：
   - BCE Loss: 简单但易过拟合
   - Focal Loss: 处理类别不平衡，但不优化 AUC
   - Soft AUC Loss: 直接优化 AUC，支持软标签
"""


# 使用示例
def train_with_soft_auc_loss():
    """使用 Soft AUC Loss 训练"""

    model = SEDModel(num_classes=206)

    # 标准训练：BCE Loss
    criterion_bce = nn.BCEWithLogitsLoss()

    # 半监督训练：Soft AUC Loss
    criterion_soft_auc = SoftAUCLoss_v4(margin=1.0)

    # 优化器
    optimizer = torch.optim.AdamW(model.parameters(), lr=1e-3)

    # 训练循环
    for epoch in range(30):
        model.train()

        for batch in train_loader:
            mel_spec = batch['mel_spec']
            labels = batch['labels']  # 可能是软标签

            # 选择损失函数
            if batch.get('is_pseudo', False):  # 伪标签数据
                # 使用 Soft AUC Loss
                loss = criterion_soft_auc(model(mel_spec), labels)
            else:  # 真实标签
                # 可以使用 BCE Loss 或 Soft AUC Loss
                loss = criterion_bce(model(mel_spec), labels)

            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

        print(f"Epoch {epoch+1}/30, Loss: {loss.item():.4f}")
```

---

## Best Practices

### 时间序列分类竞赛策略

| 策略 | 何时使用 | 说明 |
|------|---------|------|
| **CWT over STFT** | 非平稳信号 | CWT提供更好的时间-频率局部化 |
| **Entmax over Softmax** | 标签稀疏时 | Entmax产生更稀疏的输出 |
| **非负线性回归集成** | 多模型集成时 | 即使过拟合也能保持相关性 |
| **2-Stage Training** | 标签质量不均时 | Stage1全数据，Stage2高质量样本 |
| **Group K-Fold** | 有重复样本时 | 确保同一patient/EEG不分散 |
| **仅用高质量样本** | 评估时 | 使用votes≥10的样本建立验证集 |

### 时频分析方法对比

| 方法 | 优点 | 缺点 | 适用场景 |
|------|------|------|---------|
| **STFT** | 简单，易实现 | 固定窗口，时频分辨率权衡 | 平稳信号 |
| **CWT** | 多分辨率分析，捕捉局部特征 | 需要选择小波函数 | 非平稳信号，EEG |
| **Superlet** | 最高时频分辨率 | 计算成本高 | 复杂脑波模式 |

### 频率配置经验

| 配置 | 范围 | 说明 |
|------|------|------|
| **标准CWT** | 0.5-20 Hz | Kaggle提供的spectrogram默认范围 |
| **扩展CWT** | 0.5-40 Hz | 更好的结果 (suguuuuu) |
| **带通滤波** | 0.5-40 Hz | 高频噪声增加'other'投票 |

### 数据增强策略

**时间序列 (1D):**
- 随机时间偏移 (±5秒)
- 随机带通滤波 (不同频率范围)
- 通道翻转 (水平/垂直)
- 幅值缩放

**Scalogram/Spectrogram (2D):**
- XYMasking (随机遮挡)
- Mixup
- 时间方向翻转

### Backbone选择

**时间序列 (1D):**
- 1D CNN + GRU
- Transformer (Time-series Transformer)
- LSTM/GRU

**Scalogram (2D):**
- SwinV2: swinv2_tiny_window16 (最佳: CV 0.2229)
- MaxVIT: maxvit_base_tf_512
- ConvNeXt: convnextv2_atto

### 标签处理技巧

| 技巧 | 效果 |
|------|------|
| 标签平滑 (加0.02 offset) | 使低投票数标签获得更强正则化 |
| 仅用votes≥10评估 | CV/LB相关性接近1:1 |
| 投票数归一化 | 多专家投票转换为分布 |

### 常见误区

| 误区 | 正确做法 |
|------|---------|
| STFT不够好就放弃时频分析 | 尝试CWT或Superlet |
| Softmax输出不够稀疏 | 使用Entmax |
| 集成权重手动调参 | 使用非负线性回归 |
| 用全部样本验证 | 仅用高质量样本 (votes≥10) |
| 忽略Group K-Fold | 防止同一patient的数据泄露 |

