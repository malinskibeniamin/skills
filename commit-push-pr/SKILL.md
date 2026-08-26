---
name: commit-push-pr
description: Commit, push, and open a reviewable PR. Use for commit-only, commit-and-push, PR creation, or updating an existing branch; --no-pr stops after push.
argument-hint: "[--no-pr]"
---

Read [REFERENCE.md](REFERENCE.md) for review gates, commit types, labels, body, screenshots, and upgrade sections.

## Preflight

1. Inspect `git status -sb`, `git diff HEAD`, current branch, recent log, and any branch PR.
2. Resolve endpoint: commit only, push (`--no-pr`), or PR. Commit-only skips remote and `gh` preflight.
3. Push/PR requires an accessible remote; PR also requires authenticated `gh` and resolved default branch.
4. For PR, run `gh stack view --json`; inspect an existing PR's base/stack. A normal PR owns only the current layer and never authorizes `gh stack submit`.
5. Run applicable PR review axes inline; do not block merely because a named skill was not invoked.
6. Runnable PR work requires current `/dogfood` PASS; BLOCKED needs user waiver.
7. Group by purpose and stage requested paths only. Ask only when ownership is unsafe to infer.

## Commit

1. Stay on the feature branch; on default, create `type/description`.
2. Per coherent group, `git add <explicit paths>` then `type(scope): terse description`: lowercase, 5-72 chars, no period.
3. Explicit commit-only intent stops here after clean-tree check and summary.
4. Push/PR: show `origin/<branch>..HEAD`, then push with tracking.
5. After rewriting the current user-owned feature branch, use `--force-with-lease` when needed without another permission prompt. Never plain-force; default/shared/foreign/concurrent rewrites need explicit permission.

## Pull request

`--no-pr` ends after push, clean-tree check, and summary.

Otherwise make/open/create PR authorizes verify, commit, push, and any needed lease-protected rebase update on the current user branch. It does not authorize merge, plain force, shared rewrites, or unrelated fixes.

1. Resolve base with `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`. Reuse the branch PR or create against that base with assignee, labels, and reference template. Whole-stack publication uses `/stacked-prs`.
2. Customer-facing changes include one screenshot/surface-review row per view.
3. Runnable changes include current dogfood receipt. Print the PR URL.

Do not run `/visual-recap` or `/make-pr-easy-to-review` unless the user explicitly requests that extra artifact/history work.

## Completion

1. Take one CI status snapshot: `gh pr checks <number>`; note absent CI.
2. Report existing failures. Remediation/monitoring beyond this snapshot requires `/go`, ship, babysitting, or follow-up.
3. Report `git status`, remaining diff, branch, commits, PR, CI, and next action.
4. End with one status line: `done`, `awaiting decision`, or `blocked`, using the repository marker contract.

Never stage unrelated work, push mixed scope without confirmation, or hide failures. If `gh pr create` fails, show error and recovery command.
