---
title: /agent-watchdog
description: >-
  Przeprowadź audyt innego agenta pod kątem pierwotnego żądania i aktualnych
  dowodów. Używaj w przypadku sesji, transkrypcji, PR-ów, gałęzi, logów,
  porównań lub autoryzowanych poprawek.
type: skill
sidebar:
  label: /agent-watchdog
---
![Diagram umiejętności /agent-watchdog](/diagrams/skills/agent-watchdog.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/agent-watchdog.excalidraw)

Przeczytaj `references/builder-upstream.md`, gdy audyt jest złożony lub artefakt źródłowy jest niejednoznaczny.

## Tryby

- **Tylko obserwacja**: monitoruj sesję, PR, gałąź, przebieg CI lub transkrypcję aż do osiągnięcia stanu końcowego. Nie wprowadzaj zmian.
- **Audyt**: porównaj żądanie, transkrypcję, różnice, testy, CI, komentarze, zrzuty ekranu i końcowe deklaracje. Nie wprowadzaj zmian.
- **Audyt i poprawki**: najpierw przeprowadź audyt, a następnie wprowadź niewielkie poprawki dotyczące wyraźnych, autoryzowanych braków.
- **Porównanie**: porównaj wielu agentów lub wiele sesji pod kątem tego samego pierwotnego żądania.

Jeśli uprawnienia do edycji są niejasne, domyślnie przeprowadź tylko audyt.

## Przebieg pracy

1. Zidentyfikuj każdy cel: identyfikator sesji, transkrypcję, adres URL wątku, PR, gałąź, commit, przebieg CI, zgłoszenie, link do Slacka lub wklejone podsumowanie.
2. Odtwórz ustalenia: pierwotne żądanie, zmiany zakresu, ograniczenia, domniemane kryteria akceptacji, końcowe deklaracje i zastrzeżenia.
3. Sprawdzaj dowody, nie wrażenia: zmienione pliki, otaczający kod, rzeczywiste wyniki poleceń, CI, zrzuty ekranu, nierozwiązane komentarze i logi wdrożenia.
4. Sklasyfikuj każdy problem jako: `Gap`, `Bug`, `Verification miss`, `Scope drift` lub `No issue`.
5. Jeśli masz uprawnienia, poprawiaj tylko wyraźne braki; nigdy nie cofaj niepowiązanych zmian ani nie przełączaj gałęzi bez wyraźnej prośby.
6. Zgłoś stan, podając dokładne pliki, polecenia, nierozwiązane ryzyka i następne działanie.

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
