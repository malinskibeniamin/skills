---
name: setup-agent-config
description: Token-efficient AI agent hooks — env vars, test flag optimization, output truncation, NODE_OPTIONS. Use when optimizing Claude Code for fewer tokens or reducing context waste.
---

# Setup LLM Optimization

## What This Sets Up

- **SessionStart**: `AI_AGENT=1`, `CLAUDECODE=1`, `NODE_OPTIONS=--max-old-space-size=8192`
- **UserPromptSubmit**: injects project state (git branch, dirty files, scripts, violations, config) → Claude knows state without tool calls
- **PreToolUse (Bash)**: optimizes vitest commands — strips `--verbose`, suggests `--pool=forks`, `--bail=1`, `--teardownTimeout=5000`. Also handles jest/bun test (backward compat)
- **PostToolUse (Bash)**: truncates verbose output to reduce context bloat

## Steps

1. Copy `scripts/llm-env.sh`, `scripts/llm-test-flags.sh`, `scripts/llm-truncate.sh` → `.claude/hooks/`. `chmod +x`.
2. Configure in `.claude/settings.json`:
   - SessionStart: `llm-env.sh`
   - PreToolUse (Bash): `llm-test-flags.sh`
   - PostToolUse (Bash): `llm-truncate.sh`

## Verify
- [ ] `AI_AGENT`/`CLAUDECODE` set after session start
- [ ] `vitest --verbose` rewritten to `vitest`
- [ ] Long output truncated

See [REFERENCE.md](REFERENCE.md) for vitest config optimizations.
