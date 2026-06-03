<div align="center">
  <img src="LOGO.png" alt="Claude Scholar Logo" width="100%"/>

  <p>
    <a href="https://github.com/Galaxy-Dawn/claude-scholar/stargazers"><img src="https://img.shields.io/github/stars/Galaxy-Dawn/claude-scholar?style=flat-square&color=yellow" alt="Stars"/></a>
    <a href="https://github.com/Galaxy-Dawn/claude-scholar/network/members"><img src="https://img.shields.io/github/forks/Galaxy-Dawn/claude-scholar?style=flat-square" alt="Forks"/></a>
    <img src="https://img.shields.io/github/last-commit/Galaxy-Dawn/claude-scholar?style=flat-square" alt="Last Commit"/>
    <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License"/>
    <img src="https://img.shields.io/badge/Kimi_CLI-Compatible-blue?style=flat-square" alt="Kimi Code CLI"/>
  </p>

  <strong>语言</strong>: <a href="README.md">English</a> | <a href="README.zh-CN.md">中文</a> | <a href="README.ja-JP.md">日本語</a>
</div>

> 面向学术研究和软件开发的半自动研究助手，尤其适合计算机科学与 AI 研究者，已适配 [Kimi Code CLI](https://github.com/openai/kimi)，覆盖研究构思、文献综述、实验、结果报告、写作与项目知识库维护。
>
> **分支说明**：这是 Claude Scholar 的 **Kimi Code CLI 版本**。Claude Code 版本请查看 [`main` 分支](https://github.com/Galaxy-Dawn/claude-scholar/tree/main)，OpenCode 版本请查看 [`opencode` 分支](https://github.com/Galaxy-Dawn/claude-scholar/tree/opencode)。


## 最新动态

- **2026-05-14**: **将 `expression-skill` 提升为核心表达层，把 `planning-with-files` 恢复为默认持久规划层，并继续扩展 Nature 写作栈** — 把 [`expression-skill`](./skills/expression-skill/README.md) 明确为汇报、规划、文件操作和多步骤技术任务的结论先行表达纪律；将 [`planning-with-files`](./skills/planning-with-files/SKILL.md) 重新接回默认的落盘规划与进度跟踪工作流，用 `task_plan.md` / `notes.md` 管理复杂任务；引入用于章节起草与论证构建的 [`nature-writing`](./skills/nature-writing/README.md)；将 [`nature-polishing`](./skills/nature-polishing/README.md) 刷新到上游最新 article-pattern 版本；并继续保留 [`nature-response`](./skills/nature-response/README.md) 与 [`nature-data`](./skills/nature-data/README.md) 作为 journal-writing 栈的一部分。
- **2026-05-13**: **证据门槛研究工作流与 `Sources/Papers` 路由完成收紧** — 新增共享的 `research-contract.md`，统一 Evidence Records、claim strength 和 Claim Promotion Gate；将研究构思、Zotero 导入、文献综合、结果报告、论文写作与 rebuttal 工作流接入同一证据契约；并明确项目论文源笔记先放在 `Sources/Papers`，通过证据门槛后再进入 `Knowledge` 或 `Writing`。
- **2026-04-25**: **Kimi Obsidian KB lifecycle 稳定化** — 修复 Kimi 项目 KB workflow 中 rename、archive、purge、sync、lint 的边界问题，并让 repo-local binding metadata 与 Kimi runtime 保持一致。
- **2026-04-24**: **Vault-first Obsidian KB workflow 回植到 Kimi** — 将新的 project-scoped Obsidian knowledge workflow 带到 Kimi 版本，把旧的 memory skills 合并为四个核心 skill，并把项目导航改成人类优先，而不是机器 registry dump。
- **2026-04-22**: **精简常驻核心指令与安全安装生命周期** — 将大型 always-on `CLAUDE.md` / `AGENTS.md` 改为紧凑核心指令，移除非核心默认 agents，新增中文 companion 文件，并加入基于 manifest/state 的卸载流程，确保更新和卸载只处理安装器拥有的文件与配置项。
- **2026-04-15**: **提出 pubfig 与 pubtab 两个 Python package** — 推出了 [`pubfig`](https://github.com/Galaxy-Dawn/pubfig)（用于论文级 scientific figures）和 [`pubtab`](https://github.com/Galaxy-Dawn/pubtab)（用于 publication-ready tables 与 Excel↔LaTeX workflows）两个独立 Python package，为研究者提供更清晰的论文图、benchmark 表、导出控制与最终 QA 生产路径。

<details>
<summary>查看历史更新日志</summary>

- **2026-04-15**: **将 [`publication-chart-skill`](./skills/publication-chart-skill/SKILL.md) 融入 Claude Scholar** — 把 [`pubfig`](https://github.com/Galaxy-Dawn/pubfig) + [`pubtab`](https://github.com/Galaxy-Dawn/pubtab) 封装成 [`publication-chart-skill`](./skills/publication-chart-skill/SKILL.md)，加入仓库，并接到 Claude Scholar 的分析/写作边界里，让论文级图表工作有了明确的交接路径，而不是继续混在通用分析或文本写作技能里。
- **2026-03-31**: **Zotero smart-import 工作流文档完成对齐** — 围绕最新 `zotero-mcp` 的公开能力，系统更新了 Claude Scholar 的研究工作流文档：将 `zotero_add_items_by_identifier` 明确为默认论文导入入口，把 `zotero_reconcile_collection_duplicates` 设为标准导入后清理步骤，更准确地说明了来源感知 PDF cascade，同时把公开工具与内部诊断能力的边界重新讲清楚了。
- **2026-03-31**: **README 上手路径完成刷新** — 明确了 Claude Scholar 尤其适合计算机科学与 AI 研究者，在安装说明后补充了更贴近真实使用的上手场景，进一步收紧了 prerequisite / 分支说明，并把“如果用户本地已有 md 文件，需要手动 merge”这件事写得更明确。
- **2026-03-31**: **安装器与 hook-emulation 行为进一步收口** — 安装器现在会保留已有的本地 `AGENTS.md`，并把仓库版本作为 `AGENTS.scholar.md` sidecar 文件安装；同时默认模拟摘要输出进一步降噪，减少 temp files / uncommitted files 的噪声，同时保留更安全的写入守卫边界。
- **2026-03-31**: **日文文档补齐** — 为主 README 以及 `AGENTS`、`MCP_SETUP`、`OBSIDIAN_SETUP` 补充了日文文档，使 Kimi 分支的多语言文档入口更完整。

- **2026-02-25**: **Kimi Code CLI** 支持 — 新增面向 [OpenAI Kimi Code CLI](https://github.com/openai/kimi) 的 `kimi` 分支，提供 TOML 配置、Kimi 原生 skills / agents，以及 sandbox 安全机制。
- **2026-02-23**: 新增 `setup.sh` 安装脚本 — 面向已有 `~/.kimi-code` 的带备份增量更新，自动备份 Kimi 配置，并以追加方式合并安装器管理的内容
- **2026-02-21**: **OpenCode** 支持 — Claude Scholar 现已支持 [OpenCode](https://github.com/opencode-ai/opencode) 作为替代 CLI；切换到 `opencode` 分支获取兼容配置
- **2026-02-20**: 双语文档 — 维护英文与中文入口文档，便于不同读者阅读
- **2026-02-15**: Zotero MCP 集成 — 新增 `/zotero-review` 和 `/zotero-notes` 命令，更新 `research-ideation` skill 添加 Zotero 集成指南，增强 `literature-reviewer` agent 支持 Zotero MCP 自动论文导入、集合管理、全文阅读和引用导出
- **2026-02-14**: Hooks 优化 — `security-guard` 重构为两层系统（Block + Confirm），`skill-forced-eval` 按 6 类分组并切换为静默扫描模式，`session-start` 限制显示前 5 项，`session-summary` 新增 30 天日志自动清理，`stop-summary` 分别显示新增/修改/删除计数；移除废弃的 shell 脚本（lib/common.sh、lib/platform.sh）
- **2026-02-11**: 大版本更新 — 新增 10 个 skills（research-ideation、results-analysis、citation-verification、review-response、paper-self-review、post-acceptance、daily-coding、frontend-design、ui-ux-pro-max、web-design-reviewer）、7 个 agents、8 个研究工作流命令、2 条新规则（security、experiment-reproducibility）；重构主配置文档；涉及 89 个文件
- **2026-01-26**: 所有 Hooks 重写为跨平台 Node.js 版本；README 完全重写；扩展 ML 论文写作知识库；合并 PR #1（跨平台支持）
- **2026-01-25**: 项目正式开源，v1.0.0 发布，包含 25 个 skills（architecture-design、bug-detective、git-workflow、kaggle-learner、scientific-writing 等）、2 个 agents（paper-miner、kaggle-miner）、30+ 个命令（含 SuperClaude 命令套件）、5 个 Shell Hooks、2 条规则（coding-style、agents）

</details>

## 快速导航

| 部分 | 作用 |
|---|---|
| [为什么使用 Claude Scholar](#为什么使用-claude-scholar) | 快速理解项目定位与适用场景。 |
| [核心工作流](#核心工作流) | 查看从研究构思到发表的分阶段主链路。 |
| [快速开始](#快速开始) | 安全地安装到现有 `~/.kimi-code` 环境。 |
| [上手场景](#上手场景) | 查看安装完成后几种最常见的上手场景。 |
| [平台范围](#平台范围) | 了解这个分支覆盖什么，以及其他版本在哪。 |
| [集成能力](#集成能力) | 了解 Zotero 和 Obsidian 如何接入 Kimi 工作流。 |
| [主要工作流](#主要工作流) | 浏览核心研究与开发工作流。 |
| [支撑工作流](#支撑工作流) | 查看强化主工作流的后台机制。 |
| [文档入口](#文档入口) | 跳转到安装、配置与 setup 文档。 |
| [引用](#引用) | 在论文、报告或项目文档中引用 Claude Scholar。 |

## 为什么使用 Claude Scholar

Claude Scholar **不是**一个试图替代研究者的端到端全自动科研系统。

它的核心思想很简单：

> **人的决策始终在中心，助手负责加速围绕它展开的科研流程。**

这意味着 Kimi 版更适合承担科研中那些高重复、重结构、但仍需要人来把关的部分——例如文献整理、笔记沉淀、实验分析、结果汇报和写作辅助——而真正关键的判断仍然应该由研究者自己做出：

- 哪个问题值得做，
- 哪些论文真的重要，
- 哪些假设值得检验，
- 哪些结果足够有说服力，
- 以及什么该继续、该写、该投，或者该放弃。

换句话说，Claude Scholar 是一个**半自动研究助手**，而不是“全自动科学家”。

## 更适合谁

Claude Scholar 当前尤其适合：

- **计算机科学研究者**：需要在文献、代码、实验和论文写作之间频繁切换；
- **AI / ML researcher**：希望用一套工作流串起构思、实现、分析、报告和 rebuttal；
- **research engineer 与研究生**：希望引入更强的流程结构，但不放弃人的判断；
- **偏软件与计算驱动的学术项目**：能够直接受益于 Zotero、Obsidian、CLI 自动化和可追踪的 project memory。

它当然也可以帮助其他研究场景，但当前这套工作流的设计重心，最贴近计算机科学、AI 以及相邻的 computational research。

## 核心工作流

- **研究构思**：把模糊主题收敛成具体研究问题、研究空白和初步计划。
- **文献工作流**：通过 Zotero 文献集合检索、导入、组织并阅读论文。
- **论文笔记**：把论文转成结构化阅读笔记和可复用论点。
- **知识库沉淀**：将稳定知识写入 Obsidian，并按 `Sources/Papers / Knowledge / Experiments / Results / Results/Reports / Writing / Daily / Maps` 路由整理。
- **实验推进**：跟踪假设、实验线、运行历史、关键发现和下一步动作。
- **严格分析**：使用 `results-analysis` 生成严谨统计、真实科研图和分析产物。
- **结果报告**：使用 `results-report` 生成完整实验后总结报告，并写回 Obsidian。
- **写作与发表**：把稳定结论延伸到综述、论文、rebuttal、演示文稿、海报和传播材料中。

## 快速开始

### 系统要求

- [Kimi Code CLI](https://github.com/openai/kimi)
- Git
- （可选）Python + [uv](https://docs.astral.sh/uv/) 用于 Python 开发
- （可选）[Zotero](https://www.zotero.org/) + [Galaxy-Dawn/zotero-mcp](https://github.com/Galaxy-Dawn/zotero-mcp) 用于文献工作流
- （可选）[Obsidian](https://obsidian.md/) 用于项目知识库工作流

### 选项 1：完整安装（推荐）

```bash
git clone -b kimi https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
bash /tmp/claude-scholar/scripts/setup.sh
```

安装器现在支持**带备份的安全增量更新**：
- 同步仓库托管的 `skills/`、`agents/`、`scripts/` 与 `utils/`
- 当你选择保留现有 provider/model 时，把 Claude Scholar 所需 section 合并进现有 `~/.kimi-code/config.toml`
- 覆盖前自动备份已有的 `config.toml`、`mcp.json` 和托管组件文件
- 如果已存在 `~/.kimi-code/AGENTS.md`，则保留原文件，并把仓库版本另存为 `~/.kimi-code/AGENTS.scholar.md`
- 如果已存在 `~/.kimi-code/AGENTS.zh-CN.md`，则保留原文件，并把仓库中文版本另存为 `~/.kimi-code/AGENTS.zh-CN.scholar.md`
- 在增量更新路径下保留现有 provider / model / API key
- 可选启用模板中已经存在的 Zotero MCP 配置块

**重要 AGENTS 说明**：如果你原来就有自己的 `~/.kimi-code/AGENTS.md`，安装后请查看 `~/.kimi-code/AGENTS.scholar.md` 和 `~/.kimi-code/AGENTS.zh-CN.scholar.md`，并将其中你需要的 Claude Scholar 内容按需 merge 到你自己的文件里；不要假设这个 sidecar 文件会自动生效。

以后做增量更新时：

```bash
cd /tmp/claude-scholar
git pull --ff-only
bash scripts/setup.sh
```

以后如果要卸载：

```bash
cd /tmp/claude-scholar
bash scripts/uninstall.sh
```

安装器会写入：
- `~/.kimi-code/.kimi-scholar-manifest.txt`：记录 Kimi Scholar 实际管理的文件
- `~/.kimi-code/.kimi-scholar-install-state`：记录安全卸载所需的元数据，包括实际安装的 `AGENTS*.md` 目标、托管路径和 MCP server 所有权状态

卸载脚本只会删除 manifest 中明确记录的文件。对于 `config.toml`，它只会删除与安装器模板精确匹配的 Scholar hook 命令和 Scholar 默认值标记；对于 `mcp.json`，它会根据 install-state 删除安装器新增的条目、恢复被安装器覆盖的同名条目，并保留安装后被用户改过的条目，不会根据当前 repo 工作树猜测所有权。

**Windows**：请使用 Git Bash / WSL 运行安装脚本。

### 选项 2：最小化安装

只安装较小的一组研究工作流子集：

```bash
git clone -b kimi https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
mkdir -p ~/.kimi-code/skills ~/.kimi-code/agents
cp -r /tmp/claude-scholar/skills/research-ideation ~/.kimi-code/skills/
cp -r /tmp/claude-scholar/skills/results-analysis ~/.kimi-code/skills/
cp -r /tmp/claude-scholar/skills/results-report ~/.kimi-code/skills/
cp -r /tmp/claude-scholar/skills/ml-paper-writing ~/.kimi-code/skills/
cp -r /tmp/claude-scholar/skills/review-response ~/.kimi-code/skills/
cp -r /tmp/claude-scholar/agents/literature-reviewer ~/.kimi-code/agents/
cp -r /tmp/claude-scholar/agents/paper-miner ~/.kimi-code/agents/
cp /tmp/claude-scholar/AGENTS.md ~/.kimi-code/AGENTS.md
cp /tmp/claude-scholar/AGENTS.zh-CN.md ~/.kimi-code/AGENTS.zh-CN.md
```

**安装后**：最小化/手动安装**不会自动合并** `config.toml`；请根据需要手动复制仓库配置与 setup 文档里的相关 section。如果你已经有自己的 `~/.kimi-code/AGENTS.md`，也请把仓库 `AGENTS.md` 中相关内容按需 merge 到你的文件里，而不是直接覆盖。

### 选项 3：选择性安装

只复制你需要的部分：

```bash
git clone -b kimi https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
cp -r /tmp/claude-scholar/skills/<skill-name> ~/.kimi-code/skills/
cp -r /tmp/claude-scholar/agents/<agent-name> ~/.kimi-code/agents/
cp /tmp/claude-scholar/AGENTS.md ~/.kimi-code/AGENTS.md
cp /tmp/claude-scholar/AGENTS.zh-CN.md ~/.kimi-code/AGENTS.zh-CN.md
```

**安装后**：选择性/手动安装不仅不会自动合并 `config.toml`，如果你已经有自己的 `~/.kimi-code/AGENTS.md`，也请把仓库 `AGENTS.md` 中相关内容按需 merge 到你的文件里，而不是直接覆盖。

**Kimi 使用说明**：
- Kimi **不会**在 `/...` 菜单里列出自定义 skills。
- 优先使用自然语言触发；必要时可显式写 `$skill-name`。

## 上手场景

安装完成后，最简单的上手方式就是直接用自然语言描述你的任务，不需要先把整套系统全部背下来；在 Kimi 里，这些工作流也不依赖你先去记 slash 菜单。下面给几种最常见、也最实用的起步场景。

### 1. 启动一个新的研究主题
**你可以这样说：**
> 帮我围绕[你的研究主题]启动研究。我想先得到一个基于文献的初步计划、关键开放问题，以及接下来最具体的推进步骤。

**Claude Scholar 通常会帮助你：**
- 澄清主题并收敛研究问题，
- 给出值得优先看的文献方向，
- 形成初始研究计划或假设列表，
- 如果你在用 Zotero / Obsidian，还可以把工作进一步路由进去。

### 2. 回顾一个 Zotero 文献集合
**你可以这样说：**
> 帮我回顾我在 Zotero 里关于 brain foundation models 的文献集合，并总结其中的主要方向、研究空白，以及最值得继续推进的下一步。

**典型输出包括：**
- 按主题分组的论文图景，
- 一段简明文献综合，
- research gap 分析，
- 值得继续推进的候选研究方向。

### 3. 分析已经完成的实验结果
**你可以这样说：**
> 帮我分析这个实验目录里的结果，看看不同 runs 之间到底变了什么，并输出一份面向决策的总结。

**典型输出包括：**
- 指标对比，
- ablation 或 error analysis 建议，
- 一份结果总结，说明哪些结论比较稳、哪些还不够稳、下一步该跑什么。

### 4. 起草论文段落或 rebuttal 回复
**你可以这样说：**
> 请基于这个项目当前已有的发现和论文笔记，帮我起草相关工作这一节。

或者：

> 请根据这些审稿人意见，帮我起草一版 rebuttal。

**典型输出包括：**
- 结构化的段落草稿，
- 更清楚的论证链条，
- claims 与 evidence 的对应关系，
- 还需要补验证或补材料的点。

### 使用建议
- 先从一个具体任务开始，而不是一上来让系统“把所有事情都做了”。
- 在 Kimi 里，自然语言是默认入口；只有当你想强制调用某个 skill 时，才需要显式写 `$skill-name`。
- 如果你已经有自己的本地 `AGENTS.md` 或 `AGENTS.zh-CN.md` 文件，请把你需要的 Claude Scholar 内容从 `AGENTS.scholar.md` 或 `AGENTS.zh-CN.scholar.md` 里按需 merge 进去，不要假设 sidecar 文件会自动生效。
- Zotero 和 Obsidian 都不是强制的，但如果你希望得到 durable literature notes 或 project memory，而不是一次性聊天输出，它们会非常有帮助。

## 平台范围

这个分支面向 **Kimi Code CLI**。

- **Kimi Code CLI（`kimi` 分支）** — TOML 配置、AGENTS 驱动的工作约束、以文件系统为核心的 Obsidian 工作流，以及 Kimi 专用安装文档
- **Claude Code（`main` 分支）** — Claude Code 配置、原生 hooks，以及主线文档组织方式
- **OpenCode（`opencode` 分支）** — OpenCode 专用配置与安装路径

三条分支尽量共享研究工作流主线，但平台层的操作方式不同。

## 集成能力

### Zotero

适合这些场景：
- 通过 DOI / arXiv / URL 导入论文
- 按文献集合批量阅读论文
- 通过 Zotero MCP 读取全文
- 生成详细论文笔记与文献综合分析

详见 [MCP_SETUP.zh-CN.md](./MCP_SETUP.zh-CN.md)。

### Obsidian

适合这些场景：
- 维护以文件系统为核心的项目知识库
- 管理 `Sources/Papers/`
- 管理 `Knowledge/`
- 管理 `Experiments/`
- 管理 `Results/`
- 管理 `Results/Reports/`
- 管理 `Writing/` 与 `Daily/`

详见 [OBSIDIAN_SETUP.zh-CN.md](./OBSIDIAN_SETUP.zh-CN.md)。

## 主要工作流

完整学术研究生命周期 —— 从研究构思到发表的 7 个阶段。

> **Kimi 入口说明**：这个分支不依赖仓库级 slash commands。默认入口是自然语言触发；必要时可显式调用 `$results-analysis` 这样的 skill。

### 1. 研究构思（Zotero 集成）

把模糊主题收敛成有文献支持的研究方向。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `research-ideation` | 把模糊主题转成结构化问题、研究空白分析和初步研究计划。 |
| Agent | `literature-reviewer` | 搜索、分类并综合论文，形成可执行的文献图景。 |
| Skill | `zotero-obsidian-bridge` | 将 Zotero 文献集合衔接到详细论文笔记和后续 Obsidian 知识库工作流。 |

**工作方式**
- **5W1H 头脑风暴**：把模糊兴趣收敛成结构化问题。
- **文献检索与导入**：搜索论文、提取 DOI/arXiv/URL、导入 Zotero，并组织到主题文献集合。
- **PDF 与全文**：能挂 PDF 就挂 PDF，能读全文就读全文。
- **研究空白分析**：识别文献、方法、应用、跨学科和时间维度的研究空白。
- **研究问题与规划**：把文献综合结果转成具体问题、初始假设和下一步动作。

**典型产出**
- 文献综述笔记
- 结构化 Zotero 文献集合
- 研究提案或方向草稿

### 2. ML 项目开发

面向实验代码与仓库维护的可持续 ML 开发工作流。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `architecture-design` | 在新增可注册组件或新模块时设计可维护的 ML 项目结构。 |
| Skill | `git-workflow` | 约束更安全的分支协作、提交规范和 Git 习惯。 |
| Skill | `bug-detective` | 系统化排查 stack trace、shell 报错和断裂的代码路径。 |
| Skill | `git-commit` | 在本地生成符合 Conventional Commits 的提交。 |
| Skill | `git-push` | 按 Conventional Commits 完成暂存、提交和推送。 |
| Agent | `code-reviewer` | 审查改动代码的正确性、可维护性和实现质量。 |
| Agent | `tdd-guide` | 当任务明确需要 TDD 路径时，提供聚焦的测试驱动实现指导。 |

**工作方式**
- **结构设计**：在合适场景下使用 Factory / Registry 模式。
- **代码质量**：保持文件可读、带类型提示、配置驱动。
- **问题排查**：系统化处理 shell 失败、trace 与路径问题。
- **Git 纪律**：在快速迭代时保持更安全的分支和提交流程。

### 3. 实验分析

严格实验分析工作流：统计、科研图、分析产物与实验后报告。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `results-analysis` | 生成严格统计、真实科研图和分析附录。 |
| Skill | `results-report` | 把分析产物组织成完整实验后总结报告，明确结论、限制和下一步动作。 |

**工作方式**
- **数据处理**：读取实验日志、metrics 文件和结果目录。
- **统计检验**：在满足前提时执行严格统计检验，并清楚报告不确定性。
- **科研可视化**：生成真实科研图，而不是模糊的绘图建议。
- **消融与比较**：分析组件贡献、性能 tradeoff 与稳定性。
- **实验后报告**：交给 `results-report` 生成面向决策的完整复盘。

**典型产出**
- `analysis-report.md`
- `stats-appendix.md`
- `figure-catalog.md`
- `figures/`
- 写回 Obsidian `Results/Reports/` 的实验报告

### 4. 论文写作

从模板整理到草稿迭代的系统化论文写作工作流。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `ml-paper-writing` | 基于 repo、实验结果和文献上下文撰写投稿导向的 ML/AI 论文。 |
| Skill | [`nature-writing`](./skills/nature-writing/README.md) | 根据 claims、figures、results、notes 或中文草稿起草或重建 Nature 风格的论文章节。 |
| Skill | [`nature-polishing`](./skills/nature-polishing/README.md) | 将稿件内容润色、重组或翻译为更接近 Nature 风格的精炼英文。 |
| Skill | [`nature-response`](./skills/nature-response/README.md) | 为 Nature 系修回撰写、审查或重写逐点 reviewer response。 |
| Skill | [`nature-data`](./skills/nature-data/README.md) | 准备 Nature 风格的 Data Availability、repository plan 和 FAIR 元数据检查。 |
| Skill | `citation-verification` | 检查参考文献、元数据和论断-引用对齐，避免引用错误。 |
| Skill | `writing-anti-ai` | 减少机械化表述，提升清晰度、节奏和更自然的学术语气。 |
| Skill | `latex-conference-template-organizer` | 把混乱的会议模板整理成 Overleaf-ready 写作结构。 |
| Agent | `paper-miner` | 从高质量论文中提炼可复用的写作模式、结构和投稿经验。 |

**工作方式**
- **模板准备**：把会议模板清理成 Overleaf-ready 结构。
- **期刊风格润色**：在需要时加强段落逻辑、hedging 和 section moves，使表达更接近 Nature 风格。
- **审稿回复**：把大修/小修意见组织成可审计的逐点 response package。
- **数据可用性**：准备 Nature 风格的数据仓库方案、dataset citation 和 availability statement。
- **引用核验**：检查参考文献、元数据和论断-引用对齐。
- **系统化写作**：基于 repo、实验结果和文献上下文逐节写作，但未被证据支持的论断必须显式标记。
- **论断台账**：贡献、结果和相关工作对比都应能追溯到证据；否则保留为推测性表述。
- **风格打磨**：减少 AI 痕迹，改善节奏、清晰度和学术语气。

### 5. 论文自审

投稿前的质量保障工作流。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `paper-self-review` | 在投稿前系统检查结构、逻辑、引用、图表和合规性。 |

**工作方式**
- **结构检查**：检查逻辑流、章节平衡和叙事连贯性。
- **逻辑校验**：检查 claim-evidence 对齐和假设清晰度。
- **引用审计**：核对引用准确性与完整性。
- **图表质量**：检查可读性、caption 和可访问性。
- **合规性检查**：检查页数限制、格式与披露要求。

### 6. 投稿与 Rebuttal

投稿准备与审稿回复工作流。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `review-response` | 把审稿意见组织成基于证据的 rebuttal 工作流。 |
| Agent | `rebuttal-writer` | 起草专业、礼貌且结构清晰的 rebuttal 文本。 |

**工作方式**
- **投稿前检查**：确认会议格式、匿名化和所需清单项。
- **审稿意见分析**：把审稿意见分类成可执行问题。
- **回复策略**：决定是 accept、defend、clarify 还是补实验。
- **Rebuttal 写作**：生成结构化、基于证据、语气专业的回复文档。

### 7. 录用后处理

论文录用后的会议准备与研究传播工作流。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `post-acceptance` | 支持论文录用后的 slides、海报和对外传播材料准备。 |

**工作方式**
- **报告准备**：准备 talk 结构和演示文稿指导。
- **海报整理**：整理海报内容层级和版式。
- **传播内容**：生成简明的对外摘要、thread 与录用后材料。

## 支撑工作流

这些工作流运行在主工作流背后，用来增强整体 Kimi 使用体验。

### Obsidian 项目知识库

把 Obsidian 当作项目作用域的稳定知识层，而不是随手堆放笔记的地方。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `obsidian-project-kb-core` | 负责项目级 KB 的初始化、路由、registry、index、daily 和 lifecycle。 |
| Skill | `obsidian-source-ingestion` | 把外部材料写入 `Sources/Papers`、`Sources/Web`、`Sources/Docs`、`Sources/Data`、`Sources/Interviews` 或 `Sources/Notes`。 |
| Skill | `obsidian-literature-workflow` | 管理从 `Sources/Papers` 到 `Knowledge`、`Writing`、`Maps/literature.canvas` 的文献工作流。 |
| Skill | `obsidian-kb-artifacts` | 处理 wikilink、registry 表格、canvas、可选 `.base` 和 link repair 等 Obsidian 原生产物。 |
| Skill | `zotero-obsidian-bridge` | 把 Zotero 文献集合接入项目级论文笔记与文献综合流程。 |

**工作方式**
- 将已有 repo 绑定到 Obsidian vault，
- 把稳定知识路由进 `Sources / Knowledge / Experiments / Results / Results/Reports / Writing / Daily / Maps`，
- 以保守方式维护 `Daily/` 和 repo-local binding metadata，
- 把新的 source material 路由进正确的 canonical note，
- 只有在显式请求时才生成额外的 `.base` 或 canvas。

旧的 `obsidian-project-memory`、`obsidian-project-bootstrap`、`obsidian-experiment-log` 等 Kimi 时代 Obsidian skill shim 已移除。请直接使用 `obsidian-project-kb-core`、`obsidian-source-ingestion`、`obsidian-literature-workflow` 和 `obsidian-kb-artifacts`。

### Kimi 会话约束与 Native Hooks

这个分支使用 Kimi Code CLI 的 hook 配置，把最高价值的会话检查和安全检查接到本地 shell 脚本。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| File | `AGENTS.md` | 编码会话约束、skill 评估规则、安全规则和 Kimi 专用工作流说明。 |
| Hook | `hooks/security-guard.sh` | 在危险命令和敏感文件修改前做安全检查。 |
| Hook | `hooks/session-start.sh` | 在会话开始时显示 repo 状态、skills、TODO 和项目上下文。 |
| Hook | `hooks/skill-forced-eval.sh` | 在用户提示提交前静默扫描应使用的 skill。 |
| Hook | `hooks/session-summary.sh` | 在会话结束时生成工作日志。 |
| Hook | `hooks/stop-summary.sh` | 在 stop 信号出现时生成收尾摘要。 |

**工作方式**
- **会话开始代理**：检查 repo 状态、skills、TODO 和项目上下文。
- **危险操作预检**：在执行危险或不可逆命令前先做 preflight 检查。
- **编辑后检查**：在有意义改动后决定验证需求和最小 Obsidian 写回。
- **会话结束代理**：总结工作并提醒后续维护动作。

### 知识提炼工作流

专门的 agents 会持续从论文和工程方案中提炼可复用知识。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Agent | `paper-miner` | 从高质量论文中提炼可复用写作模式、结构信号和回复策略。 |
| Agent | `kaggle-miner` | 从优秀 Kaggle 工作流中提炼可复用工程实践和解决方案模式。 |

**工作方式**
- 从论文中提炼写作模式、投稿期望和 rebuttal 策略，
- 从 Kaggle 工作流中提炼工程模式和解决方案结构，
- 再把这些知识回流进共享 skills 和 references。

### 技能进化系统

Claude Scholar 也包含一套自我改进的 skill 工作流。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `skill-development` | 创建具备清晰触发条件、结构和渐进展开方式的新 skill。 |
| Skill | `skill-quality-reviewer` | 从内容质量、组织方式、表达风格和结构完整性审查 skill。 |
| Skill | `skill-improver` | 根据结构化改进计划持续优化已有 skills。 |

**工作方式**
- 创建带有清晰触发描述的新 skill，
- 按多个质量维度审查 skill，
- 合并修复建议并持续迭代。

### 表达与汇报约束层

当任务需要结论先行汇报、具体证据、可见风险或紧凑下一步时，使用可复用的沟通表达层。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | [`expression-skill`](./skills/expression-skill/README.md) | 为技术工作、写作、文档、文件操作和多步骤任务提供结论先行、具体、可核查的表达约束。 |
| Skill | [`planning-with-files`](./skills/planning-with-files/SKILL.md) | 让复杂任务把计划、进度与中间发现落到 `task_plan.md`、`notes.md` 和交付文件里，而不是只依赖瞬时对话上下文。 |

**工作方式**
- 先给结论，不先叙述过程，
- 优先使用命令、路径、数量、检查结果和可观察行为，而不是抽象过程词，
- 只有在歧义会改变结果时才追问，
- 尽早暴露风险、不确定性和破坏性边界，
- 对长任务持续给出 step / checkpoint 形式的可见路标，
- 对多步骤任务用 `task_plan.md` 和 `notes.md` 做持久化规划，而不是只依赖瞬时上下文。

## 文档入口

- [MCP_SETUP.zh-CN.md](./MCP_SETUP.zh-CN.md) — Kimi 版 Zotero MCP 配置说明
- [OBSIDIAN_SETUP.zh-CN.md](./OBSIDIAN_SETUP.zh-CN.md) — Obsidian 项目知识库工作流
- [AGENTS.md](./AGENTS.md) — 轻量版 Kimi 核心指令
- [AGENTS.zh-CN.md](./AGENTS.zh-CN.md) — 轻量核心指令的中文 companion 文件
- [README.ja-JP.md](./README.ja-JP.md) — 本 README 的日文版
- [config.toml](./config.toml) — 包含 skills、agents 与 MCP 配置块的 Kimi 模板配置

## 项目规则

Claude Scholar 的 Kimi 版包含以下规则：
- 代码风格
- agent 编排
- 安全约束
- 实验可复现性
- Kimi 专用会话约束

常驻规则主要体现在 `AGENTS.md`；详细工作流保留在仓库附带的 skills 和文档中。

## 贡献

欢迎提交 issue、PR 和工作流改进建议。

如果你想修改 installer、Zotero 工作流、Obsidian 路由或 Kimi 会话约束，建议在提案中说明：
- 用户场景
- 当前限制
- 预期行为
- 兼容性影响

## 引用

如果 Claude Scholar 对你的研究或工程工作流有帮助，你可以按下面方式引用：

```bibtex
@misc{claude_scholar_2026,
  title        = {Claude Scholar: Semi-automated research assistant for academic research and software development},
  author       = {Gaorui Zhang},
  year         = {2026},
  howpublished = {\url{https://github.com/Galaxy-Dawn/claude-scholar}},
  note         = {GitHub repository}
}
```

## 许可证

MIT 许可证。

## 致谢

基于 Kimi Code CLI 工作流构建，并由开源研究工具链持续增强。

### 参考资料

本项目受到社区优秀工作的启发和构建：

- **[everything-claude-code](https://github.com/anthropics/everything-claude-code)** - Claude Code CLI 综合资源
- **[AI-research-SKILLs](https://github.com/zechenzhangAGI/AI-research-SKILLs)** - 研究导向的 skills 与配置模式
- **[kimi](https://github.com/openai/kimi)** - 本分支所依赖的 Kimi Code CLI 基础能力
- **[expression-skill](https://github.com/Galaxy-Dawn/expression-skill)** - 这里复用了其公开的结论先行表达 skill，用于汇报和回应约束
- **[nature-skills](https://github.com/Yuan1z0825/nature-skills)** - 这里统一复用了其 Nature 风格的章节起草、学术润色、审稿回复和数据可用性 skills，并保留来源引用

这些项目共同影响了 Claude Scholar 的研究与工具工作流设计。

---

**面向学术研究、软件开发与可持续项目知识管理。**

仓库：[https://github.com/Galaxy-Dawn/claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar)
