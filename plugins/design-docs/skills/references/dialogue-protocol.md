# Dialogue protocol

How to run the conversation that produces a design document.

## Shape of a session

```
0. Orient      — understand the situation; investigate what can be investigated
1. Section plan — propose sections with reasons; one confirmation gate
2. Why phase   — Objective, Background, Goals, Non-goals, Scenarios, Constraints
   → write the document for the first time
3. How phase   — Interfaces, Dependencies, Security, SLOs, and the rest
   → append each section as it settles
4. Self-check  — run the quality checklist before declaring the document done
```

The phase boundary between Why and How is load-bearing. Asking about interfaces
or storage before the goals are settled produces answers that move as soon as the
goals move, and the rework is silent — the user rarely notices that an earlier
answer has been invalidated.

## Ask in rounds

Within a phase, ask every question whose prerequisites are already settled, in
one round. Then wait. A question whose answer depends on another question still
open belongs to the next round, not this one.

Format each round like this:

```
❓ **Q1** — **<short title>**: <the question, with concrete alternatives where they exist>

➡️ <your recommended answer, with the reason>

---

❓ **Q2** — **<short title>**: ...
```

**Every question carries a recommended answer.** This is not optional. Reacting
to a concrete proposal is far faster and more accurate than generating an answer
from nothing, and the recommendation forces you to have actually thought about
the decision rather than delegating it back to the user. Where you are genuinely
uncertain, recommend anyway and say what would change your mind.

Keep rounds to roughly three to six questions. Beyond that the user starts
answering the early ones carefully and the late ones carelessly.

## Find facts yourself

Anything discoverable from the environment is your job, not the user's. Read the
repository, the existing documents, the dependency manifests, the sibling
service. Ask the user only for decisions and for context that exists nowhere but
in their head.

If subagents are available, use them to investigate in parallel while you ask the
rest of the round — a running investigation blocks only the questions downstream
of it. If they are not available, investigate inline; the skill must work either
way.

## When requirements are not yet settled

In greenfield work the user often arrives without firm requirements. Do not send
them away to "come back with requirements". The Background and Goals sections are
where requirements are actually forged, so forge them here — but scope the
digging to what the design needs. You are not producing a requirements document;
you are extracting enough of the problem to make sound design decisions.

Where something genuinely cannot be settled now, place it in Open issues with a
concrete next step, and design around the uncertainty rather than pretending it
away.

## When to write to disk

Write the document for the first time when the Why phase is complete, then append
each section as it settles.

Do not create files during the orientation and section-planning stage. Early
exploration is volatile and should stay in the conversation. But once the Why
phase has closed, the agreed content is worth more on disk than in a context
window that may be compacted or lost — and the growing document is the one
artifact this session exists to produce, so its presence on disk is signal, not
noise.

Never create side files: no scratch notes, no summaries, no plan files. One
document per session.

## Language

Write the document in the language the user is conversing in. Conduct the
dialogue in that language too. These instructions are in English; the output is
not.

## What not to do

- Do not start writing code. This session produces a design, and the
  implementation happens later in a separate session with a fresh plan.
- Do not decompose the work into implementation tasks. That belongs to planning,
  which runs after and downstream of this document.
- Do not settle cheap, easily reversed decisions just because they came up.
  Note them as out of scope and move on.
- Do not accept a goal stated as an implementation ("adopt Kubernetes",
  "introduce a queue"). Ask what outcome that is supposed to produce, and record
  the outcome as the goal instead.
