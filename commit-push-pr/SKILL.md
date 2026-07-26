---
name: commit-push-pr
description: Commit, push, and open a reviewable PR. Use for commit-only, commit-and-push, PR creation, or updating an existing branch; --no-pr stops after push.
argument-hint: "[--no-pr]"
---

# Commit, Push, and Open PR

Read [REFERENCE.md](REFERENCE.md) for review prerequisites, commit types, labels, body
template, screenshots, and dependency-upgrade sections.

## Preflight

1. Run `git status -sb`, `git diff HEAD`, `git branch --show-current`,
   `git log --oneline -5`, and inspect any PR already open from this branch.
2. Resolve the default branch with `gh repo view`.
3. Verify `gh` exists, is authenticated, and the repo has an accessible remote.
4. Confirm a review skill ran. Otherwise block until the user accepts the skip.
5. Runnable behavior needs a current `/dogfood` PASS. BLOCKED needs a user waiver.
6. Group changed files by purpose. Mixed or unrelated changes require scope confirmation;
   stage explicit paths only.

## Commit

1. Stay on the current feature branch. On the default branch, create `type/description`.
2. For each coherent group:
   - `git add <explicit paths>`
   - commit `type(scope): terse description`
   - keep lowercase, 5-72 characters, no trailing period
3. Show `origin/<branch>..HEAD`, then push with tracking.
4. Use `--force-with-lease` only after an approved history rewrite.

## Pull request

`--no-pr` or an explicit commit-and-push request ends after a clean-tree check and pushed
commit summary.

Otherwise:

1. Reuse an existing branch PR or create one with explicit base, assignee, labels, and the
   reference body template.
2. Add a `/visual-recap` for non-trivial diffs; record the skip for tiny obvious diffs.
3. Run `/make-pr-easy-to-review` for non-trivial or mixed diffs. Rewrite history only with
   approval.
4. For customer-facing changes, include one screenshot/surface-review row per view.
5. Include the current dogfood receipt for runnable changes.
6. Print the PR URL.

## CI and completion

1. Stream `gh pr checks <number> --watch`; no sleep polling.
2. Diagnose failures, fix, commit, push, and re-watch. Note when no CI exists.
3. Run `git status` and `git diff`; report uncommitted work.
4. Summarize branch, commits, PR, recap or skip, CI, and remaining action.
5. End with one status line: `🟢 PR+CI done`, `🟡 pending CI/review`, or
   `🔴 blocked on user input`.

Never stage unrelated changes, push mixed scope without confirmation, or hide a failed
command. If `gh pr create` fails, show the error and recovery command.
