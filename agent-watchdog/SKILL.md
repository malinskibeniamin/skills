---
name: agent-watchdog
description: Audit another agent against the original request and live evidence. Use for sessions, PRs, branches, comparisons, authorized fixes, or taking over stuck work.
---

Read `references/builder-upstream.md` for complex/ambiguous audits.
Use only authorized sources and live host capabilities. Investigate inline; extra
agents, monitoring, production access, and writes need their own authorization.

## Modes

- **Watch:** monitor session/PR/branch/CI/transcript to terminal; no edits.
- **Audit:** compare request, transcript, diff, tests, CI, comments, visuals, claims; no edits.
- **Audit and fix:** audit, then narrow authorized fixes.
- **Compare:** judge agents/sessions against one request.
- **Takeover:** explicit request to own stuck work; follow [references/takeover.md](references/takeover.md), then execute to the requested endpoint. This is not limited to patching the previous approach.

Default audit-only when edit authority is unclear.

## Workflow

For takeover, use its reference instead of the narrow audit-and-fix steps below.

1. Resolve target: session/transcript/thread/PR/branch/commit/CI/issue/link/summary.
2. Reconstruct the original ask and constraints; form your own hypotheses before
   reading the watched agent's conclusions when possible.
3. Independently inspect primary evidence for the same problem, then compare it
   with the agent's diff, checks, and claims. Mark prior exposure; this inline
   investigation is not an independent reviewer or model-family pass.
4. Classify `Gap|Bug|Verification miss|Scope drift|No issue`.
5. If authorized, fix only clear gaps; never revert unrelated work or move branches unasked.
6. Report exact evidence, actionable differences, unresolved risks, and next action.
   Interrupt a live agent only for a current-step defect, correction, or blocker;
   batch other verified gaps at its next checkpoint and avoid duplicate notes.

For completed worktrees, verify pending files and actual remote HEAD per
[remote completion](../shared/remote-completion.md). Read-only modes report gaps;
authorized recovery owns verification, commit, and push.

[Sources and refresh](../shared/BUILDER-SKILLS-CREDITS.md).

```md
## Agent watchdog
Target/Mode/Contract:
Evidence checked:
Findings: <class, evidence, action>
Fixes made:
Still open:
```
