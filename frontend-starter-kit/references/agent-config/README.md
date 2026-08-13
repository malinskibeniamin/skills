# Setup LLM Optimization
## What This Sets Up

- **SessionStart**: `AI_AGENT=1`, `CLAUDECODE=1`, `NODE_OPTIONS=--max-old-space-size=8192`
- **UserPromptSubmit**: inject project state (git branch, dirty files, scripts, violations, config) -> Claude know state, no tool calls
- **PreToolUse (Bash)**: optimize Vitest and Rstest commands -- bound verbose
  output, suggest `--bail=1`, and keep Vitest-specific `--pool=threads` and
  `--teardownTimeout=5000` guidance
- **PostToolUse (Bash)**: truncate verbose output, cut context bloat

## Steps

1. Copy `scripts/llm-env.sh`, `scripts/llm-test-flags.sh`, `scripts/llm-truncate.sh` -> `.claude/hooks/`. `chmod +x`.
2. Configure in `.claude/settings.json`:
   - SessionStart: `llm-env.sh`
   - PreToolUse (Bash): `llm-test-flags.sh`
   - PostToolUse (Bash): `llm-truncate.sh`

## Verify
- [ ] `AI_AGENT`/`CLAUDECODE` set after session start
- [ ] `vitest --verbose` rewrite to `vitest`
- [ ] `rstest --reporters=verbose` rewrite to `rstest --reporters=md`
- [ ] Long output truncated

See [REFERENCE.md](REFERENCE.md) for runner-specific optimizations.
