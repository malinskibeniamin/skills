---
description: Utwórz prezentację funkcji dla klientów i opublikuj ją w wersji roboczej PR.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - demo
sidebar:
  label: /demo
title: /demo
type: skill
---
![Diagram umiejętności /demo](/diagrams/skills/demo.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/demo.excalidraw)

Przekształć ukończoną pracę w dowód wartości dla klienta. Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/demo/REFERENCE.md).

## Kontrakt [#contract]

1. Ustal zakres; domyślnie obejmuje całą bieżącą gałąź lub PR od merge-base, w tym zmiany zatwierdzone, dodane do indeksu, niedodane do indeksu i istotne nieśledzone pliki.
2. Wybierz najważniejszą widoczną korzyść; opowiedz jedną krótką historię: problem -> działanie -> rezultat.
3. Przechowuj źródła i wyniki w `demos/<slug>/`; przy aktualizacji używaj ponownie tego katalogu, nie rozpraszaj multimediów.
4. Zacznij od nagrywania: rzeczywiste nagrania przeglądarki i odtworzenia terminala z plików asciinema `.cast`. Korzystaj z [przepisów na nagrywanie i narrację](https://github.com/malinskibeniamin/skills/blob/v4.41.0/demo/RECORDING.md). Odtworzenie terminala nie jest plikiem MP4.
5. Dostarcz `output/demo.mp4` dla filmu albo `output/index.html` wraz z zasobami dla prezentacji z rozdziałami. Do prezentacji łączących przeglądarkę i terminal użyj [szablonu](https://github.com/malinskibeniamin/skills/blob/v4.41.0/demo/templates/walkthrough.html). Oznacz materiały objaśniające lub symulowane; nie są nagranym dowodem działania produktu.
6. Do opcjonalnej kompozycji wokół rzeczywistych nagrań użyj ponownie HyperFrames; zachowaj istniejący projekt Remotion, jeśli to on odpowiada za źródło. Nie instaluj drugiego renderera tylko po to, by utworzyć nagranie.
7. Prezentacja musi być zrozumiała bez dźwięku. Dodaj narrację głosową tylko na żądanie lub gdy wymaga jej materiał źródłowy; zsynchronizuj ją z nagranymi działaniami, zachowaj napisy/transkrypcje i sprawdź przez odsłuch. Mowa generowana w chmurze, klonowane głosy i przesyłanie plików wymagają odpowiednich upoważnień.
8. Sprawdź początkowe, środkowe i końcowe klatki, pełne odtwarzanie oraz ścieżki błędów; popraw usterki i wyklucz sekrety, dane prywatne oraz dane osobowe klientów. Diagram architektury jest poprawnym rozwiązaniem, gdy ruch nie wnosi wartości; dodaj opis dostępności i uzasadnienie.
9. Nigdy nie edytuj README. Przestrzegaj wyraźnego polecenia zakończenia lokalnie lub bez wypychania; w pozostałych przypadkach zatwierdź zmiany, wypchnij bieżącą gałąź i utwórz wersję roboczą PR z odnośnikiem do artefaktu. Aktualizuj istniejący PR bez zmiany stanu przeglądu.
10. macOS: `open -R`; w pozostałych systemach pokaż `pwd`, ścieżkę bezwzględną i dokładne polecenie `cd`.

## Ukończenie [#done]

Zwróć historię klienta, typ i ścieżkę artefaktu, dowody nagrania/renderowania/odtwarzania, znane ograniczenia oraz adres URL wersji roboczej PR, gdy publikacja mieści się w zakresie. Wynik wyłącznie lokalny spełnia wyraźnie wskazany lokalny punkt zakończenia, ale nie żądanie publikacji.
