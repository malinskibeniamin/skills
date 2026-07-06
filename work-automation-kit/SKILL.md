---
name: work-automation-kit
description: Install planning/project management skills -- spec creation, implementation planning, ticket breakdown, bug triage, code review. Use when setup project planning workflows or creating specs.
---

# Work Automation Kit

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
## Skills Installed

**Owned** (hook-integrated): brainstorming, grill-with-docs, domain-modeling, triage, diagnosing-bugs, qa

**Matt Pocock/community**: grill-with-docs, prototype, to-spec, to-tickets, handoff, writing-great-skills

**Builder helpers**: visual-plan, visual-recap, plan-arbiter, agent-watchdog, read-the-damn-docs, quick-recap, stay-within-limits, efficient-frontier

**Optional**: setup-atlassian-workflow (Jira via acli, opt-in), codex-plugin-cc (cross-model review)

## Install

```bash
# Owned
bunx skills@latest add malinskibeniamin/skills/brainstorming --agent claude-code -y

# Owned
bunx skills@latest add malinskibeniamin/skills/grill-with-docs --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/domain-modeling --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/triage --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/diagnosing-bugs --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/qa --agent claude-code -y

# Community
bunx skills@latest add malinskibeniamin/skills/writing-great-skills --agent claude-code -y
```

## Optional: Atlassian/Jira
Run `setup-atlassian-workflow` if team use Jira.
