# skdd

**SkDD (Skill Driven Development)** — crystallize reusable work patterns into
Skills and grow them with their **Why** (rationale) attached.

Part of the [agent-skills](../../README.md) marketplace. 日本語の解説は
[README-ja.md](../../README-ja.md) を参照してください。

## Architecture

**The plugin is an engine + installer; the project holds the materialized assets.**

The plugin itself exposes only explicitly-invoked skills (`/skdd:setup`,
`/skdd:config`, `/skdd:update`). The harvest engine (`skdd-harvest`) is a template payload that
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

### Two-layer authoring: invariants vs platform conventions

The harvest doctrine separates what SkDD owns from what the platform owns.
**SkDD invariants** — the 5 candidacy criteria, the harvest threshold with its
per-level bars and length caps, the SKILL.md + harvest.md pair with atomic
updates, naming/routing, the oscillation guard — are hardcoded in the engine
and always win. **Platform authoring conventions** — frontmatter field set,
description style, body skeleton, progressive-disclosure norms — are resolved
at harvest time instead of being frozen into the plugin: a skill-authoring
skill present in the session (e.g. Anthropic's `skill-creator`) takes
precedence, then the model's own current knowledge of Skills best practices,
then the dated baseline shipped in the engine (as of 2026-08). No
documentation fetching is involved — the chain works offline. When updating an
existing skill, newer conventions apply only to the parts being touched;
wholesale restyling is treated as churn. The point: harvested skills track the
platform's current best practices as models and Claude Code evolve, without a
plugin upgrade.

## Install

```
claude plugin marketplace add rabitarochan/agent-skills
claude plugin install skdd@agent-skills
```

For local development:

```
claude plugin marketplace add /path/to/agent-skills
claude plugin install skdd@agent-skills
```

## Usage

### `/skdd:setup` — install SkDD into a project

Run inside the target project. It asks for:

- a **skill prefix** (default `pj-`; must match `^[a-z][a-z0-9]*-$`)
- whether to install the **Stop hook** (recommended; reminds the agent to run
  the harvest evaluation at every response completion)
- a **harvest threshold** (default `medium`; see below)

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

### `/skdd:config` — change per-project settings

Changes the **harvest threshold**, the **skill prefix**, or whether the **Stop
hook** is installed, then re-renders the managed artifacts so every copy of the
rules agrees. It never changes the deployed version — that is `/skdd:update`'s
job — and never touches `backlog.md` or harvested skills.

```
/skdd:config                 # interactive
/skdd:config threshold=high  # one-shot
```

### `/skdd:update` — upgrade deployed assets

After upgrading the plugin (`claude plugin update skdd`), run `/skdd:update` in
each project. It re-renders the managed artifacts at the new version and never
touches `backlog.md`, harvested `<prefix>*` skills, or anything outside the
AGENTS.md markers.

Per-project parameters persist in the config line inside the markers:

```
<!-- skdd:config prefix=pj- hooks=true threshold=medium version=0.3.0 -->
```

A project installed before `threshold` existed has no `threshold=` key;
`/skdd:update` fills it in as `medium`, which reproduces the old behaviour
exactly.

### Harvesting

The deployed engine (and the AGENTS.md section, for non-Claude agents) drives
the loop: at task completion the session is scored against 5 criteria —
recurrence, proceduralness, non-obviousness, correction-derived, generality.

How selective that loop is comes from one dial, the **harvest threshold**.
Raising it tightens three things at once: the score bar, the bias toward
updating an existing skill instead of adding one, and how hard the writing must
be distilled. The right setting is not universal — a fresh project needs eager
capture, a mature one needs the opposite, because every new skill dilutes the
set and makes the right one harder to find.

| Level | Propose | Proto-Skill | Promote after | Consolidation | Length cap |
|---|---|---|---|---|---|
| `low` | 2/5+ | 1/5 | 2 sessions | new skill unless one clearly covers it | 500 lines |
| `medium` | 3/5+ | 1-2/5 | 2 sessions | update when scopes overlap | 500 lines |
| `high` | 4/5+ | 2-3/5 | 3 sessions | read every existing description first; any overlap → update | 200 lines |
| `max` | 5/5 | 3-4/5 | 4 sessions | new skill needs an explicit gap statement | 120 lines |

`medium` is the default. Set it at `/skdd:setup`, change it with
`/skdd:config threshold=<level>`. The per-level profile is carried in the
deployed `.claude/skills/skdd-harvest/SKILL.md`, section "Harvest Threshold" —
that section is the single source of truth for these numbers.

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
  `/skdd:update` and `/skdd:config` — engine improvements belong in this repository.
- Changing the prefix does not rename existing skills.
- The threshold changes what gets harvested from now on; it does not prune or
  re-evaluate skills already harvested at a lower level.
- Newer platform authoring conventions likewise apply only forward — and, on
  updates, only to the sections being touched; existing skills are never
  restyled wholesale.

## Plugin layout

- `.claude-plugin/plugin.json` — plugin manifest (the version is the source of truth)
- `skills/` — the installer skills (`setup`, `config`, `update`)
- `templates/` — payload deployed into projects (engine skill, backlog seed,
  hook script, AGENTS.md section)
- `SkDD-plugin-handoff.md` — design document (in Japanese); §2 is the design
  constitution (Why-bearing How, SKILL.md/harvest.md pair, atomic updates)
