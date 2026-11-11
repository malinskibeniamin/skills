---
description: >-
  Programuj w cyklu czerwony–zielony–refaktoryzacja. Używaj podczas pisania
  testów, tworzenia funkcji, naprawiania błędów, projektowania punktów styku do
  testów, zapobiegania wyciekom operacji asynchronicznych lub zastępowania
  oczekiwania przez określony czas.
related:
  - /skills/development-lifecycle
  - /skills/review
search:
  boost: 3
  keywords:
    - tdd
    - test driven development
    - red green refactor
sidebar:
  label: /tdd
title: /tdd
type: skill
---
![Diagram umiejętności /tdd](/diagrams/skills/tdd.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/tdd.excalidraw)

Przy weryfikowaniu zmienionego zachowania lub utrzymaniu weryfikacji przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/POTETO-NATIVE.md#verification).

Gdy poniższy przepływ wymaga umiejętności wywoływanej przez model, wywołaj narzędzie Skill osobno dla każdej z nich. Na hostach bez tego narzędzia przeczytaj pełny kanoniczny `SKILL.md`, zgodnie z [zasadami ładowania zależności](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies). Umiejętności wywoływane tylko przez użytkownika polecaj człowiekowi; nie uruchamiaj ich automatycznie.

Korzystaj z `GLOSSARY.md` i odpowiednich ADR-ów. Jeśli istnieje `GLOSSARY-MAP.md`, przejdź z niego do glosariusza właściwego kontekstu.

