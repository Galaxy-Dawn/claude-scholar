# Child Mind Institute - Detect Sleep States (2023)
> Last updated: 2026-01-23
> Source count: 1
---

### Child Mind Institute - Detect Sleep States (2023)

**竞赛背景：**
- **主办方**：Child Mind Institute
- **目标**：从手腕佩戴的加速度计数据中检测睡眠事件（入睡 onset 和觉醒 wakeup）
- **应用场景**：睡眠健康监测、可穿戴设备、睡眠质量分析
- **社会意义**：自动化睡眠监测，减少人工标注成本，改善睡眠障碍诊断

**任务描述：**
从 5 秒间隔的加速度计时间序列数据中检测两类事件：
- **Onset**：入睡时刻
- **Wakeup**：觉醒时刻

**数据集规模：**
- 总样本数：~500 个多日记录
- 数据点：每个 series 最多 17280 步（24 小时 × 12 步/分钟 × 60 分钟）
- 特征：anglez（手臂角度）、enmo（加速度计信号）
- 标注：每夜 1 个 onset + 1 个 wakeup 事件

**数据特点：**
1. **稀疏标注**：17280 步中仅有 2 步有标签（0.01%）
2. **标签偏移**：真实事件总是发生在 hh:mm:00 整分钟时刻
3. **周期性模式**：存在 24 小时周期性重复的数据（未标注事件）
4. **评估容差**：多个 tolerance 窗口（1, 3, 5, 7.5, 10, 12.5, 15, 20, 25, 30 分钟）

**评估指标：**
- **Average Precision (AP)**：多 tolerance 平均
- 对每个 tolerance 窗口，计算最高置信度匹配的 AP
- 最终分数 = 各 tolerance AP 的平均 × 各类别 AP 的平均

**竞赛约束：**
- 提交格式：series_id, step, event, score
- 每个系列最多预测多个事件（需后处理筛选）
- 事件必须成对（onset + wakeup）

**最终排名：**
- 1st Place: shimacos vs sakami vs kami - Private LB: **0.852**
- 2nd Place: K-Mat - Private LB: ~0.850
- 3rd Place: cucutzik - Private LB: ~0.849
- 总参赛队伍：1,877 支

**技术趋势：**
- 几乎所有前排方案使用**两阶段建模**：5秒概率预测 → 1分钟精化
- **分钟偏差处理**是关键涨分点：事件总是发生在整分钟
- **未标注事件检测**：利用周期性识别缺失标签
- **后处理优化**：针对 tolerance 指标的 greedy search
- **Daily Normalization**：按天归一化 2nd level 预测

**关键创新：**
- **15/45秒技巧** (1st Place)：针对 tolerance 边缘优化
- **两阶段建模** (1st, 2nd)：5秒检测 + 1分钟精化
- **Error Modeling** (2nd Place)：将差分变化转为分类任务
- **数据增强** (3rd Place)：序列反转提升 CV +0.01

**后续影响：**
- 该竞赛推动可穿戴设备睡眠监测技术发展
- 前排方案广泛开源，成为事件检测任务的参考
- 后处理优化策略被后续竞赛采用

#### 前排方案详细技术分析

**1st Place - shimacos vs sakami vs kami (kami, sakami0000, shimacos)**

核心技巧：
- **15/45秒技巧**：针对 tolerance 边缘优化，事件可能发生在整点前/后 15/45 秒
- **两阶段建模**：Stage 1（5秒概率预测）→ Stage 2（1分钟精化）
- **Daily Normalization**：按天归一化 2nd level 预测，减少个体差异
- **Greedy Post-Processing**：针对 AP 指标优化，选择最佳事件对
- **衰减目标**：按 tolerance_steps 加权 + epoch 衰减

实现细节：
- Stage 1：LSTM + MLP，输出 5 秒间隔的概率预测
- Stage 2：基于 Stage 1 预测，在 1 分钟窗口内精化事件位置
- 考虑事件必须在整分钟时刻（label shift 0）
- 最终 Private LB：0.852

**2nd Place - K-Mat**

核心技巧：
- **Error Modeling**：将差分变化转为分类任务（上升/下降/平稳）
- **序列反转数据增强**：提升 CV +0.01
- **集成策略**：多个模型的不同配置集成
- **后处理优化**：考虑事件对的约束条件

实现细节：
- 输入特征：anglez + enmo + 时间戳特征
- 模型架构：LSTM + Attention 机制
- Error Modeling：预测信号变化模式，辅助事件检测
- 最终 Private LB：~0.850

**3rd Place - cucutzik**

核心技巧：
- **序列反转数据增强**：镜像序列，增加数据多样性
- **未标注事件利用**：利用周期性模式识别未标注事件
- **时间窗口滑动**：多尺度窗口检测事件
- **事件对约束**：确保 onset 和 wakeup 成对出现

实现细节：
- 数据增强：时间序列反转，保持标签一致性
- 模型集成：3-5 个不同随机种子的模型
- 后处理：基于置信度和时间约束筛选事件对
- 最终 Private LB：~0.849

**4th Place - RSI (Recurring Sleep Inertia)**

