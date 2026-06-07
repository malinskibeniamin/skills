---
name: review
description: Reviews diff since fixed point across Standards and Spec, then routes UI/resilience/release risks. Use for branch, PR, WIP, or "review since X".
---

# Review

Diff review from fixed point to `HEAD`. Keep axes separate.

## Inputs

If fixed point missing, ask: "Review against what -- branch, commit, or `main`?"

Use:

- Diff: `git diff <fixed>...HEAD`
- Commits: `git log <fixed>..HEAD --oneline`

## Gather

Spec source, first found wins:

1. issue refs in commits, fetched via `docs/agents/issue-tracker.md`
2. user-provided path
3. PRD/spec under `docs/`, `specs/`, `.scratch/`
4. none -> Spec axis reports "no spec available"

Standards sources:

- `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`
- `CONTEXT.md`, `CONTEXT-MAP.md`, scoped `CONTEXT.md`
- `docs/adr/`
- style docs and config files (`biome`, `eslint`, `tsconfig`, `prettier`, `.editorconfig`)

## Parallel axes

Spawn two `general-purpose` subagents in one message when available.

### Standards

Read standards + diff. Report documented violations only. Cite file + rule. Separate hard violations from judgment calls. Skip what tooling enforces. Max 400 words.

### Spec

Read spec + diff. Report missing/partial requirements, scope creep, wrong behavior. Quote spec line for each finding. Max 400 words. Skip if no spec.

## Local review routing

After axes, decide if extra local review is needed:

- UI, copy, forms, routes, reports, CLI/TUI output, visual behavior -> run `/visual-review` or require explicit skip reason.
- forms, validation, async/data, mutations, cache, state machines, config, destructive actions, error/loading/empty states -> run `/resilience-review` or require explicit skip reason.
- release candidate, large PR, risky refactor, security/privacy/perf/test concerns, or user asks for nuclear/cold audit -> run `/thermo-nuclear-code-quality-review`.

Do not duplicate those reports. Link or summarize their verdicts.

## Output

```md
## Review
Fixed point: <fixed>
Diff: `git diff <fixed>...HEAD`

## Standards
<findings or pass>

## Spec
<findings, pass, or no spec available>

## Local review gates
- Visual review: pass | findings | skipped: <reason>
- Resilience review: pass | findings | skipped: <reason>
- Thermo nuclear review: pass | findings | skipped: <reason>

Summary: <standards count>, <spec count>, worst issue: <one line or none>
```

Rules: keep Standards and Spec separate. Findings need evidence. No vague praise.
