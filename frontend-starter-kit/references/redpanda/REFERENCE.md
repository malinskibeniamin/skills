# Redpanda frontend profile reference

## Additions

| Addition | Owner | Completion |
|---|---|---|
| Chakra and legacy UI import bans | Biome `noRestrictedImports` | `bun run lint` rejects both imports |
| Registry-owned path exclusions | `UI_LIB_DIRS=components/ui\|redpanda-ui` | registry files are recognized |
| Canonical product terminology | `REDPANDA_KIT=1` + `/ux-copy` | terminology check passes |
| Registry taxonomy and synchronization | `/registry-workflow` | requested registry operation is verified |

`REDPANDA_KIT=1` gates Redpanda terminology only. Registry guidance comes from
`/registry-workflow` when that branch is requested.

## Component imports

Import from `@/components/redpanda-ui/<name>`. Biome rejects `@chakra-ui/react` and
`@redpanda-data/ui`.

Registry docs: `https://redpanda-ui-registry.netlify.app/docs/<component>`.

| Pattern | Registry component |
|---|---|
| Protobuf-backed form | `useProtoForm` |
| Editable labels, tags, environment variables, or headers | `KeyValueField` + `BadgeGroup` |
| Product typography | `Heading` / `Text` |
| Sortable or filterable rows | `DataTable` |
| Submit/cancel action row | `FormFooter` |

## Linked repositories

Use linked repositories only when the requested work crosses a module-federation or registry
boundary:

```bash
mkdir -p linked-repos
printf 'linked-repos/\n' >> .gitignore
ln -s /path/to/remote/src linked-repos/remote
ln -s /path/to/ui-registry linked-repos/ui-registry
```

Document each link in the repository instructions. When registry source and consumer both
change, `/registry-workflow` owns drift comparison and synchronization.

## Package source

Fetch third-party source matching the lockfile only when API behavior requires source
inspection:

```bash
bunx opensrc zustand
bunx opensrc list
```

## Dependency changes

Biome owns restricted imports. `file-changed-deps.sh` owns manifest and lockfile follow-up;
`/upgrade-dependency` applies only to an actual version-upgrade branch.
