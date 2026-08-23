---
title: /triage
description: "Przenoś zgłoszenia między rolami triage i przygotowuj pracę gotową dla agenta."
type: skill
sidebar:
  label: /triage
---
![Diagram umiejętności /triage](/diagrams/skills/triage.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/triage.excalidraw)

Przenoś zgłoszenia przez małą maszynę stanów ról. Dla skonfigurowanych zewnętrznych PR-ów PR jest zgłoszeniem z dołączonym kodem; gołe numery rozwiązuj przez tracker.
Używaj słownika domeny i odpowiednich ADR-ów. Aktualną dokumentację zewnętrzną czytaj przez `/read-the-damn-docs`; konkurencyjne plany rozstrzygaj przez `/plan-arbiter`, a duże epiki pokazuj przez `/visual-plan`.

## Niezmiennik komentarza

Każdy publikowany komentarz triage zaczynaj od:

```markdown
> *To zostało wygenerowane przez AI podczas triage.*
```

## Tracker i role

Wykryj tracker z instrukcji repozytorium i zdalnych adresów:

- GitHub: użyj `gh` zgodnie z [tracker-github.md](https://github.com/malinskibeniamin/skills/blob/main/triage/tracker-github.md).
- Jira: użyj `acli` zgodnie z [tracker-jira.md](https://github.com/malinskibeniamin/skills/blob/main/triage/tracker-jira.md).
- Gdy prawdopodobne są oba, zapytaj, który jest właścicielem elementu.

Każdy element ma dokładnie jedną kategorię (`bug` albo `enhancement`) i jeden stan: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human` lub `wontfix`.
Mapuj role kanoniczne na istniejące etykiety lub stany trackera. Sprzeczne stany wymagają decyzji przed modyfikacją.

## Kolejka uwagi

Pobieraj od najstarszych:

1. Elementy bez etykiety lub stanu.
2. Elementy `needs-triage`.
3. Elementy `needs-info` z nową aktywnością zgłaszającego.

Uwzględniaj skonfigurowane elementy zewnętrzne i oznaczaj każdą linię `[PR]` albo `[issue]`; aktywne PR-y współpracowników nie są pracą odkrywania. Jawnie nazwany PR pozostaje w zakresie. Pokaż liczby i pozwól maintainerowi wybrać.

## Triage jednego elementu

1. **Zbierz.** Przeczytaj treść, komentarze, etykiety lub stan, autora, daty, wcześniejsze notatki i diff PR-a. Nie powtarzaj pytań z odpowiedzią.
2. **Eksploruj.** Wykonaj wyszukiwanie redundancji po pojęciu domenowym. Sprawdź `.out-of-scope/` pod kątem wcześniejszego odrzucenia.
3. **Zarekomenduj.** Przedstaw kategorię, stan, uzasadnienie i dowód z kodu; poczekaj na kierunek.
4. **Zweryfikuj twierdzenie.** Odtwórz błąd albo pobierz i przetestuj PR. Zgłoś potwierdzenie, niepowodzenie lub brak dowodów. Dla przyczyny źródłowej i planu RED/GREEN użyj [trybu planu poprawki TDD](https://github.com/malinskibeniamin/skills/blob/main/triage/REFERENCE.md#tdd-fix-plan-mode).
5. **Dopytaj w razie potrzeby.** Użyj `/grilling` dla nierozstrzygniętej oceny lub języka domeny.
6. **Zastosuj.** Dla stanów gotowych użyj [AGENT-BRIEF.md](https://github.com/malinskibeniamin/skills/blob/main/triage/AGENT-BRIEF.md), a dla `needs-info` użyj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/triage/REFERENCE.md). Dla `wontfix`:
   - już zaimplementowane: podaj link i zamknij bez wpisu historii odrzuceń;
   - błąd: wyjaśnij i zamknij;
   - ulepszenie: zapisz według [OUT-OF-SCOPE.md](https://github.com/malinskibeniamin/skills/blob/main/triage/OUT-OF-SCOPE.md), podaj link i zamknij.
   Zastosuj `needs-triage` bez komentarza, chyba że trzeba zapisać częściową pracę.

## Nadpisanie i wznowienie

Dla jawnego nadpisania stanu opisz zmiany i działaj bez grillowania. Zapytaj o brief agenta tylko przy przejściu do `ready-for-agent` bez briefu.
Przy wznowieniu przeczytaj wcześniejsze notatki i nowe odpowiedzi, a następnie pokaż aktualny stan bez ponawiania pytań.

Pełne szablony i przejścia stanów: [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/triage/REFERENCE.md).
