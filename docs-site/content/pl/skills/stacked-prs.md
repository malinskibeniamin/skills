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


Używaj `gh stack`; plik [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/stacked-prs/REFERENCE.md) opisuje polecenia, tryb linków zewnętrznych i odzyskiwanie.

## Kontrakt

- Każdą warstwę można niezależnie przeglądać względem jej rodzica.
- Jeden obszar roboczy Conductor zarządza jednym stosem; niepowiązane prace korzystają z innego.
- Przetestuj każdą warstwę, przejrzyj `<parent>...HEAD` i zgłoś wynik `gh stack view --json`.
- Przestrzegaj żądanego punktu końcowego: planu, pracy lokalnej, wypchnięcia, wersji roboczej, otwarcia lub scalenia.

## Ustal tryb

Sprawdź `gh`, uwierzytelnienie, obsługę repozytorium, bieżącą gałąź, zdalne repozytoria, czystość drzewa oraz wynik `git worktree list --porcelain`. Jeśli brakuje rozszerzenia, zaproponuj `gh extension install github/gh-stack`; nigdy nie instaluj go bez pozwolenia. W przypadku wielu zdalnych repozytoriów przekazuj `--remote origin`.

Domyślnie używaj trybu natywnego: jeden obszar roboczy zarządza całym stosem i przełącza gałęzie. Przed poleceniami strukturalnymi uruchom:

```bash
"${CLAUDE_PLUGIN_ROOT:-.}/scripts/stack-worktree-conflicts.sh"
```

Kod wyjścia 2 zgłasza wpisy `branch<TAB>path`; nie przejmuj gałęzi, nie usuwaj drzew roboczych ani nie wykonuj kaskady. Używaj trybu linków zewnętrznych tylko w celowych konfiguracjach z osobnym drzewem roboczym dla każdej warstwy:
`gh stack link --base <trunk> --remote origin <bottom> ... <top>`. Przed kaskadami skoordynuj te drzewa robocze.

## Zaplanuj i opracuj

Przedstaw tabelę od najniższej do najwyższej warstwy z celem, gałęzią, rodzicem, zakresem i weryfikacją. Zależności powinny znajdować się w tej samej lub niższej warstwie niż ich element zależny. Potwierdź tylko granice zaproponowane przez agenta.

Wymagaj czystego drzewa dla poleceń strukturalnych. Rozpocznij za pomocą `gh stack init --base <trunk> <bottom>`. Implementuj zgodnie z cyklem RED -> GREEN -> REFACTOR, weryfikuj i twórz commity. Dodaj jeden spójny zakres prac za pomocą `gh stack add <next>`. Używaj jawnych nazw gałęzi i wskazuj pliki przy dodawaniu, zamiast używać `git add -A`.

Używaj `gh stack checkout <branch>` i `gh stack view --json`; unikaj poleceń bez argumentów i interfejsu TUI.

## Przejrzyj i opublikuj

```bash
BASE=$("${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")
git diff "$BASE"...HEAD
git log "$BASE"..HEAD --oneline
```

Przed publikacją zweryfikuj i przetestuj praktycznie każdą warstwę. Przesłanie całego stosu domyślnie tworzy wersje robocze: `gh stack submit --auto --remote origin`; dodaj `--open` tylko na żądanie. Prośba dotycząca pojedynczego PR-a nigdy nie publikuje innych warstw.

Zastosuj [materiał dowodowy PR-a](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md) do każdej warstwy: `/quantify-impact`, osadzone porównanie przed i po oraz zaliczone testy wizualne dla widocznych zmian. Porównaj ją z rodzicem; przygotuj treści przed przesłaniem i zweryfikuj je później. Kaskady unieważniają materiał dowodowy.

## Uwagi, synchronizacja i scalanie

Popraw uwagi na gałęzi, do której należą, i zweryfikuj zmiany. Kaskady przepisują wyższe gałęzie. Stos należący do użytkownika i utrzymywany w tym obszarze roboczym można poddać rebase'owi i wypchnąć za pomocą force-with-lease bez ponownego pytania o zgodę; odnotuj to. Zapytaj, gdy własność jest niejasna albo zmianie podlegałaby gałąź domyślna, współdzielona, należąca do kogoś innego lub równolegle używana. Użyj `gh stack rebase --upstack --remote origin`, a następnie `gh stack push --remote origin`; polecenie `gh stack sync --prune --remote origin` podlega tej samej granicy.

Kontynuuj po rozwiązaniu konfliktów za pomocą `gh stack rebase --continue`; przerwij operację tylko na żądanie. W trybie linków zewnętrznych najpierw skoordynuj drzewa robocze.

Nigdy nie scalaj jako efektu ubocznego publikacji. Wyraźna intencja scalenia obejmuje wyłącznie wskazany ciągły zakres. Ponownie sprawdź zatwierdzenia, wyniki kontroli, historię, komentarze i zadania do wykonania; użyj `gh stack merge <stack-or-pr> --yes --merge-method <squash|rebase|merge>`, nigdy `gh pr merge`.

Podaj gałąź główną, uporządkowane warstwy, bieżącą warstwę, stany i adresy URL PR-ów, weryfikację, konflikty, wykonane przepisania oraz następną czynność od najniższej warstwy.
