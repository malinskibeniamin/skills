---
name: quantify-impact
description: Measure whether a change made the product or codebase meaningfully better. Use when reproducible evidence would clarify whether a feature, fix, refactor, or upgrade is worth merging.
---

Before measurements, read [Poteto](../shared/POTETO-NATIVE.md#measurement).
For performance optimization, read [optimization experiments](REFERENCE.md#optimization-experiments)
before edits: preserve the original baseline, test one cause, verify equivalent output,
and account for unresolved leads before claiming completion.

Assess impact, published or not, for every PR creation/update and [session PR check](../pr/SKILL.md#existing-pr). Reuse valid evidence; rerun invalid ones. Assessment grants no publishing authority.

## Flow

1. **Evidence opportunity scan:** benchmark only when a cheap metric can clear a predeclared worthwhile delta and variance. Tiny copy/style/test work gets a value sentence.
2. **Lock claim before coding:** thesis, primary metric, guardrail, scenario, minimum worthwhile delta. Never pick the winner afterward.
3. **Product lane + Codebase lane:** one must improve; the other must not materially regress.
   - Product: capability, task success, repro, errors, steps, latency, resources.
   - Codebase: verifiable contracts, change coordination, dependencies, warnings, leaks, bundle/build/test cost; follow [verifiability](../shared/verifiability.md), not size/complexity scores.
4. **Proportional rigor:** sentence for obvious value; deterministic repro/count for correctness; controlled paired [REFERENCE.md](REFERENCE.md) benchmark for runtime; always measure explicit performance claims.
5. **Base:** measure before coding or reconstruct merge-base. Use the same scenario, fixture, config, and machine for base/candidate.
6. **Compare:** only threshold-clearing metrics become claimed impact: raw before/after, absolute/percent delta, method, environment, and noise. Keep inconclusive/reverted attempts in the diagnostic experiment record, not the proven-impact table. Invariant tests/proxies are not performance claims.
7. **Decide:**
   - Worthwhile gain: `Value proven`.
   - Ambiguous/negligible explicit performance claim: `Value not proven`; no micro-deltas or metric-shopping. Allow one evidence-driven revision of that hypothesis, then scrap it; distinct evidence-backed optimization leads remain open.
   - No useful metric and no performance claim: normal value summary, no impact artifact.
   - Regression: fix, narrow, or stop.

Filter guardrails; omit negligible movement.

For runtime/compiler-cost measurements, load [performance analysis](../t3code-skills/performance-analysis/SKILL.md).

## PR output

State user/maintainer value and evidence. Tiny copy/style changes link visual before/after, not invented metrics. Only threshold-clearing evidence uses:

```md
## Proven impact
| Metric | Before | After | Delta |
|---|---:|---:|---:|
| <direct metric> | <base> | <candidate> | <absolute and %> |
**Value proven:** <product or codebase benefit>
Method: `<command, fixture, runs, environment>`.
```

Use through `/commit-push-pr` or `/stacked-prs`; `/make-pr-easy-to-review` reuses it on request. Keep suppressed raw data locally for reproducibility. Never emit an empty table; unproven performance claims say `Value not proven` without negligible numbers.
