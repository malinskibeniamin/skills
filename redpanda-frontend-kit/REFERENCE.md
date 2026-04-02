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

## UI Registry Documentation Injection

When `REDPANDA_KIT=1`, the orchestration-guidance hook can surface registry component documentation. For each component used, Claude should reference:

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

For projects using Module Federation (host app loading federated remotes), set up symlinks so Claude can read all frontend source transparently:

```bash
mkdir -p linked-repos && echo "linked-repos/" >> .gitignore
ln -s /path/to/remote-app-1/src linked-repos/remote-1
ln -s /path/to/remote-app-2/src linked-repos/remote-2
```

Claude follows symlinks transparently — it reads `linked-repos/remote-1/routes/...` as if it were a local directory. Add to your project's `CLAUDE.md`:

```markdown
linked-repos/ contains symlinks to federated remotes:
- linked-repos/remote-1/ → First remote app source
- linked-repos/remote-2/ → Second remote app source
When working on federated routes, read both host and remote source.
```

## UI Registry Symlink (Component Synchronization)

Symlink the UI registry repo so Claude can modify registry components alongside consumer changes:

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

When `REDPANDA_KIT=1`, the orchestration-guidance hook nudges on registry component edits to also update the upstream registry source and open a PR.

## Package Source Code (opensrc)

For understanding third-party package internals (not your team's code), use [opensrc](https://github.com/vercel-labs/opensrc):

```bash
npx opensrc zustand          # fetches source matching your lockfile version
npx opensrc @tanstack/react-query
opensrc list                  # show fetched packages
```

Creates `opensrc/<package>/` with full source. Useful when Claude needs to understand framework internals during debugging.

## Dependency Change Awareness

When Claude updates packages in `package.json`, it should:

1. **Check the changelog** — `gh release view <version> --repo <owner/repo>` or npm changelog
2. **Check for breaking changes** — especially major version bumps
3. **Check for security advisories** — `npm audit` or Snyk
4. **Read migration guides** — for major framework upgrades (React 18→19, Zustand 4→5, etc.)

This is enforced by the `bundle-guard.sh` hook for known-heavy deps, and by `orchestration-guidance.sh` which nudges on package.json changes.
