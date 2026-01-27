# ARC Prize 2025
> Last updated: 2026-01-23
> Source count: 1
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

