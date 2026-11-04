---
name: commit-push-pr
description: Commit, push, and open a reviewable PR, or execute an explicitly authorized merge. Use for delivery requests; --no-pr stops after push.
argument-hint: "[--no-pr]"
---

Read [Poteto](../shared/POTETO-NATIVE.md#execution).

Use [REFERENCE.md](REFERENCE.md) and [dependencies](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

Explicit merge only: [contract](references/merge.md).

## Preflight

1. Check status/diff/branch/log/PR; push/PR [auto-rebase](REFERENCE.md#automatic-rebase) behind owned PRs.
2. Resolve endpoint: commit only, push (`--no-pr`), or PR. Commit-only skips remote and `gh` preflight.
3. Push/PR: [auto-setup safeguards](../shared/review-enforcement.md); honor narrower endpoints.
4. For PR, run `gh stack view --json`. Own one layer; never implicit `gh stack submit`.
5. Review with owning skills; authorized council preserves coverage; do not block merely over skill invocation.
6. Load [dogfood](../dogfood/SKILL.md) for runnable PR work; require current PASS. BLOCKED needs user waiver.
7. Stage by purpose; ask on unclear ownership.

## Commit

With Changesets, load [changesets](../t3code-skills/changesets/SKILL.md) after checks.

1. Keep feature branches; on default, create `type/description`.
2. Per coherent group, `git add <explicit paths>` then `type(scope): description`: lowercase, 5-72 chars, no period.
3. Explicit commit-only intent stops here after clean-tree check.
4. Push/PR, any CI fix or rebase: show `origin/<branch>..HEAD`, then push with tracking.
5. User-owned feature rewrites use `--force-with-lease` without another permission prompt. Never plain-force; default/shared/foreign/concurrent rewrites need explicit permission.

## Pull request

`--no-pr` never creates a PR. After push: [existing PR upkeep](../pr/SKILL.md#existing-pr), then check tree. Prepare evidence.

1. Base: `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`. Keep follow-up in current PR and [metadata](references/metadata.md), including draft state. Draft PRs open without approval; stacks: `/stacked-prs`.
2. Every PR: load [PR](../tstack-skills/file-pr/SKILL.md), [impact](../quantify-impact/SKILL.md) and [body](../pr/SKILL.md) separately; keep drafts/value.
3. Visible changes: inventory, annotated before/after screenshots/video, reviewed snapshots, passing visual tests per reference. Auto-add numbered callouts/legend; gaps need user waiver.
4. Public repo (`gh repo view --json visibility`): scrub internal org, repo, product, person names and private links from commits, title, body, and evidence before push.
5. Include dogfood receipt; read back body/image access. Edits invalidate evidence.

Upkeep: [maintenance owner](../shared/delivery-workflow.md#automatic-pr-maintenance),
select native transport before watching; no duplicate dispatcher.

Do not run `/visual-recap` or `/make-pr-easy-to-review` unless the user explicitly requests.

## Completion

1. Read CI: `gh pr checks <number>`; absent/pending/skipped is not green.
2. Automatically fix applicable feedback/CI/conflicts; verify/push; continue one authorized transport.
3. Report head/PR/checks/review gaps and continuation/blocker; honor narrower stops.
4. Follow CLAUDE.md: intent/impact/status and full PR URL on final status line, including updates.

Preserve unrelated work; expose failures/recovery.
