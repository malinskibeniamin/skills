---
title: /av
description: >-
  Oceń, czy PR, plan lub zgłoszenie są warte czasu inżynierskiego: kategoria
  wartości, beneficjent, ryzyko dla przychodów, wdrożenie i jakość projektu. Do
  przeglądów PR-ów, specyfikacji, zgłoszeń i planów.
type: skill
sidebar:
  label: /av
---
![Diagram umiejętności /av](/diagrams/skills/av.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/av.excalidraw)


Oceń jeden aspekt: czy ta zmiana jest warta swojego kosztu, dla kogo i czy zostanie bezpiecznie wdrożona? Czas
jest ograniczony, a standardem jest szybkie dostarczanie, szybkie wykrywanie niepowodzeń i iterowanie małymi krokami. Oceniaj
wartość zadeklarowaną lub możliwą do wywnioskowania, nie nakład pracy ani liczbę linii. Uruchamiaj samodzielnie lub w ramach **roli av** w
`/review` i roli produktowej w `/grilling`; limit dla roli: 300 słów.

## 1. Wybierz jedną kategorię [#1-pick-one-lane]

Przeczytaj tytuł i opis PR-a, powiązane zgłoszenie oraz diff. Przypisz jedną główną kategorię:

| Kategoria | Uzasadnia poświęcony czas przez | Oczekiwane dowody |
|---|---|---|
| `ktlo` | Utrzymanie działania, eliminowanie żmudnej pracy, oszczędności | Co bez tej zmiany przestanie działać, wywoła alerty lub wygeneruje koszty; oszczędność pracy lub wydatków, najlepiej wyrażona liczbą |
| `qol` | CI, DX, wydajność, drobne usprawnienia UX, reputację | Kto zauważy zmianę; konkretne kroki odtworzenia problemu lub pomiar przed i po |
| `growth` | Nową funkcjonalność, model cenowy, kanał sprzedaży, realizację potrzeby klienta; generowanie przychodów | Wskazany segment, transakcja, premiera lub kamień milowy; sposób użycia i rozliczania; scenariusz akceptacyjny |
| `taste` | Usuwanie, upraszczanie, kształt API/projektu, RFC | Co usuwa lub umożliwia; dlaczego teraz; koszt wycofania zmiany |

Proste, mechaniczne PR-y (aktualizacja zależności, literówka, synchronizacja wygenerowanych plików) należą do `ktlo` i nie wymagają
pisemnego uzasadnienia. Prace przygotowawcze (API dla naszego UI, migracja pod przyszłą funkcję)
przyjmują kategorię zmiany widocznej dla użytkownika, której służą, i muszą ją wskazywać. Jeśli kategorię
można wywnioskować z diffu, ale nie została podana, wspomnij o tym raz.

## 2. Sprawdź dowody dla kategorii [#2-test-the-lanes-evidence]

Oznacz kategorię jako **uzasadnioną**, **słabo udokumentowaną** (wartość prawdopodobna, brak dowodów) lub
**nieuzasadnioną** (brak beneficjenta, problemu lub jedynie spekulacyjne ogólniki). Gdy dowody są słabe, zapytaj:

- `ktlo`: „Co się stanie i kto poniesie koszty, jeśli to pominiemy?”
- `qol`: „Kto to odczuje i po czym poznamy poprawę?”
- `growth`: „Który klient lub która premiera skorzysta z tego jako pierwsza i jak to przyniesie przychody?”
- `taste`: „Co dzięki temu usuniemy lub zrobimy taniej w następnym kroku?”

## 3. Sprawdź reguły przekrojowe [#3-check-cross-cutting-rules]

Wczytaj odpowiednie sekcje [RULES.md](https://github.com/malinskibeniamin/skills/blob/main/av/RULES.md):

- **Przepływy finansowe** (pomiar zużycia, ceny, rozliczenia, kredyty, uprawnienia, zawieszanie, usuwanie): zawsze wczytaj Money.
- **Elementy widoczne dla klienta** (UI, API, CLI, dokumentacja, błędy, liczby): wczytaj Trust.
- **Wdrożenie** (flagi, migracje, zmiany niekompatybilne wstecz, ustawienia domyślne, włączanie funkcji): wczytaj Delivery.
- **Nowe elementy interfejsu lub abstrakcje** (pola, opcje, usługi, konfiguracje): wczytaj Scope i Taste.

Stosuj reguły S/A; zgłaszaj B tylko przy wyraźnym naruszeniu; o C wspominaj wyłącznie w podsumowaniu.

## Waga problemu [#severity]

- **P1**: nietrywialna zmiana bez możliwego do wskazania beneficjenta lub problemu (`unjustified`);
  albo ryzyko dla przepływów finansowych: ciche zaniżanie lub zawyżanie opłat, utrata danych o płatnym zużyciu, utrata przychodów lub przychodów z kanału sprzedaży,
  destrukcyjna automatyzacja bez zabezpieczeń; albo potencjalnie fałszywe liczby prezentowane klientowi.
- **P2**: słabe dowody dla kategorii (`thin`) z konkretnymi konsekwencjami; naruszenie reguły S/A.
- **P3**: sugestie B/C, tańsze punkty wejścia, pomysły na dalsze działania. Tylko w podsumowaniu.

Zgłoś najwyżej trzy uwagi av; wybierz przede wszystkim tę, która wpływa na decyzję o scaleniu.
Potwierdzone błędy poprawności należą do głównego procesu `/review`, nie do tego aspektu oceny.

## Wynik [#output]

Zawsze zaczynaj od jednego wiersza z werdyktem:

`av: <lane> -- <justified|thin|unjustified> -- <beneficiary and why, at most 20 words>`

Następnie podaj uwagi w formacie `[P1|P2|P3] <file:line or PR body> <rule-id> -- <consequence>; <smallest
fix or the question to answer>`. W przypadku planów i zgłoszeń zastąp `file:line`
sekcją planu i dodaj brakujące kryteria akceptacji jako scenariusze
(`Given/When/Then` lub „Ja ... / Widzę ...”). Jeśli nie ma uwag, podaj wyłącznie wiersz z werdyktem.
