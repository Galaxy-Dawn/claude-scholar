<div align="center">
  <img src="LOGO.png" alt="Claude Scholar Logo" width="100%"/>

  <p>
    <a href="https://github.com/Galaxy-Dawn/claude-scholar/stargazers"><img src="https://img.shields.io/github/stars/Galaxy-Dawn/claude-scholar?style=flat-square&color=yellow" alt="Stars"/></a>
    <a href="https://github.com/Galaxy-Dawn/claude-scholar/network/members"><img src="https://img.shields.io/github/forks/Galaxy-Dawn/claude-scholar?style=flat-square" alt="Forks"/></a>
    <img src="https://img.shields.io/github/last-commit/Galaxy-Dawn/claude-scholar?style=flat-square" alt="Last Commit"/>
    <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License"/>
    <img src="https://img.shields.io/badge/Codex_CLI-Compatible-blue?style=flat-square" alt="Codex CLI"/>
    <img src="https://img.shields.io/badge/OpenCode-Compatible-orange?style=flat-square" alt="OpenCode"/>
  </p>

  <strong>Language</strong>: <a href="README.md">English</a> | <a href="README.zh-CN.md">中文</a> | <a href="README.ja-JP.md">日本語</a>
</div>

> 学術研究とソフトウェア開発のための半自動リサーチアシスタントであり、特にコンピュータサイエンスと AI 研究者に適しており、[OpenCode](https://github.com/opencode-ai/opencode) 向けに調整されています。研究構想、文献整理、実験分析、結果レポート、執筆、プロジェクト知識ベース管理を支援します。
>
> **ブランチ注記**：これは Claude Scholar の **OpenCode 版**です。Claude Code 版は [`main` ブランチ](https://github.com/Galaxy-Dawn/claude-scholar/tree/main)、Codex CLI 版は [`codex` ブランチ](https://github.com/Galaxy-Dawn/claude-scholar/tree/codex) を参照してください。


## 最新ニュース

- **2026-05-14**: **`expression-skill` を中核のコミュニケーション層に据え、その上で Nature 執筆スタックを拡張** — [`expression-skill`](./skills/expression-skill/README.md) を、報告・計画・ファイル操作・多段の技術作業における結論先行の表現規律として明示しました。あわせて、章構成の起草と論証構築向けに [`nature-writing`](./skills/nature-writing/README.md) を導入し、[`nature-polishing`](./skills/nature-polishing/README.md) を上流の最新 article-pattern 版へ更新し、[`nature-response`](./skills/nature-response/README.md) と [`nature-data`](./skills/nature-data/README.md) も journal-writing スタックに維持しています。
- **2026-05-13**: **根拠ゲート付き研究ワークフローと `Sources/Papers` ルーティングを整理** — Evidence Records、claim strength、Claim Promotion Gate を共有する `research-contract.md` を追加しました。研究アイデア出し、Zotero 取り込み、文献統合、結果レポート、論文執筆、rebuttal ワークフローを同じ根拠契約に接続し、プロジェクトの論文ソースノートはまず `Sources/Papers` に置き、根拠ゲートを通った主張だけを `Knowledge` や `Writing` へ進める方針を明確にしました。
- **2026-04-25**: **OpenCode Obsidian KB lifecycle を安定化** — OpenCode の project KB workflow で rename、archive、purge、sync、lint の edge cases を修正し、`/kb-*` commands を主入口にしました。
- **2026-04-24**: **Vault-first Obsidian KB workflow を OpenCode へ移植** — 新しい project-scoped Obsidian knowledge workflow を OpenCode edition に取り込み、旧 memory skills を 4 つの focused skills に統合し、`/kb-*` commands を唯一の Obsidian command surface にしました。
- **2026-04-22**: **軽量コア指示と安全なインストール lifecycle** — 大きな always-on `CLAUDE.md` / `AGENTS.md` をコンパクトなコア指示に置き換え、非中核の default agents を削除し、中国語 companion ファイルを追加しました。さらに manifest/state ベースのアンインストールを追加し、更新と削除がインストーラー所有のファイルと設定項目だけを扱うようにしました。
- **2026-04-15**: **pubfig と pubtab という 2 つの Python package を導入** — [`pubfig`](https://github.com/Galaxy-Dawn/pubfig) を論文品質の scientific figures 向け Python package、[`pubtab`](https://github.com/Galaxy-Dawn/pubtab) を publication-ready な tables と Excel↔LaTeX workflows 向け Python package として打ち出し、論文図、benchmark 表、書き出し制御、最終 QA までの生産経路をより明確にしました。

<details>
<summary>過去の更新履歴を表示</summary>

- **2026-04-15**: **[`publication-chart-skill`](./skills/publication-chart-skill/SKILL.md) を Claude Scholar に統合** — [`pubfig`](https://github.com/Galaxy-Dawn/pubfig) + [`pubtab`](https://github.com/Galaxy-Dawn/pubtab) を [`publication-chart-skill`](./skills/publication-chart-skill/SKILL.md) としてまとめてリポジトリに追加し、Claude Scholar の分析/執筆スタックの境界に接続しました。これにより、論文品質の図表作業を汎用分析や文章作成スキルに混ぜず、明示的な引き渡し経路で扱えるようになりました。
- **2026-03-31**: **Zotero smart-importワークフロー文書を整合** — 最新の`zotero-mcp`公開インターフェースに合わせて、Claude Scholarの研究向けドキュメントを更新しました。`zotero_add_items_by_identifier`を標準の論文インポート経路として明示し、`zotero_reconcile_collection_duplicates`を標準的なインポート後クリーンアップ手順に位置づけ、source-awareなPDF cascadeの挙動もより正確に説明し直しました。公開機能と内部診断機能の境界も整理しています。
- **2026-03-31**: **READMEの導入案内を刷新** — Claude Scholarが特にコンピュータサイエンスおよびAI研究者に適していることを明確にし、インストール後すぐ使える実践的な導入シナリオを追加しました。前提条件やブランチ案内も整理し、「既存のローカルmdファイルは手動でマージする必要がある」点をより明確にしました。
- **2026-03-31**: **インストーラーと runtime guard の挙動を整理** — インストーラーは既存のローカル`AGENTS.md`を保持しつつ、リポジトリ版を`AGENTS.scholar.md`として追加するようになりました。あわせて、デフォルト OpenCode guard の要約出力も整理し、temp filesやuncommitted filesのノイズを抑えつつ、より安全な書き込みガードは維持しています。
- **2026-03-31**: **日本語ドキュメントを追加** — メインREADMEに加え、`AGENTS`、`MCP_SETUP`、`OBSIDIAN_SETUP`の日本語版も追加し、OpenCodeブランチ全体の多言語ドキュメント導線をより充実させました。

- **2026-02-25**: **Codex CLI** サポート — [OpenAI Codex CLI](https://github.com/openai/codex) 向けの `codex` 分岐を追加し、Codex ネイティブの設定、ワークフロー導線、sandbox 安全機構を整備しました。
- **2026-02-23**: `setup.sh` インストーラー追加 — 既存 `~/.opencode` 向けのバックアップ付き増分更新、`opencode.jsonc` の自動バックアップ、`agent/mcp/permission/plugin` の追加入力マージに対応
- **2026-02-21**: **OpenCode** サポート — Claude Scholar は [OpenCode](https://github.com/opencode-ai/opencode) を代替 CLI としてサポート。互換設定は `opencode` 分岐で提供
- **2026-02-20**: バイリンガル文書 — 英文と中文の入口文書を整備し、異なる読者層が読みやすいよう改善
- **2026-02-15**: Zotero MCP 統合 — `/zotero-review` と `/zotero-notes` を追加し、`research-ideation` skill に Zotero ガイドを追加、`literature-reviewer` agent を Zotero MCP 対応へ強化
- **2026-02-14**: Hooks 最適化 — `security-guard` を二層化し、`skill-forced-eval` を 6 分類 + 静音スキャンへ変更、`session-start` を上位 5 件表示に制限、`session-summary` に 30 日ログ自動清理を追加、`stop-summary` で追加/変更/削除を分離表示
- **2026-02-11**: 大型アップデート — 10 個の skills、7 個の agents、8 個の研究ワークフロー command、2 個の新ルールを追加し、主設定文書を再構成
- **2026-01-26**: すべての Hooks をクロスプラットフォーム Node.js 版へ書き換え、README を全面更新、ML 論文執筆知識ベースを拡張
- **2026-01-25**: プロジェクト正式公開、v1.0.0 リリース

</details>

## クイックナビゲーション

| セクション | 役割 |
|---|---|
| [なぜ Claude Scholar なのか](#なぜ-claude-scholar-なのか) | プロジェクトの位置づけと適用場面を素早く理解する。 |
| [コアワークフロー](#コアワークフロー) | 研究構想から投稿までの主線を確認する。 |
| [クイックスタート](#クイックスタート) | フル / 最小 / 選択導入の方法を選ぶ。 |
| [使い始めのシナリオ](#使い始めのシナリオ) | インストール後の代表的な使い始め方を見る。 |
| [連携機能](#連携機能) | Zotero と Obsidian をどう接続するかを見る。 |
| [主要ワークフロー](#主要ワークフロー) | 中核となる研究・開発ワークフローを確認する。 |
| [支援ワークフロー](#支援ワークフロー) | 主ワークフローを支える背景メカニズムを確認する。 |
| [ドキュメント入口](#ドキュメント入口) | setup、設定、テンプレート文書へ移動する。 |
| [引用](#引用) | 論文・報告書・プロジェクト文書で Claude Scholar を引用する。 |

## なぜ Claude Scholar なのか

Claude Scholar は、研究者を置き換え、エンドツーエンドの全自動研究を目指すタイプのシステム**ではありません**。

核となる考え方はシンプルです。

> **最終判断は人間が担い、アシスタントは研究プロセスを加速する。**

そのため Claude Scholar は、文献整理、知識の蓄積、実験分析、結果報告、執筆支援のような「反復的で構造依存だが、人の判断が必要な仕事」に特に向いています。本質的な判断は、常に研究者自身が行うべきです。

- この問題に取り組む価値があるか
- どの文献が本当に重要か
- どの仮説をさらに検証すべきか
- どの結果が十分に信頼できるか
- 何を継続し、何を論文にし、何を投稿し、あるいはどこでやめるべきか

言い換えれば、Claude Scholar は**人間の意思決定を中心に据えた半自動研究アシスタント**であり、「全自動研究エージェント」ではありません。

## どんな人に向いているか

Claude Scholar は特に次のような人に向いています。

- **コンピュータサイエンス研究者**：文献、コード、実験、論文執筆を頻繁に切り替える人
- **AI / ML researcher**：構想、実装、分析、報告、rebuttal を一つの流れで回したい人
- **research engineer や大学院生**：人間の判断を保ちながら、より強いプロセス構造を導入したい人
- **ソフトウェア・計算駆動型の学術プロジェクト**：Zotero、Obsidian、CLI 自動化、追跡可能な project memory の恩恵を直接受けられる人

他分野にも役立ちますが、現状の設計重心はコンピュータサイエンス、AI、および近接する computational research に最も近いです。

## コアワークフロー

- **研究構想**：曖昧なテーマを具体的な研究問題、研究ギャップ、初期計画へ収束させる
- **文献ワークフロー**：Zotero コレクションを通じて論文を検索、取込、整理し、読む
- **論文ノート**：論文を構造化読書ノートと再利用可能な論点へ変換する
- **知識ベースへの蓄積**：安定知識を Obsidian に書き込み、`Sources / Knowledge / Experiments / Results / Results/Reports / Writing / Daily / Maps` に振り分ける。
- **実験推進**：仮説、実験ライン、実行履歴、主要発見、次アクションを追跡する
- **厳密分析**：`results-analysis` を用いて厳密統計、実際の科研図、分析成果物を生成する
- **結果レポート**：`results-report` を用いて完全な実験レビューを作成し、Obsidian へ書き戻す
- **執筆と発表**：安定した結論をレビュー、論文、rebuttal、発表資料、ポスター、発信素材へ展開する

## クイックスタート

### 前提条件

- [OpenCode](https://github.com/sst/opencode)
- Git
- （任意）Python + [uv](https://docs.astral.sh/uv/) — Python 開発用
- （任意）[Zotero](https://www.zotero.org/) + [Galaxy-Dawn/zotero-mcp](https://github.com/Galaxy-Dawn/zotero-mcp) — 文献ワークフロー用
- （任意）[Obsidian](https://obsidian.md/) — プロジェクト知識ベース用

### オプション 1：フルインストール（推奨）

```bash
git clone -b opencode https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
bash /tmp/claude-scholar/scripts/setup.sh
```

インストーラーは現在、**バックアップ付きの安全な増分更新**をサポートしています。
- リポジトリ管理の `skills/commands/plugins/scripts/utils/` を更新
- 上書き対象ファイルを `~/.opencode/.opencode-scholar-backups/<timestamp>/` にバックアップ
- `opencode.jsonc` も `opencode.jsonc.bak` としてバックアップ
- `~/.opencode/AGENTS.md` が既に存在する場合は元ファイルを保持し、リポジトリ版を `~/.opencode/AGENTS.scholar.md` として保存
- `~/.opencode/AGENTS.zh-CN.md` が既に存在する場合は元ファイルを保持し、リポジトリ版の中国語 companion を `~/.opencode/AGENTS.zh-CN.scholar.md` として保存
- 既存の `env`、モデル / provider 設定、API key、permissions、auth、および `mcp` の現在値を保持
- リポジトリ管理の `agent/mcp/permission/plugin` 条目は、全置換ではなく不足項目を追加する形でマージ

**重要な AGENTS 説明**：すでに自分用の `~/.opencode/AGENTS.md` を持っている場合は、インストール後に `~/.opencode/AGENTS.scholar.md` と `~/.opencode/AGENTS.zh-CN.scholar.md` を確認し、必要な Claude Scholar の内容だけを自分のファイルに手動で merge してください。sidecar ファイルが自動で有効化されるとは考えないでください。

以後の増分更新は次の通りです。

```bash
cd /tmp/claude-scholar
git pull --ff-only
bash scripts/setup.sh
```

後でアンインストールする場合：

```bash
cd /tmp/claude-scholar
bash scripts/uninstall.sh
```

インストーラーは次のファイルを書き込みます。
- `~/.opencode/.opencode-scholar-manifest.txt`：Claude Scholar が管理するファイル一覧
- `~/.opencode/.opencode-scholar-install-state`：安全なアンインストール用 metadata。実際に書き込まれた `AGENTS*.md` の対象と、追加された `opencode.jsonc` エントリを含みます

アンインストーラーは install state に記録されたファイルと設定エントリだけを削除します。現在の repo checkout から所有権を推測しません。

**Windows**：インストーラーは Git Bash / WSL から実行してください。

### オプション 2：最小インストール

研究ワークフローの小さなサブセットのみを導入します。

```bash
git clone -b opencode https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
mkdir -p ~/.opencode/plugins/lib ~/.opencode/skills
cp /tmp/claude-scholar/plugins/*.ts ~/.opencode/plugins/
cp /tmp/claude-scholar/plugins/lib/common.ts ~/.opencode/plugins/lib/
cp -r /tmp/claude-scholar/skills/ml-paper-writing ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/research-ideation ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/results-analysis ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/results-report ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/review-response ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/writing-anti-ai ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/git-workflow ~/.opencode/skills/
cp -r /tmp/claude-scholar/skills/bug-detective ~/.opencode/skills/
```

**インストール後**：最小化 / 手動インストールでは `opencode.jsonc` は**自動マージされません**。必要な plugin や MCP 条目だけを手動で取り込んでください。自分の `~/.opencode/AGENTS.md` がある場合も、関連部分だけを手動で merge し、丸ごと上書きしないでください。

### オプション 3：選択インストール

必要な部分だけをコピーします。

```bash
git clone -b opencode https://github.com/Galaxy-Dawn/claude-scholar.git /tmp/claude-scholar
cd /tmp/claude-scholar

cp plugins/*.ts ~/.opencode/plugins/
cp -r skills/latex-conference-template-organizer ~/.opencode/skills/
cp -r skills/architecture-design ~/.opencode/skills/
cp AGENTS.md ~/.opencode/AGENTS.md
cp AGENTS.zh-CN.md ~/.opencode/AGENTS.zh-CN.md
```

**インストール後**：選択的 / 手動インストールでも `opencode.jsonc` は自動マージされません。必要な plugin / MCP 条目だけを手動で取り込んでください。既に `~/.opencode/AGENTS.md` を持っている場合も、必要な内容だけを手動で merge してください。

## 使い始めのシナリオ

インストール後は、システム全体を先に覚えようとするよりも、自然言語で今やりたいことをそのまま伝えるのがいちばん簡単です。ここでは、最初の一歩として使いやすい代表的なシナリオをいくつか挙げます。

### 1. 新しい研究テーマを立ち上げる
**たとえばこう言えます:**
> [あなたの研究テーマ]について研究を始めたいです。文献に基づいた初期プラン、重要な未解決問題、次にやるべき具体的なステップを整理してください。

**Claude Scholarがよく支援する内容:**
- テーマを明確化して研究課題を絞り込む
- 優先して見るべき文献の方向を整理する
- 初期計画や仮説候補をまとめる
- 必要ならZoteroやObsidianにも流し込む

### 2. Zotero文献コレクションをレビューする
**たとえばこう言えます:**
> Zoteroにある brain foundation models 関連の文献コレクションをレビューして、主な流れ、研究ギャップ、次に有望な方向をまとめてください。

**典型的な出力:**
- テーマ別の論文整理
- 簡潔な文献総括
- ギャップ分析
- 次に掘る価値のある研究方向

### 3. 完了した実験結果を分析する
**たとえばこう言えます:**
> この実験フォルダの結果を分析して、各runで何が変わったのかを確認し、意思決定に使える要約を書いてください。

**典型的な出力:**
- 指標比較
- アブレーションやエラー分析の提案
- 何が堅い結論で、何がまだ弱く、次に何を走らせるべきかを整理した結果要約

### 4. 論文の節やrebuttal草稿を書く
**たとえばこう言えます:**
> このプロジェクトの現時点の知見と論文メモに基づいて、関連研究の節の草稿を書いてください。

または:

> これらの査読コメントに対するrebuttal草稿を手伝ってください。

**典型的な出力:**
- 構造化された節ドラフト
- より明確な論理展開
- 主張と根拠の対応整理
- 追加で検証や補強が必要な論点

### 実用上のメモ
- 最初は「全部やって」ではなく、具体的な一つのタスクから始めるのがおすすめです。
- すでに自分用のローカル`AGENTS.md`または`AGENTS.zh-CN.md`を運用している場合は、`AGENTS.scholar.md`または`AGENTS.zh-CN.scholar.md`から必要な内容だけを手動でマージしてください。別名で配置されたファイルが自動適用されるわけではありません。
- ZoteroとObsidianは必須ではありませんが、単発のチャット出力ではなく、継続的な文献ノートやプロジェクトメモリを残したい場合にはかなり有用です。

## プラットフォームサポート

Claude Scholar は現在、次の CLI ワークフローを対象にしています。

- **OpenCode** — このブランチの主たる導入対象
- **Claude Code** — `main` ブランチを使用
- **Codex CLI** — `codex` ブランチを使用

トップレベルの目的は共通です。研究、コーディング、実験、レポート、執筆、プロジェクト知識ベース保守を一つの大きな流れで支えます。

## 連携機能

### Zotero

次のような場面に向いています。
- DOI / arXiv / URL から論文を取り込む
- collection 単位で論文をまとめて読む
- Zotero MCP を通して全文にアクセスする
- 詳細な論文ノートと文献統合を作る

詳しくは [MCP_SETUP.ja-JP.md](./MCP_SETUP.ja-JP.md) を参照してください。

### Obsidian

ファイルシステムファーストの研究ナレッジベースとしてObsidianを利用できます:
- `Sources/`
- `Knowledge/`
- `Experiments/`
- `Results/`
- `Results/Reports/`
- `Writing/`
- `Daily/`
- `Maps/`

詳細は [OBSIDIAN_SETUP.ja-JP.md](./OBSIDIAN_SETUP.ja-JP.md) を参照。

## 主要ワークフロー

研究構想から発表までを含む、完全な学術研究ライフサイクルの 7 段階です。

### 1. 研究構想（Zotero 統合）

アイデア生成から文献管理までを一体化した研究立ち上げフローです。

| 種類 | 名前 | 一行説明 |
|---|---|---|
| Skill | `research-ideation` | 曖昧な研究テーマを構造化問題、研究ギャップ分析、初期研究計画へ収束させる |
| Agent | `literature-reviewer` | 論文を検索・分類・統合し、実行可能な文献地図を作る |
| Command | `/research-init` | 文献検索、Zotero 整理、研究提案ドラフトまでを一括起動する |
| Command | `/zotero-review` | 既存 Zotero collection を構造化レビューし、比較と統合を行う |
| Command | `/zotero-notes` | Zotero collection をまとめて読み、構造化された論文読書ノートを生成する |

**進め方**
- **5W1H ブレインストーミング**：曖昧なテーマを構造化問題へ収束させる
- **文献検索と取込**：論文を探し、DOI/arXiv/URL を抽出し、Zotero に入れてテーマごとに整理する
- **PDF と全文**：PDF を添付できるなら添付し、全文を読めるなら読む。必要に応じて要旨分析へフォールバックする
- **研究ギャップ分析**：literature / methodology / application / interdisciplinary / temporal の各種ギャップを見つける
- **研究問題と計画**：文献レビューを、明確な研究問題、初期仮説、次の計画へ変換する

**典型的な成果物**
- 文献レビュー・ノート
- 構造化された Zotero コレクション
- 研究計画 / 方向ドラフト

### 2. ML プロジェクト開発

実験コード向けの、保守しやすい ML プロジェクト開発ワークフローです。

| 種類 | 名前 | 一行説明 |
|---|---|---|
| Skill | `architecture-design` | 新しい登録可能コンポーネントやモジュール追加時に、保守しやすい ML 構造を設計する |
| Skill | `git-workflow` | ブランチ規範、commit 規範、より安全な協業フローを整える |
| Skill | `bug-detective` | stack trace、shell エラー、コードパス問題を体系的に追跡する |
| Agent | `code-reviewer` | コード変更の正しさ、保守性、実装品質をレビューする |
| Agent | `tdd-guide` | 明示的に TDD が必要な場面で、絞ったテスト駆動の実装ガイドを出す。 |
| Command | `/plan` | 実装前に計画を作成・洗練する |
| Command | `/commit` | 現在の変更に対する規範的 commit を生成する |
| Command | `/code-review` | 現在の変更に焦点を当てたコードレビューを行う |
| Command | `/tdd` | 小さなテスト駆動ステップで機能実装を進める |

**進め方**
- **構造設計**：適切な場面では Factory / Registry パターンで ML コンポーネントを整理する
- **コード品質**：ファイル規模、型ヒント、設定駆動設計を維持する
- **問題調査**：stack trace、shell エラー、コードパス問題を体系的に扱う
- **Git 規律**：ブランチ戦略、commit 規範、安全な merge / rebase フローを維持する

### 3. 実験分析

厳密統計、科研図、分析成果物、実験後レポートを含む厳格な分析ワークフローです。

| 種類 | 名前 | 一行説明 |
|---|---|---|
| Skill | `results-analysis` | 厳密統計、実際の科研図、分析付録から成る分析パッケージを生成する |
| Skill | `results-report` | 分析成果物を、結論・制約・次アクションが明確な完全な実験レポートへまとめる |
| Command | `/analyze-results` | 厳密分析から最終レポート生成までを一括実行する |

**進め方**
- **データ処理**：実験ログ、metrics ファイル、結果ディレクトリを読む
- **統計検定**：適切な前提の下で t-test / ANOVA / Wilcoxon などの厳密統計検定を行う
- **科研可視化**：曖昧な作図提案ではなく、実際の科研図と解釈の手がかりを生成する
- **消融と比較**：コンポーネント寄与、性能 tradeoff、安定性を分析する
- **実験後レポート**：分析パッケージを、結論・制約・次アクションを含む完全な実験後レポートへ変換する

**典型的な成果物**
- `analysis-report.md`
- `stats-appendix.md`
- `figure-catalog.md`
- `figures/`
- Obsidian `Results/Reports/` に書き込まれる実験まとめレポート

### 4. 論文執筆

構造準備から草稿反復までの、体系的な論文執筆ワークフローです。

| 種類 | 名前 | 一行説明 |
|---|---|---|
| Skill | `ml-paper-writing` | リポジトリコンテキスト、エビデンス、文献からML/AI論文を執筆 |
| Skill | [`nature-writing`](./skills/nature-writing/README.md) | claims、figures、results、notes、または中国語草稿から Nature スタイルの論文セクションを起草・再構成する |
| Skill | [`nature-polishing`](./skills/nature-polishing/README.md) | 原稿を推敲・再構成・翻訳し、Nature寄りの簡潔な英語へ整える |
| Skill | [`nature-response`](./skills/nature-response/README.md) | Nature系修正投稿向けの point-by-point reviewer response を作成・監査・改稿する |
| Skill | [`nature-data`](./skills/nature-data/README.md) | Nature向け Data Availability、repository plan、FAIR metadata チェックを準備する |
| Skill | `citation-verification` | 参考文献、メタデータ、主張と引用の整合性をチェックし引用ミスを防止 |
| Skill | `writing-anti-ai` | 機械的な表現を減らし、明瞭さ、リズム、人間的な学術トーンを改善 |
| Skill | `latex-conference-template-organizer` | 乱雑な学会テンプレートをOverleaf対応のライティング構造に整理 |
| Agent | `paper-miner` | 優れた論文から再利用可能なライティングパターン、構造、学会の期待値を抽出 |
| Command | `/mine-writing-patterns` | 論文を読み込み、再利用可能なライティング知識を現在インストール済みのpaper-minerメモリに統合 |

**仕組み**
- **テンプレート準備**: 学会テンプレートをOverleaf対応構造に整理
- **ジャーナル寄りの推敲**: 必要に応じて段落ロジック、hedging、section moves を整え、Nature寄りの文体へ近づける
- **査読返信**: major/minor revision コメントを監査可能な point-by-point response package に整理する
- **データ可用性**: Nature向けの repository plan、dataset citation、availability statement を準備する
- **引用検証**: 参考文献、メタデータ、主張と引用の整合性を検証
- **体系的執筆**: リポジトリコンテキスト、実験根拠、文献ノートからセクションを執筆し、未支持の主張は明示的に残す
- **主張台帳**: 貢献、結果、関連研究との差分は根拠へ追跡し、そうでなければ推測的な表現として扱う
- **スタイル改善**: 機械的な表現を減らし、リズム、明瞭さ、トーンを改善

### 5. 論文セルフレビュー

投稿前の品質保証ワークフローです。

| 種類 | 名前 | 一行説明 |
|---|---|---|
| Skill | `paper-self-review` | 投稿前に構造、論理、引用、図表、順守項目を体系的に確認する |

**進め方**
- **構造確認**：論理の流れ、章バランス、叙述の一貫性を確認する
- **論理検証**：claim-evidence の整合、仮説の明瞭さ、議論の一貫性を確認する
- **引用監査**：引用の正確さと完全性を点検する
- **図表品質**：caption 完整性、可読性、アクセシビリティを確認する
- **順守確認**：ページ制限、形式、開示要件を確認する

### 6. 投稿と Rebuttal

投稿準備と査読返信のワークフローです。

| 種類 | 名前 | 一行説明 |
|---|---|---|
| Skill | `review-response` | 査読コメントを、証拠ベースの rebuttal ワークフローへ整理する |
| Agent | `rebuttal-writer` | 専門的で礼儀正しく、構造の明確な rebuttal 文書を起草する |
| Command | `/rebuttal` | 査読コメントと既存証拠に基づき、完全な rebuttal 草稿を生成する |

**進め方**
- **投稿前確認**：会議 / ジャーナルの形式、匿名化、checklist 要件を確認する
- **査読分析**：コメントを実行可能な問題に分類する
- **返信戦略**：accept / defend / clarify / 追加実験のどれを取るか判断する
- **Rebuttal 執筆**：構造的で証拠に基づき、語調の整った返信文書を作る

### 7. 採択後処理

採択後の会議準備と研究発信ワークフローです。

| 種類 | 名前 | 一行説明 |
|---|---|---|
| Skill | `post-acceptance` | 発表、ポスター、発信素材の準備を支援する |
| Command | `/presentation` | 会議発表の構成と話し方ガイドを生成する |
| Command | `/poster` | 論文内容を整理し、ポスター構成とレイアウト指針を生成する |
| Command | `/promote` | 外部向け要約、投稿文、thread を起草する |

**進め方**
- **発表準備**：発表構成と資料指針を整える
- **ポスター整理**：ポスターの内容階層と版面を整理する
- **対外発信**：ソーシャルメディア、ブログ、簡明研究要約を生成する

## 支援ワークフロー

これらのワークフローは主ワークフローの背後で動き、全体体験を強化します。

### Obsidian プロジェクト知識ベース

Obsidian を、単なるメモ置き場ではなく、project-scoped な durable knowledge surface として扱います。

| 種類 | 名前 | 一行説明 |
|---|---|---|
| Skill | `obsidian-project-kb-core` | project-scoped KB の bootstrap、routing、registry、index、daily、lifecycle を統括する主 skill |
| Skill | `obsidian-source-ingestion` | 外部資料を `Sources/Papers`、`Sources/Web`、`Sources/Docs`、`Sources/Data`、`Sources/Interviews`、`Sources/Notes` に取り込む |
| Skill | `obsidian-literature-workflow` | `Sources/Papers` から `Knowledge`、`Writing`、`Maps/literature.canvas` へ文献 synthesis を進める |
| Skill | `obsidian-kb-artifacts` | wikilinks、registry tables、canvas、optional Bases、link repair など Obsidian-native artifacts を扱う |
| Command | `/kb-init` | `Research/{project-slug}/` 配下に vault-first KB を初期化する |
| Command | `/kb-status` | バインド済み project root から現在の KB 状態を要約する |
| Command | `/kb-ingest` | 新しい source material を正しい canonical KB destination に振り分ける |
| Command | `/kb-log` | 当日の `Daily/` と関連 project surfaces を保守的に更新する |
| Command | `/kb-sync` | registry、index、daily、runtime binding state を deterministic に再同期する |
| Command | `/kb-links` | canonical notes 間の wikilinks を修復または強化する |
| Command | `/kb-promote` | `Daily/` や source notes から durable content を canonical notes へ昇格する |
| Command | `/kb-index` | `02-Index.md` を human-readable な project navigator として再生成する |
| Command | `/kb-lint` | deterministic KB health checks を実行し `_system/lint-report.md` を更新する |
| Command | `/kb-archive` | link と registry を保ちながら KB object の archive、detach、purge、rename を行う |
| Command | `/kb-map` | 既定の literature canvas 以外の explicit-only artifacts を生成または修復する |
| Command | `/kb-literature-review` | `Sources/Papers` から `Knowledge`、`Writing`、`Maps/literature.canvas` を生成する |

旧 Obsidian command aliases は削除済みです。Obsidian KB 作業はすべて `/kb-*` command surface を使用してください。

**進め方**
- 既存 repo を Obsidian vault にバインドする
- 安定知識を `Sources / Knowledge / Experiments / Results / Results/Reports / Writing / Daily / Maps` に振り分ける
- `Daily/` と repo-local binding metadata を保守的に維持する
- 新しい source material を正しい canonical destination に取り込む
- 追加の Bases や canvas は明示要求がある場合だけ生成する
- deterministic resync は `/kb-sync`、単独の link repair は `/kb-links` を使う

**ノート言語設定**

Obsidian ノート生成・同期時の言語は次の優先順位で解決されます。
1. project config: `.opencode/project-memory/registry.yaml` -> `note_language`
2. environment variable: `OBSIDIAN_NOTE_LANGUAGE`
3. default: `en`

補足：`registry.yaml` は歴史的互換性のために名前だけ残っており、repo-local runtime binding file として扱います。project 内で見える source of truth は `_system/registry.md` です。

プロジェクト単位の例：

```json
{
  "projects": {
    "my-project": {
      "project_id": "my-project",
      "vault_root": "/path/to/vault/Research/my-project",
      "note_language": "zh-CN"
    }
  }
}
```

同期時には英語と中国語の section heading がどちらも互換的に扱われるため、設定変更後でも過去の英語 / 中国語ノートは安全に更新できます。

### 自動化制約ワークフロー

OpenCode plugins が runtime guards として日常的なチェックとリマインドを提供します。

**Plugin 一覧**
- `skill-eval.ts`
- `session-start.ts`
- `session-summary.ts`
- `stop-summary.ts`
- `security-guard.ts`

**進め方**
- **ユーザー質問前**：現在の prompt で発火すべき skills を評価し、関連 workflow ヒントを補足する
- **セッション開始時**：Git 状態、利用可能コマンド、project memory 文脈を表示する
- **セッション終了または停止時**：作業内容をまとめ、最低限のメンテナンス行動をリマインドする
- **安全防護**：破壊的コマンドを遮断し、危険だが妥当な操作には確認を要求する

### 知識抽出ワークフロー

専用 agents が論文や競技解法から再利用可能な知識を継続的に抽出します。

| 種類 | 名前 | 一行説明 |
|---|---|---|
| Agent | `paper-miner` | 高品質論文から再利用可能な執筆知識、構造パターン、投稿ノウハウを抽出する |
| Agent | `kaggle-miner` | 優れた Kaggle ワークフローから実装慣行と解法パターンを抽出する |

**進め方**
- 論文から書き方、会議要求、rebuttal 戦略を抽出する
- Kaggle ワークフローから実装パターンと解法構造を抽出する
- それらを skills と references に還流する

### Skill 進化システム

Claude Scholar には self-improving な skill ワークフローも内蔵されています。

| 種類 | 名前 | 一行説明 |
|---|---|---|
| Skill | `skill-development` | 明確な発火条件、構造、段階的展開を備えた新しい skill モジュールを作る |
| Skill | `skill-quality-reviewer` | 内容品質、構成、表現、構造完全性の観点から skill を審査する |
| Skill | `skill-improver` | 構造化された改善計画に基づいて既存 skill を継続改善する |

**進め方**
- 明確な発火説明を持つ新 skill を作る
- 複数の品質軸で skill をレビューする
- 改善提案を取り込み、継続的に反復する

### 表現と報告の規律レイヤー

結論先行の報告、具体的なエビデンス、可視化されたリスク、または簡潔な次アクションが必要なときは、再利用可能なコミュニケーションレイヤーを使います。

| 種類 | 名前 | 概要 |
|---|---|---|
| Skill | [`expression-skill`](./skills/expression-skill/README.md) | 技術作業、執筆、ドキュメント、ファイル操作、多段タスク向けに、結論先行で具体的かつ検証可能な表現規律を適用する |

**仕組み**
- 経緯説明ではなく結論から始める
- 抽象的なプロセス語より、コマンド、パス、件数、チェック結果、観測可能な挙動を優先する
- 結果が変わるときだけ確認質問をする
- リスク、不確実性、破壊的境界を早めに明示する
- 長時間作業では step / checkpoint 形式の可視化された進捗目印を出す

## ドキュメント入口

- [MCP_SETUP.ja-JP.md](./MCP_SETUP.ja-JP.md) — Zotero / ブラウザ MCP 設定
- [OBSIDIAN_SETUP.ja-JP.md](./OBSIDIAN_SETUP.ja-JP.md) — Obsidian プロジェクト知識ベースワークフロー
- [AGENTS.md](./AGENTS.md) — 軽量な OpenCode コア指示
- [AGENTS.zh-CN.md](./AGENTS.zh-CN.md) — 軽量コア指示の中国語 companion ファイル
- [README.md](./README.md) — 英語版 README
- [README.zh-CN.md](./README.zh-CN.md) — 中国語版 README
- [opencode.jsonc](./opencode.jsonc) — plugin / MCP / agent / permission の任意設定テンプレート

## プロジェクトルール

Claude Scholar には次の領域のルールが含まれます。
- コードスタイル
- agent オーケストレーション
- 安全制約
- 実験再現性

常時有効なルールは主に `AGENTS.md` にあり、詳細なワークフローは同梱 skills と docs に残しています。

## コントリビューション

issue、PR、ワークフロー改善提案を歓迎します。

installer、Zotero ワークフロー、Obsidian ルーティングを変更したい場合は、提案に次を含めてください。
- ユーザーシナリオ
- 現在の制約
- 期待される挙動
- 互換性への影響

## ライセンス

MIT License。

## 引用

Claude Scholar があなたの研究またはエンジニアリングワークフローの助けになった場合は、次のように引用できます。

```bibtex
@misc{claude_scholar_2026,
  title        = {Claude Scholar: Semi-automated research assistant for academic research and software development},
  author       = {Gaorui Zhang},
  year         = {2026},
  howpublished = {\url{https://github.com/Galaxy-Dawn/claude-scholar}},
  note         = {GitHub repository}
}
```

## 謝辞

OpenCode 向けに構築され、より広い Claude Scholar エコシステムと整合するよう維持されています。

### 参考資料

本プロジェクトはコミュニティの優れた仕事から着想を得て構築されています。

- **[everything-claude-code](https://github.com/anthropics/everything-claude-code)** - Claude Code CLI の総合リソース
- **[AI-research-SKILLs](https://github.com/zechenzhangAGI/AI-research-SKILLs)** - 研究指向の skills と設定
- **[expression-skill](https://github.com/Galaxy-Dawn/expression-skill)** - 報告と応答の規律に使う公開の結論先行コミュニケーション skill
- **[nature-skills](https://github.com/Yuan1z0825/nature-skills)** - Nature スタイルの章起草、学術推敲、査読返信、データ可用性 skills をここで再利用し、出典を明記

これらのプロジェクトは、Claude Scholar の研究志向機能に貴重な知見と土台を与えています。

---

**データサイエンス、AI 研究、学術執筆のために。**

リポジトリ：[https://github.com/Galaxy-Dawn/claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar)
