# PR contention mining — what the team actually debated (2022 → 2026)

> Method: ALL pull-request review comments fetched from the three repos via paginated `gh api pulls/comments` — **complete universes: cloudv2 35,273, console 4,089, ui-registry 380 (39,742 total)**. Frontend-path comments: 100% coverage — every comment either read (substantive) or mechanically classified (bots, <30-char acknowledgments): ui-registry 380/380, console 2,681/2,681, cloudv2 ~6,100/~6,100 frontend. Threads reconstructed by reply-chain; findings below ordered by discovery pass. Raw data was in /tmp/prc (ephemeral; refetch commands in HANDOFF). Contention = where humans had to negotiate "good" — the highest-value spots for hooks/skills because they recur.

## Debates that settled → encode

### C1 — Mock at the transport seam, not the hook (thread 2665658618, 2026-01, cloud-ui)
Contributor: "I can test the hook separately, the setup-step test should not test the hook." Engineer A: "Let's mock the transport RPC instead of the entire network peering hook" + full `createRouterTransport` snippet. **Human-contention provenance for the existing mocking rule** — a debate the harness can now settle instantly. Enforce: `hook` (flag `vi.mock` of `@/hooks/api` modules in integration tests) + skill wording citing this thread.

### C2 — Actions are buttons, URL changes are links — and it helps e2e (thread 1517382514, 2024-03, console)
engineer-c: "make actions a button by default, and actions that change the URL a link. Helpful for e2e tests as well." engineer-d pushed back ("make the spinner a button?"), converged after clarification. Provenance for the existing `<Button>`/`<Link>` hooks; the e2e-selector argument is the WHY worth adding to the skill.

### C3 — Toasts must outlive the page; never create components in render (thread 2037769817, 2025-04, console)
engineer-c: "I don't like that we create these components in the render function… stick to `createStandaloneToast`." a teammate: "the issue was with page change hiding the toast." Rule: toast infrastructure mounts once at app root; navigation must not kill in-flight toasts. Enforce: `skill` (+ hook: component definitions inside render bodies).

### C4 — Readability beats unmeasured micro-optimization (threads 1095756819 + 1334380355, 2023)
Engineer A proposed an `Infinity`-aware retrier tweak; engineer-d: "leave it as is"; engineer-h: "I don't see the value of making this more illegible when the performance impact is basically 0." Same energy from engineer-d on `my` vs margin: "not something worth spending time on / discussing." Enforce: `skill` for review hats — perf nits require a measured or structural argument; style equivalence is explicitly not-worth-discussing.

### C5 — Migration PRs migrate; deep refactors are follow-ups (threads 1334379677, 1334380355, 1904085755, 2023–2025)
engineer-c: "to what level should I dive when refactoring? … keep the PRs as small as possible and rather do more of them." Engineer A repeatedly: "feel free to leave it for now" / "we can clean up easy wins" / "Approved PR nonetheless." Settled norm: in-scope = the migration + trivial adjacent wins; anything structural is out of scope but gets named. Enforce: `skill` (review + commit-push-pr guidance).

### C6 — Fix the shared component, don't fork it — and embedding is why (thread 1219224367, 2023-06)
Engineer A: "We already have an error page… can that be used?" engineer-h: existing page hardcodes `100vw`, breaks embedded console, can't override. Resolution: use the flexible approach, fix the shared page later. The registry-first rule already exists; the contention adds the tiebreak: a fork is acceptable only with a named defect in the shared component + a follow-up to fix it at source. (Engineer A's own 2026 comment "Should this live in UI registry one day?" is the same instinct inverted.)

### C7 — Theme-level config over per-component overrides (thread 1319682471, 2023-09)
Engineer A on a one-off fontFamily: "why not keep using Inter like we do elsewhere? … `theme.ts` under `fonts` for global setting." Also nested `ChakraProvider`s injecting CSS repeatedly. Chakra is dead but the meta-rule survived into the token system: fonts/colors/spacing set globally, never per-component. Provenance for existing token rules.

