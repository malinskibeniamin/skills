---
title: /plan-arbiter
description: >-
  Rozstrzygaj między konkurencyjnymi planami. Użyj podczas wybierania lub
  łączenia propozycji od agentów, z transkrypcji, planów wizualnych, opisów
  PR-ów, plików lub wklejonych strategii.
type: skill
sidebar:
  label: /plan-arbiter
---
![Diagram umiejętności /plan-arbiter](/diagrams/skills/plan-arbiter.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/plan-arbiter.excalidraw)

Zapoznaj się z listą kryteriów oceny w `references/builder-upstream.md`.

Przekształć konkurencyjne plany w jeden wykonalny kierunek działania. Zachowaj najlepsze pomysły, odrzuć słabe założenia i przygotuj jasne przekazanie do realizacji zamiast niespójnej mieszanki.

## Przebieg pracy

1. Zbierz plany źródłowe: wklejony tekst, pliki lokalne, identyfikatory sesji, transkrypcje, PR-y, komentarze, linki do planów wizualnych lub historię czatu.
2. Ujednolić każdy plan: cel, zakres, założenia, nierozstrzygnięte pytania, modyfikowane pliki, kolejność działań, walidację, wycofanie zmian i złożoność.
3. Zweryfikuj plany względem rzeczywistej bazy kodu, dokumentacji, specyfikacji, testów, zrzutów ekranu lub systemów zewnętrznych, jeśli ma to zastosowanie.
4. Podejmij decyzję: `Adopt`, `Hybrid` lub `Revise first`.
5. Przygotuj jeden plan przekazania do realizacji z punktami kontrolnymi weryfikacji i odrzuconymi alternatywami.

Planowanie nie wprowadza zmian, chyba że po podjęciu decyzji użytkownik wyraźnie poprosi o implementację.

## Kryteria rozstrzygające

1. Poprawność i zgodność z prośbą użytkownika.
2. Oparcie na rzeczywistych plikach, interfejsach API, testach, danych i zachowaniu interfejsu użytkownika.
3. Mniejsze ryzyko nieodwracalnych skutków.
4. Mniejszy zakres możliwy do wdrożenia z solidniejszą weryfikacją.
5. Jaśniejsze przekazanie wykonawcy.

## Dane wyjściowe

```md
## Plan arbiter
Sources: <plans inspected>
Verdict: Adopt <plan>|Hybrid|Revise first
Why: <evidence-backed reason>
Execution plan: <ordered steps>
Rejected alternatives: <what and why>
Verification gates: <commands/checks>
Open questions: <only blockers>
```
