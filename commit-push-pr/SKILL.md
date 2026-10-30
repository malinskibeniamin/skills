---
name: commit-push-pr
description: Commit, push, and open a reviewable PR, or execute an explicitly authorized merge. Use for delivery requests; --no-pr stops after push.
argument-hint: "[--no-pr]"
---

For multi-step implementation or publication, read the [Poteto adaptation](../shared/POTETO-NATIVE.md#execution).

Use [REFERENCE.md](REFERENCE.md) and [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

Merge only on explicit request: [contract](references/merge.md).

## Preflight

1. Check status/diff/branch/log/PR; push/PR [auto-rebase](REFERENCE.md#automatic-rebase) behind owned PRs.
2. Resolve endpoint: commit only, push (`--no-pr`), or PR. Commit-only skips remote and `gh` preflight.
3. Push/PR: [auto-setup safeguards](../shared/review-enforcement.md); honor narrower endpoints.
4. For PR, run `gh stack view --json`; inspect base/stack. A normal PR owns one layer, never `gh stack submit`.
5. Review inline; do not block merely over named skill invocation.
6. Load [dogfood](../dogfood/SKILL.md) for runnable PR work; require current PASS. BLOCKED needs user waiver.
7. Stage by purpose; ask on unclear ownership.

## Commit

With Changesets, load [changesets](../t3code-skills/changesets/SKILL.md) after checks.

1. Stay on the feature branch; on default, create `type/description`.
2. Per coherent group, `git add <explicit paths>` then `type(scope): description`: lowercase, 5-72 chars, no period.
3. Explicit commit-only intent stops here after clean-tree check.
4. Push/PR, any CI fix or rebase: show `origin/<branch>..HEAD`, then push with tracking.
5. Current user-owned branch rewrites use `--force-with-lease` without another permission prompt. Never plain-force; default/shared/foreign/concurrent rewrites need explicit permission.

## Pull request

`--no-pr` never creates a PR. After push: [existing PR upkeep](../pr/SKILL.md#existing-pr), then clean-tree check. Prepare visuals first.

1. Resolve base: `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`. Keep follow-up in current PR; apply [repo metadata](references/metadata.md), including drafts. Template; draft PRs open without approval. Stacks use `/stacked-prs`.
2. Every PR: load [PR](../tstack-skills/file-pr/SKILL.md), [impact](../quantify-impact/SKILL.md) and [body](../pr/SKILL.md) separately; keep drafts/value.
3. Visible changes: inventory, before/after screenshots/video, reviewed snapshots and passing visual tests per reference. Missing evidence needs user waiver before publication.
4. Public repo (`gh repo view --json visibility`): scrub internal org, repo, product, person names and private links from commits, title, body, and evidence before push.
5. Include dogfood receipt. Re-read body, check reviewer image access, and print URL. Updates/reopens use same gate; edits invalidate affected evidence.

Enabled auto-review: [bind original session](../resolve-pr-feedback/AUTO-REVIEW.md).

Do not run `/visual-recap` or `/make-pr-easy-to-review` unless the user explicitly requests.

## Completion

1. Take one CI status snapshot: `gh pr checks <number>`; note absent CI.
2. Report failures; CI remediation needs `/go`, ship, babysitting, or follow-up.
3. Report status, remaining diff, branch, commits, PR, CI, and next action.
4. Follow CLAUDE.md's status/intent/impact contract; include full PR URL on final status line, including updates.

Never stage/push unrelated work or hide failures. `gh pr create` failure: show error and recovery.
