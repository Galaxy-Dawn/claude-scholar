# Results Analysis Workflow 使用指南

本文档展示如何使用 Results Analysis Workflow 系统（Command → Agent → Skill）进行实验结果分析。

## 系统架构

```
/analyze-results (Command)
    ↓
data-analyst (Agent)
    ↓
results-analysis (Skill)
```

## 快速开始

### 1. 基本使用

最简单的使用方式是直接调用命令：

```bash
/analyze-results path/to/results.csv
```

系统会自动：
1. 触发 data-analyst agent
2. Agent 使用 results-analysis skill 的方法论
3. 生成分析报告和 Results 草稿

### 2. 指定分析类型

```bash
/analyze-results experiments/comparison/ comparison
```

支持的分析类型：
- `full` - 完整分析（默认）
- `comparison` - 模型对比
- `ablation` - 消融实验
- `visualization` - 可视化生成

## 完整工作流示例

### 场景：对比三个模型的性能

假设你有以下实验结果：

```
experiments/
├── baseline_lstm.csv
├── bert_base.csv
└── our_method.csv
```

每个 CSV 文件包含 5 次运行的结果：

```csv
run,accuracy,f1_score,training_time
1,86.2,85.8,2.5
2,86.5,86.1,2.4
3,85.9,85.5,2.6
4,86.3,85.9,2.5
5,86.1,85.7,2.5
```

### Step 1: 执行分析命令

```bash
/analyze-results experiments/ comparison
```

### Step 2: Agent 执行分析

data-analyst agent 会：

1. **读取数据**
   - 定位所有 CSV 文件
   - 验证数据格式和完整性
   - 检查实验设置（5 次运行，随机种子）

2. **统计分析**
   - 计算基础统计量（均值 ± 标准差）
   - 执行预检验（正态性、方差齐性）
   - 进行显著性检验（t-test, ANOVA）
   - 计算效应量（Cohen's d）

3. **生成报告**
   - 创建 `analysis-report.md`
   - 创建 `results-draft.md`
   - 创建 `visualization-specs.md`

### Step 3: 查看输出

#### analysis-report.md

```markdown
# 实验结果分析报告

## 执行摘要

三个模型在准确率上的对比：
- Baseline LSTM: 86.2% ± 0.21%
- BERT-base: 91.3% ± 0.18%
- Our Method: 93.5% ± 0.23%

Our Method 显著优于两个基线方法（p < 0.001）。

## 统计显著性检验

### 预检验
- 正态性检验（Shapiro-Wilk）: 所有组 p > 0.05 ✓
- 方差齐性检验（Levene）: F = 1.23, p = 0.31 ✓

### 主要对比
| 对比 | t-statistic | p-value | Cohen's d |
|------|-------------|---------|-----------|
| Our Method vs Baseline | t(8) = 5.67 | p < 0.001 | d = 2.13 |
| Our Method vs BERT-base | t(8) = 3.21 | p = 0.012 | d = 1.05 |

### 多重比较校正
使用 Bonferroni 校正（α' = 0.017），所有对比仍然显著。
```

#### results-draft.md

```markdown
## Results

### Performance Comparison

Table 1 shows the performance comparison of three models on the text classification task. Our method achieves 93.5% ± 0.23% accuracy, significantly outperforming Baseline LSTM (86.2% ± 0.21%) and BERT-base (91.3% ± 0.18%).

**Table 1**: Model performance comparison. Values are mean ± standard deviation across 5 runs. Bold indicates best result.

| Model | Accuracy (%) | F1 Score (%) | Training Time (h) |
|-------|--------------|--------------|-------------------|
| Baseline LSTM | 86.2 ± 0.21 | 85.8 ± 0.19 | 2.5 ± 0.08 |
| BERT-base | 91.3 ± 0.18 | 90.7 ± 0.16 | 8.5 ± 0.12 |
| **Our Method** | **93.5 ± 0.23** | **92.8 ± 0.21** | **5.2 ± 0.10** |

To verify statistical significance, we performed paired-sample t-tests. Prior to parametric testing, we verified normality using Shapiro-Wilk test (all groups p > 0.05) and homogeneity of variance using Levene's test (F = 1.23, p = 0.31). Results show that our method significantly outperforms Baseline LSTM (t(8) = 5.67, p < 0.001, Cohen's d = 2.13) and BERT-base (t(8) = 3.21, p = 0.012, Cohen's d = 1.05). After Bonferroni correction (α' = 0.017), differences remain significant.
```

