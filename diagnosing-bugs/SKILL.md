---
name: diagnosing-bugs
description: Diagnosis loop for hard bugs and performance regressions. Use when asked to diagnose or debug, or when a hard bug needs a reproducible feedback loop.
---

# Diagnosing Bugs
Discipline for hard bugs. Skip a phase only with reason. Use the domain glossary and ADRs; for third-party, API, or version drift, run `/read-the-damn-docs` before ranking hypotheses.

## Redact
This skill exposes commands, output, and captured artifacts. Replace every secret with `<REDACTED>`.
Keep credentials in environment variables and quote only signal-bearing lines; captured artifacts may contain authentication headers. If redaction removes necessary evidence, ask for a safer source.

## Phase 1 -- Build a feedback loop
**The feedback loop is the skill.** Everything else consumes it. Build a tight, deterministic, agent-runnable pass/fail signal that goes red on the user's exact bug.
Spend disproportionate effort here; code reading is for constructing the loop, not inventing an unsupported theory.

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

### Tighten the loop
Treat the loop as a product:

- Make it faster by caching setup and skipping unrelated initialization.
- Make the signal sharper by asserting the exact symptom, not merely "did not crash."
- Make it deterministic by pinning time, seeds, filesystem state, and network inputs.

For nondeterministic bugs, raise the reproduction rate: repeat under controlled stress, parallelize, and narrow timing windows until the rate distinguishes hypotheses.

If no loop is possible, stop, list attempts, and request the missing environment, redacted artifact, or permission for safe temporary instrumentation.
Do not proceed to hypothesise without a loop.

### Completion criterion: a tight loop that goes red
Phase 1 ends only when you can name one command already run at least once, with redacted invocation and output, that is:

- **Red-capable:** drives the actual path and asserts the user's exact symptom.
- **Deterministic:** returns the same verdict, or a pinned high reproduction rate.
- **Fast:** seconds rather than minutes.
- **Agent-runnable:** unattended, except through the structured HITL script.

No red-capable command, no Phase 2.

## Phase 2 -- Reproduce + minimise
Run the loop, then `/dogfood` the reporter's real entrypoint. Confirm:

- The loop produces the failure the user described, not a nearby failure.
- It reproduces across multiple runs, or often enough to debug.
- It captures the exact symptom Phase 5 must disprove.

Shrink the red reproduction by removing inputs, callers, configuration, data, and steps one
at a time, rerunning after every cut. Keep only what is necessary for the failure and later
regression test. Finish when every remaining element is load-bearing: removing any one makes
the loop green. Do not proceed until the bug is reproduced and minimised.

## Phase 3 -- Hypothesise
Generate 3-5 ranked, falsifiable hypotheses before testing; one hypothesis anchors on the
first plausible idea. Each must predict what change makes the symptom disappear or worsen.
Show the list so domain knowledge can rerank it, but continue when the user is unavailable.
Discard claims without a testable prediction.

## Phase 4 -- Instrument
Map each probe to one prediction. Change one variable at a time.

1. Prefer debugger or REPL inspection when available.
2. Add targeted logs only at boundaries that distinguish hypotheses.
3. Never log everything and grep.

Prefix temporary logs, for example `[DEBUG-a4f2]`, so cleanup can grep every match. For
performance, establish a measured baseline with a timing harness, profiler, or query plan,
then bisect. Measure first, fix second.

## Phase 5 -- Fix + regression test
Write the regression test before the fix at the correct seam. It must exercise the real bug
pattern and call chain; a nearby shallow unit gives false confidence. If no suitable seam
exists, record that architecture gap. Otherwise:

1. Turn the minimised reproduction into a failing test and observe RED.
2. Apply the smallest root-cause fix and observe GREEN.
3. Run related checks.
4. `/dogfood` the identical user journey, then re-run the original unminimised Phase 1 loop.

## Phase 6 -- Cleanup + post-mortem
Complete every item before declaring the diagnosis done:

- `/dogfood` confirms the exact user reproduction no longer fails; the original loop passes.
- The regression test passes, or the missing seam is documented.
- All debug instrumentation is removed; grep the unique prefix.
- Throwaway artifacts are deleted or clearly isolated.
- The proven root cause is recorded in the commit or PR.

Ask what would prevent recurrence. After the root-cause fix, send a proven seam or coupling
problem to `/improve-codebase-architecture`.
