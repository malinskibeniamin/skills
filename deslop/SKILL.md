---
name: deslop
description: "Question changed code as liability and remove unjustified surface area. Use before commit, push, PR, merge, or when a change feels overbuilt or low-value."
---

# Deslop

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Code is liability. Every added line can break, page someone, or need support.

## Inputs

- Run `/simplify` first; use this skill as the stricter certainty gate after it.
- Read `git diff --stat` and `git diff` for changed files.
- Read nearby code before proposing new helpers or abstractions.
- If the goal/spec is unclear, ask one question before judging value.

## Loop: Delete -> Inline -> Justify

1. **Inventory additions** -- new files, functions, branches, deps, config, hooks.
2. **Question every addition** -- keep code only when you are certain it proves product value, defensive correctness, or test confidence.
3. **Delete first** -- remove dead paths, speculative options, unused exports, wrapper layers.
4. **Inline second** -- inline one-use helpers/components; prefer direct code until reuse is real.
5. **Tighten last** -- flatten branches, improve names, shrink tests without weakening assertions.
6. **Verify** -- rerun focused tests/type/lint. Green alone is not enough if diff is noisy.

## Blocking finding

Return `NEEDS_CHANGES` when the diff is low-value, sloppy, untested, non-defensive, or larger than the problem needs. Do not commit, push, or merge until the smallest passing diff is clear.

## Output

- Kept: why each major addition deserves ownership cost.
- Deleted/inlined: what surface area shrank.
- Still risky: blockers, tests to add, or user decisions.

See [REFERENCE.md](REFERENCE.md) for the surface-area budget checklist.