#### visualization-specs.md

```markdown
# 可视化规格

## Figure 1: 性能对比柱状图

**数据**:
- X 轴: 模型名称（Baseline LSTM, BERT-base, Our Method）
- Y 轴: 准确率（%）
- 误差条: 标准差

**样式**:
- 格式: PDF（矢量图）
- 配色: Okabe-Ito palette
- 字体: Times New Roman, 10pt
- 图表尺寸: 3.5 inch × 2.5 inch（单栏）

**Caption**:
"Performance comparison of three models. Error bars represent standard deviation across 5 runs. Our method significantly outperforms both baselines (p < 0.001)."
```

## 高级用法

### 消融实验分析

```bash
/analyze-results experiments/ablation/ ablation
```

Agent 会分析各组件的贡献：

```markdown
## 消融实验结果

| 配置 | Accuracy | Δ |
|------|----------|---|
| Full Model | 93.5 | - |
| w/o Attention | 91.2 | -2.3 |
| w/o Layer Norm | 90.8 | -2.7 |
| w/o Positional Encoding | 92.1 | -1.4 |

Layer Norm 对性能贡献最大（-2.7%），其次是 Attention（-2.3%）。
```

### 只生成可视化规格

```bash
/analyze-results experiments/ visualization
```

Agent 只生成可视化规格，不进行统计分析。

## Skill 方法论

Agent 在分析过程中遵循 results-analysis skill 的方法论：

### 1. 统计方法（references/statistical-methods.md）

- 预检验：正态性、方差齐性
- 参数检验：t-test, ANOVA
- 非参数检验：Wilcoxon, Mann-Whitney U
- 多重比较校正：Bonferroni, FDR

### 2. 写作规范（references/results-writing-guide.md）

- IMRaD 结构
- 完整的统计信息报告
- 引导读者观察关键现象
- 客观描述结果

### 3. 可视化最佳实践（references/visualization-best-practices.md）

- 矢量图格式（PDF/EPS）
- 色盲友好配色（Okabe-Ito, Paul Tol）
- 误差条和置信区间
- 黑白打印可读性

### 4. 常见错误避免（references/common-pitfalls.md）

- 不 cherry-pick 结果
- 不 p-hacking
- 报告完整统计信息
- 使用多重比较校正

## 故障排除

### 问题 1: 数据格式不正确

**错误信息**: "无法解析 CSV 文件"

**解决方案**: 确保 CSV 文件包含列名，数据格式正确：
```csv
run,metric1,metric2
1,value1,value2
```

### 问题 2: 样本量过小

**警告信息**: "样本量不足（< 3 次运行）"

**解决方案**: 至少进行 3-5 次实验运行以获得可靠的统计结果。

### 问题 3: 数据不满足正态性假设

**Agent 行为**: 自动切换到非参数检验

**输出**: "数据不满足正态性假设（Shapiro-Wilk, p < 0.05），使用 Mann-Whitney U 检验"

## 总结

Results Analysis Workflow 提供了从实验数据到论文 Results 部分的完整流程：

1. **Command** (`/analyze-results`) - 用户友好的入口
2. **Agent** (`data-analyst`) - 自动化分析执行
3. **Skill** (`results-analysis`) - 学术标准方法论

遵循这个工作流可以确保：
- 统计分析的正确性
- 结果报告的完整性
- 论文写作的规范性
- 可视化的专业性
