<!-- skdd:begin -->
<!-- skdd:config prefix={{SKDD_PREFIX}} hooks={{SKDD_HOOKS}} version={{SKDD_VERSION}} -->
<!-- This section is managed by the skdd plugin. Do not edit inside the markers; run /skdd:update to regenerate. -->

## SkDD (Skill Driven Development)

This project uses SkDD: reusable work patterns are crystallized into Skills and
grown over time with their Why (rationale) attached. Agents working in this
repository must follow this protocol.

### Skill discovery and use

- Skills live in `.claude/skills/<skill-name>/SKILL.md`.
- If your platform does not auto-discover skills there (Claude Code does), list
  the directories under `.claude/skills/`, read each SKILL.md frontmatter
  (name / description), and load the relevant skill bodies before starting work.
- No static skill index is maintained — discover dynamically (indexes drift).
- Project skill prefix: `{{SKDD_PREFIX}}` (naming: `{{SKDD_PREFIX}}<domain>-<action>`).

### Harvest criteria

At natural task-completion points, evaluate the session against 5 criteria:
(1) recurrence (2) proceduralness (3) non-obviousness (4) correction-derived (5) generality

- **3/5 or more** → propose skillification (or an update to an existing skill)
- **1–2/5** → silently record a Proto-Skill in `.claude/skills/skdd-harvest/backlog.md`
- **0/5** → do nothing
- A Proto-Skill that reappears in **2+ separate sessions** → propose promotion
- Insights within an existing skill's scope → propose updating that skill, not a new one
- Full procedure: `.claude/skills/skdd-harvest/SKILL.md`

### Skill update protocol (atomic updates)

- Harvested skills are managed as a pair: `SKILL.md` (current Why+How snapshot)
  and `harvest.md` (append-only decision record).
- A decision-level change to SKILL.md requires appending a harvest.md entry
  (context / change / supersedes / result) in the same transaction. Changing
  only one side is invalid.
- Trivial How-level fixes may edit SKILL.md directly.
- Invariant: the tail entry of harvest.md == the rationale of the current SKILL.md.
- Details: `.claude/skills/skdd-harvest/references/harvest-protocol.md`

### Knowledge routing

- Project-specific knowledge → a `{{SKDD_PREFIX}}*` skill in this project
- Project-independent, generic knowledge → suggest a global skill (`~/.claude/skills/`)
- `backlog.md` is per-developer local state (gitignored; do not commit)

<!-- skdd:end -->
