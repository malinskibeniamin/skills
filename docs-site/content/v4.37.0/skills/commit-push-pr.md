---
title: "/commit-push-pr"
description: "Commit, push, and open a reviewable PR. Use for commit-only, commit-and-push, PR creation, or updating an existing branch; --no-pr stops after push."
type: skill
sidebar:
  label: "/commit-push-pr"
---
![Diagram of the /commit-push-pr skill](/diagrams/skills/commit-push-pr.svg)

[Open the editable Excalidraw source](/diagrams/skills/commit-push-pr.excalidraw)

Read [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/commit-push-pr/REFERENCE.md) for review prerequisites, commit types, labels, body
template, screenshots, and dependency-upgrade sections.

## Preflight

1. Run `git status -sb`, `git diff HEAD`, `git branch --show-current`,
   `git log --oneline -5`, and inspect any PR already open from this branch.
2. Resolve the requested endpoint: commit only, push (`--no-pr`), or PR. Commit-only skips remote and `gh` preflight.
3. Push/PR only: verify an accessible remote. PR only: resolve the default branch with
   `gh repo view`, then verify `gh` is installed and authenticated.
4. PR only: detect local stack membership with `gh stack view --json`; if a PR already exists, also
   inspect its `baseRefName` and REST `stack` object. A normal PR endpoint owns the current
   layer only. It never authorizes `gh stack submit`, which may publish other branches.
5. PR only: run applicable review axes inline; do not block merely because a named review
   skill was not invoked.
6. PR only: runnable behavior needs a current `/dogfood` PASS. BLOCKED needs a user waiver.
7. Group changed files by purpose. Stage requested paths only; ask about scope only when
   ownership cannot be determined safely.

## Commit

1. Stay on the current feature branch. On the default branch, create `type/description`.
2. For each coherent group:
   - `git add <explicit paths>`
   - commit `type(scope): terse description`
   - keep lowercase, 5-72 characters, no trailing period
3. Explicit commit-only intent stops here after a clean-tree check and commit summary.
4. Push/PR only: show `origin/<branch>..HEAD`, then push with tracking.
5. Use `--force-with-lease` only after an approved history rewrite.

## Pull request

`--no-pr` or an explicit commit-and-push request ends after a clean-tree check and pushed
commit summary.

Otherwise:

1. Treat make/open/create PR as authorization for its prerequisites: verify, commit, and
   push the current branch. It does not authorize merge, force-push, or unrelated fixes.
2. Resolve the explicit base with
   `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`. Reuse an existing branch PR or
   create one against that base with assignee, labels, and the reference body template.
   For explicit whole-stack publication, follow `/stacked-prs` instead.
3. For customer-facing changes, include one screenshot/surface-review row per view.
4. Include the current dogfood receipt for runnable changes.
5. Print the PR URL.

Do not run `/visual-recap` or `/make-pr-easy-to-review` unless the user explicitly requests
that extra artifact or history work.

## CI and completion

1. Take one CI status snapshot with `gh pr checks <number>`. Note when no CI exists.
2. If checks are already failing, report them; fixing and monitoring beyond this snapshot
   requires `/go`, ship, explicit babysitting, or a follow-up request.
3. Run `git status` and `git diff`; report uncommitted work.
4. Summarize branch, commits, PR, CI, and remaining action.
5. End with one status line: `🟢 done — PR opened; CI <state>`, `🟡 awaiting decision — <decision>`, or
   `🔴 blocked — <external blocker and needed input>`.

Never stage unrelated changes, push mixed scope without confirmation, or hide a failed
command. If `gh pr create` fails, show the error and recovery command.
