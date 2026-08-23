---
title: "/handoff"
description: "Compact the current session into a handoff document for another agent or fresh session."
type: skill
sidebar:
  label: "/handoff"
---
![Diagram of the /handoff skill](/diagrams/skills/handoff.svg)

[Open the editable Excalidraw source](/diagrams/skills/handoff.excalidraw)

If the handoff is for auditing another agent's run, route to `/agent-watchdog`. If it hands off competing plans, include `/plan-arbiter` as the next skill.
Create a concise handoff document for another agent/session to continue from here.

## When to Use

Use when the user wants to:
- continue work in a fresh session
- hand work to another agent
- run a prototype or parallel line of work elsewhere
- preserve actionable context without carrying the whole transcript

## Procedure

1. Create a temp file:
   ```bash
   handoff_file=$(mktemp -t handoff-XXXXXX.md)
   ```
2. Write the handoff to that path.
3. Keep it compact. Do not duplicate artifacts already captured in specs, plans, ADRs, issues, commits, diffs, or docs. Reference them by path or URL.
4. If the user provided arguments, treat them as the next session focus and tailor the handoff around that work.
5. Redact sensitive information: API keys, passwords, tokens, secrets, personal data, customer data, and any other confidential values. Mention redaction only when it affects continuation.
6. Suggest skills the next session should use, if any.
7. Return only the handoff path plus a 1-2 sentence summary.
8. **Background-agent mode** -- user wants a fresh agent to pick the work up immediately:
   instead of saving the file, launch `claude --bg --name "<descriptive name>" "<handoff summary>"`
   (check `command -v claude` first; if unavailable or launch fails, do not claim an agent
   started -- print the exact command plus the summary so the user can run it). Always pass
   a descriptive `--name`; include `/agent-watchdog` in suggested skills when the next
   session must verify this agent's claims.

## Handoff Template

```markdown
# Handoff

## Next session focus
<What the next agent/session should do first.>

## Current state
<Only facts needed to resume. Include branch, cwd, PR/issue links if relevant.>

## Decisions made
<Bullets. Link to ADRs/plans/issues instead of restating them.>

## Open questions
<Bullets, or "None".>

## Next actions
1. <First concrete action>
2. <Second concrete action>
3. <Verification or shipping step>

## Relevant artifacts
- <path or URL>: <why it matters>

## Suggested skills
- </skill-name>: <why>
```

## Guardrails

- Do not use handoff as a hidden summary of everything. Include only continuation context.
- Prefer paths and URLs over pasted content.
- Redact secrets and personal data.
- Call out uncertainty explicitly.
- If no useful work has happened yet, say so and write a short starter brief.
