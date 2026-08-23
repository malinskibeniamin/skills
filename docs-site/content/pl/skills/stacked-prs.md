---
title: /stacked-prs
description: >-
  Tworzenie zależnych pull requestów GitHub i zarządzanie nimi za pomocą gh
  stack. Używaj w przypadku stosów PR-ów, łańcuchów zależnych gałęzi,
  przyrostowych warstw przeglądu lub dzielenia dużej zmiany na uporządkowane
  PR-y.
type: skill
sidebar:
  label: /stacked-prs
---
![Diagram umiejętności /stacked-prs](/diagrams/skills/stacked-prs.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/stacked-prs.excalidraw)

Używaj interfejsu CLI `gh stack` serwisu GitHub, zachowując kontrakty mechanizmu dotyczące przeglądu, drzew roboczych i dostarczania. Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/stacked-prs/REFERENCE.md), aby poznać zależną od wersji macierz poleceń, tryb linków zewnętrznych, odzyskiwanie i potwierdzenie stanu.

## Kontrakt

- **Cel:** każdą warstwę można niezależnie przeglądać względem gałęzi znajdującej się bezpośrednio pod nią.
- **Zabezpieczenia:** jeden obszar roboczy Conductor zarządza jednym stosem; niepowiązane prace korzystają z innego stosu; instalacje globalne, przepisywanie współdzielonych gałęzi, publikowanie i scalanie są wykonywane zgodnie z intencją użytkownika.
- **Weryfikacja:** przetestuj każdą warstwę, przejrzyj `<parent>...HEAD`, a następnie zgłoś wynik polecenia `gh stack view --json`.
- **Zatrzymanie:** przestrzegaj żądanego punktu końcowego: planu, pracy lokalnej, wypchnięcia, wersji roboczej, otwarcia lub scalenia.

## 1. Ustal tryb

Sprawdź `gh`, uwierzytelnienie, obsługę repozytorium, bieżącą gałąź, zdalne repozytoria, czystość drzewa oraz wynik `git worktree list --porcelain`. Jeśli brakuje rozszerzenia, podaj polecenie `gh extension install github/gh-stack`; nie instaluj go bez pozwolenia. Ten mechanizm wypycha zmiany do `origin`; w przypadku wielu zdalnych repozytoriów przekazuj `--remote origin` do każdego obsługiwanego polecenia.

Domyślnie używaj **trybu natywnego**: jeden obszar roboczy zarządza całym stosem i przełącza gałęzie. Przed wykonaniem `add`, `checkout`, `rebase`, `sync`, `modify` lub `push` uruchom:

```bash
"${CLAUDE_PLUGIN_ROOT:-.}/scripts/stack-worktree-conflicts.sh"
```

Kod wyjścia 2 wyświetla wpisy `branch<TAB>path` dla gałęzi stosu używanych przez inne drzewa robocze. Zgłoś je; nie usuwaj drzewa roboczego, nie przejmuj jego gałęzi ani nie wykonuj lokalnej kaskady.

Używaj **trybu linków zewnętrznych** tylko w celowych przepływach pracy z osobnym drzewem roboczym dla każdej warstwy. Publikuj za pomocą `gh stack link --base <trunk> --remote origin <bottom> ... <top>`. Przed każdą lokalną kaskadą skoordynuj lub zwolnij te drzewa robocze.

## 2. Zaplanuj i opracuj

Przed rozpoczęciem pracy nad kodem przedstaw tabelę od najniższej do najwyższej warstwy: cel, gałąź, rodzic, dozwolony zakres i weryfikacja dla każdej warstwy. Zależności powinny znajdować się w tej samej lub niższej warstwie. Potwierdź granice zaproponowane przez agenta; granice jawnie określone przez użytkownika nie wymagają ponownej akceptacji.

Wymagaj czystego drzewa dla poleceń strukturalnych. Przyjmij lub utwórz najniższą warstwę za pomocą `gh stack init --base <trunk> <bottom-branch>`. Implementuj zgodnie z cyklem RED -> GREEN -> REFACTOR, weryfikuj i świadomie twórz commity. Dodaj kolejny spójny zakres prac za pomocą `gh stack add <next-branch>`. Używaj jawnych nazw gałęzi oraz standardowych poleceń `git add`/`git commit`; unikaj skrótów `-A`, które zacierają własność warstw.

Nawiguj za pomocą `gh stack checkout <branch>` i sprawdzaj stan za pomocą `gh stack view --json`. Polecenia bez argumentów i wyjście TUI nie są bezpieczne dla agenta.

## 3. Przejrzyj i opublikuj

```bash
BASE=$("${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")
git diff "$BASE"...HEAD
git log "$BASE"..HEAD --oneline
```

Uruchom odpowiednią weryfikację i testy praktyczne dla bieżącej warstwy. Przed publikacją sprawdź każdą gałąź; zatrzymaj się, jeśli zgłoszenie zawiera niezamierzone lub niedokończone prace. Jawne przesłanie całego stosu domyślnie tworzy wersje robocze: `gh stack submit --auto --remote origin`. Dodaj `--open` tylko wtedy, gdy użytkownik zażądał PR-ów gotowych do przeglądu. Prośba dotycząca pojedynczego PR-a nigdy nie upoważnia do publikowania innych, jeszcze nieprzesłanych warstw.

## 4. Uwagi, synchronizacja i scalanie

Popraw uwagi na gałęzi, do której należą, i zweryfikuj zmiany. Kaskada przepisuje wyższe gałęzie. W przypadku stosu należącego do użytkownika i utrzymywanego w bieżącym obszarze roboczym wykonaj rebase i wypchnij kaskadę za pomocą `--force-with-lease` bez osobnego pytania o zgodę; odnotuj przepisanie w potwierdzeniu. Pytaj tylko wtedy, gdy własność jest niejasna albo miałaby zostać przepisana gałąź domyślna, współdzielona, należąca do kogoś innego lub równolegle używana. Następnie użyj `gh stack rebase --upstack --remote origin`, a potem `gh stack push --remote origin`. Polecenie `gh stack sync --prune --remote origin` podlega tej samej granicy własności.

Kontynuuj po rozwiązaniu konfliktu za pomocą `gh stack rebase --continue`. Przerwij operację tylko wtedy, gdy użytkownik poprosi o jej porzucenie. W trybie linków zewnętrznych najpierw skoordynuj powiązane drzewa robocze.

Nigdy nie scalaj jako efektu ubocznego publikacji. Wyraźna intencja scalenia upoważnia wyłącznie do scalenia wskazanego ciągłego zakresu. Ponownie sprawdź zatwierdzenia, wyniki kontroli, liniową historię, komentarze i zadania do wykonania, a następnie użyj `gh stack merge <stack-or-pr> --yes --merge-method <squash|rebase|merge>`, nigdy `gh pr merge`.

Na koniec podaj gałąź główną, uporządkowane warstwy, bieżącą warstwę, adresy URL i stany PR-ów, weryfikację każdej warstwy, konflikty drzew roboczych, wykonane przepisania oraz następną czynność od najniższej warstwy.
