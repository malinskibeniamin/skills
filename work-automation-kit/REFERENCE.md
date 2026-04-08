# Work Automation Kit Reference

## Workflow Map

```
Feature idea
  → /write-a-prd (community) — interactive PRD creation
  → /development-lifecycle — plan phase
  → /prd-to-issues (community) — break into GitHub/Jira issues
  → implement (use /tdd skill)
  → code review (development-lifecycle review phase)
  → merge

Bug report
  → /triage-issue — explore codebase, find root cause, TDD fix plan
  → implement fix (/tdd: failing test → fix → verify)
  → code review (development-lifecycle review phase)
  → merge

Design decision
  → /brainstorming — explore approaches + challenge decisions
  → /development-lifecycle — plan the chosen approach
  → implement

Quick question
  → /grill-me — stress-test the decision
```

## Owned vs Community Skills

| Category | Owned | Community (mattpocock) |
|---|---|---|
| Testing | tdd | — |
| Debugging | triage-issue | — |
| Planning | development-lifecycle (plan phase) | write-a-prd, prd-to-issues |
| Review | development-lifecycle (review phase) | — |
| Design | brainstorming, design-an-interface | — |
| Architecture | improve-codebase-architecture, request-refactor-plan | — |
| Meta | write-a-skill, grill-me | ubiquitous-language, qa, git-guardrails |

Owned skills ship with this repo. Skills marked "community" are installed from mattpocock/skills.

## Optional Integrations

| Integration | Requires | What it adds |
|---|---|---|
| setup-atlassian-workflow | `acli` installed + authenticated | Jira work items alongside GitHub issues |
| codex-plugin-cc | OpenAI API key | `/codex:adversarial-review` for cross-model challenge |
