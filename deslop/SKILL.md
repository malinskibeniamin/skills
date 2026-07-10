---
name: deslop
description: "Write the least code that works and remove unjustified surface area. Use before commit/push/PR/merge, when a change feels overbuilt, or on ponytail, lazy mode, YAGNI, simplest solution, do less, bloat complaints, or debt-ledger asks."
license: MIT
vendored_from: https://github.com/DietrichGebert/ponytail (write mode)
---

# Deslop
Code is liability. Every added line can break, page someone, or need support. Two modes, one doctrine: **write mode** while building (absorbed from ponytail), **gate mode** before shipping. Local rule: `/tdd` wins; production code needs a failing test first.

## Write mode (lazy senior dev)

Active when invoked before/during implementation (`/deslop write`, "ponytail", "lazy mode") -- and AUTOMATICALLY for every lifecycle implementation phase (step 3): no invocation needed, both runtimes. **Persistent**: once activated it stays on for the rest of the session -- every subsequent coding response, no drift back to over-building -- until the user says "stop deslop" / "stop ponytail" / "normal mode". Intensity level persists until changed or session end. (Breaking change from the ponytail merge, owner-approved: the ponytail slash command is gone -- say "ponytail" or use `/deslop`; behavior is otherwise the ponytail union.) Lazy = efficient, not careless. The best code is the code never written.

**Understand first.** The ladder shortens the solution, never the reading. Trace every file the change touches and the actual flow end to end, then climb. Laziness that skips comprehension ships a confident wrong fix.

**Ladder** -- stop at the first rung that holds; two rungs work -> take the higher:

1. Does this need to exist at all? Speculative need = skip, say so in one line. (YAGNI)
2. Already in this codebase? A helper, util, type, or pattern a few files over -> reuse it. Re-implementing what exists is the most common slop.
3. Stdlib does it? Use it.
4. Native platform covers it? `<input type="date">` over a picker lib, CSS over JS, DB constraint over app code.
5. Already-installed dependency solves it? Never add a new dep for what a few lines do.
6. Can it be one line? One line.
7. Only then: the minimum code that works.

**Bug fix = root cause, not symptom.** Before editing, grep every caller of the function you're about to touch. One guard in the shared function is a smaller diff than a guard in every caller -- and patching only the ticketed path leaves every sibling caller broken.

**Write-mode rules:**

- No unrequested abstraction, factory, config, or scaffold. Deletion over addition; boring over clever.
- Fewest files, shortest working diff -- but the smallest change in the wrong place is a second bug.
- Same-size stdlib options? Pick the edge-case-correct one.
- Complex request? Ship the lazy version and question the rest in the same response: "Did X; Y covers it. Need full X? Say so."
- Mark deliberate shortcuts with ceiling + trigger: `// ponytail: global lock, per-account locks if throughput matters`.
- Non-trivial logic leaves one runnable check (smallest thing that fails if the logic breaks). One-liners need none -- YAGNI applies to tests too.

**Output:** code first, then max 3 short lines: `skipped: [X], add when [Y].` Asked-for reports in full; unasked prose is debt.

**Intensity** (`/deslop lite|full|ultra`, default full): lite = build it, name the lazier alternative in one line; full = ladder enforced; ultra = deletion before addition, ship the one-liner and challenge the requirement in the same breath.

**Never cut:** input validation at trust boundaries, error handling preventing data loss, security, accessibility basics, hardware calibration knobs, explicit requests, or failing-test-first for non-trivial prod code.

## Gate mode (ship gate)

### Inputs

- Read `git diff --stat` and `git diff` for changed files.
- Read nearby code before proposing new helpers or abstractions.
- If the goal/spec is unclear, ask one question before judging value.
- `/simplify` is a useful broad pre-pass on large diffs; this skill is the stricter certainty gate either way.

### Complexity tags

Tag each finding, one line each -- `<file>:L<line>: <tag> <what>. <replacement>.`

- `delete:` dead code, unused flexibility, speculative feature. Replace with nothing.
- `stdlib:` hand-rolled stdlib. Name the function.
- `native:` dep/code doing a platform job (HTML, CSS, DB, browser, OS). Name the feature.
- `yagni:` one impl, one caller, config nobody sets. Inline until a second exists.
- `shrink:` same behavior, fewer lines. Show the shorter form.

A minimal runnable self-check is the write-mode minimum, not bloat -- never tag it for deletion.

Repo-wide audit mode (user asks "find bloat" / "what can I delete"): scan the whole repo, rank
biggest deletion first, end with `net: -<N> lines, -<M> deps possible.` Report only, apply nothing.
Nothing to cut: `Lean already. Ship.`

### Loop: Delete -> Inline -> Justify

1. **Inventory additions** -- new files, functions, branches, deps, config, hooks.
2. **Tag complexity** -- record delete/stdlib/native/yagni/shrink candidates (tags above) before judging value. `ponytail:` shortcut markers in the diff count as declared debt; keep their ceiling/trigger honest.
3. **Reuse-first ladder** -- hold the diff against the write-mode ladder: deletion, reuse-in-codebase, standard library, native platform, already-installed dependency, then one-line local code.
4. **Question every addition** -- keep code only when you are certain it proves product value, defensive correctness, or test confidence.
5. **Delete first** -- remove dead paths, speculative options, unused exports, wrapper layers.
6. **Inline second** -- inline one-use helpers/components; prefer direct code until reuse is real.
7. **Tighten last** -- flatten branches, improve names, shrink tests without weakening assertions.
8. **Eval evidence** -- skill or harness changes need matching evals changed, with RED->GREEN or failing->passing evidence. No eval evidence means block or record why the change is docs-only/non-deterministic.
9. **Verify** -- rerun focused tests/type/lint. Green alone is not enough if diff is noisy.

### Blocking finding

Return `NEEDS_CHANGES` when the diff is low-value, sloppy, untested, non-defensive, or larger than the problem needs. Do not commit, push, or merge until the smallest passing diff is clear.

### Output

- Kept: why each major addition deserves ownership cost.
- Deleted/inlined: what surface area shrank.
- Still risky: blockers, tests to add, or user decisions.
- End with `net: -<N> lines possible.` when cuts exist; `Lean already. Ship.` when none.

## Debt ledger

User asks "deslop debt" / "ponytail debt" / "what did we defer": scan `ponytail:` markers, report only.

`grep -rnE '(#|//) ?ponytail:' . --exclude-dir=.git --exclude-dir=node_modules`

One row per marker: `<file>:<line> - <simplified thing>. ceiling: <limit>. upgrade: <trigger>.`
Tag rows missing a trigger as `no-trigger`. End: `<N> markers, <M> with no trigger.`
Nothing found: `No ponytail: debt. Clean ledger.` Persist to `PONYTAIL-DEBT.md` only if asked.

See [REFERENCE.md](REFERENCE.md) for the surface-area budget checklist.
