# Codex Delegation Reference

## Cross-provider review gates

- **Authorization:** send code to OpenAI only when the repo opts in through `.codex/` or a
  root `AGENTS.md`. Otherwise use a clean-context Claude review and record the substitution.
- **Minimization:** send the diff, acceptance criteria, and verify commands, never the
  conversation, secrets, or unrelated files.
- **Budget:** Claude and Codex quotas are separate. Keep Codex review on Sol xhigh when its
  subscription meter is unavailable; never substitute `ccusage` or session tokens.
- **Diversity:** the author never solely reviews its own work. Prefer another model family;
  record unavailable cross-family coverage.

## Background execution

```bash
codex exec -s read-only "<prompt>. Write the report to <path>." </dev/null &
```

Always `</dev/null` on background runs. Poll the report through the host monitor rather
than sleeping.

## Claude wrapper

Use a thin wrapper with `model: sonnet` and `effort: low` only when a workflow needs
structured results:

1. Compose the self-contained prompt.
2. Run `codex exec`.
3. Map the report into the requested schema.

Label wrappers `GPT-5.6-sol: <task>`. Parallel implementation requires
`isolation: "worktree"`. Workflow budgets count Claude wrapper tokens; Codex work is
invisible to them.

## Routing notes

- Sol: `gpt-5.6-sol`; xhigh for implementation, plans, and Sol-only review; high for
  adversarial review of Opus work. Override with `-c 'model_reasoning_effort="xhigh"'`.
- Terra: `gpt-5.6-terra`, medium or high; PR comments and test/CI chores only.
- Luna: `gpt-5.6-luna`, `high` only; tracker and remote-tool loops only.
- GPT-5.5 is retired. Name any fallback model in the result.
- User-facing UI, copy, and API work gets a taste-qualified final pass.

## Adversarial exchange

Adversarial exchange (automatic in Claude-hosted ship workflows) uses a DIFFERENT FAMILY
whenever authorized. Opus work gets Sol high; Sol implementation gets Opus 5 xhigh
feedback. Sol-only fallback gets a labeled clean-context xhigh pass.
