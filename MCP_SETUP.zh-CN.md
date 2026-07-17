# MCP 服务器配置指南

Claude Scholar 依赖 MCP（Model Context Protocol）服务器提供扩展功能。MCP 服务器**不包含**在本仓库中 — 用户需自行安装和配置。

## 必需的 MCP 服务器

### 1. Zotero MCP（研究工作流）

**使用者**: `literature-reviewer` 代理、`research-ideation` skill 及研究工作流技能（通过自然语言触发）

**包**: [Galaxy-Dawn/zotero-mcp](https://github.com/Galaxy-Dawn/zotero-mcp) — 可自动识别本地 Zotero desktop 与 Web API 模式；远程访问和写操作时需要 Web 凭证。

#### 功能

| 类别 | 工具 |
|------|------|
| **导入** | `zotero_add_items_by_identifier`、`zotero_add_items_by_doi`、`zotero_add_items_by_arxiv`、`zotero_add_item_by_url` |
| **读取** | `zotero_get_collections`、`zotero_get_collection_items`、`zotero_search_items`、`zotero_semantic_search` |
| **更新** | `zotero_update_item`、`zotero_update_note`、`zotero_create_collection`、`zotero_move_items_to_collection`、`zotero_reconcile_collection_duplicates` |
| **删除** | `zotero_delete_items`（移至回收站）、`zotero_delete_collection` |
| **PDF** | `zotero_find_and_attach_pdfs`（基于来源感知的 PDF cascade）、`zotero_add_linked_url_attachment` |

#### 前置条件

1. 安装 [Zotero](https://www.zotero.org/)（可选，用于本地模式）
2. 如需使用 Web API，请打开 [Zotero 设置 -> Security -> Applications](https://www.zotero.org/settings/security#applications)
3. 点击 `Create new private key` 生成 API key
4. 同一页面按钮下方显示的 `User ID`，就是个人库场景下应填写的 `ZOTERO_LIBRARY_ID`

#### 安装

```bash
# 通过 uv 安装（推荐）
uv tool install git+https://github.com/Galaxy-Dawn/zotero-mcp.git
```

#### 配置

选择你的平台：

##### Kimi CLI

添加到 `~/.kimi-code/mcp.json`：

```json
{
  "mcpServers": {
    "zotero": {
      "command": "zotero-mcp",
      "args": ["serve"],
      "transport": "stdio",
      "env": {
        "ZOTERO_LOCAL": "true",
        "NO_PROXY": "localhost,127.0.0.1",
        "FASTMCP_CHECK_FOR_UPDATES": "off",
        "FASTMCP_SHOW_SERVER_BANNER": "false",
        "ZOTERO_API_KEY": "your-api-key",
        "ZOTERO_LIBRARY_ID": "your-user-id",
        "ZOTERO_LIBRARY_TYPE": "user",
        "UNPAYWALL_EMAIL": "your-email@example.com",
        "UNSAFE_OPERATIONS": "all"
      }
    }
  }
}
```

##### Claude Code

添加到 `~/.claude/settings.json`：

```json
{
  "mcpServers": {
    "zotero": {
      "command": "zotero-mcp",
      "args": ["serve"],
      "env": {
        "ZOTERO_API_KEY": "your-api-key",
        "ZOTERO_LIBRARY_ID": "your-user-id",
        "ZOTERO_LIBRARY_TYPE": "user",
        "UNPAYWALL_EMAIL": "your-email@example.com",
        "UNSAFE_OPERATIONS": "all",
        "NO_PROXY": "localhost,127.0.0.1",
        "FASTMCP_CHECK_FOR_UPDATES": "off",
        "FASTMCP_SHOW_SERVER_BANNER": "false"
      }
    }
  }
}
```

##### OpenCode

添加到 `~/.opencode/opencode.jsonc`：

```jsonc
{
  "mcp": {
    "zotero": {
      "type": "local",
      "command": ["zotero-mcp", "serve"],
      "enabled": true
    }
  }
}
```

在 `~/.zshrc` 中设置环境变量：

```bash
# Zotero MCP
export ZOTERO_API_KEY="your-api-key"
export ZOTERO_LIBRARY_ID="your-user-id"
export ZOTERO_LIBRARY_TYPE="user"
export UNPAYWALL_EMAIL="your-email@example.com"
export UNSAFE_OPERATIONS="all"
export FASTMCP_CHECK_FOR_UPDATES="off"
export FASTMCP_SHOW_SERVER_BANNER="false"
```

#### 环境变量

| 变量 | 必需 | 说明 |
|------|------|------|
| `ZOTERO_API_KEY` | 本地只读可不填；Web/写操作必填 | 你的 Zotero API 密钥 |
| `ZOTERO_LIBRARY_ID` | 本地只读可不填；Web/写操作必填 | 个人库场景下填写 Zotero 页面显示的 `User ID`（数字） |
| `ZOTERO_LIBRARY_TYPE` | 是 | `user` 或 `group` |
| `UNPAYWALL_EMAIL` | 否 | 用于 Unpaywall PDF 搜索的邮箱 |
| `UNSAFE_OPERATIONS` | 否 | `items`（启用 delete_items）、`all`（启用 delete_collection） |
| `NO_PROXY` | 否 | 绕过 localhost 代理 |
| `FASTMCP_CHECK_FOR_UPDATES` | 否 | 设为 `off`，跳过 FastMCP 启动时的更新检查 |
| `FASTMCP_SHOW_SERVER_BANNER` | 否 | 设为 `false`，关闭 FastMCP 启动 banner |

说明：
- 最小本地配置只需要 `command = "zotero-mcp"` 和 `args = ["serve"]`。
- 不要把 `your-api-key`、`your-user-id`、`your-email@example.com` 这类占位符直接保留在正式配置里。

#### 可用工具

| 工具 | 用途 |
|------|------|
| `zotero_get_collections` | 列出所有集合 |
| `zotero_get_collection_items` | 获取集合中的条目 |
| `zotero_search_items` | 按关键词搜索库 |
| `zotero_search_by_tag` | 按标签搜索 |
| `zotero_get_item_metadata` | 获取条目元数据和摘要 |
| `zotero_get_item_fulltext` | 读取 PDF 全文 |
| `zotero_get_annotations` | 获取 PDF 标注 |
| `zotero_get_notes` | 获取笔记 |
| `zotero_semantic_search` | 语义搜索（使用嵌入） |
| `zotero_advanced_search` | 高级搜索 |
| `zotero_add_items_by_identifier` | 通过 DOI、arXiv、落地页或直链 PDF 智能导入论文；若 Web 上传撞到存储配额且本地 Zotero Desktop 正在运行，可回退为本地 connector copy（`pdf_source=local_zotero_copy`），或复用已有本地副本（`pdf_source=local_zotero_existing_copy`），并在可用时返回 `local_item_key=...` |
| `zotero_add_items_by_doi` | 通过 DOI 导入论文 |
| `zotero_add_items_by_arxiv` | 通过 arXiv ID 导入预印本 |
| `zotero_add_item_by_url` | 保存网页为条目 |
| `zotero_update_item` | 更新条目字段 |
| `zotero_update_note` | 更新笔记内容 |
| `zotero_create_collection` | 创建集合 |
| `zotero_move_items_to_collection` | 在集合间移动条目 |
| `zotero_update_collection` | 重命名集合 |
| `zotero_delete_collection` | 删除集合 |
| `zotero_delete_items` | 将条目移至回收站 |
| `zotero_find_and_attach_pdfs` | 为已有条目重新运行来源感知 PDF cascade |
| `zotero_reconcile_collection_duplicates` | 导入后的去重与 collection 级清理 |
| `zotero_add_linked_url_attachment` | 添加链接 URL 附件 |

工作流说明：Claude Scholar 当前默认使用 `zotero_add_items_by_identifier` 做论文导入，并使用 `zotero_reconcile_collection_duplicates` 作为标准导入后清理步骤。import ledger 与 local-copy reconcile 属于内部诊断能力，不是默认公开 MCP tools。

### 2. 浏览器自动化 MCP（可选）

用于：Chrome 浏览器控制、网页交互。

#### 配置

```json
{
  "mcpServers": {
    "streamable-mcp-server": {
      "type": "streamable-http",
      "url": "http://127.0.0.1:12306/mcp"
    }
  }
}
```

## 验证

配置完成后，重启 CLI 并验证 MCP 服务器已连接：

```
# 在 CLI 中尝试调用 Zotero 工具：
> 列出我的 Zotero 集合
```

如果工具返回你的集合列表，说明配置成功。

## 故障排除

| 问题 | 解决方案 |
|------|----------|
| 工具返回错误 | 检查 API 密钥和库 ID 是否正确 |
| PDF 附加失败 | 确保已设置 `UNPAYWALL_EMAIL` |
| 删除操作被阻止 | 设置 `UNSAFE_OPERATIONS=items` 或 `all` |
| HTTP 错误 | 检查 `NO_PROXY` 是否包含 localhost |
| MCP server 启动前退出 | 设置 `FASTMCP_CHECK_FOR_UPDATES=off` 和 `FASTMCP_SHOW_SERVER_BANNER=false` |
| API 速率限制 (429) | 每批次 ≤10 篇论文，批次间添加延迟 |
