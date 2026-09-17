---
name: design-adr
description: >
  Work through a single architectural decision in dialogue and record it as an
  Architecture Decision Record (ADR) in Nygard format, capturing the context, the
  decision, and the consequences that come with it. Use this when the user is
  weighing one specific technical decision, or wants to record one they have
  already made. Trigger on phrases like "ADR", "architecture decision record",
  "record this decision", "should we use X or Y", "どちらを採用すべきか",
  "技術選定", "この決定を記録したい", "アーキテクチャ決定記録", "AとBで迷っている".
  Use this even when the user has not said the word "ADR" — if they are weighing
  one decision whose reasoning will matter later, this skill applies. For
  designing a whole project or a whole feature, use design-new-project or
  design-feature instead.
---

# Record an architectural decision

An ADR captures one decision: the situation that forced it, what was chosen, and
what the team now has to live with as a result. It is smaller than a design
document and it accumulates — a project has one design document and many ADRs,
forming a chronological log of how the architecture came to be what it is.

## Before you start

Read `../references/dialogue-protocol.md` for how to run the conversation. The
round format and the rule that every question carries a recommended answer apply
here too.

`../references/doc-template.md` and `../references/choosing-sections.md` are not
usually needed — the ADR format is fixed. Read them only if the decision turns out
to be large enough that a design document is the better vehicle.

## Is this the right skill?

An ADR fits a decision that is **singular** (one choice, not a whole architecture),
**consequential** (expensive or slow to reverse), and **not self-evident** (a
future reader would ask why).

- If the user is designing a whole system or a whole feature, use
  `design-new-project` or `design-feature`. Those documents may generate several
  ADRs along the way.
- If the decision is cheap to reverse, say so and skip the ADR. A record that
  costs more to write than the decision costs to undo is waste, and writing it
  teaches the team that ADRs are ceremony.

## Two ways this starts

**"We decided X, record it."** Reconstruct the reasoning — a decision without its
reasoning is nearly useless later. Ask what alternatives were live, what made the
choice, and what is being given up. If the user cannot recall, that itself is
worth knowing and worth a round of questions.

**"We're torn between X and Y."** This is the more common case. Work the decision
first, then record it. Investigate what can be investigated — how the codebase
already does it, what the existing ADRs settled, what the dependencies actually
support — then put the choice to the user with your recommendation and reasoning.
The decision is theirs; the investigation is yours.

## Investigate first

Before asking anything, read the existing ADR log and any design document. A
decision that contradicts an earlier ADR is important to notice early: either
this one supersedes it, or the reasoning has to account for the divergence.

Note the next available sequence number while you are there.

## Format

Nygard format, four parts, in the user's language:

```
# NNNN. <decision, stated as a short noun phrase>

## Status
<Proposed | Accepted | Deprecated | Superseded by NNNN>
<date>

## Context
<The situation that forces a decision. The constraints, the pressures, what is
true right now. Written neutrally — someone who disagrees with the decision
should still recognise this description as fair.>

## Decision
<What was chosen, in active voice: "We will ...". One paragraph, usually.>

## Consequences
<What becomes true as a result — the good, the bad, and the newly constrained.>
```

### Consequences is the part that matters

Most of an ADR's long-term value sits here. Context explains the past and
Decision states a fact, but Consequences is what the next person needs: what this
choice costs, what it forecloses, what now has to be maintained, what becomes
harder.

**Never leave it with only the benefits.** Every consequential decision costs
something. If you cannot name what this one costs, the decision has not been
examined yet — keep asking until you can.

> **Consequences**
> - Schema changes now require a migration step in the deploy pipeline;
>   deploys are no longer purely additive.
> - The team gains compile-time checking of queries, removing a class of runtime
>   failure seen three times this year.
> - Developers new to the project must learn the query DSL before they can make
>   meaningful changes — roughly a day of ramp-up.
> - Moving to a different database later becomes substantially harder, since the
>   DSL is not portable.

Record alternatives inside Context or Consequences, each with a line on why it
lost. A separate section for them is unnecessary at this size.

## Superseding

When a new ADR reverses an earlier one, set the old ADR's status to
`Superseded by NNNN` and reference the old one from the new. Never edit or delete
the original reasoning — the log is a history, and a history that gets rewritten
cannot be trusted.

## Output

- **Path**: `docs/adr/NNNN-<slug>.md`, zero-padded to four digits, sequential
  from the highest existing number. If the directory does not exist, start at
  `0001`.
- **Slug**: short, descriptive, from the decision. If the user supplies an
  identifier such as `issue-123` or `PJNAME-456`, include it — e.g.
  `0007-issue-123-adopt-typed-query-dsl.md`.
- **Language**: the user's conversation language
- **Status**: `Accepted` when the user has decided; `Proposed` when it still
  needs someone else's agreement. Ask if it is unclear.
- Create nothing else.

## Boundaries

One ADR records one decision. If the conversation reveals several entangled
decisions, say so and propose splitting them — an ADR covering four decisions
cannot be superseded cleanly when only one of them changes.

Do not write implementation code.
