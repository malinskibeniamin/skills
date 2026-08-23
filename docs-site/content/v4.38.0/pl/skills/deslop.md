---
title: /deslop
description: >-
  Awaryjny audyt służący usuwaniu nieuzasadnionego kodu z już nadmiernie
  rozbudowanych zmian lub repozytorium. Używaj wyłącznie na wyraźne żądanie
  dotyczące deslop, ponytail, lazy mode, YAGNI lub nadmiarowego kodu; nigdy jako
  obowiązkowego etapu cyklu pracy.
type: skill
sidebar:
  label: /deslop
---
![Diagram umiejętności /deslop](/diagrams/skills/deslop.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/deslop.excalidraw)

To rozwiązanie awaryjne, a nie element cyklu pracy. Czysty kod powinien być czysty od początku; używaj tej umiejętności tylko wtedy, gdy zmiany lub repozytorium są już nieproporcjonalnie duże względem realizowanego zachowania.

Dołączone do Claude Code polecenie `/simplify` pozostaje dostępne na wyraźne żądanie do taktycznego porządkowania kodu. Nie jest ono bramką cyklu pracy ani zamiennikiem przeglądu poprawności; `/deslop` podważa zasadność istnienia całej powierzchni rozwiązania.

## Mniej znaczy więcej

Kod jest obciążeniem, ale ujemna liczba LOC nie jest celem. Preferuj **gęstość semantyczną**: najmniejszą oczywistą implementację, w której każda konstrukcja realizuje wymagane zachowanie lub objaśnia domenę. Świetny kod wymaga niewielu wyjaśnień, ponieważ jego struktura odpowiada problemowi. Nigdy nie poświęcaj czytelności dla mniejszej liczby znaków.

Projektuj pod kątem wykazanej skali. Nie dodawaj indeksów, wirtualizacji, buforowania, kolejek, ponawiania prób, fabryk, flag, konfiguracji ani punktów rozszerzeń z myślą o jedynie wyobrażalnej przyszłości.

Dodatek zasługuje na swoje miejsce, jeśli wyraża wymagane zachowanie, objaśnia domenę lub ogranicza wiarygodne ryzyko. „Może się zdarzyć” nie jest dowodem.

## Tryb zapisu

Tylko na wyraźne żądanie: `/deslop write`, „ponytail” lub „lazy mode”. Najpierw poznaj cały przepływ; drabina skraca rozwiązanie, nigdy analizę.

1. Usuń spekulacyjny zakres lub pozostaw go niezrealizowanym.
2. Wykorzystaj ponownie kod z repozytorium.
3. Użyj języka lub biblioteki standardowej.
4. Użyj natywnej platformy.
5. Użyj już zainstalowanej zależności.
6. Napisz najmniejsze czytelne lokalne rozwiązanie.
7. Dopiero wtedy twórz własny mechanizm.

Usuwaj przyczynę źródłową, a nie objawy: przed zmianą współdzielonej funkcji wyszukaj każdego jej wywołującego. Preferuj bezpośredni kod, dopóki abstrakcja nie usuwa rzeczywistej, powtarzalnej złożoności. Komentarze wyjaśniają nieuniknione „dlaczego”; kod wyjaśnia „co”.

Istotne zachowanie zachowuje najmniejszy test publicznego kontraktu. Nie twórz testów dla trywialnego łączenia elementów ani nie usuwaj przydatnych testów tylko po to, by skrócić zmiany.

**Intensywność** (`/deslop lite|full|ultra`, domyślnie full): lite wskazuje prostszą alternatywę; full stosuje drabinę; ultra podważa każde wymaganie przed zachowaniem kodu.

**Nigdy nie usuwaj:** jawnych wymagań, walidacji na granicach zaufania, zabezpieczeń, dostępności ani obsługi błędów zapobiegającej utracie danych.

## Tryb bramki

Przeczytaj cel, pobliski kod, `git diff --stat` oraz `git diff`. Oznaczaj wyłącznie potwierdzony nadmiar:

- `delete:` martwy lub spekulacyjny kod; nie zastępuj go niczym.
- `stdlib:` własny kod zastępowany przez język lub bibliotekę standardową.
- `native:` kod lub zależność zastępowane przez zachowanie platformy.
- `yagni:` elastyczność bez bieżącego wymagania.
- `shrink:` równie czytelne zachowanie o mniejszej powierzchni.

Następnie usuwaj, umieszczaj bezpośrednio i upraszczaj. Zmiany umiejętności lub zestawu testowego nadal wymagają odpowiadających im dowodów ewaluacji RED -> GREEN. Uruchom najmniejszy właściwy zestaw weryfikacji.

Zwróć `NEEDS_CHANGES`, gdy wymagane zachowanie jest ukryte pod możliwą do uniknięcia powierzchnią rozwiązania. Nie nagradzaj przesadnego skracania kodu ani nie usuwaj sprawdzonych zabezpieczeń. Opisz, co pozostało, co usunięto i dlaczego. W przypadku audytów repozytorium uszereguj największe uzasadnione usunięcia; w pozostałych przypadkach zakończ słowami `Lean already. Ship.`

Kompaktowa lista kontrolna przeglądu znajduje się w pliku [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/deslop/REFERENCE.md).
