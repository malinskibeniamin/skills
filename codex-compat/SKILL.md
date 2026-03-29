---
name: codex-compat
description: Generate Codex-compatible hooks config and AGENTS.md from existing Claude Code hooks. Translates PostToolUse Edit|Write hooks into a Stop-based batch checker since Codex only supports Bash tool matcher. Use when setting up Codex compatibility, dual-agent support, or onboarding Codex users to a repo with Claude Code hooks.
---

# Codex Compatibility Layer

> Codex supports only the `Bash` matcher for PostToolUse — not `Edit|Write`. This skill bridges that gap by wrapping Edit|Write hooks into a Stop-based batch checker.

## What This Sets Up

- **`.codex/hooks.json`** — Codex hook config that maps compatible hooks directly and wraps PostToolUse Edit|Write hooks in a Stop-based batch checker
- **`.codex/hooks/codex-batch-check.sh`** — Stop hook that runs all PostToolUse checks on changed files at end of turn
- **`AGENTS.md`** — Codex instructions file with soft guidance for all enforced rules

## Steps

### 1. Create the batch checker script

Copy [`scripts/codex-batch-check.sh`](scripts/codex-batch-check.sh) into `.codex/hooks/`. Make executable.

### 2. Create `.codex/hooks.json`

Read `.claude/settings.json` and generate the Codex config from [REFERENCE.md](REFERENCE.md). Map:
- PreToolUse Bash → identical
- SessionStart → identical
- Stop → identical + add `codex-batch-check.sh`
- PostToolUse Edit|Write → **omit** (handled by batch checker)

### 3. Generate `AGENTS.md`

Create `AGENTS.md` at repo root using the template from [REFERENCE.md](REFERENCE.md).

### 4. Verify

- [ ] `.codex/hooks.json` exists
- [ ] `.codex/hooks/codex-batch-check.sh` is executable
- [ ] `AGENTS.md` exists at repo root
- [ ] `.claude/settings.json` unchanged
- [ ] All `.claude/hooks/*.sh` scripts still in place

### 5. Commit

Stage `.codex/` and `AGENTS.md`. Commit: `Add Codex compatibility layer for hooks`
