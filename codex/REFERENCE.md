# Codex Delegation Reference

## Cross-provider review gates

- **Authorization:** send code to OpenAI only when the repo opts in through `.codex/` or a
  root `AGENTS.md`. Otherwise use a clean-context Claude review and record the substitution.
- **Minimization:** send the diff, acceptance criteria, and verify commands, never the
  conversation, secrets, or unrelated files.
- **Budget:** Claude and Codex quotas are separate. Unknown capacity is not a reason to
  guess or lower the quality gate; never substitute `ccusage` or session tokens.
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

Label wrappers `gpt-6-sol: <task>` (or `gpt-6-astra: <task>` on fallback). Parallel implementation requires
`isolation: "worktree"`. Workflow budgets count Claude wrapper tokens; Codex work is
invisible to them.

## Routing notes

Read `config/model-routing.json`. Sol defaults to `medium` and is the second lane behind
Opus 5.5 `high`; higher efforts must be explicit or eval-backed. Astra `high` is the Sol
fallback. User-facing UI, copy, and API work stays with Claude; Astra takes it only when no
Claude owner is available. Luna `high` handles chores and escalates to Sol on judgment. Name
any fallback model in the result.

`ultra` is an agent team, so it needs explicit delegation. Pro mode, persisted reasoning,
programmatic tool calling, and explicit cache controls are API-only unless the current
harness exposes them.

## Adversarial exchange

Adversarial exchange uses a different family whenever authorized. The fallback is a
labeled clean-context Sol pass (Astra on fallback), not a cheaper GPT variant.
