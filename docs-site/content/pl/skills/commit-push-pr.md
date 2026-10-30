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

Przy wieloetapowej implementacji lub publikacji przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#execution).


Korzystaj z [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md) i [zasad ładowania zależności](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

Scalaj tylko na wyraźne żądanie: [kontrakt scalania](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/merge.md).

## Kontrola wstępna [#preflight]

1. Sprawdź stan, różnice, gałąź, dziennik i PR. Przy wypchnięciu lub PR-ze, jeśli bieżący PR na gałęzi użytkownika nie zawiera commitów bazy, automatycznie wykonaj [rebase i wypchnięcie z zabezpieczeniem lease](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#automatic-rebase). Rutynowy rebase nie wymaga pytania użytkownika.
2. Ustal żądany punkt końcowy: tylko commit, wypchnięcie (`--no-pr`) lub PR. Wariant z samym commitem pomija kontrolę zdalnego repozytorium i `gh`.
3. Wypchnięcie/PR: [automatycznie skonfiguruj zabezpieczenia repozytorium korzystającego z harnessu](https://github.com/malinskibeniamin/skills/blob/main/shared/review-enforcement.md); zachowaj węższe punkty końcowe.
4. W przypadku PR-a uruchom `gh stack view --json`; sprawdź bazę i stos. Zwykły PR obejmuje jedną warstwę; nigdy nie używaj `gh stack submit`.
5. Przeprowadź przegląd bezpośrednio; wywołanie wskazanej umiejętności nie jest bramką zatwierdzania.
6. Dla uruchamialnych zmian w PR-ze załaduj [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md); wymagaj aktualnego wyniku PASS. BLOCKED wymaga zgody użytkownika na odstępstwo.
7. Dodawaj do poczekalni według celu i tylko żądane ścieżki. Zapytaj, jeśli własność zmian jest niejasna.

## Commit

1. Pozostań na gałęzi funkcji; jeśli jesteś na gałęzi domyślnej, utwórz `type/description`.
2. Dla każdej spójnej grupy wykonaj `git add <explicit paths>`, a następnie utwórz commit `type(scope): terse description`: małymi literami, 5–72 znaki, bez kropki.
3. Wyraźne żądanie samego commita kończy się tutaj po sprawdzeniu czystości drzewa.
4. Wypchnięcie/PR, każda poprawka CI lub rebase: pokaż `origin/<branch>..HEAD`, a następnie wypchnij gałąź z ustawieniem śledzenia.
5. Po przepisaniu bieżącej, należącej do użytkownika gałęzi użyj `--force-with-lease` bez ponownego pytania o zgodę. Nigdy nie używaj zwykłego wymuszenia; przepisanie gałęzi domyślnej, współdzielonej, należącej do kogoś innego lub równolegle używanej wymaga wyraźnej zgody.

## Pull request

`--no-pr` nigdy nie tworzy PR-a. Po wypchnięciu: [utrzymanie istniejącego PR-a](https://github.com/malinskibeniamin/skills/blob/main/pr/SKILL.md#existing-pr), następnie sprawdzenie czystości drzewa. Najpierw przygotuj dowody wizualne.

1. Ustal gałąź bazową za pomocą `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`. Kontynuuj pracę w bieżącym PR-ze; przy tworzeniu i aktualizacji, także wersji roboczych, stosuj [metadane repozytorium](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/metadata.md). Korzystaj z szablonu; wersje robocze nie wymagają osobnej zgody. Dla stosów używaj `/stacked-prs`.
2. Dla każdego PR-a załaduj osobno [PR](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/file-pr/SKILL.md), [wpływ](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md) i [opis](https://github.com/malinskibeniamin/skills/blob/main/pr/SKILL.md); zachowaj stan szkicu i przedstaw wartość.
3. Każda widoczna zmiana wymaga inwentaryzacji opisanej w dokumencie referencyjnym, zrzutów ekranu i nagrań wideo przed i po zmianie, sprawdzonych migawek oraz przechodzących testów wizualnych. Brak dowodów blokuje publikację bez zgody użytkownika na odstępstwo.
4. Publiczne repozytorium (`gh repo view --json visibility`): przed wypchnięciem usuń wewnętrzne nazwy organizacji, repozytoriów i produktów, imiona i nazwiska osób oraz prywatne linki z commitów, tytułu, opisu i dowodów.
5. Uwzględnij potwierdzenie dogfood. Przeczytaj ponownie opis, sprawdź dostęp recenzenta do obrazów i wyświetl adres URL. Aktualizacje i ponowne otwarcia podlegają tym samym wymaganiom; edycje unieważniają dowody, których dotyczą.

Jeśli automatyczny przegląd jest włączony, [powiąż pierwotną sesję](https://github.com/malinskibeniamin/skills/blob/main/resolve-pr-feedback/AUTO-REVIEW.md).

Nie uruchamiaj `/visual-recap` ani `/make-pr-easy-to-review`, chyba że użytkownik wyraźnie o to poprosi.

## Zakończenie [#completion]

1. Pobierz pojedynczy stan CI za pomocą `gh pr checks <number>`; odnotuj brak CI.
2. Zgłoś niepowodzenia. Naprawianie CI wymaga `/go`, polecenia wysyłki, prośby o nadzorowanie lub kolejnego żądania.
3. Zgłoś stan, pozostałe różnice, gałąź, commity, PR, CI i następne działanie.
4. Stosuj kontrakt stanu oraz celu i wpływu z CLAUDE.md. Jeśli PR istnieje, umieść jego pełny adres URL w ostatnim wierszu stanu, także przy aktualizacjach.

Nigdy nie dodawaj do poczekalni ani nie wypychaj niezwiązanych zmian i nie ukrywaj niepowodzeń. Jeśli `gh pr create` się nie powiedzie, pokaż błąd i sposób naprawy.

Jeśli repozytorium docelowe używa Changesets, po ukierunkowanej weryfikacji, a przed commitem, wczytaj [finalizację changesetu](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/changesets/SKILL.md). Aktualizuj istniejącą notatkę bieżącego PR zamiast tworzyć nową przy każdym poleceniu.
