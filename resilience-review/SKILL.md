---
name: resilience-review
description: Murphy-law hat panel for unhappy paths -- input, timing, system, state, UX-recovery hats probe a change in parallel. Use when forms, validation, async/data, mutations, cache, state machines, destructive actions, or loading/empty/error states change.
---

# Resilience Review
Murphy pass: find every plausible unhappy path, then block, guard, recover, observe.

## Use when
Diffs touching forms, validation, submit, async/data, mutations, cache, retries, state machines, mode/union switches, config/resource choice, destructive actions, or loading/empty/error/success UI. Skip docs/test/style/trivial pure logic only; record reason.

## Hat panel (parallel)

Map the risk surface first (user action, path, state change, side effects, deps), then spawn the hats in one message as subagents -- each owns one failure class with non-goals, so they don't converge on the same findings. Small single-concern diff: run the hats inline instead, same axes, same output.

| Hat | Owns (and probes) | Non-goals |
|---|---|---|
| input | empty, null, duplicate, malformed, stale, huge, out-of-order payloads; validation format-vs-presence | timing, infra |
| timing | double submit, tab race, retry storms, slow network, timeout, cancel, out-of-order responses | payload validity |
| system | partial outage, 500s, stale cache, deleted resource, permission drift, dependency failure | UI polish |
| state | invalid/impossible states, mode-switch residue, oneof cleanup, stale derived state, recovery to a good state | network causes |
| ux-recovery | unclear disabled states, lost errors, fake success, dead ends without retry/undo, missing loading/empty states | root causes owned by other hats |

Each hat emits findings with: scenario, trigger, expected behavior, guard (Precondition -> Postcondition -> Fallback -> Observability), test to write, evidence (file/route/form/API cited). For external/browser/platform behavior, the hat runs `/read-the-damn-docs`; complex planned state flows sketch `/visual-plan` first.

Merge: dedupe by root cause, keep the highest-severity framing, then drive the finding loop: `/diagnosing-bugs` feedback loop -> `/tdd` RED test/snapshot -> `/visual-review` for UI validation.

## Output
```md
## Resilience review
Risk surface:
- ...
Hats: input <status> | timing <status> | system <status> | state <status> | ux-recovery <status>
Failure matrix:
| Scenario | Trigger | Expected behavior | Guard | Test | Observability |
Finding queue:
| Finding | Repro/diagnosing-bugs loop | RED test or snapshot | Owner | Visual review needed |
Required tests:
- ...
Polish gaps:
- ...
Verdict: PASS | NEEDS_GUARDS | BLOCKED
```

Rules: cite files/routes/forms/API. Docs/help text not enough when code can prevent bad state. Real gap unfixed -> PR evidence with owner/deferral. No silent hat skips -- one-line evidence per skipped hat.

See [REFERENCE.md](REFERENCE.md).
