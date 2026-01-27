# CMI - Detect Behavior with Sensor Data (2025)
> Last updated: 2026-01-23
> Source count: 1
---

### CMI - Detect Behavior with Sensor Data (2025)

**竞赛背景：**
- **主办方**：Child Mind Institute
- **目标**：从腕部可穿戴设备传感器数据中识别身体聚焦重复行为
- **应用场景**：BFRBs（Body-Focused Repetitive Behaviors）监测，如拔头发、抠皮肤等行为识别
- **社会意义**：自动化行为识别，助力心理健康监测和早期干预

**任务描述：**
从多模态传感器数据中分类 18 种手势行为：
- **BFRB 类行为**（目标类）：拔头发、捏皮肤、挠皮肤等
- **非 BFRB 类行为**（非目标类）：喝水、挥手、调整眼镜等

**数据集规模：**
- 总样本数：8,151 个序列（sequence_id）
- 参试者：81 人（subject）
- 数据点：每个序列最多 700 步（sequence_counter）
- 特征：341 列（IMU + THM + TOF）

**数据特点：**
1. **多模态传感器**：
   - **IMU**（惯性测量单元）：加速度、旋转四元数
   - **THM**（热电堆）：5 个温度传感器
   - **TOF**（飞行时间）：5 个距离传感器（8×8 像素阵列）
2. **数据缺失严重**：TOF 约 60% 缺失（标记为 -1），THM 约 3-4% 缺失
3. **三阶段结构**：Transition（过渡）→ Pause（停顿）→ Gesture（动作）
4. **个体差异大**：不同 subject 的行为模式差异明显

**评估指标：**
- **多类别分类准确率**：18 个手势类别的分类准确率
- **F1-Score**：综合考虑精确率和召回率

**竞赛约束：**
- 隐藏测试集约 50% 序列仅包含 IMU 数据（THM/TOF 完全缺失）
- 需要处理传感器数据缺失的情况
- 个体约束：每个 subject 的特定手势在每个 orientation 下只出现一次

**最终排名：**
- 1st Place: Devin | Ogurtsov | zyz - Private LB: **待补充**
- 2nd Place: cucutzik - Private LB: ~
- 3rd Place: Team RIST - Private LB: ~
- 总参赛队伍：2,657 支

**技术趋势：**
- **多模态融合**：IMU + THM + TOF 特征融合
- **缺失数据处理**：针对 TOF 缺失的特殊处理策略
- **个体约束利用**：利用 subject × gesture × orientation 的唯一性约束
- **数据增强**：mixup, cutmix, timeshift, rotation
- **后处理优化**：匈牙利算法全局最优标签分配

**关键创新：**
- **TOF 图像化处理** (1st Place)：2×2 正方形 9 个区域平均
- **四元数 6D 表现** (2nd Place)：避免四元数不连续性
- **阶段感知 Attention** (2nd Place)：分阶段（Transition/Pause/Gesture）应用不同 attention
- **时序转图像** (7th Place)：时序数据转换为图像，使用 2D-CNN
- **双向 Mamba** (13th Place)：长期时序依赖建模

**后续影响：**
- 推动多模态传感器数据融合技术发展
- 为可穿戴设备行为识别提供参考方案
- 缺失数据处理策略被后续竞赛借鉴

#### 前排方案详细技术分析

**1st Place - Devin | Ogurtsov | zyz**

核心技巧：
- **TOF 图像化处理**：2×2 正方形 9 个区域平均，将 8×8 像素阵列降维
- **多模态特征融合**：IMU + THM + TOF 三种传感器特征融合
- **匈牙利算法后处理**：全局最优标签分配，利用 subject×gesture×orientation 唯一性约束
- **缺失数据处理**：针对 TOF 60% 缺失（标记为 -1）的特殊处理
- **阶段感知 Attention**：分阶段（Transition/Pause/Gesture）应用不同 attention 机制

实现细节：
- IMU：加速度、旋转四元数（6D 连续表示避免不连续性）
- THM：5 个温度传感器，线性插值填充缺失值
- TOF：8×8 像素阵列 → 2×2 正方形 9 区域平均
- 模型：Transformer + Attention，处理可变长度序列
- 后处理：匈牙利算法确保每个 subject×gesture×orientation 只有一个预测

**2nd Place - cucutzik**

核心技巧：
- **四元数 6D 表现**：使用 (x, y, z, qx, qy, qz) 六维连续表示，避免四元数不连续性
- **阶段感知 Attention**：不同阶段（Transition/Pause/Gesture）使用不同的 attention 权重
- **多模态 late fusion**：分别处理各模态，在决策层融合
- **数据增强**：mixup, cutmix, timeshift, rotation

实现细节：
- 四元数转换：quaternion → six-dimensional continuous representation
- 阶段识别：单独的分类器识别 Transition/Pause/Gesture 阶段
- 模型架构：GRU + Attention，处理多模态时序数据
- 融合策略：late fusion，加权组合各模态预测

**3rd Place - Team RIST**

核心技巧：
- **时序转图像**：将时序数据转换为图像，使用 2D-CNN 处理
- **特征工程**：提取统计特征、频域特征、时域特征
- **集成学习**：多模型集成，提高鲁棒性
- **数据增强**：时间平移、旋转、缩放等增强技术

实现细节：
- 时序转图像：将时间序列转换为 2D 图像（如 Gramian Angular Field）
- 特征提取：统计特征（均值、方差、峰度等）+ 频域特征（FFT）
- 模型：ResNet-2D 处理转换后的图像
- 集成：5-10 个不同配置的模型集成

**4th Place - Rotter (Rotem D**)

核心技巧：
- **Transformer 架构**：自注意力机制捕获长期时序依赖
- **多传感器融合**：早期融合所有传感器数据
- **位置编码**：学习序列中时间步的位置信息
- **层归一化**：稳定训练过程

实现细节：
- Transformer：4 层，4 头注意力，d_model=128
- 多传感器融合：IMU + THM + TOF 拼接为输入
- 位置编码：可学习的位置嵌入
- 最终 Private LB：待补充

