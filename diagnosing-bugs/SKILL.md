---
name: diagnosing-bugs
description: Diagnosis loop for hard bugs and performance regressions. Use when asked to diagnose or debug, or when a hard bug needs a reproducible feedback loop.
---

# Diagnosing Bugs
Discipline for hard bugs. Skip a phase only with reason. Use the domain glossary and ADRs;
for third-party/API/version drift, run `/read-the-damn-docs` before ranking hypotheses.

## Phase 1 -- Build a feedback loop
**The feedback loop is the skill.** The rest is mechanical. Build a fast, deterministic,
agent-runnable pass/fail signal for the reported bug; bisection, hypothesis tests, and
instrumentation consume that signal. Spend most of the diagnosis effort here.

### Strategies (try in roughly this order)
1. **Failing test** at the highest seam that reaches the bug -- unit, integration, or e2e.
2. **Curl / HTTP script** against running dev server.
3. **CLI invocation** with fixture input, diff stdout vs known-good snapshot.
4. **Headless browser script** (Playwright / Puppeteer) -- drive UI, assert DOM/console/network.
5. **Replay captured trace.** Save real network request / payload / event log to disk; replay through code path isolated.
6. **Throwaway harness.** Start the smallest system slice that reaches the bug with one call.
7. **Property / fuzz loop.** If bug "sometimes wrong output", run 1000 random inputs, watch failure mode.
8. **Bisection harness.** If the bug appeared between two known states, automate
   "boot state X, check, repeat" so `git bisect run` works.
9. **Differential loop.** Run same input through old-version vs new-version (or two configs), diff output.
10. **HITL bash script.** Last resort. If a human must click, guide them with
    `scripts/hitl-loop.template.sh`; feed the captured output back into the loop.

### Iterate on the loop itself
Treat the loop as a product: make it faster, sharpen the asserted symptom, and remove
nondeterminism by pinning time, random seeds, filesystem state, and network inputs.

### Non-deterministic bugs
Target a **higher reproduction rate**. Run the loop repeatedly, add controlled stress, and
narrow the timing window until the failure occurs often enough to distinguish hypotheses.

### When you genuinely cannot build a loop
Stop with the attempted loops and request the missing input: access to the reproducing
environment, a captured artifact, or permission for temporary production instrumentation.

Proceed to Phase 2 when the loop reliably signals the reported failure.

## Phase 2 -- Reproduce
Run the loop, then `/dogfood` the reporter's real user entrypoint. Watch the same bug appear.

- [ ] The loop produces the failure mode the **user** described, not a nearby failure.
- [ ] The failure reproduces across multiple runs, or often enough to debug.
- [ ] The loop captures the exact symptom so Phase 5 can prove the fix addresses it.

Proceed when the reported bug reproduces.

## Phase 3 -- Hypothesise
Generate **3-5 ranked, falsifiable hypotheses** before testing any; single-hypothesis work
anchors on the first plausible idea.

> Format: "If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse."

Discard or sharpen any hypothesis that lacks a testable prediction.

Show the ranked list before testing so available domain knowledge can rerank it. Continue with
the evidence-based ranking when the user is unavailable.

## Phase 4 -- Instrument
Each probe must map to specific prediction from Phase 3. **Change one variable at a time.**

1. **Debugger / REPL inspection** when the environment supports it. One breakpoint can replace ten logs.
2. **Targeted logs** at boundaries that distinguish hypotheses.
3. Never "log everything and grep".

Tag every debug log with a unique prefix such as `[DEBUG-a4f2]`, then remove every match.

**Perf branch.** Establish a measured baseline with a timing harness, profiler, or query plan,
then bisect. Measure first, fix second.

## Phase 5 -- Fix + regression test

Write regression test **before fix** -- but only if **correct seam** for it.

The correct seam exercises the **real bug pattern** as it occurs at the call site. A shallow
unit that cannot reproduce the triggering chain gives false confidence. If no suitable seam
exists, document that architectural gap for Phase 6. Otherwise:

1. Turn minimised repro into failing test at that seam.
2. Watch it fail.
3. Apply fix.
4. Watch it pass.
5. Run `/dogfood` to replay the identical user reproduction, then re-run the original un-minimised Phase 1 loop.

## Phase 6 -- Cleanup + post-mortem
Complete every item before declaring the diagnosis done:

- [ ] `/dogfood` confirms the exact user repro no longer reproduces; Phase 1 loop also passes
- [ ] Regression test passes (or absence of seam is documented)
- [ ] All `[DEBUG-...]` instrumentation removed (`grep` the prefix)
- [ ] Throwaway prototypes deleted (or moved to a clearly-marked debug location)
- [ ] The hypothesis that turned out correct is stated in the commit / PR message -- so the next debugger learns

Then ask what would prevent recurrence. If the answer is an architectural change, hand the
specific seam or coupling problem to `/improve-codebase-architecture`. Recommend it after the root-cause
fix, when the evidence is strongest.
