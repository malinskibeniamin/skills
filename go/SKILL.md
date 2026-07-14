---
name: go
description: "Ship what built. Run verify -> self-review -> simplify -> deslop -> commit-push-pr -> monitor CI -> fix -> done. Use when implementation done, ready to launch."
---

# Go -- Ship What You Built

Phases 4-6 of `/development-lifecycle`, standalone command. Use when code written, ready launch.

**Assumes**: implementation done, tests written. If not -- run `/development-lifecycle`.

## Phase 4: Verify

Run all checks. Fix failures before proceed.

1. `bun run type:check` (TypeScript 7 `tsc`)
2. `bun run lint:fix` (biome)
3. `bun vitest run --related` (changed files)
4. Route touched -> `bun vitest run *.browser.test.tsx`
5. Dev server running -> browser smoke via `scripts/skills-browser.sh` (Vercel agent-browser). Skip if not installed.
6. Frontend or customer-facing surface diff -> run `/visual-review` (screenshots/terminal evidence, states, a11y, console, mobile/cross-browser when feasible). Skip only with reason.
7. Dependency changed (`package.json`, `bun.lock`, `yarn.lock`, `go.mod`, `go.sum`) -> run `/upgrade-dependency` or record skip reason + upgrade report/PR section.
8. **When green: commit now.** One commit per passing state.

## Phase 4b: Refine (Self-Review Loop)

**Skip if**: trivial change (<10 lines, no logic) | test-only | docs-only.

1. Claude-hosted: dispatch `self-reviewer`. Native Codex: run the same self-review axis inline unless the user explicitly requests agents.
2. **Cross-model adversarial review (automatic in Claude-hosted workflows, cross-FAMILY preferred)**: Claude authored -> dispatch `GPT-5.6-sol: adversarial` via `/codex`; GPT authored -> dispatch the Claude `adversarial-reviewer` (Opus). Initial pass is Sol or Opus -- never Terra/Luna. Native Codex runs the adversarial axis inline, does not recursively invoke `/codex`, and records cross-family review as unavailable unless explicitly requested.
3. Claude-hosted diff >200 lines -> ALSO dispatch `adversarial-reviewer` in parallel. Native Codex stays inline without delegation consent.
4. Resilience Review: risky feature/hook nudge -> run `/resilience-review` or record skip reason
5. Process findings by priority -- see [REFERENCE.md](REFERENCE.md)
6. Fix P0/P1 now (Claude may delegate per model routing; native Codex fixes inline unless delegation was requested), apply P2 `safe_auto`, show P2 `gated_auto` to user
7. Commit fixes: `refactor(scope): self-review fixes`
8. Re-verify (tests + types + lint)
9. **Max 2 refine rounds.** Then proceed.

## Phase 5: Simplify, Deslop + Ship

1. Run `/simplify` -- general cleanup pass
2. Run `/deslop` -- tag complexity cuts (delete/stdlib/native/yagni/shrink), then block unless value, defense, or test confidence is certain
3. Fix issues, commit
4. Frontend or customer-facing surface diff and `/visual-review` not run this session -> run it now or record explicit skip reason
5. Non-trivial diff -> prepare `/visual-recap` context so the PR explains what will ship; tiny obvious diff may skip with reason
6. Non-trivial or mixed diff -> run `/make-pr-easy-to-review` for reviewer guidance; no history rewrite without user approval
7. Run `/commit-push-pr` -- conventional commits, push, open PR
8. Claude-hosted: dispatch `code-reviewer`. Native Codex: run its fresh-eyes checklist inline unless agents were explicitly requested.

## Phase 5b: Iterate

Native Codex handles the first automated review/fix pass and one CI status snapshot, then stops.
Extra rounds require an explicit "babysit until clean" or `/plow-ahead`; neither grants subagent consent.

1. Claude-hosted: `Monitor: gh pr checks <number> --watch`. Native Codex: take one `gh pr checks <number>` snapshot.
2. CI fail -> diagnosing-bugs, fix, push. Claude re-monitors; native Codex reports the new pending status unless continuation was explicit.
3. Fresh-eyes findings (agent in Claude, inline in Codex) -> `/resolve-pr-feedback` triage, fix, reply, push
4. **AI self-review cap (Claude-hosted)**: up to 3 auto `code-reviewer` rounds, alternating models. **Early-exit** on `APPROVED` or empty findings; after 3 noisy rounds, hand off to a human. Native Codex defaults to one inline round; extra rounds follow the stop rule above.
5. **Existing human review (incl cloud/Copilot)**: NO cap. Address EVERY present thread, but do not poll for later feedback unless asked. `pr-feedback-completeness-stop` blocks exit until unresolved count is 0 and no CHANGES_REQUESTED reviews remain.

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
