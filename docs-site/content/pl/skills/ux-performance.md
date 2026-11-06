---
description: >-
  Audytuj i optymalizuj rzeczywistą wydajność UX aplikacji internetowych. Używaj
  w przypadku wolnych stron SPA, tras, interakcji, ogromnych tabel, ładowania,
  buforowania, pamięci, Web Vitals, Lighthouse, budżetów lub regresji CI.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - ux performance
sidebar:
  label: /ux-performance
title: /ux-performance
type: skill
---
![Diagram umiejętności /ux-performance](/diagrams/skills/ux-performance.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/ux-performance.excalidraw)

Pozwól użytkownikowi szybciej osiągnąć użyteczny, responsywny stan. Optymalizuj zmierzoną
ścieżkę krytyczną, a nie kod, który jedynie wygląda na kosztowny. Domyślnie traktuj aplikację
jako klientową aplikację internetową; przechodź do warstwy dostarczania lub backendu tylko
wtedy, gdy dowody wskazują, że opóźniają one podróż użytkownika.

## Ustal kontrakt wydajności [#contract]

Przed implementacją określ:

- **Podróż**: trasę, działanie, stan początkowy, ilość danych, klasę urządzenia i sieci oraz
  zimną lub ciepłą pamięć podręczną. Uwzględnij najgorsze wiarygodne obciążenie, nie tylko
  optymistyczny scenariusz.
