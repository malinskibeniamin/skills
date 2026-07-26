---
name: agent-watchdog
description: Audit another agent against the original request and live evidence. Use for sessions, transcripts, PRs, branches, logs, comparisons, or authorized fixes.
---

# Agent Watchdog
Read `references/builder-upstream.md` when the audit is complex or the source artifact is ambiguous.

## Modes

- **Watch only**: monitor session, PR, branch, CI run, or transcript until terminal. Do not edit.
- **Audit**: compare request, transcript, diff, tests, CI, comments, screenshots, and final claims. Do not edit.
- **Audit and fix**: audit first, then make narrow fixes for clear, authorized gaps.
- **Compare**: compare multiple agents/sessions against the same original request.

Default to audit-only when edit authority is unclear.

## Workflow

1. Resolve every target: session id, transcript, thread URL, PR, branch, commit, CI run, issue, Slack link, or pasted summary.
2. Reconstruct the contract: original ask, scope changes, constraints, implied acceptance criteria, final claims, and caveats.
3. Inspect evidence, not vibes: changed files, surrounding code, actual command output, CI, screenshots, unresolved comments, deploy logs.
4. Classify each issue: `Gap`, `Bug`, `Verification miss`, `Scope drift`, or `No issue`.
5. If authorized, fix only clear gaps; never revert unrelated work or move branches unless asked.
6. Report status with exact files, commands, unresolved risks, and next action.

## Output

```md
## Agent watchdog
Target: <artifact>
Mode: watch|audit|audit-and-fix|compare
Contract: <what the user asked>
Evidence checked: <files/commands/CI/comments>
Findings:
- <Gap|Bug|Verification miss|Scope drift|No issue>: <evidence and required action>
Fixes made: <if any>
Still open: <blockers or risks>
```
