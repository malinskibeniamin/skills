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

The manifest pins exact model IDs. Claude Fable 5.1 runs at `low`, `medium`, `high`,
`xhigh`, and `max`; reusing a Fable 5 effort result is invalid because effort labels are
not portable across releases. Claude Code 2.1.257 or newer is required. The runner checks
this before starting any cell and points stale installations to `claude update`.
Keep raw results out of git. On every major model release, record the decision with
`scorecard-template.md`, promote only the winning policy into `config/model-routing.json`,
and replace tasks that no longer discriminate between variants.

Do not tune prompts or compaction from release notes alone. First capture the new model's
baseline, then change one behavior at a time only where the scorecard shows a regression.

This suite measures ambient context. Use `HOOK_SHADOW_RULES` plus version-qualified
`/hook-audit` telemetry for hook holdouts. A skill is retained from observed, real-session
use or a separate behavioral treatment; discovery metadata alone is not evidence.

Motivation: [GPT-5.6](https://openai.com/index/gpt-5-6/) reports better coding
efficiency from leaner instructions. Anthropic's
[Fable 5.1 prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1)
requires a fresh effort sweep and recommends `high` as the starting point. These are
hypotheses for this repository until this suite measures them.