- **Kamień milowy**: rezultat widoczny dla użytkownika, taki jak użyteczna treść, wyniki
  filtrowania lub następna narysowana klatka. Dodaj zabezpieczenia poprawności i dostępności.
  Zachowaj zamierzone animacje, branding, interakcje i semantykę danych za pomocą [asercji zgodności funkcji](https://github.com/malinskibeniamin/skills/blob/main/shared/verification-replay.md).
- **Metrykę główną**: bezpośredni czas lub ograniczenie zasobów dla tego kamienia milowego.
- **Minimalną wartościową zmianę**: ustal ją przed edycją i respektuj żądaną skalę
  (1% to nie 10x). Powtarzalna poprawa o 100 ms może mieć znaczenie.
- **Punkt końcowy**: audyt, optymalizację lub instalację kontroli regresji. Audyt zwraca
  ustalenia bez edycji; optymalizacja obejmuje zweryfikowane zmiany aż do żądanego etapu dostarczenia; praca CI
  instaluje wyłącznie skalibrowane kontrole.

Dla optymalizacji przed edycją przeczytaj wspólną [pętlę eksperymentów](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/REFERENCE.md#optimization-experiments).
Określa pierwotny i zaakceptowany stan bazowy, decyzje o zachowaniu lub wycofaniu zmian,
równoważność wyników, listę tropów oraz raportowanie prób. Szczegóły wykonania sprawdzaj w instrukcji wybranego narzędzia.

## Wykonaj pętlę [#loop]

1. **Zinwentaryzuj** rzeczywisty stos, ścieżkę kompilacji produkcyjnej, istniejącą telemetrię,
   profilery, testy, budżety i wersje zainstalowanych pakietów. Przed zmianą składni frameworka
   lub biblioteki przeczytaj aktualną dokumentację źródłową.
2. **Zmierz stan bazowy przed zmianą kodu**. Odtwórz ten sam scenariusz i fixture w kompilacji
   zbliżonej do produkcyjnej. Zachowaj pierwotną kompilację i surowe ślady w ignorowanym lub
   tymczasowym miejscu. Połącz dowody terenowe i laboratoryjne zgodnie z
   [MEASUREMENT.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/MEASUREMENT.md).
3. **Zbuduj waterfall** od intencji do narysowanego wyniku. Oznacz zależności szeregowe, pracę
   równoległą i poza ścieżką, stan pamięci podręcznej oraz najdłuższe odcinki ścieżki
   krytycznej. Przypisz czas do kolejkowania, sieci i TTFB, pobierania, parsowania i wykonania,
   pracy aplikacji, renderowania i zatwierdzania React, stylów, układu oraz rysowania.
4. **Uszereguj wąskie gardła** i sformułuj falsyfikowalne hipotezy. Przed strojeniem usuń
   pracę, zmniejsz dane wejściowe lub usuń zależność szeregową. Zmieniaj po jednej zmiennej
   przyczynowej.
5. **Wybierz optymalizację opartą na pomiarach** z
   [OPTIMIZATION.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/OPTIMIZATION.md). Gdy ograniczeniem jest CPU, alokacja lub lokalność dostępu do pamięci,
   zastosuj [przeprojektowanie zorientowane na dane](https://github.com/malinskibeniamin/skills/blob/main/shared/data-oriented-performance.md), zanim dodasz buforowanie lub przeniesiesz pracę poza główny wątek.
6. **Zweryfikuj** stan bazowy i kandydata przy tym samym scenariuszu, fixture, komputerze,
   przeglądarce, kompilacji i stanie pamięci podręcznej. Użyj sparowanych przebiegów; raportuj
   medianę i rozrzut. Ponownie sprawdź poprawność, dostępność, pamięć, bundle i błędy.
7. **Zdecyduj**. Zachowaj wartościowy zysk. Wycofaj własne przegrywające lub nierozstrzygnięte
   eksperymenty; odróżniaj `Value not proven - inconclusive` od zmierzonej regresji.
   Przed raportowaniem łącznego zysku odśwież listę tropów i końcowe kontrole równoważności wyników.
   Nie dobieraj metryk po poznaniu wyniku.
8. **Zapobiegaj nawrotom** tylko na żądanie lub gdy punkt końcowy obejmuje CI. Użyj
   [CI.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/CI.md), aby umieścić stabilne, tanie kontrole w pull requestach, hałaśliwe i głębokie kontrole nocą,
   a monitoring rzeczywistych użytkowników po wdrożeniu. Hooki są opcjonalne i doradcze,
   dopóki nie zostaną skalibrowane.

Gdy twierdzenie dotyczy skali, skoku obciążenia, rywalizacji o zasoby lub długiej sesji,
użyj [STRESS.md](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/STRESS.md), aby znaleźć punkt załamania pojemności i zweryfikować poprawność pod presją.

## Wynik [#output]

Zacznij od rezultatu użytkownika i najwolniejszego odcinka:

```md
Verdict: <zmierzony stan lub ocena wartości>

| Ranga | Wąskie gardło | Koszt ścieżki krytycznej | Dowód | Następna zmiana | Pewność |
|---:|---|---:|---|---|---|
| 1 | <przyczyna, nie objaw> | <ms/bajty/praca> | <ślad/profil> | <mała interwencja> | <wysoka/średnia/niska> |

Method: <dokładne polecenie, kompilacja, fixture, pamięć podręczna, urządzenie/sieć, przebiegi, baza/kandydat>
Guardrails: <poprawność, dostępność, błędy, pamięć, bundle>
Artifacts: <ścieżki lub linki>
```

Oddziel zmierzone fakty, wnioski i niesprawdzone możliwości. Nigdy nie deklaruj przyspieszenia
wyłącznie na podstawie wyniku Lighthouse, ostrzeżenia statycznego, pozornie mniejszego kodu
lub zaktualizowanej zależności.

Dla porównań paczek wynikowych lub nieoczekiwanych modułów wczytaj [analizę paczki wynikowej](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/bundle-analysis/SKILL.md). Oddzielaj dane do badań od stałych limitów i używaj rzeczywistej kompilacji produkcyjnej.

Przy hipotezie dotyczącej kosztu renderowania w React przeczytaj [inspekcję React w czasie działania](https://github.com/malinskibeniamin/skills/blob/main/shared/react-devtools.md). Opcjonalne ślady komponentów i commitów służą do lokalizacji pracy, nie jako dowód wydajności UX w produkcji.
