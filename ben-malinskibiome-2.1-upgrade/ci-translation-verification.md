# CI translation freshness repair

Objective: fix draft PR #184 CI without weakening freshness or rewriting existing translated prose.

- Compared source/head: `2f021a3308d9880826c4127d10c942ac66f14304` → `8b2d4da5830ff89c5ca0167d95da7efa9830cb2a`.
- CI RED: missing locale installer partials, directory pages and metadata; 294 stale source stamps after mode/related/search and YAML serialization changes.
- Existing-source review: reconstructed the previous serializer for all 98 sources. Every one of 294 old hashes matched the current prose and translatable fields exactly. `ci-source-metadata-audit.ts` repeats that read-only proof from the prior committed ledger. No entry deletion or bypass; later source edits still invalidate their stamps.
- New content: reviewed Polish/Simplified Chinese/Traditional Chinese directory prose and navigation titles; installer partials copied byte-for-byte; already-authored onboarding translations adopted after View/include structure checks. Existing translated skill and homepage files unchanged.
- Freshness GREEN: `bun run docs:translate:check` → 309 current pairs, no missing/stale/untracked.
- RED browser contract: all three locale directory heading assertions failed before repair. GREEN: localized headings plus `/locale/skills/tdd` card links pass.
- Visual suite: `bun run docs:test:browser` → 21 tests and 20 screenshot assertions pass without update flags. Three locale directory baselines added; only three inspected locale onboarding snapshots updated for the sidebar group label. English/current/archived snapshots unchanged.
- Inventory: new directory titles/descriptions/introduction and group navigation labels in pl/zh-CN/zh-TW. Group labels share the current-locale sidebar wrapper; onboarding captures cover that wrapper. No new mobile layout or theme styling; existing mobile/wrapping and dark-mode tests pass.
- Capture environment: isolated Chromium, en-US browser locale, 1440×1000 viewport, reduced motion; explicit locale routes.
- Direct dogfood PASS: visit all three locale directories/onboarding pages; Polish directory → `/tdd` → scroll footer → onboarding. No page errors or failed page requests. Real before/after recordings pass the repository motion gate; native GitHub inline player uploaded separately.
- Local checks: lint:fix, named-file format, format:check, type:check, 24 root tests, docs check/build, accessibility audit all pass. Build 1,437 outputs; 1,421 HTML pages / 110,838 accessibility checks / zero issues.
- Baseline caveats unchanged: docs unit SVG-title assertion and mm frontmatter warning; audible narration quality not exercised. No deployment or canonical skill changes.
