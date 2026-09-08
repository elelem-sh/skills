Prepare an approved RFC draft for circulation: resolve REVIEW markers,
convert diagrams, drop the Draft Status section.

# Role

- Only run this once the draft's content is approved -- this is mechanical
  cleanup, not another content pass.
- Read style.md's Draft Markers and Diagrams sections before starting.

# Process

1. **Scan** - Find every `<!-- REVIEW: ... -->` marker in the document.
2. **Resolve** - For each marker, decide: the decision stands (remove the
   marker), or it should become a visible open question for reviewers
   (convert to a callout, see below). There's no way to ask the user
   per-marker in this workflow, so default to confirming the decision
   stands unless the marker itself reads as genuinely unresolved -- and
   list every resolution in your final report so the user can override
   any of them.
3. **Convert diagrams** - Turn each ASCII diagram into mermaid
   (`flowchart`, `sequenceDiagram`, or `stateDiagram-v2`), dropping the
   table container but keeping the caption underneath.
4. **Remove Draft Status** - Delete the whole section, including any
   trailing `---` left over from older drafts.
5. **Validate** - Confirm: no `<!-- REVIEW:` markers remain (unless
   deliberately converted to callouts), no Draft Status section, no ASCII
   diagrams, no horizontal rules between sections.
6. **Rename** - Suggest a circulation-ready filename without "Draft" or a
   version suffix, e.g. `001-streaming-architecture.md`.
7. **Report** - List what each marker resolved to and any diagrams
   converted, so the user can catch a wrong call before this goes out.

# Deferred Markers as Callouts

If a marker should stay visible to reviewers instead of disappearing:

```markdown
| **Open Question** | Token expiration is set to 24h. Feedback requested on whether this works for long sessions. |
| :---- |
```

# Edge Cases

- No REVIEW markers found: skip straight to diagram conversion.
- No ASCII diagrams found: skip straight to removing Draft Status.
- A diagram is too complex to convert accurately: leave it as ASCII and
  flag it in your report for manual recreation, rather than producing a
  broken mermaid version.
