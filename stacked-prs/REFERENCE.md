# Stacked pull requests reference

Use this reference when command syntax, worktree ownership, publication scope, or recovery
matters. GitHub's stack CLI and APIs are preview surfaces; verify drift against the installed
`gh stack --help` and the [official CLI reference](https://docs.github.com/en/pull-requests/reference/stacked-prs-cli-commands).

## Non-interactive command matrix

| Intent | Command | Constraint |
|---|---|---|
| Adopt/create bottom | `gh stack init --base <trunk> <branch>` | Explicit branch required |
| Add top layer | `gh stack add <branch>` | Current branch must be top |
| Navigate | `gh stack checkout <branch>` | Explicit branch or PR required |
| Inspect | `gh stack view --json` | JSON avoids the TUI |
| Publish drafts | `gh stack submit --auto --remote origin` | Publishes all included unsubmitted layers |
| Open for review | `gh stack submit --auto --open --remote origin` | Explicit open intent only |
| Rebase upper layers | `gh stack rebase --upstack --remote origin` | Rewrite authorization required |
| Push stack | `gh stack push --remote origin` | Uses force-with-lease checks |
| Sync after merges | `gh stack sync --prune --remote origin` | May rebase, push, and prune |
| External branches | `gh stack link --base <trunk> --remote origin <bottom> ... <top>` | No local tracking |
| Merge range | `gh stack merge <stack-or-pr> --yes --merge-method <method>` | Explicit merge intent only |

Commands without required branch arguments or `--auto` can prompt. Commands that accept a
remote receive `--remote origin`. Local-only commands do not need a remote; inspect remotes
first rather than relying on auto-detection when several GitHub remotes match.

## Worktree modes

### Native: one worktree per stack

The Conductor workspace switches among stack branches. This lets `gh stack` update or rebase
every branch it owns. Multiple agents may share the workspace only when the user authorized
them and they need the same branch state.

Before a multi-branch mutation, `scripts/stack-worktree-conflicts.sh` compares the branches
from `gh stack view --json` with `git worktree list --porcelain`. Exit 2 means Git would treat
at least one branch as owned elsewhere. The command prints the exact owners and makes no
changes.

### External-link: one worktree per layer

Use `gh stack link` to create, retarget, or link PRs without local stack metadata. This mode
permits parallel workspaces but cannot safely perform a local cascading rebase while those
branches remain checked out. Choose one recovery before a cascade:

1. Finish and archive/free the affected workspaces, then adopt the branches into native mode.
2. Coordinate each workspace manually after a server-side rebase.
3. Keep the stack linked remotely and postpone the cascade.

Never remove, reset, or detach another workspace to make an operation pass.

## Layer boundaries

Order branches by dependency. Schema, shared types, or core contracts sit below their API,
UI, integration, or documentation consumers. Start another layer when scope or reviewer
audience changes, or the current diff is no longer a quick read. A layer may contain several
commits when they form one review unit.

The plan table is:

| Position | Objective | Branch | Parent | Allowed scope | Verification |
|---:|---|---|---|---|---|
| 1 | Foundation | `<branch>` | `<trunk>` | `<paths/behavior>` | `<commands/use>` |

## Publication semantics

`gh stack submit --auto` can publish every included branch that lacks a PR. Therefore:

- `/commit-push-pr` remains current-layer only.
- Explicit `/stacked-prs` submission owns whole-stack publication.
- Draft is the default for automated submission.
- `--open` is a separate ready-for-review decision.
- Inspect the ordered branch list and dirty state immediately before submission.

## Feedback and recovery

Make a fix on the lowest branch that owns the behavior. Verify there, cascade upward, then
re-run affected verification on every rewritten layer. If rebase conflicts:

1. Read the conflict and both layer intents.
2. Resolve and stage the owning files.
3. Run `gh stack rebase --continue` until complete.
4. Use `gh stack rebase --abort` only with explicit abandonment intent.

After a bottom PR merges, sync before further work. Server-created rebase commits may not use
local signing, so repositories that require signed commits should prefer the local CLI path.

## Receipt

```text
Stack: <number or local>  Trunk: <branch>  Mode: <native|external-link>
1. <branch> -> <base>  PR <number/url>  <draft|open|merged>  CI <state>
Current: <position/branch>
Verification: <per-layer evidence>
Worktrees: <clear or branch/path conflicts>
Rewrites: <none or authorized operations>
Next: <bottom-up action>
```
