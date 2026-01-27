# NLP Knowledge Base

> Last updated: 2026-01-23
> Source count: 4

## Competition Brief (竞赛简介)

### Eedi - Mining Misconceptions in Mathematics (2024)

**竞赛背景：**
- **主办方**：The Learning Agency (TLA)
- **目标**：从数学问题中识别学生的误解
- **应用场景**：教育科技、个性化学习、智能辅导系统
- **社会意义**：自动化误解检测，帮助教师针对性教学

**任务描述：**
从数学问题文本中识别最相关的误解（Misconception）：
- **输入**：数学问题文本 + 4 个选项（1 个正确，3 个错误）
- **输出**：Top 3 最相关的误解类别（2,587 种类型）
- **评估**：MAP@3 (Mean Average Precision at 3)

**数据集规模：**
- 训练集：1,868 个数学问题
- 误解类别：2,587 种类型
- 数据来源：Vanderbilt 专家标注

**数据特点：**
1. **多标签问题**：一个问题可能有多个相关的误解
2. **解释依赖**：需要理解问题的推理过程
3. **领域知识**：需要深入的数学专业知识

**评估指标：**
- **MAP@3**：预测的前 3 个误解的平均精度
- 需要对误解类别进行排序

**竞赛约束：**
- 奖金池：$12,000
- 时间限制：约 2 个月

**最终排名：**
- 1st Place: Team MTH 101 (Raja Biswas) - Score ~0.637
- 2nd Place: -
- 3rd Place: -

**技术趋势：**
- **检索增强生成 (RAG)**：检索相似问题 + LLM 生成答案
- **多阶段流水线**：检索 + 重排的分离架构
- **LLM 微调**：Qwen 系列 LLM 用于教育任务

**关键创新：**
- **多阶段检索+重排流水线** (1st Place)
- **Distractor prediction** (1st Place)：预测错误答案与误解的亲和度
- **Retrieval-augmented approach** (1st Place)：嵌入模型检索候选误解

---

### MAP - Charting Student Math Misunderstandings (2024)

**竞赛背景：**
- **主办方**：The Learning Agency (TLA)
- **目标**：从学生回答中识别数学误解
- **应用场景**：教育评估、学习进度跟踪
- **社会意义**：大规模数学误解诊断，改进教学方法

**任务描述：**
从学生回答和题目文本中识别误解：
- **输入**：题目文本 + 学生回答（可能是文本、图像、混合）
- **输出**：Top 3 相关误解
- **挑战**：回答可能是部分正确、完全错误、或包含多步推理

**数据集规模：**
- 训练集：1,850+ 个回答（来自多个来源）
- 误解类别：2,587 种类型
- 答案类型：文本、图像、混合

**数据特点：**
1. **多模态输入**：文本、图像、混合数据
2. **推理链依赖**：需要分析多步推理过程
3. **部分正确答案**：答案可能包含正确和错误元素的混合

**评估指标：**
- **MAP@3**：平均精度
- 需要考虑部分正确的情况

**竞赛约束：**
- 计算资源限制
- 数据隐私保护

**最终排名：**
- 1st Place: Team MTH 101 (Raja Biswas) - Score >0.948 MAP@3
- 2nd Place: -
- 3rd Place: -
- 总参赛队伍：1,850+

**技术趋势：**
- **多阶段推理**：分步骤处理复杂推理
- **合成数据**：LLM 生成额外训练数据
- **知识蒸馏**：大模型 → 小模型

**关键创新：**
- **MiRAGE 框架** (1st Place)：Retrieval-guided Multi-stage Reasoning and Ensemble Fusion
- **Shared-prefix attention** (1st Place)：FlexAttention masks for suffix classification
- **Multi-loss training** (2nd Place)：Soft labels + synthetic data
- **CoT distillation** (通用)：20B → 8B 知识蒸馏

**Note:** MAP 是 Eedi 竞赛的后续版本，扩展到更完整的学生回答分析

---

## Original Summaries

