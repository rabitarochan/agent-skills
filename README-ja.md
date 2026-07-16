# agent-skdd (日本語ドキュメント)

**SkDD (Skill Driven Development)** — 再利用可能な作業パターンを Skill として
結晶化し、**Why(判断理由)** を伴って育てる開発手法です。

このリポジトリは Claude Code プラグイン **`skdd`** を配布する、単一リポジトリ
完結の marketplace です。プラグインの中身(スキル・テンプレート)は英語で
記述されています。本ファイルはその日本語解説です。

## アーキテクチャ

**プラグイン = エンジン + インストーラー / プロジェクト = 実体(マテリアライズされた資産)**

プラグインが公開するのは明示呼び出し専用の 2 スキル(`/skdd:setup`、
`/skdd:update`)のみです。収穫エンジン(`skdd-harvest`)はテンプレートペイロード
として、setup が各プロジェクトへコピーします。配置される資産は素のプロジェクト
ファイル(`.claude/skills/`、`AGENTS.md`)なので、AGENTS.md を読む OpenAI Codex
などの Agent Skills 対応プラットフォームも、何もインストールせずに SkDD に
参加できます。

プロジェクトごとの skdd-harvest が、プロジェクト固有の判断と知識(Why + How)を
`<接頭辞><domain>-<action>` という名前のスキル(デフォルト接頭辞 `pj-`)に
結晶化していきます。これが agent-skdd の本質です。

収穫されたスキルは必ずペアで管理します:

- `SKILL.md` — 現行の Why + How スナップショット
- `harvest.md` — スキルの進化の系譜(追記専用の ADR)

decision-level の変更で SKILL.md を編集する場合、同一トランザクションで
harvest.md にエントリを追記します(**原子的更新**プロトコル)。詳細は
`templates/skdd-harvest/references/harvest-protocol.md` を参照してください。

## インストール

```
claude plugin marketplace add rabitarochan/agent-skdd
claude plugin install skdd@agent-skdd
```

ローカル開発時:

```
claude plugin marketplace add /path/to/agent-skdd
claude plugin install skdd@agent-skdd
```

## 使い方

### `/skdd:setup` — プロジェクトへの導入

対象プロジェクト内で実行します。次の 2 点を質問されます:

- **スキル接頭辞**(デフォルト `pj-`。`^[a-z][a-z0-9]*-$` に一致すること。
  既存プロジェクトの `mss-` などをそのまま使えます)
- **Stop hook を導入するか**(推奨。応答完了のたびに収穫評価をエージェントに
  促します)

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

### `/skdd:update` — 配置済み資産の更新

プラグイン本体を更新(`claude plugin update skdd`)した後、各プロジェクトで
`/skdd:update` を実行します。管理対象の資産を新バージョンで再レンダリングし、
`backlog.md`・収穫済み `<接頭辞>*` スキル・AGENTS.md マーカー外には一切
触れません。

プロジェクトごとのパラメータはマーカー内の config 行に永続化されます:

```
<!-- skdd:config prefix=pj- hooks=true version=0.1.0 -->
```

接頭辞の変更: この行の `prefix=` を手で書き換えて `/skdd:update` を実行します
(バージョンが同じ場合は強制再レンダリングを指示)。既存スキルのリネームは
行われないため、手動で移行してください。

### 収穫(harvest)の流れ

配置されたエンジン(および非 Claude エージェント向けの AGENTS.md セクション)が
次のループを駆動します。タスク完了時にセッションを 5 基準で評価します:

(1) 再発性 (2) 手順性 (3) 非自明性 (4) 修正由来 (5) 汎用性

- **3/5 以上** → スキル化(または既存スキルの更新)を提案
- **1–2/5** → `backlog.md` に Proto-Skill としてサイレント記録
- Proto-Skill が **2 セッション以上**で再登場 → 昇格を提案

## バージョニング

`plugin.json` の `version`(semver)が唯一の真実源で、update のキャッシュキー
です。**`templates/` または `skills/` に変更を加えたら必ず bump してください**
(patch = 文言・修正、minor = プロトコル・挙動の変更)。バージョンは 3 箇所に
スタンプされます: AGENTS.md の config 行、配置された SKILL.md のコメント、
`skdd-stop.sh` のヘッダーコメント。

## 依存関係

- Stop hook は hook 実行環境の PATH に `bash` が必要です(Windows は Git Bash)。
  それ以外の依存はありません(`jq` は意図的に使っていません)。

## v1 の既知の制約

- 配置済み skdd-harvest への手元編集は `/skdd:update` で上書きされます —
  エンジンの改善はこのリポジトリ側で行ってください。
- 接頭辞を変更しても既存スキルはリネームされません。

## リポジトリ構成

- `.claude-plugin/` — プラグイン + marketplace マニフェスト
- `skills/` — インストーラー 2 スキル(`setup`、`update`)
- `templates/` — プロジェクトへ配置されるペイロード(エンジンスキル、backlog
  シード、hook スクリプト、AGENTS.md セクション)
- `SkDD-plugin-handoff.md` — 設計資料。§2 が設計の憲法(Why を伴った How が資産、
  SKILL.md/harvest.md ペア、原子的更新)
- `work/` — プラグイン化以前のレガシー資産(参照用。プラグインローダーは
  スキャンしません)