Dla testów T3 lub Effect ustal [kontekst natywny](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/T3CODE-NATIVE.md#resolve-context) z punktem wejścia `tdd`; przestrzegaj kontraktów projektu dotyczących zegara, procesów roboczych i cyklu życia renderowania.


Stosuj [weryfikację proporcjonalną do ryzyka](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/verifiability.md#proportionate-verification). Używaj RED -> GREEN -> REFACTOR, gdy wiarygodna regresja wymaga nowego pokrycia; wykorzystuj istniejące kontrole dla już pokrytych zachowań, typów, połączeń, tekstów, stylów i usuwania niezmieniającego zachowania. Nie każda edycja ani wywołanie zależności wymaga nowego testu. Pokrycie nigdy nie jest celem.

Przy każdym proponowanym punkcie testowania podaj, jakie błędy wykrywa i jakie pomija.

## Punkty styku do testów i antywzorce [#test-seams-and-anti-patterns]

- **Punkty styku:** testuj na publicznych granicach. Najpierw nazwij punkt styku; potwierdź z użytkownikiem wcześniej uzgodnione punkty, jeśli problem i konwencja nie wskazują ich jednoznacznie. Nie testuj niepotwierdzonych elementów wewnętrznych. Użyj `/codebase-design`, zamiast wymyślać punkt styku dla wygody.
- **Testy tautologiczne:** oczekiwane wartości wymagają niezależnego źródła prawdy: literału, rozwiązanego przykładu, danych testowych, specyfikacji lub obserwacji.
- **Ponowne testowanie zależności:** ufaj udokumentowanym narzędziom bibliotek; testuj nasze decyzje domenowe i założenia integracji tylko wtedy, gdy wnoszą odrębne ryzyko. Rozszerzaj istniejące pokrycie zamiast powtarzać ten sam kontrakt w kolejnych warstwach.
- **Przybliżenia oparte na tekście źródłowym:** usuń testy, które przeszukują implementację, CSS, znaczniki lub konfigurację pod kątem tokenów lub wyrażeń regularnych i traktują je jako dowód zachowania w czasie działania. Zastąp je testami publicznego punktu styku, gdy zachowanie ma znaczenie; użyj analizy statycznej dla składni. Zachowaj asercje treści tylko dla publicznych wyników.
- **Przekroje pionowe:** stosuj przekroje pionowe: za każdym razem jeden test RED i implementacja GREEN; testy tworzone zbiorczo utrwalają wyobrażone zachowanie.

## Przebieg pracy [#workflow]

### Kontrakt [#contract]

- Nazwij publiczne zachowanie; stosuj słownik domenowy projektu i ADR-y.
- Wybierz najmniejszy test, który zakończy się niepowodzeniem, gdy zachowanie przestanie działać; nowe lub zmienione testy muszą spełniać [kryteria tworzenia testów](https://github.com/malinskibeniamin/skills/blob/v4.45.0/test-audit/SKILL.md#authoring-gate).
- Dla niezmienników obejmujących wejścia o dużej liczbie możliwych wartości lub sekwencje stanów przeczytaj [PROPERTY-BASED-TESTING.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/tdd/PROPERTY-BASED-TESTING.md); wymagaj niezależnej wyroczni i możliwości odtworzenia.
- Dla czasu życia zasobów na długo działających stronach przeglądarkowych użyj powtarzalnych pełnych cykli i [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/e2e-testing/SOAK-TESTING.md); nowe konteksty nie ujawnią kumulacji.
- Użyj `/read-the-damn-docs` dla kontraktów zewnętrznych oraz [tests.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/tdd/tests.md), gdy forma testu jest niejasna.

### RED

Napisz jeden test zachowania i sprawdź, czy kończy się niepowodzeniem z zamierzonego powodu. Używaj publicznych interfejsów; stosuj atrapy tylko dla niedostępnych zewnętrznych granic.

### GREEN

Napisz najmniejszą implementację, która przechodzi test. Najpierw usuń lub wykorzystaj ponownie, a następnie wybieraj język, platformę lub zainstalowaną zależność. Naśladuj konwencje odpowiedniego pliku w `exemplars/`, a nie jego rozmiar.

### REFACTOR

Stosuj [weryfikowalność zamiast czytelności](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/verifiability.md): ulepszaj niezależne sprawdzenia, nazwy domenowe, własność stanu lub zmierzoną wydajność, a nie wskaźniki rozmiaru lub złożoności. Utrzymuj stan zielony; nigdy nie osłabiaj asercji. Oznacz testy jednostkowe trwające ponad 500 ms i testy integracyjne trwające ponad 2 s; preferuj zbiorcze dane wejściowe zamiast symulowania każdego naciśnięcia klawisza. Wywołaj narzędzie Skill z nazwą "dogfood" dla istotnych zielonych przekrojów; usterki stają się RED.

### POWTÓRZENIE [#repeat]

Powtórz tylko dla kolejnego kontraktu lub niezależnego, wiarygodnego ryzyka. Podczas aktywnej pracy używaj `vitest --watch`, oczekiwania opartego na warunkach oraz `--detectAsyncLeaks` dla nowych operacji asynchronicznych.

## Regresja wizualna [#visual-regression]

Dla ryzyk wizualnych wykorzystuj właściwe przypadki w istniejącym narzędziu do asercji zrzutów; sprawdzaj zamierzone aktualizacje i uruchamiaj testy ponownie w normalnym trybie. Dodawaj przypadek tylko dla wiarygodnej regresji bez pokrycia. Drobne zmiany tekstów lub stylów wymagają inspekcji, a nie automatycznie nowych migawek lub narzędzia. Używaj [dowodów wizualnych PR](https://github.com/malinskibeniamin/skills/blob/v4.45.0/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5), gdy porównanie pomaga w przeglądzie lub jest wymagane. Niewidoczne zmiany nie wymagają zrzutów.

## Po zakończeniu [#done]

Testy przechodzą bez ostrzeżeń, wycieków operacji asynchronicznych ani oczekiwania przez określony czas; pozostają poprawne po refaktoryzacji. Zobacz [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/tdd/REFERENCE.md), aby poznać oczekiwanie, selektory, portale, atrapy, diagnostykę i przykłady odporności.

Gdy kryteria akceptacji obejmują inferencję, przypisywalność, przeciążenia lub sposób wyświetlania typów, wczytaj [tworzenie testów](https://github.com/malinskibeniamin/skills/blob/v4.45.0/t3code-skills/test-development/SKILL.md). Regresje wykonania nadal wymagają testów wykonania; zwykłe deklaracje wymagają sprawdzenia typów.
