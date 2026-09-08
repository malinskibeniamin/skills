---
title: /frontend-starter-kit
description: >-
  Skonfiguruj narzędzia frontendowe, linting, bramki jakości, stos React, stos
  danych i CI.
type: skill
sidebar:
  label: /frontend-starter-kit
---
![Diagram umiejętności /frontend-starter-kit](/diagrams/skills/frontend-starter-kit.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/frontend-starter-kit.excalidraw)

Jedna umiejętność odpowiada za całą konfigurację początkową. Instrukcje instalacji każdego narzędzia znajdują się w
`references/<tool>/README.md` (oraz w `SETUP.md`/`REFERENCE.md`, jeśli są dostępne) -- czytaj je
dopiero wtedy, gdy są potrzebne dla wybranego profilu. Wszystkie kroki są idempotentne.

Użytkownicy wtyczki mają już dostarczone i skonfigurowane wszystkie hooki -- w ich przypadku kroki kopiowania hooków
nie wykonują żadnych operacji; uruchom tylko kroki konfiguracji i narzędzi. Pełne kopiowanie jest istotne w przypadku repozytoriów bez
wtyczki („export harness”).

## Profile

- **full** (domyślny): wszystkie poniższe narzędzia, w podanej kolejności, dla kanonicznego stosu opisanego w
  [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/frontend-starter-kit/REFERENCE.md) (React 19 + Rsbuild + Tailwind + TanStack Router/Query +
  Connect Query + shadcn/Base UI + Vitest/Playwright + Biome/Ultracite + TypeScript 7 `tsc`).
- **minimal**: toolchain, biome, quality-gate, env-validation, conventional-commits.
- **redpanda**: full + `references/redpanda/README.md` (przepływ pracy rejestru, taksonomia komponentów Redpanda,
  `REDPANDA_KIT=1`).
- **`<tool>`**: tylko dokumentacja danego narzędzia.

## Narzędzia (kolejno dla profilu full)

| Narzędzie | Dokumentacja | Co konfiguruje |
|---|---|---|
| toolchain | `references/toolchain/` | bun + wymuszanie TypeScript 7 `tsc`, zabezpieczenia przed destrukcyjnymi poleceniami |
| tanstack-intent | `references/tanstack-intent/` | wskazówki dotyczące pakietów TanStack dopasowanych do wersji + oficjalne bramki edycji |
| biome | `references/biome/` | Biome + Ultracite, hook automatycznych poprawek |
| quality-gate | `references/quality-gate/` | skrypt quality:gate, przepływ pracy CI, hook Stop, kontrola rozmiaru paczki |
| agent-config | `references/agent-config/` | AI_AGENT=1, skracanie danych wyjściowych |
| react-compiler | `references/react-compiler/` | React Compiler + kontrola memoizacji |
| zustand | `references/zustand/` | create z podwójnymi nawiasami, useShallow, persist |
| react-rules | `references/react-rules/` | zakaz surowego HTML, obchodzenia typów TS, XSS i importów zbiorczych |
| env-validation | `references/env-validation/` | t3-env + zod; zakaz process.env przez Biome noProcessEnv |
| conventional-commits | `references/conventional-commits/` | wymuszanie formatu type(scope): description |
| react-doctor | `references/react-doctor/` | bramka zmienionych diagnostyk + hook Stop |
| ci-pipeline | `references/ci-pipeline/` | CI w GitHub Actions, progi pokrycia, buforowanie |
| redpanda | `references/redpanda/` | przepływ pracy rejestru Redpanda + taksonomia komponentów |

Umiejętności ze wskazówkami dotyczącymi pracy bieżącej (codzienna praca, nie konfiguracja): `/accessibility`, `/tanstack-router`,
`/connect-query`, `/e2e-testing`, `/registry-workflow`, `/ux-copy`. Opcjonalna infrastruktura:
`/setup-routines`, `/setup-atlassian-workflow` (tylko jako polecenia z ukośnikiem). Repozytoria korzystające już z Biome lub Oxlint mogą włączyć reguły chroniące dowody typów za pomocą `/install-anti-slop`.

## Kroki

1. Potwierdź profil (domyślnie full). Czytaj dokumentację każdego narzędzia dopiero po przejściu do jego konfiguracji.
2. Ustaw `REACT_RULES_BAN_USEEFFECT=1` w session-env.sh, jeśli repozytorium wymaga ścisłych reguł efektów.
3. Umiejętności dotyczące przepływu pracy (development-lifecycle, tdd, grilling, triage,
   diagnosing-bugs, prototype, domain-modeling) są dostarczane z tą wtyczką -- nie trzeba niczego instalować.

## Weryfikacja

- [ ] `.claude/settings.json` zawiera wszystkie hooki, w tym TanStack Intent, gdy zainstalowane są pakiety TanStack; istnieją `biome.jsonc` + `src/env.ts`
- [ ] Skrypty: lint, lint:fix, type:check, test, quality:gate
- [ ] Istnieje `.github/workflows/quality-gate.yml`, wszystkie hooki są wykonywalne
