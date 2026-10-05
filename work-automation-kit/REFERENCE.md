# Work Automation Kit Reference

## Workflow Map

```
Feature idea
  -> /to-spec -- interactive spec creation
  -> /development-lifecycle -- plan phase
  -> /grilling -- stress-test plan + update GLOSSARY.md/ADRs
  -> /to-tickets -- break into GitHub/Jira tickets
  -> /development-lifecycle with /tdd -- implement a ticket
     or /implement-spec -- integrate the spec (delegation only when requested)
  -> /review -> /pr -- review and write the PR body
  -> merge only when explicitly authorized
  -> /retro (optional) -- improve the feedback loop from session evidence

Bug report
  -> /diagnosing-bugs -- feedback-loop-first, 6-phase debugging
  -> /triage -- explore codebase, find root cause, TDD fix plan, file ticket
  -> implement fix (/tdd: failing test -> fix -> verify)
  -> code review (development-lifecycle review phase)
  -> merge only when explicitly authorized

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

## Local workflow skills

| Category | Skills |
|---|---|
| Testing | tdd |
| Debugging | diagnosing-bugs |
| Triage | triage |
| Planning | development-lifecycle, to-spec, to-tickets, to-questionnaire |
| Implementation | development-lifecycle, implement-spec |
| Review and delivery | review, pr |
| Design | grilling, prototype, codebase-design |
| Architecture | improve (architecture mode) |
| Domain model | domain-modeling |
| Session improvement | retro |
| Meta | writing-for-agents, ask-ben |

These skills ship with this repo, including local adaptations of Matt Pocock's skills. Install the local versions; keep their harness and delegation guardrails.

## Project Context Setup Protocol

### Explore

Read existing state. Do not assume.

- `git remote -v`, `.git/config`
- `AGENTS.md`, `CLAUDE.md`; existing `## Agent skills`
- `GLOSSARY.md`, `GLOSSARY-MAP.md`, `docs/adr/`, nested ADR dirs
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

**External request triage:** the GitHub/GitLab templates default this off; do not ask another setup question. Users can opt in later by editing the flag.

**Domain docs:** glossary + ADRs feed tdd/diagnosing-bugs/triage/architecture. Without monorepo signals, select single-context without asking. Offer multi-context only for a monorepo, then confirm the choice.

Choose:

- Single context: root `GLOSSARY.md` + `docs/adr/`
- Multi-context: root `GLOSSARY-MAP.md` points to per-context docs

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
