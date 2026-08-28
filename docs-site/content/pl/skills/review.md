---
title: /review
description: >-
  Używaj do opartego na dowodach przeglądu defektów wprowadzonych przez diff w
  gałęziach, PR-ach, WIP lub wydaniach.
type: skill
sidebar:
  label: /review
---
![Diagram umiejętności /review](/diagrams/skills/review.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/review.excalidraw)

Przeglądaj od ustalonego punktu do `HEAD`. Nie edytuj, nie commituj, nie wypychaj ani nie publikuj;
Publikowanie komentarzy wymaga jawnej intencji. Zachowaj jednego właściciela; delegacja musi być jawna.

## Kontrakt przeglądu

- **Cel**: ustal, czy pełny diff osiąga oczekiwany wynik bez wiarygodnego defektu.
- **Ograniczenia**: zgłaszaj tylko problemy wprowadzone przez diff; oddziel standardy od luk produktu/specyfikacji;
  pliki generowane są dowodem, nie celem edycji.
- **Weryfikacja**: prześledź źródło. Samodzielnie użyj każdej uruchamialnej zmiany przez prawdziwy punkt wejścia;
  testy nie zastępują doświadczenia.
- **Stop**: uwzględnij każdą powierzchnię; znaleziska wymagają dowodu, konsekwencji, priorytetu,
  poprawki i weryfikacji.

Zapytaj, jeśli brakuje ustalonego punktu. W przeciwnym razie ustaw
`BASE=$(PR_BASE_REF="${REVIEW_BASE:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`,
a następnie sprawdź pełny diff i log do `HEAD`.

## Pętla dowodowa

**sprawdź -> zweryfikuj -> sklasyfikuj -> zsyntetyzuj.**

### Sprawdź

1. Przeczytaj żądanie/specyfikację, zasady, pełny diff, miejsca użycia i zachowanie. Nie ufaj opisowi PR bardziej niż kodowi.
2. Dla każdej zmienionej przesłanki prześledź ją wstecz do autorytatywnych producentów, schematów,
   zapisu, konsumentów i powierzchni publicznych. Szukaj po pojęciu domenowym, polu i emitowanej
   wartości, nie tylko zmienionym symbolu.
3. Sprawdź zaskakujące wyniki w niezależnych artefaktach odpowiedniego niezmienionego kodu, bazie,
   najnowszej historii, dowodach ze środowiska uruchomieniowego i fixture'ach. Porównaj fixture'y z produkcyjnym kształtem danych.
4. Zbuduj jeden behawioralny kontrprzykład dla prawdopodobnej kolizji. Zmapuj uprawnienia i widoczne
   powierzchnie; pomiń styl należący do formatera i wcześniejsze defekty.
5. Zapytaj, co nadal może być błędne, jeśli testy przechodzą.

### Zweryfikuj

- Odtwórz problem na podstawie źródła, schematu, dokumentacji pierwotnej albo najmniejszej wykonywalnej kontroli.
- Na reprezentatywnych danych o rzeczywistej skali wykonaj ścieżkę poprawną i jedną wiarygodną ścieżkę błędu lub odzyskiwania.
  Obserwuj konsolę, sieć, logi i czas odpowiedzi; gdy jest to niebezpieczne lub niemożliwe, nazwij blokadę.
- Sprawdź integralność testów: zachowanie publiczne, RED, asercje, pokrycie i brak oczekiwania przez czas.
  Kontrole tekstu źródłowego nie zapewniają pokrycia, chyba że tekst jest publicznym wynikiem; usuń je lub zastąp testem przez
  publiczny punkt styku. Do składni używaj analizy statycznej.
- Oceń dodatki względem wymaganego zachowania, gęstości semantycznej, jasności domeny, wiarygodnego
  ryzyka i wykazanej skali. Nigdy nie optymalizuj liczby linii ani nie premiuj code golfu.

Dodaj kontrolę powierzchni tylko wtedy, gdy diff daje ku temu dowód:

| Powierzchnia | Kontrola |
|---|---|
| UI/CLI/raport dla klienta | Render, stany, tekst, klawiatura/a11y, konsola, viewport |
| Bezpieczeństwo/prywatność/utrata danych | Zaufanie, autoryzacja, sekrety, wstrzyknięcia, odzyskiwanie |
| API/schemat/SQL/PostgreSQL | Zgodność, migracje, wynik generowany, rzeczywisty dialekt |
| Go/współbieżność/workflow | Własność, anulowanie, wyścigi, ponowienia, idempotencja |
| Zależność/zewnętrzne API | Dokumentacja pierwotna, wersje, lockfile, ostrzeżenia |

### Sklasyfikuj

Znalezisko jest wprowadzone przez diff, ma wpływ, jest odtwarzalne lub konkretne, wskazuje najściślejszą zmienioną linię
i jest połączone z najmniejszą bezpieczną poprawką.

- **P0**: ekspozycja, utrata danych, awaria lub niemożliwy przepływ podstawowy.
- **P1**: regresja użytkownika, złamany kontrakt, fałszywy sukces lub poważny problem a11y.
- **P2**: użyteczna, ograniczona poprawka o mniejszym wpływie.
- Pomijaj opcjonalną przyszłą pracę i kosmetykę w komentarzach liniowych.

Nie zgłaszaj wydajności bez pomiaru lub granicy strukturalnej. Nie zgłaszaj przypadku brzegowego
bez wiarygodnego ryzyka. Dowód może uzasadniać odrzucenie uwagi.

### Zsyntetyzuj

Zacznij od znalezisk. Deduplikuj według przyczyny źródłowej. Podaj ścieżkę, wpływ, poprawkę i krok
weryfikacji; pomiń pochwały i narrację. Przy ponownym przeglądzie oznacz stan każdej wcześniejszej uwagi.

## Tryb głęboki

Dla `--deep` użyj tej samej pętli z pełnym rejestrem zastosowania. Przeczytaj
[DEEP-AUDIT.md](https://github.com/malinskibeniamin/skills/blob/main/review/DEEP-AUDIT.md); uwzględnij wszystkie powierzchnie i nie dodawaj automatycznych agentów.

## Wynik

Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/review/REFERENCE.md), aby poznać słownictwo i schemat. Zgłaszaj
`[P0|P1|P2] <file:line> <title> - <evidence, consequence, correction, verify command>`.
Dodaj `entrypoint, data, actions, observations, timing, limits`, ustalony punkt, tryb, liczby,
werdykt i pozostałe ograniczenia. Czysty przegląd zwraca tylko werdykt i pozostałe ograniczenia.
