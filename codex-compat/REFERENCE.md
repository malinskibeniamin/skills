# Codex Compatibility Reference

## codex-batch-check.sh

Stop hook wrapper — runs all PostToolUse Edit|Write checks on changed files.
Reuses existing `.claude/hooks/` scripts — no duplication.
Handles JS/TS, CSS/SCSS (tailwind-check), package.json (bundle-guard).

> Script: [`scripts/codex-batch-check.sh`](scripts/codex-batch-check.sh)

## .codex/hooks.json template

Generate from existing `.claude/settings.json`. Copy PreToolUse Bash, SessionStart, Stop hooks directly. Add batch checker as Stop hook.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/session-env.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/llm-env.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/user-prompt-context.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/intent-detect.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/enforce-toolchain.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/llm-test-flags.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/conventional-commits-check.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/llm-truncate.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.codex/hooks/codex-batch-check.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0",
            "statusMessage": "Running code quality checks on changed files..."
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/biome-autofix.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/typecheck-stop.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/react-doctor-stop.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/registry-check.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/orchestration-stop.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/test-perf-stop.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/lifecycle-stop.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          },
          {
            "type": "command",
            "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/violation-summary-stop.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0"
          }
        ]
      }
    ]
  }
}
```

**Notes:**
- SessionStart, UserPromptSubmit, PreToolUse Bash hooks work identical on Codex
- Stop hooks work identical on Codex (`decision: "block"` continues turn)
- PostToolUse Edit|Write hooks NOT in `.codex/hooks.json` — `codex-batch-check.sh` auto-discovers all `*-check.sh` scripts, runs at Stop time
- PostToolUse Bash (llm-truncate) works on Codex
- `_hook-lib.sh` must be in `.claude/hooks/` alongside check scripts
- `shared/hook-lib.sh` must be accessible (symlinked or copied) for Stop hooks that source it

## AGENTS.md

Generated at repo root: [`AGENTS.md`](../AGENTS.md). Contains all enforced rules as soft guidance for Codex (replaces PostCompact context re-injection). Customize based on installed skills.