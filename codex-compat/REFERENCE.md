# Codex Compatibility Reference

## codex-batch-check.sh

Stop hook wrapper that runs all PostToolUse Edit|Write checks on changed files.
Reuses the existing `.claude/hooks/` scripts — no duplication.
Handles JS/TS, CSS/SCSS (for tailwind-check), and package.json (for bundle-guard).

> Script: [`scripts/codex-batch-check.sh`](scripts/codex-batch-check.sh)

## .codex/hooks.json template

Generate this from the existing `.claude/settings.json`. Copy PreToolUse Bash, SessionStart, and Stop hooks directly. Add the batch checker as a Stop hook.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/enforce-toolchain.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0",
            "statusMessage": "Checking toolchain..."
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/conventional-commits-check.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0",
            "statusMessage": "Validating commit format..."
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/session-env.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.codex/hooks/codex-batch-check.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0",
            "statusMessage": "Running code quality checks on changed files..."
          }
        ]
      }
    ]
  }
}
```

**Notes:**
- PreToolUse Bash hooks work identically on Codex (same JSON format, same `permissionDecision` output)
- SessionStart hooks work identically on Codex
- Stop hooks work identically on Codex (`decision: "block"` continues the turn)
- PostToolUse Edit|Write hooks are NOT in `.codex/hooks.json` — the batch checker handles them
- `_hook-lib.sh` must be in `.claude/hooks/` alongside the check scripts

## AGENTS.md

Generated at repo root: [`AGENTS.md`](../AGENTS.md). Contains all enforced rules as soft guidance for Codex (replaces PostCompact context re-injection). Customize based on installed skills.
