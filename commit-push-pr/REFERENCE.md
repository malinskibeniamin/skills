# Commit-push-pr reference

## Review evidence (Phase 0 pre-flight)

Before the PR endpoint, run the applicable review axes inline:

- `/review` -- correctness, value, and semantic density
- `/improve-codebase-architecture` -- deep-module and invariant redesigns that remove error classes
- `/prototype` -- redesign module or layout
- `/visual-review` -- multi-hat review for frontend/visual/customer-facing surface diffs

Frontend or customer-facing surface diff -> `/visual-review` and the visual evidence gate below must run, even if another review skill already ran. Only an explicit user waiver can accept a named missing check; record it in the PR body.

A named review skill is not a separate approval gate. Use `/review` only when requested;
frontend/customer-facing changes still need visual evidence, not an agent-authored skip.

## Conventional commit types (Phase 3)

Group changed files by purpose:

| Type | Matches |
|------|---------|
| `docs` | *.md, SKILL.md, REFERENCE.md, comments-only changes |
| `test` | *.test.ts, *.test.tsx, *.spec.ts, EVAL.ts, agent-evals/ |
| `refactor` | restructure, no behavior change |
| `style` | formatting, whitespace, lint-only fixes |
| `fix` | bug fixes, error corrections |
| `feat` | new features, components, endpoints |
| `chore` | config, deps, build scripts, tooling |
| `perf` | perf improvements |
| `ci` | CI/CD pipeline changes |
| `build` | build system changes |

File fit multiple -> pick most specific.

## Auto-label map (Phase 5)

Map commit types to GitHub labels. Verify label exist first: `gh label list --search "<name>" --json name --jq '.[0].name'` -- only add existing labels.

| Commit type | Label |
|-------------|-------|
| `feat` | `enhancement` |
| `fix` | `bug` |
| `docs` | `documentation` |
| `perf` | `performance` |
| `ci` | `ci` |
| `test` | `testing` |

## PR body template (Phase 5)

Run `/quantify-impact` for every PR, including non-UI changes. Lead with the outcome,
use short bullets and the visual comparison table, and omit unused sections. No commit
dump, boilerplate attribution, repeated rationale, or separate recap artifact. Keep full
logs/matrices in reviewer-accessible evidence links; keep before/after images in the body.

```
gh pr create --base <base> --assignee @me --title '<concise outcome>' --body "$(cat <<'EOF'
## Summary
- <observable behavior change and why it matters; 1-3 bullets>

## Impact
- <automatic /quantify-impact value assessment; replace with Proven impact below when measured>

## Proven impact
<omit unless meaningful measured evidence replaces Impact>

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| <direct metric> | <base> | <candidate> | <absolute and %> |

- **Value proven:** <product or codebase benefit>
- Method: <command, fixture/runs, environment, base/candidate>
<explicit unproven performance claims instead get an Impact bullet: Value not proven + limitation>

## Stack context
- <stacked PR only: parent, layer position, dependent PRs, draft/ready>

## Reviewer guide
- <non-trivial diffs only: entry point, risk, deliberate limitation>

## Screenshots / surface review
<omit entire section if no frontend/customer-facing surface changes -- see Frontend detection below>

| View | Before | After | Notes |
|------|--------|-------|-------|
| <route/component> | ![before](<url>) | ![after](<url>) | <what changed> |

- Visual regression: `<normal command>` - PASS; <test count and report link>
- Coverage: <affected views/states, viewports/themes; inventory link if large>
- Baseline: `<base SHA>` -> `<head SHA>`; <fixture/browser/viewport>
- Limits: <explicit user-waived gaps only; omit if none>

## Dogfood evidence
<omit only when no runnable behavior changed; otherwise copy the current /dogfood receipt>

- Verdict:
- Entrypoint:
- Actions and break attempts:
- Observations:
- Repairs and replay:
- Limits:

## Dependency upgrade path
<omit entire section if no dependency-file diff>

- Upgrade evidence: <what broke / adapted / adopted + verify commands, or skip reason>
- Packages:
- SemVer confidence:
- Risk gate:
- Security notes:

## Tests
- <command and actual result; short checklist for remaining manual review only>
EOF
)"
```

Use a body file for long bodies rather than fragile shell quoting. Updates use `gh pr edit
<number> --body-file <file>`; preserve user-authored context outside the evidence sections.

Append `--label <label1> --label <label2>` per verified label.

Resolve `<base>` with `scripts/resolve-pr-base.sh` from the plugin root. For a stack layer,
this is the branch immediately below it, not the stack trunk. Ordinary `/commit-push-pr`
publishes only the current layer; `gh stack submit` belongs to an explicit `/stacked-prs`
endpoint because it can publish every unsubmitted branch.

