As a `user fetching skills from a remote index`, I `want the fetcher
to refuse private and cloud metadata addresses`, so that `a remote
index or redirect cannot make my machine request internal services`.

# SYNOPSIS

Decide whether SSRF protection is in scope; if so, refuse private
ranges for remote origins.

# DESCRIPTION

Decision needed first: is protection against server-side request
forgery in scope for `skills fetch`? The user chooses the index, which
argues no. A remote index can still redirect, and can list skill URLs
on any host, which argues yes. Record the decision in this story before
any code changes. If out of scope, document the limit in the README
and close the story.

Current behavior: `secure?` (fetcher.rb:154-161) refuses only this
machine (loopback, `localhost`, `0.0.0.0` and their numeric spellings),
and only when the origin is remote. An https URL, or a redirect, to
10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 (including the
169.254.169.254 metadata address), IPv6 unique local or link-local
addresses is allowed. `local?` checks numeric forms only
(fetcher.rb:134-152); a host name that resolves to a private or
loopback address is not checked, as its comment says.

If in scope:

* Resolve each host before connecting, and refuse private, loopback,
  link-local, unique local and metadata addresses unless the origin
  itself is private (someone fetching from their own LAN server).
* Connect to the address that was checked, so a second DNS answer
  cannot differ from the first.
* Check again after every redirect.

# SEE ALSO

* [ ] lib/elelem/skills/fetcher.rb:134-152 - local?, numeric_addresses
* [ ] lib/elelem/skills/fetcher.rb:154-161 - secure?
* [ ] lib/elelem/skills/fetcher.rb:114 - get, checked per hop
* [ ] Formerly elelem-sh/elelem.sh#52

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] The scope decision is recorded in this story
* [ ] If out of scope: the README states that fetch does not block
      private addresses
* [ ] If in scope: a remote origin, skill URL or redirect that resolves
      to a private, link-local or metadata address is refused with a
      clear error
* [ ] If in scope: a private origin can still fetch from itself
* [ ] If in scope: specs cover numeric addresses, a name that resolves
      to a private address, and a redirect into a private range
