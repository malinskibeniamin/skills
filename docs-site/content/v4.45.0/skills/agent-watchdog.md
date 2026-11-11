---
description: "Audit another agent against the original request and live evidence. Use for sessions, PRs, branches, comparisons, authorized fixes, or taking over stuck work."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["agent watchdog"]}
sidebar: {"label":"/agent-watchdog"}
title: "/agent-watchdog"
type: "skill"
---
![Diagram of the /agent-watchdog skill](/diagrams/skills/agent-watchdog.svg)

[Open the editable Excalidraw source](/diagrams/skills/agent-watchdog.excalidraw)


Read [audit protocol](https://github.com/malinskibeniamin/skills/blob/v4.45.0/agent-watchdog/references/audit.md) before audits; read
`references/builder-upstream.md` for complex/ambiguous audits.
Use authorized sources and live host tools. Investigate inline; extra agents,
monitoring, production access, and writes need separate authorization.

## Modes

- **Watch:** monitor session/PR/branch/CI/transcript to terminal; no edits.
- **Audit:** compare request, evidence, diff, tests, CI, comments and claims; no edits.
- **Audit and fix:** audit, then narrow authorized fixes.
- **Compare:** judge agents/sessions against one request.
- **Takeover:** explicit request to own stuck work; follow [takeover](https://github.com/malinskibeniamin/skills/blob/v4.45.0/agent-watchdog/references/takeover.md) through the requested endpoint, not just the previous approach.

Default audit-only when edit authority is unclear.

## Workflow

Takeover uses its reference; otherwise:

1. Resolve target and original ask/constraints; form your own hypotheses first.
2. Inspect primary evidence; compare the agent's diff, checks and claims.
3. Mark prior exposure; inline investigation is not an independent reviewer or model-family pass.
4. Classify `Gap|Bug|Verification miss|Scope drift|No issue`.
5. Fix only authorized gaps; never revert unrelated work or move branches unasked.
6. Report exact evidence, actionable differences, risks and next action; follow the audit protocol for relay, completed worktrees and output.
