---
name: dogfood
description: Use after each material behavior slice and before handoff or shipping to exercise runnable work at its real entrypoint.
---

# Dogfood

A material runnable slice changes a real entrypoint or public seam.
Dogfood each slice and final PR. Tests are not dogfood.

## Inventory

1. Resolve the comparison base with
   `BASE=$(PR_BASE_REF="${DOGFOOD_BASE_REF:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`.
2. Inspect the full PR: merge-base through committed, staged, unstaged, and untracked work.
3. Map behavior to its real entrypoint, including skill references/assets/scripts and actual
   hook events. Standalone docs, tests, and evals need no experiential coverage.

Cover this turn locally; every runnable branch behavior before PR or shipping.

## Loop

Run **use -> abuse -> repair -> replay** on the current implementation.

### Use

Perform intended journeys through the implementation; inspect output, state transitions,
side effects, console, network, and logs directly.

Use representative live-scale data: production-like shape/cardinality. Compare expected
and observed counts, ordering, timing, state, side effects; run to expose accumulation.

For bugs, replay the reporter's exact steps unfixed. If you cannot reproduce it,
request missing environment or evidence before diagnosis.

### Abuse

Apply relevant lenses and one plausible break attempt:

- Careless: empty, invalid, oversized, duplicate, or reordered input.
- Impatient: repeat, double-submit, reload, navigate away, cancel, or interrupt.
- Unlucky: stale or missing data, slow or failed dependency, partial completion.
- Live data: sparse fields, duplicate IDs, mixed versions or tenants, long text, Unicode,
  timezone boundaries, realistic cardinality.
- Performance: measure response time, network, render, CPU, and memory against a baseline or budget.

Prefer credible user behavior; observe failure and recovery.

UI content/layout risks: Call the Skill tool with "break-ui". Reuse schema-valid fixtures
and evidence in replay/receipt; test only uncovered cases. Keep invalid-input validation separate.

### Repair

An observed defect fails the checkpoint. When automatable, add a RED public-contract test,
fix through `/tdd`, and rerun focused checks. Behavior edits invalidate evidence.

### Replay

Restart at the real entrypoint; repeat intended use and every break attempt. For bugs,
replay identical original steps and adjacent behavior. For stateful bugs or recurring repro gaps,
use [replay packets](../shared/verification-replay.md). PASS binds to the current runnable state.

## Entrypoints

| Change | Exercise |
|---|---|
| Web/UI | Run, navigate, act, reload, inspect console/network |
| CLI/TUI | Invoke realistic, invalid, and interrupted flows |
| API/worker | Send real requests/events; inspect response and side effects |
| Library | Call the public API from a minimal consumer |
| Hook/automation | Trigger the actual event with representative fixtures |
| Skill/agent | Use on a fresh realistic task and inspect behavior |
| Demo/prototype | Operate it until the question has observed evidence |

Use repo tools. Fresh agents require explicit delegation.

If a project-local `verify-*` skill exists, use its doctor, drive, evidence, and cleanup.
Verifier drift routes to `/maintain-verification-skill`; a recurring missing path routes to
`/create-verification-skill` after proof.

## Receipt

Report entrypoint, actions and observations: `Verdict: PASS | FAIL | BLOCKED`, then:

- **Entrypoint:** exact command, URL, event, or consumer.
- **Actions:** intended journey and break attempts.
- **Observations:** data, outputs, state, effects, console/network/logs, and timing.
- **Repairs:** defects, RED tests, fixes, and replay result.
- **Limits:** untried behavior and reason.

PASS requires direct evidence for every changed behavior. FAIL leaves an observed defect.
BLOCKED names the missing access, environment, hardware, or safety condition.
