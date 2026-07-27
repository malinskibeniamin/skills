---
name: quantify-impact
description: Prove product or codebase value with proportional before-and-after evidence. Use for dependency upgrades/package bumps, UI bug fixes, UI performance, benchmark comparisons, frontend audits, leak fixes, optimizations, and measurable features.
---

# Quantify Impact

Make value immediately obvious without benchmark theater. This is advisory, not a hard merge hook. Existing workflow skills call it automatically; users need not invoke it.

## Flow

1. **Evidence opportunity scan**: ask whether a direct, decision-useful metric exists and is cheap enough for the change. Benchmark only when the answer is yes. Tiny copy/style/test-only work gets one clear value sentence, not forced numbers. No benchmark theater.
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
6. **Compare honestly**: report raw before/after, absolute and percentage delta, method, environment, and noise. Never turn an invariant test or proxy into a performance claim.
7. **Decide**:
   - Clear worthwhile gain: `Value proven`.
   - Ambiguous/no gain: `Value not proven`; do not metric-shop. Allow one evidence-driven revision, then recommend scrap or close the PR.
   - Regression: fix, narrow, or stop.

## PR output

When useful evidence exists, give `/make-pr-easy-to-review`:

```md
## Proven impact

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| <direct metric> | <base> | <candidate> | <absolute and %> |

**Value proven:** <product or codebase benefit>

Method: `<exact command, fixture, run count, environment>`.
```

No meaningful evidence opportunity: use a normal value summary; do not emit an empty table.
