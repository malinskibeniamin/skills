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

The suite now includes three Astra-motivated review trials alongside implementation and
policy tasks:

- `workflow-system-audit` finds repeated prompts, manual release work, skill and instruction
  candidates, schedule candidates, and recurring stop points across synthetic agent history.
- `knowledge-system-audit` traces schema, ingestion, retrieval, duplication, conflict, and
  apparent non-use evidence without treating a small access log as deletion authority.
- `evergreen-project-recovery` runs green automated checks plus a failing real demo, then
  grades the file-scoped recovery plan and its verification contract.

They test the proposed workflows; they do not establish a general model ranking. A model may
own planning or review only after it clears the recorded gate. Handoffs to a different model
remain explicit owner-approved delegation, not automatic routing.

The manifest pins exact model IDs. GPT-6 Astra and Claude Fable 5.1 run at `low`,
`medium`, `high`, `xhigh`, and `max`; results from their predecessors do not determine
the new effort frontier. Astra starts at the harness's current `xhigh` default while the
suite measures the lowest quality-equivalent effort. Claude Code 2.1.257 or newer is
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

Motivation: [GPT-6 Astra](https://openai.com/index/gpt-6-astra/) and its
[model guide](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6-astra)
report stronger instruction sensitivity, initiative, and verification behavior. Existing
task-success, quality, token, duration, and verification metrics test those claims without
duplicating release guidance into ambient context. [GPT-5.6](https://openai.com/index/gpt-5-6/)
reports better coding efficiency from leaner instructions. Anthropic's
[Fable 5.1 prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1)
requires a fresh effort sweep and recommends `high` as the starting point. These are
hypotheses for this repository until this suite measures them.
