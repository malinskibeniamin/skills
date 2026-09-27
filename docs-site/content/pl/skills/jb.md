---
title: /jb
description: >-
  Oceń lub przygotuj PR, plan lub zgłoszenie tak, by były warte czasu i dobrze
  wdrożone: kategoria wartości, odbiorca zablokowany dziś, falsyfikowalne
  kryteria ukończenia, odwracalne wdrożenie, warsztat i jakość projektu. Używaj
  przy PR-ach i planach.
type: skill
sidebar:
  label: /jb
---
![Diagram umiejętności /jb](/diagrams/skills/jb.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/jb.excalidraw)


Oceniaj jeden aspekt: czy ta zmiana służy teraz rzeczywistemu odbiorcy, dowodzi swojej skuteczności
w środowisku użytkowników i daje się wycofać? Czas jest ograniczony; wdrażaj szybko, szybko wykrywaj porażki, iteruj małymi krokami.
Działa samodzielnie lub jako **rola jb** w `/review` (300 słów); defekty kodu pozostają w zakresie tamtego przeglądu.

Domyślnie zatwierdzaj. Blokuj tylko z powodów z listy P1, nigdy z powodu drobiazgów, nakładu pracy ani rozmiaru diffu.

## 1. Wybierz jedną kategorię [#1-pick-one-lane]

Przeczytaj tytuł i opis PR-a, zgłoszenie oraz diff. Przypisz jedną główną kategorię:

| Kategoria | Uzasadnia poświęcony czas przez | Oczekiwane dowody |
|---|---|---|
| `ktlo` | Utrzymanie działania, eliminowanie żmudnej pracy, oszczędności | Incydent, awaria lub koszt, które eliminuje; porównanie liczb przed i po, jeśli są dostępne |
| `qol` | Usprawnienia CI, DX, wydajności, niezawodności i reputacji | Pomiar pokazujący, czyj cykl pracy się skraca lub który problem użytkownika znika |
| `growth` | Nową funkcjonalność potrzebną klientowi, do zawarcia umowy lub premiery; generowanie przychodów | Odbiorca zablokowany dziś, jego możliwości po scaleniu, warunek dopuszczenia, scenariusz akceptacyjny |
| `taste` | Usuwanie, ujednolicanie lub generowanie, dzięki którym kolejna zmiana będzie tania | Co usuwa lub uniemożliwia i któremu kolejnemu odbiorcy odblokowuje pracę |

Mechaniczne PR-y (aktualizacje wersji, synchronizacja wygenerowanych plików, wycofania zmian) są uzasadnionym `ktlo`. Prace przygotowawcze przyjmują
kategorię zmiany, której służą. Niepowiązane kategorie są podstawą do prośby o podział. Porównaj z wytycznymi w sekcji **Lanes** pliku RULES.md.

## 2. Sprawdź dowody dla kategorii [#2-test-the-lanes-evidence]

Oznacz jako **uzasadnione** tylko wtedy, gdy PR, zgłoszenie lub diff wskazują konkretny problem lub odbiorcę;
wartość, której trzeba się domyślać, ma **słabe uzasadnienie**. **Nieuzasadnione**: brak beneficjenta, brak problemu lub spekulatywna
ogólność. Wskazanie beneficjenta nigdy nie uzasadnia cichego nadpisywania tego, o co prosił odbiorca
(modelu, tożsamości, regionu, wartości), ani odstępowania od standardowego kontraktu; to co najwyżej słabe uzasadnienie. Zapytaj:

- `ktlo`: „Co się zepsuje, wywoła alarm lub będzie kosztować, jeśli to pominiemy?”
- `qol`: „Czyj cykl pracy się skróci i jak to zaobserwujemy?”
- `growth`: „Który odbiorca jest dziś zablokowany i co będzie mógł zrobić po scaleniu tej zmiany?”
- `taste`: „Co to usuwa i co dzięki temu będzie tańsze w następnej kolejności?”

## 3. Sprawdź reguły przekrojowe [#3-check-cross-cutting-rules]

Wczytaj odpowiednie sekcje [RULES.md](https://github.com/malinskibeniamin/skills/blob/main/jb/RULES.md); stosuj S/A, zgłaszaj B tylko przy wyraźnym
naruszeniu, a C wspominaj wyłącznie w podsumowaniu:

- **Zawsze**: zakres, dowody oraz listy zatwierdzeń i decyzji właściciela.
- **Wdrożenie** (flagi, migracje, wartości domyślne, wdrożenia, publiczne API): dostarczanie.
- **Wynik używany przez odbiorców** (API, UI, CLI, wynik narzędzia, błąd, metryka): kontrakty.
- **Nowy element interfejsu lub abstrakcja** (pole, opcja, tryb, usługa, generator): jakość projektu.
- **Wydatki** (tokeny, moc obliczeniowa, minuty CI, limit, żmudna praca): koszt.

## 4. Sprawdź warsztat [#4-check-craft]

Wczytaj [CRAFT.md](https://github.com/malinskibeniamin/skills/blob/main/jb/CRAFT.md): zawsze sekcje Ship i Verify; Code dla Go, proto lub SQL; Review
voice dla komentarzy. Ustalenia dotyczące warsztatu mają wagę najwyżej P2. Przy tworzeniu treści najpierw zastosuj te zasady do wersji roboczej.

## Waga problemu [#severity]

- **P1**: nietrywialna zmiana bez możliwego do wskazania beneficjenta lub problemu (`unjustified`);
  spekulatywny zakres: pole, opcja, abstrakcja, usługa lub tryb bez odbiorcy dziś;
  zmiana `growth` lub ryzykowna zmiana bez falsyfikowalnego kryterium akceptacji albo ścieżki weryfikacji;
  nieodwracalny krok bez flagi, możliwości wycofania lub udokumentowanej decyzji właściciela.
- **P2**: dowody dla kategorii ocenione jako `thin`, z konkretną konsekwencją; naruszenie reguły S/A. Dodatki domyślnie wyłączone,
  wymagające świadomego włączenia lub dostępne tylko w środowisku deweloperskim obniżają wagę braków w dowodach do P3.
- **P3**: sugestie B/C, tańsze etapy, dalsze działania; tylko w podsumowaniu.

Zgłoś najwyżej trzy ustalenia, zaczynając od tych, które decydują o scaleniu. Eskalacje wskazują scenariusz i potrzebną decyzję.

## Wynik [#output]

Zawsze zaczynaj od jednego wiersza z werdyktem:

`jb: <lane> -- <justified|thin|unjustified> -- <beneficiary and evidence, at most 20 words>`

Następnie `[P1|P2|P3] <file:line or PR body> <rule-id> -- <consequence>; <smallest fix>`. W przypadku
planów wskaż sekcję i zapisz brakujące kryteria jako falsyfikowalne scenariusze. Jeśli nie ma zastrzeżeń, podaj tylko wiersz z werdyktem.
