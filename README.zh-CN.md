# Claude Scholar

**语言**: [English](README.md) | [中文](README.zh-CN.md)

面向数据科学、AI 研究和学术写作的 Claude Code 配置系统。

## 简介

Claude Scholar 是一套为研究人员、数据科学家和 ML 工程师设计的 Claude Code CLI 配置。它整合了技能、命令、代理和钩子，覆盖从想法到发表的完整研究流程。

## 核心工作流

### 1. 自动化执行

跨平台钩子（Node.js）自动化重复性任务：

```
会话开始 → 技能评估 → 会话结束 → 会话停止
```

- **skill-forced-eval** (`skill-forced-eval.js`): 每次提示前扫描所有可用技能，强制评估并激活相关技能
- **session-start** (`session-start.js`): 会话开始时显示 Git 状态、待办事项和可用命令
- **session-summary** (`session-summary.js`): 会话结束时生成工作日志和下一步建议
- **stop-summary** (`stop-summary.js`): 会话停止时检查临时文件并提供清理建议

跨平台兼容：所有钩子使用 Node.js，支持 Windows/macOS/Linux。

### 2. 论文写作

从想法到发表的完整生命周期：

```
模板准备 → 写作 → 去AI化 → 投稿 → 审稿意见回复
```

- **模板准备** (`latex-conference-template-organizer`): 提取会议模板主文件，删除示例内容，输出适合 Overleaf 的干净结构
- **写作** (`ml-paper-writing`): 从研究仓库到最终草稿的完整指导，包括叙事框架、摘要公式、文献搜索和引文验证
- **去AI化** (`writing-anti-ai`): 移除夸大象征、宣传语言、模糊归因，添加人性化表达
- **投稿**: 会议检查清单（NeurIPS 16项、ICML 更广泛影响、ICLR LLM 披露）和页数限制
- **审稿意见回复**: 从成功会议回复中提取的策略，解决技术问题和额外实验请求

### 3. 代码组织

构建可维护的 ML 项目：

```
项目结构 → 代码风格 → 调试 → Git 工作流
```

- **结构** (`architecture-design`): Factory & Registry 模式，配置驱动模型仅接受 `cfg` 参数
- **风格** (`code-reviewer` agent): 文件最大 200-400 行，必须类型提示，配置使用 `@dataclass(frozen=True)`
- **调试** (`bug-detective`): Python、Bash/Zsh、JavaScript/TypeScript 的系统性错误检测
- **Git** (`git-workflow`): Conventional Commits、分支策略、`--no-ff` 合并、rebase 同步

### 4. 技能进化

3 步持续改进循环：

```
skill-development → skill-quality-reviewer → skill-improver
```

1. **开发**: 创建技能（YAML frontmatter、清晰描述、渐进式披露）
2. **审查**: 4 维质量评估（描述、组织、风格、结构）
3. **改进**: 合并更改、更新文档、根据反馈迭代

### 5. 知识提取

两个挖掘代理持续从实践中学习：

- **paper-miner**: 分析论文（PDF/DOCX/arXiv），提取写作模式、结构见解、会议要求和审稿回复策略
- **kaggle-miner**: 研究获胜的 Kaggle 解决方案，提取工程最佳实践、数据处理管道和模型架构模式

每篇分析的论文或解决方案都会丰富知识库，创建自我改进系统。

## 文件结构

```
claude-scholar/
├── hooks/               # 跨平台 JavaScript 钩子
│   ├── session-start.js         # 会话开始
│   ├── skill-forced-eval.js     # 技能评估
│   ├── session-summary.js       # 会话总结
│   ├── stop-summary.js          # 快速状态检查
│   └── security-guard.js        # 安全验证
│
├── skills/              # 21 个专业技能
│   ├── ml-paper-writing/        # 论文写作（NeurIPS/ICML/ICLR/ACL/AAAI/COLM）
│   │   └── references/knowledge/ # 从成功论文提取的模式
│   ├── writing-anti-ai/         # 移除 AI 写作痕迹
│   ├── architecture-design/     # ML 项目设计模式
│   ├── git-workflow/            # Git 工作流规范
│   ├── bug-detective/           # 调试指南
│   ├── code-review-excellence/  # 代码审查
│   └── ... （15+ 更多技能）
│
├── commands/            # 30+ 斜杠命令
│   ├── plan.md                  # 实施方案规划
│   ├── commit.md                # Conventional Commits 提交
│   ├── code-review.md           # 代码审查
│   ├── tdd.md                   # 测试驱动开发
│   └── sc/                      # SuperClaude 命令套件
│
├── agents/              # 7 个专业代理
│   ├── architect.md             # 系统架构设计
│   ├── code-reviewer.md         # 代码审查
│   ├── paper-miner.md           # 提取论文知识
│   └── ...
│
├── rules/               # 全局指导原则
│   ├── coding-style.md          # ML 项目代码标准
│   └── agents.md                # 代理编排规则
│
└── CLAUDE.md            # 全局配置
```

