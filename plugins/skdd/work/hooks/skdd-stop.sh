#!/bin/bash
# SkDD (Skill Driven Development) Stop Hook
# Claude の応答完了時に SkDD 評価を促すフック

INPUT=$(cat)

# 既に Stop hook が発火済み（再評価中）なら許可して終了 → 無限ループ防止
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

# SkDD 評価リマインダーを出して応答をブロック
cat >&2 <<'MSG'
【SkDD チェック】タスク完了ポイントです。以下の基準を評価してください:
(1) 再発性 (2) 手順性 (3) 非自明性 (4) 修正由来 (5) 汎用性
→ 3/5以上: スキル化を提案 | 1-2/5: Proto-Skill としてサイレント記録 | 0/5: 何もしない
※ 単純な質問応答・挨拶・確認のみの場合はスキップしてよい。
MSG
exit 2
