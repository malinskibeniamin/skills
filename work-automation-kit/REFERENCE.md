# Work Automation Kit Reference

## Workflow Map

```
Feature idea
  → /to-prd (community) — interactive PRD creation
  → /development-lifecycle — plan phase
  → /domain-model — stress-test plan + update CONTEXT.md/ADRs (auto-invoked)
  → /to-issues (community) — break into GitHub/Jira issues
  → implement (use /tdd skill)
  → code review (development-lifecycle review phase)
  → merge

Bug report
  → /triage-issue — explore codebase, find root cause, TDD fix plan
  → implement fix (/tdd: failing test → fix → verify)
  → code review (development-lifecycle review phase)
  → merge

Issue management
  → /github-triage — triage via label state machine
  → /qa — interactive QA session → auto-file issues

Design decision
  → /brainstorming — explore approaches + challenge decisions
  → /development-lifecycle — plan the chosen approach
  → /domain-model — stress-test the plan + sharpen terminology (auto-invoked)
  → implement

Quick question (on a specific decision)
  → /domain-model — stress-test against domain model
  → /grill-me — lightweight stress-test (no DDD docs)
```

## Owned vs Community Skills

| Category | Owned | Community (mattpocock) |
|---|---|---|
| Testing | tdd | — |
| Debugging | triage-issue | — |
| Triage | github-triage, qa | — |
| Planning | development-lifecycle (plan phase) | to-prd, to-issues |
| Review | development-lifecycle (review phase) | — |
| Design | brainstorming, design-an-interface | — |
| Architecture | improve-codebase-architecture, request-refactor-plan | — |
| DDD | domain-model | ubiquitous-language |
| Meta | write-a-skill, grill-me, zoom-out | git-guardrails |

Owned skills ship with repo. "Community" skills install from mattpocock/skills.

## Optional Integrations

| Integration | Requires | What it adds |
|---|---|---|
| setup-atlassian-workflow | `acli` installed + authenticated | Jira work items alongside GitHub issues |
| codex-plugin-cc | OpenAI API key | `/codex:adversarial-review` for cross-model challenge |