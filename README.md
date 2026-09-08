# elelem-skills

Loads [agent skills](https://github.com/anthropics/skills) — `SKILL.md` files
under an `.agents/skills/` directory — and exposes them to an `elelem` agent.

## What this actually is

A skill is a directory containing a `SKILL.md` with YAML frontmatter:

```
.agents/skills/tdd/SKILL.md
---
name: tdd
description: Test-driven development. Use when the user wants tests written first.
---

# Test-Driven Development
...body...
```

`elelem-skills` scans:

1. `~/.agents/skills/*/SKILL.md` (user-level)
2. `.agents/skills/*/SKILL.md` (project-level, shadows user-level by name)

for skills, and registers a `skill` toolbox tool whose *description* is the
skill index (name + frontmatter description for every discovered skill) --
this is the progressive-disclosure mechanism the standard relies on: the
model sees the index up front and decides when to call `skill(name: "tdd")`
to pull in the full body on demand, rather than every skill being crammed
into the system prompt.

The tool result includes the skill's directory (`dir`), so a skill body that
links to bundled files (`[tests.md](tests.md)`) can be followed with the
`read` tool from `elelem-builtins`.

A `/skills [name]` command is also registered for human-driven listing/reading.

## What's not implemented

- `agents/*.yaml` sidecar files (per-runtime display metadata, invocation
  policy) that some skills ship alongside `SKILL.md` -- ignored for now.
- `allowed-tools` / permission scoping from the frontmatter.
- Skill installation/updates (that's `npx skills`, a separate concern).

## Setup

```
bundle install
bundle exec rake spec
```

## Usage

Add `elelem-skills` to an elelem project and skills under `~/.agents/skills/`
or `.agents/skills/` are picked up automatically:

```
bundle exec elelem
> /skills
tdd: Test-driven development. Use when the user wants tests written first.
> /skills tdd
# Test-Driven Development
...
```
