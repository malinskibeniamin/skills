# ETHOS

Permanent principles. Learn each at its enforcement boundary, not ambient prelude.

## 1. Types Are The First Reviewer

`any`, `unknown` (as escape), `Record<string, any>`, `as unknown as T`
blocked at Edit. tsconfig strict flags can never weaken.

Enforced by: `ts-no-escape-hatches-check`, `tsconfig-strict-check`,
`as-cast-check`, `biome-ignore-check`.

## 2. Every Thread Resolved Before Human

Every non-bot, non-outdated PR thread: reply + resolve.
`scripts/pr-unresolved-count.sh` must print 0.

Enforced by: `pr-feedback-completeness-stop`.

## 3. Worktree Isolation Is Not Optional

One terminal = one worktree = one branch. Hook asserts cwd matches
bound worktree. `git commit|push|checkout|switch` across drift denied.

Enforced by: `branch-safety-check`, `_hook_assert_bound_worktree`,
`_hook_file_outside_current_worktree`.

## 4. Discover Before Commitment

Every spec has gaps, but not every gap needs a user interview. Find blind
spots, resolve facts from evidence, prototype volatile unknowns, and ask the
human only for decisions that materially change the result. A plan is ready
when architecture-changing decisions are settled and every remaining unknown
has a lookup, prototype, reversible assumption, or pause trigger.

Enforced by: `lifecycle-stop` untested-source gate, `/grilling` flow.

## 5. Search Before Add

Grep before writing. Read `package.json` before installing. Read
existing hooks before writing a new one. Reinvention is theft.

Enforced by: `legacy-linter-check`.

## 6. Toolchain Discipline

`bun` not `npm`. TypeScript 7 (`tsc` or tsrs) not preview-era `tsgo`. Biome not ESLint. `vitest` not
`jest`. No `--no-verify`. No `bunx skills:*` workarounds.

Enforced by: `enforce-toolchain.sh`.

## 7. User Sovereignty

Humans decide. Model consensus is not authority. When 3 agents agree
and the user disagrees, the user wins. Name judgment calls; present
options with cost. Destructive ops need explicit confirmation.

Behavioral -- not hook-enforceable. Reviewer agents surface, never
auto-merge.

## 8. Tests Prove Behavior

Use RED -> GREEN -> REFACTOR for bugs and meaningful behavior. One
public-contract test can prove many lines; add another only for an independent
credible risk. Coverage quotas and speculative edge-case matrices are not
correctness.

Enforced by: `/tdd`, test runner hooks, `self-reviewer`, `code-reviewer`.
