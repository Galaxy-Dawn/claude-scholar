# Commit Message 详细规范

## Conventional Commits 格式

采用 **Conventional Commits** 规范，Commit Message格式如下：

```
<type>(<scope>): <subject>

<body>

<footer>
```

## 字段说明

| 字段    | 必填 | 说明     |
| :------ | :--- | :------- |
| type    | ✅    | 提交类型 |
| scope   | ❌    | 影响范围 |
| subject | ✅    | 简短描述 |
| body    | ❌    | 详细描述 |
| footer  | ❌    | 脚注信息 |

## Type 类型

| 类型       | 说明     | 示例                                |
| :--------- | :------- | :---------------------------------- |
| `feat`     | 新功能   | `feat(user): 新增用户导出功能`      |
| `fix`      | 修复Bug  | `fix(login): 修复验证码不刷新问题`  |
| `docs`     | 文档更新 | `docs(api): 更新接口文档`           |
| `style`    | 代码格式 | `style: 调整代码缩进`               |
| `refactor` | 重构     | `refactor(utils): 重构日期工具函数` |
| `perf`     | 性能优化 | `perf(list): 优化List渲染性能`      |
| `test`     | 测试相关 | `test(user): 添加用户模块单元测试`  |
| `build`    | 构建相关 | `build: 升级 vite 到 5.0`           |
| `ci`       | CI配置   | `ci: 添加 GitHub Actions`           |
| `chore`    | 其他修改 | `chore: 更新依赖版本`               |
| `revert`   | 回滚提交 | `revert: 回滚 feat(user)`           |

## Scope 范围

Scope 用于说明提交影响的范围，常用的 scope 包括：

- `data` - 数据处理
- `utils` - 工具函数
- `model` - 模型架构
- `config` - 参数配置
- `trainer` - 训练
- `evaluator` - 测评
- `workflow` - 工作流

## Subject 规范

- 使用动词开头：添加、修复、更新、移除、优化
- 不超过50个字符
- 不以句号结尾
- 使用中文或英文，保持一致

### 正确与错误示例

```
# ✅ 正确示例
feat(user): 添加用户导出功能
fix(login): 修复验证码不刷新问题

# ❌ 错误示例
feat(user): 添加用户导出功能。     # 不要句号
feat(user): 用户导出              # 要用动词开头
feat: 添加了一个新的用户导出功能   # 太长
```

## Body 详细描述

当改动较大或需要说明原因时，使用 Body 提供详细描述：

```
feat(user): 添加用户批量导入功能

- 支持 Excel 文件导入
- 支持数据校验和错误提示
- 支持导入进度Show

相关需求: #123
```

## Footer 脚注

用于关联 Issue 或说明破坏性变更：

```
# 关联 Issue
Closes #123, #456

# 破坏性变更
BREAKING CHANGE: 用户接口返回格式变更
旧格式: { data: user }
新格式: { code: 200, data: user, msg: 'success' }
```

## 完整示例

### 简单提交

```bash
git commit -m "feat(user): 添加用户导出功能"
```

### 带 Body 的提交

```bash
git commit -m "fix(login): 修复验证码不刷新问题

原因: 缓存时间设置过长导致验证码一直Show同一张图片
方案: 将缓存时间从5分钟调整为1分钟"
```

### 带 Footer 的提交

```bash
git commit -m "feat(api): 重构用户接口

BREAKING CHANGE: 用户查询接口路径变更
旧路径: /api/user/list
新路径: /api/system/user/list

Closes #789"
```
