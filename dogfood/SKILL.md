---
name: dogfood
description: Dogfood runnable work at its real user entrypoint. Use after each material behavior slice and before handoff or shipping for features, fixes, demos, prototypes, hooks, skills, CLIs, APIs, or UI.
---

# Dogfood

A **material runnable increment** is a behavior slice that can be exercised through a real user or public entrypoint. Dogfood it before starting the next slice and again before handoff or shipping. Tests are not dogfood: they prove assertions, not the experience.

## Loop

Run **use -> abuse -> repair -> replay** on the current implementation.

### 1. Use

Identify every changed behavior and its real user entrypoint. Start the actual implementation and perform the intended journey yourself. Inspect the visible output, state transitions, side effects, logs, and console rather than inferring success from code or tests.

For a bug, first run the reporter's exact steps against the unfixed behavior and capture the exact symptom. If you cannot reproduce it, stop diagnosis, report what you tried, and request the missing environment or evidence. Do not fix an assumed bug.

**Complete when:** each changed behavior has a directly observed baseline at its public seam.

### 2. Abuse

Try to break each changed behavior like a real user:

- **Careless:** empty, invalid, oversized, duplicate, or out-of-order input.
- **Impatient:** repeat, double-submit, navigate away, reload, cancel, or interrupt.
- **Unlucky:** stale state, missing data, dependency failure, slow response, or partial completion.

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
- **Observations:** outputs, state, side effects, console or logs
- **Repairs:** defects found, tests added, fixes made, replay result
- **Limits:** untried behavior and why

PASS requires experiential evidence for every changed behavior on the current implementation. FAIL means an observed defect remains. BLOCKED names the missing access, environment, hardware, or safety constraint and the evidence needed next.
