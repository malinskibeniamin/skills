---
name: quantify-impact
description: Measure whether a change made the product or codebase meaningfully better. Use when reproducible evidence would clarify whether a feature, fix, refactor, or upgrade is worth merging.
---

# Quantify Impact

Make value immediately obvious without benchmark theater. This is advisory, not a hard merge hook. Existing workflow skills call it automatically; users need not invoke it.

## Flow

1. **Evidence opportunity scan**: ask whether a direct, decision-useful metric exists and is cheap enough for the change. A metric is decision-useful only when it can clear a predeclared minimum worthwhile delta and, for noisy measurements, normal variance. Benchmark only when the answer is yes. Tiny copy/style/test-only work gets one clear value sentence, not forced numbers. No benchmark theater.
2. **Lock the claim before coding**: state the change thesis, primary metric, guardrail, scenario, and minimum worthwhile delta before implementation or edits. Do not choose the winning metric afterward.
3. **Use two value lanes**:
   Product lane + Codebase lane: one must improve; the other must not materially regress.
   - **Product lane**: capability, task success, bug reproduction, errors, steps, latency, or resource cost.
   - **Codebase lane**: maintenance surface, complexity, dependencies, warnings, leaks, bundle, build/test cost, or testability.
   A code-health improvement is valid primary value.
4. **Choose proportional rigor**:
   - Tiny/obvious: value sentence only.
   - Correctness or exact count: deterministic before/after repro or count.
   - Runtime/performance: controlled paired benchmark from [REFERENCE.md](REFERENCE.md).
   - Explicit performance claim: always measure.
5. **Capture base**: measure before coding when feasible. Otherwise reconstruct the exact merge-base. Run base and candidate with the same scenario, fixture, configuration, and machine.
6. **Compare honestly**: for metrics that clear the predeclared threshold, report raw before/after, absolute and percentage delta, method, environment, and noise. Suppress metrics below that threshold or within normal variance; measuring a number does not make it meaningful. Never turn an invariant test or proxy into a performance claim.
7. **Decide**:
   - Clear worthwhile gain: `Value proven`.
   - Explicit performance claim with ambiguous, negligible, or no gain: `Value not proven`; omit the micro-deltas and do not metric-shop. Allow one evidence-driven revision, then recommend scrap or close the PR.
   - No explicit performance claim and no worthwhile metric: omit quantified impact output and use a normal value summary.
   - Regression: fix, narrow, or stop.

Apply the same filter to guardrails. Omit negligible guardrail movement entirely; do not display its raw values or add a `Guardrail held` line merely to account for it.

## PR output

When useful evidence clears the predeclared threshold, give `/make-pr-easy-to-review`:

```md
## Proven impact

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| <direct metric> | <base> | <candidate> | <absolute and %> |

**Value proven:** <product or codebase benefit>

Method: `<exact command, fixture, run count, environment>`.
```

Filter individual rows: include only decision-useful deltas. Keep suppressed raw measurements in the local evidence artifact when useful for reproducibility, not in the PR output.

No meaningful evidence opportunity or no metric above threshold: use a normal value summary; do not emit an empty table. For an explicit performance claim, state `Value not proven` without publishing negligible numbers.
