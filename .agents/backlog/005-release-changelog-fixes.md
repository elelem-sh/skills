As a `user reading the elelem-skills changelog`, I `want each entry to
state the real elelem requirement and link to the right place`, so
that `I know which elelem I need and can find the story behind a fix`.

# SYNOPSIS

Correct the 0.4.0 changelog before release, and stop generating links
to the wrong repository.

# DESCRIPTION

The open release PR for 0.4.0 (release-please branch, commit 9527824)
adds a CHANGELOG.md with two problems:

* The entry for 8b25a4f says "require elelem ~> 0.12". The gemspec now
  allows `>= 0.12, < 1` (elelem-skills.gemspec:32). The change was made
  in 877903f, a chore commit, so it is not in the changelog.
* Two entries link `elelem-sh/elelem.sh#4` to
  `https://github.com/elelem-sh/skills/issues/4`. release-please links
  a `#N` in a commit subject to the repository it runs in, so a
  reference to another repository's issue gets the wrong URL.

Fix the CHANGELOG.md in the release PR by hand before merging: state
the actual constraint, and point the issue links at
`https://github.com/elelem-sh/elelem.sh/issues/4` (or drop them).

Going forward, issues are moving to `.agents/backlog` story files, so
new commits should reference a story path, not `#N`. That avoids the
wrong link on every later release.

# SEE ALSO

* [ ] elelem-skills.gemspec:32 - elelem dependency
* [ ] release-please-config.json
* [ ] .release-please-manifest.json - still 0.3.0 on main
* [ ] Formerly elelem-sh/elelem.sh#55

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] The 0.4.0 changelog states the elelem requirement the gemspec
      has (`>= 0.12, < 1`)
* [ ] No changelog link points at `elelem-sh/skills/issues/`
* [ ] The 0.4.0 gem is released with the corrected changelog
