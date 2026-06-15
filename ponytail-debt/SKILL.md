---
name: ponytail-debt
description: Harvests ponytail shortcut comments into a debt ledger. Use when user says ponytail debt, what did ponytail defer, list shortcuts, ponytail ledger, or what did we mark for later.
license: MIT
vendored_from: https://github.com/DietrichGebert/ponytail
upstream_commit: 687c1b339872289d70f65c5eaabce850b1663867
---

# Ponytail Debt

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Vendored from DietrichGebert/ponytail. Reads `ponytail:` comments; report only unless user asks ledger file.
Caveman terse: rows, counts, rot risk.

Collect deliberate shortcuts so later does not become never.

## Scan

Run or emulate:

`grep -rnE '(#|//) ?ponytail:' . --exclude-dir=.git --exclude-dir=node_modules`

Add comment prefixes for stack if needed.

## Output

Group by file:

`<file>:<line> - <simplified thing>. ceiling: <limit>. upgrade: <trigger>.`

Convention: `ponytail: <ceiling>, <upgrade trigger>`.

Tag rows with no trigger as `no-trigger`.

End with `<N> markers, <M> with no trigger.`

Nothing found: `No ponytail: debt. Clean ledger.`

## Example

`src/cache.ts:12 - global lock. ceiling: low write throughput. upgrade: per-account locks if contention appears.`

## Boundary

Reads only. If user asks persistence, write `PONYTAIL-DEBT.md` or repo convention.
