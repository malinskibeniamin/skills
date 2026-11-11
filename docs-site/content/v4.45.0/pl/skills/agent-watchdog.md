---
description: >-
  Przeprowadź audyt innego agenta pod kątem pierwotnego żądania i aktualnych
  dowodów. Użyj do sesji, PR-ów, gałęzi, porównań, autoryzowanych poprawek lub
  przejmowania zablokowanej pracy.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - agent watchdog
sidebar:
  label: /agent-watchdog
title: /agent-watchdog
type: skill
---
![Diagram umiejętności /agent-watchdog](/diagrams/skills/agent-watchdog.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/agent-watchdog.excalidraw)

Przed audytem przeczytaj [protokół audytu](https://github.com/malinskibeniamin/skills/blob/v4.45.0/agent-watchdog/references/audit.md); przy złożonym lub niejednoznacznym audycie przeczytaj `references/builder-upstream.md`.
Korzystaj z autoryzowanych źródeł i rzeczywiście dostępnych narzędzi hosta. Prowadź analizę samodzielnie; dodatkowi agenci, monitorowanie, dostęp do produkcji i zapisy wymagają osobnej autoryzacji.

## Tryby [#modes]

- **Tylko obserwacja:** monitoruj sesję, PR, gałąź, CI lub transkrypcję do stanu końcowego; nie wprowadzaj zmian.
- **Audyt:** porównaj żądanie, dowody, diff, testy, CI, komentarze i deklaracje; nie wprowadzaj zmian.
- **Audyt i poprawki:** przeprowadź audyt, a następnie wprowadź wąskie, autoryzowane poprawki.
- **Porównanie:** oceniaj agentów lub sesje względem jednego żądania.
- **Przejęcie:** wyraźne żądanie przejęcia zablokowanej pracy; postępuj zgodnie z [zasadami przejęcia](https://github.com/malinskibeniamin/skills/blob/v4.45.0/agent-watchdog/references/takeover.md) do żądanego punktu końcowego, nie ograniczając się do poprzedniego podejścia.

Jeśli uprawnienia do edycji są niejasne, domyślnie przeprowadź tylko audyt.

## Przebieg pracy [#workflow]

Przy przejęciu użyj jego dokumentu referencyjnego; w pozostałych przypadkach:

1. Ustal cel, pierwotne żądanie i ograniczenia; najpierw sformułuj własne hipotezy.
2. Zbadaj źródłowe dowody; porównaj diff, kontrole i deklaracje agenta.
3. Zaznacz wcześniejsze zapoznanie się z materiałem; analiza w tym samym kontekście nie jest niezależną recenzją ani przeglądem innej rodziny modeli.
4. Klasyfikuj jako `Gap|Bug|Verification miss|Scope drift|No issue`.
5. Naprawiaj tylko autoryzowane braki; nigdy nie cofaj niepowiązanych zmian ani nie przełączaj gałęzi bez wyraźnej prośby.
6. Zgłoś dokładne dowody, różnice wymagające działania, ryzyka i następny krok; przy przekazywaniu uwag, zakończonych worktree i formacie wyniku stosuj protokół audytu.
