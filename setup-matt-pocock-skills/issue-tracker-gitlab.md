# Issue tracker: GitLab

Issues and PRDs for this repo live as GitLab issues. Use the [`glab`](https://gitlab.com/gitlab-org/cli) CLI for all operations.

## Conventions

- **Create an issue**: `glab issue create --title "..." --description "..."`. Use a heredoc for multi-line descriptions. Pass `--description -` to open an editor.
- **Read an issue**: `glab issue view <number> --comments`. Use `-F json` for machine-readable output.
- **List issues**: `glab issue list -F json` with appropriate `--label` filters.
- **Comment on an issue**: `glab issue note <number> --message "..."`. GitLab calls comments "notes".
- **Apply / remove labels**: `glab issue update <number> --label "..."` / `--unlabel "..."`. Multiple labels can be comma-separated or by repeating the flag.
- **Close**: `glab issue close <number>`. `glab issue close` does not accept a closing comment, so post the explanation first with `glab issue note <number> --message "..."`, then close.
- **Merge requests**: GitLab calls PRs "merge requests". Use `glab mr create`, `glab mr view`, `glab mr note`, etc. -- the same shape as `gh pr ...` with `mr` in place of `pr` and `note`/`--message` in place of `comment`/`--body`.

Infer the repo from `git remote -v` -- `glab` does this automatically when run inside a clone.

## When a skill says "publish to the issue tracker"

Create a GitLab issue.

## When a skill says "fetch the relevant ticket"

Run `glab issue view <number> --comments`.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a single issue with **child** issues as tickets.

- **Map**: create one issue labelled `wayfinder:map`, holding Notes / Decisions-so-far / Fog. On tiers with epics, an epic may hold the map instead; a labelled issue works everywhere.
- **Child ticket**: create an issue with `Part of #<map>` at the top and labels `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`).
- **Blocking**: use GitLab native blocking links when available by posting `/blocked_by #<n>` as a note. Native blocking links are a Premium/Ultimate feature; on the free tier, or when unavailable, fallback to `Blocked by: #<n>, #<n>` at the top of the description.
- **Frontier query**: list the map's open children, drop any with a native `blocked_by` link to an open issue (`glab api projects/:id/issues/:iid/links`), an open issue in the fallback `Blocked by:` line, or an assignee, and take the first in map order.
- **Claim**: `glab issue update <n> --assignee @me` before any work.
- **Resolve**: `glab issue note <n> --message "<answer>"`, then `glab issue close <n>`, then append a context pointer to the map's Decisions-so-far.
