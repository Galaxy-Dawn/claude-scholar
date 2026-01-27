# BirdCLEF 2024
> Last updated: 2026-01-23
> Source count: 1
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
