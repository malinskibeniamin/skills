# Durability map — what survives migrations vs what dies with the stack

The corpus spans six years and at least seven full-stack migrations:

| Died | Replaced by | Era of death |
|---|---|---|
| bootstrap / antd / Chakra / the legacy UI library | Tailwind v4 / shadcn / Base UI / ui-registry | 2025-2026 |
| React 18 (+ manual memo, forwardRef) | React 19 + Compiler | 2026 |
| react-router-dom (v5 → v6 → dead) | TanStack Router | 2026-01 |
| Redux Toolkit Query (+ redux-observable epics before it) | connect-query + gRPC + protobuf | 2023-2025 (19-month strangler) |
| Yup (+ hand-rolled validators) | zod / standard schema / protovalidate | 2024-2026 |
| Formik | react-hook-form (+ useProtoForm) | 2023 |
| Redux / MobX | zustand + React context | 2024-2026 |
| CRA / webpack / jest / msw-everywhere | rsbuild / vitest / transport-seam mocks | 2024-2025 |
| i18n (react-intl, base.json/en.json) | plain strings + docs-team review | ~2024 (quiet death) |

**Rule for harness-building: encode the invariant, not the API.** A rule that names a current-stack API must live in a stack-tagged group (like Biome `noRestrictedImports` blocks per dead stack), so the next migration replaces the group wholesale instead of leaving stale guidance to mislead agents. History shows *every* migration ended with mechanical enforcement of the old stack's death (C39, M1) — the harness's stack-tagged rules are the continuation of that practice.

## Tier 1 — TIMELESS invariants (observed across ≥2 stack eras; encode unconditionally)

1. **The amplification principle** (C44): any tolerated anti-pattern gets amplified by LLM authors. Zero-tolerance review + no-suppressions gates. (2026, but it is the explicit rationale for behavior visible since 2022.)
2. **Never lie in the rendering** — honest payloads (engineer-d 2023), `-` fallbacks (2022), zero-vs-undefined (2026), no fake defaults (272k tokens), verbatim reported reasons, don't show unready features. Three-author, three-era convergence.
3. **URL = shareable state, local/session storage = personal prefs.** Witnessed in rtk-era `ui.ts` (2022), the nuqs debate (2025), TanStack `validateSearch` (2026), engineer-g's `useQueryStates` (2026). Mechanism changed 4×; the split never did.
4. **Design tokens over ad-hoc values.** "All colors defined as tokens, not ad hoc" (Engineer E, 2023, Chakra) ≡ theme-token rules (2026, Tailwind). Same for spacing-scale multiples (Chakra ×4 → Tailwind scale) and "round Figma's 7px to the scale".
5. **Fix shared components at source; never fork or inline-restyle.** UI-library era (2023 Error401Page) ≡ registry era (2026). Includes: registry/library changes are their own PR; consumer-local edits to managed files get blasted away.
6. **Mock at the boundary seam; mock as little as possible.** The seam moved (fake-API msw 2022 → createRouterTransport 2024 → runtime transport seams 2026) — the principle and its corollaries (only mock unhappy paths, factories use assign-never-merge) never moved.
7. **Tests must prove a side effect a user can cause.** Render-only tests deleted as worthless in 2022 ([blocker] "does not do anything"), 2025 ("quality over quantity"), 2026. Deterministic waiting, never fixed sleeps (2024 checkly → 2026 vi.waitFor).
8. **Feature-flag lifecycle: add → migrate → assert → remove; removal is the definition of done.** SSO flag cleanup 2024, Engineer C's 3-week flags 2026, plus "every migration ends with a lint freeze."
9. **Severity labels encode required action; graded, approve-to-unblock reviews; follow-ups need ticket links; reasoned declines are valid resolutions.** Survived three label systems (sand/boulder → blocker/suggestion → P0-P3).
10. **Review-as-verification**: claims checked against source/docs/live behavior; verification limits stated honestly; before/after screenshots for anything visual (2020 → mandatory 2026).
11. **Domain truth comes from the domain owner** — Kafka config hierarchy, otel naming, GiB-vs-GB, SLA numbers, "docs team reviews all user-facing copy" (2022 doc → the docs editor sweeps → ux-copy skill).
12. **Naming: verbose beats clever; no acronyms in routes/files; booleans `is`-prefixed; entity-precise verbs** ("Assign roles" not "Change roles"). Explicit LLM justification since 2025: verbose names reduce hallucination.
13. **Security instincts in frontend review**: secrets never in git history (rewrite it), redact logs/replays, fail-closed authz, GET never mutates, client-side token decoding resisted, URL-persisted state audited for leakage.
14. **Scope discipline**: single-purpose PRs; migrations migrate (deep refactors are named follow-ups); unrelated dep bumps separate; "does this belong in this PR?"
15. **Kill unused experiments and delete legacy on the way out** (hide-statistics button 2023 → SCSS deletion 2026 → "snapshots updated, not deleted" for things that must live).
16. **Navigation history hygiene**: nested/intra-section navigation replaces, section entry pushes (engineer-d 2024, router-agnostic).
17. **Component state completeness**: loading/empty/error/disabled/stuck/indeterminate all handled; loading reserves layout (CLS); destructive flows fail closed.
18. **Reduced/restrained motion; animation serves state clarity** (2020 antd table polish → 2026 prefers-reduced-motion).
19. **Platform primitives over hand-rolled for tricky domains** (semver 2022, date-fns/Intl/chrono arc) — with the minimalism counterweight ("new dep for 40 LOC?") as a standing grilling question.
20. **The team curates the codebase for AI consumption** (C21/C35): docs/registry/naming decisions made for what agents will reach for; skills reviewed like code; agent behavior is a review dimension. (2025→, but structurally timeless for this org.)

