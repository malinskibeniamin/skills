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

Projektuj **głębokie moduły**: dużo zachowań za małym interfejsem umieszczonym w dobrze dobranym szwie, możliwych do przetestowania przez ten interfejs. Cel: duża użyteczność dla wywołujących, lokalność dla osób utrzymujących kod oraz testowalność dla agentów i ludzi.

Głębokość musi już teraz zwiększać gęstość semantyczną. Nie twórz modułu, szwu, adaptera
ani interfejsu z myślą o hipotetycznym ponownym użyciu. Projekt jest udany tylko wtedy, gdy usuwa
z kodu wywołującego więcej wiedzy i potrzeby koordynacji, niż sam wprowadza.

## Słownik

Używaj dokładnie tych terminów; unikaj luźnych synonimów.

**Moduł** -- wszystko, co ma interfejs i implementację: funkcja, klasa, pakiet, wycinek. Unikaj: jednostka, komponent, usługa.

**Interfejs** -- wszystko, co musi wiedzieć kod wywołujący: powierzchnia typów, niezmienniki, kolejność, błędy, konfiguracja, wydajność. Unikaj: API lub sygnatura, gdy masz na myśli pełny kontrakt.

**Implementacja** -- to, co znajduje się wewnątrz modułu. Różni się od **Adaptera**: adapter jest konkretnym elementem wypełniającym szew.

**Głębokość** -- użyteczność zapewniana przez interfejs. **Głęboki** = mały interfejs, dużo zachowań. **Płytki** = interfejs niemal tak złożony jak implementacja.

**Szew** -- miejsce, w którym zachowanie może się zmieniać bez edytowania tego miejsca; tam znajduje się interfejs modułu. Unikaj: granica, termin przeciążony znaczeniem ograniczonego kontekstu DDD.

**Adapter** -- konkretna implementacja spełniająca interfejs w szwie; nazwa określa rolę, nie tworzywo.

**Użyteczność** -- kod wywołujący otrzymuje więcej możliwości na każdy poznany interfejs.

**Lokalność** -- zmiany, błędy, wiedza i weryfikacja skupiają się w jednym miejscu.

## Głębokie a płytkie

Głęboki moduł:

```
Small Interface
----------------
Deep Implementation
```

Płytki moduł:

```
Large Interface
----------------
Thin Implementation
```

Zapytaj:

- Czy można ograniczyć liczbę metod?
- Czy można uprościć parametry?
- Czy można ukryć więcej złożoności wewnątrz?

## Zasady

- **Głębokość jest właściwością interfejsu, a nie rozmiaru implementacji.** Wnętrze może zawierać prywatne szwy; kod wywołujący nie musi ich znać.
- **Test usunięcia.** Jeśli usunięcie modułu sprawia, że złożoność znika, moduł był tylko warstwą pośrednią. Jeśli złożoność pojawia się ponownie w kodzie wywołującym lub testach, moduł zasłużył na swoje miejsce.
- **Interfejs jest powierzchnią testową.** Kod wywołujący i testy przekraczają ten sam szew. Testowanie poza nim zwykle oznacza niewłaściwą strukturę.
- **Jeden adapter oznacza hipotetyczny szew. Dwa adaptery oznaczają rzeczywisty szew.** Nie dodawaj szwów dla wyobrażonej zmienności.
- **Bezpośredniość to również projekt.** Małe lokalne wyrażenie jest lepsze niż abstrakcja, która jedynie przenosi kod.

## Projektowanie pod kątem testowalności

1. Przyjmuj zależności; nie twórz ich wewnątrz.
2. Zwracaj wyniki, gdy jest to możliwe; ograniczaj niejawne efekty uboczne.
3. Utrzymuj małą powierzchnię: mniej metod, mniej parametrów, jaśniejsze niezmienniki.

Gdy dwa sensowne projekty modułu lub interfejsu przejdą test usunięcia, użyj `/plan-arbiter`, aby przed wyborem jednego z nich porównać głębokość, lokalność, powierzchnię testową i możliwość wycofania zmian.

## Relacje

- Moduł ma jeden Interfejs.
- Głębokość mierzy się względem Interfejsu.
- Szew to miejsce, w którym znajduje się Interfejs.
- Adapter znajduje się w Szwie i spełnia Interfejs.
- Głębokość tworzy Użyteczność i Lokalność.

## Odrzucone ujęcia

- Głębokość jako stosunek liczby wierszy implementacji do liczby wierszy interfejsu: premiuje sztuczne rozbudowywanie kodu.
- Interfejs wyłącznie jako TypeScript `interface` lub metody publiczne: zbyt wąskie ujęcie.
- Granica: używaj terminu szew lub interfejs, chyba że masz na myśli ograniczony kontekst DDD.

## Materiały referencyjne

- [DEEPENING.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/codebase-design/DEEPENING.md) -- kategorie zależności, dyscyplina stosowania szwów, testowanie przez zastępowanie zamiast nakładania warstw.
- [DESIGN-IT-TWICE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/codebase-design/DESIGN-IT-TWICE.md) -- równoległe projekty interfejsów, porównanie pod względem głębokości, lokalności i umiejscowienia szwów.
