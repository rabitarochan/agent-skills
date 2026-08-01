---
name: setup
description: >
  Install SkDD into the current project. Deploys the skdd-harvest engine skill,
  backlog seed, optional Stop hook, the managed AGENTS.md section, and the
  CLAUDE.md import. Explicit invocation only (/skdd:setup).
disable-model-invocation: true
---

# /skdd:setup — Install SkDD into the current project

You are installing SkDD (Skill Driven Development) assets into the project in
the current working directory. Follow the steps in order. Use your normal
Read/Write/Edit/Glob tools; there are no scripts to run except copying the hook
payload.

Plugin file references below use `${CLAUDE_PLUGIN_ROOT}` — resolve it to the
skdd plugin's installation directory.

## Step 1 — Preflight

1. Confirm the current working directory is the intended project root (a `.git`
   directory is the usual signal). If there is no `.git`, ask the user to
   confirm the target directory before continuing.
2. If `AGENTS.md` exists and contains the line `<!-- skdd:begin -->`: SkDD is
   already set up. Read the `<!-- skdd:config ... -->` line, report the
   installed version, tell the user to run `/skdd:update` instead, and STOP.
   Do not write anything.

## Step 2 — Gather parameters

Ask the user (one question round):

1. **Skill prefix** for project-specific skills. Default: `pj-`. Must match
   `^[a-z][a-z0-9]*-$` (lowercase alphanumeric, trailing hyphen; e.g. `pj-`,
   `mss-`). Re-ask on mismatch.
2. **Install the Stop hook?** (recommended: yes). Explain: at every response
   completion, the hook reminds the agent to run the SkDD harvest evaluation.
   Dependency: `bash` on PATH in the hook environment (Git Bash on Windows).
3. **Harvest threshold.** Default: `medium`. One of `low` / `medium` / `high` /
   `max`. Re-ask on any other value. Present it as one dial that controls how
   selective harvesting is — offer these one-liners:

   - `low` — harvest eagerly; for a new or under-documented project
   - `medium` — the balanced default (propose at 3 of the 5 criteria)
   - `high` — keep the skill set small and sharp; prefers updating an existing
     skill over adding one
   - `max` — only knowledge that changes how future work is judged

## Step 3 — Read the plugin version and derive the threshold values

1. Read `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` and take its `version`
   value as `SKDD_VERSION` for the placeholder substitution below.
2. Read the `## Harvest Threshold` section of
   `${CLAUDE_PLUGIN_ROOT}/templates/skdd-harvest/SKILL.md`. That section is the
   single source of truth for the level → values mapping; do not derive the
   numbers from memory. From the block matching the level chosen in Step 2, take:

   - `SKDD_SCORE_MIN` — the proposal bar as a bare integer (e.g. `4`)
   - `SKDD_PROTO_BAND` — the Proto-Skill band exactly as written, ASCII hyphen
     included (e.g. `2-3`, or `1` for a single-value band)
   - `SKDD_PROMOTE_SESSIONS` — the promotion session count as a bare integer

## Step 4 — Deploy the engine skill

Copy from `${CLAUDE_PLUGIN_ROOT}/templates/skdd-harvest/` into the project at
`.claude/skills/skdd-harvest/` (create directories as needed):

| Source | Target | Substitution |
|---|---|---|
| `SKILL.md` | `.claude/skills/skdd-harvest/SKILL.md` | yes |
| `references/harvest-protocol.md` | `.claude/skills/skdd-harvest/references/harvest-protocol.md` | no (verbatim) |
| `references/adr-entry-schema.md` | `.claude/skills/skdd-harvest/references/adr-entry-schema.md` | no (verbatim) |
| `.gitignore` | `.claude/skills/skdd-harvest/.gitignore` | no (verbatim) |

Substitution = replace EVERY occurrence of these tokens while copying:

- `{{SKDD_PREFIX}}` → the prefix from Step 2
- `{{SKDD_HOOKS}}` → `true` or `false` per Step 2
- `{{SKDD_THRESHOLD}}` → the level from Step 2
- `{{SKDD_SCORE_MIN}}`, `{{SKDD_PROTO_BAND}}`, `{{SKDD_PROMOTE_SESSIONS}}` → the
  values derived in Step 3

Note: the `## Harvest Threshold` section describes all four levels and is copied
as-is. Only the "Active level" line carries a token — do not delete the other
levels' blocks, and do not rewrite their numbers.

**Verification (mandatory):** after writing, grep the written files for
`{{SKDD_`. Any hit is an error — fix before continuing.

## Step 5 — Backlog seed

If `.claude/skills/skdd-harvest/backlog.md` does NOT exist, copy
`${CLAUDE_PLUGIN_ROOT}/templates/backlog.md` there (verbatim).
If it exists, DO NOT touch it — it is per-developer state.

## Step 6 — Stop hook (only if opted in at Step 2)

1. Copy `${CLAUDE_PLUGIN_ROOT}/templates/skdd-stop.sh` to
   `.claude/hooks/skdd-stop.sh` (create the directory). This file **is
   substituted** — apply the same token replacement as Step 4, and include it in
   the mandatory `{{SKDD_` grep verification. The reminder text it prints must
   state this project's actual bars, otherwise the highest-frequency trigger in
   the system would contradict the configured threshold.
2. Merge into `.claude/settings.json`:
   - If the file does not exist, create it with exactly:

     ```json
     {
       "hooks": {
         "Stop": [
           {
             "hooks": [
               {
                 "type": "command",
                 "command": "bash $CLAUDE_PROJECT_DIR/.claude/hooks/skdd-stop.sh",
                 "timeout": 5
               }
             ]
           }
         ]
       }
     }
     ```

   - If the file exists, Read and parse it. **If it fails to parse as JSON,
     STOP and report — never overwrite a file you could not parse.**
     Otherwise: ensure `hooks.Stop` exists as an array; scan every existing
     Stop entry's command strings for the substring `skdd-stop.sh` — if found,
     skip (already installed); if not found, APPEND the matcher-group object
     shown above to the `Stop` array. Never remove, reorder, or modify existing
     entries or any other settings keys. Write back with 2-space indentation.

## Step 7 — AGENTS.md managed section

1. Render `${CLAUDE_PLUGIN_ROOT}/templates/agents-section.md` with the same
   substitutions as Step 4.
2. If `AGENTS.md` does not exist: create it containing exactly the rendered block.
3. If it exists: append the rendered block at the end of the file, separated by
   one blank line. Never modify existing content.

## Step 8 — CLAUDE.md import

Claude Code does not natively read AGENTS.md; the official workaround is a
CLAUDE.md that imports it.

- If `CLAUDE.md` does not exist: create it containing the single line `@AGENTS.md`.
- If it exists: check for a line that, trimmed, equals `@AGENTS.md` or
  `@./AGENTS.md`. If none, append `@AGENTS.md` on its own line at the end.

## Step 9 — Report

Tell the user:

- Every file created or modified (full list)
- `backlog.md` is intentionally gitignored (per-developer state); everything
  else under `.claude/` plus `AGENTS.md`/`CLAUDE.md` should be committed
- If the hook was installed: it takes effect after the session restarts
  (hooks are snapshotted at startup); it can be reviewed with `/hooks`
- The chosen harvest threshold, and that `/skdd:config` changes it later
- Suggest trying a first harvest at the end of the next substantial task

## Recovery notes

- The `<!-- skdd:begin -->` marker is the source of truth for "already set up".
  If the marker is absent but `.claude/skills/skdd-harvest/` exists (a partial
  or broken install), proceed as a normal setup — Step 5's existence check
  protects the backlog, and everything else is safely re-copied.
