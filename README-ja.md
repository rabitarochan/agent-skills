# agent-skills (日本語ドキュメント)

Claude Code のプラグイン marketplace です。プラグインの中身(スキル・
テンプレート・コマンド)は英語で記述されています。本ファイルはその日本語解説です。

| プラグイン | 概要 | 詳細 |
|---|---|---|
| `skdd` | **SkDD (Skill Driven Development)** — 再利用可能な作業パターンを Skill として結晶化し、**Why(判断理由)** を伴って育てる。収穫エンジンを各プロジェクトへ配置する。 | [plugins/skdd](plugins/skdd/README.md) |
| `design-docs` | 新規プロジェクト・機能追加・単一の技術的決定の設計を対話で詰め、設計ドキュメント / ADR として書き出す。 | [plugins/design-docs](plugins/design-docs/README.md) |

## インストール

```
claude plugin marketplace add rabitarochan/agent-skills
claude plugin install skdd@agent-skills
claude plugin install design-docs@agent-skills
```

2 つのプラグインは独立しているので、必要なものだけ入れてください。

ローカル開発時:

```
claude plugin marketplace add /path/to/agent-skills
```

## skdd

**SkDD (Skill Driven Development)** — 再利用可能な作業パターンを Skill として
結晶化し、**Why(判断理由)** を伴って育てる開発手法です。

### アーキテクチャ

**プラグイン = エンジン + インストーラー / プロジェクト = 実体(マテリアライズされた資産)**

プラグインが公開するのは明示呼び出し専用のスキル(`/skdd:setup`、
`/skdd:config`、`/skdd:update`)のみです。収穫エンジン(`skdd-harvest`)はテンプレートペイロード
として、setup が各プロジェクトへコピーします。配置される資産は素のプロジェクト
ファイル(`.claude/skills/`、`AGENTS.md`)なので、AGENTS.md を読む OpenAI Codex
などの Agent Skills 対応プラットフォームも、何もインストールせずに SkDD に
参加できます。

プロジェクトごとの skdd-harvest が、プロジェクト固有の判断と知識(Why + How)を
`<接頭辞><domain>-<action>` という名前のスキル(デフォルト接頭辞 `pj-`)に
結晶化していきます。これが SkDD の本質です。

収穫されたスキルは必ずペアで管理します:

- `SKILL.md` — 現行の Why + How スナップショット
- `harvest.md` — スキルの進化の系譜(追記専用の ADR)

decision-level の変更で SKILL.md を編集する場合、同一トランザクションで
harvest.md にエントリを追記します(**原子的更新**プロトコル)。詳細は
`plugins/skdd/templates/skdd-harvest/references/harvest-protocol.md` を参照してください。

#### 2 層の執筆規約: SkDD 不変条件とプラットフォーム作法

収穫のドクトリンは「SkDD が所有するもの」と「プラットフォームが所有するもの」を
分離しています。**SkDD 不変条件** — 5 基準、収穫閾値とレベルごとのバー・行数上限、
SKILL.md + harvest.md ペアと原子的更新、命名・ルーティング、oscillation guard —
はエンジンにハードコードされ、常に優先されます。**プラットフォーム作法** —
frontmatter のフィールド構成、description の書き方、本文の骨子、
progressive disclosure の流儀 — はプラグインに焼き込まず、収穫時に解決します:
セッションに skill 作成系スキル(例: Anthropic の `skill-creator`)があれば
それが優先、なければモデル自身が持つ最新の Skills ベストプラクティス、
どちらも無ければエンジン同梱の日付付きベースライン(2026-08 時点)です。
ドキュメントの取得は行わないため、このチェーンはオフラインでも動作します。
既存スキルの更新では、新しい作法は「編集した箇所」にのみ適用します —
スタイル合わせだけの全面リライトは churn として扱います。狙いは、モデルや
Claude Code が進化しても、プラグインを更新することなく、収穫されるスキルが
その時々のベストプラクティスに追従することです。

### 使い方

#### `/skdd:setup` — プロジェクトへの導入

対象プロジェクト内で実行します。次の 3 点を質問されます:

