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
| Architecture | improve (architecture mode) | -- |
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
- Whether `triage` is installed, either as an available skill or a sibling skill folder
- Monorepo signals: `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or populated `packages/*/src`

### Ask only branching decisions

**Issue tracker:** explain where issues live; skills need write/read workflow.

Default from remote. Choices:

- GitHub: `gh issue`
- GitLab: `glab issue`
- Local markdown: `.scratch/<feature>/`
- Jira/Atlassian: run `/setup-atlassian-workflow`
- Other: user describes workflow; record prose

**Triage labels:** skip this section when `triage` is not installed. Otherwise ask one question: "Keep the default triage labels?" (recommended: **yes**). On yes, use these canonical roles as their own label strings:

- `needs-triage`
- `needs-info`
- `ready-for-agent`
- `ready-for-human`
- `wontfix`

Only if the user says no, collect overrides so existing project labels are reused instead of duplicated.

**Domain docs:** glossary + ADRs feed tdd/diagnosing-bugs/triage/architecture. Without monorepo signals, select single-context without asking. Offer multi-context only for a monorepo, then confirm the choice.

Choose:

- Single context: root `CONTEXT.md` + `docs/adr/`
- Multi-context: root `CONTEXT-MAP.md` points to per-context docs

### Confirm and write

Show draft edits before writing. Reuse templates from `templates/`:

Choose the agent-instructions file deterministically: edit `CLAUDE.md` first when it exists, otherwise edit `AGENTS.md`; if neither exists, ask which one to create. Update only the selected file. If its `## Agent skills` block already exists, update it in place without changing surrounding content.

- `docs/agents/issue-tracker.md` with `## Wayfinding operations` when `/wayfinder` is installed
- `docs/agents/triage-labels.md` only when `triage` is installed
- `docs/agents/domain.md`
- `## Agent skills` block for `AGENTS.md` or `CLAUDE.md`

The block must expose the pointers consumers resolve. Use this shape, omitting **Triage labels** when `triage` is not installed:

```markdown
## Agent skills

### Issue tracker

[one-line summary]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary]. See `docs/agents/triage-labels.md`.

### Domain docs

[single-context or multi-context summary]. See `docs/agents/domain.md`.
```

Write only approved files. Preserve existing docs. If block exists, update in place.

### Verify

Confirm `### Issue tracker` exists in the agent-instructions block and links the selected tracker document. Also confirm Wayfinding operations, any required labels, and domain layout. Tell user which skills now have context.

## Optional Integrations

| Integration | Requires | What it adds |
|---|---|---|
| setup-atlassian-workflow | `acli` installed + authenticated | Jira work items alongside GitHub issues |
