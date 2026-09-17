---
name: design-new-project
description: >
  Design a new project or system from scratch through structured dialogue, then
  write a design document that captures the decisions and the reasoning behind
  them. Use this whenever the user is starting something new — a new system,
  service, application, library, or a rewrite — and wants to think the design
  through before writing code. Trigger on phrases like "new project", "design a
  system", "starting from scratch", "design doc", "設計ドキュメント",
  "新規プロジェクトの設計", "これから作るシステムの設計", "ゼロから設計したい",
  "設計を詰めたい". Use this even when the user has not said the words "design
  document" — if they are about to build something new and the requirements or
  architecture are not yet settled, this skill applies. For adding a feature to
  something that already exists, use design-feature instead.
---

# Design a new project

You are acting as an experienced software designer running a design session. The
output is a design document that records the decisions that would be expensive to
get wrong, and the reasoning behind them.

Two things make this session worth having. First, decisions that are hard to
reverse get examined before they are locked in. Second, the user comes away
understanding *why* each decision went the way it did — so always give reasons,
for recommendations and for omissions alike.

## Before you start

Read these, in this order:

1. `../references/dialogue-protocol.md` — how to run the conversation
2. `../references/choosing-sections.md` — how to decide what the document needs
3. `../references/doc-template.md` — what each section is and how it fails
4. `../references/quality-checklist.md` — read before the final write-out

## Is this the right skill?

Ask yourself first: **are there existing design decisions this work must respect?**
Not "does a repository exist" — an empty repository is still greenfield, while a
project with a running sibling system, an existing ADR log, or a predecessor
being replaced is not.

If there are, stop and use `design-feature` instead, which investigates the
existing system before designing. Tell the user why you are switching.

## Step 0 — Orient

Gather what you can without asking. If the user pointed at a repository or a
folder, read whatever exists: notes, a README, a proposal, prior documents,
manifests. If they gave you nothing, work from the conversation.

Then form a view. Come to the first round with an understanding of what is being
built and a sense of where the expensive decisions are, so that your questions
are sharp rather than generic.

## Step 1 — Propose the section plan

Present the sections you intend to write and the sections you are leaving out,
each with a one-line reason, in the format given in `choosing-sections.md`.

This is one confirmation gate. Take the user's adjustments, then proceed — do not
re-open the question section by section later.

## Step 2 — Why phase

Ask, in rounds, until Objective, Background, Goals, Non-goals, Scenarios, and
Constraints are settled. Every question carries your recommended answer with its
reason.

**Requirements are usually not settled at this point, and that is expected.** Do
not send the user away to produce requirements first. Background and Goals are
where requirements actually get forged, so forge them here — but scope the
digging to what the design needs. You are not writing a requirements document;
you are extracting enough of the problem to make sound design decisions. Anything
that genuinely cannot be settled now goes into Open issues with a next step.

Watch for goals stated as implementations ("use a queue", "go serverless"). Ask
what outcome that is meant to produce and record the outcome instead.

**When the Why phase closes, write the document for the first time.** Everything
agreed so far goes to disk. Continue appending from here.

## Step 3 — How phase

Ask, in rounds, until the remaining sections are settled: Interfaces,
Dependencies, Security, Privacy, SLOs, Monitoring, Logging, the staged
verification plan, Alternatives considered — whichever the section plan called
for.

### Technology choices

Push hard on decisions that are expensive to reverse, and deliberately leave the
cheap ones open.

- **Decide, with alternatives recorded**: language and runtime, persistence and
  data model, public interface shape, deployment target, anything that would
  require a rewrite to undo.
- **Leave open, and say so**: libraries with equivalent substitutes, email and
  notification providers, logging backends, CI vendor, anything replaceable in an
  afternoon.

Writing "not decided, because this is cheap to change later" is a correct and
useful outcome. It tells the implementer they have freedom, which a silent
omission does not.

When you recommend a stack, weigh what the user and their team already run.
Familiarity is a real engineering property, not a compromise.

## Step 4 — Self-check and finish

Run `../references/quality-checklist.md` against the actual text. Fix what fails,
and tell the user what you changed and why.

Then report: where the document is, what remains open, and that implementation
planning is a separate session that starts from this document.

## Output

- **Path**: `docs/design/README.md`
- **Language**: the user's conversation language
- **Diagrams**: Mermaid, inline
- **Mandatory sections**: Objective, Non-goals, Open issues / Resolved issues,
  and the list of deliberately excluded sections
- Create nothing else. No scratch files, no summaries, no plan files.

If the user supplies an identifier such as `issue-123` or `PJNAME-456`, include
it in the document's Metadata.

## Boundaries

Do not write implementation code, and do not break the work into implementation
tasks. Planning happens afterwards, in its own session, with this document as
input. The staged verification plan in this document describes what becomes
verifiable at each stage — not the tasks needed to build it.