- **スキル接頭辞**(デフォルト `pj-`。`^[a-z][a-z0-9]*-$` に一致すること。
  既存プロジェクトの `mss-` などをそのまま使えます)
- **Stop hook を導入するか**(推奨。応答完了のたびに収穫評価をエージェントに
  促します)
- **収穫閾値**(デフォルト `medium`。後述)

配置されるファイル:

| パス | 役割 | update で管理? |
|---|---|---|
| `.claude/skills/skdd-harvest/SKILL.md` + `references/` | 収穫エンジン | される(上書き) |
| `.claude/skills/skdd-harvest/.gitignore` | backlog.md を ignore | される(上書き) |
| `.claude/skills/skdd-harvest/backlog.md` | Proto-Skill バックログ(ローカル状態) | **されない — 不可侵** |
| `.claude/hooks/skdd-stop.sh` + `.claude/settings.json` の Stop エントリ | 収穫リマインダー hook(opt-in) | される(スクリプト再コピー) |
| `AGENTS.md` の管理セクション(`<!-- skdd:begin/end -->` 間) | 全エージェント向けプロトコル | される(再レンダリング) |
| `CLAUDE.md` の `@AGENTS.md` インポート行 | Claude Code 向けブリッジ | 欠落時に修復 |

`backlog.md` 以外はコミットしてください(backlog.md は gitignore 済み)。

#### `/skdd:config` — プロジェクト設定の変更

**収穫閾値**・**スキル接頭辞**・**Stop hook の有無**を変更し、管理対象の資産を
再レンダリングして全コピーの記述を揃えます。デプロイ済みバージョンは変更しません
(それは `/skdd:update` の役割です)。`backlog.md` と収穫済みスキルには触れません。

```
/skdd:config                 # 対話的に変更
/skdd:config threshold=high  # ワンショット
```

#### `/skdd:update` — 配置済み資産の更新

プラグイン本体を更新(`claude plugin update skdd`)した後、各プロジェクトで
`/skdd:update` を実行します。管理対象の資産を新バージョンで再レンダリングし、
`backlog.md`・収穫済み `<接頭辞>*` スキル・AGENTS.md マーカー外には一切
触れません。

プロジェクトごとのパラメータはマーカー内の config 行に永続化されます:

```
<!-- skdd:config prefix=pj- hooks=true threshold=medium version=0.3.0 -->
```

`threshold` 導入前に setup したプロジェクトにはこのキーがありません。
`/skdd:update` が `medium`(= 従来の挙動と等価)で補完します。

#### 収穫(harvest)の流れ

配置されたエンジン(および非 Claude エージェント向けの AGENTS.md セクション)が
次のループを駆動します。タスク完了時にセッションを 5 基準で評価します:

(1) 再発性 (2) 手順性 (3) 非自明性 (4) 修正由来 (5) 汎用性

このループの選択性は **収穫閾値(threshold)** という 1 本のダイヤルで決まります。
レベルを上げると 3 つが同時に厳しくなります: スコアのバー、新規作成より既存スキル
更新に寄せる強さ、そして蒸留の規律です。適切な値はプロジェクト共通ではありません —
スキルが無いうちは積極的に拾うべきですが、成熟したプロジェクトでは逆で、
スキルが増えるほど全体が薄まり、必要な 1 つを見つけにくくなります。

| レベル | 提案 | Proto-Skill | 昇格 | 統合バイアス | 行数上限 |
|---|---|---|---|---|---|
| `low` | 2/5 以上 | 1/5 | 2 セッション | 明らかに既存が覆う場合を除き新規作成 | 500 行 |
| `medium` | 3/5 以上 | 1-2/5 | 2 セッション | スコープが重なれば更新 | 500 行 |
| `high` | 4/5 以上 | 2-3/5 | 3 セッション | 先に全既存スキルの description を読み、重なれば更新 | 200 行 |
| `max` | 5/5 | 3-4/5 | 4 セッション | 既存が受け皿にならない理由の明示が必要 | 120 行 |

デフォルトは `medium` です。`/skdd:setup` で選択し、`/skdd:config threshold=<レベル>`
で変更します。レベルごとのプロファイル本体は、配置された
`.claude/skills/skdd-harvest/SKILL.md` の「Harvest Threshold」セクションにあり、
そこがこれらの数値の唯一の真実源です。