## Tier 2 — CURRENT-STACK rules (encode, tagged `stack:2026`; re-evaluate at next migration)

- **connect-query + protobuf**: hooks in `hooks/api/<service>`, `*Query`/`*MutationWithToast` suffixes, `transform` option over component-layer parsing, `createConnectQueryKey`, awaited invalidation (never refetch), cardinality-aware keys, `QUERY_STALE_TIME` tiers, global retry 5xx-not-4xx, `create(Schema)`, enums by name, `.toDate()`, oneof type predicates, protovalidate at mutation boundaries, FieldMask from dirtyFields, test fixtures import the same proto version as the component.
- **Forms**: react-hook-form mode onChange, `useWatch`, spread `...field`, `useProtoForm` owns state, no native `disabled={!isValid}` submit, FormErrorSummary, setServerErrors from FieldViolations.
- **TanStack Router**: loaders + `preload="intent"`, loader↔hook query-key parity, zod `validateSearch`, `.page.tsx` split, no `{strict:false}`, typed navigation, clamp URL-sourced page indices.
- **zustand**: `create<T>()()`, `useShallow`, devtools wrapper, test provider; sessionStorage-compatible persistence.
- **Tailwind v4 / registry**: `cn()` for all class composition, bang-suffix important, `wrap-break-word`, `space-y-*`, tone×variant axes, fumadocs CLI sync, changesets-as-design-docs, codemods for breaking changes, errors-as-alerts-never-toasts, Toaster-at-root (sonner), frozen globals.css.
- **React 19 + Compiler**: no manual `useMemo`/`useCallback`/`memo` (annotation-mode caveats documented), no `forwardRef`, named useEffects, no components/types declared in render.
- **Test stack**: vitest 4-tier taxonomy, committed light+dark browser baselines updated via workflow, markdown reporter locally, Chromium-only clipboard tests, `vi.fn()` not `jest.*`.

## Tier 3 — SUPERSEDED (do NOT encode; meta-lesson only where noted)

| Dead guidance (appears in corpus, must not leak into harness) | Surviving meta-lesson |
|---|---|
| Chakra style props (`Box`/`Flex`, `my={4}`, `colorScheme`, `boxSize`), `chakra.span`, ChakraProvider nesting | Tier-1 #4 (tokens), #5 (fix at source) |
| Chakra `useDisclosure` steering | concept reborn as registry `use-disclosure`; cite registry, not Chakra |
| RTK Query `providesTags`/`invalidatesTags`/`initiate()`/`skipToken` mechanics; "add msw handler for every endpoint" | Tier-1 #6 (seam mocking); invalidation discipline now lives in connect-query terms |
| MobX `observer`/`useLocalObservable`/`@computed`; "keep upper-level mobx classes for consistency" (2025!) | none — explicitly repudiated ("strongly advise against adding tech debt with observer()") |
| redux-observable epics, createReduxModel, toast-via-redux-middleware | Engineer A's 2022 "rtk-query trims the fat" argument is itself superseded; keep only the migration-shape lesson (strangler for data layers) |
| Formik `Field` wiring; Yup schemas, `yupErrorMessages.utils`, Yup path-validation tricks | validate format-not-presence survives; mechanics don't |
| react-router v5→v6 idioms (`element` prop, no PrivateRoute abstraction, `unstable_HistoryRouter`, MemoryRouter test wiring) | "follow the framework's own idiom, don't abstract against it" + big-bang for routers |
| i18n machinery (FormattedMessage, base.json/en.json sync bugs, readable-keys debate, `{br}` interpolation) | copy authority + interpolated-`<link>` tags lesson; i18n itself is dead ("English-only products pay i18n tax without benefit") |
| CRA/webpack/react-scripts config, `REACT_APP_` polyfills, peerDeps-in-app debate | don't let the framework own the build; overrides > peerDeps in apps |
| jest specifics (jest.mocked debate, jsdom-extended, `esModules` arrays) | ESM-readiness argument; everything else dead |
| Checkly constraints (4-min ceilings, type-inference limits) | dead; e2e determinism lessons absorbed into Tier-1 #7 |
| `the legacy UI library` steering ("import everything from the UI library", PasswordInput/ConfirmItemDeleteModal pointers) | registry-first survives with new registry; old component names are landmines — several still appear in 2025-2026 comments as "legacy library", never recommend them |
| NextJS console federation experiment, TanStack Start experiment, nuqs | validated dead ends; keep as G2 evidence (dependency-vs-platform timing) |

## Encoding directive for the harness

1. Tier 1 goes into skills/review-hats as permanent principles, each citing its multi-era witnesses.
2. Tier 2 goes into stack-tagged rule groups (hooks + skill sections marked `stack:2026-tailwind-tanstack-connectquery`), designed to be replaced wholesale — mirroring how the team itself freezes dead stacks with Biome.
3. Tier 3 items get NEGATIVE encoding where cheap: the existing `noRestrictedImports`-style bans (chakra, react-router-dom, yup, the legacy UI library) already cover most; add MobX patterns (`observer(`, `makeObservable`) and `FormattedMessage` to the ban list for new code in migrated apps.
4. Any mined comment quoted as guidance must carry its era; pre-2025 mechanics quotes are historical evidence, not instructions.
