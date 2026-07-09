---
name: codex
description: Delegate work to GPT-5.5/5.6 via the codex CLI -- clear-spec implementation, independent review, computer use, investigation, or data analysis. Use for bulk mechanical work, token-hungry tasks, or a cross-model second opinion.
---

# Codex delegation (GPT-5.5 / GPT-5.6)

GPT-5.6 (and 5.5) are reachable ONLY through the codex CLI (`codex exec`, `codex review`) --
never through the agent/workflow `model` parameter (Claude models only). **Default to GPT-5.6
for all codex work** (`-m gpt-5.6`, or set `model = "gpt-5.6"` in `~/.codex/config.toml`);
GPT-5.5 is a fallback only while 5.6 is unavailable on the account. GPT models are extremely
steerable: write explicit, self-contained prompts and they follow them.

## Prompt contract (every codex run)

Self-contained -- codex sees none of this conversation. Include: repo path + branch, objective,
scope and out-of-scope, acceptance criteria, exact verify commands, evidence format for the
report, and stop conditions. Fable judges the returned output against the bar; below bar ->
rerun with a sharper prompt or redo on a smarter model without asking.

## Modes

- **Implement** (clear spec, migrations, mechanical sweeps): `codex exec` with write access,
  in a worktree when anything else touches the checkout.
- **Review** (independent second opinion on a diff/PR): `codex review`, or
  `codex exec -s read-only` with the diff command in the prompt. Findings feed the normal
  review merge; treat as one lane, not the verdict.
- **Computer use** (browser/GUI verification, visual re-checks): shell the whole computer-use
  task to codex -- it is a token furnace on Claude models. Prompt must name the URL/app, the
  states to verify, and the evidence to capture; codex reports back, Fable judges.
- **Investigate / analyze** (log clustering, data analysis, codebase surveys):
  `codex exec -s read-only "<self-contained prompt>"` -- no write access needed.

## Timeouts and background runs

Codex runs can exceed Bash's default 10-minute timeout. Either pass an explicit `timeout`
on the Bash call, or run in the background and poll for the report file:

```bash
codex exec -s read-only "<prompt>. Write the final report to <report-path>." &
# Bash(run_in_background: true), then poll/Read <report-path>
```

## Inside workflows and subagents (the wrapper pattern)

The workflow/agent `model` parameter only accepts Claude models. To use GPT-5.5/5.6 in a
workflow lane or subagent, spawn a thin Claude wrapper:

- Wrapper: `model: sonnet`, `effort: low` -- its ONLY job is to compose the self-contained
  codex prompt, run `codex exec` via Bash, and return the report.
- Structured results: put the `schema` on the wrapper agent; it maps the codex report into
  the schema.
- **Always label the agent with a `GPT-5.6:` prefix** (for example `label: "GPT-5.6: review"`; use the model actually invoked).
  The workflow UI shows the wrapper's Claude model, so the label is the only indication the
  real worker is GPT.
- Parallel implementation wrappers MUST use `isolation: "worktree"` so codex edits do not
  collide in the shared checkout.
- Workflow token budgets count Claude tokens only -- codex work is free and invisible to
  `budget.spent()`. Budget the wrappers, not the codex runs.

## When NOT to delegate

Judgment-heavy work stays with Fable-5/Opus-4.8: ambiguous decomposition, architecture,
synthesis across conflicting reports, final review of anything that ships. User-facing
output (UI, copy, API design) needs taste >= 7 -- GPT-5.5 (taste 5) drafts, a Claude model
finishes. Never use Haiku for anything.
