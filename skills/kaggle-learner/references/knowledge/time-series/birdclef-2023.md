# BirdCLEF 2023
> Last updated: 2026-01-25
> Source count: 10+
---

### BirdCLEF 2023 - Bird Sound Identification (2023)

**竞赛背景：**
- **主办方**：Cornell Lab of Ornithology, LifeCLEF
- **目标**：识别东非鸟类叫声，促进鸟类保护和生态监测
- **应用场景**：自动化生物声学监测，替代人工识别
- **社会意义**：大规模鸟类种群监测，生物多样性保护
- **竞赛时间**：2023 年 3-5 月
- **参赛队伍**：1,189 支团队

**任务描述：**
从肯尼亚 soundscape 音频中分类 264 种鸟类叫声：
- **多标签分类**：一个音频可能包含多种鸟类
- **评估指标**：**Macro-averaged ROC-AUC**（所有类别的平均）
- 需要预测所有 264 个类别的概率
- 提交格式：row_id × 264物种的概率矩阵

**数据集规模：**
- 训练数据：~20,000 个标注样本（5 秒片段）
- 测试数据：未标注的 soundscape 音频（需 5 秒滑动窗口预测）
- 音频长度：随机长度（5 秒到数分钟）
- 采样率：通常为 32 kHz
- 物种数量：264 种东非鸟类

**数据特点：**
1. **类别不平衡**：某些鸟类样本数 < 10，某些 > 1000
2. **混合叫声**：一个音频可能包含多种鸟类
3. **背景噪声**：风声、雨声、人声、昆虫声等环境噪声
4. **未标注数据**：大量未标注 soundscape 可用于伪标签
5. **领域偏移**：训练数据（哥伦比亚）与测试数据（肯尼亚）存在分布差异

**竞赛约束：**
- **推理限制**：仅 CPU，推理时间限制
- 需要优化推理速度，不能使用太大模型
- 提交文件大小限制

**前排方案排名：**
| 排名 | 团队/个人 | Private LB | 关键技术 |
|------|----------|------------|----------|
| **1st** | Volodymyr Sydorskyi | **0.76392** | Correct Data is All You Need - 数据清洗 + 外部数据 + 模型集成 |
| **2nd** | Griffith | ~0.75+ | SED + CNN with 7 models ensemble |
| **3rd** | ADSR | ~0.75 | SED with attention on Mel frequency bands |
| **4th** | ATFujita | 0.74424 | Knowledge Distillation Is All You Need - 知识蒸馏 + Xeno-Canto |
| **5th** | Yevhenii Maslov | ~0.74 | 外部数据 + 预训练 + 集成 |

**技术演进（与后续版本对比）：**
| 技术点 | BirdCLEF 2023 | BirdCLEF 2024 | BirdCLEF+ 2025 |
|--------|---------------|---------------|-----------------|
| **物种数量** | 264 种 | 182 种 | 206 种（多分类群）|
| **外部数据** | Xeno-Canto 重要 | 不用外部数据更优 | Xeno-Canto 预训练重要 |
| **模型架构** | EfficientNetV2 + SED | EfficientNet B0 + RegNetY | EfficientNet + ViT |
| **损失函数** | BCE + FocalLoss | CE Loss | BCE Loss |
| **伪标签** | 高低阈值筛选 | Google Classifier 预标注 | Noisy Student |
| **推理优化** | PyTorch | OpenVINO | OpenVINO |

---

## Competition Brief（竞赛简介）

### 竞赛概述

BirdCLEF 2023 是 Kaggle 上举办的鸟类声音识别竞赛，目标是从东非肯尼亚的 soundscape 音频中自动识别鸟类物种。该竞赛是 BirdCLEF 系列的 2023 年版本，属于时序音频分类任务。

### 关键挑战

1. **长尾分布**：264 个物种的样本数量极不均衡
2. **领域偏移**：训练数据与测试数据来自不同地区
3. **背景噪声**：实际环境中的各种噪声干扰
4. **弱监督学习**：大量未标注 soundscape 数据需要利用
5. **计算限制**：CPU 推理限制，需要优化推理速度

### 评估机制

- **指标**：Macro-averaged ROC-AUC
- **评估方式**：每个类别独立计算 AUC，然后取平均
- **提交格式**：CSV 文件，包含 row_id 和 264 个物种的概率列
- **后处理**：允许基于时间和空间一致性的后处理

---

## 前排方案详细技术分析

### 1st Place - Volodymyr Sydorskyi (Volodymyr)

**最终成绩**：0.76392（Private LB）

**核心策略**：Correct Data is All You Need

**关键技术**：

1. **数据清洗和质量控制**
   - 严格的音频质量筛选
   - 基于信噪比的过滤
   - 去除低质量标注样本
   - 时间戳验证和清洗

2. **外部数据策略**
   - Xeno-Canto 数据集成
   - 跨年度数据利用（2021/2022 竞赛数据）
   - 领域自适应技术
   - 数据重采样策略

3. **模型架构**
   - EfficientNetV2 系列作为 backbone
   - SED (Sound Event Detection) 框架
   - 多尺度特征提取
   - 注意力机制集成

4. **训练策略**
   - 两阶段训练：预训练 + 微调
   - Focal Loss 处理类别不平衡
   - 混合精度训练
   - 梯度累积

5. **集成策略**
   - 多模型集成（不同 backbone 和配置）
   - Checkpoint averaging
   - 时序平滑后处理
   - 基于物种出现时间的后处理

**实现细节**：
- 使用 EfficientNetV2-s 和 EfficientNetV2-m
- 7+ 模型集成
- Mel-spectrogram 参数：n_mels=128, fmin=64, fmax=16000
- 数据增强：SpecAugment + MixUp
- 推理优化：ONNX + 多线程

