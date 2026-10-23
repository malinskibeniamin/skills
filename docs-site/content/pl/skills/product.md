---
description: >-
  Dbaj o wartość biznesową pracy: jeden obszar, odbiorca, dlaczego teraz,
  dowody, dostępność, najmniejszy odwracalny zakres. Stosuj przy każdym PR-ze,
  planie, automatycznym przeglądzie lub kontroli odchodzenia od celu.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - product
sidebar:
  label: /product
title: /product
type: skill
---
![Diagram umiejętności /product](/diagrams/skills/product.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/product.excalidraw)

Czy ta zmiana jest warta swojego kosztu i dotrze do odbiorcy? Defekty kodu pozostają w `/review`,
a porównanie twierdzeń z dowodami w `/lie-detector`. Działa samodzielnie, jako **perspektywa produktowa** w
`/review` i `/grilling` oraz w procedurze automatycznego przeglądu. [RULES.md](https://github.com/malinskibeniamin/skills/blob/main/product/RULES.md) ocenia
każdą regułę według liczby niezależnych zestawów dowodów, które ją potwierdzają; [CRAFT.md](https://github.com/malinskibeniamin/skills/blob/main/product/CRAFT.md) to
podręcznik autora dotyczący wyboru, kształtowania, testowania i dostarczania pracy.

## Obszary [#lanes]

Każda zmiana służy jednemu głównemu obszarowi. Różne cele rozdzielaj na osobne PR-y.

| Obszar | Co uzasadnia poświęcony czas | Dowody, które się liczą |
| --- | --- | --- |
| Utrzymanie działania | Oszczędności lub zapobieganie stratom: awarie, koszty bezczynnych zasobów, żmudna praca, nieużywane elementy, ścieżki rozliczeń i przejścia na wyższy plan | Incydent lub reprodukcja, kwoty, godziny żmudnej pracy, zweryfikowana poprawka |
| Komfort pracy | Szybkość i reputacja: CI i cykl pracy programisty, opóźnienia, błędy ze wskazówką rozwiązania, działające instrukcje, niestabilne testy | Pomiary przed i po, komu odblokowano pracę, jak często |
| Funkcjonalność | Zarabianie: konkretny nabywca, segment, premiera lub demo zyskuje nowe możliwości | Konkretne zapotrzebowanie, dostępny punkt dostępu, sygnał użycia |
| Jakość projektu | Niski koszt kolejnej zmiany: jedno źródło prawdy, standardowe ścieżki, zabezpieczenia całych klas przypadków, usuwanie | Już spowodowane rozbieżności lub koszty utrzymania, drugie miejsce użycia |

## Tryby [#modes]

| Tryb | Kiedy | Wynik |
| --- | --- | --- |
| Planowanie | Zgłoszenie, specyfikacja lub plan przed kodowaniem; perspektywa produktowa w `/grilling` | Werdykt, kryteria akceptacji Given/When/Then, najtańszy sposób obalenia hipotezy, plan podziału |
| Autorstwo | Pisanie PR-a, w tym `/commit-push-pr` | Wiersz `Lane:` i opis odpowiadający na pytania recenzenta ([CRAFT.md](https://github.com/malinskibeniamin/skills/blob/main/product/CRAFT.md)) |
| Przegląd | `/review`, procedura automatycznego przeglądu, bezpośrednia prośba | Wiersz werdyktu i najwyżej trzy uwagi |
| Śledzenie | Długo rozwijana gałąź, stos PR-ów lub stale rosnący zakres pracy | `on track`, `drifting` lub `park`, ze wskazaniem zakresu do usunięcia |

## Procedura [#procedure]

1. **Intencja:** przeczytaj plan lub opis PR-a, powiązane zgłoszenie, commity i pełny diff; nigdy nie ufaj
   podsumowaniu bardziej niż kodowi. Zapisz zadeklarowany obszar (wiersz `Lane:`) lub wywnioskuj go i zaznacz to.
2. **Odbiorca:** nazwij rolę i zmianę, którą odczuje. Same określenia „użytkownicy” lub „porządki”
   nie wskazują odbiorcy.
3. **Dlaczego teraz:** znajdź impuls (incydent, prośba klienta, premiera, umowa, skok kosztów,
   zmierzona regresja, zablokowany odbiorca). Jego brak oznacza, że praca konkuruje z planem rozwoju.
4. **Dowody:** pomiar > reprodukcja > konkretny przykład > deklaracja. Twierdzenia o wydajności, kosztach
   i niezawodności wymagają liczb; obalona hipoteza kończy pracę.
5. **Dotarcie:** prześledź drogę wartości do punktu dostępu, z którego odbiorca korzysta dzisiaj: UI, API, CLI, dokumentacja,
   flaga gdzieś włączona. Samo scalenie bez możliwości użycia nie przynosi jeszcze wartości.
6. **Koszt utrzymania:** porównaj koszty działania, nowe elementy, zależności, obciążenie dyżurów i czas przeglądu
   z najprostszą alternatywą.
7. **Podział i bezpieczeństwo:** najmniejszy samodzielnie użyteczny zakres, domyślnie wyłączony z możliwością wycofania,
   ochrona obecnych odbiorców, nieodwracalne decyzje pozostawione osobom za nie odpowiedzialnym.
8. **Reguły:** zawsze sekcje Justification, Scope i Evidence z RULES.md; sekcja danego obszaru; oraz
   Delivery, Trust lub Money, gdy diff dotyczy wdrożenia, wyników widocznych dla klienta lub
   rozliczeń. Wczytaj CRAFT.md przy zmianach w niegenerowanym kodzie źródłowym lub testach.
   Egzekwuj S i A; stosuj B, gdy diff wyraźnie pasuje; C tylko na prośbę.

Tryb śledzenia porównuje gałąź z zadeklarowanym rezultatem: praca poza obszarem to
`drifting` (wskaż zakres do usunięcia lub kolejny PR); wartość, której nie można jeszcze dostarczyć, to `park`
(wskaż warunek wznowienia).

## Werdykty i waga problemów [#verdicts-and-severity]

- **justified**: każdy krok ma odpowiedź popartą dowodami. Zatwierdź bez dodatkowych uwag.
- **thin**: wartość jest realna, ale brakuje dowodów, kryteriów akceptacji, dostępności lub planu wdrożenia; dostarcz po
  wskazanej poprawce.
- **unjustified**: brak odbiorcy lub impulsu, spekulacyjne elementy albo koszt przewyższający korzyści;
  przemyśl zakres lub odłóż pracę, określając warunek wznowienia.

- **P1 Value**: fałszywy sukces lub cichy brak działania; utracona lub podwójna opłata; awaria używanej ścieżki
  bez możliwości wyłączenia; nieodwracalna decyzja podjęta bez osoby za nią odpowiedzialnej; nieprawdziwe publiczne
  twierdzenie.
- **P2 Value**: brak odbiorcy, impulsu, dowodów, kryteriów akceptacji lub planu wdrożenia; spekulacyjne
  elementy; mieszanie obszarów.
- **P3**: sugestia; automatyzacja nigdy jej nie publikuje.

Nigdy nie blokuj wyłącznie ze względu na preferencje projektowe. Ocena określa siłę stosowania reguły; waga problemu wynika wyłącznie
z tej listy.

## Automatyczny przegląd [#automated-review]

Cisza oznacza, że uzasadnienie wartości jest jasne: zmiana **justified** otrzymuje tylko wiersz werdyktu.
W przeciwnym razie opublikuj jeden ogólny komentarz Value z najwyżej trzema uwagami P1 lub P2, każdą
z identyfikatorem reguły, konsekwencją i najmniejszą poprawką. Nigdy nie powtarzaj opisu PR-a. Uwagi dotyczące wyłącznie wartości
publikuj jako komentarze, nigdy jako żądanie zmian; decyduje osoba odpowiedzialna. Uwagi bota oceniaj merytorycznie.

## Format wyniku [#output]

```
product: <ktlo|qol|feature|taste> (<declared|inferred>) -- <justified|thin|unjustified> -- <beneficiary>; trigger: <why now>; evidence: <strongest proof>
- [P1|P2 Value] <rule id> <gap> - <consequence> - <smallest fix>
```

Tryb planowania dodaje scenariusze akceptacji i najtańszy sposób obalenia hipotezy. Tryb śledzenia umieszcza
`on track`, `drifting` lub `park` w miejscu werdyktu.
Wskaż, czego przegląd nie mógł zweryfikować i kto powinien podjąć ostateczną decyzję.
