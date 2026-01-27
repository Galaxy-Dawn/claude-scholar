# Konwinski Prize 2025 - 6th Place 实战学习笔记

> 基于 quan16369 的开源解决方案
> GitHub: https://github.com/quan16369/Kaggle-Konwinski-Prize-6th-Place-Solution-
> 排名: 6th/617 (Gold Medal)

---

## 竞赛背景

### 任务描述
- **目标**: 构建 AI Agent，自动修复 GitHub 真实项目中的 bug
- **挑战**: 测试集隐藏，要求模型具有强泛化能力
- **评估**: 严格评分（错误修复重罚，跳过轻罚）
- **难度**: 极高 - 第 1 名仅 7.5% 成功率

### 6th Place 成绩
| 策略 | Private LB | Public LB |
|------|------------|-----------|
| Select-Patch-Verify-Choose | 0.008237 (3 correct, 2 wrong, 115 skipped) | -0.000097 (1 correct, 1 wrong, 69 skipped) |

---

## 核心架构：Select-Patch-Verify-Choose Pipeline

### 完整流程图

```
┌─────────────┐
│   Select    │  分析 bug 报告 + 代码树 → 生成多个选择查询
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Patch     │  基于选定代码段 → 生成候选补丁 (diffs)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Verify    │  多次验证 (VALIDATION_COPY_COUNT) → 评估置信度
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Choose    │  规则评分函数 → 选择最优补丁或跳过
└─────────────┘
```

---

## 关键创新点

### 1. 多次验证 (Multi-attempt Verification)

**问题**: 单次 LLM 自我评估可能产生幻觉

**解决方案**: 强制模型验证每个候选补丁多次

```python
# judgments_aggregated 示例
[
    [],                          # Candidate 1: 无 Yes 票
    [True, True, True],          # Candidate 2: 强信号 (3/3 Yes)
    [],                          # Candidate 3: 无 Yes 票
    [],                          # Candidate 4: 无 Yes 票
    [],                          # Candidate 5: 无 Yes 票
    [True, True, True],          # Candidate 6: 强信号 (3/3 Yes)
    []                           # Candidate 7: 无 Yes 票
]
```

**关键参数**: `VALIDATION_COPY_COUNT`
- 推荐值: 3
- 作用: 只有高一致性的补丁才被认为是可靠的

---

### 2. 基于评分的补丁选择

**核心思想**: 不简单地选择 "Yes" 票最多的补丁，而是使用复杂的评分公式

#### 评分公式

```python
def calculate_patch_score(patch, judgments):
    # 无效或无 Yes 票 → 重罚
    if not is_valid(patch) or judgments.count(True) == 0:
        return -LARGE_PENALTY

    # 基础分 = (Yes 票数)^2 × 权重
    score = (judgments.count(True) ** 2) * 5.0

    # 减去指数级大小惩罚
    score -= (np.exp(len(patch) / 10) - 1)

    return score
```

#### 多标准过滤

补丁只有在满足以下所有条件时才被选择：
1. 正分数
2. 位于 top 百分位（如 top 1%）
3. 显著优于第二名补丁
4. 满足最小 "Yes" 票要求

否则：**SKIP**（确保安全）

---

### 3. 指数级大小惩罚

**目的**: 强制 LLM 找到最简洁、精确的解决方案

**效果**: 避免不必要的修改，减少副作用

**数学表达**:
```
penalty = exp(patch_length / 10) - 1
```

**示例**:
- 10 字符补丁: penalty ≈ 0.72
- 50 字符补丁: penalty ≈ 148
- 100 字符补丁: penalty ≈ 22026

---

## 核心代码实现

### choose_patch_string_optimized 函数

```python
def choose_patch_string_optimized(
    patches: List[str],
    judgments_aggregated: List[List[bool]],
    dry_run_results: List[bool],
    top_percentile: float = 0.01,
    min_yes_votes: int = 3,
    large_penalty: float = 1e6
) -> Optional[int]:
    """
    基于评分的补丁选择函数

    Args:
        patches: 候选补丁列表
        judgments_aggregated: 聚合的验证结果
        dry_run_results: 干运行结果
        top_percentile: 前 N% 考虑
        min_yes_votes: 最小 Yes 票数
        large_penalty: 大惩罚值

    Returns:
        选择的补丁索引，或 None（跳过）
    """
    # 计算每个补丁的分数
    scores = []
    for i, (patch, judgments, dry_run_ok) in enumerate(
        zip(patches, judgments_aggregated, dry_run_results)
    ):
        # 无效或干运行失败 → 重罚
        if not dry_run_ok or not judgments:
            scores.append(-large_penalty)
            continue

        # 计算分数
        yes_votes = sum(judgments)
        if yes_votes == 0:
            scores.append(-large_penalty)
            continue

        # 基础分 = (Yes 票)^2 × 权重
        score = (yes_votes ** 2) * 5.0

        # 指数级大小惩罚
        score -= np.exp(len(patch) / 10) - 1

        scores.append(score)

    # 找到最高分
    max_score = max(scores)
    if max_score <= 0:
        return None  # 跳过

    # top 百分位过滤
    threshold = np.percentile(scores, 100 * (1 - top_percentile))
    if max_score < threshold:
        return None

    # 选择最高分补丁
    best_idx = scores.index(max_score)

    # 检查是否显著优于第二名
    sorted_scores = sorted(scores, reverse=True)
    if len(sorted_scores) > 1 and max_score < sorted_scores[1] * 1.5:
        return None

    # 最小 Yes 票检查
    if sum(judgments_aggregated[best_idx]) < min_yes_votes:
        return None

    return best_idx
```

