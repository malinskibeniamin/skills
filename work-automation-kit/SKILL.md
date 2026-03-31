---
name: work-automation-kit
description: Install planning and project management skills — PRD creation, implementation planning, issue breakdown, bug triage. Use when setting up project planning workflows or creating PRDs.
---

# Work Automation Kit

## What This Sets Up

Installs community workflow skills for project planning, management, and skill authoring:

1. **write-a-prd** — Create PRDs through interactive interview, codebase exploration, and module design
2. **prd-to-plan** — Convert PRDs into multi-phase implementation plans with vertical slices
3. **prd-to-issues** — Break PRDs into independently-grabbable GitHub Issues
4. **triage-issue** — Investigate bugs, identify root causes, and file GitHub Issues with TDD-based fix plans
5. **write-a-skill** — Create new agent skills with proper structure, progressive disclosure, and bundled resources

### Optional integrations

6. **setup-atlassian-workflow** — Jira integration via `acli` CLI. Mirrors gh-based workflow skills for Jira users. Opt-in: only activates if `acli` is installed and authenticated. Works alongside `gh` (set `ISSUE_TRACKER=both`) or standalone (`ISSUE_TRACKER=acli`).
7. **codex-plugin-cc** — Cross-model review via Codex inside Claude Code. `/codex:review` for second-opinion reviews, `/codex:adversarial-review` for design challenge. Requires ChatGPT subscription or OpenAI API key.

## Steps

### 1. Install community workflow skills

```bash
bunx skills@latest add mattpocock/skills/write-a-prd --agent claude-code -y
bunx skills@latest add mattpocock/skills/prd-to-plan --agent claude-code -y
bunx skills@latest add mattpocock/skills/prd-to-issues --agent claude-code -y
bunx skills@latest add mattpocock/skills/triage-issue --agent claude-code -y
bunx skills@latest add mattpocock/skills/write-a-skill --agent claude-code -y
```

### 2. Verify

- [ ] `write-a-prd` skill is installed
- [ ] `prd-to-plan` skill is installed
- [ ] `prd-to-issues` skill is installed
- [ ] `triage-issue` skill is installed
- [ ] `write-a-skill` skill is installed

### 3. Usage

- Start a new feature: `/write-a-prd` → `/prd-to-plan` → `/prd-to-issues`
- Investigate a bug: `/triage-issue`
- Create a new skill: `/write-a-skill`

### 4. Optional: Atlassian/Jira integration

If your team uses Jira, run `setup-atlassian-workflow` to add acli integration. This makes all workflow skills (PRD→issues, triage, QA) work with Jira in addition to or instead of GitHub Issues.
