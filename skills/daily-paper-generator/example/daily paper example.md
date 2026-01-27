# DeeperBrain: A Neuro-Grounded EEG Foundation Model Towards Universal BCI

## 作者及单位
Jiquan Wang, Sha Zhao, Yangxuan Zhou, Yiming Kang, Shijian Li, Gang Pan
Zhejiang University, College of Computer Science and Technology

## arXiv 链接
https://arxiv.org/abs/2601.06134

**发表日期**: 2026-01-05
**arXiv ID**: 2601.06134
**分类**: cs.LG, q-bio.NC, eess.SP

---

## 中文评语

通用脑机接口的发展受限于 EEG 信号的跨受试和跨任务泛化能力不足。现有基础模型大多采用通用深度学习架构，忽略了 EEG 信号的神经生理学特性和生物物理约束，且在冻结探针评估下效果有限。本研究提出 DeeperBrain，一种神经驱动的 EEG 基础模型，将领域特定的归纳偏差整合到模型设计和学习目标中。在架构层面，该方法包含基于容积传导的通道编码和神经动力学感知的时间编码。在预训练层面，引入双目标策略：掩码 EEG 重建保证局部保真度，神经动力学统计预测以强制与宏观脑状态对齐。实验结果显示，DeeperBrain 在零样本跨受试迁移、跨任务泛化和少样本学习场景下优于现有基础模型。更重要的是，它在严格的冻结探针评估下保持优越效果，验证了将神经科学第一原理嵌入模型能够赋予学习表示通用 BCI 所需的泛化能力。

## English Review

Universal Brain-Computer Interfaces are constrained by the limited cross-subject and cross-task generalization of EEG signals. Most existing foundation models employ generic deep learning architectures that overlook neurophysiological characteristics and biophysical constraints, showing limited efficacy under frozen probing evaluation. This study presents DeeperBrain, a neuro-grounded EEG foundation model that integrates domain-specific inductive biases into both architecture design and learning objectives. The model incorporates volume conduction-based channel encoding and neurodynamics-aware temporal encoding to capture spatial and temporal patterns respectively. For pretraining, this study introduces a dual-objective strategy combining masked EEG reconstruction for local fidelity and neurodynamics statistics prediction to align with macroscopic brain states. Experiments show DeeperBrain outperforms existing foundation models across zero-shot cross-subject transfer, cross-task generalization, and few-shot learning scenarios. The model maintains strong performance under frozen probing evaluation, demonstrating that embedding neuroscientific first principles endows learned representations with the generalization needed for universal BCI.

## 主图

这里需要将论文的主图进行下载并存放。

---

## 论文元数据

| 项目 | 内容 |
|------|------|
| **标题** | DeeperBrain: A Neuro-Grounded EEG Foundation Model Towards Universal BCI |
| **第一作者** | Jiquan Wang |
| **作者列表** | Jiquan Wang, Sha Zhao, Yangxuan Zhou, Yiming Kang, Shijian Li, Gang Pan |
| **第一作者单位** | Zhejiang University, College of Computer Science and Technology |
| **发表日期** | 2026-01-05 |
| **arXiv 链接** | https://arxiv.org/abs/2601.06134 |
| **PDF 链接** | https://arxiv.org/pdf/2601.06134 |
| **分类** | cs.LG, q-bio.NC, eess.SP |

---

## 整合格式

Daily Paper 0126

DeeperBrain: A Neuro-Grounded EEG Foundation Model Towards Universal BCI

https://arxiv.org/abs/2601.06134



通用脑机接口的发展受限于 EEG 信号的跨受试和跨任务泛化能力不足。现有基础模型大多采用通用深度学习架构，忽略了 EEG 信号的神经生理学特性和生物物理约束，且在冻结探针评估下效果有限。本研究提出 DeeperBrain，一种神经驱动的 EEG 基础模型，将领域特定的归纳偏差整合到模型设计和学习目标中。在架构层面，该方法包含基于容积传导的通道编码和神经动力学感知的时间编码。在预训练层面，引入双目标策略：掩码 EEG 重建保证局部保真度，神经动力学统计预测以强制与宏观脑状态对齐。实验结果显示，DeeperBrain 在零样本跨受试迁移、跨任务泛化和少样本学习场景下优于现有基础模型。更重要的是，它在严格的冻结探针评估下保持优越效果，验证了将神经科学第一原理嵌入模型能够赋予学习表示通用 BCI 所需的泛化能力。



Universal Brain-Computer Interfaces are constrained by the limited cross-subject and cross-task generalization of EEG signals. Most existing foundation models employ generic deep learning architectures that overlook neurophysiological characteristics and biophysical constraints, showing limited efficacy under frozen probing evaluation. This study presents DeeperBrain, a neuro-grounded EEG foundation model that integrates domain-specific inductive biases into both architecture design and learning objectives. The model incorporates volume conduction-based channel encoding and neurodynamics-aware temporal encoding to capture spatial and temporal patterns respectively. For pretraining, this study introduces a dual-objective strategy combining masked EEG reconstruction for local fidelity and neurodynamics statistics prediction to align with macroscopic brain states. Experiments show DeeperBrain outperforms existing foundation models across zero-shot cross-subject transfer, cross-task generalization, and few-shot learning scenarios. The model maintains strong performance under frozen probing evaluation, demonstrating that embedding neuroscientific first principles endows learned representations with the generalization needed for universal BCI.

## 附录

**github连接：**未开源

**补充说明**

这篇论文的重要价值在于：

1. **跨学科融合**：将神经科学知识与深度学习结合
2. **可解释性**：神经驱动设计提高了模型的可解释性
3. **泛化能力**：在跨受试、跨任务场景下表现优异
4. **实用价值**：为通用 BCI 系统的开发提供了新方向

**Sources:**

- [arXiv Abstract](https://arxiv.org/abs/2601.06134)
- [arXiv HTML](https://arxiv.org/html/2601.06134v1)
- [Paperverse Review](https://paperverse.io/paper/eabc5d58-8762-4dc9-aaf3-665057852cb7)
