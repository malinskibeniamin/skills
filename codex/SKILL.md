---
name: codex
description: Delegate work to GPT-5.6 via the codex CLI -- clear-spec implementation, independent review, computer use, investigation, or data analysis. Use for bulk mechanical work, token-hungry tasks, or a cross-model second opinion.
---

# Codex delegation (GPT-5.6)

**Host gate:** this CLI delegation path is Claude-hosted. If already in native Codex, do not start
a recursive `codex exec` or native subagent unless the user requests delegation or parallel agents.
Work inline; preserve the selected model and reasoning effort; do not rewrite Codex configuration.

GPT-5.6 is reachable ONLY through the codex CLI (`codex exec`, `codex review`), never the
agent/workflow `model` parameter (Claude models only). GPT-5.5 is retired. **Capability-detect**:
run `codex exec -m gpt-5.6-sol "reply OK"` once per session; if the model is unavailable, fall
back to the strongest GPT and label the actual model. CLI unavailable skips the lane and records it.
GPT models are extremely steerable: write explicit, self-contained prompts.

**Delegated CLI variant routing (effort floors are HARD -- never run a delegated variant below its floor):**

| Variant | Flag | Effort | Use for | Never |
|---|---|---|---|---|
| **Sol** | `-m gpt-5.6-sol` (default) | implementation/plan/Sol-only review `xhigh`; Opus adversarial review `high` | ALL code writing, implementation, review, and plan checks | low effort |
| **Terra** | `-m gpt-5.6-terra` | `medium`\|`high` only | PR comments and test-runner/CI chores | product code or review |
| **Luna** | `-m gpt-5.6-luna` | `high` only | tracker orchestration and mundane tool loops | development or review |
Optional user setup: `model = "gpt-5.6-sol"` in `~/.codex/config.toml`; agents do not mutate it.

## Prompt contract (every codex run)

Self-contained -- codex sees none of this conversation. **Steering payload (required for
implementation work)**: codex gets none of Claude's path-scoped skill autoloading, so the
prompt must carry the conventions -- include the matched skill rules for every touched
surface (ConnectRPC files -> connect-query rules; UI -> registry/token + a11y rules; routes
-> tanstack-router rules; UI strings -> ux-copy), plus "match the shape of the relevant
`exemplars/` file" with that file inlined. Also include: repo path + branch, objective,
scope and out-of-scope, acceptance criteria, exact verify commands, evidence format for the
report, and stop conditions. Fable judges the returned output against the bar; below bar ->
rerun with a sharper prompt or redo on a smarter model without asking.

## Modes

- **Implement** (clear spec, migrations, mechanical sweeps): run
  `codex exec -m gpt-5.6-sol -c 'model_reasoning_effort="xhigh"'` with write access, in a
  worktree when anything else touches the checkout.
- **Review** (independent second opinion on a diff/PR): Opus work gets Sol high; Sol-only
  fallback uses xhigh. Include the diff command; merge findings as one lane, not the verdict.
- **Adversarial exchange (automatic in Claude-hosted workflows -- no ask needed)**: the author
  model never solely reviews its own work, and the reviewer comes from a DIFFERENT FAMILY
  whenever possible -- family diversity catches what same-family blind spots share. Claude
  authored the diff -> `GPT-5.6-sol: adversarial` review here (`codex review` / read-only
  exec, high effort, prompt: "try to break this -- failure scenarios, spec drift, missing
  tests; P0-P3 findings only, evidence required"). GPT authored the diff -> Fable/Opus
  reviews (the `/review` panel or `adversarial-reviewer` agent). Same-family clean-context
  review is the fallback ONLY when the other family is unavailable -- record the
  substitution. Terra/Luna never review. Findings route back per model routing. `/go` phase 4b invokes
  this automatically. Native Codex runs the axis inline and records cross-family review as
  unavailable unless the user explicitly requests an external lane.

  **Cross-provider gates (checked before every automatic exchange):**
  - *Authorization*: send code to OpenAI only when the repo opts in -- a `.codex/` directory
    or an AGENTS.md at the repo root is the opt-in signal (the owner configured Codex for
    this codebase). Unclassified/private repos without it -> the adversarial lane is a
    clean-context Claude agent instead; record the substitution.
  - *Minimization*: send the diff, acceptance criteria, and verify commands -- never the
    conversation, secrets, or unrelated files.
  - *Budget*: Claude and Codex quotas are separate. Opus adversarial review stays Sol high;
    Sol-only review stays xhigh when its subscription meter is unavailable. Never substitute
    `ccusage` token/cost data for quota.
    Cap the exchange at one Sol review per refine round and one per PR-iterate round.
- **Computer use** (browser/GUI verification, visual re-checks): shell the whole computer-use
  task to codex -- it is a token furnace on Claude models. Prompt must name the URL/app, the
  states to verify, and the evidence to capture; codex reports back, Fable judges.
- **Investigate / analyze** (log clustering, data analysis, codebase surveys):
  `codex exec -s read-only "<self-contained prompt>"` -- no write access needed.

## Timeouts and background runs

Codex runs can exceed Bash's default 10-minute timeout. Either pass an explicit `timeout`
on the Bash call, or run in the background and poll for the report file:

```bash
codex exec -s read-only "<prompt>. Write the final report to <report-path>." </dev/null &
# Bash(run_in_background: true), then poll/Read <report-path>
```

**Always `</dev/null` on background runs**: codex also reads its prompt from stdin, so an
open-but-silent stdin pipe blocks it forever waiting for EOF -- 0s CPU, no session, looks "stuck".

## Inside Claude-hosted workflows and subagents (the wrapper pattern)

The workflow/agent `model` parameter only accepts Claude models. Review calls Codex directly
through Bash so a wrapper cannot spend Claude quota. Other workflow lanes may use a thin wrapper:

- Wrapper: `model: sonnet`, `effort: low` -- its ONLY job is to compose the self-contained
  codex prompt, run `codex exec` via Bash, and return the report.
- Structured results: put the `schema` on the wrapper agent; it maps the codex report into
  the schema.
- **Always label the agent with the variant prefix** (`GPT-5.6-sol: implement`, `GPT-5.6-terra: pr-comments`).
  The workflow UI shows the wrapper's Claude model, so the label is the only indication the
  real worker is GPT.
- Parallel implementation wrappers MUST use `isolation: "worktree"` so codex edits do not
  collide in the shared checkout.
- Workflow token budgets count Claude tokens only -- codex work is invisible to
  `budget.spent()`. Budget the wrappers, not the codex runs.

## When NOT to delegate

Judgment-heavy work uses the quota-routed Claude profile plus Sol xhigh, or Sol alone when
Claude is disabled: ambiguous decomposition, architecture, synthesis. User-facing
output (UI, copy, API design) needs taste >= 7 -- GPT-5.6 (taste 6) drafts, a Claude model
finishes. Never use Haiku for anything.
