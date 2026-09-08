---
name: quantify-impact
description: Measure whether a change made the product or codebase meaningfully better. Use when reproducible evidence would clarify whether a feature, fix, refactor, or upgrade is worth merging.
---

Make value obvious without benchmark theater. Every PR creation/update runs this assessment automatically through `/commit-push-pr` or `/stacked-prs`; measurement stays proportional.

## Flow

1. **Evidence opportunity scan:** benchmark only when a cheap direct metric could clear a predeclared worthwhile delta and normal variance. Tiny copy/style/test work gets a value sentence. No benchmark theater.
2. **Lock claim before coding:** thesis, primary metric, guardrail, scenario, minimum worthwhile delta. Never pick the winner afterward.
3. **Product lane + Codebase lane:** one must improve; the other must not materially regress.
   - Product: capability, task success, repro, errors, steps, latency, resources.
   - Codebase: maintenance surface, complexity, dependencies, warnings, leaks, bundle, build/test cost, testability.
4. **Proportional rigor:** sentence for obvious value; deterministic repro/count for correctness; controlled paired [REFERENCE.md](REFERENCE.md) benchmark for runtime; always measure explicit performance claims.
5. **Base:** measure before coding or reconstruct merge-base. Use the same scenario, fixture, config, and machine for base/candidate.
6. **Compare:** only threshold-clearing metrics report raw before/after, absolute/percent delta, method, environment, and noise. Suppress below-threshold/within-variance numbers. Invariant tests/proxies are not performance claims.
7. **Decide:**
   - Worthwhile gain: `Value proven`.
   - Ambiguous/negligible explicit performance claim: `Value not proven`; no micro-deltas or metric-shopping. Allow one evidence-driven revision, then scrap/close.
   - No useful metric and no performance claim: normal value summary, no impact artifact.
   - Regression: fix, narrow, or stop.

Apply the same filter to guardrails; omit negligible movement.

## PR output

Always provide a concise impact bullet: what improved for the user or maintainer and the evidence. Tiny copy/style changes get a value sentence linked to visual before/after evidence, not an invented metric. Only when evidence clears threshold, replace that bullet with:

```md
## Proven impact
| Metric | Before | After | Delta |
|---|---:|---:|---:|
| <direct metric> | <base> | <candidate> | <absolute and %> |
**Value proven:** <product or codebase benefit>
Method: `<command, fixture, runs, environment>`.
```

Give this directly to the PR body through `/commit-push-pr` or `/stacked-prs`; no separate reviewability request is needed. `/make-pr-easy-to-review` reuses it when explicitly requested. Keep suppressed raw data only in local evidence when reproducibility needs it. Never emit an empty table; explicit unproven performance claims say `Value not proven` without negligible numbers.
