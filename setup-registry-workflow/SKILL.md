---
name: setup-registry-workflow
description: Stop hook reminding to rebuild registry.json and update changelog when UI components change. Use when maintaining a shadcn component registry or design system.
---

# Setup Registry Workflow

## What This Sets Up

- **Stop hook** that checks if redpanda-ui component files were modified without updating `registry.json`
- Reminds to rebuild registry and update changelog

## Steps

### 1. Create hook script

Copy [`scripts/registry-check.sh`](scripts/registry-check.sh) into `.claude/hooks/`. Make executable.

### 2. Configure Stop hook in `.claude/settings.json`

```json
{
  "hooks": {
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

- [ ] Hook is executable
- [ ] Modifying a file in redpanda-ui/ without touching registry.json triggers reminder

Commit: `Add registry workflow reminder hook`
