# Obsidianプロジェクトナレッジベース セットアップ

Kimi Scholarには、Obsidian研究ナレッジベースワークフローが内蔵されています。MCPやAPIキーは不要です。

## このワークフローでできること

Obsidianは単なる論文ライブラリではなく、研究プロジェクトの既定ナレッジレイヤとして扱われます。保存対象は次の通りです。

- 安定したプロジェクト背景と研究課題
- 論文ノートと文献統合
- 実験 runbook と結果要約
- 日次研究ログ、scratch notes、同期キュー
- draft、slides、proposal、rebuttal などの執筆資産
- 主作業面に残し続けるべきでない履歴知識

## Requirements

### Required
- ローカルの Obsidian vault パス
- `OBSIDIAN_VAULT_PATH` を環境変数で設定するか、bootstrap 時に明示的に渡すこと

### Optional
- ナビゲーション用に Obsidian Desktop をインストールして開いておくこと
- open/search/daily 操作用の `obsidian` CLI
- きれいな `obsidian://` リンクや CLI targeting 用の `OBSIDIAN_VAULT_NAME`

## 内蔵 skills

Kimi Scholar には project-scoped な Obsidian KB workflow が含まれています。

既定ワークフローの中心は次の skills です。

- `obsidian-project-kb-core`
- `obsidian-source-ingestion`
- `obsidian-literature-workflow`
- `obsidian-kb-artifacts`
- `defuddle`

既定ワークフローは `.base`、MCP、API サービスに依存しません。既定で自動保守されるグラフ artifact は `Maps/literature.canvas` のみで、追加の `.base` view や project / experiment canvas は explicit-only です。

## 既定の挙動

Kimi Scholar が `.kimi-code/project-memory/registry.yaml` を含むリポジトリ内で実行されている場合、そのリポジトリを Obsidian プロジェクトナレッジベースにバインド済みとして扱い、既定で更新を行います。

まだバインドされていなくても、`.git`、`README.md`、`docs/`、`notes/`、`plan/`、`results/`、`outputs/`、`src/`、`scripts/` などから研究リポジトリらしいと判断できる場合は、自動で bootstrap します。

## Vault 内の既定ディレクトリ構成

```text
Research/{project-slug}/
  00-Hub.md
  01-Plan.md
  02-Index.md
  Sources/
    Papers/
    Web/
    Docs/
    Data/
    Interviews/
    Notes/
  Knowledge/
  Experiments/
  Results/
    Reports/
  Writing/
  Daily/
  Maps/
  Archive/
  _system/
    registry.md
    schema.md
    lint-report.md
```

よく生成されるファイルは次の通りです。

- `02-Index.md`
- `_system/registry.md`
- `_system/schema.md`
- `_system/lint-report.md`
- `.kimi-code/project-memory/{project_id}.md`
- 文献ワークフローで必要な場合の `Maps/literature.canvas`

## Repo-local binding metadata

各研究リポジトリは次を持ちます。

```text
.kimi-code/project-memory/
  registry.yaml
  {project_id}.md
```

- `registry.yaml` は repo ↔ vault の binding を保持
- `{project_id}.md` は assistant-facing な runtime project memory を保持

## ノート言語

生成・同期ノートの言語は次の優先順位で決まります。
1. `.kimi-code/project-memory/registry.yaml` の project config
2. 環境変数 `OBSIDIAN_NOTE_LANGUAGE`
3. 既定値 `en`

注意：`registry.yaml` は repo-local runtime binding file のままです。プロジェクト内で見える source of truth は `_system/registry.md` です。

## Kimi での主なワークフロー

Kimi では Claude Code 風の slash command を前提にしません。同じ KB ワークフローは自然言語の依頼と対応 skill / helper script で進めます。

- `obsidian-project-kb-core` で project KB を初期化または導入する
- `obsidian-source-ingestion` で外部資料を `Sources/*` に振り分ける
- `skills/obsidian-project-kb-core/scripts/project_kb.py` で決定論的メンテナンスを走らせる
- `obsidian-kb-artifacts` で wikilink と派生 artifact を修復する
- `obsidian-literature-workflow` で `Sources/Papers` から文献統合を生成する
- lifecycle helper で archive / purge / rename / detach / rebuild を扱う

## バインド済み repo の最小メンテナンス面

リポジトリが `.kimi-code/project-memory/registry.yaml` で既にバインドされている場合、Kimi Scholar は保守を保守的に行います。

- 研究状態が変わったら `Daily/YYYY-MM-DD.md` を確認する
- project のトップレベル状態が本当に変わったときだけ `00-Hub.md` を更新する
- project 状態が変わったら `.kimi-code/project-memory/{project_id}.md` を更新する
- `Knowledge/`、`Experiments/`、`Results/`、`Writing/` は毎回自動で書き換えず agent-first を維持する

## オプション: Obsidian CLI のインストール

公式 Obsidian CLI は新しいデスクトップインストーラーに内蔵されています。`obsidian ...` を使うには：

1. CLI 登録をサポートする Obsidian Desktop を使う
2. Obsidian Desktop で `Settings -> General -> Advanced` を開く
3. **Command line interface** を有効にする
4. macOS では `/Applications/Obsidian.app/Contents/MacOS` を `PATH` に追加する（例: `~/.zprofile`）
5. ターミナルを再起動して次で確認する

```bash
obsidian help
obsidian search query="diffusion" limit=5
```

`Command line interface is not enabled` と出る場合、シェル側の PATH は正しいが Obsidian アプリ内のトグルがまだオフです。

## Lifecycle actions

### Detach
- 自動同期を停止する
- vault 内容は残す
- project memory file も残す

### Archive
- **note archive** は canonical note を `Research/{project-slug}/Archive/` に移動する
- **project archive** はプロジェクト全体を `Research/_archived/{project-slug}-{date}/` に移動する
- archive は履歴を保持し、project archive では同期も無効化する

### Purge
- binding、project memory、vault 内の project folder を永久削除する
- 明示的に永久削除を求められた場合のみ使う
