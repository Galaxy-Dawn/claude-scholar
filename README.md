# Oh My Claude

个人 Claude Code 配置仓库，为学术研究和软件开发优化的完整工作环境。

## 简介

这是一个为 Claude Code 定制的个人配置系统，提供了丰富的技能、命令、代理和钩子，针对以下场景优化：

- **学术研究** - ML/AI 论文写作、文献管理、会议投稿
- **软件开发** - Git 工作流、代码审查、测试驱动开发
- **插件开发** - Skill、Command、Agent、Hook 开发指南
- **项目管理** - 规划文档、代码规范、自动化工作流

## 项目结构

```
.claude/
├── skills/              # 自定义技能（22 个）
├── commands/            # Slash 命令（13 个）
│   └── sc/              # SuperClaude 命令集
├── agents/              # 自定义代理（7 个）
├── hooks/               # 钩子脚本（6 个，JavaScript）
├── plugins/             # 插件系统
│   └── marketplaces/    # 插件市场（4 个）
├── rules/               # 编码规范和配置
├── CLAUDE.md            # 全局配置
└── README.md            # 本文档
```

## 技能 (Skills)

### 开发工作流

- **git-workflow** - Git 工作流规范（Conventional Commits, 分支管理）
- **code-review-excellence** - 代码审查最佳实践
- **bug-detective** - 调试和错误排查（Python, Bash, JS/TS）
- **architecture-design** - ML 项目代码框架和设计模式
- **verification-loop** - 验证循环和测试

### 写作与学术

- **ml-paper-writing** - ML/AI 论文写作辅助
  - 顶会：NeurIPS, ICML, ICLR, ACL, AAAI, COLM
  - 期刊：Nature, Science, Cell, PNAS
  - 内置文献研究和 LaTeX 模板
- **writing-anti-ai** - 去除 AI 写作痕迹（中英双语）
- **doc-coauthoring** - 文档协作工作流
- **daily-paper-generator** - 每日论文生成器
- **latex-conference-template-organizer** - LaTeX 会议模板整理

### 插件开发

- **skill-development** - Skill 开发指南
- **skill-improver** - Skill 改进工具
- **skill-quality-reviewer** - Skill 质量审查
- **command-development** - Slash 命令开发
- **command-name** - 插件结构指南
- **agent-identifier** - Agent 开发配置
- **hook-development** - Hook 开发和事件处理
- **mcp-integration** - MCP 服务器集成

### 工具与实用

- **uv-package-manager** - uv 包管理器使用
- **planning-with-files** - 使用 Markdown 文件进行规划
- **webapp-testing** - 本地 Web 应用测试
- **kaggle-learner** - Kaggle 竞赛学习

## 命令 (Commands)

便捷的 Slash 命令快捷方式：

| 命令 | 功能 |
|------|------|
| `/plan` | 创建实施计划 |
| `/commit` | 提交代码（遵循 Conventional Commits） |
| `/update-github` | 提交并推送到 GitHub |
| `/update-readme` | 更新 README 文档 |
| `/code-review` | 代码审查 |
| `/tdd` | 测试驱动开发工作流 |
| `/build-fix` | 修复构建错误 |
| `/verify` | 验证更改 |
| `/checkpoint` | 创建检查点 |
| `/refactor-clean` | 重构和清理 |
| `/learn` | 从代码中提取可重用模式 |
| `/create_project` | 创建新项目 |
| `/setup-pm` | 配置包管理器（uv/pnpm） |

### SuperClaude 命令集 (`/sc`)

SuperClaude 提供的高级命令集，包括：

- `/sc agent` - Agent 调度
- `/sc analyze` - 代码分析
- `/sc brainstorm` - 交互式头脑风暴
- `/sc build` - 构建项目
- `/sc design` - 系统设计
- `/sc document` - 生成文档
- `/sc git` - Git 操作
- `/sc implement` - 功能实现
- `/sc index` - 项目索引
- `/sc test` - 测试执行
- ... [更多命令](commands/sc/)

## 代理 (Agents)

自动化任务执行的专门代理：

