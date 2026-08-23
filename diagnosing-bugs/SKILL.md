---
name: diagnosing-bugs
description: Use when a hard bug or performance regression needs a reproducible diagnosis loop.
---

# Diagnosing Bugs

Skip a phase only with a reason. Read the domain glossary and ADRs; use
`/read-the-damn-docs` for third-party or version drift.

## Redact

Replace secrets with `<REDACTED>` before sharing commands, output, or artifacts. Keep
credentials in environment variables and quote only signal-bearing lines. Ask for a safer
source when redaction removes necessary evidence.

## Phase 1 -- Build a feedback loop

Build a fast, deterministic, agent-runnable pass/fail signal for the reported symptom.
Improve its speed, precision, and determinism before debugging.

Try the cheapest faithful seam:

1. Failing test: unit, integration, or E2E.
2. HTTP script against the running service.
3. CLI fixture with stdout diff.
4. Headless browser such as Playwright.
5. Captured request, payload, trace, or event replay.
6. Minimal throwaway harness.
7. Property or fuzz loop for intermittent output.
8. Automated harness for `git bisect run`.
9. Differential old/new version or configuration run.
10. HITL script from `scripts/hitl-loop.template.sh` only as a last resort.

Pin time, seeds, filesystem state, and network input. For nondeterminism, repeat under
controlled stress until the reproduction rate can distinguish hypotheses. If no loop is
possible, stop with attempts and request the missing environment, artifact, or safe
instrumentation access.

## Phase 2 -- Reproduce

Run the loop, then `/dogfood` the reporter's real entrypoint. Confirm the exact user-reported
failure, across enough runs to debug, and capture a symptom Phase 5 can disprove.

## Phase 3 -- Hypothesise

Write 3-5 ranked, falsifiable hypotheses before testing. Each predicts what change would
remove or worsen the symptom. Show the list for reranking; discard claims without a testable
prediction.

## Phase 4 -- Instrument

Map each probe to one prediction. Change one variable at a time.

- Prefer debugger or REPL inspection, then targeted boundary logs; never log everything.
- Prefix temporary logs, for example `[DEBUG-a4f2]`, so cleanup can grep the prefix.
- For performance, measure a baseline with a timing harness, profiler, or query plan before
  bisecting or fixing.

## Phase 5 -- Fix + regression test

Create the regression test before the fix at the correct seam: it must reproduce the real
call-site chain, not a nearby unit behavior. If no such seam exists, record the architecture
gap. Otherwise:

1. Minimize the reproduction into a failing test and observe RED.
2. Apply the smallest root-cause fix and observe GREEN.
3. Run related checks.
4. `/dogfood` the identical user journey, then re-run the full Phase 1 loop.

## Phase 6 -- Cleanup + post-mortem

- Original repro no longer reproduces; re-run the original loop.
- Regression test passes, or the missing seam is documented.
- All debug instrumentation removed; grep the unique prefix.
- Throwaway artifacts are deleted or clearly isolated.
- Record the proven root cause in the commit or PR.

Ask what would prevent recurrence. After the root-cause fix, send a proven seam or coupling
problem to `/improve-codebase-architecture`.
