# Obsidian 项目知识库配置指南

Kimi Scholar 内置了 Obsidian 研究知识库工作流，不需要 MCP，也不需要 API key。

## 这套工作流提供什么

Obsidian 在这里不是单纯的论文库，而是研究项目的默认知识层，可以统一沉淀：

- 稳定的项目背景与研究问题
- 论文笔记与文献综合
- 实验 runbook 与结果总结
- 每日研究日志、scratch notes 与同步队列
- 草稿、slides、proposal、rebuttal 等写作资产
- 不应继续留在主工作面的历史知识

## Requirements

### Required
- 一个本地 Obsidian vault 路径
- 通过环境变量设置 `OBSIDIAN_VAULT_PATH`，或在 bootstrap 时显式传入

### Optional
- 安装并打开 Obsidian Desktop，便于跳转与查看
- 可用的 `obsidian` CLI，用于 open/search/daily 等辅助操作
- `OBSIDIAN_VAULT_NAME`，便于生成更干净的 `obsidian://` 链接和 CLI targeting

## 内置 skills

Kimi Scholar 内置了面向项目作用域的 Obsidian KB 工作流。

默认主线最相关的是：

- `obsidian-project-kb-core`
- `obsidian-source-ingestion`
- `obsidian-literature-workflow`
- `obsidian-kb-artifacts`
- `defuddle`

默认工作流不依赖 `.base`、MCP 或 API 服务。默认自动维护的图谱产物只有 `Maps/literature.canvas`；其他 `.base` 视图或项目/实验 canvas 都是 explicit-only。

## 默认行为

当 Kimi Scholar 运行在一个包含 `.kimi-code/project-memory/registry.yaml` 的仓库里时，应默认把这个仓库视为已经绑定到 Obsidian 项目知识库，并在任务过程中自动维护它。

如果仓库还没有绑定，但看起来像研究项目（例如包含 `.git`、`README.md`、`docs/`、`notes/`、`plan/`、`results/`、`outputs/`、`src/` 或 `scripts/`），Kimi Scholar 应自动 bootstrap 一个项目知识库。

## Vault 中的默认目录结构

```text
Research/{project-slug}/
  00-Hub.md
  01-Plan.md
  02-Index.md
  Sources/
    Papers/
    Web/
    Docs/
    Data/
    Interviews/
    Notes/
  Knowledge/
  Experiments/
  Results/
    Reports/
  Writing/
  Daily/
  Maps/
  Archive/
  _system/
    registry.md
    schema.md
    lint-report.md
```

常见生成文件包括：

- `02-Index.md`
- `_system/registry.md`
- `_system/schema.md`
- `_system/lint-report.md`
- `.kimi-code/project-memory/{project_id}.md`
- 文献工作流需要时生成 `Maps/literature.canvas`

## Repo-local binding metadata

每个研究仓库都会在本地维护：

```text
.kimi-code/project-memory/
  registry.yaml
  {project_id}.md
```

- `registry.yaml` 存 repo ↔ vault 的绑定关系
- `{project_id}.md` 存 assistant-facing 的运行时项目记忆

## 笔记语言

生成和同步笔记时，语言按以下优先级解析：
1. `.kimi-code/project-memory/registry.yaml` 中的项目配置
2. 环境变量 `OBSIDIAN_NOTE_LANGUAGE`
3. 默认 `en`

注意：`registry.yaml` 仍然只是 repo-local runtime binding 文件。项目内真正可见的 source of truth 仍然是 `_system/registry.md`。

支持的值：
- `en`
- `zh-CN`

## Kimi 中的主工作流

Kimi 不假设 Claude Code 风格的 slash commands。请通过自然语言请求配合对应 skill / helper script 来完成同一套 KB 工作流：

- 用 `obsidian-project-kb-core` 初始化或导入项目 KB
- 用 `obsidian-source-ingestion` 把外部材料路由到 `Sources/*`
- 通过 `skills/obsidian-project-kb-core/scripts/project_kb.py` 运行确定性维护
- 用 `obsidian-kb-artifacts` 修复 wikilink 和派生 artifact
- 用 `obsidian-literature-workflow` 从 `Sources/Papers` 生成文献综合
- 用 lifecycle helpers 执行 archive、purge、rename、detach、rebuild

## 已绑定仓库的最小维护面

当仓库已经通过 `.kimi-code/project-memory/registry.yaml` 绑定时，Kimi Scholar 应保持保守维护：

- 只要研究状态发生变化，就检查 `Daily/YYYY-MM-DD.md`
- 只有项目顶层状态真正变化时才更新 `00-Hub.md`
- 只要项目状态变化，就更新 `.kimi-code/project-memory/{project_id}.md`
- `Knowledge/`、`Experiments/`、`Results/`、`Writing/` 默认保持 agent-first，而不是每轮都自动重写

## 可选的 Obsidian CLI 安装

官方 Obsidian CLI 是内置在较新的桌面版安装器里的。要使用 `obsidian ...` 命令：

1. 使用支持 CLI 注册的 Obsidian Desktop 版本。
2. 在 Obsidian Desktop 中打开 `Settings -> General -> Advanced`。
3. 打开 **Command line interface**。
4. 在 macOS 上确保 `/Applications/Obsidian.app/Contents/MacOS` 已加入 `PATH`（例如写入 `~/.zprofile`）。
5. 重启终端后验证：

```bash
obsidian help
obsidian search query="diffusion" limit=5
```

如果提示 `Command line interface is not enabled`，通常说明 shell 路径已经配置好，但 Obsidian 应用内的开关还没打开。

## Lifecycle actions

### Detach
- 停止自动同步
- 保留 vault 内容
- 保留 project memory 文件

### Archive
- **note archive**：把 canonical note 移到 `Research/{project-slug}/Archive/`
- **project archive**：把整个项目移到 `Research/_archived/{project-slug}-{date}/`
- archive 会保留历史记录；project archive 会同时禁用同步

### Purge
- 永久删除 binding、project memory 和 vault 中的项目目录
- 只有在用户明确要求永久删除时才使用

## 可选的 CLI 与 URI 用法

Kimi Scholar 可选使用官方 Obsidian CLI 与 URI：

- CLI 文档：<https://help.obsidian.md/cli>
- URI 文档：<https://help.obsidian.md/uri>

## Troubleshooting

| 问题 | 解决方式 |
|------|----------|
| Bootstrap 缺少 vault path | 设置 `OBSIDIAN_VAULT_PATH` 或显式传入 vault path |
| 项目反复重新导入 | 检查 `.kimi-code/project-memory/registry.yaml` 是否存在且 repo root 正确 |
| vault 里仍出现旧目录拓扑 | 那通常来自旧文档或旧项目生成；当前默认结构以上述目录为准，默认只自动维护 `Maps/literature.canvas` |
| CLI 命令失败 | 检查 `Settings -> General -> Advanced -> Command line interface` 是否已打开；否则继续使用 filesystem-only sync |
| “删除项目知识” 看起来过于危险 | 优先使用 archive 或 detach；purge 仅用于永久删除 |
