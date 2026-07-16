# Handoff — React/TS pattern mining of cloudv2 (Engineer A, 2022-08 → 2026-07)

## DEEP PASS — superseded by contention sampling (user decision, 2026-07-16)
The exhaustive 280-batch pipeline in `deep/` (corpora + batches.tsv + PROTOCOL.md) remains available but the user redirected to **sampled PR-contention mining**: pull review threads, find points of contention, derive hooks/skills from what the team actually debated. **100% COVERAGE COMPLETE** → `findings/pr-contention.md`: every PR review comment in all three repos fetched (39,742 total: cloudv2 35,273 + console 4,089 + ui-registry 380) and every frontend comment read or mechanically classified (~9,200 frontend: substantive read in full, bots/acks classified). **46 findings (C1-C46) + 3 grilling questions (G1-G3)**, spanning 2020-07 → 2026-07. Crown findings: the amplification principle — "as soon as I let 1 of these patterns in, LLM will abuse it" — as the WHY behind zero-tolerance review + the `lint:no-suppressions` CI gate (C44); the 2026 review-as-verification format with per-finding ✅/❌ re-review and honest verification limits (C45); dated origins for ~25 currently-encoded harness rules (C37-C43); the severity-taxonomy war sand/boulder → semantic → P0-P3 (C37/C14); zero-mock testing's founding document and its contention (C38); errors-as-alerts-never-toasts, frozen globals.css, baselines-updated-never-deleted, fail-closed destructive flows, copy-paste command sanctity (C46). Remaining unmined (optional): PR-level issue comments (non-inline), PR bodies pre-2026, review comments in company-data/ui (legacy Chakra library repo).

## Next session focus
Turn the evidence-backed findings in `findings/*.md` into harness changes — **reading everything through `findings/durability-map.md` FIRST**: it stratifies the whole corpus into Tier 1 timeless invariants (encode unconditionally), Tier 2 current-stack rules (encode in stack-tagged groups designed for wholesale replacement at the next migration), and Tier 3 superseded dead-stack guidance (never encode; negative-encode via ban lists — MobX and FormattedMessage still need adding). Then: (1) fix three rules the evidence **contradicts**, (2) add the highest-value hooks, (3) fold taste/judgment patterns into the existing skills.

