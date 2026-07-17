# MCP Server Setup Guide

Claude Scholar relies on MCP (Model Context Protocol) servers for extended capabilities. MCP servers are **not included** in this repository — users must install and configure them separately.

## Required MCP Servers

### 1. Zotero MCP (Research Workflow)

**Used by**: `literature-reviewer` agent, `research-ideation` skill, and research workflow skills (triggered via natural language)

**Package**: [Galaxy-Dawn/zotero-mcp](https://github.com/Galaxy-Dawn/zotero-mcp) — auto-detects local Zotero desktop vs Web API mode; Web credentials are required for remote access and write tools.

#### Features

| Category | Tools |
|----------|-------|
| **Import** | `zotero_add_items_by_identifier`, `zotero_add_items_by_doi`, `zotero_add_items_by_arxiv`, `zotero_add_item_by_url` |
| **Read** | `zotero_get_collections`, `zotero_get_collection_items`, `zotero_search_items`, `zotero_semantic_search` |
| **Update** | `zotero_update_item`, `zotero_update_note`, `zotero_create_collection`, `zotero_move_items_to_collection`, `zotero_reconcile_collection_duplicates` |
| **Delete** | `zotero_delete_items` (to trash), `zotero_delete_collection` |
| **PDF** | `zotero_find_and_attach_pdfs` (source-aware PDF cascade), `zotero_add_linked_url_attachment` |

#### Prerequisites

1. Install [Zotero](https://www.zotero.org/) (optional, for local mode)
2. For Web API access, open [Zotero Settings -> Security -> Applications](https://www.zotero.org/settings/security#applications)
3. Click `Create new private key` to generate your API key
4. On the same page, the `User ID` shown below the button is the value to use as `ZOTERO_LIBRARY_ID` for a personal library

#### Installation

```bash
# Install via uv (recommended)
uv tool install git+https://github.com/Galaxy-Dawn/zotero-mcp.git
```

#### Configuration

Choose your platform below:

##### Kimi Code CLI

Add to your `~/.kimi-code/mcp.json`:

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

Add to your `~/.claude/settings.json`:

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

Add to your `~/.opencode/opencode.jsonc`:

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

Then set environment variables in `~/.zshrc`:

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

#### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `ZOTERO_API_KEY` | No for local read-only; Yes for Web/write tools | Your Zotero API key |
| `ZOTERO_LIBRARY_ID` | No for local read-only; Yes for Web/write tools | Your Zotero `User ID` (numeric) for personal libraries |
| `ZOTERO_LIBRARY_TYPE` | Yes | `user` or `group` |
| `UNPAYWALL_EMAIL` | No | Email for Unpaywall PDF search |
| `UNSAFE_OPERATIONS` | No | `items` (delete_items), `all` (delete_collection) |
| `NO_PROXY` | No | Bypass proxy for localhost |
| `FASTMCP_CHECK_FOR_UPDATES` | No | Set to `off` to skip FastMCP's startup update check |
| `FASTMCP_SHOW_SERVER_BANNER` | No | Set to `false` to suppress FastMCP's startup banner |

Notes:
- The minimal local setup is just `command = "zotero-mcp"` plus `args = ["serve"]`.
- Do not leave placeholder values such as `your-api-key`, `your-user-id`, or `your-email@example.com` in your live config.

#### Available Tools

| Tool | Purpose |
|------|---------|
| `zotero_get_collections` | List all collections |
| `zotero_get_collection_items` | Get items in a collection |
| `zotero_search_items` | Search library by keyword |
| `zotero_search_by_tag` | Search by tag |
| `zotero_get_item_metadata` | Get item metadata and abstract |
| `zotero_get_item_fulltext` | Read PDF full text |
| `zotero_get_annotations` | Get PDF annotations |
| `zotero_get_notes` | Get notes |
| `zotero_semantic_search` | Semantic search (uses embeddings) |
| `zotero_advanced_search` | Advanced search |
| `zotero_add_items_by_identifier` | Smart paper import from DOI, arXiv, landing pages, or direct PDF URLs; when web upload hits storage quota and Zotero Desktop is running, it can fall back to a local connector copy (`pdf_source=local_zotero_copy`) or reuse an existing local copy (`pdf_source=local_zotero_existing_copy`), exposing `local_item_key=...` when available |
| `zotero_add_items_by_doi` | Import papers by DOI |
| `zotero_add_items_by_arxiv` | Import preprints by arXiv ID |
| `zotero_add_item_by_url` | Save webpage as item |
| `zotero_update_item` | Update item fields |
| `zotero_update_note` | Update note content |
| `zotero_create_collection` | Create collection |
| `zotero_move_items_to_collection` | Move items between collections |
| `zotero_update_collection` | Rename collection |
| `zotero_delete_collection` | Delete collection |
| `zotero_delete_items` | Move items to trash |
| `zotero_find_and_attach_pdfs` | Re-run the source-aware PDF cascade for existing items |
| `zotero_reconcile_collection_duplicates` | Post-import dedupe and collection-level cleanup |
| `zotero_add_linked_url_attachment` | Add linked URL attachment |

Workflow note: Claude Scholar's current research startup path prefers `zotero_add_items_by_identifier` for import, then `zotero_reconcile_collection_duplicates` as the standard post-import cleanup. Import ledger and local-copy reconcile remain internal diagnostics rather than default public MCP tools.

### 2. Browser Automation MCP (Optional)

Used for: Chrome browser control, web page interaction.

#### Configuration

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

## Verification

After configuration, restart your CLI and verify MCP servers are connected:

```
# In your CLI, try calling a Zotero tool:
> List my Zotero collections
```

If the tool responds with your collections, the setup is complete.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Tools return error | Check API key and library ID are correct |
| PDF attach fails | Ensure `UNPAYWALL_EMAIL` is set |
| Delete operations blocked | Set `UNSAFE_OPERATIONS=items` or `all` |
| HTTP errors | Check `NO_PROXY` includes localhost |
| MCP server exits before startup | Set `FASTMCP_CHECK_FOR_UPDATES=off` and `FASTMCP_SHOW_SERVER_BANNER=false` |
| API rate limit (429) | Batch ≤10 papers at a time, add delays between batches |
