---
description: "Measure whether a change made the product or codebase meaningfully better. Use when reproducible evidence would clarify whether a feature, fix, refactor, or upgrade is worth merging."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["quantify impact"]}
sidebar: {"label":"/quantify-impact"}
title: "/quantify-impact"
type: "skill"
---
![Diagram of the /quantify-impact skill](/diagrams/skills/quantify-impact.svg)

[Open the editable Excalidraw source](/diagrams/skills/quantify-impact.excalidraw)


Read [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/POTETO-NATIVE.md#measurement).
For performance optimization, read the [experiment loop](https://github.com/malinskibeniamin/skills/blob/v4.45.0/quantify-impact/REFERENCE.md#optimization-experiments) before edits.
For repeated candidates, use [hill-climb](https://github.com/malinskibeniamin/skills/blob/v4.45.0/hill-climb/SKILL.md).

Assess every PR creation/update and [session PR check](https://github.com/malinskibeniamin/skills/blob/v4.45.0/pr/SKILL.md#existing-pr), published or not. Reuse valid evidence; rerun invalid comparisons. Assessment grants no publication authority.

## Flow

1. **Evidence opportunity scan:** benchmark only when a cheap metric can clear a predeclared worthwhile delta and variance. Tiny copy/style/test work gets a value sentence.
2. **Lock claim before coding:** thesis, primary metric, guardrail, scenario, minimum worthwhile delta. Never pick the winner afterward.
3. **Product lane + Codebase lane:** one must improve; the other must not materially regress.
   - Product: capability, task success, repro, errors, steps, latency, resources.
   - Codebase: verifiable contracts, change coordination, dependencies, warnings, leaks, bundle/build/test cost; follow [verifiability](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/verifiability.md), not size/complexity scores.
4. **Proportional rigor:** sentence for obvious value; deterministic repro/count for correctness; paired [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/quantify-impact/REFERENCE.md) benchmarks for runtime. Measure explicit performance claims.
5. **Base:** measure before coding or reconstruct merge-base. Use the same scenario, fixture, config, and machine for base/candidate.
6. **Compare:** claim only threshold-clearing deltas with method, environment and noise. Diagnostic attempts are not proven impact; tests/proxies alone do not prove speed.
7. **Decide:**
   - Worthwhile gain: `Value proven`.
   - Ambiguous/negligible performance claim: `Value not proven`; no metric-shopping. Revise a hypothesis once with evidence, then scrap it; distinct supported leads remain open.
   - No useful metric and no performance claim: normal value summary, no impact artifact.
   - Regression: fix, narrow, or stop.

Filter guardrails; omit negligible movement.

For runtime/compiler-cost measurements, load [performance analysis](https://github.com/malinskibeniamin/skills/blob/v4.45.0/t3code-skills/performance-analysis/SKILL.md).

## PR output

State user/maintainer value and evidence; tiny copy/style edits use visual proof, not invented metrics. Only threshold-clearing evidence uses:

```md
## Proven impact
| Metric | Before | After | Delta |
|---|---:|---:|---:|
| <direct metric> | <base> | <candidate> | <absolute and %> |
**Value proven:** <product or codebase benefit>
Method: `<command, fixture, runs, environment>`.
```

Publish via `/commit-push-pr` or `/stacked-prs`; `/make-pr-easy-to-review` reuses on request. Keep raw data locally. No empty tables or negligible claimed gains; unproven claims say `Value not proven`.
