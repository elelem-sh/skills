As a `user fetching skills`, I `want a 304 or a redirect with no
Location to be reported for what it is`, so that `I am not told "too
many redirects" for a server that never redirected`.

# SYNOPSIS

Treat only real redirects as redirects; report 304 and missing
Location plainly.

# DESCRIPTION

`get` follows any `Net::HTTPRedirection` (fetcher.rb:118).
`Net::HTTPNotModified` (304) is a subclass of `Net::HTTPRedirection`,
so a 304 is followed like a redirect. `redirect` joins the current URI
with `response["location"].to_s` (fetcher.rb:131). With an empty or
missing Location header that resolves back to the same URI, so the
fetcher requests the same URL until the 5-hop limit and raises "too
many redirects" (fetcher.rb:129).

Expected:

* 301, 302, 303, 307 and 308 with a Location header are followed as
  today.
* A 3xx without a Location, or with an empty one, raises a
  `FetchError` that says the redirect had no Location.
* A 304 raises a `FetchError` that reports the status. The fetcher
  sends no conditional headers, so a 304 is unexpected.

# SEE ALSO

* [ ] lib/elelem/skills/fetcher.rb:118 - is_a?(Net::HTTPRedirection)
* [ ] lib/elelem/skills/fetcher.rb:128-131 - redirect
* [ ] spec/elelem/skills/fetcher_spec.rb
* [ ] Formerly elelem-sh/elelem.sh#51

# Tasks

* [ ] TBD (filled in design mode)

# Acceptance Criteria

* [ ] A 304 response raises an error that names the status, after one
      request
* [ ] A 302 with no Location raises an error that says the Location is
      missing, after one request
* [ ] A 302 with an empty Location behaves the same way
* [ ] Existing redirect specs still pass
