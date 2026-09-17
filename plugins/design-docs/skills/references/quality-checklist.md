# Quality checklist

Run this before telling the user the document is finished. Check each item
against the actual text, not against your memory of writing it. Where an item
fails, fix it and say what you changed and why — the reasoning is what makes the
check useful to the user rather than just to the document.

## Purpose and scope

- [ ] **Objective is one sentence and free of jargon.** A stakeholder outside the
      team should understand it without reading further.
- [ ] **The first page stands alone.** A reader who received the link with no
      verbal introduction can tell what this is and why it exists.
- [ ] **Goals describe outcomes, not implementations.** "Adopt technology X" is a
      failed goal; "reduce deploy-related outages" is a goal. If a goal names a
      technology, it is probably a How that escaped into the Why.
- [ ] **Non-goals is not empty**, and each entry is something a reader might
      plausibly have assumed was in scope.
- [ ] **Background answers why now.** What problem, what prompted it, what was
      tried before.

## Decisions

- [ ] **Every expensive-to-reverse decision is present** — language, persistence,
      public interfaces, trust boundaries, data ownership. Anything that would
      require a rewrite to undo.
- [ ] **No cheap decisions are present.** If a decision could be reversed in an
      afternoon, it does not belong here and will only attract review noise.
- [ ] **Alternatives considered covers the options a reader would ask about**,
      each with a line on why it lost. A few lines each is enough; an exhaustive
      catalogue of everything rejected is waste.
- [ ] **Constraints that shaped the design are stated**, so a reader does not
      re-litigate a choice that was never free.

## Measurability

- [ ] **SLOs, if present, are numbers.** "Fast", "reliable", and "performant" are
      not objectives; they are disagreements waiting to surface at code complete.
- [ ] **Each SLO has a way to be observed.** An objective nobody measures is a
      wish.

## Honesty

- [ ] **Open issues carries every unresolved question**, each with the options
      seen and a concrete next step — not just a statement that it is unresolved.
- [ ] **If nothing is unresolved, that is written explicitly.** An absent section
      reads as an oversight; an explicit "none" reads as a claim.
- [ ] **Resolved issues retains the original discussion**, not only the verdict.
      The reasoning is what future readers need when circumstances change.
- [ ] **Excluded sections are listed with reasons** at the end of the document.

## Readability

- [ ] **Diagrams exist wherever the structure is not obvious from prose** — data
      flow, component relationships, protocol exchanges. Diagrams are in Mermaid,
      inline, so they can be edited later rather than frozen as an image.
- [ ] **Unfamiliar terms are defined inline where they first appear**, with a
      glossary only for terms that recur. Sending the reader to an appendix is a
      worse outcome than a short parenthetical.
- [ ] **No section is a heading with filler under it.** An empty section is worse
      than an absent one: it claims coverage it does not have. Either fill it or
      move it to the excluded list with a reason.

## Boundaries

- [ ] **No implementation task breakdown.** Staged plans describe what becomes
      verifiable at each stage, not the tasks required to get there.
- [ ] **No code beyond interface signatures and small illustrative snippets.**
      If a section reads like the implementation, the design phase has been
      skipped rather than completed.
