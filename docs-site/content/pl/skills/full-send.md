---
description: >-
  Prowadź naprawy, weryfikację, CI i opiekę nad przeglądami do autoryzowanego
  punktu końcowego. Użyj dla full send; full stop lub --no-merge pozostawia
  decyzję o merge użytkownikowi.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - full send
sidebar:
  label: /full-send
title: /full-send
type: skill
---
![Diagram umiejętności /full-send](/diagrams/skills/full-send.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/full-send.excalidraw)

Odpowiadaj za rezultat, nie tylko diff. Kontynuuj rutynowe naprawy; wróć dopiero po potwierdzeniu żądanego punktu końcowego albo gdy zewnętrzna blokada wymaga działania użytkownika.

## Autoryzacja i zakres [#authorization-and-scope]

- Wyraźne `full send <zadanie lub PR>` autoryzuje naprawy, commit, push, utworzenie PR-a, opiekę nad CI/przeglądami oraz merge tego jednego jednoznacznego rezultatu. Prośba o wyjaśnienie, stworzenie lub przegląd tej umiejętności nie jest jej wywołaniem. Odkrycie umiejętności nie oznacza zgody.
- Ustal repozytorium, cel, posiadaną gałąź/worktree, PR/bazę, dowody akceptacji i warunek zakończenia. Użyj istniejącego PR-a; pozostaw jego gałąź aktywną w Conductor. Gdy cel jest niejednoznaczny, zapytaj o niego zamiast wybierać inny PR.
- Wcześniejsze instrukcje zakończenia mają pierwszeństwo: `--no-merge`, bez push, tylko lokalnie, tylko draft lub gotowy PR zawężają autoryzację. Sama opieka nad PR-em nie upoważnia do merge. Przed merge wskaż instrukcję użytkownika autoryzującą ten konkretny PR.
- Zachowaj niezwiązane zmiany, nazwy gałęzi, zabezpieczenia repozytorium i decyzje zastrzeżone dla użytkownika dotyczące produkcji, operacji destrukcyjnych oraz bezpieczeństwa. Pracuj na bieżącej posiadanej gałęzi funkcji. Rozszerzenie zakresu wymaga decyzji; rutynowe naprawy i lease-push nie wymagają jej.
- Pracuj w głównym kontekście, chyba że użytkownik wyraźnie autoryzuje delegowanie. Korzystaj wyłącznie z autoryzowanych narzędzi, kont i izolowanych sesji przeglądarki; „wszelkimi środkami” nie oznacza obchodzenia zabezpieczeń.

Wczytuj zależności zgodnie z [mechaniką umiejętności](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
Dla full stop, kontroli stanu na serwerze, powiadomienia o blokadzie, wznowienia pracy lub wyraźnie zamówionej pętli Sol przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/full-send/REFERENCE.md).

## Napraw i udowodnij [#fix-and-prove]

