---
description: "Audit and optimize real web UX performance. Use for slow SPA pages, routes, interactions, huge tables, loading, caching, memory, Web Vitals, Lighthouse, budgets, or CI regressions."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["ux performance"]}
sidebar: {"label":"/ux-performance"}
title: "/ux-performance"
type: "skill"
---
![Diagram of the /ux-performance skill](/diagrams/skills/ux-performance.svg)

[Open the editable Excalidraw source](/diagrams/skills/ux-performance.excalidraw)


Optimize measured intent-to-useful-state, not suspicious code. Default to client web; follow delayed journeys to backend/delivery.

## Contract

Name before edits:

- **Journey:** route/action, start state, data volume, device/network, cache state, and worst credible load.
- **Milestone:** visible outcome; preserve intended animation, branding, interaction and data semantics via [fidelity assertions](https://github.com/malinskibeniamin/skills/blob/v4.40.0/shared/verification-replay.md).
- **Primary metric:** elapsed time or resource bound for that milestone.
- **Worthwhile delta:** fixed before edits; repeatable 100 ms can matter, noise does not.
- **Endpoint:** audit (read-only), optimize (verified local changes), or calibrated CI guard.

## Loop

1. Inventory stack/versions, production build, telemetry, profilers, tests and budgets. Read current first-party docs before framework/library syntax changes.
2. Measure the baseline before changing code with one production-like scenario/fixture. Save raw traces under ignored `.context/ux-performance/<journey>/`; use [MEASUREMENT.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/ux-performance/MEASUREMENT.md) for field/lab evidence.
3. Build intent-to-paint waterfall. Mark serial, parallel/off-path, cache state, and critical segments: queue, network/TTFB, download, parse/evaluate, app, React render/commit, layout, paint.
4. Rank bottlenecks. Form 3-5 falsifiable hypotheses and change one causal variable at a time. Delete work, shrink input, or remove serialization before optimizing work.
5. Choose the narrowest evidence-backed [optimization](https://github.com/malinskibeniamin/skills/blob/v4.40.0/ux-performance/OPTIMIZATION.md). Wrappers, contexts, caches, workers, compilers, upgrades, prefetch, and SSR are candidates, never presumed wins.
6. Pair base/candidate on the same scenario, fixture, machine, browser, build, and cache. Report median/spread; verify fidelity, accessibility, memory, bundle, and errors.
7. Keep a worthwhile gain. If within variance, displaced, or guardrail-regressing, report `Value not proven - inconclusive` and revert speculative complexity. Never metric-shop.
8. Prevent recurrence only when requested or CI is the endpoint. [CI.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/ux-performance/CI.md): cheap stable PR checks, noisy/deep nightly checks, real-user monitoring after deploy. Hooks remain advisory until calibrated.

For scale/burst/contention/long-session claims, use [STRESS.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/ux-performance/STRESS.md): capacity knee and correctness under pressure.

For bundle comparisons/composition, load [bundle analysis](https://github.com/malinskibeniamin/skills/blob/v4.40.0/t3code-skills/bundle-analysis/SKILL.md).

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

[React render probes](https://github.com/malinskibeniamin/skills/blob/v4.40.0/shared/react-devtools.md) are not production UX proof.
