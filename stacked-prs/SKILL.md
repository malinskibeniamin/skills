---
name: stacked-prs
description: Create and manage dependent GitHub pull requests with gh stack. Use for stacked PRs, dependent branch chains, incremental review layers, or splitting a large change into ordered PRs.
---

# Stacked pull requests

Use GitHub's `gh stack` CLI while preserving harness review, worktree, and delivery
contracts. Read [REFERENCE.md](REFERENCE.md) for the version-sensitive command matrix,
external-link mode, recovery, and status receipt.

## Contract

- **Objective:** every layer is independently reviewable against the branch below it.
- **Guardrails:** one Conductor workspace owns one stack; unrelated work uses another stack;
  global installs, shared-branch rewrites, publication, and merge honor user intent.
- **Verification:** test each layer, review `<parent>...HEAD`, then report
  `gh stack view --json`.
- **Stop:** respect the requested plan, local, push, draft, open, or merge endpoint.

## 1. Establish the mode

Check `gh`, authentication, repository support, the current branch, remotes, cleanliness, and
`git worktree list --porcelain`. If the extension is absent, give
`gh extension install github/gh-stack`; do not install it without permission. This harness
pushes to `origin`; with multiple remotes, pass `--remote origin` to every supported command.

Default to **native mode**: one workspace owns the whole stack and switches branches. Before
`add`, `checkout`, `rebase`, `sync`, `modify`, or `push`, run:

```bash
"${CLAUDE_PLUGIN_ROOT:-.}/scripts/stack-worktree-conflicts.sh"
```

Exit 2 lists `branch<TAB>path` for stack branches owned by other worktrees. Report them; do
not remove a worktree, steal its branch, or cascade locally.

Use **external-link mode** only for deliberate worktree-per-layer workflows. Publish with
`gh stack link --base <trunk> --remote origin <bottom> ... <top>`. Coordinate or free those
worktrees before any local cascade.

## 2. Plan and develop

Before code, show a bottom-to-top table: objective, branch, parent, allowed scope, and
verification per layer. Dependencies belong in the same or a lower layer. Confirm boundaries
proposed by the agent; explicit user-owned boundaries need no second approval.

Require a clean tree for structural commands. Adopt or create the bottom with
`gh stack init --base <trunk> <bottom-branch>`. Implement through RED -> GREEN -> REFACTOR,
verify, and commit deliberately. Add a coherent next concern with
`gh stack add <next-branch>`. Use explicit branch names and standard `git add`/`git commit`;
avoid `-A` shortcuts that blur layer ownership.

Navigate with `gh stack checkout <branch>` and inspect with `gh stack view --json`.
Argumentless commands and TUI output are not agent-safe.

## 3. Review and publish

```bash
BASE=$("${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")
git diff "$BASE"...HEAD
git log "$BASE"..HEAD --oneline
```

Run applicable verification and dogfood for the current layer. Inspect every branch before
publication; stop if submission includes unintended or unfinished work. Explicit whole-stack
submission creates drafts by default: `gh stack submit --auto --remote origin`. Add `--open`
only when the user requested ready-for-review PRs. A single-PR request never authorizes
publishing other unsubmitted layers.

## 4. Feedback, sync, and merge

Fix feedback on its owning branch and verify it. Explain that cascading rewrites upper
branches: a force-with-lease requires explicit authorization. Then use
`gh stack rebase --upstack --remote origin` followed by `gh stack push --remote origin`.
`gh stack sync --prune --remote origin` uses the same authorization boundary.

Continue a resolved conflict with `gh stack rebase --continue`. Abort only when the user asks
to abandon the operation. External-link mode must first coordinate its worktrees.

Never merge as a publication side effect. Explicit merge intent authorizes only the named
contiguous range. Recheck approvals, checks, linear history, comments, and todos; then use
`gh stack merge <stack-or-pr> --yes --merge-method <squash|rebase|merge>`, never
`gh pr merge`.

Finish with trunk, ordered layers, current layer, PR URLs/states, per-layer verification,
worktree conflicts, rewrites performed, and the next bottom-up action.
