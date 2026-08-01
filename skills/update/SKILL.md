---
name: update
description: >
  Update SkDD assets already deployed in the current project (skdd-harvest
  engine skill, Stop hook, managed AGENTS.md section) to the installed plugin
  version. Never touches the backlog or harvested skills. Explicit invocation
  only (/skdd:update).
disable-model-invocation: true
---

# /skdd:update — Update deployed SkDD assets

You are updating the SkDD assets that `/skdd:setup` previously deployed into
the project in the current working directory. Per-project state is preserved;
only managed artifacts are rewritten.

Plugin file references below use `${CLAUDE_PLUGIN_ROOT}` — resolve it to the
skdd plugin's installation directory.

## Hard prohibitions (read first)

NEVER, under any circumstances:

- touch `.claude/skills/skdd-harvest/backlog.md`
- touch any skill directory other than `.claude/skills/skdd-harvest/`
  (in particular, never touch harvested `<prefix>*` skills or their harvest.md)
- write outside the `<!-- skdd:begin -->` / `<!-- skdd:end -->` markers in AGENTS.md
- delete user files
- modify `.claude/settings.json` beyond appending/repairing the single skdd Stop
  hook entry

## Step 1 — Locate deployed state

1. Read `AGENTS.md`. If it does not exist or contains no `<!-- skdd:begin -->`
   line, SkDD is not set up here — tell the user to run `/skdd:setup` and STOP.
2. Parse the config line (first line inside the markers):
   `<!-- skdd:config prefix=<prefix> hooks=<true|false> threshold=<level> version=<semver> -->`
   — space-separated `key=value` pairs, keys: `prefix`, `hooks`, `threshold`,
   `version`.
3. **If `threshold=` is absent** (a project set up before the key existed),
   treat it as `medium` and write it into the config line during the Step 5
   re-render. `medium` reproduces the pre-threshold behaviour exactly, so an
   existing project's harvesting does not change under it.
4. If the config line is missing or unparseable, ask the user for the prefix,
   whether the hook is installed, and the threshold level, then continue
   (self-healing re-render).

## Step 2 — Version gate

Read `version` from `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`.
If it equals the deployed version from Step 1, report "already at v<X.Y.Z>"
and STOP — unless the user explicitly asked to force a re-render.

## Step 3 — Re-deploy the engine skill

First derive the threshold values, exactly as setup Step 3 does: read the
`## Harvest Threshold` section of
`${CLAUDE_PLUGIN_ROOT}/templates/skdd-harvest/SKILL.md` — the single source of
truth for the level → values mapping — and from the block matching the Step 1
`threshold` level take `SKDD_SCORE_MIN` (bare integer), `SKDD_PROTO_BAND`
(exactly as written, ASCII hyphen included, e.g. `2-3`), and
`SKDD_PROMOTE_SESSIONS` (bare integer).

Then, same procedure as setup Step 4: copy `SKILL.md` (substituting
`{{SKDD_PREFIX}}`, `{{SKDD_HOOKS}}`, `{{SKDD_THRESHOLD}}`, `{{SKDD_SCORE_MIN}}`,
`{{SKDD_PROTO_BAND}}`, `{{SKDD_PROMOTE_SESSIONS}}` with the Step 1 parameters,
and `{{SKDD_VERSION}}` with the NEW plugin version) plus
`references/harvest-protocol.md`, `references/adr-entry-schema.md` and
`.gitignore` (all verbatim) from
`${CLAUDE_PLUGIN_ROOT}/templates/skdd-harvest/` into
`.claude/skills/skdd-harvest/`, overwriting the existing files.

**Verification (mandatory):** grep the written files for `{{SKDD_` — any hit is
an error.

Note: local edits to the deployed engine files are overwritten by design;
engine improvements belong in the plugin repository.

## Step 4 — Stop hook

- If `hooks=true`: re-copy `${CLAUDE_PLUGIN_ROOT}/templates/skdd-stop.sh` to
  `.claude/hooks/skdd-stop.sh` (overwrite), **applying the same token
  substitution as Step 3** — the script is a template, not a verbatim copy, and
  it must be included in the `{{SKDD_` grep verification. Then verify `.claude/settings.json`
  still contains a Stop entry whose command references `skdd-stop.sh`; if it is
  missing, re-add it using the same merge procedure as setup Step 6 (parse
  first; stop on unparseable JSON; append only).
- If `hooks=false`: do nothing. Never install a hook that was not requested,
  and never uninstall one.

## Step 5 — Re-render the AGENTS.md managed section

1. Render `${CLAUDE_PLUGIN_ROOT}/templates/agents-section.md` with the Step 1
   `prefix`, `hooks` and `threshold` values, the Step 3 derived threshold
   numbers, and the NEW plugin version.
2. Replace the region of `AGENTS.md` from the `<!-- skdd:begin -->` line through
   the `<!-- skdd:end -->` line, inclusive, with the rendered block.
3. Every byte outside the markers must remain untouched.

## Step 6 — CLAUDE.md import

Verify `CLAUDE.md` contains a line that, trimmed, equals `@AGENTS.md` or
`@./AGENTS.md`. If the file or line is missing, repair it as in setup Step 8.

## Step 7 — Report

Tell the user:

- "Updated v<FROM> → v<TO>" (from Step 1 / Step 2 values)
- The list of files rewritten
- If `threshold=` had been absent and was defaulted to `medium`: say so, and
  mention that `/skdd:config` changes it
- Explicit confirmation that `backlog.md` and harvested `<prefix>*` skills were
  not touched
