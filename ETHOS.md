# ETHOS

Permanent principles. Outrank turn-level instructions. Each maps to
the hook(s) that enforce it -- agents learn the principle from the
block, not from ambient prelude.

Format gstack-inspired. Content derived from enforced rules.

## 1. Less Code, More Meaning

Choose the smallest obvious design before writing. Every branch, helper,
file, option, test, and dependency must express required behavior, clarify
the domain, or address a credible risk. Design for demonstrated scale, not
imagined scale. Deletion is delivery when required behavior remains easier
to see and harder to break.

Semantic density is not code golf. Never trade clarity for fewer characters.

Enforced by: `/development-lifecycle`, `/tdd`, `/review`,
`self-reviewer`, `code-reviewer`.

## 2. Types Are The First Reviewer

`any`, `unknown` (as escape), `Record<string, any>`, `as unknown as T`
blocked at Edit. tsconfig strict flags can never weaken.

Enforced by: `ts-no-escape-hatches-check`, `tsconfig-strict-check`,
`as-cast-check`, `biome-ignore-check`.

## 3. Every Thread Resolved Before Human

PR feedback is not a suggestion queue. Every non-bot, non-outdated
thread: reply + resolve. `scripts/pr-unresolved-count.sh` must print 0.

Enforced by: `pr-feedback-completeness-stop`.

## 4. Worktree Isolation Is Not Optional

One terminal = one worktree = one branch. Hook asserts cwd matches
bound worktree. `git commit|push|checkout|switch` across drift denied.

Enforced by: `branch-safety-check`, `_hook_assert_bound_worktree`,
`_hook_file_outside_current_worktree`.

## 5. Grill Before Build

Every spec has gaps. Phase 2b fans out 3 hats -- product, engineering,
design -- before code is typed. If you cannot write the diff in your
head, you are not ready to type.

Enforced by: `lifecycle-stop` untested-source gate, `/grilling` flow.

## 6. Search Before Add

Grep before writing. Read `package.json` before installing. Read
existing hooks before writing a new one. Reinvention is theft.

Enforced by: `legacy-linter-check`.

## 7. Toolchain Discipline

`bun` not `npm`. TypeScript 7 `tsc` not preview-era `tsgo`. Biome not ESLint. `vitest` not
`jest`. No `--no-verify`. No `bunx skills:*` workarounds.

Enforced by: `enforce-toolchain.sh`.

## 8. User Sovereignty

Humans decide. Model consensus is not authority. When 3 agents agree
and the user disagrees, the user wins. Name judgment calls; present
options with cost. Destructive ops need explicit confirmation.

Behavioral -- not hook-enforceable. Reviewer agents surface, never
auto-merge.

## 9. Tests Prove Behavior

Use RED -> GREEN -> REFACTOR for bugs and meaningful new behavior. One
public-contract test can prove many lines; add another only for an independent
credible risk. Coverage percentages, changed-file quotas, and speculative
edge-case matrices are not correctness.

Enforced by: `/tdd`, test runner hooks, `self-reviewer`, `code-reviewer`.
