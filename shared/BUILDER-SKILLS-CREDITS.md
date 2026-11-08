# Builder workflow sources and refresh

The selected workflow guidance was reviewed against
[BuilderIO/skills at `f4f10b8d`](https://github.com/BuilderIO/skills/tree/f4f10b8d513476c24bd995ceac5294bcdd6ee15c)
(`f4f10b8d513476c24bd995ceac5294bcdd6ee15c`). This is a selected skill
integration, not installation of the Agent-Native runtime or the complete suite.
WebMCP has [separate provenance](../webmcp/CREDITS.md).

## Selection

- `skills/visual-plan/` and `skills/visual-recap/`: the existing sync command
  copies entrypoints into `references/agent-native-plan.md` and
  `references/agent-native-recap.md`, with all skill-local references. It
  normalizes typographic punctuation; these are not byte-exact snapshots.
- `skills/agent-watchdog/SKILL.md`: punctuation-normalized source in
  `agent-watchdog/references/builder-upstream.md`; local mode, authorization,
  remote-completion and inline-investigation rules stay in its owner.
- `skills/plan-arbiter/SKILL.md` and `skills/read-the-damn-docs/SKILL.md`:
  existing `references/builder-upstream.md` copies are unchanged at this pin.
- `skills/plow-ahead/SKILL.md`: existing reference remains locally adapted for
  owned-branch delivery; the latest source does not change its other guidance.
- Upstream `efficient-frontier` now aliases the explicit-only
  `efficient-orchestrator`, which selects cheaper helper models. That policy is
  not adopted. Local `efficient-frontier` keeps `config/model-routing.json`,
  owner-selected model/effort and the bounded delegation-packet adaptation.
  No new orchestrator command is registered.

## Host compatibility

Local owners, repository instructions and the live host take precedence over
source recipes. Skill loading grants no agents, monitoring, production access,
runtime installs, browser takeover, visibility changes or external publication.
Use the live schema before applying named tools or revision fences; unavailable
capabilities remain explicit gaps rather than invented calls. Local-files mode
must not upload private content. Do not claim renderer-schema validation when
only offline lint ran. Browser access and server startup follow the host's
requested-surface rules. An iteration budget never authorizes handing off a
known broken artifact: report the unresolved defect instead.

## Refresh and verification

Use a separate trusted Git checkout at a reviewed full revision. Review source,
local resources, helpers, URLs and license changes before copying. The imported workflow instructions and references are Markdown; upstream
READMEs and agent metadata remain unregistered. No upstream helper is executed.

```sh
git -C /path/to/BuilderIO-skills checkout --detach <reviewed-full-sha>
node scripts/sync-agent-native-plan-skills.mjs /path/to/BuilderIO-skills
node scripts/sync-agent-native-plan-skills.mjs --check /path/to/BuilderIO-skills
bash evals/run.sh builder-skills
```

For the remaining references, compare each selected source at that revision;
retain the local adaptations above rather than blindly replacing owners.
Run the sync again and confirm no additional diff. Central catalog/discovery,
packaging and repository checks remain coordinator-owned. These checks establish
source consistency and routing, not model adherence or Plan runtime behavior.

## Upstream license

MIT License

Copyright (c) 2026 Builder.io

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