- **architect** - 系统架构设计
- **build-error-resolver** - 构建错误修复
- **code-reviewer** - 代码审查
- **refactor-cleaner** - 代码重构和清理
- **tdd-guide** - TDD 工作流指导
- **kaggle-miner** - Kaggle 方案挖掘
- **paper-miner** - 论文资源挖掘

## 钩子 (Hooks)

自动化工作流的钩子脚本（JavaScript 实现，跨平台支持）：

| 钩子 | 触发时机 | 功能 |
|------|----------|------|
| `session-start.js` | 会话开始 | 初始化环境 |
| `session-summary.js` | 会话结束 | 生成总结 |
| `stop-summary.js` | 会话停止 | 最终总结 |
| `skill-forced-eval.js` | 用户输入 | 强制技能评估 |
| `security-guard.js` | 安全检查 | 防护和验证 |

注：所有 hooks 均使用 Node.js 编写，支持 Windows、macOS、Linux 跨平台运行。

## 插件市场

通过插件市场扩展功能：

- **ai-research-skills** - AI 研究相关技能
- **anthropic-agent-skills** - Anthropic 官方代理
- **claude-plugins-official** - Claude 官方插件
- **superpowers-marketplace** - SuperClaude 超能力集

## 规范与配置

### 编码规范

根据 `rules/coding-style.md`：

- 文件大小：200-400 行
- 不可变配置优先（dataclass frozen）
- 类型提示必需
- Factory & Registry 模式
- Config-Driven 模型

### 代理配置

根据 `rules/agents.md`：

- 可用的代理类型和用途
- 代理调度策略
- 任务分配规则

### 全局配置

根据 `CLAUDE.md`：

- 中文回答，专业术语保留英文
- 计划文档：`/plan` 目录
- 临时文件：`/temp` 目录
- Git 提交：Conventional Commits 规范
- 复杂任务：先交流，后拆解，再实施

## Git 工作流

项目采用以下 Git 规范：

### 提交规范 (Conventional Commits)

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型：**
- `feat` - 新功能
- `fix` - Bug 修复
- `docs` - 文档更新
- `refactor` - 代码重构
- `perf` - 性能优化
- `test` - 测试相关
- `chore` - 其他修改

**示例：**
```
feat(skills): 添加新的论文写作技能

- 支持顶会投稿格式
- 集成 LaTeX 模板

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 分支策略

- `master` - 主分支（可发布）
- `develop` - 开发分支
- `feature/*` - 功能分支
- `bugfix/*` - Bug 修复分支
- `hotfix/*` - 紧急修复分支

### 合并策略

- 功能分支同步：使用 `rebase`
- 合并到主分支：使用 `merge --no-ff`

## 安装使用

### 快速开始

1. **克隆仓库**
   ```bash
   git clone https://github.com/Galaxy-Dawn/oh-my-claude.git ~/.claude
   ```

2. **设置权限**
   ```bash
   chmod +x ~/.claude/hooks/*.sh
   ```

3. **重启 Claude Code**

### 依赖要求

- Claude Code CLI
- Git
- （部分功能需要）uv, Python, Node.js

## 技术栈偏好

### Python 开发

- **包管理**：`uv` - 现代化 Python 包管理器
- **配置管理**：Hydra + OmegaConf
- **模型训练**：Transformers Trainer

### 开发工具

- **类型检查**：mypy
- **代码格式**：ruff
- **测试框架**：pytest

## .gitignore

以下目录和文件被忽略（本地使用，不提交）：

- `ide/` - IDE 临时文件
- `plan/` - 规划文档
- `docs/` - 文档输出
- `cache/`, `debug/`, `logs/` - 缓存和日志
- `session-env/`, `file-history/` - 会话环境
- `projects/`, `temp/` - 临时文件

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 作者

**Galaxy-Dawn**

---

> 为学术研究和软件开发优化的 Claude Code 配置系统
>
> 仓库地址：[https://github.com/Galaxy-Dawn/oh-my-claude](https://github.com/Galaxy-Dawn/oh-my-claude)
