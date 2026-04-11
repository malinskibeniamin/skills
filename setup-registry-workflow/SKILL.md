---
name: setup-registry-workflow
description: Stop hook reminding to rebuild registry.json and update changelog when UI components change. Use when maintaining a shadcn component registry or design system.
---

# Setup Registry Workflow

## What This Sets Up

- **PostToolUse hook** (`ui-registry-warn.sh`) that warns once per session when editing files in UI component directories (`components/ui/`, `redpanda-ui/`, etc.), prompting you to open a PR against the upstream UI registry
- **Stop hook** (`registry-check.sh`) that blocks if redpanda-ui component files were modified without updating `registry.json` and `CHANGELOG.md`

## Steps

### 1. Create hook scripts

Copy both scripts into `.claude/hooks/`. Make executable.

- [`scripts/ui-registry-warn.sh`](scripts/ui-registry-warn.sh) — real-time warning on Edit/Write
- [`scripts/registry-check.sh`](scripts/registry-check.sh) — Stop-phase enforcement

### 2. Configure hooks in `.claude/settings.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/ui-registry-warn.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0" }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "f=$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/registry-check.sh; [ -x \"$f\" ] && exec \"$f\"; exit 0" }
        ]
      }
    ]
  }
}
```

### 3. Verify & Commit

- [ ] Both hooks are executable
- [ ] Editing a file in `components/ui/` or `redpanda-ui/` triggers the real-time warning
- [ ] Modifying a file in `redpanda-ui/` without touching `registry.json` triggers the Stop block

Commit: `Add UI registry workflow hooks`
