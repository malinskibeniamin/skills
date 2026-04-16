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

When `REDPANDA_KIT=1`, orchestration-guidance adds nudges:

| Detected pattern | Nudge |
|---|---|
| `useForm` + ConnectRPC imports | Consider `useProtoForm` for proto-backed forms |
| `<h1>`--`<h6>`, `<p>` raw HTML | Use `Heading`/`Text` from registry |
| Key-value / labels / tags patterns | Consider `KeyValueField` + `BadgeGroup` |

Warnings, not blocks. Surface registry components Claude wouldn't know.

## Redpanda-Specific Environment

Set in `.claude/hooks/session-env.sh`:

```bash
echo "export UI_LIB_DIRS=components/ui|redpanda-ui" >> "$CLAUDE_ENV_FILE"
echo "export REDPANDA_KIT=1" >> "$CLAUDE_ENV_FILE"
```

## Component Import Paths

Import from `@/components/redpanda-ui/<name>`. Never `@chakra-ui` or `@redpanda-data/ui`.

## UI Registry Docs

Registry docs: `https://redpanda-ui-registry.netlify.app/docs/<component>`

### Key Patterns

| Pattern | When to use | Registry URL |
|---|---|---|
| `useProtoForm` | Forms backed by ConnectRPC/protobuf schemas | `/docs/use-proto-form` |
| `KeyValueField` + `BadgeGroup` | Editable labels, tags, env vars, HTTP headers | `/docs/patterns/key-value` |
| `Heading` / `Text` | All text — never raw `<h1>`-`<h6>` or `<p>` | `/docs/components/heading` |
| `DataTable` | Sortable, filterable tabular data | `/docs/components/data-table` |
| `FormFooter` | Consistent submit/cancel button layout | `/docs/components/form-footer` |

## Cross-Repo Visibility (Module Federation)

Symlink remotes so Claude can read them:

```bash
mkdir -p linked-repos && echo "linked-repos/" >> .gitignore
ln -s /path/to/remote-app-1/src linked-repos/remote-1
```

Document in `CLAUDE.md`. Claude follows symlinks transparently.

## UI Registry Symlink

```bash
ln -s /path/to/ui-registry linked-repos/ui-registry
```

When modifying `@/components/redpanda-ui/`, also update `linked-repos/ui-registry/`. With `REDPANDA_KIT=1`, orchestration nudges upstream PR.

## Package Source Code (opensrc)

[opensrc](https://github.com/vercel-labs/opensrc) fetches third-party source matching lockfile version:

```bash
npx opensrc zustand
opensrc list
```

## Dependency Changes

Handled by `bundle-guard.sh` (heavy deps) + `orchestration-guidance.sh` (package.json nudge).
