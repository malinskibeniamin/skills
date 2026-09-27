---
title: /commit-push-pr
description: >-
  Utwórz commit, wypchnij zmiany i otwórz PR gotowy do przeglądu albo wykonaj
  jawnie autoryzowane scalenie. Użyj przy żądaniach dostarczenia; --no-pr kończy
  działanie po wypchnięciu.
type: skill
sidebar:
  label: /commit-push-pr
---
![Diagram umiejętności /commit-push-pr](/diagrams/skills/commit-push-pr.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/commit-push-pr.excalidraw)


Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md), aby poznać wymagania wstępne przeglądu, commity, etykiety, opis i dowody.

Tylko wyraźne żądania scalenia obsługuje [kontrakt scalania](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/merge.md), a nie poniższy przepływ tworzenia PR-a.

## Kontrola wstępna [#preflight]

1. Sprawdź stan, różnice, bieżącą gałąź, ostatnie wpisy dziennika i ewentualny PR gałęzi.
2. Ustal żądany punkt końcowy: tylko commit, wypchnięcie (`--no-pr`) lub PR. Wariant z samym commitem pomija kontrolę zdalnego repozytorium i `gh`.
3. Wypchnięcie/PR wymaga zdalnego repozytorium; PR wymaga również uwierzytelnionego `gh` i domyślnej gałęzi.
4. W przypadku PR-a uruchom `gh stack view --json`; sprawdź bazę i stos. Zwykły PR obejmuje jedną warstwę; nigdy nie używaj `gh stack submit`.
5. Przeprowadź przegląd bezpośrednio; nie blokuj działania wyłącznie z powodu niewywołania wskazanej umiejętności.
6. Uruchamialne zmiany w PR-ze wymagają aktualnego wyniku PASS z `/dogfood`; wynik BLOCKED wymaga zgody użytkownika na odstępstwo.
7. Dodawaj do poczekalni według celu i tylko żądane ścieżki. Zapytaj, jeśli własność zmian jest niejasna.

## Commit

1. Pozostań na gałęzi funkcji; jeśli jesteś na gałęzi domyślnej, utwórz `type/description`.
2. Dla każdej spójnej grupy wykonaj `git add <explicit paths>`, a następnie utwórz commit `type(scope): terse description`: małymi literami, 5–72 znaki, bez kropki.
3. Jawne żądanie utworzenia wyłącznie commitu kończy działanie w tym miejscu po sprawdzeniu czystości drzewa i podsumowaniu.
4. Wypchnięcie/PR: pokaż `origin/<branch>..HEAD`, a następnie wypchnij gałąź z ustawieniem śledzenia.
5. Po przepisaniu bieżącej, należącej do użytkownika gałęzi użyj `--force-with-lease` bez ponownego pytania o zgodę. Nigdy nie używaj zwykłego wymuszenia; przepisanie gałęzi domyślnej, współdzielonej, należącej do kogoś innego lub równolegle używanej wymaga wyraźnej zgody.

## Pull request

`--no-pr` nigdy nie tworzy PR-a. Po wypchnięciu odśwież dowody i opis istniejącego PR-a; w przeciwnym razie zakończ po wypchnięciu i sprawdzeniu czystości drzewa. Przygotuj lokalne dowody wizualne przed wypchnięciem.

Utworzenie PR-a upoważnia do weryfikacji, utworzenia commitu, wypchnięcia zmian i wykonania rebase bieżącej gałęzi użytkownika z ochroną dzierżawy; nigdy do scalania ani niezwiązanych poprawek.

1. Ustal gałąź bazową za pomocą `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`. Kolejne etapy pracy dodawaj do bieżącego PR-a; w przeciwnym razie utwórz PR, przypisując osobę, etykiety i korzystając z szablonu. Utworzenie roboczego PR-a na tym etapie nie wymaga osobnej zgody. Publikacja całego stosu używa `/stacked-prs`.
2. Każdy PR uruchamia `/quantify-impact`; uwzględnij zwięzły opis wartości lub potwierdzone wskaźniki, bez pozorowanych benchmarków.
3. Każda widoczna zmiana wymaga inwentaryzacji opisanej w dokumencie referencyjnym, zrzutów ekranu i nagrań wideo przed i po zmianie, sprawdzonych migawek oraz przechodzących testów wizualnych. Brak dowodów blokuje publikację bez zgody użytkownika na odstępstwo.
4. Publiczne repozytorium (`gh repo view --json visibility`): przed wypchnięciem usuń wewnętrzne nazwy organizacji, repozytoriów i produktów, imiona i nazwiska osób oraz prywatne linki z commitów, tytułu, opisu i dowodów.
5. Uwzględnij potwierdzenie dogfood. Przeczytaj ponownie opis, sprawdź dostęp recenzenta do obrazów i wyświetl adres URL. Aktualizacje i ponowne otwarcia podlegają tym samym wymaganiom; edycje unieważniają dowody, których dotyczą.

Nie uruchamiaj `/visual-recap` ani `/make-pr-easy-to-review`, chyba że użytkownik wyraźnie o to poprosi.

## Zakończenie [#completion]

1. Pobierz pojedynczy stan CI za pomocą `gh pr checks <number>`; odnotuj brak CI.
2. Zgłoś niepowodzenia. Naprawianie CI wymaga `/go`, polecenia wysyłki, prośby o nadzorowanie lub kolejnego żądania.
3. Zgłoś stan, pozostałe różnice, gałąź, commity, PR, CI i następne działanie.
4. Zakończ jednym wierszem stanu: `done`, `awaiting decision` lub `blocked`, zgodnie z kontraktem znaczników repozytorium. Jeśli PR istnieje, umieść jego pełny adres URL w tym ostatnim wierszu — zarówno dla nowego, jak i zaktualizowanego PR-a.

Nigdy nie dodawaj do poczekalni niezwiązanych zmian, nie wypychaj mieszanego zakresu ani nie ukrywaj niepowodzeń. Jeśli `gh pr create` się nie powiedzie, pokaż błąd i polecenie naprawcze.
