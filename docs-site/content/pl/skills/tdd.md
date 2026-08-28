---
title: /tdd
description: >-
  Programuj w cyklu czerwony–zielony–refaktoryzacja. Używaj podczas pisania
  testów, tworzenia funkcji, naprawiania błędów, projektowania punktów styku do
  testów, zapobiegania wyciekom operacji asynchronicznych lub zastępowania
  oczekiwania przez określony czas.
type: skill
sidebar:
  label: /tdd
---
![Diagram umiejętności /tdd](/diagrams/skills/tdd.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/tdd.excalidraw)


TDD chroni istotne zachowanie. Stosuj RED -> GREEN -> REFACTOR w przypadku zmienionych reguł domenowych, rozgałęzień, stanów, parsowania, walidacji, efektów asynchronicznych i kontraktów integracji. Typy, reeksporty, połączenia, statyczne teksty i style oraz usuwanie niezmieniające zachowania mogą wymagać ukierunkowanej weryfikacji. Pokrycie może ujawnić przeoczenie, ale nigdy nie jest celem.

## Punkty styku do testów i antywzorce

- **Punkty styku:** testuj na publicznych granicach. Najpierw nazwij punkt styku; potwierdź z użytkownikiem wcześniej uzgodnione punkty, jeśli problem i konwencja nie wskazują ich jednoznacznie. Nie testuj niepotwierdzonych elementów wewnętrznych. Użyj `/codebase-design`, zamiast wymyślać punkt styku dla wygody.
- **Testy tautologiczne:** oczekiwane wartości wymagają niezależnego źródła prawdy: literału, rozwiązanego przykładu, danych testowych, specyfikacji lub obserwacji.
- **Przybliżenia oparte na tekście źródłowym:** usuń testy, które odczytują kod implementacji, CSS, znaczniki lub konfigurację i traktują asercje dotyczące tokenów lub wyrażeń regularnych jako dowód zachowania w czasie działania. Zastąp je testami publicznego punktu styku, gdy zachowanie ma znaczenie; użyj analizy statycznej, gdy kontraktem jest składnia. Zachowaj asercje treści tylko wtedy, gdy plik lub zserializowany tekst sam jest publicznym wynikiem.
- **Przekroje pionowe:** stosuj przekroje pionowe: za każdym razem jeden test RED i implementacja GREEN; testy tworzone zbiorczo utrwalają wyobrażone zachowanie.

## Przebieg pracy

### Kontrakt

- Nazwij obserwowalne zachowanie publicznego interfejsu; stosuj słownik domenowy projektu i ADR-y.
- Wybierz najmniejszy test, który zakończy się niepowodzeniem, gdy zachowanie przestanie działać. Dodawaj przypadki tylko dla niezależnych, wiarygodnych ryzyk.
- Dla niezmienników obejmujących wejścia o dużej liczbie możliwych wartości lub sekwencje stanów przeczytaj [PROPERTY-BASED-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/PROPERTY-BASED-TESTING.md); wymagaj niezależnej wyroczni i możliwości odtworzenia.
- Dla czasu życia zasobów na długo działających stronach przeglądarkowych użyj powtarzalnych pełnych cykli i przeczytaj [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SOAK-TESTING.md); nowe konteksty nie ujawnią kumulacji.
- Użyj `/read-the-damn-docs` dla kontraktów zewnętrznych oraz [tests.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/tests.md), gdy forma testu jest niejasna.

### RED

Napisz jeden test zachowania i sprawdź, czy kończy się niepowodzeniem z zamierzonego powodu. Preferuj rzeczywiste publiczne interfejsy; stosuj atrapy tylko dla niedostępnych zewnętrznych granic.

### GREEN

Napisz najmniejszą implementację, która przechodzi test. Najpierw usuń lub wykorzystaj ponownie, a następnie wybieraj język, platformę lub zainstalowaną zależność. Naśladuj konwencje odpowiedniego pliku w `exemplars/`, a nie jego rozmiar.

### REFACTOR

Poprawiaj nazwy i strukturę tylko dla większej przejrzystości lub usunięcia rzeczywistej duplikacji. Utrzymuj stan zielony; nigdy nie osłabiaj asercji. Oznacz testy jednostkowe trwające ponad 500 ms i testy integracyjne trwające ponad 2 s; preferuj zbiorcze dane wejściowe zamiast symulowania każdego naciśnięcia klawisza. Uruchom `/dogfood` dla istotnych zielonych przekrojów; usterki stają się RED.

### POWTÓRZENIE

Powtórz tylko dla kolejnego kontraktu lub niezależnego, wiarygodnego ryzyka. Podczas aktywnej pracy używaj `vitest --watch`, oczekiwania opartego na warunkach oraz `--detectAsyncLeaks` dla nowych operacji asynchronicznych.

## Regresja wizualna

Gdy nieobjęte testami zachowanie trasy widoczne dla klienta używa `@vitest/browser`, dodaj najmniejszy użyteczny test `*.browser.test.tsx`; pomiń trasy związane z układem, przekierowaniem i czysto deklaratywne.

## Po zakończeniu

Odpowiednie testy przechodzą bez ostrzeżeń; operacje asynchroniczne nie pozostawiają wycieków ani oczekiwania przez określony czas; testy pozostają poprawne po refaktoryzacji elementów wewnętrznych; żaden przypadek nie istnieje wyłącznie dla pokrycia. Zobacz [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/REFERENCE.md), aby poznać oczekiwanie oparte na warunkach, selektory, portale, atrapy, diagnostykę i przykłady odporności.
