---
name: ux-performance
description: Audit and optimize real web UX performance. Use for slow SPA pages, routes, interactions, huge tables, loading, caching, memory, Web Vitals, Lighthouse, budgets, or CI regressions.
---

Optimize measured intent-to-useful-state, not suspicious code. Default to client web; follow delayed journeys to backend/delivery.

## Contract

Name before edits:

- **Journey:** route/action, start state, data volume, device/network, cache state, and worst credible load.
- **Milestone:** visible outcome; preserve intended animation, branding, interaction and data semantics via [fidelity assertions](../shared/verification-replay.md).
- **Primary metric:** elapsed time or resource bound for that milestone.
- **Worthwhile delta:** set before edits; honor requested scale (1% is not 10x). Repeatable 100 ms can matter.
- **Endpoint:** read-only audit, optimize through requested delivery, or calibrated CI guard.

For optimization, read the [experiment loop](../quantify-impact/REFERENCE.md#optimization-experiments) before edits.

## Loop

1. Inventory versions, production build, telemetry, profilers, tests and budgets. Read first-party docs before framework/API changes.
2. Measure baseline before edits on one production-like scenario/fixture. Keep original build/traces ignored or temporary; [MEASUREMENT.md](MEASUREMENT.md) owns field/lab evidence.
3. Build intent-to-paint waterfall: queue, network/TTFB, transfer, parse/evaluate, app/render/commit, layout, paint. Mark serial/off-path work and cache state.
4. Rank bottlenecks; form falsifiable hypotheses. Delete work, shrink input, or remove serialization before tuning; change one causal variable at a time.
5. Choose a measured [optimization](OPTIMIZATION.md). For CPU/allocation/locality, apply [data-oriented redesign](../shared/data-oriented-performance.md) before caching or offloading.
6. Pair base/candidate on the same scenario, fixture, machine, browser, build, and cache. Report median/spread; verify fidelity, accessibility, memory, bundle, and errors.
7. Keep worthwhile, guardrail-safe gains; revert losing/inconclusive owned edits. Report `Value not proven - inconclusive` for noise, regression for losses. Refresh leads/fidelity before cumulative results; never metric-shop.
8. CI only when requested: [CI.md](CI.md), stable cheap PR checks, noisy/deep nightly checks, real-user monitoring after deploy. Hooks are advisory until calibrated.

For scale/burst/contention/soak claims, use [STRESS.md](STRESS.md): capacity knee and correctness under pressure.

For bundles, load [bundle analysis](../t3code-skills/bundle-analysis/SKILL.md).

## Output

Outcome and slowest segment:

```md
Verdict: <measured state or value verdict>
| Rank | Bottleneck | Critical-path cost | Evidence | Next change | Confidence |
|---:|---|---:|---|---|---|
Method: <command, build, fixture, cache, device/network, runs, base/candidate>
Guardrails: <correctness, accessibility, errors, memory, bundle>
Artifacts: <paths or links>
```

Separate measured facts, inferences, and untested opportunities. Lighthouse scores, static warnings, smaller-looking code, or an upgrade alone never prove speed.

[React render probes](../shared/react-devtools.md) are not production UX proof.
