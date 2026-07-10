---
name: codex
description: Delegate work to GPT-5.6 via the codex CLI -- clear-spec implementation, independent review, computer use, investigation, or data analysis. Use for bulk mechanical work, token-hungry tasks, or a cross-model second opinion.
---

# Codex delegation (GPT-5.6)

GPT-5.6 is reachable ONLY through the codex CLI (`codex exec`, `codex review`) --
never through the agent/workflow `model` parameter (Claude models only). GPT-5.5 is retired
as a routing target. **Capability-detect before relying on 5.6**: run
`codex exec -m gpt-5.6-sol "reply OK"` once per session; on model-unavailable fall back to
the strongest GPT available and label wrappers with the model actually invoked -- distinguish
that from CLI-unavailable (codex not installed), which skips the codex lane entirely and
records the skip. GPT models are extremely steerable: write explicit, self-contained prompts
and they follow them.

**Variant routing (effort floors are HARD -- never run a variant below its floor):**

| Variant | Flag | Effort | Use for | Never |
|---|---|---|---|---|
| **Sol** | `-m gpt-5.6-sol` (default) | `medium`\|`high` only | ALL code writing, implementation, adversarial review -- smartest model rivaled only by Fable-5, efficient for the price | low effort |
| **Terra** | `-m gpt-5.6-terra` | `medium`\|`high` only | budget non-code work: posting PR comments, routine review passes, test-runner/CI chores | writing product code |
| **Luna** | `-m gpt-5.6-luna` | `high` only | last resort: extremely cheap/quick/limited tasks far from code -- Jira/GitHub issue orchestration, mundane tool-call loops, test fixtures | development of any kind |

Set `model = "gpt-5.6-sol"` in `~/.codex/config.toml` as the default.

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

- **Implement** (clear spec, migrations, mechanical sweeps): `codex exec` with write access,
  in a worktree when anything else touches the checkout.
- **Review** (independent second opinion on a diff/PR): `codex review`, or
  `codex exec -s read-only` with the diff command in the prompt. Findings feed the normal
  review merge; treat as one lane, not the verdict.
- **Adversarial exchange (automatic -- runs on every change, no ask needed)**: the author
  model never solely reviews its own work, and the reviewer comes from a DIFFERENT FAMILY
  whenever possible -- family diversity catches what same-family blind spots share. Claude
  authored the diff -> `GPT-5.6-sol: adversarial` review here (`codex review` / read-only
  exec, medium+ effort, prompt: "try to break this -- failure scenarios, spec drift, missing
  tests; P0-P3 findings only, evidence required"). GPT authored the diff -> Fable/Opus
  reviews (the `/review` panel or `adversarial-reviewer` agent). Same-family clean-context
  review is the fallback ONLY when the other family is unavailable -- record the
  substitution. Terra may take routine re-check rounds after fixes; Sol or Claude owns the
  initial adversarial pass. Findings route back per model routing. `/go` phase 4b invokes
  this automatically.

  **Cross-provider gates (checked before every automatic exchange):**
  - *Authorization*: send code to OpenAI only when the repo opts in -- a `.codex/` directory
    or an AGENTS.md at the repo root is the opt-in signal (the owner configured Codex for
    this codebase). Unclassified/private repos without it -> the adversarial lane is a
    clean-context Claude agent instead; record the substitution.
  - *Minimization*: send the diff, acceptance criteria, and verify commands -- never the
    conversation, secrets, or unrelated files.
  - *Budget*: codex spends plan allowance/credits -- it is cheap relative to Claude tokens,
    not free. Cap the automatic exchange at one codex review per refine round and one per
    PR-iterate round; extra runs need a reason.
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

## Inside workflows and subagents (the wrapper pattern)

The workflow/agent `model` parameter only accepts Claude models. To use GPT-5.6 in a
workflow lane or subagent, spawn a thin Claude wrapper:

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

Judgment-heavy work stays with Fable-5/Opus-4.8: ambiguous decomposition, architecture,
synthesis across conflicting reports, final review of anything that ships. User-facing
output (UI, copy, API design) needs taste >= 7 -- GPT-5.6 (taste 6) drafts, a Claude model
finishes. Never use Haiku for anything.
