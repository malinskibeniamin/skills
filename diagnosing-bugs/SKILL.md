---
name: diagnosing-bugs
description: Diagnosis loop for hard bugs and performance regressions. Use when asked to diagnose or debug, or when a hard bug needs a reproducible feedback loop.
---

When investigating a concrete defect or failed repair, read the [Poteto adaptation](../shared/POTETO-NATIVE.md#review-and-diagnosis).

# Diagnosing Bugs
Skip a phase only with reason. Use `GLOSSARY.md` (follow `GLOSSARY-MAP.md` when present) and ADRs; for third-party, API, or version drift, Call the Skill tool with "read-the-damn-docs" before ranking hypotheses.
Other hosts: [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Redact
Replace every secret with `<REDACTED>`. Keep credentials in environment variables; quote only signal-bearing lines. Artifacts may contain auth headers. If redaction hides evidence, ask for a safer source.

## Phase 1 -- Build a feedback loop
**The feedback loop is the skill.** Build a deterministic, agent-runnable pass/fail loop for the exact bug. Read code to construct it, not invent theories.

### Strategies, roughly in order
1. **Failing test** at the highest seam that reaches the bug: unit, integration, or E2E.
2. **Curl or HTTP script** against the running service.
3. **CLI invocation** with fixture input and a known-good stdout diff.
4. **Headless browser script** that asserts DOM, console, or network behavior.
5. **Captured trace replay:** request, payload, event log, or other real artifact.
6. **Throwaway harness:** the smallest system slice that reaches the bug with one call.
7. **Property or fuzz loop** for intermittent wrong output.
8. **Bisection harness** suitable for `git bisect run`.
9. **Differential loop** comparing old/new versions or configurations on the same input.
10. **HITL script** from `scripts/hitl-loop.template.sh` only when a human must act.

UI content/layout failures: Call the Skill tool with "break-ui" for schema-valid fixtures.
Pin the failing fixture through the real component into this loop; retain original input for post-fix replay.

### Tighten the loop
- Make it faster by caching setup and skipping unrelated initialization.
- Make the signal sharper by asserting the exact symptom, not merely "did not crash."
- Make it deterministic by pinning time, seeds, filesystem state, and network inputs.

For nondeterministic bugs, raise the reproduction rate: repeat under controlled stress, parallelize, and narrow timing windows until the rate distinguishes hypotheses.

Without a loop, stop, list attempts, and request the missing environment, redacted artifact, or safe temporary instrumentation permission.
Do not proceed to hypothesise without a loop.

### Completion criterion: a tight loop that goes red
Phase 1 ends only when you can name one command already run at least once, with redacted invocation and output, that is:

- **Red-capable:** drives the actual path and asserts the user's exact symptom.
- **Deterministic:** returns the same verdict, or a pinned high reproduction rate.
- **Fast:** seconds rather than minutes.
- **Agent-runnable:** unattended, except through the structured HITL script.

No red-capable command, no Phase 2.

## Phase 2 -- Reproduce + minimise
For stateful bugs, capture the [original replay packet](../shared/verification-replay.md) before minimization.
Run the loop; Call the Skill tool with "dogfood" at the reporter's real entrypoint. Confirm:

- The loop produces the failure the user described, not a nearby failure.
- It reproduces across multiple runs, or often enough to debug.
- It captures the exact symptom Phase 5 must disprove.

Minimise inputs, callers, configuration, data, and steps one at a time; rerun after each cut.
Finish when every remaining element is load-bearing: removing any one makes the loop green.
Retain this reproduction for the regression test; only then proceed.

## Phase 3 -- Hypothesise
Generate 3-5 ranked, falsifiable hypotheses before testing; one hypothesis anchors on the
first plausible idea. Each must predict what change makes the symptom disappear or worsen.
Show the list so domain knowledge can rerank it, but continue when the user is unavailable.
Discard claims without a testable prediction.

## Phase 4 -- Instrument
Map each probe to one prediction. Change one variable at a time.

1. Prefer debugger/REPL. React: [inspection](../shared/react-devtools.md).
2. Log only boundaries that distinguish hypotheses.
3. Never log everything and grep.

Prefix temporary logs, for example `[DEBUG-a4f2]`, so cleanup can grep every match. For
performance, establish a measured baseline with a timing harness, profiler, or query plan,
then bisect. Measure first, fix second.

## Phase 5 -- Fix + regression test
Write the regression test before the fix at the correct seam. It must exercise the real bug
pattern and call chain; a nearby shallow unit gives false confidence. If no suitable seam
exists, record that architecture gap. Otherwise:

1. Turn the minimised reproduction into a failing test and observe RED. For forced RED, diff the mutation against a pristine copy; restore before testing the fix.
2. Apply the smallest root-cause fix and observe GREEN.
3. Run related checks.
4. Call the Skill tool with "dogfood" for the identical user journey, then re-run the original unminimised Phase 1 loop.

## Phase 6 -- Cleanup
Complete every item before declaring the diagnosis done:

- `/dogfood` confirms the exact user reproduction no longer fails; the original loop passes.
- The regression test passes, or the missing seam is documented.
- All debug instrumentation is removed; grep the unique prefix.
- Throwaway artifacts are deleted or clearly isolated.
- The proven root cause is recorded in the commit or PR.
