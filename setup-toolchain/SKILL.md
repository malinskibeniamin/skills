---
name: setup-toolchain
description: Configure Claude Code hooks to enforce bun as package manager and tsgo as TypeScript compiler. Blocks npm, npx, tsc, global installs, and direct bunx for scripted tools. Use when setting up frontend toolchain enforcement, banning npm, or configuring package manager hooks.
---

# Setup Toolchain Enforcement

## What This Sets Up

- **PreToolUse hooks** blocking banned CLI commands with actionable suggestions
- **SessionStart hook** setting environment variables for LLM-friendly defaults
- All hooks written to `.claude/settings.json` (project-level, committed to git)

## Steps

### 1. Create hook scripts

Write the scripts from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`:

- `enforce-toolchain.sh` — PreToolUse: blocks npm/npx/tsc/global installs, ensures --yarn flag, blocks direct bunx for scripted tools
- `session-env.sh` — SessionStart: sets PKG_MANAGER, LINTER, TEST_RUNNER, AI_AGENT, CLAUDECODE

Make both executable: `chmod +x .claude/hooks/*.sh`

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
