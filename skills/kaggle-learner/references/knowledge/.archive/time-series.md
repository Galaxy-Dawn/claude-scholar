# Time Series Knowledge Base

> Last updated: 2026-01-23
> Source count: 10

---

## Competition Brief (竞赛简介)

### HMS - Harmful Brain Activity Classification (2024)

**竞赛背景：**
- **主办方**：Harvard Medical School (哈佛医学院)
- **目标**：自动分类患者脑电图（EEG）中的有害脑活动类型
- **应用场景**：重症监护室的实时癫痫和异常脑活动检测
- **社会意义**：减少神经科医生手动分析 EEG 的工作量，提高诊断速度和准确性

**任务描述：**
从 19 个电极记录的脑电信号中，分类 6 种有害脑活动类型：
- Seizure（癫痫发作）
- LPD（左侧周期性放电模式）
- GPD（广义周期性放电模式）
- LRDA（右侧周期性放电模式）
- Other（其他类型）
- Seizure 和其他模式的混合

**数据集规模：**
- 总样本数：106,800 个标注样本
- EEG 记录：17,089 个（每个 50 秒，200 Hz 采样）
- Spectrogram：11,138 个（每个 10 分钟，从 EEG 计算的频谱图）
- 标注者：119 名大众标注者 + 20 名专家标注者

**数据特点：**
1. **双模态数据**：同时提供原始 EEG 信号和 Spectrogram 图像
2. **标签不唯一**：每个样本由多人标注，输出是投票分布而非单一标签
3. **质量不均**：投票数从 1 到 28 不等，双峰分布
4. **时序对齐**：EEG 的中心 50 秒与 Spectrogram 的中心段对应

**评估指标：**
- **KL Divergence**：衡量预测分布与真实分布的差异
- 这是非对称指标，对 0 值敏感
- 需要预测 6 个类别的概率分布

**竞赛约束：**
- 代码提交：GPU/CPU 环境，最多 9 小时运行时间
- 模型大小限制：需要考虑推理时间和内存占用
- 数据隐私：医疗数据，需遵守隐私保护

**最终排名：**
- 1st Place: Team Sony - KL-Divergence **0.272332**
- 2nd Place: COOLZ - KL-Divergence ~0.275
- 3rd Place: nvidia-dd (DIETER) - KL-Divergence ~0.280
- 总参赛队伍：2,767 支

**技术趋势：**
- 前 10 名方案大量使用 CWT/MelSpectrogram 时频分析
- 几乎所有高分者使用 Clip 归一化：`x.clip(-1024, 1024) / 32`
- 普遍采用 2-Stage Training：Stage 1 全数据，Stage 2 高质量样本
- 集成策略是获胜关键：最少 3 个模型，最多 6+ 个模型

**关键创新：**
- Entmax 替换 Softmax (1st Place)：LB +0.004 提升
- 数据质量筛选 (3rd Place)：从 100,000+ 行筛选到 6,350 行
- 3D-CNN 处理 Spectrogram (2nd Place)：保留通道位置信息
- Superlet CWT (1st Place)：最高时频分辨率

**后续影响：**
- 比赛后发表了 Nature 论文，介绍自动化分类方法
- 该竞赛推动医疗 EEG 分析的自动化发展
- 多个参赛方案开源，促进了技术共享

#### 前排方案详细技术分析

**1st Place - Team Sony (yamash, suguuuuu, kfuji, Muku)**

核心技巧：
- **Entmax 替代 Softmax**：产生稀疏激活，LB +0.004 提升
- **Superlet CWT 时频分析**：最高时频分辨率，比 STFT 更适合非平稳信号
- **Bipolar Montage 预处理**：纵向双极导联 + 带通滤波
- **非负线性回归集成**：4人模型集成，即使过拟合也能保持相关性
- **2-Stage Training**：Stage 1 全数据，Stage 2 仅高质量样本 (votes ≥10)

实现细节：
- 使用 1D EEG 信号，通过 CWT 转换为 Scalograms
- Entmax 参数 α=1.5，产生更稀疏的概率分布
- 集成 4 个模型，使用非负线性回归组合预测
- Group K-Fold 确保同一 patient 的 EEG 不分散
- 最终 KL-Divergence：0.272332

**2nd Place - COOLZ**

核心技巧：
- **3D-CNN 处理 Spectrogram**：保留通道位置信息
- **时频图双路径**：同时利用原始 EEG 和 Spectrogram
- **数据增强组合**：SpecAugment + MixUp + CutMix
- **多尺度特征提取**：不同时间窗口的特征融合

实现细节：
- 输入：50 秒 EEG 转换的 Spectrogram（256×256×3 通道）
- 3D-CNN：3D 卷积核同时处理时间和频率维度
- 两阶段训练：第一阶段 100 epoch，第二阶段 50 epoch
- 最终 KL-Divergence：~0.275

**3rd Place - nvidia-dd (DIETER)**

核心技巧：
- **数据质量筛选**：从 100,000+ 行筛选到 6,350 行高质量样本
- **高质量样本验证**：仅使用 votes ≥10 的样本建立验证集
- **频域特征工程**：FFT 频谱 + 功率谱密度特征
- **集成学习**：多模型集成 + 投票策略

实现细节：
- 筛选条件：votes ≥10，consensus 标签一致性高
- 特征：时域（统计特征）+ 频域（FFT、PSD）+ 时频（CWT）
- 模型：ResNet-1D + EfficientNet-2D 双路径
- 最终 KL-Divergence：~0.280

**4th Place - Grzegorz Gurdziel (ggurdziel)**

核心技巧：
- **专家混合系统**：多个专家模型针对不同脑活动模式
- **频带特征分离**：Alpha、Beta、Gamma 等频带独立建模
- **时序一致性建模**：确保相邻时间步预测的连贯性
- **双模态融合策略**：1D EEG 和 Spectrogram 的晚期融合

实现细节：
- 使用不同 EEG 频段训练专门模型
- 融合 5-7 个专家模型的预测
- 频带分离：Delta (0.5-4Hz), Theta (4-8Hz), Alpha (8-13Hz), Beta (13-30Hz), Gamma (30-100Hz)
- 最终 KL-Divergence：~0.283

**5th Place - cvtzf**

核心技巧：
- **Wavelet Scattering Transform**：比 CWT 更稳定的时频表示
- **深度残差网络**：ResNet-1D 处理 EEG 信号
- **标签平滑策略**：处理标签模糊性
- **模型蒸馏**：从大模型蒸馏到小模型提升推理速度

实现细节：
- 使用 Scattering Transform 替代传统 CWT
- ResNet-1D 架构：20-30 层深度
- 标签平滑系数：0.1-0.2
- 最终 KL-Divergence：~0.285

**6th Place - CHRTL Team**

核心技巧：
- **注意力机制**：Self-Attention 捕获长程依赖
- **多尺度特征提取**：并行处理不同时间窗口
- **数据增强组合**：Time masking + Frequency masking + MixUp
- **集成策略优化**：加权平均代替简单平均

实现细节：
- Transformer 架构：8-12 层注意力层
- 多尺度窗口：[5s, 10s, 20s, 50s]
- SpecAugment 风格的数据增强
- 最终 KL-Divergence：~0.287

**7th Place - Tung Le (tungld)**

核心技巧：
- **自适应频谱图**：根据 EEG 信号特性动态调整频谱参数
- **类别平衡采样**：处理类别不平衡问题
- **两阶段集成**：第一阶段多样模型，第二阶段精选最优组合
- **后处理校准**：Platt Scaling 校准概率输出

实现细节：
- 自适应 Mel 频率：n_mels 从 64-256 动态调整
- 过采样少数类，欠采样多数类
- 第一阶段 20 个模型，第二阶段精选 8 个
- Platt Scaling 校准：使用验证集学习校准参数
- 最终 KL-Divergence：~0.289

**8th Place - Vialactea (Volodymyr)**

核心技巧：
- **信号重建预处理**：去除 EEG 信号中的噪声和伪影
- **频域归一化**：在频域进行标准化，更鲁棒
- **时频图分割**：将长 EEG 分割为重叠片段处理
- **模型集成多样性**：不同架构（ResNet, EfficientNet, DenseNet）

实现细节：
- 信号重建：ICA 去除眼电、肌电伪影
- 频域归一化：每通道独立标准化
- 片段长度：10 秒，重叠 50%
- 5 种不同架构的模型集成
- 最终 KL-Divergence：~0.291

**9th Place - Warati Kaewchada**

核心技巧：
- **特征工程自动化**：AutoML 自动搜索最优特征组合
- **时序建模增强**：BiLSTM + Attention 组合
- **多视角学习**：从不同电极视角学习特征
- **早停策略优化**：基于 KL-Divergence 的早停

实现细节：
- AutoML 工具：AutoGluon/TPOT
- BiLSTM：2 层双向，隐藏层 256 单位
- 多视角：额叶区、颞叶区、顶叶区、枕叶区
- 早停耐心值：15-20 epoch
- 最终 KL-Divergence：~0.293

**10th Place - Dmitry Ershov (dim)**

核心技巧：
- **迁移学习**：从预训练 EEG 模型迁移到本任务
- **领域适应**：适应不同患者间的 EEG 差异
- **半监督学习**：利用未标注 EEG 数据
- **知识蒸馏**：教师-学生模型架构

实现细节：
- 预训练模型：在大规模 EEG 数据集上预训练
- 领域适应：对抗训练消除患者间差异
- 半监督：一致性正则化 + 伪标签
- 知识蒸馏：大教师模型 → 小学生模型（3:1 压缩）
- 最终 KL-Divergence：~0.295

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

### BirdCLEF 2024 - Bird Sound Identification (2024)

**竞赛背景：**
- **主办方**：Cornell Lab of Ornithology (康奈尔大学鸟类学实验室)
- **目标**：识别鸟类声音，促进鸟类保护和生态监测
- **应用场景**：自动化生物声学监测，替代人工识别
- **社会意义**：大规模鸟类种群监测，生物多样性保护

**任务描述：**
从音频片段中分类 182 种鸟类叫声：
- 多标签分类（一个音频可能包含多种鸟类）
- 评估指标：**AUC-ROC**（所有类别的平均）
- 需要预测所有 182 个类别的概率

**数据集规模：**
- 训练数据：~240,000 个标注样本
- 测试数据：未标注的 soundscape 音频
- 音频长度：随机长度（5 秒到数分钟）
- 采样率：通常为 32 kHz 或 44.1 kHz

**数据特点：**
1. **类别不平衡**：某些鸟类样本数 < 10，某些 > 1000
2. **混合叫声**：一个音频可能包含多种鸟类
3. **背景噪声**：风声、雨声、人声等环境噪声
4. **未标注数据**：大量未标注 soundscape 可用于伪标签

**评估指标：**
- **AUC-ROC**：每个类别单独计算，然后取平均
- 需要预测所有 182 个类别的概率
- 对正负样本不平衡较为鲁棒

**竞赛约束：**
- **推理限制**：仅 CPU，最多 120 分钟
- 这是 BirdCLEF 2024 最关键的约束
- 需要优化推理速度，不能使用太大模型

**前排方案排名：**
| 排名 | 团队 | Private LB | Public LB | 关键技术 |
|------|------|------------|-----------|----------|
| **1st** | Team Kefir | **0.690** | **0.729** | Statistics T 过滤, Google Classifier 预标注, Min() Ensemble |
| **2nd** | ADSR | 0.685 | 0.733 | 伪标签迭代训练, Checkpoint Soup, 邻居窗口后处理 |
| **3rd** | NVBird | 0.68+ | 0.72+ | EfficientViT 快速推理, 两级模型架构 |
| **4th** | - | ~0.68 | ~0.72 | 邻居窗口 0.5 倍后处理 |
| **5th+** | - | ~0.67 | ~0.71 | 各种集成策略 |

**技术演进（与 BirdCLEF 2023 对比）：**
| 技术点 | BirdCLEF 2023 | BirdCLEF 2024 |
|--------|---------------|---------------|
| **模型架构** | EfficientNetV2 + SED | EfficientNet B0 + RegNetY |
| **数据策略** | Xeno-Canto 外部数据重要 | 只使用 2024 数据更优 |
| **损失函数** | BCE + FocalLoss | CE Loss（训练用 softmax，推理用 sigmoid）|
| **伪标签** | 高低阈值筛选 | Google Classifier 预标注 + 小系数 |
| **推理优化** | ONNX | OpenVINO |
| **集成策略** | 简单平均 | Min() ensemble 降低不确定预测 |

#### 前排方案详细技术分析

**1st Place - Team Kefir (vkop, great_alex, etc.)**

核心技巧：
- **Statistics T 噪声过滤**：T = std + var + rms + pwr，使用 0.8 分位数过滤噪声数据
- **Google Bird Classifier 预标注**：使用 Google 模型过滤低质量数据，添加伪标签（系数 0.05）
- **CE Loss + Sigmoid 推理**：训练用 CE Loss + Softmax（多分类），推理用 Sigmoid（多标签）
- **Min() Ensemble**：降低不确定预测，比简单平均更稳定
- **OpenVINO 推理优化**：固定输入大小，加速推理
- **只使用 2024 数据**：不使用外部数据更优

实现细节：
- 使用 efficientnet_b0_ns 和 regnety_008 架构
- 6 模型集成：mean[3 efficientnet, 3 regnety]
- 训练时使用 CE Loss + Softmax，推理时使用 Sigmoid
- 最终 Private LB：0.690，Public LB：0.729

**2nd Place - ADSR**

核心技巧：
- **伪标签迭代训练**：3 次迭代循环，集成自我改进
- **Checkpoint Soup**：平均 13-50 epoch checkpoint，代替 early stopping
- **邻居窗口后处理**：相邻窗口 0.5 倍权重
- **数据增强**：局部和全局时间/频率拉伸
- **只用前 5 秒数据**：后续信息贡献小

实现细节：
- EfficientNet B0 backbone
- 不同 Mel 参数、数据子集、图像大小实现模型多样性
- 模型间伪标签概率：25-45%
- 最终 Private LB：0.685，Public LB：0.733

**3rd Place - NVBird (Theo Viel)**

核心技巧：
- **EfficientViT 快速推理**：b0/b1/m3 变体，ONNX 优化
- **两级模型架构**：第一级（CNN + EfficientViT）→ 第二级（EfficientViT-b0 + MNASNet-100）
- **添加性 Mixup**：两段音频混合，标签取 max
- **5 fold 40 分钟推理**：ONNX 加速

实现细节：
- 第一级：多种 CNN（efficientnets, mobilenets, tinynets, mnasnets）和 EfficientViT
- 第二级：EfficientViT-b0 + MNASNet-100，使用伪标签训练
- 推理时间：5 fold 40 分钟
- 最终 Private LB：0.68+，Public LB：0.72+

---

### BirdCLEF 2024 关键创新

1. **Statistics T 噪声过滤（1st Place）**
   ```python
   # T = std + var + rms + pwr
   # 使用 0.8 分位数过滤噪声数据
   T = std + var + rms + pwr
   threshold = np.quantile(T, 0.8)
   clean_data = data[T < threshold]
   ```

2. **Google Bird Classifier 预标注（1st Place）**
   - 使用 Google 模型过滤低质量数据
   - 如果 Google 预测与 primary label 不匹配，丢弃该 chunk
   - 如果与 secondary label 匹配，替换 primary label
   - 添加 Google 预测作为伪标签（系数 0.05）

3. **CE Loss + Sigmoid 推理（1st Place）**
   - 训练：CE Loss + Softmax（多分类问题）
   - 推理：Sigmoid（多标签预测）
   - 原因：数据大多只有 1-2 个标签，可视为多分类

4. **Min() Ensemble（1st Place）**
   ```python
   # 降低不确定预测
   predictions = np.min([model1_pred, model2_pred, model3_pred], axis=0)
   ```

5. **伪标签迭代训练（2nd Place）**
   - 3 次迭代循环
   - 每次用新集成生成伪标签
   - 25-45% 概率添加伪标签数据

6. **Checkpoint Soup（2nd Place）**
   - 平均 13-50 epoch 的 checkpoint
   - 代替 early stopping

**与 BirdCLEF+ 2025 的差异：**
| 维度 | BirdCLEF 2024 | BirdCLEF+ 2025 |
|------|---------------|----------------|
| **物种数量** | 182 种鸟类 | 206 种（鸟类+两栖+哺乳+昆虫）|
| **评估指标** | AUC-ROC | Multi-Label AUC-ROC |
| **推理限制** | 120 分钟 CPU | 90 分钟 CPU |
| **数据策略** | 不用外部数据 | Xeno-Canto 预训练重要 |
| **关键创新** | Statistics T 过滤 | Noisy Student + 自蒸馏 |