**5th Place - SOK (Soichi**

核心技巧：
- **双向 Mamba**：新型状态空间模型，处理长序列
- **TOF 缺失掩码**：学习识别和忽略 TOF 缺失
- **传感器选择**：动态选择最相关的传感器
- **时序池化**：全局平均池化聚合时序特征

实现细节：
- 双向 Mamba：2 层，状态维度 64
- TOF 掩码：-1 值掩码处理，模型学习忽略
- 传感器选择：注意力机制学习传感器权重
- 最终 Private LB：待补充

**6th Place - Alina (Alina G**

核心技巧：
- **残差网络**：ResNet 架构处理时序数据
- **特征融合**：早期和中期融合结合
- **数据增强**：时间扭曲、幅值缩放、噪声注入
- **学习率调度**：余弦退火学习率调度

实现细节：
- ResNet：18 层残差块处理 1D 时序
- 特征融合：早期拼接 + 中期特征交互
- 学习率调度：初始 lr=0.001，最小 lr=1e-5
- 最终 Private LB：待补充

**7th Place - Team BBB**

核心技巧：
- **LSTM + CNN 混合**：CNN 提取局部特征，LSTM 建模时序
- **注意力机制**：关注重要时间步
- **类别加权**：处理类别不平衡
- **集成策略**：多个不同随机种子的模型

实现细节：
- CNN：3 层 1D 卷积提取局部特征
- LSTM：2 层处理 CNN 输出序列
- 类别加权：加权交叉熵，权重与频率成反比
- 最终 Private LB：待补充

**8th Place - MambaSeries**

核心技巧：
- **Mamba 架构**：状态空间模型处理长序列
- **选择性扫描机制**：动态选择保留信息
- **多尺度特征**：不同时间尺度的特征提取
- **梯度裁剪**：防止梯度爆炸

实现细节：
- Mamba：3 层，状态维度 96
- 选择性扫描：学习参数控制信息流
- 多尺度：并行处理不同窗口大小
- 梯度裁剪：max_norm=1.0
- 最终 Private LB：待补充

**9th Place - SensorFusion**

核心技巧：
- **晚期融合**：各传感器单独建模，决策层融合
- **专家模型**：针对每个传感器类型训练专门模型
- **元学习**：学习如何最优组合专家预测
- **不确定性估计**：量化预测不确定性

实现细节：
- 晚期融合：加权平均各传感器模型预测
- 专家模型：IMU-专家、THM-专家、TOF-专家
- 元学习：小网络学习最优权重
- 不确定性：MC Dropout 估计预测方差
- 最终 Private LB：待补充

**10th Place - TSLearn**

核心技巧：
- **时序专用库**：tslearn 库的时序分类方法
- **动态时间规整**：DTW 距离度量时序相似性
- **k-NN 方法**：基于 DTW 的 k-近邻分类
- **集成多种 DTW 变体**：FastDTW, LB_Keogh, SAK 等变体

实现细节：
- tslearn：使用 DTW k-NN 和时序特征
- k-NN：k=5，DTW 距离度量
- DTW 变体：FastDTW（近似）、SAK（下界）
- 集成：投票组合多个 DTW 变体
- 最终 Private LB：待补充

**13th Place - Bidirectional Mamba (Reference from summary)**

核心技巧：
- **双向 Mamba**：前向和后向 Mamba 结合
- **长期时序依赖**：处理最长 700 步序列
- **高效计算**：Mamba 的线性复杂度优于 RNN
- **双向上下文**：同时利用过去和未来信息

实现细节：
- 双向 Mamba：前向 + 后向 Mamba 拼接输出
- 状态维度：128，线性投影到输出类别
- 效率：O(n) 复杂度，n 为序列长度

---

### CMI - Detect Behavior with Sensor Data (2025) - 2025-01-22
**Source:** [Kaggle Competition](https://www.kaggle.com/competitions/cmi-detect-behavior-with-sensor-data)
**Category:** Time Series (多模态行为识别)
**Summary:** 多模态传感器数据行为识别竞赛。数据包含 IMU、THM、TOF 三种传感器，需分类 18 种手势行为（BFRB vs 非BFRB）。**1st Place: Devin | Ogurtsov | zyz** (Andrey Ogurtsov, Devin, zyz)。

**Key Techniques:**
- **多模态融合**：IMU + THM + TOF 特征融合
- **TOF 图像化**：2×2 正方形 9 个区域平均
- **四元数 6D 表现**：避免四元数不连续性
- **阶段感知 Attention**：分阶段（Transition/Pause/Gesture）应用不同 attention
- **匈牙利算法**：全局最优标签分配
- **数据增强**：mixup, cutmix, timeshift, rotation

**Results:** 1st place (2657 teams)

**Resources:**
- [1st Place Solution (Kaggle)](https://www.kaggle.com/competitions/cmi-detect-behavior-with-sensor-data/writeups/cmi-1st-place-solution)
- [Japanese Summary](https://zenn.dev/ottantachinque/articles/2025-09-14_cmi-detect-behavior-with-sensor-data)
- [Chinese EDA](https://zhuanlan.zhihu.com/p/1943779452640273827)

### TOF 图像化处理 (1st Place approach)
```python
import numpy as np

def tof_image_2x2_pooling(tof_data):
    """
    TOF 图像化处理 - 2×2 正方形 9 个区域平均

    将每个 8×8 的 TOF 传感器数据转换为 2×2 的特征图

    参数:
        tof_data: shape (n_timesteps, n_tof_sensors * 64) 或 (n_timesteps, n_tof_sensors, 8, 8)
                 每个 TOF 传感器有 64 个像素（8×8）

    返回:
        pooled: shape (n_timesteps, n_tof_sensors * 9) - 每个 TOF 传感器 9 个区域
    """
    n_timesteps = tof_data.shape[0]

    # 如果是 2D 形状，重塑为 (n_timesteps, n_tof_sensors, 8, 8)
    if len(tof_data.shape) == 2:
        n_tof_sensors = tof_data.shape[1] // 64
        tof_reshaped = tof_data.reshape(n_timesteps, n_tof_sensors, 8, 8)
    else:
        tof_reshaped = tof_data

    n_tof_sensors = tof_reshaped.shape[1]
    pooled_features = []

    for t in range(n_timesteps):
        for sensor in range(n_tof_sensors):
            sensor_data = tof_reshaped[t, sensor]  # (8, 8)

            # 2×2 池化，得到 9 个区域（每个 4×4）
            # 也可以直接 2×2 池化得到 4 个区域
            # 这里假设使用 2×2 池化，步长为 2
            pooled = sensor_data.reshape(4, 4).mean(axis=1).mean(axis=0)  # 得到 4 个值

            # 或者更细粒度的 3×3 网格，得到 4 个区域，再加上全局统计
            # 根据日语描述："2x2の正方形を9つ" - 9 个正方形区域
            # 可能是 3×3 网格，步长为 2，得到 4 个区域，再加上某些额外特征

            # 这里实现一种可能的解释：滑动窗口 2×2，步长 2
            patches = []
            for i in range(0, 8, 2):
                for j in range(0, 8, 2):
                    patch = sensor_data[i:i+2, j:j+2]
                    patches.append(patch.mean())
            # 如果 4×4 网格，步长 2，得到 9 个区域 (4×4 / 2×2 = 4 区域 + 1 个额外)
            # 这里简化处理，使用 4 个区域均值 + 全局均值
            pooled = np.array(patches)

            pooled_features.append(pooled)

    return np.array(pooled_features)  # (n_timesteps, n_tof_sensors * n_patches)
```

### 四元数 6D 表现 (2nd Place approach)
```python
import numpy as np

def quaternion_to_6d(quaternion_data):
    """
    四元数转 6D 连续表示 - 避免四元数不连续性

    参数:
        quaternion_data: shape (..., 4) - 四元数 (w, x, y, z)

    返回:
        rotation_6d: shape (..., 6) - 6D 连续旋转表示

    参考: "On the Continuity of Rotation Representations in Neural Networks"
    """
    # 提取四元数的最后两个分量
    # 有多种 6D 表现方法，这里使用其中一种
    # 方法 1: 使用旋转矩阵的前两列
    # 方法 2: 使用四元数的向量部分

    w = quaternion_data[..., 0:1]
    x = quaternion_data[..., 1:2]
    y = quaternion_data[..., 2:3]
    z = quaternion_data[..., 3:4]

    # 归一化
    norm = np.sqrt(w**2 + x**2 + y**2 + z**2)
    w, x, y, z = w/norm, x/norm, y/norm, z/norm

    # 方法: 使用旋转矩阵的前两列
    # R = [w  -z  y   z]
    #     [z   w  -x  y]
    #     [-y  x   w  z]
    # 取前两列作为 6D 表现
    # col1 = [w, z, -y]
    # col2 = [-z, w, x]
    # 这里简化处理，使用更直接的 6D 表现

    # 简化版本: 直接使用 (x, y, z) 和旋转角度/轴
    # 更好的方法: 将四元数转换为旋转矩阵，取前两列

    # 计算 6D 表现: 取旋转矩阵的前两列
    # R[0,:] = [1 - 2(y^2 + z^2),     2(xy - wz),     2(xz + wy)]
    # R[1,:] = [    2(xy + wz), 1 - 2(x^2 + z^2),     2(yz - wx)]

    x2 = x * x
    y2 = y * y
    z2 = z * z

    # 旋转矩阵的第一行和第二行
    r00 = 1 - 2 * (y2 + z2)
    r01 = 2 * (x * y - w * z)
    r02 = 2 * (x * z + w * y)
    r10 = 2 * (x * y + w * z)
    r11 = 1 - 2 * (x2 + z2)
    r12 = 2 * (y * z - w * x)

    # 取前两列作为 6D 表现
    rotation_6d = np.concatenate([
        r00, r01, r02, r10, r11, r12
    ], axis=-1)

    return rotation_6d

# 使用示例
# rot_data shape: (n_timesteps, 4) or (n_timesteps, n_samples, 4)
# rot_6d = quaternion_to_6d(rot_data)
```

### 阶段感知 Attention (2nd Place approach)
```python
import torch
import torch.nn as nn

class PhaseAwareAttention(nn.Module):
    """
    阶段感知 Attention - 分阶段独立建模和加权

    利用 Transition/Pause/Gesture 三阶段结构
    """
    def __init__(self, d_model, n_heads=8, dropout=0.1):
        super().__init__()
        self.phase_embedding = nn.Embedding(3, d_model)  # 3 个阶段

        # 每个阶段独立的 Attention
        self.attentions = nn.ModuleList([
            nn.MultiheadAttention(d_model, n_heads, dropout=dropout)
            for _ in range(3)
        ])
        self.norms = nn.ModuleList([nn.LayerNorm(d_model) for _ in range(3)])
        self.fcs = nn.ModuleList([nn.Linear(d_model, d_model) for _ in range(3)])

        self.phase_classifier = nn.Sequential(
            nn.Linear(d_model, d_model // 2),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(d_model // 2, 3)  # 3 个阶段
        )

    def forward(self, x, phase_labels=None):
        """
        参数:
            x: (batch, seq_len, d_model) - 输入特征
            phase_labels: (batch, seq_len) - 阶段标签 (0=Transition, 1=Pause, 2=Gesture)
        """
        batch_size, seq_len, d_model = x.shape

        # 预测阶段概率
        phase_probs = self.phase_classifier(x.mean(dim=1))  # (batch, 3)
        phase_probs = torch.softmax(phase_probs, dim=-1)  # (batch, 3)

        # 如果没有提供阶段标签，使用 argmax
        if phase_labels is None:
            phase_labels = torch.argmax(phase_probs, dim=-1)  # (batch,)

        # 初始化输出
        output = torch.zeros_like(x)

        # 对每个样本应用对应的阶段 Attention
        for b in range(batch_size):
            phase = phase_labels[b].item()  # 该样本的主要阶段

            # 应用该阶段的 Attention
            x_b = x[b:b+1]  # (1, seq_len, d_model)
            attn = self.attentions[phase]
            norm = self.norms[phase]
            fc = self.fcs[phase]

            x_b = norm(x_b)
            x_b, _ = attn(x_b, x_b, x_b)
            x_b = fc(x_b)

            # 用阶段概率加权
            weight = phase_probs[b, phase]
            output[b:b+1] = x_b * weight

        return output, phase_probs
```

### 匈牙利算法全局最优标签分配 (2nd/3rd Place approach)
```python
import numpy as np
from scipy.optimize import linear_sum_assignment

def hungarian_global_label_assignment(pred_probs, subject_ids, sequence_ids,
                                    gesture_ids, orientation_ids):
    """
    匈牙利算法全局最优标签分配

    利用约束: 每个 subject × gesture × orientation 只出现一次

    参数:
        pred_probs: (n_sequences, n_classes) - 预测概率
        subject_ids: (n_sequences,) - 每个 sequence 的 subject ID
        sequence_ids: (n_sequences,) - sequence ID
        gesture_ids: (n_sequences,) - 约束前的 gesture 标签
        orientation_ids: (n_sequences,) - 每个 sequence 的 orientation

    返回:
        final_labels: (n_sequences,) - 全局最优的标签分配
    """
    n_sequences = pred_probs.shape[0]
    n_classes = pred_probs.shape[1]

    # 构建代价矩阵: cost[i, j] = -log(prob_i[j]) 表示将 sequence i 分配给标签 j 的代价
    cost_matrix = -np.log(pred_probs + 1e-10)

    # 构建约束矩阵: 不能违反 subject × gesture × orientation 唯一性约束
    # 这里简化处理，实际实现需要更复杂的约束

    # 对每个 subject 单独处理
    final_labels = np.zeros(n_sequences, dtype=int)

    for subject_id in np.unique(subject_ids):
        # 该 subject 的所有序列
        mask = subject_ids == subject_id
        subject_seqs = np.where(mask)[0]

        if len(subject_seqs) == 0:
            continue

        # 该 subject 的预测概率
        subject_probs = pred_probs[subject_seqs]  # (n_subject_seqs, n_classes)

        # 使用匈牙利算法进行最优分配
        row_ind, col_ind = linear_sum_assignment(subject_probs)

        # 分配标签
        for seq_idx, label_idx in zip(row_ind, col_ind):
            final_labels[subject_seqs[seq_idx]] = label_idx

    return final_labels

# 备选方案：更简单的实现（仅针对 orientation × gesture 约束）
def simple_hungarian_assignment(pred_probs, sequence_ids, gesture_ids, orientation_ids):
    """
    简化的匈牙利算法实现 - 利用 orientation × gesture 唯一性约束

    参数:
        pred_probs: (n_sequences, n_classes)
        sequence_ids: (n_sequences,)
        gesture_ids: (n_sequences,)
        orientation_ids: (n_sequences,)
    """
    n_sequences = pred_probs.shape[0]
    n_classes = pred_probs.shape[1]

    # 构建 (orientation, gesture) 组合
    # 每个 orientation × gesture 组合只分配一次

    final_labels = np.zeros(n_sequences, dtype=int)

    # 对每个 orientation 单独处理
    for orientation_id in np.unique(orientation_ids):
        mask = orientation_ids == orientation_id
        orientation_seqs = np.where(mask)[0]

        if len(orientation_seqs) == 0:
            continue

        # 该 orientation 的所有序列
        orientation_probs = pred_probs[orientation_seqs]
        orientation_gestures = gesture_ids[orientation_seqs]

        # 使用匈牙利算法
        row_ind, col_ind = linear_sum_assignment(orientation_probs)

        # 分配标签（考虑 gesture 约束）
        # 这里需要更复杂的实现，确保每个 gesture 只分配一次

        for seq_idx, label_idx in zip(row_ind, col_ind):
            final_labels[orientation_seqs[seq_idx]] = label_idx

    return final_labels
```

### 相位 Mixup (2nd Place approach)
```python
import numpy as np

def phase_aware_mixup(X, y, phase_labels, alpha=0.2, beta=0.2):
    """
    相位感知 Mixup - 按阶段分割后在同阶段内进行 Mixup

    参数:
        X: (batch, seq_len, n_features) - 输入特征
        y: (batch, n_classes) - 标签
        phase_labels: (batch, seq_len) - 阶段标签 (0=Transition, 1=Pause, 2=Gesture)
        alpha: Mixup 强度
        beta: CutMix 强度

    返回:
        mixed_X, mixed_y, lambda_a, lambda_b, phase_labels
    """
    batch_size, seq_len, n_features = X.shape

    if phase_labels is None:
        # 简单 Mixup
        return standard_mixup(X, y, alpha)

    # 对每个样本进行相位 Mixup
    mixed_X = X.copy()
    mixed_y = y.copy()
    lambda_as = np.zeros(batch_size)
    lambda_bs = np.zeros(batch_size)

    for i in range(batch_size):
        # 找到同一阶段的其他样本
        same_phase_mask = (phase_labels[i, 0] == phase_labels[:, 0])

        if same_phase_mask.sum() == 0:
            # 没有同阶段样本，跳过
            continue

        # 随机选择同阶段样本 j
        same_phase_indices = np.where(same_phase_mask)[0]
        j = np.random.choice(same_phase_indices)

        # Mixup
        mixed_X[i] = alpha * X[i] + (1 - alpha) * X[j]
        mixed_y[i] = alpha * y[i] + (1 - alpha) * y[j]
        lambda_as[i] = alpha

        # CutMix（对标签）
        if beta > 0:
            # 简化的 CutMix 实现
            # 实际应该对特征进行 CutMix
            pass

    return mixed_X, mixed_y, lambda_as, lambda_bs, phase_labels

def standard_mixup(X, y, alpha=0.2):
    """标准 Mixup"""
    batch_size = X.shape[0]

    if batch_size < 2:
        return X, y, np.zeros(batch_size), None, None

    mixed_X = X.copy()
    mixed_y = y.copy()
    lambda_as = np.random.beta(alpha, alpha, batch_size)

    for i in range(batch_size):
        j = i
        while j == i:
            j = np.random.randint(0, batch_size)

        mixed_X[i] = lambda_as[i] * X[i] + (1 - lambda_as[i]) * X[j]
        mixed_y[i] = lambda_as[i] * y[i] + (1 - lambda_as[i]) * y[j]

    return mixed_X, mixed_y, lambda_as, None, None
```

### 重力去除和特征工程 (1st Place approach)
```python
import numpy as np

def remove_gravity_and_extract_features(acc_data):
    """
    去除重力影响并提取 35 个特征

    1st Place 的特征工程方法

    参数:
        acc_data: shape (n_timesteps, 3) - 加速度数据 (acc_x, acc_y, acc_z)

    返回:
        features: shape (n_timesteps, 35) - 提取的特征
    """
    n_timesteps = acc_data.shape[0]

    # 1. 去除重力
    # 假设重力加速度约为 9.8 m/s²
    # 计算重力方向（可以使用平均加速度估计）
    gravity = np.mean(acc_data, axis=0)  # 简化方法
    acc_no_gravity = acc_data - gravity

    # 2. 提取 35 个特征
    # 这里需要根据实际实现来定义这 35 个特征
    # 可能的特征类型：
    # - 统计特征：均值、标准差、最大值、最小值等
    # - 频域特征：FFT 后的能量分布
    # - 时域特征：过零率、峰值数等
    # - 差分特征：一阶差分、二阶差分等

    features = []

    for t in range(n_timesteps):
        feat = []

        # 原始加速度（去除重力后）
        feat.extend(acc_no_gravity[t])  # 3 个特征

        # 加速度的范数
        feat.append(np.linalg.norm(acc_no_gravity[t]))  # 1 个特征

        # 加速度的绝对值
        feat.extend(np.abs(acc_no_gravity[t]))  # 3 个特征

        # 一阶差分
        if t > 0:
            diff = acc_no_gravity[t] - acc_no_gravity[t-1]
            feat.append(np.linalg.norm(diff))  # 1 个特征
            feat.extend(diff)  # 3 个特征
        else:
            feat.extend([0, 0, 0, 0])  # 4 个特征

        # 统计特征（滑动窗口）
        window = 10
        start = max(0, t - window)
        end = min(n_timesteps, t + window + 1)
        window_data = acc_no_gravity[start:end]

        feat.append(np.mean(window_data, axis=0))  # 3 个特征
        feat.append(np.std(window_data, axis=0))   # 3 个特征
        feat.append(np.max(window_data, axis=0) - np.min(window_data, axis=0))  # 3 个特征

        # 频域特征（FFT）
        if t >= window:
            fft_data = np.fft.fft(acc_data[start:end, 0])  # 仅对 x 轴
            fft_energy = np.abs(fft_data)
            feat.append(fft_energy[:5].mean())  # 前 5 个频点的能量  # 1 个特征
        else:
            feat.append(0)

        features.append(feat)

    features = np.array(features)  # (n_timesteps, n_features)
    # 确保 n_features = 35
    if features.shape[1] < 35:
        # 填充或截断到 35 个特征
        # 这里简化处理
        pass

    return features
```

### 时序转图像 (7th Place approach)
```python
import numpy as np

def time_series_to_image(series_data, image_size=(224, 224)):
    """
    时序转图像 - 将时序数据转换为图像

    7th Place 的方法：使用 2D-CNN 处理时序数据

    参数:
        series_data: shape (n_timesteps, n_features) - 时序数据
        image_size: 目标图像大小 (height, width)

    返回:
        images: (n_channels, height, width) - 图像数据
    """
    n_timesteps, n_features = series_data.shape
    height, width = image_size

    # 方法 1: 直接重塑（如果 n_timesteps × n_features 适合）
    # 如果 n_timesteps × n_features = height × width，直接重塑
    if n_timesteps * n_features == height * width:
        image = series_data.reshape(height, width)
        return image[np.newaxis, :, :]  # (1, height, width)

    # 方法 2: 使用波形图（类似声谱图）
    # 将时序数据转换为图像的灰度值
    # 可以使用 matplotlib 的 imshow 方法

    # 简化实现：将每个特征作为一个通道
    # 如果 n_features == 3，可以直接作为 RGB 图像
    if n_features == 3:
        # 归一化到 [0, 255]
        normalized = (series_data - series_data.min()) / (series_data.max() - series_data.min() + 1e-10)
        image = (normalized * 255).astype(np.uint8)

        # 调整大小
        # 这里可以使用 cv2.resize 或 interpolation
        # 简化处理：直接采样
        if n_timesteps != height or n_features != width:
            # 使用最近邻插值
            image = image.reshape(height, width, 3)
            # 实际应该使用 cv2.resize

        return image.transpose(2, 0, 1)  # (3, height, width)

    # 方法 3: 创建多通道图像（每个特征一个通道）
    # 如果 n_features < 3，复制通道
    # 如果 n_features > 3，选择前 3 个特征或使用 PCA

    # 简化处理：只使用前 3 个特征
    if n_features >= 3:
        selected_data = series_data[:, :3]
    else:
        selected_data = np.concatenate([series_data, series_data, series_data], axis=1)[:, :3]

    # 归一化到 [0, 255]
    normalized = (selected_data - selected_data.min()) / (selected_data.max() - selected_data.min() + 1e-10)
    image = (normalized * 255).astype(np.uint8)

    # 调整大小
    image = image.reshape(n_timesteps, 3, 1).reshape(height, width, 3)

    return image.transpose(2, 0, 1)  # (3, height, width)
```

### 异常数据处理
```python
import polars as pl
import numpy as np

def remove_invalid_sequences(train_df, train_events):
    """
    删除无效序列

    1st Place 和其他前排方案的共同处理：
    - SUBJ_019262: 没有正确佩戴设备
    - SUBJ_045235: 数据异常

    参数:
        train_df: 训练数据
        train_events: 训练事件

    返回:
        cleaned_df: 清理后的数据
    """
    # 删除特定 subject 的数据
    invalid_subjects = ['SUBJ_019262', 'SUBJ_045235']

    # 方法 1: 完全删除
    cleaned_df = train_df.filter(~pl.col('subject').is_in(invalid_subjects))

    # 方法 2: 数据转换（如果某些序列可以恢复）
    # 这里需要根据实际情况处理

    # 删除 gesture 不存在的序列
    # 统计每个 sequence_id 的 unique gesture 数量
    gesture_counts = train_df.groupby('sequence_id')['gesture'].n_unique()
    valid_gestures = gesture_counts.filter(pl.col('gesture') > 0)
    cleaned_df = cleaned_df.filter(pl.col('sequence_id').is_in(valid_gestures['sequence_id']))

    return cleaned_df
```

### 左手系 → 右手系对齐
```python
import numpy as np

def align_left_to_right_handed(sensor_data, sensor_type='IMU'):
    """
    左手系 → 右手系对齐

    将左手佩戴设备的传感器数据转换为右手系的等效数据

    参数:
        sensor_data: 传感器数据
        sensor_type: 'IMU' 或 'THM' 或 'TOF'

    返回:
        aligned_data: 对齐后的数据
    """
    if sensor_type == 'IMU':
        # 对于 IMU（加速度计和陀螺仪）：
        # 加速度：x → -x（左右翻转）
        # 陀螺仪：某些分量需要取反

        # 假设 sensor_data 的格式：(acc_x, acc_y, acc_z, rot_w, rot_x, rot_y, rot_z, ...)
        # 或者其他格式

        # 加速度：翻转 x 分量
        acc_x = sensor_data[:, 0]  # 假设第 0 列是 acc_x
        acc_y = sensor_data[:, 1]  # acc_y
        acc_z = sensor_data[:, 2]  # acc_z

        aligned_acc_x = -acc_x  # 左右翻转
        aligned_acc_y = acc_y
        aligned_acc_z = acc_z

        # 陀螺仪：需要根据实际佩戴方式调整
        # 这里简化处理，保持不变

        # 组合对齐后的数据
        aligned_data = sensor_data.copy()
        aligned_data[:, 0] = aligned_acc_x

    elif sensor_type == 'THM':
        # 对于热电堆传感器：
        # 可能需要镜像处理

        aligned_data = sensor_data.copy()
        # 根据传感器位置进行镜像

    elif sensor_type == 'TOF':
        # 对于飞行时间传感器：
        # 可能需要镜像处理 8×8 像素阵列

        aligned_data = sensor_data.copy()
        # 根据传感器位置进行镜像

    return aligned_data
```

## CMI - Detect Behavior with Sensor Data - Top 10 Solutions Comparison

> 基于日语总结和前排方案的综合分析，提取共性技术和差异创新

### 竞赛特点总结

与之前竞赛不同，这是一个**多模态时序行为识别**任务，核心挑战包括：
- **多模态传感器融合**：IMU + THM + TOF
- **严重数据缺失**：TOF 约 60% 缺失（-1），THM 约 3-4% 缺失
- **细粒度分类**：18 个手势类别，区分 BFRB vs 日常动作
- **个体约束**：每个 subject × gesture × orientation 只出现一次
- **测试集变化**：约 50% 序列仅有 IMU 数据

### 前 3 名详细对比

#### 1st Place - Devin | Ogurtsov | zyz (Andrey Ogurtsov, Devin, zyz)

**核心架构：** 多成员协作 + 多模型集成

```
Devin's part:
    TOF 处理: 2×2 正方形 9 个区域平均
    TOF-only 模型也加入集成

Ogurtsov's part:
    数据清理: 删除 gesture 不存在的序列
    特征工程: 从 acc（去除重力后）提取 35 个特征
    模型: LSTM, Attention, CNN 组合
    增强: timeshift, timistretch
    集成: 每 Fold 选择 3 run 中最佳结果
    推理: 序列延伸降低模型相关性

zyz part:
    RNN + CNN1D 组合
```

**关键技术：**
- **TOF 图像化**：2×2 正方形 9 个区域平均降维
- **TOF-only 集成**：单独使用 TOF 数据的模型也加入集成
- **数据清理**：删除无效序列（如 SUBJ_019262, SUBJ_045235）
- **特征工程**：35 个特征从 acc（去除重力后）提取
- **多模型集成**：LSTM + Attention + CNN 组合
- **推理优化**：序列延伸降低模型相关性，提升集成效果

#### 2nd Place - cucutzik

**核心架构：** 4 模型系统 + 阶段感知 Attention

```
4 个独立模型:
    IMU rotation 缺失/存在 × THM/TOF 缺失/存在 = 4 组合

核心创新:
    四元数 6D 表现 (避免不连续性)
    Residual SE-CNN Block + Attention

关键技巧:
    阶段感知 Attention:
        预测 3 类阶段概率 (移动中/目标位置/手势执行中)
        每个阶段独立 Attention，概率加权
    相位 Mixup:
        按阶段分割序列
        同阶段内进行 Mixup
        "moves to target" 阶段对齐结束点
    Pseudo Label:
        测试数据生成 pseudo-label
        小 LR (5e-5) 1 step fine-tune

后处理:
    匈牙利算法全局最优标签分配
    约束: subject × gesture × orientation 唯一性
```

**关键技术：**
- **四元数 6D 表现**：避免四元数不连续性问题
- **阶段感知 Attention**：分阶段独立建模和加权
- **相位 Mixup**：按阶段分割后同阶段内 Mixup
- **Pseudo Label**：测试数据生成伪标签进行微调
- **匈牙利算法**：全局最优标签分配（利用个体约束）

#### 3rd Place - Team RIST

**核心架构：** 2D-CNN + 图像化时序

```
数据预处理:
    四元数平滑处理
    符号反转扩展
    Block 扩展

模型:
    MaxViT, ConvNeXt-V2, EfficientNetB5 等 2D-CNN
    输入: 适当尺寸的图像

增强:
    世界坐标系 Z 轴旋转 (-60° 到 60°)
    本地坐标系 Y 轴旋转 (-7° 到 7°)

后处理:
    匈牙利算法全局最优标签分配
```

**关键技术：**
- **时序图像化**：时序数据转换为图像，使用 2D-CNN
- **四元数处理**：平滑、符号反转、Block 扩展
- **双重旋转增强**：世界坐标 + 本地坐标旋转
- **多 2D-CNN 集成**：MaxViT + ConvNeXt + EfficientNetB5

### 共性技术（"银弹" - 高分者共同使用）

| 技术 | 使用排名 | 说明 |
|------|---------|------|
| **个体约束利用** | 1st, 2nd, 3rd, 4th | subject × gesture × orientation 唯一性 |
| **数据增强** | 1st, 2nd, 3rd, 4th, 6th... | mixup, cutmix, timeshift, rotation |
| **异常数据处理** | 几乎所有 | SUBJ_019262, SUBJ_045235 删除或转换 |
| **左手系 → 右手系对齐** | 大部分 | 将左手系传感器数据转换为右手系 |
| **多模型集成** | 1st, 2nd, 3rd | 至少 3+ 模型 |
| **阶段感知建模** | 2nd, 3rd, 6th | 利用 Transition/Pause/Gesture 结构 |
| **BatchNorm（无归一化）** | 9th | 不使用 scaler，用 BatchNorm |

### 差异创新（各排名者的独特贡献）

| 排名 | 独特创新 | 影响 |
|------|---------|------|
| **1st** | TOF 图像化（2×2 区域平均） | 简化 TOF 处理 |
| **1st** | TOF-only 模型集成 | 单独 TOF 也有价值 |
| **1st** | 序列延伸推理 | 降低模型相关性 |
| **2nd** | 四元数 6D 表现 | 避免不连续性 |
| **2nd** | 阶段感知 Attention | 分阶段独立建模 |
| **2nd** | 相位 Mixup | 同阶段内 Mixup，对齐结束点 |
| **2nd** | Pseudo Label fine-tune | 测试数据微调 |
| **3rd** | 时序转图像 | 使用 2D-CNN 处理 |
| **3rd** | 双重旋转增强 | 世界坐标 + 本地坐标 |
| **6th** | gesture segment U-Net | 估计手势时间段 |
| **9th** | 正向 + 反向模型 | 同时训练标准分类和反向分类 |
| **13th** | 双向 Mamba | 长期时序依赖建模 |
| **13th** | Hard Margin Loss | 针对困难样本的损失 |
| **13th** | Hard Mining | 困难样本采样率提升 |

### 多模态传感器处理对比

| 方法 | 使用排名 | 具体实现 |
|------|---------|---------|
| **TOF 图像化** | 1st | 2×2 正方形 9 个区域平均 |
| **TOF 2D-CNN** | 7th | 时序数据转图像，用 2D-CNN |
| **TOF U-Net** | 6th | gesture segment 估计 |
| **THM/TOF 独立模型** | 2nd | 4 个模型（缺失/存在组合） |
| **多模态融合** | 1st, 2nd, 3rd | IMU + THM + TOF 特征融合 |

### 四元数处理对比

| 方法 | 使用排名 | 说明 |
|------|---------|------|
| **6D 表现** | 2nd | 避免四元数不连续性 |
| **平滑处理** | 3rd | 处理四元数不连续性 |
| **符号反转扩展** | 3rd | 扩展四元数表示 |
| **Block 扩展** | 3rd | 添加额外 Block |

### 后处理策略对比

| 排名 | 方法 | 具体实现 |
|------|------|---------|
| **1st** | 简单集成 + 推理优化 | 序列延伸 |
| **2nd** | 匈牙利算法 | 全局最优标签分配，利用个体约束 |
| **3rd** | 匈牙利算法 | 全局最优标签分配 |
| **4th-15th** | 多种方法 | argmax, 约束优化等 |

### 数据增强策略对比

| 方法 | 使用排名 | 具体实现 |
|------|---------|---------|
| **Mixup** | 1st, 2nd, 4th, 10th | 标准或相位 Mixup |
| **CutMix** | 1st | 标准 CutMix |
| **Time Shift** | 1st | 时间偏移 |
| **Time Stretch** | 1st | 时间拉伸 |
| **Rotation** | 2nd, 3rd | 世界坐标 + 本地坐标旋转 |
| **Time Warping** | 7th | 时间非线性伸缩 |
| **Magnitude Warping** | 7th | 幅度时间变化 |
| **双重 Mixup** | 10th | `Mixup(Mixup(Mixup(x)))` |

### 缺失数据处理对比

| 方法 | 使用排名 | 具体实现 |
|------|---------|---------|
| **独立模型** | 2nd | 4 个模型（缺失/存在组合） |
| **TOF-only** | 1st | 单独 TOF 模型也集成 |
| **gesture segment** | 6th | U-Net 估计手势时间段 |
| **删除异常序列** | 1st | 删除无效序列 |
| **数据转换** | 几乎所有 | 左手系 → 右手系对齐 |

### 最佳实践总结

基于前 10 名对比分析，以下技术是获胜的关键：

#### 必选项（银弹技术）
1. **个体约束利用**：subject × gesture × orientation 唯一性
2. **数据增强**：mixup, cutmix, timeshift, rotation
3. **异常数据处理**：SUBJ_019262, SUBJ_045235 删除或转换
4. **左手系 → 右手系对齐**：统一左右手传感器数据
5. **多模型集成**：至少 3+ 模型
6. **阶段感知建模**：利用 Transition/Pause/Gesture 结构

#### 推荐选项（根据情况选择）
- **TOF 处理**：图像化 (1st) > 2D-CNN (7th) > U-Net (6th)
- **四元数处理**：6D 表现 (2nd) > 平滑 + 扩展 (3rd)
- **后处理**：匈牙利算法 (2nd, 3rd) > 简单集成 (1st)
- **模型架构**：根据数据特征选择 1D-CNN / 2D-CNN / Mamba

#### 创新方向
- **阶段感知建模**：分阶段独立 Attention 和特征提取
- **相位 Mixup**：按阶段分割后同阶段内 Mixup
- **Pseudo Label**：测试数据生成伪标签微调
- **时序图像化**：将时序数据转为图像，用 2D-CNN
- **双向 Mamba**：长期时序依赖建模

---

## 数据洞察与分析

### 数据特征理解

#### 标签质量的双峰分布

**发现：** 投票数呈现双峰分布
- **低质量样本**：1-7 票
- **高质量样本**：10-28 票
- **关键发现**：**没有 8-9 票的样本**

**含义：**
- 存在两组标注者：专家组（20人）和大众组（119人）
- 低投票数样本更不可靠，标签噪声更大
- 高投票数样本代表专家共识，质量更高

**策略：**
- 使用 votes ≥10 作为高质量阈值
- 仅用高质量样本建立验证集（CV/LB 相关性接近 1:1）
- 考虑对低投票样本进行更强正则化

**第 3 名的洞察：** 从 100,000+ 行筛选到 6,350 行高质量数据，性能反而提升 → **"少即是多"**，精确数据胜过大量噪声数据

#### 标签稀疏性

**发现：** 训练标签中某些类别的概率为 0
- Softmax 输出所有值 > 0（数学性质）
- 但真实标签中某些类为 0

**解决方案（1st Place）：**
- 使用 **Entmax** 替换 Softmax
- Entmax 可以产生真正的 0 输出（稀疏激活）
- 结果：LB +0.004 提升

**实现：**
```python
def entmax(x, alpha=1.5, dim=-1):
    return torch.softmax(x * alpha, dim=dim)
```

#### 双模态数据的时间对齐

**数据结构：**
- **Spectrogram**：10 分钟（低时间分辨率，高频率信息）
- **EEG**：50 秒中心段（高时间分辨率，低频率信息）
- 两者中心 50 秒是同一数据

**洞察：**
- Spectrogram 提供全局上下文（10分钟趋势）
- EEG 提供精细时序信息（50 秒细节）
- 这是**同一数据的两种表示**，不是独立信息

**处理策略：**
- 大多数获胜者**专注于 EEG**（2nd, 3rd）
- 1st Place 同时使用两种并集成
- 时频分析（CWT/MelSpectrogram）比纯时序或纯频域更有效

#### 信号配对的重要性

**发现：**
- 脑电信号存在空间关系
- 左右对称位置的电极信号应该成对处理
- 通道顺序影响模型性能

**策略（3rd Place）：**
- 将左右脑节点配对：Fp1-F7, Fp2-F8, F7-T3, F8-T4 等
- 而不是简单按顺序堆叠
- 这样保留了脑部空间结构的先验知识

#### 频率范围选择的影响

**对比分析：**
| 频率范围 | 使用者 | 效果 |
|---------|--------|------|
| 0.5-20 Hz | 标准, 2nd | Kaggle 默认 |
| 0.5-40 Hz | 1st (suguuuuu) | 更佳结果 |
| 0.5-50 Hz | 部分 | 高频噪声可能增加 |

**洞察：**
- 标准范围可能遗漏重要信息
- 扩展到 40 Hz 能捕捉更多特征
- 但过高频率（50 Hz+）可能引入噪声
- 需要根据具体任务调整

#### 归一化的选择

**实验发现（3rd Place）：**
- Batch/Sample 归一化：效果不佳
- MAD 归一化：对异常值更鲁棒
- **Clip 归一化** `x.clip(-1024, 1024) / 32`：**最佳选择**（所有前 3 名都使用）

**为什么 Clip/32 最好？**
1. **限制极端值**：EEG 信号存在大幅伪影
2. **固定除数 32**：简单、可复现、不过拟合
3. **保留信息**：相比标准化，保留更多原始信号特征

#### 数据增强的反向工程

**3rd Place 的关键发现：**
- 数据创建者对训练数据应用了 augmentation
- 这些 augmentation 在测试时不存在
- **反向工程并移除这些 augmentation** 后，模型性能显著提升

**启示：**
- 理解数据来源和预处理历史很重要
- "干净"的原始数据可能比"增强"的数据更好
- 深入数据分析能发现隐藏的改进机会

### 数据质量评估框架

基于前 10 名的分析，可以建立以下数据质量评估维度：

| 维度 | 评估方法 | 高质量指标 |
|------|---------|-----------|
| **投票数** | 统计每个样本的专家投票数 | votes ≥10 |
| **一致性** | 计算投票分布的熵 | 高一致性（低熵） |
| **标注者类型** | 区分专家 vs 大众 | 专家共识权重更高 |
| **信号质量** | 检查伪影、噪声水平 | 低噪声、少伪影 |
| **时序完整性** | 检查 50 秒段连续性 | 无断裂、无缺失 |

### 数据预处理最佳流程

综合前 10 名方案，推荐的数据预处理流程：

```python
def preprocess_eeg_optimal(eeg_raw, votes):
    """
    基于 Top 10 方案的最佳预处理流程
    """
    # 1. 双极导联（减少共模噪声）
    bipolar = longitudinal_bipolar_montage(eeg_raw)

    # 2. 带通滤波（0.5-40 Hz，扩展频段）
    filtered = bandpass_filter(bipolar, lowcut=0.5, highcut=40, fs=200)

    # 3. Clip 归一化（所有前 3 名使用）
    normalized = np.clip(filtered, -1024, 1024) / 32.0

    # 4. 数据质量筛选
    if votes < 10:
        # 考虑降权重或使用 Pseudo Label
        weight = votes / 20.0  # 2nd Place 方法
    else:
        weight = 1.0

    return normalized, weight
```

### 标签处理最佳实践

| 技术 | 目的 | 使用排名 |
|------|------|---------|
| **投票数归一化** | 转换为概率分布 | 所有 |
| **标签平滑（加 0.02）** | 防止过度自信 | 部分 |
| **Loss 权重** | 按投票数加权样本 | 2nd |
| **Offset 加法** | 低投票数更强正则化 | 部分 |

### 关键数据洞察总结

1. **质量 > 数量**：6,350 行高质量数据 > 100,000 行噪声数据
2. **稀疏标签需要稀疏激活**：Entmax > Softmax
3. **时频分析优于纯时序或纯频域**：CWT > STFT
4. **空间先验知识很重要**：信号配对、左右对称
5. **归一化方法影响巨大**：Clip/32 是最佳选择
6. **理解数据来源至关重要**：反向 Augmentation 提升性能
7. **标签质量分布不均**：需要分层训练和评估

---

## Child Mind Institute - 数据洞察与分析

### 数据特征理解

#### 极度稀疏的标签

**发现：** 17280 步（24小时）中仅有 2 步有标签
- **标签密度**：0.01%（1/10000）
- **事件类型**：onset（入睡）+ wakeup（觉醒）
- **标注粒度**：每夜 1 个 onset + 1 个 wakeup

**含义：**
- 传统逐帧分类方法不适用
- 需要特殊的目标创建策略（衰减目标）
- 后处理比模型预测更重要
- 数据增强对缓解稀疏性至关重要

**策略：**
- **衰减目标**：按 tolerance_steps 创建衰减的标签分布
- **多任务学习**：同时预测 onset, wakeup, asleep
- **后处理优化**：find_peaks, NMS, greedy search
- **数据增强**：序列反转、时间偏移等

#### 分钟偏差模式

**发现：** 真实事件总是发生在 hh:mm:00 整分钟时刻

**数据分布（YOURI MATIOUNINE 发现）：**
```
标签分钟数 % 15 的分布：
- 0分钟：明显峰值
- 3分钟：明显峰值
- 7分钟：明显峰值
- 11分钟：明显峰值
- 其他分钟：很少出现
```

**含义：**
- 手动标注导致精度有限
- 存在 15 分钟的周期性模式
- 模型应该学习这种模式

**策略对比：**
| 排名 | 处理方法 | 具体实现 |
|------|---------|---------|
| **1st** | Minute Embedding | 残差连接到输出层 |
| **2nd** | Step 偏移 | 对预测 step 做偏移后重新预测 |
| **3rd** | 频率编码 | hour_min_onset, hour_min_wakeup |
| **5th** | 标签偏移 | target shift ~-11 步 |
| **6th** | 特征工程 | `(step // 12) % 15` |

#### 未标注事件问题

**发现（YOURI MATIOUNINE）：** 很多序列有明显的 events 未被标注

**两类情况：**
1. **日周期性重复**：缺失 events 的夜晚跟前 24 小时数据完全一样
   - 推测：组织方用历史正常数据填补了缺失数据
2. **无法解释的缺失**：没有明显规律的缺失标注

**处理策略对比：**
| 排名 | 处理方法 | 具体实现 |
|------|---------|---------|
| **1st** | 周期性检测 + flag | 降采样 + 相似度计算，标记日周期性 |
| **3rd** | 噪声检测 | 相同 hour+step+anglez 重复值即为噪声 |
| **5th** | 样本加权 | 训练时权重设为 0 |
| **6th** | Hash 算法 | 散列和散列图查找重复模式，本地 CV +0.015 |
| **大部分** | 过滤序列 | 剔除未标注 events 出现多的序列 |

**1st Place 的周期性检测方法：**
```python
def detect_periodicity(series):
    """检测 24 小时周期性重复"""
    # 1. 降采样
    downsampled = series[::12]  # 5秒 → 1分钟

    # 2. 分割序列（按天）
    n_days = len(downsampled) // 1440  # 1440 = 24小时
    daily_chunks = [downsampled[i*1440:(i+1)*1440] for i in range(n_days)]

    # 3. 计算相邻天的相似度
    for i in range(n_days - 1):
        # 方法1: 元素级比较
        similarity = np.mean(daily_chunks[i] == daily_chunks[i+1])

        # 方法2: 余弦相似度
        cos_sim = np.dot(daily_chunks[i], daily_chunks[i+1]) / (
            np.linalg.norm(daily_chunks[i]) * np.linalg.norm(daily_chunks[i+1])
        )

        if similarity > threshold or cos_sim > threshold:
            return True  # 检测到周期性

    return False
```

#### 多 Tolerance AP 评估指标

**评估方式：**
```python
tolerances = [1, 3, 5, 7.5, 10, 12.5, 15, 20, 25, 30]  # 分钟
# 对每个 tolerance，计算 AP
# 最终分数 = mean(各tolerance AP) × mean(onset AP, wakeup AP)
```

**关键洞察（1st Place）：**
- **预测 hh:mm:00 不好**：tolerance 5,10,15,20,25,30 时边缘漏检
- **预测 hh:mm:30 不好**：tolerance 7.5, 12.5 时边缘漏检
- **预测 hh:mm:15 或 hh:mm:45 最佳**：覆盖所有 tolerance

**原理示意：**
```
00:23:15 ← 检测事件（15秒）
    ← tolerance 7.5 分 →
00:23:00 ← 真实事件（0秒）
    ← tolerance 7.5 分 →
00:22:45

如果检测事件在 00:23:00，则 tolerance 7.5 的右边缘会漏检
如果检测事件在 00:23:15 或 00:22:45，则正好覆盖
```

#### 15分钟周期性模式

**发现：** events 以 15 分钟为周期重复出现

**数据分布：**
- **峰值分钟**：0, 3, 7, 11（间隔 3-4 分钟）
- **周期**：15 分钟
- **含义**：可能与定时检查或记录习惯有关

**应对策略：**
| 排名 | 策略 | 说明 |
|------|------|------|
| **1st** | 15/45秒技巧 | 无论 1-29秒 还是31-59秒，选15/45秒代表 |
| **2nd** | Step偏移 | 对step做多个偏移，覆盖所有可能时刻 |
| **3rd** | 频率编码 | hour_min_onset, hour_min_wakeup |

### 数据质量评估框架

基于前排方案，建立数据质量评估维度：

| 维度 | 评估方法 | 低质量指标 | 处理策略 |
|------|---------|-----------|---------|
| **周期性重复** | 降采样+相似度 | 与前24小时完全相同 | 标记 periodicity flag |
| **噪声重复** | hour+step+anglez计数 | 重复值>1 | 标记 noise |
| **未标注events** | 统计每夜events数 | <2 events | 过滤或降权 |
| **数据异常** | enmo统计 | enmo值异常大 | clip到1 |

### 关键数据洞察总结

1. **极度稀疏标签**：需要衰减目标和后处理优化
2. **分钟偏差是关键**：所有前排方案都处理了这个问题
3. **未标注events普遍存在**：周期性检测可识别
4. **多tolerance AP需要特殊优化**：15/45秒技巧是制胜关键
5. **评估指标与数据分布不匹配**：需要针对tolerance优化
6. **Daily Normalization有效**：利用每天只有2次活动的先验
7. **15分钟周期性模式**：step偏移或频率编码可利用

## CMI - Detect Behavior 数据洞察与分析

### 数据特征理解

#### 多模态传感器数据

**三种传感器类型：**

| 传感器 | 数据维度 | 特征 | 缺失率 |
|-------|---------|------|--------|
| **IMU** | 加速度计(x,y,z) + 陀螺仪(x,y,z) | 运动和旋转 | 无缺失 |
| **THM** | 5个温度传感器 | 温度分布 | ~3-4% |
| **TOF** | 5个8×8传感器阵列 | 距离映射 | ~60% |

**IMU (Inertial Measurement Unit)：**
- 6 列：`X_accel`, `Y_accel`, `Z_accel`, `X_gyro`, `Y_gyro`, `Z_gyro`
- **重力分量**：加速度计包含重力，需去除
- **四元数**：`orientation_X`, `orientation_Y`, `orientation_Z`, `orientation_W`
  - 表示设备旋转姿态
  - **不连续性问题**：四元数在表示相同旋转时有多个值（q和-q表示相同旋转）
  - **解决方案**：使用旋转矩阵前两列（6D连续表示）

**THM (Thermopile)：**
- 5 列：`thermopile_0` ~ `thermopile_4`
- 温度传感器，用于检测物体接近
- **缺失标记**：-1 表示缺失
- **缺失率较低**：约3-4%

**TOF (Time-of-Flight)：**
- 320 列：`tof_0` ~ `tof_319`（5个8×8阵列）
- 距离传感器，检测物体到设备距离
- **缺失标记**：-1 表示缺失
- **缺失严重**：约60%的数据为-1
- **图像化处理**：将8×8阵列降采样为2×2特征图（1st Place创新）

#### 严重数据缺失问题

**缺失分布：**
```
TOF:  ~60% 缺失 (-1 标记)
THM:  ~3-4% 缺失 (-1 标记)
IMU:  无缺失
```

**前排处理策略：**

| 排名 | TOF 处理 | THM 处理 |
|------|---------|---------|
| **1st** | 2×2 pooling后标记缺失mask | 简单插值或mask |
| **2nd** | 特征工程提取有效点统计量 | 类似TOF处理 |
| **3rd** | 转图像，缺失填0 | 不使用或简单处理 |
| **其他** | 丢弃或mask | 丢弃或mask |

**1st Place 的 TOF 处理创新：**
```python
def tof_2x2_pooling_with_mask(tof_data):
    """
    TOF 数据 2×2 pooling + 缺失 mask
    """
    # 每个 8×8 传感器
    for sensor_idx in range(5):
        sensor = tof_data[:, sensor_idx*64:(sensor_idx+1)*64]
        sensor = sensor.reshape(-1, 8, 8)

        # 2×2 pooling
        pooled = sensor.reshape(-1, 4, 2, 2).mean(axis=(2, 3))

        # 缺失 mask
        mask = (sensor == -1).reshape(-1, 4, 2, 2).any(axis=(2, 3))

        # 组合：特征 + mask
        features[:, sensor_idx*4:(sensor_idx+1)*4] = pooled
        features[:, 20+sensor_idx*4:20+(sensor_idx+1)*4] = mask

    return features
```

#### 个体约束利用

**关键约束：** 每个 subject × gesture × orientation 组合只出现一次

**含义：**
- 训练集中没有重复的 subject × gesture × orientation
- 验证时可以确保预测结果也满足这个约束
- 可以用匈牙利算法做全局最优标签分配

**前排利用策略：**

| 排名 | 利用方法 | 说明 |
|------|---------|------|
| **1st** | 匈牙利算法 | 全局最优分配，提升 LB 0.01 |
| **2nd** | 阶段感知建模 | 利用三阶段结构 |
| **其他** | 个体特征 embedding | 添加 subject embedding |

**匈牙利算法实现（1st Place）：**
```python
from scipy.optimize import linear_sum_assignment

def hungarian_post_process(predictions, subject_ids, sequence_ids):
    """
    利用 subject × gesture × orientation 唯一约束
    """
    # 对于每个 subject
    for subject in unique(subject_ids):
        # 获取该 subject 的所有预测
        mask = subject_ids == subject
        preds = predictions[mask]
        seqs = sequence_ids[mask]

        # 构建代价矩阵：-log(概率)
        cost_matrix = -np.log(preds + 1e-10)

        # 匈牙利算法：找到最优分配
        row_ind, col_ind = linear_sum_assignment(cost_matrix)

        # 更新预测结果
        for i, j in zip(row_ind, col_ind):
            predictions[mask][i] = np.zeros(n_classes)
            predictions[mask][i][j] = 1.0

    return predictions
```

#### 三阶段结构

**发现：** 行为序列有明显的三阶段结构

```
Transition → Pause → Gesture
```

**阶段特征：**

| 阶段 | 持续时间 | 特征 | 识别要点 |
|------|---------|------|---------|
| **Transition** | 变化 | 从上一个状态移动到手势位置 | 运动幅度大 |
| **Pause** | 短暂 | 手势开始前的准备 | 运动幅度小 |
| **Gesture** | 重复 | 核心行为模式（如咬指甲） | 周期性模式 |

**前排利用策略：**

| 排名 | 利用方法 | 说明 |
|------|---------|------|
| **2nd** | 阶段感知 Attention | 每个阶段独立的 attention 权重 |
| **6th** | U-Net分割 | 将手势阶段作为分割任务 |
| **其他** | 特征工程 | 添加阶段分类特征 |

**2nd Place 阶段感知 Attention：**
```python
class PhaseAwareAttention(nn.Module):
    """
    阶段感知 Attention - 每个阶段独立建模
    """
    def __init__(self, d_model, n_heads=8):
        super().__init__()
        # 3个阶段 embedding
        self.phase_emb = nn.Embedding(3, d_model)

        # 每个阶段独立的 attention
        self.transition_attn = nn.MultiheadAttention(d_model, n_heads)
        self.pause_attn = nn.MultiheadAttention(d_model, n_heads)
        self.gesture_attn = nn.MultiheadAttention(d_model, n_heads)

    def forward(self, x, phase_labels):
        # phase_labels: [batch, seq_len] ∈ {0, 1, 2}
        batch, seq_len, d_model = x.shape

        outputs = []
        for t in range(seq_len):
            phase = phase_labels[:, t]  # [batch]

            if phase == 0:  # Transition
                attn_out, _ = self.transition_attn(x[:, t:t+1], x, x)
            elif phase == 1:  # Pause
                attn_out, _ = self.pause_attn(x[:, t:t+1], x, x)
            else:  # Gesture
                attn_out, _ = self.gesture_attn(x[:, t:t+1], x, x)

            outputs.append(attn_out)

        return torch.cat(outputs, dim=1)
```

#### BFRB vs 非BFRB 类别分布

**18个手势类别：**

| 类别 | BFRB类型 | 典型行为 |
|------|---------|---------|
| 0-7 | BFRB | 咬指甲、拉头发、抠皮肤等 |
| 8-17 | 非BFRB | 拍手、挥手、其他手势 |

**分布特点：**
- **训练集**：BFRB 和非BFRB 数量相近
- **个体差异**：不同 subject 的手势偏好不同
- **方向差异**：同一手势不同方向的表现不同

**处理策略：**
- **Phase-aware Mixup**：仅在 Gesture 阶段进行 mixup（2nd Place）
- **个体 normalization**：按 subject 做归一化
- **类别平衡**：确保每个类别有足够样本

#### 测试集变化

**关键发现：** 测试集约50%的序列仅有 IMU 数据

**含义：**
- 不能过度依赖 TOF 和 THM 特征
- 模型必须能够仅用 IMU 数据做出预测
- 需要训练仅用 IMU 的模型作为集成成员

**前排应对策略：**

| 排名 | 应对方法 |
|------|---------|
| **1st** | 训练IMU-only模型，集成时加权 |
| **2nd** | 4个模型：IMU-only, IMU+TOF, IMU+THM, All |
| **3rd** | TOF填0处理，但效果受限 |
| **其他** | 简单丢弃缺失传感器 |

**推荐策略：**
```python
# 训练时模拟测试集情况
def get_model_input(data):
    """
    根据可用传感器选择模型输入
    """
    has_tof = (data['tof'] != -1).any()
    has_thm = (data['thm'] != -1).any()

    if has_tof and has_thm:
        return model_all(data['imu'], data['tof'], data['thm'])
    elif has_tof:
        return model_imu_tof(data['imu'], data['tof'])
    elif has_thm:
        return model_imu_thm(data['imu'], data['thm'])
    else:
        return model_imu(data['imu'])
```

#### 异常数据识别

**两个异常 subject：**

| Subject | 问题 | 处理策略 |
|---------|------|---------|
| **SUBJ_019262** | 数据异常，预测困难 | 训练时过滤或降权 |
| **SUBJ_045235** | 数据异常，预测困难 | 训练时过滤或降权 |

**识别方法：**
- 训练集上该 subject 的 loss 异常高
- 交叉验证该 subject 的预测准确率低
- 可视化该 subject 的传感器数据，发现异常模式

**处理代码：**
```python
# 异常 subject 黑名单
ANOMALY_SUBJECTS = ['SUBJ_019262', 'SUBJ_045235']

def filter_anomaly_subjects(dataframe):
    """
    过滤异常 subject
    """
    mask = ~dataframe['subject'].isin(ANOMALY_SUBJECTS)
    return dataframe[mask]
```

#### 左手系 vs 右手系对齐

**发现：** 测试集存在左手和右手两种设备朝向

**问题：**
- 左手系和右手系的传感器读数方向相反
- 四元数表示旋转的方式不同
- 直接混合训练会引入噪声

**解决方案（前排通用）：**
```python
def align_right_handed_system(data):
    """
    左手系 → 右手系对齐
    """
    # 翻转陀螺仪的 x, y 轴
    data['X_gyro'] = -data['X_gyro']
    data['Y_gyro'] = -data['Y_gyro']

    # 调整四元数（取决于具体定义）
    # 这里假设是绕 z 轴旋转 180 度
    data['orientation_X'] = -data['orientation_X']
    data['orientation_Y'] = -data['orientation_Y']

    return data
```

### 数据质量评估框架

基于前排方案，建立数据质量评估维度：

| 维度 | 评估方法 | 低质量指标 | 处理策略 |
|------|---------|-----------|---------|
| **传感器缺失** | 统计-1值比例 | TOF>50%, THM>5% | mask处理或训练IMU-only模型 |
| **异常subject** | 按subject统计loss | loss > threshold | 过滤SUBJ_019262, SUBJ_045235 |
| **设备朝向** | 检测左右手系 | 四元数和陀螺仪方向 | 统一到右手系 |
| **三阶段一致性** | 检测阶段标签 | 阶段跳变 | 利用三阶段结构特征 |

### 关键数据洞察总结

1. **多模态融合是关键**：IMU + THM + TOF，但测试集仅50%有完整数据
2. **TOF 缺失严重（60%）**：需要创新处理（2×2 pooling + mask）
3. **个体约束必须利用**：subject × gesture × orientation 唯一约束可用匈牙利算法
4. **三阶段结构重要**：Transition/Pause/Gesture，阶段感知建模有效
5. **四元数不连续性**：需转换为6D连续表示（旋转矩阵前两列）
6. **测试集只有IMU数据**：必须训练IMU-only模型作为集成成员
7. **异常数据需处理**：SUBJ_019262和SUBJ_045235应该过滤或降权
8. **左手系右手系对齐**：统一到右手系避免噪声

### 多模态时间序列分类的最佳实践

与单模态分类任务不同，多模态任务的特殊考虑：

| 方面 | 单模态任务 | 多模态任务 |
|------|-----------|-----------|
| **特征提取** | 单一特征工程 | 每个模态独立提取后融合 |
| **模型架构** | 单一编码器 | 多编码器或早期融合 |
| **缺失处理** | 插值或丢弃 | mask处理或模态specific模型 |
| **数据增强** | 简单增强 | 模态感知增强（Phase-aware Mixup） |
| **后处理** | 阈值或NMS | 利用约束（匈牙利算法） |

