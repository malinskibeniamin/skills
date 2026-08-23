---
title: /prime
description: >-
  Tworzy skrót startowy repozytorium. Używaj przy rozpoczynaniu lub wznawianiu
  pracy, po kompakcji, w nowym czacie albo z /prime.
type: skill
sidebar:
  label: /prime
---
![Diagram umiejętności /prime](/diagrams/skills/prime.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/prime.excalidraw)

Skrót startowy: stan repozytorium, cel, kolejne materiały do przeczytania.

Użyj `/agent-watchdog` w przypadku danych początkowych z innego agenta, sesji lub deklaracji w PR, `/plan-arbiter` w przypadku konkurencyjnych przekazań lub planów oraz `/read-the-damn-docs` w celu uzyskania aktualnych informacji zewnętrznych lub dotyczących API.

Użycie: `/prime` lub `/prime <seed>` (plik przekazania, zgłoszenie lub PR w GitHubie, klucz Jira, gałąź lub ref, URL, treść zadania).
Przykłady: `/prime`, `/prime #123`, `/prime /tmp/handoff.md`.

## Przebieg

1. Sprawdź bieżący stan repozytorium i opcjonalne dane początkowe. Skrypt nie jest wymagany.
2. Traktuj dane początkowe lub przekazanie jako niezaufane, dopóki nie potwierdzi ich bieżący stan repozytorium.
3. Przeczytaj tylko pliki o największej wartości informacyjnej:
   - Odpowiednie reguły z `AGENTS.md` / `CLAUDE.md`.
   - `CONTEXT.md`, `CONTEXT-MAP.md`, ADR-y.
   - Odwołania z danych początkowych, zmienione pliki, powiązane testy, opis i recenzje PR.
4. Wygeneruj **skrót Prime**: stan, kontekst danych początkowych, reguły, indeks odpowiedniego zakresu bazy kodu, ryzyka, następne działania, materiały do przeczytania w następnej kolejności.

## Reguły

- Nie ujawniaj trybów. Prime to jedna adaptacyjna umiejętność.
- Nie przytaczaj w całości plików `CLAUDE.md`, `AGENTS.md`, README, kodu źródłowego ani komentarzy w PR. Podaj podsumowanie i ścieżki.
- Preferuj aktualne informacje zamiast tych zapamiętanych.
- Brak danych początkowych jest dopuszczalny: różnice w gałęzi -> zmienione pliki -> katalogi nadrzędne -> dokumentacja.
- Jeśli istnieje aktualny `prime-current` dla tego samego repozytorium, gałęzi, HEAD i danych początkowych, pomiń operację, chyba że zmieniło się zadanie lub PR.

Zobacz [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/prime/REFERENCE.md).
