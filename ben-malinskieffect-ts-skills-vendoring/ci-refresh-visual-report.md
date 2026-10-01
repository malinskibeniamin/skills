# Effect skill evidence after CI repair

- Base: c35e0ebf06fc3e4c8f886753d3c3e0085dca4b96 (main).
- Candidate: 0dd91b70355f705c6aef72eb5173c10d03f1a904.
- 48 cases per revision, 96 passing screenshot assertions on normal reruns.
- Chromium: desktop/dark 1280x900; mobile/light 390x844; scale 1; reduced motion.
- English, Polish, Simplified Chinese, Traditional Chinese.
- Zero-pixel tolerance unchanged; page errors rejected; images and editable sources checked.
- Inventory: setup search, migration search, both new skill pages, routing table and routing intro.
- New skill pages use the real baseline's empty search, because those pages did not exist.
- Rebase adopted main's Blume 2.1 renderer. Old renderer baselines were retained separately, not reused as current evidence.
- Captures wait for Blume narration initialization. Shortened Chinese router prose is below Blume's 280-character narration threshold, so its inherited narration control stays hidden. Audible speech is not tested.
- Reviewed comparison sheets for all four locales, both viewports, and both new pages. No clipping, missing diagram, console error, or stale Effect description found.
- README content is unchanged by the CI repair/rebase; its original pinned evidence remains in the PR.
- Video is a real recorded search -> result -> router navigation/scroll flow; 8 seconds, before left/after right.
- No Effect consumer application migration was attempted.

## Reproduce

Start archived main on localhost:4407 and the candidate on localhost:4408, using each revision's frozen dependencies. Place the published spec/config in .context/rebase-evidence/ (the config uses the repository's shared Playwright reporter).

```sh
EFFECT_VISUAL_SIDE=before bunx --no-install playwright test --config .context/rebase-evidence/playwright.config.ts --grep-invert 'README provenance' --max-failures=3
bunx --no-install playwright test --config .context/rebase-evidence/playwright.config.ts --grep-invert 'README provenance' --max-failures=3
```

Each command: 48 passed. No snapshot-update flag on either final run.

## Paired captures

### desktop-dark, en

| Surface | Before | After |
|---|---|---|
| catalog | ![before](ci-refresh-before-desktop-dark-en-catalog.png) | ![after](ci-refresh-after-desktop-dark-en-catalog.png) |
| migration-catalog | ![before](ci-refresh-before-desktop-dark-en-migration-catalog.png) | ![after](ci-refresh-after-desktop-dark-en-migration-catalog.png) |
| setup | ![before](ci-refresh-before-desktop-dark-en-setup.png) | ![after](ci-refresh-after-desktop-dark-en-setup.png) |
| migration | ![before](ci-refresh-before-desktop-dark-en-migration.png) | ![after](ci-refresh-after-desktop-dark-en-migration.png) |
| router | ![before](ci-refresh-before-desktop-dark-en-router.png) | ![after](ci-refresh-after-desktop-dark-en-router.png) |
| router-intro | ![before](ci-refresh-before-desktop-dark-en-router-intro.png) | ![after](ci-refresh-after-desktop-dark-en-router-intro.png) |

### desktop-dark, pl

| Surface | Before | After |
|---|---|---|
| catalog | ![before](ci-refresh-before-desktop-dark-pl-catalog.png) | ![after](ci-refresh-after-desktop-dark-pl-catalog.png) |
| migration-catalog | ![before](ci-refresh-before-desktop-dark-pl-migration-catalog.png) | ![after](ci-refresh-after-desktop-dark-pl-migration-catalog.png) |
| setup | ![before](ci-refresh-before-desktop-dark-pl-setup.png) | ![after](ci-refresh-after-desktop-dark-pl-setup.png) |
| migration | ![before](ci-refresh-before-desktop-dark-pl-migration.png) | ![after](ci-refresh-after-desktop-dark-pl-migration.png) |
| router | ![before](ci-refresh-before-desktop-dark-pl-router.png) | ![after](ci-refresh-after-desktop-dark-pl-router.png) |
| router-intro | ![before](ci-refresh-before-desktop-dark-pl-router-intro.png) | ![after](ci-refresh-after-desktop-dark-pl-router-intro.png) |

### desktop-dark, zh-CN

| Surface | Before | After |
|---|---|---|
| catalog | ![before](ci-refresh-before-desktop-dark-zh-CN-catalog.png) | ![after](ci-refresh-after-desktop-dark-zh-CN-catalog.png) |
| migration-catalog | ![before](ci-refresh-before-desktop-dark-zh-CN-migration-catalog.png) | ![after](ci-refresh-after-desktop-dark-zh-CN-migration-catalog.png) |
| setup | ![before](ci-refresh-before-desktop-dark-zh-CN-setup.png) | ![after](ci-refresh-after-desktop-dark-zh-CN-setup.png) |
| migration | ![before](ci-refresh-before-desktop-dark-zh-CN-migration.png) | ![after](ci-refresh-after-desktop-dark-zh-CN-migration.png) |
| router | ![before](ci-refresh-before-desktop-dark-zh-CN-router.png) | ![after](ci-refresh-after-desktop-dark-zh-CN-router.png) |
| router-intro | ![before](ci-refresh-before-desktop-dark-zh-CN-router-intro.png) | ![after](ci-refresh-after-desktop-dark-zh-CN-router-intro.png) |

### desktop-dark, zh-TW

