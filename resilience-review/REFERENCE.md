# Resilience Review Reference

## Frame

Murphy law, ranked by evidence. Focus on failures a normal user or current
system can credibly reach, not every state that can be imagined.

Prior art: layered workflows, gstack QA (evidence -> tests), Matt Pocock skills (small SKILL.md), footgun checklists.

## Standard

Protect trust boundaries, irreversible effects, explicit contracts, observed
incidents, demonstrated scale, and likely user paths. Do not add guards,
fallbacks, or tests without one of those signals.

## Probes

Use this catalog only to investigate a credible signal; it is not a checklist
to exhaust for every form, API, mutation, config, or job:

- User mistakes: missing required fields, wrong format/project/env/secret/resource, accidental click.
- Controls: Stale enabled button, disabled bypass, hidden submit, Enter key submit, autofill.
- Value: empty, null, duplicate, stale, malformed, huge, unsupported enum.
- Time: stale, slow, timeout, cancelled, double submit, tab race.
- State: mode switch, partial edit, dirty form, deleted resource, stale cache.
- Form state: choose pre-submit and post-submit validation lifecycles separately; delayed validation uses per-field timers; a registered array dirty leaf is boolean while useFieldArray state is nested/sparse; reverting or removing all values clears empty dirty containers.
- Validation timing: a stale async validation result must not replace a newer result; debounce reduces work but cancellation or generation checks own ordering.
- Dependent-field cleanup: `deps` revalidates but does not clear invalid child values or field state; test the parent change, payload, error, touched, and dirty transitions.
- Error visibility: `criteriaMode: 'all'` only helps when the UI renders all validation errors for each field and the summary includes every invalid field.
- System: partial outage, 500, retry storm, queue delay, background failure.
- UX: loading, empty, error, success, disabled, optimistic, rollback.

## Layers

Choose the smallest layer that closes the credible risk. Most findings need one,
not all four.

| Layer | Ask | Defense |
|---|---|---|
| Precondition | Can bad action start? | schema, type guard, field error, disabled submit |
| Invariant | Can bad state exist? | cross-field check, ownership match, exhaustive switch |
| Postcondition | Did action finish right? | verify state, idempotency, rollback, cache update |
| Fallback | Dependency fails? | retry, error state, partial data, safe empty |
| Observability | Will we know? | log context, metric, audit event, request ID |

## Finding pipeline

Every confirmed finding gets its own loop:

1. `/diagnosing-bugs`: build feedback loop; repro exact symptom; capture artifact.
2. `/tdd`: convert finding to RED test before fix; public UI/API seam preferred.
3. Fix: pass test; add snapshot/verification for visual, serialized, config state.
4. `/visual-review`: UI pass for error text, disabled state, loading/error/empty/success, layout.
5. Record evidence only when the risk surface requires it.

## Verdict

| Verdict | Use when | Action |
|---|---|---|
| `PASS` | Covered/harmless | Document evidence |
| `NEEDS_GUARDS` | User stuck/confused, bad config, support/on-call noise | Add guard/test or accepted deferral |
| `BLOCKED` | Crash, corrupt state, data loss, outage, irreversible wrong action | Stop, fix before ship |

P0=crash/corruption/data loss/outage. P1=normal-user stuck path/silent
failure/fake success/no recovery. Hypothetical edges are not findings.

## Examples

- form validation: Missing required fields -> inline errors, no request; invalid URL -> field error; server errors -> all errors visible. Finding queue: Diagnose empty submit/error mapping; TDD RED tests; Visual review error text/focus/disabled submit.
- disabled button edge and double submit: Stale enabled button, Enter key bypass, double click -> submit handler revalidates + pending/idempotency lock. Diagnose validator race; TDD out-of-order validation test; Visual review button/spinner/recovery/focus.
- partial outage: Save 500 keeps form dirty + retry; stale cache updates row; deleted resource explains 404, no crash. Diagnose 500/stale-cache/deleted-resource; TDD recovery/cache tests; Visual review loading/error/retry/success.
- config/resource footgun: wrong project secret rejected by ownership check; mode switch ghost data clears inactive fields. Diagnose wrong-project payload; TDD ownership/ghost-data tests; Visual review selected project/resource before submit.

PR evidence minimum: credible risk, supporting evidence, smallest guard, and
contract test.
