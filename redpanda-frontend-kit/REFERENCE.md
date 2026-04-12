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
| `<h1>`–`<h6>`, `<p>` raw HTML | Use `Heading`/`Text` from registry |
| Key-value / labels / tags patterns | Consider `KeyValueField` + `BadgeGroup` |

Warnings, not blocks. Surface registry components Claude wouldn't know.

## Redpanda-Specific Environment

Set in `.claude/hooks/session-env.sh`:

```bash
echo "export UI_LIB_DIRS=components/ui|redpanda-ui" >> "$CLAUDE_ENV_FILE"
echo "export REDPANDA_KIT=1" >> "$CLAUDE_ENV_FILE"
```

## Component Import Paths

Import from `@/components/redpanda-ui/<name>`, not `@chakra-ui` or `@redpanda-data/ui`.

## UI Registry Documentation Injection

When `REDPANDA_KIT=1`, reference for each component:

- **Registry docs**: `https://redpanda-ui-registry.netlify.app/docs/<component>`
- **Available patterns**: key-value, proto-form, form-footer, dialog, data-table
- **Component props/variants**: check the registry playground for correct usage

### Key Registry Patterns

| Pattern | When to use | Registry URL |
|---|---|---|
| `useProtoForm` | Forms backed by ConnectRPC/protobuf schemas | `/docs/use-proto-form` |
| `KeyValueField` + `BadgeGroup` | Editable labels, tags, env vars, HTTP headers | `/docs/patterns/key-value` |
| `Heading` / `Text` | All text — never raw `<h1>`-`<h6>` or `<p>` | `/docs/components/heading` |
| `DataTable` | Sortable, filterable tabular data | `/docs/components/data-table` |
| `FormFooter` | Consistent submit/cancel button layout | `/docs/components/form-footer` |

## Cross-Repo Visibility (Module Federation)

For Module Federation, symlink remotes for Claude visibility:

```bash
mkdir -p linked-repos && echo "linked-repos/" >> .gitignore
ln -s /path/to/remote-app-1/src linked-repos/remote-1
ln -s /path/to/remote-app-2/src linked-repos/remote-2
```

Claude follows symlinks transparently. Add to `CLAUDE.md`:

```markdown
linked-repos/ contains symlinks to federated remotes:
- linked-repos/remote-1/ → First remote app source
- linked-repos/remote-2/ → Second remote app source
When working on federated routes, read both host and remote source.
```

## UI Registry Symlink (Component Synchronization)

Symlink UI registry for cross-repo edits:

```bash
ln -s /path/to/ui-registry linked-repos/ui-registry
```

Add to `CLAUDE.md`:

```markdown
linked-repos/ui-registry/ → UI Registry source (symlinked)
When modifying a component from @/components/redpanda-ui/, also update
the source in linked-repos/ui-registry/ to keep both in sync.
After changes, open a PR against the ui-registry repo.
```

When `REDPANDA_KIT=1`, orchestration-guidance nudges to update upstream registry + PR.

## Package Source Code (opensrc)

For third-party package source, use [opensrc](https://github.com/vercel-labs/opensrc):

```bash
npx opensrc zustand          # fetches source matching your lockfile version
npx opensrc @tanstack/react-query
opensrc list                  # show fetched packages
```

Creates `opensrc/<package>/` with full source for debugging framework internals.

## Dependency Changes

Handled by `bundle-guard.sh` (heavy deps) + `orchestration-guidance.sh` (package.json nudge).
