## Codex-specific

### Commits

`type(scope): description` -- feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert. Scope required. Lowercase, 5-72 chars. (Codex has no conventional-commits deny hook on every event; state the format here.)

### Runtime notes

- Hooks arrive per-call; `codex-edit-dispatch.sh` adapts edits to the shared batch protocol.
- `process.env` allowed only in build/test configs; app code goes through `@/env`.
- Subagent output enforcement is best effort; follow `agents/references/findings-schema.md` for review findings.

### Code exploration

- Follow repo-root `shared/repo-navigation.md` for source precedence, TraceDecay exploration, and bounded fallback.
- Treat TraceDecay savings as local estimates, not Codex usage, quota, or billing evidence. In linked worktrees, confirm the active project and branch before relying on graph results.

### Native delegation

- In native Codex, do not spawn subagents or start a recursive `codex exec` unless the user explicitly requests subagents, delegation, parallel agent work, or invokes `/swarm`. Skill activation alone is not consent. `/work`, `/go`, `/review`, `/grilling`, `/resilience-review`, and `/plow-ahead` do not grant it.
- Without consent, run required review and planning axes inline in the root context. Report them as inline, never independent or cross-family. Parallel shell and tool calls remain allowed.
- Spawned agents may not create descendants without separate authorization for nested delegation.
- Preserve the user's selected model and reasoning effort. Do not rewrite Codex config or enable experimental multi-agent flags as part of this policy.

### Native stop boundaries

- Honor the endpoint-aware execution contract above. A well-scoped build/fix/implement
  request continues after its concise plan through commit and push; an explicit local,
  no-commit, or no-push instruction stops earlier. Stop for plan approval only when the user
  requested planning/grilling or a material reserved decision remains.
- A PR request ends after one CI status snapshot; ship and `/go` also never wait for
  CI/reviews/approvals. Follow `shared/review-enforcement.md`; preserve hosted merge policy.
  Monitoring and feedback need explicit scope; `/plow-ahead` is not delegation consent.
- `ccusage` token/cost reports are not Codex subscription-quota evidence. Use a host meter or user-reported value; otherwise usage is unknown and report `Codex usage unavailable to the harness`. Never infer quota from session tokens. Do not guess reset time. Keep the owner-selected Opus/Sol `xhigh` routes; unknown usage never invents a 50% effort gate. Authorized unknown-usage agent waves checkpoint after one explicitly requested wave.
