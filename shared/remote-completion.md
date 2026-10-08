# Recover local-only agent work

Treat a finished agent's “Changes uncommitted”, “not pushed”, or similar report as
incomplete delivery, not a handoff. Git state is decisive even when the message
claims success. Apply this when finishing action work or inspecting another
agent's completed worktree.

1. Resolve the exact repository, worktree, branch, original request, and endpoint.
   Inspect staged, unstaged, untracked files and local commits; identify the
   configured push remote and branch. `git worktree list --porcelain` locates
   checkouts but does not prove their agents are inactive. Confirm ownership and
   that no agent, git operation, or concurrent owner is still using the target.
2. Preserve explicit local/no-commit/no-push stops. Audit-only requests remain
   read-only: report unpublished paths/commits, not successful delivery. A request to recover
   or propagate the work authorizes delivery. Otherwise follow the original
   action endpoint on the current user-owned feature branch. Other worktrees
   require recovery authority; do not sweep active, foreign, default, or shared
   branches or upload secrets, ignored scratch files, or unrelated hunks.
3. Compare pending files and commits with the original scope. Adopt verified
   in-scope work from the prior agent even if it predates this session. Unclear
   ownership is a reserved decision, not permission for `git add -A`. Run the
   applicable checks, commit explicit paths/hunks, then push to the intended
   remote branch. Configure tracking on its first push. Use
   [commit-push-pr](../commit-push-pr/REFERENCE.md) for delivery and safe rebase;
   preserve the existing branch and PR, including draft state. Do not merge or
   force away concurrent remote work.
4. Verify no requested changes remain uncommitted and read the actual remote
   branch with `git ls-remote <remote> refs/heads/<branch>`. Its SHA must match
   local `HEAD`; a clean tree, cached tracking ref, or successful command alone
   is insufficient. If access fails or publication cannot be verified, report
   the exact blocker and remaining local paths/commits. Keep the worktree intact.
5. Report branch, committed scope, remote SHA, verification, and requested PR.
   Separate unrelated or explicitly local work from delivered work. Do not ask
   again for routine commit/push permission already granted by the endpoint.

This is a completion/recovery check, not an unattended watcher. It does not
authorize starting agents, changing workspaces, or repairing every local tree.
