# Architecture evolution — cloudv2 frontend (2022-08 → 2026-07)

> Recovered from the mining agent's transcript after a quota wind-down; the agent completed all mining passes but was stopped before writing. Evidence below is as it stated it; SHAs verified against `~/Documents/git/cloudv2` where cited.

## Migration timeline

| Date | Event | Evidence |
|---|---|---|
| 2022 mid | cloud-ui established in the cloudv2 monorepo on CRA + Chakra | corpus start `1694107` (2022-08-23) |
| 2022-09 | admin-ui created with the same tooling | corpus |
| 2022-12 | RTK Query adopted for the service layer | corpus |
| 2023 | react-scripts testing dropped; Formik→react-hook-form, Yup→zod begins | corpus |
| 2023-12 | react-query + connect-query adopted for public-API gRPC | corpus |
| 2024 mid | Ejected from CRA; rspack migration; cloud-ui becomes Module Federation host (Console embedding) | corpus |
| 2025-06/07 | RTK Query removal completes in admin-ui — a 19-month strangler migration | corpus |
| 2025-08 | Design system formalized: vendored the vendored registry in `src/components/registry-ui/` | corpus |
| 2025-10 | Tests split into unit + integration suites | `462df56ae1`, `37b96de345` |
| 2026-01-19 | admin-ui adopts the company UI registry | `093110fa03` |
| 2026-01-21/26 | react-router-dom → TanStack Router, big-bang per app (admin-ui, cloud-ui 635 files); loader + `preload="intent"`; `_splat` pattern removed | `3bd9c7b10e`, `68587a94c9`, `49ba414730`, `23d244d4aa`, `1955c50271` |
| 2026-02-03 | Module Federation set up for the AI gateway | `8efbfdcf62` |
| 2026-03-20 | aigw UI launched greenfield: shadcn registry, TanStack Router, connect-query, rsbuild, vitest, Tailwind | `8a68542bac` |
| 2026-03-30 | Explicit transport; TransportProvider removed | `c42d9e64ca` |
| 2026-04-02 | aigw UI → adp-console → adp-ui (extraction + rename bootstrap) | `089129064e`, `192c51a073` |
| 2026-04-21 | Legacy AI Gateway webui removed from cloud-ui, replaced by federated ADP | `e6da56f9` |
| 2026-06-11 | rsbuild v2 | `1ec7c12c57`, `46c6b8cd4a` |
| 2026-06-13 | Biome `noRestrictedImports` blocks `the legacy UI library`, `@chakra-ui`, `yup`; dead deps removed (`@mui/material`, `react-router-dom`) | `2ae461a76a`, `cd3295607e` |
| 2026-06-19/24 | React 19 rollout via Module Federation bridge (remotes upgrade independently of the React 18 host) | `60be09b885`, `b9c6060557`, `0772defd40` |
| 2026-07-07 | Radix removed as runtime dependency | `d9122e0df7` |

## What died (validated anti-patterns)

1. **Shared component library (`the legacy UI library`/Chakra)** → vendored per-app shadcn-style registry. Lesson: app teams own their components; a shared lib locks everyone to one version. Killed by lint (`2ae461a76a`).
2. **RTK Query / Redux data fetching** → react-query + connect-query. Coexisted ~18 months after react-query arrived (2023-12) — migrations stretch far longer than planned; strangler works but budget for it.
3. **CRA/framework-owned tooling** — adopted 2022, testing dropped 2023, ejected 2024, rspack/rsbuild mid-2024; adp-ui born directly on rsbuild. Lesson: don't let the framework own the build.
4. **react-router-dom + `_splat` routing** → TanStack Router, big-bang per app (not strangler) — a router touches everything, gradual migration costs more.
5. **Implicit TransportProvider context** → explicit transport passed via router context (`c42d9e64ca`). Lesson: implicit single-instance context blocks multi-transport futures.
6. **In-host product areas** → Module Federation remotes. The legacy in-host AI gateway was deleted in favor of the federated remote (`e6da56f9`); the MF bridge let remotes take React 19 before the host.
7. **Yup, MUI, Radix runtime dep** — each removed once the replacement was full coverage, then frozen by lint.

## Repeatable meta-patterns

- **M1 — Every migration ends with a lint-enforced freeze.** The migration isn't done until Biome `noRestrictedImports` blocks the old import. Enforcement: `skill` — when a harness migration completes, add the ban rule in the same PR (`2ae461a76a`).
- **M2 — New product areas are federated remotes, not folders in the host.** Enforcement: `skill`. Evidence: aigw→adp lineage, React-19-via-bridge decoupling.
- **M3 — New apps bootstrap by extraction + rename, greenfield on current tooling.** adp-ui is the template and the exemplar app for anything new. Enforcement: `exemplar` — `apps/adp-ui/` wholesale.
- **M4 — Big-bang for routers, strangler for data layers.** Enforcement: `skill`.

## Module organization (adp-ui = current convention)

- Flat feature folders under `src/components/` (agents, guardrails, mcp-servers, …), kebab-case filenames, **zero barrel files** (no `index.ts` re-exports). cloud-ui/admin-ui still carry legacy `pages/` + `routes/` splits.
- Hooks flat in `src/hooks/` with co-located `.test.ts`.
- Routes split: definition `_authenticated.tsx` vs page component `_authenticated.page.tsx`, tests co-located, excluded from routegen via config.
- Proto-generated code centralized at monorepo level and **symlinked** into apps, never duplicated per app.
- Test taxonomy in filenames: `.test.ts` / `.integration.test.tsx` / `.browser.test.tsx` / `e2e/*.spec.ts` (split formalized `462df56ae1`).
- **Refactor shape seen 16+ times:** extract hooks/helpers out of growing components, often triggered by complexity lint; when splitting a large file, split by **domain axis** (trigger drawer by kind, guardrail policies by domain, conversation views by mode), never by architectural layer. Enforcement: `skill` + `hook` candidate (ban new `index.ts` barrels in component dirs — mechanical, zero false positives in adp-ui HEAD).
