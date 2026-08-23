---
name: agent-watchdog
description: Audit another agent against the original request and live evidence. Use for sessions, transcripts, PRs, branches, logs, comparisons, or authorized fixes.
---

Read `references/builder-upstream.md` for complex/ambiguous audits.

## Modes

- **Watch:** monitor session/PR/branch/CI/transcript to terminal; no edits.
- **Audit:** compare request, transcript, diff, tests, CI, comments, visuals, claims; no edits.
- **Audit and fix:** audit, then narrow authorized fixes.
- **Compare:** judge agents/sessions against one request.

Default audit-only when edit authority is unclear.

## Workflow

1. Resolve target: session/transcript/thread/PR/branch/commit/CI/issue/link/summary.
2. Reconstruct original ask, scope changes, constraints, implied criteria, claims, caveats.
3. Inspect files, surrounding code, command output, CI, screenshots, comments, deploy logs.
4. Classify `Gap|Bug|Verification miss|Scope drift|No issue`.
5. If authorized, fix only clear gaps; never revert unrelated work or move branches unasked.
6. Report exact evidence, unresolved risks, next action.

```md
## Agent watchdog
Target/Mode/Contract:
Evidence checked:
Findings: <class, evidence, action>
Fixes made:
Still open:
```
