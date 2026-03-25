---
name: setup-registry-workflow
description: Configure Claude Code Stop hook to remind about registry.json rebuild and changelog update when redpanda-ui components are modified. Use when maintaining a shadcn component registry, updating design system components, or enforcing registry build discipline.
---

# Setup Registry Workflow

## What This Sets Up

- **Stop hook** that checks if redpanda-ui component files were modified without updating `registry.json`
- Reminds to rebuild registry and update changelog

## Steps

### 1. Create hook script

Write `registry-check.sh` from [REFERENCE.md](REFERENCE.md) into `.claude/hooks/`. Make executable.

### 2. Configure Stop hook in `.claude/settings.json`

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": ".claude/hooks/registry-check.sh" }
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
