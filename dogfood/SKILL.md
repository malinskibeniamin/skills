---
name: dogfood
description: Dogfood runnable work at its real user entrypoint. Use after each material behavior slice and before handoff or shipping for features, fixes, demos, prototypes, hooks, skills, CLIs, APIs, or UI.
---

# Dogfood

A **material runnable increment** is a behavior slice that can be exercised through a real user or public entrypoint. Dogfood it before starting the next slice and again before handoff or shipping. Tests are not dogfood: they prove assertions, not the experience.

## Inventory the runnable change

Before using the implementation, identify the complete behavior inventory:

1. Resolve the target with
   `BASE=$(PR_BASE_REF="${DOGFOOD_BASE_REF:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`.
   This selects the current stacked PR's parent before falling back to the remote default.
2. Inspect the whole PR diff from its merge-base through committed, staged, unstaged, and untracked changes. Do not limit scope to files touched in the current session.
3. Map every runnable artifact to its changed behavior and real entrypoint. A skill includes `SKILL.md` plus its referenced guidance, assets, and scripts; hooks and automation are runnable through their actual events. Exclude standalone documentation, tests, and evals from required experiential coverage.

For an ordinary local turn, dogfood when that turn changed runnable behavior. Before PR or ship completion, dogfood every runnable behavior in the full PR even when it was implemented in an earlier session.

## Loop

Run **use -> abuse -> repair -> replay** on the current implementation.

### 1. Use

Identify every changed behavior and its real user entrypoint. Start the actual implementation and perform the intended journey yourself. Inspect the visible output, state transitions, side effects, logs, and console rather than inferring success from code or tests.

Use representative live-scale data that matches production shape and cardinality. Compare expected and observed counts, ordering, timing, state, and side effects; repeat long enough to expose steady-state or accumulation behavior.

For a bug, first run the reporter's exact steps against the unfixed behavior and capture the exact symptom. If you cannot reproduce it, stop diagnosis, report what you tried, and request the missing environment or evidence. Do not fix an assumed bug.

**Complete when:** each changed behavior has a directly observed baseline at its public seam.

### 2. Abuse

Try to break each changed behavior like a real user:

- **Careless:** empty, invalid, oversized, duplicate, or out-of-order input.
- **Impatient:** repeat, double-submit, navigate away, reload, cancel, or interrupt.
- **Unlucky:** stale state, missing data, dependency failure, slow response, or partial completion.
- **Live data:** sparse fields, duplicate IDs, mixed tenants or versions, long text, Unicode, timezone boundaries, and realistic cardinality.
- **Performance:** measure response time, network, render, CPU, and memory when relevant; compare evidence with an explicit budget or baseline.

Apply every relevant lens and at least one plausible break attempt per changed behavior. Prefer likely user behavior over arbitrary cases.

**Complete when:** intended use and applicable failure or recovery behavior were directly observed.

### 3. Repair

Treat every discovered defect as a failed checkpoint. When automatable, turn it into a RED regression test, fix it through `/tdd`, and rerun focused automated checks. A code change invalidates prior dogfood evidence.

**Complete when:** no observed defect remains unresolved or silently deferred.

### 4. Replay

Restart from the real entrypoint and repeat the intended journey plus every break attempt on the current implementation. For a bug fix, replay the identical pre-fix reproduction and confirm the reported symptom is gone without breaking adjacent behavior.

**Complete when:** the current runnable state, not an earlier build, survives the full loop.

## Pick the real entrypoint

| Change | Exercise |
|---|---|
| Web or dashboard | Run the app; navigate, click, type, reload, and inspect console/network |
| CLI or TUI | Invoke the built command with realistic, invalid, and interrupted input |
| API or worker | Send real requests/events and inspect response plus side effects |
| Library | Use its public API from a minimal real consumer |
| Hook or automation | Trigger the actual event against a representative fixture |
| Skill or agent instruction | Use it on a fresh realistic task; inspect behavior, not prose |
| Demo or prototype | Play with the runnable artifact until its question has an observed answer |

Use project-native tools first. Use fresh agents only when the user authorized delegation.

## Receipt

Bind the entrypoint, actions, and observations to the current implementation. Report:

`Verdict: PASS | FAIL | BLOCKED`

- **Entrypoint:** exact command, URL, event, or consumer
- **Actions:** intended journey and break attempts
- **Observations:** data shape/scale, counts/order/timing, outputs, state, side effects, console/network/logs
- **Repairs:** defects found, tests added, fixes made, replay result
- **Limits:** untried behavior and why

Include the complete structured receipt in the final response. PASS requires experiential evidence for every changed behavior on the current implementation. FAIL means an observed defect remains. BLOCKED names the missing access, environment, hardware, or safety constraint and the evidence needed next.
