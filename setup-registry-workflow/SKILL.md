---
name: setup-registry-workflow
description: Stop hook reminding to rebuild registry.json and update changelog when UI components change. Use when maintaining a shadcn component registry or design system.
---

# Setup Registry Workflow

- **PostToolUse hook** (`ui-registry-warn.sh`): warns once/session when editing UI component dirs, prompts upstream PR
- **Stop hook** (`registry-check.sh`): blocks if redpanda-ui modified without updating `registry.json` + `CHANGELOG.md`

## Steps

1. Copy `scripts/ui-registry-warn.sh` + `scripts/registry-check.sh` → `.claude/hooks/`. `chmod +x`.
2. Configure in `.claude/settings.json`:
   - PostToolUse (Edit|Write): `ui-registry-warn.sh`
   - Stop: `registry-check.sh`

## Verify
- [ ] Both hooks executable
- [ ] Editing `components/ui/` or `redpanda-ui/` triggers warning
- [ ] Modifying `redpanda-ui/` without `registry.json` update → Stop block
