# Engineer D (engineer-d) — console founding author (weight 7)

> Lean single-pass, inline. 4 diffs + stats read; the rest profiled from 1,585 commit subjects.

## Corpus

console (local): **1,585 commits, 2019-09-29 → 2024-10-08** — literally commit #1 of the repo (the OSS predecessor). Peak 2020-2021 (946), gone by late 2024. cloudv2: 7. ui-registry: 0.

**Mining lens for weight 7 + legacy era:** his *structural* patterns (MobX singleton store, class components, Chakra) are documented as superseded in architecture-evolution.md — do not encode them. His *domain UX* for Kafka data is the part that survived two generations of rewrites and IS the product's signature. Themes: payload/encoding 124, topics 125, search 66, connect 74, filters 42, timestamps 35.

## Surviving domain-UX patterns

### P1 — Push-down JS message filters — survived 2 rewrites — `skill`/`exemplar`
User-supplied JavaScript predicates filtering Kafka messages server-side — the OSS predecessor's signature feature. Survival proof: Engineer C migrated its modal to the UI registry in **2026** (`1fd08a72a`, the engineer-c corpus) rather than rethinking the concept. Lesson: for data-exploration UIs over huge streams, push user-programmable filtering to the server; the UI ships the predicate, not the data.

### P2 — Deterministic display order with user intent first — `skill`
`905ce2848` (2022-05-23): preview fields sort by a fully-specified precedence — user-defined order highest, then shorter JSON paths, then alphabetical — and the commit message documents the total ordering as a spec. Lesson: any UI list with mixed user/derived entries needs an explicit, documented total ordering; user-defined order always wins.

### P3 — Honest payload rendering: never pretty-print what can't be reliably decoded — `skill`
`cc1b92cb0` (2023-06-19): stop preview-decoding base64 bytes that can't be reliably decoded — show the faithful raw form instead of a lossy guess. Part of a 124-commit payload/deserialization investment (encoding detection, protobuf/avro/json). Convergent with Engineer C's "honest degraded states" (P2) and Engineer A's "machine truth beside human labels" (design-taste P14) — **three-author convergence: never lie in the rendering.**

### P4 — Time is a first-class UX in streaming products — `skill`
Live-updating relative timestamps (`b1dcf6afe`, 2021), unixMillis conversion fix (`6aea8899f`), search-messages-by-timestamp (#982, `78932b0a6`), start-offset-by-timestamp (#183). Timestamps must be live, convertible (relative/absolute/local), and usable as query inputs, not just display strings.

### P5 — History hygiene: nested pages replace, they don't push — `skill`
`5645d9277` (2024-10-01): navigating within the security page section replaces the history entry so Back escapes the section instead of stepping through every nested tab. Rule: intra-section navigation (tabs, wizard steps, detail sub-views) uses replace; only section entry uses push.

### P6 — Embedded-mode hardening: boundaries, caught refreshes, visibility-checked routes — `skill`
Console-embedded-in-cloud (the seed of the Module Federation host story): ErrorBoundary around `AppContent` in `EmbeddedApp` (`ab76e02a1`), license refresh errors caught instead of bubbling to the host (`99165d4cc`), embedded routes filtered by their `visibilityCheck` (`f3595c3e0`). An embedded app must never crash its host, and its route surface must respect host-granted visibility.

### P7 — Docs at point of need, in the page description — `skill`
`32023b7a5` (2024-09-04): docu links moved from a separate box into the page description; `ec8ba7868`: docu links on the create page. Education lives inline where the decision is made, not in a sidebar box.

## Superseded (do not encode — already covered)
MobX singleton `backendApi` store, class components, Chakra composition, hash-era routing — all replaced 2025-2026 (architecture-evolution.md "what died" + Engineer C's migration corpus). His `frontend/src/state/backendApi.ts` pattern is the canonical "before" for the react-query migration.

## Gaps (NOT MINED)
- The 2020-2021 peak (946 commits) — virtual scrolling / rendering perf for huge message tables likely lives there.
- the OSS predecessor-era UX experiments that were dropped pre-the company (validated dead ends).
