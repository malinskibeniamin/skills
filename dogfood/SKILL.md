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
3. Map behavior to real entrypoints, including skill resources/scripts and hook events.
   Standalone docs, tests and evals need no experiential coverage.

Cover changed runnable branches before PR/shipping.

## Loop

Run **use -> abuse -> repair -> replay**.

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

At the real entrypoint, repeat intended use and every break attempt. For bugs, replay identical
steps and adjacent behavior. Use [replay packets](../shared/verification-replay.md) for
stateful bugs or recurring repro gaps. PASS binds to the current runnable state.

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

If a project-local `verify-*` skill exists, use its doctor, drive, evidence, and cleanup.
T3 Code checkout UI only: resolve [native context](../shared/T3CODE-NATIVE.md#resolve-context), then load [web/desktop](../t3code-skills/test-t3-app/SKILL.md) or
[native mobile](../t3code-skills/test-t3-mobile/SKILL.md). Missing Browser/Device tools mean
BLOCKED, not installing or switching harnesses.
Verifier drift routes to `/maintain-verification-skill`; a recurring missing path routes to
`/create-verification-skill` after proof.

## Receipt

`Verdict: PASS | FAIL | BLOCKED`; entrypoint, actions, observations:

- **Entrypoint:** exact command, URL, event, or consumer.
- **Actions:** intended journey and break attempts.
- **Observations:** data, outputs, state, effects, console/network/logs, and timing.
- **Repairs:** defects, RED tests, fixes, and replay result.
- **Limits:** untried behavior and reason.

PASS needs direct evidence for every changed behavior. FAIL records an observed defect.
BLOCKED names missing access, environment, hardware or a safety condition.
