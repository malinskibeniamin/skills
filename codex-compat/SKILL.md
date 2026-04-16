---
name: codex-compat
description: Generate Codex hooks.json and AGENTS.md from Claude Code hooks. Wraps Edit|Write checks into Stop batch checker. Use when setting up Codex compatibility or dual-agent support.
---

# Codex Compatibility Layer

Codex supports only `Bash` matcher for PostToolUse — no Edit|Write. This bridges that gap.

## What This Creates

- **`.codex/hooks.json`** — maps compatible hooks directly, wraps Edit|Write into Stop batch checker
- **`.codex/hooks/codex-batch-check.sh`** — Stop hook running all PostToolUse checks on changed files at end of turn
- **`AGENTS.md`** + **`CLAUDE.md`** — shared project rules (Codex reads AGENTS.md, Claude Code reads CLAUDE.md)

## Steps

1. Copy `scripts/codex-batch-check.sh` → `.codex/hooks/`. `chmod +x`.
2. Generate `.codex/hooks.json` from `.claude/settings.json` per [REFERENCE.md](REFERENCE.md):
   - PreToolUse Bash → identical
   - SessionStart → identical
   - Stop → identical + codex-batch-check.sh
   - PostToolUse Edit|Write → **omit** (batch checker handles)
3. Generate `AGENTS.md` + `CLAUDE.md` from [REFERENCE.md](REFERENCE.md) template.

## Verify
- [ ] `.codex/hooks.json` + `.codex/hooks/codex-batch-check.sh` exist
- [ ] `AGENTS.md` + `CLAUDE.md` at repo root
- [ ] `.claude/settings.json` unchanged
