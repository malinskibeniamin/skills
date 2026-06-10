# Plan NNN: <imperative title>

> **Executor instructions**: Follow step by step. Run every verification command. If any STOP condition occurs, stop and report; do not improvise. Update `plans/README.md` when done.
>
> **Drift check**: `git diff --stat <commit>..HEAD -- <in-scope files>`
> If listed files changed since planning, compare excerpts to live code. Mismatch is a STOP condition.

## Status

- Priority: P0|P1|P2|P3
- Effort: S|M|L
- Risk: LOW|MED|HIGH
- Depends on: none|Plan NNN
- Category: correctness|security|performance|test coverage|tech debt|dependencies|DX|docs|direction
- Planned at: commit `<short-sha>`, <date>

## Why this matters

Explain the concrete pain and why this plan is worth doing now.

## Current state

List exact files and line ranges. Include short excerpts read by the advisor, not copied from subagents.

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| Test | `<command>` | exit 0 |
| Lint/type | `<command>` | exit 0 |

## Scope

**In scope**:
- `<file>`

**Out of scope**:
- `<file or behavior>`

## Steps

### Step 1: <action>

Exact change. Mention tests first when applicable.

**Verify**: `<command>` → `<expected>`.

## Test plan

- New/updated tests and exact paths.
- Existing suites to run.

## Done criteria

- [ ] Commands pass with expected output.
- [ ] Tests cover regression/behavior.
- [ ] No files outside scope modified.
- [ ] `plans/README.md` status updated.

## STOP conditions

Stop if code drift invalidates excerpts, verification commands are unavailable, required change expands outside scope, or behavior differs from assumptions.

## Maintenance notes

Future review concerns and follow-up areas.
