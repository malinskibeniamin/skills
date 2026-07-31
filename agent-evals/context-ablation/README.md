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

The manifest lists `max` because GPT-5.6 Sol exposes it. Fable and Opus run at their
supported quality efforts, so family comparisons do not pretend that effort labels are portable.
Keep raw results out of git. On every major model release, record the decision with
`scorecard-template.md`, promote only the winning policy into `config/model-routing.json`,
and replace tasks that no longer discriminate between variants.

This suite measures ambient context. Use `HOOK_SHADOW_RULES` plus version-qualified
`/hook-audit` telemetry for hook holdouts. A skill is retained from observed, real-session
use or a separate behavioral treatment; discovery metadata alone is not evidence.

Motivation: [GPT-5.6](https://openai.com/index/gpt-5-6/) reports better coding
efficiency from leaner instructions; the
[Fable field guide](https://claude.com/blog/a-field-guide-to-claude-fable-finding-your-unknowns)
and [context-engineering notes](https://x.com/trq212/article/2080710971228918066)
favor unknown-first planning and progressive disclosure. These are hypotheses for this
repository until this suite measures them.
