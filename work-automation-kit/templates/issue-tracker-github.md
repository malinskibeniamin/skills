# Issue tracker: GitHub

Specs and tickets for this repo live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --json number,title,body,labels,comments`.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Parent/sub-issue**: use `gh issue create --parent <parent>` or `gh issue edit <parent> --add-sub-issue <child>` when the installed CLI exposes these flags. Otherwise use `gh api --method POST repos/<owner>/<repo>/issues/<parent>/sub_issues -F sub_issue_id=<child-db-id>`; use the numeric database ID, not the issue number. Verify the native relationship; use body links only if unavailable.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from `git remote -v` -- `gh` does this automatically when run inside a clone.

## Pull requests as a triage surface

**PRs as a request surface: no.** Set to `yes` only when external PRs should enter the triage queue. Missing or `no` excludes PR discovery, not an explicitly named PR.

When enabled, read with `gh pr view` / `gh pr diff`. Discover external PRs with `gh api --paginate 'repos/{owner}/{repo}/pulls?state=open' --jq '.[] | select(.author_association | IN("OWNER","MEMBER","COLLABORATOR") | not) | {number, title, author: .user.login, author_association, labels: [.labels[].name]}'`. Comment, label, and close through `gh pr` equivalents. GitHub shares issue/PR numbers; resolve a bare number before choosing the surface.

## When a skill says "publish to the issue tracker"

Create a GitHub issue.

## When a skill says "fetch the relevant ticket"

Read the ticket with the structured **Read an issue** command above.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: create one issue labelled `wayfinder:map`, holding Notes / Decisions-so-far / Fog.
- **Child ticket**: create an issue linked to the map using the **Parent/sub-issue** operation. Re-read the map and verify every created ticket appears in its child count; a body reference alone does not count. If sub-issues are unavailable, add the child to a task list in the map body and put `Part of #<map>` at the top of the child body. Labels: `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`).
- **Blocking**: use GitHub native issue dependencies. Add an edge with `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`, where `<blocker-db-id>` is the blocker's numeric database id from `gh api repos/<owner>/<repo>/issues/<n> --jq .id`, not the `#number` or `node_id`. If dependencies are unavailable, fallback to `Blocked by: #<n>, #<n>` at the top of the child body.
- **Frontier query**: list the map's open children, drop any with `issue_dependencies_summary.blocked_by > 0` (or an open issue in the fallback `Blocked by:` line) or an assignee, and take the first in map order.
- **Claim**: `gh issue edit <n> --add-assignee @me` before any work.
- **Resolve**: `gh issue comment <n> --body "<answer>"`, then `gh issue close <n>`, then append a context pointer to the map's Decisions-so-far.
