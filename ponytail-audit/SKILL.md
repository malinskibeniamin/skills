---
name: ponytail-audit
description: Audits a whole repo for over-engineering. Use when user says audit this codebase, find bloat, what can I delete, audit for over-engineering, or ponytail-audit.
license: MIT
vendored_from: https://github.com/DietrichGebert/ponytail
upstream_commit: 687c1b339872289d70f65c5eaabce850b1663867
---

# Ponytail Audit
Vendored from DietrichGebert/ponytail. Repo-wide `/ponytail-review`; report only.
Caveman terse: ranked cuts, one line each.

Scan whole repo, not just diff. Rank biggest deletion first.

## Hunt

- Deps stdlib/native platform already covers.
- One-impl interfaces, factories, adapters, wrappers.
- Dead flags, config, env, feature toggles.
- Files exporting one thing with no boundary value.
- Hand-rolled stdlib and copy-paste helpers.

## Tags

Same as `/ponytail-review`: `delete:`, `stdlib:`, `native:`, `yagni:`, `shrink:`.

## Output

One line per finding:

`<tag> <what to cut>. <replacement>. [path]`

End with `net: -<N> lines, -<M> deps possible.`

Nothing to cut: `Lean already. Ship.`

## Example

`stdlib: custom query-string parser. URLSearchParams. [src/url.ts]`

## Boundary

Complexity only. Bugs/security/perf -> normal review. Applies nothing. One-shot.
