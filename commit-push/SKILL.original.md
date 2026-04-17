---
name: commit-push
description: Analyze changes, create categorized conventional commits, and push. Use when user asks to commit and push, invokes `/commit-push`, or requests conventional commits without a PR.
---

# Commit and push

## Step 0: Gather context

Run these Bash commands before proceeding:

- `git status -sb` — current working-tree state
- `git diff HEAD` — staged + unstaged changes
- `git branch --show-current` — current branch
- `gh repo view --json defaultBranchRef -q '.defaultBranchRef.name'` — default branch
- `git log --oneline -5` — recent commits for style reference

## Prerequisites

1. Verify inside git repository
2. Verify git remote exists: `git remote -v` — if none, stop and explain

## Your task

Execute full commit-and-push workflow below in single response.

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
2. If worktree contains unrelated changes, **ask user** which files belong — do NOT default to `git add -A`
3. Present file list grouped by category for confirmation before proceeding

### Phase 2: Branch strategy

1. If on default branch → create new branch named `type/description` (e.g. `feat/add-commit-push-command`) and switch
2. Otherwise stay on current branch
3. Check for existing PR: `gh pr list --head $(git branch --show-current) --json number,url --jq '.[0]'` — if PR exists, inform user (push will update it)

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

If file fits multiple categories, assign most specific one.

### Phase 4: Pre-push review

1. Show what will be pushed: `git log --oneline origin/<branch>..HEAD 2>/dev/null || git log --oneline -5`
2. Confirm commit count and branch target with user before pushing

### Phase 5: Push

1. Push with tracking: `git push -u origin $(git branch --show-current)`
2. Never force push — `--force-with-lease` acceptable when needed (after rebase)

### Phase 6: Verify and summarize

1. Run `git status` and `git diff` to confirm clean worktree
2. If anything remains uncommitted, warn user
3. Summarize: branch name, commits created, remote URL, remaining user actions

### Safety

- Never stage unrelated changes silently
- Never push without confirming scope when worktree has mixed changes
- Never force push — `--force-with-lease` acceptable when needed (after rebase)
- If no accessible git remote, stop and explain blocker