### C8 — Suspicious-string hook: uninterpolated template text shown to users (thread 2664325626, 2026-01)
Engineer A: "Did you mean to interpolate this string? This is the message to display to the user" — a `${}` placeholder sat inside a plain-quoted string. Enforce: `hook` — flag string literals containing `${` that are not template literals. Mechanical, near-zero false positives.

### C9 — Stale identifiers in error messages after renames (thread 2711394820, 2026-01)
Engineer A caught a console error still naming the pre-rename prop; Engineer K: "let's make that change in the ui-registry then" — fix upstream, not in the consumer copy. Enforce: `skill` (rename checklist: grep error/log strings for the old name) + registry fix-at-source provenance.

### C10 — Validation belongs to mutation boundaries, not read paths (thread 2668947225, 2026-01)
Engineer A suggested `protovalidate-es` for a traces read path; engineer-g: the response "is served by the backend and can be considered validated"; Engineer A conceded: "since we are not performing any mutations here, protovalidate-es is not required." Sharpens the existing "validate format not presence" rule with a direction: client-side proto validation applies to what we SEND, not what we receive.

### C11 — Domain hierarchies come from the domain owner, not FE assumptions (thread 1908410929, 2025-01)
FE displayed config inheritance wrongly; engineer-g supplied the authoritative 5-level Kafka config hierarchy (DYNAMIC_TOPIC → … → DEFAULT). Enforce: `skill` — when rendering inherited/fallback semantics, the precedence chain must be sourced from backend/domain docs, cited in the code.

### C12 — Kill stuck experiments (thread 1334390176, 2023-09)
Confusion over a broken "hide statistics bar" button ended with engineer-d: "Let's remove the entire button. It was an experiment that stuck around… not being used." Enforce: `skill` — when a review can't explain what a control is for, deletion is a first-class outcome.

### C13 — PR comment severity labels are old culture (multiple threads)
Engineer A's `[question]` prefix (2023), engineer-h's `[sand]` (non-blocking suggestion, 2023), "not blocking at all", "Approved PR nonetheless" — severity-graded review predates the 2026 `[P0-P3]` format (pr-craft-and-reviews.md). Confirms: the review skill should always emit graded, approve-to-unblock feedback.

## Debates worth institutionalizing as grilling questions (not settled by rule)