1. Sprawdź pełny diff gałęzi i prośbę, nie tylko opis PR-a. Przed zmianą zachowania przygotuj nieprzechodzący test publicznego kontraktu; użyj [TDD](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md).
2. Napraw przyczynę najmniejszą zmianą. Uruchom testy celowane, lint, kontrolę typów oraz wymagane sprawdzenia build/integracji właściwe dla repozytorium. Ujawniaj ostrzeżenia i pominięty zakres weryfikacji.
3. Wykonaj [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md) przez rzeczywisty punkt wejścia: zamierzony scenariusz i wiarygodną ścieżkę awarii/odzyskiwania. Dla widocznych zmian zbierz i sprawdź [dowody wizualne PR-a](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5).
4. Wykonaj [review](https://github.com/malinskibeniamin/skills/blob/main/review/SKILL.md) w głównym kontekście. Napraw konkretne defekty; o gotowości decydują dowody, nie entuzjazm modelu ani pochwały recenzenta.
5. Powiąż dowody z SHA head i rewizją bazy. Każda edycja, push, rebase lub zmiana bazy unieważnia dotknięte dowody; powtórz weryfikację przed ogłoszeniem sukcesu.

## Opublikuj i pilnuj [#publish-and-babysit]

Publikuj przez [commit-push-pr](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/SKILL.md); gotowość wymaga aktualnej [kontroli bramek repozytorium korzystającego z harnessu](https://github.com/malinskibeniamin/skills/blob/main/shared/review-enforcement.md). Kontynuuj po pojedynczym sprawdzeniu CI; potwierdź zakres commitów i zgodność zdalnego HEAD z lokalnym HEAD.

- Obserwuj kontrole bieżącego PR-a i zamówione przeglądy w tej aktywnej sesji. Stan oczekujący oznacza dalsze czekanie, nie koniec. Brak CI nie oznacza zielonego CI; ustal wymagane kontrole z polityki repozytorium zamiast wymyślać dowód sukcesu.
- Sprawdź logi nieudanego zadania, odtwórz problem, napraw, zweryfikuj, wykonaj commit/push i obserwuj nowy head. Powtarzaj awarię infrastruktury tylko na podstawie dowodów; niezmienne powtarzające się awarie wymagają diagnozy, nie nieskończonych ponowień. Nie osłabiaj bramek dla zielonego wyniku.
- Użyj [resolve-pr-feedback](https://github.com/malinskibeniamin/skills/blob/main/resolve-pr-feedback/SKILL.md) dla uwag ludzi i konkretnych uwag automatów. Pobierz wszystkie strony wątków, komentarzy i przeglądów; napraw albo odrzuć z dowodami, odpowiedz i ponownie odczytaj stan rozwiązania. Stare akceptacje i milczenie botów nie są aktualnymi przeglądami.
- Wymagaj zakończonych obowiązkowych kontroli i przeglądów, braku zasadnych nierozwiązanych uwag oraz aktywnych żądań zmian dotyczących kandydata. Nie zatwierdzaj własnego PR-a ani nie wymyślaj poparcia. Gdy recenzent, uprawnienia lub usługa pozostają niedostępne i agent nie może już działać, powiadom przez obsługiwane narzędzie pytań lub danych wejściowych; jeśli jest niedostępne, zakończ wyraźnym potwierdzeniem blokady i dokładnie potrzebnym działaniem. W oczekiwaniu nie zastępuj tożsamości, danych uwierzytelniających ani uprawnień.
- Jeśli jest to wymagane, wykonaj rebase posiadanej gałęzi pozostającej za bazą, zweryfikuj i użyj `--force-with-lease`. Kontynuuj w tym samym PR-ze. Przed limitem kontekstu zapisz head/bazę, ID oczekujących uruchomień/wątków, dowody i następny krok w nieśledzonym punkcie kontrolnym; bez niespodziewanego demona, cron, konfiguracji auto-review ani obietnic pracy po zakończeniu sesji.

## Ostatnia weryfikacja i pewność [#final-verification-and-confidence]

Po ustabilizowaniu CI i uwag odśwież head/bazę, pełny diff, kontrole, decyzję przeglądu, wątki, stan draft i możliwość merge. Wykonaj ostatnią weryfikację dokładnie tego kandydata: kryteria akceptacji, dotknięte scenariusze przez rzeczywiste punkty wejścia i przegląd ryzyka w głównym kontekście. Jeśli kandydat się zmieni, wróć do pętli; zielone dowody starszego kandydata nie wystarczą.

Zgłaszaj **wysoką pewność** tylko przy zaobserwowanym zachowaniu, przechodzących wymaganych bramkach, obsłużonych uwagach, braku istotnych defektów/niewiadomych oraz zrozumianym wdrożeniu i odzyskiwaniu. Wskaż ograniczenia; nie wymyślaj procentu ani gwarancji braku przyszłych regresji. Niższa pewność oznacza zebranie dowodów lub naprawę, nie przekazanie rutynowego przeglądu użytkownikowi.

## Zamknij pętlę [#close-the-loop]

Dla autoryzowanego merge wczytaj [kontrakt chronionego merge](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/merge.md) i użyj chronionej ścieżki serwera z kontrolą oczekiwanego head. Respektuj bramkę aktualności/wyścigu bazy lub kolejkę merge; nie używaj obejścia administratora ani auto-merge jako alternatywy. Potwierdź stan serwera: **merged** nie oznacza **queued**. Obserwuj autoryzowany wpis w kolejce aż do wyniku końcowego; awaria kolejki lub ruch head/bazy przywraca weryfikację. Nieznany wynik mutacji wymaga odczytu przed ponowieniem.

Przed zakończeniem potwierdź wymagane kontrole po merge. Osobna promocja na produkcję i stały monitoring wymagają własnej autoryzacji. Wcześniejsze zatrzymanie bez merge kończy się zweryfikowaną gotowością PR-a; oczekujące kontrole, przeglądy lub kolejka nie spełniają tego warunku.

Zwróć krótkie potwierdzenie: rezultat/URL PR-a, zweryfikowany head i ewentualny commit merge, kontrole, stan przeglądów/wątków, pewność popartą dowodami oraz rzeczywiste ograniczenia/blokady. Stosuj kontrakt intencji/wpływu/statusu repozytorium. Nie przedstawiaj niedokończonego PR-a jako ukończonej pracy ani nie obiecuj stałego nadzoru.

Inspiracja i ograniczenia badań: [SOURCES.md](https://github.com/malinskibeniamin/skills/blob/main/full-send/SOURCES.md). To autorski lokalny workflow, nie kopia ani umiejętność zatwierdzona przez Theo.
