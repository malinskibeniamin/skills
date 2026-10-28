---
description: "Compact the current session into a handoff document for another agent or fresh session."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["handoff"]}
sidebar: {"label":"/handoff"}
title: "/handoff"
type: "skill"
---
![Diagram of the /handoff skill](/diagrams/skills/handoff.svg)

[Open the editable Excalidraw source](/diagrams/skills/handoff.excalidraw)


Call the Skill tool separately: "agent-watchdog" for another run's claims; "plan-arbiter" for competing plans. Other hosts: [dependency loading](https://github.com/malinskibeniamin/skills/blob/v4.41.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Procedure

1. Use host temp (`$TMPDIR`, else `/tmp`; Windows `%TEMP%`), never workspace. Unix: `handoff_file=$(mktemp "${TMPDIR:-/tmp}/handoff-XXXXXX")`.
2. Keep the endpoint via [continuation](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/progress-evidence.md#continuation). Arguments set focus, not task or authority.
3. Do not duplicate artifacts; link them. Redact sensitive data. Label uncertainty and replay omissions.
4. Return path and 1-2 sentences. No useful work: write a starter brief.

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
