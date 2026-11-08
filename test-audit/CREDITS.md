# Credits

`test-audit` and its [CAMPAIGN.md](CAMPAIGN.md) are adapted from [OpenClaw](https://github.com/openclaw/openclaw/tree/main/.agents/skills/test-audit), pinned at `89ba6b0f12ff337b6f60dc162391575e5999873e`. OpenClaw-only tooling (its Vitest wrapper, changed-gate script, `$crabbox`, `$autoreview`, and PR maintainer flow) maps onto this harness's `/tdd`, `/review`, and `/commit-push-pr`; parallel lanes require explicit delegation. The Telegram campaign examples are kept as upstream evidence.

## Source and local adaptations

Reviewed on 2026-11-08. Source files at the immutable pin:

- [Authoring and audit entrypoint](https://github.com/openclaw/openclaw/blob/89ba6b0f12ff337b6f60dc162391575e5999873e/.agents/skills/test-audit/SKILL.md).
- [Audit reference](https://github.com/openclaw/openclaw/blob/89ba6b0f12ff337b6f60dc162391575e5999873e/.agents/skills/test-audit/references/audit.md).
- [Campaign](https://github.com/openclaw/openclaw/blob/89ba6b0f12ff337b6f60dc162391575e5999873e/.agents/skills/test-audit/CAMPAIGN.md).
- [MIT license](https://github.com/openclaw/openclaw/blob/89ba6b0f12ff337b6f60dc162391575e5999873e/LICENSE).

These are local adaptations, not unchanged snapshots. The expanded audit checklist
and workflow remain together in [SKILL.md](SKILL.md), including local UI and async
false-proof patterns. Upstream's new dead-code checks map to the target repository's
configured dependency, unused-file, and export checks; no analyzer is installed.
Campaign reruns can use broad CI proof only for the same merged candidate, without
weakening repository gates. Delegation and delivery remain explicitly authorized.
Upstream-only proof-policy and writing-test links resolve to the local authoring
gate and verification owners rather than importing another harness workflow.

## Refresh

At one reviewed full upstream SHA, compare the three skill files and LICENSE above,
carry changed guidance into the existing local owners, preserve host adaptations,
and update this pin plus `evals/test-openclaw-vendored-skills.sh`. Run
`bash evals/run.sh openclaw-vendored-skills`,
`bash evals/run.sh low-value-test-audit`, and `bash evals/run.sh lie-detector`.

## Upstream license

MIT License

Copyright (c) 2026 OpenClaw Foundation

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
