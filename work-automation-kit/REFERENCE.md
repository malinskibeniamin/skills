# Work Automation Kit Reference

## Workflow Map

```
Feature idea
  → /write-a-prd (community) — interactive PRD creation
  → /writing-plans (owned) — detailed implementation plan
  → /prd-to-issues (community) — break into GitHub/Jira issues
  → implement (use test-driven-development skill)
  → /requesting-code-review (owned) — two-stage review
  → merge

Bug report
  → /systematic-debugging (owned) — 4-phase root cause analysis
  → implement fix (TDD: failing test → fix → verify)
  → /requesting-code-review (owned)
  → merge

Design decision
  → /brainstorming (owned) — explore approaches + challenge decisions
  → /writing-plans (owned) — plan the chosen approach
  → implement

Quick question
  → /grill-me (community) — stress-test the decision
```

## Owned vs Community Skills

| Category | Owned (hook-integrated) | Community (mattpocock) |
|---|---|---|
| Testing | test-driven-development | — |
| Debugging | systematic-debugging | — |
| Planning | writing-plans | write-a-prd, prd-to-issues |
| Review | requesting-code-review | — |
| Design | brainstorming | grill-me, design-an-interface |
| Architecture | — | improve-codebase-architecture, request-refactor-plan |
| Meta | — | write-a-skill, ubiquitous-language, qa, git-guardrails |

Owned skills integrate with hooks (intent-detect, orchestration-guidance, orchestration-stop). Community skills are standalone — no hook integration.

## Optional Integrations

| Integration | Requires | What it adds |
|---|---|---|
| setup-atlassian-workflow | `acli` installed + authenticated | Jira work items alongside GitHub issues |
| codex-plugin-cc | OpenAI API key | `/codex:adversarial-review` for cross-model challenge |
