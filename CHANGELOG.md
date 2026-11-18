# Changelog

## [0.4.2](https://github.com/elelem-sh/skills/compare/v0.4.1...v0.4.2) (2026-11-18)


### Bug Fixes

* **deps:** accept the json that Ruby 4.0 ships ([7c79852](https://github.com/elelem-sh/skills/commit/7c79852730a53ba96a4aa88e264a968ae1b9beb2))

## [0.4.1](https://github.com/elelem-sh/skills/compare/v0.4.0...v0.4.1) (2026-11-17)


### Bug Fixes

* elelem-skills treats -h and --help as help instead of an unknown command ([0edbcc8](https://github.com/elelem-sh/skills/commit/0edbcc868cad3174fb898a321c8c3ce0fa2295c3))

## [0.4.0](https://github.com/elelem-sh/skills/compare/v0.3.0...v0.4.0) (2026-11-17)


### Features

* add elelem-skills CLI, lockfile for remote fetches, drop bundled scrum skill ([6a66dd9](https://github.com/elelem-sh/skills/commit/6a66dd990d974709fabd16fd3023ddf30087a53c))


### Bug Fixes

* a remote skills index cannot redirect to this machine, and /skills fetch names skills that changed ([61a0f7a](https://github.com/elelem-sh/skills/commit/61a0f7aa6ff3312776c5b9c8747dac31973cef88))
* require elelem &gt;= 0.13.1, the release the specs are written against ([7ef87b8](https://github.com/elelem-sh/skills/commit/7ef87b82dbb0b4b8603c665d214949eb741d9340))
* require elelem ~&gt; 0.12, the floor builtins/skills actually need ([8b25a4f](https://github.com/elelem-sh/skills/commit/8b25a4f60c298e2a647ca66529e921583ab983a4))
* SKILL.md files with Windows line endings or a byte order mark load ([550d3b5](https://github.com/elelem-sh/skills/commit/550d3b529a6a7a72325eb1490c5d7d2143fe1c79))
* SKILL.md is read as UTF-8 whatever the locale ([8f7447c](https://github.com/elelem-sh/skills/commit/8f7447c1827227aaec00583d131c53e65c5b1201))
* skills also treats numeric loopback forms like 127.1 as this machine ([a78391e](https://github.com/elelem-sh/skills/commit/a78391ee04b6f4e66461b7321f9a800d46c205b3))
* skills decides this machine by address, so other spellings of loopback are refused too ([8bb1924](https://github.com/elelem-sh/skills/commit/8bb19249aa446c95338a3c76b59ee1771311c9f3))
* skills fetch follows up to 5 redirects, never from https to http (elelem-sh/elelem.sh[#4](https://github.com/elelem-sh/skills/issues/4)) ([44635ad](https://github.com/elelem-sh/skills/commit/44635adac765e4be51f083154205de711a656cab))
* skills fetch needs https, installs all or nothing, and warns when a pinned digest changes (elelem-sh/elelem.sh[#4](https://github.com/elelem-sh/skills/issues/4)) ([1134c2d](https://github.com/elelem-sh/skills/commit/1134c2d0aee89b94587b4cf83ba528455d1806ef))
* wrap Agent in Session in specs ([0c7cab1](https://github.com/elelem-sh/skills/commit/0c7cab14c377e83ba20871b997dd5b036082d97f))
