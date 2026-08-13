---
name: ux-performance
description: Audit and optimize real web UX performance. Use for slow SPA pages, routes, interactions, huge tables, loading, caching, memory, Web Vitals, Lighthouse, budgets, or CI regressions.
---

# UX Performance

Make the user reach a useful, responsive state sooner. Optimize the measured critical
path, not code that merely looks expensive. Default to a client-side web app; follow
evidence into delivery or backend work only when it delays the journey.

## Establish the performance contract

Before implementation, name:

- **Journey**: route, action, start state, data volume, device/network class, and cold or
  warm cache. Include a worst credible workload, not only the happy path.
- **Milestone**: the user-visible outcome, such as useful content, filter results, or the
  next painted frame. Add correctness and accessibility guardrails.
- **Primary metric**: direct elapsed time or resource bound for that milestone.
- **Minimum worthwhile delta**: a repeatable 100 ms win is valid; a delta within noise is
  not. Keep one primary metric fixed before edits.
- **Endpoint**: audit, optimize, or install regression checks. An audit returns findings
  without edits; optimization continues through verified local changes; CI work installs
  only calibrated checks.

## Run the loop

1. **Inventory** the real stack, production build path, existing telemetry, profilers,
   tests, budgets, and installed package versions. Read current first-party docs before
   changing framework or library syntax.
2. **Measure the baseline before changing code**. Reproduce the same scenario and fixture in a production-like
   build. Save raw traces under `.context/ux-performance/<journey>/` when `.context/` is
   ignored. Use [MEASUREMENT.md](MEASUREMENT.md) to combine field and lab evidence.
3. **Build the waterfall** from intent to painted result. Mark serial dependencies,
   parallel/off-path work, cache state, and the longest critical-path segments. Attribute
   time across queueing, network/TTFB, download, parse/evaluate, application work, React
   render/commit, style/layout, and paint.
4. **Rank bottlenecks**, not audit warnings. Form 3-5 falsifiable hypotheses, then change
   one causal variable at a time. Prefer deleting work, shrinking input, or removing a
   serial dependency before making the same work faster.
5. **Intervene** with the narrowest evidence-backed option from
   [OPTIMIZATION.md](OPTIMIZATION.md). A wrapper, context, cache, worker, compiler,
   framework upgrade, prefetch, or server render is a candidate—not a default win.
6. **Verify** base and candidate with the same scenario, fixture, machine, browser, build,
   and cache state. Use paired runs; report median and spread. Re-run correctness,
   accessibility, memory, bundle, and error guardrails.
7. **Decide**. Keep a clear worthwhile gain. If the result is inside variance, moves cost
   elsewhere, or regresses a guardrail, report `Value not proven — inconclusive` and revert
   the speculative complexity. Do not metric-shop.
8. **Prevent recurrence** only when requested or when the endpoint includes CI. Use
   [CI.md](CI.md) to place stable cheap checks in pull requests, noisy/deep checks nightly,
   and real-user monitoring after deploy. Hooks are optional and advisory until calibrated.

When scale, burst, contention, or long-session behavior is part of the claim, use
[STRESS.md](STRESS.md) to find the capacity knee and verify correctness under pressure.

## Output

Lead with the user outcome and the slowest segment:

```md
Verdict: <measured state or value verdict>

| Rank | Bottleneck | Critical-path cost | Evidence | Next change | Confidence |
|---:|---|---:|---|---|---|
| 1 | <cause, not symptom> | <ms/bytes/work> | <trace/profile> | <small intervention> | <high/medium/low> |

Method: <exact command, build, fixture, cache, device/network, runs, base/candidate>
Guardrails: <correctness, accessibility, errors, memory, bundle>
Artifacts: <paths or links>
```

Separate measured facts, inferences, and untested opportunities. Never claim speed from a
Lighthouse score, static warning, smaller-looking code, or upgraded dependency alone.
