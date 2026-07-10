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

## Skills Installed

**Owned** (hook-integrated): grilling (incl. explore mode), domain-modeling, triage, diagnosing-bugs

**Matt Pocock/community**: grilling, prototype, to-spec, to-tickets, handoff, writing-great-skills

**Builder helpers**: visual-plan, visual-recap, plan-arbiter, agent-watchdog, read-the-damn-docs, efficient-frontier

**Optional**: setup-atlassian-workflow (Jira via acli, opt-in)

## Install

```bash
# Owned

# Owned
bunx skills@latest add malinskibeniamin/skills/grilling --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/domain-modeling --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/triage --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/diagnosing-bugs --agent claude-code -y

# Community
bunx skills@latest add malinskibeniamin/skills/writing-great-skills --agent claude-code -y
```

## Optional: Atlassian/Jira
Run `setup-atlassian-workflow` if team use Jira.

## Project Context Setup

See `REFERENCE.md` for details.

1. Explore `git remote -v`, agent docs, existing `docs/agents/`, context docs, and ADRs.
2. Ask tracker, triage-label, and domain-doc decisions one at a time.
3. Confirm draft docs before writing. Reuse `templates/`.
4. Write approved docs only:
   - `docs/agents/issue-tracker.md` with `## Wayfinding operations` when `/wayfinder` is installed
   - `docs/agents/triage-labels.md`
   - `docs/agents/domain.md`
   - `## Agent skills` block for `AGENTS.md` or `CLAUDE.md`
5. Verify tracker, labels, Wayfinding operations, and domain layout are present.
