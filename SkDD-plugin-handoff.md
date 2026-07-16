# SkDD → Claude Code Plugin 化 — HandOff

> このドキュメントは、SkDD (Skill Driven Development) を Claude Code の **Plugin** として実装するための引き継ぎ資料です。Claude Code 上での作業を想定し、フレッシュなセッション(またはサブエージェント)がこれ単体で着手できるように書いています。
>
> 記述方針: 本資料自体が SkDD の中核原則である **「How だけでなく Why を残す」** に従い、各判断について *なぜそうするのか* を明示しています。手順(How)だけを拾って実装すると、前提が変わったときに壊れます。

---

## 0. 30秒サマリ

- **やること**: SkDD を Claude Code Plugin 化し、`skills/` を主要コンポーネントとして構成する。
- **中核データモデル**: 各 Skill は `SKILL.md`(現行の Why+How スナップショット)と `harvest.md`(進化の系譜 = Skill 単位の ADR)のペアを持つ。
- **中核プロトコル**: SKILL.md の更新と harvest.md への追記は **1トランザクション**として扱う(原子的更新)。
- **配布**: 個人で iterate → 固まったら private marketplace でチーム配布。
- **前提の追い風**: SKILL.md はセッション内でホットリロードされる(育てる思想と一致)。commands/ は legacy 化しており、skills/ を主軸にすべき。

---

## 1. 背景と目的 (Why)

### 1.1 SkDD とは(この資料での前提定義)

SkDD は「再利用可能な作業パターンを Skill として結晶化し、それを **育てていく**」開発哲学。Claude(エージェント)が閾値を超えた再利用パターンを自律検出し、Skill 化を提案・更新する。ポイントは Skill が **一度作って終わりではなく、成長する生き物**である点。

### 1.2 なぜ今 Plugin 化するのか

ここまでの議論で到達した結論:

- タスクの **進め方**(汎用ワークフロー、手続き的足場)は、本体が賢くなるほど吸収され陳腐化する。
- 陳腐化しないのは **文脈・規約・判断(Why)を運ぶ器**。本体が賢くなるほど、その意図を正確に実行してくれるようになり、むしろ価値が上がる。
- SkDD はまさに後者(あなた固有の判断を Skill に結晶化する)への投資なので、方向として正しい。

Plugin 化は、この「資産」を **versioned・shareable・governed** な単位に昇格させる手段。個人の dotfile(`.claude/`)に散らばった知恵を、チーム全体が install・update・trust できる標準にする。CTO としてチーム(~10名)へ横展開する文脈では、この配布レイヤーが本質的に効く。

### 1.3 この HandOff が確定させた設計判断

前段の対話で合意済みの、**動かしてはいけない**判断:

1. **資産の単位は「Why を伴った How」**。裸の How(判断基準を欠いた手順)は brittle。捨てるのは裸の How、残すのは Why を背負った How。
2. **Why の置き場を二分する**:
   - **生きた Why**(なぜ *今* この手順を採るか)→ `SKILL.md` に **インライン**で残す。これは実行時の逸脱・適応を生む生成器なので、ランタイムに読まれる場所に置く必要がある。
   - **退役した Why**(なぜ旧アプローチを捨てたか、何を試して却下したか)→ `harvest.md` に残す。
3. **SKILL.md = 現行の Why+How スナップショット / harvest.md = 進化の系譜(ADR)**。
4. **原子的更新**: 「Skill を進化させる = harvest.md に決定を append しつつ SKILL.md の該当箇所を差し替える」を 1トランザクションとして定義。片方だけの変更は不正。
5. **閾値ゲート**: harvest.md に記録するのは **decision-level の変更だけ**。瑣末な How の微修正は SKILL.md 直編集で済ませ、harvest をノイズで埋めない(ADR の価値は信号の濃さ)。

---

## 2. コア設計原則(不変の判断基準)

> このセクションが SkDD Plugin の「憲法」。実装のどこで迷っても、ここに戻れば判断がブレない。

### 2.1 harvest.md = Skill 単位の ADR

ADR(Architecture Decision Record)の性質を harvest.md に寄せる:

- **append-only**: 既存エントリは書き換えず、新しい決定で supersede する。
- 各エントリが持つべき要素:
  - `context`: 変更を引き起こした状況(なぜ再検討が起きたか)
  - `change`: Why と How が何にどう変わったか
  - `superseded-by` / `supersedes`: どの過去決定を上書きするか(系譜リンク)
  - `result`: 変更の結果(わかっていれば)
- これにより **判断の lineage(系譜)** が辿れる ADR になる。

### 2.2 原子的更新がもたらす2つの効果

- **quality gate 化**: 「SKILL.md を編集する前に harvest エントリ(=なぜ変えるか)を書け」を強制すると、判断が黙って上書きされる代わりに毎回捕捉される。ドキュメントというより **変更を判断込みで残させる強制関数**。
- **oscillation 防止**: 状況がドリフトして再検討が起きたとき、退役 Why が残っていれば「そのアプローチは前に検討して却下済み」を参照でき、エージェントが過去に捨てた案を賢そうな顔で再採用する thrash を止められる。

