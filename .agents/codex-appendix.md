## Codex-specific

### Commits

`type(scope): description` -- feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert. Scope required. Lowercase, 5-72 chars. (Codex has no conventional-commits deny hook on every event; state the format here.)

### Runtime notes

- Hooks arrive per-call (no PostToolBatch); behavior is generated to parity from skill-manifest.json.
- `process.env` allowed only in build/test configs; app code goes through `@/env`.
- Subagent output enforcement is best effort; follow `agents/references/findings-schema.md` for review findings.

### Native delegation

- In native Codex, do not spawn subagents or start a recursive `codex exec` unless the user explicitly requests subagents, delegation, parallel agent work, or invokes `/swarm`. Skill activation alone is not consent. `/work`, `/go`, `/review`, `/grilling`, `/resilience-review`, and `/plow-ahead` do not grant it.
- Without consent, run required review and planning axes inline in the root context. Report them as inline, never independent or cross-family. Parallel shell and tool calls remain allowed.
- Spawned agents may not create descendants without separate authorization for nested delegation.
- Preserve the user's selected model and reasoning effort. Do not rewrite Codex config or enable experimental multi-agent flags as part of this policy.

### Native stop boundaries

- Honor any user-supplied earlier stop point. Otherwise, stop after plan and grilling before edits; after implementation approval, stop after opening the PR, handling the first automated review/fix pass, and taking one CI status snapshot.
- `/plow-ahead` may waive milestone stops, but it is not delegation consent. Do not poll for later human feedback unless the user asks.
- `ccusage` measures Claude usage, not Codex. Use a host-provided Codex meter or a user-reported value; otherwise report `Codex usage unavailable to the harness`. Never infer subscription usage from session tokens or guess a reset time. When usage is unknown, allow at most one explicitly requested agent wave before a checkpoint.
