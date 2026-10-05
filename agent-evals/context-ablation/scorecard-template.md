# Model-release ablation scorecard

- Date:
- Model version:
- Harness commit:
- Previous winning variant:
- Effort and speed mode:
- Outcome contracts: task -> requested outcome, guardrails, verification, endpoint

## Results

| Variant | Task pass rates | High-severity regressions | Human quality | Input tokens | Duration |
|---|---|---|---|---|---|
| bare | | | | | |
| guardrails | | | | | |
| lean | | | | | |
| current | | | | | |

## Intent and completion (manual)

Report each task separately across the same runs; keep failures in the denominator.
Use the [review definitions](README.md#intent-and-completion-review), not overall model scores.
Unknown evidence leaves promotion undecided.

| Variant / task | First-pass accepted / runs | Verified completion / runs | Scope/endpoint violations | Clear prose / runs + example |
|---|---|---|---|---|
| bare / | | | | |
| guardrails / | | | | |
| lean / | | | | |
| current / | | | | |

- Corrective follow-ups: count and outcome, or not observed; keep original results above.
- Observed provider task cost at the compared effort/mode, or unknown:

## Hook retention

| Rule | Baseline outcome | Shadow outcome | Quality delta | Latency | Keep, soften, or delete |
|---|---|---|---|---|---|
| | | | | | |

Use only comparable model + harness cohorts. Strict safety and permission rules are not
eligible for shadowing.

## Skill retention

| Skill or context group | Real opportunities | Observed use | Behavioral treatment | Decision |
|---|---|---|---|---|
| | | | | |

Zero firing without a demonstrated opportunity is missing evidence, not a delete signal.

## Decision

- Winning variant:
- Quality verdict:
- Intent/completion/readability verdict and per-task evidence:
- Context restored and why:
- Context deleted and why:
- Hook decisions and why:
- Skill decisions and why:
- Saturated tasks to replace before the next model release:
- Follow-up pause trigger:

Commit this summary without raw transcripts, prompts containing private data, credentials,
or provider session identifiers.
