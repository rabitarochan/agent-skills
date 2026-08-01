---
name: config
description: >
  Change SkDD's per-project settings — the harvest threshold
  (low/medium/high/max), the skill prefix, and whether the Stop hook is
  installed — then re-render the managed assets so every artifact agrees.
  Explicit invocation only (/skdd:config).
disable-model-invocation: true
---

# /skdd:config — Change SkDD's per-project settings

You are changing the settings of a SkDD installation that `/skdd:setup` already
deployed into the project in the current working directory, and re-rendering the
managed artifacts so they all reflect the new values.

Plugin file references below use `${CLAUDE_PLUGIN_ROOT}` — resolve it to the
skdd plugin's installation directory.

`/skdd:config` changes **settings**. `/skdd:update` changes the **version**.
Neither does the other's job: this skill never bumps the deployed version, and
it never pulls in a newer engine than the one already installed.

## Hard prohibitions (read first)

NEVER, under any circumstances:

- touch `.claude/skills/skdd-harvest/backlog.md`
- touch any skill directory other than `.claude/skills/skdd-harvest/`
  (in particular, never touch harvested `<prefix>*` skills or their harvest.md)
- write outside the `<!-- skdd:begin -->` / `<!-- skdd:end -->` markers in AGENTS.md
- delete user files
- rename harvested skills when the prefix changes (see Step 5)
- modify `.claude/settings.json` beyond adding or removing the single skdd Stop
  hook entry
- change the `version=` value in the config line

## Step 1 — Read the current settings

1. Read `AGENTS.md`. If it does not exist or contains no `<!-- skdd:begin -->`
   line, SkDD is not set up here — tell the user to run `/skdd:setup` and STOP.
2. Parse the config line (first line inside the markers):
   `<!-- skdd:config prefix=<prefix> hooks=<true|false> threshold=<level> version=<semver> -->`
   — space-separated `key=value` pairs.
3. If `threshold=` is absent (a project set up before the key existed), treat the
   current value as `medium` — that is the level whose behaviour matches a
   pre-threshold install.
4. If the config line is missing or unparseable, ask the user for all three
   settings and continue (self-healing re-render).

## Step 2 — Decide the new settings

If the invocation carried arguments in `key=value` form (e.g.
`/skdd:config threshold=high`), apply those and skip the questions for keys the
user did not name.

Otherwise, show the current settings and ask which to change. Offer:

1. **Harvest threshold** — `low` / `medium` / `high` / `max`:

   - `low` — harvest eagerly; for a new or under-documented project
   - `medium` — the balanced default (propose at 3 of the 5 criteria)
   - `high` — keep the skill set small and sharp; prefers updating an existing
     skill over adding one
   - `max` — only knowledge that changes how future work is judged

   Raising the level tightens three things at once: the score bar, the bias
   toward updating an existing skill rather than adding one, and how hard the
   writing must be distilled. The full per-level profile is the
   `## Harvest Threshold` section of
   `${CLAUDE_PLUGIN_ROOT}/templates/skdd-harvest/SKILL.md` — read it out if the
   user wants the details.

2. **Skill prefix** — must match `^[a-z][a-z0-9]*-$`. Re-ask on mismatch.
   Warn before accepting a change: existing harvested skills are **not** renamed.

3. **Stop hook** — `true` or `false`.

Validate every value before writing anything. An invalid threshold level is a
re-ask, never a silent fallback — silently ignoring it would leave the user
believing a setting took effect when it did not.

If nothing changed, say so and STOP without writing.

## Step 3 — Derive the threshold values

Read the `## Harvest Threshold` section of
`${CLAUDE_PLUGIN_ROOT}/templates/skdd-harvest/SKILL.md`. That section is the
single source of truth for the level → values mapping; do not derive the numbers
from memory. From the block matching the NEW level, take:

- `SKDD_SCORE_MIN` — the proposal bar as a bare integer (e.g. `4`)
- `SKDD_PROTO_BAND` — the Proto-Skill band exactly as written, ASCII hyphen
  included (e.g. `2-3`, or `1` for a single-value band)
- `SKDD_PROMOTE_SESSIONS` — the promotion session count as a bare integer

