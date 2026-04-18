---
name: mux
description: "Use when user invokes /mux to spawn a git worktree, branch, and bound Claude session atomically. Handles branch-name validation, worktree creation, settings copy, session-hint write, and launch. Also /mux --list and /mux clean."
---

# Mux — Worktree + Branch + Session Spawn

Atomic spawn: branch + worktree + pre-bound session.

## Invocation

- `/mux <branch-name>` — from current HEAD
- `/mux <branch-name> --from <base>` — from `<base>`
- `/mux --list` — active worktrees + bindings
- `/mux clean` — prune stale worktrees

## Spawn Workflow

### 1. Validate Branch Name
Conventional pattern: `^(feat|fix|chore|docs|refactor|test|perf|ci|build)\/[a-z0-9][a-z0-9-]*$`. Fail → print pattern, exit.

### 2. Resolve Paths
Repo root: `git rev-parse --show-toplevel`. Repo name: basename. Worktree path: `../<repo>-worktrees/<branch-with-slashes-as-dashes>`. Path exists → fail with hint to `/mux clean` or pick new name.

### 3. Base Resolution
`--from <base>` → `git rev-parse --verify <base>`. Else current HEAD. Unverified → fail.

### 4. Create Worktree
`git worktree add -b <branch> <path> <base>`. Any error → abort, no partial state.

### 5. Copy Local Settings
`cp <repo>/.claude/settings.local.json <path>/.claude/settings.local.json` (if source exists). mkdir `.claude/` in target first.

### 6. Write Session Hint
`<path>/.claude/session-hint` contains:

    worktree=<path>
    branch=<branch>
    base=<base>
    spawned_at=<iso8601>

`session-env.sh` hook reads this on next session start to pre-bind `MUX_*` env vars.

### 7. Print Launch Hint

    spawned: <branch> at <path>
    cd <path> && claude

Do not auto-launch — user controls.

## --list Mode

`git worktree list --porcelain` → parse → table:

    | Path | Branch | Base | Bound? |
    |---|---|---|---|
    | ../repo-wt/feat-x | feat/x | main | yes (session-hint) |

"Bound?" = session-hint file present.

## clean Mode

1. `git worktree list --porcelain` — enumerate.
2. Per worktree: check branch merged into default (`git branch --merged`) AND no uncommitted changes (`git -C <path> status --porcelain`).
3. Both clean → propose prune. Prompt user per worktree. Confirm → `git worktree remove <path>`.
4. Skip the main working tree always.

## Safety

- Never remove worktree with uncommitted changes without `--force` + explicit user confirm.
- Never touch main working tree.
- Branch-name validation blocks path traversal (`..`, `/`).
- session-hint is plaintext, non-executable — treat as data.

See [REFERENCE.md](REFERENCE.md) for spawn command details + bind mechanism.
