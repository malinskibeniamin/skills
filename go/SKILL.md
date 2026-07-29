---
name: go
description: "Ship completed work through verification, review, PR, and CI."
disable-model-invocation: true
---

# Go -- Ship What You Built

Phases 4-6 of `/development-lifecycle`, standalone command. Use when code written, ready launch.

**Assumes**: implementation done, tests written. If not -- run `/development-lifecycle`.

## Phase 4: Verify

Discover the repository's documented checks, then run every applicable ecosystem branch.
Fix failures before proceeding.

1. TypeScript/frontend: `bun run type:check`, `bun run lint:fix`, and the repository's
   targeted Vitest command. A touched route also runs its `.browser.test.tsx` coverage.
2. Go: `go test ./...`, `go vet ./...`, and the repository's documented build command.
3. Other ecosystems: use the commands in the repository instructions and CI configuration.
4. Runnable behavior changed -> run `/dogfood` through the real entrypoint on the current implementation. For UI, use `scripts/skills-browser.sh` or Playwright when available. Tests never replace this. Record a non-runnable reason only for docs/test-only changes.
5. Frontend or customer-facing surface diff -> run `/visual-review` (screenshots/terminal evidence, states, a11y, console, mobile/cross-browser when feasible). Skip only with reason.
6. A dependency version upgrade -> reuse `/upgrade-dependency` evidence. An ordinary dependency add/remove needs install, lockfile, audit, and affected-call-site evidence without invoking the upgrade workflow.
7. Impact evidence -> if `/quantify-impact` locked a contract or the diff presents an obvious measurable benefit, run the identical candidate scenario and record before/after, delta, method, and verdict. Otherwise keep a concise value explanation; do not force a benchmark.
8. **When green: commit now.** One commit per passing state.

## Phase 4b: Refine (Self-Review Loop)

**Skip if**: trivial change (<10 lines, no logic) | test-only | docs-only.

1. Run the self-reviewer and adversarial axes inline in the primary context.
2. **Cross-model adversarial review**: for non-trivial PR/ship work, run one bounded,
   awaited pass from a different model family when available. Otherwise use a labeled
   clean-context Sol pass. Follow `config/model-routing.json`; do not silently substitute
   an eval-gated variant.
3. Do not dispatch background or paired reviewers unless the user explicitly requested delegation.
4. Resilience Review: run only for credible data-loss, security/privacy, irreversible, contract, or likely stuck-user risk
5. Process findings by priority -- see [REFERENCE.md](REFERENCE.md)
6. Fix P0/P1 inline when in scope. Report P2 unless it blocks the requested endpoint.
7. Commit fixes: `refactor(scope): self-review fixes`
8. Re-verify (tests + types + lint + `/dogfood` for runnable repairs)
9. **Max 2 refine rounds.** Then proceed.

## Phase 5: Ship Clean

The implementation and review phases already own semantic density. Do not add a
mandatory cleanup ceremony. If review found avoidable surface area, fix that
specific finding and re-verify.

1. If runnable behavior changed since its receipt, rerun `/dogfood`; commit only current PASS evidence
2. Frontend or customer-facing surface diff and `/visual-review` not run this session -> run it now or record explicit skip reason
3. Run `/commit-push-pr` -- conventional commits, push, open PR.
4. Run the code-reviewer axis inline; do not dispatch another agent.

Do not run `/visual-recap` or `/make-pr-easy-to-review` unless the user explicitly requests
that extra artifact or history work.

## Phase 5b: Iterate

`/go` is an explicit full-delivery endpoint. It may monitor CI, but every reviewer remains
foreground and awaited. `/plow-ahead` does not grant subagent consent.

1. `Monitor: gh pr checks <number> --watch`.
2. CI fail -> diagnosing-bugs, fix, `/dogfood` runnable repairs, push, re-monitor.
3. Fresh-eyes findings inline -> `/resolve-pr-feedback` triage, fix, reply, push.
4. **AI self-review cap**: up to 2 inline rounds. **Early-exit** on `APPROVED` or empty findings; after 2 noisy rounds, hand off to a human.
5. **Existing human review (incl cloud/Copilot)**: NO cap. Address EVERY present thread, but do not poll for later feedback unless asked. `pr-feedback-completeness-stop` blocks exit until unresolved count is 0 and no CHANGES_REQUESTED reviews remain.

## Phase 6: Compound

After non-trivial tasks, report a reusable lesson if one exists. Do not create unrelated
rules or follow-up artifacts unless the user asks or the same defect class has recurred.

- Repeated AI bug -> propose a focused `.claude/rules/<topic>.md` rule or regression eval.

## Done

1. Post final PR comment: changes, dogfood receipt, review findings, verification
2. Request review: `gh pr edit <number> --add-reviewer <username>`
3. Report PR URL + CI status
4. End the final message with one status line, nothing after it:
   `🟢 done — <verification evidence>` | `🟡 awaiting decision — <specific decision>` | `🔴 blocked — <external blocker and needed input>`
5. **Stop.** No poll for human approval.

## Entry Gate

Before start, check work to ship:

- No uncommitted changes AND no unpushed commits -> nothing do, stop
- On default branch, no feature branch -> **auto-spawn via `scripts/mux-worktree.sh <type>/<name>`** before proceed. Never ship from main. [ETHOS: Worktree Isolation]

See [REFERENCE.md](REFERENCE.md) for detailed checklists, gate logic, flowchart.
