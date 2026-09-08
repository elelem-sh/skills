---
name: rfc
description: Write, review, finalize, and incorporate feedback on RFC/PRD/Implementation Plan documents in .agents/rfcs/. Use when the user wants to propose an architecture decision or design in writing, not just implement one.
---

# RFC

A four-phase workflow for writing technical proposals, tracked as a markdown
file in `.agents/rfcs/`. Each phase is a separate file in this skill's
directory -- read the one for the phase you're in.

# Phases

| Phase | File | When |
|---|---|---|
| Draft | [draft.md](draft.md) | No document exists yet, or it needs a first pass |
| Style | [style.md](style.md) | Reference only -- draft and feedback both read this, it has no phase of its own |
| Finalize | [finalize.md](finalize.md) | Draft content is approved, needs cleanup before circulating |
| Feedback | [feedback.md](feedback.md) | Reviewers responded and their comments need addressing |

# Document Types

Not every proposal needs an RFC. Pick the altitude that matches the question:

| Document | Answers | Audience |
|---|---|---|
| PRD | Why? Business justification, user needs | Stakeholders, product |
| RFC | What? Architecture decisions, system design | Engineers, PMs |
| Implementation Plan | How? Execution steps, code-level decisions | Engineers doing the work |

An RFC documents a decision, not the execution of one. If the request is
really "how do we build this," read the scrum skill's design.md instead.

# Document Lifecycle

Draft creates the document, applying style.md throughout. Finalize prepares
an approved draft for circulation. Feedback processes reviewer comments
after circulation and updates the document. There is no build phase here --
an RFC documents a decision, it doesn't implement one.

Every phase runs in a single turn with no way to pause for a live answer.
Where the source material leaves something ambiguous, make the call, note
it inline as `<!-- REVIEW: ... -->`, and list it in the document's Draft
Status section -- see style.md for the exact convention. Don't leave blanks
and don't stall waiting for clarification that can't arrive mid-turn.

# Attribution

The style and structure in this skill are adapted from
[lemieux/rfc-skills](https://github.com/lemieux/rfc-skills) (MIT License,
Copyright (c) 2026 Marc-Antoine Lemieux), trimmed to a single-agent,
single-turn workflow: no subagents, no live back-and-forth review loop --
decisions get made and flagged with `<!-- REVIEW: ... -->` instead.
