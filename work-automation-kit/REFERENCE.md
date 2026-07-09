# Work Automation Kit Reference

## Workflow Map

```
Feature idea
  -> /to-spec (community) -- interactive spec creation
  -> /development-lifecycle -- plan phase
  -> /grilling -- stress-test plan + update CONTEXT.md/ADRs
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
  -> /grilling explore mode -- explore approaches + challenge decisions
  -> /development-lifecycle -- plan the chosen approach
  -> /grilling -- stress-test the plan + sharpen terminology
  -> implement

Quick question (on a specific decision)
  -> /domain-modeling -- stress-test terms against domain model
  -> /grilling -- lightweight stress-test (no DDD docs)
```

## Owned vs Community Skills

| Category | Owned | Community (mattpocock) |
|---|---|---|
| Testing | tdd | -- |
| Debugging | diagnosing-bugs | -- |
| Triage | triage | -- |
| Planning | development-lifecycle (plan phase) | to-spec, to-tickets |
| Review | development-lifecycle (review phase) | -- |
| Design | grilling (explore mode), prototype | -- |
| Architecture | improve-codebase-architecture | -- |
| DDD | grilling, domain-modeling | -- |
| Meta | writing-great-skills, grilling, ask-ben | -- |

Owned skills ship with repo. "Community" skills install from mattpocock/skills.

## Project Context Setup Protocol

### Explore

Read existing state. Do not assume.

- `git remote -v`, `.git/config`
- `AGENTS.md`, `CLAUDE.md`; existing `## Agent skills`
- `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, nested ADR dirs
- `docs/agents/`
- `.scratch/`

### Ask decisions one at time

**Issue tracker:** explain where issues live; skills need write/read workflow.

Default from remote. Choices:

- GitHub: `gh issue`
- GitLab: `glab issue`
- Local markdown: `.scratch/<feature>/`
- Jira/Atlassian: run `/setup-atlassian-workflow`
- Other: user describes workflow; record prose

**Triage labels:** map canonical roles to actual labels/statuses:

- `needs-triage`
- `needs-info`
- `ready-for-agent`
- `ready-for-human`
- `wontfix`

Avoid duplicate vocabulary if repo already has names.

**Domain docs:** explain glossary + ADRs feed tdd/diagnosing-bugs/triage/architecture.

Choose:

- Single context: root `CONTEXT.md` + `docs/adr/`
- Multi-context: root `CONTEXT-MAP.md` points to per-context docs

### Confirm and write

Show draft edits before writing. Reuse templates from `templates/`:

- `docs/agents/issue-tracker.md` with `## Wayfinding operations` when `/wayfinder` is installed
- `docs/agents/triage-labels.md`
- `docs/agents/domain.md`
- `## Agent skills` block for `AGENTS.md` or `CLAUDE.md`

Write only approved files. Preserve existing docs. If block exists, update in place.

### Verify

Confirm files exist and mention selected tracker, Wayfinding operations, labels, domain layout. Tell user which skills now have context.

## Optional Integrations

| Integration | Requires | What it adds |
|---|---|---|
| setup-atlassian-workflow | `acli` installed + authenticated | Jira work items alongside GitHub issues |
