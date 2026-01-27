# Claude Scholar

**语言**: [English](README.md) | [中文](README.zh-CN.md)

面向数据科学、AI 研究和学术写作的全面 Claude Code 配置系统。

## 简介

Claude Scholar 是一个生产就绪的 Claude Code CLI 配置系统，专为研究人员、数据科学家和 ML 工程师优化。它提供了技能、命令、代理和钩子，简化从想法到发表的完整研究工作流程。

## 解决的研究工作流痛点

### 1. 自动化执行工作流

跨平台钩子（Node.js）自动化工作流执行：

```
会话开始 → 技能评估 → 会话结束 → 会话停止
```

- **skill-forced-eval** (`skill-forced-eval.js`): 在每次用户提示之前 → 动态扫描所有可用技能（本地 + 插件）→ 强制评估每个技能 → 要求实现前激活 → 确保不遗漏相关技能
- **session-start** (`session-start.js`): 会话开始时 → 显示 Git 状态、待办事项、可用命令、包管理器 → 一目了然地展示项目上下文
- **session-summary** (`session-summary.js`): 会话结束时 → 生成全面的工作日志 → 总结所做的所有更改 → 提供下一步的智能建议
- **stop-summary** (`stop-summary.js`): 会话停止时 → 快速状态检查 → 检测临时文件 → 显示可操作的清理建议

**跨平台**: 所有钩子使用 Node.js（非 shell 脚本），确保 Windows/macOS/Linux 兼容性。

### 2. 论文写作工作流

从想法到发表的完整生命周期：

```
模板准备 → 写作 → 去AI化 → 投稿 → 反驳
```

- **模板准备** (`latex-conference-template-organizer`): 下载官方会议模板 .zip 文件 → 技能提取主文件，删除示例内容 → 输出适合 Overleaf 的干净模板结构
- **写作** (`ml-paper-writing`): 从研究仓库到最终草稿的系统指导 → 包括叙事框架、摘要公式（5句式）、文献搜索与引文验证、分节起草与反馈循环
- **去AI化** (`writing-anti-ai`): 模式检测移除夸大象征、宣传语言、模糊归因 → 添加人性化的声音和变化的节奏 → 支持中英文
- **投稿**: 会议特定检查清单（NeurIPS 16项、ICML 更广泛影响、ICLR LLM 披露）和页数限制执行
- **反驳**: paper-miner 知识库中的策略 → 从成功的会议反驳中提取 → 解决技术问题和额外实验请求

### 3. 代码组织工作流

可维护的 ML 项目结构：

```
项目结构 → 代码风格 → 调试 → Git 工作流
```

- **结构** (`architecture-design`): 模块实例化的 Factory & Registry 模式 → 配置驱动模型仅接受 `cfg` 参数 → 由 `rules/coding-style.md` 强制执行
- **风格** (由 `code-reviewer` agent 强制执行): 最大 200-400 行文件 → 需要类型提示 → 配置使用 `@dataclass(frozen=True)` → 在 4 层嵌套前分割函数
- **调试** (`bug-detective`): Python、Bash/Zsh、JavaScript/TypeScript 的系统性错误检测 → 错误模式匹配 → 堆栈跟踪分析 → 常见反模式识别
- **Git** (`git-workflow`): Conventional Commits 格式 (`feat/scope: message`) → 分支策略（master/develop/feature）→ 使用 `--no-ff` 合并 → 使用 rebase 同步上游更改

### 4. 技能进化系统

3步持续改进循环：

```
skill-development → skill-quality-reviewer → skill-improver
```

1. **开发** (`skill-development`): 创建具有正确 YAML frontmatter 的技能 → 清晰的描述和触发短语 → 渐进式披露（精简的 SKILL.md，详细信息在 `references/`）
2. **审查** (`skill-quality-reviewer`): 4维质量评估 → 描述质量（25%）、内容组织（30%）、写作风格（20%）、结构完整性（25%）→ 生成优先修复的改进计划
3. **改进** (`skill-improver`): 合并建议更改 → 更新文档 → 根据反馈迭代 → 自动读取并应用改进计划