### バージョニング

`plugin.json` の `version`(semver)が唯一の真実源で、update のキャッシュキー
です。**`plugins/skdd/templates/` または `plugins/skdd/skills/` に変更を加えたら必ず bump してください**
(patch = 文言・修正、minor = プロトコル・挙動の変更)。バージョンは 3 箇所に
スタンプされます: AGENTS.md の config 行、配置された SKILL.md のコメント、
`skdd-stop.sh` のヘッダーコメント。

### 依存関係

- Stop hook は hook 実行環境の PATH に `bash` が必要です(Windows は Git Bash)。
  それ以外の依存はありません(`jq` は意図的に使っていません)。

### v1 の既知の制約

- 配置済み skdd-harvest への手元編集は `/skdd:update` と `/skdd:config` で
  上書きされます — エンジンの改善はこのリポジトリ側で行ってください。
- 接頭辞を変更しても既存スキルはリネームされません。
- 閾値は「これから何を収穫するか」を変えるだけで、既に低い閾値で収穫済みの
  スキルを整理したり再評価したりはしません。
- 新しいプラットフォーム作法も同様に「これから」にのみ適用されます — 更新時も
  編集した箇所だけが対象で、既存スキルが全面的にリスタイルされることは
  ありません。

### プラグイン構成

- `plugins/skdd/.claude-plugin/plugin.json` — プラグインマニフェスト(version が真実源)
- `plugins/skdd/skills/` — インストーラースキル(`setup`、`config`、`update`)
- `plugins/skdd/templates/` — プロジェクトへ配置されるペイロード(エンジンスキル、
  backlog シード、hook スクリプト、AGENTS.md セクション)
- `plugins/skdd/SkDD-plugin-handoff.md` — 設計資料。§2 が設計の憲法(Why を伴った
  How が資産、SKILL.md/harvest.md ペア、原子的更新)

## design-docs

設計ドキュメントを「対話で詰めてから書き出す」ためのスキル群です。

| スキル | 用途 | 出力先 |
|---|---|---|
| `design-new-project` | 新規プロジェクト全体の設計 | `docs/design/README.md` |
| `design-feature` | 既存システムへの機能追加の設計 | `docs/design/features/<slug>/README.md` |
| `design-adr` | 単一の技術的決定の記録 | `docs/adr/NNNN-<slug>.md` |

`/design-docs:design-new-project` などのコマンドからも、スキルの自動発火からも
起動します。スキルの `description` には日本語のトリガーフレーズ(「技術選定」
「設計ドキュメント」など)を含めてあるので、日本語のプロンプトからも発火します。

### 設計方針

- **可搬性**: `SKILL.md` は素の Markdown で書かれ、Claude Code 固有機能
  (サブエージェント、hooks、Plan Mode)に依存しません。サブエージェントによる
  並列調査のみ「利用可能なら使う」という条件付き記述です。`skills/`
  ディレクトリごとコピーすれば他のエージェントでも動作します。
- **依存ゼロ**: 他のスキル・プラグインに依存しません。共通リファレンスの参照は
  同梱ディレクトリ内で完結します。
- **スキル本文は英語、成果物はユーザーの利用言語**。
- **設計のプロとして章を選ぶ**。固定テンプレートを埋めさせず、必要な章とその
  理由・除外した章とその理由を冒頭で 1 回だけ提示して合意を取ります。
- **実装計画は書かない**。設計ドキュメントは Plan Mode の入力であり、タスク
  分割は別セッションの仕事です。

章立ての原則は Michael Lynch, "How to Write an Effective Software Design
Document"
(<https://refactoringenglish.com/excerpts/write-an-effective-design-doc/>)
を参考に、独自の言葉で再構成しています。

## リポジトリ構成

- `.claude-plugin/marketplace.json` — marketplace マニフェスト
- `plugins/<name>/` — プラグイン 1 つにつき 1 ディレクトリ。それぞれが
  `.claude-plugin/plugin.json` と README を持つ
- 各プラグインのバージョンはそれぞれの `plugin.json` で独立して管理されます

## ライセンス

MIT
