# Claude 配置

## 项目概述

**AI Research Assistant Skills Library** - 面向学术研究的 AI 技能库

**Mission**: 使 Claude 成为 AI 研究的得力助手，从数据处理到模型训练到论文写作，覆盖完整的研究工作流。

---

## 技能目录结构

### 📝 写作相关 (2 skills)

- **scientific-writing**: 学术论文写作辅助，覆盖顶会（NeurIPS, ICML, ICLR, KDD）和高影响期刊（Nature, Science, Cell, PNAS）投稿，提供逻辑分析、反 AI 化写作、审稿人视角润色
- **writing-anti-ai**: 去除 AI 写作痕迹，支持中英文双语，基于维基百科"AI 写作特征"指南，检测并修复夸大象征意义、宣传性语言、肤浅分析、模糊归因、AI 词汇、否定式排比等模式

### 💻 开发相关 (7 skills)

- **git-workflow**: Git 工作流规范（Conventional Commits, 分支管理策略）
- **bug-detective**: 调试和错误排查（Python, Bash/Zsh, JavaScript/TypeScript）
- **code-review-excellence**: 代码审查最佳实践
- **architecture-design**: ML 项目代码框架和设计模式
- **uv-package-manager**: uv 包管理器使用指南
- **code-simplifier**: 代码简化和重构

### 🔌 Claude Code 插件开发 (7 skills)

- **skill-development**: Skill 开发指南
- **command-development**: Slash 命令开发
- **agent-identifier**: Agent 开发和配置
- **hook-development**: Hook 开发和事件处理
- **mcp-integration**: MCP 服务器集成
- **command-name**: 插件结构和组织

### 📊 规划与协作 (2 skills)

- **planning-with-files**: 使用 Markdown 文件进行规划和进度跟踪
- **doc-coauthoring**: 文档协作工作流

### 🧪 其他技能

- **kaggle-learner**: 从 Kaggle 解决方案中学习
- **latex-conference-template-organizer**: LaTeX 会议模板整理
- **webapp-testing**: 本地 Web 应用测试

---

## 全局配置

### 语言设置
- 用中文进行回答
- 专业术语保持英文（如 NeurIPS, RLHF, TDD, Git）
- 不翻译特定名词或名称

### 工作目录规范
- 计划文档：`/plan` 文件夹
- 临时文件：`/temp` 文件夹
- 文件夹不存在时自动创建

### Git 工作流
- 提交规范：Conventional Commits
- 同步到远程仓库

### 任务执行原则
- 复杂任务先交流意见，再拆解实施
- 实施后进行示例测试
- 做好备份，不影响现有功能
- 完成后及时删除临时文件

---

## 用户背景

### 学术背景
- **学历**: 计算机科学 PhD
- **投稿目标**:
  - 顶会：NeurIPS, ICML, ICLR, KDD
  - 高影响期刊：Nature, Science, Cell, PNAS
- **关注点**: 学术写作质量、逻辑连贯性、自然表达

---

## 技术栈偏好

### Python 生态
- **包管理**: `uv` - 现代化 Python 包管理器
- **配置管理**: Hydra + OmegaConf
  - 支持配置组合和覆盖
  - 类型安全的配置访问
- **模型训练**: Transformers Trainer

### Git 规范
- **提交规范**: Conventional Commits
  ```
  Type: feat, fix, docs, style, refactor, perf, test, chore
  Scope: data, model, config, trainer, utils, workflow
  ```
- **分支策略**: master/develop/feature/bugfix/hotfix/release
- **合并策略**:
  - 功能分支用 rebase 同步
  - 用 merge --no-ff 合并

---

## 工作风格

### 任务管理
- 使用 TodoWrite 工具跟踪任务进度
- 复杂任务先规划再执行
- 优先使用已有的 skills 和工具

### 沟通方式
- 不确定时主动询问细节
- 重要操作前先确认再执行
- 遵循 hook 强制流程（当激活时）

### 代码风格
- Python: 遵循 PEP 8
- 注释：使用中文
- 命名：函数和变量使用英文

---

## 命名规范

### Skill 命名
- 格式：kebab-case（小写+连字符）
- 形式：优先使用 gerund form（动词+ing）
- 示例：`scientific-writing`, `git-workflow`, `bug-detective`

### Tags 命名
- 格式：Title Case
- 缩写全大写：TDD, RLHF, NeurIPS, ICLR
- 示例：`[Writing, Research, Academic]`

### 描述规范
- 人称：第三人称
- 内容：包含用途和使用场景
- 示例："为学术论文写作提供指导，覆盖顶会投稿要求"

---

## 任务完成总结

**每次任务完成或用户准备离开时，必须主动提供总结，包含以下内容：**

### 📋 操作回顾
- 列出执行的主要操作
- 修改了哪些文件
- 使用了哪些工具/命令

### 📊 当前状态
- Git 状态（如果在仓库中）：分支、变更文件数
- 文件系统状态：临时文件、新增文件
- 运行状态（如适用）：服务、进程等

### 💡 下一步建议
- 基于实际操作的针对性建议
- 考虑：是否需要提交代码、清理临时文件、测试验证等
- 不要使用通用的"记得备份"建议，除非确实需要

---

## 总结格式示例

```
---
📋 本次操作回顾
1. XXX
2. XXX

📊 当前状态
• XXX

💡 下一步建议
1. XXX
2. XXX
---
```