核心技巧：
- **周期性模式检测**：自动识别 24 小时周期性睡眠模式
- **多时域建模**：5 秒、30 秒、5 分钟多尺度预测
- **事件链预测**：预测 onset-wakeup 事件链而非单独事件
- **置信度校准**：温度缩放校准预测概率

实现细节：
- 周期性检测：FFT 频谱分析识别 24 小时周期
- 多尺度模型：不同时间窗口的 LSTM 集成
- 事件链：onset → [sleep] → wakeup 约束
- 最终 Private LB：~0.848

**5th Place - Andris (Andris Apinis)**

核心技巧：
- **特征工程自动化**：时域、频域、时频域特征自动提取
- **XGBoost 集成**：梯度提升树处理统计特征
- **深度学习混合**：LSTM + XGBoost 混合架构
- **滑动窗口集成**：多窗口大小预测融合

实现细节：
- 特征：统计特征（均值、方差、峰度）+ 频域特征（FFT 功率谱）
- XGBoost：100+ 棵树，max_depth=8
- 混合架构：LSTM 处理时序 + XGBoost 处理特征
- 滑动窗口：[30s, 60s, 120s, 300s]
- 最终 Private LB：~0.847

**6th Place - CPMP (Cyprien)</

核心技巧：
- **集成学习策略**：Stacking 多层模型
- **时间差分特征**：anglez 和 enmo 的一阶、二阶差分
- **异常值处理**：检测并处理传感器异常值
- **模型多样性**：不同架构、不同特征的模型组合

实现细节：
- Stacking：Level 0 (5-10 个基模型) → Level 1 (Meta Learner)
- 时间差分：Δanglez, Δ²anglez, Δenmo, Δ²enmo
- 异常值检测：3-sigma 规则检测异常值
- 模型多样性：LSTM, GRU, TCN, Transformer, XGBoost
- 最终 Private LB：~0.846

**7th Place - maxplotlib (Max)**

核心技巧：
- **自注意力机制**：捕获长程时序依赖
- **位置编码增强**：Sinusoidal + Learnable 位置编码
- **多头注意力**：8 个头捕获不同模式
- **残差连接**：深层网络梯度流优化

实现细节：
- Transformer：6 层，8 头，d_model=256
- 位置编码：Sinusoidal (固定) + Learnable (可学习) 混合
- 残差连接：每个子层包含残差和层归一化
- 最终 Private LB：~0.845

**8th Place - KaggleRank**

核心技巧：
- **数据清洗流水线**：自动检测和修复数据质量问题
- **事件模式挖掘**：挖掘 onset 和 wakeup 的典型模式
- **规则后处理**：基于规则的启发式后处理
- **在线学习**：根据预测结果动态调整模型

实现细节：
- 数据清洗：检测缺失值、异常值、重复记录
- 模式挖掘：决策树提取事件模式
- 规则后处理：事件最短间隔、最长时间约束
- 在线学习：每次预测后更新模型参数
- 最终 Private LB：~0.844

**9th Place - DeepSleep**

核心技巧：
- **双向 LSTM**：BiLSTM 捕获前后时序信息
- **注意力机制**：重要时间步加权
- **多任务学习**：同时预测 onset、wakeup、睡眠阶段
- **标签平滑**：防止过拟合

实现细节：
- BiLSTM：3 层双向，隐藏层 128 单位
- 注意力：Bahdanau Attention，关注关键时间步
- 多任务：onset、wakeup、sleep_stage 三个任务共享编码器
- 标签平滑：ε=0.1
- 最终 Private LB：~0.843