### 5. 知识提取工作流

两个专门的挖掘代理持续提取知识以改进技能：

- **paper-miner** (agent): 分析研究论文（PDF/DOCX/arXiv 链接）→ 提取写作模式、结构见解、会议要求、反驳策略 → 使用分类条目更新 `ml-paper-writing/references/knowledge/`（structure.md、writing-techniques.md、submission-guides.md、review-response.md）
- **kaggle-miner** (agent): 研究获胜的 Kaggle 竞赛解决方案 → 提取工程最佳实践、数据处理管道、模型架构模式 → 将见解输入到 `architecture-design`、`bug-detective` 和相关开发技能

**知识反馈循环**: 每篇分析的论文或解决方案都会丰富知识库，创建一个随您研究进化的自我改进系统。

## 文件结构

```
claude-scholar/
├── hooks/               # 跨平台 JavaScript 钩子（自动化执行）
│   ├── session-start.js         # 会话开始 - 显示 Git 状态、待办事项、命令
│   ├── skill-forced-eval.js     # 每次提示前强制技能评估
│   ├── session-summary.js       # 会话结束 - 生成带有建议的工作日志
│   ├── stop-summary.js          # 会话停止 - 快速状态检查、临时文件检测
│   └── security-guard.js        # 文件操作的安全验证
│
├── skills/              # 22 个专业技能（领域知识 + 工作流）
│   ├── ml-paper-writing/        # 完整论文写作：NeurIPS、ICML、ICLR、ACL、AAAI、COLM
│   │   └── references/
│   │       └── knowledge/        # 从成功论文中提取的模式
│   │       ├── structure.md           # 论文组织模式
│   │       ├── writing-techniques.md  # 句子模板、过渡
│   │       ├── submission-guides.md   # 会议要求（页数限制等）
│   │       └── review-response.md     # 反驳策略
│   │
│   ├── writing-anti-ai/         # 移除 AI 模式：象征主义、宣传语言
│   │   └── references/
│   │       ├── patterns-english.md    # 要移除的英文 AI 模式
│   │       ├── patterns-chinese.md     # 要移除的中文 AI 模式
│   │       └── phrases-to-cut.md        # 要删除的填充短语
│   │
│   ├── architecture-design/     # ML 项目模式：Factory、Registry、配置驱动
│   ├── git-workflow/            # Git 纪律：Conventional Commits、分支
│   ├── bug-detective/           # 调试：Python、Bash、JS/TS 错误模式
│   ├── code-review-excellence/  # 代码审查：安全性、性能、可维护性
│   ├── skill-development/       # 技能创建：YAML、渐进式披露
│   ├── skill-quality-reviewer/  # 技能评估：4维评分
│   ├── skill-improver/          # 技能进化：合并改进
│   ├── kaggle-learner/          # 从 Kaggle 获胜解决方案中学习
│   ├── doc-coauthoring/         # 文档协作工作流
│   ├── latex-conference-template-organizer  # Overleaf 模板清理
│   └── ... （10+ 更多技能）
│
├── commands/            # 30+ 斜杠命令（快速工作流执行）
│   ├── plan.md                  # 带代理委托的实施方案规划
│   ├── commit.md                # Conventional Commits：feat/fix/docs/refactor
│   ├── code-review.md           # 质量和安全审查工作流
│   ├── tdd.md                   # 测试驱动开发：Red-Green-Refactor
│   ├── build-fix.md             # 自动修复构建错误
│   ├── verify.md                # 运行验证循环
│   ├── checkpoint.md            # 保存验证状态
│   ├── refactor-clean.md        # 移除死代码
│   ├── learn.md                 # 从代码中提取模式
│   └── sc/                      # SuperClaude 命令套件（20+ 命令）
│       ├── sc-agent.md           # 代理管理
│       ├── sc-estimate.md       # 开发时间估算
│       ├── sc-improve.md         # 代码改进
│       └── ...
│
├── agents/              # 7 个专业代理（专注任务委托）
│   ├── architect.md             # 系统设计：架构决策
│   ├── code-reviewer.md         # 代码审查：质量、安全、最佳实践
│   ├── tdd-guide.md             # 指导 TDD：测试优先开发
│   ├── paper-miner.md           # 提取论文知识：结构、技巧
│   ├── kaggle-miner.md          # 从 Kaggle 提取工程实践
│   ├── build-error-resolver.md  # 修复构建错误：分析和解决
│   └── refactor-cleaner.md      # 移除死代码：检测和清理
│
├── rules/               # 全局指导原则（始终遵循的约束）
│   ├── coding-style.md          # ML 项目标准：文件大小、不可变性、类型
│   └── agents.md                # 代理编排：何时委托、并行执行
│
├── CLAUDE.md            # 全局配置：项目概述、偏好设置、规则
│
└── README.md            # 此文件 - 概述、安装、功能
```

