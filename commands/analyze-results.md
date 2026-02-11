---
name: analyze-results
description: Analyze experimental results and generate statistical analysis for paper writing. Triggers data-analyst agent to perform comprehensive analysis following academic standards.
args:
  - name: data_path
    description: Path to experimental results (CSV, JSON, or directory)
    required: false
  - name: analysis_type
    description: Type of analysis (full, comparison, ablation, visualization)
    required: false
    default: full
tags: [Research, Analysis, Statistics, Paper Writing]
---

# Analyze Results Command

快速启动实验结果分析工作流，生成论文级的统计分析和可视化。

## 使用方法

### 基本用法

```bash
/analyze-results
```

交互式模式，会询问数据位置和分析类型。

### 指定数据路径

```bash
/analyze-results path/to/results.csv
```

分析指定的实验结果文件。

### 指定分析类型

```bash
/analyze-results path/to/results/ comparison
```

对指定目录中的结果进行模型对比分析。

## 分析类型

| 类型 | 说明 | 输出 |
|------|------|------|
| `full` | 完整分析（默认） | 统计分析 + 可视化 + Results 草稿 |
| `comparison` | 模型对比 | 性能对比 + 显著性检验 |
| `ablation` | 消融实验 | 组件贡献分析 |
| `visualization` | 可视化生成 | 论文级图表规格 |

## 工作流程

1. **数据定位** - 找到实验结果文件
2. **数据验证** - 检查数据完整性和格式
3. **统计分析** - 执行预检验和假设检验
4. **生成报告** - 创建分析报告和 Results 草稿
5. **可视化规格** - 提供图表生成规格

## 输出文件

命令执行后会生成以下文件：

```
analysis-output/
├── analysis-report.md          # 分析报告（统计摘要、关键发现）
├── results-draft.md            # Results 部分草稿（可直接用于论文）
└── visualization-specs.md      # 可视化规格（图表详细说明）
```

## 示例

### 示例 1：分析单个实验结果

```bash
/analyze-results experiments/model_performance.csv
```

**输出**：
- 基础统计量（均值、标准差、置信区间）
- 与基线的对比分析
- 统计显著性检验结果
- 论文 Results 部分草稿

### 示例 2：对比多个模型

```bash
/analyze-results experiments/comparison/ comparison
```

**输出**：
- 多模型性能对比表
- 统计显著性检验（t-test, ANOVA）
- 效应量分析（Cohen's d, η²）
- 对比可视化规格

### 示例 3：消融实验分析

```bash
/analyze-results experiments/ablation/ ablation
```

**输出**：
- 各组件贡献分析
- 性能下降量化
- 消融实验表格
- 组件重要性排序

## 集成说明

此命令触发 **data-analyst agent**，该 agent 会：
1. 使用 **results-analysis skill** 的方法论
2. 遵循学术写作标准
3. 确保统计正确性和可重现性
4. 生成论文级的输出

## 注意事项

- 确保实验结果包含完整的统计信息（多次运行、随机种子）
- 数据格式应清晰标注（列名、单位、指标方向）
- 对于大型数据集，分析可能需要较长时间
- 生成的 Results 草稿需要人工审核和调整

## 相关资源

- **Skill**: `results-analysis` - 详细的分析方法论
- **Agent**: `data-analyst` - 执行分析的专门 agent
- **References**:
  - `references/statistical-methods.md` - 统计方法指南
  - `references/results-writing-guide.md` - Results 写作规范
  - `references/visualization-best-practices.md` - 可视化最佳实践