## Current state
- Branch `benmal/react-pr-pattern-mining` in this workspace; nothing committed yet — all output lives in `.context/react-mining/` (gitignored).
- Corpus: `corpus/engineer-a-frontend-commits.txt` — 4,050 frontend commits (of 6,969 total) by Engineer A in `~/Documents/git/cloudv2`, format `sha|date|subject`. Frontend surface: cloud-ui, adp-ui, admin-ui, adp-console, tests/e2e-ui. adp-ui (2025–2026) is ground truth for current taste.
- All 8 themed mining passes are written to `findings/`: data-fetching, forms, routing-state, errors-resilience, testing, pr-craft-and-reviews, design-taste, architecture-evolution (the last recovered from the stopped agent's transcript).
- Every pattern in the findings carries 3+ commit SHAs, the anti-pattern it replaced, and an enforcement classification: `hook` (mechanical, near-zero false positives), `skill` (judgment/taste wording), or `exemplar` (canonical file in adp-ui).

## Decisions made
- Mining method: fix/refactor commits are primary evidence (the "before" state is the proven anti-pattern); 2026 adp-ui code is the living convention; agents were given the already-encoded harness rules and reported only new/refining/contradicting findings.
- Enforcement split: mechanical → hooks (extend the existing `connect-query-check.sh` rather than new scripts where it fits); judgment → skill wording; shape → exemplar file pointers.
- **Shell gotcha (affects any future mining):** the rtk/truncation filter silently caps piped `git log` output at ~50 lines — always redirect git output to a file first, then read the file.

## Findings that CONTRADICT currently-encoded harness rules (fix first)
1. **"Disabled submit needs Tooltip" is superseded** — 2026 code never uses native `disabled={!isValid}`; submit stays clickable with `FormErrorSummary`, or soft-disables via `aria-disabled` + tooltip (`c8ecec8`, forms.md #2).
2. **"createRouterTransport for ConnectRPC mocks" is legacy-cloud-ui only** — adp-ui mocks at runtime transport seams + `vi.mock('@connectrpc/connect-query')` + `page.route(rpcRoute(method))` (testing.md).
3. **userEvent-always has one deliberate exception** — combobox/typeahead uses `fireEvent.change()` because atomic value set beats per-keystroke races under parallel load (`defff748`, testing.md).

## Highest-value NEW hook candidates (mechanical, evidence-backed)
- Never `disabled={!isValid}` on submit buttons (forms.md #2).
- `RequiredIndicator` asterisk, ban "(optional)" label text (forms.md #5, `d925374`).
- Ban `nuqs`/search-param wrappers — native TanStack validateSearch (routing-state.md, `a23154bb`).
- Fire-and-forget teardown before unload/redirect must be awaited (errors-resilience.md #2, `8b92cbba56`).
- Proto optional = `undefined`, never `null` (errors-resilience.md #11, `3a706a84a0`).
- Bounded retry contract: no unclassified infinite retries (errors-resilience.md #5 + data-fetching.md #8).
- Role+accessible-name queries over loose text regex; no fixed sleeps / no-op `expect.soft`-in-`toPass` waits; reset mock state between tests (testing.md #1, #3, #10).
- Extend `connect-query-check.sh`: ban call-site `useTransport` imports (app-owned transport hook seam), ban over-specific invalidation keys (data-fetching.md #2, #4).
- Ban new `index.ts` barrel files in component dirs (architecture-evolution.md — zero present in adp-ui HEAD, so zero false positives).

## Key skill/exemplar additions
- **Data fetching:** semantic `QUERY_STALE_TIME` tier registry; cardinality-agnostic `invalidateResource`; loader↔hook query-key parity (silent double-fetch otherwise); guarded prefetch. Exemplar trio: `apps/adp-ui/src/hooks/use-llm-providers.ts`, `lib/api/resource-query-contract.ts`, `lib/query-policy.ts`.
- **Forms:** `useProtoForm` (proto-driven validation, zod purged from form bodies — zod only in route `validateSearch`); `setServerErrors` maps FieldViolations by descriptor walk; cast-free oneof helpers. Exemplars: `apps/adp-ui/src/components/registry-ui/lib/use-proto-form.ts`, `secret-form.tsx`.
- **Resilience meta-pattern:** "state resolved asynchronously, read too early or scoped too broadly" unifies cache-scope leaks, teardown races, out-of-order fetches, flag-default races, chained-query flicker. Layered boundary order: unauthenticated → chunk-load → cancellation → generic. Canonical utils listed in errors-resilience.md.
- **Testing pyramid:** unit → `.integration.test.tsx` (module-mocked) → `.browser.test.tsx` (committed light+dark baselines) → functional-only e2e with unmocked-request safety net (`apps/adp-ui/e2e/tests/base.ts`); visual regression banned from e2e.
- **PR craft (pr-craft-and-reviews.md):** ~12.5 single-purpose PRs/day, median 299 lines; body = Summary/Why/visual before-after (all states, light+dark)/reviewer read-order guide/test plan with exact counts/inline cross-model review. Review taxonomy A–K (fail-closed authz, tests-must-prove-claims, platform primitives over hand-rolled, scope-probing openers) → feed the review skill hats.
- **Design taste (findings/design-taste.md):** 15 principles P1–P15 + design-system timeline (Chakra 2022 → the legacy UI library 2023 → shadcn registry 2025-08+) + 7 exemplar paths. Standouts: two-click create with detail-page-as-wizard; flatten nesting via helper drawers; empty states with one CTA across four states; tables earn columns with container-width tiers; dark mode token-fixed and CI-tested; never fork the base kit (scope + upstream); loading reserves layout; machine truth beside human labels. Note: `apps/adp-ui/.claude/skills/{form-ux,design-audit,ui-development}` already codify much of this in-repo — reuse their wording.

## Multi-author expansion (added 2026-07-16)
- `author-weights.md` records the user's quality weights (Engineer A 10 → Engineer K 2). Higher weight wins pattern conflicts; below ~4 = context, not convention.
- **Engineer B (9) mined** → `findings/engineer-b.md`: 11 design-system craft principles (floating-UI anchor lifecycle, portals for overlays, dark-safe semantic tone-in-surface color, ramp weight parity, token-rename silent-fallback hook, two-axis variant APIs, drift convergence + codemods, changesets-as-design-docs, full state-matrix coverage, animation restraint, React 18+19 consumer matrix). His corpus: 46 ui-registry + 12 console + 8 cloudv2 PRs, all since 2026-04; ui-registry is his center of gravity.
- **Engineer C (8) mined** → `findings/engineer-c.md`: 8 patterns from 1,126 console commits (2023-09 → 2026-06). Standouts: `disabledReason` prop + `cannotVerbNounReason()` domain guards (refines the harness disabled-Tooltip rule); honest degraded states with verbatim reported reason + retry; FF lifecycle where flag removal = migration done; URL-vs-localStorage state split (convergent with Engineer A's routing-state.md); scroll-to-section over filtering; token-drift micro-audits. Cross-author convergence section included.
- **Engineer D/engineer-d (7) mined** → `findings/engineer-d.md`: founding author of the OSS predecessor/console (commit #1, 2019-09; 1,585 commits through 2024-10). Structural patterns superseded (do not encode); 7 surviving domain-UX patterns: push-down JS message filters (survived 2 rewrites — Engineer C migrated the modal in 2026), deterministic display order with user intent first, honest payload rendering (3-author convergence on "never lie in the rendering"), time as first-class UX, replace-not-push for nested pages, embedded-mode hardening (never crash the host), docs at point of need.
- **All remaining authors (6→2) mined** → `findings/remaining-authors.md`: Engineer E (flicker-free media, modals name their subject), Engineer F (the `window.location`+modifier-key patch `166e31beee` is the canonical "before" evidence for the harness `<Link>` hook; flag hygiene), engineer-g (2026 adp-ui create-flow shell + AutoForm co-owner; e2e reconciled in the same PR; console era superseded), Engineer H (convention-tests-as-executable-lint technique; parser round-trip tests), Engineer I/Engineer J/Engineer K (context only per weights; Engineer K is #2 ui-registry committer — weight her git-blame hits accordingly). New three-witness convergences: flag-removal-as-done, native link affordances, migrations-update-tests-in-same-PR.
- **Author mining COMPLETE**: all 11 weighted authors covered across findings/ (engineer-a = the 8 themed files; engineer-b.md, engineer-c.md, engineer-d.md, remaining-authors.md).

## Open questions
- (resolved) Architecture-evolution findings were recovered from the killed agent's transcript and written to `findings/architecture-evolution.md` — full migration timeline with SHAs, 7 "what died" anti-patterns, 4 meta-patterns (every migration ends with a lint freeze; new areas = federated remotes; adp-ui is the bootstrap template; big-bang routers, strangler data layers), and adp-ui module-organization rules (no barrels, domain-axis file splits, `.page.tsx` route split, symlinked proto).
- PR list hit the 400 `--limit` cap (6-week window); older review comments unmined — optional deeper pass.
- A11y/UX-copy got no dedicated pass (existing skills cover them; design-taste overlaps).

## Next actions
1. Read `findings/*.md`, dedupe overlapping patterns (loader↔hook key parity appears in both data-fetching and routing-state).
2. Apply the three contradiction fixes to CLAUDE.md/skills — evidence says current rules are stale.
3. Implement hook candidates in priority order above, each with an escape hatch (`// allow:` comment) and zero-false-positive test against adp-ui HEAD.
4. Fold skill wordings + exemplar pointers into connect-query, tdd/e2e-testing, resilience-review, review skills; wire the review-taxonomy hats into `/review`.
5. Ship via `/commit-push-pr` on this branch.

## Relevant artifacts
- `.context/react-mining/findings/` — seven themed findings files, all SHA-evidenced (verify design-taste.md landed).
- `.context/react-mining/corpus/engineer-a-frontend-commits.txt` + `engineer-a-all-commits.txt` — reproducible corpus.
- `~/Documents/git/cloudv2` — full clone; all SHAs resolvable there.
- Existing hook to extend: `.claude/**/setup-connect-query/scripts/connect-query-check.sh` (in this skills repo).

## Suggested skills
- /improve — turn findings into an implementation plan/backlog.
- /grilling — stress-test which hook candidates truly have zero false positives before encoding.
- /tdd — each new hook script gets a failing test against real adp-ui snippets first.
