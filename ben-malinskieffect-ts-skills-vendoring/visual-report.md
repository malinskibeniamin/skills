# Effect vendoring: visual inventory and verification

Base: `a666713cdba0326f758cb04270e6fbce3d75f443` → candidate: `580768558889ea7601d1af3f7873af38f0d6829c`.

## Scope

- Current catalog/search, setup page, migration page, and routing catalog in English, Polish, Simplified Chinese, and Traditional Chinese: 16 surfaces.
- README provenance rendered by GitHub: one surface.
- Each surface captured in Chromium at desktop/dark 1280×900 and mobile/light 390×844, DPR 1: 34 paired cases.
- Empty Effect search on the base is the real prior flow for the two new pages; no fabricated prior page.
- Diagrams, source-download links, titles, localized descriptions, sidebar entries, and the 97 → 99 catalog count are covered by these views.
- No shared layout/style, authentication, form submission, loading/error lifecycle, or archived release content changed. Package metadata, licenses, reference text, and Codex/Claude registrations are verified by vendoring/install checks rather than UI screenshots.

## Screenshot regression

Command: `bunx playwright test --config .context/pr-evidence/playwright.config.ts --max-failures=3`.

Normal candidate rerun: **34 passed**, without snapshot updates; zero differing pixels allowed.
Base snapshots were captured first. All 34 intended differences were inspected through before/after/diff images before the candidate snapshots were accepted. Files in this folder are immutable reviewer evidence, not a permanent new application test suite.

- Docs checks include HTTP 200, working search hydration, expected catalog/route entries, visible loaded diagrams/source links, and no page exceptions.
- Real flow: scroll to search → type `effect-ts` → inspect results → search `ask-ben` → open routing catalog → scroll its entries. Before is left; after is right.
- Each take is under 10 seconds. The repository recording/composition helper accepted both takes as moving UI, not still-image video.
- GitHub MP4 attachment upload timed out; the published GIF is the inline moving fallback. No attachment completion is claimed.
- Actual consumer Effect migration was not performed; this change distributes instructions.

## Paired captures