## 功能概览

### 技能（21 个）

**写作与学术：**
- `ml-paper-writing` - 顶级会议/期刊论文写作指导
- `writing-anti-ai` - 移除 AI 写作模式（中英文）
- `doc-coauthoring` - 文档协作工作流
- `latex-conference-template-organizer` - LaTeX 模板管理

**开发：**
- `git-workflow` - Git 最佳实践
- `code-review-excellence` - 代码审查指南
- `bug-detective` - Python、Bash、JS/TS 调试
- `architecture-design` - ML 项目设计模式

**插件开发：**
- `skill-development` - 技能创建
- `skill-improver` - 技能改进
- `skill-quality-reviewer` - 质量评估
- `command-development` - 命令创建
- `agent-identifier` - 代理配置
- `hook-development` - 钩子开发
- `mcp-integration` - MCP 服务器集成

**工具：**
- `uv-package-manager` - Python 包管理
- `planning-with-files` - Markdown 规划
- `webapp-testing` - Web 应用测试
- `kaggle-learner` - Kaggle 解决方案学习

### 命令（30+）

| 命令 | 用途 |
|---------|---------|
| `/plan` | 创建实施计划 |
| `/commit` | Conventional Commits 提交 |
| `/code-review` | 代码审查 |
| `/tdd` | 测试驱动开发 |
| `/build-fix` | 修复构建错误 |
| `/sc` | SuperClaude 命令套件 |

### 代理（7 个）

- **architect** - 系统架构
- **build-error-resolver** - 构建错误
- **code-reviewer** - 代码审查
- **refactor-cleaner** - 死代码清理
- **tdd-guide** - TDD 指导
- **paper-miner** - 论文知识提取
- **kaggle-miner** - Kaggle 实践提取

## 快速开始

### 安装方式

#### 方式 1：完整安装（推荐）

```bash
git clone https://github.com/Galaxy-Dawn/claude-scholar.git ~/.claude
```

包含所有 21 个技能、30+ 命令、7 个代理、5 个钩子和项目规则。

#### 方式 2：最小化安装

```bash
git clone https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar

mkdir -p ~/.claude/hooks ~/.claude/skills
cp /tmp/claude-scholar/hooks/*.js ~/.claude/hooks/
cp -r /tmp/claude-scholar/skills/ml-paper-writing ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/writing-anti-ai ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/git-workflow ~/.claude/skills/
cp -r /tmp/claude-scholar/skills/bug-detective ~/.claude/skills/

rm -rf /tmp/claude-scholar
```

包含 5 个钩子、4 个核心技能。

#### 方式 3：选择性安装

```bash
git clone https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
cd /tmp/claude-scholar

# 按需复制
cp hooks/*.js ~/.claude/hooks/
cp -r skills/latex-conference-template-organizer ~/.claude/skills/
cp agents/paper-miner.md ~/.claude/agents/
cp rules/coding-style.md ~/.claude/rules/
```

### 系统要求

- Claude Code CLI
- Git
- （可选）Node.js
- （可选）uv、Python

## 项目规则

### 代码风格

`rules/coding-style.md` 强制执行：
- 文件最大 200-400 行
- 配置使用 `@dataclass(frozen=True)`
- 所有函数需要类型提示
- 模块使用 Factory & Registry 模式
- 模型仅接受 `cfg` 参数

### 代理编排

`rules/agents.md` 定义：
- 代理类型和用途
- 并行任务执行
- 多视角分析

## 贡献

欢迎：
- Fork 并适配到你的研究
- 提交 issue 报告问题
- 提交 issue 建议改进

## 许可证

MIT

## 致谢

本项目受以下项目启发：
- **[everything-claude-code](https://github.com/affaan-m/everything-claude-code)** - Claude Code CLI 资源
- **[AI-research-SKILLs](https://github.com/zechenzhangAGI/AI-research-SKILLs)** - 研究导向技能

---

**面向数据科学、AI 研究和学术写作**

仓库：[https://github.com/Galaxy-Dawn/claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar)
