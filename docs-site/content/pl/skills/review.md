---
title: /review
description: "Używaj do opartego na dowodach przeglądu defektów wprowadzonych przez diff w gałęziach, PR-ach, WIP lub wydaniach."
type: skill
sidebar:
  label: /review
---
![Diagram umiejętności /review](/diagrams/skills/review.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/review.excalidraw)

Przeglądaj od ustalonego punktu do `HEAD`. Nie edytuj, nie commituj, nie wypychaj, nie odpowiadaj ani nie rozwiązuj. Publikowanie komentarzy wymaga jawnej intencji. Jeden właściciel pozostaje w głównym kontekście; delegacja musi być jawna.

## Kontrakt przeglądu

- **Cel:** ustal, czy pełny diff osiąga oczekiwany wynik bez wiarygodnego defektu.
- **Ograniczenia:** zgłaszaj tylko możliwe do działania problemy wprowadzone przez diff; oddziel standardy od luk produktu/specyfikacji; pliki generowane są dowodem, nie celem edycji.
- **Weryfikacja:** prześledź twierdzenia do źródła. Samodzielnie użyj każdej uruchamialnej zmiany przez prawdziwy punkt wejścia; testy wspierają doświadczenie, ale go nie zastępują.
- **Stop:** uwzględniono każdą powierzchnię, a każde znalezisko ma dowód, konsekwencję, priorytet, poprawkę i weryfikację.

Zapytaj, jeśli brakuje punktu odniesienia. W przeciwnym razie ustaw
`BASE=$(PR_BASE_REF="${REVIEW_BASE:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`,
a następnie sprawdź pełny diff i log do `HEAD`.

## Pętla dowodowa

**sprawdź -> zweryfikuj -> sklasyfikuj -> zsyntetyzuj.**

### Sprawdź

1. Przeczytaj żądanie/specyfikację, zasady repozytorium, pełny diff, miejsca użycia i zachowanie. Nie ufaj opisowi PR bardziej niż kodowi.
2. Dla każdej zmienionej przesłanki prześledź wstecz źródła autorytatywne: producentów, schematy, zapis, konsumentów i powierzchnie publiczne. Szukaj po pojęciu domenowym, polu i emitowanej wartości, nie tylko zmienionym symbolu.
3. Sprawdź zaskakujące twierdzenia w niezależnych artefaktach niezmienionego kodu, bazie, historii, środowisku uruchomieniowym i fixture'ach. Porównaj fixture'y z produkcyjnym kształtem danych.
4. Zbuduj jeden behawioralny kontrprzykład dla prawdopodobnej kolizji. Zmapuj uprawnienia i widoczne powierzchnie; pomiń styl należący do formatera i wcześniejsze defekty.
5. Zapytaj, co nadal może być błędne, jeśli testy przechodzą.

### Zweryfikuj

- Odtwórz problem względem źródła, schematu, aktualnej dokumentacji pierwotnej albo najmniejszej wykonywalnej kontroli.
- Na reprezentatywnych danych o rzeczywistej skali wykonaj ścieżkę poprawną i jedną wiarygodną ścieżkę błędu lub odzyskiwania. Obserwuj konsolę, sieć, logi i czas odpowiedzi; gdy to niemożliwe, nazwij blokadę.
- Sprawdź integralność testów: zachowanie publiczne, RED przed poprawką, istotne asercje, pokrycie i brak oczekiwania przez czas.
- Oceń dodatki względem wymaganego zachowania, gęstości semantycznej, domeny, ryzyka i skali. Nie optymalizuj liczby linii ani code golfu.

Dodaj kontrolę powierzchni tylko wtedy, gdy diff daje ku temu dowód:

| Powierzchnia | Kontrola |
|---|---|
| UI/CLI/raport dla klienta | Render, stany, tekst, klawiatura/a11y, konsola, viewport |
| Bezpieczeństwo/prywatność/utrata danych | Granice zaufania, autoryzacja, sekrety, wstrzyknięcia, odzyskiwanie |
| API/schemat/SQL/PostgreSQL | Zgodność, migracje, wynik generowany, rzeczywisty dialekt |
| Go/współbieżność/workflow | Własność, anulowanie, wyścigi, ponowienia, idempotencja |
| Zależność/zewnętrzne API | Dokumentacja pierwotna, wersje, lockfile, ostrzeżenia |

### Sklasyfikuj

Znalezisko jest wprowadzone przez diff, ma wpływ, jest odtwarzalne lub poparte konkretną ścieżką, wskazuje najściślejszą zmienioną linię i najmniejszą bezpieczną poprawkę.

- **P0:** ekspozycja, utrata danych, awaria lub niemożliwy przepływ podstawowy.
- **P1:** regresja użytkownika, złamany kontrakt, fałszywy sukces lub poważny problem a11y.
- **P2:** użyteczna, ograniczona poprawka o mniejszym wpływie.
- Pomijaj opcjonalną przyszłą pracę i kosmetykę w komentarzach liniowych.

Nie zgłaszaj wydajności bez pomiaru lub granicy strukturalnej ani przypadku brzegowego bez wiarygodnego ryzyka. Dowód może uzasadniać odrzucenie uwagi.

### Zsyntetyzuj

Zacznij od znalezisk i deduplikuj według przyczyny źródłowej. Podaj ścieżkę, wpływ, poprawkę i krok weryfikacji; pomiń pochwały i narrację. Przy ponownym przeglądzie oznacz stan wcześniejszych uwag.

## Tryb głęboki

Dla `--deep` użyj tej samej pętli z pełnym rejestrem zastosowania. Przeczytaj [DEEP-AUDIT.md](https://github.com/malinskibeniamin/skills/blob/main/review/DEEP-AUDIT.md); uwzględnij wszystkie powierzchnie i nie dodawaj automatycznych agentów.

## Wynik

[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/review/REFERENCE.md) definiuje słownictwo i schemat. Zgłaszaj `[P0|P1|P2] <plik:linia> <tytuł> - <dowód, konsekwencja, poprawka, polecenie weryfikacji>`.
Dodaj `entrypoint, data, actions, observations, timing, limits`, punkt odniesienia, tryb, liczby, werdykt i ograniczenia. Czysty przegląd zwraca tylko werdykt i ograniczenia.
