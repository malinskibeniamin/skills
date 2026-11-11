---
description: "Commit, push, and open a reviewable PR, or execute an explicitly authorized merge. Use for delivery requests; --no-pr stops after push."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["commit push pr"]}
sidebar: {"label":"/commit-push-pr"}
title: "/commit-push-pr"
type: "skill"
---
![Diagram of the /commit-push-pr skill](/diagrams/skills/commit-push-pr.svg)

[Open the editable Excalidraw source](/diagrams/skills/commit-push-pr.excalidraw)


Read [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/POTETO-NATIVE.md#execution).

Use [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/commit-push-pr/REFERENCE.md) and [dependencies](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

Explicit merge only: [contract](https://github.com/malinskibeniamin/skills/blob/v4.45.0/commit-push-pr/references/merge.md).

## Preflight

1. Check status/diff/branch/log/PR; push/PR [auto-rebase](https://github.com/malinskibeniamin/skills/blob/v4.45.0/commit-push-pr/REFERENCE.md#automatic-rebase) behind owned PRs.
2. Resolve endpoint: commit only, push (`--no-pr`), or PR. Commit-only skips remote and `gh` preflight.
3. Push/PR: [auto-setup safeguards](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/review-enforcement.md); honor narrower endpoints.
4. For PR, run `gh stack view --json`. Own one layer; never implicit `gh stack submit`.
5. Review with owning skills; authorized council preserves coverage; do not block merely over skill invocation.
6. Load [dogfood](https://github.com/malinskibeniamin/skills/blob/v4.45.0/dogfood/SKILL.md) for runnable PR work; require current PASS. BLOCKED needs user waiver.
7. Stage by purpose; ask on unclear ownership.

## Commit

With Changesets, load [changesets](https://github.com/malinskibeniamin/skills/blob/v4.45.0/t3code-skills/changesets/SKILL.md) after checks.

1. Keep feature branches; on default, create `type/description`.
2. Per coherent group, `git add <explicit paths>` then `type(scope): description`: lowercase, 5-72 chars, no period.
3. Explicit commit-only intent stops here after clean-tree check.
4. Push/PR, any CI fix or rebase: show `origin/<branch>..HEAD`, then push with tracking.
5. User-owned feature rewrites use `--force-with-lease` without another permission prompt. Never plain-force; default/shared/foreign/concurrent rewrites need explicit permission.

## Pull request

`--no-pr` never creates a PR. After push: [existing PR upkeep](https://github.com/malinskibeniamin/skills/blob/v4.45.0/pr/SKILL.md#existing-pr), then check tree. Prepare evidence.

1. Base: `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`. Keep follow-up in current PR and [metadata](https://github.com/malinskibeniamin/skills/blob/v4.45.0/commit-push-pr/references/metadata.md), including draft state. Draft PRs open without approval; stacks: `/stacked-prs`.
2. Every PR: load [PR](https://github.com/malinskibeniamin/skills/blob/v4.45.0/tstack-skills/file-pr/SKILL.md), [impact](https://github.com/malinskibeniamin/skills/blob/v4.45.0/quantify-impact/SKILL.md) and [body](https://github.com/malinskibeniamin/skills/blob/v4.45.0/pr/SKILL.md) separately; keep drafts/value.
3. Require [visual evidence](https://github.com/malinskibeniamin/skills/blob/v4.45.0/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)
   or a scoped exception.
4. Public repo (`gh repo view --json visibility`): scrub internal org, repo, product, person names and private links from commits, title, body, and evidence before push.
5. Summarize checks/limits and dogfood inline; read back body/media access.
   Refresh invalidated evidence; no separate evidence file.

Upkeep: [maintenance owner](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/delivery-workflow.md#automatic-pr-maintenance),
select native transport before watching; no duplicate dispatcher.

Do not run `/visual-recap` or `/make-pr-easy-to-review` unless the user explicitly requests.

## Completion

1. Read CI: `gh pr checks <number>`; absent/pending/skipped is not green.
2. Automatically fix applicable feedback/CI/conflicts; verify/push; continue one authorized transport.
3. Report head/PR/checks/review gaps and continuation/blocker; honor narrower stops.
4. Follow CLAUDE.md: intent/impact/status and full PR URL on final status line, including updates.

Preserve unrelated work; expose failures/recovery.
