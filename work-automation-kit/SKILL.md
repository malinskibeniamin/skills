---
name: work-automation-kit
description: Install planning and project management skills — PRD creation, implementation planning, issue breakdown, bug triage, code review. Use when setting up project planning workflows or creating PRDs.
---

# Work Automation Kit

## What This Sets Up

### Owned workflow skills (hook-integrated)

4. **brainstorming** — Design exploration + challenge mode

### Community workflow skills

5. **write-a-prd** — Create PRDs through interactive interview
6. **prd-to-issues** — Break PRDs into GitHub Issues
7. **write-a-skill** — Create new agent skills
8. **github-triage** — Label-based issue management state machine, agent briefs, out-of-scope tracking

### Optional integrations

8. **setup-atlassian-workflow** — Jira integration via `acli` CLI. Opt-in: only activates if `acli` is installed.
9. **codex-plugin-cc** — Cross-model review via Codex inside Claude Code.

## Steps

### 1. Install owned workflow skills

```bash
bunx skills@latest add malinskibeniamin/skills/brainstorming --agent claude-code -y
```

### 2. Install community workflow skills

```bash
bunx skills@latest add mattpocock/skills/write-a-prd --agent claude-code -y
bunx skills@latest add mattpocock/skills/prd-to-issues --agent claude-code -y
bunx skills@latest add mattpocock/skills/github-triage --agent claude-code -y
bunx skills@latest add mattpocock/skills/write-a-skill --agent claude-code -y
```

### 3. Usage

- Explore designs: `/brainstorming`

### 4. Optional: Atlassian/Jira integration

If your team uses Jira, run `setup-atlassian-workflow` to add acli integration.