### 2.3 整合性の担保(最重要の運用規律)

エージェントが自律的に Skill を育てる以上、片方だけ更新される drift は構造的に起きうる。したがって:

- **harvest 末尾 = SKILL.md 現行** が常に一致する状態を不変条件とする。
- この不変条件が保たれると、**harvest.md の末尾を読むだけで「なぜ今この形なのか」が即座に辿れる**という副産物が得られる。

---

## 3. ターゲットアーキテクチャ(Plugin 構造)

### 3.1 ディレクトリレイアウト

```
skdd/                                  # プラグインルート
├── .claude-plugin/
│   └── plugin.json                    # マニフェスト(このディレクトリにはこれだけ)
├── skills/
│   ├── skdd/                          # ★ メタスキル本体(Skill を検出・提案・育成)
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── harvest-protocol.md    # 原子的更新プロトコルの詳細
│   │       └── adr-entry-schema.md    # harvest.md エントリのスキーマ
│   └── <harvested-skill>/             # ← SkDD が育てていく個別 Skill 群
│       ├── SKILL.md                   # 現行の Why+How スナップショット
│       └── harvest.md                 # 進化の系譜(ADR)= bundled resource
├── hooks/
│   └── hooks.json                     # 整合性チェック用(§3.4)
└── scripts/
    └── harvest_guard.*                # SKILL.md/harvest.md 整合性チェッカ
```

**設計上の注意**:
- `.claude-plugin/` には **plugin.json だけ**。skills / hooks / scripts はすべてルート直下。
- `harvest.md` は標準コンポーネントではなく、**Skill ディレクトリ内の bundled resource**として置く。これにより progressive disclosure が効き、**通常は context に載らない**(トークンコストを食わない)。育成/ADR 参照フロー時にのみエージェントが読む。
- `commands/` は **作らない**。現行の方向性は skills 主軸で、commands は legacy 扱い。SkDD の思想(進め方の足場は消耗品、判断の器が資産)とも一致する。
- ポータブルなパス参照が必要な場合は `${CLAUDE_PLUGIN_ROOT}` を使う(ハードコード禁止)。

### 3.2 plugin.json(最小構成)

```json
{
  "name": "skdd",
  "version": "0.1.0",
  "description": "Skill Driven Development — 再利用パターンを Skill として結晶化し、Why を伴って育てるメタフレームワーク",
  "author": { "name": "rabitarochan" },
  "license": "MIT",
  "keywords": ["skill", "skdd", "adr", "orchestration"]
}
```

- `name` は kebab-case。これが **skill namespace** になり、個別 Skill は `/skdd:<skill-name>` で呼べる。
- `version` は semver。これが **update のキャッシュキー**なので、チーム配布時は「fix がチームに届いたか」を左右する。

### 3.3 メタスキル `skdd` の責務

`skills/skdd/SKILL.md` が SkDD 本体。責務:

1. **検出**: 会話中に閾値を超えた再利用パターンを検知する。
2. **提案**: Skill 化 / 既存 Skill の更新を提案する(閾値ゲート判定込み)。
3. **育成**: SKILL.md 更新 + harvest.md 追記の **原子的更新プロトコル**を実行する。

> `skdd/SKILL.md` の description は「pushy」に書く(Claude は Skill を undertrigger しがちなため)。例: 「... 再利用可能なパターン、繰り返し手順、"これ前にもやった" という状況が現れたら、明示的な依頼がなくてもこの Skill を使うこと」。

### 3.4 hooks による整合性チェック(補助)

`hooks/hooks.json` で **PostToolUse**(Edit/Write が `**/SKILL.md` にマッチしたとき)に整合性チェッカを発火:

- git working tree を見て、SKILL.md が変わったのに兄弟 `harvest.md` が変わっていなければ **warn(または block)**。
- **正確な期待値**: hook は単一ツールイベントへの反応なので、真の「トランザクション性」は保証できない。**一次的な保証はメタスキルのプロトコル**(SKILL.md を編集するなら harvest 追記が必須)にあり、hook は working tree の不整合を検出する **advisory な安全網**という位置づけ。

---

## 4. Claude Code Plugin の事実(実装制約 / 2026-07 時点)

実装前に押さえるべき、確認済みの現行仕様:

- **必須ファイル**は `.claude-plugin/plugin.json` のみ。省略時はディレクトリ名から名前を導出し、コンポーネントを既定位置から auto-discover する。
- コンポーネント配置: `commands/` `agents/` `skills/` `hooks/` は **すべてルート直下**。`.claude-plugin/` の中に入れてはならない。
- **ライブ変更検知**: SKILL.md の変更は現在のセッションに **即時反映**。hooks/ `.mcp.json` agents/ output-styles/ の変更は `/reload-plugins` か再起動が必要。→ **SkDD の「育てる」ループは SKILL.md 上で回すのが最もフリクションが低い**。
- **commands/ は legacy** 扱いで、skills/ の使用が推奨されている。
- **namespace**: プラグイン Skill はスラッシュコマンド呼び出し時 `plugin-name:skill-name` 形式。
- **token コストの可視化**: `claude plugin details <name>` で always-on(毎セッション載る listing テキスト)と on-invoke(発火時)コストを確認できる。SkDD が肥大化していないかの監視に使える。
- **skills-dir プラグイン**: `~/.claude/skills/<name>/` に置くと install 不要で次セッションから `<name>@skills-dir` として自動ロード。**iterate 段階に最適**(marketplace 不要)。
- **marketplace**: git リポジトリ root の `.claude-plugin/marketplace.json` で定義。private(チーム専用)可。plugin source は `sha` でコミット固定でき、production では再現性のため推奨。

