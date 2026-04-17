---
name: go
description: "Ship what you built. Runs verify → self-review → simplify → commit-push-pr → monitor CI → fix → done. Use after implementation is complete. Alias: /ship."
---

# Go — Ship What You Built

Phases 4-6 of `/development-lifecycle`, extracted as standalone command. Use when code is written and you want to launch it.

**Assumes**: implementation done, tests written. If not — run `/development-lifecycle` instead.

## Phase 4: Verify

Run all checks. Fix failures before proceeding.

1. `bun run type:check` (tsgo)
2. `bun run lint:fix` (biome)
3. `bun vitest run --related` (changed files)
4. Route touched → `bun vitest run *.browser.test.tsx`
5. Dev server running + `claude-in-chrome` available → browser smoke test
6. **When green: commit immediately.** One commit per passing state.

## Phase 4b: Refine (Self-Review Loop)

**Skip if**: trivial change (<10 lines, no logic) | test-only | docs-only.

1. Dispatch `self-reviewer` agent on session diff
2. Diff >50 lines OR touches auth/security → also dispatch `adversarial-reviewer` in parallel
3. Process findings by priority — see [REFERENCE.md](REFERENCE.md)
4. Fix P0/P1 immediately, apply P2 `safe_auto`, show P2 `gated_auto` to user
5. Commit fixes: `refactor(scope): self-review fixes`
6. Re-verify (tests + types + lint)
7. **Max 2 refinement rounds.** Then proceed.

## Phase 5: Simplify + Ship

1. Run `/simplify` — review changed code for reuse, quality, efficiency
2. Fix any issues found, commit
3. Run `/commit-push-pr` — conventional commits, push, open PR
4. Dispatch `code-reviewer` agent (fresh-eyes review)

## Phase 5b: Iterate (max 2 rounds)

1. `Monitor: gh pr checks <number> --watch` — stream CI in background
2. CI fail → diagnose, fix, push, re-monitor
3. Review comments exist → `/resolve-pr-feedback` to triage, fix, reply, push
4. Round 2: `code-reviewer` verification → `/resolve-pr-feedback` → push → monitor
5. **NO third round.** Hand off to human.

## Phase 6: Compound

After non-trivial tasks: "Did we learn something worth preserving?"

- Write rule to `.claude/rules/<topic>.md` with `paths:` glob
- AI bug → create eval/test fixture catching same error class

## Done

1. Post final PR comment: changes, review findings, test coverage
2. Request review: `gh pr edit <number> --add-reviewer <username>`
3. Report PR URL + CI status
4. **Stop.** Do not poll for human approval.

## Entry Gate

Before starting, check there's work to ship:

- No uncommitted changes AND no unpushed commits → nothing to do, stop
- On default branch with no feature branch → warn, suggest branching first

## Skills Composed

| Skill | Phase | How |
|---|---|---|
| `self-reviewer` agent | 4b | Auto-dispatch on diff |
| `adversarial-reviewer` agent | 4b | Conditional (>50 lines or auth/security) |
| `/simplify` | 5 | Code quality review |
| `/commit-push-pr` | 5 | Conventional commits + push + PR |
| `code-reviewer` agent | 5 | Fresh-eyes review on PR |
| `/resolve-pr-feedback` | 5b | Triage + fix review comments |

See [REFERENCE.md](REFERENCE.md) for detailed checklists, gate logic, and flowchart.
