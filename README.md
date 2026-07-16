# agent-skdd

**SkDD (Skill Driven Development)** — crystallize reusable work patterns into
Skills and grow them with their **Why** (rationale) attached.

日本語のドキュメントは [README-ja.md](README-ja.md) を参照してください。

This repository is a self-contained Claude Code plugin marketplace shipping one
plugin: **`skdd`**.

## Architecture

**The plugin is an engine + installer; the project holds the materialized assets.**

The plugin itself exposes only two explicitly-invoked skills (`/skdd:setup`,
`/skdd:update`). The harvest engine (`skdd-harvest`) is a template payload that
setup copies into each project. Because the deployed assets are plain project
files (`.claude/skills/`, `AGENTS.md`), any agent platform that reads AGENTS.md
— OpenAI Codex and other Agent Skills-compatible tools — can participate in
SkDD without installing anything.

Per project, the deployed `skdd-harvest` engine crystallizes project-specific
judgment and knowledge (Why + How) into skills named `<prefix><domain>-<action>`
(default prefix `pj-`). Each harvested skill is a pair:

- `SKILL.md` — the current snapshot of Why + How
- `harvest.md` — an append-only decision record (ADR) of how the skill evolved

Editing a harvested skill at decision level requires appending a harvest.md
entry in the same transaction (the *atomic update* protocol) — see
`templates/skdd-harvest/references/harvest-protocol.md`.

## Install

```
claude plugin marketplace add rabitarochan/agent-skdd
claude plugin install skdd@agent-skdd
```

For local development:

```
claude plugin marketplace add /path/to/agent-skdd
claude plugin install skdd@agent-skdd
```

## Usage

### `/skdd:setup` — install SkDD into a project

Run inside the target project. It asks for:

- a **skill prefix** (default `pj-`; must match `^[a-z][a-z0-9]*-$`)
- whether to install the **Stop hook** (recommended; reminds the agent to run
  the harvest evaluation at every response completion)

It then writes:

| Path | Role | Managed by update? |
|---|---|---|
| `.claude/skills/skdd-harvest/SKILL.md` + `references/` | harvest engine | yes (overwritten) |
| `.claude/skills/skdd-harvest/.gitignore` | ignores backlog.md | yes (overwritten) |
| `.claude/skills/skdd-harvest/backlog.md` | Proto-Skill backlog (local state) | **no — never touched** |
| `.claude/hooks/skdd-stop.sh` + `.claude/settings.json` Stop entry | harvest reminder hook (opt-in) | yes (script re-copied) |
| `AGENTS.md` managed section (between `<!-- skdd:begin/end -->`) | protocol for all agents | yes (re-rendered) |
| `CLAUDE.md` `@AGENTS.md` import line | Claude Code bridge | repaired if missing |

Commit everything except `backlog.md` (already gitignored).

### `/skdd:update` — upgrade deployed assets

After upgrading the plugin (`claude plugin update skdd`), run `/skdd:update` in
each project. It re-renders the managed artifacts at the new version and never
touches `backlog.md`, harvested `<prefix>*` skills, or anything outside the
AGENTS.md markers.

Per-project parameters persist in the config line inside the markers:

```
<!-- skdd:config prefix=pj- hooks=true version=0.1.0 -->
```

Changing the prefix: edit `prefix=` in this line and run `/skdd:update` with a
version bump (or force). Existing harvested skills are **not** renamed —
migrate them manually.

### Harvesting

The deployed engine (and the AGENTS.md section, for non-Claude agents) drives
the loop: at task completion the session is scored against 5 criteria —
recurrence, proceduralness, non-obviousness, correction-derived, generality.

- 3/5+ → propose a skill (or an update to an existing one)
- 1–2/5 → silently record a Proto-Skill in `backlog.md`
- Proto-Skill seen in 2+ sessions → propose promotion

## Versioning

`plugin.json` `version` (semver) is the single source of truth and the update
cache key. **Any change under `templates/` or `skills/` requires a bump**
(patch = wording/fix, minor = protocol/behavior change). Deployed artifacts are
stamped in three places: the AGENTS.md config line, the deployed SKILL.md
comment, and the `skdd-stop.sh` header comment.

## Dependencies

- The Stop hook needs `bash` on PATH in the hook environment (Git Bash on
  Windows). It has no other dependencies (`jq` is deliberately not used).

## Known v1 limitations

- Local edits to the deployed `skdd-harvest` files are overwritten by
  `/skdd:update` — engine improvements belong in this repository.
- Changing the prefix does not rename existing skills.

## Repository layout

- `.claude-plugin/` — plugin + marketplace manifests
- `skills/` — the two installer skills (`setup`, `update`)
- `templates/` — payload deployed into projects (engine skill, backlog seed,
  hook script, AGENTS.md section)
- `SkDD-plugin-handoff.md` — design document (in Japanese); §2 is the design
  constitution (Why-bearing How, SKILL.md/harvest.md pair, atomic updates)
- `work/` — legacy pre-plugin assets kept for reference (not scanned by the
  plugin loader)
