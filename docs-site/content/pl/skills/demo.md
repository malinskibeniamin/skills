---
title: /demo
description: Utwórz prezentację funkcji dla klientów i opublikuj ją w wersji roboczej PR.
type: skill
sidebar:
  label: /demo
---
![Diagram umiejętności /demo](/diagrams/skills/demo.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/demo.excalidraw)

Przekształć ukończoną pracę w prezentację wartości dla klienta, a nie raport o stanie prac deweloperskich. Przed utworzeniem artefaktu przeczytaj
[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/demo/REFERENCE.md).

## Kontrakt

1. Ustal żądany zakres. Domyślnie uwzględnij całą bieżącą gałąź lub PR od punktu wspólnego przodka,
   w tym zmiany zatwierdzone, dodane do indeksu, niedodane do indeksu oraz istotne nieśledzone pliki.
2. Wybierz najważniejszą korzyść widoczną dla klienta, którą potwierdza zmiana. Zbuduj jedną krótką
   historię wokół problemu klienta, jego działania i rezultatu.
3. Utwórz zatwierdzone artefakty w `demos/<slug>/`. Przy aktualizacji
   tej samej prezentacji używaj ponownie tego katalogu; nigdy nie rozmieszczaj wygenerowanych multimediów w różnych częściach repozytorium.
4. Preferuj kompozycję Remotion i wyrenderuj `demos/<slug>/output/demo.mp4`. Wykorzystaj rzeczywiste
   zrzuty produktu, jeśli zwiększają wiarygodność rezultatu.
5. Użyj wyrenderowanej sekwencji, stanu, przepływu lub diagramu architektury tylko wtedy, gdy występuje
   konkretny problem uniemożliwiający użycie Remotion albo animacja nie wnosi wartości dla klienta. Użyj Mermaid do
   prostego grafu, a `/excalidraw-diagram` do dopracowanego wizualnie objaśnienia przestrzennego. Zapisz
   powód.
6. Sprawdź reprezentatywne klatki lub cały diagram, popraw widoczne usterki i
   upewnij się, że nie zawierają żadnych sekretów, prywatnych danych ani danych osobowych klientów. Do każdego diagramu zastępczego
   dodaj zwięzły opis dostępności.
7. Nie edytuj żadnego pliku README. Zatwierdź prezentację, wypchnij bieżącą gałąź i utwórz wersję roboczą PR
   z nagraniem lub materiałem zastępczym podlinkowanym w treści. Zaktualizuj istniejący PR bez
   zmiany jego stanu przeglądu.
8. W systemie macOS pokaż nagranie za pomocą `open -R`. W innych systemach wyświetl jego bezwzględną ścieżkę oraz
   dokładne polecenie `cd` po wyświetleniu `pwd` dla katalogu wyjściowego.

## Ukończenie

Zwróć historię klienta, typ artefaktu, bezwzględną ścieżkę artefaktu, dowody renderowania lub walidacji,
powód użycia materiału zastępczego, jeśli ma zastosowanie, oraz adres URL wersji roboczej PR. Lokalny artefakt bez
żądanego PR oznacza zablokowane dostarczenie, a nie ukończenie.
