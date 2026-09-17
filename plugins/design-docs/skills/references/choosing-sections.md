# Choosing sections

How to decide which sections a design document needs, and how to present that
decision to the user.

> The principles below are adapted from Michael Lynch's "How to Write an
> Effective Software Design Document"
> (<https://refactoringenglish.com/excerpts/write-an-effective-design-doc/>),
> restated in our own words and extended with conventions specific to these
> skills.

## The core test: what does being wrong cost?

A design document is not a specification of everything. If it pins down every
detail, the implementation has already been written during design, and the
document has defeated its own purpose.

Decide what goes in by asking one question about each decision:

**If this turns out to be wrong, what does it cost to reverse?**

- **Expensive and slow to reverse** → it belongs in the document, with the
  reasoning and the alternatives that were rejected. Choice of language,
  persistence layer, public interface shape, trust boundaries, data model.
- **Cheap to reverse** → leave it out. Page size, button placement, log
  wording, which email provider sends the notifications. Deciding these in the
  document wastes review attention and invites bikeshedding.

Volume of debate is not a signal of importance. Cheap decisions attract the most
opinions precisely because everyone can hold one.

Apply the same test to whole sections. A section earns its place when leaving it
out would let an expensive mistake through unnoticed.

## Act as the designer, not as a form

Never hand the user a fixed list of headings to fill in. Read the situation,
choose the sections a competent designer would insist on for *this* project, and
be prepared to defend both the inclusions and the omissions.

Signals that pull sections in:

| Signal in the project | Sections it pulls in |
|---|---|
| Serves end users or other teams | Scenarios, Interfaces |
| Runs unattended in production | SLOs, Monitoring, Logging |
| Accepts input from outside a trust boundary | Security |
| Touches personal, medical, or financial data | Privacy, Legal |
| Regulated industry, or a contract constrains the design | Legal, Constraints |
| More than one component, or a non-obvious data flow | Diagrams |
| Replaces or coexists with an existing system | Background, Alternatives considered, Constraints |
| Internal vocabulary a new reader would not know | Glossary |
| Order of construction affects how early mistakes surface | Staged verification plan |

Signals that push sections out:

- A one-off internal tool with no availability expectation does not need SLOs.
- A pure library with no runtime of its own does not need Monitoring.
- A project with no user-visible surface does not need Scenarios.
- A solo project with no approval chain needs only minimal Metadata.

## Sections that are never optional

Three sections stay in every document produced by these skills, because leaving
them out is how documents rot:

1. **Objective** — one sentence. Without it the reader cannot orient.
2. **Non-goals** — an empty scope boundary is not a boundary. If nothing was
   ruled out, scope was never examined.
3. **Open issues / Resolved issues** — the most common way a design document
   decays is that the questions nobody could answer quietly disappear. If there
   are none, write that there are none, explicitly.

## Present the plan once, then proceed

Before writing any content, show the user the section plan. This is a single
confirmation gate, not a running negotiation.

Present it in this shape:

```
## 章立て案

**含める**
- Objective — <one line on why this project needs it>
- ...

**含めない**
- SLOs — <why it would add nothing here>
- ...
```

Give a reason for every line, on both sides. The reasons are the point: the
omissions carry as much design judgement as the inclusions, and a user who reads
"we are not writing SLOs because this tool runs on demand and has no
availability expectation" learns something reusable about when SLOs matter.

Accept adjustments, then move on. Do not ask again section by section — that
turns a design session into an interrogation and stalls the work.

## Record what was left out

In the finished document, close with a short section listing the sections that
were deliberately excluded and why, one line each. Suggested heading:
"Out of scope for this document" (translate to the user's language).

This serves two readers: the reviewer who wonders whether security was
considered, and the future maintainer whose circumstances have changed and who
needs to know that the omission was a judgement, not an oversight.