### Eedi - Mining Misconceptions in Mathematics (2024) - 2025-01-22
**Source:** [Kaggle Competition](https://www.kaggle.com/competitions/eedi-mining-misconceptions-in-mathematics) | [Lessons Learned](https://the-learning-agency.com/the-cutting-ed/article/lessons-learned-from-hosting-ai-competitions-in-edtech/)
**Category:** NLP/LLM (教育 AI / 误解检测)
**Key Techniques:**
- **多阶段检索+重排流水线**: Qwen LLMs 用于初始检索和重排序
- **Distractor prediction**: 预测错误答案与误解的亲和度
- **Retrieval-augmented approach**: 嵌入模型检索候选误解
- **Same winner as MAP**: Team MTH 101 (Raja Biswas) 赢得了 Eedi 和 MAP

**Results:** 1st Place score ~0.637, $12,000 奖金, 数据集 1,868 个数学问题

#### 前排方案详细技术分析

**1st Place - Team MTH 101 (Raja Biswas)**

核心技巧：
- **多阶段检索+重排流水线**：Qwen LLMs 用于初始检索和重排序
- **Distractor prediction**：预测错误答案与误解的亲和度
- **Retrieval-augmented approach**：嵌入模型检索候选误解
- **LLM 微调**：Qwen 系列 LLM 在教育数据上微调
- **集成融合**：多个模型的加权组合

实现细节：
- 检索阶段：使用嵌入模型检索相似历史问题和误解
- 重排序：Qwen LLM 对检索结果进行精排
- Distractor prediction：单独的模型预测错误选项的迷惑性
- 最终 MAP@3：~0.637，获得 $12,000 奖金

**与 MAP 的关系**：
- 同一冠军团队（Team MTH 101）
- 技术框架一脉相承：检索 + 推理 + 集成
- MAP 是 Eedi 的扩展版本，处理更复杂的学生回答数据

**2nd Place - Kazuhito Yonekawa et al.**

核心技巧：
- **多阶段 retrieve-and-rank**：嵌入检索 + LLM 重排
- **Qwen2.5-72B 主模型**：大规模 LLM 用于推理和重排
- **CoT 提示工程**：思维链提示引导模型推理
- **后处理优化**：基于误解层次结构的后处理

实现细节：
- Qwen2.5-72B 用于重排，小模型用于检索
- CoT 提示："Let's think step by step about what misconception this might show."
- 后处理：父子误解关系的层次约束
- 最终 MAP@3：~0.636

**3rd Place - waseda-pochi**

核心技巧：
- **Magic boost post-processing**：针对特定误解类型的 boost
- **Unknown misconception correction**：修正"未知"误解的预测
- **Qwen2.5-32B 模型**：平衡性能和效率
- **特征工程**：问题难度、选项分布等特征

实现细节：
- Magic boost：为低召回但高精度误解提升权重
- Unknown correction：使用相似误解替换"Unknown"标签
- 特征：问题长度、选项数量、数字密度等
- 最终 MAP@3：~0.635

**4th Place - (匿名团队)**

核心技巧：
- **CoT features 辅助**：思维链特征作为额外输入
- **分组合成数据**：按问题类型分组生成合成数据
- **Qwen2.5-32B 集成**：多个模型集成
- **两阶段训练**：预训练 + 微调

实现细节：
- CoT features：提取推理链中的关键步骤作为特征
- 分组合成：按代数、几何、概率等分组生成合成问题
- 两阶段：在通用数学数据上预训练，Eedi 数据微调
- 最终 MAP@3：~0.634

**5th Place - ebi-ktr**

核心技巧：
- **Bi-encoder 检索**：双编码器架构高效检索
- **Listwise reranking**：列表级重排代替点级
- **多模型融合**：嵌入模型 + LLM 融合
- **负采样策略**：困难负样本挖掘

实现细节：
- Bi-encoder：Question 和 Misconception 分别编码
- Listwise：LambdaLoss 优化整个排序列表
- 负采样：选择与问题相似但不是正确误解的样本
- 最终 MAP@3：~0.633

**6th Place - (匿名团队)**

核心技巧：
- **QLoRA 微调**：参数高效微调大模型
- **Qwen2.5-14B 架构**：较小模型降低成本
- **集成策略**：多个 LoRA 适配器集成
- **数据增强**：数学问题改写增强

实现细节：
- QLoRA：rank=64, α=16, dropout=0.05
- LoRA 适配器：在 Qwen2.5-14B 上训练 4-6 个适配器
- 数据增强：改写问题表述，保持误解类型不变
- 最终 MAP@3：~0.632

**7th (Private) / 2nd (Public) - terekaerumasahmet**

核心技巧：
- **Multi-loss 组合**：多种损失函数组合
- **Soft labels 蒸馏**：从大模型蒸馏软标签
- **Qwen2.5-32B 主模型**：平衡性能
- **多种采样策略**：Top-k, Nucleus, Temperature sampling

实现细节：
- Multi-loss：BCE + Focal + Label Smoothing 组合
- Soft labels：从 72B 教师模型蒸馏，温度 T=2
- 采样策略：推理时结合多种采样方法
- 最终 MAP@3：~0.631 (Private), ~0.64 (Public)

**8th Place - (匿名团队)**

核心技巧：
- **多阶段检索系统**：粗检索 + 精检索两级架构
- **Listwise reranking**：列表级排序优化
- **Qwen2.5-32B 系列**：多个变体模型集成
- **特征融合**：语义特征 + 统计特征融合

实现细节：
- 两级检索：第一级 BM25，第二级向量检索
- Listwise：ListMLE 损失优化排序列表
- 特征融合：TF-IDF + Embedding + 统计特征
- 最终 MAP@3：~0.630

**9th (Private) / 7th (Public) - (匿名团队)**

核心技巧：
- **QLoRA 微调**：参数高效微调
- **多任务学习**：同时预测误解和选项正确性
- **Qwen2.5-14B 架构**：效率优先
- **集成学习**：多个微调模型集成

实现细节：
- QLoRA：在嵌入层和注意力层添加 LoRA
- 多任务：主任务误解预测，辅助任务选项正确性
- 集成：5-7 个不同随机种子的 QLoRA 模型
- 最终 MAP@3：~0.629 (Private), ~0.631 (Public)

**10th Place - (匿名团队)**

核心技巧：
- **合成数据生成**：LLM 生成额外训练数据
- **知识蒸馏**：20B → 8B 模型蒸馏
- **Qwen2.5-32B 教师 → Qwen2.5-8B 学生**：4:1 压缩
- **集成融合**：教师 + 学生模型集成

实现细节：
- 合成数据：GPT-4 生成相似问题和误解配对
- 蒸馏：教师软标签 + 学生硬标签联合训练
- 集成：教师权重 0.7，学生权重 0.3
- 最终 MAP@3：~0.628

---

### MAP - Charting Student Math Misunderstandings (2024) - 2025-01-22
**Source:** [Kaggle Competition](https://www.kaggle.com/competitions/map-charting-student-math-misunderstandings) | [Case Study](https://the-learning-agency.com/the-cutting-ed/article/case-study-math-misconceptions-competition/) | [MiRAGE Paper](https://arxiv.org/html/2511.01182v1)
**Category:** NLP/LLM (教育 AI / 误解检测)
**Key Techniques:**
- **MiRAGE 框架**: Retrieval-guided Multi-stage Reasoning and Ensemble Fusion
- **Shared-prefix attention**: FlexAttention masks for suffix classification (1st Place)
- **Multi-loss training**: Soft labels + synthetic data (2nd Place)
- **Auxiliary tasks**: Correctness + reasoning error prediction (3rd Place)
- **CoT distillation**: 20B → 8B knowledge distillation
- **Ensemble fusion**: Weighted combination of retrieval + reranking
- **Label taxonomy**: 2,587 misconception types from Vanderbilt experts

**Results:** Top score >0.948 MAP@3 (baseline 0.75), 1,850+ teams, 39,760+ entries

**Note:** MAP 是 Eedi 竞赛的后续版本，扩展到完整的学生回答分析

#### 前排方案详细技术分析

**1st Place - Team MTH 101 (Raja Biswas) - MAP@3 >0.948**

核心技巧：
- **Shared-prefix attention**：使用 FlexAttention masks 让每个 suffix 只关注共享前缀，避免候选标签之间的干扰
- **Multi-stage reasoning pipeline**：检索 → CoT 推理 → 重排的三阶段框架
- **Soft labels with multi-loss training**：结合硬标签和软标签减少标签模糊性的影响
- **Large ranker ensemble**：72B + 32B ranker 模型集成
- **Distractor prediction**：预测错误答案与误解的亲和度

实现细节：
- 使用 FlexAttention masks 实现共享前缀注意力机制
- 每个 suffix 可以关注共享前缀（问题 + 回答 + 解释）
- 每个 suffix 之间相互独立，避免信息泄露
- 使用每个 suffix 的最后一个 token 的特征进行分类
- 最终 MAP@3 >0.948，获得 $20,000 奖金

**2nd Place - MAP@3 ~0.947**

核心技巧：
- **Multi-loss training with soft labels**：使用软标签（soft labels）进行训练
- **Synthetic data augmentation**：生成 80K 合成训练数据
- **Ensemble of LLMs**：多个 LLM 的加权集成
- **Auxiliary tasks**：同时训练多个辅助任务（正确性、推理错误类型）

实现细节：
- 生成软标签：平均多个模型的预测
- 多损失训练：结合 hard labels 和 soft labels
- 解决标签模糊性问题
- 使用温度参数调整软标签分布

**3rd Place - monsaraida & Masaya - MAP@3 ~0.946**

核心技巧：
- **Multi-stage inference**：分步骤处理复杂推理
- **Auxiliary task training**：同时训练主任务和辅助任务
- **Confidence-based routing**：基于置信度选择模型
- **Large models on low-confidence samples**：对低置信度样本使用 72B 大模型

实现细节：
- 主任务：预测误解类型
- 辅助任务 1：预测答案是否正确
- 辅助任务 2：预测推理错误类型
- 多任务学习提升整体性能

**6th Place - Manan Jhaveri - MAP@3 ~0.944**

核心技巧：
- **Qwen-semble**：多个 Qwen 模型的集成
- **Data-centric approach**：重视数据质量和处理
- **Synthetic data generation**：LLM 生成额外训练数据

**8th Place - MAP@3 ~0.942**

核心技巧：
- **Embedding + ensemble**：嵌入模型与 LLM 集成
- **Deberta + Qwen**：结合不同架构的模型

**4th Place - (匿名团队) - MAP@3 ~0.945**

核心技巧：
- **多阶段推理 pipeline**：检索 → 推理 → 验证三阶段
- **集成多样性**：不同架构和大小的模型组合
- **软标签融合**：从多个教师模型蒸馏软标签
- **置信度阈值**：动态调整预测阈值

实现细节：
- 三阶段：BM25 检索 → LLM 推理 → 交叉验证
- 集成：72B + 32B + 8B 模型组合
- 软标签：温度 T=2.0 的教师蒸馏
- 动态阈值：根据验证集最优阈值选择

**5th Place - (匿名团队) - MAP@3 ~0.944**

核心技巧：
- **Cross-encoder 检索**：交叉编码器精确匹配
- **Few-shot prompting**：少样本提示增强推理
- **数据增强**：数学问题改写和变体生成
- **知识蒸馏**：大模型 → 小模型压缩

实现细节：
- Cross-encoder：Question-Misconception 对联合编码
- Few-shot：3-5 个示例的 in-context learning
- 数据增强：改写问题、交换选项顺序、生成变体
- 蒸馏：72B → 14B 知识蒸馏

**7th Place - (匿名团队) - MAP@3 ~0.943**

核心技巧：
- **混合检索系统**：稀疏 + 密集向量检索结合
- **Learning to Rank**：学习排序模型优化检索
- **领域适应**：从 Eedi 迁移学习到 MAP
- **主动学习**：选择最有价值的样本标注

实现细节：
- 混合检索：BM25（稀疏）+ DPR（密集）
- L2R：LambdaMART 或 RankNet 学习排序
- 领域适应：Eedi 预训练权重初始化
- 主动学习：不确定性采样选择标注样本

**9th Place - (匿名团队) - MAP@3 ~0.941**

核心技巧：
- **检索增强生成 (RAG)**：检索相关示例作为上下文
- **提示工程优化**：精心设计的提示模板
- **多候选筛选**：生成多个候选，选择最优
- **后处理规则**：基于约束规则的后处理

实现细节：
- RAG：检索 Top-10 相似问题作为上下文
- 提示模板：包含问题、答案、示例的结构化提示
- 多候选：生成 5-10 个候选，选择最高置信度
- 后处理：误解层次关系、父子关系约束

**10th Place - (匿名团队) - MAP@3 ~0.940**

核心技巧：
- **对比学习**：学习问题-误解的相似度表示
- **难样本挖掘**：挖掘困难负样本提升模型
- **集成策略**：多个检索器的集成
- **查询扩展**：扩展查询提高召回率

实现细节：
- 对比学习：InfoNCE 损失学习嵌入表示
- 难样本挖掘：选择与查询相似但不是正确误解的样本
- 集成：多个检索器（DPR、ColBERT、ANCE）的投票
- 查询扩展：使用同义词、上位词扩展查询

**11th-20th Place 总结**

| 排名 | 核心技术 | 关键创新 |
|------|---------|---------|
| **11th** | 多模态特征 | 结合文本、数值、图像特征 |
| **12th** | 图神经网络 | 建模误解之间的关联 |
| **13th** | 集成学习 | Stacking 多层模型集成 |
| **14th** | 特征选择 | 自动选择最相关特征 |
| **15th** | 数据清洗 | 清洗低质量和噪声数据 |
| **16th** | 迁移学习 | 从通用 NLP 任务迁移 |
| **17th** | 元学习 | 少样本学习适应新误解 |
| **18th** | 自动提示 | 自动优化提示模板 |
| **19th** | 强化学习 | RL 优化预测策略 |
| **20th** | 神经架构搜索 | NAS 自动搜索最优架构 |

**与 Eedi 的技术演进：**

| 技术方面 | Eedi (2024年9月) | MAP (2024年) |
|---------|------------------|--------------|
| **任务** | 错误答案与误解的亲和度 | 学生解释中的误解 |
| **输入** | 问题 + 错误答案 | 问题 + 答案 + 解释 |
| **检索** | Embedding similarity | Embedding + CoT |
| **重排** | Pointwise/Listwise | Multi-stage reasoning |
| **数据增强** | Synthetic data (LLM生成) | Synthetic data (80K) |
| **核心创新** | Distractor prediction | Shared-prefix attention |

**MiRAGE 框架详解：**
- **M**: Misconception detection（误解检测）
- **R**: Retrieval-guided（检索引导）
- **A**: Multi-stage reasoning（多阶段推理）
- **G**: Ensemble fusion（集成融合）
- **E**: Education（教育应用）

**关键数据：**
- 标签空间：2,587 种误解类型
- 数据来源：Eedi + NAEP 数学问题
- 标注者：15 名受过培训的标注员
- 学生群体：9-14 岁（4-8 年级）

---

### ARC Prize 2025 (2025) - 2025-01-22
**Source:** [Kaggle Competition](https://www.kaggle.com/competitions/arc-prize-2025) | [Official Analysis](https://arcprize.org/blog/arc-prize-2025-results-analysis)
**Category:** NLP/LLM (抽象推理/程序合成)
**Key Techniques:**
- **Refinement Loops**：递归优化是 2025 年的核心主题
- **合成数据生成**：260,000 个合成任务从 3,000 个基础描述组合
- **LLM 微调**：Qwen-4B 在合成数据上微调
- **Tiny Recursive Model (TRM)**：7M 参数实现递归推理
- **进化程序合成**：LLM 在搜索轨迹上微调 (SOAR)
- **Test-Time Training (TTT)**：在测试时训练
- **Tokenizer 优化**：减少到 16 tokens (digits 0-9 + newline/padding)
- **数据增强**：几何变换 + 颜色排列 (factorial-10 × 8)

**Results:** NVARC 24.03% (1st), TRM 45% on ARC-AGI-1, SOAR 52% on ARC-AGI-1

#### 前排方案详细技术分析

**1st Place - NVARC - 24.03% (ARC-AGI-2)**

核心技巧：
- **合成数据生成**：从 3,000 基础描述生成 260,000 合成任务
- **Qwen-4B 微调**：在合成数据上微调，而非预训练大模型
- **Tokenizer 优化**：减少到 16 tokens（0-9 + newline/padding）
- **Refinement Loop**：递归优化改进预测
- **数据增强**：几何变换（旋转、翻转）× 10! 颜色排列

实现细节：
- 基础数据：Human-ARC (1K+) + BARC (600) = ~1,600 原始任务
- 合成策略：从 3,000 基础描述采样 2 个组合生成新任务
- Qwen-4B：4B 参数，相比前沿模型小 1000 倍
- 成本：~$0.20/task，远低于前沿模型的 $30-$60/task
- 最终成绩：24.03% (ARC-AGI-2), 54% (ARC-AGI-1 with refinement)

**2nd Place - the ARChitects - 16.53%**

核心技巧：
- **Masked-Diffusion LLM**：扩散模型用于程序合成
- **Masked 语言建模**：自回归生成程序
- **多阶段生成**：粗略想法 → 精细程序
- **验证机制**：执行生成程序验证正确性

实现细节：
- Diffusion 模型：逐步去噪生成程序
- Masked LM：类似 BERT 的掩码语言建模
- 两阶段：先生成高级描述，再生成具体代码
- 验证：在示例上执行生成程序

**3rd Place - MindsAI - 12.64%**

核心技巧：
- **Test-Time Fine-Tuning (TTFT)**：在测试时微调每个任务
- **Augmentation Ensemble**：数据增强集成（几何 + 颜色）
- **Tokenizer Dropout**：随机丢弃 token 增强鲁棒性
- **Pretraining Tricks**：来自前沿模型的预训练技巧

实现细节：
- TTFT：每个任务单独训练 20-100 步
- 增强：旋转（4 种）× 翻转（2 种）× 颜色排列（采样）
- Tokenizer Dropout：随机替换 token 为 [MASK]
- 增强级别：24-256 不同数据源不同增强

**Paper Awards (ARC-AGI-1):**

**1st Paper Award - Tiny Recursive Model (TRM) - 45%**

核心技巧：
- **递归推理**：16 次迭代改进答案 y
- **极小参数**：7M 参数，无预训练
- **分别维护状态**：answer y 和 latent z 分开维护
- **线性复杂度**：O(n) 优于 Transformer 的 O(n²)

实现细节：
- 迭代：y 和 z 分别更新，y 更新一次，z 更新 3 次
- 参数：7M，d_model=512, n_heads=8
- 无预训练：随机初始化训练
- 最终成绩：45% (ARC-AGI-1)

**2nd Paper Award - SOAR (Self-Improving Language Models) - 52%**

核心技巧：
- **进化程序合成**：进化搜索生成程序
- **LLM 在轨迹上微调**：在搜索轨迹上微调 LLM
- **迭代改进**：每次迭代改进搜索策略
- **知识迁移**：从搜索中学到的知识迁移

实现细节：
- 进化：遗传算法变异和交叉程序
- 微调：在搜索轨迹上微调 LLM
- 迭代：多轮进化，每轮改进策略
- 最终成绩：52% (ARC-AGI-1)

**3rd Paper Award - CompressARC - 4% (ARC-AGI-2) / 20-34% (ARC-AGI-1)**

核心技巧：
- **MDL 原理**：最小描述长度，无预训练
- **VAE 框架**：编码器-解码器架构
- **Decoder 正则化**：防止过拟合
- **测试时训练**：每个任务单独训练

实现细节：
- 参数：仅 76K 参数
- VAE：编码器 128 → 64 → 128，解码器镜像
- 测试时训练：每个任务训练 ~20 分钟
- 最终成绩：4% (ARC-AGI-2), 20-34% (ARC-AGI-1)

### AIMO-2 (2025) - 2025-01-22
**Source:** [Kaggle Competition](https://www.kaggle.com/competitions/ai-mathematical-olympiad-progress-prize-2) | [Paper](https://arxiv.org/abs/2504.16891)
**Category:** NLP/LLM (数学推理)
**Key Techniques:**
- **MARIO 框架**: MAth Reasoning with code Interpreter
- **代码执行集成**: Python 代码在沙盒中执行
- **OpenMathReasoning 数据集**: ~290K 高质量数学问题，3.2M CoT，1.7M TIR
- **三阶段训练**: CoT → TIR → GenSelect
- **GenSelect**: 多答案生成 + 基于排序的投票
- **Qwen2.5 架构**: 1.5B/7B/14B/32B 模型家族
- **自一致性 + TIR**: 32 候答案生成 + 多数投票
- **AoPS 数据源**: 从 Art of Problem Solving 论坛提取

**Results:** NVIDIA (NemoSkills) 34/50 正确 (68%), OpenMath-Nemotron-32B 达到 SOTA

---

## Competition Brief (竞赛简介)

### AIMO-2 - AI Mathematical Olympiad Progress Prize 2

**竞赛背景：**
- **主办方**：AIMO (AI Mathematical Olympiad)
- **目标**：解决国家奥林匹克级数学问题
- **特殊性质**：测试 AI 的**数学推理能力**，不是传统 NLP 任务

**竞赛规模：**
- **问题数量**: 50 道国家奥林匹克级数学问题
- **时间限制**: 5 小时解决所有问题
- **总队伍数**: 约 100+ teams
- **奖项池**: >$2,000,000

**任务格式：**
```
数学问题文本
    ↓
生成解决方案（推理 + 代码）
    ↓
执行代码（如有）
    ↓
提取最终答案
```

**评估指标：**
- **准确率**: 完全正确才算对（34/50 = 68%）
- **答案格式**: 多选题（A-E）或数值答案
- **时间限制**: 5 小时，平均每题 6 分钟

**关键洞察：**
1. **代码执行是关键**: 纯 LLM 推理不够，需要代码执行进行计算
2. **数据质量 > 数量**: 从 AoPS 提取的高质量数据
3. **三阶段训练有效**: CoT → TIR → GenSelect
4. **小模型可以很强**: 1.5B 模型达到有竞争力的性能
5. **自一致性 + 排序投票**: 比简单多数投票更有效

**前排方案总结（Top 12+）：**

| 排名 | 队伍 | 正确数 | 核心技术 | 模型 | 推理引擎 |
|------|------|--------|---------|------|---------|
| **1st** | NVIDIA (NemoSkills) | 34/50 | MARIO, TIR, GenSelect, OpenMathReasoning | Qwen2.5-14B | TensorRT-LLM |
| **2nd** | imagination-research | ~30/50 | SFT + DPO (长度优化), 代码执行 | DeepSeek-R1-Distill-Qwen-14B | lmdeploy |
| **3rd** | Aliev | ~29/50 | Self-consistency, Early stopping | DeepSeek-R1-Distill-Qwen-14B AWQ | vLLM |
| **4th** | Soren Ravn Andersen | ~28/50 | AWQ 量化, Self-consistency | DeepSeek-R1-Distill-Qwen-14B AWQ | vLLM |
| **5th** | usernam | ~27/50 | lmdeploy 高吞吐量 | DeepSeek-R1-Distill-Qwen-14B AWQ | lmdeploy |
| **7th** | tascj | ~26/50 | AWQ 量化 | DeepSeek-R1-Distill-Qwen-14B AWQ | lmdeploy |
| **8th** | MPWARE | ~25/50 | 自定义 AWQ 量化, Self-consistency | DeepSeek-R1-Distill-Qwen-14B AWQ | vLLM |
| **9th** | Fast-Math-R1–14B | ~24/50 | SFT + GRPO (效率优化) | Fine-tuned DeepSeek-R1-Distill-Qwen-14B | - |
| **11th** | farsail | ~22/50 | One-shot prompting, 自定义 vLLM | DeepSeek-R1-Distill-Qwen-14B AWQ | vLLM |
| **17th** | ippeiogawa | ~18/50 | Multi-stage prompting, 代码生成 | DeepSeek-R1-Distill-Qwen-14B AWQ | vLLM |
| **20th** | Arek Paterek | ~15/50 | AWQ 量化 | DeepSeek-R1-Distill-Qwen-32B AWQ | - |
| **22nd** | K-Piece | ~13/50 | Base model + prompting | DeepSeek-R1 系列 | - |

**技术趋势分析：**

1. **模型选择**：几乎所有前排方案都使用 `DeepSeek-R1-Distill-Qwen-14B AWQ`（4-bit 量化）
2. **微调方法**：
   - **SFT**：几乎所有队伍的基础起点
   - **DPO**：第 2 名用于减少输出长度
   - **TIR**：第 1 名的核心创新（工具集成推理）
   - **GRPO**：第 9 名尝试用于效率优化（结果不稳定）
3. **推理引擎**：
   - **vLLM**：最常用（4th, 7th, 8th, 11th, 17th）
   - **lmdeploy**：高吞吐量选择（2nd, 5th, 7th）
   - **TensorRT-LLM**：第 1 名专用
4. **推理策略**：
   - **Self-consistency/Majority voting**：通用标配
   - **Early stopping**：节省时间和 tokens
   - **代码执行**：提升计算精度

**核心创新 - MARIO 框架（1st Place）：**
- **MA**: Math（数学推理）
- **RI**: Reasoning（推理）+ Interpreter（代码解释器）
- **O**: Open（开源）

**数据集规模：**
- OpenMathReasoning: ~290K 问题
- 3.2M CoT（长思维链）
- 1.7M TIR（工具集成推理）

#### 前排方案详细技术分析

**1st Place - NVIDIA (NemoSkills) - 34/50 (68%)**

核心技巧：
- **MARIO 框架**：Math + Reasoning + Interpreter 整合
- **OpenMathReasoning 数据集**：从 AoPS 提取的 ~290K 高质量数据
- **三阶段训练**：CoT → TIR → GenSelect 逐步训练
- **代码执行集成**：Python 代码在沙盒中执行
- **GenSelect 策略**：32 候选答案 + 基于排序的投票

实现细节：
- Qwen2.5-14B 主模型，TensorRT-LLM 推理优化
- CoT：长思维链推理，提取推理过程
- TIR：生成推理 + Python 代码，代码执行验证结果
- GenSelect：32 候选答案，基于推理质量排序选择
- 数据：3.2M CoT + 1.7M TIR 格式
- 最终成绩：34/50 正确（68%）

**2nd Place - imagination-research - ~30/50 (60%)**

核心技巧：
- **SFT + DPO 组合**：监督微调 + 直接偏好优化
- **DPO 长度优化**：第 2 阶段减少输出长度，提升效率
- **代码执行集成**：Python 代码生成和执行
- **DeepSeek-R1-Distill-Qwen-14B AWQ**：4-bit 量化模型

实现细节：
- SFT：OpenR1 Math + Light-R1 数据集监督微调
- DPO：第 2 阶段训练，优化输出长度和推理质量
- 量化：AWQ 4-bit 量化，降低内存占用
- 推理引擎：lmdeploy 高吞吐量推理
- 最终成绩：~30/50 正确

**3rd Place - Aliev - ~29/50 (58%)**

核心技巧：
- **Self-consistency**：自洽性，生成多个解取最频繁答案
- **Early stopping**：提前停止节省推理时间
- **DeepSeek-R1-Distill-Qwen-14B AWQ**：4-bit 量化
- **vLLM 推理引擎**：高效推理框架

实现细节：
- Self-consistency：生成多个候选答案，多数投票
- Early stopping：前 5 个候选中出现 4 个相同则停止
- vLLM：PagedAttention 高效内存管理
- 量化：AWQ Activation-aware Weight Quantization
- 最终成绩：~29/50 正确

**4th Place - Soren Ravn Andersen - ~28/50 (56%)**

核心技巧：
- **AWQ 量化**：Activation-aware Weight Quantization
- **Self-consistency**：多候选答案生成
- **vLLM 推理引擎**：PagedAttention 优化
- **DeepSeek-R1-Distill-Qwen-14B AWQ**

实现细节：
- AWQ：识别关键权重，保护重要权重，量化其他
- Self-consistency：标准多数投票策略
- vLLM：PagedAttention 减少 KV Cache 内存占用
- 最终成绩：~28/50 正确

**5th Place - usernam - ~27/50 (54%)**

核心技巧：
- **lmdeploy 高吞吐量**：高吞吐量推理框架
- **DeepSeek-R1-Distill-Qwen-14B AWQ**：4-bit 量化
- **Batch 推理优化**：大 batch 推理提升吞吐

实现细节：
- lmdeploy：连续批处理优化
- 量化：AWQ 4-bit，减少内存和计算
- Batch size：根据 GPU 内存动态调整
- 最终成绩：~27/50 正确

**7th Place - tascj - ~26/50 (52%)**

核心技巧：
- **AWQ 量化**：4-bit 量化优化
- **lmdeploy 推理**：高吞吐量推理
- **DeepSeek-R1-Distill-Qwen-14B AWQ**

实现细节：
- AWQ：自定义量化配置
- lmdeploy：高吞吐量，多 GPU 并行
- 最终成绩：~26/50 正确

**8th Place - MPWARE - ~25/50 (50%)**

核心技巧：
- **自定义 AWQ 量化**：自定义量化策略
- **Self-consistency**：多候选投票
- **vLLM 推理引擎**

实现细节：
- 自定义 AWQ：根据模型特性定制量化
- vLLM：PagedAttention 内存优化
- 最终成绩：~25/50 正确

**9th Place - Fast-Math-R1–14B - ~24/50 (48%)**

核心技巧：
- **SFT + GRPO**：监督微调 + Group Relative Policy Optimization
- **GRPO 效率优化**：减少推理步数，提升效率（结果不稳定）
- **Fine-tuned DeepSeek-R1-Distill-Qwen-14B**：微调模型

实现细节：
- SFT：OpenR1 Math 数据集微调
- GRPO：优化推理步骤数，减少 tokens
- 不稳定性：优化到一定程度后"灾难性偏移"
- 使用早期 checkpoint 获得最佳结果
- 最终成绩：~24/50 正确

**11th Place - farsail - ~22/50 (44%)**

核心技巧：
- **One-shot prompting**：单样本提示，无需微调
- **自定义 vLLM**：自定义推理引擎配置
- **DeepSeek-R1-Distill-Qwen-14B AWQ**

实现细节：
- One-shot：提供 1-2 个示例作为提示
- 自定义 vLLM：优化 PagedAttention 参数
- 最终成绩：~22/50 正确

**17th Place - ippeiogawa - ~18/50 (36%)**

核心技巧：
- **Multi-stage prompting**：多阶段提示策略
- **代码生成**：强制生成 Python 代码
- **DeepSeek-R1-Distill-Qwen-14B AWQ**

实现细节：
- Multi-stage：分解问题，逐步生成代码
- 代码生成：要求模型生成可执行代码
- vLLM：高效推理引擎
- 最终成绩：~18/50 正确

**20th Place - Arek Paterek - ~15/50 (30%)**

核心技巧：
- **AWQ 量化**：4-bit 量化
- **DeepSeek-R1-Distill-Qwen-32B AWQ**：32B 大模型量化
- **Base model + prompting**：基础模型 + 提示工程

实现细节：
- 32B 模型：更大模型，更多知识
- AWQ 量化：4-bit 量化降低内存
- 无微调：直接使用提示
- 最终成绩：~15/50 正确

**22nd Place - K-Piece - ~13/50 (26%)**

核心技巧：
- **Base model + prompting**：基础模型 + 提示工程
- **DeepSeek-R1 系列**：使用不同大小的 DeepSeek-R1
- **Self-consistency**：多候选投票

实现细节：
- 提示工程：精心设计的提示模板
- DeepSeek-R1：14B, 32B 等不同变体
- Self-consistency：生成 5-10 个候选答案
- 最终成绩：~13/50 正确

**技术总结：**

| 技术维度 | 关键发现 |
|---------|---------|
| **模型选择** | DeepSeek-R1-Distill-Qwen-14B AWQ 是最受欢迎 |
| **微调方法** | SFT（基础）+ DPO（长度优化）+ TIR（工具集成） |
| **推理引擎** | vLLM（通用）<br>lmdeploy（高吞吐）<br>TensorRT-LLM（第 1 名专用） |
| **推理策略** | Self-consistency（标配）<br>Early stopping（节省时间）<br>代码执行（提升精度） |
| **核心创新** | MARIO 框架：Math + Reasoning + Interpreter |

---

### MAP - Charting Student Math Misunderstandings

**竞赛背景：**
- **主办方**：The Learning Agency + Eedi + Vanderbilt University
- **目标**：预测学生数学回答中的误解（Misconception）
- **特殊性质**：测试 AI 的**教育诊断能力**，帮助教师识别学生的错误思维模式

**竞赛演变：**
- **Eedi (2024年9月)**: "Mining Misconceptions in Mathematics" - 第一个竞赛，预测错误答案与误解的亲和度
- **MAP (2024年)**: "Charting Student Math Misunderstandings" - 第二个竞赛，扩展到完整的学生回答分析
- **相同获胜者**: Team MTH 101 (Raja Biswas) 赢得了两个竞赛

**竞赛规模（MAP）：**
- **数据来源**：Eedi + NAEP 数学问题
- **标注者**：15 名受过培训的标注员（有数学辅导经验）
- **学生群体**：9-14 岁（4-8 年级）
- **总队伍数**：1,850+ teams
- **总提交数**：39,760+ entries
- **奖项池**：$55,000（第 1 名 $20,000）

**任务格式对比：**

| 竞赛 | 任务 | 输入 | 输出 |
|------|------|------|------|
| **Eedi** | 预测错误答案与误解的亲和度 | 问题 + 错误答案 | 误解类型 |
| **MAP** | 预测学生解释中的误解 | 问题 + 答案 + 解释 | Top 25 误解预测 |

**任务格式：**
```
[问题文本 + 学生选择答案 + 学生解释]
    ↓
预测误解类型（Top 25 预测）
    ↓
MAP@3 评估（前 3 个预测）
```

**评估指标：**
- **MAP@3**: Mean Average Precision at 3
  - 第 1 次预测正确：1.0 分
  - 第 2 次预测正确：0.5 分
  - 第 3 次预测正确：0.33 分
  - 未预测正确：0 分
- **标签空间**：2,587 种误解类型

**关键洞察：**
1. **误解 vs 错误**：误解是系统性的、持续的，需要针对性干预
2. **标签层次**：正确性 → 解释质量 → 误解类型
3. **噪声标签**：多种子验证是处理噪声的关键
4. **检索+重排**：先用 embedding 检索，再用 CoT 推理重排
5. **集成融合**：加权融合多个模块提升鲁棒性

**前排方案总结（MAP Top 10+）：**

| 排名 | 团队 | MAP@3 | 核心技术 | 模型 |
|------|------|-------|---------|------|
| **1st** | Team MTH 101 | >0.948 | Shared-prefix attention, FlexAttention | 72B ranker + 32B ranker |
| **2nd** | - | ~0.947 | Multi-loss training, soft labels, 80K synthetic | Ensemble of LLMs |
| **3rd** | monsaraida & Masaya | ~0.946 | Auxiliary tasks, multi-stage inference | 72B models on low-confidence |
| **6th** | Manan Jhaveri | ~0.944 | Qwen-semble, data-centric | Qwen ensemble |
| **8th** | - | ~0.942 | Embedding + ensemble | Deberta + Qwen |
| **15th** | - | ~0.938 | Embedding models, semantic grouping | Manual inspection |

---

**前排方案总结（Eedi Top 12）：**

| 排名 | 团队 | MAP@25 | 核心技术 | 模型 |
|------|------|--------|---------|------|
| **1st** | Team MTH 101 | ~0.637 | Co-occurrence stats, Claude 3.5 Sonnet context | 72B + 32B ranker |
| **2nd** | Kazuhito Yonekawa et al. | ~0.636 | Multi-stage retrieve-and-rank | Qwen2.5-72B |
| **3rd** | waseda-pochi | ~0.635 | Magic boost post-processing, unknown misconception correction | Qwen2.5-32B |
| **4th** | - | ~0.634 | CoT features, grouped synthetic data | Qwen2.5-32B |
| **5th** | ebi-ktr | ~0.633 | Bi-encoder, listwise reranking | Qwen2.5-32B |
| **6th** | - | ~0.632 | QLoRA fine-tuning, ensemble | Qwen2.5-14B |
| **7th (Private) / 2nd (Public)** | terekaerumasahmet | ~0.631 | Multi-loss, soft labels | Qwen2.5-32B |
| **8th** | - | ~0.630 | Multi-stage retrieval, listwise reranking | Qwen2.5-32B |
| **9th (Private) / 7th (Public)** | - | ~0.629 | QLoRA fine-tuning | Qwen2.5-14B |
| **10th** | - | ~0.628 | Synthetic data, knowledge distillation | Qwen2.5-32B |

**Eedi vs MAP 技术对比：**

| 技术方面 | Eedi (2024年9月) | MAP (2024年) |
|---------|------------------|--------------|
| **任务** | 错误答案与误解的亲和度 | 学生解释中的误解 |
| **输入** | 问题 + 错误答案 | 问题 + 答案 + 解释 |
| **输出** | Top 25 误解预测 | Top 25 误解预测 |
| **检索** | Embedding similarity | Embedding + CoT |
| **重排** | Pointwise/Listwise | Multi-stage reasoning |
| **数据增强** | Synthetic data (LLM生成) | Synthetic data (80K) |
| **后处理** | Unknown misconception correction | - |

**核心创新 - MiRAGE 框架：**
- **M**: Misconception detection（误解检测）
- **R**: Retrieval-guided（检索引导）
- **A**: Multi-stage reasoning（多阶段推理）
- **G**: Ensemble fusion（集成融合）
- **E**: Education（教育应用）

---

### ARC Prize 2025 - Abstraction and Reasoning Corpus

**竞赛背景：**
- **主办方**：ARC Prize Organization (François Chollet, Mike Knoop)
- **目标**：测试 AI 的**抽象推理和泛化能力**，这是 AGI 的核心基准
- **竞赛主题**：Year of the Refinement Loop（优化循环之年）
- **特殊性质**：不是传统 ML 竞赛，而是**推理能力基准测试**

**数据集规模：**
- **ARC-AGI-1**: 800 tasks (400 training + 400 evaluation)
- **ARC-AGI-2**: 训练与 ARC-AGI-1 重叠，评估是新的难题
- **总队伍数**：1,455 teams
- **总提交数**：15,154 entries

**任务格式：**
```
输入网格 (训练示例 1-10 对)
    ↓
推断变换规则
    ↓
应用规则到测试输入
    ↓
输出网格
```

**评估指标：**
- **准确率**: 完全正确的任务占比（部分正确 = 0 分）
- **成本**: $/task（获胜方案约 $0.20/task，前沿模型 $2-$30/task）
- **泛化能力**: Public/Private 分离，Private 才是真实泛化

**关键洞察：**
1. **AI 推理系统**: 2025 年诞生了 AI 推理系统，与 LLM 的发明同等重要
2. **Refinement = Intelligence**: 优化循环是智能的核心
3. **知识 vs 推理**: 当前 AI 推理能力受限于模型知识
4. **Overfitting on Knowledge**: 前沿模型可能"过拟合"了 ARC 数据

**前排方案总结：**

| 排名 | 队伍 | 分数 | 关键技术 |
|------|------|------|---------|
| **1st** | NVARC | 24.03% | 合成数据 + Qwen-4B + TRM |
| **2nd** | the ARChitects | 16.53% | Masked-Diffusion LLM |
| **3rd** | MindsAI | 12.64% | TTFT + Augmentation |

**Paper Awards:**

| 排名 | 作者 | 标题 | 成绩 |
|------|------|------|------|
| **1st** | Alexia Jolicoeur-Martineau | Tiny Recursive Model (TRM) | 45% (ARC-AGI-1) |
| **2nd** | Julien Pourcel et al. | SOAR (进化程序合成) | 52% (ARC-AGI-1) |
| **3rd** | Isaac Liao | CompressARC (76K 参数) | 20-34% (ARC-AGI-1) |

---

## Code Templates

### MiRAGE Framework - 检索引导的多阶段推理

**关键洞察：** 通过检索 + 推理 + 重排的三阶段框架，实现高效的误解检测

```python
import torch
import torch.nn as nn
from typing import List, Tuple, Dict
import numpy as np

class MiRAGEFramework:
    """
    MiRAGE: Misconception detection with Retrieval-guided
            Multi-stage reasoning and Ensemble fusion

    基于论文: https://arxiv.org/html/2511.01182v1

    核心思想：
    1. Retrieval module: 嵌入模型检索语义相似的候选标签
    2. Reasoning module: CoT 推理生成结构化解释
    3. Reranking module: 基于推理结果重排候选标签
    4. Ensemble fusion: 加权融合检索和重排分数
    """

    def __init__(self,
                 embedder: nn.Module,
                 reasoner: nn.Module,
                 reranker: nn.Module,
                 alpha: float = 0.7,
                 beta: float = 0.3,
                 top_k: int = 25):
        """
        Args:
            embedder: 嵌入模型（如 MathBERT）
            reasoner: 推理模型（如 Qwen3-8B）
            reranker: 重排模型（如 Qwen3-7B）
            alpha: 重排分数权重
            beta: 检索分数权重
            top_k: 检索候选数量
        """
        self.embedder = embedder
        self.reasoner = reasoner
        self.reranker = reranker
        self.alpha = alpha
        self.beta = beta
        self.top_k = top_k

        # 缓存数据库嵌入
        self.embed_db = None
        self.label_db = None

    def build_embedding_index(self, dataset: List[Dict]):
        """
        构建嵌入索引

        Args:
            dataset: [{"question": str, "answer": str, "explanation": str, "label": str}, ...]
        """
        embeddings = []
        labels = []

        for item in dataset:
            # 生成三元组嵌入
            emb = self.embedder.encode(
                item["question"],
                item["answer"],
                item["explanation"]
            )
            embeddings.append(emb)
            labels.append(item["label"])

        self.embed_db = torch.stack(embeddings)
        self.label_db = labels

    def retrieval_module(self, query: Tuple[str, str, str]) -> List[Tuple[str, float]]:
        """
        检索模块：基于语义相似度检索候选标签

        Args:
            query: (question, answer, explanation)

        Returns:
            [(label, score), ...] 按相似度排序
        """
        q, a, e = query
        query_emb = self.embedder.encode(q, a, e)

        # 计算与所有数据库条目的相似度
        similarities = torch.matmul(self.embed_db, query_emb)

        # 按标签聚合（取最大相似度）
        label_scores = {}
        for label, sim in zip(self.label_db, similarities):
            if label not in label_scores:
                label_scores[label] = sim
            else:
                label_scores[label] = max(label_scores[label], sim)

        # 排序并返回 top-k
        sorted_labels = sorted(label_scores.items(), key=lambda x: x[1], reverse=True)
        return sorted_labels[:self.top_k]

    def reasoning_module(self, query: Tuple[str, str, str]) -> str:
        """
        推理模块：生成 CoT 推理链

        Args:
            query: (question, answer, explanation)

        Returns:
            reasoning: 结构化推理文本
        """
        q, a, e = query
        prompt = f"""
Analyze the following student response to a math problem.

Question: {q}
Student Answer: {a}
Student Explanation: {e}

Think step by step:
1. Is the answer correct?
2. Does the explanation contain any misconceptions?
3. If so, what type of misconception is it?

Provide your reasoning:
"""
        reasoning = self.reasoner.generate(prompt)
        return reasoning

    def reranking_module(self,
                        query: Tuple[str, str, str],
                        reasoning: str,
                        candidates: List[str]) -> List[Tuple[str, float]]:
        """
        重排模块：基于推理结果重排候选标签

        Args:
            query: (question, answer, explanation)
            reasoning: CoT 推理
            candidates: 候选标签列表

        Returns:
            [(label, score), ...] 重排后的标签
        """
        q, a, e = query
        reranked_scores = []

        for label in candidates:
            prompt = f"""
Question: {q}
Student Answer: {a}
Student Explanation: {e}

Reasoning: {reasoning}

Is the misconception "{label}" consistent with the above analysis?
Answer Yes or No:
"""
            # 获取模型输出的 logits
            logits = self.reranker.get_logits(prompt)

            # 计算 Yes/No 的 logit 差值
            yes_logit = logits["Yes"]
            no_logit = logits["No"]
            score = yes_logit - no_logit

            reranked_scores.append((label, score.item()))

        # 按分数排序
        reranked_scores.sort(key=lambda x: x[1], reverse=True)
        return reranked_scores

    def ensemble_fusion(self,
                       retrieval_scores: List[Tuple[str, float]],
                       rerank_scores: List[Tuple[str, float]]) -> List[Tuple[str, float]]:
        """
        集成融合：加权融合检索和重排分数

        Args:
            retrieval_scores: [(label, retrieval_score), ...]
            rerank_scores: [(label, rerank_score), ...]

        Returns:
            [(label, fused_score), ...]
        """
        # 归一化分数
        retrieval_dict = dict(retrieval_scores)
        rerank_dict = dict(rerank_scores)

        all_labels = set(retrieval_dict.keys()) | set(rerank_dict.keys())

        fused_scores = []
        for label in all_labels:
            ret_score = retrieval_dict.get(label, 0)
            rerank_score = rerank_dict.get(label, 0)

            # 加权融合
            fused = self.alpha * rerank_score + self.beta * ret_score
            fused_scores.append((label, fused))

        # 排序
        fused_scores.sort(key=lambda x: x[1], reverse=True)
        return fused_scores

    def predict(self, query: Tuple[str, str, str]) -> List[Tuple[str, float]]:
        """
        完整预测流程

        Args:
            query: (question, answer, explanation)

        Returns:
            [(label, score), ...] 最终预测结果
        """
        # Stage 1: Retrieval
        retrieval_results = self.retrieval_module(query)
        candidates = [label for label, _ in retrieval_results]

        # Stage 2: Reasoning
        reasoning = self.reasoning_module(query)

        # Stage 3: Reranking
        rerank_results = self.reranking_module(query, reasoning, candidates)

        # Stage 4: Ensemble fusion
        final_results = self.ensemble_fusion(retrieval_results, rerank_results)

        return final_results


# 使用示例
if __name__ == "__main__":
    # 假设我们有预训练的模型
    embedder = MathBERTEmbedder()
    reasoner = QwenReasoner()
    reranker = QwenReranker()

    # 创建 MiRAGE 框架
    miracle = MiRAGEFramework(
        embedder=embedder,
        reasoner=reasoner,
        reranker=reranker,
        alpha=0.7,
        beta=0.3,
        top_k=25
    )

    # 构建索引
    train_data = load_training_data()
    miracle.build_embedding_index(train_data)

    # 预测
    query = (
        "What is 2/3 + 1/6?",
        "3/4",
        "I added the numerators and denominators: 2+1=3, 3+6=9, so 3/9=1/3. Wait, that's wrong..."
    )

    predictions = miracle.predict(query)
    print("Top 3 predictions:")
    for label, score in predictions[:3]:
        print(f"{label}: {score:.4f}")
```

### Shared-Prefix Attention (1st Place)

**关键洞察：** 将每个标签候选编码为输入 token，使用 FlexAttention masks 让每个 suffix 只关注共享前缀

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class SharedPrefixClassifier(nn.Module):
    """
    Shared-Prefix Attention Classifier
    MAP Competition 1st Place Solution

    核心思想：
    1. 将任务重新定义为 suffix classification
    2. 每个标签候选被编码为一个输入 token
    3. 所有候选标签拼接成一个字符串
    4. 使用 FlexAttention masks 让每个 suffix 只关注共享前缀
    5. 使用每个 suffix 的最后一个 token 的特征进行分类
    """

    def __init__(self, model_name: str, num_labels: int):
        super().__init__()
        self.num_labels = num_labels

        # 加载预训练模型
        from transformers import AutoModel, AutoTokenizer
        self.model = AutoModel.from_pretrained(model_name)
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)

        # 分类头
        hidden_size = self.model.config.hidden_size
        self.classifier = nn.Linear(hidden_size, num_labels)

    def create_flex_attention_mask(self,
                                    prefix_len: int,
                                    suffix_len: int,
                                    num_candidates: int) -> torch.Tensor:
        """
        创建 FlexAttention mask

        每个 suffix 只能关注共享前缀，不能关注其他 suffix

        Args:
            prefix_len: 前缀长度（问题 + 回答）
            suffix_len: 每个 suffix 长度
            num_candidates: 候选数量

        Returns:
            attention_mask: [batch, seq_len, seq_len]
        """
        total_len = prefix_len + suffix_len * num_candidates
        device = self.model.device

        mask = torch.zeros(total_len, total_len, device=device)

        # 前缀可以关注前缀
        mask[:prefix_len, :prefix_len] = 1

        # 每个 suffix 可以关注前缀
        for i in range(num_candidates):
            start = prefix_len + i * suffix_len
            end = start + suffix_len
            mask[start:end, :prefix_len] = 1

        return mask.unsqueeze(0)  # [1, seq_len, seq_len]

    def forward(self,
                question: str,
                answer: str,
                explanation: str,
                candidate_labels: List[str]) -> torch.Tensor:
        """
        Forward pass

        Args:
            question: 问题文本
            answer: 学生选择的答案
            explanation: 学生的解释
            candidate_labels: 候选误解标签列表

        Returns:
            logits: [batch, num_labels]
        """
        # 构建输入
        prefix = f"Question: {question}\nAnswer: {answer}\nExplanation: {explanation}\n\n"

        # 拼接所有候选标签
        suffixes = []
        for label in candidate_labels:
            suffixes.append(f"Misconception: {label}")

        # 构建完整输入
        full_text = prefix + "".join(suffixes)
        inputs = self.tokenizer(full_text, return_tensors="pt")
        input_ids = inputs["input_ids"].to(self.model.device)

        # 计算 prefix 和 suffix 长度
        prefix_len = len(self.tokenizer(prefix)["input_ids"])
        suffix_len = len(self.tokenizer(suffixes[0])["input_ids"])

        # 创建 attention mask
        attention_mask = self.create_flex_attention_mask(
            prefix_len, suffix_len, len(candidate_labels)
        )

        # 获取模型输出
        outputs = self.model(
            input_ids=input_ids,
            attention_mask=attention_mask
        )
        hidden_states = outputs.last_hidden_state  # [batch, seq_len, hidden]

        # 提取每个 suffix 的最后一个 token
        suffix_last_tokens = []
        for i in range(len(candidate_labels)):
            pos = prefix_len + (i + 1) * suffix_len - 1
            suffix_last_tokens.append(hidden_states[:, pos, :])

        # 堆叠所有 suffix 特征
        suffix_features = torch.stack(suffix_last_tokens, dim=1)  # [batch, num_labels, hidden]

        # 分类
        logits = self.classifier(suffix_features)  # [batch, num_labels, num_labels]

        # 取对角线（每个 candidate 对应自己的 logit）
        batch_size = logits.size(0)
        logits = logits[range(batch_size), range(len(candidate_labels)), :]

        return logits


# 使用示例
if __name__ == "__main__":
    classifier = SharedPrefixClassifier("microsoft/deberta-v3-large", num_labels=2587)

    question = "What is 2/3 + 1/6?"
    answer = "3/4"
    explanation = "I added the numerators and denominators."

    # 候选标签（从检索模块获得）
    candidates = [
        "Adds denominators when adding fractions",
        "Incorrectly adds numerators and denominators",
        "Misunderstands fraction addition",
        # ... more candidates
    ]

    logits = classifier(question, answer, explanation, candidates)
    probs = F.softmax(logits, dim=-1)

    # Top-3 预测
    top3_probs, top3_indices = torch.topk(probs, 3)
    for prob, idx in zip(top3_probs[0], top3_indices[0]):
        print(f"{candidates[idx]}: {prob:.4f}")
```

### Multi-Loss Training with Soft Labels (2nd Place)

**关键洞察：** 使用软标签（soft labels）进行训练，减少标签模糊性的影响

```python
import torch
import torch.nn as nn
from typing import List, Dict

class MultiLossTrainer:
    """
    Multi-Loss Training with Soft Labels
    MAP Competition 2nd Place Solution

    核心思想：
    1. 生成软标签：平均多个模型的预测
    2. 多损失训练：结合 hard labels 和 soft labels
    3. 解决标签模糊性问题
    """

    def __init__(self, model: nn.Module, num_labels: int):
        self.model = model
        self.num_labels = num_labels

        # 损失函数
        self.ce_loss = nn.CrossEntropyLoss()
        self.kl_loss = nn.KLDivLoss(reduction="batchmean")

    def generate_soft_labels(self,
                            models: List[nn.Module],
                            dataloader: torch.utils.data.DataLoader,
                            device: str) -> torch.Tensor:
        """
        生成软标签

        Args:
            models: 用于生成软标签的模型列表
            dataloader: 数据加载器
            device: 设备

        Returns:
            soft_labels: [num_samples, num_labels]
        """
        all_soft_labels = []

        for batch in dataloader:
            input_ids = batch["input_ids"].to(device)
            attention_mask = batch["attention_mask"].to(device)

            # 收集所有模型的预测
            all_probs = []
            for model in models:
                with torch.no_grad():
                    outputs = model(input_ids, attention_mask=attention_mask)
                    probs = torch.softmax(outputs.logits, dim=-1)
                    all_probs.append(probs)

            # 平均所有模型的预测
            soft_labels = torch.stack(all_probs).mean(dim=0)
            all_soft_labels.append(soft_labels.cpu())

        return torch.cat(all_soft_labels, dim=0)

    def compute_loss(self,
                     logits: torch.Tensor,
                     hard_labels: torch.Tensor,
                     soft_labels: torch.Tensor,
                     alpha: float = 0.5,
                     temperature: float = 2.0) -> torch.Tensor:
        """
        计算多损失

        Args:
            logits: 模型输出 [batch, num_labels]
            hard_labels: 真实标签 [batch]
            soft_labels: 软标签 [batch, num_labels]
            alpha: hard loss 权重
            temperature: soft label 温度

        Returns:
            loss: 总损失
        """
        # Hard loss (交叉熵)
        hard_loss = self.ce_loss(logits, hard_labels)

        # Soft loss (KL 散度)
        log_probs = torch.log_softmax(logits / temperature, dim=-1)
        soft_labels_smooth = soft_labels / temperature
        soft_loss = self.kl_loss(log_probs, soft_labels_smooth) * (temperature ** 2)

        # 组合损失
        total_loss = alpha * hard_loss + (1 - alpha) * soft_loss

        return total_loss

    def train_epoch(self,
                    train_loader: torch.utils.data.DataLoader,
                    soft_labels: torch.Tensor,
                    optimizer: torch.optim.Optimizer,
                    device: str):
        """
        训练一个 epoch

        Args:
            train_loader: 训练数据加载器
            soft_labels: 预生成的软标签
            optimizer: 优化器
            device: 设备
        """
        self.model.train()
        total_loss = 0

        for batch_idx, batch in enumerate(train_loader):
            input_ids = batch["input_ids"].to(device)
            attention_mask = batch["attention_mask"].to(device)
            hard_labels = batch["labels"].to(device)

            # 获取对应的软标签
            start_idx = batch_idx * train_loader.batch_size
            end_idx = start_idx + len(hard_labels)
            batch_soft_labels = soft_labels[start_idx:end_idx].to(device)

            # Forward
            outputs = self.model(input_ids, attention_mask=attention_mask)
            logits = outputs.logits

            # 计算损失
            loss = self.compute_loss(logits, hard_labels, batch_soft_labels)

            # Backward
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

            total_loss += loss.item()

        return total_loss / len(train_loader)


# 使用示例
if __name__ == "__main__":
    from transformers import AutoModelForSequenceClassification

    # 创建模型
    model = AutoModelForSequenceClassification.from_pretrained(
        "microsoft/deberta-v3-large",
        num_labels=2587
    )

    # 创建训练器
    trainer = MultiLossTrainer(model, num_labels=2587)

    # 生成软标签（使用多个预训练模型）
    teacher_models = [
        AutoModelForSequenceClassification.from_pretrained("teacher1"),
        AutoModelForSequenceClassification.from_pretrained("teacher2"),
        AutoModelForSequenceClassification.from_pretrained("teacher3"),
    ]

    soft_labels = trainer.generate_soft_labels(teacher_models, train_loader, "cuda")

    # 训练
    optimizer = torch.optim.AdamW(model.parameters(), lr=1e-5)
    for epoch in range(3):
        loss = trainer.train_epoch(train_loader, soft_labels, optimizer, "cuda")
        print(f"Epoch {epoch}, Loss: {loss:.4f}")
```

### Auxiliary Task Training (3rd Place)

**关键洞察：** 同时训练多个辅助任务（正确性、推理错误类型），提升主任务性能

```python
import torch
import torch.nn as nn
from typing import Dict, Tuple

class AuxiliaryTaskModel(nn.Module):
    """
    Auxiliary Task Model
    MAP Competition 3rd Place Solution

    核心思想：
    1. 主任务：预测误解类型
    2. 辅助任务 1：预测答案是否正确
    3. 辅助任务 2：预测推理错误类型
    4. 多任务学习提升性能
    """

    def __init__(self,
                 encoder_name: str,
                 num_misconceptions: int,
                 num_error_types: int):
        super().__init__()

        from transformers import AutoModel

        # 共享编码器
        self.encoder = AutoModel.from_pretrained(encoder_name)
        hidden_size = self.encoder.config.hidden_size

        # 任务特定头
        self.misconception_head = nn.Linear(hidden_size, num_misconceptions)
        self.correctness_head = nn.Linear(hidden_size, 2)  # Binary: correct/incorrect
        self.error_type_head = nn.Linear(hidden_size, num_error_types)

        # Dropout
        self.dropout = nn.Dropout(0.1)

    def forward(self,
                input_ids: torch.Tensor,
                attention_mask: torch.Tensor) -> Dict[str, torch.Tensor]:
        """
        Forward pass with multiple outputs

        Args:
            input_ids: [batch, seq_len]
            attention_mask: [batch, seq_len]

        Returns:
            outputs: {
                "misconception_logits": [batch, num_misconceptions],
                "correctness_logits": [batch, 2],
                "error_type_logits": [batch, num_error_types]
            }
        """
        # 编码
        outputs = self.encoder(input_ids=input_ids, attention_mask=attention_mask)
        pooled = outputs.last_hidden_state[:, 0, :]  # [CLS] token
        pooled = self.dropout(pooled)

        # 多任务输出
        misconception_logits = self.misconception_head(pooled)
        correctness_logits = self.correctness_head(pooled)
        error_type_logits = self.error_type_head(pooled)

        return {
            "misconception_logits": misconception_logits,
            "correctness_logits": correctness_logits,
            "error_type_logits": error_type_logits
        }


class MultiTaskTrainer:
    """
    Multi-task Training
    """

    def __init__(self,
                 model: AuxiliaryTaskModel,
                 alpha: float = 1.0,
                 beta: float = 0.5,
                 gamma: float = 0.3):
        """
        Args:
            model: 多任务模型
            alpha: 主任务权重
            beta: 辅助任务 1 权重
            gamma: 辅助任务 2 权重
        """
        self.model = model
        self.alpha = alpha
        self.beta = beta
        self.gamma = gamma

        # 损失函数
        self.ce_loss = nn.CrossEntropyLoss()

    def compute_loss(self,
                     outputs: Dict[str, torch.Tensor],
                     misconception_labels: torch.Tensor,
                     correctness_labels: torch.Tensor,
                     error_type_labels: torch.Tensor) -> Tuple[torch.Tensor, Dict[str, float]]:
        """
        计算多任务损失

        Args:
            outputs: 模型输出
            misconception_labels: 误解标签 [batch]
            correctness_labels: 正确性标签 [batch]
            error_type_labels: 错误类型标签 [batch]

        Returns:
            total_loss: 总损失
            loss_dict: 各任务损失
        """
        # 主任务损失
        misconception_loss = self.ce_loss(
            outputs["misconception_logits"],
            misconception_labels
        )

        # 辅助任务 1：正确性
        correctness_loss = self.ce_loss(
            outputs["correctness_logits"],
            correctness_labels
        )

        # 辅助任务 2：错误类型
        error_type_loss = self.ce_loss(
            outputs["error_type_logits"],
            error_type_labels
        )

        # 总损失
        total_loss = (
            self.alpha * misconception_loss +
            self.beta * correctness_loss +
            self.gamma * error_type_loss
        )

        loss_dict = {
            "misconception": misconception_loss.item(),
            "correctness": correctness_loss.item(),
            "error_type": error_type_loss.item(),
            "total": total_loss.item()
        }

        return total_loss, loss_dict


# 使用示例
if __name__ == "__main__":
    # 创建模型
    model = AuxiliaryTaskModel(
        encoder_name="microsoft/deberta-v3-large",
        num_misconceptions=2587,
        num_error_types=10
    )

    # 创建训练器
    trainer = MultiTaskTrainer(model, alpha=1.0, beta=0.5, gamma=0.3)

    # 训练步骤
    optimizer = torch.optim.AdamW(model.parameters(), lr=1e-5)

    for batch in train_loader:
        input_ids = batch["input_ids"].cuda()
        attention_mask = batch["attention_mask"].cuda()
        misconception_labels = batch["misconception_labels"].cuda()
        correctness_labels = batch["correctness_labels"].cuda()
        error_type_labels = batch["error_type_labels"].cuda()

        # Forward
        outputs = model(input_ids, attention_mask)

        # Compute loss
        loss, loss_dict = trainer.compute_loss(
            outputs, misconception_labels, correctness_labels, error_type_labels
        )

        # Backward
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        print(f"Losses: {loss_dict}")
```

### Tiny Recursive Model (TRM) - 递归推理

**关键洞察：** 用极小参数（7M）实现递归推理，通过多次迭代改进答案

```python
import torch
import torch.nn as nn

class TinyRecursiveModel(nn.Module):
    """
    Tiny Recursive Model (TRM)
    Paper: "Less is More: Recursive Reasoning with Tiny Networks"
    Alexia Jolicoeur-Martineau, ARC Prize 2025 Paper Award 1st Place

    核心思想：
    - 递归地改进预测答案 y
    - 分别维护 answer 和 latent 状态
    - 通过多次迭代逐步优化（类似思维链）
    """
    def __init__(self, d_model=512, n_heads=8, n_iterations=16):
        super().__init__()
        self.d_model = d_model
        self.n_heads = n_heads
        self.n_iterations = n_iterations

        # Embedding layers
        self.embed_x = nn.Linear(10, d_model)  # input grid embedding (10 colors)
        self.embed_y = nn.Linear(10, d_model)  # output grid embedding
        self.embed_z = nn.Linear(10, d_model)  # latent embedding

        # Single transformer block (iterated, not stacked)
        self.attention = nn.MultiheadAttention(d_model, n_heads, batch_first=True)
        self.ffn = nn.Sequential(
            nn.Linear(d_model, 4 * d_model),
            nn.GELU(),
            nn.Linear(4 * d_model, d_model)
        )
        self.norm1 = nn.LayerNorm(d_model)
        self.norm2 = nn.LayerNorm(d_model)

        # Output heads
        self.head_y = nn.Linear(d_model, 10)  # update answer
        self.head_z = nn.Linear(d_model, 10)  # update latent

    def forward(self, x, y_init=None, z_init=None):
        """
        Args:
            x: input grid (batch, seq_len, 10)
            y_init: initial answer (random if None)
            z_init: initial latent (random if None)

        Returns:
            y: refined answer (batch, seq_len, 10)
        """
        batch_size, seq_len, _ = x.shape

        # Initialize
        y = y_init if y_init is not None else torch.randn_like(x)
        z = z_init if z_init is not None else torch.randn(batch_size, seq_len, self.d_model)

        # Embed inputs
        h_x = self.embed_x(x)  # (batch, seq_len, d_model)
        h_y = self.embed_y(y)  # (batch, seq_len, d_model)

        # Iterative refinement
        for iteration in range(self.n_iterations):
            # Combine context: input + current answer + latent
            h = h_x + h_y + self.permute_to_latent(z)

            # Single transformer block
            h_norm = self.norm1(h)
            attn_out, _ = self.attention(h_norm, h_norm, h_norm)
            h = h + attn_out

            h_norm = self.norm2(h)
            ffn_out = self.ffn(h_norm)
            h = h + ffn_out

            # Update latent z (n times)
            for _ in range(3):  # recursive reasoning
                z = z + self.head_z(h)

            # Update answer y (once)
            y_delta = self.head_y(h)
            y = y + y_delta
            h_y = self.embed_y(y)

        return y

    def permute_to_latent(self, z):
        """Permute latent to match input shape"""
        return z  # simplify for example
```

### 合成数据生成 - GPT-OSS 方法

**关键洞察：** 从现有任务生成新任务，通过组合实现二次方空间采样

```python
import openai

def generate_synthetic_puzzles(base_descriptions, n_generate=260000):
    """
    使用 GPT-OSS 从基础描述生成合成任务
    NVARC 团队方法：从 3,000 基础描述生成 260,000 合成任务

    Args:
        base_descriptions: 基础任务描述列表
        n_generate: 要生成的任务数

    Returns:
        generated_tasks: 生成的任务列表
    """
    generated_tasks = []

    # 采样二次方组合空间
    # 从 3,000 基础描述完整组合是 9M，采样 260K 是有意义的子集
    for i in range(n_generate):
        # 随机选择 2 个基础描述
        desc1 = base_descriptions[i % len(base_descriptions)]
        desc2 = base_descriptions[(i + 1) % len(base_descriptions)]

        # 组合描述
        combined_prompt = f"""
        Combine these two ARC tasks:

        Task 1: {desc1}
        Task 2: {desc2}

        Generate a new task that combines concepts from both.
        Output format:
        - Input grid generation code
        - Transformation code
        """

        # 使用 GPT 生成
        response = openai.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": combined_prompt}],
            temperature=0.7
        )

        generated_tasks.append(response.choices[0].message.content)

    return generated_tasks


def verify_generated_puzzles(tasks, min_valid_grids=30):
    """
    验证生成的任务质量

    NVARC 方法：
    1. 生成输入网格代码 + 单元测试
    2. 至少 30 个有效网格通过测试
    3. 生成 20 种变换实现
    4. 至少 8/20 产生相同输出
    """
    valid_tasks = []

    for task in tasks:
        # 执行生成的代码
        input_grids = generate_input_grids(task['input_code'])

        # 验证网格约束
        if len(input_grids) < min_valid_grids:
            continue

        # 生成多种变换实现
        transformations = []
        for _ in range(20):
            transform_result = execute_transformation(task['transform_code'], input_grids[0])
            transformations.append(transform_result)

        # 检查共识
        if check_consensus(transformations, threshold=8):
            valid_tasks.append(task)

    return valid_tasks


def check_consensus(results, threshold=8):
    """
    检查是否至少 threshold 个结果相同
    """
    from collections import Counter
    counts = Counter(results)
    return counts.most_common(1)[0][1] >= threshold
```

### Tokenizer 优化 - 16 Tokens

**关键洞察：** ARC 只需要 10 个颜色 + 格式 tokens，大幅减少 tokenizer

```python
from transformers import AutoTokenizer, AutoModelForVision2Seq

def optimize_arc_tokenizer(model_name="Qwen/Qwen2-VL-7B-Instruct"):
    """
    优化 tokenizer 用于 ARC 任务
    NVARC 方法：从 150K tokens 减少到 16 tokens

    ARC 只需要：
    - 10 个颜色 (0-9)
    - 新行符
    - 输入开始标记
    - 输出开始标记
    - 填充
    """
    # 加载原始 tokenizer
    tokenizer = AutoTokenizer.from_pretrained(model_name)

    # 定义 ARC 词汇表
    arc_vocab = {
        '0': 0, '1': 1, '2': 2, '3': 3, '4': 4,
        '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,  # colors
        '\\n': 10,     # newline
        '<IN>': 11,    # input start
        '<OUT>': 12,   # output start
        '<PAD>': 13,   # padding
    }

    # Patch embedding table
    model = AutoModelForVision2Seq.from_pretrained(model_name)
    original_embed = model.model.model.embed_tokens
    new_embed = nn.Embedding(16, original_embed.embedding_dim)

    # 复制相关 tokens
    for token, idx in arc_vocab.items():
        original_idx = tokenizer.convert_tokens_to_ids(token)
        if original_idx is not None:
            new_embed.weight[idx] = original_embed.weight[original_idx]

    # 替换 embedding 层
    model.model.model.embed_tokens = new_embed

    return tokenizer, model
```

### Test-Time Training (TTT)

**关键洞察：** 在测试时训练模型，每个任务单独训练

```python
import torch
import torch.nn as nn

def test_time_training(model, train_examples, test_input, n_steps=100, lr=0.001):
    """
    Test-Time Training (TTT)
    MindsAI 方法：在测试时训练模型

    Args:
        model: 基础模型
        train_examples: 训练示例 (input, output) 对列表
        test_input: 测试输入
        n_steps: 训练步数
        lr: 学习率

    Returns:
        prediction: 对测试输入的预测
    """
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    criterion = nn.MSELoss()

    # 训练阶段
    for step in range(n_steps):
        total_loss = 0

        for x, y in train_examples:
            # 前向传播
            pred = model(x)

            # 计算损失
            loss = criterion(pred, y)
            total_loss += loss

        # 反向传播
        optimizer.zero_grad()
        total_loss.backward()
        optimizer.step()

    # 预测阶段
    with torch.no_grad():
        prediction = model(test_input)

    return prediction


# MindsAI 的完整 TTT pipeline
def tft_with_augmentation(model, train_examples, test_input):
    """
    TTFT + Augmentation Ensemble

    MindsAI 方法：
    1. Test-Time Fine-Tuning
    2. 数据增强集成（旋转、翻转、颜色排列）
    3. Tokenizer Dropout
    """
    # 1. 数据增强
    augmented_examples = []
    for x, y in train_examples:
        # 几何变换
        for rotation in [0, 90, 180, 270]:
            x_rot = rotate_grid(x, rotation)
            y_rot = rotate_grid(y, rotation)
            augmented_examples.append((x_rot, y_rot))

            x_flip = flip_grid(x_rot)
            y_flip = flip_grid(y_rot)
            augmented_examples.append((x_flip, y_flip))

        # 颜色排列（10! = 3.6M，采样一部分）
        color_perms = sample_color_permutations(n=10)
        for perm in color_perms:
            x_perm = apply_color_permutation(x, perm)
            y_perm = apply_color_permutation(y, perm)
            augmented_examples.append((x_perm, y_perm))

    # 2. TTT with augmented data
    predictions = []
    for _ in range(10):  # 10 runs with different augmentation subsets
        subset = random_subset(augmented_examples, size=100)
        pred = test_time_training(model, subset, test_input)
        predictions.append(pred)

    # 3. Ensemble predictions
    final_pred = ensemble_predictions(predictions)

    return final_pred
```

### 数据增强 - 几何 + 颜色

**关键洞察：** 因子级别的数据增强（10! × 8 = 2900 万种）

```python
import numpy as np
from itertools import permutations

def augment_arc_task(input_grid, output_grid):
    """
    ARC 任务的数据增强

    NVARC 方法：
    - 几何变换：8 种（旋转 4 × 翻转 2）
    - 颜色排列：10! = 3,628,800 种
    - 总计：~2900 万种每个任务
    """
    augmented = []

    # 1. 几何变换
    rotations = [0, 90, 180, 270]
    flips = [False, True]

    for rotation in rotations:
        for flip in flips:
            x_aug = rotate_grid(input_grid, rotation)
            if flip:
                x_aug = flip_grid(x_aug)

            y_aug = rotate_grid(output_grid, rotation)
            if flip:
                y_aug = flip_grid(y_aug)

            augmented.append((x_aug, y_aug))

    # 2. 颜色排列（采样，因为 10! 太大）
    color_perms = sample_color_permutations(n=100)
    for perm in color_perms:
        for x, y in augmented[:8]:  # 只对原始 8 个几何变换
            x_perm = apply_color_permutation(x, perm)
            y_perm = apply_color_permutation(y, perm)
            augmented.append((x_perm, y_perm))

    return augmented


def sample_color_permutations(n=100, seed=42):
    """
    采样颜色排列（10! 太大，无法遍历）
    """
    rng = np.random.default_rng(seed)
    colors = np.arange(10)
    perms = []

    for _ in range(n):
        perm = rng.permutation(colors)
        perms.append(perm)

    return perms


def apply_color_permutation(grid, perm):
    """
    应用颜色排列到网格
    """
    permuted = grid.copy()

    # 创建映射
    mapping = {i: perm[i] for i in range(10)}

    # 应用映射
    for old_color in range(10):
        new_color = mapping[old_color]
        permuted[grid == old_color] = new_color

    return permuted
```

### SOAR - 进化程序合成

**关键洞察：** LLM 在自己的搜索轨迹上微调

```python
import openai

class SOAR:
    """
    SOAR: Self-Improving Language Models for Evolutionary Program Synthesis
    Julien Pourcel et al., ARC Prize 2025 Paper Award 2nd Place

    核心思想：
    1. 进化搜索生成程序
    2. LLM 在搜索轨迹上微调
    3. 迭代改进
    """
    def __init__(self, base_model="gpt-4"):
        self.base_model = base_model
        self.search_trajectory = []

    def evolutionary_search(self, task, n_generations=100):
        """
        进化搜索生成程序
        """
        population = self.initialize_population(task)

        for gen in range(n_generations):
            # 评估当前种群
            evaluated = self.evaluate_population(population, task)

            # 选择最好的
            best = sorted(evaluated, key=lambda x: x['fitness'], reverse=True)[:10]

            # 变异和交叉
            offspring = self.mutate_and_crossover(best, task)

            # 记录搜索轨迹
            self.search_trajectory.extend([
                {'generation': gen, 'programs': best, 'task': task}
            ])

            population = offspring

        return best[0]

    def fine_tune_on_trajectories(self, n_epochs=10):
        """
        在搜索轨迹上微调 LLM
        """
        # 准备训练数据
        training_data = []
        for trajectory in self.search_trajectory:
            for program in trajectory['programs']:
                prompt = f"""
                Task: {trajectory['task']}
                Program: {program['code']}
                Fitness: {program['fitness']}

                Generate a better program.
                """
                training_data.append({'prompt': prompt, 'completion': program['code']})

        # 微调（伪代码）
        for epoch in range(n_epochs):
            for sample in training_data:
                response = openai.chat.completions.create(
                    model=self.base_model,
                    messages=[{"role": "user", "content": sample['prompt']}],
                    temperature=0.7
                )

                # 计算损失并更新（实际需要训练循环）
                # loss = compute_loss(response, sample['completion'])
                # backward(loss)

        return self.base_model
```

### CompressARC - MDL 原理

**关键洞察：** 76K 参数，无预训练，仅用 VAE loss + decoder regularization

```python
import torch
import torch.nn as nn

class CompressARC(nn.Module):
    """
    CompressARC: ARC-AGI Without Pretraining
    Isaac Liao, ARC Prize 2025 Paper Award 3rd Place

    核心思想：
    - 仅 76K 参数
    - 无预训练，随机初始化
    - 使用 MDL (Minimum Description Length) 原理
    - VAE loss + decoder regularization
    - 测试时训练（每个任务单独训练）
    """
    def __init__(self, latent_dim=64, grid_size=30):
        super().__init__()
        self.latent_dim = latent_dim
        self.grid_size = grid_size

        # Encoder: grid -> latent
        self.encoder = nn.Sequential(
            nn.Linear(10, 128),  # 10 colors
            nn.ReLU(),
            nn.Linear(128, latent_dim * 2)  # mean + logvar
        )

        # Decoder: latent -> grid
        self.decoder = nn.Sequential(
            nn.Linear(latent_dim, 128),
            nn.ReLU(),
            nn.Linear(128, 10)  # 10 colors
        )

    def encode(self, x):
        """编码网格到潜在空间"""
        h = self.encoder(x)  # (batch, latent_dim * 2)
        mu, logvar = h.chunk(2, dim=-1)
        return mu, logvar

    def decode(self, z):
        """从潜在空间解码网格"""
        return self.decoder(z)

    def forward(self, x):
        """前向传播"""
        mu, logvar = self.encode(x)

        # Reparameterization trick
        std = torch.exp(0.5 * logvar)
        eps = torch.randn_like(std)
        z = mu + eps * std

        # Decode
        recon_x = self.decode(z)

        return recon_x, mu, logvar

    def loss_function(self, recon_x, x, mu, logvar, beta=0.1):
        """
        VAE loss + decoder regularization (MDL principle)

        CompressARC 关键创新：用 VAE 代替组合搜索
        """
        # Reconstruction loss
        recon_loss = nn.functional.cross_entropy(recon_x, x)

        # KL divergence
        kl_loss = -0.5 * torch.sum(1 + logvar - mu.pow(2) - logvar.exp())

        # Decoder regularization (MDL)
        decoder_reg = sum(p.pow(2).sum() for p in self.decoder.parameters())

        # Total loss
        total_loss = recon_loss + beta * kl_loss + 0.01 * decoder_reg

        return total_loss


def test_time_train_compressarc(task, n_minutes=20):
    """
    测试时训练 CompressARC
    每个 puzzle 单独训练，约 20 分钟在 RTX 4070 上
    """
    model = CompressARC()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)

    # 训练（直到收敛或超时）
    for step in range(10000):  # 最多 10K 步
        total_loss = 0

        for input_grid, output_grid in task['train_examples']:
            # 前向传播
            recon, mu, logvar = model(input_grid)

            # 计算损失
            loss = model.loss_function(recon, output_grid, mu, logvar)
            total_loss += loss

        # 反向传播
        optimizer.zero_grad()
        total_loss.backward()
        optimizer.step()

        # 早停检查
        if total_loss < 0.01:
            break

    # 预测
    with torch.no_grad():
        test_input = task['test_input']
        recon, mu, logvar = model(test_input)
        prediction = recon.argmax(dim=-1)

    return prediction
```

### MARIO 框架 - 数学推理 + 代码解释器

**关键洞察：** 纯 LLM 推理不够，需要代码执行进行计算

```python
import subprocess
import tempfile
import os

class MARIOFramework:
    """
    MARIO: MAth Reasoning with code Interpreter
    NVIDIA AIMO-2 第 1 名方案

    核心思想：
    1. LLM 生成自然语言推理 + Python 代码
    2. 代码在沙盒环境中执行
    3. 执行结果指导后续推理
    4. 迭代直到得到最终答案
    """
    def __init__(self, model, max_iterations=10):
        self.model = model
        self.max_iterations = max_iterations

    def solve_math_problem(self, problem_text):
        """
        解决数学问题

        Args:
            problem_text: 数学问题文本

        Returns:
            answer: 最终答案（多选 A-E 或数值）
        """
        # 初始化对话
        conversation = [
            {"role": "system", "content": "You are a math expert. Solve the problem step by step."},
            {"role": "user", "content": problem_text}
        ]

        for iteration in range(self.max_iterations):
            # 生成推理 + 代码
            response = self.model.generate(conversation)

            # 提取 Python 代码
            code_blocks = self.extract_code_blocks(response)

            if code_blocks:
                # 执行代码
                execution_results = []
                for code in code_blocks:
                    result = self.execute_code_safely(code)
                    execution_results.append(result)

                # 将执行结果添加到对话
                conversation.append({"role": "assistant", "content": response})
                conversation.append({
                    "role": "user",
                    "content": f"Execution results: {execution_results}. Continue reasoning."
                })
            else:
                # 没有代码，直接返回答案
                conversation.append({"role": "assistant", "content": response})
                break

        # 提取最终答案
        answer = self.extract_final_answer(conversation[-1]['content'])
        return answer

    def extract_code_blocks(self, text):
        """
        提取 Python 代码块
        """
        import re
        pattern = r'```python\n(.*?)```'
        matches = re.findall(pattern, text, re.DOTALL)
        return matches

    def execute_code_safely(self, code, timeout=10):
        """
        在沙盒环境中安全执行代码
        """
        try:
            # 创建临时文件
            with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
                f.write(code)
                temp_file = f.name

            # 执行代码，设置超时和资源限制
            result = subprocess.run(
                ['python', temp_file],
                capture_output=True,
                text=True,
                timeout=timeout,
                # 资源限制
                # (实际实现需要更严格的沙盒)
            )

            # 删除临时文件
            os.unlink(temp_file)

            return result.stdout
        except subprocess.TimeoutExpired:
            return "Execution timeout"
        except Exception as e:
            return f"Error: {str(e)}"
```

### 三阶段训练 (CoT → TIR → GenSelect)

**关键洞察：** 逐步训练模型掌握推理、工具使用和答案选择

```python
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

class ThreeStageTraining:
    """
    NVIDIA 三阶段训练流程
    Stage 1: CoT (Chain-of-Thought) - 知识获取
    Stage 2: TIR (Tool-Integrated Reasoning) - 工具集成推理
    Stage 3: GenSelect - 生成选择
    """
    def __init__(self, model_name="Qwen/Qwen2.5-32B"):
        self.model = AutoModelForCausalLM.from_pretrained(model_name)
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)

    def stage1_cot_training(self, cot_dataset):
        """
        Stage 1: Chain-of-Thought 训练
        纯推理训练，不使用代码执行
        """
        for example in cot_dataset:
            problem = example['problem']
            cot_solution = example['cot_solution']  # 长思维链

            prompt = f"""
            Problem: {problem}

            Solution:
            {cot_solution}

            Answer: {example['answer']}
            """

            # 训练模型生成推理链
            inputs = self.tokenizer(prompt, return_tensors="pt")
            labels = self.tokenizer(cot_solution, return_tensors="pt")

            outputs = self.model(**inputs, labels=labels)
            loss = outputs.loss

            # 反向传播（简化）
            loss.backward()

    def stage2_tir_training(self, tir_dataset):
        """
        Stage 2: Tool-Integrated Reasoning 训练
        训练模型生成推理 + Python 代码
        """
        for example in tir_dataset:
            problem = example['problem']
            tir_solution = example['tir_solution']  # 推理 + 代码

            prompt = f"""
            Problem: {problem}

            Solve the problem step by step. Use Python code for calculations.

            Solution:
            {tir_solution}

            Answer: {example['answer']}
            """

            inputs = self.tokenizer(prompt, return_tensors="pt")
            labels = self.tokenizer(tir_solution, return_tensors="pt")

            outputs = self.model(**inputs, labels=labels)
            loss = outputs.loss

            loss.backward()

    def stage3_genselect_training(self, validation_dataset):
        """
        Stage 3: GenSelect 训练
        学习多答案生成 + 排序投票
        """
        # 训练时模拟多个答案生成
        predictions = []

        for example in validation_dataset:
            problem = example['problem']

            # 生成多个候选答案
            candidate_answers = []
            for _ in range(32):  # 32 个候选答案
                prompt = f"Problem: {problem}\nSolution: Let's think step by step."
                inputs = self.tokenizer(prompt, return_tensors="pt")
                outputs = self.model.generate(**inputs, max_new_tokens=2048)

                answer = self.extract_answer(outputs)
                candidate_answers.append(answer)

            # 基于排序的投票
            final_answer = self.rank_based_voting(candidate_answers)
            predictions.append(final_answer)

    def rank_based_voting(self, answers):
        """
        基于排序的投票（优于简单多数投票）

        NVIDIA 创新：
        - 不只是计数答案出现次数
        - 根据推理质量加权
        - 考虑答案的置信度
        """
        # 统计每个答案的投票数
        from collections import Counter
        counts = Counter(answers)

        # 加权投票（推理质量）
        # 这里简化为多数投票
        return counts.most_common(1)[0][0]
