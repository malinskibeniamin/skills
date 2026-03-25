---
name: work-automation-kit
description: Meta-skill that installs planning and project management workflow skills — PRD creation, implementation planning, issue breakdown, and bug triage. Use when setting up project planning workflows, creating PRDs, breaking work into issues, or bootstrapping project management automation.
---

# Work Automation Kit

## What This Sets Up

Installs community workflow skills for project planning, management, and skill authoring:

1. **write-a-prd** — Create PRDs through interactive interview, codebase exploration, and module design
2. **prd-to-plan** — Convert PRDs into multi-phase implementation plans with vertical slices
3. **prd-to-issues** — Break PRDs into independently-grabbable GitHub Issues
4. **triage-issue** — Investigate bugs, identify root causes, and file GitHub Issues with TDD-based fix plans
5. **write-a-skill** — Create new agent skills with proper structure, progressive disclosure, and bundled resources

## Steps

### 1. Install community workflow skills

```bash
bunx skills@latest add mattpocock/skills/write-a-prd
bunx skills@latest add mattpocock/skills/prd-to-plan
bunx skills@latest add mattpocock/skills/prd-to-issues
bunx skills@latest add mattpocock/skills/triage-issue
bunx skills@latest add mattpocock/skills/write-a-skill
```

Let the user choose the installation scope for each skill interactively — do not pass `-y`.

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
