# Oh My Claude Config

个人 Claude Code 配置仓库，包含自定义技能、命令、代理和钩子。

## 简介

这是为 Claude Code 配置的个人工作环境，针对学术研究和软件开发进行了优化。

## 目录结构

```
.claude/
├── skills/          # 自定义技能（30+）
├── commands/        # Slash 命令
├── agents/          # 自定义代理
├── hooks/           # Git 钩子
├── plugins/         # 插件
├── CLAUDE.md        # 全局配置
└── settings.json    # Claude 设置
```

## 主要功能

### 开发相关 Skills

- **git-workflow** - Git 工作流规范（Conventional Commits, 分支管理）
- **bug-detective** - 调试和错误排查（Python, Bash/Zsh, JS/TS）
- **code-review-excellence** - 代码审查最佳实践
- **architecture-design** - ML 项目代码框架和设计模式
- **uv-package-manager** - uv 包管理器使用

### 写作相关 Skills

- **scientific-writing** - 学术论文写作辅助
  - 顶会投稿（NeurIPS, ICML, ICLR, KDD）
  - 高影响期刊（Nature, Science, Cell, PNAS）
- **paper-writer** - 论文结构和写作指导
- **stop-slop** - 移除 AI 写作模式

### Claude Code 开发 Skills

- **skill-development** - Skill 开发指南
- **command-development** - Slash 命令开发
- **agent-identifier** - Agent 开发
- **hook-development** - Hook 开发
- **mcp-integration** - MCP 服务器集成

### 其他 Skills

- **planning-with-files** - 使用 Markdown 文件进行规划
- **doc-coauthoring** - 文档协作工作流
- **chrome-mcp-helper** - Chrome MCP 工具辅助
- **kaggle-learner** - Kaggle 竞赛学习

## 全局配置

根据 `CLAUDE.md`，配置包括：

- 中文回答
- 复杂任务先交流再实施
- 计划文件存放在 `/plan`，临时文件存放在 `/temp`
- Git 提交遵循 Conventional Commits 规范

## Git 工作流

项目采用以下 Git 规范：

- **提交规范**: Conventional Commits
  - Type: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`
  - 示例: `feat(skills): 添加新技能`

- **分支策略**:
  - `master` - 主分支
  - `develop` - 开发分支
  - `feature/*` - 功能分支
  - `bugfix/*` - Bug 修复分支

- **合并策略**:
  - 功能分支同步: `rebase`
  - 合并到主分支: `merge --no-ff`

## 安装使用

1. 克隆仓库到 `~/.claude`：
   ```bash
   git clone https://github.com/Galaxy-Dawn/oh-my-claude.git ~/.claude
   ```

2. 确保 Git 钩子可执行：
   ```bash
   chmod +x ~/.claude/hooks/*.sh
   ```

3. 重启 Claude Code 使配置生效

## 依赖

- Claude Code CLI
- Git
- （部分技能需要）uv, Python, Node.js

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 作者

Galaxy-Dawn

---

> 为学术研究和软件开发优化的 Claude Code 配置
