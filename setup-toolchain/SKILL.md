---
name: setup-toolchain
description: Enforce bun + tsgo as toolchain via PreToolUse hooks. Blocks npm, npx, tsc, global installs. Use when setting up toolchain enforcement or banning npm.
---

# Setup Toolchain Enforcement

## What This Sets Up

- **PreToolUse hooks** blocking banned CLI commands with actionable suggestions
- **Destructive command guards** preventing `rm -rf` (except safe targets like node_modules/.next/dist/build), `git push --force`, `git reset --hard`, and `git checkout .` / `git restore .`
- **SessionStart hook** setting environment variables for LLM-friendly defaults
- All hooks written to `.claude/settings.json` (project-level, committed to git)

## Steps

### 1. Create hook scripts

Copy [`scripts/enforce-toolchain.sh`](scripts/enforce-toolchain.sh) and [`scripts/session-env.sh`](scripts/session-env.sh) into `.claude/hooks/`. Make both executable: `chmod +x .claude/hooks/*.sh`

### 2. Configure hooks in `.claude/settings.json`

Add to hooks config (merge with existing):
- **PreToolUse** (matcher: `Bash`): `.claude/hooks/enforce-toolchain.sh`
- **SessionStart**: `.claude/hooks/session-env.sh`

### 3. Verify

- [ ] `.claude/hooks/enforce-toolchain.sh` exists and is executable
- [ ] `.claude/hooks/session-env.sh` exists and is executable
- [ ] `.claude/settings.json` contains both hook entries
- [ ] Test: run `npm install` in Claude — should be blocked
- [ ] Test: run `bun add lodash` in Claude — should be blocked (missing --yarn)

### 4. Commit

Stage `.claude/hooks/` and `.claude/settings.json`. Commit with: `Add toolchain enforcement hooks (bun + tsgo)`
