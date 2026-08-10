---
title: /teach
description: Naucz użytkownika nowej umiejętności lub koncepcji w tym obszarze roboczym.
type: skill
sidebar:
  label: /teach
---
![Diagram umiejętności /teach](/diagrams/skills/teach.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/teach.excalidraw)

Obszar roboczy do nauki z zachowaniem stanu. Bieżący katalog przechowuje stan nauki.

## Pliki obszaru roboczego

- `MISSION.md` -- dlaczego użytkownik uczy się danego tematu. Format: [MISSION-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/MISSION-FORMAT.md).
- `RESOURCES.md` -- zaufane źródła stanowiące podstawę nauczania. Format: [RESOURCES-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/RESOURCES-FORMAT.md).
- `reference/*.html` -- materiały pomocnicze do druku, glosariusze, algorytmy, składnia i procedury.
- `learning-records/*.md` -- potwierdzone postępy w nauce i wcześniejsza wiedza. Format: [LEARNING-RECORD-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/LEARNING-RECORD-FORMAT.md).
- `lessons/*.html` -- jedna samodzielna lekcja na plik.
- `assets/*` -- komponenty wielokrotnego użytku: arkusze stylów, widżety quizów, symulatory i narzędzia do tworzenia diagramów.
- `NOTES.md` -- preferencje użytkownika i notatki robocze.

## Najpierw misja

Jeśli brakuje pliku `MISSION.md` lub jego treść jest niejasna, przed rozpoczęciem nauczania przeprowadź rozmowę z użytkownikiem. Przejdź od abstrakcyjnego celu do konkretnego rezultatu. Jeden obszar roboczy powinien mieć jedną misję.
Jeśli misja się zmieni, najpierw uzyskaj potwierdzenie, zaktualizuj plik `MISSION.md` i zapisz postęp w nauce.

## Dyscyplina źródeł

Dopóki plik `RESOURCES.md` nie zawiera solidnych podstaw, wyszukuj wiarygodne źródła. Nigdy nie polegaj wyłącznie na wiedzy parametrycznej. Lekcje muszą zawierać cytowania oraz ścieżki do dalszej nauki.

## Zasady lekcji

Lekcja:

- uczy tylko jednej rzeczy
- jest bezpośrednio powiązana z misją
- mieści się w strefie najbliższego rozwoju użytkownika
- jest szybka do ukończenia
- zapewnia wymierny efekt
- wykorzystuje interaktywne zadanie, quiz lub listę kroków do wykonania w praktyce
- obejmuje krótką pętlę informacji zwrotnej, najlepiej automatyczną lub natychmiastową
- wzmacnia trwałość wiedzy zamiast płynności jej odtwarzania: aktywne przypominanie, rozłożenie nauki w czasie i przeplatanie tematów
- unika podpowiedzi w quizach: w miarę możliwości odpowiedzi mają podobną liczbę słów i nie zawierają wskazówek wynikających z formatowania
- zawiera linki do powiązanych lekcji i dokumentów referencyjnych z kotwicami HTML
- poleca jedno główne źródło do dalszej nauki
- przypomina użytkownikowi, że może zadawać dodatkowe pytania
- jest zapisywana jako `lessons/NNNN-dash-case.html`
- jest przejrzysta, czytelna i nadaje się do druku

Ułatw otwieranie lekcji, najlepiej za pomocą jednego polecenia CLI.

## Zasoby

Domyślnie wykorzystuj ponownie istniejące elementy. Przed utworzeniem lekcji zapoznaj się z zawartością `./assets/` i korzystaj z istniejących komponentów. Jeśli lekcja wymaga kodu lub stylu wielokrotnego użytku, przenieś go do `./assets/` i dodaj do niego odnośnik; nigdy nie osadzaj w lekcji elementów, które będą później powielane. Pierwszym komponentem powinien być zazwyczaj współdzielony arkusz stylów.

## Strefa najbliższego rozwoju

Przed wyborem kolejnej lekcji:

1. przeczytaj `learning-records/`
2. przeczytaj `NOTES.md`
3. sprawdź misję
4. wybierz najbliższe przydatne wyzwanie

Jeśli użytkownik mówi, że już coś wie, zapisz poziom tej wiedzy w rejestrze nauki.

## Rejestry nauki

Zapisuj postęp tylko wtedy, gdy użytkownik wykaże zrozumienie, ujawni wcześniejszą wiedzę, skoryguje błędne przekonanie lub zmieni się misja. Samo omówienie materiału nie oznacza jego opanowania.

## Dokumenty referencyjne

Twórz materiały referencyjne, gdy temat można skutecznie przedstawić w postaci skróconej składni, procedur, algorytmów,
póz, ćwiczeń lub glosariusza. Użyj [GLOSSARY-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/GLOSSARY-FORMAT.md); dodawaj terminy
dopiero wtedy, gdy użytkownik je rozumie.

## Wiedza praktyczna i społeczność

Jeśli pytanie wymaga praktycznego osądu, udziel wstępnej odpowiedzi, a następnie zaproponuj renomowaną społeczność, kurs, forum lub źródło prowadzone przez praktyka. Uszanuj decyzję użytkownika, jeśli odmówi.

## Notatki

W pliku `NOTES.md` zapisuj preferencje: tempo, przykłady, ton, potrzeby w zakresie dostępności, niepożądane formaty i ograniczenia dotyczące ćwiczeń. Przeczytaj go przed przygotowaniem kolejnych lekcji.
