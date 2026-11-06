---
name: hill-climb
description: Optimize a defined outcome through bounded evaluation loops. Use for hill-climb requests or repeated improvement against an executable eval, benchmark, or visual comparison; not a one-pass review.
---

Optimize the artifact, not its judge. Prefer executable evidence; calibrate visual judgment.

## Compose with existing owners

Load the [owners](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies) below; share one loop and budget:

- [Development lifecycle](../development-lifecycle/SKILL.md) owns implementation and delivery.
  Report, plan and review requests stay read-only except for requested plan artifacts;
  [improve](../improve/SKILL.md) can recommend a climb without starting one.
- [Quantify impact](../quantify-impact/SKILL.md) owns metrics, worthwhile deltas and noise.
- For UI, [visual review](../visual-review/SKILL.md) owns rendered evidence and specialist routing;
  [dogfood](../dogfood/SKILL.md) owns real behavior and failure/recovery checks.
- Only when explicitly authorized, [council](../tstack-skills/council/SKILL.md) or
  [sol-loop](../tstack-skills/sol-loop/SKILL.md) supplies read-only review rounds under
  [host compatibility](../shared/TSTACK.md#review-evidence-for-council-and-sol-loop).
  Loading hill-climb alone grants no delegation. Otherwise review inline and label it so.
  [Efficient frontier](../efficient-frontier/SKILL.md) owns authorized model routing and capacity.

## Define the hill before editing

Use the existing task contract or a compact inline note:

- **Objective:** beneficiary, desired outcome, primary metric or named rubric categories,
  acceptance condition and minimum worthwhile improvement. A number alone is not value.
- **Guardrails:** protected behavior, accessibility, security, permissible edit surface and
  resource limits. Preserve unrelated work and the original user's endpoint.
- **Verification:** evaluator command or visual protocol, fixture, environment, original
  revision and current best accepted candidate (the incumbent). Retain both references.
- **Stop:** requested endpoint, evaluation budget and plateau rule. Without a supplied
  budget, allow at most three candidate iterations; reserve confirmation within that budget.
  Tighter reviewer, time, usage or cost limits still win; nested helpers share the budget.

If no credible evaluator exists, build the smallest verifier within authorized scope or
return the missing prerequisite. Do not substitute an easy proxy for the requested result.
If the baseline already meets the outcome, confirm it and stop without speculative edits.

## Calibrate the evaluator

Choose the applicable branch; keep its inputs fixed throughout comparable rounds:

| Branch | Baseline and proof |
|---|---|
| Executable correctness/eval | Reproduce representative failures and retain valid controls. Freeze assertions, expected answers and supported routes; keep held-out cases for confirmation when feasible. |
| Performance/resources | Use the [optimization experiment protocol](../quantify-impact/REFERENCE.md#optimization-experiments): identical workload/environment, paired measurements, noise and fidelity guardrails against original and incumbent. |
| Visual quality | Capture original, candidate and useful reference products in comparable route/data, viewport, zoom, theme and interaction states. Choose task-relevant categories such as hierarchy, readability and feedback; preserve behavioral and accessibility gates. |

For authorized independent visual reviews, use fresh contexts with the same artifacts,
rubric, intent, constraints, check results and unresolved findings. Withhold the desired
numeric rating, previous scores and preferred winner; use neutral candidate labels where
practical. Request evidence-backed comparisons and specific defects; numeric ratings only
when requested, and always advisory. Inline self-review is neither blind nor independent.

Re-evaluate an unchanged reference to detect judge drift. If unchanged inputs receive
materially different judgments, investigate or report uncertainty instead of claiming a win.
An evaluator repair or changed rubric, fixture, model or environment starts a newly
baselined comparison; never splice its scores into the old trend or weaken tests to pass.

## Climb

1. **Hypothesize:** choose one evidenced bottleneck or concrete quality defect and predict
   how a small reversible edit should improve the objective without breaking a guardrail.
2. **Change:** implement only that intervention through the owning workflow. Preserve a
   recoverable incumbent; do not edit scoped inputs while reviewers evaluate them.
3. **Evaluate:** run relevant checks and the frozen evaluator on the exact candidate.
   Reuse valid evidence; record invalid samples, failures and unavailable coverage honestly.
4. **Keep or revert:** accept only a worthwhile supported gain with guardrails intact against
   original and incumbent. Revert only the losing experiment's owned edits, retaining earlier
   verified wins and others' work. Ties, noisy scores and missing results are not improvements.
5. **Record:** keep a compact round ledger: candidate identity, hypothesis, evidence/delta,
   guardrail result, keep/revert and unresolved findings. Use ignored/temporary storage only
   when the run needs it; no routine audit dumps or per-round PRs.

Stop early at supported acceptance, exhausted budget, two consecutive no-gain candidates,
or an external/reserved blocker. A higher score alone never resolves a substantive defect.
Stalled or exhausted means target unmet, not approval; retain and report the best verified
candidate rather than silently expanding scope or raising the target.

For prompt/tool-description optimization, first establish behavioral correctness across
the declared routes. Then freeze that passing suite as a guardrail and reduce context
incrementally, rerunning controls and held-out cases. Keep the stages separate; shorter
instructions that worsen tool choice lose. Use [writing for agents](../writing-for-agents/SKILL.md);
model/context-route changes retain [efficient frontier's evaluation gate](../efficient-frontier/SKILL.md#promotion).

## Confirm and hand off

Confirm with a fresh fixed batch rather than the winning exploratory samples. Re-run
affected functional/visual checks and inspect against the original. Missing independent
coverage stays explicit; consensus or a target rating cannot replace verification or human approval.

Report outcome/target status, original-to-final evidence, kept/reverted experiments,
remaining limits and why the loop stopped. Continue through the existing delivery owner
to the user's endpoint; hill-climb itself adds no PR, merge, deployment or monitoring grant.

Source: [Theo's walkthrough](https://x.com/theo/status/2118465321032106235),
13:04–20:44 (comparison/score drift), 26:21–30:27 (eval first, then compression).
