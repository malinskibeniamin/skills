---
title: /codebase-design
description: >-
  Projektuj głębokie moduły z małymi interfejsami. Używaj przy wyborze szwów,
  ograniczaniu konieczności przeskakiwania między plikami, pogłębianiu modułów,
  testowaniu interfejsów oraz stosowaniu wspólnego słownictwa projektowego.
type: skill
sidebar:
  label: /codebase-design
---
![Diagram umiejętności /codebase-design](/diagrams/skills/codebase-design.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/codebase-design.excalidraw)


Projektuj **głębokie moduły**: dużo zachowań za małym interfejsem umieszczonym w dobrze dobranym szwie, możliwych do przetestowania przez ten interfejs. Optymalizuj użyteczność dla wywołujących, lokalność dla osób utrzymujących kod oraz testowalność.

Głębokość musi już teraz zwiększać gęstość semantyczną. Nie twórz modułów, szwów, adapterów ani interfejsów z myślą o hipotetycznym ponownym użyciu. Projekt jest udany tylko wtedy, gdy usuwa z kodu wywołującego więcej wiedzy i potrzeby koordynacji, niż sam wprowadza.

## Słownik

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

## Zasady

- Głębokość jest właściwością interfejsu, a nie stosunkiem liczby wierszy; prywatne szwy nie muszą być ujawniane.
- **Test usunięcia:** jeśli usunięcie modułu sprawia, że złożoność znika, moduł był tylko warstwą pośrednią; jeśli złożoność rozprzestrzenia się na kod wywołujący lub testy, moduł zasłużył na swoje miejsce.
- **Interfejs jest powierzchnią testową:** kod wywołujący i testy przekraczają ten sam szew. Testowanie poza nim wskazuje na niewłaściwą strukturę.
- **Jeden adapter oznacza hipotetyczny szew; dwa adaptery oznaczają rzeczywisty szew.**
- Bezpośredni kod lokalny jest lepszy niż abstrakcja, która jedynie przenosi kod.

## Testowalność

1. Przyjmuj zależności; nie twórz ich wewnątrz.
2. Zwracaj wyniki; ograniczaj niejawne efekty uboczne.
3. Utrzymuj niewiele metod i parametrów oraz jasne niezmienniki.

Gdy dwa projekty przejdą test usunięcia, użyj `/plan-arbiter`, aby porównać głębokość, lokalność, powierzchnię testową i możliwość wycofania zmian.

Relacje: Moduł ma jeden Interfejs; Głębokość mierzy się względem niego; Szew go zawiera; Adapter go spełnia; Głębokość tworzy Użyteczność i Lokalność.

Odrzuć głębokość mierzoną liczbą wierszy, interfejs rozumiany jako słowo kluczowe TypeScript oraz nieprecyzyjne użycie terminu granica.

Przeczytaj [DEEPENING.md](https://github.com/malinskibeniamin/skills/blob/main/codebase-design/DEEPENING.md), aby poznać zasady dotyczące zależności, szwów i testowania, oraz [DESIGN-IT-TWICE.md](https://github.com/malinskibeniamin/skills/blob/main/codebase-design/DESIGN-IT-TWICE.md), aby poznać równoległe projekty.
W kwestiach obciążenia czytelnika, egzekwowania struktury i integracji opartej na pierwszych zasadach używaj wspólnych
[reguł inżynieryjnych Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-ENGINEERING.md), zamiast powielać je tutaj.