**代码仓库**：
- GitHub: [VSydorskyy/BirdCLEF_2023_1st_place](https://github.com/VSydorskyy/BirdCLEF_2023_1st_place)
- Kaggle Writeup: [1st place solution: Correct Data is All You Need](https://www.kaggle.com/competitions/birdclef-2023/writeups/volodymyr-1st-place-solution-correct-data-is-all-y)

---

### 2nd Place - Griffith

**最终成绩**：~0.75+（Private LB）

**核心策略**：SED + CNN with 7 models ensemble

**关键技术**：

1. **SED (Sound Event Detection) 框架**
   - 基于 EfficientNetV2-s 的 SED 模型
   - 强时间建模能力
   - 音频事件检测与分类结合
   - 时序一致性约束

2. **7 模型集成策略**
   - 不同 backbone：EfficientNetV2-s, ResNet, ConvNeXt
   - 不同输入尺寸和配置
   - 不同 Mel 参数组合
   - 加权集成代替简单平均

3. **数据增强**
   - SpecAugment（时间/频率掩码）
   - MixUp 数据混合
   - 颜色噪声注入
   - 音频速度和音调变化

4. **损失函数**
   - BCE Loss（Binary Cross Entropy）
   - Focal Loss 处理类别不平衡
   - Label Smoothing
   - 辅助损失函数

**实现细节**：
- EfficientNetV2-s backbone
- SED 框架 + 自定义 CNN
- 7 个模型集成
- Mel 参数：n_mels=128-256 不同配置
- 数据增强：SpecAugment + MixUp + 颜色噪声
- 推理优化：模型并行 + 批处理

**代码仓库**：
- GitHub: [LIHANG-HONG/birdclef2023-2nd-place-solution](https://github.com/LIHANG-HONG/birdclef2023-2nd-place-solution)
- Kaggle Writeup: [2nd place solution: SED + CNN with 7 models ensemble](https://www.kaggle.com/competitions/birdclef-2023/writeups/griffith-2nd-place-solution-sed-cnn-with-7-models-)

---

### 3rd Place - ADSR

**最终成绩**：~0.75（Private LB）

**核心策略**：SED with attention on Mel frequency bands

**关键技术**：

1. **Mel 频域注意力机制**
   - 在 Mel 频率维度上添加注意力
   - 自适应频率加权
   - 频带重要性学习
   - 多尺度频谱分析

2. **改进的 SED 框架**
   - CNN + RNN 混合架构
   - 双向 LSTM 时序建模
   - CRF 层优化时序一致性
   - 多任务学习

3. **特征工程**
   - 多尺度 Mel-spectrogram
   - MFCC 特征
   - 频谱对比度增强
   - 时频域联合分析

4. **训练策略**
   - 课程学习（从简单到困难）
   - 难样本挖掘
   - 在线难样本挖掘（OHEM）
   - 渐进式训练

**实现细节**：
- 改进的 SED 架构
- Mel 频域注意力机制
- 双向 LSTM 时序建模
- 多任务学习框架
- 课程学习策略

**代码仓库**：
- Kaggle Writeup: [3rd place solution: SED with attention on Mel frequency bands](https://www.kaggle.com/competitions/birdclef-2023/writeups/adsr-3rd-place-solution-sed-with-attention-on-mel-)

---

### 4th Place - ATFujita

**最终成绩**：0.74424（Private LB）

**核心策略**：Knowledge Distillation Is All You Need

**关键技术**：

1. **知识蒸馏（Knowledge Distillation）**
   - 使用 Kaggle Models 的 bird-vocalization-classifier 作为教师模型
   - 预计算教师模型预测
   - 蒸馏损失：KL 散度 + 学生损失
   - 温度参数调优

2. **Xeno-Canto 数据集成**
   - 收集额外 Xeno-Canto 数据
   - 数据过滤和质量控制
   - 领域自适应
   - 数据重采样

3. **预训练策略**
   - 在 Xeno-Canto 上预训练
   - 在竞赛数据上微调
   - 渐进式解冻
   - 学习率调度

4. **集成策略**
   - 4 个模型集成
   - 不同 backbone
   - Checkpoint averaging
   - 时序平滑

**实现细节**：
- BaseModel + Knowledge Distillation
- 4 个模型集成
- Xeno-Canto 预训练
- Mel 参数：n_mels=128, fmin=64, fmax=16000
- 数据增强：标准 SpecAugment
- 推理优化：模型量化

**代码仓库**：
- GitHub: [AtsunoriFujita/BirdCLEF-2023-Identify-bird-calls-in-soundscapes](https://github.com/AtsunoriFujita/BirdCLEF-2023-Identify-bird-calls-in-soundscapes)
- Kaggle Writeup: [4th Place Solution: Knowledge Distillation Is All You Need](https://www.kaggle.com/competitions/birdclef-2023/writeups/atfujita-4th-place-solution-knowledge-distillation)

**关键创新**：
- 使用预训练的 bird-vocalization-classifier 作为教师模型
- 蒸馏损失与标准损失的加权组合
- 高效的伪标签生成
- 领域自适应技术

---

### 5th Place - Yevhenii Maslov

**最终成绩**：~0.74（Private LB）

**核心策略**：外部数据 + 预训练 + 集成

**关键技术**：

1. **外部数据利用**
   - 2023/2022/2021 竞赛数据
   - Xeno-Canto 数据（2023 物种）
   - 数据过滤和清洗
   - 数据平衡策略

2. **预训练和微调**
   - 在外部数据上预训练
   - 在竞赛数据上微调
   - 分层学习率
   - 渐进式训练

3. **模型架构**
   - EfficientNetV2 系列
   - SED 框架
   - 注意力机制
   - 多尺度特征融合

4. **推理优化**
   - 模型量化（INT8）
   - 多线程推理
   - 批处理优化
   - ONNX 导出

**实现细节**：
- EfficientNetV2 backbone
- SED 框架
- 外部数据预训练
- 5+ 模型集成
- Mel 参数：标准配置
- 推理优化：量化 + 多线程

**代码仓库**：
- GitHub: [yevmaslov](https://github.com/yevmaslov)
- Kaggle Writeup: [5th place solution](https://www.kaggle.com/competitions/birdclef-2023/writeups/yevhenii-maslov-5th-place-solution)

---

### 8th Place - FURU-NAG

**最终成绩**：~0.73（Private LB）

**核心策略**：Implementing Multimodal Data Augmentation Methods

**关键技术**：

1. **多模态数据增强**
   - 波形级增强：音调变化、时间拉伸、噪声注入
   - 频谱级增强：SpecAugment、频率掩码、时间掩码
   - 混合增强：MixUp、CutMix
   - 自适应增强策略

2. **防止过拟合**
   - 现实音频组合
   - 增强强度调度
   - 在线增强
   - 增强多样性

3. **预处理管道**
   - 音频质量检查
   - 噪声过滤
   - 音频归一化
   - 特征标准化

**实现细节**：
- 多模态数据增强管道
- 防止过拟合的策略
- 现实音频组合
- 自适应增强

**代码仓库**：
- Kaggle Writeup: [8th Place Solution: Implementing Multimodal Data Augmentation Methods](https://www.kaggle.com/competitions/birdclef-2023/writeups/furu-nag-8th-place-solution-implementing-multimoda)

---

### 18th Place - SED with Attention

**核心策略**：SED with attention

**关键技术**：

1. **注意力机制**
   - 时间注意力
   - 频率注意力
   - 自注意力
   - 交叉注意力

2. **SED 框架改进**
   - 改进的时序建模
   - 多尺度特征提取
   - 注意力加权
   - 残差连接

**代码仓库**：
- Kaggle Writeup: [18th place solution: SED with attention](https://www.kaggle.com/competitions/birdclef-2023/writeups/18th-place-solution-sed-with-attention)

---

## Code Templates（代码模板）

### 1. Mel-Spectrogram 特征提取

```python
import torch
import torchaudio
import torch.nn as nn
import numpy as np
import librosa

class MelSpectrogramExtractor:
    """BirdCLEF 2023 统一 Mel-Spectrogram 提取器"""

    def __init__(
        self,
        sample_rate: int = 32000,
        n_mels: int = 128,
        n_fft: int = 2048,
        hop_length: int = 512,
        fmin: float = 64.0,
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
    "config_128": {  # EfficientNetV2-s 标准
        "n_mels": 128,
        "n_fft": 2048,
        "hop_length": 512,
        "fmin": 64.0,
        "fmax": 16000.0,
    },
    "config_256": {  # 高分辨率
        "n_mels": 256,
        "n_fft": 4096,
        "hop_length": 1024,
        "fmin": 64.0,
        "fmax": 16000.0,
    },
}

# 使用示例
extractor = MelSpectrogramExtractor(**CONFIGS["config_128"])
waveform, sr = torchaudio.load("audio.wav")
if sr != 32000:
    waveform = torchaudio.transforms.Resample(sr, 32000)(waveform)
mel_spec = extractor.extract_fixed_length(waveform.squeeze(0), target_length=313)  # 5秒 -> 313帧
```

### 2. SED 模型架构（2nd Place 风格）

```python
import torch
import torch.nn as nn
import timm

class SEDModel(nn.Module):
    """
    Sound Event Detection 模型
    基于 2nd Place Griffith 的方案
    """

    def __init__(
        self,
        model_name: str = "tf_efficientnetv2_s",
        num_classes: int = 264,
        pretrained: bool = True,
        in_channels: int = 1,
        rnn_layers: int = 1,
        rnn_hidden: int = 128,
    ):
        super().__init__()

        # Backbone（EfficientNetV2）
        self.backbone = timm.create_model(
            model_name,
            pretrained=pretrained,
            in_chans=in_channels,
            num_classes=0,  # 移除分类头
            global_pool="",  # 移除全局池化
        )

        # 获取 backbone 特征维度
        backbone_features = self.backbone.num_features

        # RNN 层（时序建模）
        self.rnn = nn.LSTM(
            input_size=backbone_features,
            hidden_size=rnn_hidden,
            num_layers=rnn_layers,
            batch_first=True,
            bidirectional=True,
        )

        # 分类头
        self.classifier = nn.Sequential(
            nn.Linear(rnn_hidden * 2, rnn_hidden),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(rnn_hidden, num_classes),
        )

    def forward(self, x, return_segmentwise=False):
        """
        Args:
            x: (batch, channels, n_mels, time)
            return_segmentwise: 是否返回分段预测

        Returns:
            logits: (batch, num_classes) 或 (batch, time, num_classes)
        """
        batch_size = x.size(0)

        # Backbone 特征提取
        # (batch, channels, n_mels, time) -> (batch, features, time')
        features = self.backbone(x)

        # 转置为 (batch, time', features)
        features = features.permute(0, 2, 1)

        # RNN 时序建模
        # (batch, time', features) -> (batch, time', rnn_hidden * 2)
        rnn_out, _ = self.rnn(features)

        if return_segmentwise:
            # 分段预测（每个时间步）
            segmentwise_logits = self.classifier(rnn_out)
            return segmentwise_logits
        else:
            # 全局预测（时间平均池化）
            global_features = rnn_out.mean(dim=1)  # (batch, rnn_hidden * 2)
            logits = self.classifier(global_features)
            return logits


# 使用示例
model = SEDModel(
    model_name="tf_efficientnetv2_s",
    num_classes=264,
    pretrained=True,
    in_channels=1,
    rnn_layers=1,
    rnn_hidden=128,
)

# 前向传播
mel_spec = torch.randn(4, 1, 128, 313)  # (batch, channels, n_mels, time)
logits = model(mel_spec)  # (batch, 264)
segmentwise_logits = model(mel_spec, return_segmentwise=True)  # (batch, time, 264)
```

### 3. 带 Mel 频域注意力的 SED 模型（3rd Place 风格）

```python
import torch
import torch.nn as nn
import torch.nn.functional as F
import timm

class MelFrequencyAttention(nn.Module):
    """Mel 频域注意力机制（3rd Place ADSR）"""

    def __init__(self, n_mels: int, reduction: int = 8):
        super().__init__()
        self.avg_pool = nn.AdaptiveAvgPool2d(1)
        self.max_pool = nn.AdaptiveMaxPool2d(1)

        self.fc = nn.Sequential(
            nn.Linear(n_mels, n_mels // reduction, bias=False),
            nn.ReLU(inplace=True),
            nn.Linear(n_mels // reduction, n_mels, bias=False),
        )
        self.sigmoid = nn.Sigmoid()

    def forward(self, x):
        """
        Args:
            x: (batch, channels, n_mels, time)

        Returns:
            attention: (batch, channels, n_mels, 1)
        """
        # 全局平均池化和最大池化
        avg_out = self.avg_pool(x).squeeze(-1).squeeze(-1)  # (batch, channels)
        max_out = self.max_pool(x).squeeze(-1).squeeze(-1)  # (batch, channels)

        # 通过 FC 层
        avg_out = self.fc(avg_out)
        max_out = self.fc(max_out)

        # 合并并应用 sigmoid
        attention = self.sigmoid(avg_out + max_out)
        attention = attention.unsqueeze(-1).unsqueeze(-1)  # (batch, channels, n_mels, 1)

        return attention


class SEDWithMelAttention(nn.Module):
    """带 Mel 频域注意力的 SED 模型"""

    def __init__(
        self,
        model_name: str = "tf_efficientnetv2_s",
        num_classes: int = 264,
        pretrained: bool = True,
        n_mels: int = 128,
        rnn_hidden: int = 128,
    ):
        super().__init__()

        # Backbone
        self.backbone = timm.create_model(
            model_name,
            pretrained=pretrained,
            in_chans=1,
            num_classes=0,
            global_pool="",
        )

        backbone_features = self.backbone.num_features

        # Mel 频域注意力
        self.mel_attention = MelFrequencyAttention(n_mels=n_mels)

        # RNN 层
        self.rnn = nn.LSTM(
            input_size=backbone_features,
            hidden_size=rnn_hidden,
            num_layers=1,
            batch_first=True,
            bidirectional=True,
        )

        # 分类头
        self.classifier = nn.Sequential(
            nn.Linear(rnn_hidden * 2, rnn_hidden),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(rnn_hidden, num_classes),
        )

    def forward(self, x, return_segmentwise=False):
        """
        Args:
            x: (batch, 1, n_mels, time)

        Returns:
            logits: (batch, num_classes)
        """
        # Backbone 特征
        features = self.backbone(x)  # (batch, features, time')

        # 应用 Mel 频域注意力
        mel_att = self.mel_attention(features)  # (batch, features, n_mels, 1)
        features = features * mel_att

        # 转置
        features = features.permute(0, 2, 1)  # (batch, time', features)

        # RNN
        rnn_out, _ = self.rnn(features)

        if return_segmentwise:
            segmentwise_logits = self.classifier(rnn_out)
            return segmentwise_logits
        else:
            global_features = rnn_out.mean(dim=1)
            logits = self.classifier(global_features)
            return logits


# 使用示例
model = SEDWithMelAttention(
    model_name="tf_efficientnetv2_s",
    num_classes=264,
    pretrained=True,
    n_mels=128,
    rnn_hidden=128,
)
```

### 4. 数据增强（8th Place 风格）

```python
import torch
import torchaudio
import numpy as np

class AudioAugmentation:
    """多模态音频增强（8th Place FURU-NAG）"""

    def __init__(
        self,
        sample_rate: int = 32000,
        apply_prob: float = 0.5,
    ):
        self.sample_rate = sample_rate
        self.apply_prob = apply_prob

    def __call__(self, waveform: torch.Tensor) -> torch.Tensor:
        """应用随机增强"""
        if torch.rand(1).item() > self.apply_prob:
            return waveform

        # 随机选择增强方法
        augmentations = [
            self._pitch_shift,
            self._time_stretch,
            self._add_noise,
            self._gain,
        ]

        np.random.shuffle(augmentations)

        # 应用 1-2 种增强
        num_augment = np.random.randint(1, 3)
        for aug in augmentations[:num_augment]:
            waveform = aug(waveform)

        return waveform

    def _pitch_shift(self, waveform: torch.Tensor) -> torch.Tensor:
        """音调变化"""
        if torch.rand(1).item() > 0.5:
            return waveform

        n_steps = np.random.uniform(-2, 2)  # 半音
        waveform_np = waveform.numpy()

        # 使用 librosa 进行音调变化
        shifted = librosa.effects.pitch_shift(
            waveform_np,
            sr=self.sample_rate,
            n_steps=n_steps,
        )

        return torch.from_numpy(shifted).float()

    def _time_stretch(self, waveform: torch.Tensor) -> torch.Tensor:
        """时间拉伸"""
        if torch.rand(1).item() > 0.5:
            return waveform

        rate = np.random.uniform(0.8, 1.2)
        waveform_np = waveform.numpy()

        # 使用 librosa 进行时间拉伸
        stretched = librosa.effects.time_stretch(
            waveform_np,
            rate=rate,
        )

        return torch.from_numpy(stretched).float()

    def _add_noise(self, waveform: torch.Tensor) -> torch.Tensor:
        """添加噪声"""
        if torch.rand(1).item() > 0.5:
            return waveform

        snr = np.random.uniform(10, 30)  # 信噪比
        noise = torch.randn_like(waveform)

        # 计算噪声功率
        signal_power = waveform.mean() ** 2
        noise_power = noise.mean() ** 2

        # 调整噪声功率
        noise = noise * torch.sqrt(signal_power / (noise_power * (10 ** (snr / 10))))

        return waveform + noise

    def _gain(self, waveform: torch.Tensor) -> torch.Tensor:
        """增益调整"""
        if torch.rand(1).item() > 0.5:
            return waveform

        gain = np.random.uniform(0.8, 1.2)
        return waveform * gain


class SpecAugment:
    """SpecAugment 增强（频谱增强）"""

    def __init__(
        self,
        time_mask_param: int = 50,
        freq_mask_param: int = 16,
        num_time_masks: int = 2,
        num_freq_masks: int = 2,
        apply_prob: float = 0.5,
    ):
        self.time_mask_param = time_mask_param
        self.freq_mask_param = freq_mask_param
        self.num_time_masks = num_time_masks
        self.num_freq_masks = num_freq_masks
        self.apply_prob = apply_prob

    def __call__(self, spec: torch.Tensor) -> torch.Tensor:
        """
        Args:
            spec: (channels, n_mels, time)

        Returns:
            augmented_spec: (channels, n_mels, time)
        """
        if torch.rand(1).item() > self.apply_prob:
            return spec

        # 时间掩码
        for _ in range(self.num_time_masks):
            t = np.random.randint(0, self.time_mask_param)
            t0 = np.random.randint(0, max(1, spec.size(-1) - t))
            spec[:, :, t0:t0 + t] = 0

        # 频率掩码
        for _ in range(self.num_freq_masks):
            f = np.random.randint(0, self.freq_mask_param)
            f0 = np.random.randint(0, max(1, spec.size(-2) - f))
            spec[:, f0:f0 + f, :] = 0

        return spec


class MixUp:
    """MixUp 数据增强"""

    def __init__(self, alpha: float = 0.5, apply_prob: float = 0.5):
        self.alpha = alpha
        self.apply_prob = apply_prob

    def __call__(
        self,
        mel_spec: torch.Tensor,
        labels: torch.Tensor,
    ) -> tuple[torch.Tensor, torch.Tensor]:
        """
        Args:
            mel_spec: (batch, channels, n_mels, time)
            labels: (batch, num_classes)

        Returns:
            mixed_mel, mixed_labels
        """
        if torch.rand(1).item() > self.apply_prob:
            return mel_spec, labels

        batch_size = mel_spec.size(0)

        # 生成混合权重
        lam = np.random.beta(self.alpha, self.alpha)

        # 随机排列
        index = torch.randperm(batch_size)

        # 混合特征和标签
        mixed_mel = lam * mel_spec + (1 - lam) * mel_spec[index]
        mixed_labels = lam * labels + (1 - lam) * labels[index]

        return mixed_mel, mixed_labels


# 使用示例
audio_aug = AudioAugmentation(sample_rate=32000, apply_prob=0.8)
spec_aug = SpecAugment(
    time_mask_param=50,
    freq_mask_param=16,
    num_time_masks=2,
    num_freq_masks=2,
    apply_prob=0.8,
)
mixup = MixUp(alpha=0.5, apply_prob=0.5)

# 音频增强
waveform = torchaudio.load("audio.wav")[0]
augmented_waveform = audio_aug(waveform)

# 频谱增强
mel_spec = torch.randn(4, 1, 128, 313)
augmented_spec = spec_aug(mel_spec)

# MixUp
labels = torch.randint(0, 2, (4, 264)).float()
mixed_spec, mixed_labels = mixup(mel_spec, labels)
```

### 5. 损失函数

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class FocalLoss(nn.Module):
    """Focal Loss（处理类别不平衡）"""

    def __init__(
        self,
        alpha: float = 0.25,
        gamma: float = 2.0,
        reduction: str = "mean",
    ):
        super().__init__()
        self.alpha = alpha
        self.gamma = gamma
        self.reduction = reduction

    def forward(self, inputs: torch.Tensor, targets: torch.Tensor) -> torch.Tensor:
        """
        Args:
            inputs: (batch, num_classes) - logits
            targets: (batch, num_classes) - one-hot or multi-hot labels

        Returns:
            loss
        """
        bce_loss = F.binary_cross_entropy_with_logits(
            inputs, targets, reduction="none"
        )

        pt = torch.exp(-bce_loss)
        focal_loss = self.alpha * (1 - pt) ** self.gamma * bce_loss

        if self.reduction == "mean":
            return focal_loss.mean()
        elif self.reduction == "sum":
            return focal_loss.sum()
        else:
            return focal_loss


class CombinedLoss(nn.Module):
    """组合损失（BCE + Focal Loss）"""

    def __init__(
        self,
        bce_weight: float = 0.5,
        focal_weight: float = 0.5,
        focal_alpha: float = 0.25,
        focal_gamma: float = 2.0,
        label_smoothing: float = 0.0,
    ):
        super().__init__()
        self.bce_weight = bce_weight
        self.focal_weight = focal_weight

        self.focal_loss = FocalLoss(
            alpha=focal_alpha,
            gamma=focal_gamma,
        )

        self.label_smoothing = label_smoothing

    def forward(
        self,
        inputs: torch.Tensor,
        targets: torch.Tensor,
    ) -> torch.Tensor:
        """
        Args:
            inputs: (batch, num_classes) - logits
            targets: (batch, num_classes) - multi-hot labels

        Returns:
            loss
        """
        # Label smoothing
        if self.label_smoothing > 0:
            targets = targets * (1 - self.label_smoothing) + \
                      self.label_smoothing / targets.size(-1)

        # BCE Loss
        bce_loss = F.binary_cross_entropy_with_logits(inputs, targets)

        # Focal Loss
        focal_loss = self.focal_loss(inputs, targets)

        # 组合
        loss = self.bce_weight * bce_loss + self.focal_weight * focal_loss

        return loss


class KnowledgeDistillationLoss(nn.Module):
    """知识蒸馏损失（4th Place）"""

    def __init__(
        self,
        temperature: float = 4.0,
        alpha: float = 0.7,  # 蒸馏损失权重
    ):
        super().__init__()
        self.temperature = temperature
        self.alpha = alpha

    def forward(
        self,
        student_logits: torch.Tensor,
        teacher_logits: torch.Tensor,
        targets: torch.Tensor,
    ) -> torch.Tensor:
        """
        Args:
            student_logits: (batch, num_classes) - 学生模型预测
            teacher_logits: (batch, num_classes) - 教师模型预测（预计算）
            targets: (batch, num_classes) - 真实标签

        Returns:
            loss
        """
        # 蒸馏损失（KL 散度）
        T = self.temperature

        # Soft targets
        soft_teacher = F.softmax(teacher_logits / T, dim=-1)
        soft_student = F.log_softmax(student_logits / T, dim=-1)

        distillation_loss = F.kl_div(
            soft_student,
            soft_teacher,
            reduction="batchmean",
        ) * (T ** 2)

        # 学生损失（标准 BCE）
        student_loss = F.binary_cross_entropy_with_logits(
            student_logits,
            targets,
        )

        # 组合
        loss = self.alpha * distillation_loss + (1 - self.alpha) * student_loss

        return loss


# 使用示例
criterion = CombinedLoss(
    bce_weight=0.5,
    focal_weight=0.5,
    focal_alpha=0.25,
    focal_gamma=2.0,
    label_smoothing=0.1,
)

logits = torch.randn(4, 264)
targets = torch.randint(0, 2, (4, 264)).float()

loss = criterion(logits, targets)
print(f"Combined Loss: {loss.item()}")

# 知识蒸馏
kd_criterion = KnowledgeDistillationLoss(
    temperature=4.0,
    alpha=0.7,
)

student_logits = torch.randn(4, 264)
teacher_logits = torch.randn(4, 264)  # 预计算的教师预测

kd_loss = kd_criterion(student_logits, teacher_logits, targets)
print(f"KD Loss: {kd_loss.item()}")
```

---

## Best Practices（最佳实践）

### 1. 数据处理最佳实践

#### 1.1 音频质量筛选（1st Place）

```python
import librosa
import numpy as np

def calculate_snr(audio: np.ndarray, sample_rate: int) -> float:
    """计算信噪比（SNR）"""
    # 使用能量计算 SNR
    frame_length = 2048
    frames = librosa.util.frame(audio, frame_length=frame_length, hop_length=512)

    # 计算每帧能量
    energies = np.mean(frames ** 2, axis=0)

    # 信号能量：高能量帧
    signal_energy = np.percentile(energies, 90)
    # 噪声能量：低能量帧
    noise_energy = np.percentile(energies, 10)

    snr = 10 * np.log10(signal_energy / (noise_energy + 1e-9))
    return snr

def filter_audio_by_quality(
    audio_path: str,
    min_snr: float = 10.0,
    max_duration: float = 60.0,
) -> bool:
    """根据质量筛选音频"""
    try:
        audio, sr = librosa.load(audio_path, sr=32000)

        # 检查 SNR
        snr = calculate_snr(audio, sr)
        if snr < min_snr:
            return False

        # 检查时长
        duration = len(audio) / sr
        if duration > max_duration:
            return False

        # 检查是否静音
        rms = librosa.feature.rms(y=audio)[0]
        if np.mean(rms) < 0.01:
            return False

        return True

    except Exception as e:
        print(f"Error loading {audio_path}: {e}")
        return False


# 使用示例
is_good_quality = filter_audio_by_quality("audio.wav", min_snr=10.0)
```

#### 1.2 外部数据集成（4th/5th Place）

```python
from pathlib import Path
import pandas as pd

def load_external_data(
    data_dir: str,
    species_list: list[str],
    min_samples_per_species: int = 5,
) -> pd.DataFrame:
    """加载外部数据（Xeno-Canto）"""
    data_dir = Path(data_dir)

    all_records = []

    for species in species_list:
        species_dir = data_dir / species
        if not species_dir.exists():
            continue

        audio_files = list(species_dir.glob("*.wav")) + \
                      list(species_dir.glob("*.mp3"))

        # 过滤样本数少的物种
        if len(audio_files) < min_samples_per_species:
            continue

        for audio_file in audio_files:
            all_records.append({
                "filename": str(audio_file),
                "species": species,
                "source": "xeno_canto",
            })

    return pd.DataFrame(all_records)


# 使用示例
species_list = ["bird_a", "bird_b", "bird_c"]
external_df = load_external_data(
    "data/xeno_canto",
    species_list,
    min_samples_per_species=5,
)
```

### 2. 训练策略最佳实践

#### 2.1 两阶段训练（1st/4th Place）

```python
import torch
import torch.nn as nn
from torch.utils.data import DataLoader

def two_stage_training(
    model: nn.Module,
    train_loader_external: DataLoader,
    train_loader_competition: DataLoader,
    val_loader: DataLoader,
    num_epochs_stage1: int = 10,
    num_epochs_stage2: int = 20,
    lr_stage1: float = 1e-3,
    lr_stage2: float = 1e-4,
):
    """两阶段训练：外部数据预训练 + 竞赛数据微调"""

    # Stage 1: 在外部数据上预训练
    print("Stage 1: Pre-training on external data")
    optimizer = torch.optim.AdamW(model.parameters(), lr=lr_stage1)
    criterion = nn.BCEWithLogitsLoss()

    for epoch in range(num_epochs_stage1):
        model.train()
        for batch in train_loader_external:
            mel_spec = batch["mel_spec"].cuda()
            labels = batch["labels"].cuda()

            # 前向传播
            logits = model(mel_spec)
            loss = criterion(logits, labels)

            # 反向传播
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

        # 验证
        val_loss = validate(model, val_loader, criterion)
        print(f"Epoch {epoch+1}/{num_epochs_stage1}, Val Loss: {val_loss:.4f}")

    # Stage 2: 在竞赛数据上微调
    print("Stage 2: Fine-tuning on competition data")
    optimizer = torch.optim.AdamW(model.parameters(), lr=lr_stage2)

    for epoch in range(num_epochs_stage2):
        model.train()
        for batch in train_loader_competition:
            mel_spec = batch["mel_spec"].cuda()
            labels = batch["labels"].cuda()

            # 前向传播
            logits = model(mel_spec)
            loss = criterion(logits, labels)

            # 反向传播
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

        # 验证
        val_loss = validate(model, val_loader, criterion)
        print(f"Epoch {epoch+1}/{num_epochs_stage2}, Val Loss: {val_loss:.4f}")

    return model


def validate(model: nn.Module, val_loader: DataLoader, criterion: nn.Module):
    """验证"""
    model.eval()
    total_loss = 0

    with torch.no_grad():
        for batch in val_loader:
            mel_spec = batch["mel_spec"].cuda()
            labels = batch["labels"].cuda()

            logits = model(mel_spec)
            loss = criterion(logits, labels)

            total_loss += loss.item()

    return total_loss / len(val_loader)
```

#### 2.2 Checkpoint Averaging（2nd/4th Place）

```python
import torch
from pathlib import Path

def average_checkpoints(
    checkpoint_paths: list[str],
    output_path: str,
):
    """平均多个 checkpoint"""
    # 加载所有 checkpoint
    checkpoints = []
    for path in checkpoint_paths:
        ckpt = torch.load(path, map_location="cpu")
        checkpoints.append(ckpt)

    # 获取第一个 checkpoint 的结构
    avg_state_dict = checkpoints[0]["model_state_dict"].copy()

    # 计算平均
    for key in avg_state_dict.keys():
        tensors = [ckpt["model_state_dict"][key] for ckpt in checkpoints]
        avg_state_dict[key] = torch.stack(tensors).mean(dim=0)

    # 保存
    torch.save({
        "model_state_dict": avg_state_dict,
        "epoch": sum([ckpt["epoch"] for ckpt in checkpoints]) // len(checkpoints),
    }, output_path)

    print(f"Averaged checkpoint saved to {output_path}")


# 使用示例
checkpoint_dir = Path("checkpoints")
checkpoint_paths = [
    str(checkpoint_dir / "model_epoch_13.pt"),
    str(checkpoint_dir / "model_epoch_15.pt"),
    str(checkpoint_dir / "model_epoch_17.pt"),
    str(checkpoint_dir / "model_epoch_19.pt"),
    str(checkpoint_dir / "model_epoch_20.pt"),
]

average_checkpoints(
    checkpoint_paths,
    "checkpoints/model_averaged.pt",
)
```

### 3. 推理优化最佳实践

#### 3.1 模型量化（5th Place）

```python
import torch
import torch.nn as nn

def quantize_model(
    model: nn.Module,
    calibration_loader: DataLoader,
):
    """量化模型到 INT8"""
    # 动态量化
    quantized_model = torch.quantization.quantize_dynamic(
        model,
        {nn.Linear, nn.Conv2d},
        dtype=torch.qint8,
    )

    # 校准（静态量化需要）
    # quantized_model.eval()
    # with torch.no_grad():
    #     for batch in calibration_loader:
    #         _ = quantized_model(batch["mel_spec"])

    return quantized_model


# 使用示例
quantized_model = quantize_model(model, val_loader)
torch.save(quantized_model.state_dict(), "model_quantized.pt")
```

#### 3.2 ONNX 导出和优化

```python
import torch
import torch.onnx
import onnxruntime as ort

def export_to_onnx(
    model: nn.Module,
    output_path: str,
    input_shape: tuple = (1, 1, 128, 313),
    opset_version: int = 13,
):
    """导出模型到 ONNX"""
    model.eval()

    # 创建示例输入
    dummy_input = torch.randn(*input_shape)

    # 导出
    torch.onnx.export(
        model,
        dummy_input,
        output_path,
        opset_version=opset_version,
        input_names=["mel_spec"],
        output_names=["logits"],
        dynamic_axes={
            "mel_spec": {0: "batch_size"},
            "logits": {0: "batch_size"},
        },
    )

    print(f"Model exported to {output_path}")

    # 优化 ONNX 模型
    sess_options = ort.SessionOptions()
    sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL

    session = ort.InferenceSession(
        output_path,
        sess_options,
        providers=["CPUExecutionProvider"],
    )

    return session


# 使用示例
onnx_session = export_to_onnx(
    model,
    "model.onnx",
    input_shape=(1, 1, 128, 313),
)

# ONNX 推理
def predict_onnx(session: ort.InferenceSession, mel_spec: np.ndarray):
    """使用 ONNX Runtime 推理"""
    inputs = {session.get_inputs()[0].name: mel_spec}
    outputs = session.run(None, inputs)

    return outputs[0]


# 批量推理
def batch_predict_onnx(
    session: ort.InferenceSession,
    mel_specs: np.ndarray,
    batch_size: int = 32,
):
    """批量推理"""
    predictions = []

    for i in range(0, len(mel_specs), batch_size):
        batch = mel_specs[i:i+batch_size]
        batch_pred = predict_onnx(session, batch)
        predictions.append(batch_pred)

    return np.concatenate(predictions, axis=0)
```

### 4. 集成策略最佳实践

#### 4.1 加权集成（2nd Place）

```python
import numpy as np
from scipy.optimize import minimize

def find_optimal_weights(
    predictions: np.ndarray,
    targets: np.ndarray,
) -> np.ndarray:
    """
    找到最优集成权重

    Args:
        predictions: (num_models, num_samples, num_classes)
        targets: (num_samples, num_classes)

    Returns:
        weights: (num_models,)
    """
    num_models = predictions.shape[0]

    def objective(weights):
        # 加权平均
        weighted_pred = np.average(predictions, axis=0, weights=weights)
        # 计算 AUC（简化版）
        auc = compute_auc(weighted_pred, targets)
        return -auc  # 最小化负 AUC

    # 约束：权重和为 1
    constraints = {"type": "eq", "fun": lambda w: np.sum(w) - 1}
    bounds = [(0, 1) for _ in range(num_models)]

    # 初始权重：平均
    initial_weights = np.ones(num_models) / num_models

    # 优化
    result = minimize(
        objective,
        initial_weights,
        method="SLSQP",
        bounds=bounds,
        constraints=constraints,
    )

    return result.x


def compute_auc(predictions: np.ndarray, targets: np.ndarray) -> float:
    """计算 AUC（简化版）"""
    from sklearn.metrics import roc_auc_score
    return roc_auc_score(targets, predictions, average="macro")


# 使用示例
# predictions: (num_models, num_samples, num_classes)
predictions = np.random.rand(5, 1000, 264)
targets = np.random.randint(0, 2, (1000, 264))

optimal_weights = find_optimal_weights(predictions, targets)
print(f"Optimal weights: {optimal_weights}")

# 加权集成
final_predictions = np.average(predictions, axis=0, weights=optimal_weights)
```

#### 4.2 Min/Max Ensemble（1st Place 风格）

```python
import numpy as np

def min_ensemble(predictions: np.ndarray) -> np.ndarray:
    """
    Min 集成（降低不确定预测）

    Args:
        predictions: (num_models, num_samples, num_classes)

    Returns:
        ensemble: (num_samples, num_classes)
    """
    return np.min(predictions, axis=0)


def max_ensemble(predictions: np.ndarray) -> np.ndarray:
    """
    Max 集成（增强高置信预测）

    Args:
        predictions: (num_models, num_samples, num_classes)

    Returns:
        ensemble: (num_samples, num_classes)
    """
    return np.max(predictions, axis=0)


def rank_ensemble(
    predictions: np.ndarray,
    method: str = "geometric",
) -> np.ndarray:
    """
    Rank 集成（基于排名的集成）

    Args:
        predictions: (num_models, num_samples, num_classes)
        method: "geometric" or "arithmetic"

    Returns:
        ensemble: (num_samples, num_classes)
    """
    # 计算排名
    ranks = np.zeros_like(predictions)
    for i in range(predictions.shape[0]):
        ranks[i] = scipy.stats.rankdata(predictions[i], axis=-1)

    # 平均排名
    if method == "geometric":
        avg_ranks = np.exp(np.mean(np.log(ranks + 1), axis=0)) - 1
    else:  # arithmetic
        avg_ranks = np.mean(ranks, axis=0)

    # 将排名转回概率
    ensemble = avg_ranks / avg_ranks.sum(axis=-1, keepdims=True)

    return ensemble


# 使用示例
predictions = np.random.rand(5, 1000, 264)

min_pred = min_ensemble(predictions)
max_pred = max_ensemble(predictions)
rank_pred = rank_ensemble(predictions, method="geometric")
```

### 5. 后处理最佳实践

#### 5.1 时序平滑（2nd/3rd Place）

```python
import numpy as np
from scipy.ndimage import gaussian_filter1d

def temporal_smoothing(
    predictions: np.ndarray,
    sigma: float = 1.0,
) -> np.ndarray:
    """
    时序平滑（高斯滤波）

    Args:
        predictions: (num_samples, num_classes) - 按时间排序
        sigma: 高斯核标准差

    Returns:
        smoothed: (num_samples, num_classes)
    """
    smoothed = np.zeros_like(predictions)

    for i in range(predictions.shape[1]):
        smoothed[:, i] = gaussian_filter1d(predictions[:, i], sigma=sigma)

    return smoothed


def neighbor_window_smoothing(
    predictions: np.ndarray,
    window_size: int = 5,
    neighbor_weight: float = 0.5,
) -> np.ndarray:
    """
    邻居窗口平滑（2nd Place 风格）

    Args:
        predictions: (num_samples, num_classes)
        window_size: 窗口大小（奇数）
        neighbor_weight: 邻居权重

    Returns:
        smoothed: (num_samples, num_classes)
    """
    half_window = window_size // 2
    smoothed = np.zeros_like(predictions)

    for i in range(len(predictions)):
        # 获取邻居窗口
        start = max(0, i - half_window)
        end = min(len(predictions), i + half_window + 1)

        window = predictions[start:end]

        # 中心样本权重为 1，邻居权重为 neighbor_weight
        weights = np.ones(len(window))
        weights[weights == 1] = neighbor_weight
        weights[len(window) // 2] = 1.0

        # 加权平均
        smoothed[i] = np.average(window, axis=0, weights=weights)

    return smoothed


# 使用示例
predictions = np.random.rand(100, 264)  # 100 个时间步

smoothed_gaussian = temporal_smoothing(predictions, sigma=1.5)
smoothed_neighbor = neighbor_window_smoothing(
    predictions,
    window_size=5,
    neighbor_weight=0.5,
)
```

#### 5.2 基于物种时间的后处理

```python
import numpy as np
import pandas as pd

def species_time_filtering(
    predictions: pd.DataFrame,
    time_info: pd.DataFrame,
    species_activity: dict,
) -> pd.DataFrame:
    """
    基于物种活动时间的后处理

    Args:
        predictions: (num_samples, num_species) - 包含 species columns
        time_info: (num_samples,) - 包含 "time" column
        species_activity: {species: {active_hours: [start, end]}}

    Returns:
        filtered_predictions
    """
    filtered = predictions.copy()

    for species, activity in species_activity.items():
        if species not in predictions.columns:
            continue

        active_hours = activity["active_hours"]  # [start, end]

        # 获取小时
        hours = pd.to_datetime(time_info["time"]).dt.hour

        # 在非活跃时间降低预测
        mask = (hours < active_hours[0]) | (hours > active_hours[1])
        filtered.loc[mask, species] *= 0.5

    return filtered


# 使用示例
predictions_df = pd.DataFrame({
    "bird_a": np.random.rand(100),
    "bird_b": np.random.rand(100),
})

time_info_df = pd.DataFrame({
    "time": pd.date_range("2023-01-01 00:00", periods=100, freq="5min"),
})

species_activity = {
    "bird_a": {"active_hours": [6, 18]},  # 6:00-18:00 活跃
    "bird_b": {"active_hours": [18, 6]},  # 夜间活跃
}

filtered_predictions = species_time_filtering(
    predictions_df,
    time_info_df,
    species_activity,
)
```

---

## 关键技术创新总结

### BirdCLEF 2023 vs 2024 vs 2025 对比

| 维度 | BirdCLEF 2023 | BirdCLEF 2024 | BirdCLEF+ 2025 |
|------|---------------|---------------|----------------|
| **物种数量** | 264 种 | 182 种 | 206 种（多分类群）|
| **评估指标** | Macro AUC-ROC | AUC-ROC | Multi-Label AUC-ROC |
| **外部数据** | Xeno-Canto 重要 | 不用外部数据 | Xeno-Canto 预训练重要 |
| **模型架构** | EfficientNetV2 + SED | EfficientNet B0 + RegNetY | EfficientNet + ViT |
| **损失函数** | BCE + FocalLoss | CE Loss | BCE Loss |
| **伪标签** | 高低阈值筛选 | Google Classifier 预标注 | Noisy Student |
| **推理优化** | PyTorch | OpenVINO | OpenVINO |
| **关键创新** | 数据清洗 + 知识蒸馏 | Statistics T 过滤 | 自蒸馏 + 幂次变换 |

### BirdCLEF 2023 独特创新

1. **数据清洗（1st Place）**
   - 严格的音频质量筛选
   - 基于信噪比的过滤
   - 时间戳验证

2. **知识蒸馏（4th Place）**
   - 使用预训练 bird-vocalization-classifier
   - 蒸馏损失 + 学生损失
   - 温度参数调优

3. **Mel 频域注意力（3rd Place）**
   - 自适应频率加权
   - 多尺度频谱分析
   - 频带重要性学习

4. **多模态增强（8th Place）**
   - 波形级增强
   - 频谱级增强
   - 现实音频组合

---

## 参考资料

### Kaggle Writeups

1. **[1st place solution: Correct Data is All You Need](https://www.kaggle.com/competitions/birdclef-2023/writeups/volodymyr-1st-place-solution-correct-data-is-all-y)** - Volodymyr Sydorskyi
2. **[2nd place solution: SED + CNN with 7 models ensemble](https://www.kaggle.com/competitions/birdclef-2023/writeups/griffith-2nd-place-solution-sed-cnn-with-7-models-)** - Griffith
3. **[3rd place solution: SED with attention on Mel frequency bands](https://www.kaggle.com/competitions/birdclef-2023/writeups/adsr-3rd-place-solution-sed-with-attention-on-mel-)** - ADSR
4. **[4th Place Solution: Knowledge Distillation Is All You Need](https://www.kaggle.com/competitions/birdclef-2023/writeups/atfujita-4th-place-solution-knowledge-distillation)** - ATFujita
5. **[5th place solution](https://www.kaggle.com/competitions/birdclef-2023/writeups/yevhenii-maslov-5th-place-solution)** - Yevhenii Maslov
6. **[8th Place Solution: Implementing Multimodal Data Augmentation Methods](https://www.kaggle.com/competitions/birdclef-2023/writeups/furu-nag-8th-place-solution-implementing-multimoda)** - FURU-NAG
7. **[18th place solution: SED with attention](https://www.kaggle.com/competitions/birdclef-2023/writeups/18th-place-solution-sed-with-attention)**

### GitHub Repositories

1. **[VSydorskyy/BirdCLEF_2023_1st_place](https://github.com/VSydorskyy/BirdCLEF_2023_1st_place)** - 1st Place 代码
2. **[LIHANG-HONG/birdclef2023-2nd-place-solution](https://github.com/LIHANG-HONG/birdclef2023-2nd-place-solution)** - 2nd Place 代码
3. **[AtsunoriFujita/BirdCLEF-2023-Identify-bird-calls-in-soundscapes](https://github.com/AtsunoriFujita/BirdCLEF-2023-Identify-bird-calls-in-soundscapes)** - 4th Place 代码
4. **[yevmaslov](https://github.com/yevmaslov)** - 5th Place 代码

### 学术论文

1. **[Overview of BirdCLEF 2023: Automated Bird Species Identification in Eastern Africa](https://hal.science/hal-05182512/document)** - 竞赛概述
2. **[Acoustic Bird Species Recognition at BirdCLEF 2023](https://ceur-ws.org/Vol-3497/paper-172.pdf)** - 2nd Place 学术论文
3. **[Bird Species Recognition using Convolutional Neural Networks with Attention on Frequency Bands](https://www.researchgate.net/publication/389264675_Bird_Species_Recognition_using_Convolutional_Neural_Networks_with_Attention_on_Frequency_Bands)**

### 技术博客

1. **[(Kaggle) BirdCLEF 2023 - 24th (top 2%) place solution](https://kozistr.tech/2023-05-26-birdcelf-2023/)** - 24th Place 详细方案
2. **[763rd Place Solution for the BirdCLEF 2023 Competition](https://www.kaggle.com/competitions/birdclef-2023/discussion/451041)** - 讨论帖

### 其他资源

1. **[Leaderboard - BirdCLEF 2023](https://www.kaggle.com/competitions/birdclef-2023/leaderboard)** - 最终排行榜
2. **[BirdCLEF 2023 Competition Page](https://www.kaggle.com/competitions/birdclef-2023)** - 竞赛主页
3. **[Xeno-canto Extended Metadata for BirdCLEF2023](https://www.kaggle.com/datasets/mariotsaberlin/xeno-canto-extended-metadata-for-birdclef2023)** - Xeno-Canto 扩展数据集

---

## 总结

BirdCLEF 2023 是一个专注于东非鸟类声音识别的竞赛，其关键特点包括：

1. **数据质量是关键**（1st Place）：严格的音频质量筛选比模型架构更重要
2. **外部数据的战略使用**：Xeno-Canto 数据的合理集成和领域自适应
3. **SED 框架的普及**：前排方案大多采用 SED（Sound Event Detection）框架
4. **知识蒸馏的应用**（4th Place）：使用预训练模型作为教师提升性能
5. **注意力机制的优化**（3rd Place）：Mel 频域注意力机制提升特征提取
6. **多模态数据增强**（8th Place）：波形级和频谱级的联合增强

**与后续版本的主要区别**：
- BirdCLEF 2023 更依赖外部数据（Xeno-Canto）
- BirdCLEF 2024 强调不使用外部数据，关注数据清洗
- BirdCLEF+ 2025 扩展到多分类群（鸟类、两栖、哺乳、昆虫）

**技术演进趋势**：
- 从 EfficientNetV2 → EfficientNet B0/RegNetY
- 从 BCE+Focal Loss → CE Loss → BCE Loss
- 从伪标签高低阈值 → Google Classifier 预标注 → Noisy Student
- 从 PyTorch 推理 → OpenVINO 优化