### G1 — Revert strategy: feature flag vs git history (thread 2687239078, 2026-01)
a teammate + a teammate: dead old-sidebar code should live in git history only; Engineer A: the flag "will just render the old sidebar in case we need to revert" at runtime. Both positions are right in different conditions (runtime rollback risk vs code hygiene). Grilling question for risky UI swaps: "If this ships broken, is the revert path a flag flip or a deploy? Who flips it, and when does the losing branch get deleted?" (Note Engineer C's 3-week flag lifetime norm, engineer-c.md P3.)

### G2 — Adopt a helper dependency vs wait for the platform migration (thread 2041903526, 2025-04)
Engineer A suggested `nuqs` for URL state; engineer-c: "we're super close to upgrading the router… nuqs would not be needed anymore. So I wanted to avoid it." History proved him right — `a23154bb` deleted nuqs after the TanStack migration. Grilling question for any new dependency: "Does a planned platform change make this redundant within a quarter?"

### G3 — Premature helper extraction (thread 1121969597, 2023-03)
engineer-h: "we could reuse this logic in the future… a helper function would be ideal"; engineer-d: "Where would we reuse it? What would the helper do?" — extraction denied without a second call site. Matches the deslop ladder; keep as the canonical quote for "delete/inline before abstract".

## Full-coverage pass (all 648 remaining comments, including 1-2-comment threads)

### C14 — Severity-label lineage runs 2022 → 2026 — `skill` (review)
`[sand]`/`[boulder]` size-labels (Engineer A, 2022-10) → `[question]`/`[suggestion]`/`[nit]`/`[major]`/`[future]` (2023-2026) → `[P0-P3] What/Why/Suggested fix` + "Fixed in <sha>" author replies (2026, see a teammate's replies — including reasoned declines that reviewers accept: "Kept as string-literal unions — idiomatic"). The review skill should emit the current format AND accept reasoned pushback as a valid resolution.

### C15 — Formatting debates belong in tool config, never PR threads (the 2022-07-12 war)
engineer-d posted 10+ objections to an auto-formatter pass ("parenthesis were there for clarity", "single line was fine", "added line breaks don't make this easier to read"); engineer-h: "gonna try to find a way to enforce it" — the debate ended by moving style into config. Canonical provenance for Biome-owns-formatting; a review hat should never argue style the formatter already decided.

### C16 — Library steering: platform primitives over hand-rolled — with a minimalism counterweight — `skill` + grilling
Engineer A steers repeatedly: `date-fns` (6 separate comments), `chrono-node` for timezone-safe natural language, `json-bigint` with `storeAsString`, `pluralize()`, `tokenlens`, proto Timestamp `.toDate()`/`.fromDate()` "so you won't be dealing with all this math for seconds/nanos". engineer-g pushes the other way: "Do we really need to pull in a new dependency for ~40LOC?" Both are house values → grilling question on new deps: "is this ≥40LOC of tricky domain logic (dates/bigint/pluralization → library) or a trivial util (keep it local)?"

### C17 — Query-layer discipline sharpened — `skill` (connect-query)
From Engineer A's 2026 comments: use the `transform` option on useQuery so no parsing lives in the component layer ([major]); `staleTime`/`gcTime` come from the global query client, delete per-hook copies; page sizes are conventions (100/500) enforced from the hook, not parsed in components; unbounded lists get infinite query + "load more"; TanStack-Query built-in polling over hand-rolled intervals; split multi-RPC pages into one file per RPC.

### C18 — Component-file hygiene rules from repeated singleton nits — `skill` + partial hooks
Split legacy/new variants into two files (`UsageCardLegacy`/`UsageCard`); "separate component for each even if it feels like overkill"; move pure helpers outside the component body (Engineer A + Engineer B + Engineer K all say this); no `use` prefix on non-hooks (`isLegacyApiKeyMode`); no type declarations inside render (Engineer K); early returns ordered most→least specific (Engineer K ×2); no dynamic `import()` for code organization — top-level imports unless lazy-loading heavy deps (Engineer A ×3, "adding unnecessary complexity").

### C19 — Reduced motion is a house preference — `skill` (design) — two-witness
Engineer A: "I wonder if we should do reduced motion by default… Most people @ the company prefer it" (2026-04); Engineer B ships `prefers-reduced-motion` respect and Engineer A's review flags reduced-motion regressions as P2 (edge fades, motion-removal). Encode: every animation honors `prefers-reduced-motion`; prefer subtle/no motion by default.

### C20 — The registry has a boundary, and consumers get white-gloved — `skill` (registry-workflow)
Engineer A: connect-query-specific table wiring "is at the boundary of what UI registry may still want to contain"; engineer-h: "what's the benefit of being a shadcn proxy — maybe small opt-in components that align with how we operate". Engineer K on breaking changes: "we've been doing this for months… agents never seem to find them all" (manual white-gloving fails → Engineer B's codemod discipline is the answer, three-witness now). Engineer K: "separate PRs for unrelated dependency bumps — this changed every single registry component."

### C21 — The team curates code FOR AI agents — new theme, `skill` candidates
Registry decisions made explicitly for LLM consumers: native-select removed "so LLMs don't reach for it" (Engineer B); `bunx` standardized in docs "so LLMs use it consistently"; jsDoc-vs-docs debated by LLM readability (Engineer K/Engineer B); review comments call out "reduce this LLM comment", "ai-slop verbose comment cleanup", "overengineering claude during base ui migration?"; Engineer A proposes skills IN review comments ("we need a skill called typography-refactor", "use this form-refactorer skill"); engineer-g on skills fetching remote content: "feels bad that they can control my agent otherwise — copy paste the current state into the skill" (supply-chain caution for skill authoring). Harness implication: reviews should flag LLM-slop comments (hook: comment-density heuristics) and registry/docs decisions should consider what agents will reach for.

### C22 — Early-era taste that still holds (engineer-d 2020-2021)
Display names must self-explain ("what does the Default timestamp mode actually display?"); clickable region fills the whole cell; screenshots in reviews from day one; clipboard/API availability checks (`caniuse` — Engineer A echoes in 2023). Also engineer-g's domain-naming authority: "stick to the otel names — they directly refer to span attributes" (naming defers to the upstream standard), and his regex-escaping catch: escaping user input "fundamentally changes search semantics from pattern matching to literal" — semantic changes disguised as safety fixes need explicit decision.

### C23 — engineer-c's testability sweep pattern (2026-01-13, nine comments in one PR) — `skill`
On a single traces PR: add `data-testid` (×4) + `aria-expanded` "for better e2e experience"; move parsing logic to utils + unit test (×3); URL per tab; persist filter state to URL "so URLs are shareable"; `rem` over `px`; consolidate duplicated `isJSON` helpers. One reviewer, one pass, one checklist — this IS the review-skill checklist for new feature pages.

## ui-registry at 100% (all 380 comments; adds registry-governance findings)

### C24 — Registry governance rules from the founding era (2025-06 → 2026-07) — `skill` (registry-workflow)
- **Framework-agnostic invariant**: "I would personally avoid adding any react-router-dom dependency because we should make it framework agnostic" (Engineer A, 2025-11); consumers span React 18/19, SPA/SSR.
- **Documented dependency tradeoffs**: `yarn.lock` kept solely because Snyk can't scan `bun.lock` — re-litigated once (2026-04) and settled by linking the Snyk support thread. Rule: infra tradeoffs get a written why + external reference, so future reviewers don't re-argue them.
- **Composability over render props**: Engineer A pushed `BadgeGroup` from `items` prop to children composition (×2, 2026-01/02); Engineer K conceded "in hindsight I never should've done so much render coercion using items props". Registry APIs follow shadcn's composition idiom.
- **Explicit variant names**: "`default` as a value makes no sense" — variants are named for what they are, `default` only maps to one.
- **Component admission bar**: "if a component is great out of the box, it deserves a spot in our library if it meets our needs" (Engineer A) — need-driven, not novelty-driven; demo count capped for Chromatic/build times.
- **Implicit correctness via selectors**: Engineer K added button-icon sizing selectors because "a lot of people passing different sizes to icons" — when consumers repeatedly misuse an API, fix it structurally in the component, not in review comments.
- **Changelog discipline**: docs/playground changes are not breaking and don't enter the changelog; breaking entries must include a migration path/example (Engineer A).

### C25 — Skills and agent-tooling are first-class review subjects — `skill` (harness meta)
SKILL.md files get line-level review like code: "add more keywords so the skill kicks in more often" (Engineer A ×2), "we shouldn't suggest no-op arrow functions", Engineer K's incremental-skill strategy ("very short for now… stop seeing incorrect tailwind token usage first"), console.log-in-skills debate, figma-to-component guardrails ("disallow 9px in brackets" — LLMs must stay in the token scale), CLS-check tooling ideas, subagent additions praised ("registry-deps-validator… we would benefit from having some subagents like this"). The harness itself is part of the codebase and gets the same review bar.

### C26 — CI/tooling reviews have a cost-taste (Engineer A, 2026-04-13, four comments on one workflow)
"Caching bun dependencies takes longer than installing" → remove; don't fetch full git depth; "that's a very beefy machine, we can scale it down"; use latest Playwright image. Plus "killed reviewdog intentionally, it was annoying" — CI ergonomics get actively pruned, not accreted.

## Console at 100% (all 2,681 frontend comments; 299 mechanically-trivial, 1,839 substantive read)

### C27 — The registry-consumer review checklist exists in the wild (Engineer K, 2026-06-03, 30+ comments on one PR) — `skill` (review)
A complete checklist, live: BadgeGroup for overflow (×3); EditableText/Separator/Label/Spinner/useDisclosure already exist — search before building; typography variants, never `text-sm` one-offs; jsdoc for prop comments ("shows in intellisense"); `cva` for variants; no comments above JSX ("composition speaks for itself"); no deep selectors — let Button size its own icons; boolean names past-tense or `is`-prefixed; `git mv` for renames; **before/after screenshots required for visual changes** (major); "tokenize all the things". Plus explicit LLM-wrangling: "I beg claude to not add these", "really claude… do we really need a function for a ternary?", and a user-level skill gating low-quality comments ("does the code speak for itself?").

### C28 — Registry sync is its own PR; consumer files under registry management are never hand-edited — `skill`/`hook`, three-witness
Engineer K (blocker): "can we make ui-registry updates separate from feature work? very hard to detect accidental registry changes"; Engineer B complies by splitting registry updates into their own PR; "these will be blasted away whenever the registry component updates" (Engineer B, Engineer K ×2, Engineer A's shared-types move). Hook candidate: flag diffs that modify files under `components/registry-ui/` outside a registry-sync PR.

### C29 — The Base UI migration P0 as a case study — `skill` (upgrade-dependency)
Consumer-side catch: "every delete flow is broken: the confirm dialog never opens" — Radix `onSelect` silently dropped by Base UI `Menu.Item` (`a teammate` fix, Engineer A P0). Exactly the class the ui-registry codemod review predicted (C24/engineer-b.md P7). Lesson: registry breaking changes need consumer smoke tests on destructive flows, not just visual baselines.

### C30 — Recurring URL-state bug class: stale `?page=` renders empty tables — `hook` candidate
Found twice independently (tab-consumers `?consumerPage=999`, quotas-list `?page=` P2): URL pagination fed into controlled tables without clamping. Also: raw search input written to URL can leak sensitive config values (2026-06-12). Rule: URL-sourced indices are clamped against data length; URL-persisted search on sensitive surfaces is allow-listed.

### C31 — Security instincts in frontend review — `skill` (review adversarial hat)
e2e failure log dumps may include license/JWT/SASL material → redact (2026-06-12); bcrypt over hand-rolled crypto for hashes; `/sql` route feature-gate bypassable by direct navigation (P1); SELECT-only gate "both over-restrictive and trivially bypassable"; module-global run token breaks multi-instance (P2). Frontend review includes an authorization/leakage pass, not just UX.

### C32 — Zero-vs-undefined rendering bugs — `hook`/`skill`
"A quota explicitly set to `0` renders as 'No limit configured'" (`value ? … : fallback` on numerics); `lag !== 0` including null rows (Copilot). Rule: numeric display fallbacks use explicit `== null` checks, never truthiness.

### C33 — e2e conventions converged hard in 2026 — `skill` (e2e-testing)
waitForURL/waitForRequest over element polls and timeouts (10+ comments); test.step everywhere "so CI shows exactly where we failed"; PLAYWRIGHT flag makes toasts never dismiss; clipboard tests Chromium-only; retries CI 1 aiming for 0; **markdown reporter locally because it's LLM-token-friendly**; match RPC URLs on `Service/Method` not `v1alpha1` (version-proof); Playwright test-agents adopted with test.step generation. Plus test-value bar: "quality over quantity" — delete render-only tests, test side effects users can take (×5).

### C34 — One genuine UNRESOLVED contention: e2e locator strategy — grilling
engineer-c: role-based locators "test a11y as a side effect", verifies page contents not just URL; Engineer A: `getByRole` is slower, prefers testids + waitForURL/waitForRequest. Both argued from real values (a11y coverage vs speed/flake). Grilling question for e2e suites: "does this suite owe a11y coverage, or is that owned by axe/browser tests?"

### C35 — AI-era code review culture, console edition — `skill` (harness meta)
"@claude review will this capture all chakra components?" inline; codex `/review` findings pasted as review comments and how-to shared ("Codex CLI has a built-in /review command"); Claude-generated patterns explicitly assessed ("this pattern was generated by claude… should we tweak it?", "claude flub", "overengineered around this part"); CLAUDE.md deliberately compacted when a size warning appeared ("all business logic preserved without hitting the context threshold"); skills requested in reviews ×4 (test-generator, typography-refactor); "I will make it deeply ingrained into LLM use so you won't have to remember" (npm script naming). The team treats agent behavior as a first-class review dimension.

### C36 — Assorted settled rules from the full pass (each 2+ occurrences)
- Never `-new` suffix components shipped without a flag decision: "if it's not below FF why can't we just replace the old component?" (Engineer A).
- Referential integrity in UX: "we should not allow deleting MCP servers that are in use by the AI agent".
- Tooltip-on-disabled reaffirmed by engineer-c 2026-04: "aim for always showing a tooltip why a button is disabled" — but implemented by wrapping, per the forms finding.
- TooltipProvider hoisted once, never per-cell (P3 + Engineer C's quotas fix).
- N+1 query per table row = P2 (`useXQuery` inside row components).
- Pre-release/beta dependencies challenged with bundle-size numbers (react-data-grid beta, 150KB gzip measured with Claude); unmaintained deps rejected with root-cause analysis (react-beautiful-dnd breaking React 19 via react-redux@7).
- Tailwind v4 idioms enforced: bang suffix `className!`, `wrap-break-word`, `space-y-*` over fake margins.
- Retry buttons get prominence matching the surface (destructive alert → not `variant="secondary"`, P3).

## cloudv2 2022-05 → 2024-01 at 100% (2,277 substantive frontend comments read; bots/trivia classified)

### C37 — The severity-taxonomy war and its resolution (2022 → 2023-12) — provenance for C14
Two label systems competed: geological size ([dust]/[pebble]/[sand]/[rock]/[boulder]/[mountain] — engineer-h/Engineer A, 2022) vs semantic ([blocker]/[suggestion]/[question]/[future]/[nit] — Engineer E). Engineer E twice pushed to settle it: "pebble doesn't really communicate what I need to do to move forward" (2023-08), "it's really hard to remember what dust, stone, rock, boulder mean — stick to this doc" (2023-12). Semantic labels won and evolved into today's P0-P3. Lesson for the review skill: labels must encode REQUIRED ACTION, not size.

### C38 — The zero-mock testing philosophy has a founding document (2022-10-22) and a real contention
Engineer A: "This is a foundation on how we should write tests from now on. 0 mocks except calling the fake API." a teammate dissented hard: "unit test by definition requires mocking… child components should be tested on their own." Engineer E brokered ("what Engineer A has done is removed the boilerplate"). History resolved toward Engineer A's position (msw fake-API → createRouterTransport → today's transport-seam mocking, C1). Corollaries from the same era: "only mock for unhappy paths"; mock factories use `assign`, never `merge` ([boulder] — merge kept stale nested zones); render-only tests flagged [blocker] "this test does not do anything" (×3 — the origin of quality-over-quantity, C33).

### C39 — Origins of currently-encoded rules (all confirmed, with dates)
- **No-`as`-casting culture**: engineer-h's 2022-08-25 sweep — eight `[boulder] seems like an unnecessary casting` comments in one day; "type the useSelector instead".
- **Toast on every mutation outcome**: [boulder] "dispatch an action to trigger a toast with success" (2022-10); missing-error-toast sweep (2022-10-19 "we previously never showed an error but we should have").
- **`-` fallback for absent values** (Engineer E, 2022-10) — ancestor of C32's zero-vs-undefined rule.
- **Design tokens**: Engineer E 2023-06 ×3 "what is this color? I would like all colors defined as tokens and not used ad hoc"; Figma 7px → "round to the nearest spacing-scale multiple" (Engineer A 2023-09).
- **Status-color semantics**: "Red is really to draw attention. deleted would be gray" (Engineer E 2023-06).
- **Retry policy**: settled 2023-12 — retry 5xx/INTERNAL/UNKNOWN, never 4xx, set once on the global QueryClient (a teammate + a teammate gRPC-code correction + Engineer A moving it to global config).
- **Proto enums by name**: Engineer A 2023-12 explaining `CLOUD_PROVIDER_AWS`-vs-`1` during public-API adoption; engineer-h repeatedly: "use the generated code directly, remove the model abstractions".
- **UX copy authority**: Engineer E linking THE user-facing message doc from 2022-11; the docs editor's 110-suggestion copy sweeps (2023-06); "Cannot sounds less accusatory than Don't"; no-"Please" rule; brand-orange never used for errors ("our brand color is already too close to warning/red" — designer, 2023-11).
- **waitForTimeout ban**: Engineer A 2024-01 in checkly-era e2e ("introduces flakiness… wait for the input to be present/enabled instead") — two years before the adp-ui rules.
- **Named exports**: settled in a quality meeting (2023-05, a teammate: "default exports allow different names between imports — make a linter rule").
- **kebab-case for non-component files**: engineer-h asking "do we have a standard?" (2023-12) → Engineer A's Biome rule (2025-10, C-console) — a 2-year convention gestation.

### C40 — Validated dead ends the early era proves (extends architecture-evolution "what died")
- createReduxModel generic abstraction (2022-07): debated at birth ("difficult to extend"), dead within a year — genericizing Redux CRUD didn't survive contact with rtk-query.
- redux-observable epics: Engineer A 2022-10 "massive overkill… rtk-query trims so much fat (actions, selectors, reducers)" — the original data-fetching migration argument.
- i18n/react-intl: heavily invested 2022-2023 (readable keys won over generated ids; separate copy repo floated), then abandoned — Engineer A 2024-01: "I don't see us using i18n for everything anytime soon". Lesson: English-only products pay i18n tax without benefit.
- NextJS Console federation experiment (2024-01, Engineer A + engineer-h) — built, then discarded for rspack MF. engineer-h's veto shape: "the NextJS change should accommodate to this", not vice versa.
- Component-level Cypress tests (2022-09): engineer-h "[boulder] we should focus on E2E" — killed at proposal.

### C41 — Security/privacy instincts, early era — extends C31
Sentry replays: "everything is redacted by default" verified before enabling (2023-02); client ID committed → "rewrite history to ensure it does not remain in any GH commits" (2023-09); JWT decoding on the client resisted ("don't feel like we should be decoding the token client-side"); okta issuer as env secret ([boulder], 2022-10); `verifyEmail` as GET flagged [blocker] "a GET request shouldn't change anything" (2023-08).

### C42 — Review culture mechanics worth encoding
- Follow-ups are created IN the review: "Added issue #NNNN" appears 30+ times — a deferred fix isn't accepted until it has a ticket link (hook candidate for review skill: every "later/follow-up" reply must contain an issue/ticket reference).
- Reasoned decline is a valid resolution (Engineer E on chakra-spacing for the loading screen; Engineer A accepting).
- Kindness explicitly maintained: "sorry if this is too picky — everything is completely fine :)" (Engineer A 2023-05); "You can't write a novel on the first draft" (Engineer E 2022-10).
- Screenshots/Looms attached for visual claims from 2022 onward (later formalized as C27's before/after requirement).

## cloudv2 2024-01 → 2026-07 at 100% (final ~3,400 substantive comments read)

### C43 — Origins recovered for currently-encoded rules (mid-era, 2024-2025)
- **Cache tiers**: engineer-f proposed "Long/Medium/Short-lived cache time" (2024-03); engineer-h capped it at 2-3 values ("if we go that granular, keep the magic number in the query") → today's `QUERY_STALE_TIME`. `Infinity` criterion defined: "resource never refetched unless we invalidate".
- **Custom-hook conventions born in review**: `*MutationWithToast` suffix (2024-06, engineer-h's naming), options-with-`enabled` exposure debate (Engineer A won: "leave room for disabling via options"), hooks in `hooks/api/<service>/`, "don't override mutateAsync with hidden side effects — be explicit" (engineer-h blocker, 2024-08).
- **Presentational purity sweep**: engineer-h 2024-07, eight comments in one PR — "make ssoProviderId a prop"; page fetches, widgets receive. Origin of the hooks-out-of-components rule.
- **Exhaustive-enum tests**: engineer-h 2024-06: "make a test so if somebody adds another proto state, it fails — ensures the code gets updated with the proto."
- **`getByRole` slowness**: Engineer A 2024-06: "extremely slow because jest traverses the DOM tree" — the testid preference has a measured origin, predating the engineer-c a11y debate (C34).
- **Type predicates for proto oneOf** (engineer-h teaching, 2024-07) → today's `isClusterCustomerManagedResourcesGCP` pattern.
- **Retry/backoff**: exponential backoff + max retries demanded on hand-rolled retry (engineer-h 2025-06); Engineer A: "react-query has retry built in".
- **jest → vitest argued on ESM grounds** (2024-05: "Jest will bite us if we ever move to full ESM") — executed 2025-03.
- **Verbose names for LLMs**: Engineer A 2025-04: "for LLMs it's more useful to be verbose — makes the LLM hallucinate less" — LLM-awareness in naming conventions 18 months before the ADP era.

### C44 — The amplification principle — WHY the review bar is zero-tolerance — `skill` (core)
Engineer A, 2026-04, twice in one week: "I can't accept this — as soon as I let 1 of these patterns in, LLM will abuse it and spread more of them" and "why so many ignores? if we leave this in the code, LLM would love to abuse this pattern." Corollaries enforced mechanically: `lint:no-suppressions` blocking CI gate added the same month ("if it reintroduced, it means CI is not strict enough"); react-doctor overrides systematically burned down ("stop ignoring rules and fix them"). This is the single most important cultural finding: in an AI-authoring codebase, every tolerated anti-pattern is a training example.

### C45 — The 2026 review format at full maturity — `skill` (review) — exemplar threads
The ADP-UI era reviews are verification, not opinion: P0-P3 + What/Why + fix; claims checked against backend source (`apps/aigw/internal/llm/authz.go`), external product docs (13 MCP clients' config schemas — Cursor base64 deeplinks, Antigravity's real config path, Warp's `--mcp` auth surface), and CSP semantics (a teammate successfully DISMISSING a Engineer A P1 with RFC-level reasoning — reviewer accepts). Honest verification limits stated: "I can't live-verify (no provisioned staging), so I stopped over-promising rather than assert it works." Authors reply "Fixed in <sha>" per finding; re-review posts ✅/❌ status updates per prior finding against the new tip. Grilling-quality product pushback lives inside code review ("I don't want a create dialog, I want a dedicated create page").

### C46 — Late-era settled rules (each 2+ occurrences, 2026)
- **Errors surface as alerts, never toasts** (Engineer K 2026-06: "we should always surface errors as an alert, never a toast — update other call sites") — completes the toast-minimalism arc (C-console).
- **globals.css is frozen**: "no globals.css change allowed for this PR"; fixes belong in the affected component; `@utility` extractions go to shared constants (`TRUNCATE_FADE_CLASS`).
- **Visual baselines are updated via workflow, never deleted** ("snapshots should be updated, not deleted outright"; `adp-ui-update-baselines` dispatch).
- **Destructive flows fail closed**: delete dialogs gate on successful zero-reference lookup (loading/error ≠ confirmable); one-click irreversible delete without confirmation = P1; `fresh: true` lookups for destructive dialogs (staleTime 0).
- **Dialog keyboard contract**: Enter-to-confirm and ESC must respect in-flight/dirty state; X/Escape must hit the same dirty-gate as Cancel.
- **Copy-paste commands are sacred**: copy button must never include sample output; unquoted interpolation into bash/TOML/YAML = P1/P2; `<code>`-wrap command names.
- **Hover-only controls need `focus-visible` parity** (session-picker, guardrails chips).
- **New molecules ship with tests** (P1 ×2: "new 222-line stateful component ships with zero tests").
- **One-time codemods don't get committed** (ts-morph dep + 5 scripts flagged); benchmark docs live in PR descriptions, not the repo.
- **Old-version proto fixtures in tests are a P1/P2 class**: v1beta2 fixtures against v1-typed props "invisible to CI" — fixtures must import the schema version the component uses.

## Meta-findings
- **Engineer A is the most frequent thread participant across all eras and repos** — the review taxonomy in pr-craft-and-reviews.md is not a 2026 artifact; the `[question]`/convention-setting style is visible from 2023.
- Contention volume is low-single-digit threads/month on frontend paths — the team converges fast; most threads end in explicit agreement ("All good, agreed"), which is what makes the settled rules trustworthy.
- Unmined: PR-level (non-inline) discussion comments, issues, and the middle pages of each era. The sampling method is cheap (~20 gh calls) — rerun with more pages/eras when a deeper pass is wanted.