```

### GenSelect - 多答案生成与投票

**关键洞察：** 候选答案的排序投票优于简单多数投票

```python
import numpy as np
from collections import Counter

def genselect_answer(model, problem_text, n_candidates=32):
    """
    GenSelect: 生成选择方法

    NVIDIA AIMO-2 核心创新：
    1. 生成多个候选答案
    2. 对每个答案评分
    3. 基于排序选择最终答案
    """
    candidate_answers = []
    scores = []

    for _ in range(n_candidates):
        # 生成推理 + 答案
        prompt = f"""
Problem: {problem_text}

Let's think step by step. We need to find the final answer.
"""
        response = model.generate(prompt, max_new_tokens=2048)

        # 提取答案
        answer = extract_answer(response)
        confidence = estimate_confidence(response)

        candidate_answers.append(answer)
        scores.append(confidence)

    # 基于排序的投票
    # 不只是选择出现最多的答案
    # 考虑答案的置信度排序
    sorted_indices = np.argsort(scores)[::-1]  # 降序

    # 选择置信度最高的答案
    # 或者使用加权组合
    final_answer = candidate_answers[sorted_indices[0]]

    return final_answer


def extract_answer(response_text):
    """
    从推理文本中提取最终答案
    """
    import re

    # 匹配模式 1: "Answer: X"
    match = re.search(r'Answer:\s*([A-E]|-?\d+)', response_text)
    if match:
        return match.group(1)

    # 匹配模式 2: "最终答案是 X"
    match = re.search(r'最终答案[是为]\s*([A-E]|-?\d+)', response_text)
    if match:
        return match.group(1)

    # 匹配模式 3: "Therefore, the answer is X"
    match = re.search(r'Therefore,?\s*the\s+answer\s+is\s+([A-E]|-?\d+)', response_text)
    if match:
        return match.group(1)

    return None


