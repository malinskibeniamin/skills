---
title: /diagnosing-bugs
description: "Używaj, gdy trudny błąd lub regresja wydajności wymaga odtwarzalnej pętli diagnostycznej."
type: skill
sidebar:
  label: /diagnosing-bugs
---
![Diagram umiejętności /diagnosing-bugs](/diagrams/skills/diagnosing-bugs.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/diagnosing-bugs.excalidraw)

Pomijaj fazę tylko z uzasadnieniem. Przeczytaj słownik domeny i ADR-y; dla zmian zewnętrznych lub wersji użyj `/read-the-damn-docs`.

## Redakcja

Przed udostępnieniem poleceń, wyników lub artefaktów zastąp sekrety tekstem `<REDACTED>`. Poświadczenia przechowuj w zmiennych środowiskowych i cytuj tylko linie niosące sygnał. Gdy redakcja usuwa potrzebny dowód, poproś o bezpieczniejsze źródło.

## Faza 1 -- Zbuduj pętlę informacji zwrotnej

Zbuduj szybki, deterministyczny i uruchamialny przez agenta sygnał zaliczenia dla zgłoszonego objawu. Przed debugowaniem popraw jego szybkość, precyzję i deterministyczność.

Wybierz najtańszy wierny punkt styku:

1. Nieudany test: jednostkowy, integracyjny lub E2E.
2. Skrypt HTTP przeciw uruchomionej usłudze.
3. Fixture CLI z porównaniem stdout.
4. Przeglądarka bez interfejsu, na przykład Playwright.
5. Odtworzenie przechwyconego żądania, payloadu, śladu lub zdarzenia.
6. Minimalny jednorazowy harness.
7. Pętla właściwości lub fuzz dla sporadycznego wyniku.
8. Automatyczny harness dla `git bisect run`.
9. Różnicowe uruchomienie starej i nowej wersji lub konfiguracji.
10. Skrypt HITL z `scripts/hitl-loop.template.sh` tylko w ostateczności.

Ustal czas, ziarna losowości, stan systemu plików i wejście sieciowe. Dla niedeterminizmu powtarzaj przy kontrolowanym obciążeniu, aż częstość odtworzenia rozróżni hipotezy. Jeśli pętla jest niemożliwa, pokaż próby i poproś o brakujące środowisko, artefakt albo bezpieczny dostęp do instrumentacji.

## Faza 2 -- Odtwórz

Uruchom pętlę, potem `/dogfood` na prawdziwym punkcie wejścia zgłaszającego. Potwierdź dokładny zgłoszony błąd w wystarczającej liczbie prób i uchwyć objaw, który Faza 5 może obalić.

## Faza 3 -- Postaw hipotezy

Przed testowaniem zapisz 3-5 uszeregowanych, falsyfikowalnych hipotez. Każda przewiduje zmianę, która usunie albo pogorszy objaw. Pokaż listę do korekty kolejności; odrzuć twierdzenia bez testowalnej prognozy.

## Faza 4 -- Instrumentuj

Każdą sondę powiąż z jedną prognozą. Zmieniaj jedną zmienną naraz.

- Preferuj debugger lub REPL, potem ukierunkowane logi na granicach; nie loguj wszystkiego.
- Oznacz logi tymczasowe unikalnym prefiksem, na przykład `[DEBUG-a4f2]`, aby podczas sprzątania wyszukać prefiks.
- Dla wydajności zmierz bazę przez harness czasowy, profiler albo plan zapytania przed bisekcją lub poprawką.

## Faza 5 -- Poprawka i test regresji

Przed poprawką utwórz test regresji we właściwym punkcie styku: musi odtwarzać prawdziwy łańcuch wywołań, a nie pobliskie zachowanie jednostkowe. Gdy takiego punktu brak, zapisz lukę architektoniczną. W innym przypadku:

1. Zminimalizuj reprodukcję do nieudanego testu i zaobserwuj RED.
2. Zastosuj najmniejszą poprawkę przyczyny źródłowej i zaobserwuj GREEN.
3. Uruchom powiązane kontrole.
4. Wykonaj `/dogfood` dla identycznej ścieżki użytkownika i ponownie uruchom pełną pętlę Fazy 1.

## Faza 6 -- Sprzątanie i wnioski

- Pierwotna reprodukcja już nie występuje; uruchom ponownie pierwotną pętlę.
- Test regresji przechodzi albo brakujący punkt styku jest udokumentowany.
- Cała instrumentacja debugująca została usunięta; wyszukaj unikalny prefiks.
- Artefakty jednorazowe są usunięte lub wyraźnie odizolowane.
- Zapisz potwierdzoną przyczynę źródłową w commicie lub PR-ze.

Zapytaj, co zapobiegłoby nawrotowi. Po poprawce przekaż potwierdzony problem punktu styku lub sprzężenia do `/improve-codebase-architecture`.