| Locale | Surface | Viewport/theme | Before | After | Diff |
|---|---|---|---|---|---|
| en | catalog | desktop-dark | [before](before-desktop-dark-en-catalog.png) | [after](after-desktop-dark-en-catalog.png) | [diff](diff-desktop-dark-en-catalog.png) |
| en | catalog | mobile-light | [before](before-mobile-light-en-catalog.png) | [after](after-mobile-light-en-catalog.png) | [diff](diff-mobile-light-en-catalog.png) |
| en | setup | desktop-dark | [before](before-desktop-dark-en-setup.png) | [after](after-desktop-dark-en-setup.png) | [diff](diff-desktop-dark-en-setup.png) |
| en | setup | mobile-light | [before](before-mobile-light-en-setup.png) | [after](after-mobile-light-en-setup.png) | [diff](diff-mobile-light-en-setup.png) |
| en | migration | desktop-dark | [before](before-desktop-dark-en-migration.png) | [after](after-desktop-dark-en-migration.png) | [diff](diff-desktop-dark-en-migration.png) |
| en | migration | mobile-light | [before](before-mobile-light-en-migration.png) | [after](after-mobile-light-en-migration.png) | [diff](diff-mobile-light-en-migration.png) |
| en | router | desktop-dark | [before](before-desktop-dark-en-router.png) | [after](after-desktop-dark-en-router.png) | [diff](diff-desktop-dark-en-router.png) |
| en | router | mobile-light | [before](before-mobile-light-en-router.png) | [after](after-mobile-light-en-router.png) | [diff](diff-mobile-light-en-router.png) |
| pl | catalog | desktop-dark | [before](before-desktop-dark-pl-catalog.png) | [after](after-desktop-dark-pl-catalog.png) | [diff](diff-desktop-dark-pl-catalog.png) |
| pl | catalog | mobile-light | [before](before-mobile-light-pl-catalog.png) | [after](after-mobile-light-pl-catalog.png) | [diff](diff-mobile-light-pl-catalog.png) |
| pl | setup | desktop-dark | [before](before-desktop-dark-pl-setup.png) | [after](after-desktop-dark-pl-setup.png) | [diff](diff-desktop-dark-pl-setup.png) |
| pl | setup | mobile-light | [before](before-mobile-light-pl-setup.png) | [after](after-mobile-light-pl-setup.png) | [diff](diff-mobile-light-pl-setup.png) |
| pl | migration | desktop-dark | [before](before-desktop-dark-pl-migration.png) | [after](after-desktop-dark-pl-migration.png) | [diff](diff-desktop-dark-pl-migration.png) |
| pl | migration | mobile-light | [before](before-mobile-light-pl-migration.png) | [after](after-mobile-light-pl-migration.png) | [diff](diff-mobile-light-pl-migration.png) |
| pl | router | desktop-dark | [before](before-desktop-dark-pl-router.png) | [after](after-desktop-dark-pl-router.png) | [diff](diff-desktop-dark-pl-router.png) |
| pl | router | mobile-light | [before](before-mobile-light-pl-router.png) | [after](after-mobile-light-pl-router.png) | [diff](diff-mobile-light-pl-router.png) |
| zh-CN | catalog | desktop-dark | [before](before-desktop-dark-zh-CN-catalog.png) | [after](after-desktop-dark-zh-CN-catalog.png) | [diff](diff-desktop-dark-zh-CN-catalog.png) |
| zh-CN | catalog | mobile-light | [before](before-mobile-light-zh-CN-catalog.png) | [after](after-mobile-light-zh-CN-catalog.png) | [diff](diff-mobile-light-zh-CN-catalog.png) |
| zh-CN | setup | desktop-dark | [before](before-desktop-dark-zh-CN-setup.png) | [after](after-desktop-dark-zh-CN-setup.png) | [diff](diff-desktop-dark-zh-CN-setup.png) |
| zh-CN | setup | mobile-light | [before](before-mobile-light-zh-CN-setup.png) | [after](after-mobile-light-zh-CN-setup.png) | [diff](diff-mobile-light-zh-CN-setup.png) |
| zh-CN | migration | desktop-dark | [before](before-desktop-dark-zh-CN-migration.png) | [after](after-desktop-dark-zh-CN-migration.png) | [diff](diff-desktop-dark-zh-CN-migration.png) |
| zh-CN | migration | mobile-light | [before](before-mobile-light-zh-CN-migration.png) | [after](after-mobile-light-zh-CN-migration.png) | [diff](diff-mobile-light-zh-CN-migration.png) |
| zh-CN | router | desktop-dark | [before](before-desktop-dark-zh-CN-router.png) | [after](after-desktop-dark-zh-CN-router.png) | [diff](diff-desktop-dark-zh-CN-router.png) |
| zh-CN | router | mobile-light | [before](before-mobile-light-zh-CN-router.png) | [after](after-mobile-light-zh-CN-router.png) | [diff](diff-mobile-light-zh-CN-router.png) |
| zh-TW | catalog | desktop-dark | [before](before-desktop-dark-zh-TW-catalog.png) | [after](after-desktop-dark-zh-TW-catalog.png) | [diff](diff-desktop-dark-zh-TW-catalog.png) |
| zh-TW | catalog | mobile-light | [before](before-mobile-light-zh-TW-catalog.png) | [after](after-mobile-light-zh-TW-catalog.png) | [diff](diff-mobile-light-zh-TW-catalog.png) |
| zh-TW | setup | desktop-dark | [before](before-desktop-dark-zh-TW-setup.png) | [after](after-desktop-dark-zh-TW-setup.png) | [diff](diff-desktop-dark-zh-TW-setup.png) |
| zh-TW | setup | mobile-light | [before](before-mobile-light-zh-TW-setup.png) | [after](after-mobile-light-zh-TW-setup.png) | [diff](diff-mobile-light-zh-TW-setup.png) |
| zh-TW | migration | desktop-dark | [before](before-desktop-dark-zh-TW-migration.png) | [after](after-desktop-dark-zh-TW-migration.png) | [diff](diff-desktop-dark-zh-TW-migration.png) |
| zh-TW | migration | mobile-light | [before](before-mobile-light-zh-TW-migration.png) | [after](after-mobile-light-zh-TW-migration.png) | [diff](diff-mobile-light-zh-TW-migration.png) |
| zh-TW | router | desktop-dark | [before](before-desktop-dark-zh-TW-router.png) | [after](after-desktop-dark-zh-TW-router.png) | [diff](diff-desktop-dark-zh-TW-router.png) |
| zh-TW | router | mobile-light | [before](before-mobile-light-zh-TW-router.png) | [after](after-mobile-light-zh-TW-router.png) | [diff](diff-mobile-light-zh-TW-router.png) |
| en | README provenance | desktop-dark | [before](before-desktop-dark-readme.png) | [after](after-desktop-dark-readme.png) | [diff](diff-desktop-dark-readme.png) |
| en | README provenance | mobile-light | [before](before-mobile-light-readme.png) | [after](after-mobile-light-readme.png) | [diff](diff-mobile-light-readme.png) |

## Visual review

Product: both Effect skills are discoverable and the router explains their distinct jobs.
Design: current hierarchy, copy, mobile wrapping, diagrams, and empty/result states remain readable.
Engineering: immutable upstream pin, MIT notices, explicit migration invocation, and preserved reference checkouts.
QA: isolated base/current servers, replayed actual browser flow, reviewed all paired/diff captures, normal screenshot rerun.

No diff-introduced P0/P1 visual finding. Existing architecture SVG title mismatch remains outside this change.