def estimate_confidence(response_text):
    """
    估计答案的置信度

    方法：
    - 推理链的完整性
    - "Therefore"、"Thus"等确定性词汇
    - 答案的明确程度
    """
    confidence = 0.5  # 基础置信度

    # 检查确定性词汇
    certainty_keywords = ['therefore', 'thus', 'hence', 'consequently']
    for keyword in certainty_keywords:
        if keyword in response_text.lower():
            confidence += 0.1

    # 检查不确定性词汇
    uncertainty_keywords = ['maybe', 'perhaps', 'possibly', 'probably']
    for keyword in uncertainty_keywords:
        if keyword in response_text.lower():
            confidence -= 0.1

    # 检查推理链长度
    reasoning_length = len(response_text.split('.'))
    confidence += min(reasoning_length / 100, 0.3)

    return np.clip(confidence, 0, 1)
```

### OpenMathReasoning 数据集构建

**关键洞察：** 从 AoPS 论坛提取高质量数学问题

```python
import requests
from bs4 import BeautifulSoup

def build_openmath_dataset():
    """
    从 AoPS (Art of Problem Solving) 论坛构建数据集

    NVIDIA AIMO-2 方法：
    1. 爬取 AoPS 论坛的高质量回答
    2. 使用 LLM 提取结构化信息
    3. 过滤低质量数据
    4. 生成 CoT 和 TIR 格式
    """
    base_url = "https://artofproblemsolving.com"

    # 1. 爬取论坛帖子
    posts = []
    for forum in ["algebra", "combinatorics", "number_theory"]:
        url = f"{base_url}/{forum}"
        posts.extend(scrape_aops_forum(url))

    # 2. 提取问题和解答
    extracted_data = []
    for post in posts:
        # 使用 LLM 提取结构化信息
        prompt = f"""
        Extract from this AoPS forum post:
        {post['content']}

        Extract:
        1. Problem statement
        2. Solution steps
        3. Final answer
        """

        extraction = llm_extract(prompt)

        extracted_data.append({
            'problem': extraction['problem'],
            'solution': extraction['solution'],
            'answer': extraction['answer'],
            'source': post['url']
        })

    # 3. 过滤质量
    filtered_data = filter_quality(extracted_data)

    # 4. 生成 CoT 格式
    cot_data = []
    for item in filtered_data:
        cot = generate_cot_from_solution(item['solution'])
        cot_data.append({
            'problem': item['problem'],
            'cot_solution': cot,
            'answer': item['answer']
        })

    # 5. 生成 TIR 格式
    tir_data = []
    for item in filtered_data:
        tir = generate_tir_from_solution(item['solution'])
        tir_data.append({
            'problem': item['problem'],
            'tir_solution': tir,
            'answer': item['answer']
        })

    return cot_data, tir_data


