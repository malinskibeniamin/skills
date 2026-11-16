---
description: >-
  Uporządkuj chaotyczną historię PR-a i dodaj wskazówki dla recenzenta bez
  zmiany działania kodu.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - make pr easy to review
sidebar:
  label: /make-pr-easy-to-review
title: /make-pr-easy-to-review
type: skill
---
![Diagram umiejętności /make-pr-easy-to-review](/diagrams/skills/make-pr-easy-to-review.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/make-pr-easy-to-review.excalidraw)

Przygotuj PR tak, aby recenzent mógł szybko zrozumieć jego cel, najważniejsze pliki i ryzyko. Domyślnym celem jest ułatwienie przeglądu bez zmiany działania kodu.

## Przebieg pracy [#workflow]

1. Ustal docelowy PR na podstawie adresu URL podanego przez użytkownika lub bieżącej gałęzi.
2. Sprawdź commity, rozmiar diffu, zmienione ścieżki, wygenerowane pliki i opis PR-a.
   W przypadku PR-a w stosie porównaj go z `baseRefName`, zanotuj jego warstwę i sąsiednie PR-y oraz wykonuj
   operacje na historii wyłącznie w obrębie gałęzi, do której ona należy.
3. Zidentyfikuj problemy utrudniające przegląd: chaotyczne commity, nieaktualny opis, niepowiązane zmiany, połączenie zmian mechanicznych i logicznych, brakujące testy lub niejasne punkty rozpoczęcia przeglądu.
4. Przed przepisaniem historii lub wykonaniem force push przedstaw plan. Zmiana kolejności, scalanie commitów lub
   kaskadowa modyfikacja stosu wymaga wyraźnej zgody na operację obejmującą cały stos.
5. Wprowadź bezpieczne ulepszenia, a następnie sprawdź, czy drzewo lub diff nadal odpowiada zamierzonym zmianom w kodzie.

## Porządkowanie historii [#history]

Przepisuj historię tylko wtedy, gdy użytkownik o to poprosi lub zaakceptuje plan. Przed przepisaniem:

```bash
gh pr view <PR> --json title,headRefName,baseRefName,state,commits --jq '{title,headRefName,baseRefName,state,commits}'
git fetch origin <headRefName> <baseRefName>
ORIGINAL_TREE=$(git rev-parse origin/<headRefName>^{tree})
```

Dobre grupowanie commitów zwykle odpowiada kolejności zależności:

1. Schemat, warstwa przechowywania danych lub wygenerowane definicje API.
2. Główna logika.
3. Połączenia i integracja.
4. Interfejs użytkownika lub zachowanie warstwy zewnętrznej.
5. Testy.

Po przepisaniu historii sprawdź zgodność zawartości:

Wypisz `Original tree: $ORIGINAL_TREE` i `Current tree: $(git rev-parse HEAD^{tree})`, a następnie sprawdź `git diff origin/<headRefName> --stat`.

Nie wykonuj push, jeśli drzewo zmieniło się w niezamierzony sposób.

## Wskazówki dla recenzenta [#guidance]

Aby uzyskać kontekst wizualny (diagramy, mapy plików, opisane przewodniki), uruchom `/visual-recap` — nie powielaj go tutaj. Ta umiejętność służy wyłącznie do dopracowania tekstu PR-a:

- Jeśli `/quantify-impact` dostarczyło istotnych dowodów, umieść najpierw jego blok `## Proven impact` (`Metric | Before | After | Delta`), a następnie dokładne polecenie i środowisko. Jeśli pomiar nie był przydatny, zachowaj standardowe podsumowanie wartości; nie dodawaj sztucznej pustej tabeli. Jeśli dowody nie osiągnęły wymaganego progu, napisz `Value not proven`, zamiast to ukrywać.
- Dodaj TL;DR zgodne z faktycznym diffem.
- Oddziel główne pliki od plików wygenerowanych lub zmienionych mechanicznie.
- Wskaż ryzykowne zmiany zachowania, kolejność migracji, plan wdrożenia i zakres testów.
- Dodaj odnośniki do systemów śledzenia zgłoszeń, paneli lub dokumentów projektowych, jeśli wyjaśniają cel zmian.
- Zastosuj pięć kryteriów z [materiału do przeglądu przez człowieka](https://github.com/malinskibeniamin/skills/blob/main/shared/review-contract.md#human-review-handoff) do istniejących dowodów samodzielnego przeglądu i weryfikacji. Wskaż ścieżki wymagające najdokładniejszego przeglądu oraz luki w doborze właścicieli kodu do przeglądu, wykrywaniu błędów i odzyskiwaniu; nie wymyślaj dowodów ani nie zmieniaj zasad zatwierdzania.

## Zasady bezpieczeństwa [#guardrails]

- Nigdy nie ukrywaj istotnych zmian zachowania pod nazwą „porządkowanie”.
- Nie omijaj hooków, chyba że użytkownik wyraźnie o to poprosi.
- Jeśli PR jest zbyt duży, aby notatki wystarczyły do ułatwienia jego przeglądu, zalecaj jego podzielenie zamiast maskowania problemu dopracowanym opisem.
