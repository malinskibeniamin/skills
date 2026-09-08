---
title: /commit-push-pr
description: >-
  Utwórz commit, wypchnij zmiany i otwórz PR gotowy do przeglądu. Użyj do
  utworzenia samego commitu, utworzenia commitu i wypchnięcia zmian, utworzenia
  PR-a lub aktualizacji istniejącej gałęzi; --no-pr kończy działanie po
  wypchnięciu.
type: skill
sidebar:
  label: /commit-push-pr
---
![Diagram umiejętności /commit-push-pr](/diagrams/skills/commit-push-pr.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/commit-push-pr.excalidraw)


Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md), aby poznać wymagania wstępne przeglądu, commity, etykiety, opis i dowody.

## Kontrola wstępna

1. Sprawdź `git status -sb`, `git diff HEAD`, bieżącą gałąź, ostatnie wpisy dziennika i ewentualny PR gałęzi.
2. Ustal żądany punkt końcowy: tylko commit, wypchnięcie (`--no-pr`) lub PR. Wariant z samym commitem pomija kontrolę zdalnego repozytorium i `gh`.
3. Wypchnięcie/PR wymaga zdalnego repozytorium; PR wymaga również uwierzytelnionego `gh` i domyślnej gałęzi.
4. W przypadku PR-a uruchom `gh stack view --json`; sprawdź bazę i stos. Zwykły PR obejmuje jedną warstwę; nigdy nie używaj `gh stack submit`.
5. Przeprowadź odpowiednie obszary przeglądu bezpośrednio; nie blokuj działania wyłącznie z powodu niewywołania wskazanej umiejętności.
6. Uruchamialne zmiany w PR-ze wymagają aktualnego wyniku PASS z `/dogfood`; wynik BLOCKED wymaga zgody użytkownika na odstępstwo.
7. Dodawaj do poczekalni według celu i tylko żądane ścieżki. Zapytaj, jeśli własność zmian jest niejasna.

## Commit

1. Pozostań na gałęzi funkcji; jeśli jesteś na gałęzi domyślnej, utwórz `type/description`.
2. Dla każdej spójnej grupy wykonaj `git add <explicit paths>`, a następnie utwórz commit `type(scope): terse description`: małymi literami, 5–72 znaki, bez kropki.
3. Jawne żądanie utworzenia wyłącznie commitu kończy działanie w tym miejscu po sprawdzeniu czystości drzewa i podsumowaniu.
4. Wypchnięcie/PR: pokaż `origin/<branch>..HEAD`, a następnie wypchnij gałąź z ustawieniem śledzenia.
5. Po przepisaniu bieżącej, należącej do użytkownika gałęzi funkcji użyj w razie potrzeby `--force-with-lease` bez ponownego pytania o zgodę. Nigdy nie używaj zwykłego wymuszenia; przepisanie gałęzi domyślnej, współdzielonej, należącej do kogoś innego lub równolegle używanej wymaga wyraźnej zgody.

## Pull request

`--no-pr` nigdy nie tworzy PR-a. Po wypchnięciu odśwież dowody i opis istniejącego PR-a; w przeciwnym razie zakończ po wypchnięciu i sprawdzeniu czystości drzewa. Przygotuj lokalne dowody wizualne przed wypchnięciem.

Utworzenie PR-a upoważnia do weryfikacji, utworzenia commitu, wypchnięcia zmian i wykonania rebase bieżącej gałęzi użytkownika z ochroną dzierżawy; nigdy do scalania ani niezwiązanych poprawek.

1. Ustal gałąź bazową za pomocą `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`. Użyj ponownie PR-a gałęzi lub utwórz go względem tej bazy, przypisując osobę, etykiety i korzystając z referencyjnego szablonu. Publikacja całego stosu używa `/stacked-prs`.
2. Każdy PR uruchamia `/quantify-impact`; uwzględnij zwięzły opis wartości lub potwierdzone wskaźniki, bez pozorowanych benchmarków.
3. Każda widoczna zmiana, nawet najmniejsza, wymaga inwentaryzacji opisanej w dokumencie referencyjnym, osadzonych materiałów przed i po zmianie, sprawdzonych migawek oraz przechodzących testów wizualnych. Brak dowodów blokuje publikację bez wyraźnej zgody użytkownika na odstępstwo.
4. Uwzględnij aktualne potwierdzenie dogfood. Przeczytaj ponownie opis, sprawdź dostęp recenzenta do obrazów i wyświetl adres URL. Aktualizacje i ponowne otwarcia podlegają tym samym wymaganiom; edycje unieważniają dowody, których dotyczą.

Nie uruchamiaj `/visual-recap` ani `/make-pr-easy-to-review`, chyba że użytkownik wyraźnie o to poprosi.

## Zakończenie

1. Pobierz pojedynczy stan CI za pomocą `gh pr checks <number>`; odnotuj brak CI.
2. Zgłoś istniejące niepowodzenia. Naprawianie i monitorowanie wykraczające poza ten pojedynczy stan wymaga `/go`, polecenia wysyłki, prośby o nadzorowanie lub kolejnego żądania.
3. Zgłoś `git status`, pozostałe różnice, gałąź, commity, PR, CI i następne działanie.
4. Zakończ jednym wierszem stanu: `done`, `awaiting decision` lub `blocked`, zgodnie z kontraktem znaczników repozytorium.

Nigdy nie dodawaj do poczekalni niezwiązanych zmian, nie wypychaj mieszanego zakresu bez potwierdzenia ani nie ukrywaj niepowodzeń. Jeśli `gh pr create` się nie powiedzie, pokaż błąd i polecenie naprawcze.
