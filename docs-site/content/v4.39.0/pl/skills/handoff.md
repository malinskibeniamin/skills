---
title: /handoff
description: >-
  Kompaktowo podsumuj bieżącą sesję w dokumencie przekazania dla innego agenta
  lub nowej sesji.
type: skill
sidebar:
  label: /handoff
---
![Diagram umiejętności /handoff](/diagrams/skills/handoff.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/handoff.excalidraw)

Jeśli przekazanie służy do audytu pracy innego agenta, skieruj zadanie do `/agent-watchdog`. Jeśli przekazuje konkurencyjne plany, wskaż `/plan-arbiter` jako następną umiejętność.
Utwórz zwięzły dokument przekazania, aby inny agent lub sesja mogli kontynuować pracę od tego miejsca.

## Kiedy używać

Użyj, gdy użytkownik chce:
- kontynuować pracę w nowej sesji
- przekazać pracę innemu agentowi
- uruchomić prototyp lub równoległy tok prac w innym miejscu
- zachować kontekst potrzebny do działania bez przenoszenia całego zapisu rozmowy

## Procedura

1. Utwórz plik tymczasowy:
   ```bash
   handoff_file=$(mktemp -t handoff-XXXXXX.md)
   ```
2. Zapisz przekazanie pod tą ścieżką.
3. Zachowaj zwięzłość. Nie powielaj artefaktów już ujętych w specyfikacjach, planach, ADR-ach, zgłoszeniach, commitach, diffach ani dokumentacji. Odwołuj się do nich za pomocą ścieżki lub adresu URL.
4. Jeśli użytkownik podał argumenty, potraktuj je jako zakres prac w następnej sesji i dostosuj do niego przekazanie.
5. Usuń informacje poufne: klucze API, hasła, tokeny, sekrety, dane osobowe, dane klientów i wszelkie inne wartości poufne. Wspomnij o redakcji tylko wtedy, gdy wpływa ona na możliwość kontynuowania pracy.
6. W razie potrzeby zasugeruj umiejętności, których należy użyć w następnej sesji.
7. Zwróć wyłącznie ścieżkę do przekazania oraz podsumowanie w 1–2 zdaniach.
8. **Tryb agenta w tle** — użytkownik chce, aby nowy agent natychmiast przejął pracę:
   zamiast zapisywać plik, uruchom `claude --bg --name "<descriptive name>" "<handoff summary>"`
   (najpierw sprawdź `command -v claude`; jeśli polecenie jest niedostępne lub uruchomienie się nie powiedzie, nie twierdź, że agent
   został uruchomiony — wyświetl dokładne polecenie wraz z podsumowaniem, aby użytkownik mógł je wykonać). Zawsze podawaj
   opisową wartość `--name`; uwzględnij `/agent-watchdog` w sugerowanych umiejętnościach, gdy następna
   sesja musi zweryfikować twierdzenia tego agenta.

## Szablon przekazania

```markdown
# Handoff

## Next session focus
<What the next agent/session should do first.>

## Current state
<Only facts needed to resume. Include branch, cwd, PR/issue links if relevant.>

## Decisions made
<Bullets. Link to ADRs/plans/issues instead of restating them.>

## Open questions
<Bullets, or "None".>

## Next actions
1. <First concrete action>
2. <Second concrete action>
3. <Verification or shipping step>

## Relevant artifacts
- <path or URL>: <why it matters>

## Suggested skills
- </skill-name>: <why>
```

## Zasady bezpieczeństwa

- Nie używaj przekazania jako ukrytego podsumowania wszystkiego. Uwzględnij wyłącznie kontekst potrzebny do kontynuacji.
- Preferuj ścieżki i adresy URL zamiast wklejonej treści.
- Usuń sekrety i dane osobowe.
- Wyraźnie wskaż wszelkie niepewności.
- Jeśli nie wykonano jeszcze żadnej użytecznej pracy, poinformuj o tym i napisz krótki opis startowy.
