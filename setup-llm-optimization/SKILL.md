---
name: setup-llm-optimization
description: Token-efficient AI agent hooks — env vars, test flag optimization, output truncation, NODE_OPTIONS. Use when optimizing Claude Code for fewer tokens or reducing context waste.
---

# Setup LLM Optimization

## What This Sets Up

- **SessionStart hook** setting `AI_AGENT=1`, `CLAUDECODE=1`, and `NODE_OPTIONS=--max-old-space-size=8192`
- **PreToolUse hook** optimizing test commands:
  - Strip `--verbose` (hard enforcement via `updatedInput` rewrite — wastes tokens)
  - Suggest `--pool=forks` (prevents zombie processes)
  - Suggest `--bail=1` (fail fast, save tokens)
  - Suggest `--teardownTimeout=5000` (prevent hanging teardown)
  - Suggest `--reporter=github` in CI
  - Jest: suggest `--bail --forceExit`
- **PostToolUse hook** truncating verbose bash output to reduce context bloat

## Steps

### 1. Create hook scripts

Copy [`scripts/llm-env.sh`](scripts/llm-env.sh), [`scripts/llm-test-flags.sh`](scripts/llm-test-flags.sh), and [`scripts/llm-truncate.sh`](scripts/llm-truncate.sh) into `.claude/hooks/`. Make all executable.

### 2. Configure hooks in `.claude/settings.json`

Add to hooks config (merge with existing):
- **SessionStart**: `.claude/hooks/llm-env.sh`
- **PreToolUse** (matcher: `Bash`): `.claude/hooks/llm-test-flags.sh`
- **PostToolUse** (matcher: `Bash`): `.claude/hooks/llm-truncate.sh`

### 3. Verify

- [ ] All hook scripts are executable
- [ ] `AI_AGENT` and `CLAUDECODE` are set after session start
- [ ] `bun test --verbose` is silently rewritten to `bun test` (verbose stripped)
- [ ] `bun test` triggers suggestions for `--pool=forks`, `--bail=1`, `--teardownTimeout=5000`
- [ ] `NODE_OPTIONS=--max-old-space-size=8192` is set after session start
- [ ] Long output is truncated

See [REFERENCE.md](REFERENCE.md) for vitest config optimizations and test runner tuning.

### 4. Commit

Stage and commit: `Add LLM optimization hooks (env vars, test flags, output truncation)`