---

## 5. 実装フェーズ (How)

> How には各フェーズの Why を添える。フェーズ順序は「iterate しやすさ → 保証の強度 → 配布」の順。

### Phase 0 — skills-dir で iterate(install レス)
**Why**: marketplace や plugin.json の儀式なしに、SKILL.md ホットリロードで高速に回すため。
- `~/.claude/skills/skdd/SKILL.md` にメタスキルのドラフトを置く。
- 手で数回「Skill 提案 → SKILL.md/harvest.md 生成」を回し、プロトコルの当たりを取る。

### Phase 1 — メタスキル + harvest プロトコル確立
**Why**: SkDD の心臓部。ここが固まらないと後続の強制も配布も意味を持たない。
- `skdd/SKILL.md` に検出・提案・育成の 3 責務を記述。
- `references/harvest-protocol.md` に原子的更新の手順、`references/adr-entry-schema.md` にエントリスキーマ(§2.1)。
- 個別 Skill の生成テンプレ(SKILL.md = 生きた Why 込み / harvest.md = 初期エントリ)を定義。

### Phase 2 — hook で整合性を強制
**Why**: 自律更新での drift は構造的に起きる。メタスキルの規律を、機械的な安全網で二重化する。
- `scripts/harvest_guard.*` を実装(git diff ベースの兄弟ファイル整合チェック)。
- `hooks/hooks.json` の PostToolUse に登録。まずは warn、運用が乗ったら block へ。

### Phase 3 — Plugin 化 + private marketplace 配布
**Why**: 個人資産をチーム標準へ昇格。versioned・governed に。
- `.claude-plugin/plugin.json` を整備、skills-dir 版から plugin レイアウトへ移行。
- 別 git リポジトリ root に `.claude-plugin/marketplace.json` を置き、`skdd` を登録。
- チームは clone → trust dialog → install の day-one フローで同一の Skill 群を得る。
- production 配布では plugin source を `sha` 固定。

### Phase 4(任意)— cc-orchestrator との統合
**Why**: 既存のオーケストレーション資産と接続し、サブエージェントの成果を Skill として harvest する回路を作る。
- サブエージェント実行後に「harvest 候補」を skdd メタスキルへ流すフックを検討。
- ※ これは新規スコープなので、Phase 3 まで固めてから別途設計する。

---

## 6. 未決事項 / 実装前に決めるべき点

1. **閾値の定義**: 「再利用パターンが Skill 化に値する」閾値を何で測るか(出現回数? 手順の複雑さ? 判断分岐の有無?)。harvest 記録の閾値(decision-level とは何か)も同時に定義が必要。
2. **harvest.md のフォーマット**: Markdown 見出しベースか、front-matter 付き構造化か。機械的な整合チェック(Phase 2)のしやすさと人間の可読性のトレードオフ。
3. **原子性の強制レベル**: hook を warn 止まりにするか block まで上げるか。block はエージェントの自律更新を阻害しうるので、運用データを見てから判断。
4. **メタスキルの粒度**: `skdd` 単一スキルにまとめるか、`skdd-detect` / `skdd-grow` などに分割するか。分割は責務が明確になるが always-on トークンが増える(`claude plugin details` で計測して判断)。
5. **skill-creator との関係**: 既存の skill-creator(eval ループつき)と SkDD メタスキルの役割分担。SkDD は「育成 + ADR + 閾値検出」に特化し、eval/最適化は skill-creator に委ねる、が素直な切り分け候補。

---

## 7. 参考リンク

- Claude Code Plugins reference: https://code.claude.com/docs/en/plugins-reference
- Plugins in the SDK(構造・namespace・commands legacy 表記): https://platform.claude.com/docs/en/agent-sdk/plugins
- Claude Code docs overview: https://docs.claude.com/en/docs/claude-code/overview
- プラグイン提出: platform.claude.com/plugins/submit

---

## 付録: 実装エージェントへの最初の指示例

> 次のように始めると、この HandOff の意図に沿って着手できる:

```
このリポジトリで SkDD を Claude Code Plugin として実装したい。
まず SkDD-plugin-handoff.md を読み、§2 のコア原則(特に
「Why を伴った How が資産」「SKILL.md=現行/harvest.md=ADR」
「原子的更新」)を絶対制約として扱ってほしい。
Phase 0 から始め、~/.claude/skills/skdd/SKILL.md のドラフトを
書いたら、§6 の未決事項1(閾値定義)について私に確認を取ること。
```
