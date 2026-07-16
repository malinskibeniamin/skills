# Engineer C (engineer-c) — console veteran mining (weight 8)

> Lean single-pass, inline, no subagents. 4 diffs read in depth; the rest profiled from 1,126 commit subjects.

## Corpus

| Repo | Commits | Range | Nature |
|---|---|---|---|
| console (local) | 1,126 | 2023-09 → 2026-06 | center of gravity: Kafka-domain UX (topics/consumers/schemas 152, ACL/RBAC 63), testing 132, migrations 91, chakra-era 46 |
| cloudv2 | 28 | — | secondary |
| ui-registry | 10 | — | consumer-side contributions |

Steady cadence: 129 (2023) → 402 (2024) → 304 (2025) → 291 (2026). He owns the console side of the registry migration and the deepest Kafka-domain pages.

## Patterns extracted

### P1 — `disabledReason` prop + `cannotVerbNounReason()` domain guards — `exemplar`/`skill`
Disabled controls take a reason string from a single domain function shared by all call sites: `IconButton disabledReason={cannotEditGroupReason(group, feature, consumedPartitions)}` / `cannotDeleteGroupOffsetsReason(...)` (`dbb14dd01`, 2026-05-26 — scattered ternaries like `isUnconsumed ? 'No committed offset' : ...` folded INTO the guard). "Why is this not allowed" is domain data computed once, not UI-level conditionals. **Refines the harness rule "disabled Button needs Tooltip why": console encodes it as a component-API contract, not a per-usage tooltip.**

### P2 — Honest degraded states: name both causes, show the reported reason, offer retry — `skill`
No-permissions/unhealthy overview (`d361c4065`, 2026-06-27): copy admits ambiguity ("cluster is unreachable, or your account lacks permission"), surfaces `Reported reason: {clusterStatusReason}` verbatim, ships a Retry button — and lands with 145 lines of route-loader + page tests for a UX polish PR. Related: `de2590e42` removes a redundant scary banner the same week. Also "Show unconsumed partitions in consumer groups" (`9a705e0fe`) — show the data with explanation rather than hiding it.

### P3 — Feature-flag lifecycle for page rewrites: add FF → migrate → assert → remove FF — `skill`
`3ca49421e` (2026-06-03, FF for new topic listing) → migration commits (`6767d5e8f`, `34cd134a5`, `50ec78545`, `a189c3045` quotas, `2b5f22907` all modals) → e2e asserting the new layout (`7ca290b42`) → `6d11f2c0c` (2026-06-23, remove `enableNewTopicPage` FF). Three-week flag lifetime; the flag removal is part of the migration's definition of done. Same for `/permissions` (`35b06b32b`, `8e97aa0b3`).

### P4 — URL params for shareable state, localStorage for personal prefs — `skill`
Pagination from URL params (`d37844538`) and page size + sorting persisted to localStorage (`f0c0e533d`), landed as separate commits in one migration — the split between "state a teammate should get from my link" and "state that's my preference" is deliberate. Matches Engineer A's routing-state.md P2/P3 from the app side; this is console-side convergent evidence.

### P5 — Navigate content, don't hide it: scroll-to-section over filtering — `skill`
Config category sidebar changed from filtering rows to scrolling to grouped sections with headings (`0872b734c`, +85/-35; grouped layout asserted in e2e `7ca290b42`; padding polish `49355796f`). Filtering makes users think options don't exist; anchored sections preserve overview.

### P6 — UI-audit drift fixes as micro-commits — `skill`/`hook`
`c19bb752b` (2026-06-26): replace arbitrary `h-[400px]` with the `h-100` token and Base UI render prop over `asChild` — a one-line commit from a UI audit pass (co-authored with Claude). Registry refresh commits pin versions (`584f5bbd1` "refresh alert component to ui-registry v2.2.0"). Hook candidate (already partially covered by Biome): flag arbitrary `h-[Npx]`/`w-[Npx]` values where a spacing token exists.

### P7 — e2e infra must survive its own failure modes — `skill`
Backend container logs buffered via log consumer so they survive container removal (`c27da9cc3`), captured when `start()` fails in setup (`4d6461523`), selector fixes as dedicated commits (`aacc3504a`). Debuggability of a failed e2e run is part of the test, not an afterthought.

### P8 — Migration hygiene: delete the old styling system on the way out — `skill`
`4932bced8` removes `TopicConfiguration.scss` during the registry migration; `65a471edd` removes `ConfirmDeletionModal` in favor of registry dialog; empty placeholders added for consumers/partitions tabs during the same pass (`c32443fd1`). A page migration includes deleting its legacy CSS/bespoke modals, not just swapping components.

## Cross-author convergence (raises confidence)
- P4 = Engineer A's URL-as-state (routing-state.md) — two authors, two repos, same split.
- P6 = Engineer B's token discipline (engineer-b.md P3-P5) — consumer side of the same contract.
- P3's flag-removal-as-done matches Engineer A's lint-freeze-as-done (architecture-evolution.md M1): both treat "old path deleted/blocked" as the migration finish line.

## Gaps (NOT MINED)
- 2023-2024 Chakra-era history (his fix-commit ore from that period), review comments, ACL/RBAC page patterns in depth, schema-registry pages.
