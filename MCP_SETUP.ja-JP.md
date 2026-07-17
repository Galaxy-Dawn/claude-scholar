# MCPサーバー セットアップガイド

Claude Scholarは拡張機能のためにMCP（Model Context Protocol）サーバーを利用します。MCPサーバーはこのリポジトリには**含まれていません** — ユーザーが個別にインストールおよび設定する必要があります。

## 必須MCPサーバー

### 1. Zotero MCP（研究ワークフロー）

**使用先**: `literature-reviewer`エージェント、`research-ideation`スキル、および自然言語から起動する研究系ワークフロー

**パッケージ**: [Galaxy-Dawn/zotero-mcp](https://github.com/Galaxy-Dawn/zotero-mcp) — ローカルZoteroデスクトップとWeb APIモードを自動検出。Web認証情報はリモートアクセスまたは書き込みツールの場合にのみ必要。

#### 機能

| カテゴリ | ツール |
|---------|-------|
| **インポート** | `zotero_add_items_by_identifier`, `zotero_add_items_by_doi`, `zotero_add_items_by_arxiv`, `zotero_add_item_by_url` |
| **読み取り** | `zotero_get_collections`, `zotero_get_collection_items`, `zotero_search_items`, `zotero_semantic_search` |
| **更新** | `zotero_update_item`, `zotero_update_note`, `zotero_create_collection`, `zotero_move_items_to_collection`, `zotero_reconcile_collection_duplicates` |
| **削除** | `zotero_delete_items`（ゴミ箱へ移動）, `zotero_delete_collection` |
| **PDF** | `zotero_find_and_attach_pdfs`（source-aware PDF cascade）, `zotero_add_linked_url_attachment` |

#### 前提条件

1. Web API認証情報なしでローカル読み取り専用アクセスを行う場合は[Zotero](https://www.zotero.org/)をインストール
2. 書き込みツールまたはリモートWeb APIアクセスの場合は、[Zotero設定 -> セキュリティ -> アプリケーション](https://www.zotero.org/settings/security#applications)を開く
3. `Create new private key`をクリックしてAPIキーを生成
4. 同じページでボタンの下に表示される`User ID`をコピー。個人ライブラリの場合、この数値を`ZOTERO_LIBRARY_ID`として使用

#### インストール

```bash
# uv経由でインストール（推奨）
uv tool install git+https://github.com/Galaxy-Dawn/zotero-mcp.git
```

#### 設定

以下からプラットフォームを選択してください:

##### Claude Code

Claude Code v2.1.5以降の場合、`~/.claude.json`の`mcpServers`に追加。

それ以前のバージョンの場合、`~/.claude/settings.json`の`mcpServers`に追加:

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

##### Kimi CLI

`~/.kimi-code/mcp.json`に追加:

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

##### OpenCode

`~/.opencode/opencode.jsonc`に追加:

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

次に`~/.zshrc`で環境変数を設定:

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

#### 環境変数

| 変数 | 必須 | 説明 |
|------|-----|------|
| `ZOTERO_API_KEY` | ローカル読み取り専用: 不要、Web/書き込みツール: 必要 | Zotero APIキー |
| `ZOTERO_LIBRARY_ID` | ローカル読み取り専用: 不要、Web/書き込みツール: 必要 | 個人ライブラリ用のZotero `User ID`（数値） |
| `ZOTERO_LIBRARY_TYPE` | 必要 | `user`または`group` |
| `UNPAYWALL_EMAIL` | 不要 | Unpaywall PDF検索用メールアドレス |
| `UNSAFE_OPERATIONS` | 不要 | `items`（delete_items）、`all`（delete_collection） |
| `NO_PROXY` | 不要 | localhostのプロキシをバイパス |
| `FASTMCP_CHECK_FOR_UPDATES` | 不要 | `off`に設定するとFastMCPの起動時アップデート確認をスキップ |
| `FASTMCP_SHOW_SERVER_BANNER` | 不要 | `false`に設定するとFastMCPの起動バナーを抑制 |

注意:
- 最小限のローカルセットアップは`command = "zotero-mcp"`と`args = ["serve"]`のみです。
- 本番設定に`your-api-key`、`your-user-id`、`your-email@example.com`などのプレースホルダー値を残さないでください。

#### 利用可能なツール

| ツール | 用途 |
|-------|------|
| `zotero_get_collections` | 全コレクションを一覧表示 |
| `zotero_get_collection_items` | コレクション内のアイテムを取得 |
| `zotero_search_items` | キーワードでライブラリを検索 |
| `zotero_search_by_tag` | タグで検索 |
| `zotero_get_item_metadata` | アイテムのメタデータとアブストラクトを取得 |
| `zotero_get_item_fulltext` | PDFフルテキストを読解 |
| `zotero_get_annotations` | PDFアノテーションを取得 |
| `zotero_get_notes` | ノートを取得 |
| `zotero_semantic_search` | セマンティック検索（埋め込みを使用） |
| `zotero_advanced_search` | 高度な検索 |
| `zotero_add_items_by_identifier` | DOI、arXiv、ランディングページ、または直接PDF URLから論文をスマートに取り込む。Webアップロードが容量制限に当たり、かつ Zotero Desktop が起動している場合は、ローカル connector copy（`pdf_source=local_zotero_copy`）へフォールバックしたり、既存のローカル copy（`pdf_source=local_zotero_existing_copy`）を再利用したりでき、利用可能な場合は `local_item_key=...` を返す |
| `zotero_add_items_by_doi` | DOIで論文をインポート |
| `zotero_add_items_by_arxiv` | arXiv IDでプレプリントをインポート |
| `zotero_add_item_by_url` | Webページをアイテムとして保存 |
| `zotero_update_item` | アイテムのフィールドを更新 |
| `zotero_update_note` | ノートの内容を更新 |
| `zotero_create_collection` | コレクションを作成 |
| `zotero_move_items_to_collection` | コレクション間でアイテムを移動 |
| `zotero_update_collection` | コレクション名を変更 |
| `zotero_delete_collection` | コレクションを削除 |
| `zotero_delete_items` | アイテムをゴミ箱に移動 |
| `zotero_find_and_attach_pdfs` | 既存アイテムに対して source-aware PDF cascade を再実行 |
| `zotero_reconcile_collection_duplicates` | インポート後の重複排除とコレクション単位のクリーンアップ |
| `zotero_add_linked_url_attachment` | リンクURL添付ファイルを追加 |

ワークフローメモ: Claude Scholar の現在の研究立ち上げ経路では、インポートに `zotero_add_items_by_identifier` を優先し、その後の標準クリーンアップとして `zotero_reconcile_collection_duplicates` を使います。import ledger と local-copy reconcile は、既定の公開 MCP ツールではなく内部診断に留まります。

### 2. ブラウザオートメーションMCP（任意）

用途: Chromeブラウザ制御、Webページインタラクション。

#### 設定

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

## 検証

設定後、CLIを再起動してMCPサーバーの接続を確認:

```
# Zoteroの例:
> List my Zotero collections

```

ツールがデータ（例: コレクション）を返せば、セットアップは完了です。

## トラブルシューティング

| 問題 | 解決方法 |
|------|---------|
| ツールがエラーを返す | APIキーとライブラリIDが正しいか確認 |
| PDF添付が失敗する | `UNPAYWALL_EMAIL`が設定されているか確認 |
| 削除操作がブロックされる | `UNSAFE_OPERATIONS=items`または`all`を設定 |
| HTTPエラー | `NO_PROXY`にlocalhostが含まれているか確認 |
| MCP serverが起動前に終了する | `FASTMCP_CHECK_FOR_UPDATES=off`と`FASTMCP_SHOW_SERVER_BANNER=false`を設定 |
| APIレート制限（429） | 一度に10件以下の論文をバッチ処理し、バッチ間に遅延を追加 |
