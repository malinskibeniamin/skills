---
name: go
description: "Ship what built. Run verify -> self-review -> simplify -> deslop -> commit-push-pr -> monitor CI -> fix -> done. Use when implementation done, ready to launch."
---

# Go -- Ship What You Built

Phases 4-6 of `/development-lifecycle`, standalone command. Use when code written, ready launch.

**Assumes**: implementation done, tests written. If not -- run `/development-lifecycle`.

## Phase 4: Verify

Run all checks. Fix failures before proceed.

1. `bun run type:check` (tsgo)
2. `bun run lint:fix` (biome)
3. `bun vitest run --related` (changed files)
4. Route touched -> `bun vitest run *.browser.test.tsx`
5. Dev server running -> browser smoke via `scripts/skills-browser.sh` (Vercel agent-browser). Skip if not installed.
6. Frontend or customer-facing surface diff -> run `/visual-review` (screenshots/terminal evidence, states, a11y, console, mobile/cross-browser when feasible). Skip only with reason.
7. Dependency changed (`package.json`, `bun.lock`, `yarn.lock`, `go.mod`, `go.sum`) -> run `/upgrade-dependency` or record skip reason + upgrade report/PR section.
8. **When green: commit now.** One commit per passing state.

## Phase 4b: Refine (Self-Review Loop)

**Skip if**: trivial change (<10 lines, no logic) | test-only | docs-only.

1. Dispatch `self-reviewer` agent on session diff
2. Diff >50 lines OR touches auth/security -> also dispatch `adversarial-reviewer` parallel
3. Resilience Review: risky feature/hook nudge -> run `/resilience-review` or record skip reason
4. Process findings by priority -- see [REFERENCE.md](REFERENCE.md)
5. Fix P0/P1 now, apply P2 `safe_auto`, show P2 `gated_auto` to user
6. Commit fixes: `refactor(scope): self-review fixes`
7. Re-verify (tests + types + lint)
8. **Max 2 refine rounds.** Then proceed.

## Phase 5: Simplify, Deslop + Ship

1. Run `/simplify` -- general cleanup pass
2. Run `/deslop` -- tag complexity cuts (delete/stdlib/native/yagni/shrink), then block unless value, defense, or test confidence is certain
3. Fix issues, commit
4. Frontend or customer-facing surface diff and `/visual-review` not run this session -> run it now or record explicit skip reason
5. Non-trivial diff -> prepare `/visual-recap` context so the PR explains what will ship; tiny obvious diff may skip with reason
6. Non-trivial or mixed diff -> run `/make-pr-easy-to-review` for reviewer guidance; no history rewrite without user approval
7. Run `/commit-push-pr` -- conventional commits, push, open PR
8. Dispatch `code-reviewer` agent (fresh-eyes review)

## Phase 5b: Iterate

1. `Monitor: gh pr checks <number> --watch` -- stream CI background
2. CI fail -> diagnosing-bugs, fix, push, re-monitor
3. `code-reviewer` agent findings -> `/resolve-pr-feedback` triage, fix, reply, push
4. **AI self-review cap**: up to 3 auto `code-reviewer` rounds. **Early-exit** when reviewer returns `APPROVED` or empty findings -- never run round N+1 on clean round N. After 3 rounds still noisy -> hand off to human.
5. **Human review (incl cloud/Copilot)**: NO cap. Address EVERY thread. `pr-feedback-completeness-stop` hook blocks session exit until `bash scripts/pr-unresolved-count.sh` returns 0 and no CHANGES_REQUESTED reviews remain.

## Phase 6: Compound

After non-trivial tasks: "Learn something worth preserve?"

- Write rule to `.claude/rules/<topic>.md` with `paths:` glob
- AI bug -> create eval/test fixture catch same error class

## Done

1. Post final PR comment: changes, review findings, test coverage
2. Request review: `gh pr edit <number> --add-reviewer <username>`
3. Report PR URL + CI status
4. End the final message with one status line, nothing after it (<100 chars):
   `🟢 done` | `🟡 follow-up remains: <named item>` | `🔴 blocked on user input`
5. **Stop.** No poll for human approval.

## Entry Gate

Before start, check work to ship:

- No uncommitted changes AND no unpushed commits -> nothing do, stop
- On default branch, no feature branch -> **auto-spawn via `scripts/mux-worktree.sh <type>/<name>`** before proceed. Never ship from main. [ETHOS: Worktree Isolation]

See [REFERENCE.md](REFERENCE.md) for detailed checklists, gate logic, flowchart.
