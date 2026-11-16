As a `user who just ran /skills fetch`, I `want the model to see the
new skills in the skill tool's description right away`, so that `I do
not have to restart elelem before the model knows they exist`.

# SYNOPSIS

Rebuild the skill tool description when the catalog reloads.

# DESCRIPTION

The `skill` tool's description embeds the catalog index: "Load a
skill's instructions by name. Available skills:" followed by one
summary per skill (setup.rb:27-29). The string is built once, when the
tool is registered. After `/skills fetch`, `@catalog.all(reload: true)`
refreshes the catalog (setup.rb:74), so `/skills`, `/skills NAME` and a
`skill` call by name all see the new skills. The description the model
reads still lists the old set until elelem restarts, and the fetch
message says so (setup.rb:75-76). A model rarely calls a skill it has
not been told about.

Options to weigh in design:

* Re-register the `skill` tool after a fetch, so the toolbox holds a
  new description.
* Let core accept a description that is computed when tools are sent
  to the provider (a callable), and use it here. That change belongs in
  core.

Already fixed on main, from the same issue:

* The CLI (`exe/elelem-skills`, cli.rb) and the lockfile are in the
  source. They reach users when 0.4.0 is released; the release PR is
  open (release-please branch, version 0.4.0) and RubyGems still has
  0.3.0.
* The bundled `scrum` skill was dropped (6a66dd9).
* The catalog is reloaded after a fetch, so `/skills` sees new skills
  (setup.rb:74, catalog.rb:18-21).

Not in this repository: the `/tools` table cuts the skill row at
"Available skills:". Core's tools plugin uses only the first line of
each description (`t.description.lines.first`, elelem
lib/elelem/plugins/tools.rb:13). Whether that is the right summary for a
table is a core decision; this story does not change it.

# SEE ALSO

* [ ] lib/elelem/skills/setup.rb:27-29 - description built once
* [ ] lib/elelem/skills/setup.rb:74-76 - reload and restart notice
* [ ] lib/elelem/skills/catalog.rb:18 - all(reload:)
* [ ] elelem lib/elelem/plugins/tools.rb:13 - /tools row uses the first
      line (core)
* [ ] Formerly elelem-sh/elelem.sh#46

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] After `/skills fetch` installs a skill, the next request to the
      provider carries a `skill` tool description that lists it
* [ ] The fetch message no longer tells the user to restart
* [ ] A spec fetches a skill, then checks the tool description sent on
      the next turn
