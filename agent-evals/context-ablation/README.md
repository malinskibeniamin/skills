# Context ablation

Run this paid suite before promoting a model, effort, or always-loaded context
change:

```sh
agent-evals/context-ablation/run.sh --dry
agent-evals/context-ablation/run.sh --smoke
agent-evals/context-ablation/run.sh --force
```

`current` and `lean` share tasks, run counts, validation, and a fixed quality gate.
The prompts state outcomes rather than copying the rule text that hidden tests check.
Compare each one-group change against the previous winner. Treat token and duration
savings as tie-breakers only after quality is non-inferior.

The manifest lists `max` because GPT-5.6 Sol exposes it. Fable and Opus run at their
supported quality efforts, so family comparisons do not pretend that effort labels are portable.
Keep raw results out of git; promote only the winning policy into
`config/model-routing.json`.

Motivation: [GPT-5.6](https://openai.com/index/gpt-5-6/) reports better coding
efficiency from leaner instructions; the
[Fable field guide](https://claude.com/blog/a-field-guide-to-claude-fable-finding-your-unknowns)
and [context-engineering notes](https://x.com/trq212/article/2080710971228918066)
favor unknown-first planning and progressive disclosure. These are hypotheses for this
repository until this suite measures them.
