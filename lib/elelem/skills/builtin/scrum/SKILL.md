---
name: scrum
description: Story-driven workflow for building a feature -- plan it into stories, design tasks, build test-first, review, then verify. Stories live in .agents/backlog/. Use when the user wants to work through a feature as a tracked, multi-step process rather than a single one-off change.
---

# Scrum

A five-phase workflow, one story at a time, tracked as a markdown file in
`.agents/backlog/`. Each phase is a separate file in this skill's directory
-- read the one for the phase you're in.

# Phases

| Phase | File | When |
|---|---|---|
| Plan | [plan.md](plan.md) | Nothing is broken into stories yet |
| Design | [design.md](design.md) | A story exists but has no Tasks, or its Tasks are stale |
| Build | [build.md](build.md) | A story has Tasks and needs implementing |
| Review | [review.md](review.md) | A story's Tasks are all checked off |
| Verify | [verify.md](verify.md) | A story passed review |

Read only the phase file you need for the current request -- each one is
self-contained and says what to read the story for and what to write back.

# Story Lifecycle

A story file moves through the phases in order: plan creates it, design adds
Tasks, build implements and checks them off, review approves the diff, verify
confirms it works end-to-end and closes it out. Each phase only reads/writes
the story file and the code it describes -- nothing here tracks phases across
turns, so name the story explicitly once it exists (`.agents/backlog/NNN-*.md`)
rather than relying on this skill to remember where you left off.
