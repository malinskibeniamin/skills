---
name: work-automation-kit
description: Install planning and project management skills — PRD creation, implementation planning, issue breakdown, bug triage, code review. Use when setting up project planning workflows or creating PRDs.
---

# Work Automation Kit

## Skills Installed

**Owned** (hook-integrated): brainstorming

**Community**: write-a-prd, prd-to-issues, write-a-skill, github-triage

**Optional**: setup-atlassian-workflow (Jira via acli, opt-in), codex-plugin-cc (cross-model review)

## Install

```bash
# Owned
bunx skills@latest add malinskibeniamin/skills/brainstorming --agent claude-code -y

# Community
bunx skills@latest add mattpocock/skills/write-a-prd --agent claude-code -y
bunx skills@latest add mattpocock/skills/prd-to-issues --agent claude-code -y
bunx skills@latest add mattpocock/skills/github-triage --agent claude-code -y
bunx skills@latest add mattpocock/skills/write-a-skill --agent claude-code -y
```

## Optional: Atlassian/Jira
Run `setup-atlassian-workflow` if team uses Jira.
