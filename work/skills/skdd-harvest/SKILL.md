---
name: skdd-harvest
description: >
  Structures and generates reusable Skills (SKILL.md) from knowledge discovered
  during conversations. The core skill of SkDD (Skill Driven Development).
  Use when: the user says "skillify", "harvest", "/harvest", "turn this into a skill",
  or "make a skill from this"; when Claude detects a skill candidate at task completion
  and the user approves; when updating an existing skill with new insights;
  when promoting a Proto-Skill to a full skill. Also consult for topics related to
  SkDD, knowledge management, or tacit-to-explicit knowledge conversion.
---

# SkDD Harvest — Knowledge Harvesting from Daily Work

## Purpose

Quickly harvest knowledge born from daily LLM collaboration into reusable Skills.
If `skill-creator` is a "workshop for designing and evaluating polished skills",
`skdd-harvest` is "picking ripe knowledge from today's fieldwork".

## Invocation

### Explicit triggers

- User says "skillify this", "harvest", "/harvest", "turn this into a skill"
- User points at a specific procedure and says "I want to keep this"

### Autonomous triggers (governed by CLAUDE.md SkDD Directive)

- Claude detects a skill candidate at a natural task completion point
  AND the candidacy criteria threshold (3/5+) is met
- A Proto-Skill has appeared in 2+ separate sessions and qualifies for promotion

### When NOT to propose

- The candidacy threshold is not met (fewer than 3/5 criteria)
- The session consisted only of simple Q&A with no procedural knowledge
- The knowledge is already covered by an existing skill

## Workflow

### Step 1: Knowledge Extraction

Analyze the current conversation and identify knowledge worth skillifying.

**Extraction priority (highest first):**

1. Points the user corrected or flagged — the richest source of tacit knowledge
2. Final procedures reached after trial and error
3. Domain knowledge the user explicitly taught
4. Constraints, prerequisites, and pitfalls discovered during work

**Types of knowledge to extract:**

- Procedures (what to do and in what order)
- Decision rules (when to branch and how)
- Prohibitions (what breaks things, anti-patterns to avoid)
- Tool-specific know-how (practical wisdom not in the docs)
- Domain terminology (team-internal meanings and definitions)

### Step 2: Skill Design (agreement with user)

Present the following concisely and get approval:

```
📦 Skill Proposal
─────────────────────
Name:    <snake-case-name>
Summary: <one-line description>
Scope:   <2-3 bullet points>
Trigger: <"when you want to...", "when asked to...">
Criteria met: <which of the 5 criteria apply>
─────────────────────
Shall I generate this?
```

**Naming convention:**

- Prefer `<domain>-<action>` format (e.g., `oracle-datapump-copy`, `ddd-repository-test`)
- Verify no name collision with existing skills

**If context is already clear** (e.g., user said "skillify this" mid-conversation),
minimize confirmation and move quickly to generation.

### Step 3: Generate SKILL.md

#### Directory structure

```
skill-name/
├── SKILL.md              (required)
└── references/            (only if supplementary content exceeds 300 lines)
    └── <topic>.md
```

#### SKILL.md structure template

```markdown
---
name: <skill-name>
description: >
  <What this skill does and when to use it.
   Be specific about triggers. Include related keywords for triggering accuracy.
   Write slightly pushy to ensure the skill fires when relevant.>
---

# <Skill Title>

## Overview

<The problem this skill solves. 2-3 lines.>

## Prerequisites

<Required tools, environment, or knowledge. Omit if none.>

## Procedure

<Step-by-step instructions. Write in imperative form.>
<Attach "why" to each step: "because...", "otherwise X will happen".>

## Decision Rules

<Branching logic and conditions. Omit if none.>

## Pitfalls & Warnings

<Things that break, anti-patterns, gotchas.>
<Concentrate insights from user corrections here.>

## Examples

<Input/Output examples if available.>
```

#### Writing principles

- **Imperative form**: "Run...", "Verify...", "Do not..."
- **Attach why**: "because...", "otherwise X happens", "this prevents..."
- **Under 500 lines**. If longer, split into `references/` and add pointers from SKILL.md
- **Define domain terms** on first use with a brief parenthetical
- **Description is comprehensive**: include multiple phrasings a user might say to maximize trigger accuracy

### Step 4: Output

#### Claude.ai

1. Write the skill directory to `/mnt/user-data/outputs/`
2. Present via `present_files`
3. Guide installation: "Add this skill to your Claude.ai project,
   or install it for use in future sessions."

#### Claude Code

1. Write to `.skills/` at project root (create the directory if needed)
2. Append to `<available_skills>` in CLAUDE.md
3. Suggest `git add`

## Proto-Skill (Seed Planting)

Record knowledge that does not yet meet the skillification threshold
but may recur.

### Recording condition

- 1-2 of the 5 candidacy criteria are met, but fewer than 3
- The knowledge feels like "might be a one-off, but worth tracking"

### Recording format

#### Claude.ai — store in Memory

Use the `memory_user_edits` tool to add:

```
[Proto-Skill] <topic>: <one-line summary>
```

#### Claude Code — append to .claude/skills/skdd-harvest/backlog.md

```markdown
## <topic>

- Summary: <one line>
- First seen: <date>
- Notes: <bullet points of key insights>
```

### Promotion condition

When a Proto-Skill appears in **2 or more separate sessions**, propose skillification:
"The knowledge about <topic> that I noted earlier came up again in this session.
It might be time to turn it into a proper skill. Shall I?"

## Updating Existing Skills

When new insights fall within an existing skill's scope:

1. **Propose an update**, not a new skill
2. **Show the diff explicitly**: "I suggest adding X to the 'Pitfalls' section of skill Y"
3. After approval, generate the updated SKILL.md
4. **Preserve the original skill name** and directory name — do not rename
