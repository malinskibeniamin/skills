# Registry Workflow Reference

## registry-check.sh

> Script: [`scripts/registry-check.sh`](scripts/registry-check.sh)

## How It Works

The Stop hook runs when Claude finishes a turn. It checks:

1. Were any files in `redpanda-ui/` or `src/redpanda-ui/` modified? (`git diff --name-only HEAD`)
2. If yes — was `registry.json` also modified in the same diff?
3. If `registry.json` was NOT updated → **blocks** with a reminder

If no `redpanda-ui/` directory exists in the repo, the hook exits immediately (zero overhead).

## When It Triggers

| Changed files | registry.json updated? | Result |
|---|---|---|
| `redpanda-ui/button.tsx` | Yes | Pass |
| `redpanda-ui/button.tsx` | No | **Block** — rebuild registry |
| `src/components/UserTable.tsx` | N/A | Pass (not a registry file) |
| No files changed | N/A | Pass |

## Registry Rebuild Steps

When blocked:

1. Run the registry build command: `bun run build:registry`
2. Update `CHANGELOG.md` with the component changes
3. Let Claude finish the turn — the hook will re-check

## Skipping in Non-Registry Repos

The hook auto-detects: if neither `redpanda-ui/` nor `src/redpanda-ui/` exists at the repo root, it exits 0 immediately. No configuration needed to disable it in non-registry projects.