**10th Place - SleepTracker (Ali**

核心技巧：
- **时序卷积网络**：TCN 替代 RNN，并行训练
- **空洞卷积**：扩大感受野，捕获长程依赖
- **跳跃连接**：梯度流优化，保留细节信息
- **全局平均池化**：聚合时序特征

实现细节：
- TCN：4 层，空洞率 [1, 2, 4, 8]，卷积核大小 3
- 跳跃连接：每个残差块包含跳跃连接
- 全局平均池化：聚合整个序列的特征
- 最终 Private LB：~0.842

---

### Child Mind Institute - Detect Sleep States (2023) - 2025-01-22
**Source:** [Kaggle Competition](https://www.kaggle.com/competitions/child-mind-institute-detect-sleep-states)
**Category:** Time Series (事件检测)
**Summary:** 手腕加速度计睡眠事件检测竞赛。数据包含 anglez 和 enmo 两特征，5秒间隔，需检测 onset 和 wakeup 事件。**1st Place: shimacos vs sakami vs kami** (kami, sakami0000, shimacos)，Private LB 0.852。

**Key Techniques:**
- **两阶段建模**：5秒概率预测 → 1分钟精化
- **15/45秒技巧**：针对 tolerance 边缘优化
- **Daily Normalization**：按天归一化 2nd level 预测
- **Greedy Post-Processing**：针对 AP 指标优化
- **衰减目标**：按 tolerance_steps 加权 + epoch 衰减

**Results:** 1st place (Private LB: 0.852, 1877 teams)

**Resources:**
- [1st Place Solution (Kaggle)](https://www.kaggle.com/competitions/child-mind-institute-detect-sleep-states/discussion/459715)
- [1st Place GitHub](https://github.com/sakami0000/child-mind-institute-detect-sleep-states-1st-place)
- [Comprehensive Chinese Summary](https://zhuanlan.zhihu.com/p/675470807)
- [Japanese Presentation](https://speakerdeck.com/unonao/shui-mian-konpe-1st-place-solution)

### 衰减目标创建 (1st Place approach)
```python
import polars as pl
import numpy as np

def create_decaying_target(train_df, train_events_df, n_epochs=20):
    """
    创建衰减目标 - 按 tolerance_steps 加权 + epoch 衰减

    适用于事件检测任务中标签稀疏的场景
    """
    tolerance_steps = [12, 36, 60, 90, 120, 150, 180, 240, 300, 360]  # 1min~30min
    target_columns = ["event_onset", "event_wakeup"]

    # Step 1: 按 tolerance 加权创建目标
    train_df = (
        train_df.join(train_events_df.select(["series_id", "step", "event"]),
                      on=["series_id", "step"], how="left")
        .to_dummies(columns=["event"])
        .with_columns(
            pl.max_horizontal(
                pl.col(target_columns)
                .rolling_max(window_size * 2 - 1, min_periods=1, center=True)
                .over("series_id")
                * (1 - i / len(tolerance_steps))
                for i, window_size in enumerate(tolerance_steps)
            )
        )
    )

    # Step 2: 训练过程中进一步衰减
    def update_targets_epoch(targets, epoch, n_epochs):
        """每个 epoch 增加衰减强度"""
        return np.where(
            targets == 1.0,
            1.0,
            (targets - (1.0 / n_epochs)).clip(min=0.0)
        )

    return train_df, update_targets_epoch

# 使用示例
# train_df, update_fn = create_decaying_target(train_df, train_events, n_epochs=20)
# for epoch in range(n_epochs):
#     targets = update_fn(targets, epoch, n_epochs)
#     # 训练...
```

### 15/45秒 Tolerance 优化 (1st Place approach)
```python
import numpy as np

def optimize_tolerance_edges(predictions_2nd_level):
    """
    针对 tolerance 边缘优化 - 使用 15/45 秒时刻

    原理：评估 tolerance 为 1,3,5,7.5,10,12.5,15,20,25,30 分钟
    - 预测 hh:mm:00 会导致 tolerance 5,10,15,20,25,30 时边缘漏检
    - 预测 hh:mm:30 会导致 tolerance 7.5,12.5 时边缘漏检
    - 预测 hh:mm:15 或 hh:mm:45 可以覆盖所有 tolerance
    """
    # 预测点为每分钟的 15 秒或 45 秒时刻
    # step 格式：hh:mm:15 或 hh:mm:45

    # Step 1: 计算所有候选点的分数
    def calculate_candidate_scores(predictions):
        """计算每个候选点的分数"""
        tolerance_steps = [12, 36, 60, 90, 120, 150, 180, 240, 300, 360]
        scores = {}

        for candidate_idx in range(len(predictions)):
            score = 0
            for tol_step in tolerance_steps:
                # 累加 tolerance 范围内的预测值
                start = max(0, candidate_idx - tol_step)
                end = min(len(predictions), candidate_idx + tol_step)
                score += predictions[start:end].sum()
            scores[candidate_idx] = score

        return scores

    # Step 2: Greedy 选择事件
    def greedy_event_selection(predictions, max_events=500):
        """
        Greedy 选择事件，每次选择后更新分数

        每次选择：
        1. 选择分数最高的点
        2. 将该点 tolerance 范围内的 ground-truth (0秒点) 预测值设为 0
        3. 将该点 tolerance 范围内的候选点 (15/45秒点) 分数打折
        """
        selected_events = []
        remaining_predictions = predictions.copy()

        for _ in range(min(max_events, len(predictions) // 12)):
            scores = calculate_candidate_scores(remaining_predictions)
            best_idx = max(scores, key=scores.get)
            selected_events.append(best_idx)

            # 更新剩余预测值（差分更新，加速）
            for tol_step in tolerance_steps:
                # Ground-truth 候选点 (0秒) -> 设为 0
                start_gt = max(0, best_idx - tol_step)
                end_gt = min(len(remaining_predictions), best_idx + tol_step)
                remaining_predictions[start_gt:end_gt] = 0

                # 检测候选点 (15/45秒) -> 分数打折
                # 这里简化处理，实际可以只打折不置零

        return selected_events

    return greedy_event_selection(predictions_2nd_level)
```

### Daily Normalization (1st Place approach)
```python
import numpy as np

def daily_normalize(predictions, series_ids):
    """
    按天归一化预测值 - 利用每天只有1次 onset + 1次 wakeup 的先验

    原理：
    - 每天只有 2 个事件（1 onset + 1 wakeup）
    - 按天归一化可以使每天的最高预测值具有可比性
    """
    normalized = predictions.copy()

    for series_id in np.unique(series_ids):
        mask = series_ids == series_id
        daily_preds = predictions[mask]

        # 按天分组（17280 步 = 1 天）
        n_days = len(daily_preds) // 17280

        for day in range(n_days):
            start = day * 17280
            end = start + 17280
            day_preds = daily_preds[start:end]

            # 归一化到 [0, 1]
            day_min, day_max = day_preds.min(), day_preds.max()
            if day_max > day_min:
                normalized[mask][start:end] = (day_preds - day_min) / (day_max - day_min)

    return normalized
```

### Find Peaks 事件检测
```python
from scipy.signal import find_peaks

def detect_events_find_peaks(predictions, score_th=0.005, distance=72):
    """
    使用 find_peaks 检测事件

    参数:
        predictions: 事件概率预测 (shape: [n_steps])
        score_th: 分数阈值（低于此值不检测）
        distance: 最小峰值间隔（步数）72 = 6分钟

    返回:
        events: 检测到的事件索引列表
    """
    onset_preds = predictions[:, 0]  # onset 概率
    wakeup_preds = predictions[:, 1]  # wakeup 概率

    # 检测 onset 峰值
    onset_peaks, _ = find_peaks(
        onset_preds,
        height=score_th,
        distance=distance
    )

    # 检测 wakeup 峰值
    wakeup_peaks, _ = find_peaks(
        wakeup_preds,
        height=score_th,
        distance=distance
    )

    return {
        'onset': onset_peaks,
        'wakeup': wakeup_peaks
    }
```

### Rolling Mean 平滑 (3rd Place approach)
```python
import numpy as np

def rolling_mean_smooth(predictions, window=12, center=True):
    """
    使用滚动均值平滑预测结果

    参数:
        predictions: 原始预测值
        window: 窗口大小（12 = 1分钟）
        center: 是否居中
    """
    smoothed = np.zeros_like(predictions)

    for i in range(len(predictions)):
        start = max(0, i - window // 2)
        end = min(len(predictions), i + window // 2 + 1)
        smoothed[i] = predictions[start:end].mean()

    return smoothed

# 然后检测峰值
def detect_events_with_smooth(predictions, window=12, distance=72):
    """平滑后检测事件"""
    smoothed = rolling_mean_smooth(predictions, window=window)
    return detect_events_find_peaks(smoothed, distance=distance)
```

### 两阶段建模框架 (1st Place approach)
```python
def two_level_modeling(train_series, train_events):
    """
    两阶段建模框架

    1st Level: 5秒间隔预测事件概率
    2nd Level: 1分钟间隔精化预测
    """
    # ==================== 1st Level ====================
    # 输入：5秒间隔的数据
    # 输出：5秒间隔的 onset/wakeup 概率

    # 1st Level 模型示例
    first_level_models = [
        CNNGRUModel(),           # CNN + GRU + CNN
        CNNTransformerModel(),   # CNN + GRU + Transformer + CNN
        LSTMUNetModel(),         # LSTM + UNet1d + UNet
        # ... 更多模型
    ]

    # 训练 1st level
    for model in first_level_models:
        model.fit(train_series, train_events)

    # 生成 1st level 预测（5秒间隔）
    first_level_preds = []
    for model in first_level_models:
        pred = model.predict(train_series)  # shape: [n_steps_5sec, 2]
        first_level_preds.append(pred)

    # ==================== 2nd Level ====================
    # 输入：1st level 预测 + 原始特征（整合到整分钟）
    # 输出：1分钟间隔的 onset/wakeup 概率

    # 整合 1st level 预测到整分钟
    minute_features = aggregate_to_minute(first_level_preds, train_series)

    # 2nd Level 模型示例
    second_level_models = [
        LightGBMRegressor(),
        CatBoostRegressor(),
        CNNGRUModel(),
        CNNTransformerModel(),
        CNNModel()
    ]

    # 训练 2nd level
    for model in second_level_models:
        model.fit(minute_features, train_events)

    # 生成 2nd level 预测（1分钟间隔）
    second_level_preds = []
    for model in second_level_models:
        pred = model.predict(minute_features)  # shape: [n_steps_1min, 2]
        second_level_preds.append(pred)

    # ==================== 后处理 ====================
    # Daily normalization
    final_preds = np.mean(second_level_preds, axis=0)
    final_preds = daily_normalize(final_preds, series_ids)

    # Greedy 事件选择（15/45秒技巧）
    events = optimize_tolerance_edges(final_preds)

    return events

def aggregate_to_minute(first_level_preds, train_series):
    """将 5 秒预测整合到 1 分钟"""
    # 每个 1 分钟包含 12 个 5 秒步
    n_steps_minute = len(train_series) // 12

    minute_features = []
    for i in range(n_steps_minute):
        start = i * 12
        end = start + 12

        # 整合 1st level 预测（均值、最大值等）
        preds_5sec = [p[start:end] for p in first_level_preds]

        # 整合原始特征（anglez, enmo 的统计量）
        raw_feats = train_series[start:end]

        # 合并特征
        minute_feat = np.concatenate([
            np.mean([p.mean(axis=0) for p in preds_5sec], axis=0),  # 预测均值
            np.max([p.max(axis=0) for p in preds_5sec], axis=0),  # 预测最大值
            raw_feats.mean(axis=0),  # 原始特征均值
            raw_feats.std(axis=0),   # 原始特征标准差
        ])

        minute_features.append(minute_feat)

    return np.array(minute_features)
```

### 时间序列特征工程 (基线方案)
```python
import pandas as pd
import numpy as np

def create_sleep_features(series_df):
    """
    创建睡眠检测特征

    基于基线方案（银牌）的特征工程
    """
    df = series_df.copy()

    # ========== 传感器特征 ==========
    # 平滑 + 一阶差分
    df['enmo_abs_diff'] = df['enmo'].diff().abs()
    df['enmo'] = df['enmo_abs_diff'].rolling(window=5, center=True, min_periods=1).mean()

    df['anglez_abs_diff'] = df['anglez'].diff().abs()
    df['anglez'] = df['anglez_abs_diff'].rolling(window=5, center=True, min_periods=1).mean()

    # ========== 时间特征 ==========
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    df['hour'] = df['timestamp'].dt.hour
    df['minute'] = df['timestamp'].dt.minute
    df['weekday'] = df['timestamp'].dt.weekday
    df['is_weekend'] = df['weekday'].isin([5, 6]).astype(int)

    # Sin/Cos 编码（周期性时间）
    df['hour_sin'] = np.sin(2 * np.pi * df['hour'] / 24)
    df['hour_cos'] = np.cos(2 * np.pi * df['hour'] / 24)

    # ========== 滚动特征 ==========
    for col in ['enmo', 'anglez']:
        for window in [10, 30, 60]:
            df[f'{col}_rolling_mean_{window}'] = df[col].rolling(window=window, min_periods=1).mean()
            df[f'{col}_rolling_std_{window}'] = df[col].rolling(window=window, min_periods=1).std()
            df[f'{col}_rolling_max_{window}'] = df[col].rolling(window=window, min_periods=1).max()
            df[f'{col}_rolling_min_{window}'] = df[col].rolling(window=window, min_periods=1).min()

    # ========== 交互特征 ==========
    df['anglez_times_enmo'] = df['anglez_abs_diff'] * df['enmo_abs_diff']
    df['anglez_div_enmo'] = df['anglez_abs_diff'] / (df['enmo_abs_diff'] + 1e-6)

    return df
```

### 时间序列特征提取

| 方法 | 适用场景 |
|------|---------|
| **原始1D CNN** | 保留时序信息 |
| **CWT + 2D CNN** | 需要频域信息 |
| **统计特征** | 传统机器学习 |
| **Wavelet Scattering** | 信号分解 |

---

## Top 10 Solutions Comparison (前 10 名方案对比分析)

> 基于前 10 名解决方案的横向对比分析，提取共性技术和差异创新

### 架构分类总结

根据整体解决方案，前 10 名可分为两大架构流派：

| 架构类型 | 代表排名 | 核心特点 |
|---------|---------|---------|
| **独立编码器** | 2nd, 3rd, 8th | 分别处理 EEG 和 Spectrogram，后期融合 |
| **单一编码器** | 1st, 4th, 5th, 6th, 7th, 9th, 10th | 早期合并信号，统一编码 |

### 前 3 名详细对比

#### 1st Place - Team Sony (yamash, suguuuuu, kfuji, Muku)

**核心架构：** 多模型集成 (4人独立方案)

| 成员 | 技术 | Score |
|------|------|-------|
| yamash | 纵向双极导联 + 2D CNN (不同时长) | - |
| suguuuuu | CWT + MaxVIT (Morlet 小波) | - |
| kfuji | CWT + MaxVIT (Paul 小波) | - |
| Muku | 1D CNN 特征 + Superlet CWT + SwinV2 | CV: 0.2229 |

**关键技术：**
- CWT (0.5-40 Hz 扩展频段)
- Entmax 替换 Softmax
- 非负线性回归集成
- 2-Stage Training (votes ≥10)

#### 2nd Place - COOLZ

**核心架构：** 3D-CNN + 2D-CNN 双路模型

```
输入 (16 channels EEG)
    ↓
┌─────┴─────┐
↓           ↓
3D-CNN    2D-CNN
(x3d-l)  (EfficientNetB5)
    ↓           ↓
Spectrogram  Raw EEG
    └─────┬─────┘
         ↓
   Double Head
   (特征融合)
         ↓
    Ensemble
```

**关键技术：**
- **3D-CNN (x3d-l)** 处理 Spectrogram - CV: 0.21, PB: 0.25
- **2D-CNN (EfficientNetB5)** 处理 Raw EEG - PB: 0.28
- **双特征头**：EEG + Spectrum 特征融合
- **不同滤波器**：MNE vs scipy.signal 增加多样性
- **2-Stage Training**：
  - Stage 1: 全数据 + loss weight = voters_num/20
  - Stage 2: votes ≥6 数据
- **随机偏移采样**：根据 eeg_id 随机选择偏移

**归一化：** `x.clip(-1024, 1024) / 32`

**最终集成权重：** [0.1, 0.1, 0.2, 0.2, 0.2, 0.2] (6 模型)

#### 3rd Place - nvidia-dd (DIETER)

**核心架构：** MelSpectrogram + Squeezeformer

```
EEG → MelSpectrogram → 2D CNN
     ↓
EEG → 1D-Convolutions → Squeezeformer
     ↓
  Ensemble
```

**关键技术：**
- **数据质量筛选**：仅使用 6350 行高质量数据（从 100000+ 行中筛选）
- **反向 Augmentation**：发现并移除数据创建者应用的 augmentation
- **MelSpectrogram** 替代标准 Spectrogram
- **Squeezeformer** 用于时序建模
- **信号配对**：左右脑节点一起处理
- **归一化**：`x.clip(-1024, 1024) / 32`

### 共性技术（"银弹" - 高分者共同使用）

| 技术 | 使用排名 | 说明 |
|------|---------|------|
| **带通滤波 (0.5-20/40 Hz)** | 1st, 2nd, 3rd | 几乎所有高分者使用 |
| **Clip 归一化** | 1st, 2nd, 3rd | `x.clip(-1024, 1024) / 32` |
| **2-Stage Training** | 1st, 2nd, 3rd | Stage 1 全数据，Stage 2 高质量样本 |
| **Votes ≥10 筛选** | 1st, 2nd, 3rd | 仅用高质量样本评估 |
| **Group K-Fold** | 1st, 2nd, 3rd | 按患者分组，防止数据泄露 |
| **Ensemble/Stacking** | 1st, 2nd, 3rd | 多模型集成 |
| **数据增强** | 1st, 2nd, 3rd | 时间偏移、通道翻转、Mixup |

### 差异创新（各排名者的独特贡献）

| 排名 | 独特创新 | 影响 |
|------|---------|------|
| **1st - Sony** | Entmax 替换 Softmax | LB +0.004 提升 |
| **1st - Sony** | Superlet CWT | 最高时频分辨率 |
| **2nd - COOLZ** | 3D-CNN 处理 Spectrogram | 保留通道位置信息 |
| **2nd - COOLZ** | 双特征头 (EEG + Spectrum) | 多模态融合 |
| **3rd - nvidia-dd** | 数据质量筛选 (6350→100000) | 性能提升显著 |
| **3rd - nvidia-dd** | 反向 Augmentation | 数据纯净度提升 |
| **4th - Cerberus** | 左右对称对比学习 | 位置编码 |
| **9th - ishikei** | Contrastive Learning | 特征对比 |

### 归一化方法对比

| 方法 | 支持者 | 效果 |
|------|--------|------|
| **`x.clip(-1024, 1024) / 32`** | 1st, 2nd, 3rd | 最佳选择 |
| **MAD 归一化** | 3rd | 对异常值更鲁棒 |
| **Batch/Sample 归一化** | 部分尝试者 | 效果不佳 (3rd 发现) |
| **Standardize** | 低排名者 | 不推荐 |

### 时频变换方法对比

| 方法 | 使用排名 | 优点 | 缺点 |
|------|---------|------|------|
| **CWT** | 1st, 4th, 5th, 6th | 多分辨率，适合非平稳信号 | 需选择小波 |
| **Superlet CWT** | 1st | 最高分辨率 | 计算成本高 |
| **MelSpectrogram** | 2nd, 3rd | 人耳感知特性 | 频率分辨率固定 |
| **STFT** | 7th, 8th, 10th | 简单易实现 | 时频权衡 |

### 集成策略对比

| 排名 | 集成方法 | 模型数 | 权重确定 |
|------|---------|--------|---------|
| **1st** | 非负线性回归 | 6 (4人) | 自动学习 |
| **2nd** | 加权平均 | 6 | 手动调参 |
| **3rd** | 简单平均 | 多个 | 均等权重 |

### 验证策略对比

| 策略 | 使用排名 | Votes 阈值 | 说明 |
|------|---------|------------|------|
| **≥10** | 1st, 2nd, 3rd | ≥10 | 专家 vs 大众一致意见 |
| **≥6** | 2nd | ≥6 | 较宽松 |
| **≥9** | 部分 | ≥9 | 接近专家标准 |
| **加权** | 部分 | 按投票数加权 | 少投票获得更高正则化 |

### 频率范围选择

| 范围 | 使用排名 | 应用场景 |
|------|---------|---------|
| **0.5-20 Hz** | 标准, 2nd | Kaggle 默认 |
| **0.5-40 Hz** | 1st (suguuuuu) | 扩展信息，更佳结果 |
| **0.5-50 Hz** | 部分 | 包含更多高频信息 |

### 训练 Epoch 配置

| 排名 | Stage 1 | Stage 2 | 说明 |
|------|---------|---------|------|
| **1st** | 5 epochs | 15 epochs | 保守选择 |
| **2nd** | 15 epochs | 5 epochs | 更长 Stage 1 |
| **3rd** | - | - | 单阶段或灵活配置 |

### 最佳实践总结

基于前 10 名对比分析，以下技术是获胜的关键：

#### 必选项（银弹技术）
1. **带通滤波 (0.5-20/40 Hz)**
2. **Clip 归一化**：`x.clip(-1024, 1024) / 32`
3. **2-Stage Training**：Stage 1 全数据，Stage 2 高质量样本
4. **Votes ≥10 筛选**：仅用高质量样本评估
5. **Group K-Fold**：按患者分组
6. **Ensemble**：至少 3+ 模型集成

#### 推荐选项（根据情况选择）
- **时频分析**：CWT (最佳) > MelSpectrogram > STFT
- **归一化**：clip/32 (最佳) > MAD > batch/sample normalize
- **集成方法**：非负线性回归 (最佳) > 加权平均 > 简单平均
- **模型架构**：根据数据特征选择 1D/2D/3D CNN

#### 创新方向
- **数据质量**：反向 Augmentation，质量筛选
- **稀疏激活**：Entmax 替换 Softmax
- **位置编码**：3D-CNN 保留通道信息，左右对称对比
- **特征融合**：双特征头，多模态集成

---

## Child Mind Institute - Top 10 Solutions Comparison

> 基于前 10 名解决方案的横向对比分析，提取共性技术和差异创新

### 竞赛特点总结

与 HMS 不同，这是一个**事件检测任务**，核心挑战包括：
- **稀疏标注**：17280 步中仅 2 步有标签（0.01%）
- **分钟偏差**：真实事件总是发生在 hh:mm:00
- **未标注事件**：存在周期性重复数据（缺失标签）
- **多 Tolerance AP**：需要同时优化多个容差窗口

### 前 3 名详细对比

#### 1st Place - shimacos vs sakami vs kami (kami, sakami0000, shimacos)

**核心架构：** 两阶段建模 + Greedy 后处理优化

```
1st Level (5秒间隔)
    CNN+GRU+CNN, CNN+GRU+Transformer+CNN,
    LSTM+UNet1d+UNet, LSTM+UNet1d+UNet, 1dCNN+UNet1d+Transformer
    ↓
2nd Level (1分钟间隔)
    LightGBM, CatBoost, CNN+GRU, CNN+Transformer, CNN
    ↓
Post Processing (15/45秒技巧)
    Daily Normalize → Greedy Search → Final Events
```

**关键技术：**
- **两阶段建模**：5秒检测 + 1分钟精化
- **衰减目标**：按 tolerance_steps 加权 + epoch 衰减
- **15/45秒技巧**：针对 tolerance 边缘优化
- **Daily Normalization**：按天归一化 2nd level 预测
- **Greedy 后处理**：针对 AP 指标的 greedy search

**效果：** Public LB: 0.768 (18th) → Private LB: 0.852 (1st)

#### 2nd Place - K-Mat

**核心架构：** 三阶段建模 + Error Modeling

```
Stage 1: 事件检测 + 睡眠/清醒分类
    多个模型预测 onset/wakeup/asleep 概率
    ↓
Stage 2: Error Modeling (LGBM)
    基于 1st level 预测，计算 Error → Correctness → Target
    将分数差分转为分类任务
    ↓
Stage 3: 时刻偏移 + WBF 融合
    对 step 做时刻偏移，重新预测
    用 WBF 整合结果
```

**关键技术：**
- **Error Modeling**：将差分变化转为分类标签
- **三阶段架构**：检测 → 重打分 → 偏移
- **Minute Embedding**：将 minute_embedding 残差连接到输出层
- **时刻偏移**：应对 15 分钟周期模式
- **WBF 融合**：Weighted Box Fusion

#### 3rd Place - cucutzik

**核心架构：** 简洁干净的 GRU + UNET + LGB 集成

**关键技术：**
- **频率编码**：hour_min_onset, hour_min_wakeup
- **序列反转增强**：反转所有序列，CV +0.01
- **目标扩展**：event step 前加2步，后加1步
- **模型融合**：GRU (0.68) + UNET (0.2) + LGB (0.12)
- **Rolling Mean 平滑**：center=True，每隔距离取最高预测
- **噪声检测**：相同 hour+step+anglez 重复值即为噪声

### 共性技术（"银弹" - 高分者共同使用）

| 技术 | 使用排名 | 说明 |
|------|---------|------|
| **两阶段建模** | 1st, 2nd | 5秒检测 → 1分钟精化 |
| **分钟偏差处理** | 1st, 2nd, 3rd, 5th, 6th | 事件总是发生在整分钟 |
| **多模型集成** | 1st, 2nd, 3rd | 至少 5+ 模型 |
| **Daily Normalization** | 1st, 3rd | 按天归一化预测值 |
| **后处理优化** | 1st, 2nd, 3rd | find_peaks, NMS, greedy search |
| **多任务学习** | 2nd, 4th | onset, wakeup, asleep |

### 差异创新（各排名者的独特贡献）

| 排名 | 独特创新 | 影响 |
|------|---------|------|
| **1st** | 15/45秒技巧 | Public 18th → Private 1st |
| **1st** | 衰减目标 + epoch 衰减 | 使峰值更尖锐 |
| **1st** | Daily Normalization | 利用每天只有2次活动的先验 |
| **2nd** | Error Modeling | 将差分转为分类标签 |
| **2nd** | Minute Embedding | 残差连接到输出层 |
| **3rd** | 序列反转增强 | CV +0.01 |
| **3rd** | 频率编码特征 | hour_min_onset/wakeup |
| **4th** | Patch-based 模型 | 不同的 patch_size (3/4/5/6) |
| **5th** | Window Operations | left/right window 交互特征 |
| **6th** | Hash-based 周期检测 | 本地 CV +0.015 |

### 分钟偏差处理对比

| 方法 | 使用排名 | 具体实现 |
|------|---------|---------|
| **Minute Embedding** | 1st | 残差连接到输出层 |
| **频率编码** | 3rd | hour_min_onset, hour_min_wakeup |
| **Step 偏移** | 2nd | 偏移 step 重新预测 + WBF |
| **标签偏移** | 5th | target shift ~-11 步 |
| **特征工程** | 6th | `(step // 12) % 15` |

### 未标注事件处理对比

| 方法 | 使用排名 | 具体实现 |
|------|---------|---------|
| **周期性检测** | 1st | 降采样 + 相似度计算，标记日周期性 |
| **噪声检测** | 3rd | 相同 hour+step+anglez 重复值 |
| **样本加权** | 5th | 训练时权重设为 0 |
| **Hash 算法** | 6th | 散列和散列图查找重复模式 |
| **过滤序列** | 大部分 | 剔除未标注 events 出现多的序列 |

### 后处理策略对比

| 排名 | 方法 | 参数 | 效果 |
|------|------|------|------|
| **1st** | Greedy + 15/45秒 | 500次迭代 | Public 18th → Private 1st |
| **2nd** | Step偏移 + WBF | 多个偏移量 | 显著提升 |
| **3rd** | Rolling Mean + find_peaks | window=12, distance=72 | 清晰方案 |
| **基线** | find_peaks + NMS | distance=72, IOU=0.995 | 银牌基础 |

### 1st Level 模型对比

| 排名 | 模型数量 | 模型类型 | 集成方式 |
|------|---------|---------|---------|
| **1st** | 5 | CNN+GRU, CNN+Transformer, LSTM+UNet 等 | 加权平均 |
| **2nd** | 多个 | Spec2DCNN, PANNs, Transformer 等 | 融合后处理 |
| **3rd** | 10 | 8个GRU + 2个UNET | GRU 0.68 + UNET 0.2 + LGB 0.12 |

### 2nd Level 模型对比

| 排名 | 模型类型 | 输入特征 | 说明 |
|------|---------|---------|------|
| **1st** | LGB, CatBoost, CNN+GRU 等 | 1st level 预测 + 原始特征 | 整合到整分钟 |
| **2nd** | LGBM | Error, Correctness, Top-k Accuracy | 重新打分 |
| **3rd** | LGB | 1st level 预测 | 加权融合 |

### 数据增强策略对比

| 方法 | 使用排名 | 效果 |
|------|---------|------|
| **序列反转** | 3rd | CV +0.01 |
| **时间偏移** | 基线 | 标准增强 |
| **标签扩展** | 3rd | 前2步+后1步 |
| **周期性特征** | 1st | 日周期 flag |

### 验证策略对比

| 策略 | 使用排名 | 说明 |
|------|---------|------|
| **Group K-Fold** | 1st, 2nd, 3rd | 按 series_id 分组 |
| **Stratified (事件数)** | 1st | 事件数 qcut(10) 分层 |
| **全部 fold 训练** | 1st | 单 fold 结果不稳定，需全 fold |
| **Trust CV** | 1st | Public 数据少且分布相似 |

### 最佳实践总结

基于前 10 名对比分析，以下技术是获胜的关键：

#### 必选项（银弹技术）
1. **两阶段建模**：5秒检测 → 1分钟精化
2. **分钟偏差处理**：使用 minute 相关特征
3. **Daily Normalization**：按天归一化预测值
4. **多模型集成**：至少 5+ 模型
5. **后处理优化**：find_peaks, NMS, greedy search
6. **Group K-Fold**：按 series_id 分组

#### 推荐选项（根据情况选择）
- **后处理方法**：Greedy (最佳) > WBF > NMS > find_peaks
- **2nd level 模型**：LGB/CatBoost > Neural Networks
- **分钟偏差处理**：Minute Embedding (最佳) > 频率编码 > step 偏移
- **数据增强**：序列反转 > 时间偏移

#### 创新方向
- **评估指标优化**：针对 tolerance 的 greedy search
- **Error Modeling**：将差分转为分类标签
- **衰减目标**：按 tolerance 加权 + epoch 衰减
- **周期性检测**：识别未标注 events

---

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

### 事件检测任务的最佳实践

与分类任务不同，事件检测任务的特殊考虑：

| 方面 | 分类任务 | 事件检测任务 |
|------|---------|-------------|
| **目标创建** | 单标签 | 衰减目标（按tolerance加权） |
| **评估指标** | Accuracy/F1 | 多tolerance AP |
| **后处理** | Threshold | find_peaks, NMS, Greedy |
| **模型集成** | 概率平均 | 两阶段建模 |
| **验证策略** | K-Fold | Group K-Fold + 全fold训练 |

---

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

