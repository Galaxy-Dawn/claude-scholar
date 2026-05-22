<div align="center">
  <img src="LOGO.png" alt="Claude Scholar Logo" width="100%"/>

  <p>
    <a href="https://github.com/Galaxy-Dawn/claude-scholar/stargazers"><img src="https://img.shields.io/github/stars/Galaxy-Dawn/claude-scholar?style=flat-square&color=yellow" alt="Stars"/></a>
    <a href="https://github.com/Galaxy-Dawn/claude-scholar/network/members"><img src="https://img.shields.io/github/forks/Galaxy-Dawn/claude-scholar?style=flat-square" alt="Forks"/></a>
    <img src="https://img.shields.io/github/last-commit/Galaxy-Dawn/claude-scholar?style=flat-square" alt="Last Commit"/>
    <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License"/>
    <img src="https://img.shields.io/badge/Claude_Code-Compatible-blueviolet?style=flat-square" alt="Claude Code"/>
    <img src="https://img.shields.io/badge/Codex_CLI-Compatible-blue?style=flat-square" alt="Codex CLI"/>
    <img src="https://img.shields.io/badge/OpenCode-Compatible-orange?style=flat-square" alt="OpenCode"/>
  </p>


  <strong>语言</strong>: <a href="README.md">English</a> | <a href="README.zh-CN.md">中文</a> | <a href="README.ja-JP.md">日本語</a>

</div>

