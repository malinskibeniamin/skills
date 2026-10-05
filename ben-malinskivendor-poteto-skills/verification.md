# Complete pstack 0.15.9 refresh

Objective: expose every current Poteto skill through both harnesses, without activation.
Comparison: `334329cd3601a3f125834d643366e4050fd64aac` → `698c57f6cf777e33eee8f749dea2f57eb7acd74a`.
Source: [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/e43c7ee26e0038c6c1fa8380dd34ce86ff94cb2a/pstack), 0.15.9, freshly checked upstream.

## Implementation and invariants

- Complete upstream inventory: 50 → 53 skills; 158 → 161 files; all 23 playbooks retained. Three new skills, 18 modified existing upstream files, no removals.
- Three intentional short metadata mappings unlock the importer. Public CLI RED: `Short description needs an entry: correct`; GREEN: 9 tests, byte-preserved input and explicit-only flags.
- Generator-owned namespaced Claude adapters, Codex proxies/metadata, 152 registrations, four language catalogs. Original descriptions and every upstream file/mode retained in the source lock.
- Host compatibility unchanged: no agent spawning, recursive models, background automations, model/config rewrites, or live Benny setup triggered by packaging. Three additions remain explicit-only.

## Verification

- `python3 scripts/vendor-poteto.py --check`: 53 skills / 161 exact upstream files, hashes/modes.
- `python3 evals/test-poteto-sync.py`: 9/9; includes drift refusal, unmanaged-file preservation, complete refresh, metadata bounds and invocation policy.
- All three generation guards, `bun run lint:fix`, `bun run type:check`, `bun run format:check`: PASS.
- `bun run test`: 20 protocol + 4 docs-version tests PASS. Focused catalog-disclosure integration test PASS.
- Docs strict check and build PASS; Blume translation check: 315 current.
- Real isolated Claude/Codex plugin installation PASS: 152 skills in each. No external integrations or upstream automations enabled.
- Hook unit suite: 617 pass / 0 fail / 4 skip. Differential replay: 8/8 PASS.
- Full serial eval suite: **5197 pass / 0 fail / 0 skip**. Initial run during concurrent hook tests had one continuation-envelope parse failure (5196/1); isolated differential replay and final full serial replay passed. No failure was suppressed.

Later main `7abed67d7bedb61fd65c58c9b56792da87d57375` changes unrelated delivery policy/pages. The captured catalog, all localized catalog source, and docs source adapter are byte-identical to the comparison base; read-only merge-tree with that main succeeds. No rebase or conflict hiding.

## Visual inventory and current dogfood receipt

Verdict: PASS for packaging/discovery scope.
Entry points: importer CLI, isolated real plugin installs, built `/skills/ask-ben` and localized counterparts.
Actions: refresh/check/idempotence/drift refusal; install both plugin consumers; search → router → language switch → scroll to new rows; keyboard focus/Enter navigation; Traditional Chinese reload.
Observed: 50 → 53 Poteto rows, exactly one new row each; 152 registered skills; no page or failed-request errors across 24 paired browser contexts.
Repairs: local Python server's default accept backlog reset module/font requests (`ERR_CONNECTION_RESET`), leaving narration uninitialized on both sides. Context-only server backlog corrected; original feedback loop 20/20 ready. No app behavior, waits, assertion thresholds or snapshots weakened.
Limits: imported prompt quality and live Benny integrations not executed; packaging activates neither. No runtime performance claim.

Native visual test: `PATH="$PWD/node_modules/.bin:$PATH" bun run docs:test:browser --config ../.context/poteto-followup-static.config.ts --max-failures=3 poteto-catalog.spec.ts` — 12/12 PASS, 24 screenshot assertions, no snapshot-update flags.
To reproduce, copy the adjacent `poteto-followup-static.config.ts` and `poteto-static-server.py` into the checked-out repository's `.context/` directory, then run the command above.
Config uses the repository's native Playwright suite and compiled static output with an owned local server. macOS / local Bun 1.4.2 (CI pins Bun 1.3.14), repository-pinned Playwright 1.61.1 / Chromium 149; en-US browser locale, reduced motion, mocked OS voices, normalized localized source date. No region masked.

| Locale | Desktop light | Desktop dark | Mobile light |
|---|---|---|---|
| en | 1440×1000 | 1440×1000 | 390×844 |
| pl | 1440×1000 | 1440×1000 | 390×844 |
| zh-CN | 1440×1000 | 1440×1000 | 390×844 |
| zh-TW | 1440×1000 | 1440×1000 | 390×844 |

48 real before/after captures; each published PNG vertically joins catalog/correction and measurement scroll positions. 12 old baselines intentionally updated, 12 new measurement baselines added. Reviewed additions, translations, wrapping and unchanged shared chrome. No new authored skill route, search entry, interactive control, role, loading/error state, or theme introduced.
Paired recordings: actual search typing, router navigation, locale menu, and scroll; 7–8 seconds per side, motion gate PASS. Inline GIF fallback: isolated GitHub attachment profile not signed in; no downloadable-video substitution.

## Remaining limits / adjacent issue

Optional full `bun test docs-site/skill-source.test.ts`: 7 pass / 1 inherited SVG title mismatch for improve-codebase-architecture, reproduced on untouched base. Focused changed catalog test passes. Unrelated title/test not modified.

## Rollback and blast radius

Two-way door: revert the single refresh commit; previous lock/source/adapters/catalogs/snapshots return together. Scope: skill packaging/discovery and upstream prompt instructions on explicit invocation; localized router presentation. MIT license, Benny files/assets, native skills and execution boundaries unchanged.