## 功能亮点

### 技能（21 个）

**写作与学术：**
- `ml-paper-writing` - 顶级会议/期刊的完整论文写作指导
- `writing-anti-ai` - 移除 AI 写作模式（双语支持）
- `doc-coauthoring` - 结构化文档协作工作流
- `latex-conference-template-organizer` - LaTeX 模板管理

**开发：**
- `git-workflow` - Git 最佳实践（Conventional Commits、分支）
- `code-review-excellence` - 代码审查指南
- `bug-detective` - Python、Bash、JS/TS 调试
- `architecture-design` - ML 项目设计模式
- `verification-loop` - 测试和验证

**插件开发：**
- `skill-development` - 技能创建指南
- `skill-improver` - 技能改进工具
- `skill-quality-reviewer` - 质量评估
- `command-development` - 斜杠命令创建
- `agent-identifier` - 代理配置
- `hook-development` - 钩子开发指南
- `mcp-integration` - MCP 服务器集成

**工具：**
- `uv-package-manager` - 现代 Python 包管理
- `planning-with-files` - 基于 Markdown 的规划
- `webapp-testing` - 本地 Web 应用测试
- `kaggle-learner` - 从 Kaggle 解决方案中学习

### 命令（30+）

| 命令 | 用途 |
|---------|---------|
| `/plan` | 创建实施计划 |
| `/commit` | 使用 Conventional Commits 提交 |
| `/code-review` | 执行代码审查 |
| `/tdd` | 测试驱动开发工作流 |
| `/build-fix` | 修复构建错误 |
| `/verify` | 验证更改 |
| `/checkpoint` | 创建检查点 |
| `/refactor-clean` | 重构和清理 |
| `/learn` | 提取可重用模式 |
| `/sc` | SuperClaude 命令套件（20+ 命令）|

### 代理（7 个专业）

- **architect** - 系统架构设计
- **build-error-resolver** - 修复构建错误
- **code-reviewer** - 审查代码质量
- **refactor-cleaner** - 移除死代码
- **tdd-guide** - 指导 TDD 工作流
- **paper-miner** - 提取论文写作知识
- **kaggle-miner** - 提取 Kaggle 工程实践

## 快速开始

### 安装选项

选择适合您需求的安装方式：

#### 选项 1：完整安装（推荐）

数据科学、AI 研究和学术写作的完整设置：

```bash
# 克隆仓库
git clone https://github.com/Galaxy-Dawn/claude-scholar.git ~/.claude

# 重启 Claude Code CLI
```

**包含**：所有 22 个技能、30+ 命令、7 个代理、5 个钩子和项目规则。

#### 选项 2：最小化安装

仅核心钩子和基本技能（加载更快，复杂度更低）：

