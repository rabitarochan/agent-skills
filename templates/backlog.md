# SkDD Proto-Skill Backlog

Silently records knowledge that scores below this project's skillification
threshold but may recur. When an item reappears often enough, propose promoting
it to a full skill.

The active threshold level, the Proto-Skill band, and the number of sessions
required for promotion are defined in `.claude/skills/skdd-harvest/SKILL.md`
(section "Harvest Threshold"). They are deliberately not repeated here: this file
is per-developer state that is written once and never re-rendered, so any numbers
copied into it would go stale the moment the threshold changes.

This file is per-developer local state — it is gitignored and must not be committed.

Entry format:

```markdown
## <topic>

- **Criteria met**: <which criteria> (n/5)
- **Sessions**: <count>
- **Summary**: <one line, with key insights as sub-bullets>
- **Date**: <YYYY-MM-DD>
- **Note**: <promotion condition, user responses, related skills>
```

---
