---
title: "/ux-performance"
description: "Audytuj i optymalizuj rzeczywistą wydajność UX aplikacji internetowych. Używaj w przypadku wolnych stron SPA, tras, interakcji, ogromnych tabel, ładowania, buforowania, pamięci, Web Vitals, Lighthouse, budżetów lub regresji CI."
type: skill
sidebar:
  label: "/ux-performance"
---
![Diagram umiejętności /ux-performance](/diagrams/skills/ux-performance.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/ux-performance.excalidraw)

Pozwól użytkownikowi szybciej osiągnąć użyteczny, responsywny stan. Optymalizuj zmierzoną
ścieżkę krytyczną, a nie kod, który jedynie wygląda na kosztowny. Domyślnie traktuj aplikację
jako klientową aplikację internetową; przechodź do warstwy dostarczania lub backendu tylko
wtedy, gdy dowody wskazują, że opóźniają one podróż użytkownika.

## Ustal kontrakt wydajności

Przed implementacją określ:

- **Podróż**: trasę, działanie, stan początkowy, ilość danych, klasę urządzenia i sieci oraz
  zimną lub ciepłą pamięć podręczną. Uwzględnij najgorsze wiarygodne obciążenie, nie tylko
  optymistyczny scenariusz.
- **Kamień milowy**: rezultat widoczny dla użytkownika, taki jak użyteczna treść, wyniki
  filtrowania lub następna narysowana klatka. Dodaj zabezpieczenia poprawności i dostępności.
- **Metrykę główną**: bezpośredni czas lub ograniczenie zasobów dla tego kamienia milowego.
- **Minimalną wartościową zmianę**: powtarzalna poprawa o 100 ms jest wartościowa; zmiana
  mieszcząca się w szumie nie jest. Przed edycją ustal jedną metrykę główną.
- **Punkt końcowy**: audyt, optymalizację lub instalację kontroli regresji. Audyt zwraca
  ustalenia bez edycji; optymalizacja trwa do zweryfikowanych zmian lokalnych; praca CI
  instaluje wyłącznie skalibrowane kontrole.

## Wykonaj pętlę

1. **Zinwentaryzuj** rzeczywisty stos, ścieżkę kompilacji produkcyjnej, istniejącą telemetrię,
   profilery, testy, budżety i wersje zainstalowanych pakietów. Przed zmianą składni frameworka
   lub biblioteki przeczytaj aktualną dokumentację źródłową.
2. **Zmierz stan bazowy przed zmianą kodu**. Odtwórz ten sam scenariusz i fixture w kompilacji
   zbliżonej do produkcyjnej. Gdy `.context/` jest ignorowany, zapisz surowe ślady w
   `.context/ux-performance/<journey>/`. Połącz dowody terenowe i laboratoryjne zgodnie z
   [MEASUREMENT.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/ux-performance/MEASUREMENT.md).
3. **Zbuduj waterfall** od intencji do narysowanego wyniku. Oznacz zależności szeregowe, pracę
   równoległą i poza ścieżką, stan pamięci podręcznej oraz najdłuższe odcinki ścieżki
   krytycznej. Przypisz czas do kolejkowania, sieci i TTFB, pobierania, parsowania i wykonania,
   pracy aplikacji, renderowania i zatwierdzania React, stylów, układu oraz rysowania.
4. **Uszereguj wąskie gardła**, nie ostrzeżenia audytu. Utwórz 3–5 falsyfikowalnych hipotez,
   a następnie zmieniaj po jednej zmiennej przyczynowej. Najpierw usuń pracę, zmniejsz dane
   wejściowe lub usuń zależność szeregową, zanim przyspieszysz tę samą pracę.
5. **Interweniuj** za pomocą najwęższej opcji popartej dowodami z
   [OPTIMIZATION.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/ux-performance/OPTIMIZATION.md). Wrapper, kontekst, pamięć podręczna, worker, kompilator,
   aktualizacja frameworka, prefetch lub renderowanie serwerowe to kandydaci, a nie domyślne zyski.
6. **Zweryfikuj** stan bazowy i kandydata przy tym samym scenariuszu, fixture, komputerze,
   przeglądarce, kompilacji i stanie pamięci podręcznej. Użyj sparowanych przebiegów; raportuj
   medianę i rozrzut. Ponownie sprawdź poprawność, dostępność, pamięć, bundle i błędy.
7. **Zdecyduj**. Zachowaj wyraźny, wartościowy zysk. Jeśli wynik mieści się w wariancji,
   przenosi koszt gdzie indziej lub pogarsza zabezpieczenie, zgłoś
   `Value not proven — inconclusive` i wycofaj spekulacyjną złożoność. Nie dobieraj metryk
   po poznaniu wyniku.
8. **Zapobiegaj nawrotom** tylko na żądanie lub gdy punkt końcowy obejmuje CI. Użyj
   [CI.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/ux-performance/CI.md), aby umieścić stabilne, tanie kontrole w pull requestach, hałaśliwe i głębokie kontrole nocą,
   a monitoring rzeczywistych użytkowników po wdrożeniu. Hooki są opcjonalne i doradcze,
   dopóki nie zostaną skalibrowane.

Gdy twierdzenie dotyczy skali, skoku obciążenia, rywalizacji o zasoby lub długiej sesji,
użyj [STRESS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/ux-performance/STRESS.md), aby znaleźć punkt załamania pojemności i zweryfikować poprawność pod presją.

## Wynik

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
