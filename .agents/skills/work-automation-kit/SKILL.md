---
name: work-automation-kit
description: Meta-skill that installs planning and project management workflow skills — PRD creation, implementation planning, issue breakdown, and bug triage. Use when setting up project planning workflows, creating PRDs, breaking work into issues, or bootstrapping project management automation.
---

# Work Automation Kit

## What This Sets Up

Installs community workflow skills for project planning and management:

1. **write-a-prd** — Create PRDs through interactive interview, codebase exploration, and module design
2. **prd-to-plan** — Convert PRDs into multi-phase implementation plans with vertical slices
3. **prd-to-issues** — Break PRDs into independently-grabbable GitHub Issues
4. **triage-issue** — Investigate bugs, identify root causes, and file GitHub Issues with TDD-based fix plans

## Steps

### 1. Install community workflow skills

```bash
bunx skills@latest add mattpocock/skills/write-a-prd -y
bunx skills@latest add mattpocock/skills/prd-to-plan -y
bunx skills@latest add mattpocock/skills/prd-to-issues -y
bunx skills@latest add mattpocock/skills/triage-issue -y
```

### 2. Verify

- [ ] `write-a-prd` skill is installed
- [ ] `prd-to-plan` skill is installed
- [ ] `prd-to-issues` skill is installed
- [ ] `triage-issue` skill is installed

### 3. Usage

- Start a new feature: `/write-a-prd` → `/prd-to-plan` → `/prd-to-issues`
- Investigate a bug: `/triage-issue`
