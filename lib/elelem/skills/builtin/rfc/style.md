# RFC Style Guide

Reference for writing and reviewing documents in this skill. Read before
drafting or revising -- draft.md and feedback.md both point here instead
of repeating these rules.

# Constraints

- Target 500-1000 lines. If it's growing past that, trim -- it's drifting
  into implementation-plan territory.
- Prefer pseudocode over full implementations. Code should illustrate, not
  be copy-pasteable.
- Present ONE solution in Proposal. Move alternatives to Abandoned Ideas.
- Never include time estimates. Describe phases and dependencies only.
- Write Abandoned Ideas as narrative prose, not a template.
- No "Open Questions" section. Every question gets answered with a
  decision, then flagged `<!-- REVIEW: ... -->` -- see Draft Markers below.

# Patterns to Avoid

These read as AI-generated and undermine the document:

| Don't write | Write instead |
|---|---|
| It's worth noting that... | [state the fact directly] |
| Let's dive into... | The X works as follows. |
| This helps facilitate... | This enables... |
| On one hand X, but on the other hand Y | X. However, Y. |
| It could potentially cause... | This risks causing... |
| In this section, we will explore... | [start the section] |
| Em dashes for asides | Commas, periods, or parentheses |
| "The X Trap" / "The X Problem" | A descriptive header |
| Dramatic rhetorical questions | A direct statement |
| "You need to..." | "We need to..." |

# Writing Style

- Plain vocabulary: "use" not "utilize", "help" not "facilitate".
- Direct and confident. Explain the why behind a decision, not just the what.
- "We", not "you" -- the document is the team thinking together.
- Vary sentence length and connect ideas with reasoning words (because, so,
  which means, since). Three or more short declarative sentences in a row
  reads as a bulleted list pretending to be prose -- rewrite it as one.
- One idea per paragraph, 3-5 sentences, first sentence states the point.
- No numbered headers, no manual table of contents, no horizontal rules
  (`---`) between sections -- headers already separate them.

**Choppy (avoid):** Redis pub/sub is fire-and-forget. If no subscriber is
listening, the message is lost. The buffer is authoritative. Pub/sub is an
optimization.

**Connected (better):** Redis pub/sub is fire-and-forget, meaning if no
subscriber is listening when a message is published, it's gone. Because of
this, we treat the buffer as the authoritative source. Pub/sub pushes
chunks for low-latency delivery, but the buffer is what makes the system
reliable.

# Structure Rules

- Code blocks only for actual code, config, commands, or data contracts --
  never for prose or emphasis.
- Tables for dense reference data (fields, status codes, options). Prose
  with subheaders for anything needing explanation (risks, tradeoffs).
- Define a component before referencing it.
- Show real request/response JSON for API contracts, not just prose
  describing them.

# Diagrams

Every diagram reference needs a real diagram, not a placeholder sentence.

While drafting, use ASCII wrapped in a table with the caption as a second
row of the same table:

```markdown
| |
|:---:|
| `Client -> Redis Buffer -> Delivery Pod -> Widget` |
| *Caption: High-level data flow* |
```

During finalize, convert ASCII to mermaid (`flowchart`, `sequenceDiagram`,
or `stateDiagram-v2`) placed directly in the document -- mermaid renders
its own boundary, so drop the table container but keep the caption.

# Draft Markers

Use `<!-- REVIEW: ... -->` to flag a decision that was made but might need
a second look, rather than leaving a blank or a live question:

```markdown
We chose Redis for the buffer because it supports pub/sub natively.
<!-- REVIEW: Assumed a 3-node cluster. Confirm capacity with platform. -->
```

Every marker appears in two places: inline where the decision was made,
and again in a `## Draft Status` section at the top of the document:

```markdown
## Draft Status

**State:** Draft

**Items for review:**
- [ ] <!-- REVIEW: Assumed a 3-node cluster. Confirm capacity with platform. -->
```

Make the decision, then flag it. Most items should be resolved this way,
not left as open options. For a genuinely unresolved fork where either
choice is defensible, present both under a single marker and say so
explicitly, rather than picking arbitrarily.

# Sections

| Section | Length | Notes |
|---|---|---|
| Abstract | 2-3 sentences | A reader with no context understands the problem and approach in 10 seconds. |
| Background | as needed | All context needed to follow the rest. Done when a newcomer stops asking clarifying questions. |
| Glossary | 1 line/term | Optional. Only if domain jargon exists; place near the top, not at the end. |
| Problem Statement | as needed | Optional. Skip if Background already makes the problem obvious. |
| Proposal | 40-60% of document | The one solution, not a menu. Sub-sections: architecture, component responsibilities, key flows (happy path and error/recovery), data model, integration points. Shorter than Background + Problem Statement combined is a sign it's too thin. |
| Bill of Work | 50-100 words/component | Optional. Only if multiple teams/components are involved. |
| Rollout | 200-400 words | Optional. Deployment strategy and rollback plan. Phases and dependencies only, never dates or sprint counts. |
| Risks | 50-100 words/risk | Optional but recommended. Prose with a subheader per risk, not a table. |
| Future Steps | 100-300 words | Optional. What this enables later, so reviewers see it's not overbuilt. |
| Abandoned Ideas | 150-300 words/alternative | Required. Narrative prose per alternative: why it looked viable, what killed it. Not a "what/why attractive/why rejected" template. |

# Review Checklist

- [ ] Proposal is meatier than Background + Problem Statement combined
- [ ] Abandoned Ideas has real reasoning, not a one-line dismissal
- [ ] No three-plus-short-sentences-in-a-row choppiness
- [ ] No patterns from the avoid-list above
- [ ] "We", not "you", throughout
- [ ] Every diagram is a real diagram (ASCII while drafting, mermaid after finalize)
- [ ] Every REVIEW marker appears both inline and in Draft Status
- [ ] API contracts show real JSON, not prose paraphrase
- [ ] No Open Questions section
