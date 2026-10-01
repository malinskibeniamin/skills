# Blume 2.1 visual verification

Revision pair: a666713cdba0326f758cb04270e6fbce3d75f443 -> d64aaf00a0933916918a4661028012ebcf1d8985.
Blume application change: ab3aa96e165b21030e53e28d1089832e07213aea; follow-up adds tests and documentation only.

Environment: macOS arm64, Chromium, en-US, device scale 1, reduced motion;
1440x1000 desktop and 390x844 mobile. Video uses 1280x720, identical dark
browser preference on both sides. Same checked-in skill content; baseline built
in an isolated detached worktree. No human browser, credentials, or private data
in captures.

| Surface/state | Visual assertion | Comparable evidence |
|---|---|---|
| Landing/header, light and dark | homepage, homepage-dark | before/after homepage and homepage-dark |
| New directory, desktop/dark/mobile | directory, directory-dark, directory-mobile | after directory; before is the prior homepage/filter discovery flow |
| New onboarding, Claude and Codex | onboarding-claude, onboarding-codex | after onboarding-claude/onboarding; prior entrypoint is the homepage |
| New localized onboarding | onboarding-polish, onboarding-simplified-chinese, onboarding-traditional-chinese | after polish/simplified/traditional; no prior onboarding route |
| Current skill and new narration player | skill, narration-paused | before/after skill plus after narration |
| Archived skill wrapper | archived-skill | before/after archived |
| Related links and site footer | related-and-footer, footer | before/after related-footer |
| Empty landing search and recovery | filter-empty plus functional recovery test | before/after filter-empty |
| Global search/results/keyboard dismissal | global-search | before/after global-search |
| Mobile onboarding with wrapped commands | onboarding-mobile | after mobile; before mobile is the prior homepage |

Normal command: `bun run docs:test:browser` -- 18 tests passed, 18 screenshot assertions. Initial missing-baseline runs failed; each actual image was inspected
before accepting the new baseline. Final normal run has no update flags, changed
thresholds, or masked areas. These are initial platform-specific baselines, not
bulk changes to an existing golden suite. Keyboard Escape in Chromium first clears
the native search field, then dismisses the dialog; the test asserts both states.

Inline product/design/engineering/QA review: readable hierarchy, localized header
and footer, no mobile overflow, proper current/archived wrappers, visible empty
state and recovery, functional view persistence and narration controls. No remaining
diff-introduced P0/P1 found. Coverage is representative shared templates and named
states, not a claim that every one of the 1,421 pages was visually inspected.

Other verification: lint:fix, type:check, format:check, root tests, docs:check,
frozen install passed. Build emitted 1,437 outputs. Accessibility audit checked
1,421 HTML pages / 110,838 checks, zero issues. Independent live replay confirmed
97 directory cards, search aliases, translations, archived links, generated skill,
and private-snippet 404; no page errors or failed page requests.

Baseline limitations: docs unit files have 23 pass / 1 existing SVG-title assertion
failure; mm already produces an agent-skill frontmatter build warning on Blume
2.0.3. Neither is modified or suppressed here. Speech hardware is stubbed, so
audible quality is not verified. No Firefox/WebKit or physical-device claim.
