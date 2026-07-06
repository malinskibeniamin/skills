# Work Automation Kit Reference

## Workflow Map

```
Feature idea
  -> /to-spec (community) -- interactive spec creation
  -> /development-lifecycle -- plan phase
  -> /grill-with-docs -- stress-test plan + update CONTEXT.md/ADRs
  -> /to-tickets (community) -- break into GitHub/Jira tickets
  -> implement (use /tdd skill)
  -> code review (development-lifecycle review phase)
  -> merge

Bug report
  -> /diagnosing-bugs -- feedback-loop-first, 6-phase debugging
  -> /triage -- explore codebase, find root cause, TDD fix plan, file ticket
  -> implement fix (/tdd: failing test -> fix -> verify)
  -> code review (development-lifecycle review phase)
  -> merge

Issue management
  -> /triage -- triage via state machine (GitHub via gh, Jira via acli)
  -> /triage -- interactive intake -> auto-file issues

Design decision
  -> /brainstorming -- explore approaches + challenge decisions
  -> /development-lifecycle -- plan the chosen approach
  -> /grill-with-docs -- stress-test the plan + sharpen terminology
  -> implement

Quick question (on a specific decision)
  -> /domain-modeling -- stress-test terms against domain model
  -> /grill-me -- lightweight stress-test (no DDD docs)
```

## Owned vs Community Skills

| Category | Owned | Community (mattpocock) |
|---|---|---|
| Testing | tdd | -- |
| Debugging | diagnosing-bugs | -- |
| Triage | triage | -- |
| Planning | development-lifecycle (plan phase) | to-spec, to-tickets |
| Review | development-lifecycle (review phase) | -- |
| Design | brainstorming, prototype | -- |
| Architecture | improve-codebase-architecture | -- |
| DDD | grill-with-docs, domain-modeling | -- |
| Meta | writing-great-skills, grill-me, ask-ben | git-guardrails |

Owned skills ship with repo. "Community" skills install from mattpocock/skills.

## Optional Integrations

| Integration | Requires | What it adds |
|---|---|---|
| setup-atlassian-workflow | `acli` installed + authenticated | Jira work items alongside GitHub issues |
| codex-plugin-cc | OpenAI API key | `/codex:adversarial-review` for cross-model challenge |