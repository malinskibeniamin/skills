# Manual release checklist

1. Run `bun run lint:fix`.
2. Run `bun run type:check`.
3. Run `bun test`.
4. Copy the branch name into `git push -u origin <branch>`.
5. Copy the same summary into `gh pr create`.
6. Open the pull request checks page and report the first CI snapshot.

Operators paste this checklist into most feature sessions.
