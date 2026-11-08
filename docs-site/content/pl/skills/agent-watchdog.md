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

Przeczytaj `references/builder-upstream.md`, gdy audyt jest złożony lub artefakt źródłowy jest niejednoznaczny.

Korzystaj wyłącznie z autoryzowanych źródeł i rzeczywiście dostępnych możliwości hosta. Prowadź analizę samodzielnie; dodatkowi agenci, monitorowanie, dostęp do produkcji i zapisy wymagają osobnej autoryzacji.

## Tryby

- **Tylko obserwacja**: monitoruj sesję, PR, gałąź, przebieg CI lub transkrypcję aż do osiągnięcia stanu końcowego. Nie wprowadzaj zmian.
- **Audyt**: porównaj żądanie, transkrypcję, różnice, testy, CI, komentarze, zrzuty ekranu i końcowe deklaracje. Nie wprowadzaj zmian.
- **Audyt i poprawki**: najpierw przeprowadź audyt, a następnie wprowadź niewielkie poprawki dotyczące wyraźnych, autoryzowanych braków.
- **Porównanie**: porównaj wielu agentów lub wiele sesji pod kątem tego samego pierwotnego żądania.
- **Przejęcie**: wyraźne żądanie przejęcia zablokowanej pracy; postępuj zgodnie z [references/takeover.md](https://github.com/malinskibeniamin/skills/blob/main/agent-watchdog/references/takeover.md), a następnie realizuj zadanie do żądanego punktu końcowego. Nie ogranicza się to do łatania poprzedniego podejścia.

Jeśli uprawnienia do edycji są niejasne, domyślnie przeprowadź tylko audyt.

## Przebieg pracy

W trybie przejęcia użyj jego dokumentu referencyjnego zamiast poniższych kroków audytu i niewielkich poprawek.

1. Zidentyfikuj każdy cel: identyfikator sesji, transkrypcję, adres URL wątku, PR, gałąź, commit, przebieg CI, zgłoszenie, link do Slacka lub wklejone podsumowanie.
2. Odtwórz pierwotne żądanie i ograniczenia; w miarę możliwości sformułuj własne hipotezy przed przeczytaniem wniosków obserwowanego agenta.
3. Samodzielnie zbadaj źródłowe dowody dotyczące tego samego problemu, a następnie porównaj je z diffem, kontrolami i deklaracjami agenta. Zaznacz wcześniejsze zapoznanie się z materiałem; taka analiza w tym samym kontekście nie jest niezależną recenzją ani przeglądem innej rodziny modeli.
4. Sklasyfikuj każdy problem jako: `Gap`, `Bug`, `Verification miss`, `Scope drift` lub `No issue`.
5. Jeśli masz uprawnienia, poprawiaj tylko wyraźne braki; nigdy nie cofaj niepowiązanych zmian ani nie przełączaj gałęzi bez wyraźnej prośby.
6. Zgłoś dokładne dowody, różnice wymagające działania, nierozwiązane ryzyka i następne działanie. Przerywaj pracującemu agentowi tylko w sprawie błędu bieżącego kroku, poprawki lub blokady; pozostałe zweryfikowane braki zbierz na następny punkt kontrolny i nie powielaj uwag.

Dla zakończonych worktree sprawdź oczekujące pliki i rzeczywisty zdalny HEAD zgodnie z [weryfikacją zdalnego dostarczenia](https://github.com/malinskibeniamin/skills/blob/main/shared/remote-completion.md). Tryby tylko do odczytu raportują braki; autoryzowane przejęcie obejmuje weryfikację, commit i push.

[Źródła i odświeżanie](https://github.com/malinskibeniamin/skills/blob/main/shared/BUILDER-SKILLS-CREDITS.md).

## Wynik

```md
## Agent watchdog
Target: <artifact>
Mode: watch|audit|audit-and-fix|compare
Contract: <what the user asked>
Evidence checked: <files/commands/CI/comments>
Findings:
- <Gap|Bug|Verification miss|Scope drift|No issue>: <evidence and required action>
Fixes made: <if any>
Still open: <blockers or risks>
```
