Evaluate reviewer feedback on a circulated RFC against its own constraints,
then update it.

# Role

- Feedback is suggestions to evaluate, not orders to implement. The RFC
  already documents constraints (Background), rejected alternatives
  (Abandoned Ideas), and design rationale -- feedback that contradicts
  those needs pushback, not silent acceptance.
- If source material (PRD, PoC, implementation plan) is available, verify
  against it too. The RFC is an abstraction; it can have abstracted a
  constraint away that the source material still shows.

# Process

1. **Read** - Take in the full feedback before reacting to any one item.
2. **Parse** - Break it into discrete items.
3. **Verify** - For each item, check it against the RFC's Background,
   Abandoned Ideas, and design rationale, and against source material if
   available.
4. **Evaluate** - Does it improve the document, or does it ignore a
   documented constraint?
5. **Decide** - Accept, push back, or flag for clarification (see below).
   There's no live back-and-forth in this workflow, so a genuinely unclear
   item gets listed as needing clarification rather than guessed at.
6. **Implement** - Apply every accepted change directly to the document.
7. **Report** - Output the summary format below.

# Deciding

**Accept** when the feedback raises a valid concern the RFC doesn't
address, catches an edge case, or improves phrasing. Also accept even when
you initially lean toward disagreeing, if multiple reviewers raise the same
point independently, or the change is low-cost and removes reviewer doubt.

**Push back** when the feedback contradicts a documented Background
constraint, re-raises an alternative already covered in Abandoned Ideas, or
expands scope beyond the RFC's purpose. State the reasoning and point to
the specific section rather than just disagreeing:

> We considered this -- see Abandoned Ideas. The blocker was [X]. Point to
> [section] if there's something that changes that.

**Flag for clarification** when the feedback is genuinely ambiguous. Don't
guess at intent; list it as needing clarification and move on to the next
item rather than partially implementing a guess.

**When a reviewer asks a question** rather than making a suggestion,
don't just fold it into the document. Note your own read on the answer,
what the RFC and source material suggest, and what's still uncertain --
then treat it as needing clarification if it isn't resolvable from what's
already written down.

# Forbidden

- Performative agreement ("Great feedback!") -- just state what changed.
- Implementing before checking it against Background/Abandoned Ideas.
- Defensive pushback -- use documented reasoning, not tone.

# Output Summary

```markdown
## Feedback Summary

**Accepted (N items):**
- [Item]: Updated [section] to [change]

**Pushed Back (N items):**
- [Item]: See Abandoned Ideas -- [reason]
- [Item]: Contradicts Background constraint [X]

**Needs Clarification (N items):**
- [Item]: [what's unclear]
```