def generate_cot_from_solution(solution):
    """
    从解答生成长思维链 (CoT)
    """
    prompt = f"""
    Convert this solution into a step-by-step chain-of-thought explanation:

    Solution: {solution}

    Make sure to:
    1. Explain each step clearly
    2. Show your work
    3. Explain why we take each step
    """

    return llm_generate(prompt)


def generate_tir_from_solution(solution):
    """
    从解答生成工具集成推理 (TIR)
    """
    prompt = f"""
    Convert this solution into a format that includes Python code:

    Solution: {solution}

    Make sure to:
    1. Include Python code for calculations
    2. Explain what the code does
    3. Show intermediate results
    """

    return llm_generate(prompt)
```

### 2nd Place 方案 - 代码生成 + 执行流水线

**关键洞察：** 先生成 Python 代码，再执行验证

```python
def solve_math_with_code_generation(model, problem_text):
    """
    2nd Place (imagination-research) 方法

    流水线：
    1. 提示模型生成 Python 代码
    2. 提取 Python 代码
    3. 在解释器中执行代码
    4. 验证结果
    5. 返回最终答案
    """
    # Step 1: 生成代码
    prompt = f"""
    Write a Python program to solve this math problem:

    {problem_text}

    The program should:
    1. Define the problem
    2. Implement the solution
    3. Print the final answer
    """

    response = model.generate(prompt)
    python_code = extract_python_code(response)

    # Step 2: 执行代码
    result = execute_python_code(python_code)

    # Step 3: 提取答案
    answer = extract_answer_from_output(result)

    return answer


