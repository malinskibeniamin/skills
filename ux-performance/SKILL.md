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
- **Endpoint:** audit (read-only), optimize (verified changes through the requested delivery endpoint), or calibrated CI guard.

For optimization, read the shared [experiment loop](../quantify-impact/REFERENCE.md#optimization-experiments)
before edits. It owns original/accepted baselines, keep/revert decisions, output equivalence,
the lead checklist and attempt reporting; use the selected tool's manual for mechanics.

## Loop

1. Inventory stack/versions, production build, telemetry, profilers, tests and budgets. Read current first-party docs before framework/library syntax changes.
2. Measure the baseline before changing code with one production-like scenario/fixture. Save the original build and raw traces in ignored or temporary storage; use [MEASUREMENT.md](MEASUREMENT.md) for field/lab evidence.
3. Build intent-to-paint waterfall. Mark serial, parallel/off-path, cache state, and critical segments: queue, network/TTFB, download, parse/evaluate, app, React render/commit, layout, paint.
4. Rank bottlenecks; form falsifiable hypotheses. Delete work, shrink input, or remove serialization before tuning; change one causal variable at a time.
5. Choose a measured [optimization](OPTIMIZATION.md). For CPU/allocation/locality, apply [data-oriented redesign](../shared/data-oriented-performance.md) before caching or offloading.
6. Pair base/candidate on the same scenario, fixture, machine, browser, build, and cache. Report median/spread; verify fidelity, accessibility, memory, bundle, and errors.
7. Keep a worthwhile gain. Revert losing/inconclusive owned experiments; distinguish `Value not proven - inconclusive` from a measured regression. Refresh the lead checklist and final output-equivalence checks before reporting the cumulative gain. Never metric-shop.
8. Prevent recurrence only when requested or CI is the endpoint. [CI.md](CI.md): cheap stable PR checks, noisy/deep nightly checks, real-user monitoring after deploy. Hooks remain advisory until calibrated.

For scale/burst/contention/long-session claims, use [STRESS.md](STRESS.md): capacity knee and correctness under pressure.

For bundle comparisons/composition, load [bundle analysis](../t3code-skills/bundle-analysis/SKILL.md).

## Output

Lead with outcome and slowest segment:

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
