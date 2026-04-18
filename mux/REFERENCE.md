# Mux Reference

## Spawn Command (full)

```bash
branch="$1"; base="${2:-HEAD}"
repo=$(git rev-parse --show-toplevel)
name=$(basename "$repo")
safe=$(printf '%s' "$branch" | tr '/' '-')
path="$(dirname "$repo")/${name}-worktrees/${safe}"

[ -e "$path" ] && { echo "exists: $path"; exit 1; }
git worktree add -b "$branch" "$path" "$base" || exit 1

mkdir -p "$path/.claude"
[ -f "$repo/.claude/settings.local.json" ] && \
  cp "$repo/.claude/settings.local.json" "$path/.claude/settings.local.json"

cat > "$path/.claude/session-hint" <<EOF
worktree=$path
branch=$branch
base=$base
spawned_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

printf 'spawned: %s at %s\ncd %s && claude\n' "$branch" "$path" "$path"
```

## Bind Mechanism

`session-env.sh` hook (SessionStart):

1. `[ -f .claude/session-hint ] || exit 0` — no hint, no bind.
2. Parse `key=value` pairs (no eval; read line-by-line).
3. Export: `MUX_WORKTREE`, `MUX_BRANCH`, `MUX_BASE`, `MUX_SPAWNED_AT`.
4. Verify `git rev-parse --abbrev-ref HEAD` matches `$MUX_BRANCH` — mismatch → warn, do not auto-switch.
5. Inject context prelude so model knows it is in a muxed worktree bound to `<branch>` from `<base>`.
6. Leave session-hint in place (acts as breadcrumb for `--list`).

## State Invariants

- One session-hint per worktree.
- session-hint written atomically (write-temp + rename) to avoid partial reads.
- `git worktree remove` also removes session-hint (lives inside worktree).
- Main working tree never carries session-hint.

## Failure Modes

| Failure | Recovery |
|---|---|
| `worktree add` fails | No rollback needed (nothing created) |
| Copy settings fails | Warn, continue (worktree still usable) |
| session-hint write fails | `git worktree remove <path>` + retry |
| Branch exists already | Pick new name or `/mux clean` |

## Integration

- `/commit-push-pr` reads `MUX_BRANCH` if set, avoids branch detection ambiguity.
- `/canary` writes baseline keyed by `MUX_BRANCH` for isolation.
- `/simplify` honors worktree boundary — won't reach into sibling worktrees.
- `branch-safety-check.sh` reads `bound-branch` written by `session-env.sh` on first run; `/mux` pre-writes it via session-hint.
