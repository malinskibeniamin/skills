---
name: setup-llm-optimization
description: Configure Claude Code hooks for token-efficient AI agent workflows. Sets LLM-friendly env vars, injects agent reporter flags on test commands, and truncates verbose output. Use when optimizing Claude Code for fewer tokens, reducing context waste, or configuring AI-friendly test output.
---

# Setup LLM Optimization

## What This Sets Up

- **SessionStart hook** setting `AI_AGENT=1` and `CLAUDECODE=1` for LLM-friendly test output
- **PreToolUse hook** auto-injecting agent reporter flags on test commands
- **PostToolUse hook** truncating verbose bash output to reduce context bloat

## Steps

### 1. Create hook scripts

Write scripts from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`:

- `llm-env.sh` — SessionStart: sets AI_AGENT, CLAUDECODE env vars
- `llm-test-flags.sh` — PreToolUse on Bash: blocks `--verbose` flag on test runners
- `llm-truncate.sh` — PostToolUse on Bash: truncates output >200 lines

Make all executable.

### 2. Configure hooks in `.claude/settings.json`

Merge these entries (preserve existing):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": ".claude/hooks/llm-env.sh" }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/llm-test-flags.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/llm-truncate.sh" }
        ]
      }
    ]
  }
}
```

### 3. Verify

- [ ] All hook scripts are executable
- [ ] `AI_AGENT` and `CLAUDECODE` are set after session start
- [ ] `bun test --verbose` is blocked
- [ ] Long output is truncated

### 4. Commit

Stage and commit: `Add LLM optimization hooks (env vars, test flags, output truncation)`