> 面向学术研究和软件开发的半自动研究助手，尤其适合计算机科学与 AI 研究者。支持 [Claude Code](https://github.com/anthropics/claude-code)、[Codex CLI](https://github.com/openai/codex) 和 [OpenCode](https://github.com/opencode-ai/opencode)，覆盖文献管理、编码、实验分析、结果报告、写作与项目知识库维护。

  <p><em>分支说明</em>：<code>main</code> 分支对应 Claude Code 工作流。如果你使用 Codex CLI，请查看 <a href="https://github.com/Galaxy-Dawn/claude-scholar/tree/codex"><code>codex</code> 分支</a>；如果你使用 OpenCode，请查看 <a href="https://github.com/Galaxy-Dawn/claude-scholar/tree/opencode"><code>opencode</code> 分支</a>。</p>

## 最新动态

- **2026-05-14**: **将 `expression-skill` 提升为核心表达层，把 `planning-with-files` 恢复为默认持久规划层，并继续扩展 Nature 写作栈** — 把 [`expression-skill`](./skills/expression-skill/README.md) 明确为汇报、规划、文件操作和多步骤技术任务的结论先行表达纪律；将 [`planning-with-files`](./skills/planning-with-files/SKILL.md) 重新接回默认的落盘规划与进度跟踪工作流，用 `task_plan.md` / `notes.md` 管理复杂任务；引入用于章节起草与论证构建的 [`nature-writing`](./skills/nature-writing/README.md)；将 [`nature-polishing`](./skills/nature-polishing/README.md) 刷新到上游最新 article-pattern 版本；并继续保留 [`nature-response`](./skills/nature-response/README.md) 与 [`nature-data`](./skills/nature-data/README.md) 作为 journal-writing 栈的一部分。
- **2026-05-13**: **证据门槛研究工作流与 `Sources/Papers` 路由完成收紧** — 新增共享的 `research-contract.md`，统一 Evidence Records、claim strength 和 Claim Promotion Gate；将研究构思、Zotero 导入、文献综合、结果报告、论文写作与 rebuttal 工作流接入同一证据契约；并明确项目论文源笔记先放在 `Sources/Papers`，通过证据门槛后再进入 `Knowledge` 或 `Writing`。
- **2026-04-24**: **项目级 Obsidian KB 工作流完成合并** — 将 Obsidian 项目知识管理重构为以 vault 为中心的工作流，把旧的重叠记忆技能合并为四个核心技能，保留仓库本地的项目绑定元数据作为运行时层，并把项目导航改成人类优先，而不是机器注册表清单。
- **2026-04-22**: **精简核心指令、裁剪默认 agents、安全安装生命周期与通用论文发现流程** — 将大型常驻 `CLAUDE.md` / `AGENTS.md` 改为紧凑核心指令，裁剪默认 agent 集合并保留主链路所需的核心 agents，新增基于安装状态的安全卸载支持，将 `daily-paper-generator` 扩展为面向通用主题的 arXiv / bioRxiv 检索与 Top 10 -> Top 3 -> Top 1 固定筛选流程。
- **2026-04-15**: **提出 pubfig 与 pubtab 两个 Python package** — 推出了 [`pubfig`](https://github.com/Galaxy-Dawn/pubfig)（用于论文级 scientific figures）和 [`pubtab`](https://github.com/Galaxy-Dawn/pubtab)（用于 publication-ready tables 与 Excel↔LaTeX workflows）两个独立 Python package，为研究者提供更清晰的论文图、benchmark 表、导出控制与最终 QA 生产路径。

<details>
<summary>查看历史更新日志</summary>

- **2026-04-15**: **将 [`publication-chart-skill`](./skills/publication-chart-skill/SKILL.md) 融入 Claude Scholar** — 把 [`pubfig`](https://github.com/Galaxy-Dawn/pubfig) + [`pubtab`](https://github.com/Galaxy-Dawn/pubtab) 封装成 [`publication-chart-skill`](./skills/publication-chart-skill/SKILL.md)，加入仓库，并接到 Claude Scholar 的分析/写作边界里，让论文级图表工作有了明确的交接路径，而不是继续混在通用分析或文本写作技能里。
- **2026-03-31**: **Zotero smart-import 工作流文档完成对齐** — 围绕最新 `zotero-mcp` 的公开能力，系统更新了 Claude Scholar 的研究工作流文档：将 `zotero_add_items_by_identifier` 明确为默认论文导入入口，把 `zotero_reconcile_collection_duplicates` 设为标准导入后清理步骤，更准确地说明了来源感知 PDF cascade，同时把公开工具与内部诊断能力的边界重新讲清楚了。
- **2026-03-31**: **README 上手路径完成刷新** — 明确了 Claude Scholar 尤其适合计算机科学与 AI 研究者，在安装说明后补充了更贴近真实使用的上手场景，进一步收紧了前置条件和分支说明，并把“如果用户本地已有 md 文件，需要手动合并”这件事写得更明确。
- **2026-03-31**: **安装器与 hooks 行为进一步收口** — 安装器现在会保留已有的本地 `CLAUDE.md`，并把仓库版本作为 `CLAUDE.scholar.md` 旁路文件安装；同时默认 hooks 的摘要输出进一步降噪，减少临时文件和未提交文件提示的噪声，同时保留更安全的写入守卫边界。
- **2026-03-31**: **日文文档补齐** — 为主 README 以及 `AGENTS`、`MCP_SETUP`、`OBSIDIAN_SETUP` 补充了日文文档，使 OpenCode 分支的多语言文档入口更完整。

- **2026-02-25**: **Codex CLI** 支持 — 新增 `codex` 分支，支持 [OpenAI Codex CLI](https://github.com/openai/codex)，包含 config.toml、40 个 skills、14 个 agents 和 sandbox 安全机制
- **2026-02-23**: 新增 `setup.sh` 安装脚本 — 面向已有 `~/.opencode` 的带备份增量更新，自动备份 `opencode.jsonc`，以追加方式合并 `agent/mcp/permission/plugin`
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
| [为什么使用 Claude Scholar](#为什么使用-claude-scholar) | 快速理解项目定位和适用场景。 |
| [核心工作流](#核心工作流) | 查看从研究构思到发表的主链路。 |
| [快速开始](#快速开始) | 选择完整、最小或选择性安装方式。 |
| [上手场景](#上手场景) | 查看安装完成后几种最常见的上手场景。 |
| [集成能力](#集成能力) | 了解 Zotero 和 Obsidian 如何接入工作流。 |
| [主要工作流](#主要工作流) | 查看核心研究与开发工作流。 |
| [支撑工作流](#支撑工作流) | 查看支撑主工作流的后台机制。 |
| [文档入口](#文档入口) | 快速跳转到 setup、配置和模板文档。 |
| [引用](#引用) | 在论文、报告或项目文档中引用 Claude Scholar。 |

## 为什么使用 Claude Scholar

Claude Scholar **不是**那种试图替代研究者、追求端到端全自动化科研的系统。

它的核心思想很简单：

> **以人的决策为中心，让助手去加速科研流程，而不是替人做最终判断。**

这意味着 Claude Scholar 更适合承担科研中那些高重复、重结构、但仍需要人来把关的环节，例如文献整理、知识沉淀、实验分析、结果汇报和写作辅助；而真正关键的判断始终应该由研究者自己做出：

- 这个问题值不值得做，
- 哪些文献真正重要，
- 哪些假设值得继续验证，
- 哪些结果足够可信，
- 以及什么应该继续推进、写成论文、投稿，或者及时放弃。

换句话说，Claude Scholar 是一个**以人类决策为中心的半自动研究助手**，而不是一个“全自动科研代理”。

## 更适合谁

Claude Scholar 当前尤其适合：

- **计算机科学研究者**：需要在文献、代码、实验和论文写作之间频繁切换；
- **AI / ML 研究者**：希望用一套工作流串起构思、实现、分析、报告和 rebuttal；
- **研究工程师与研究生**：希望引入更强的流程结构，但不放弃人的判断；
- **偏软件与计算驱动的学术项目**：能够直接受益于 Zotero、Obsidian、CLI 自动化和可追踪的项目记忆。

它当然也可以帮助其他研究场景，但当前这套工作流的设计重心，最贴近计算机科学、AI 以及相邻的计算型研究。

## 核心工作流

Claude Scholar 将研究工作路由为一条可追踪路径：
`问题 -> 证据 -> 实验 -> 分析 -> 论断 -> 写作`。
每个阶段都应该保留：已知什么、不确定什么、下一步该做什么决定。

- **研究构思**：把模糊主题收敛成具体研究问题、研究空白和初步计划。
- **文献工作流**：通过 Zotero 文献集合检索、导入、组织并阅读论文。
- **论文笔记**：把论文转成结构化阅读笔记和可复用论点。
- **知识库沉淀**：将稳定知识写入 Obsidian，并按 `Sources / Knowledge / Experiments / Results / Results/Reports / Writing / Daily / Maps` 路由整理。
- **实验推进**：跟踪假设、实验线、运行历史、关键发现和下一步动作。
- **严格分析**：使用 `results-analysis` 生成严谨统计、真实科研图和分析产物。
- **结果报告**：使用 `results-report` 生成完整实验复盘报告，并写回 Obsidian。
- **写作与发表**：把稳定结论延伸到综述、论文、rebuttal、演示文稿、海报和传播材料中。

## 快速开始

### 系统要求

- [Claude Code](https://github.com/anthropics/claude-code)
- Git
- （可选）Python + [uv](https://docs.astral.sh/uv/) 用于 Python 开发
- （可选）[Zotero](https://www.zotero.org/) + [Galaxy-Dawn/zotero-mcp](https://github.com/Galaxy-Dawn/zotero-mcp) 用于文献工作流
- （可选）[Obsidian](https://obsidian.md/) 用于项目知识库工作流

### 选项 1：完整安装（推荐）

**Linux / macOS**：
```bash
git clone -b antigravity https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
bash /tmp/claude-scholar/scripts/setup.sh
```

**Windows (PowerShell)**：
```powershell
git clone -b antigravity https://github.com/Galaxy-Dawn/claude-scholar.git C:\Temp\claude-scholar
powershell -ExecutionPolicy Bypass -File C:\Temp\claude-scholar\scripts\setup.ps1
```

安装器现在支持**带备份的安全增量更新**：
- 更新仓库托管的 `skills/commands/agents/rules/hooks/scripts/CLAUDE*.md` 直接到插件目录 `~/.gemini/config/plugins/claude-scholar/`
- 将被覆盖的文件备份到 `~/.gemini/config/plugins/claude-scholar/.claude-scholar-backups/<timestamp>/`
- 同时把 `mcp_config.json` 备份为 `mcp_config.json.bak`
- 如果已存在 `~/.gemini/config/plugins/claude-scholar/CLAUDE.md`，则保留原文件，并把仓库版本另存为 `~/.gemini/config/plugins/claude-scholar/CLAUDE.scholar.md`
- 如果已存在 `~/.gemini/config/plugins/claude-scholar/CLAUDE.zh-CN.md`，则保留原文件，并把仓库版本另存为 `~/.gemini/config/plugins/claude-scholar/CLAUDE.zh-CN.scholar.md`
- 保留已有的 `env`、模型/provider 配置、API key、permissions，以及当前 `mcpServers` 的现有取值
- 将所需的 MCP 服务合并到 `~/.gemini/config/mcp_config.json`，而不会替换你现有的全部配置

**重要 CLAUDE 说明**：如果你原来就有自己的 `~/.gemini/config/plugins/claude-scholar/CLAUDE.md` 或 `~/.gemini/config/plugins/claude-scholar/CLAUDE.zh-CN.md`，安装后请查看旁路的 `.scholar.md` 文件，并将其中你需要的 Claude Scholar 内容按需合并到你自己的文件里；不要假设这些旁路文件会自动生效。

以后做增量更新时：

```bash
cd /tmp/claude-scholar  # Windows 下为 C:\Temp\claude-scholar
git pull --ff-only
bash scripts/setup.sh   # Windows 下为 powershell -ExecutionPolicy Bypass -File scripts/setup.ps1
```

以后如果要卸载：

```bash
cd /tmp/claude-scholar
bash scripts/uninstall.sh
```

安装器现在还会写入：
- `~/.gemini/config/plugins/claude-scholar/.claude-scholar-manifest.txt`：记录 Claude Scholar 实际管理的文件
- `~/.gemini/config/plugins/claude-scholar/.claude-scholar-install-state`：记录安全卸载所需的 ownership 元数据

卸载脚本只会删除 install state 中明确记录的文件和 settings 条目，不会再根据当前 repo 工作树去猜测所有权。

### 选项 2：最小化安装

只安装一组较小的研究工作流子集：

```bash
git clone -b antigravity https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
mkdir -p ~/.gemini/config/plugins/claude-scholar/hooks ~/.gemini/config/plugins/claude-scholar/skills
cp /tmp/claude-scholar/hooks/*.js ~/.gemini/config/plugins/claude-scholar/hooks/
cp -r /tmp/claude-scholar/skills/ml-paper-writing ~/.gemini/config/plugins/claude-scholar/skills/
cp -r /tmp/claude-scholar/skills/research-ideation ~/.gemini/config/plugins/claude-scholar/skills/
cp -r /tmp/claude-scholar/skills/results-analysis ~/.gemini/config/plugins/claude-scholar/skills/
cp -r /tmp/claude-scholar/skills/results-report ~/.gemini/config/plugins/claude-scholar/skills/
cp -r /tmp/claude-scholar/skills/review-response ~/.gemini/config/plugins/claude-scholar/skills/
cp -r /tmp/claude-scholar/skills/writing-anti-ai ~/.gemini/config/plugins/claude-scholar/skills/
cp -r /tmp/claude-scholar/skills/git-workflow ~/.gemini/config/plugins/claude-scholar/skills/
cp -r /tmp/claude-scholar/skills/bug-detective ~/.gemini/config/plugins/claude-scholar/skills/
```

**安装后**：最小化/手动安装**不会自动合并** `mcp_config.json`；请按需从 `settings.json.template` 复制你需要的 MCP 条目到 `~/.gemini/config/mcp_config.json`。如果你已经有自己的 `~/.gemini/config/plugins/claude-scholar/CLAUDE.md` 或 `~/.gemini/config/plugins/claude-scholar/CLAUDE.zh-CN.md`，也请把仓库提供的相关内容按需合并到你的文件里，而不是直接覆盖。

### 选项 3：选择性安装

只复制你需要的部分：

```bash
git clone -b antigravity https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
cd /tmp/claude-scholar

cp hooks/*.js ~/.gemini/config/plugins/claude-scholar/hooks/
cp -r skills/latex-conference-template-organizer ~/.gemini/config/plugins/claude-scholar/skills/
cp -r skills/architecture-design ~/.gemini/config/plugins/claude-scholar/skills/
cp agents/paper-miner.md ~/.gemini/config/plugins/claude-scholar/agents/
cp rules/coding-style.md ~/.gemini/config/plugins/claude-scholar/rules/
cp rules/agents.md ~/.gemini/config/plugins/claude-scholar/rules/
```

**安装后**：选择性/手动安装**不会自动合并** `mcp_config.json`；请按需从 `settings.json.template` 复制你需要的 MCP 条目到 `~/.gemini/config/mcp_config.json`。如果你已经有自己的 `~/.gemini/config/plugins/claude-scholar/CLAUDE.md` 或 `~/.gemini/config/plugins/claude-scholar/CLAUDE.zh-CN.md`，也请把仓库提供的相关内容按需合并到你的文件里，而不是直接覆盖。

### 选项 4：插件市场安装

**第一步：安装插件**

```bash
/plugin marketplace add Galaxy-Dawn/claude-scholar
/plugin install claude-scholar@claude-scholar
```

自动加载所有 skills、commands、agents 和 hooks。安装时可选择作用范围：user（所有项目）或 project（单个项目）。

**第二步：安装 Rules（必须）**

Claude Code 插件无法自动分发 rules，需要手动安装：

```bash
git clone -b antigravity https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar

# 用户级（所有项目生效）
mkdir -p ~/.gemini/config/plugins/claude-scholar/rules
cp /tmp/claude-scholar/rules/*.md ~/.gemini/config/plugins/claude-scholar/rules/

# 或项目级（仅当前项目生效）
mkdir -p .claude/rules
cp /tmp/claude-scholar/rules/*.md .claude/rules/
```

**安装后**：插件安装**不会**自动加载 `CLAUDE.md` 或配置 `mcp_config.json`；如果你已经有自己的 `~/.gemini/config/plugins/claude-scholar/CLAUDE.md` 或 `~/.gemini/config/plugins/claude-scholar/CLAUDE.zh-CN.md`，也请把仓库提供的相关内容按需合并到你的文件里，而不是假设插件会自动应用。如需 Zotero MCP 或其他集成，请参阅[集成能力](#集成能力)部分手动设置。

## 上手场景

安装完成后，最简单的上手方式就是直接用自然语言描述你的任务，不需要先把整套系统全部背下来。下面给几种最常见、也最实用的起步场景。

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
- 论断与证据的对应关系，
- 还需要补验证或补材料的点。

### 使用建议
- 先从一个具体任务开始，而不是一上来让系统”把所有事情都做了”。
- 如果你已经有自己的本地 `CLAUDE.md` 文件，请把你需要的 Claude Scholar 内容按需合并进去，不要假设旁路文件会自动生效。
- Zotero 和 Obsidian 都不是强制的，但如果你希望得到可长期复用的文献笔记或项目记忆，而不是一次性聊天输出，它们会非常有帮助。

## 平台支持

Claude Scholar 目前面向以下 CLI 工作流：

- **Claude Code** — 主安装目标
- **Codex CLI** — 支持对应工作流与文档
- **OpenCode** — 作为替代 CLI 支持

顶层目标一致：研究、编码、实验、报告、写作、项目知识库维护。

## 集成能力

### Zotero

适合这些场景：
- 通过 DOI / arXiv / URL 导入论文
- 按 collection 批量阅读论文
- 通过 Zotero MCP 读取全文
- 生成详细论文笔记与文献综合分析

详见 [MCP_SETUP.zh-CN.md](./MCP_SETUP.zh-CN.md)。

### Obsidian

适合这些场景：
- 维护以文件系统为核心的项目知识库
- 管理 `Sources/` 与 `Knowledge/`
- 管理 `Experiments/`
- 管理 `Results/` 与 `Results/Reports/`
- 管理 `Writing/`、`Daily/` 与 `Maps/`

详见 [OBSIDIAN_SETUP.zh-CN.md](./OBSIDIAN_SETUP.zh-CN.md)。

## 主要工作流

完整学术研究生命周期 —— 从研究构思到发表的 7 个阶段。

### 1. 研究构思（Zotero 集成）

从想法生成到文献管理的一体化研究启动流程。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `research-ideation` | 把模糊研究主题收敛成结构化问题、研究空白分析和初始研究计划。 |
| Agent | `literature-reviewer` | 搜索、分类并综合论文，形成可执行的文献图景。 |
| Command | `/research-init` | 从文献检索、Zotero 组织到研究问题卡片；只有通过证据门槛时才生成研究提案草稿。 |
| Command | `/zotero-review` | 对已有 Zotero collection 做结构化文献综述与比较。 |
| Command | `/zotero-notes` | 批量阅读 Zotero collection，并生成结构化论文阅读笔记。 |

**工作方式**
- **5W1H 头脑风暴**：把模糊主题收敛成结构化问题。
- **文献检索与导入**：搜索论文、提取 DOI/arXiv/URL、导入 Zotero，并组织到主题文献集合。
- **PDF 与全文**：能挂 PDF 就挂 PDF，能读全文就读全文，必要时回退到摘要分析。
- **研究空白分析**：识别文献型、方法型、应用型、跨学科型、时间型等不同类型的研究空白。
- **研究问题与规划**：把文献综述进一步转成明确研究问题、初始假设和下一步计划。
- **证据门槛**：在论断进入 `Knowledge`、`Writing` 或研究提案之前，保留弱来源、项目假设和缺失证据。

**典型产出**
- 带有假设、证据需求、证伪条件和下一步动作的研究问题卡片
- 文献综述笔记
- 结构化 Zotero 文献集合
- 证据足够时生成研究提案；否则只生成研究方向或初步整理草稿

### 2. ML 项目开发

面向实验代码的可维护 ML 项目开发工作流。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `architecture-design` | 在新增可注册组件或模块时设计可维护的 ML 项目结构。 |
| Skill | `git-workflow` | 约束分支规范、commit 规范和更安全的协作流程。 |
| Skill | `bug-detective` | 系统化排查 stack trace、shell 报错和代码路径问题。 |
| Agent | `code-reviewer` | 审查改动代码的正确性、可维护性和实现质量。 |
| Agent | `tdd-guide` | 当任务明确需要 TDD 路径时，提供聚焦的测试驱动实现指导。 |
| Command | `/plan` | 在编码前创建或细化实现计划。 |
| Command | `/commit` | 为当前改动生成符合规范的 commit。 |
| Command | `/code-review` | 对当前代码改动执行一次聚焦审查。 |
| Command | `/tdd` | 以小步、测试驱动的方式推进功能实现。 |

**工作方式**
- **结构设计**：在合适场景下使用 Factory / Registry 模式组织 ML 组件。
- **代码质量**：保持文件规模、类型提示与配置驱动设计。
- **问题排查**：系统化处理 stack trace、shell 报错和代码路径问题。
- **Git 纪律**：维持分支策略、commit 规范和更安全的合并/rebase 流程。

### 3. 实验分析

严格实验分析工作流：统计、科研图、分析产物与实验后报告。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `results-analysis` | 生成由严格统计、真实科研图和分析附录组成的严格分析产物包。 |
| Skill | `results-report` | 把分析产物组织成完整实验总结报告，明确结论、限制和下一步动作。 |
| Command | `/analyze-results` | 执行阻塞项优先的实验后工作流：先验证证据，能严格分析时再分析，证据包足够时才生成报告。 |

**工作方式**
- **数据处理**：读取实验日志、metrics 文件和结果目录。
- **阻塞项优先门槛**：先锁定分析单位、主指标、seeds/folds/runs、来源追踪和比较族。
- **统计检验**：在合适前提下执行 t-test / ANOVA / Wilcoxon 等严格统计检验。
- **科研可视化**：生成真实科研图和解释线索，而不是只给模糊的绘图建议。
- **消融与比较**：分析组件贡献、性能取舍和稳定性。
- **实验后报告**：把分析产物包转成完整实验后总结报告，包含结论、限制和下一步动作。

**典型产出**
- `analysis-report.md`
- `stats-appendix.md`
- `figure-catalog.md`
- `figures/`
- 写入 Obsidian `Results/Reports/` 的实验总结报告
- 证据不足时生成阻塞项摘要或审计笔记

### 4. 论文写作

从结构准备到草稿迭代的系统化论文写作工作流。

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
| Command | `/mine-writing-patterns` | 读取论文并把可复用写作知识合并进当前已安装的 paper-miner 写作记忆。 |

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
- **逻辑校验**：检查论断-证据对齐、假设清晰度和论证一致性。
- **论断审计**：检查主要论断是否被证据支持，削弱过强表述，并在证据不足时保留不确定性。
- **引用审计**：检查引用准确性与完整性。
- **图表质量**：检查图注/表注完整性、可读性和可访问性。
- **合规性检查**：检查页数限制、格式和披露要求。

### 6. 投稿与 Rebuttal

投稿准备和审稿回复工作流。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `review-response` | 把审稿意见组织成基于证据的 rebuttal 工作流。 |
| Agent | `rebuttal-writer` | 如果当前运行时可用，可作为起草专业、礼貌且结构清晰 rebuttal 的辅助 agent。 |
| Command | `/rebuttal` | 基于审稿意见和现有证据生成带证据锚点的 rebuttal 草稿，未解决项必须显式标出。 |

**工作方式**
- **投稿前检查**：检查会议/期刊格式、匿名化和清单要求。
- **审稿意见分析**：把审稿意见分类成可执行的问题。
- **回复策略**：决定是接受、反驳、澄清还是补实验。
- **Rebuttal 写作**：生成结构化、基于证据、语气专业的回复文档，并保留证据锚点与未解决项。

### 7. 录用后处理

论文录用后的会议准备与研究传播工作流。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `post-acceptance` | 支持论文录用后的报告、海报和传播材料准备。 |
| Command | `/presentation` | 生成会议报告的结构和讲解指导。 |
| Command | `/poster` | 整理论文内容并生成海报版式与内容指导。 |
| Command | `/promote` | 起草面向外部传播的摘要、帖子或长帖内容。 |

**工作方式**
- **报告准备**：准备报告结构和演示文稿指导。
- **海报整理**：整理海报内容层级和版式。
- **传播内容**：生成社交媒体、博客或简明研究摘要。

## 支撑工作流

这些工作流运行在主工作流背后，用来增强整体使用体验。

### Obsidian 项目知识库

把 Obsidian 当作项目作用域的稳定知识层，而不是随手堆放笔记的地方。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `obsidian-project-kb-core` | 负责项目级 KB 的初始化、路由、注册表、索引、每日记录和生命周期。 |
| Skill | `obsidian-source-ingestion` | 把外部材料写入 `Sources/Papers`、`Sources/Web`、`Sources/Docs`、`Sources/Data`、`Sources/Interviews` 或 `Sources/Notes`。 |
| Skill | `obsidian-literature-workflow` | 管理从 `Sources/Papers` 到 `Knowledge`、`Writing`、`Maps/literature.canvas` 的文献工作流。 |
| Skill | `obsidian-kb-artifacts` | 处理 wikilink、注册表表格、canvas、可选 `.base` 和链接修复等 Obsidian 原生产物。 |
| Command | `/kb-init` | 在 `Research/{project-slug}/` 下初始化以 vault 为中心的 KB。 |
| Command | `/kb-status` | 汇总当前已绑定项目 KB 的状态。 |
| Command | `/kb-ingest` | 将新的来源材料路由到正确的规范位置。 |
| Command | `/kb-log` | 保守更新当天 `Daily/` 和相关项目表面。 |
| Command | `/kb-sync` | 运行确定性的 KB 维护，刷新注册表、索引、每日记录和运行时绑定状态。 |
| Command | `/kb-links` | 修复或增强规范 KB 笔记之间的 wikilink。 |
| Command | `/kb-promote` | 将 Daily 或来源笔记中稳定的内容提升为规范笔记。 |
| Command | `/kb-index` | 重建 `02-Index.md` 这个人类导航页。 |
| Command | `/kb-lint` | 运行确定性的 KB 健康检查并更新 `_system/lint-report.md`。 |
| Command | `/kb-archive` | 归档、分离、清除或重命名 KB 对象，并保持链接与注册表一致。 |
| Command | `/kb-map` | 在默认 literature canvas 之外，按需生成或修复显式请求的 KB 产物。 |
| Command | `/kb-literature-review` | 从 `Sources/Papers` 生成经过证据门槛的文献综合，并写入 `Knowledge`、可选 `Writing` 和 `Maps/literature.canvas`。 |

**工作方式**
- 将已有 repo 绑定到 Obsidian vault
- 把稳定知识路由进 `Sources / Knowledge / Experiments / Results / Results/Reports / Writing / Daily / Maps`
- 以保守方式维护 `Daily/` 和仓库本地绑定元数据
- 把新的来源材料路由进正确的规范笔记
- 防止只有摘要或网页占位来源支撑稳定论断
- 只有在显式请求时才生成额外的 `.base` 或 canvas
- 用 `/kb-sync` 做确定性重同步，用 `/kb-links` 做独立的链接修复

**笔记语言配置**

生成和同步 Obsidian 笔记时，语言按以下优先级解析：
1. 项目配置：`.claude/project-memory/registry.yaml` 中的 `note_language`
2. 环境变量：`OBSIDIAN_NOTE_LANGUAGE`
3. 默认值：`en`

说明：文件名目前仍叫 `registry.yaml`，但其磁盘格式实际上是 JSON。

项目级示例：

```json
{
  "projects": {
    "my-project": {
      "project_id": "my-project",
      "vault_root": "/path/to/vault/Research/my-project",
      "note_language": "zh-CN"
    }
  }
}
```

同步时会同时兼容英文和中文 section heading，因此切换配置后，历史英文/中文笔记都可以继续安全更新。

### 自动化约束工作流

跨平台 hooks 自动执行日常检查与提醒。

**Hook 列表**
- `skill-forced-eval.js`
- `session-start.js`
- `session-summary.js`
- `stop-summary.js`
- `security-guard.js`

**工作方式**
- **用户提问前**：评估当前 prompt 应该触发哪些 skills，并补充相关工作流提示。
- **会话开始时**：显示 Git 状态、可用命令和项目记忆上下文。
- **会话结束或停止时**：总结工作内容，并提醒最小维护动作。
- **安全防护**：拦截灾难性命令，并对危险但合理的操作要求确认。

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

### 知识提炼工作流

专门的 agents 可持续提炼论文和竞赛中的可复用知识。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Agent | `paper-miner` | 从高质量论文中提炼可复用的写作知识、结构模式和投稿经验。 |
| Agent | `kaggle-miner` | 从优秀 Kaggle 工作流中提炼工程实践和解决方案模式。 |

**工作方式**
- 从论文中提炼写作模式、会议要求和 rebuttal 策略
- 从 Kaggle 工作流中提炼工程模式和解决方案结构
- 再把这些知识回流进 skills 与 references 中。

### 技能进化系统

Claude Scholar 也内置了自我改进的 skill 工作流。

| 类型 | 名字 | 一句话解释 |
|---|---|---|
| Skill | `skill-development` | 创建具备清晰触发条件、结构和渐进展开方式的新技能模块。 |
| Skill | `skill-quality-reviewer` | 从内容质量、组织方式、表达风格和结构完整性审查 skill。 |
| Skill | `skill-improver` | 根据结构化改进计划持续优化已有 skills。 |

**工作方式**
- 创建带有清晰触发描述的新 skill
- 按多个质量维度审查 skill
- 合并改进建议并持续迭代

## 文档入口

- [MCP_SETUP.zh-CN.md](./MCP_SETUP.zh-CN.md) — Zotero / 浏览器 MCP 配置
- [OBSIDIAN_SETUP.zh-CN.md](./OBSIDIAN_SETUP.zh-CN.md) — Obsidian 项目知识库工作流
- [CLAUDE.md](./CLAUDE.md) — 轻量版 Claude Code 核心指令
- [CLAUDE.zh-CN.md](./CLAUDE.zh-CN.md) — 轻量核心指令的中文 companion 文件
- [settings.json.template](./settings.json.template) — hooks / plugins / MCP 的可选模板

## 项目规则

Claude Scholar 包含以下方面的项目规则：
- 代码风格
- agent 编排
- 安全约束
- 实验可复现性

这些规则体现在仓库附带的 rules 以及 `CLAUDE.md` 中。

## 贡献

欢迎提交 issue、PR 和工作流改进建议。

如果你想改 installer、Zotero 工作流或 Obsidian 路由，建议在提案中说明：
- 用户场景
- 当前限制
- 预期行为
- 兼容性影响

## 许可证

MIT 许可证。

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

## 致谢

使用 Claude Code CLI 构建，并由开源社区增强。

### 参考资料

本项目受到社区优秀工作的启发和构建：

- **[everything-claude-code](https://github.com/anthropics/everything-claude-code)** - Claude Code CLI 的综合资源
- **[AI-research-SKILLs](https://github.com/zechenzhangAGI/AI-research-SKILLs)** - 研究导向的技能和配置
- **[expression-skill](https://github.com/Galaxy-Dawn/expression-skill)** - 这里复用了其公开的结论先行表达 skill，用于汇报和回应约束
- **[nature-skills](https://github.com/Yuan1z0825/nature-skills)** - 这里统一复用了其 Nature 风格的章节起草、学术润色、审稿回复和数据可用性 skills，并保留来源引用

这些项目为 Claude Scholar 的研究导向功能提供了宝贵的见解和基础。

---

**面向数据科学、AI 研究和学术写作。**

仓库：[https://github.com/Galaxy-Dawn/claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar)
