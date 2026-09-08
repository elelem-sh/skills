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

`elelem-skills` scans, in this order (later paths shadow earlier ones by name):

1. `lib/elelem/skills/builtin/*/SKILL.md` bundled with this gem -- currently
   just `scrum`: a story-driven workflow (backlog files under
   `.agents/backlog/`) with five phases (plan, design, build, review, verify)
   as sibling files the model reads on demand. Used to live as five separate
   ERB system prompts before the skills standard existed.
2. `~/.agents/remote-skills/<host>/*/SKILL.md` -- skills installed via
   `/skills fetch` (see below), partitioned by the index host they came
   from so two publishers naming a skill the same thing don't clobber each
   other's files on disk. Note this only prevents the file collision: if
   two different hosts both publish a skill named `wrangler`, `Catalog`
   still resolves `skill(name: "wrangler")` to whichever one was scanned
   last (see precedence above) -- partitioning fixes storage, not naming
   ambiguity across publishers.
3. `~/.agents/skills/*/SKILL.md` (user-level)
4. `.agents/skills/*/SKILL.md` (project-level)

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

## Remote discovery: `/skills fetch <origin>`

Implements [cloudflare/agent-skills-discovery-rfc](https://github.com/cloudflare/agent-skills-discovery-rfc)
(`.well-known/agent-skills/`) as a client. `/skills fetch example.com`:

1. GETs `https://example.com/.well-known/agent-skills/index.json`
2. Verifies `$schema` matches the v0.2.0 schema URI the spec defines --
   an unrecognized or absent `$schema` is rejected outright, per spec
3. For each `type: "skill-md"` entry, GETs the artifact and verifies its
   SHA-256 against the index's `digest` before writing anything to disk;
   a mismatch raises rather than installing unverified content
4. Writes verified skills to `~/.agents/remote-skills/<host>/<name>/SKILL.md`,
   partitioned by the index's own host (not the artifact URL's host, which
   the spec allows to point elsewhere, e.g. a CDN)

This is deliberately a separate, on-demand step from `Catalog` discovery,
not folded into it -- `Catalog#discover` runs synchronously on every
agent build, so it stays local-filesystem-only and fast. Fetching is the
only place in this gem that touches the network.

**Restart `elelem` after a fetch to pick up the newly installed skills --
don't use `/reload`.** `Registry#reload` in elelem core clears all
registered setups and toolbox tools, then re-`load`s files under
`~/.agents/plugins`; but those files typically just `require
"elelem/skills"`, and `require` is a no-op the second time (unlike
`load`), so this gem's `config.setup(:skills)` block -- and therefore the
`skill` tool itself -- never re-registers. Verified: after `/reload`,
`agent.toolbox.tools.keys` is `[]`. A fresh `elelem` process picks up
fetched skills correctly; this is a core gap in how `/reload` interacts
with plugin files that use `require` instead of `load`, not something
fixable from this gem.

**Not implemented**: `type: "archive"` entries (`.tar.gz`/`.zip` bundles
with `scripts/`/`references/`/`assets/`) are skipped with a warning --
only single-file `skill-md` entries install today. Verified against the
real, live index at `developers.cloudflare.com`, which publishes both
types; the `skill-md` entries (`wrangler`, `web-perf`, etc.) install and
parse correctly, the `archive` entries are skipped as designed.

## What's not implemented

- `agents/*.yaml` sidecar files (per-runtime display metadata, invocation
  policy) that some skills ship alongside `SKILL.md` -- ignored for now.
- `allowed-tools` / permission scoping from the frontmatter.
- Skill installation/updates from the `npx skills` package manager
  ecosystem -- a separate concern from the well-known-URI discovery above.
- `type: "archive"` fetch entries (see above).

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