| Surface | Before | After |
|---|---|---|
| catalog | ![before](ci-refresh-before-desktop-dark-zh-TW-catalog.png) | ![after](ci-refresh-after-desktop-dark-zh-TW-catalog.png) |
| migration-catalog | ![before](ci-refresh-before-desktop-dark-zh-TW-migration-catalog.png) | ![after](ci-refresh-after-desktop-dark-zh-TW-migration-catalog.png) |
| setup | ![before](ci-refresh-before-desktop-dark-zh-TW-setup.png) | ![after](ci-refresh-after-desktop-dark-zh-TW-setup.png) |
| migration | ![before](ci-refresh-before-desktop-dark-zh-TW-migration.png) | ![after](ci-refresh-after-desktop-dark-zh-TW-migration.png) |
| router | ![before](ci-refresh-before-desktop-dark-zh-TW-router.png) | ![after](ci-refresh-after-desktop-dark-zh-TW-router.png) |
| router-intro | ![before](ci-refresh-before-desktop-dark-zh-TW-router-intro.png) | ![after](ci-refresh-after-desktop-dark-zh-TW-router-intro.png) |

### mobile-light, en

| Surface | Before | After |
|---|---|---|
| catalog | ![before](ci-refresh-before-mobile-light-en-catalog.png) | ![after](ci-refresh-after-mobile-light-en-catalog.png) |
| migration-catalog | ![before](ci-refresh-before-mobile-light-en-migration-catalog.png) | ![after](ci-refresh-after-mobile-light-en-migration-catalog.png) |
| setup | ![before](ci-refresh-before-mobile-light-en-setup.png) | ![after](ci-refresh-after-mobile-light-en-setup.png) |
| migration | ![before](ci-refresh-before-mobile-light-en-migration.png) | ![after](ci-refresh-after-mobile-light-en-migration.png) |
| router | ![before](ci-refresh-before-mobile-light-en-router.png) | ![after](ci-refresh-after-mobile-light-en-router.png) |
| router-intro | ![before](ci-refresh-before-mobile-light-en-router-intro.png) | ![after](ci-refresh-after-mobile-light-en-router-intro.png) |

### mobile-light, pl

| Surface | Before | After |
|---|---|---|
| catalog | ![before](ci-refresh-before-mobile-light-pl-catalog.png) | ![after](ci-refresh-after-mobile-light-pl-catalog.png) |
| migration-catalog | ![before](ci-refresh-before-mobile-light-pl-migration-catalog.png) | ![after](ci-refresh-after-mobile-light-pl-migration-catalog.png) |
| setup | ![before](ci-refresh-before-mobile-light-pl-setup.png) | ![after](ci-refresh-after-mobile-light-pl-setup.png) |
| migration | ![before](ci-refresh-before-mobile-light-pl-migration.png) | ![after](ci-refresh-after-mobile-light-pl-migration.png) |
| router | ![before](ci-refresh-before-mobile-light-pl-router.png) | ![after](ci-refresh-after-mobile-light-pl-router.png) |
| router-intro | ![before](ci-refresh-before-mobile-light-pl-router-intro.png) | ![after](ci-refresh-after-mobile-light-pl-router-intro.png) |

### mobile-light, zh-CN

| Surface | Before | After |
|---|---|---|
| catalog | ![before](ci-refresh-before-mobile-light-zh-CN-catalog.png) | ![after](ci-refresh-after-mobile-light-zh-CN-catalog.png) |
| migration-catalog | ![before](ci-refresh-before-mobile-light-zh-CN-migration-catalog.png) | ![after](ci-refresh-after-mobile-light-zh-CN-migration-catalog.png) |
| setup | ![before](ci-refresh-before-mobile-light-zh-CN-setup.png) | ![after](ci-refresh-after-mobile-light-zh-CN-setup.png) |
| migration | ![before](ci-refresh-before-mobile-light-zh-CN-migration.png) | ![after](ci-refresh-after-mobile-light-zh-CN-migration.png) |
| router | ![before](ci-refresh-before-mobile-light-zh-CN-router.png) | ![after](ci-refresh-after-mobile-light-zh-CN-router.png) |
| router-intro | ![before](ci-refresh-before-mobile-light-zh-CN-router-intro.png) | ![after](ci-refresh-after-mobile-light-zh-CN-router-intro.png) |

### mobile-light, zh-TW

| Surface | Before | After |
|---|---|---|
| catalog | ![before](ci-refresh-before-mobile-light-zh-TW-catalog.png) | ![after](ci-refresh-after-mobile-light-zh-TW-catalog.png) |
| migration-catalog | ![before](ci-refresh-before-mobile-light-zh-TW-migration-catalog.png) | ![after](ci-refresh-after-mobile-light-zh-TW-migration-catalog.png) |
| setup | ![before](ci-refresh-before-mobile-light-zh-TW-setup.png) | ![after](ci-refresh-after-mobile-light-zh-TW-setup.png) |
| migration | ![before](ci-refresh-before-mobile-light-zh-TW-migration.png) | ![after](ci-refresh-after-mobile-light-zh-TW-migration.png) |
| router | ![before](ci-refresh-before-mobile-light-zh-TW-router.png) | ![after](ci-refresh-after-mobile-light-zh-TW-router.png) |
| router-intro | ![before](ci-refresh-before-mobile-light-zh-TW-router-intro.png) | ![after](ci-refresh-after-mobile-light-zh-TW-router-intro.png) |
