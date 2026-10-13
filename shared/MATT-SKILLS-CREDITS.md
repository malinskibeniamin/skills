# Matt Pocock skills provenance

Upstream: [mattpocock/skills](https://github.com/mattpocock/skills), MIT.
Last released baseline: [v1.3.1](https://github.com/mattpocock/skills/releases/tag/v1.3.1).
Reviewed source: [49dd158d1076134a641b33efb035946536778336](https://github.com/mattpocock/skills/tree/49dd158d1076134a641b33efb035946536778336), reviewed October 13, 2026.
This refresh follows [the post-release delta](https://github.com/mattpocock/skills/compare/v1.3.1...49dd158d1076134a641b33efb035946536778336), not a new upstream release. Local skills remain adaptations, not byte-identical copies.

## Adopted

| Upstream change | Local owner |
|---|---|
| Read a skill before recommending or skipping it | `ask-ben` |
| Ticket identity before implementation | `development-lifecycle` rather than retired `implement` |
| Complete standards-source discovery | `review`; independent foreground axes only with authorized delegation |
| Proven forced-RED mutations and seam coverage trade-offs | `diagnosing-bugs`, `tdd` |
| Yes accepts the recommended answer | `grilling` |
| Decision-only labels, type dispatch, real-ID cross-references | `wayfinder` |
| Native parent relationships and one source of blocker truth | `to-tickets`, `work-automation-kit` tracker templates |
| Create missing configured labels; structured and paginated tracker reads | `work-automation-kit`, `triage/tracker-github.md` |
| Explicit host temporary directory; learner-relative paths and quiz order | `handoff`, `teach` |
| EOF, quoting/defaults, symlinks/permissions, parsed procedure, visible opener fallback | `wizard/template.sh` |
| Tactical versus strategic environment improvement | Existing `retro` and opt-in `swarm`, not another coordinator skill |

The GitHub sub-issue operations are capability-gated by installed CLI help, with a database-ID API fallback. GitLab uses the documented long `--output` flag; its short flag differs between issue and MR commands.

## Compatibility and exclusions

- Preserve requested scope, endpoint, model, and explicit delegation/scheduling authorization. A refresh never grants background work or creates research branches by default.
- Keep human selection before retrospective changes. Strategic findings stay recommendations outside the active task's scope.
- Keep our existing native plugin surfaces and names; do not install the upstream pack alongside them. Upstream managed-install documentation is not a change to this harness's installation identity.
- Compose existing workflows before adding a skill. Upstream `chief-of-staff` remains WIP; its mandatory background-agent and no-workaround policies are not imported.
- Keep `misc/` skills unregistered. Upstream's personal contribution freeze and automatic 14-day issue closure are maintainer policies, not portable harness defaults; no remote issue automation is enabled by this refresh.
- The upstream apostrophe-decoding expression was repaired for macOS Bash 3.2 after the rerun regression test caught an extra backslash. Atomic replacement was retained through symlink resolution after a real file-size-limit failure showed the upstream in-place rewrite truncating existing configuration.
- The published handoff command uses trailing `XXXXXX`; BSD `mktemp` treated `XXXXXX.md` as a literal filename. A twice-run command test caught the collision.
- `write_env` preserves shell literals. Dotenv parsers differ on embedded quotes and expansion: verify the project's actual loader before using such values, rather than claim universal compatibility.

## Refresh verification

Read the current pin and compare it with one new reviewed commit. Reconcile each changed skill against its local owner and retain the compatibility decisions above.

- `bun test ./wizard/template.test.ts`: real generated Bash procedure with isolated browser/secret commands; success, EOF failure, reruns, literal values, permissions, symlinks, atomic failure preservation, and edits after prompting.
- `bash evals/run.sh matt-post-v1-3`: published instruction/tracker contracts, not an agent-behavior benchmark.
- Existing Matt evals, skill-writing/token budgets, generation gates, `bun run lint:fix`, and `bun run type:check`.

No paid model evaluations or live tracker/credential mutations are needed for this deterministic refresh.

## Upstream license

Retained from the reviewed source's [LICENSE](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/LICENSE).

```text
MIT License

Copyright (c) 2026 Matt Pocock

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
