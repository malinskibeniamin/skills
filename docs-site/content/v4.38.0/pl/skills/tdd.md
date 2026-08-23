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

TDD chroni istotne zachowanie; nie jest kosztem nakładanym na każdy zmieniony plik.

Stosuj RED -> GREEN -> REFACTOR w przypadku błędów, regresji oraz nowych lub zmienionych
kontraktów: reguł domenowych, rozgałęzień, przejść stanów, parsowania, walidacji,
efektów asynchronicznych i zachowania integracji, których awaria ma znaczenie. Typy,
reeksporty, deklaratywne połączenia, statyczne teksty i style oraz usuwanie
niezmieniające zachowania mogą wymagać jedynie istniejącej, ukierunkowanej weryfikacji.

Pokrycie może ujawnić podejrzewaną lukę. Nigdy nie jest celem ani powodem
do wymyślania testów.

## Punkty styku do testów i antywzorce

- **Punkty styku**: testuj na publicznych granicach. Przed napisaniem testu określ punkt styku i potwierdź z użytkownikiem wcześniej uzgodnione punkty, jeśli problem lub istniejąca konwencja nie wskazują ich jednoznacznie. Nie testuj niepotwierdzonych elementów wewnętrznych.
- **Testy tautologiczne**: nie wyliczaj oczekiwanych wartości w taki sam sposób jak kod; użyj niezależnego źródła prawdy: sprawdzonego literału, rozwiązanego przykładu, danych testowych, specyfikacji lub zaobserwowanego zachowania.
- **Przekroje poziome**: nie pisz najpierw wszystkich testów, a potem całej implementacji. Testy tworzone zbiorczo sprawdzają wyobrażone zachowanie. Poprawnie: przekroje pionowe — jeden test i implementacja RED->GREEN, a następnie powtórzenie cyklu.

Jeśli sam publiczny punkt styku jest niejasny, użyj `/codebase-design`; nie wymyślaj
wewnętrznego punktu styku dla wygody testowania.

## Przebieg pracy

### 0. Kontrakt

- Nazwij obserwowalne zachowanie publicznego interfejsu. Stosuj słownik domenowy projektu i ADR-y.
- Wybierz najmniejszy test, który zakończyłby się niepowodzeniem, gdyby to zachowanie przestało działać. Jeden test może obejmować wiele wierszy.
- Dodaj kolejny przypadek tylko dla niezależnego, wiarygodnego ryzyka, a nie dla każdej możliwej sytuacji brzegowej.
- Gdy jedna niezmiennicza reguła obejmuje wejścia o dużej liczbie możliwych wartości lub osiągalne sekwencje stanów, przeczytaj
  [o testowaniu opartym na właściwościach](https://github.com/malinskibeniamin/skills/blob/v4.38.0/tdd/PROPERTY-BASED-TESTING.md). Wymagaj niezależnej wyroczni i odtwarzalnych niepowodzeń.
- Dla kontraktu czasu życia zasobu na długo działającej stronie przeglądarkowej użyj powtarzalnego
  pełnego cyklu i przeczytaj [o testach długotrwałych SPA](https://github.com/malinskibeniamin/skills/blob/v4.38.0/e2e-testing/SOAK-TESTING.md). Nowy
  kontekst przeglądarki nie ujawni kumulacji między interakcjami.
- Jeśli zachowanie zewnętrznego rozwiązania definiuje kontrakt, użyj `/read-the-damn-docs`.
- Przeczytaj [tests.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/tdd/tests.md), gdy punkt styku lub forma testu są niejasne.

### 1. RED

- Napisz jeden test zachowania i sprawdź, czy kończy się niepowodzeniem z zamierzonego powodu.
- Preferuj rzeczywiste publiczne interfejsy; stosuj atrapy tylko dla zewnętrznych granic, których nie można uruchomić lokalnie.

### 2. GREEN

- Napisz najmniejszą oczywistą implementację, która przechodzi test.
- Najpierw usuń lub wykorzystaj ponownie; następnie wybieraj język, platformę lub zainstalowaną zależność zamiast własnych mechanizmów.
- Naśladuj przejrzystość i konwencje odpowiedniego pliku w `exemplars/`, a nie jego rozmiar.

### 3. REFACTOR

- Poprawiaj nazwy i strukturę tylko wtedy, gdy znaczenie staje się wyraźniejsze lub znika rzeczywista duplikacja.
- Utrzymuj stan zielony. Nigdy nie osłabiaj asercji zachowania tylko po to, aby test przeszedł.
- Oznacz testy jednostkowe trwające ponad 500 ms i testy integracyjne trwające ponad 2 s; preferuj zbiorcze dane wejściowe zamiast symulowania każdego naciśnięcia klawisza.
- Uruchom `/dogfood` dla istotnego zachowania, które można uruchomić; zaobserwowane usterki stają się kolejnym RED.

### 4. POWTÓRZENIE

Powtórz tylko dla kolejnego wymaganego kontraktu lub niezależnego, wiarygodnego ryzyka.

Podczas aktywnej pracy monitoruj `vitest --watch`. Używaj oczekiwania opartego na warunkach oraz
`--detectAsyncLeaks`, gdy zmiana tworzy pracę asynchroniczną.

## Klasyfikacja testów

| Sufiks | Cel | DOM? |
|--------|---------|------|
| `.test.ts` | Jednostkowy — czysta logika | Nie |
| `.test.tsx` / `.integration.tsx` | Integracyjny — renderowanie komponentów | Tak |
| `e2e/*.spec.ts` | E2E — przeglądarka Playwright | Przeglądarka |

## Testy regresji wizualnej

Gdy trasa dodaje zachowanie widoczne dla klienta, które nie jest jeszcze objęte testami, a projekt
używa `@vitest/browser`, dodaj najmniejszy użyteczny test `*.browser.test.tsx`. Pomiń
trasy związane z układem, przekierowaniem i czysto deklaratywne.

## Po zakończeniu

- Odpowiednie testy przechodzą bez ostrzeżeń.
- Zmiany asynchroniczne nie pozostawiają trwających operacji ani oczekiwania przez określony czas.
- Testy pozostają poprawne po refaktoryzacji elementów wewnętrznych, ponieważ weryfikują zachowanie, a nie implementację.
- Nie ma zbędnego przypadku istniejącego wyłącznie po to, aby zwiększyć pokrycie.

Zobacz [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/tdd/REFERENCE.md), aby poznać oczekiwanie oparte na warunkach, selektory,
portale, atrapy, diagnostykę i ukierunkowane przykłady odporności.
