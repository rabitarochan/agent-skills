# design-docs

Skills for working a design out in dialogue **before** writing it down.

| Skill | Use for | Output |
|---|---|---|
| `design-new-project` | designing a whole new project | `docs/design/README.md` |
| `design-feature` | designing a feature added to an existing system | `docs/design/features/<slug>/README.md` |
| `design-adr` | recording a single technical decision | `docs/adr/NNNN-<slug>.md` |

## Install

This plugin ships from the `rabitarochan-skills` marketplace in this repository — see
the [root README](../../README.md) for the install commands.

To use the skills without the plugin system, copy the three skill directories
and `skills/references/` into `~/.claude/skills/`. Keep `references/` as a
sibling of the skill directories so the `../references/` links resolve.

## Layout

```
design-docs/
├── .claude-plugin/plugin.json
├── commands/                   # thin Claude Code wrappers
│   ├── design-new-project.md
│   ├── design-feature.md
│   └── design-adr.md
└── skills/
    ├── design-new-project/SKILL.md
    ├── design-feature/SKILL.md
    ├── design-adr/SKILL.md
    └── references/             # shared by all three skills
        ├── choosing-sections.md   # which sections to keep, judged by the cost of getting it wrong
        ├── dialogue-protocol.md   # the Why → How phase progression and how to ask
        ├── doc-template.md        # what each section is, how to write it, examples
        └── quality-checklist.md   # self-check before writing the document out
```

## Design principles

- **Portable.** Each `SKILL.md` is plain Markdown and depends on no Claude Code
  specific feature (subagents, hooks, Plan Mode). Parallel investigation by
  subagents is written as "use it if available". Copying the `skills/`
  directory is enough to run these on another agent.
- **No dependencies.** Nothing outside this plugin is referenced; the shared
  references resolve inside the bundled directory.
- **Skill text in English, output in the user's language.**
- **Pick sections like a designer would.** No fixed template to fill in: the
  skill proposes the sections it needs and the ones it is leaving out, with
  reasons, once at the start, and gets agreement.
- **No implementation plan.** A design document is the input to Plan Mode;
  breaking the work into tasks is a separate session's job.

## Source

The sectioning principles are a reconstruction, in our own words, of Michael
Lynch, "How to Write an Effective Software Design Document"
(<https://refactoringenglish.com/excerpts/write-an-effective-design-doc/>).
