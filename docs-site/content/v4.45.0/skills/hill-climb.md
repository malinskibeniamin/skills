---
description: "Optimize a defined outcome through bounded evaluation loops. Use for hill-climb requests or repeated improvement against an executable eval, benchmark, or visual comparison; not a one-pass review."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["hill climb"]}
sidebar: {"label":"/hill-climb"}
title: "/hill-climb"
type: "skill"
---
![Diagram of the /hill-climb skill](/diagrams/skills/hill-climb.svg)

[Open the editable Excalidraw source](/diagrams/skills/hill-climb.excalidraw)


Optimize the artifact, not its judge. Prefer executable evidence; calibrate visual judgment.

## Compose with existing owners

Load only applicable [owners](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies); share one loop and budget:

- [Development lifecycle](https://github.com/malinskibeniamin/skills/blob/v4.45.0/development-lifecycle/SKILL.md) owns implementation/delivery; [improve](https://github.com/malinskibeniamin/skills/blob/v4.45.0/improve/SKILL.md) stays advisory. Report/plan/review requests authorize no implementation edits.
- [Quantify impact](https://github.com/malinskibeniamin/skills/blob/v4.45.0/quantify-impact/SKILL.md) owns metrics, worthwhile deltas and noise.
- For UI, [visual review](https://github.com/malinskibeniamin/skills/blob/v4.45.0/visual-review/SKILL.md) owns rendered evidence/specialist routing; [dogfood](https://github.com/malinskibeniamin/skills/blob/v4.45.0/dogfood/SKILL.md) owns behavior/recovery checks.
- Explicitly authorized [council](https://github.com/malinskibeniamin/skills/blob/v4.45.0/tstack-skills/council/SKILL.md) or [sol-loop](https://github.com/malinskibeniamin/skills/blob/v4.45.0/tstack-skills/sol-loop/SKILL.md) supplies read-only rounds under [host compatibility](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/TSTACK.md#review-evidence-for-council-and-sol-loop).
  Otherwise review inline, never as independent. No implicit delegation; [efficient frontier](https://github.com/malinskibeniamin/skills/blob/v4.45.0/efficient-frontier/SKILL.md) owns routing/capacity. Helpers share the budget.

## Define the hill before editing

Use the existing task contract or a compact inline note:

- **Objective:** beneficiary, outcome, primary metric or rubric categories, acceptance condition and minimum worthwhile improvement.
- **Guardrails:** protected behavior, accessibility, security, edit surface and resource limits; preserve unrelated work and the user's endpoint.
- **Verification:** evaluator command/visual protocol, fixture, environment, original revision and best confirmed candidate (the incumbent). Retain both references.
- **Stop:** endpoint, finite evaluation/resource budget and plateau rule. Default: three
  candidate attempts, accepted or not; one intervention counts once regardless of file count.
  Baseline batches, retries and confirmation all consume the evaluation/resource budget.
  Reserve confirmation capacity before each attempt; stop searching if it cannot fit.
  Tighter user, reviewer or host limits win; re-baselining never resets counters.

If no credible evaluator exists, build the smallest authorized verifier or report the missing prerequisite; an easy proxy is not the requested result.
If the baseline already meets the outcome, confirm it and stop without speculative edits.

## Calibrate the evaluator

Choose the applicable branch; keep its inputs fixed throughout comparable rounds:

| Branch | Baseline and proof |
|---|---|
| Executable correctness/eval | Reproduce representative failures and retain valid controls. Freeze assertions, expected answers and supported routes; keep held-out cases for confirmation when feasible. |
| Performance/resources | Use the [optimization experiment protocol](https://github.com/malinskibeniamin/skills/blob/v4.45.0/quantify-impact/REFERENCE.md#optimization-experiments): identical workload/environment, paired measurements, noise and fidelity guardrails against original and incumbent. |
| Visual quality | Follow [visual calibration](https://github.com/malinskibeniamin/skills/blob/v4.45.0/visual-review/REFERENCE.md#review-calibration). Capture original, candidate and requested reference products in comparable states; preserve design intent, behavioral and accessibility gates. |

For authorized independent visual reviews, use fresh contexts with the same artifacts, rubric, intent, constraints, check results and unresolved findings.
Withhold desired ratings, previous scores and preferred winners; use neutral candidate labels where practical. Request evidence-backed comparisons and specific defects.
Numeric ratings are requested-only and advisory. Inline self-review is neither blind nor independent.

Only when review policy permits staging, screen with an authorized judge before the full panel. Reserve capacity for every required final reviewer on the same candidate.
Mark not-run, unavailable or stale results explicitly, never as agreement; staging grants no provider substitution or weaker final coverage.

Re-evaluate an unchanged reference to detect judge drift. If unchanged inputs receive
materially different judgments, investigate or report uncertainty instead of claiming a win.
An evaluator repair or changed rubric, fixture, model or environment needs a fresh baseline;
never splice incompatible scores into one trend or weaken tests to pass. Calibrate an added
or replacement authorized judge on the unchanged references; keep per-judge results separate.

## Climb

1. **Hypothesize:** choose one evidenced bottleneck/quality defect; predict a small reversible improvement without breaking a guardrail.
2. **Change:** implement only that intervention through its owner. Preserve a recoverable incumbent; freeze scoped inputs during review.
3. **Evaluate:** run relevant checks and the frozen evaluator on the exact candidate.
   Reuse valid evidence; record invalid samples, failures and unavailable coverage honestly.
4. **Confirm, then keep:** require a worthwhile gain beyond noise and intact guardrails against
   original and incumbent. Keep it provisional until a fresh fixed batch confirms it; advance
   the incumbent only then. Failed/inconclusive confirmation rejects the trial; restore only its
   owned edits, retaining the confirmed incumbent and others' work. Ties or missing results are not gains.
5. **Record:** keep a compact ledger: candidate, hypothesis, evidence/delta, guardrails,
   keep/revert, remaining budget and unresolved findings. Use ignored/temporary storage only
   when the run needs it; no routine audit dumps or per-round PRs.

Stop at confirmed acceptance, exhausted budget, two consecutive no-gain candidates, or an external/reserved blocker.
An owner-raised target needs a new explicit contract; preserve the prior result and budget record rather than silently escalating or creating another PR/worktree.

| Exit evidence | Report |
|---|---|
| Current confirmation meets target and every guardrail | `met`; retain confirmed incumbent. |
| Valid evaluations fall short at budget/plateau stop | `unmet`; retain best confirmed incumbent, not the last trial. |
| Missing/invalid evaluator, drift or unavailable required coverage | `unverified`; retain incumbent and name the missing proof. |

A higher rating never resolves a substantive defect. Apply requested per-category and reference-ranking targets individually; an overall average cannot hide a missed target.
Keep the original scope and target; diagnose invalid evaluations rather than rerolling unchanged candidates for a passing grade.

For prompt/tool-description optimization, load the [experiment protocol](https://github.com/malinskibeniamin/skills/blob/v4.45.0/hill-climb/references/tool-description-optimization.md).
Establish correctness before compression; preserve its supported matrix and regression suite.

## Confirm and hand off

Reuse confirmation only for unchanged inputs; re-run invalidated functional/visual checks against the original.
Disclose missing independent coverage; consensus or ratings cannot replace verification or human approval.

Report outcome/target status, original-to-final evidence, kept/reverted experiments,
remaining limits and why the loop stopped. Continue through the existing delivery owner
to the user's endpoint; hill-climb itself adds no PR, merge, deployment or monitoring grant.

Examples:
- `/hill-climb improve sidebar readability against the supplied screenshots; preserve keyboard flows; 3 candidates; local only; no delegates`
- `/hill-climb reduce tool-description tokens while preserving the existing tool-choice eval across supported routes; 3 candidates; local only; no delegates`

Source: [Theo's walkthrough](https://x.com/theo/status/2118465321032106235), 06:18-08:09 (review loop), 11:39-20:44 (visual comparison, staged reviews, score drift), 26:37-30:27 (failure-derived evals, correctness before compression). Budgets and permission boundaries are harness adaptations.
