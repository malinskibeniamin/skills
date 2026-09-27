---
title: /ss
description: >-
  Oceń, czy zmiana jest warta naszego ograniczonego czasu: kategoria wartości,
  beneficjent, dowody, dostępność, koszt i wielkość zakresu. Stosuj przy każdym
  przeglądzie PR-a, automatycznym przeglądzie lub planowaniu pracy.
type: skill
sidebar:
  label: /ss
---
![Diagram umiejętności /ss](/diagrams/skills/ss.svg)

[Otwórz edytowalny plik źródłowy Excalidraw](/diagrams/skills/ss.excalidraw)


Oceń jeden aspekt: czy to właściwa praca, we właściwym zakresie i we właściwym momencie? Poprawność pozostaje domeną
`/review`; ta perspektywa pyta, kto skorzysta, skąd to wiemy i ile będzie kosztować utrzymanie.
[RULES.md](https://github.com/malinskibeniamin/skills/blob/main/ss/RULES.md) zawiera wszystkie reguły wraz z ich oceną i dowodami ważonymi według aktualności.

## Kategorie [#buckets]

Każdy PR ma dokładnie jedną główną kategorię. Różne cele rozdziel na osobne PR-y.

| Kategoria | Deklarowana korzyść | Dowody, które ją uzasadniają |
| --- | --- | --- |
| Utrzymanie działania | Oszczędza pieniądze, eliminuje żmudną pracę lub ryzyko | Incydent, alert, ustalenie, data wycofania, kwoty w dolarach, godziny żmudnej pracy |
| Komfort pracy | CI, doświadczenie programistów, wydajność, reputacja | Pomiary przed i po, komu odblokowuje pracę i jak często |
| Funkcjonalność | Przynosi przychody | Konkretny klient, potencjalny klient, segment, premiera lub demonstracja; droga do przychodów |
| Zakład projektowy | Wyczucie projektowe, które ogranicza przyszłe koszty | Mniej pojęć, usunięte elementy, odwracalny zakres, sygnał do kontynuacji lub rezygnacji |

## Procedura [#procedure]

1. **Odczytaj intencję:** opis PR-a, powiązane zgłoszenie, commity, statystyki zmian. Zapisz deklarowaną kategorię;
   jeśli jej nie podano, wywnioskuj ją i zaznacz brak deklaracji.
2. **Beneficjent:** wskaż personę lub klienta i opisz, co się dla nich zmieni. Same określenia „użytkownicy” lub
   „porządki” nie wskazują beneficjenta.
3. **Dlaczego teraz:** znajdź impuls (incydent, prośba klienta, data premiery, kontrakt, skok kosztów,
   zmierzona regresja). Brak impulsu oznacza, że praca konkuruje z planem rozwoju; powiedz to wprost.
4. **Siła dowodów:** zmierzone > konkretnie wskazane > prawdopodobne > zadeklarowane. Twierdzenia o wydajności, kosztach i
   niezawodności wymagają liczb; obalona hipoteza oznacza zamknięcie PR-a.
5. **Dostępność:** prześledź drogę od wartości do miejsca, z którego beneficjent może korzystać już dziś: UI, API,
   CLI, dokumentacja, flaga gdzieś włączona. Zmiana scalona, ale niedostępna, jeszcze nie przynosi korzyści.
6. **Koszt utrzymania:** koszty działania w dolarach, nowa infrastruktura, zakres konfiguracji, flagi, obciążenie dyżurami,
   nakład pracy na przeglądy. Usuwanie i upraszczanie też stanowią wartość.
7. **Zakres:** najmniejszy odwracalny przyrost, który potwierdza deklarowaną korzyść; domyślnie wyłączony; dalsze prace
   w osobnych zgłoszeniach, bez rozszerzania zakresu; ochrona obecnych płacących klientów zapewniona już w projekcie.
8. **Zastosuj reguły:** sprawdź wpisy w RULES.md pasujące do kategorii i obszaru zmiany.

## Werdykt [#verdict]

- **uzasadnione**: kategoria, beneficjent i dowody są spójne; zakres jest proporcjonalny.
- **wymaga uzasadnienia**: prawdopodobnie wartościowe, ale PR tego nie wykazuje. Poproś o jeden
  brakujący fakt (beneficjenta, impuls, liczbę lub kryteria akceptacji), nie o esej.
- **raczej się nie opłaci**: brak beneficjenta lub impulsu, koszt przekracza prawdopodobny zwrot albo
  jedynym powodem jest niepoparte pomiarami twierdzenie. Zalecaj odłożenie, zmniejszenie zakresu lub zamknięcie.

Nigdy nie blokuj wyłącznie ze względu na gust. O wartości decyduje właściciel; ta perspektywa uwidacznia
kompromis. Termin może uzasadniać niedopracowany przyrost, jeśli PR wskazuje dalsze prace.

## Waga problemu [#severity]

- **P1 Wartość**: scalenie prawdopodobnie spowoduje stratę pieniędzy lub zaufania: pominięte lub podwójne naliczenie opłat,
  skonfigurowana, lecz niedziałająca funkcja płatna lub zabezpieczająca, zmiana niezgodna wstecznie dla obecnych klientów,
  zmiana przychodów lub cen bez akceptacji zespołu produktowego, nieodwracalna decyzja podjęta na potrzeby hipotetycznego wymagania.
- **P2 Wartość**: brak beneficjenta, impulsu, dowodów, kryteriów akceptacji lub dostępności; zbyt duży PR lub
  PR łączący różne cele; nowy stały koszt bez kwoty w dolarach; uogólnienie na potrzeby jednego użytkownika.
- **P3**: sformułowania lub porządek w zgłoszeniach. Tylko w podsumowaniu.

## Automatyczny przegląd [#automated-review]

W automatycznym przeglądzie: opublikuj jeden ogólny komentarz dotyczący wartości tylko wtedy, gdy werdykt jest inny niż
**uzasadnione**; wskaż najwyżej trzy problemy, każdy z brakującym faktem i poprawką opisaną w jednym wierszu.
Brak komentarza oznacza, że uzasadnienie wartości jest jasne. Nigdy nie streszczaj autorowi jego własnego PR-a.

## Wynik [#output]

```md
Value: <bucket> | Beneficiary: <who> | Trigger: <why now> | Evidence: <grade>
Verdict: justified | needs justification | unlikely to pay off
- [P1|P2 Value] <rule id> <gap> - <consequence> - <smallest fix>
```

Limit dla tej roli: 250 słów. Wynik bez zastrzeżeń zawiera tylko dwa pierwsze wiersze.
