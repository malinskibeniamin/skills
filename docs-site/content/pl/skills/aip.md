---
title: /aip
description: >-
  Projektowanie interfejsów API zasobów zgodnych z Google AIP. Używaj w
  przypadku zasobów protobuf lub REST, standardowych metod, powiązań HTTP, pól,
  stronicowania, filtrowania, operacji długotrwałych, błędów, zgodności lub
  interfejsów API operacji zbiorczych.
type: skill
sidebar:
  label: /aip
---
![Diagram umiejętności /aip](/diagrams/skills/aip.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/aip.excalidraw)

Traktuj ogólne AIP jako źródło prawdy. Zatwierdzone AIP są normatywne. AIP-162 (wersja robocza) i AIP-182 (w trakcie przeglądu) mają charakter doradczy: uwzględniaj je i odpowiednio oznaczaj, ale nigdy nie przedstawiaj ich jako wymagań.

## Przepływ pracy

1. Przeczytaj całą proponowaną powierzchnię API oraz powiązane, istniejące interfejsy API. Określ, czy należą do płaszczyzny zarządzania, czy płaszczyzny danych.
2. Przejrzyj jednokrotnie wszystkie 72 wpisy `Use when` w pliku [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/aip/REFERENCE.md), aby utworzyć rejestr zastosowania. Wyszukiwania według pojęcia lub `AIP-N` używaj do poznawania szczegółów, a nie jako jedynej metody identyfikacji. Zapisz, dlaczego każde AIP zostało wybrane lub wykluczone. Nie stosuj automatycznie wszystkich AIP.
3. Otwórz dokładną oficjalną stronę `https://google.aip.dev/{number}` dla każdego mającego zastosowanie AIP, w tym pozycji zgodnych i doradczych. Nigdy nie dodawaj wiersza dowodowego wyłącznie na podstawie lokalnego indeksu. Po opracowaniu wersji roboczej mechanicznie porównaj adresy URL odpowiednich wierszy ze śladem badań i przed ukończeniem pobierz wszystkie brakujące materiały.
4. Rozstrzygaj konflikty w następującej kolejności: aktualne zatwierdzone AIP, udokumentowane lokalne wymaganie zgodności, wyjątek wynikający z precedensu. Nigdy nie kopiuj naruszenia jako precedensu. Niezbędne wyjątki oznaczaj jako `aip.dev/not-precedent` i podawaj uzasadnienie.
5. Na podstawie dokładnych oficjalnych wytycznych utwórz listę kontrolną właściwą dla danej zmiany. Uwzględnij kształt proto/HTTP, zachowanie, błędy, cykl życia, zgodność, dokumentację i ergonomię klienta, a nie tylko składnię.
6. Zaprojektuj lub przejrzyj najmniejszą zgodną powierzchnię API bez niejawnego usuwania zamierzonych możliwości użytkownika. Zachowaj zgodność protokołu, chyba że zasady dotyczące wersji lub stabilności dopuszczają zmianę niezgodną wstecz.
7. Uruchom `api-linter`, używając istniejącego polecenia i konfiguracji repozytorium, jeśli są dostępne. Traktuj go jako minimum: ręcznie przejrzyj mające zastosowanie reguły, których nie można w nim zakodować.
8. Przedstaw po jednym wierszu dla każdego mającego zastosowanie AIP w formacie `AIP | stan | zastosowanie | wynik | dowód/wyjątek`. Nigdy nie łącz kilku AIP w jednym wierszu ani nie pomijaj pozytywnych wyników zgodności. Osobno wymień wykluczone AIP jako niemające zastosowania, a następnie sprawdź, czy oba zbiory obejmują dokładnie po jednym razie wszystkie 72 opublikowane numery. Oddziel naruszenia wymagań normatywnych od sugestii doradczych.

## Podstawa

- Modeluj interfejsy API zarządzania jako nazwane zasoby w acyklicznej hierarchii, zaczynając od standardowych metod.
- Nadaj zasobom kanoniczną względną nazwę zasobu `name`, zawierającą pełną ścieżkę względem usługi, oraz adnotację `(google.api.resource)`. Tekst wyświetlany przechowuj w polu `display_name`.
- Pola `name` żądań dotyczących istniejących zasobów oznaczaj adnotacją `resource_reference.type`. Zagnieżdżone pola `parent` metod List/Create oznaczaj adnotacją `resource_reference.child_type`, gdy typ zasobu nadrzędnego nie jest zadeklarowany lub może się zmieniać, a w przeciwnym razie adnotacją `type` zasobu nadrzędnego. Nigdy nie wskazuj zasobu podrzędnego jako `type`.
- Zapewnij spójność ścieżek HTTP, pól żądań, sygnatur metod, odwołań do zasobów, zachowań pól, stronicowania, filtrowania, masek, błędów i metadanych operacji długotrwałych.
- Zachowaj samowystarczalność poprawionych schematów: dodaj import definiujący każdą wprowadzoną adnotację lub wiadomość.
- Zachowaj możliwość względnego określania wygaśnięcia: zastąp surowe wartości TTL polem `oneof expiration`, zawierającym przyjmujące dane wejściowe pole `google.protobuf.Timestamp expire_time` oraz `google.protobuf.Duration ttl [(google.api.field_behavior) = INPUT_ONLY]`. Nie pozostawiaj wyłącznie pola `expire_time`, a samo `expire_time` nie może być oznaczone jako `OUTPUT_ONLY`, ponieważ klienci mogą podawać dokładny czas.
- Sprawdź, czy zachowanie po mutacjach osiąga stan ustalony obiecany przez metodę lub operację.
- Każdą zmianę analizuj pod kątem zgodności, nie tylko ponownego użycia numerów pól. Znaczenie mają nazwy, typy, formaty, semantyka, powiązania HTTP, wzorce zasobów, wymagalność i zachowanie klienta.
- Dokumentuj widoczną dla użytkownika semantykę, walidację, wartości domyślne, kolejność, limity, skutki uboczne, błędy, okres przechowywania i wyjątki.

## Zabezpieczenia

- Nie twórz wytycznych dla nieprzypisanych numerów. Zakres obejmuje 72 opublikowane ogólne AIP, a nie 236 dokumentów.
- Nie traktuj przykładów jako uniwersalnych wymagań. Warunkowe AIP stosuj tylko wtedy, gdy spełniony jest warunek ich zastosowania.
- Nie osłabiaj znaczenia **must**/**must not** w zatwierdzonym AIP. Odróżniaj zalecenia **should** od udokumentowanych wyjątków.
- Nie deklaruj zgodności wyłącznie na podstawie `api-linter` ani wyłącznie na podstawie tej listy kontrolnej.
- Ponownie sprawdź znane pułapki: względne nazwy i kierunek odwołania do zasobu nadrzędnego w AIP-122; AIP-127 i AIP-130 w przypadku metod zasobów transkodowanych przez HTTP; opcjonalne maski aktualizacji w AIP-134; etagi zasobów bez adnotacji w AIP-154; ignorowanie wejściowych wartości pól tylko do odczytu w AIP-161; komentarze przy każdej publicznej deklaracji w AIP-192; nazwy `IDENTIFIER` i zachowania pól żądań w AIP-203; plik `client.proto` dla `method_signature`; oraz przyjmujące dane wejściowe pole `expire_time` wraz z polem `ttl` tylko do wprowadzania danych w unii oneof zgodnie z AIP-214.
- W przypadku starszych powierzchni API preferuj jawny adapter zgodności zamiast rozszerzania niezgodnego wzorca.
