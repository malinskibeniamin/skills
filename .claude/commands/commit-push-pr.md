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

1. Verify `gh --version` exists — if missing, stop and ask user to install
2. Verify `gh auth status` — if not authenticated, ask user to run `gh auth login` and stop
3. Verify inside git repository

## Your task

Execute full commit-push-PR workflow below in single response using only `allowed-tools`.

### Phase 0: Pre-flight — verify review skill ran

1. Check if any review skill was invoked this session:
   - `/simplify` — small fixes/tweaks
   - `/request-refactor-plan` — refactors
   - `/improve-codebase-architecture` — cleanup (oversized files, shallow modules, tangled deps)
   - `/design-an-interface` — redesigning module or layout
2. If NONE ran: warn — "Lifecycle requires review skill before shipping. Recommend: `/simplify` for small changes, `/request-refactor-plan` for refactors, `/improve-codebase-architecture` for cleanup."
3. Only proceed if review skill ran or user explicitly confirms skip

### Phase 1: Scope confirmation

1. Inspect status and diff above
2. If PR already exists on this branch (from context), inform user — new commits update existing PR. Skip to Phase 3.
3. If worktree contains unrelated changes, **ask user** which files belong — do NOT default to `git add -A`
4. Present file list grouped by category for confirmation before proceeding

### Phase 2: Branch strategy

1. If on default branch → create new branch named `type/description` (e.g. `feat/add-commit-push-command`) and switch
2. Otherwise stay on current branch

### Phase 3: Categorized commits

Analyze changed files, group by purpose into conventional commit types:

| Type | Matches |
|------|---------|
| `docs` | *.md, SKILL.md, REFERENCE.md, comments-only changes |
| `test` | *.test.ts, *.test.tsx, *.spec.ts, EVAL.ts, agent-evals/ |
| `refactor` | restructuring without behavior change |
| `style` | formatting, whitespace, lint-only fixes |
| `fix` | bug fixes, error corrections |
| `feat` | new features, components, endpoints |
| `chore` | config, dependencies, build scripts, tooling |
| `perf` | performance improvements |
| `ci` | CI/CD pipeline changes |
| `build` | build system changes |

**For each category with files:**

1. Stage only relevant files with explicit paths: `git add <file1> <file2> ...` — never `git add -A` or `git add .`
2. Commit: `type(scope): terse description`
   - Infer scope from directory/module
   - Lowercase first letter, 5-72 chars, no trailing period
   - Include `Co-Authored-By` trailer
3. Move to next category

Record which commit types were created — used for auto-labeling in Phase 5.

If file fits multiple categories, assign most specific one.

### Phase 4: Push

1. Show what will be pushed: `git log --oneline origin/<branch>..HEAD 2>/dev/null || git log --oneline -5`
2. Push with tracking: `git push -u origin $(git branch --show-current)`
3. Never force push — `--force-with-lease` acceptable when needed (after rebase)

### Phase 5: Open pull request

**If PR already exists** (from context), skip to Phase 6 — push already updated it.

1. Determine base branch from context
2. Build `gh pr create` with:
   - `--base <default-branch>`
   - `--fill-verbose` — seed title/body from commits
   - `--assignee @me`
   - **Auto-label from commit types:**

     | Commit type | Label |
     |-------------|-------|
     | `feat` | `enhancement` |
     | `fix` | `bug` |
     | `docs` | `documentation` |
     | `perf` | `performance` |
     | `ci` | `ci` |
     | `test` | `testing` |

     Before adding `--label`, verify label exists: `gh label list --search "<name>" --json name --jq '.[0].name'` — only add existing labels
   - **Draft mode**: if changes look WIP (TODO comments, incomplete implementations, test stubs), add `--draft`

3. Override auto-filled body with structured template:

```
gh pr create --base <base> --assignee @me --fill-verbose --body "$(cat <<'EOF'
## Summary
<bulleted summary synthesized from commits>

## Commits
<list each commit: hash + message>

## Test plan
<checklist of how to verify — infer from changes>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Note: `--fill-verbose` sets title from commits. Override with `--title` only if auto-generated title is poor.

4. Append `--label <label1> --label <label2>` for each verified label
5. Print PR URL

### Phase 6: Watch CI (MANDATORY)

1. **Always** stream CI checks: `gh pr checks <PR_NUMBER> --watch` using Monitor tool
2. Do NOT use `sleep` + polling — use `--watch` flag
3. Do NOT skip — CI failures caught here save time
4. If checks fail: read logs, diagnose, fix, commit, push, re-watch
5. If no CI configured, note it and proceed

### Phase 7: Verify and summarize

1. Run `git status` and `git diff` to confirm clean worktree
2. If anything remains uncommitted, warn user
3. Summarize: branch name, commits, PR URL (or existing PR URL), CI status, remaining user actions

### Safety

- Never stage unrelated changes silently
- Never push without confirming scope when worktree has mixed changes
- Never force push — `--force-with-lease` acceptable when needed (after rebase)
- If no accessible git remote, stop and explain blocker
- If `gh pr create` fails, show error and suggest `--recover` flag for retry
