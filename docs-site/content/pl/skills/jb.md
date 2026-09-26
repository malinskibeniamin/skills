---
title: /jb
description: >-
  Oceń, czy PR, plan lub zgłoszenie uzasadnia poświęcony czas: kategoria
  wartości, odbiorca zablokowany dziś, falsyfikowalne kryterium ukończenia,
  odwracalne wdrożenie i wyczucie projektowe. Do przeglądów PR-ów i planów.
type: skill
sidebar:
  label: /jb
---
![Diagram umiejętności /jb](/diagrams/skills/jb.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/jb.excalidraw)


Oceń jeden aspekt: czy ta zmiana służy konkretnemu odbiorcy już teraz, potwierdza swoje działanie
w środowisku użytkowników i daje się wycofać? Czas jest ograniczony; wdrażaj szybko, szybko wykrywaj niepowodzenia i iteruj małymi krokami.
Działa samodzielnie lub jako **rola jb** w `/review` (300 słów); defekty kodu pozostają w zakresie tego przeglądu.

Domyślnie zatwierdzaj: praktyka stojąca za tą rolą zakłada żądanie zmian w mniej niż 1% PR-ów.
Blokuj tylko z powodów z listy P1, nigdy z powodu drobiazgów, nakładu pracy ani rozmiaru diffu.

## 1. Wybierz jedną kategorię [#1-pick-one-lane]

Przeczytaj tytuł i opis PR-a, zgłoszenie oraz diff. Przypisz jedną główną kategorię:

| Kategoria | Uzasadnienie poświęconego czasu | Oczekiwane dowody |
|---|---|---|
| `ktlo` | Utrzymanie działania, eliminacja żmudnej pracy, oszczędności | Eliminowany incydent, awaria lub wydatek; porównanie liczb przed i po, jeśli są dostępne |
| `qol` | Usprawnienia CI, DX, wydajności, niezawodności i reputacji | Czyj cykl pracy się skraca lub jaki problem użytkownika znika, poparte pomiarem |
| `growth` | Nowa funkcja potrzebna klientowi, do zawarcia umowy lub premiery; przynosi przychody | Odbiorca zablokowany dziś, co będzie mógł zrobić po scaleniu, warunek dopuszczenia, scenariusz akceptacyjny |
| `taste` | Usuwanie, ujednolicanie lub generowanie, by obniżyć koszt następnej zmiany | Co usuwa lub uniemożliwia i którego kolejnego odbiorcę odblokowuje |

Mechaniczne PR-y (aktualizacje wersji, synchronizacja wygenerowanych plików, wycofania zmian, poprawki literówek w dokumentacji) należą do `ktlo` i nie wymagają
pisemnego uzasadnienia. Prace przygotowawcze przyjmują kategorię zmiany widocznej dla użytkownika, której służą, i wskazują tę zmianę.
Niepowiązane kategorie w jednym PR-ze są powodem do żądania podziału. Porównaj z wytycznymi **Lanes** w RULES.md.

## 2. Sprawdź dowody dla kategorii [#2-test-the-lanes-evidence]

Oznacz zmianę jako **uzasadnioną** tylko wtedy, gdy PR, zgłoszenie lub diff wskazuje konkretny problem lub odbiorcę;
jeśli wartość trzeba wywnioskować, uzasadnienie jest **słabe**. **Nieuzasadniona**: brak beneficjenta, brak problemu lub uogólnienie
na zapas. Wskazanie beneficjenta nigdy nie uzasadnia cichego nadpisywania żądań wywołującego
(modelu, tożsamości, regionu, wartości) ani odstępowania od standardowego kontraktu; takie uzasadnienie jest co najwyżej słabe. Zapytaj:

- `ktlo`: „Co się zepsuje, wywoła alarm dla dyżurnego lub będzie kosztować, jeśli to pominiemy?”
- `qol`: „Czyj cykl pracy się skróci i jak to zaobserwujemy?”
- `growth`: „Który odbiorca jest dziś zablokowany i co będzie mógł zrobić po scaleniu?”
- `taste`: „Co to usuwa i jaką kolejną zmianę czyni tańszą?”

## 3. Sprawdź zasady przekrojowe [#3-check-cross-cutting-rules]

Wczytaj odpowiednie sekcje [RULES.md](https://github.com/malinskibeniamin/skills/blob/main/jb/RULES.md); stosuj S/A, zgłaszaj B tylko przy wyraźnym
naruszeniu, a C wspominaj tylko w podsumowaniu:

- **Zawsze**: Scope, Evidence oraz listy zatwierdzeń i decyzji właściciela.
- **Wdrożenie** (flagi, migracje, wartości domyślne, wdrożenia, publiczne API, nieodwracalne działania): Delivery.
- **Wynik używany przez odbiorcę** (API, UI, CLI, wynik narzędzia, błąd, metryka): Contracts.
- **Nowy element interfejsu lub abstrakcja** (pole, opcja, tryb, usługa, generator): Taste.
- **Koszty** (tokeny modelu, zasoby obliczeniowe, minuty CI, limity dostawcy, żmudna praca): Cost.

## Waga problemu [#severity]

- **P1**: nietrywialna zmiana bez możliwego do wskazania beneficjenta lub problemu (`unjustified`);
  zakres na zapas: pole, opcja, abstrakcja, usługa lub tryb bez odbiorcy dziś;
  zmiana `growth` lub ryzykowna zmiana bez falsyfikowalnego kryterium akceptacji lub sposobu weryfikacji;
  nieodwracalna zmiana bez flagi, możliwości wycofania lub udokumentowanej decyzji właściciela.
- **P2**: słabe (`thin`) dowody dla kategorii z konkretnymi konsekwencjami; naruszenie zasady S/A. Dodatki domyślnie wyłączone,
  wymagające świadomego włączenia lub dostępne tylko w środowisku deweloperskim obniżają wagę braków w dowodach do P3.
- **P3**: sugestie B/C, mniejsze i tańsze etapy, dalsze prace; tylko w podsumowaniu.

Zgłoś najwyżej trzy uwagi, zaczynając od tych decydujących o scaleniu. Eskalacje do właściciela wskazują niekorzystny
scenariusz i wymaganą decyzję.

## Format wyniku [#output]

Zawsze zaczynaj od jednego wiersza z werdyktem:

`jb: <lane> -- <justified|thin|unjustified> -- <beneficiary and evidence, at most 20 words>`

Następnie `[P1|P2|P3] <file:line or PR body> <rule-id> -- <consequence>; <smallest fix, or the
sentence the PR body is missing>`. W przypadku planów wskaż sekcję i zapisz brakujące kryteria
akceptacji jako falsyfikowalne scenariusze. Jeśli nie ma uwag, podaj wyłącznie wiersz z werdyktem.
