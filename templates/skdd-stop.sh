#!/bin/bash
# skdd v{{SKDD_VERSION}} — SkDD (Skill Driven Development) Stop hook
# Prompts a SkDD harvest evaluation when the agent finishes responding.
# Managed by the skdd plugin. Do not edit directly; run /skdd:update.

INPUT=$(cat)

# If the Stop hook already fired (re-evaluation in progress), allow and exit
# to prevent an infinite loop.
if echo "$INPUT" | grep -qE '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

# Emit the SkDD evaluation reminder and block the stop.
cat >&2 <<'MSG'
[SkDD check] Task completion point. Evaluate this session against the criteria:
(1) recurrence (2) proceduralness (3) non-obviousness (4) correction-derived (5) generality
Threshold for this project: {{SKDD_THRESHOLD}}
-> {{SKDD_SCORE_MIN}}/5+: propose skillification | {{SKDD_PROTO_BAND}}/5: silently record a Proto-Skill in the backlog | below that: do nothing
Before proposing a NEW skill, check whether an existing one already covers it — prefer an update.
Skip for simple Q&A, greetings, or confirmation-only exchanges.
MSG
exit 2
