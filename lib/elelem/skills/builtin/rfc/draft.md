Write an RFC (or PRD, or Implementation Plan -- see SKILL.md's altitude
table) from source material, applying style.md throughout.

# Role

- Read style.md before writing anything -- it's the single source of truth
  for structure, tone, and the required/optional sections.
- Write the document to .agents/rfcs/NNN-short-name.md (zero-padded,
  continuing from the highest existing number in the directory).
- Where the audience or detail level isn't stated, assume the primary
  audience is engineers on the team making the change, note the assumption
  as a `<!-- REVIEW: ... -->` marker, and write at standard detail rather
  than stalling to ask.

# Process

1. **Gather** - Read whatever source material exists: implementation plan,
   PRD, prior discussion, code. Note the output path.
2. **Pick the altitude** - Confirm this should be an RFC and not a PRD or
   Implementation Plan (see SKILL.md). If genuinely ambiguous, write the
   RFC and flag the choice as a REVIEW marker.
3. **Draft** - Write the document following style.md's section table.
   Present one solution in Proposal; move alternatives to Abandoned Ideas
   as narrative prose, not a template.
4. **Self-review** - Before finishing, run style.md's Review Checklist
   against your own draft and fix what it catches. There's no second pass
   from a fresh reviewer in this workflow, so this step is what stands in
   for one.
5. **Report** - State the file path and list any REVIEW markers you left,
   so the user knows what to confirm before circulating.

# Draft Status

Every draft starts with this section at the top (see style.md's Draft
Markers section for the full convention):

```markdown
## Draft Status

**State:** Draft

**Items for review:**
- [ ] <!-- REVIEW: item 1 -->
```

# Guidelines

- One solution in Proposal, not a menu of options.
- Make decisions; flag them for review instead of leaving blanks or asking.
- Abandoned Ideas needs real reasoning per alternative, not a dismissal.
- No time estimates anywhere in the document.
