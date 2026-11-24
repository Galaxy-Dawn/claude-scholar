---
description: Check and update AGENTS.md memory based on changes to skills, commands, and plugins.
---

# Update Memory

检查并更新 AGENTS.md 全局记忆文件，确保其内容与 skills、commands、plugins 的源文件保持同步。

## 功能概述

先通过 `opencode debug paths` 确认当前全局配置目录。以下 `<config-dir>` 均指该目录。

AGENTS.md 是一个汇总记忆文件，包含：
- 技能目录结构（来自 `<config-dir>/skills/`）
- 命令列表（来自 `<config-dir>/commands/`）
- 代理配置（来自实际使用的 `opencode.json` 或 `opencode.jsonc`）
- 插件定义（来自 `<config-dir>/plugins/`）

当这些源文件发生变化时，AGENTS.md 需要同步更新。

## 检测逻辑

1. **扫描源文件修改时间**
   - `<config-dir>/skills/**/SKILL.md`
   - `<config-dir>/commands/**/*.md`
   - `<config-dir>/opencode.json(c)`（`agent` 或 `agents` 字段）
   - `<config-dir>/plugins/*.ts`

2. **对比 AGENTS.md 最后修改时间**
   - 如果任意源文件比 AGENTS.md 新 → 需要更新

3. **生成报告**
   - 列出所有变更的源文件
   - 显示需要更新的 AGENTS.md 章节

## 更新流程

### 1. 扫描阶段

```
扫描 Skills: X 个
扫描 Commands: Y 个
扫描 Agents: Z 个 (from opencode.jsonc)
扫描 Plugins: W 个
```

### 2. 对比阶段

```
需要更新的章节:
- [ ] 技能目录结构 (3 个技能变更)
- [ ] 命令列表 (1 个命令新增)
- [ ] 代理配置 (无变更)
- [ ] 插件定义 (2 个插件修改)
```

### 3. 确认更新

询问用户是否执行更新：
```
是否更新 AGENTS.md? (yes/no/diff)
- yes: 执行更新
- no: 取消
- diff: 显示详细差异
```

### 4. 执行更新

- 保留用户手动编辑的内容（如"用户背景"、"技术栈偏好"）
- 仅更新 AUTO-GENERATED 标记的章节
- 更新时间戳

## 使用方式

```
/update-memory          # 检查并提示更新
/update-memory --check  # 仅检查，不更新
/update-memory --force  # 强制更新，不询问
/update-memory --diff   # 显示差异对比
```

## 输出示例

### 检查结果

```
📋 AGENTS.md 记忆状态检查

源文件状态:
✅ Skills: 32 个 (最近修改: ml-paper-writing)
✅ Commands: 52 个 (最近修改: update-readme)
✅ Agents: 14 个 (无变更)
✅ Plugins: 5 个 (最近修改: session-summary)

⚠️ 检测到变更，建议更新 AGENTS.md

是否执行更新? (yes/no/diff)
```

### 更新完成

```
✅ AGENTS.md 已更新

更新内容:
- 技能目录: 同步 32 个技能
- 命令列表: 同步 52 个命令
- 代理配置: 无变更
- 插件定义: 同步 5 个插件
```