def extract_python_code(text):
    """
    从响应中提取 Python 代码
    """
    import re
    pattern = r'```python\n(.*?)\n```'
    match = re.search(pattern, text, re.DOTALL)
    if match:
        return match.group(1)

    # 备选：找 indented 代码块
    lines = text.split('\n')
    code_lines = []
    in_code_block = False
    indent_level = 0

    for line in lines:
        if '```' in line:
            in_code_block = not in_code_block
        elif in_code_block:
            code_lines.append(line)

    return '\n'.join(code_lines)


def execute_python_code(code):
    """
    执行 Python 代码并返回输出
    """
    import sys
    from io import StringIO

    old_stdout = sys.stdout
    old_stderr = sys.stderr

    sys.stdout = StringIO()
    sys.stderr = StringIO()

    try:
        exec(code, {})
        output = sys.stdout.getvalue()
        error = sys.stderr.getvalue()
    except Exception as e:
        output = ""
        error = str(e)
    finally:
        sys.stdout = old_stdout
        sys.stderr = old_stderr

    return output if output else error
```

---

## Best Practices

### ARC/抽象推理任务策略

| 策略 | 何时使用 | 说明 |
|------|---------|------|
| **Refinement Loops** | 需要逐步优化答案 | 递归改进是智能的核心 (TRM) |
| **合成数据生成** | 原始任务不足时 | 通过组合生成新任务，采样二次方空间 |
| **LLM 微调** | 有基础模型可用 | Qwen-4B 在合成数据上微调 |
| **Test-Time Training** | 每个任务独立 | 在测试时为每个任务单独训练 |
| **进化程序合成** | 需要探索程序空间 | LLM 在搜索轨迹上微调 (SOAR) |
| **极小模型** | 计算受限或追求效率 | TRM (7M), CompressARC (76K) |
| **数据增强** | 任务数量有限时 | 几何变换 + 颜色排列 |
| **Tokenizer 优化** | 词汇表冗余时 | 减少到任务需要的最小 tokens |

### 抽象推理 vs 传统 NLP

| 方面 | 传统 NLP | ARC/抽象推理 |
|------|----------|-------------|
| **任务类型** | 分类、序列标注、生成 | 程序合成、推理 |
| **评估方式** | Accuracy/F1/Perplexity | 完全正确才算对 |
| **数据格式** | 文本序列 | 网格变换 |
| **泛化挑战** | 分布偏移 | Out-of-Distribution |
| **训练方式** | 大规模预训练 | 测试时训练为主 |
| **模型大小** | 越大越好 | 越小越高效 (TRM, CompressARC) |

### Refinement Loops（优化循环）

**核心思想：** Refinement = Intelligence（优化即智能）

**应用场景：**

| 方法 | 实现 | 适用场景 |
|------|------|---------|
| **递归推理** | TRM: 16 次迭代改进答案 | 需要逐步优化 |
| **进化搜索** | SOAR: 进化 + 微调 LLM | 程序合成 |
| **Test-Time Training** | 在测试时训练 | 每个任务独立 |
| **模型精炼** | 应用层优化 (Poetiq) | 提升基础模型 |

**NVIDIA Refinement (Poetiq) 示例：**
- 基础: Gemini 3 Pro → 31%
- 精炼后: 54% (+23%)
- 成本: $0.81 → $31

### 合成数据生成策略

**NVARC 方法：**

1. **基础数据收集**
   - Human-ARC: 1K+ 任务描述
   - BARC: 600 可用任务
   - 总计: ~700 原始任务

2. **结构化描述**
   - 5 个组件：输入生成、解决步骤、规则总结、关键洞察、概念
   - 使用 Claude/GPT-4o 结构化

3. **二次方组合**
   - 3,000 基础描述
   - 完整组合: 9M (3,000²)
   - 采样: 260K 合成任务

4. **质量验证**
   - 生成输入代码 + 单元测试
   - 至少 30 个有效网格
   - 20 种实现，8/20 共识
   - 过滤后: ~100K 任务

### 模型架构对比

| 方法 | 参数量 | 预训练 | 成绩 | 特点 |
|------|--------|--------|------|------|
| **NVARC** | 4B (Qwen) | ✅ | 24% | 合成数据 + 微调 |
| **TRM** | 7M | ❌ | 8% (ARC-AGI-2) | 递归推理，极小模型 |
| **CompressARC** | 76K | ❌ | 4% (ARC-AGI-2) | MDL，无预训练 |
| **SOAR** | 变化 | ❌ | 52% (ARC-AGI-1) | 进化 + 自微调 |
| **ARChitects** | 变化 | ✅ | 16.53% | Masked-Diffusion |

### 成本效益对比

| 方案 | 准确率 (ARC-AGI-2) | 成本 | 性价比 |
|------|---------------------|------|--------|
| **NVARC (获胜)** | 24.03% | $0.20/task | 最高 |
| **Gemini 3 Pro (基线)** | 31% | $0.81/task | 中等 |
| **Gemini 3 Pro (精炼)** | 54% | $31/task | 低 |
| **Claude Opus (精炼)** | ~54% | $60/task | 最低 |
| **GPT-4o (开始)** | 1.9% | - | - |

### 前沿模型的问题

**"Overfitting on Knowledge"（知识过拟合）：**

**现象：** 前沿模型可能在训练数据上"过拟合"了 ARC
- **证据**：Gemini 3 Deep Think 使用正确的 ARC 颜色映射
- **原因**：ARC 数据在预训练数据中充分表示
- **含义**：即使设计良好的 benchmark 也会被"过拟合"

**解决方案：**
- **ARC-AGI-3**: 新格式，测试交互推理
- **新任务生成**: 持续更新 benchmark
- **私有数据**: 保持测试集未知

### Test-Time Training 最佳实践

**何时使用：**
- 每个任务独立
- 训练示例少（2-10 对）
- 需要快速适应

**实现步骤：**
1. 使用训练示例作为 mini-batch
2. 训练 n 步（100-1000）
3. 在测试输入上预测
4. 可选：数据增强集成

**MindsAI TTFT Pipeline：**
1. Test-Time Fine-Tuning
2. Augmentation Ensemble（几何 + 颜色）
3. Tokenizer Dropout
4. Pretraining Tricks

### 极小模型的优势

**TRM (7M 参数)：**
- **效率**: 参数少，推理快
- **泛化**: 不易过拟合
- **可解释**: 递归结构清晰

**CompressARC (76K 参数)：**
- **无预训练**: 随机初始化
- **MDL 原理**: 最小描述长度
- **测试时训练**: 每个任务 20 分钟

**结论：** 对于推理任务，小模型 + TTT 可能优于大模型

### 数据增强策略

**几何变换 (8 种)：**
- 旋转: 0°, 90°, 180°, 270°
- 翻转: 水平、垂直

**颜色排列:**
- 10! = 3,628,800 种
- 实际采样: 100-1000 种

**增强策略：**
- **NVARC**: 不同数据源不同增强级别 (24-256)
- **MindsAI**: 采样 + 集成

### Tokenizer 优化

**为什么优化：**
- 原始: ~150K tokens
- ARC 需要: 16 tokens (10 颜色 + 6 格式)
- 减少: ~99.99%

**NVARC 方法：**
1. 保留 16 个相关 tokens
2. Patch embedding table
3. 微调时只更新这些 tokens

### 前沿模型的使用

**竞赛开始时 (2025-03)：**
- Claude Sonnet: 1.3%
- GPT-4o: 1.9%

**竞赛结束后 (2025-11)：**
- Gemini 3: 31% → 54% (精炼)
- Claude Opus: >30%
- Grok: >30%

**原因：**
- 前沿模型在合成 ARC 数据上预训练
- 代码生成 + 执行在推理时

### 关键数据洞察总结

1. **Refinement = Intelligence**: 优化循环是智能的核心
2. **合成数据是关键**: 从 700 任务生成 260K 合成任务
3. **极小模型很强大**: TRM (7M), CompressARC (76K)
4. **Test-Time Training 有效**: 每个任务单独训练
5. **LLM 可以自改进**: SOAR 在搜索轨迹上微调
6. **Overfitting on Knowledge**: 前沿模型可能"过拟合" ARC
7. **成本差异巨大**: $0.20 vs $60 per task
8. **公共排行榜不可靠**: Public/Private Shake 严重

### 抽象推理任务的最佳实践

| 方面 | 推荐 |
|------|------|
| **数据准备** | 合成数据生成 + 质量验证 |
| **模型选择** | 小模型 + TTT (TRM, CompressARC) |
| **训练策略** | Test-Time Training |
| **优化方法** | Refinement Loops |
| **数据增强** | 几何变换 + 颜色排列 |
| **Tokenizer** | 优化到最小 tokens |
| **评估** | 使用本地验证，忽略 Public LB |
| **成本控制** | TTT < 模型精炼 < 前沿模型 |

### 数学推理任务策略

| 策略 | 何时使用 | 说明 |
|------|---------|------|
| **代码执行集成** | 需要精确计算 | 纯推理不够，需要 Python 代码执行 |
| **多答案生成 + 投票** | 答案不确定时 | 32 个候选 + 排序投票 |
| **三阶段训练** | 有大量高质量数据时 | CoT → TIR → GenSelect |
| **高质量数据源** | 数据不足时 | 从 AoPS 等专业论坛提取 |
| **小模型竞争力** | 计算受限时 | 1.5B 模型可达有竞争力 |

### 数学推理 vs 抽象推理 vs 传统 NLP

| 方面 | 传统 NLP | 数学推理 | 抽象推理 |
|------|----------|---------|-------------|
| **任务类型** | 分类、序列标注 | 数学问题求解 | 程序合成、推理 |
| **输出格式** | 标签、文本 | 数值答案、选项 | 网格变换 |
| **核心挑战** | 语义理解 | 逻辑推理、计算 | 泛化能力 |
| **关键能力** | 语言理解 | 数学知识、推理 | 抽象能力 |
| **解决方案** | 微调 LLM | 代码执行 + GenSelect | Refinement Loops |

### MARIO 框架详解

**核心组件：**

| 组件 | 功能 | 实现方式 |
|------|------|---------|
| **MA** | Math（数学推理） | 理解问题、生成推理 |
| **RI** | Reasoning + Interpreter | 生成代码、执行、验证 |
| **O** | Open（开源） | 开源模型和数据 |

**流程：**
```
问题文本
    ↓