## Step 4 — Re-render the managed artifacts

Use the NEW setting values together with the **deployed version from Step 1**
(unchanged). Substitution tokens: `{{SKDD_PREFIX}}`, `{{SKDD_HOOKS}}`,
`{{SKDD_THRESHOLD}}`, `{{SKDD_SCORE_MIN}}`, `{{SKDD_PROTO_BAND}}`,
`{{SKDD_PROMOTE_SESSIONS}}`, `{{SKDD_VERSION}}`.

1. **Engine skill** — copy `${CLAUDE_PLUGIN_ROOT}/templates/skdd-harvest/SKILL.md`
   to `.claude/skills/skdd-harvest/SKILL.md` with substitution, overwriting.
   The `## Harvest Threshold` section describes all four levels and is copied
   as-is; only the "Active level" line carries a token. Do not delete the other
   levels' blocks and do not rewrite their numbers.

   Leave `references/` and `.gitignore` alone — they carry no settings.

2. **Stop hook** — only if `hooks` is `true` after Step 2: copy
   `${CLAUDE_PLUGIN_ROOT}/templates/skdd-stop.sh` to
   `.claude/hooks/skdd-stop.sh` with substitution, overwriting. The script is a
   template, not a verbatim copy — its reminder text states the active bars, and
   it fires on every response completion, so a stale copy would contradict the
   configured threshold at the highest frequency in the system.

3. **AGENTS.md managed section** — render
   `${CLAUDE_PLUGIN_ROOT}/templates/agents-section.md` with the same
   substitutions and replace the region from the `<!-- skdd:begin -->` line
   through the `<!-- skdd:end -->` line, inclusive. Every byte outside the
   markers must remain untouched. The rendered config line carries the new
   settings and the unchanged version.

**Verification (mandatory):** grep every written file for `{{SKDD_` — any hit is
an error. Fix it before reporting success.

## Step 5 — Stop hook install / uninstall

Compare the old and new `hooks` value.

- **`false` → `true`**: install as `/skdd:setup` Step 6 does — copy the script
  (Step 4 already did this) and merge the Stop entry into
  `.claude/settings.json`. Read and parse the file first; **if it fails to parse
  as JSON, STOP and report — never overwrite a file you could not parse.**
  Ensure `hooks.Stop` exists as an array, scan every existing Stop entry's
  command strings for the substring `skdd-stop.sh`, and — only if absent —
  append this matcher-group object to the `Stop` array:

  ```json
  {
    "hooks": [
      {
        "type": "command",
        "command": "bash $CLAUDE_PROJECT_DIR/.claude/hooks/skdd-stop.sh",
        "timeout": 5
      }
    ]
  }
  ```

  Never remove, reorder, or modify existing entries or any other settings key.
  Write back with 2-space indentation.

- **`true` → `false`**: parse `.claude/settings.json` (stop on unparseable JSON).
  From `hooks.Stop`, remove **only** the matcher-group objects whose every
  command string contains `skdd-stop.sh`. If a group also holds non-skdd hooks,
  remove just the skdd hook from that group's inner array and leave the group.
  If `hooks.Stop` ends up empty, an empty array is fine — do not delete the key
  structure or any other settings. Leave `.claude/hooks/skdd-stop.sh` on disk:
  re-enabling should be cheap, and deleting a file the user may have inspected
  buys nothing.

- **unchanged**: do nothing here.

## Step 6 — Report

Tell the user:

- Each setting that changed, as `key: <old> → <new>` (and note any that were
  left alone)
- The full list of files rewritten
- If the threshold changed: the new bars in concrete terms — propose at
  `<SKDD_SCORE_MIN>`/5, Proto-Skill at `<SKDD_PROTO_BAND>`/5, promote after
  `<SKDD_PROMOTE_SESSIONS>` sessions
- Explicit confirmation that `backlog.md` and harvested `<prefix>*` skills were
  not touched, and that the deployed version is unchanged
- If the prefix changed: existing harvested skills keep their old names —
  migrate them by hand if you want them renamed
- If the hook was installed or removed: it takes effect after the session
  restarts (hooks are snapshotted at startup); review with `/hooks`
