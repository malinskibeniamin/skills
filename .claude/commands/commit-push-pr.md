---
allowed-tools: Bash(git *), Bash(gh *)
description: Analyze changes, create categorized conventional commits, push, and open a PR
---

## Context

- Current git status: !`git status -sb`
- Current diff (staged and unstaged): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Default branch: !`gh repo view --json defaultBranchRef -q '.defaultBranchRef.name'`
- Recent commits for style reference: !`git log --oneline -5`
- Existing PR on branch: !`gh pr list --head $(git branch --show-current) --json number,url,title --jq '.[0] // empty'`

## Prerequisites

1. Verify `gh --version` exists — if missing, stop and ask the user to install it
2. Verify `gh auth status` — if not authenticated, ask the user to run `gh auth login` and stop
3. Verify you are inside a git repository

## Your task

Based on the above changes, execute the full commit-push-PR workflow below in a single response. Use only the tools listed in `allowed-tools`.

### Phase 0: Pre-flight — verify review skill ran

1. Check if any review skill was invoked in this session (search conversation history):
   - `/simplify` — lightweight review for small fixes/tweaks
   - `/request-refactor-plan` — for planning and executing refactors
   - `/improve-codebase-architecture` — for cleaning up messy code (oversized files, shallow modules, tangled deps)
   - `/design-an-interface` — for redesigning a module or exploring a different layout/approach
2. If NONE ran: warn the user — "Lifecycle requires a review skill before shipping. Recommend: `/simplify` for small changes, `/request-refactor-plan` for refactors, `/improve-codebase-architecture` for cleanup."
3. Only proceed past this gate if a review skill ran or user explicitly confirms skip

### Phase 1: Scope confirmation

1. Inspect the status and diff above
2. If a PR already exists on this branch (from context above), inform user — new commits will update existing PR. Skip to Phase 3.
3. If the worktree contains changes that look unrelated to each other, **ask the user** which files belong in this publish flow — do NOT default to `git add -A`
4. Present the file list grouped by detected category for user confirmation before proceeding

### Phase 2: Branch strategy

1. If on the default branch (detected above) → create a new branch named `type/description` (for example `feat/add-commit-push-command`) and switch to it
2. Otherwise stay on the current branch

### Phase 3: Categorized commits

Analyze every changed file and group by change purpose into conventional commit types:

| Type | Matches |
|------|---------|
| `docs` | *.md, SKILL.md, REFERENCE.md, comments-only changes |
| `test` | *.test.ts, *.test.tsx, *.spec.ts, EVAL.ts, agent-evals/ |
| `refactor` | code restructuring without behavior change |
| `style` | formatting, whitespace, lint-only fixes |
| `fix` | bug fixes, error corrections |
| `feat` | new features, new components, new endpoints |
| `chore` | config files, dependencies, build scripts, tooling |
| `perf` | performance improvements |
| `ci` | CI/CD pipeline changes |
| `build` | build system changes |

**For each category that has files:**

1. Stage only the relevant files with explicit paths: `git add <file1> <file2> ...` — never use `git add -A` or `git add .`
2. Commit with message format: `type(scope): terse description`
   - Infer scope from the directory or module the files belong to
   - Lowercase first letter, 5-72 characters, no trailing period
   - Include a `Co-Authored-By` trailer
3. Move to the next category

Record which commit types were created — used for auto-labeling in Phase 5.

If a file could fit multiple categories, assign it to the most specific one.

### Phase 4: Push

1. Show what will be pushed: `git log --oneline origin/<branch>..HEAD 2>/dev/null || git log --oneline -5`
2. Push with tracking: `git push -u origin $(git branch --show-current)`
3. Never force push — `--force-with-lease` acceptable when needed (after rebase)

### Phase 5: Open pull request

**If PR already exists** (detected in context), skip to Phase 6 — push already updated it.

1. Determine base branch from context above
2. Build `gh pr create` command with these flags:
   - `--base <default-branch>`
   - `--fill-verbose` — seed title and body from commit messages
   - `--assignee @me` — self-assign
   - **Auto-label from commit types** — map commit types to GitHub labels:

     | Commit type | Label |
     |-------------|-------|
     | `feat` | `enhancement` |
     | `fix` | `bug` |
     | `docs` | `documentation` |
     | `perf` | `performance` |
     | `ci` | `ci` |
     | `test` | `testing` |

     Before adding `--label`, verify the label exists: `gh label list --search "<name>" --json name --jq '.[0].name'` — only add labels that exist in the repo
   - **Draft mode**: if user's changes look work-in-progress (TODO comments, incomplete implementations, test stubs), add `--draft`

3. Override the auto-filled body with a structured template:

```
gh pr create --base <base> --assignee @me --fill-verbose --body "$(cat <<'EOF'
## Summary
<bulleted summary synthesized from commits>

## Commits
<list each commit: hash + message>

## Test plan
<checklist of how to verify — infer from the changes>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Note: `--fill-verbose` sets the title from commits. Override title with `--title` only if the auto-generated title is poor (too long, unclear, or just a hash).

4. Add labels if they exist: append `--label <label1> --label <label2>` for each verified label
5. Print the PR URL

### Phase 6: Watch CI (MANDATORY)

1. **Always** stream CI checks: `gh pr checks <PR_NUMBER> --watch` using the Monitor tool for real-time output
2. Do NOT use `sleep` + `gh pr checks` polling — use `--watch` flag which streams updates
3. Do NOT skip this step — CI failures caught here save user time
4. If checks fail: read failure logs, diagnose root cause, fix, commit, push, and re-watch
5. If no CI configured, note it and proceed

### Phase 7: Verify and summarize

1. Run `git status` and `git diff` to confirm the working tree is clean
2. If anything remains uncommitted, warn the user
3. Summarize: branch name, list of commits, PR URL (or existing PR URL), CI status, and anything the user still needs to do

### Safety

- Never stage unrelated changes silently
- Never push without confirming scope when the worktree contains mixed changes
- Never force push — `--force-with-lease` acceptable when needed (after rebase)
- If no accessible git remote exists, stop and explain the blocker
- If `gh pr create` fails, show error and suggest `--recover` flag for retry