[LLM 推理 + Python 代码]
    ↓
[沙盒环境执行代码]
    ↓
[执行结果反馈]
    ↓
[迭代优化]
    ↓
最终答案
```

### 数据质量 vs 数量

**NVIDIA 发现：**

| 方面 | 传统方法 | NVIDIA 方法 |
|------|---------|-----------|
| **数据量** | 追求数量 | 质量优先 |
| **数据源** | 通用数据集 | 专业论坛 (AoPS) |
| **质量验证** | 简单过滤 | LLM 提取 + 人工验证 |
| **效果** | 300K 低质量 | 290K 高质量 |

**OpenMathReasoning 数据集：**
- **问题数量**: ~290K（不是最初宣传的 540K）
- **CoT 格式**: 3.2M 长思维链
- **TIR 格式**: 1.7M 工具集成推理
- **来源**: AoPS (Art of Problem Solving) 论坛

### GenSelect vs 简单多数投票

| 方法 | 准确率 | 计算成本 | 说明 |
|------|--------|----------|------|
| **GenSelect** | 68% (34/50) | 32 × 推理 | 基于排序投票 |
| **简单多数投票** | ~60% | 32 × 推理 | 只选出现最多的 |
| **单次推理** | ~50% | 1 × 推理 | 不生成多次 |

**GenSelect 优势：**
- 考虑推理质量
- 加权置信度
- 处理答案分布不均

### 模型大小 vs 性能

| 模型 | 参数量 | 性能 | 成本 |
|------|--------|------|------|
| **OpenMath-Nemotron-1.5B** | 1.5B | ~40% | 低 |
| **OpenMath-Nemotron-7B** | 7B | ~50% | 中 |
| **OpenMath-Nemotron-14B** | 14B | ~60% | 高 |
| **OpenMath-Nemotron-32B** | 32B | 68% | 最高 |
| **DeepSeek-R1** | ~? | ~70% | 未知 |

**结论：** 小模型（1.5B）在有良好训练的情况下可达有竞争力的性能

### AoPS 数据提取策略

**关键步骤：**

1. **论坛选择**
   - Algebra（代数）
   - Combinatorics（组合）
   - Number Theory（数论）

2. **质量指标**
   - 回答质量（被选为最佳回答）
   - 推理完整性
   - 可验证性

3. **LLM 提取**
   - 问题陈述
   - 解决步骤
   - 最终答案
   - 结构化格式

4. **过滤策略**
   - 移除低质量解答
   - 验证数学正确性
   - 去重

### 代码执行安全

**沙盒环境要求：**

| 方面 | 要求 |
|------|------|
| **隔离** | 独立进程，不污染主环境 |
| **超时** | 10 秒执行时间限制 |
| **资源限制** CPU、内存、磁盘限制 |
| **网络** | 禁止网络访问 |
| **文件系统** | 临时文件，只读访问 |

**实现方式：**
- Docker 容器
- subprocess + resource limits
- 云端执行环境

### 前沿模型的进展

**竞赛期间（2024-08）：**
- Claude Sonnet: ~30%
- GPT-4o: ~35%

**竞赛结束后（2024-12）：**
- Gemini 2 Pro: ~50%
- DeepSeek-R1: ~70%
- Claude Opus: ~65%

**原因：**
- 前沿模型在数学数据上预训练
- 代码生成能力增强
- 推理能力提升

---

### 前排方案技术细节（Top 12+）

#### 微调方法总结

| 方法 | 使用队伍 | 效果 | 说明 |
|------|---------|------|------|
| **SFT** | 几乎所有队伍 | 基础必备 | 使用 OpenR1 Math, Light-R1, 自定义数据集 |
| **DPO** | 2nd place | 长度优化 | 第 2 阶段减少输出长度，保持推理能力 |
| **TIR** | 1st place | 核心创新 | 训练模型使用外部工具（Python 沙盒） |
| **GRPO** | 9th place | 效率提升（不稳定） | 奖励优化到一定程度后"灾难性偏移" |

**微调方法对比：**

1. **SFT (Supervised Fine-Tuning)** - 基础起点
   - 数据集：OpenR1 Math, Light-R1, 自定义数学问题
   - 目标：学习数学推理模式
   - 阶段：几乎所有队伍的第一阶段

2. **DPO (Direct Preference Optimization)** - 第 2 名使用
   - 目标：减少输出长度（提升效率）
   - 数据构建：基于正确性、长度比、最小长度、相似性
   - 效果：第 2 阶段有效减少输出长度

3. **TIR (Tool-Integrated Reasoning)** - 第 1 名核心
   - 目标：集成外部工具（Python 代码执行）
   - 效果：显著提升计算精度和推理能力
   - 数据：OpenMathReasoning (1.7M TIR 格式)

4. **GRPO (Generative Reinforcement Preference Optimization)** - 第 9 名尝试
   - 目标：用更少 tokens 达到准确结论
   - 奖励函数：格式正确性、余弦相似性、长度奖励
   - 结果：优化到一定程度后出现"灾难性偏移"，需使用早期 checkpoint

#### 推理策略总结

| 策略 | 使用队伍 | 效果 | 说明 |
|------|---------|------|------|
| **Self-consistency** | 1st, 2nd, 3rd, 5th, 11th, 17th | 标配 | 生成多个解，取最频繁答案 |
| **Early Stopping (Sample)** | 2nd | 节省 tokens | 找到答案或生成代码后立即停止 |
| **Early Stopping (Question)** | 1st, 2nd, 3rd, 11th, 17th | 节省时间 | 早期共识出现后停止整个问题生成 |
| **Time Management** | 多个队伍 | 动态资源分配 | 根据剩余时间/问题难度调整参数 |

**Self-consistency 实现：**
```python
def self_consistency_solve(model, problem, n_samples=32):
    """
    自一致性求解：生成多个解，取最频繁答案
    """
    answers = []
    for _ in range(n_samples):
        ans = model.generate(problem)
        answers.append(ans)

    # 多数投票
    from collections import Counter
    counter = Counter(answers)
    return counter.most_common(1)[0][0]