```bash
# 克隆仓库
git clone https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar

# 仅复制钩子和核心技能
mkdir -p ~/.claude/hooks ~/.claude/skills
cp /tmp/claude-scholar/hooks/*.js ~/.claude/hooks/
cp -r /tmp/claude-scholar/skills/ml-paper-writing ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/writing-anti-ai ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/git-workflow ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/bug-detective ~/.claude/skills/

# 清理
rm -rf /tmp/claude-scholar
```

**包含**：5 个钩子、4 个核心技能。

#### 选项 3：选择性安装

选择和选择特定组件：

```bash
# 克隆仓库
git clone https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
cd /tmp/claude-scholar

# 复制您需要的内容，例如：
# - 仅钩子
cp hooks/*.js ~/.claude/hooks/

# - 特定技能
cp -r skills/latex-conference-template-organizer ~/.claude/skills/
cp -r skills/architecture-design ~/.claude/skills/

# - 特定代理
cp agents/paper-miner.md ~/.claude/agents/

# - 项目规则
cp rules/coding-style.md ~/.claude/rules/
cp rules/agents.md ~/.claude/rules/
```

**推荐用于**：想要自定义配置的高级用户。

### 系统要求

- Claude Code CLI
- Git
- （可选）Node.js（用于钩子）
- （可选）uv、Python（用于 Python 开发）

### 首次运行

安装后，钩子提供自动化工作流辅助：

1. **每次提示**触发 `skill-forced-eval` → 确保考虑适用技能
2. **会话开始**时使用 `session-start` → 显示项目上下文
3. **会话结束**时使用 `session-summary` → 生成带有建议的工作日志
4. **会话停止**时使用 `stop-summary` → 提供状态检查

## 技能进化系统

3 步改进过程确保持续技能进化：

### 第 1 步：开发

使用 `skill-development` 创建结构正确的技能：
- 清晰的描述和用例
- 正确的触发条件
- 全面的文档

### 第 2 步：审查

使用 `skill-quality-reviewer` 评估技能质量：
- 描述质量评分
- 内容组织审查
- 写作风格分析
- 结构完整性检查

### 第 3 步：改进

使用 `skill-improver` 应用改进：
- 合并建议更改
- 更新技能文档
- 根据反馈迭代

### 知识反馈循环

`paper-miner` 和 `kaggle-miner` 代理持续提取：
- 论文写作技巧 → 输入到 `ml-paper-writing`
- 工程实践 → 输入到 `architecture-design`、`bug-detective`

这创建了一个随您研究进化的自我改进系统。

## 项目规则

### 代码风格

由 `rules/coding-style.md` 强制执行：
- **文件大小**：最大 200-400 行
- **不可变性**：配置使用 `@dataclass(frozen=True)`
- **类型提示**：所有函数都需要
- **模式**：所有模块使用 Factory & Registry
- **配置驱动**：模型仅接受 `cfg` 参数

### 代理编排

在 `rules/agents.md` 中定义：
- 可用的代理类型和用途
- 并行任务执行
- 多视角分析

## 贡献

这是个人配置，但欢迎您：
- Fork 并适应您自己的研究
- 通过 issue 提交错误
- 通过 issue 建议改进

## 许可证

MIT 许可证

## 致谢

使用 Claude Code CLI 构建，并由开源社区增强。

### 参考资料

本项目受到社区优秀工作的启发和构建：

- **[everything-claude-code](https://github.com/affaan-m/everything-claude-code)** - Claude Code CLI 的综合资源
- **[AI-research-SKILLs](https://github.com/zechenzhangAGI/AI-research-SKILLs)** - 研究导向的技能和配置

这些项目为 Claude Scholar 的研究导向功能提供了宝贵的见解和基础。

---

**面向数据科学、AI 研究和学术写作。**

仓库：[https://github.com/Galaxy-Dawn/claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar)
