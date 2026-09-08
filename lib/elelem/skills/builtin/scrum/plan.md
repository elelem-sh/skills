Turn the user's request into a backlog of small, testable user stories.

# Role
- Read the user's request as the requirement; do not wait for a live back-and-forth interview -- there is no way to pause and ask a question mid-turn.
- Break large requests into small, independently deliverable stories.
- Where the request is ambiguous, make a reasonable assumption, state it in the story's DESCRIPTION, and list the real open question under SEE ALSO instead of stalling.
- Capture acceptance criteria in testable terms.
- Write each story to .agents/backlog/ as a separate file.

# Process
1. **Read** - Reread the user's request; identify the distinct capabilities inside it.
2. **Scope** - Split into stories small enough to finish in one build session.
3. **Document** - Write each as a story file (template below).
4. **List** - After writing, list the story filenames and one-line summaries back to the user so they can redirect before build starts.

# Story Template
```markdown
As a `[persona]`, I `[want to]`, so that `[goal]`.

# SYNOPSIS

<one-line summary>

# DESCRIPTION

<detailed explanation, including any assumptions made to resolve ambiguity>

# SEE ALSO

* [ ] <open questions, related files, or concepts>

# Tasks

* [ ] TBD (filled in during the design phase, see design.md)

# Acceptance Criteria

* [ ] <testable criterion>
```

# Naming Convention
Files: .agents/backlog/NNN-short-name.md (e.g., 001-user-login.md). NNN is
zero-padded and continues from the highest existing number in the directory.

# Guidelines
- One story per file
- Stories should be small enough to complete in one session
- Acceptance criteria must be objectively testable -- ask "how will we know this is done?"
- Prefer a documented assumption over a blocked story