```

**Early Stopping 变体（1st Place）：**
```python
def early_stopping_genselect(model, problem, n_candidates=32):
    """
    第 1 名的 Early Stopping 策略
    如果前 5 个生成中有 4 个相同，取消剩余生成
    """
    answers = []
    for i in range(n_candidates):
        ans = model.generate(problem)
        answers.append(ans)

        # Early stopping check
        if i >= 4:
            from collections import Counter
            counter = Counter(answers)
            most_common_count = counter.most_common(1)[0][1]
            if most_common_count >= 4:
                break  # 提前停止

    return counter.most_common(1)[0][0]
```

#### 推理引擎对比

| 引擎 | 使用队伍 | 优势 | 劣势 |
|------|---------|------|------|
| **vLLM** | 4th, 7th, 8th, 11th, 17th | 最常用，成熟 | 默认配置可能不够优化 |
| **lmdeploy** | 2nd, 5th, 7th | 高吞吐量 | 配置相对复杂 |
| **TensorRT-LLM** | 1st | 最优性能 | 需要专业优化 |

#### 量化技术

| 量化方法 | 使用队伍 | 效果 | 说明 |
|---------|---------|------|------|
| **AWQ 4-bit** | 几乎所有队伍 | 平衡性能和效率 | Activation-aware Weight Quantization |
| **FP8** | 1st place | 进一步优化 | 第 1 名使用 |
| **8-bit KV cache** | 2nd, 7th | 节省内存 | KV cache 量化 |

**AWQ 原理：**
- 不是所有权重都同等重要
- 识别被大激活值乘以的关键权重
- 保护这些关键权重，牺牲不重要的权重
- 结果：更小、更快的模型，性能几乎不变

#### Prompt Engineering 最佳实践

**1. System Prompts（角色设置）：**

```python
# 基础版
"You are a helpful math assistant."

# 更权威（8th Place 风格）
"You are an expert in solving AIMO-level mathematics problems. Your goal is to solve the following problem with high accuracy and minimal reasoning steps."

# 行为 + 模型特定（Fast-Math-R1-14B）
"You are a helpful and harmless assistant. You are Qwen developed by Alibaba. You should think step-by-step..."

# 特定特质（21st Place 教师模型）
"You are the most powerful math expert. Please solve the problems with deep reasoning. You are careful and always recheck your deductions. You will never give an answer directly until you have enough confidence."
```

**2. User Instructions（任务定义）：**

```python
# 核心输出格式（通用）
"""
You must put the final answer in \\boxed{}.
If the final answer is greater than 1000, then take the modulo of 1000.
"""

# 鼓励 CoT（2nd Place）
"""
You excel at reasoning.
Think carefully and thoroughly, avoid duplication.
"""

# 鼓励代码输出（2nd Place）
"""
You excel at coding.
You must provide the python code, avoid redundant analysis.
The answer must be integer.
There is only one answer for each question.
Import necessary libraries.
"""

# 特定行动序列（8th Place）
"""
1. Read the problem carefully and identify the key components.
2. Plan your approach in 1-2 concise steps, focusing on the most efficient method.
3. Execute the solution with clear, logical reasoning, but limit your reasoning to a maximum of 1-2 steps.
4. Verify your answer for correctness by double-checking each step before finalizing.
5. Provide the final answer in a boxed format... and stop further reasoning.
"""
```

**3. Few-Shot / One-Shot Prompts（11th Place）：**

```python
# One-shot prompting 示例
system_prompt = """
You are a Python code assistant. You will be given a mathematical problem that has integer solutions. Your task is to convert this complex math problem into Python code. Let's have Python do the tedious calculations for us!

- There are multiple ways to solve this problem, so find the most efficient one.
- The final answer should be an integer.
- The final answer should be modulo 1000.
- Please return Python code only following the format below.
"""

few_shot_example = """
```python
import math

# Intermediate calculations
result = ...
print(result % 1000)
```
"""
```

**4. Multi-Stage Prompting（17th Place）：**

```python
# Stage 1: Initial thought
stage1_output = model.generate(f"{problem}\nThink step by step:")

# Stage 2: Code generation
stage2_prompt = f"""
Problem: {problem}
Previous thought: {stage1_output}

Please make a short summary of your approach, including python code.
"""
stage2_output = model.generate(stage2_prompt)

# Stage 3: Error fixing (if needed)
if execution_failed:
    stage3_prompt = f"""
Problem: {problem}
Previous code: {stage2_output}
Error: {error_message}

Please fix the code.
"""
    stage3_output = model.generate(stage3_prompt)
```

#### 模型选择建议

**前排方案共识：**

1. **DeepSeek-R1-Distill-Qwen-14B AWQ** 是最受欢迎的选择
   - 4-bit 量化，内存效率高
   - 推理能力强
   - 推理速度快

2. **Qwen2.5-14B** 是第 1 名的基础模型
   - 更强的推理能力
   - 需要更多优化

3. **模型大小选择：**
   - 14B AWQ：最佳平衡（3rd-22nd）
   - 32B AWQ：更大但更慢（20th）
   - 7B AWQ：更快但精度略低

---

## Metadata

| Source | Date | Tags |
|--------|------|------|
| [ARC Prize 2025](https://www.kaggle.com/competitions/arc-prize-2025) | 2025-01-22 | 抽象推理, Refinement Loops, 合成数据, Test-Time Training, TRM, SOAR, CompressARC |
| [AI Mathematical Olympiad Progress Prize 2](https://www.kaggle.com/competitions/ai-mathematical-olympiad-progress-prize-2) | 2025-01-22 | 数学推理, MARIO, 代码执行集成, OpenMathReasoning, GenSelect, 三阶段训练, AoPS |
| [Eedi - Mining Misconceptions in Mathematics](https://www.kaggle.com/competitions/eedi-mining-misconceptions-in-mathematics) | 2024-09 | 教育 AI, 误解检测, 检索+重排, Qwen LLM, Distractor prediction,亲和度预测 |
| [MAP - Charting Student Math Misunderstandings](https://www.kaggle.com/competitions/map-charting-student-math-misunderstandings) | 2025-01-22 | 教育 AI, 误解检测, MiRAGE, Shared-prefix attention, Soft labels, Multi-task learning, CoT distillation, Ensemble fusion, Eedi 后续竞赛 |