---

## 性能优化

### 1. 并行处理
- 使用 vLLM 的并行处理
- 并发生成和验证候选补丁

### 2. 早期过滤
- 无效或不可应用的补丁立即丢弃
- 节省计算资源

---

## 经验教训

### ✅ 优势

1. **生成-过滤策略**: 信任 LLM 产生多个解决方案，然后应用严格逻辑过滤
2. **指数大小惩罚**: 强制模型直接解决问题，避免冗余修改
3. **多次验证**: 减少 LLM 幻觉，提高可靠性

### ❌ 局限性和改进方向

#### 1. **强制性测试阶段** (最关键)

**问题**: 仅靠 LLM 验证不够客观

**解决方案** (来自前排方案):
- 要求 LLM 自动生成 F2P (Fail-to-Pass) 测试
- 测试必须在原始代码上失败，在补丁后通过
- 最可靠的 bug 复现和修复确认方式

#### 2. **更智能的选择阶段**

改进方向:
- 优先分析 traceback（如 5th Place 的正则方法）
- 提供现有测试的上下文（如获胜方案的单元测试示例）
- 将补丁格式从 git diff 改为 SEARCH/REPLACE 中间格式

#### 3. **重试机制**

- 当初始测试生成失败时实现重试
- 可以使用更高温度设置增加多样性

#### 4. **增强评分系统**

- 添加修改文件数量的惩罚
- 优先考虑本地化更改

---

## 可复用模板

### Template 1: 多次验证

```python
def multi_attempt_verify(
    patch: str,
    context: str,
    num_attempts: int = 3,
    model: str = "deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct"
) -> List[bool]:
    """
    多次验证补丁

    Returns:
        List of bool: 每个 Yes 票表示验证通过
    """
    judgments = []

    for _ in range(num_attempts):
        response = llm_call(
            model=model,
            messages=[{
                "role": "user",
                "content": f"""请验证以下补丁是否正确修复了 bug：

上下文：
{context}

补丁：
{patch}

请回答 "Yes" 或 "No"。"""
            }]
        )

        judgment = "yes" in response.lower()
        judgments.append(judgment)

    return judgments
```

### Template 2: 补丁评分

```python
def score_patch(
    patch: str,
    yes_votes: int,
    base_weight: float = 5.0,
    size_penalty_scale: float = 10.0
) -> float:
    """
    计算补丁分数

    Args:
        patch: 补丁内容
        yes_votes: Yes 票数
        base_weight: 基础权重
        size_penalty_scale: 大小惩罚缩放

    Returns:
        补丁分数
    """
    # 基础分 = (Yes 票)^2 × 权重
    score = (yes_votes ** 2) * base_weight

    # 指数级大小惩罚
    size_penalty = np.exp(len(patch) / size_penalty_scale) - 1
    score -= size_penalty

    return score
```

### Template 3: Select-Patch-Verify-Choose 完整流程

```python
async def spvc_pipeline(
    bug_report: str,
    code_tree: Dict[str, str],
    model: str = "deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct"
) -> Optional[str]:
    """
    Select-Patch-Verify-Choose 完整流程

    Returns:
        选择的补丁，或 None（跳过）
    """
    # 1. Select
    selections = await select_phase(bug_report, code_tree, model)

    # 2. Patch
    patches = await patch_phase(selections, model)

    # 3. Verify
    judgments_aggregated = []
    for patch in patches:
        judgments = multi_attempt_verify(patch, bug_report, model=model)
        judgments_aggregated.append(judgments)

    # 4. Choose
    best_idx = choose_patch_string_optimized(
        patches=patches,
        judgments_aggregated=judgments_aggregated,
        dry_run_results=[True] * len(patches)  # 假设都通过干运行
    )

    return patches[best_idx] if best_idx is not None else None
```

---

## 相关资源

### GitHub 仓库
- **6th Place Solution**: https://github.com/quan16369/Kaggle-Konwinski-Prize-6th-Place-Solution-

### Kaggle 竞赛
- **竞赛主页**: https://www.kaggle.com/competitions/konwinski-prize
- **官方网站**: https://kprize.ai

### 策略指南
- **Strategy Guide**: https://github.com/raymyers/konwinski-prize-strategy-guide

### 相关基准测试
- **SWE-bench**: https://www.swebench.com/

---

## 总结

6th Place 的方案展示了如何在 **严格的规则约束** 下，通过 **生成-过滤策略** 和 **多次验证机制**，在 **高难度代码修复任务** 中获得优异成绩。

**核心要点**:
1. 质量 > 数量：宁愿跳过也不要错误修复
2. 多次验证：减少 LLM 幻觉
3. 指数惩罚：强制简洁解决方案
4. 严格过滤：确保只有高置信度补丁被选择

**下一步改进**:
- 添加 F2P 测试阶段（最关键）
- 优化选择阶段的上下文提供
- 实现重试机制
- 增强评分系统