**Draft mode**: changes look WIP (TODO comments, incomplete impl, test stubs) -> add `--draft`.

## Frontend/customer-facing detection + screenshot table (Phase 5)

**No size threshold.** Any change an end user could see triggers this gate, including a
one-word label, one-pixel spacing adjustment, focus/hover/disabled state, or removal.

1. **Inventory before edits:** resolve the real PR base (parent for stacks), record its
   merge-base SHA and candidate SHA, and inspect the complete branch diff plus staged,
   unstaged, and relevant untracked work. File extensions are hints, not the decision:
   include TSX/JSX, CSS, HTML, Vue/Svelte/Astro, tokens/themes, fonts/icons/images, copy and
   translations, rendered docs/reports, CLI/TUI, mobile/desktop, and data/config/dependency
   changes that alter rendered output. Trace shared components/styles to affected consumers.
   Map every visible change to `surface/state -> test -> before/after capture`; include
   affected responsive sizes, themes, roles, and loading/empty/error/success states. Add
   keyboard/focus and interaction checks where changed. Mark non-applicable cases with
   concrete reasons. A type-only edit may be non-visible; a backend response change may not.
2. **Capture comparable base/candidate:** use the actual base revision, identical fixture,
   route/state, browser, viewport/DPR, fonts, locale, theme, and motion settings. Stabilize
   clock/data/network and wait for readiness, not sleeps. Reconstruct a missed baseline in
   an isolated detached worktree or existing base deployment; never switch the active tree
   or fabricate a before image. New/removed views show the real prior/replacement flow;
   if none exists, use a visible `New view`/`Removed view` label with reason and the available
   real capture. Reuse earlier evidence only when revision and scenario still match.
3. **Run visual regression:** use the repository's existing screenshot assertion runner,
   not DOM/text snapshots. Add missing cases for uncovered visible changes. Run against
   existing baselines first; inspect before/after/diff images for every mismatch, fix
   unintended differences, then update only intended snapshots. Rerun without snapshot-update
   flags and require PASS. Never bulk-accept, weaken thresholds, or mask the changed region
   to get green. Shared tokens/layout/dependencies require the full relevant visual suite
   unless the consumer inventory proves a narrower scope. If no runner exists, establish
   the smallest repository-native visual test via `/create-verification-skill`; unavailable
   runtime/fixtures are blockers, not permission to substitute a screenshot for a test.
4. **Check completeness:** run `/visual-review`; reconcile the final diff and affected
   consumers against the inventory, test results, and captures. Every affected surface/state
   must be accounted for. Inspect changed and unexpectedly unchanged snapshots. Record exact
   normal test command/result, baseline updates, revision pair, environment, and remaining
   limits. New edits, rebases, base changes, or failed CI invalidate affected evidence;
   refresh the tests, captures, and PR body before declaring it current. A green suite alone
   does not prove the inventory complete; never claim exhaustive coverage from filenames.
5. **Publish visible evidence:** embed real before/after images in the PR body table, one
   row per affected view/state (group identical cases with a coverage note). Link diff images
   and the full visual-test report when available. Use repository-approved, reviewer-accessible
   image hosting or committed snapshot raw URLs pinned to immutable SHAs. Review captures
   for secrets/personal data before upload; use sanitized fixtures, never public hosting for
   private evidence without authorization. Local paths are not reviewer-visible evidence.
   Neither are localhost, expiring session URLs, or artifact ZIP links. `gh pr comment` does not upload
   local image files. Missing capture/test/hosting blocks publication unless the user
   explicitly waives the named gap; put that waiver and limitation in the body, never PASS.
6. **Verify publication:** Re-read the actual PR body after create/edit/reopen/stack submit.
   Verify the images render in an isolated browser with reviewer-equivalent access; an agent
   download alone does not prove access. Check the revision pair and concise impact/test
   bullets. Do not overwrite unrelated reviewer notes. Omit the visual section only when the
   inventory establishes no user-visible effect; keep that rationale in verification evidence.

The PR-entrypoint hook is an advisory reminder, not a completeness detector or a hard CI
gate. This workflow owns semantic detection and evidence collection on every supported
host, including hosts without hooks. Follow `visual-review/REFERENCE.md` for deeper review
evidence; local HTML reports are supplementary, never a substitute for embedded images.

## Dependency upgrade section

Dependency diff = `package.json`, `bun.lock`, `yarn.lock`, `go.mod`, or `go.sum`.

If present, add `Dependency upgrade path` section. Reuse `/upgrade-dependency` notes directly; never create or link a local Markdown report. If change is not a package upgrade (lockfile regen, fixture, rollback), record skip reason. Do not omit silently.
