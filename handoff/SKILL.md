---
name: handoff
description: Compact the current session into a handoff document for another agent or fresh session.
argument-hint: What should the next session focus on?
disable-model-invocation: true
---

Call the Skill tool separately: "agent-watchdog" audits another run; "plan-arbiter" compares plans. Other hosts: [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies). Continuation context only.

## Procedure

1. Use host temp (`$TMPDIR`, else `/tmp`; `%TEMP%` on Windows), never the workspace. Unix: `handoff_file=$(mktemp "${TMPDIR:-/tmp}/handoff-XXXXXX")`.
2. Do not duplicate artifacts. Link specs, plans, ADRs, issues, commits, diffs, and docs.
3. Treat arguments as next-session focus.
4. Redact sensitive data (credentials, secrets, personal/customer data); note redaction only when continuation is affected.
5. Suggest useful next skills.
6. Return only path plus 1-2 sentence summary.

For an explicitly requested background agent, skip the file. Check `command -v claude`, then `claude --bg --name "<descriptive name>" "<handoff summary>"`. Failure: return command and summary, never claim a launch. Include `/agent-watchdog` for claim verification.

## Template

```markdown
# Handoff
## Next session focus
<first objective>
## Current state
<branch, cwd, PR/issue, required facts>
## Decisions made
<linked bullets>
## Open questions
<bullets or None>
## Next actions
1. <action>
2. <verification/shipping>
## Relevant artifacts
- <path/URL>: <purpose>
## Suggested skills
- </skill>: <why>
```

## Guardrails

Label uncertainty. If no useful work happened, write a short starter brief.
