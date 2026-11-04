---
description: >-
  Projektuj głębokie moduły z małymi interfejsami. Używaj przy wyborze szwów,
  ograniczaniu konieczności przeskakiwania między plikami, pogłębianiu modułów,
  testowaniu interfejsów oraz stosowaniu wspólnego słownictwa projektowego.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - codebase design
sidebar:
  label: /codebase-design
title: /codebase-design
type: skill
---
![Diagram umiejętności /codebase-design](/diagrams/skills/codebase-design.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/codebase-design.excalidraw)

Przy zmianach interfejsów, typów lub współdzielonego stanu przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#design).

Gdy poniższy przepływ wymaga umiejętności wywoływanej przez model, wywołaj narzędzie Skill osobno dla każdej z nich. Na hostach bez tego narzędzia przeczytaj pełny kanoniczny `SKILL.md`, zgodnie z [zasadami ładowania zależności](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies). Umiejętności wywoływane tylko przez użytkownika polecaj człowiekowi; nie uruchamiaj ich automatycznie.

Korzystaj z `GLOSSARY.md` i odpowiednich ADR-ów. Jeśli istnieje `GLOSSARY-MAP.md`, przejdź z niego do glosariusza właściwego kontekstu.

Projektuj **głębokie moduły**: dużo zachowań za małym interfejsem w dobrze dobranym szwie, możliwych do przetestowania przez ten interfejs. Stosuj [weryfikowalność zamiast czytelności](https://github.com/malinskibeniamin/skills/blob/main/shared/verifiability.md); optymalizuj niezależną weryfikację, użyteczność dla wywołujących i lokalność, a nie rozmiar implementacji.

Moduł powinien ograniczać wiedzę i koordynację wymaganą od kodu wywołującego, zachowując wymagane zachowanie.

## Słownik [#glossary]

Używaj dokładnie tych terminów:

**Moduł** -- interfejs wraz z implementacją: funkcja, klasa, pakiet, wycinek.

**Interfejs** -- wszystko, co musi wiedzieć kod wywołujący: typy, niezmienniki, kolejność, błędy, konfiguracja, wydajność; pojęcie szersze niż sygnatura.

**Implementacja** -- wnętrze modułu.

**Głębokość** -- użyteczność zapewniana przez interfejs. **Głęboki** oznacza mały interfejs i dużo zachowań; **płytki** oznacza podobną złożoność interfejsu i implementacji.

**Szew** -- miejsce, w którym zachowanie może się zmieniać bez edytowania kodu wywołującego; tam znajduje się jego interfejs. Unikaj: granica, chyba że masz na myśli ograniczony kontekst DDD.

**Adapter** -- konkretna implementacja w szwie, nazwana według roli.

**Użyteczność** -- możliwości na każdy poznany interfejs.

**Lokalność** -- zmiany, błędy, wiedza i weryfikacja skupiają się w jednym miejscu.

Zapytaj, czy można ograniczyć liczbę metod i parametrów oraz ukryć więcej złożoności.

## Zasady [#principles]

- Głębokość jest właściwością interfejsu, a nie stosunkiem liczby wierszy; prywatne szwy nie muszą być ujawniane.
- **Test usunięcia:** jeśli usunięcie modułu sprawia, że złożoność znika, moduł był tylko warstwą pośrednią; jeśli złożoność rozprzestrzenia się na kod wywołujący lub testy, moduł zasłużył na swoje miejsce.
- **Interfejs jest powierzchnią testową:** kod wywołujący i testy przekraczają ten sam szew. Testowanie poza nim wskazuje na niewłaściwą strukturę.
- **Jeden adapter oznacza hipotetyczny szew; dwa adaptery oznaczają rzeczywisty szew.**
- Bezpośredni kod lokalny jest lepszy niż abstrakcja, która jedynie przenosi kod.

## Szkic od strony wywołującego [#caller-first-sketch]

Dla nowego lub zmienianego interfejsu napisz reprezentatywny kod wywołujący przed typami i sygnaturami: jeden sukces oraz jedną wiarygodną porażkę lub odmowę. Wskaż właściciela stanu, chroniony niezmiennik i to, co kod wywołujący obserwuje przy błędzie. Wykorzystaj istniejące typy domenowe; wyprowadź najmniejszy interfejs z tych wywołań, zamiast ujawniać wewnętrzne etapy.

Przed wyborem struktury sprawdź wobec szkicu [najkrótszą błędną zmianę](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-ENGINEERING.md#probe-the-shortest-wrong-edit). Przy małej zmianie wystarczy szkic w bieżącym opisie; mechaniczne przeniesienia nie wymagają ćwiczenia projektowego. Porównuj całe alternatywne struktury tylko wtedy, gdy pozostaje istotna decyzja lub użytkownik tego zażąda. Nie dodaje to przerwy przed implementacją.

## Testowalność [#testability]

1. Sprawdzaj publiczny interfejs za pomocą ukierunkowanego polecenia i powtarzalnych danych testowych.
2. Kontroluj istotne zależności w istniejących szwach; zwracaj obserwowalne wyniki i izoluj stan otoczenia.
3. Ułatwiaj znalezienie niezmienników i diagnostyki błędów; wykaż, że wiarygodne niepoprawne zachowanie powoduje niepowodzenie testu, bez wiązania testów z wnętrzem implementacji.

Gdy dwa projekty przejdą test usunięcia, użyj `/plan-arbiter`, aby porównać głębokość, lokalność, powierzchnię testową i możliwość wycofania zmian.

Relacje: Moduł ma jeden Interfejs; Głębokość mierzy się względem niego; Szew go zawiera; Adapter go spełnia; Głębokość tworzy Użyteczność i Lokalność.

Odrzuć głębokość mierzoną liczbą wierszy, interfejs rozumiany jako słowo kluczowe TypeScript oraz nieprecyzyjne użycie terminu granica.

Przeczytaj [DEEPENING.md](https://github.com/malinskibeniamin/skills/blob/main/codebase-design/DEEPENING.md), aby poznać zasady dotyczące zależności, szwów i testowania, oraz [DESIGN-IT-TWICE.md](https://github.com/malinskibeniamin/skills/blob/main/codebase-design/DESIGN-IT-TWICE.md), aby poznać równoległe projekty.
