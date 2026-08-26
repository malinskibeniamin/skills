---
title: /to-tickets
description: "Podziel plan na zgłoszenia typu tracer bullet z jawnymi krawędziami blokującymi."
type: skill
sidebar:
  label: /to-tickets
---
![Diagram umiejętności /to-tickets](/diagrams/skills/to-tickets.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/to-tickets.excalidraw)

Przekształć zatwierdzony plan, specyfikację lub rozmowę w niezależnie weryfikowalne pionowe wycinki.
Jeśli istnieje `CLAUDE.md`, przeczytaj go przed `AGENTS.md`; w przeciwnym razie przeczytaj `AGENTS.md`. Użyj wskaźnika Issue tracker. Gdy go brak, użyj `/work-automation-kit` lub lokalnego rozwiązania.

## 1. Zbierz

Użyj kontekstu rozmowy. Pobierz przekazaną specyfikację, zgłoszenie lub URL z pełną treścią i komentarzami. Eksploruj tylko wtedy, gdy bieżący kod i słownictwo domeny są niejasne; respektuj słownik i ADR-y. Najpierw ułatw zmianę, potem wykonaj łatwą zmianę.

## 2. Opracuj wycinki

Każde zgłoszenie:

- Przecina wąską ścieżkę end-to-end przez potrzebne warstwy zamiast jednej warstwy poziomej.
- Jest samodzielnie demonstracyjne lub weryfikowalne i mieści się w świeżym oknie kontekstu.
- Deklaruje tylko prawdziwe blokady; ich brak oznacza gotowość.
- Opisuje zachowanie i kryteria, nie nietrwałe ścieżki plików ani fragmenty kodu.

**Szerokie refaktoryzacje są wyjątkiem.** Użyj expand, migrate, contract: dodaj nową formę obok starej, przenoś wywołania w niezależnie zielonych partiach, potem usuń starą. Każda partia migrate jest blokowana przez expand. Contract jest blokowany przez wszystkie partie migrate. Jeśli partie nie mogą być zielone samodzielnie, użyj gałęzi integracyjnej i końcowego zgłoszenia integrate-and-verify.

Użyj `/plan-arbiter`, gdy pozostaje kilka grafów. Użyj `/visual-plan` dla dużego grafu wymagającego kontroli granicy lub blokad.

## 3. Potwierdź

Pokaż numerowaną listę z **Tytułem**, **Blokowane przez** i **Co dostarcza**. Zapytaj o ziarnistość, krawędzie oraz łączenie lub dzielenie. Iteruj do zatwierdzenia.

## 4. Opublikuj

Publikuj jeden element na zgłoszenie, najpierw blokery. Nie modyfikuj ani nie zamykaj rodzica.

- **Lokalnie:** zapisz `.scratch/<feature-slug>/tickets/<NN>-<slug>.md`, numerując od `01`. Każdy plik podaje numery i tytuły blokerów.
- **Tracker:** utwórz osobne zgłoszenia. Dołącz natywną relacją podzgłoszenia i natywnymi blokadami, jeśli są dostępne; w przeciwnym razie wpisz linki. Zastosuj skonfigurowaną rolę `ready-for-agent`.

Granica obejmuje każde zgłoszenie, którego blokery są zakończone.

```markdown
# <NN> -- <Tytuł zgłoszenia>
**Co zbudować:** <zachowanie end-to-end z perspektywy użytkownika>
**Blokowane przez:** <numery i tytuły albo None -- można zacząć>
**Status:** ready-for-agent
## Kryteria akceptacji
- [ ] <obserwowalne kryterium>
```

Dla zgłoszeń trackera dodaj `## Parent`, gdy istnieje rodzic, potem `## What to build`, `## Acceptance criteria` i `## Blocked by`.
Nie wklejaj szczegółów implementacji. Dla kodu `/prototype` dodaj wskaźnik kontekstu do trwałej lokalizacji.
