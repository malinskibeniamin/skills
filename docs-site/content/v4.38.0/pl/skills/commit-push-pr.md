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

Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/commit-push-pr/REFERENCE.md), aby poznać wymagania wstępne przeglądu, typy commitów, etykiety, szablon
opisu, zrzuty ekranu i sekcje dotyczące aktualizacji zależności.

## Kontrola wstępna

1. Uruchom `git status -sb`, `git diff HEAD`, `git branch --show-current`,
   `git log --oneline -5` i sprawdź, czy z tej gałęzi jest już otwarty PR.
2. Ustal żądany punkt końcowy: tylko commit, wypchnięcie (`--no-pr`) lub PR. Wariant z samym commitem pomija kontrolę zdalnego repozytorium i `gh`.
3. Tylko wypchnięcie/PR: sprawdź, czy zdalne repozytorium jest dostępne. Tylko PR: ustal domyślną gałąź za pomocą
   `gh repo view`, a następnie sprawdź, czy `gh` jest zainstalowane i uwierzytelnione.
4. Tylko PR: wykryj lokalną przynależność do stosu za pomocą `gh stack view --json`; jeśli PR już istnieje, sprawdź również
   jego `baseRefName` i obiekt `stack` z interfejsu REST. Standardowy punkt końcowy PR-a obejmuje tylko bieżącą
   warstwę. Nigdy nie upoważnia do użycia `gh stack submit`, które może opublikować inne gałęzie.
5. Tylko PR: przeprowadź odpowiednie obszary przeglądu bezpośrednio; nie blokuj działania wyłącznie dlatego, że nie wywołano wskazanej umiejętności
   przeglądu.
6. Tylko PR: działające zachowanie wymaga aktualnego wyniku PASS z `/dogfood`. Wynik BLOCKED wymaga zgody użytkownika na odstępstwo.
7. Pogrupuj zmienione pliki według celu. Dodaj do poczekalni tylko żądane ścieżki; zapytaj o zakres wyłącznie wtedy, gdy
   nie można bezpiecznie ustalić własności zmian.

## Commit

1. Pozostań na bieżącej gałęzi funkcji. Jeśli jesteś na gałęzi domyślnej, utwórz `type/description`.
2. Dla każdej spójnej grupy:
   - `git add <explicit paths>`
   - utwórz commit `type(scope): terse description`
   - użyj małych liter, 5–72 znaków, bez kropki na końcu
3. Jawne żądanie utworzenia wyłącznie commitu kończy działanie w tym miejscu po sprawdzeniu czystości drzewa i podsumowaniu commitu.
4. Tylko wypchnięcie/PR: pokaż `origin/<branch>..HEAD`, a następnie wypchnij gałąź z ustawieniem śledzenia.
5. Po wykonaniu rebase lub innego przepisania bieżącej, należącej do użytkownika gałęzi funkcji użyj
   `--force-with-lease`, gdy jest to potrzebne, bez ponownego pytania o zgodę. Nigdy nie używaj zwykłego
   `--force`; przepisanie gałęzi domyślnej, współdzielonej, należącej do kogoś innego lub równolegle
   używanej wymaga wyraźnej zgody.

## Pull request

`--no-pr` lub jawne żądanie utworzenia commitu i wypchnięcia zmian kończy działanie po sprawdzeniu czystości drzewa i podsumowaniu
wypchniętego commitu.

W przeciwnym razie:

1. Traktuj żądanie przygotowania/otwarcia/utworzenia PR-a jako zgodę na wykonanie wymaganych czynności: weryfikację, utworzenie commitu i
   wypchnięcie bieżącej gałęzi. Obejmuje to także potrzebne `--force-with-lease` po wykonaniu rebase bieżącej,
   należącej do użytkownika gałęzi funkcji, ale nie scalanie, zwykłe `--force`, przepisywanie gałęzi współdzielonej
   ani niezwiązane poprawki.
2. Ustal jawną gałąź bazową za pomocą
   `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`. Użyj ponownie istniejącego PR-a gałęzi lub
   utwórz PR względem tej gałęzi bazowej, przypisując osobę, etykiety i korzystając z referencyjnego szablonu opisu.
   W przypadku jawnej publikacji całego stosu postępuj zgodnie z `/stacked-prs`.
3. W przypadku zmian widocznych dla klientów uwzględnij po jednym wierszu ze zrzutem ekranu/przeglądem powierzchni dla każdego widoku.
4. W przypadku zmian uruchamialnych uwzględnij bieżące potwierdzenie dogfood.
5. Wyświetl adres URL PR-a.

Nie uruchamiaj `/visual-recap` ani `/make-pr-easy-to-review`, chyba że użytkownik wyraźnie poprosi
o ten dodatkowy artefakt lub pracę nad historią.

## CI i zakończenie

1. Pobierz pojedynczy stan CI za pomocą `gh pr checks <number>`. Odnotuj brak CI.
2. Jeśli testy już kończą się niepowodzeniem, zgłoś je; naprawianie i monitorowanie wykraczające poza ten pojedynczy stan
   wymaga `/go`, polecenia wysyłki, jawnej prośby o nadzorowanie lub kolejnego żądania.
3. Uruchom `git status` i `git diff`; zgłoś niezatwierdzone zmiany.
4. Podsumuj gałąź, commity, PR, CI i pozostałe działania.
5. Zakończ jednym wierszem stanu: `🟢 gotowe — PR otwarty; CI <state>`, `🟡 oczekiwanie na decyzję — <decision>` lub
   `🔴 zablokowane — <external blocker and needed input>`.

Nigdy nie dodawaj do poczekalni niezwiązanych zmian, nie wypychaj mieszanego zakresu bez potwierdzenia ani nie ukrywaj nieudanego
polecenia. Jeśli `gh pr create` się nie powiedzie, pokaż błąd i polecenie naprawcze.
