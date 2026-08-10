---
title: /development-lifecycle
description: >-
  Prowadź implementację w React, TypeScript i interfejsie użytkownika od
  ogólnego celu aż po samodzielną weryfikację.
type: skill
sidebar:
  label: /development-lifecycle
---
![Diagram umiejętności /development-lifecycle](/diagrams/skills/development-lifecycle.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/development-lifecycle.excalidraw)

Weź odpowiedzialność za jeden rezultat i pracuj, dopóki dowody go nie potwierdzą lub nie pojawi się rzeczywista przeszkoda.

## Kontrakt rezultatu

Przed rozpoczęciem edycji wyodrębnij z żądania i repozytorium cztery elementy:

- **Cel**: ogólny stan końcowy.
- **Ograniczenia**: ograniczenia repozytorium, których nie można wywnioskować, decyzje zastrzeżone dla użytkownika oraz
  nieodwracalne granice.
- **Weryfikacja**: wykonywalne kontrole lub obserwowalne zachowanie, które odróżniają ukończone
  rozwiązanie od rozwiązania jedynie pozornie poprawnego.
- **Zatrzymanie**: żądany punkt końcowy i warunki, które rzeczywiście wymagają udziału użytkownika.

Nie rozwijaj tego w przewidywany kod ani długą procedurę. Precyzyjnie określone żądanie utworzenia, naprawy lub
implementacji upoważnia do działania: przedstaw zwięzły kontrakt i od razu kontynuuj.

## Pętla wykonania

**sprawdź -> działaj -> zweryfikuj -> powtórz.**

### Sprawdź

- Znajdź niewiadomą, która najprawdopodobniej podważy przyjęte podejście.
- Przeczytaj kod, testy, logi, bieżącą dokumentację i sąsiednie przykłady. Preferuj wykonywalne
  dowody zamiast kolejnego opisu.
- Najpierw rozstrzygnij najbardziej zmienną niewiadomą. Pozostałe zaklasyfikuj jako wyszukanie, prototyp,
  odwracalne założenie lub przesłankę do wstrzymania pracy.
- Dopasuj się do istniejących wzorców i sprawdzonej skali. Korzystaj ze specjalistycznych wskazówek tylko wtedy, gdy
  analizowane zadanie wchodzi w ich konkretną dziedzinę.

### Działaj

- Jeden model główny jest jedynym właścicielem zadania. Delegowanie i stała praca w tle wymagają
  wyraźnej zgody użytkownika.
- Zacznij od najmniejszej oczywistej zmiany. Najpierw usuwaj lub wykorzystuj ponownie, zanim dodasz nowe mechanizmy.
- W przypadku błędów i istotnych zachowań stosuj TDD na poziomie publicznego kontraktu: RED -> najmniejsze GREEN
  -> REFACTOR. Nie twórz sztucznych testów dla statycznego okablowania ani usuwania, które nie zmienia zachowania.
- Pozwól, by ustalenia korygowały podejście. Ponownie zaplanuj zmieniony fragment zamiast trzymać się nieaktualnych
  przewidywań.
- Trzymaj się celu. Poboczne porządki zgłoś, chyba że blokują weryfikację.

### Zweryfikuj

- Uruchom odpowiednie dla repozytorium testy, sprawdzanie typów, lintowanie, kompilację i kontrole statyczne.
- Sprawdź istotne zachowanie przez jego rzeczywisty punkt wejścia. Przetestuj zamierzone użycie oraz jedną
  wiarygodną ścieżkę błędu lub odzyskiwania.
- Oceń rezultat względem celu, ograniczeń i wiarygodnego ryzyka. Weryfikacja to
  dowód, a nie samo odhaczenie listy kontrolnej.
- Każde niepowodzenie wyznacza kolejne działanie. Naprawiaj i powtarzaj, aż wszystkie kryteria zakończenia zostaną spełnione.

## Granice

- Pytaj tylko o istotną decyzję zastrzeżoną dla użytkownika albo nieodwracalne działanie dotyczące środowiska produkcyjnego,
  prawa lub prywatności, usuwania danych bądź wysokiego poziomu bezpieczeństwa.
- Nigdy nie scalaj zmian, nie wykonuj wymuszonego wypychania, nie twórz dodatkowych PR-ów ani nie rozszerzaj punktu końcowego bez zgody.
- Przed zmianą kodu na gałęzi main/master/develop utwórz odizolowane drzewo robocze za pomocą
  `scripts/mux-worktree.sh <type>/<branch-name>`. [ETHOS: Izolacja drzewa roboczego]
- Przy długiej pracy lub wielu niewiadomych można zapisać bieżącą hipotezę, dowody, odstępstwa i
  przesłanki do wstrzymania pracy w ignorowanym przez Git pliku `.context/implementation-notes.md`. Krótkie zadania pozostają
  w rozmowie.

## Zakończenie

Zatrzymaj się w żądanym punkcie końcowym: odpowiedź, zweryfikowana zmiana lokalna, commit, wypchnięcie zmian, PR lub pełne
wdrożenie. Nie przerywaj tylko dlatego, że zaplanowany krok został ukończony. Zobacz [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/REFERENCE.md)
wyłącznie wtedy, gdy konkretna ścieżka weryfikacji lub dostarczenia wymaga opisanych tam szczegółowych poleceń.
