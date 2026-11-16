As a `person who finds elelem-skills on RubyGems`, I `want the
gem page to link to the plugin's documentation, backlog and
changelog`, so that `I can learn how to use it and see known
problems without GitHub Issues`.

# SYNOPSIS

Point the gemspec homepage at elelem.sh and add the standard links.

# DESCRIPTION

RubyGems shows `homepage_uri` and the other `metadata` links on every
gem page. Today `elelem-skills.gemspec` sets `spec.homepage`
to the site root (https://elelem.sh) and sets only `homepage_uri`,
`source_code_uri`, `allowed_push_host` and
`rubygems_mfa_required`.
There is no documentation, bug tracker or changelog link.

Proposed change:

```ruby
spec.homepage = "https://elelem.sh/plugins/skills/"
spec.metadata["homepage_uri"] = spec.homepage
spec.metadata["source_code_uri"] = "https://github.com/elelem-sh/skills"
spec.metadata["documentation_uri"] = spec.homepage
spec.metadata["bug_tracker_uri"] = "https://github.com/elelem-sh/skills/tree/main/.agents/backlog"
spec.metadata["changelog_uri"] = "https://github.com/elelem-sh/skills/blob/main/CHANGELOG.md"
```

The original proposal pointed `bug_tracker_uri` at GitHub Issues on
elelem-sh/elelem.sh, filtered by label. That no longer fits: the
project is moving its backlog out of GitHub Issues and into
`.agents/backlog` story files in each repository, so the bug tracker
link points at this repository's backlog directory instead.

/man/skills/ redirects to /plugins/skills/ on elelem.sh, so a
separate documentation_uri adds nothing. Point both at the plugin page.

CHANGELOG.md does not exist yet; release-please adds it with the
0.4.0 release, so the link works once that release PR merges.

Keep `allowed_push_host` and `rubygems_mfa_required` as they are.
RubyGems only shows the new links after the next release.

# SEE ALSO

* [ ] elelem-skills.gemspec - spec.homepage
* [ ] elelem-skills.gemspec - source_code_uri
* [ ] .agents/backlog/ - where bug_tracker_uri will point
* [ ] Formerly elelem-sh/elelem.sh#41

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] `spec.homepage` and `homepage_uri` are https://elelem.sh/plugins/skills/
* [ ] `bug_tracker_uri` points at this repository's `.agents/backlog`,
      not at GitHub Issues
* [ ] `changelog_uri` and `source_code_uri` point at this repository
* [ ] `allowed_push_host` and `rubygems_mfa_required` are unchanged
* [ ] `gem build` succeeds and `gem spec` on the built gem shows every
      link
* [ ] Every link resolves (no 404) at release time
