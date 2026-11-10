---
description: >-
  Utwórz commit, wypchnij zmiany i otwórz PR gotowy do przeglądu albo wykonaj
  jawnie autoryzowane scalenie. Użyj przy żądaniach dostarczenia; --no-pr kończy
  działanie po wypchnięciu.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - commit push pr
sidebar:
  label: /commit-push-pr
title: /commit-push-pr
type: skill
---
![Diagram umiejętności /commit-push-pr](/diagrams/skills/commit-push-pr.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/commit-push-pr.excalidraw)

Przeczytaj [Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#execution).

Korzystaj z [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md) i [zasad ładowania zależności](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

Scalaj tylko na wyraźne żądanie: [kontrakt scalania](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/merge.md).

## Kontrola wstępna [#preflight]

1. Sprawdź stan, diff, gałąź, dziennik i PR; przy wypchnięciu lub publikacji PR-a wykonaj [automatyczny rebase](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#automatic-rebase), jeśli PR należący do użytkownika nie zawiera aktualnej bazy.
2. Ustal punkt końcowy: tylko commit, wypchnięcie (`--no-pr`) lub PR. Sam commit pomija kontrolę zdalnego repozytorium i `gh`.
3. Wypchnięcie/PR: [automatycznie skonfiguruj zabezpieczenia](https://github.com/malinskibeniamin/skills/blob/main/shared/review-enforcement.md); zachowaj węższe punkty końcowe.
4. Dla PR-a uruchom `gh stack view --json`. Obsługuj jedną warstwę; nigdy nie uruchamiaj `gh stack submit` bez odpowiedniego zakresu.
5. Przeprowadź przegląd zgodnie z właściwymi umiejętnościami; autoryzowana rada recenzentów zachowuje wymagany zakres oceny. Samo wywołanie umiejętności nie jest bramką zatwierdzania.
6. Dla uruchamialnych zmian w PR-ze załaduj [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md); wymagaj aktualnego wyniku PASS. BLOCKED wymaga zgody użytkownika na odstępstwo.
7. Dodawaj zmiany do poczekalni według celu; zapytaj, jeśli ich własność jest niejasna.

## Commit

Jeśli repozytorium używa Changesets, po weryfikacji załaduj [changesets](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/changesets/SKILL.md).

1. Pozostań na gałęzi funkcji; na gałęzi domyślnej utwórz `type/description`.
2. Dla każdej spójnej grupy wykonaj `git add <explicit paths>`, a następnie utwórz commit `type(scope): description`: małymi literami, 5–72 znaki, bez kropki.
3. Wyraźne żądanie samego commita kończy pracę tutaj, po sprawdzeniu czystości drzewa.
4. Wypchnięcie/PR, każda poprawka CI lub rebase: pokaż `origin/<branch>..HEAD`, a następnie wypchnij gałąź z ustawieniem śledzenia.
5. Po przepisaniu gałęzi funkcji należącej do użytkownika użyj `--force-with-lease` bez ponownego pytania o zgodę. Nigdy nie używaj zwykłego wymuszenia; przepisanie gałęzi domyślnej, współdzielonej, cudzej lub równolegle używanej wymaga wyraźnej zgody.

## Pull request

`--no-pr` nigdy nie tworzy PR-a. Po wypchnięciu zadbaj o [istniejący PR](https://github.com/malinskibeniamin/skills/blob/main/pr/SKILL.md#existing-pr), następnie sprawdź drzewo. Przygotuj dowody.

1. Baza: `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`. Kontynuuj pracę w bieżącym PR-ze i zachowaj [metadane](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/metadata.md), w tym stan szkicu. Tworzenie szkiców PR nie wymaga zatwierdzenia; stosy: `/stacked-prs`.
2. Dla każdego PR-a załaduj osobno [PR](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/file-pr/SKILL.md), [wpływ](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md) i [opis](https://github.com/malinskibeniamin/skills/blob/main/pr/SKILL.md); zachowaj szkic i przedstaw wartość.
3. Dobierz [dowody wizualne](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5). Zmiany backendu, API, Protobuf, kontraktów lub przepływu danych bez zrzutów albo nagrania wyjaśniającego zachowanie wymagają diagramu opartego na kodzie; preferuj Excalidraw, a jako rozwiązanie zastępcze użyj Mermaid bezpośrednio w opisie. Odczytaj opublikowany opis ponownie; bramka Stop cyklu pracy sprawdza obecność dowodów lub jawnego, uzasadnionego wyjątku.
4. Publiczne repozytorium (`gh repo view --json visibility`): przed wypchnięciem usuń wewnętrzne nazwy organizacji, repozytoriów, produktów i osób oraz prywatne linki z commitów, tytułu, opisu i dowodów.
5. Podsumuj rozstrzygające kontrole i istotne ograniczenia w opisie; nie twórz osobnego pliku z dowodami. Uwzględnij odpowiednie wyniki dogfood; odczytaj ponownie opis i sprawdź dostęp do dołączonych materiałów. Edycje unieważniają tylko dowody, których dotyczą.

Utrzymanie: [właściciel pętli utrzymania](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md#automatic-pr-maintenance).
Przed monitorowaniem wybierz natywny mechanizm wznowień; nie uruchamiaj drugiego dispatchera.

Nie uruchamiaj `/visual-recap` ani `/make-pr-easy-to-review`, chyba że użytkownik wyraźnie o to poprosi.

## Zakończenie [#completion]

1. Odczytaj CI: `gh pr checks <number>`; brak, oczekiwanie lub pominięcie nie oznacza przejścia kontroli.
2. Automatycznie naprawiaj zasadne uwagi, CI i konflikty; zweryfikuj i wypchnij zmiany. Kontynuuj przez jeden autoryzowany mechanizm wznowień.
3. Podaj head, PR, kontrole, luki w przeglądzie oraz sposób kontynuacji lub blokadę; zachowaj węższe punkty zatrzymania.
4. Stosuj CLAUDE.md: cel/wpływ/stan oraz pełny adres URL PR-a w ostatnim wierszu stanu, także przy aktualizacjach.

Zachowaj niezwiązaną pracę; ujawniaj niepowodzenia i sposób odzyskania poprawnego stanu.
