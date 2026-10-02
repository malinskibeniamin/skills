# Codex Delegation Reference

## Cross-provider review gates

- **Authorization:** send code to OpenAI only when the repo opts in through `.codex/` or a
  root `AGENTS.md`. Otherwise use a clean-context Claude review and record the substitution.
- **Minimization:** send the diff, acceptance criteria, and verify commands, never the
  conversation, secrets, or unrelated files.
- **Budget:** Claude and Codex quotas are separate. Unknown capacity is not a reason to
  guess or lower the quality gate; never substitute `ccusage` or session tokens.
- **Diversity:** for an authorized independent review, prefer Sol for Opus work and Opus
  for Sol work. Label clean-context fallbacks and disclose missing different-family coverage.

## Background execution

```bash
codex exec -s read-only "<prompt>. Write the report to <path>." </dev/null &
```

Always `</dev/null` on background runs. Poll the report through the host monitor rather
than sleeping.

## Claude wrapper

Use a thin wrapper inheriting the Opus owner and its `xhigh` effort only when a workflow
needs structured results:

1. Compose the self-contained prompt.
2. Run `codex exec`.
3. Map the report into the requested schema.

Label wrappers `gpt-6.1-sol: <task>`; label unavailable-family review fallbacks
`claude-opus-5-5: <task>`. Parallel implementation requires
`isolation: "worktree"`. Workflow budgets count Claude wrapper tokens; Codex work is
invisible to them.

## Routing notes

Read `config/model-routing.json`. Opus 5.5 `xhigh` is the daily/UI owner; Sol `xhigh`
is the preferred reviewer and explicitly selected Codex execution lane. Keep chores on
Opus. If Sol is unavailable, use a labeled clean-context Opus `xhigh` review and disclose
missing different-family coverage. If Opus is unavailable for UI, report the lane blocked.
Route only the Opus/Sol pair; never silently lower effort or substitute another model.
If neither is available, report the lane blocked. The owner's preference does not authorize delegation.

`ultra` is an agent team, so it needs explicit delegation. Pro mode, persisted reasoning,
programmatic tool calling, and explicit cache controls are API-only unless the current
harness exposes them.

## Adversarial exchange

Adversarial exchange uses a different family whenever authorized. The fallback is a
labeled clean-context pass within the Opus/Sol pair, with missing different-family coverage disclosed.
