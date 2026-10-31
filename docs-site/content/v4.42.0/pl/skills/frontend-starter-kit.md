---
description: >-
  Skonfiguruj narzędzia frontendowe, linting, bramki jakości, stos React, stos
  danych i CI.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - frontend starter kit
sidebar:
  label: /frontend-starter-kit
title: /frontend-starter-kit
type: skill
---
![Diagram umiejętności /frontend-starter-kit](/diagrams/skills/frontend-starter-kit.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/frontend-starter-kit.excalidraw)


Przeprowadź idempotentną konfigurację początkową. Czytaj tylko potrzebne `references/<tool>/README.md` i powiązane przewodniki. Kopiowanie hooków we wtyczkach nie wykonuje żadnych operacji; repozytoria bez wtyczki wymagają kopii z export-harness.

## Profile [#profiles]

- **full** (domyślny): kanoniczny stos opisany w [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/frontend-starter-kit/REFERENCE.md), w podanej poniżej kolejności.
- **minimal:** toolchain, biome, quality-gate, env-validation, conventional-commits.
- **redpanda:** full + `references/redpanda/README.md`, taksonomia, `REDPANDA_KIT=1`.
- **`<tool>`:** tylko dokumentacja danego narzędzia.

## Kolejność dla profilu full [#full-order]

| Narzędzie | Przeznaczenie |
|---|---|
| `toolchain` | `references/toolchain/`: bun, TypeScript 7 `tsc`/tsrs, zabezpieczenia przed destrukcyjnymi poleceniami |
| `tanstack-intent` | wskazówki dopasowane do wersji i bramki edycji |
| `biome` | Biome, Ultracite, hook automatycznych poprawek |
| `quality-gate` | skrypt, CI, hook Stop, kontrola rozmiaru paczki |
| `agent-config` | `AI_AGENT=1`, skracanie danych wyjściowych |
| `react-compiler` | Compiler, kontrola memoizacji |
| `zustand` | `create<T>()()`, `useShallow`, persist |
| `react-rules` | zakaz surowego HTML, obchodzenia typów TS, XSS i importów zbiorczych |
| `env-validation` | t3-env/zod, `noProcessEnv` |
| `conventional-commits` | `type(scope): description` |
| `react-doctor` | bramka zmienionych diagnostyk, hook Stop |
| `ci-pipeline` | Actions, pokrycie, buforowanie |
| `redpanda` | przepływ pracy rejestru i taksonomia |

Umiejętności ze wskazówkami dotyczącymi pracy bieżącej, nie konfiguracji: `/accessibility`, `/tanstack-router`, `/connect-query`, `/e2e-testing`, `/registry-workflow`, `/ux-copy`. Opcjonalna infrastruktura dostępna tylko jako polecenia z ukośnikiem: `/setup-routines`, `/setup-atlassian-workflow`.

## Kroki [#steps]

1. Potwierdź profil; dla full przetwarzaj tabelę kolejno, czytając dokumentację dopiero wtedy, gdy jest potrzebna.
2. Ustaw `REACT_RULES_BAN_USEEFFECT=1` tylko w repozytoriach, które wybierają ścisłe reguły efektów.
3. [Automatycznie skonfiguruj zabezpieczenia](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/review-enforcement.md) w każdym repozytorium korzystającym z harnessu; przestrzegaj granic upoważnionego punktu końcowego.
4. Umiejętności dotyczące przepływu pracy są już dostarczane z wtyczką; nie instaluj niczego dodatkowego.

## Weryfikacja [#verify]

- `.claude/settings.json` zawiera hooki, w tym TanStack Intent, gdy zainstalowane są pakiety TanStack; istnieją `biome.jsonc` i `src/env.ts`.
- Skrypty: lint, lint:fix, type:check, test, quality:gate.
- Istnieje `.github/workflows/quality-gate.yml`; hooki są wykonywalne.
