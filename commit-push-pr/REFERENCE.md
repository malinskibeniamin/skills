# Commit-push-pr reference

## Review skill list (Phase 0 pre-flight)

Before `/commit-push-pr`, one review skill must run in session:

- `/simplify` -- small fixes/tweaks
- `/deslop` -- liability certainty gate with complexity tags (delete/stdlib/native/yagni/shrink)
- `/improve architecture` -- refactors, architecture plans, cleanup (oversized files, shallow modules)
- `/prototype` -- redesign module or layout
- `/visual-review` -- multi-hat review for frontend/visual/customer-facing surface diffs

Frontend or customer-facing surface diff -> `/visual-review` must run or an explicit skip reason must be recorded, even if another review skill already ran.

None ran -> warn: "Lifecycle requires review skill before shipping. Recommend: `/deslop` for liability certainty, `/simplify` for small changes, `/improve architecture` for cleanup, `/visual-review` for frontend changes."

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

```
gh pr create --base <base> --assignee @me --fill-verbose --body "$(cat <<'EOF'
## Summary
<bulleted summary synthesized from commits -- behavior changes, not file lists>

## Why
<rationale + explicit out-of-scope line for anything deliberately deferred>

## Commits
<list each commit: hash + message>

## Reviewer guide
<read-order file map for non-trivial diffs: start here -> then -> then; name the one file that carries the core change>

## Screenshots / surface review
<omit entire section if no frontend/customer-facing surface changes -- see Frontend detection below>

| View | Before | After | Notes |
|------|--------|-------|-------|
| <route/component> | ![before](<url>) | ![after](<url>) | <what changed> |

## Dependency upgrade path
<omit entire section if no dependency-file diff>

- Upgrade evidence: <what broke / adapted / adopted + verify commands, or skip reason>
- Packages:
- SemVer confidence:
- Risk gate:
- Security notes:

## Test plan
<checklist of how to verify -- infer from changes>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Note: `--fill-verbose` set title from commits. Override with `--title` only if auto-gen title poor.

Append `--label <label1> --label <label2>` per verified label.

**Draft mode**: changes look WIP (TODO comments, incomplete impl, test stubs) -> add `--draft`.

## Frontend/customer-facing detection + screenshot table (Phase 5)

**Detect frontend change** -- diff touches any:

- `*.tsx`, `*.jsx`, `*.css`, `*.scss`, `*.html`
- `tailwind.config.*`, `postcss.config.*`
- `src/components/`, `src/routes/`, `src/pages/`, `src/app/`
- registry UI (`components/ui/`)
- CLI/TUI output, mobile/desktop screens, generated reports, rendered docs, onboarding/setup flows

Frontend or customer-facing surface detected -> **require `/visual-review` result or explicit skip reason**, then include Screenshots/Surface review table. Follow `visual-review/REFERENCE.md` PR evidence contract, including HTML report path when generated. Omit section entirely otherwise (no empty table, no "N/A" row).

**Capture before/after:**

- `/visual-review` already ran this session -> reuse its checked views, screenshots, findings, and skip reasons
- `/triage` already ran this session -> reuse captured refs/screenshots
- Else: run `/visual-review`; if user explicitly skips, record reason in PR body
- Fallback: `scripts/skills-browser.sh screenshot --out /tmp/pr-<view>-after.png` per affected view
- Before image: prior PR screenshot, main-branch capture, or `<!-- no prior state -->` for new views
- Upload via `gh pr comment` drag-paste URL, or reference `/tmp/*.png` path if asset host unavailable -- note blocker in PR body

**Row per visual change.** Group by route or component. One-line `Notes` col: what visibly changed (spacing, copy, new state, a11y). No screenshot/surface evidence for backend-only refactors even if a frontend file touched (e.g. type-only `.tsx` edit).

## Dependency upgrade section

Dependency diff = `package.json`, `bun.lock`, `yarn.lock`, `go.mod`, or `go.sum`.

If present, add `Dependency upgrade path` section. Prefer `/upgrade-dependency` report path. If change is not a package upgrade (lockfile regen, fixture, rollback), record skip reason. Do not omit silently.
