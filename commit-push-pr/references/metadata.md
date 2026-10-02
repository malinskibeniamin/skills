# Repository-aware PR metadata

Apply on every PR creation, including drafts and each submitted stack layer. Resolve
metadata without a routine approval prompt; explicit user overrides and repository
requirements win. Reconcile after creation and follow-up pushes; preserve unrelated
labels, assignees, and manual review requests.

## Labels and assignee

1. Resolve the **base repository**, not the fork, with `gh repo view --json nameWithOwner`;
   pass `--repo <owner/repo>` consistently. For an existing PR, use its base repository.
2. Read that repository's instructions, PR template, and labeler configuration, then
   list its actual labels: `gh api --paginate repos/<owner/repo>/labels --jq '.[].name'`.
   Repository labels and documented mappings outrank generic names.
3. Match the complete PR diff against its real base: change type plus affected area,
   package, team, and required status labels. If no documented mapping exists, inspect
   recent merged PRs touching the same paths (`gh pr list --state merged --limit 20
   --json number,title,labels`, then `gh pr view <number> --json files,labels`). Use
   consistent, applicable precedent, not every label on a vaguely similar PR.
4. Only as a fallback, map `feat -> enhancement`, `fix -> bug`, `docs -> documentation`,
   `perf -> performance`, `ci -> ci`, `test -> testing`, **when that exact label exists**.
   Mixed diffs may need more than one label. A CODEOWNERS team slug does not establish
   a label mapping: `team-xyz`, `team/xyz`, and `area/xyz` are not interchangeable.
5. Pass each verified label as a separate `--label '<exact name>'`, plus
   `--assignee @me`, to `gh pr create`; `@me` is the authenticated human's `gh` account,
   not the commit author or a guessed login. With bot credentials, use the verified
   triggering human instead. For a PR created by `gh stack submit`, add missing values
   with `gh pr edit <number> --add-assignee @me --add-label '<exact name>'`.

If no label fits, report that outcome. If a required mapping is ambiguous or a lookup
fails, identify the missing metadata; do not invent labels, create repository labels,
expand token permissions, or claim completion of that field. Let an existing labeler
workflow apply its labels, then verify its outcome rather than assuming it succeeded.

## CODEOWNERS review routing

Resolve owners from the PR's **base branch**. GitHub searches `.github/CODEOWNERS`,
`CODEOWNERS`, then `docs/CODEOWNERS`; the first existing file wins. Patterns are case
sensitive, last-match wins, and an ownerless rule clears ownership.

Use the shared resolver from the target repository root (requires Python 3.9+):

```bash
set -o pipefail
BASE=$("${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")
git diff --name-only --no-renames -z "$BASE"...HEAD |
  python3 "${CLAUDE_PLUGIN_ROOT:-.}/scripts/codeowners-reviewers.py" --base "$BASE" --stdin0
```

`--no-renames` includes both old and new paths, including deletions. For an existing
remote PR, reconcile these paths against its current file list. For stacks, `BASE` is
that layer's parent. If a base ref is missing, fetch it rather than using head ownership.
The resolver returns deduplicated `gh` handles: teams for each matching file when
present, otherwise its individual owners. `--teams-only` supports stricter repository
policies. An empty result means no matching owner, not permission to guess one.

- Verify owners' eligibility and any CODEOWNERS errors against GitHub. A team must be
  visible and have explicit repository write access; retain `org/team-xyz` as a team
  request. Do not expand a team into its members or choose an unrelated broad team.
- Prefer an eligible matching team per owned area. Use that area's verified individual
  owners only when it has no eligible team; keep person-only areas covered even when
  another area has a team. For a rejected team, inspect the error and original matching
  rule before using its eligible people. Repository-mandated team review remains a
  requirement, not permission to invent a team or edit CODEOWNERS.
- Exclude the PR author from individual review requests. Resolve email owners to verified
  GitHub logins; the helper reports unresolved email owners instead of emitting bad handles.
  Missing CODEOWNERS/owners or inaccessible teams are visible routing gaps; do not guess
  reviewers from display names or treat them as completed review requests.

### Draft and ready behavior

Assign and label drafts immediately. GitHub defers automatic CODEOWNERS review requests
until **ready for review**. Keep the PR draft; record the resolved routing in its body
as backticked handles without pinging team members, for example
`Review routing: org/team-xyz (CODEOWNERS; deferred while draft)`.
Never mark a draft ready solely to send notifications or say a deferred review was requested.

On ready/open publication, refresh owners against the current diff and request missing
team-first reviewers with repeated `gh pr edit <number> --add-reviewer 'org/team-xyz'`
flags (or `--reviewer` at non-draft creation). Check existing requests and submitted
reviews first; do not re-request on every push. GitHub itself notifies configured
CODEOWNERS when a human marks the draft ready; this skill does not install an action,
poller, or team auto-assignment setting, and does not promise a review was performed.

## Readback and recovery

Read `gh pr view <number> --json url,isDraft,author,assignees,labels,reviewRequests,reviews`.
Verify actual labels and assignee; verify reviewers for non-drafts or the deferred routing
for drafts. Add only missing metadata. If create/edit fails, locate and reread the
existing PR before retrying: creation may already have succeeded. Repair the missing
fields on that PR, never open a duplicate or erase manual metadata. Report remaining
permission/routing gaps alongside the PR URL.

Sources: [CODEOWNERS semantics and draft notifications](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners),
[gh create flags](https://cli.github.com/manual/gh_pr_create),
[gh edit flags](https://cli.github.com/manual/gh_pr_edit).
