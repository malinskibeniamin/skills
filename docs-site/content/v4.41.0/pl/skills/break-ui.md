---
description: "Testuj dane i układ UI pod obciążeniem: długi tekst, Unicode, powiększenie, wąskie kontenery, puste stany i duże kolekcje. Używaj przy diagnozie, dogfood, przeglądzie wizualnym lub jawnym żądaniu próby uszkodzenia."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["break ui"]}
sidebar: {"label":"/break-ui"}
title: "/break-ui"
type: "skill"
---
![Diagram umiejętności /break-ui](/diagrams/skills/break-ui.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/break-ui.excalidraw)

Testuj rzeczywisty komponent na trudnych, lecz poprawnych danych. Adaptacja umiejętności Emila Kowalskiego;
[pochodzenie](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/EMIL-SKILLS-CREDITS.md). To ukierunkowany audyt danych/układu,
nie zastępstwo dogfood całego cyklu życia ani ogólnej krytyki wizualnej.

## Zakres działania

Audyt zwraca dowody i propozycje poprawek bez edycji komponentów produkcyjnych.
Najpierw użyj istniejących stories, danych testowych i atrap. Przełącznik tylko deweloperski
lub izolowane środowisko twórz wyłącznie na żądanie ich zbudowania; materiały robocze trzymaj w `.context/`.
Jawne żądanie poprawki pozwala naprawiać potwierdzone usterki przez TDD i dostarczanie;
rutynowe poprawki w uzgodnionym zakresie nie wymagają kolejnego zatwierdzenia.

## Pętla

1. Zmapuj renderowane pola, ich źródło/typ, ograniczenie schematu, opcjonalność i granice kolekcji.
   Brak granicy oznacza niewiadomą, a nie zgodę na wymyślenie jej lub zmianę API.
2. Przeczytaj [CATALOG.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/break-ui/CATALOG.md). Wybierz realistyczne wartości zgodne z faktycznym kontraktem;
   niepoprawne/null wprowadzaj tylko na granicy, która ma je walidować.
   Nie zmieniaj kształtu danych, kodu komponentu, tokenów ani ścieżki renderowania.
3. Wprowadź dane przez rzeczywistą granicę props/atrapy/API. Łącz tekst długi, krótki i Unicode,
   brakujące pola opcjonalne, wszystkie poprawne statusy i liczności 0/1/wiele. Porównaj dane zwykłe,
   najgorszy przypadek, pusty zbiór, jeden element i obsługiwaną granicę liczności.
4. Renderuj w rzeczywistym kontenerze oraz najwęższym/najszerszym obsługiwanym układzie, przy powiększeniu 200%
   i w obsługiwanych motywach/kierunkach. Sprawdź działania wychodzące poza obszar klawiaturą/dotykiem.
   Zapisz zrzuty/stan; bez dostępu do przeglądarki oznacz wnioski z CSS jako przypuszczenia.
5. Podaj wartość, widoczną awarię, miejsce, wpływ, propozycję poprawki i to, co wytrzymało próbę.
   Wskaż rzeczywiste decyzje produktowe (zawijanie/przycinanie, paginacja/wirtualizacja); zachowaj
   istniejące konwencje zamiast przeprojektowywać każdy przypadek brzegowy.
6. Przy zamówionych poprawkach zacznij od nieudanego testu regresji kontraktu publicznego, napraw, a potem
   odtwórz każde dotknięte dane testowe i dane zwykłe. Dane regresji pozostają tylko w testach/dewelopmencie.

## Punkty podatne na awarie

Sprawdź rodzeństwo flex o stałym rozmiarze, `min-width: 0`/`minmax(0, 1fr)`, niełamliwe ciągi,
przycinanie wielowierszowych glifów, inicjały bez rozbijania grafemów, lokalizację/liczby mnogie,
zastępstwo obrazu i dostęp do pełnej wartości po przycięciu. Nie ukrywaj liczb wymagających porównania.

Dane testowe korzystają z zarezerwowanych domen przykładowych i danych syntetycznych. Nie kontaktuj się z klientami,
nie wykonuj HTML z danych testowych i nie zmieniaj rekordów produkcyjnych dla testu.
Żądanie samego raportu kończy się raportem; bez zbędnego trwałego procesu lub przełącznika demonstracyjnego.
