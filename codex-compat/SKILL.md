---
name: codex-compat
description: Generate Codex hooks.json and AGENTS.md from Claude Code hooks. Wraps Edit|Write checks into Stop batch checker. Use when setting up Codex compatibility or dual-agent support.
---

# Codex Compatibility Layer

> Codex supports only the `Bash` matcher for PostToolUse — not `Edit|Write`. This skill bridges that gap by wrapping Edit|Write hooks into a Stop-based batch checker.

## What This Sets Up

- **`.codex/hooks.json`** — Codex hook config that maps compatible hooks directly and wraps PostToolUse Edit|Write hooks in a Stop-based batch checker
- **`.codex/hooks/codex-batch-check.sh`** — Stop hook that runs all PostToolUse checks on changed files (JS/TS, CSS/SCSS, package.json) at end of turn
- **`AGENTS.md`** — Codex instructions file with soft guidance for all enforced rules
- **`CLAUDE.md`** — Claude Code instructions file with the same rules (for plugin and manual installs)

## Steps

### 1. Create the batch checker script

Copy [`scripts/codex-batch-check.sh`](scripts/codex-batch-check.sh) into `.codex/hooks/`. Make executable.

### 2. Create `.codex/hooks.json`

Read `.claude/settings.json` and generate the Codex config from [REFERENCE.md](REFERENCE.md). Map:
- PreToolUse Bash → identical
- SessionStart → identical
- Stop → identical + add `codex-batch-check.sh`
- PostToolUse Edit|Write → **omit** (handled by batch checker)

### 3. Generate `AGENTS.md` and `CLAUDE.md`

Create both files at repo root using the template from [REFERENCE.md](REFERENCE.md). Both files contain the same project rules — `AGENTS.md` is read by Codex, `CLAUDE.md` is read by Claude Code.

### 4. Verify

- [ ] `.codex/hooks.json` exists
- [ ] `.codex/hooks/codex-batch-check.sh` is executable
- [ ] `AGENTS.md` exists at repo root
- [ ] `CLAUDE.md` exists at repo root
- [ ] `.claude/settings.json` unchanged
- [ ] All `.claude/hooks/*.sh` scripts still in place

### 5. Commit

Stage `.codex/`, `AGENTS.md`, and `CLAUDE.md`. Commit: `Add Codex compatibility layer for hooks`
