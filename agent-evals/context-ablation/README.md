# Context ablation

Run this paid suite before promoting a model, effort, or always-loaded context
change:

```sh
agent-evals/context-ablation/run.sh --dry
agent-evals/context-ablation/run.sh --smoke
agent-evals/context-ablation/run.sh --force
```

The ladder starts with the bare model, then restores guardrails, lean repository context,
and current runtime-native context. Codex receives `AGENTS.md`; Claude Code receives
`CLAUDE.md`. Every variant shares tasks, run counts, validation, and a fixed quality gate.
Prompts state high-level outcomes and verification paths without copying the hidden grader
rules. Compare each group against the previous winner. Treat token and duration savings as
tie-breakers only after quality is non-inferior.

## Intent and completion review

Freeze each task's requested outcome, guardrails, verification, and endpoint before running
the matrix. Review each original run against that contract and record these manual metrics
per task in the scorecard:

- **First-pass intent success:** accepted runs / all runs, with no corrective user prompt.
  A justified pause for a reserved decision can satisfy a contract; unnecessary scope changes
  or stopping before the requested endpoint cannot.
- **Verified completion:** runs satisfying the contract with observed verification / all runs.
  Green checks for the wrong outcome and unsupported claims of success do not count.
- **Scope/endpoint violations:** count runs that change excluded behavior or cross the stop boundary.
- **Readability:** clear runs / all runs, with a concrete example of any unclear output.
  A run is clear when the owner can identify the result, evidence, uncertainty, and any needed
  decision without reconstructing the transcript.

Hold tasks, run counts, and harness fixed; name each model/version, effort, and speed mode
(or note that the harness does not expose one).
For context comparisons, also hold model, effort, and mode fixed. Keep failed original runs
in the denominator; record corrective follow-ups separately if observed, otherwise mark them
not observed. Neither readability nor aggregate pass rates can hide a per-task intent or
completion regression. The runner does not calculate these manual metrics or enforce the
promotion verdict; missing review evidence leaves it undecided.

Subjective rankings and impressions of subscription allowance motivate trials, not results.
Record provider task cost only when observed at the compared effort/mode; unknown cost stays
unknown. Token counts, API spend, and these trials do not establish subscription capacity.

The suite includes three review trials alongside implementation and
policy tasks:

- `workflow-system-audit` finds repeated prompts, manual release work, skill and instruction
  candidates, schedule candidates, and recurring stop points across synthetic agent history.
- `knowledge-system-audit` traces schema, ingestion, retrieval, duplication, conflict, and
  apparent non-use evidence without treating a small access log as deletion authority.
- `evergreen-project-recovery` runs green automated checks plus a failing real demo, then
  grades the file-scoped recovery plan and its verification contract.

They test the proposed workflows; they do not establish a general model ranking.
Unrequested planning or review promotions must clear the recorded gate. The current pair
is owner-selected, not benchmark-promoted. Handoffs to a different model remain explicit
owner-approved delegation, not automatic routing.

The manifest pins only Claude Opus 5.5 and GPT-6.1 Sol. Both run at `low`, `medium`,
`high`, `xhigh`, and `max`; results from their
predecessors do not determine the new effort frontier. The owner-selected drivers start at
Opus 5.5 `xhigh` and Sol `xhigh` while the suite measures the lowest quality-equivalent
effort. Claude Code 2.1.257 or newer is
required. The runner checks this before starting any cell and points stale installations
to `claude update`.
Keep raw results out of git. On every major model release, record the decision with
`scorecard-template.md`, promote only the winning policy into `config/model-routing.json`,
and replace tasks that no longer discriminate between variants.

Do not tune prompts or compaction from release notes alone. First capture the new model's
baseline, then change one behavior at a time only where the scorecard shows a regression.

This suite measures ambient context. Use `HOOK_SHADOW_RULES` plus version-qualified
`/hook-audit` telemetry for hook holdouts. A skill is retained from observed, real-session
use or a separate behavioral treatment; discovery metadata alone is not evidence.
