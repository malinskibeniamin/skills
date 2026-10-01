---
title: "/effect-ts"
description: "Używaj podczas konfiguracji repozytorium korzystającego z biblioteki Effect dla TypeScript."
type: skill
sidebar:
  label: "/effect-ts"
---
![Diagram umiejętności /effect-ts](/diagrams/skills/effect-ts.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/effect-ts.excalidraw)

## Instalacja Effect

Użyj menedżera pakietów repozytorium. Przy nowej konfiguracji v4 upstream korzysta z kanału wydań kandydujących:

```sh
bun add effect@rc
```

Zachowaj istniejącą wersję Effect, chyba że zażądano aktualizacji. Przy migracji z v3 do v4 użyj `/effect-v3-to-v4`, zamiast traktować ją jako nową instalację.

W monorepo zainstaluj Effect jako zależność deweloperską w katalogu głównym, jeśli jest potrzebna do udostępnienia źródeł i przewodnika dla agentów z `node_modules/effect`:

```sh
bun add -D effect@rc
```

Zachowaj zależności uruchomieniowe w pakietach importujących Effect. Przed dodaniem poniższej instrukcji sprawdź istnienie `node_modules/effect/AGENTS.md` i `node_modules/effect/src`. Jeśli ich brakuje, zgłoś zainstalowaną wersję i brakujące pliki.

## Aktualizacja instrukcji dla agentów

Dodaj poniższy blok do kanonicznego źródła instrukcji dla agentów. Wygeneruj ponownie pochodne pliki `AGENTS.md` lub `CLAUDE.md`; nie edytuj wygenerowanych instrukcji ręcznie.

```md
# Więcej informacji o Effect

To repozytorium korzysta z biblioteki Effect dla TypeScript.

Przed napisaniem kodu Effect przeczytaj w całości `node_modules/effect/AGENTS.md`
i w razie potrzeby przejdź do wskazanych w nim odnośników.

W przypadku API i koncepcji nieopisanych w przewodniku przeszukaj zainstalowane
źródła w `node_modules/effect/src`.
```
