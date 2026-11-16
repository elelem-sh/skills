As a `user who fetches skills from a remote index`, I `want a skill
whose digest changed since I pinned it to be held back until I accept
it`, so that `a compromised or changed server cannot swap the
instructions my agent follows`.

# SYNOPSIS

Refuse changed pinned digests unless accepted, and skip entries without
a digest instead of aborting the fetch.

# DESCRIPTION

The fetcher now pins each skill's digest in `.skill-lock.json` on first
fetch and reads it back on later fetches. When the index advertises a
different digest, `warn_if_changed` logs a warning, adds the skill to
`changed`, and installs the new content anyway (fetcher.rb:88-95). The
digest and the content come from the same server, so the pin only helps
if a change is stopped, not just reported. A warning in a log, or one
line in `/skills fetch` output, is easy to miss.

An index entry with no digest raises `FetchError`
(fetcher.rb:69). Because every skill is downloaded before any is
installed, one such entry aborts the whole fetch and nothing installs,
including well-formed skills from the same index.

Already fixed on main (commit 1134c2d and later):

* https is required; plain http is allowed only for a skill server on
  this machine (fetcher.rb:154-161).
* All skills are downloaded and checked before any is written, and
  each file is written beside the target and renamed
  (fetcher.rb:42-46, :82-84).
* Redirects are followed, up to 5 hops, never from https to http and
  never from a remote origin to this machine.
* The lockfile is read on later fetches (lockfile.rb:34).

Proposed behavior:

* A changed digest for a pinned skill is not installed. The fetch says
  which skills were held back, with old and new digests, and how to
  accept them (for example `elelem-skills fetch --update NAME` or a
  flag that accepts all changes; decide in design).
* An entry without a digest is skipped with a warning, like an
  unsupported type (fetcher.rb:64-68), and the rest of the index
  installs.

# SEE ALSO

* [ ] lib/elelem/skills/fetcher.rb:69 - missing digest aborts the fetch
* [ ] lib/elelem/skills/fetcher.rb:88-95 - changed digest only warns
* [ ] lib/elelem/skills/lockfile.rb:34 - digest_for
* [ ] lib/elelem/skills/setup.rb:72 - /skills fetch reports changes
* [ ] lib/elelem/skills/cli.rb - elelem-skills fetch
* [ ] Formerly elelem-sh/elelem.sh#4

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] A skill whose index digest differs from its pinned digest is not
      written, and the pinned file is left as it was
* [ ] The fetch output names each held-back skill with both digests
* [ ] An explicit accept option installs the new content and updates
      the pin
* [ ] An index entry without a digest is skipped with a warning, and the
      other skills from that index install
* [ ] A first fetch (no pin yet) still installs and pins as today
* [ ] Specs cover each case above, for both `/skills fetch` and the
      elelem-skills CLI
