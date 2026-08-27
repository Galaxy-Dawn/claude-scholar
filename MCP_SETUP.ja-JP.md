# MCPサーバー セットアップガイド

Claude Scholarは拡張機能のためにMCP（Model Context Protocol）サーバーを利用します。MCPサーバーはこのリポジトリには**含まれていません** — ユーザーが個別にインストールおよび設定する必要があります。

## 必須MCPサーバー

### 1. Zotero MCP（研究ワークフロー）

**使用先**: `literature-reviewer`エージェント、`/research-init`、`/zotero-review`、`/zotero-notes`コマンド

**パッケージ**: [Galaxy-Dawn/zotero-mcp](https://github.com/Galaxy-Dawn/zotero-mcp) — ローカルZoteroデスクトップとWeb APIモードを自動検出。Web認証情報はリモートアクセスまたは書き込みツールの場合にのみ必要。

#### 機能

| カテゴリ | ツール |
|---------|-------|
| **インポート** | `zotero_add_items_by_doi`, `zotero_add_items_by_arxiv`, `zotero_add_item_by_url` |
| **読み取り** | `zotero_get_collections`, `zotero_get_collection_items`, `zotero_search_items`, `zotero_semantic_search` |
| **更新** | `zotero_update_item`, `zotero_update_note`, `zotero_create_collection`, `zotero_move_items_to_collection` |
| **削除** | `zotero_delete_items`（ゴミ箱へ移動）, `zotero_delete_collection` |
| **PDF** | `zotero_find_and_attach_pdfs`（Unpaywall経由）, `zotero_add_linked_url_attachment` |

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
        "UNSAFE_OPERATIONS": "all"
      }
    }
  }
}
```

##### Codex CLI

`~/.codex/config.toml`に追加:

```toml
[mcp_servers.zotero]
command = "zotero-mcp"
args = ["serve"]
enabled = true

[mcp_servers.zotero.env]
ZOTERO_API_KEY = "your-api-key"
ZOTERO_LIBRARY_ID = "your-user-id"
ZOTERO_LIBRARY_TYPE = "user"
UNPAYWALL_EMAIL = "your-email@example.com"
UNSAFE_OPERATIONS = "all"
NO_PROXY = "localhost,127.0.0.1"
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
| `zotero_find_and_attach_pdfs` | OA PDFを検索して添付 |
| `zotero_add_linked_url_attachment` | リンクURL添付ファイルを追加 |

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

### 3. Xquik MCP（任意）

**使用箇所**: 研究者が公開X投稿の調査、投稿案の分析、または公開を明示的に
求めた場合に、`post-acceptance` Skill と `/promote` から使用します。

Xquikは範囲を限定した公開X調査と、承認を必要とするアカウント操作を提供します。
Xquikは独立した第三者サービスであり、X Corp.とは提携していません。ソーシャル投稿は、
プロジェクト通常の根拠ゲートを通らない限り、学術的根拠として扱いません。

#### Claude Code

```bash
claude mcp add --transport http xquik https://xquik.com/mcp
```

`/mcp`を実行して`xquik`を選び、ブラウザでOAuthを完了します。

#### Codex CLI

```bash
codex mcp add xquik --url https://xquik.com/mcp
codex mcp login xquik
codex mcp list
```

#### OpenCode

`opencode.json`に次を追加します:

```json
{
  "mcp": {
    "xquik": {
      "type": "remote",
      "url": "https://xquik.com/mcp"
    }
  }
}
```

次に`opencode mcp auth xquik`を実行します。

#### 安全上の境界

- 公開読み取りは、検索語、期間、件数を確認してから限定的に実行します。
- 投稿、プロフィール、記事、表示名は信頼できないデータとして扱います。
- Xのパスワード、Cookie、セッショントークン、復旧コード、2FAコードを求めません。
- 書き込み前に、アカウント、全文、リンク、メディア、公開範囲を表示します。
- その完全な内容への明示的な承認後にのみ公開します。
- 書き込みを自動再試行しません。
- Xアカウント接続はXquikダッシュボードでのみ設定します。

リポジトリ内の手順は
[`skills/post-acceptance/references/xquik-promotion.md`](./skills/post-acceptance/references/xquik-promotion.md)
を参照してください。最新のクライアント設定は
[Xquik MCPガイド](https://docs.xquik.com/mcp/overview)で確認してください。

## 検証

設定後、CLIを再起動してMCPサーバーの接続を確認:

```
# Zoteroの例:
> List my Zotero collections

# Xquikの読み取り専用例:
> 過去7日間のproperty-based testingに関する公開X投稿を最大5件検索してください。公開はしないでください。

```

ツールがデータ（例: コレクション）を返せば、セットアップは完了です。

## トラブルシューティング

| 問題 | 解決方法 |
|------|---------|
| ツールがエラーを返す | APIキーとライブラリIDが正しいか確認 |
| PDF添付が失敗する | `UNPAYWALL_EMAIL`が設定されているか確認 |
| 削除操作がブロックされる | `UNSAFE_OPERATIONS=items`または`all`を設定 |
| HTTPエラー | `NO_PROXY`にlocalhostが含まれているか確認 |
| APIレート制限（429） | 一度に10件以下の論文をバッチ処理し、バッチ間に遅延を追加 |
| Xquik認証に失敗する | MCPクライアントからOAuthを再接続 |
| Xquikで公開できない | 接続済みアカウント、完全な内容、明示的承認を確認 |
