---
name: handoff
description: Compact the current session into a handoff document for another agent or fresh session.
argument-hint: What should the next session focus on?
disable-model-invocation: true
---

Call the Skill tool separately: "agent-watchdog" for another run's claims; "plan-arbiter" for competing plans. Other hosts: [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Procedure

1. Use host temp (`$TMPDIR`, else `/tmp`; Windows `%TEMP%`), never workspace. Unix: `handoff_file=$(mktemp "${TMPDIR:-/tmp}/handoff-XXXXXX")`.
2. Preserve the endpoint via [continuation](../shared/progress-evidence.md#continuation). Arguments set next-step focus, not task or authority.
3. Link artifacts; redact sensitive data. Label uncertainty and replay-relevant omissions.
4. Return path plus 1-2 sentences. With no useful work, write a starter brief.

Explicit background-agent request: check `command -v claude`, then `claude --bg --name "<name>" "<summary>"` instead of a file. Include `/agent-watchdog`. Failure: return command/summary, not a launch claim.

## Template

```markdown
# Handoff
Contract: <original objective, requested endpoint/stops, reserved decisions>
State: <repo/worktree/branch, HEAD/base, dirty scope, PR/issue, gate receipts>
Decisions/artifacts: <links, evidence limits, replay packet/command>
Next: <focus, actions, open decisions, verification/delivery>
Suggested skills: <next skills and why>
```
