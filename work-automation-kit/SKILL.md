---
name: work-automation-kit
description: Install planning/PM workflows: specs, ticket breakdown, tracker docs, triage.
disable-model-invocation: true
---

# Work Automation Kit

Installs workflow skills and scaffolds per-repo context:

- Issue tracker: GitHub, GitLab, local markdown, Jira/Atlassian, or other.
- Triage labels: project strings for canonical roles.
- Domain docs: `CONTEXT.md`, `CONTEXT-MAP.md`, ADR layout.

Prompt-driven. Explore -> present -> confirm -> write.

## Included workflows

Install the planning set once each: `grilling`, `domain-modeling`, `triage`,
`diagnosing-bugs`, `prototype`, `to-questionnaire`, `to-spec`, `to-tickets`, `handoff`,
`writing-for-agents`, `visual-plan`, `visual-recap`, `plan-arbiter`, `agent-watchdog`,
`read-the-damn-docs`, and `efficient-frontier`.

`setup-atlassian-workflow` is optional for Jira via `acli`.

## Install

```bash
for skill in \
  grilling domain-modeling triage diagnosing-bugs prototype to-questionnaire to-spec \
  to-tickets handoff writing-for-agents visual-plan visual-recap plan-arbiter \
  agent-watchdog read-the-damn-docs efficient-frontier
do
  bunx skills@latest add "malinskibeniamin/skills/$skill" --agent claude-code -y
done
```

## Optional: Atlassian/Jira
Run `setup-atlassian-workflow` if team use Jira.

## Project Context Setup

See `REFERENCE.md` for details.

1. Explore `git remote -v`, agent docs, existing `docs/agents/`, context docs, ADRs, whether `triage` is installed, and monorepo signals (`pnpm-workspace.yaml`, package workspaces, or populated `packages/*/src`).
2. Present the recommended tracker first; ask only when the choice genuinely branches.
3. If `triage` is installed, ask one question: "Keep the default triage labels?" (recommended: **yes**). On yes, use the five canonical role names. Only if the user says no, collect overrides. Without `triage`, skip label setup.
4. Without monorepo signals, choose **single-context without asking**. Offer **multi-context only for a monorepo**, then confirm the layout.
5. Confirm draft docs before writing. Reuse `templates/`.
6. Choose the agent-instructions file deterministically: edit `CLAUDE.md` first when it exists, otherwise edit `AGENTS.md`; if neither exists, ask which one to create. Update only the selected file, then write approved docs:
   - `docs/agents/issue-tracker.md` with `## Wayfinding operations` when `/wayfinder` is installed
   - `docs/agents/triage-labels.md` only when `triage` is installed
   - `docs/agents/domain.md`
   - `## Agent skills` block in the selected agent-instructions file; it must contain `### Issue tracker` with a one-line summary and link to `docs/agents/issue-tracker.md`, plus conditional triage-label and domain-doc pointers
7. Verify `### Issue tracker` exists in the agent-instructions block and links the selected tracker document; also verify any required labels, Wayfinding operations, and domain layout.
