---
name: dogfood
description: Use after each material behavior slice and before handoff or shipping to exercise runnable work at its real entrypoint.
---

For behavior/verifier checks, read [Poteto](../shared/POTETO-NATIVE.md#verification).

Dogfood each material runnable slice and final PR at public seams. Tests are not dogfood.

## Inventory

1. Resolve base with
   `BASE=$(PR_BASE_REF="${DOGFOOD_BASE_REF:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`.
2. Inspect full PR: merge-base through committed, staged, unstaged and untracked work.
3. Cover changed branches at real entrypoints, including skill resources/scripts and hook events.
   Standalone docs/tests/evals need no experiential coverage.

## Loop

Run use -> abuse -> repair -> replay.

### Use

Exercise intended paths; inspect output, transitions, effects, console, network and logs.

Use representative live-scale data (production-like shape/cardinality); compare expected/observed
counts, ordering, timing, state and effects; expose accumulation.

For bugs, replay the reporter's exact steps unfixed. If you cannot reproduce it,
request missing environment or evidence before diagnosis.

### Abuse

Try one credible break:

- Careless: empty, invalid, oversized, duplicate, or reordered input.
- Impatient: repeat, double-submit, reload, navigate away, cancel, or interrupt.
- Unlucky: stale or missing data, slow or failed dependency, partial completion.
- Live data: sparse fields, duplicate IDs, mixed versions or tenants, long text, Unicode,
  timezone boundaries, realistic cardinality.
- Performance: measure response time, network, render, CPU, and memory against a baseline or budget.

Observe failure and recovery.

UI content/layout risks: Call the Skill tool with "break-ui". Reuse schema-valid fixtures
and evidence in replay/receipt; test only uncovered cases. Keep invalid-input validation separate.

### Repair

Defects fail. When automatable, add a RED public-contract test,
fix via `/tdd`, and rerun focused checks. Edits invalidate evidence.

### Replay

Repeat intended use and every break attempt at the real entrypoint. Replay identical bug
steps and adjacent behavior. Use [replay packets](../shared/verification-replay.md) for
stateful bugs/repro gaps. PASS binds to current runnable state.

## Entrypoints

| Change | Exercise |
|---|---|
| Web/UI | Run, navigate, act, reload, inspect console/network |
| CLI/TUI | Invoke realistic, invalid, and interrupted flows |
| API/worker | Send real requests/events; inspect response and side effects |
| Library | Call the public API from a minimal consumer |
| Hook/automation | Trigger the actual event with representative fixtures |
| Skill/agent | Use on a fresh realistic task and inspect behavior |
| Demo/prototype | Operate until the question has observed evidence |

Fresh agents require explicit delegation.

Use project-local `verify-*` doctor, drive, evidence and cleanup when available.
T3 Code checkout UI only: resolve [native context](../shared/T3CODE-NATIVE.md#resolve-context), then load [web/desktop](../t3code-skills/test-t3-app/SKILL.md) or
[native mobile](../t3code-skills/test-t3-mobile/SKILL.md). Missing Browser/Device: BLOCKED;
do not install or switch harnesses.
Verifier drift: `/maintain-verification-skill`; recurring gaps: `/create-verification-skill` after proof.

React: [runtime probes](../shared/react-devtools.md).

## Browser and data tasks

Read [browser defaults](../shared/verification-replay.md#browser-and-data-tasks).

## Receipt

`Verdict: PASS | FAIL | BLOCKED`; entrypoint/actions/observations:

- **Entrypoint:** exact command/URL/event/consumer.
- **Actions:** journey and break attempts.
- **Observations:** data, outputs, state, effects, console/network/logs, timing.
- **Repairs:** defects, RED tests, fixes, replay result.
- **Limits:** untried behavior and reason.

PASS: direct evidence per behavior; FAIL: observed defect; BLOCKED: missing access,
environment, hardware or safety condition.
