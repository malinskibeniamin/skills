# Redpanda Frontend Kit Reference

## What This Adds Over frontend-starter-kit

| Addition | What it does |
|---|---|
| Chakra UI ban | Blocks `@chakra-ui/react` imports |
| Legacy import ban | Blocks `@redpanda-data/ui` imports |
| `UI_LIB_DIRS` | Sets `components/ui\|redpanda-ui` for hook exclusion |
| `REDPANDA_KIT=1` | Enables registry pattern nudges |
| setup-registry-workflow | Stop hook for registry.json rebuild reminders |

## Registry Pattern Nudges (REDPANDA_KIT=1)

When `REDPANDA_KIT=1` is set, the orchestration-guidance hook adds soft nudges:

| Detected pattern | Nudge |
|---|---|
| `useForm` + ConnectRPC imports | Consider `useProtoForm` for proto-backed forms |
| `<h1>`–`<h6>`, `<p>` raw HTML | Use `Heading`/`Text` from registry |
| Key-value / labels / tags patterns | Consider `KeyValueField` + `BadgeGroup` |

These are warnings, not blocks. They surface registry components Claude wouldn't otherwise know about.

## Redpanda-Specific Environment

Set in `.claude/hooks/session-env.sh`:

```bash
echo "export UI_LIB_DIRS=components/ui|redpanda-ui" >> "$CLAUDE_ENV_FILE"
echo "export REDPANDA_KIT=1" >> "$CLAUDE_ENV_FILE"
```

## Component Import Paths

Redpanda UI Registry components import from `@/components/redpanda-ui/<name>` or `src/components/redpanda-ui/<name>`, not from `@chakra-ui` or `@redpanda-data/ui`.
