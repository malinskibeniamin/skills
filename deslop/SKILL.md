---
name: deslop
description: "Question changed code as liability and remove unjustified surface area. Use before commit, push, PR, merge, or when a change feels overbuilt or low-value."
---

# Deslop
Code is liability. Every added line can break, page someone, or need support.

## Inputs

- Read `git diff --stat` and `git diff` for changed files.
- Read nearby code before proposing new helpers or abstractions.
- If the goal/spec is unclear, ask one question before judging value.
- `/simplify` is a useful broad pre-pass on large diffs; this skill is the stricter certainty gate either way.

## Complexity tags

Tag each finding, one line each -- `<file>:L<line>: <tag> <what>. <replacement>.`

- `delete:` dead code, unused flexibility, speculative feature. Replace with nothing.
- `stdlib:` hand-rolled stdlib. Name the function.
- `native:` dep/code doing a platform job (HTML, CSS, DB, browser, OS). Name the feature.
- `yagni:` one impl, one caller, config nobody sets. Inline until a second exists.
- `shrink:` same behavior, fewer lines. Show the shorter form.

Repo-wide audit mode (user asks "find bloat" / "what can I delete"): scan the whole repo, rank
biggest deletion first, end with `net: -<N> lines, -<M> deps possible.` Report only, apply nothing.
Nothing to cut: `Lean already. Ship.`

## Loop: Delete -> Inline -> Justify

1. **Inventory additions** -- new files, functions, branches, deps, config, hooks.
2. **Tag complexity** -- record delete/stdlib/native/yagni/shrink candidates (tags above) before judging value. `ponytail:` shortcut markers in the diff count as declared debt; keep their ceiling/trigger honest.
3. **Reuse-first ladder** -- before owning new code, prefer deletion, standard library, native platform, already-installed dependency, then one-line local code.
4. **Question every addition** -- keep code only when you are certain it proves product value, defensive correctness, or test confidence.
5. **Delete first** -- remove dead paths, speculative options, unused exports, wrapper layers.
6. **Inline second** -- inline one-use helpers/components; prefer direct code until reuse is real.
7. **Tighten last** -- flatten branches, improve names, shrink tests without weakening assertions.
8. **Eval evidence** -- skill or harness changes need matching evals changed, with RED->GREEN or failing->passing evidence. No eval evidence means block or record why the change is docs-only/non-deterministic.
9. **Verify** -- rerun focused tests/type/lint. Green alone is not enough if diff is noisy.

## Blocking finding

Return `NEEDS_CHANGES` when the diff is low-value, sloppy, untested, non-defensive, or larger than the problem needs. Do not commit, push, or merge until the smallest passing diff is clear.

## Output

- Kept: why each major addition deserves ownership cost.
- Deleted/inlined: what surface area shrank.
- Still risky: blockers, tests to add, or user decisions.

See [REFERENCE.md](REFERENCE.md) for the surface-area budget checklist.