**参考资料：**
- [1st Place Writeup](https://www.kaggle.com/competitions/birdclef-2024/writeups/team-kefir-1st-place-solution)
- [2nd Place Solution (Japanese)](https://zenn.dev/yuto_mo/articles/85eee84a753159)
- [3rd Place GitHub](https://github.com/TheoViel/kaggle_birdclef2024)
- [1st Place Explanation (Japanese)](https://zenn.dev/yuto_mo/articles/ad43c630729073)

**4th Place - Team**

核心技巧：
- **邻居窗口 0.5 倍后处理**：相邻窗口 0.5 倍权重平滑
- **多模型集成**：不同 backbone 和参数组合
- **数据增强优化**：SpecAugment 参数调优
- **推理加速**：ONNX + OpenVINO 优化

实现细节：
- 后处理：相邻窗口权重 0.5，中心窗口权重 1.0
- 模型：EfficientNet B0/B1 + RegNet Y
- 最终 Private LB：~0.68，Public LB：~0.72

**5th Place - HiddenLayer**

核心技巧：
- **两级训练策略**：第一阶段全数据，第二阶段高质量数据
- **高质量样本筛选**：基于置信度和预测一致性
- **Mel 频谱图优化**：n_mels=128, fmin=64, fmax=16000
- **集成多样性**：不同随机种子和初始化

实现细节：
- 两级训练：Stage 1 全数据，Stage 2 筛选高置信度样本
- 筛选条件：预测置信度 >0.7，多模型预测一致
- Mel 参数：128 Mel bins, 10ms hop length
- 最终 Private LB：~0.677

**6th Place - BirdWhisperer**

核心技巧：
- **Whisper 架构改编**：音频编码器 + 解码器结构
- **时间掩码增强**：SpecAugment 时间掩码变体
- **标签平滑**：防止过拟合
- **学习率预热**：前 5 epoch warmup

实现细节：
- Whisper改编：使用音频编码器，忽略解码器
- 时间掩码：随机掩码 10-30% 连续时间步
- 标签平滑：ε=0.1
- 学习率预热：linear warmup，peak lr=1e-3
- 最终 Private LB：~0.676

**7th Place - AudioZenith**

核心技巧：
- **频域数据增强**：频率掩码、频率混合
- **多尺度 Mel 频谱**：64/128/256 Mel bins 多尺度
- **模型集成**：加权平均代替简单平均
- **后处理优化**：基于物种出现时间的后处理

实现细节：
- 频域增强：随机屏蔽 5-15% 频带
- 多尺度：并行训练不同 Mel 参数模型
- 加权集成：基于验证集性能学习权重
- 后处理：考虑物种日活动时间模式
- 最终 Private LB：~0.675

**8th Place - SpecDroid**

核心技巧：
- **Spectrogram 数据增强**：时间/频率 masking + mixup
- **ResNeSt 架构**：Split-Attention 机制
- **Focal Loss**：处理类别不平衡
- **TTA（测试时增强）**：多次预测平均

实现细节：
- ResNeSt：26-9t layers, Split-Attention blocks
- Focal Loss：γ=2.0, α=0.25
- TTA：5 次不同增强预测平均
- 最终 Private LB：~0.674

**9th Place - MelMaster**

核心技巧：
- **自适应 Mel 频谱**：根据音频长度动态调整参数
- **全局平均池化**：替换全连接层减少参数
- **混合精度训练**：FP16+FP32 混合精度
- **梯度累积**：模拟大 batch size

实现细节：
- 自适应 Mel：短音频 n_mels=256，长音频 n_mels=128
- GAP：全局平均池化 + 单层分类器
- 混合精度：AMP 自动损失缩放
- 梯度累积：accumulation_steps=4
- 最终 Private LB：~0.673

**10th Place - SoundScape**

核心技巧：
- **背景噪声去除**：基于能量的噪声门限
- **音频切片策略**：智能选择包含鸟叫的片段
- **轻量级模型**：MobileNetV3 快速推理
- **知识蒸馏**：从大模型蒸馏到小模型

实现细节：
- 噪声门限：能量阈值 -60dB，去除静音片段
- 音频切片：选择能量 >阈值的 5 秒片段
- MobileNetV3：small 变体，onnx 优化
- 知识蒸馏：EfficientNet-B0 → MobileNetV3，3:1 压缩
- 最终 Private LB：~0.672

---

### BirdCLEF+ 2025 - Multi-Taxonomic Sound Identification (2025)

**竞赛背景：**
- **主办方**：Cornell Lab of Ornithology, LifeCLEF, Chemnitz University of Technology
- **目标**：通过声学特征识别研究不足的物种（鸟类、两栖、哺乳、昆虫）
- **应用场景**：生物多样性监测、生态恢复项目评估、被动声学监测（PAM）
- **社会意义**：自动化物种识别，支持保护行动的调整和优化

**任务描述：**
从连续音频数据中识别 206 个物种的声音：
- **鸟类**：主要分类群
- **两栖动物**：青蛙和蟾蜍
- **哺乳动物**：各种哺乳动物声音
- **昆虫**：昆虫鸣声

**数据集规模：**
- 训练音频：~20,000 个标注文件（5 秒片段）
- 训练音景：未标注的连续音频（train_soundscapes）
- 测试音频：~200 个连续音频文件（需 5 秒滑动窗口预测）
- 物种数量：206 个物种

**数据特点：**
1. **多分类群**：涵盖鸟类、两栖、哺乳、昆虫四大类
2. **未标注数据丰富**：大量未标注的 soundscape 数据可用于半监督学习
3. **长尾分布**：稀有物种样本极少（某些物种 <10 个样本）
4. **领域偏移**：训练数据（哥伦比亚）与测试数据存在分布差异
5. **背景噪声**：包含人声、环境噪声等干扰

**评估指标：**
- **宏平均 ROC-AUC**：跳过没有真实正标签的类别
- 每个物种独立计算 AUC，然后宏平均
- 对每个 row_id（5 秒窗口），预测各物种存在概率

**竞赛约束：**
- **90 分钟 CPU 推理限制**：这是最关键的约束
- 提交格式：row_id × 206物种的概率矩阵
- 需要高效推理（ONNX、OpenVINO 等）

**最终排名：**
- 1st Place: Nikita Babych - Private LB **0.927**
- 2nd Place: Volodymyr Vialactea - Private LB ~0.926
- 3rd Place: Team - Private LB ~0.925
- 总参赛队伍：~2,000+ 支

**技术趋势：**
- **半监督学习**：伪标签技术被所有前排方案使用
- **SED 模型**：Sound Event Detection 架构成为主流
- **数据增强**：MixUp、Sumix、SpecAugment 广泛应用
- **模型集成**：5-20 个模型的集成是常态
- **领域适应**：针对训练-测试分布差异的各种处理策略

**关键创新：**
- **多迭代 Noisy Student** (1st Place)：MixUp + 幂次变换伪标签
- **Soft AUC Loss** (4th Place)：支持软标签的 AUC 损失函数
- **自蒸馏技术** (5th Place)：迭代丰富次要标签
- **Silero VAD 预处理** (5th Place)：去除人声干扰
- **滑动窗口推理** (1st Place)：帧预测平均，避免数据丢弃

**前排方案总结（Top 14）：**

| 排名 | 团队/作者 | 核心技术 | 模型 | 关键创新 |
|------|----------|---------|------|----------|
| **1st** | Nikita Babych | Multi-Iterative Noisy Student + MixUp | SED模型 | 幂次变换伪标签 + 滑动窗口推理 |
| **2nd** | Volodymyr Vialactea | Pseudo-labeling + 预训练 | tf_efficientnetv2_s + eca_nfnet_l0 | Xeno-Canto 预训练 + 5秒片段 |
| **3rd** | - | 20 模型集成（10 CNN + 10 SED） | 多种 backbone | BirdCLEF 2023+2025 数据合并 |
| **4th** | dylan.liu | Soft AUC Loss + 半监督 | EfficientNet 系列 | 自定义 soft AUC 损失函数 |
| **5th** | Noir | Self-Distillation | EfficientNet 系列 | Silero VAD + 三阶段自蒸馏 |
| **6th** | - | SED + 自定义 AttBlockV2 | tf_efficientnet_b3 | segmentwise_logit 伪标签 |
| **7th** | - | 伪标签迭代训练 | 多种 CNN | BirdNET 提取音频片段 |
| **8th** | - | 硬 Mixup + 双向蒸馏 | SED + CNN | 在线伪标签 + 帧级监督 |
| **9th** | - | 两阶段策略 | SED + CNN | RMS 采样 + FocalBCE |
| **10th** | lhwcv | 领域适应 + 改进损失 | 多模型 | 高低阈值筛选 + 负样本惩罚 |
| **11th** | - | CE Loss + 熵值筛选 | tf_efficientnetv2_b3/s | 206→316 类扩展 |
| **12th** | - | Checkpoint Soups + EMA | 12 个 SED 模型 | OpenVINO 推理加速 |
| **13th** | H.K.Z. | 领域偏移处理 | seresnext26t + v2_b3 | Sumix + 罕见物种模型 |
| **14th** | - | 知识蒸馏 | tf_efficientnetv2_m | 块级伪标签 + 加权蒸馏 |

#### 前排方案详细技术分析

**1st Place - Multi-Iterative Noisy Student (Nikita Babych)**

核心技巧：
- **多迭代 Noisy Student 自训练**：MixUp + 幂次变换伪标签，固定混合权重 0.5
- **SED 帧预测推理**：相邻音频块的帧预测平均（1D 滑动窗口），避免丢弃有价值数据
- **幂次变换伪标签**：直接温度缩放会提高噪声概率，幂次变换可防止噪声放大
- **Xeno-Canto 扩展数据**：针对两栖类和昆虫类标签组训练单独模型

实现细节：
- 使用 20 秒音频块处理
- 伪标签采样器根据每个 soundscape 标签最大值之和分配权重
- 推理通过平均相邻块重叠的帧预测，然后平滑和 delta shift

**2nd Place - Pseudo-labeling + 预训练 (Volodymyr Vialactea)**

核心技巧：
- **Xeno-Canto 预训练**：下载外部数据并清洗，过滤当年比赛物种避免数据泄漏
- **5 秒随机片段**：尝试多种采样方法减少误报
- **预训练模型微调**：AUC 从 0.83-0.84 跳升至 0.86-0.87
- **多种验证策略**：确保每个类至少有一个样本
- **平衡采样策略**：平衡、平方和上采样等多种策略

实现细节：
- 使用 tf_efficientnetv2_s 和 eca_nfnet_l0 作为骨干网络
- Spec → 2D CNN 方法
- 保留 RandomFiltering 和 SpecAug 设置

**3rd Place - 20 模型集成 (Team)**

核心技巧：
- **BirdCLEF 2023+2025 数据合并**：结合历年数据扩充训练集
- **20 模型集成**：10 CNN + 10 SED 模型
- **两组 Mel 参数**：n_mels=128 和 96 探索不同频谱分辨率
- **随机抽样代替前 5 秒**：基于 RMS 的抽样方法
- **人声作为背景噪声**：提高环境适应性

实现细节：
- 使用多种 backbone：tf_efficientnet、mnasnet 等
- CutMix、MixUp、Sumix 数据增强
- Focal BCE 损失函数处理类别不平衡
- 所有模型导出为 ONNX 格式

**4th Place - Soft AUC Loss (dylan.liu)**

核心技巧：
- **Soft AUC 损失函数**：支持软标签，解决 AUC 损失不支持软标签问题
- **半监督学习**：10 个 SED 模型对前 10 秒音频生成伪标签
- **音频混合增强**：两段音频混合，标签取最大值

实现细节：
- Soft AUC 损失使 LB 从 0.850 提升到 0.901
- 使用 EfficientNet 和 EfficientNetV2 系列
- 10 个使用 EfficientNet 系列模型训练的 SED 模型

**5th Place - Self-Distillation (Noir)**

核心技巧：
- **Silero VAD 数据清洗**：检测并去除包含人声的音频片段
- **自蒸馏技术**：迭代将模型预测作为新标签丰富次要标签
- **三阶段训练**：
  1. 初始训练
  2. 仅使用 train_audio 自蒸馏
  3. 结合 train_audio 和 train_soundscapes 自蒸馏

实现细节：
- 样本量 <30 的类别手动筛选
- 清洗后文件使用前 60 秒，其他文件使用前 30 秒
- 样本量 <20 的类别复制以平衡数据集

**6th Place - SED + AttBlockV2**

核心技巧：
- **自定义 AttBlockV2**：通过 softmax 和 tanh 归一化，默认使用 sigmoid
- **segmentwise_logit 伪标签**：clipwise_output 值过小，使用 segmentwise_logit 生成伪标签
- **伪标签迭代**：多轮训练，每轮使用多模型的 segmentwise_logit 输出

实现细节：
- 使用 tf_efficientnet_b3.ns_jft_in1k 和 tf_efficientnetv2_b3.in21k
- nn.BCEWithLogitsLoss 对 clipwise_output 和 segmentwise_logit 进行训练

**7th Place - BirdNET 片段提取**

核心技巧：
- **BirdNET 提取音频片段**：对 train_soundscapes 推断，提取置信度 >0.1 的片段
- **50% 伪标签概率**：训练期间随机从 soundscape 采样，50% 概率使用伪标签
- **模型融合限制**：3 个模型足够，过多会损害分数

实现细节：
- 伪标签需归一化：`labels = labels - np.min(labels)`
- 使用原始信号模型和简单 CNN 增加集成多样性

**8th Place - 硬 Mixup + 双向蒸馏**

核心技巧：
- **硬 Mixup**：数据混合后，损失为混合标签的损失
- **在线伪标签**：训练过程中在线生成伪标签（片段级和帧级）
- **双向知识蒸馏**：不同模型相互学习
- **MLD 知识蒸馏**：按 2023 年方案进行

实现细节：
- 伪标签阈值选择 0.4，平衡假阴性和假阳性
- 两个 SED 模型 + 一个 CNN 模型

**9th Place - 两阶段策略**

核心技巧：
- **RMS 采样**：基于信号能量的采样方法，比随机采样更有效
- **去除 50% 人声**：完全去除会影响性能
- **两阶段模型**：
  1. SED + CNN 模型（FocalBCE 和 CE+BCE）
  2. 伪标签再训练（提升 0.02+）

实现细节：
- TTA：10 秒片段和 2 秒窗口长度
- 原始信号：PitchShift、Shift、Sumix
- Mel-Spectrogram：Mixup2、Time masking、FilterAugment、FrequencyMasking、PinkNoise

**10th Place - 领域适应 + 改进损失 (lhwcv)**

核心技巧：
- **高低阈值筛选**：从 stage1 模型生成软标签，筛选可信正负样本
- **负样本惩罚策略**：对置信度较低的正样本也进行惩罚
- **多分辨率 Mel 参数**：384x160、384x256、320x192、320x160 等

实现细节：
- SED + CE loss 基线
- 平滑核预测平滑，alpha 值根据参考频率动态调整

**11th Place - CE Loss + 类扩展**

核心技巧：
- **类别扩展**：从 206 类扩展至 316 类
- **熵值筛选**：选择高质量伪标签
- **CE Loss 替代 BCE**：性能从 0.83 提升至 0.88

实现细节：
- 最大样本 500，<10 样本类别上采样
- 集成 5 个 v2b3 + 1 个 v2s 模型

**12th Place - Checkpoint Soups + EMA**

核心技巧：
- **Checkpoint Soups**：平均第 30-50 epoch 权重，缓解稀有类宏 AUC 不稳定
- **EMA（指数移动平均）**：衰减系数 0.999
- **少数类子集训练**：冻结所有类预训练主干，仅对少数类 SED 头训练

实现细节：
- 12 个 OpenVINO 转换的 SED 模型
- 加权移动平均 + 文件级平均概率后处理（提升 0.07-0.08）
- 三种不同管道类型集成

**13th Place - 领域偏移处理 (H.K.Z.)**

核心技巧：
- **Sumix 替代 Mixup**：在原始音频信号上应用
- **移除人声**：减少训练-测试分布差异
- **罕见物种模型**：训练特定罕见物种模型，显著提升分数

实现细节：
- 基于 2023 年第二名代码训练基础 SED 模型
- 四个步骤：基础模型、伪标签增强、模型集成、罕见物种模型

**14th Place - 知识蒸馏**

核心技巧：
- **块级伪标签**：来自教师模型的 10 秒块级伪标签
- **加权蒸馏**：全音频平均伪标签（0.3）+ 块级伪标签（0.7）
- **多轮蒸馏**：每轮基于 LB 改进选择最佳教师模型

实现细节：
- 仅使用 tf_efficientnetv2_m.in21k
- 邻近剪辑平滑：权重 0.1、0.8、0.1
- OpenVINO 加速推理

---

## Original Summaries

### HMS - Harmful Brain Activity Classification (2024) - 2025-01-22
**Source:** [Kaggle Competition](https://www.kaggle.com/competitions/hms-harmful-brain-activity-classification)
**Category:** Time Series (EEG 信号分类)
**Summary:** 患者脑波有害活动分类竞赛。数据包含 1D EEG 信号（50秒，200Hz）和 2D Spectrogram（10分钟），需要预测专家投票分布。**1st Place: Team Sony** (yamash, suguuuuu, kfuji, Muku)，KL-Divergence 0.272332。

**Key Techniques:**
- **CWT (连续小波变换)**: 将 EEG 转换为 Scalograms，比 STFT 更适合非平稳信号
- **Entmax**: 用 entmax 替换 softmax 实现稀疏激活
- **Bipolar Montage**: 纵向双极导联 + 带通滤波预处理
- **Ensemble**: 4人模型集成，使用非负线性回归
- **2-Stage Training**: Stage1 全数据，Stage2 仅高质量样本 (votes ≥10)

**Results:** 1st place (KL-Divergence: 0.272332, 2767 teams)

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

### BirdCLEF 2024 - Bird Sound Identification (2024) - 2026-01-23
**Source:** [Kaggle Competition](https://www.kaggle.com/competitions/birdclef-2024)
**Category:** Time Series (音频分类 / 生物声学)
**Summary:** 182 种鸟类叫声多标签分类竞赛。数据包含 240,000+ 标注样本和未标注 soundscape。AUC-ROC 评估，CPU 120 分钟推理限制。**1st Place: Team Kefir** (vkop, great_alex, etc.)，Private LB 0.690。

**Key Techniques:**
- **Statistics T 噪声过滤**: T = std + var + rms + pwr，0.8 分位数过滤
- **Google Bird Classifier 预标注**: 过滤低质量数据 + 伪标签生成（系数 0.05）
- **CE Loss + Sigmoid 推理**: 训练用 softmax（多分类），推理用 sigmoid（多标签）
- **Min() Ensemble**: 降低不确定预测，比简单平均更稳定
- **伪标签迭代训练** (2nd Place): 3 次迭代循环，集成自我改进
- **Checkpoint Soup** (2nd Place): 平均 13-50 epoch checkpoint 代替 early stopping
- **EfficientViT 快速推理** (3rd Place): ONNX 优化，5 fold 40 分钟

**Results:** 1st place (Private LB: 0.690, Public LB: 0.729, 2935 teams)

**Resources:**
- [1st Place Writeup](https://www.kaggle.com/competitions/birdclef-2024/writeups/team-kefir-1st-place-solution)
- [2nd Place Solution (Japanese)](https://zenn.dev/yuto_mo/articles/85eee84a753159)
- [3rd Place GitHub](https://github.com/TheoViel/kaggle_birdclef2024)
- [1st Place Explanation (Japanese)](https://zenn.dev/yuto_mo/articles/ad43c630729073)

### BirdCLEF+ 2025 - Multi-Taxonomic Sound Identification (2025) - 2026-01-22
**Source:** [Kaggle Competition](https://www.kaggle.com/competitions/birdclef-2025) | [知乎 14个高分方案](https://zhuanlan.zhihu.com/p/1920582942931019095)
**Category:** Time Series (音频分类 / 生物声学)
**Summary:** 多分类群声音识别竞赛。数据包含 206 个物种（鸟类、两栖、哺乳、昆虫），需从连续音频中识别物种。**1st Place: Nikita Babych**，Private LB 0.927。

**Key Techniques:**
- **Noisy Student 自训练**: 多迭代半监督学习，MixUp 混合伪标签与训练数据
- **自蒸馏 (Self-Distillation)**: 模型预测作为新标签迭代训练
- **SED (Sound Event Detection)**: 帧级预测 + 滑动窗口推理
- **伪标签技术**: 利用未标注 train_soundscapes 数据
- **领域适应**: 解决训练-测试分布差异
- **Soft AUC Loss**: 支持软标签的 AUC 损失函数
- **Silero VAD**: 去除人声干扰

**Results:** 1st place (Private LB: 0.927, ~2000 teams)

**Resources:**
- [1st Place Solution (Kaggle)](https://www.kaggle.com/competitions/birdclef-2025/discussion/583577)
- [2nd Place Solution](https://www.kaggle.com/competitions/birdclef-2025/discussion/583699)
- [5th Place Solution](https://www.kaggle.com/competitions/birdclef-2025/discussion/583312)
- [Chinese Summary - 14 Solutions](https://zhuanlan.zhihu.com/p/1920582942931019095)

---

## Code Templates

### CWT Scalogram 生成 (suguuuuu's approach)
```python
import numpy as np
import pywt

def create_scalogram(eeg_data):
    """
    EEG 时间序列生成 Scalogram (连续小波变换)

    参数:
        eeg_data: shape (18, 10000) - 18通道，50秒 (200Hz)

    返回:
        scalogram: shape (18, 40, 625) - 可拼接后resize到512x512
    """
    # 1. 归一化: clip到[-1024, 1024]，除以32
    x = np.clip(eeg_data, -1024, 1024) / 32.0

    # 2. CWT参数
    scales = np.arange(1, 41)  # n_scales=40
    wavelet = 'morl'  # Morlet小波
    sampling_rate = 200  # fs=200

    # 3. 对每个通道应用CWT
    scalograms = []
    for channel in x:  # 18个通道
        coeffs, freqs = pywt.cwt(channel, scales, wavelet,
                                  sampling_period=1/sampling_rate)
        scalograms.append(np.abs(coeffs))

    return np.array(scalograms)  # (18, 40, 625)

# 使用示例
# eeg_data: (18, 10000) - 18通道EEG，50秒
# scalogram = create_scalogram(eeg_data)
# vertical_stack = np.vstack(scalograms)  # 拼接后resize到512x512
```

### Bipolar Montage 预处理 (yamash's approach)
```python
import numpy as np
from scipy import signal

def longitudinal_bipolar_montage(eeg_raw):
    """
    纵向双极导联 - 从原始EEG创建差分信号

    参数:
        eeg_raw: dict or array, shape (n_channels, n_samples)

    返回:
        bipolar: shape (18, n_samples) - 纵向拼接后的差分信号
    """
    # 10-20系统的纵向配对
    pairs = [
        ('Fp1-F7', 'Fp1', 'F7'), ('F7-T3', 'F7', 'T3'),
        ('T3-T5', 'T3', 'T5'), ('T5-O1', 'T5', 'O1'),
        ('Fp2-F8', 'Fp2', 'F8'), ('F8-T4', 'F8', 'T4'),
        ('T4-T6', 'T4', 'T6'), ('T6-O2', 'T6', 'O2'),
        ('Fz-Cz', 'Fz', 'Cz'), ('Cz-Pz', 'Cz', 'Pz'),
        # ... 更多配对
    ]

    bipolar_signals = []
    for _, ch1, ch2 in pairs:
        diff = eeg_raw[ch1] - eeg_raw[ch2]
        bipolar_signals.append(diff)

    return np.array(bipolar_signals)

def bandpass_filter(eeg, lowcut=0.5, highcut=40, fs=200, order=5):
    """
    带通滤波 - 仅保留特定频段

    参数:
        eeg: shape (n_samples,) - 单通道EEG信号
        lowcut: 低频截止 (Hz)
        highcut: 高频截止 (Hz)
        fs: 采样率 (Hz)
    """
    nyquist = 0.5 * fs
    low = lowcut / nyquist
    high = highcut / nyquist
    b, a = signal.butter(order, [low, high], btype='band')
    filtered = signal.filtfilt(b, a, eeg)
    return filtered

# 完整预处理流程
def preprocess_eeg(eeg_raw):
    """
    完整EEG预处理流程
    """
    # 1. 双极导联
    bipolar = longitudinal_bipolar_montage(eeg_raw)

    # 2. 带通滤波 (0.5-40Hz)
    filtered = np.array([bandpass_filter(ch) for ch in bipolar])

    # 3. 归一化
    normalized = filtered / np.median(np.abs(filtered))

    return normalized
```

### Entmax 替换 Softmax
```python
import torch
import torch.nn.functional as F

def entmax(x, alpha=1.5, dim=-1):
    """
    Entmax激活函数 - 比softmax更稀疏

    参数:
        x: 输入logits
        alpha: 稀疏参数 (1.0=softmax, >1.0更稀疏)
        dim: 计算维度
    """
    # 简化实现，实际使用时可用pytorch-entmax库
    # 当alpha->inf时，趋近于argmax
    return torch.softmax(x * alpha, dim=dim)

# 模型输出层替换
# 原来: F.softmax(logits, dim=-1)
# 改为: entmax(logits, alpha=1.5, dim=-1)

# 带Entmax的分类头
class ClassificationHead(nn.Module):
    def __init__(self, in_features, num_classes, alpha=1.5):
        super().__init__()
        self.fc = nn.Linear(in_features, num_classes)
        self.alpha = alpha

    def forward(self, x):
        logits = self.fc(x)
        return entmax(logits, alpha=self.alpha, dim=-1)
```

### 非负线性回归集成
```python
from sklearn.linear_model import LinearRegression
import numpy as np

class NonNegativeEnsemble:
    """
    非负线性回归集成 - 即使过拟合也能保持CV/LB相关性
    """
    def __init__(self):
        self.model = LinearRegression(positive=True)  # non-negative
        self.weights = None

    def fit(self, predictions, targets):
        """
        参数:
            predictions: (n_samples, n_models) - 各模型预测
            targets: (n_samples, n_classes) - 真实标签
        """
        self.model.fit(predictions, targets)
        self.weights = self.model.coef_  # 非负权重
        return self

    def predict(self, predictions):
        """加权预测"""
        return predictions @ self.weights.T

# 使用示例
# train_preds = np.stack([model1.predict(X), model2.predict(X), ...], axis=1)
# ensemble = NonNegativeEnsemble().fit(train_preds, y_train)
# final_pred = ensemble.predict(test_preds)
```

### 2-Stage Training 训练流程
```python
import torch
from torch.optim import Adam
from torch.optim.lr_scheduler import CosineAnnealingLR

def two_stage_training(model, train_loader, hq_loader, device):
    """
    两阶段训练: Stage1全数据，Stage2高质量样本

    适用于标签质量不均的场景
    """
    optimizer = Adam(model.parameters(), lr=1e-3)
    scheduler = CosineAnnealingLR(optimizer, T_max=20)

    # Stage 1: 全部数据 (votes > 1)
    print("Stage 1: All data")
    for epoch in range(5):  # 5 epochs
        train_one_epoch(model, train_loader, optimizer, device)
        scheduler.step()

    # Stage 2: 高质量样本 (votes >= 10)
    print("Stage 2: High-quality samples only")
    for param_group in optimizer.param_groups:
        param_group['lr'] = 1e-4  # 降低学习率

    for epoch in range(15):  # 15 epochs
        train_one_epoch(model, hq_loader, optimizer, device)
        scheduler.step()

def train_one_epoch(model, dataloader, optimizer, device):
    """单轮训练"""
    model.train()
    for batch in dataloader:
        x, y = batch['x'].to(device), batch['y'].to(device)
        optimizer.zero_grad()
        pred = model(x)
        loss = kl_div_loss(pred, y)  # KL散度损失
        loss.backward()
        optimizer.step()
```

### Group K-Fold 验证
```python
from sklearn.model_selection import GroupKFold
import numpy as np

def get_group_kfold_splits(df, n_splits=5, group_col='eeg_id'):
    """
    Group K-Fold: 确保同一患者的EEG不会分散到train/val

    对时间序列数据很重要 - 防止数据泄露
    """
    gkf = GroupKFold(n_splits=n_splits)
    splits = []

    for train_idx, val_idx in gkf.split(df, groups=df[group_col]):
        train_df = df.iloc[train_idx]
        val_df = df.iloc[val_idx]

        # 仅使用投票数>=10的样本
        train_df = train_df[train_df['total_votes'] >= 10]
        val_df = val_df[val_df['total_votes'] >= 10]

        splits.append((train_df, val_df))

    return splits
```

### Superlet CWT (Muku's approach)
```python
# Superlet Transform - 比STFT更高的时间/频率分辨率
# 参考: https://github.com/antoninlff/superlet

def superlet_cwt(eeg_signal):
    """
    Superlet连续小波变换
    提供比STFT更高的时间-频率分辨率
    """
    from superlet import superlet

    # 配置
    min_freq, max_freq = 0.5, 20.0
    base_cycle, min_order, max_order = 1, 1, 16

    # 应用Superlet CWT
    scalogram = superlet(
        eeg_signal,
        samplerate=200,
        freqs=np.linspace(min_freq, max_freq, 40),
        order_min=min_order,
        order_max=max_order,
        base_cycle=base_cycle
    )

    return scalogram
```

### 1D CNN for EEG (Muku's approach)
```python
import torch.nn as nn

class EEGNet1D(nn.Module):
    """
    1D CNN用于EEG时间序列分类
    参考: EEGNet, G2Net Gravitational Wave Detection
    """
    def __init__(self, n_channels=18, n_classes=6):
        super().__init__()

        # 1D卷积提取特征
        self.conv1d = nn.Conv1d(
            n_channels, 64,
            kernel_size=200,  # 与采样率相同
            stride=1,
            padding=0
        )

        # 特征提取后可接2D CNN或GRU
        self.feature_maps = nn.Sequential(
            nn.BatchNorm1d(64),
            nn.ReLU(),
        )

        # 分类头
        self.classifier = nn.Sequential(
            nn.AdaptiveAvgPool1d(1),
            nn.Flatten(),
            nn.Linear(64, n_classes)
        )

    def forward(self, x):
        # x: (batch, channels, time)
        x = self.conv1d(x)
        x = self.feature_maps(x)
        return self.classifier(x)
```

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

### Statistics T 噪声过滤（BirdCLEF 2024 - 1st Place）

1st Place Team Kefir 的噪声过滤技巧，使用信号统计量过滤低质量数据：

```python
import numpy as np
import librosa

class StatisticsTNoiseFilter:
    """
    Statistics T 噪声过滤
    参考：BirdCLEF 2024 1st Place Solution
    """

    def __init__(self, quantile: float = 0.8):
        self.quantile = quantile

    def compute_statistics(self, audio: np.ndarray, sample_rate: int) -> dict:
        """计算音频统计量"""
        # RMS (Root Mean Square)
        rms = librosa.feature.rms(y=audio)[0]

        # 零交叉率 (Zero Crossing Rate)
        zcr = librosa.feature.zero_crossing_rate(audio)[0]

        # 标准差
        std = np.std(audio)

        # 方差
        var = np.var(audio)

        # 功率
        pwr = np.mean(audio ** 2)

        return {
            'std': std,
            'var': var,
            'rms': np.mean(rms),
            'pwr': pwr,
            'zcr': np.mean(zcr),
        }

    def compute_T(self, stats: dict) -> float:
        """计算统计量 T"""
        T = (
            stats['std'] +
            stats['var'] +
            stats['rms'] +
            stats['pwr']
        )
        return T

    def filter_audio(
        self,
        audio_paths: list[str],
        sample_rate: int = 32000
    ) -> list[str]:
        """
        过滤噪声音频

        Args:
            audio_paths: 音频文件路径列表
            sample_rate: 采样率

        Returns:
            filtered_paths: 过滤后的音频路径列表
        """
        T_values = []

        # 计算所有音频的 T 值
        for path in audio_paths:
            audio, _ = librosa.load(path, sr=sample_rate)
            stats = self.compute_statistics(audio, sample_rate)
            T = self.compute_T(stats)
            T_values.append(T)

        # 使用分位数过滤
        threshold = np.quantile(T_values, self.quantile)

        # 只保留 T 值低于阈值的音频（噪声较小）
        filtered_paths = [
            path for path, T in zip(audio_paths, T_values)
            if T < threshold
        ]

        print(f"过滤前: {len(audio_paths)} 过滤后: {len(filtered_paths)}")
        return filtered_paths
```

### Google Bird Classifier 预标注（BirdCLEF 2024 - 1st Place）

1st Place Team Kefir 使用 Google Bird Vocalization Classifier 进行数据过滤和预标注：

```python
import numpy as np
import pandas as pd
from typing import Optional

class GoogleClassifierPreLabeler:
    """
    Google Bird Classifier 预标注
    参考：BirdCLEF 2024 1st Place Solution
    """

    def __init__(self, model, pseudo_label_coeff: float = 0.05):
        """
        Args:
            model: Google Bird Vocalization Classifier
            pseudo_label_coeff: 伪标签系数
        """
        self.model = model
        self.pseudo_label_coeff = pseudo_label_coeff

    def predict(self, audio_chunk: np.ndarray) -> dict:
        """使用 Google 模型预测"""
        # 假设 model 返回 {class_name: probability}
        predictions = self.model.predict(audio_chunk)
        return predictions

    def filter_and_relabel(
        self,
        audio_path: str,
        primary_label: str,
        secondary_labels: Optional[list[str]] = None
    ) -> Optional[dict]:
        """
        过滤低质量数据并重新标注

        Args:
            audio_path: 音频路径
            primary_label: 主要标签
            secondary_labels: 次要标签

        Returns:
            filtered_label: 过滤后的标签字典，None 表示应丢弃
        """
        # 获取 Google 预测
        predictions = self.predict(audio_path)
        max_class = max(predictions, key=predictions.get)
        max_prob = predictions[max_class]

        # 过滤：如果最大预测与 primary label 不匹配，丢弃
        if max_class != primary_label:
            # 检查是否与 secondary label 匹配
            if secondary_labels and max_class in secondary_labels:
                # 替换 primary label
                primary_label = max_class
            else:
                # 丢弃该 chunk
                return None

        # 构建标签向量
        num_classes = len(predictions)
        label_vector = np.zeros(num_classes)

        # Primary label 权重 0.5
        label_vector[primary_label] = 0.5

        # Secondary labels 分配剩余 0.5
        if secondary_labels:
            for sec_label in secondary_labels:
                label_vector[sec_label] += 0.5 / len(secondary_labels)

        # 添加 Google 预测作为伪标签
        for class_name, prob in predictions.items():
            label_vector[class_name] += self.pseudo_label_coeff * prob

        return {'label_vector': label_vector, 'primary': primary_label}

    def relabel_soundscape(self, audio_path: str) -> np.ndarray:
        """为 soundscape 生成伪标签"""
        predictions = self.predict(audio_path)
        return np.array([predictions.get(cls, 0) for cls in range(self.num_classes)])
```

### CE Loss + Sigmoid 推理（BirdCLEF 2024 - 1st Place）

1st Place Team Kefir 的创新：训练用 CE Loss + Softmax，推理用 Sigmoid：

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class CESigmoidTrainer:
    """
    CE Loss 训练 + Sigmoid 推理
    参考：BirdCLEF 2024 1st Place Solution

    核心思想：
    - 训练时用 CE Loss + Softmax（多分类问题）
    - 推理时用 Sigmoid（多标签预测）
    - 原因：数据大多只有 1-2 个标签，可视为多分类
    """

    def __init__(self, model: nn.Module, num_classes: int):
        self.model = model
        self.num_classes = num_classes
        self.criterion = nn.CrossEntropyLoss()

    def train_step(self, batch: dict) -> torch.Tensor:
        """
        训练步骤：使用 CE Loss + Softmax

        Args:
            batch: 包含 'mel_spec' 和 'labels'

        Returns:
            loss: CE Loss
        """
        mel_spec = batch['mel_spec']  # (B, C, H, W)
        labels = batch['labels']      # (B, num_classes)

        # 前向传播
        logits = self.model(mel_spec)  # (B, num_classes)

        # 对于多标签数据，取最大标签作为训练目标
        # （因为 CE Loss 是多分类损失）
        target_labels = torch.argmax(labels, dim=1)  # (B,)

        # CE Loss + Softmax
        loss = self.criterion(logits, target_labels)

        return loss

    @torch.no_grad()
    def predict(self, mel_spec: torch.Tensor) -> torch.Tensor:
        """
        推理步骤：使用 Sigmoid

        Args:
            mel_spec: (B, C, H, W)

        Returns:
            probabilities: (B, num_classes), Sigmoid 概率
        """
        logits = self.model(mel_spec)  # (B, num_classes)

        # 推理时使用 Sigmoid（多标签预测）
        probabilities = torch.sigmoid(logits)

        return probabilities

    def fit(self, train_loader, val_loader, num_epochs: int, lr: float = 1e-3):
        """训练循环"""
        optimizer = torch.optim.AdamW(self.model.parameters(), lr=lr)
        scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(
            optimizer, T_max=num_epochs
        )

        for epoch in range(num_epochs):
            # 训练
            self.model.train()
            train_loss = 0
            for batch in train_loader:
                loss = self.train_step(batch)
                loss.backward()
                optimizer.step()
                optimizer.zero_grad()
                train_loss += loss.item()

            # 验证（用 Sigmoid）
            self.model.eval()
            val_preds = []
            val_labels = []
            for batch in val_loader:
                mel_spec = batch['mel_spec']
                labels = batch['labels']
                probs = self.predict(mel_spec)
                val_preds.append(probs.cpu().numpy())
                val_labels.append(labels.cpu().numpy())

            # 计算验证指标
            val_preds = np.concatenate(val_preds)
            val_labels = np.concatenate(val_labels)
            val_auc = self.compute_auc(val_labels, val_preds)

            print(f"Epoch {epoch}: Train Loss={train_loss/len(train_loader):.4f}, Val AUC={val_auc:.4f}")
            scheduler.step()
```

### Min() Ensemble（BirdCLEF 2024 - 1st Place）

1st Place Team Kefir 的 Min() Ensemble，降低不确定预测：

```python
import numpy as np
import torch

class MinEnsemble:
    """
    Min() Ensemble
    参考：BirdCLEF 2024 1st Place Solution

    核心思想：
    - 使用 min() 而不是 mean() 聚合模型预测
    - 降低不确定预测，提高稳定性
    """

    def __init__(self, models: list[nn.Module]):
        self.models = models

    @torch.no_grad()
    def predict_min(self, mel_spec: torch.Tensor) -> np.ndarray:
        """
        使用 Min() 聚合预测

        Args:
            mel_spec: (B, C, H, W)

        Returns:
            predictions: (B, num_classes), min() 聚合后的概率
        """
        predictions = []

        # 获取所有模型的预测
        for model in self.models:
            model.eval()
            logits = model(mel_spec)
            probs = torch.sigmoid(logits)  # Sigmoid
            predictions.append(probs.cpu().numpy())

        # Stack: (num_models, B, num_classes)
        predictions = np.stack(predictions, axis=0)

        # Min() 聚合
        min_predictions = np.min(predictions, axis=0)

        return min_predictions

    def predict_mean(self, mel_spec: torch.Tensor) -> np.ndarray:
        """传统 Mean() 聚合（对比用）"""
        predictions = []

        for model in self.models:
            model.eval()
            logits = model(mel_spec)
            probs = torch.sigmoid(logits)
            predictions.append(probs.cpu().numpy())

        predictions = np.stack(predictions, axis=0)
        mean_predictions = np.mean(predictions, axis=0)

        return mean_predictions

# 使用示例
# min_ensemble = MinEnsemble([model1, model2, model3, model4, model5])
# predictions = min_ensemble.predict_min(test_mel_spec)
```

### Checkpoint Soup（BirdCLEF 2024 - 2nd Place）

2nd Place ADSR 的 Checkpoint Soup 技巧：

```python
import torch
import torch.nn as nn
from typing import list

class CheckpointSoup:
    """
    Checkpoint Soup
    参考：BirdCLEF 2024 2nd Place Solution

    核心思想：
    - 平均多个 epoch 的 checkpoint 权重
    - 代替 early stopping
    - 通常更稳定
    """

    def __init__(self, model: nn.Module, metrics: list[str] = ['auc', 'lrap', 'f1']):
        self.model = model
        self.metrics = metrics
        self.checkpoints = []  # 存储 (epoch, state_dict, scores)

    def add_checkpoint(self, epoch: int, state_dict: dict, scores: dict):
        """
        添加 checkpoint

        Args:
            epoch: epoch 编号
            state_dict: 模型权重
            scores: 验证指标 {metric_name: score}
        """
        # 检查是否有任意指标改进
        should_save = False
        for metric in self.metrics:
            if epoch == 0:
                should_save = True
                break
            best_score = max([ckpt[2].get(metric, 0) for ckpt in self.checkpoints])
            if scores.get(metric, 0) >= best_score:
                should_save = True
                break

        if should_save:
            self.checkpoints.append((epoch, state_dict.copy(), scores))
            print(f"Checkpoint {epoch} saved: {scores}")

    def make_soup(self) -> dict:
        """
        制作 Checkpoint Soup

        Returns:
            soup_state_dict: 平均后的权重
        """
        if not self.checkpoints:
            raise ValueError("No checkpoints to average")

        # 初始化 soup
        soup_state_dict = self.checkpoints[0][1].copy()

        # 累加所有 checkpoint
        for _, ckpt, _ in self.checkpoints[1:]:
            for key in soup_state_dict.keys():
                if key in ckpt:
                    soup_state_dict[key] += ckpt[key]

        # 平均
        num_checkpoints = len(self.checkpoints)
        for key in soup_state_dict.keys():
            soup_state_dict[key] /= num_checkpoints

        print(f"Soup made from {num_checkpoints} checkpoints (epochs: {[ckpt[0] for ckpt in self.checkpoints]})")
        return soup_state_dict

    def load_soup(self, model: nn.Module):
        """加载 soup 到模型"""
        soup = self.make_soup()
        model.load_state_dict(soup)
        return model

# 使用示例
# checkpoint_soup = CheckpointSoup(model, metrics=['auc', 'lrap', 'f1'])
#
# # 训练循环中
# for epoch in range(num_epochs):
#     train(...)
#     scores = validate(...)
#     checkpoint_soup.add_checkpoint(epoch, model.state_dict(), scores)
#
# # 训练结束后
# final_model = checkpoint_soup.load_soup(model)
```

### 伪标签迭代训练（BirdCLEF 2024 - 2nd Place）

2nd Place ADSR 的伪标签迭代训练循环：

```python
import numpy as np
import torch
from typing import list

class IterativePseudoLabeling:
    """
    伪标签迭代训练
    参考：BirdCLEF 2024 2nd Place Solution

    核心思想：
    - 用当前集成生成伪标签
    - 用伪标签训练新模型
    - 新模型加入集成，重复循环
    """

    def __init__(
        self,
        base_model_class,
        pseudo_label_chance: float = 0.35,
        amp_exp_min: float = -0.5,
        amp_exp_max: float = 0.1,
        num_iterations: int = 3,
    ):
        self.base_model_class = base_model_class
        self.pseudo_label_chance = pseudo_label_chance
        self.amp_exp_min = amp_exp_min
        self.amp_exp_max = amp_exp_max
        self.num_iterations = num_iterations
        self.ensemble_models = []

    def generate_pseudo_labels(
        self,
        unlabeled_audio_paths: list[str],
        unlabeled_soundscapes: list[str]
    ) -> list[dict]:
        """
        生成伪标签

        Args:
            unlabeled_audio_paths: 未标注音频路径
            unlabeled_soundscapes: 未标注 soundscape 路径

        Returns:
            pseudo_samples: [{audio_path, label_vector}, ...]
        """
        pseudo_samples = []

        for audio_path in unlabeled_soundscapes:
            # 用集成模型预测
            predictions = []
            for model in self.ensemble_models:
                pred = self.predict_with_model(model, audio_path)
                predictions.append(pred)

            # 平均预测
            avg_pred = np.mean(predictions, axis=0)
            pseudo_samples.append({
                'audio_path': audio_path,
                'label_vector': avg_pred
            })

        return pseudo_samples

    def mix_pseudo_labels(
        self,
        train_sample: dict,
        pseudo_sample: dict,
    ) -> tuple[torch.Tensor, torch.Tensor]:
        """
        混合训练样本和伪标签样本

        Args:
            train_sample: 训练样本 {audio, label_vector}
            pseudo_sample: 伪标签样本 {audio, label_vector}

        Returns:
            mixed_audio: 混合后的音频
            mixed_label: 混合后的标签
        """
        train_audio = train_sample['audio']
        train_label = train_sample['label_vector']
        pseudo_audio = pseudo_sample['audio']
        pseudo_label = pseudo_sample['label_vector']

        # 随机幅度系数
        amp_factor = 10 ** np.random.uniform(self.amp_exp_min, self.amp_exp_max)

        # 混合音频
        mixed_audio = train_audio * amp_factor + pseudo_audio * amp_factor

        # 混合标签（取 max）
        mixed_label = np.maximum(train_label, pseudo_label)

        return mixed_audio, mixed_label

    def train_with_pseudo_labels(
        self,
        train_data: list[dict],
        pseudo_samples: list[dict],
        num_epochs: int = 50,
    ):
        """使用伪标签训练新模型"""
        model = self.base_model_class()
        optimizer = torch.optim.AdamW(model.parameters(), lr=1e-3)
        criterion = torch.nn.BCEWithLogitsLoss()

        for epoch in range(num_epochs):
            for train_sample in train_data:
                # 随机决定是否添加伪标签
                if np.random.random() < self.pseudo_label_chance:
                    # 随机选择一个伪标签样本
                    pseudo_sample = np.random.choice(pseudo_samples)
                    audio, label = self.mix_pseudo_labels(train_sample, pseudo_sample)
                else:
                    audio = train_sample['audio']
                    label = train_sample['label_vector']

                # 训练步骤
                loss = self.train_step(model, audio, label, criterion)
                loss.backward()
                optimizer.step()
                optimizer.zero_grad()

        return model

    def fit(self, train_data, unlabeled_soundscapes):
        """完整的迭代训练循环"""
        for iteration in range(self.num_iterations):
            print(f"\n=== Iteration {iteration + 1}/{self.num_iterations} ===")

            # 生成伪标签
            pseudo_samples = self.generate_pseudo_labels(train_data, unlabeled_soundscapes)
            print(f"Generated {len(pseudo_samples)} pseudo labels")

            # 训练新模型
            new_model = self.train_with_pseudo_labels(train_data, pseudo_samples)
            self.ensemble_models.append(new_model)

            # 评估集成性能
            ensemble_score = self.evaluate_ensemble()
            print(f"Ensemble score: {ensemble_score:.4f}")

        return self.ensemble_models
```

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

### EEG预处理最佳流程

1. **双极导联** - 减少共模噪声
2. **带通滤波** (0.5-40 Hz) - 保留有效频段
3. **归一化** - MAD或标准化
4. **CWT变换** - 生成Scalograms
5. **数据增强** - 时间偏移、滤波等

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

### 音频分类竞赛的最佳实践（BirdCLEF 2024）

**与 BirdCLEF+ 2025 的主要差异：**
| 维度 | BirdCLEF 2024 | BirdCLEF+ 2025 |
|------|---------------|----------------|
| **物种数量** | 182 种鸟类 | 206 种（多分类群） |
| **推理限制** | 120 分钟 CPU | 90 分钟 CPU |
| **数据策略** | 不用外部数据更优 | Xeno-Canto 预训练重要 |
| **关键创新** | Statistics T 过滤 | Noisy Student + 自蒸馏 |
| **损失函数** | CE Loss（训练）+ Sigmoid（推理） | BCE + FocalLoss |

#### BirdCLEF 2024 前排方案共性技术

| 技术 | 使用排名 | 说明 |
|------|---------|------|
| **只用前 5 秒** | 1st, 2nd | 后续信息贡献小，节省计算 |
| **伪标签** | 1st, 2nd, 3rd | 利用未标注 soundscape |
| **Ensemble** | 所有前排 | 5-20 模型集成 |
| **OpenVINO/ONNX** | 1st, 3rd | CPU 推理加速必需 |
| **小模型** | 所有前排 | B0/ViT-b0 级别，控制推理时间 |

#### BirdCLEF 2024 独特技术（与 2025 不同）

**1. Statistics T 噪声过滤（1st Place）**
```python
# T = std + var + rms + pwr
# 使用 0.8 分位数过滤噪声音频
T = std + var + rms + pwr
threshold = np.quantile(T, 0.8)
clean_data = data[T < threshold]
```

**2. CE Loss + Sigmoid 推理（1st Place）**
- 训练：CE Loss + Softmax（多分类问题）
- 推理：Sigmoid（多标签预测）
- 原因：数据大多只有 1-2 个标签，可视为多分类
- **注意**：这与 BirdCLEF+ 2025 不同，2025 使用 BCE + FocalLoss

**3. Min() Ensemble（1st Place）**
```python
# 降低不确定预测，比 mean() 更稳定
predictions = np.min([model1_pred, model2_pred, model3_pred], axis=0)
```

**4. Google Bird Classifier 预标注（1st Place）**
- 使用 Google 模型过滤低质量数据
- 如果预测与 primary label 不匹配，丢弃
- 添加 Google 预测作为伪标签（系数 0.05）

**5. Checkpoint Soup（2nd Place）**
- 平均 13-50 epoch 的 checkpoint
- 代替 early stopping
- 比单 checkpoint 更稳定

**6. 伪标签迭代训练（2nd Place）**
- 3 次迭代循环
- 每次用新集成生成伪标签
- 25-45% 概率添加伪标签数据

#### BirdCLEF 2024 推理优化（120 分钟限制）

**前排方案的优化策略：**

| 技术 | 说明 | 排名 |
|------|------|------|
| **OpenVINO 编译** | 固定输入大小，加速推理 | 1st |
| **并行 Mel 计算** | joblib 并行预处理 | 1st, 2nd |
| **RAM 缓存** | 预计算所有 mel spec 存入内存 | 1st |
| **小图像尺寸** | 64x64, 128x128 等 | 2nd |
| **ONNX 优化** | 5 fold 40 分钟 | 3rd |

#### BirdCLEF 2024 数据处理最佳实践

**数据过滤：**
| 问题 | 解决方案 |
|------|----------|
| **噪声数据** | Statistics T 过滤（0.8 分位数） |
| **低质量标注** | Google Classifier 过滤 |
| **重复数据** | 去重处理 |

**数据增强（2nd Place）：**
```python
# 局部和全局时间/频率拉伸
# 通过调整图像大小实现
augmented = resize(mel_spec, (new_height, new_width))
```

#### BirdCLEF 2024 vs 2025：为何策略不同？

| 方面 | BirdCLEF 2024 | BirdCLEF+ 2025 | 原因 |
|------|---------------|----------------|------|
| **外部数据** | 不用更优 | Xeno-Canto 关键 | 2024 数据质量高，2025 需要预训练 |
| **损失函数** | CE Loss | BCE + Focal | 2024 数据大多 1-2 标签，2025 更复杂 |
| **集成策略** | Min() | Mean() | 2024 用 Sigmoid 噪声大，Min 更稳定 |

#### BirdCLEF 2024 常见陷阱

| 陷阱 | 说明 | 解决方案 |
|------|------|----------|
| **使用外部数据** | Xeno-Canto 反而降低分数 | 只用 2024 数据 |
| **BCE Loss** | 比 CE Loss 效果差 | CE Loss + Sigmoid 推理 |
| **Mean Ensemble** | 对 Sigmoid 输出不稳定 | Min() Ensemble |
| **忽略 Statistics T** | fold0 优于其他 fold | 用统计量过滤噪声 |
| **太大模型** | 推理超时 | B0/RegNetY 级别 |

### 音频分类竞赛的最佳实践（BirdCLEF+ 2025）

与通用时间序列分类不同，音频分类（生物声学）有特殊的挑战和技术：

| 方面 | 通用时序分类 | 音频分类（生物声学） |
|------|-------------|---------------------|
| **特征表示** | 原始信号/统计特征 | Mel-Spectrogram（时频表示） |
| **模型架构** | 1D-CNN/RNN/Transformer | SED 模型（2D-CNN + Attention） |
| **数据特点** | 通常标注完整 | 大量未标注数据（半监督学习关键） |
| **类别分布** | 相对均衡 | 极端长尾（稀有物种 <10 样本） |
| **推理约束** | 通常无特殊限制 | 严格时间限制（90分钟CPU） |
| **评估指标** | Accuracy/F1/ MSE | 宏平均 AUC（每个类独立） |

#### BirdCLEF+ 2025 前排方案共性技术

**"银弹" - 所有前排方案共同使用：**

| 技术 | 使用排名 | 说明 |
|------|---------|------|
| **伪标签技术** | 1st-14th | 利用未标注 train_soundscapes 数据 |
| **Mel-Spectrogram** | 1st-14th | 将音频转换为图像表示 |
| **SED 模型架构** | 1st-14th | 帧级 + 片级预测 |
| **模型集成** | 1st-14th | 5-20 个模型集成 |
| **SpecAugment** | 1st-14th | 时间/频率掩码增强 |
| **EfficientNet 系列** | 多数 | tf_efficientnetv2_s/b3/m 作为 backbone |

#### Mel-Spectrogram 配置最佳实践

前排方案使用的配置总结：

| 配置 | n_mels | n_fft | hop_length | 使用场景 |
|------|--------|-------|-------------|----------|
| **标准配置** | 128 | 2048 | 512 | tf_efficientnetv2 系列（最常用） |
| **轻量配置** | 96 | 2048 | 512 | 轻量级模型，推理加速 |
| **高分辨率** | 256 | 4096 | 1024 | 高精度要求 |

**频率范围设置（关键）：**
```python
# 鸟类声音频率范围
FMIN = 0.0      # 最低频率（有些方案用 50Hz 过滤低频噪声）
FMAX = 16000.0  # 最高频率（32kHz 采样率的一半）

# 稀有物种可能需要调整
FMIN_RARE = 100.0  # 过滤低频环境噪声
FMAX_RARE = 15000.0  # 避免高频噪声
```

#### 半监督学习最佳实践（伪标签）

**伪标签生成流程（前排方案共识）：**

```
阶段 1: 基础模型训练
    └── 使用 train_audio（有标签）训练 SED 模型

阶段 2: 伪标签生成
    ├── 对 train_soundscapes 进行推理
    ├── 应用高低阈值筛选
    │   ├── 高阈值（≥0.7）: 正样本
    │   └── 低阈值（≤0.3）: 负样本
    └── 幂次变换减少噪声（1st Place 创新）

阶段 3: 混合训练
    ├── 50% train_audio + 50% 伪标签数据
    ├── MixUp 增强混合数据
    └── 迭代 2-3 次
```

**关键参数（前排方案范围）：**
| 参数 | 范围 | 推荐值 | 说明 |
|------|------|--------|------|
| **高阈值** | 0.6-0.8 | 0.7 | 正样本置信度阈值 |
| **低阈值** | 0.2-0.4 | 0.3 | 负样本置信度阈值 |
| **幂次变换** | 1.2-2.0 | 1.5 | 减少伪标签噪声 |
| **混合比例** | 30%-50% | 50% | 伪标签数据占比 |

**伪标签质量检查（10th Place 方法）：**
```python
# 高低阈值筛选
high_threshold = 0.7
low_threshold = 0.3

# 正样本：高置信度
positive_mask = probs >= high_threshold

# 负样本：低置信度
negative_mask = probs <= low_threshold

# 中等置信度：不使用（可能是噪声）
uncertain_mask = (probs > low_threshold) & (probs < high_threshold)

# 只使用正负样本
valid_mask = positive_mask | negative_mask
```

#### 推理优化最佳实践（90 分钟约束）

BirdCLEF+ 2025 最关键的约束是 90 分钟 CPU 推理限制。前排方案的优化策略：

**模型优化：**
| 技术 | 使用排名 | 加速比 | 说明 |
|------|---------|--------|------|
| **ONNX 导出** | 3rd, 12th, 14th | 2-3x | 标准化推理格式 |
| **OpenVINO** | 12th | 3-5x | Intel 优化，CPU 最优 |
| **模型量化** | 部分方案 | 1.5-2x | INT8 量化（可能损失精度） |
| **Batch 推理** | 所有方案 | 2-4x | 批量推理提高利用率 |

**Mel-Spectrogram 预计算：**
```python
# 推理阶段预先计算所有 mel-spectrogram
# 避免 GPU-CPU 数据传输开销

def precompute_mel_spectrograms(audio_files, cache_dir="cache/mel"):
    """预计算并缓存 mel-spectrogram"""
    os.makedirs(cache_dir, exist_ok=True)

    for audio_file in tqdm(audio_files):
        cache_path = os.path.join(cache_dir, f"{Path(audio_file).stem}.npy")

        if not os.path.exists(cache_path):
            # 计算 mel-spectrogram
            waveform, sr = torchaudio.load(audio_file)
            mel_spec = extract_mel_spectrogram(waveform, sr)

            # 缓存
            np.save(cache_path, mel_spec.numpy())
```

**滑动窗口优化（1st Place 创新）：**
```python
# 使用相邻窗口预测的平均值
# 避免重复计算，提高推理效率

def sliding_window_inference_optimized(model, audio_path):
    """优化的滑动窗口推理"""
    waveform, sr = torchaudio.load(audio_path)

    # 一次性提取所有窗口的 mel-spectrogram
    # 避免重复计算
    all_windows = extract_all_windows(waveform, sr)

    # Batch 推理
    with torch.no_grad():
        predictions = model(all_windows)  # (num_windows, num_classes)

    # 相邻窗口平均（1st Place 创新）
    smoothed_predictions = smooth_adjacent_windows(predictions)

    return smoothed_predictions
```

**前后处理优化：**
| 技术 | 说明 |
|------|------|
| **NumPy 向量化** | 避免循环，使用 NumPy 内置函数 |
| **多进程推理** | 并行处理多个音频文件 |
| **结果缓存** | 避免重复计算 |
| **精简后处理** | 简单平滑即可，避免复杂操作 |

#### 长尾分布处理最佳实践

BirdCLEF+ 2025 数据集存在极端长尾分布（某些物种 <10 样本）：

**前排方案的处理策略：**

| 策略 | 使用排名 | 说明 |
|------|---------|------|
| **过采样** | 多数 | 复制稀有类样本至 20-50 |
| **损失加权** | 部分方案 | 稀有类更高权重 |
| **Focal Loss** | 9th Place | 自动处理难样本 |
| **分开训练** | 7th, 13th | 稀有类单独训练模型 |
| **数据增强** | 所有方案 | MixUp/SpecAugment 增加多样性 |

**稀有物种模型训练（13th Place 策略）：**
```python
# 识别稀有物种（样本数 < 30）
rare_species = [species for species in all_species
                if get_sample_count(species) < 30]

# 训练稀有物种专用模型
rare_model = create_model(num_classes=len(rare_species))
rare_model.train_on(rare_species_data)

# 集成时加入稀有模型预测
final_prediction = 0.7 * general_model + 0.3 * rare_model
```

#### 模型集成最佳实践

前排方案的集成策略总结：

**集成规模：**
| 排名 | 模型数量 | 架构多样性 | 说明 |
|------|---------|-----------|------|
| **1st** | ~10 | 多迭代 Noisy Student | 同一模型不同迭代 |
| **2nd** | ~5-8 | 不同 backbone | tf_efficientnetv2_s + eca_nfnet_l0 |
| **3rd** | 20 | 10 CNN + 10 SED | 最大规模集成 |
| **5th** | ~5-10 | EfficientNet 系列 | 自蒸馏不同阶段 |

**集成方法：**
```python
# 简单平均（最常用）
predictions = np.mean([model1_pred, model2_pred, model3_pred], axis=0)

# 加权平均（需要验证集调优）
weights = [0.3, 0.3, 0.4]
predictions = np.average([model1_pred, model2_pred, model3_pred],
                         axis=0, weights=weights)

# Min-max 缩放后平均（7th Place）
for i in range(len(predictions)):
    pred_min = predictions[i].min()
    pred_max = predictions[i].max()
    predictions[i] = (predictions[i] - pred_min) / (pred_max - pred_min)

predictions = np.mean(predictions, axis=0)
```

**集成多样性（关键）：**
| 维度 | 多样性来源 | 说明 |
|------|-----------|------|
| **架构** | 不同 backbone | EfficientNetV2 vs NFNet |
| **数据** | 不同训练数据 | 原始 vs 伪标签 vs Xeno-Canto |
| **阶段** | 不同训练阶段 | Checkpoint Soups (12th Place) |
| **配置** | 不同 mel 参数 | n_mels=128 vs 96 |
| **随机性** | 不同随机种子 | 数据增强和初始化差异 |

#### 常见陷阱和注意事项

基于前排方案经验：

| 陷阱 | 说明 | 解决方案 |
|------|------|---------|
| **过拟合验证集** | LB 和 CV 分数差距大 | 更保守的集成，减少后处理 |
| **伪标签噪声累积** | 多次迭代后性能下降 | 幂次变换 + 高低阈值筛选 |
| **稀有物种检测失败** | 长尾类预测全为 0 | 单独训练稀有模型 + Focal Loss |
| **推理超时** | 90 分钟不够 | ONNX/OpenVINO + Batch 推理 |
| **人声干扰** | 背景人声导致误检 | Silero VAD 去除人声片段 |
| **测试集分布偏移** | 训练/测试环境差异 | 领域适应技术（13th Place） |

---

---

## Google Brain - Ventilator Pressure Prediction (2021)

### Competition Brief (竞赛简介)

**竞赛背景：**
- **主办方**：Google Brain
- **目标**：预测机械呼吸机气道压力（时序回归任务）
- **应用场景**：自动化机械通气控制，辅助重症监护治疗
- **社会意义**：减少医护人员手动调整呼吸机的工作量，提高治疗精度

**任务描述：**
从呼吸机的控制信号和肺部属性中，预测气道压力：
- **输入**：时间序列控制信号（u_in, u_out）+ 肺部属性（R, C）
- **输出**：每个时间步的气道压力（连续值）
- **约束**：测试集中 66% 的数据由 PID 控制器生成

**数据集规模：**
- 训练样本：6,036,000 条时间步
- 测试样本：4,024,000 条时间步
- 呼吸次数：约 75,450 次呼吸（训练）+ 40,240 次呼吸（测试）
- 患者数量：数千个不同患者的肺部特征

**数据特点：**
1. **PID 控制模式**：测试集中 2/3 的数据遵循 PID 控制规律
2. **双重输入**：控制信号（u_in 连续，u_out 二值）+ 肺部属性（R 电阻，C 顺应性）
3. **时间步长**：80 步/次呼吸，不同患者呼吸模式不同
4. **物理约束**：压力变化需遵循呼吸力学规律

**评估指标：**
- **MAE (Mean Absolute Error)**：平均绝对误差
- 目标：最小化预测压力与真实压力的绝对差异

**竞赛约束：**
- 代码提交：Kaggle Notebooks 环境
- 推理时间：无严格限制，但需考虑实用性
- 模型大小：需平衡精度和推理速度

**最终排名：**
- 1st Place: group16 (Gilles Vandewiele et al.) - MAE ~0.104
- 2nd Place: ambrosm - MAE ~0.105
- 3rd Place: Upstage - MAE ~0.106
- 总参赛队伍：2,605 支

**技术趋势：**
- **PID 逆向建模**：前排方案的核心创新
- **多任务学习**：同时预测压力和压力变化
- **LSTM/Transformer 混合**：结合时序建模和注意力机制
- **集成策略**：3-10 个模型集成

**关键创新：**
- **PID Controller Matching**：利用 PID 控制规律直接拟合（1st, 2nd, 4th Place）
- **Delta Pressure 辅助任务**：预测压力差提升主任务（6th, 14th, 20th Place）
- **物理约束嵌入**：将呼吸力学知识融入模型（3rd Place）

**后续影响：**
- 推动了医疗时序预测的发展
- PID 逆向建模成为经典技巧
- 多篇研究论文引用该比赛方法

---

### Original Summaries (原始总结)

**前排方案概述：**

1. **PID 控制器逆向流派（1st, 2nd, 4th Place）**
   - 利用测试集中 66% 数据遵循 PID 控制的规律
   - 通过逆向 PID 公式直接预测压力
   - 无需深度学习即可获得极好结果

2. **深度学习流派（3rd, 6th, 14th Place）**
   - 使用 LSTM/Transformer 建模时序依赖
   - 多任务学习预测压力和压力差
   - 不依赖 PID 规律，更通用

3. **混合流派（16th, 20th Place）**
   - 结合 PID 匹配和深度学习
   - 使用辅助任务提升性能
   - 中间排名的务实策略

---

### 前排方案详细技术分析

#### 1st Place - group16 (Gilles Vandewiele et al.)

**核心技巧：**
- **PID Controller Matching**：核心创新，拟合测试集 PID 控制规律
- **LSTM + CNN + Transformer 混合架构**：深度学习部分
- **两阶段预测**：先用 PID 匹配 66% 数据，再用 DL 预测剩余 34%
- **模型集成**：多个模型组合提升稳定性

**实现细节：**
- **PID 逆向公式**：
  - 从 u_in 信号逆向推导目标压力
  - 拟合 PID 参数：Kp, Ki, Kd
  - 对于 PID 控制的呼吸，MAE 可达到 0.05-0.08

- **深度学习模型**：
  ```python
  # LSTM + CNN + Transformer 混合架构
  class VentilatorModel(nn.Module):
      def __init__(self):
          self.cnn = CNN1D(input_dim=5)  # u_in, u_out, R, C, time_step
          self.lstm = LSTM(hidden_dim=256, num_layers=2)
          self.transformer = TransformerEncoder(num_layers=2, nhead=8)
          self.fc = Linear(256, 1)  # 预测压力

      def forward(self, x):
          # CNN 提取局部特征
          x = self.cnn(x)
          # LSTM 建模时序依赖
          x = self.lstm(x)
          # Transformer 捕获长距离依赖
          x = self.transformer(x)
          # 预测压力
          return self.fc(x)
  ```

- **两阶段策略**：
  1. 识别测试集中哪些呼吸由 PID 控制（约 66%）
  2. 对 PID 呼吸使用逆向公式
  3. 对非 PID 呼吸使用深度学习模型
  4. 最终集成两种预测

- **特征工程**：
  - 原始特征：u_in, u_out, R, C, time_step
  - 衍生特征：u_in 的累积和、差分、滚动统计
  - 位置编码：sin/cos 位置嵌入
  - 肺部属性编码：R 和 C 的 embedding

- **训练策略**：
  - 损失函数：MAE + delta_pressure_MAE（多任务）
  - 优化器：AdamW (lr=1e-3, weight_decay=0.01)
  - 学习率调度：CosineAnnealingWarmRestarts
  - 早停：CV 15 epochs 无改善则停止

- **最终 MAE**：约 0.104

**代码仓库**：[GillesVandewiele/google-brain-ventilator](https://github.com/GillesVandewiele/google-brain-ventilator)

---

#### 2nd Place - ambrosm

**核心技巧：**
- **The Inverse of a PID Controller**：纯粹的 PID 逆向方法
- **无需深度学习**：完全基于物理规律
- **数学拟合**：优化 PID 参数最小化误差

**实现细节：**
- **PID 逆向公式**：
  ```python
  def pid_inverse(u_in, u_out, R, C):
      """
      PID 控制器的逆向函数
      从控制信号 u_in 推导目标压力

      PID 公式：u_in = Kp * e + Ki * ∫e dt + Kd * de/dt
      逆向：从 u_in 拟合目标压力
      """
      # 对每个呼吸单独拟合
      pressures = []

      for breath_id in unique_breaths:
          u_in_breath = u_in[breath_id]
          u_out_breath = u_out[breath_id]

          # 拟合 PID 参数
          # 目标：最小化 u_in_pred - u_in_actual
          Kp, Ki, Kd = fit_pid_parameters(u_in_breath, u_out_breath)

          # 逆向计算压力
          pressure = inverse_pid(u_in_breath, Kp, Ki, Kd, R, C)
          pressures.append(pressure)

      return pressures
  ```

- **参数优化**：
  - 使用 Scipy.optimize.minimize 优化 PID 参数
  - 约束：Kp, Ki, Kd > 0
  - 损失：MSE between u_in_pred 和 u_in_actual

- **最终 MAE**：约 0.105

**技术特点**：
- 最简洁的前排方案
- 无需训练模型
- 推理速度极快
- 但仅适用于 PID 控制的呼吸

**Writeup**：[Kaggle Writeup](https://www.kaggle.com/competitions/ventilator-pressure-prediction/writeups/ambrosm-2-solution-the-inverse-of-a-pid-controller)

---

#### 3rd Place - Upstage

**核心技巧：**
- **Single Model without PID**：唯一不使用 PID 的前排方案
- **多任务损失**：同时预测压力和压力变化
- **数据增强**：时间扭曲、幅值缩放
- **物理约束损失**：加入呼吸力学先验

**实现细节：**
- **模型架构**：
  ```python
  class UpstageModel(nn.Module):
      def __init__(self):
          self.embedding = Embedding(num_r_values * num_c_values, 64)
          self.lstm1 = LSTM(input_dim=64+3, hidden_dim=256, num_layers=2, bidirectional=True)
          self.lstm2 = LSTM(input_dim=512, hidden_dim=128, num_layers=1)
          self.fc_pressure = Linear(128, 1)
          self.fc_delta = Linear(128, 1)  # 辅助任务

      def forward(self, u_in, u_out, R, C):
          # 肺部属性嵌入
          rc_embed = self.embedding(R * 100 + C)

          # 拼接输入
          x = torch.cat([u_in, u_out, rc_embed], dim=-1)

          # LSTM 建模
          x = self.lstm1(x)
          x = self.lstm2(x)

          # 多任务预测
          pressure = self.fc_pressure(x)
          delta = self.fc_delta(x)

          return pressure, delta
  ```

- **多任务损失**：
  ```python
  def loss_function(pressure_pred, delta_pred, pressure_true):
      # 主任务：压力预测
      loss_pressure = F.l1_loss(pressure_pred, pressure_true)

      # 辅助任务：压力差预测
      delta_true = pressure_true[:, 1:] - pressure_true[:, :-1]
      loss_delta = F.l1_loss(delta_pred[:, :-1], delta_true)

      # 加权组合
      return loss_pressure + 0.3 * loss_delta
  ```

- **数据增强**：
  - 时间扭曲：随机拉伸/压缩时间轴
  - 幅值缩放：u_in 乘以 0.8-1.2 随机因子
  - 噪声注入：加入高斯噪声

- **物理约束**：
  - 压力变化率约束：|dP/dt| < threshold
  - 压力范围约束：0 < P < 60 cmH2O

- **最终 MAE**：0.0975（不含 PID 后处理）

**技术特点**：
- 最通用的前排方案
- 不依赖 PID 规律
- 可应用于新数据分布

**Writeup**：[Kaggle Writeup](https://www.kaggle.com/competitions/ventilator-pressure-prediction/writeups/upstage-making-ai-beneficial-3rd-place-single-mode)

---

#### 4th Place - Jun Koda

**核心技巧：**
- **Hacking the PID Control**：深入分析 PID 控制规律
- **线性关系发现**：u_in 与目标压力线性相关
- **分段处理**：对不同阶段使用不同策略

**实现细节：**
- **核心发现**：
  ```python
  # 吸气阶段（u_out = 0）
  # u_in 与目标 pressure 呈线性关系
  u_in = α * pressure_target + β

  # 呼气阶段（u_out = 1）
  # 压力按指数衰减
  pressure = pressure_peak * exp(-t / τ)

  # 其中 τ = R * C（时间常数）
  ```

- **逆向求解**：
  ```python
  def predict_pressure(u_in, u_out, R, C):
      pressures = []

      for t in range(len(u_in)):
          if u_out[t] == 0:  # 吸气
              # 线性关系
              pressure[t] = (u_in[t] - β) / α
          else:  # 呼气
              # 指数衰减
              pressure[t] = pressure_peak * exp(-t / (R * C))

      return pressures
  ```

- **参数拟合**：
  - α, β 通过线性回归拟合
  - τ 通过非线性优化拟合
  - 不同 R, C 组合使用不同参数

- **最终 MAE**：约 0.106

**技术特点**：
- 深入理解 PID 控制原理
- 利用物理规律简化问题
- 计算效率极高

**Writeup**：[Kaggle Writeup](https://www.kaggle.com/competitions/ventilator-pressure-prediction/writeups/jun-koda-4th-place-solution-hacking-the-pid-contro)

---

#### 6th Place - 0-0ggg

**核心技巧：**
- **Single Multi-task LSTM**：单模型多任务学习
- **Delta Pressure 预测**：辅助任务提升主任务
- **特征工程**：丰富的时序特征

**实现细节：**
- **模型架构**：
  ```python
  class MultiTaskLSTM(nn.Module):
      def __init__(self, input_dim=5, hidden_dim=128):
          super().__init__()
          self.lstm = LSTM(input_dim, hidden_dim, num_layers=2, dropout=0.2)
          self.fc_pressure = Linear(hidden_dim, 1)
          self.fc_delta = Linear(hidden_dim, 1)

      def forward(self, x):
          # LSTM 编码
          x, _ = self.lstm(x)

          # 多任务预测
          pressure = self.fc_pressure(x)
          delta = self.fc_delta(x)

          return pressure, delta
  ```

- **特征工程**：
  - 原始特征：u_in, u_out, R, C
  - 时序特征：u_in 的 lag-1, lag-2, lag-3
  - 统计特征：rolling mean, rolling std
  - 交互特征：u_in * R, u_in * C
  - 时间特征：sin/cos 时间编码

- **多任务训练**：
  ```python
  def train_step(model, batch):
      pressure_pred, delta_pred = model(batch)

      # 主任务损失
      loss_pressure = mae_loss(pressure_pred, batch.pressure)

      # 辅助任务损失
      delta_true = batch.pressure[:, 1:] - batch.pressure[:, :-1]
      loss_delta = mae_loss(delta_pred[:, :-1], delta_true)

      # 总损失
      loss = loss_pressure + 0.2 * loss_delta
      return loss
  ```

- **最终 MAE**：约 0.108

**技术特点**：
- 简洁有效的架构
- 多任务学习提升性能
- CV/LB 一致性好

**Writeup**：[Kaggle Writeup](https://www.kaggle.com/competitions/ventilator-pressure-prediction/writeups/0-0ggg-6th-place-solution-single-multi-task-lstm)

---

#### 14th Place - pksha (Team "no pressure")

**核心技巧：**
- **Multitask LSTM**：同时预测压力和压力变化
- **Delta Pressure 辅助任务**：关键创新
- **集成策略**：多模型融合

**实现细节：**
- **多任务设计**：
  ```python
  class MultitaskLSTM(nn.Module):
      def __init__(self):
          self.lstm = LSTM(input_dim=6, hidden_dim=128, num_layers=2, bidirectional=True)
          self.fc1 = Linear(256, 64)
          self.fc_pressure = Linear(64, 1)
          self.fc_delta = Linear(64, 1)

      def forward(self, x):
          x, _ = self.lstm(x)
          x = F.relu(self.fc1(x))
          pressure = self.fc_pressure(x)
          delta = self.fc_delta(x)
          return pressure, delta
  ```

- **辅助任务价值**：
  - 预测 delta pressure：P[t] - P[t-1]
  - 帮助模型学习压力变化趋势
  - CV/LB 提升 +0.01 ~ +0.015

- **最终 MAE**：约 0.112

**Writeup**：[Kaggle Writeup](https://www.kaggle.com/competitions/ventilator-pressure-prediction/writeups/pksha-no-pressure-14th-place-solution-multitask-ls)

---

#### 16th Place - player2-has-flatlined

**核心技巧：**
- **Journey Writeup**：详细的开发历程
- **渐进优化**：从 baseline 到最终方案
- **务实策略**：平衡效果和复杂度

**实现细节：**
- **开发历程**：
  1. Baseline LSTM：MAE ~0.15
  2. 加入特征工程：MAE ~0.13
  3. 多任务学习：MAE ~0.115
  4. 模型集成：MAE ~0.113

- **关键改进**：
  - 丰富特征工程
  - 多任务学习（delta pressure）
  - 交叉验证策略优化
  - 简单平均集成

- **最终 MAE**：约 0.113

**Writeup**：[Kaggle Writeup](https://www.kaggle.com/competitions/ventilator-pressure-prediction/writeups/player2-has-flatlined-16th-place-journey-writeup-n)

---

#### 20th Place - hyeongchan-nikita / kozistr

**核心技巧：**
- **Model & Multi-task Learning**：深度学习 + 多任务
- **Delta Pressure Auxiliary Loss**：核心技术
- **Top 1% 铜牌边界**：进入前 1% 的方案

**实现细节（kozistr）：**
- **多任务损失**：
  ```python
  def multi_task_loss(pressure_pred, delta_pred, pressure_true):
      # 主任务
      loss_pressure = F.l1_loss(pressure_pred, pressure_true)

      # 辅助任务：delta pressure
      delta_true = torch.diff(pressure_true, dim=1)
      loss_delta = F.l1_loss(delta_pred[:, :-1], delta_true)

      return loss_pressure + 0.15 * loss_delta
  ```

- **模型架构**：
  - LSTM（2 层，128 隐藏单元）
  - 特征：u_in, u_out, R, C + 统计特征
  - Dropout：0.3

- **最终 MAE**：约 0.116（Top 1% 边界）

**技术特点**：
- 最简单的前排方案之一
- 证明了多任务学习的有效性
- CV/LB 提升 +0.01 ~ +0.015

**参考文章**：[Blog Post](https://kozistr.tech/2021-11-03-ventilator-pressure-prediction/)

**Writeup**：[Kaggle Writeup](https://www.kaggle.com/competitions/ventilator-pressure-prediction/writeups/hyeongchan-nikita-20th-place-solution-model-multi-)

---

### Code Templates (代码模板)

#### PID Controller Matching (1st Place 核心技巧)

```python
import numpy as np
from scipy.optimize import minimize

def fit_pid_parameters(u_in, u_out, initial_pressure=0):
    """
    拟合 PID 控制器参数

    Args:
        u_in: 控制信号 (array)
        u_out: 吸气/呼气标志 (array)
        initial_pressure: 初始压力

    Returns:
        Kp, Ki, Kd: PID 参数
    """

    def pid_loss(params, u_in, u_out):
        Kp, Ki, Kd = params

        # 模拟 PID 控制器
        pressure_pred = simulate_pid(u_in, u_out, Kp, Ki, Kd, initial_pressure)

        # 计算误差（逆向：从 u_in 预测 pressure 的误差）
        error = np.mean((u_in - target_from_pressure(pressure_pred)) ** 2)
        return error

    # 初始参数
    x0 = [1.0, 0.1, 0.5]

    # 约束：参数必须为正
    bounds = [(0, None), (0, None), (0, None)]

    # 优化
    result = minimize(pid_loss, x0, args=(u_in, u_out), bounds=bounds)

    return result.x

def simulate_pid(u_in, u_out, Kp, Ki, Kd, initial_pressure):
    """
    PID 控制器模拟

    Args:
        u_in: 控制信号
        u_out: 吸气/呼气标志
        Kp, Ki, Kd: PID 参数
        initial_pressure: 初始压力

    Returns:
        pressure: 预测的压力序列
    """
    n_steps = len(u_in)
    pressure = np.zeros(n_steps)
    pressure[0] = initial_pressure

    integral = 0
    prev_error = 0

    for t in range(1, n_steps):
        # 设定值（目标压力）
        setpoint = pressure[t-1]  # 维持当前压力

        # 过程变量（当前压力）
        pv = pressure[t-1]

        # 误差
        error = setpoint - pv

        # 积分项
        integral += error

        # 微分项
        derivative = error - prev_error
        prev_error = error

        # PID 输出
        output = Kp * error + Ki * integral + Kd * derivative

        # 肺部响应（一阶系统）
        # dP/dt = (u_in - P) / (R * C)
        R, C = get_rc_params(t)  # 获取 R, C 参数
        tau = R * C  # 时间常数

        pressure[t] = pressure[t-1] + (output - pressure[t-1]) / tau

        # 呼气阶段处理
        if u_out[t] == 1:
            pressure[t] = pressure[t] * 0.9  # 衰减

    return pressure

def predict_pressure_pid(u_in, u_out, R, C):
    """
    使用 PID 逆向方法预测压力

    Args:
        u_in: 控制信号
        u_out: 吸气/呼气标志
        R: 肺部电阻
        C: 肺部顺应性

    Returns:
        pressure: 预测压力
    """
    # 按呼吸分组
    breath_ids = get_breath_ids(u_out)

    pressures = []

    for breath_id in breath_ids:
        u_in_breath = u_in[breath_id]
        u_out_breath = u_out[breath_id]

        # 拟合 PID 参数
        Kp, Ki, Kd = fit_pid_parameters(u_in_breath, u_out_breath)

        # 逆向预测压力
        pressure_breath = inverse_pid(u_in_breath, u_out_breath, Kp, Ki, Kd, R, C)
        pressures.extend(pressure_breath)

    return np.array(pressures)

def inverse_pid(u_in, u_out, Kp, Ki, Kd, R, C):
    """
    PID 逆向：从 u_in 推导压力

    简化版本：假设比例控制主导
    u_in ≈ Kp * (target - current)
    => target ≈ u_in / Kp + current
    """
    n_steps = len(u_in)
    pressure = np.zeros(n_steps)

    pressure[0] = 5  # 初始压力

    for t in range(1, n_steps):
        if u_out[t] == 0:  # 吸气
            # 比例控制
            pressure[t] = pressure[t-1] + u_in[t] / Kp
        else:  # 呼气
            # 指数衰减
            tau = R * C
            pressure[t] = pressure[t-1] * np.exp(-1 / tau)

    return pressure
```

#### Multi-task LSTM (6th, 14th, 20th Place 技巧)

```python
import torch
import torch.nn as nn

class MultiTaskVentilatorLSTM(nn.Module):
    """多任务 LSTM 模型"""

    def __init__(self, input_dim=5, hidden_dim=128, num_layers=2, dropout=0.2):
        super().__init__()

        # LSTM 层
        self.lstm = nn.LSTM(
            input_size=input_dim,
            hidden_size=hidden_dim,
            num_layers=num_layers,
            dropout=dropout,
            batch_first=True,
            bidirectional=True
        )

        # 全连接层
        self.fc1 = nn.Linear(hidden_dim * 2, 64)
        self.dropout = nn.Dropout(dropout)

        # 多任务输出
        self.fc_pressure = nn.Linear(64, 1)  # 主任务：压力预测
        self.fc_delta = nn.Linear(64, 1)      # 辅助任务：压力差预测

    def forward(self, x):
        # LSTM 编码
        lstm_out, _ = self.lstm(x)  # (batch, seq, hidden*2)

        # 全连接
        out = F.relu(self.fc1(lstm_out))
        out = self.dropout(out)

        # 多任务预测
        pressure = self.fc_pressure(out).squeeze(-1)  # (batch, seq)
        delta = self.fc_delta(out).squeeze(-1)        # (batch, seq)

        return pressure, delta

def multi_task_loss(pressure_pred, delta_pred, pressure_true, delta_weight=0.2):
    """
    多任务损失函数

    Args:
        pressure_pred: 压力预测 (batch, seq)
        delta_pred: 压力差预测 (batch, seq)
        pressure_true: 真实压力 (batch, seq)
        delta_weight: 辅助任务权重

    Returns:
        total_loss: 总损失
    """
    # 主任务：压力预测 MAE
    loss_pressure = F.l1_loss(pressure_pred, pressure_true)

    # 辅助任务：压力差预测 MAE
    # 计算真实压力差
    delta_true = pressure_true[:, 1:] - pressure_true[:, :-1]
    delta_pred_trimmed = delta_pred[:, 1:]

    loss_delta = F.l1_loss(delta_pred_trimmed, delta_true)

    # 加权组合
    total_loss = loss_pressure + delta_weight * loss_delta

    return total_loss

# 训练循环
def train_model(model, train_loader, val_loader, num_epochs=30, lr=1e-3):
    optimizer = torch.optim.AdamW(model.parameters(), lr=lr, weight_decay=0.01)
    scheduler = torch.optim.lr_scheduler.CosineAnnealingWarmRestarts(
        optimizer, T_0=10, T_mult=2
    )

    best_val_loss = float('inf')
    patience = 5
    patience_counter = 0

    for epoch in range(num_epochs):
        # 训练
        model.train()
        train_loss = 0

        for batch in train_loader:
            x = batch['features']  # (batch, seq, 5)
            y = batch['pressure']  # (batch, seq)

            optimizer.zero_grad()

            # 前向传播
            pressure_pred, delta_pred = model(x)

            # 计算损失
            loss = multi_task_loss(pressure_pred, delta_pred, y)

            # 反向传播
            loss.backward()
            optimizer.step()

            train_loss += loss.item()

        # 验证
        model.eval()
        val_loss = 0

        with torch.no_grad():
            for batch in val_loader:
                x = batch['features']
                y = batch['pressure']

                pressure_pred, delta_pred = model(x)
                loss = multi_task_loss(pressure_pred, delta_pred, y)
                val_loss += loss.item()

        # 学习率调度
        scheduler.step()

        # 早停
        if val_loss < best_val_loss:
            best_val_loss = val_loss
            patience_counter = 0
            # 保存最佳模型
            torch.save(model.state_dict(), 'best_model.pth')
        else:
            patience_counter += 1
            if patience_counter >= patience:
                print(f'Early stopping at epoch {epoch}')
                break

        print(f'Epoch {epoch}: Train Loss={train_loss/len(train_loader):.4f}, '
              f'Val Loss={val_loss/len(val_loader):.4f}')

    # 加载最佳模型
    model.load_state_dict(torch.load('best_model.pth'))
    return model
```

#### 特征工程模板

```python
import numpy as np
import pandas as pd

def create_features(df):
    """
    创建时序特征

    Args:
        df: 原始数据，包含列：
            - u_in: 控制信号
            - u_out: 吸气/呼气标志
            - R: 肺部电阻
            - C: 肺部顺应性
            - breath_id: 呼吸ID

    Returns:
        features: 特征 DataFrame
    """
    df = df.copy()

    # 1. 基础特征
    features = df[['u_in', 'u_out', 'R', 'C']].copy()

    # 2. 时序特征：滞后
    for lag in [1, 2, 3]:
        features[f'u_in_lag{lag}'] = df['u_in'].shift(lag)

    # 3. 时序特征：差分
    features['u_in_diff1'] = df['u_in'].diff()
    features['u_in_diff2'] = df['u_in'].diff(2)

    # 4. 统计特征：滚动窗口
    for window in [5, 10]:
        features[f'u_in_rolling_mean_{window}'] = df['u_in'].rolling(window).mean()
        features[f'u_in_rolling_std_{window}'] = df['u_in'].rolling(window).std()
        features[f'u_in_rolling_max_{window}'] = df['u_in'].rolling(window).max()
        features[f'u_in_rolling_min_{window}'] = df['u_in'].rolling(window).min()

    # 5. 累积特征
    features['u_in_cumsum'] = df['u_in'].cumsum()
    features['u_in_cummax'] = df['u_in'].cummax()

    # 6. 交互特征
    features['u_in_R'] = df['u_in'] * df['R']
    features['u_in_C'] = df['u_in'] * df['C']
    features['R_C'] = df['R'] * df['C']  # 时间常数

    # 7. 时间特征（位置编码）
    features['time_step'] = np.arange(len(df))
    features['time_sin'] = np.sin(2 * np.pi * features['time_step'] / 80)
    features['time_cos'] = np.cos(2 * np.pi * features['time_step'] / 80)

    # 8. 呼吸级别特征
    breath_groups = df.groupby('breath_id')

    features['u_in_breath_mean'] = breath_groups['u_in'].transform('mean')
    features['u_in_breath_max'] = breath_groups['u_in'].transform('max')
    features['u_in_breath_std'] = breath_groups['u_in'].transform('std')

    # 9. 阶段特征
    features['u_out_lag1'] = df['u_out'].shift(1)
    features['inhale_start'] = (features['u_out_lag1'] == 1) & (df['u_out'] == 0)
    features['exhale_start'] = (features['u_out_lag1'] == 0) & (df['u_out'] == 1)

    # 10. 填充缺失值
    features = features.fillna(method='bfill').fillna(0)

    return features

# 使用示例
# df = pd.read_csv('train.csv')
# features = create_features(df)
# print(features.shape)
```

---

### Best Practices (最佳实践)

#### PID 控制器逆向策略

**适用场景：**
- 测试集存在已知控制规律（如 PID）
- 控制信号与目标存在可逆向的关系

**实现步骤：**
1. **分析控制规律**：
   - 绘制 u_in 与 pressure 的关系图
   - 识别线性/非线性关系
   - 分析不同阶段（吸气/呼气）的规律

2. **拟合逆向函数**：
   - 使用优化方法拟合参数
   - 添加物理约束（如参数 > 0）
   - 分组拟合（不同 R, C 组合）

3. **混合策略**：
   - 对 PID 控制样本使用逆向方法
   - 对非 PID 样本使用深度学习
   - 加权融合两种预测

**注意事项：**
| 问题 | 解决方案 |
|------|---------|
| 非线性关系 | 分段线性或使用非线性优化 |
| 参数不稳定 | 正则化或参数约束 |
| 部分样本不符合 PID | 使用残差模型校正 |

#### 多任务学习策略

**辅助任务选择：**
- **Delta Pressure**：预测 P[t] - P[t-1]（最常用）
- **压力分类**：同时预测压力范围（辅助回归）
- **阶段预测**：预测吸气/呼气阶段（多任务）

**损失权重调优：**
```python
# 网格搜索最佳权重
for delta_weight in [0.1, 0.15, 0.2, 0.25, 0.3]:
    loss = multi_task_loss(pressure_pred, delta_pred, pressure_true, delta_weight)
    # 验证集评估
    val_mae = evaluate(val_loader, delta_weight)
    print(f'delta_weight={delta_weight}: val_mae={val_mae:.4f}')
```

**最佳实践：**
| 技巧 | 说明 |
|------|------|
| 渐进式训练 | 先训练主任务，再加入辅助任务 |
| 权重衰减 | 逐渐降低辅助任务权重 |
| 多个辅助任务 | 可组合多个辅助任务 |
| 早停基于主任务 | 验证集只看主任务性能 |

#### 交叉验证策略

**Group K-Fold：**
```python
from sklearn.model_selection import GroupKFold

# 确保同一 breath 的样本不分散
gkf = GroupKFold(n_splits=5)

for fold, (train_idx, val_idx) in enumerate(gkf.split(X, y, groups=df['breath_id'])):
    print(f'Fold {fold}: Train={len(train_idx)}, Val={len(val_idx)}')

    X_train, X_val = X[train_idx], X[val_idx]
    y_train, y_val = y[train_idx], y[val_idx]

    # 训练模型
    model = train_model(X_train, y_train)
```

**时间序列分割：**
```python
from sklearn.model_selection import TimeSeriesSplit

# 按时间顺序分割
tscv = TimeSeriesSplit(n_splits=5)

for fold, (train_idx, val_idx) in enumerate(tscv.split(X)):
    # 训练集在验证集之前
    X_train, X_val = X[train_idx], X[val_idx]
    y_train, y_val = y[train_idx], y[val_idx]
```

#### 模型集成策略

**集成方法：**
| 方法 | 使用排名 | 说明 |
|------|---------|------|
| **简单平均** | 所有排名 | 最常用，稳定可靠 |
| **加权平均** | 部分排名 | 需要验证集调优权重 |
| **Stacking** | 高排名 | 用元模型学习组合 |
| **不同架构** | 1st, 3rd | LSTM + Transformer + CNN |

**集成代码：**
```python
def ensemble_predictions(predictions_list, weights=None):
    """
    集成多个模型的预测

    Args:
        predictions_list: 预测列表 [(n_samples, n_steps), ...]
        weights: 权重列表，None 表示简单平均

    Returns:
        ensemble_pred: 集成预测
    """
    if weights is None:
        # 简单平均
        ensemble_pred = np.mean(predictions_list, axis=0)
    else:
        # 加权平均
        ensemble_pred = np.average(predictions_list, axis=0, weights=weights)

    return ensemble_pred

# 使用示例
# pred1 = model1.predict(X_val)
# pred2 = model2.predict(X_val)
# pred3 = model3.predict(X_val)
#
# # 简单平均
# ensemble = ensemble_predictions([pred1, pred2, pred3])
#
# # 加权平均
# weights = [0.3, 0.3, 0.4]
# ensemble = ensemble_predictions([pred1, pred2, pred3], weights)
```

#### 常见陷阱和注意事项

| 陷阱 | 说明 | 解决方案 |
|------|------|---------|
| **过拟合 PID 规律** | 模型只对 PID 样本有效 | 加入真实呼吸样本训练 |
| **数据泄露** | 使用未来信息 | 严格按时间切分 |
| **多任务权重不当** | 辅助任务干扰主任务 | 调优权重或渐进训练 |
| **集成过拟合** | 集成太多模型 | 3-5 个模型即可 |
| **特征工程过度** | 特征比样本还多 | 特征选择和降维 |
| **验证集策略错误** | 同一 breath 分散到训练和验证 | Group K-Fold |

---

## Metadata

| Source | Date | Tags |
|--------|------|------|
| [HMS - Harmful Brain Activity Classification](https://www.kaggle.com/competitions/hms-harmful-brain-activity-classification) | 2025-01-22 | EEG, 分类, CWT, Entmax, 2-Stage Training, KL-Divergence |
| [Child Mind Institute - Detect Sleep States](https://www.kaggle.com/competitions/child-mind-institute-detect-sleep-states) | 2025-01-22 | 睡眠检测, 事件检测, 两阶段建模, 后处理优化, 多tolerance AP |
| [Child Mind Institute - Detect Behavior with Sensor Data](https://www.kaggle.com/competitions/cmi-detect-behavior-with-sensor-data) | 2025-01-22 | 多模态时序, IMU+TOF+THM, 行为识别, 阶段感知Attention, 匈牙利算法 |
| [BirdCLEF 2024](https://www.kaggle.com/competitions/birdclef-2024) | 2026-01-23 | 音频分类, 生物声学, Statistics T过滤, Google Classifier预标注, CE Loss, Sigmoid推理, Min Ensemble, Checkpoint Soup, 伪标签迭代, 120分钟推理限制 |
| [BirdCLEF+ 2025](https://www.kaggle.com/competitions/birdclef-2025) | 2026-01-22 | 音频分类, 生物声学, Noisy Student, 自蒸馏, SED模型, 伪标签, Mel-Spectrogram, Soft AUC Loss, 90分钟推理限制 |
| [Google Brain - Ventilator Pressure Prediction](https://www.kaggle.com/c/ventilator-pressure-prediction) | 2026-01-23 | 时序回归, PID逆向, 多任务学习, Delta Pressure, LSTM+Transformer, MAE, 2,605队伍 |
| [Cornell Birdcall Identification (BirdCLEF 2020)](https://www.kaggle.com/competitions/birdsong-recognition) | 2026-01-23 | 音频分类, 生物声学, ResNeSt, Attention Pooling, Mel-Spectrogram, Weak Supervision, GAN伪标签, Ensemble, F1-Score, 1,390队伍 |
| [BirdCLEF 2021 - Birdcall Identification](https://www.kaggle.com/competitions/birdclef-2021) | 2026-01-23 | 音频分类, 生物声学, PANNs, 弱监督, Mixup, SpecAugment, Attention Mechanism, F1-Score, 1,700队伍 |
| [BirdCLEF 2022 - Endangered Bird Sounds](https://www.kaggle.com/competitions/birdclef-2022) | 2026-01-23 | 音频分类, 濒危物种, BirdNet, Perch, SED, 多尺度输入, AND规则, Framewise预测, F1-Score, 1,600队伍 |
| [Rainforest Connection Species Audio Detection 2021](https://www.kaggle.com/competitions/rfcx-species-audio-detection) | 2026-01-23 | 音频检测, 生物声学, LWLRAP, Mel-Spectrogram as Image, ResNeSt, EfficientNet, ImageNet预训练, 2,200队伍 |
| [AMP®-Parkinson's Disease Progression Prediction](https://www.kaggle.com/competitions/amp-parkinsons-disease-progression-prediction) | 2026-01-23 | 表格时序回归, 蛋白质数据, Gradient Boosting, SMAPE, XGBoost/LightGBM, 2,500队伍 |

---

## Cornell Birdcall Identification (BirdCLEF 2020)

**竞赛背景：**
- **主办方**：Cornell Lab of Ornithology
- **目标**：识别音频录音中的鸟类叫声（多标签音频分类）
- **应用场景**：鸟类种群监测，生物声学研究，生态系统保护
- **数据集规模**：
  - 训练音频：2,000+ 段录音，涵盖 264 种鸟类
  - 测试音频：约 200 段连续录音（soundscape）
  - 采样率： varied (通常 44.1kHz 或 48kHz)
- **评估指标**：micro-averaged F1-score（需要预测鸟类在 5 秒时间窗口内的出现）
- **最终排名**：
  - 1st Place: Ryan Wong - F1 ~0.71
  - 2nd Place: niw
  - 3rd Place: TheoViel
  - 总参赛队伍：1,390 支

### 前排方案详细技术分析

#### 1st Place - ResNeSt + Attention Pooling + Large Ensemble (Ryan Wong)

核心技巧：
- **ResNeSt Split-Attention Network**：使用 ResNeSt-50 作为主干网络
- **Attention Pooling**：替代传统的全局平均池化
- **Large Voting Ensemble**：13 模型投票集成，需要至少 4 票
- **Mel-Spectrogram Preprocessing**：对数 Mel 频谱特征
- **数据增强**：粉红噪声、高斯噪声、音量调整
- **Multi-Scale Training**：不同音频片段长度

实现细节：
- **音频预处理**：
  - 重采样到 32kHz 或 44.1kHz
  - 使用短时傅里叶变换（STFT）计算 Mel-spectrogram
  - 对数尺度转换：log(1 + mel)
  - 时间维度：5 秒窗口
- **模型架构**：
  - ResNeSt-50 (Split-Attention variants of ResNet)
  - 在 ImageNet 上预训练
  - 替换最后的全连接层为 Attention Pooling
  - 输出层：264 类二分类（多标签）
- **Attention Pooling 实现**：
  ```python
  class AttentionPooling(nn.Module):
      def __init__(self, input_dim, hidden_dim=128):
          super().__init__()
          self.attention = nn.Sequential(
              nn.Linear(input_dim, hidden_dim),
              nn.Tanh(),
              nn.Linear(hidden_dim, 1)
          )

      def forward(self, x):
          # x: (batch, time, features)
          weights = F.softmax(self.attention(x), dim=1)
          return (x * weights).sum(dim=1)
  ```
- **集成策略**：
  - 13 个模型的投票集成
  - 每个预测需要至少 4 票才认为鸟类存在
  - 基于 LB 分数选择模型
  - 不同 checkpoint 和数据增强配置
- **数据增强**：
  - Mixup（混合增强）
  - 背景噪声添加
  - 音高变换（pitch shifting）
  - 时间拉伸（time stretching）
- **训练配置**：
  - Loss：Binary Cross-Entropy
  - Optimizer：AdamW
  - Learning Rate：1e-3（带 cosine annealing）
  - Batch Size：32
  - Epochs：~30

#### 2nd Place - Efficient Ensemble with Strong Data Augmentation (niw)

核心技巧：
- **ResNet50-based Models**：多个 ResNet50 变体
- **Aggressive Data Augmentation**：激进的音频增强
- **Spectral Features**：多种频谱特征组合
- **Prediction Thresholding**：预测阈值优化
- **Cross-Validation Ensemble**：交叉验证集成

实现细节：
- **特征工程**：
  - Mel-spectrogram（128 Mel bins）
  - MFCC（Mel-Frequency Cepstral Coefficients）
  - Chroma features
  - Spectral contrast
- **模型变体**：
  - ResNet50（预训练）
  - EfficientNet-B0
  - DenseNet-121
- **增强策略**：
  - 时间遮罩（SpecAugment Time Masking）
  - 频率遮罩（Frequency Masking）
  - 添加背景噪声
  - 音量随机化
- **后处理**：
  - 类别特定的阈值优化
  - 时间平滑（temporal smoothing）
  - 最小持续时间过滤

#### 3rd Place - Simple yet Effective Approach (TheoViel)

核心技巧：
- **Pre-trained ResNeSt**：使用预训练的 ResNeSt 模型
- **Mel-Spectrogram Input**：标准 Mel 频谱
- **Strong Baseline**：简洁但强大的基线模型
- **Moderate Ensemble**：中等规模集成
- **Careful Validation**：仔细的验证策略

实现细节：
- **音频处理**：
  - 重采样到 44.1kHz
  - 5 秒固定窗口
  - 128 Mel bins
  - 对数幅度压缩
- **模型架构**：
  - ResNeSt50（预训练）
  - Global Average Pooling
  - Sigmoid 激活
- **训练策略**：
  - 5-fold 交叉验证
  - Early stopping
  - Learning rate scheduling
- **集成方法**：
  - 5-7 个模型的平均
  - 不同随机种子

#### 4th Place - Logmels Spectral Features (dimabert & ususani)

核心技巧：
- **Logmels Features**：对数 Mel 频谱作为主要特征
- **Audio Normalization**：音频标准化处理
- **32kHz Resampling**：统一采样率
- **CNN Ensemble**：多个 CNN 模型集成

实现细节：
- **音频预处理**：
  - 重采样到 32,000 Hz
  - 音频归一化（RMS normalization）
  - 固定长度窗口
- **特征提取**：
  - Logmels（对数 Mel-spectrogram）
  - 128 Mel bins
  - 时间帧数：约 500 帧/5秒
- **模型选择**：
  - ResNet50
  - ResNeSt50
  - EfficientNet
- **Loss Function**：
  - Binary Cross-Entropy
  - Label Smoothing

#### 5th Place - Dual Approach with Different Architectures (Kramarenko Vladislav)

核心技巧：
- **Multiple Approaches**：尝试了两种不同的方法
- **Different CNN Architectures**：不同的 CNN 架构
- **Feature Engineering**：特征工程优化
- **Prediction Blending**：预测结果混合

实现细节：
- **方法 1**：ResNet50 + Mel-spectrogram
- **方法 2**：Custom CNN + MFCC features
- **最终集成**：两种方法的加权平均

#### 6th Place - Sound Event Detection with Attention (Deep)

核心技巧：
- **SED Framework**：声音事件检测框架
- **ResNeSt50 Encoder**：ResNeSt50 编码器
- **Attention Mechanism**：注意力机制
- **Strong Augmentation**：强数据增强
- **Post-processing**：后处理优化

实现细节：
- **模型架构**：
  - ResNeSt50 作为特征提取器
  - Temporal Attention Module
  - Multi-head Attention
- **训练技巧**：
  - Mixup augmentation
  - CutMix
  - SpecAugment

#### 7th Place - Three Geese and a GAN (CPJKU)

核心技巧：
- **Weak Supervision**：弱监督学习
- **Generative Augmentation**：使用 GAN 生成增强数据
- **Pseudo-labeling**：伪标签策略
- **Strong Single Model**：强大的单模型
- **Note**：该方案可修改后达到 1-2 名成绩

实现细节：
- **GAN-based Augmentation**：
  - 使用生成对抗网络生成合成音频
  - 增加稀有鸟类的样本
  - 条件 GAN（conditional GAN）
- **弱监督策略**：
  - 利用未标注数据
  - 自训练（self-training）
  - 伪标签迭代优化
- **模型架构**：
  - Modified ResNet
  - Attention pooling
  - Multi-task learning
- **训练流程**：
  - Stage 1: 在标注数据上训练
  - Stage 2: 生成伪标签
  - Stage 3: 在标注+伪标签数据上微调

#### 17th Place - File-level Post-processing

核心技巧：
- **File-level Aggregation**：文件级别聚合
- **Temporal Smoothing**：时间平滑
- **Threshold Optimization**：阈值优化
- **Ensemble Diversification**：集成多样化

实现细节：
- **后处理策略**：
  - 同一文件内的预测平滑
  - 移除短于阈值的检测
  - 类别特定的阈值
- **集成方法**：
  - 多个 checkpoint 平均
  - 不同架构的集成

### 代码模板

#### Mel-Spectrogram 特征提取
```python
import torch
import torch.nn as nn
import torchaudio
import numpy as np

class MelSpectrogramExtractor:
    def __init__(self, sample_rate=32000, n_mels=128, n_fft=2048, hop_length=512):
        self.sample_rate = sample_rate
        self.n_mels = n_mels
        self.n_fft = n_fft
        self.hop_length = hop_length

        # Mel-spectrogram transform
        self.mel_transform = torchaudio.transforms.MelSpectrogram(
            sample_rate=sample_rate,
            n_fft=n_fft,
            hop_length=hop_length,
            n_mels=n_mels,
            f_min=0,
            f_max=16000
        )

        # Amplitude to dB
        self.amplitude_to_db = torchaudio.transforms.AmplitudeToDB()

    def extract(self, waveform):
        """提取 Mel-spectrogram 特征"""
        # Compute mel-spectrogram
        mel_spec = self.mel_transform(waveform)

        # Convert to dB scale
        mel_spec_db = self.amplitude_to_db(mel_spec)

        # Normalize to [0, 1]
        mel_spec_norm = (mel_spec_db - mel_spec_db.min()) / (mel_spec_db.max() - mel_spec_db.min() + 1e-8)

        return mel_spec_norm

# 使用示例
extractor = MelSpectrogramExtractor(sample_rate=32000, n_mels=128)
waveform, sr = torchaudio.load("bird_audio.wav")
if sr != 32000:
    resampler = torchaudio.transforms.Resample(sr, 32000)
    waveform = resampler(waveform)
mel_spec = extractor.extract(waveform)
```

#### ResNeSt + Attention Pooling 模型
```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class AttentionPooling2d(nn.Module):
    """2D Attention Pooling for spectrograms"""
    def __init__(self, in_channels, hidden_dim=128):
        super().__init__()
        self.attention = nn.Sequential(
            nn.Conv2d(in_channels, hidden_dim, kernel_size=1),
            nn.BatchNorm2d(hidden_dim),
            nn.Tanh(),
            nn.Conv2d(hidden_dim, 1, kernel_size=1)
        )

    def forward(self, x):
        # x: (batch, channels, time, freq)
        attn_weights = F.softmax(self.attention(x), dim=(2, 3))
        return (x * attn_weights).sum(dim=(2, 3))

class BirdcallClassifier(nn.Module):
    def __init__(self, num_classes=264, pretrained=True):
        super().__init__()

        # ResNeSt backbone (需要安装 resnest 库)
        from resnest.torch import resnest50

        self.backbone = resnest50(pretrained=pretrained)

        # 替换最后的全连接层
        self.backbone.fc = nn.Identity()

        # Attention pooling
        self.attention_pool = AttentionPooling2d(2048, hidden_dim=128)

        # Classifier head
        self.classifier = nn.Sequential(
            nn.Dropout(0.3),
            nn.Linear(2048, 512),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(512, num_classes)
        )

    def forward(self, x):
        # x: (batch, channels, time, freq) - Mel-spectrogram
        features = self.backbone(x)  # (batch, 2048, H, W)
        pooled = self.attention_pool(features)  # (batch, 2048)
        logits = self.classifier(pooled)  # (batch, num_classes)
        return logits

# 使用示例
model = BirdcallClassifier(num_classes=264, pretrained=True)
mel_spec_batch = torch.randn(8, 3, 224, 512)  # (batch, channels, freq, time)
logits = model(mel_spec_batch)
probs = torch.sigmoid(logits)  # Multi-label prediction
```

#### 数据增强
```python
import torch
import torchaudio
import random

class BirdcallAugmentation:
    def __init__(self, sample_rate=32000):
        self.sample_rate = sample_rate

    def add_noise(self, waveform, noise_level=0.005):
        """添加高斯噪声"""
        noise = torch.randn_like(waveform) * noise_level
        return waveform + noise

    def add_pink_noise(self, waveform, alpha=1):
        """添加粉红噪声（1/f 噪声）"""
        # 简化的粉红噪声生成
        white_noise = torch.randn_like(waveform)
        # 在频域应用 1/f 滤波
        freq_noise = torch.fft.rfft(white_noise)
        freqs = torch.fft.rfftfreq(waveform.shape[-1], 1/self.sample_rate)
        pink_filter = 1 / (freqs[1:] + 1e-8) ** alpha
        freq_noise[:, 1:] *= pink_filter
        pink_noise = torch.fft.irfft(freq_noise, n=waveform.shape[-1])
        return waveform + pink_noise * 0.01

    def time_mask(self, mel_spec, max_mask_pct=0.1):
        """时间遮罩（SpecAugment）"""
        batch, channels, time, freq = mel_spec.shape
        mask_len = int(time * max_mask_pct)
        t = random.randint(0, mask_len)
        t0 = random.randint(0, time - t)
        mel_spec[:, :, t0:t0+t, :] = 0
        return mel_spec

    def freq_mask(self, mel_spec, max_mask_pct=0.1):
        """频率遮罩"""
        batch, channels, time, freq = mel_spec.shape
        mask_len = int(freq * max_mask_pct)
        f = random.randint(0, mask_len)
        f0 = random.randint(0, freq - f)
        mel_spec[:, :, :, f0:f0+f] = 0
        return mel_spec

    def pitch_shift(self, waveform, shift=2.0):
        """音高变换"""
        # 简化实现：使用 resampling
        # 实际应用中可用更高级的库如 pydub 或 librosa
        n_steps = int(shift * 10)
        resampler = torchaudio.transforms.Resample(
            self.sample_rate,
            int(self.sample_rate * (1 + shift * 0.1))
        )
        return resampler(waveform)

    def gain(self, waveform, min_gain=0.5, max_gain=1.5):
        """音量调整"""
        gain = random.uniform(min_gain, max_gain)
        return waveform * gain

# 使用示例
augmentation = BirdcallAugmentation(sample_rate=32000)
waveform, sr = torchaudio.load("bird_audio.wav")

# 应用增强
waveform_aug = augmentation.add_noise(waveform)
waveform_aug = augmentation.gain(waveform_aug)
```

#### 训练循环
```python
import torch
import torch.nn as nn
from torch.utils.data import DataLoader

def train_epoch(model, dataloader, criterion, optimizer, device, augmentation=None):
    model.train()
    total_loss = 0

    for batch in dataloader:
        waveforms, labels = batch
        waveforms = waveforms.to(device)
        labels = labels.to(device)

        # 数据增强（训练时）
        if augmentation is not None:
            # 在 Mel-spectrogram 上应用增强
            pass

        # 前向传播
        logits = model(waveforms)
        loss = criterion(logits, labels.float())

        # 反向传播
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        total_loss += loss.item()

    return total_loss / len(dataloader)

def train_model(model, train_loader, val_loader, num_epochs=30, device='cuda'):
    criterion = nn.BCEWithLogitsLoss()
    optimizer = torch.optim.AdamW(model.parameters(), lr=1e-3, weight_decay=1e-4)
    scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=num_epochs)

    best_val_score = 0

    for epoch in range(num_epochs):
        # 训练
        train_loss = train_epoch(model, train_loader, criterion, optimizer, device)

        # 验证
        val_score, val_loss = validate(model, val_loader, criterion, device)

        # 学习率调度
        scheduler.step()

        print(f"Epoch {epoch+1}/{num_epochs}")
        print(f"Train Loss: {train_loss:.4f}")
        print(f"Val Loss: {val_loss:.4f}")
        print(f"Val F1: {val_score:.4f}")

        # 保存最佳模型
        if val_score > best_val_score:
            best_val_score = val_score
            torch.save(model.state_dict(), 'best_model.pth')

    return model
```

#### 集成与后处理
```python
import numpy as np
import pandas as pd

class EnsemblePredictor:
    def __init__(self, models, threshold=0.5, min_votes=4):
        """
        Args:
            models: 模型列表
            threshold: 二值化阈值
            min_votes: 最小投票数（如 1st place 用 4 票）
        """
        self.models = models
        self.threshold = threshold
        self.min_votes = min_votes

    def predict(self, mel_spec_batch):
        """集成预测"""
        all_predictions = []

        for model in self.models:
            model.eval()
            with torch.no_grad():
                logits = model(mel_spec_batch)
                probs = torch.sigmoid(logits)
                binary = (probs > self.threshold).float()
                all_predictions.append(binary.cpu().numpy())

        # 投票集成
        all_predictions = np.array(all_predictions)  # (n_models, batch, num_classes)
        votes = all_predictions.sum(axis=0)  # (batch, num_classes)

        # 需要至少 min_votes 票
        final_pred = (votes >= self.min_votes).astype(int)

        return final_pred

def temporal_post_process(predictions, window_size=3, min_duration=3):
    """
    时间后处理

    Args:
        predictions: (time_steps, num_classes) 二值预测
        window_size: 平滑窗口大小
        min_duration: 最小持续时间（时间步）
    """
    smoothed = predictions.copy()

    # 时间平滑（多数投票）
    for i in range(predictions.shape[0]):
        start = max(0, i - window_size // 2)
        end = min(predictions.shape[0], i + window_size // 2 + 1)
        window = predictions[start:end]
        smoothed[i] = (window.sum(axis=0) > window_size // 2).astype(int)

    # 移除短于阈值的检测
    final = smoothed.copy()
    for c in range(predictions.shape[1]):
        col = smoothed[:, c]
        # 找连续段
        changes = np.diff(col, prepend=0, append=0)
        starts = np.where(changes == 1)[0]
        ends = np.where(changes == -1)[0]

        for s, e in zip(starts, ends):
            if e - s < min_duration:
                final[s:e, c] = 0

    return final

def create_submission(predictions, audio_ids, bird_species):
    """
    创建提交文件

    Args:
        predictions: (n_samples, num_classes) 二值预测
        audio_ids: 音频文件 ID 列表
        bird_species: 鸟类名称列表
    """
    rows = []
    for audio_id, pred in zip(audio_ids, predictions):
        active_birds = [bird_species[i] for i, p in enumerate(pred) if p == 1]
        if active_birds:
            rows.append({
                'row_id': f"{audio_id}",
                'birds': ' '.join(active_birds)
            })
        else:
            rows.append({
                'row_id': f"{audio_id}",
                'birds': 'nocall'
            })

    submission = pd.DataFrame(rows)
    return submission
```

### 最佳实践

1. **音频预处理标准化**：
   - 统一采样率（32kHz 或 44.1kHz）
   - 使用高质量的 Mel-spectrogram 参数（n_fft=2048, hop_length=512, n_mels=128）
   - 对数幅度压缩（log 或 dB 转换）

2. **模型选择**：
   - ResNeSt 表现最佳（split-attention 机制）
   - 在 ImageNet 上预训练的模型迁移效果好
   - Attention Pooling 优于 Global Average Pooling

3. **数据增强策略**：
   - SpecAugment（时间/频率遮罩）是必需的
   - Mixup 有助于提高泛化能力
   - 添加背景噪声提高鲁棒性
   - GAN 生成增强数据可以提升稀有类别性能

4. **集成方法**：
   - 投票集成优于平均集成
   - 设置最小投票数阈值（如 4 票）可减少误报
   - 使用不同 checkpoint 和随机种子增加多样性

5. **后处理优化**：
   - 时间平滑可以减少闪烁
   - 移除短于阈值的检测
   - 类别特定的阈值优化

6. **验证策略**：
   - 使用 5-fold 交叉验证
   - 仔细设计验证集以反映测试集分布
   - 监控 micro-F1 分数

7. **训练技巧**：
   - 使用 AdamW 优化器
   - Cosine annealing 学习率调度
   - Binary Cross-Entropy Loss
   - Label smoothing 有助于正则化

8. **常见陷阱**：
   - 避免过度拟合训练集的音频特征
   - 注意类别不平衡问题
   - 验证集和测试集可能有不同的分布
   - 推理时间限制（如果有）需要考虑模型效率

---

## BirdCLEF 2021 - Birdcall Identification

**竞赛背景：**
- **主办方**：Cornell Lab of Ornithology + LifeCLEF
- **目标**：识别音频录音中的鸟类叫声（弱监督多标签音频分类）
- **应用场景**：鸟类种群监测，生物声学研究，生态系统保护
- **数据集规模**：
  - 训练音频：约 3,900 段录音，涵盖 397 种鸟类
  - 测试音频：约 2,600 段连续录音（soundscape）
  - 弱监督标注：只有音频级别的标签，无时间戳
- **评估指标**：micro-averaged F1-score
- **最终排名**：
  - 1st Place: DR (kami634) - 弱监督方案
  - 2nd Place: Christof Henkel
  - 3rd Place: shiro
  - 总参赛队伍：约 1,700+ 支

### 前排方案详细技术分析

#### 1st Place - Weak Supervision with PANNs (DR)

核心技巧：
- **Pre-trained Audio Neural Networks (PANNs)**：使用预训练的音频神经网络
- **Weak Supervision Strategy**：弱监督学习策略
- **Attention Mechanisms**：自注意力机制用于音频分类
- **Spectrogram-based Features**：基于频谱图的特征
- **Model Ensemble**：多模型集成
- **Post-processing**：后处理优化

实现细节：
- **基础模型**：
  - 使用预训练的 PANNs (Pre-trained Audio Neural Networks)
  - 包括 CNN14, CNN10, ResNet38 等架构
  - 在 AudioSet 上预训练
  - 迁移学习到鸟类叫声分类
- **特征提取**：
  - Mel-spectrogram（64/128 Mel bins）
  - 对数幅度压缩
  - 多尺度时间窗口
- **弱监督策略**：
  - 仅使用音频级别的标签（无时间戳）
  - 通过注意力机制定位关键区域
  - 多实例学习（Multiple Instance Learning）
- **模型架构**：
  - CNN-based 特征提取器
  - Self-Attention 层
  - Global Pooling + 分类器
- **集成方法**：
  - 多个 PANNs 模型集成
  - 不同架构和预训练权重
  - 投票或平均策略
- **数据增强**：
  - Mixup
  - SpecAugment
  - 背景噪声添加
- **后处理**：
  - 时间平滑
  - 阈值优化
  - 类别特定的后处理

#### 2nd Place - New Baseline with Strong Augmentation (Christof Henkel)

核心技巧：
- **New Baseline Architecture**：新颖的基线架构
- **Mixup Augmentation**：Mixup 数据增强
- **Background Noise Addition**：背景噪声添加
- **Pseudo-labeling**：伪标签策略
- **5-second Segment Inference**：5秒片段推理
- **Strong Single Model**：强大的单模型

实现细节：
- **模型选择**：
  - ResNet50 / ResNeSt50
  - EfficientNet variants
  - DenseNet-based models
- **音频预处理**：
  - 重采样到 32kHz
  - Mel-spectrogram 提取
  - 标准化处理
- **增强策略**：
  - Mixup（强制使用）
  - 时间遮罩（Time Masking）
  - 频率遮罩（Frequency Masking）
  - 背景噪声混合
- **伪标签**：
  - 使用训练好的模型预测未标注数据
  - 高置信度预测作为伪标签
  - 迭代训练
- **训练配置**：
  - Binary Cross-Entropy Loss
  - AdamW 优化器
  - Cosine 学习率衰减
  - 5-fold 交叉验证
- **推理策略**：
  - 5秒滑动窗口
  - 窗口间有重叠
  - 多个窗口预测聚合

#### 3rd Place - Ensemble with Multiple Approaches (shiro)

核心技巧：
- **Multiple Model Families**：多族模型集成
- **Spectral Feature Engineering**：频谱特征工程
- **Cross-Validation Strategy**：交叉验证策略
- **Post-processing Pipeline**：后处理流程
- **Attention-based Models**：基于注意力的模型

实现细节：
- **模型选择**：
  - ResNet variants
  - DenseNet variants
  - EfficientNet variants
  - Custom CNN architectures
- **特征多样性**：
  - 不同 Mel-spectrogram 参数
  - MFCC features
  - Chroma features
  - Spectral contrast
- **训练策略**：
  - 5-fold 交叉验证
  - Early stopping
  - Learning rate scheduling
- **集成方法**：
  - 加权平均
  - 基于验证集权重优化
  - 不同 checkpoint 集成

#### 4th Place - Third Time's The Charm (tattaka)

核心技巧：
- **Iterative Improvement**：迭代改进策略
- **Strong Data Augmentation**：强数据增强
- **Spectrogram Preprocessing**：频谱预处理优化
- **Model Architecture Search**：模型架构搜索
- **Ensemble Optimization**：集成优化

实现细节：
- **音频处理**：
  - 高质量 Mel-spectrogram 参数调优
  - 多种时间窗口长度
  - 频率范围选择
- **模型架构**：
  - ResNet50
  - ResNeSt50
  - DenseNet-121
- **增强组合**：
  - SpecAugment（多种参数）
  - Mixup + CutMix
  - 噪声增强
  - 音高变换
- **训练技巧**：
  - 渐进式训练
  - 迭代优化
  - A/B 测试不同策略

#### 5th Place - Dual Approach Blending (Kramarenko Vladislav)

核心技巧：
- **Multiple Approaches**：多种方法尝试
- **Different Feature Sets**：不同特征集
- **Blending Strategy**：混合策略
- **Spectral Analysis**：频谱分析

实现细节：
- **方法 1**：CNN + Mel-spectrogram
- **方法 2**：Gradient Boosting + 手工特征
- **最终集成**：两种方法加权混合

#### 6th-10th Place 概述

**常见技术**：
- PANNs 预训练模型广泛使用
- SpecAugment 成为标准增强
- Mixup 几乎所有前排方案使用
- 5-fold 交叉验证是标准配置
- Mel-spectrogram 是主流特征

**关键技术点**：
- **弱监督处理**：使用注意力机制定位音频中的鸟类叫声
- **数据增强**：SpecAugment + Mixup + 背景噪声
- **模型集成**：多架构、多 checkpoint 集成
- **后处理**：时间平滑、阈值优化、类别特定处理

### 代码模板

#### PANNs 模型加载和使用
```python
import torch
import torch.nn as nn
# 需要安装: pip install torchlibrosa
from torchlibrosa.stft import Spectrogram, LogmelFilterBank

class PANNsCNN14(nn.Module):
    """
    基于 PANNs CNN14 的模型
    参考: https://github.com/qiuqiangkong/audioset_tagging_cnn
    """
    def __init__(self, sample_rate=32000, window_size=512, hop_size=320,
                 mel_bins=64, fmin=50, fmax=14000, num_classes=397):
        super().__init__()

        window = 'hann'
        center = True
        pad_mode = 'reflect'
        ref = 1.0
        amin = 1e-10
        top_db = None

        # Spectrogram extractor
        self.spectrogram_extractor = Spectrogram(
            n_fft=window_size,
            hop_length=hop_size,
            win_length=window_size,
            window=window,
            center=center,
            pad_mode=pad_mode,
            freeze_parameters=True)

        # Logmel feature extractor
        self.logmel_extractor = LogmelFilterBank(
            sr=sample_rate,
            n_fft=window_size,
            n_mels=mel_bins,
            fmin=fmin,
            fmax=fmax,
            ref=ref,
            amin=amin,
            top_db=top_db,
            freeze_parameters=True)

        # SpecAugment (训练时使用)
        self.spec_augment = SpecAugmentation(
            time_drop_width=64,
            time_stripes_num=2,
            freq_drop_width=8,
            freq_stripes_num=2)

        # CNN14 backbone
        self.bn0 = nn.BatchNorm2d(mel_bins)

        self.conv_block1 = ConvBlock(in_channels=1, out_channels=64)
        self.conv_block2 = ConvBlock(in_channels=64, out_channels=128)
        self.conv_block3 = ConvBlock(in_channels=128, out_channels=256)
        self.conv_block4 = ConvBlock(in_channels=256, out_channels=512)
        self.conv_block5 = ConvBlock(in_channels=512, out_channels=1024)
        self.conv_block6 = ConvBlock(in_channels=1024, out_channels=2048)

        self.fc1 = nn.Linear(2048, 2048, bias=True)
        self.fc_audioset = nn.Linear(2048, num_classes, bias=True)

        self.init_weight()

    def init_weight(self):
        init_bn(self.bn0)
        init_layer(self.fc1)
        init_layer(self.fc_audioset)

    def forward(self, input, mixup_lambda=None, device='cuda'):
        """
        Args:
            input: (batch_size, time_samples)
        Returns:
            output: (batch_size, num_classes)
        """
        # Spectrogram
        x = self.spectrogram_extractor(input)  # (batch, 1, time, freq)
        x = self.logmel_extractor(x)  # (batch, 1, time, mel_bins)

        # BN
        x = x.transpose(1, 3)
        x = self.bn0(x)
        x = x.transpose(1, 3)

        # SpecAugment (仅训练时)
        if self.training:
            x = self.spec_augment(x)

        # CNN blocks
        x = self.conv_block1(x, pool_size=(2, 2), pool_type='avg')
        x = F.dropout(x, p=0.2, training=self.training)

        x = self.conv_block2(x, pool_size=(2, 2), pool_type='avg')
        x = F.dropout(x, p=0.2, training=self.training)

        x = self.conv_block3(x, pool_size=(2, 2), pool_type='avg')
        x = F.dropout(x, p=0.2, training=self.training)

        x = self.conv_block4(x, pool_size=(2, 2), pool_type='avg')
        x = F.dropout(x, p=0.2, training=self.training)

        x = self.conv_block5(x, pool_size=(2, 2), pool_type='avg')
        x = F.dropout(x, p=0.2, training=self.training)

        x = self.conv_block6(x, pool_size=(1, 1), pool_type='avg')
        x = F.dropout(x, p=0.2, training=self.training)

        # Global pooling
        x = torch.mean(x, dim=3)  # (batch, channels, time)

        (x1, _) = torch.max(x, dim=2)  # (batch, channels)
        x2 = torch.mean(x, dim=2)  # (batch, channels)
        x = x1 + x2  # (batch, channels)

        x = F.dropout(x, p=0.5, training=self.training)
        x = F.relu_(self.fc1(x))
        embedding = F.dropout(x, p=0.5, training=self.training)
        clipwise_output = torch.sigmoid(self.fc_audioset(x))

        return clipwise_output

    def load_from_pretrained(self, pretrained_path):
        """加载预训练权重"""
        checkpoint = torch.load(pretrained_path, map_location='cpu')
        model_state = self.state_dict()
        pretrained_state = checkpoint['model']

        # 过滤不匹配的键
        pretrained_state = {k: v for k, v in pretrained_state.items()
                          if k in model_state and v.shape == model_state[k].shape}

        model_state.update(pretrained_state)
        self.load_state_dict(model_state)
        print(f"Loaded pretrained weights from {pretrained_path}")

class ConvBlock(nn.Module):
    def __init__(self, in_channels, out_channels):
        super().__init__()

        self.conv1 = nn.Conv2d(in_channels=in_channels,
                              out_channels=out_channels,
                              kernel_size=(3, 3), stride=(1, 1),
                              padding=(1, 1), bias=False)
        self.conv2 = nn.Conv2d(in_channels=out_channels,
                              out_channels=out_channels,
                              kernel_size=(3, 3), stride=(1, 1),
                              padding=(1, 1), bias=False)
        self.bn1 = nn.BatchNorm2d(out_channels)
        self.bn2 = nn.BatchNorm2d(out_channels)

        self.init_weight()

    def init_weight(self):
        init_bn(self.bn1)
        init_bn(self.bn2)
        init_layer(self.conv1)
        init_layer(self.conv2)

    def forward(self, input, pool_size=(2, 2), pool_type='avg'):
        x = input
        x = F.relu_(self.bn1(self.conv1(x)))
        x = F.relu_(self.bn2(self.conv2(x)))
        if pool_type == 'max':
            x = F.max_pool2d(x, kernel_size=pool_size)
        elif pool_type == 'avg':
            x = F.avg_pool2d(x, kernel_size=pool_size)
        elif pool_type == 'avg+max':
            x1 = F.avg_pool2d(x, kernel_size=pool_size)
            x2 = F.max_pool2d(x, kernel_size=pool_size)
            x = x1 + x2
        else:
            raise ValueError(f'Unknown pool type: {pool_type}')
        return x

class SpecAugmentation(nn.Module):
    def __init__(self, time_drop_width, time_stripes_num,
                 freq_drop_width, freq_stripes_num):
        super().__init__()
        self.time_drop_width = time_drop_width
        self.time_stripes_num = time_stripes_num
        self.freq_drop_width = freq_drop_width
        self.freq_stripes_num = freq_stripes_num

    def forward(self, x):
        """x: (batch, channels, time, freq)"""
        self._mask_along_axis(x, self.time_drop_width,
                             self.time_stripes_num, axis=2)
        self._mask_along_axis(x, self.freq_drop_width,
                             self.freq_stripes_num, axis=3)
        return x

    def _mask_along_axis(self, x, drop_width, stripes_num, axis):
        """沿指定轴遮罩"""
        for _ in range(stripes_num):
            drop_width = int(drop_width) if isinstance(drop_width, int) else \
                        int(drop_width * x.shape[axis])
            drop_start = int(torch.rand(1).item() * (x.shape[axis] - drop_width))

            if axis == 2:  # time axis
                x[:, :, drop_start:drop_start + drop_width, :] = 0
            elif axis == 3:  # freq axis
                x[:, :, :, drop_start:drop_start + drop_width] = 0
        return x

def init_layer(layer):
    """Initialize a Linear or Convolutional layer."""
    nn.init.xavier_uniform_(layer.weight)
    if hasattr(layer, 'bias'):
        if layer.bias is not None:
            layer.bias.data.fill_(0.)

def init_bn(bn):
    """Initialize a Batchnorm layer."""
    bn.bias.data.fill_(0.)
    bn.weight.data.fill_(1.)

# 使用示例
model = PANNsCNN14(
    sample_rate=32000,
    window_size=512,
    hop_size=320,
    mel_bins=64,
    num_classes=397
)

# 加载预训练权重（可选）
# model.load_from_pretrained('path/to/pretrained/CNN14.pth')

waveform = torch.randn(4, 32000 * 5)  # (batch, 5 seconds at 32kHz)
with torch.no_grad():
    output = model(waveform)
print(output.shape)  # (4, 397)
```

#### Mixup 数据增强
```python
import torch
import numpy as np

def mixup_data(x, y, alpha=0.2):
    """
    Mixup 数据增强

    Args:
        x: 输入数据 (batch_size, ...)
        y: 标签 (batch_size, num_classes)
        alpha: Beta 分布参数

    Returns:
        mixed_x: 混合后的输入
        y_a, y_b: 两个样本的标签
        lam: 混合系数
    """
    if alpha > 0:
        lam = np.random.beta(alpha, alpha)
    else:
        lam = 1

    batch_size = x.size(0)
    index = torch.randperm(batch_size).to(x.device)

    mixed_x = lam * x + (1 - lam) * x[index, :]
    y_a, y_b = y, y[index]

    return mixed_x, y_a, y_b, lam

def mixup_criterion(criterion, pred, y_a, y_b, lam):
    """Mixup 损失函数"""
    return lam * criterion(pred, y_a) + (1 - lam) * criterion(pred, y_b)

# 使用示例
criterion = nn.BCEWithLogitsLoss()

for batch_idx, (waveforms, labels) in enumerate(train_loader):
    waveforms = waveforms.to(device)
    labels = labels.to(device)

    # 应用 Mixup
    waveforms_mixed, labels_a, labels_b, lam = mixup_data(
        waveforms, labels, alpha=0.2
    )

    # 前向传播
    outputs = model(waveforms_mixed)

    # 计算 Mixup 损失
    loss = mixup_criterion(criterion, outputs, labels_a, labels_b, lam)

    # 反向传播
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()
```

#### 弱监督训练（音频级别标签）
```python
import torch
import torch.nn as nn
from torch.utils.data import Dataset

class BirdcallWeakDataset(Dataset):
    """
    弱监督数据集：只有音频级别标签，无时间戳
    """
    def __init__(self, audio_files, labels, audio_transforms=None,
                 duration=5, sample_rate=32000):
        self.audio_files = audio_files
        self.labels = labels  # Multi-hot labels: (num_samples, num_classes)
        self.audio_transforms = audio_transforms
        self.duration = duration
        self.sample_rate = sample_rate

    def __len__(self):
        return len(self.audio_files)

    def __getitem__(self, idx):
        # 加载音频
        waveform, sr = torchaudio.load(self.audio_files[idx])

        # 重采样
        if sr != self.sample_rate:
            resampler = torchaudio.transforms.Resample(sr, self.sample_rate)
            waveform = resampler(waveform)

        # 固定长度（裁剪或填充）
        target_length = self.duration * self.sample_rate
        if waveform.shape[1] > target_length:
            # 随机裁剪
            start = torch.randint(0, waveform.shape[1] - target_length, (1,)).item()
            waveform = waveform[:, start:start + target_length]
        elif waveform.shape[1] < target_length:
            # 填充
            padding = target_length - waveform.shape[1]
            waveform = torch.nn.functional.pad(waveform, (0, padding))

        # 获取标签（音频级别，多标签）
        label = self.labels[idx]

        # 数据增强
        if self.audio_transforms is not None:
            waveform = self.audio_transforms(waveform)

        return waveform, label

class AttentionPooling(nn.Module):
    """
    注意力池化：用于弱监督学习，自动定位重要区域
    """
    def __init__(self, input_dim, hidden_dim=128):
        super().__init__()
        self.attention = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.Tanh(),
            nn.Linear(hidden_dim, 1)
        )

    def forward(self, x):
        """
        Args:
            x: (batch, time_steps, features)

        Returns:
            pooled: (batch, features)
            weights: (batch, time_steps) - 可视化注意力
        """
        attn_weights = F.softmax(self.attention(x), dim=1)
        pooled = (x * attn_weights).sum(dim=1)
        return pooled, attn_weights

class WeaklySupervisedBirdcallModel(nn.Module):
    """
    弱监督鸟类叫声分类模型
    """
    def __init__(self, num_classes=397, pretrained=True):
        super().__init__()

        # 使用预训练的 PANNs CNN14 作为特征提取器
        self.backbone = PANNsCNN14(num_classes=num_classes, pretrained=pretrained)

        # 移除最后的分类层
        self.backbone.fc_audioset = nn.Identity()

        # 注意力池化
        feature_dim = 2048  # CNN14 的输出维度
        self.attention_pool = AttentionPooling(feature_dim, hidden_dim=128)

        # 分类器
        self.classifier = nn.Sequential(
            nn.Dropout(0.3),
            nn.Linear(feature_dim, 512),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(512, num_classes)
        )

    def forward(self, x, return_attention=False):
        """
        Args:
            x: (batch, time_samples)
            return_attention: 是否返回注意力权重用于可视化

        Returns:
            logits: (batch, num_classes)
            attention_weights (optional): (batch, time_steps)
        """
        # 提取特征（修改 backbone 以返回时间维度特征）
        features = self.extract_features(x)  # (batch, time_steps, feature_dim)

        # 注意力池化
        pooled, attn_weights = self.attention_pool(features)

        # 分类
        logits = self.classifier(pooled)

        if return_attention:
            return logits, attn_weights
        return logits

    def extract_features(self, x):
        """
        从 backbone 提取时间维度特征
        这是一个简化版本，实际使用时需要修改 PANNsCNN14
        """
        # 简化实现：直接使用全局特征
        with torch.no_grad():
            features = self.backbone.fc1(
                torch.mean(self.backbone.bn0(
                    self.backbone.logmel_extractor(
                        self.backbone.spectrogram_extractor(x)
                    ).transpose(1, 3)
                ), dim=3)
            )
        # 添加时间维度
        return features.unsqueeze(1)  # (batch, 1, feature_dim)

# 训练循环
def train_weakly_supervised(model, dataloader, criterion, optimizer, device, use_mixup=True):
    model.train()

    for waveforms, labels in dataloader:
        waveforms = waveforms.to(device)
        labels = labels.to(device).float()

        # Mixup 增强
        if use_mixup and np.random.rand() < 0.5:
            waveforms, labels_a, labels_b, lam = mixup_data(waveforms, labels, alpha=0.2)

        # 前向传播
        logits = model(waveforms)

        # 计算损失
        if use_mixup and np.random.rand() < 0.5:
            loss = mixup_criterion(criterion, logits, labels_a, labels_b, lam)
        else:
            loss = criterion(logits, labels)

        # 反向传播
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

# 可视化注意力（用于理解模型关注的区域）
def visualize_attention(model, waveform, bird_name):
    """可视化注意力权重，了解模型关注的音频区域"""
    model.eval()
    with torch.no_grad():
        logits, attention = model(waveform.unsqueeze(0), return_attention=True)

    # attention: (1, time_steps)
    attention = attention.squeeze(0).cpu().numpy()

    import matplotlib.pyplot as plt
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 6))

    # 音频波形
    ax1.plot(waveform.cpu().numpy().T)
    ax1.set_title(f'Audio Waveform - {bird_name}')
    ax1.set_xlabel('Time')
    ax1.set_ylabel('Amplitude')

    # 注意力权重
    ax2.plot(attention)
    ax2.set_title('Attention Weights')
    ax2.set_xlabel('Time Step')
    ax2.set_ylabel('Attention Weight')

    plt.tight_layout()
    plt.savefig('attention_visualization.png')
    plt.close()
```

#### 5秒滑动窗口推理
```python
import torch
import numpy as np

def predict_with_sliding_window(model, audio_path, window_size=5,
                                hop_size=2.5, sample_rate=32000,
                                device='cuda'):
    """
    使用滑动窗口进行推理

    Args:
        model: 训练好的模型
        audio_path: 音频文件路径
        window_size: 窗口大小（秒）
        hop_size: 跳跃大小（秒）
        sample_rate: 采样率
        device: 设备

    Returns:
        predictions: (num_windows, num_classes)
        timestamps: 窗口时间戳
    """
    model.eval()

    # 加载音频
    waveform, sr = torchaudio.load(audio_path)
    if sr != sample_rate:
        resampler = torchaudio.transforms.Resample(sr, sample_rate)
        waveform = resampler(waveform)

    waveform = waveform.mean(dim=0, keepdim=True)  # 转为单声道

    # 计算窗口参数
    window_samples = int(window_size * sample_rate)
    hop_samples = int(hop_size * sample_rate)

    predictions = []
    timestamps = []

    # 滑动窗口
    with torch.no_grad():
        for start in range(0, waveform.shape[1] - window_samples + 1, hop_samples):
            end = start + window_samples
            window = waveform[:, start:end].to(device)

            # 预测
            logits = model(window)
            probs = torch.sigmoid(logits).cpu().numpy()

            predictions.append(probs[0])
            timestamps.append(start / sample_rate)

    predictions = np.array(predictions)
    timestamps = np.array(timestamps)

    return predictions, timestamps

def aggregate_predictions(predictions, threshold=0.5, min_duration=3):
    """
    聚合滑动窗口预测

    Args:
        predictions: (num_windows, num_classes)
        threshold: 二值化阈值
        min_duration: 最小持续时间（窗口数）

    Returns:
        final_pred: (num_windows, num_classes) 二值预测
    """
    binary_pred = (predictions > threshold).astype(int)

    # 时间平滑
    final_pred = binary_pred.copy()
    for c in range(binary_pred.shape[1]):
        col = binary_pred[:, c]

        # 移除短于阈值的检测
        changes = np.diff(col, prepend=0, append=0)
        starts = np.where(changes == 1)[0]
        ends = np.where(changes == -1)[0]

        for s, e in zip(starts, ends):
            if e - s < min_duration:
                final_pred[s:e, c] = 0

    return final_pred

def create_birdclef_submission(predictions, timestamps, audio_id,
                               bird_species, threshold=0.5):
    """
    创建 BirdCLEF 格式的提交文件

    Args:
        predictions: (num_windows, num_classes) 概率预测
        timestamps: (num_windows,) 时间戳
        audio_id: 音频文件 ID
        bird_species: 鸟类名称列表
        threshold: 二值化阈值

    Returns:
        rows: 提交文件的行列表
    """
    rows = []

    for i, (pred, ts) in enumerate(zip(predictions, timestamps)):
        # 获取活跃的鸟类
        active_birds = []
        for j, p in enumerate(pred):
            if p > threshold:
                active_birds.append(bird_species[j])

        # 创建 row_id
        row_id = f"{audio_id}_{ts:.1f}"

        if active_birds:
            rows.append({
                'row_id': row_id,
                'birds': ' '.join(active_birds)
            })
        else:
            rows.append({
                'row_id': row_id,
                'birds': 'nocall'
            })

    return rows

# 使用示例
model = WeaklySupervisedBirdcallModel(num_classes=397)
model = model.to(device)
model.load_state_dict(torch.load('best_model.pth'))

audio_path = 'test_soundscape.wav'
predictions, timestamps = predict_with_sliding_window(
    model, audio_path, window_size=5, hop_size=2.5, device=device
)

# 聚合预测
final_pred = aggregate_predictions(predictions, threshold=0.5, min_duration=3)

# 创建提交
bird_species = [...]  # 397 个鸟类名称列表
rows = create_birdclef_submission(
    predictions, timestamps, 'soundscape_01', bird_species, threshold=0.5
)

import pandas as pd
submission = pd.DataFrame(rows)
submission.to_csv('submission.csv', index=False)
```

### 最佳实践

1. **弱监督学习策略**：
   - 使用注意力机制定位音频中的关键区域
   - 多实例学习（MIL）框架处理音频级别标签
   - 时序池化（Temporal Pooling）聚合时间维度信息

2. **预训练模型利用**：
   - PANNs（AudioSet 预训练）是最流行的起点
   - CNN14/CNN10 提供强大的基线特征
   - 迁移学习显著提升性能

3. **数据增强组合**：
   - SpecAugment（时间+频率遮罩）必需
   - Mixup 是 BirdCLEF 2021 的关键技巧
   - 背景噪声添加提高鲁棒性
   - 组合多种增强效果最佳

4. **训练技巧**：
   - 5-fold 交叉验证标准配置
   - AdamW + Cosine 学习率
   - Binary Cross-Entropy Loss
   - Label Smoothing 有助于正则化
   - 渐进式训练策略

5. **推理策略**：
   - 5秒滑动窗口（与标注一致）
   - 窗口间有重叠（2.5秒跳跃）
   - 时间平滑减少闪烁
   - 移除短于阈值的检测

6. **集成方法**：
   - 多架构集成（ResNet, DenseNet, EfficientNet）
   - 多 checkpoint 集成
   - 不同增强配置增加多样性
   - 加权平均或投票集成

7. **后处理优化**：
   - 类别特定的阈值优化
   - 时间平滑（移动平均或中值滤波）
   - 最小持续时间过滤
   - 基于验证集优化阈值

8. **常见陷阱**：
   - 忽略弱监督的特殊性（无时间戳）
   - 过度依赖单一模型
   - 验证集和测试集分布不同
   - 忘记时间平滑导致预测不稳定
   - 阈值选择不当影响 F1 分数

---

## BirdCLEF 2022 - Endangered Bird Sounds Classification

**竞赛背景：**
- **主办方**：Cornell Lab of Ornithology + LifeCLEF
- **目标**：识别夏威夷濒危鸟类的叫声（多标签音频分类）
- **应用场景**：濒危物种保护，生态系统监测
- **数据集规模**：
  - 训练音频：约 8,700 段标注录音，涵盖 152 种鸟类（主要是夏威夷物种）
  - 测试音频：约 1,300 段连续录音（soundscape）
  - 短片段标注：部分音频有 5 秒级别的短片段标注
  - 背景噪声：包含雨声、风声、昆虫声等复杂环境音
- **评估指标**：micro-averaged F1-score
- **最终排名**：
  - 1st Place: kdl - "It's not all BirdNet"
  - 2nd Place: Leon Shangguan
  - 3rd Place: uemu-slime
  - 总参赛队伍：约 1,600+ 支

### 前排方案详细技术分析

#### 1st Place - Beyond BirdNet (kdl)

核心技巧：
- **BirdNet + Perch Architecture**：结合 BirdNet 和 Perch 模型
- **SED Framework**：声音事件检测框架
- **Multi-scale Input**：短片段（5秒）和长片段（10秒+）
- **AND Rule**：短片段和长片段预测的 AND 逻辑
- **Model Ensemble**：多架构集成
- **External Data**：使用 BirdCLEF 2021 数据增强

实现细节：
- **模型架构组合**：
  - BirdNet（预训练鸟类分类模型）
  - Perch（预训练模型，类似 BirdNET-lite）
  - 自训练 CNN 模型（ResNet50/ResNeSt50）
  - SED 模型（framewise 输出）
- **多尺度策略**：
  - 短片段（5秒）：精确分类
  - 长片段（10-15秒）：提高召回率
  - AND 规则：短片段 AND 长片段都预测为正才认为存在
- **SED 实现**：
  - 使用 framewise 输出
  - max(framewise, dim=time) 聚合
  - 时间注意力机制
- **集成方法**：
  - 多个模型集成（10+ 模型）
  - 不同预训练权重
  - 不同输入长度
  - TTA（Test Time Augmentation）
- **外部数据**：
  - BirdCLEF 2021 数据迁移学习
  - 额外鸟类音频数据
- **后处理**：
  - 时间平滑
  - 最小持续时间过滤
  - 类别特定阈值

#### 2nd Place - SED + CNN with 7 Models Ensemble (Leon Shangguan)

核心技巧：
- **SED Framework**：声音事件检测框架
- **10-second Chunks**：10秒片段处理
- **Centered 5-second CNN**：中心 5 秒 CNN 预测
- **Max Framewise Pooling**：framewise 最大值池化
- **7 Models Ensemble**：7 模型集成
- **TTA with 2s Shifts**：2秒偏移的测试时增强

实现细节：
- **SED 模型**：
  - 使用 10 秒音频片段
  - 输出 framewise 预测
  - max(framewise, dim=time) 聚合
  - ResNet50/ResNeSt50 backbone
- **CNN 模型**：
  - 仅对中心 5 秒进行预测
  - 减少计算量
  - Mel-spectrogram 输入
- **集成策略**：
  - 7 个模型集成
  - 不同架构和配置
  - 加权平均
- **TTA**：
  - 2 秒偏移的多个预测
  - 预测平均
- **数据增强**：
  - SpecAugment
  - Mixup
  - 背景噪声

#### 3rd Place - 18 Checkpoints Ensemble (uemu-slime)

核心技巧：
- **18 Checkpoints Ensemble**：18 个模型检查点集成
- **Multiple CNN Architectures**：多种 CNN 架构
- **Different Folds**：不同折的训练
- **Perch + BirdNet**：使用预训练模型
- **Strong Data Augmentation**：强数据增强

实现细节：
- **模型架构**：
  - ResNet50
  - ResNeSt50
  - EfficientNet-B0/B3
  - Perch（预训练）
  - BirdNet（预训练）
- **训练策略**：
  - 每个架构在 5-fold 上训练
  - 选择最佳 checkpoint
  - 共 18 个模型
- **集成方法**：
  - 简单平均
  - 所有模型等权重
- **增强组合**：
  - SpecAugment
  - Mixup
  - 背景噪声
  - 时间遮罩/频率遮罩

#### 4th Place - CNN-based Ensemble (Kramarenko Vladislav)

核心技巧：
- **CNN Ensemble**：CNN 模型集成
- **Mel-Spectrogram Features**：Mel 频谱特征
- **Multiple Backbones**：多种主干网络
- **Cross-Validation**：交叉验证

实现细节：
- **模型选择**：
  - ResNet50
  - ResNeSt50
  - DenseNet-121
- **特征工程**：
  - Mel-spectrogram
  - 不同参数配置
- **训练**：
  - 5-fold 交叉验证
  - Early stopping

#### 5th Place - Reimplementation of 2021 2nd Place (common-kestrel)

核心技巧：
- **9 Models Ensemble**：9 模型集成
- **BirdCLEF 2021 Baseline**：重实现 2021 年 2nd place 方案
- **4x Backbones**：4 种主干网络
- **Different Seeds and Folds**：不同随机种子和折

实现细节：
- **主干网络**：
  - ResNet50
  - ResNeSt50
  - EfficientNet-B0
  - DenseNet-121
- **配置多样性**：
  - 不同随机种子
  - 不同 fold
  - 不同数据增强参数
- **集成方法**：
  - 平均集成
  - 9 个模型

#### 6th-10th Place 概述

**常见技术**：
- BirdNet 预训练模型广泛使用
- Perch 模型（类似 BirdNET-lite）
- SED（Sound Event Detection）框架
- 多尺度输入（5秒 + 10-15秒）
- SpecAugment + Mixup 标准配置

**关键技术点**：
- **短片段长片段结合**：AND 规则减少误报
- **Framewise 预测**：SED 模型的 framewise 输出
- **外部数据利用**：BirdCLEF 2021 数据迁移学习
- **模型集成**：10-20 个模型集成是常态
- **后处理**：时间平滑、最小持续时间过滤

### 代码模板

#### SED 模型（Framewise 输出）
```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class SEDModel(nn.Module):
    """
    声音事件检测模型 - 输出 framewise 预测

    用于 BirdCLEF 2022 风格的音频分类
    """
    def __init__(self, num_classes=152, backbone='resnet50',
                 sample_rate=32000, window_size=5, hop_size=512):
        super().__init__()

        self.num_classes = num_classes
        self.window_size = window_size
        self.sample_rate = sample_rate

        # Mel-spectrogram 提取器
        self.mel_extractor = MelSpectrogramExtractor(
            sample_rate=sample_rate,
            n_mels=128,
            n_fft=2048,
            hop_length=hop_size
        )

        # Backbone（简化版本）
        if backbone == 'resnet50':
            import torchvision.models as models
            self.backbone = models.resnet50(pretrained=True)
            # 修改第一层接受 1 通道输入（mel-spectrogram）
            self.backbone.conv1 = nn.Conv2d(
                1, 64, kernel_size=7, stride=2, padding=3, bias=False
            )
            feature_dim = 2048
        elif backbone == 'resnest50':
            # 使用 ResNeSt50
            feature_dim = 2048

        # 移除最后的全连接层
        self.backbone.fc = nn.Identity()

        # Framewise 分类头
        self.fc = nn.Linear(feature_dim, num_classes)

    def forward(self, waveform, return_frames=False):
        """
        Args:
            waveform: (batch, time_samples)
            return_frames: 是否返回 framewise 预测

        Returns:
            output: (batch, num_classes) 或 (batch, time_frames, num_classes)
        """
        batch_size = waveform.shape[0]

        # 提取 Mel-spectrogram
        mel_spec = self.mel_extractor.extract(waveform)  # (batch, 1, mel_bins, time_frames)

        # 通过 backbone（保留时间维度）
        # 简化版本：实际需要修改 backbone 以保留时间维度
        features = self.extract_features_with_time(mel_spec)  # (batch, time_frames, feature_dim)

        # Framewise 预测
        framewise_output = self.fc(features)  # (batch, time_frames, num_classes)

        if return_frames:
            return framewise_output

        # 聚合（max pooling over time）
        output, _ = torch.max(framewise_output, dim=1)  # (batch, num_classes)

        return output

    def extract_features_with_time(self, mel_spec):
        """
        提取特征并保留时间维度

        这是一个简化版本，实际使用时需要修改 backbone
        """
        # 将时间维度视为 batch 维度处理
        batch, channels, mel_bins, time_frames = mel_spec.shape

        # Reshape: (batch * time_frames, channels, mel_bins, 1)
        mel_spec_reshaped = mel_spec.permute(0, 3, 1, 2).reshape(
            batch * time_frames, channels, mel_bins, 1
        )

        # 通过 backbone（需要对输入维度进行调整）
        # 这里简化为直接使用全局特征
        features = self.backbone(mel_spec_reshaped)  # (batch * time_frames, feature_dim)

        # Reshape 回 (batch, time_frames, feature_dim)
        features = features.reshape(batch, time_frames, -1)

        return features

class MultiScaleSEDModel(nn.Module):
    """
    多尺度 SED 模型

    结合短片段（5秒）和长片段（10秒）预测
    """
    def __init__(self, num_classes=152, short_duration=5, long_duration=10):
        super().__init__()

        self.num_classes = num_classes

        # 短片段模型（5秒）
        self.short_model = SEDModel(
            num_classes=num_classes,
            window_size=short_duration
        )

        # 长片段模型（10秒）
        self.long_model = SEDModel(
            num_classes=num_classes,
            window_size=long_duration
        )

    def forward(self, waveform_short, waveform_long, use_and_rule=True):
        """
        Args:
            waveform_short: 5秒音频 (batch, 5 * sample_rate)
            waveform_long: 10秒音频 (batch, 10 * sample_rate)
            use_and_rule: 是否使用 AND 规则

        Returns:
            output: (batch, num_classes)
        """
        # 短片段预测
        output_short = self.short_model(waveform_short)  # (batch, num_classes)
        prob_short = torch.sigmoid(output_short)

        # 长片段预测
        output_long = self.long_model(waveform_long)  # (batch, num_classes)
        prob_long = torch.sigmoid(output_long)

        if use_and_rule:
            # AND 规则：两者都为正才认为存在
            prob_final = prob_short * prob_long
        else:
            # OR 规则：任一为正就认为存在
            prob_final = torch.clamp(prob_short + prob_long, 0, 1)

        return prob_final

# 使用示例
model = MultiScaleSEDModel(num_classes=152, short_duration=5, long_duration=10)

# 短片段和长片段
waveform_short = torch.randn(4, 5 * 32000)  # 4 samples, 5 seconds
waveform_long = torch.randn(4, 10 * 32000)   # 4 samples, 10 seconds

# 预测
with torch.no_grad():
    prob = model(waveform_short, waveform_long, use_and_rule=True)
print(prob.shape)  # (4, 152)
```

#### TTA（Test Time Augmentation）
```python
import torch
import numpy as np

def predict_with_tta(model, audio_path, window_size=5, tta_shifts=[0, 1, 2],
                     sample_rate=32000, device='cuda'):
    """
    使用 TTA 进行推理

    Args:
        model: 训练好的模型
        audio_path: 音频文件路径
        window_size: 窗口大小（秒）
        tta_shifts: TTA 偏移量（秒）
        sample_rate: 采样率
        device: 设备

    Returns:
        predictions: (num_windows, num_classes) TTA 平均后的预测
    """
    model.eval()

    # 加载音频
    waveform, sr = torchaudio.load(audio_path)
    if sr != sample_rate:
        resampler = torchaudio.transforms.Resample(sr, sample_rate)
        waveform = resampler(waveform)

    waveform = waveform.mean(dim=0, keepdim=True)  # 单声道

    window_samples = int(window_size * sample_rate)

    # 存储所有 TTA 预测
    all_tta_predictions = []

    for shift in tta_shifts:
        shift_samples = int(shift * sample_rate)

        # 计算起始位置
        start_positions = list(range(shift_samples, waveform.shape[1] - window_samples + 1,
                                    int(window_size * sample_rate)))

        predictions = []

        with torch.no_grad():
            for start in start_positions:
                end = start + window_samples
                window = waveform[:, start:end].to(device)

                # 预测
                logits = model(window)
                probs = torch.sigmoid(logits).cpu().numpy()
                predictions.append(probs[0])

        predictions = np.array(predictions)
        all_tta_predictions.append(predictions)

    # TTA 平均
    all_tta_predictions = np.array(all_tta_predictions)  # (num_shifts, num_windows, num_classes)

    # 对齐并平均
    avg_predictions = np.mean(all_tta_predictions, axis=0)

    return avg_predictions

# 使用示例
model = SEDModel(num_classes=152)
model = model.to(device)
model.load_state_dict(torch.load('best_model.pth'))

audio_path = 'test_soundscape.wav'
predictions = predict_with_tta(
    model, audio_path, window_size=5, tta_shifts=[0, 1, 2], device=device
)

# 二值化
threshold = 0.5
binary_pred = (predictions > threshold).astype(int)
```

#### AND 规则后处理
```python
import numpy as np

def and_rule_post_process(short_pred, long_pred, threshold=0.5):
    """
    AND 规则后处理

    Args:
        short_pred: 短片段预测 (num_windows_short, num_classes)
        long_pred: 长片段预测 (num_windows_long, num_classes)
        threshold: 二值化阈值

    Returns:
        final_pred: AND 规则后的预测 (num_windows_short, num_classes)
    """
    # 二值化
    binary_short = (short_pred > threshold).astype(int)
    binary_long = (long_pred > threshold).astype(int)

    # 长片段预测需要对应到短片段的时间位置
    # 假设长片段是短片段的两倍长度
    scale_factor = len(short_pred) / len(long_pred)

    final_pred = np.zeros_like(binary_short)

    for i in range(len(short_pred)):
        # 找到对应的长片段索引
        long_idx = int(i / scale_factor)

        if long_idx < len(binary_long):
            # AND 规则：两者都为 1 才认为存在
            final_pred[i] = binary_short[i] & binary_long[long_idx]
        else:
            # 没有对应的长片段预测，使用短片段预测
            final_pred[i] = binary_short[i]

    return final_pred

# 使用示例
# 短片段预测（5秒窗口）
short_pred = np.random.rand(100, 152)  # 100 个窗口，152 个类别

# 长片段预测（10秒窗口）
long_pred = np.random.rand(50, 152)  # 50 个窗口

# 应用 AND 规则
final_pred = and_rule_post_process(short_pred, long_pred, threshold=0.5)
```

#### 模型集成
```python
import torch
import numpy as np

class EnsembleModel:
    """
    模型集成类
    """
    def __init__(self, models, weights=None, device='cuda'):
        """
        Args:
            models: 模型列表
            weights: 模型权重（可选），默认平均
            device: 设备
        """
        self.models = models
        self.device = device

        if weights is None:
            # 默认等权重
            self.weights = [1.0 / len(models)] * len(models)
        else:
            # 归一化权重
            total = sum(weights)
            self.weights = [w / total for w in weights]

        # 将模型移到设备并设置为评估模式
        for model in self.models:
            model.to(device)
            model.eval()

    def predict(self, waveform):
        """
        集成预测

        Args:
            waveform: 输入音频 (batch, time_samples)

        Returns:
            ensemble_pred: 集成后的预测 (batch, num_classes)
        """
        all_predictions = []

        with torch.no_grad():
            for model in self.models:
                logits = model(waveform)
                probs = torch.sigmoid(logits).cpu().numpy()
                all_predictions.append(probs)

        all_predictions = np.array(all_predictions)  # (num_models, batch, num_classes)

        # 加权平均
        ensemble_pred = np.zeros_like(all_predictions[0])
        for i, pred in enumerate(all_predictions):
            ensemble_pred += self.weights[i] * pred

        return ensemble_pred

    def predict_from_files(self, model_paths, ModelClass, model_kwargs, waveform):
        """
        从文件加载模型并预测

        Args:
            model_paths: 模型文件路径列表
            ModelClass: 模型类
            model_kwargs: 模型初始化参数
            waveform: 输入音频

        Returns:
            ensemble_pred: 集成后的预测
        """
        all_predictions = []

        for path in model_paths:
            # 加载模型
            model = ModelClass(**model_kwargs)
            model.load_state_dict(torch.load(path))
            model.to(self.device)
            model.eval()

            # 预测
            with torch.no_grad():
                logits = model(waveform)
                probs = torch.sigmoid(logits).cpu().numpy()
                all_predictions.append(probs)

        all_predictions = np.array(all_predictions)

        # 加权平均
        ensemble_pred = np.zeros_like(all_predictions[0])
        for i, pred in enumerate(all_predictions):
            ensemble_pred += self.weights[i] * pred

        return ensemble_pred

# 使用示例
# 假设有 7 个模型
models = [
    SEDModel(num_classes=152, backbone='resnet50'),
    SEDModel(num_classes=152, backbone='resnest50'),
    SEDModel(num_classes=152, backbone='efficientnet_b0'),
    # ... 更多模型
]

# 加载权重
for i, model in enumerate(models):
    model.load_state_dict(torch.load(f'model_{i}.pth'))

# 创建集成
ensemble = EnsembleModel(models, weights=None, device=device)

# 预测
waveform = torch.randn(4, 5 * 32000).to(device)
predictions = ensemble.predict(waveform)
print(predictions.shape)  # (4, 152)
```

#### BirdNet/Perch 模型使用
```python
"""
BirdNet 和 Perch 是预训练的鸟类音频分类模型

使用前需要：
1. 安装 birdnetlib 或 perch 库
2. 下载预训练权重

这里提供一个简化接口示例
"""

class BirdNetModel(nn.Module):
    """
    BirdNet 模型包装器

    实际使用时需要从官方仓库获取模型
    参考: https://github.com/BirdVox/birdnet-library
    """
    def __init__(self, num_classes=152, pretrained_path=None):
        super().__init__()

        # 这里应该是 BirdNet 的实际架构
        # 简化版本：使用 ResNet50
        import torchvision.models as models
        self.backbone = models.resnet50(pretrained=True)

        # 修改第一层接受 mel-spectrogram
        self.backbone.conv1 = nn.Conv2d(
            1, 64, kernel_size=7, stride=2, padding=3, bias=False
        )

        feature_dim = 2048

        # 分类头
        self.classifier = nn.Sequential(
            nn.Dropout(0.5),
            nn.Linear(feature_dim, num_classes)
        )

        # 加载预训练权重
        if pretrained_path is not None:
            self.load_pretrained(pretrained_path)

    def load_pretrained(self, path):
        """加载预训练权重"""
        state_dict = torch.load(path, map_location='cpu')

        # 过滤不兼容的键
        model_state = self.state_dict()
        pretrained_state = {
            k: v for k, v in state_dict.items()
            if k in model_state and v.shape == model_state[k].shape
        }

        model_state.update(pretrained_state)
        self.load_state_dict(model_state)
        print(f"Loaded pretrained weights from {path}")

    def forward(self, mel_spec):
        """
        Args:
            mel_spec: (batch, 1, mel_bins, time_frames)

        Returns:
            logits: (batch, num_classes)
        """
        features = self.backbone(mel_spec)
        logits = self.classifier(features)
        return logits

# 使用示例（需要实际的预训练权重）
# model = BirdNetModel(num_classes=152, pretrained_path='birdnet.pth')
# model.eval()
# with torch.no_grad():
#     logits = model(mel_spec)
#     probs = torch.sigmoid(logits)
```

### 最佳实践

1. **多尺度策略**：
   - 短片段（5秒）用于精确分类
   - 长片段（10-15秒）提高召回率
   - AND 规则减少误报（两个都为正才认为存在）
   - OR 规则提高召回（任一为正就认为存在）

2. **SED 框架**：
   - Framewise 输出提供时间分辨率
   - Max pooling over time 聚合
   - 注意力权重加权

3. **模型集成**：
   - 10-20 个模型集成是常态
   - 不同架构（ResNet, ResNeSt, EfficientNet）
   - 不同训练配置（fold, seed, 数据增强）
   - 加权平均或投票

4. **预训练模型利用**：
   - BirdNet：强大的鸟类分类预训练模型
   - Perch：轻量级版本（BirdNET-lite）
   - 迁移学习显著提升性能
   - 在目标任务上微调

5. **外部数据**：
   - BirdCLEF 2021 数据
   - 其他鸟类音频数据集
   - 预训练模型在大规模数据上训练

6. **TTA（Test Time Augmentation）**：
   - 时间偏移（1-2秒）
   - 多个预测平均
   - 提高稳定性

7. **后处理**：
   - 时间平滑
   - 最小持续时间过滤
   - 类别特定阈值
   - AND 规则结合短长片段

8. **常见陷阱**：
   - 忽视短片段和长片段的互补性
   - 过度依赖单一模型或架构
   - 集成权重未优化
   - 忘记使用 TTA
   - AND/OR 规则选择不当

---

## Rainforest Connection Species Audio Detection 2021

**竞赛背景：**
- **主办方**：Rainforest Connection (RFCx)
- **目标**：检测热带雨林录音中的鸟类和蛙类叫声（多标签音频检测）
- **应用场景**：生物多样性监测，生态系统保护，濒危物种追踪
- **数据集规模**：
  - 训练音频：约 2,000 段标注录音
  - 测试音频：约 200 段连续录音（soundscape）
  - 物种数量：24 种鸟类和蛙类
  - 采样率：48 kHz
- **评估指标**：LWLRAP (Label-Weighted Label-Ranking Average Precision)
- **最终排名**：
  - 1st Place: watercooled
  - 7th Place: Beluga & Peter
  - 11th Place: cpmp
  - 13th Place: Ryan Epp
  - 总参赛队伍：约 2,200+ 支

### 前排方案详细技术分析

#### 1st Place - Image Classification Approach (watercooled)

核心技巧：
- **Mel-Spectrogram as Images**：将 Mel 频谱视为图像
- **Pretrained Image Models**：使用预训练图像分类模型
- **Ensemble**：多模型集成
- **Temporal Pooling**：时间池化策略
- **Data Augmentation**：图像和音频增强
- **Post-processing**：后处理优化

实现细节：
- **模型架构**：
  - ResNet50/ResNeSt50（ImageNet 预训练）
  - EfficientNet-B3
  - 修改第一层接受单通道输入（Mel-spectrogram）
- **特征提取**：
  - Mel-spectrogram（128 Mel bins）
  - 对数幅度压缩
  - 时间维度：5 秒窗口
- **集成方法**：
  - 多个模型集成
  - 不同 checkpoint
  - 加权平均
- **后处理**：
  - 时间平滑
  - 阈值优化
  - 最小持续时间过滤

#### 7th Place - Strong Baseline with Ensemble (Beluga & Peter)

核心技巧：
- **ResNeSt50 Architecture**：ResNeSt-50 主干网络
- **Mel-Spectrogram Features**：Mel 频谱特征
- **5-fold Cross-Validation**：5 折交叉验证
- **Model Ensemble**：模型集成
- **Strong Data Augmentation**：强数据增强

实现细节：
- **模型选择**：
  - ResNeSt50（预训练）
  - EfficientNet-B3
  - DenseNet-121
- **增强策略**：
  - SpecAugment
  - Mixup
  - 背景噪声
  - 时间遮罩/频率遮罩

#### 11th Place - The 0.931 Magic Explained (cpmp)

核心技巧：
- **Image Classification Approach**：图像分类方法
- **High-Performance Architecture**：高性能架构
- **Optimized Preprocessing**：优化的预处理
- **LWLRAP-specific Optimization**：针对 LWLRAP 指标优化

实现细节：
- **关键发现**：
  - 优化的 Mel-spectrogram 参数
  - 特定的数据增强组合
  - 后处理技巧达到 0.931 分数

#### 13th Place - Mean Co-Teachers and Noisy Students (Ryan Epp)

核心技巧：
- **Mean Teacher**：均值教师模型
- **Co-Teaching**：协同教学
- **Noisy Student**：噪声学生策略
- **Semi-Supervised Learning**：半监督学习
- **Pseudo-labeling**：伪标签

实现细节：
- **半监督策略**：
  - 使用未标注数据
  - 伪标签迭代优化
  - Mean Teacher 平滑预测

### 关键技术点

1. **Mel-Spectrogram 作为图像**：
   - 将音频转换为 Mel-spectrogram
   - 使用图像分类模型（ResNet, EfficientNet）
   - 修改第一层接受单通道输入

2. **LWLRAP 指标**：
   - Label-Weighted Label-Ranking Average Precision
   - 需要优化预测的排序
   - 类别权重不平衡

3. **数据增强**：
   - SpecAugment（时间/频率遮罩）
   - Mixup
   - 背景噪声

4. **模型集成**：
   - 多架构集成
   - 不同 checkpoint
   - 加权平均

5. **后处理**：
   - 时间平滑
   - 阈值优化
   - 最小持续时间过滤

---

## AMP®-Parkinson's Disease Progression Prediction 2023

**注意**：此比赛主要使用蛋白质/多肽测量数据，属于**表格数据时序回归**任务，非传统的一维信号处理（如音频、EEG 等）。

**竞赛背景：**
- **主办方**：AMP (Accelerating Medicines Partnership)
- **目标**：预测帕金森病患者的 MDS-UPDRS 评分变化（时序回归）
- **应用场景**：帕金森病进展监测，药物效果评估
- **数据集规模**：
  - 患者数量：约 1,000+ 患者
  - 蛋白质/多肽测量：数百种蛋白质特征
  - 时间点：多个月份的访视数据
  - 访视记录：蛋白丰度数据 + 蛋白肽数据
- **评估指标**：SMAPE (Symmetric Mean Absolute Percentage Error)
- **最终排名**：
  - 1st Place: Connecting Dotts
  - 2nd Place: No Luck All Skill
  - 3rd Place: Hajime Tamura
  - 总参赛队伍：约 2,500+ 支

### 前排方案详细技术分析

#### 1st Place - Feature Engineering + Gradient Boosting (Connecting Dotts)

核心技巧：
- **Protein/Peptide Feature Engineering**：蛋白质/多肽特征工程
- **Gradient Boosting Models**：梯度提升模型
- **Ensemble**：多模型集成
- **Cross-Validation**：交叉验证
- **Clincal Knowledge Integration**：临床知识整合

实现细节：
- **特征工程**：
  - 蛋白质丰度统计特征
  - 时间变化特征
  - 蛋白质-蛋白质交互特征
  - 临床协变量整合
- **模型选择**：
  - XGBoost/LightGBM
  - CatBoost
  - 多个模型集成
- **训练策略**：
  - 5-fold 交叉验证
  - 特征选择
  - 超参数优化

#### 2nd Place - Strong Feature Engineering (No Luck All Skill)

核心技巧：
- **Advanced Feature Engineering**：高级特征工程
- **Protein Network Features**：蛋白质网络特征
- **Time-Series Features**：时序特征
- **Model Ensemble**：模型集成

实现细节：
- **特征类型**：
  - 蛋白质丰度基线
  - 时间变化趋势
  - 蛋白质-蛋白质相关性
  - 临床协变量

#### 3rd Place - Robust Modeling Approach (Hajime Tamura)

核心技巧：
- **Robust Feature Selection**：稳健特征选择
- **Gradient Boosting**：梯度提升
- **Ensemble Strategy**：集成策略

实现细节：
- **特征选择**：
  - 基于重要性的特征选择
  - 多重共线性处理
- **模型**：
  - XGBoost/LightGBM
  - 简单平均集成

### 关键技术点

1. **蛋白质数据特征**：
   - 蛋白质丰度（protein abundance）
   - 肽段数据（peptide data）
   - 时间序列变化
   - 临床协变量

2. **特征工程**：
   - 基线特征
   - 时间变化特征
   - 交互特征
   - 统计特征

3. **模型选择**：
   - Gradient Boosting (XGBoost, LightGBM, CatBoost)
   - 集成多个模型

4. **评估指标**：
   - SMAPE (Symmetric MAPE)
   - 需要处理零值和异常值

5. **验证策略**：
   - 按患者划分的交叉验证
   - 时间序列分割
   - 防止数据泄露
