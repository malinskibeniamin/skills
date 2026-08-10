---
title: /quantify-impact
description: >-
  Zmierz, czy zmiana znacząco ulepszyła produkt lub bazę kodu. Użyj, gdy
  powtarzalne dowody pomogą ocenić, czy warto scalić funkcję, poprawkę,
  refaktoryzację lub aktualizację.
type: skill
sidebar:
  label: /quantify-impact
---
![Diagram umiejętności /quantify-impact](/diagrams/skills/quantify-impact.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/quantify-impact.excalidraw)

Natychmiast pokaż wartość, bez pozorowanych testów porównawczych. To wskazówka, a nie bezwzględny warunek scalenia. Istniejące umiejętności przepływu pracy wywołują ją automatycznie; użytkownicy nie muszą robić tego samodzielnie.

## Przebieg

1. **Ocena możliwości zebrania dowodów**: sprawdź, czy istnieje bezpośrednia metryka przydatna przy podejmowaniu decyzji i czy jej uzyskanie jest wystarczająco tanie dla danej zmiany. Przeprowadzaj test porównawczy tylko wtedy, gdy odpowiedź brzmi „tak”. Drobne zmiany dotyczące wyłącznie treści, stylu lub testów wymagają jednego jasnego zdania o wartości, a nie wymuszonych liczb. Bez pozorowanych testów porównawczych.
2. **Ustal tezę przed rozpoczęciem kodowania**: przed implementacją lub edycją określ tezę zmiany, główną metrykę, kryterium ochronne, scenariusz oraz minimalną wartościową różnicę. Nie wybieraj zwycięskiej metryki po fakcie.
3. **Użyj dwóch obszarów wartości**:
   Obszar produktu + obszar bazy kodu: jeden musi się poprawić, a drugi nie może ulec istotnemu pogorszeniu.
   - **Obszar produktu**: możliwości, powodzenie zadania, odtworzenie błędu, błędy, liczba kroków, opóźnienie lub koszt zasobów.
   - **Obszar bazy kodu**: zakres utrzymania, złożoność, zależności, ostrzeżenia, wycieki, rozmiar pakietu, koszt kompilacji lub testów albo testowalność.
   Poprawa jakości kodu może być główną wartością.
4. **Dobierz proporcjonalny rygor**:
   - Drobna lub oczywista zmiana: tylko zdanie o wartości.
   - Poprawność lub dokładna liczba: deterministyczne odtworzenie albo zliczenie przed zmianą i po niej.
   - Czas działania lub wydajność: kontrolowany test porównawczy par według [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/REFERENCE.md).
   - Jawna deklaracja poprawy wydajności: zawsze wykonaj pomiar.
5. **Zbierz dane bazowe**: jeśli to możliwe, wykonaj pomiar przed rozpoczęciem kodowania. W przeciwnym razie dokładnie odtwórz stan punktu wspólnego scalania. Uruchom wersję bazową i kandydującą z tym samym scenariuszem, zestawem danych, konfiguracją i na tej samej maszynie.
6. **Porównuj rzetelnie**: podaj surowe wartości przed zmianą i po niej, różnicę bezwzględną i procentową, metodę, środowisko oraz poziom szumu. Nigdy nie przedstawiaj testu niezmienników ani wskaźnika zastępczego jako dowodu poprawy wydajności.
7. **Podejmij decyzję**:
   - Wyraźna, wartościowa poprawa: `Wartość potwierdzona`.
   - Niejednoznaczny wynik lub brak poprawy: `Wartość niepotwierdzona`; nie dobieraj metryk pod oczekiwany wynik. Dopuść jedną korektę opartą na dowodach, a następnie zaleć porzucenie zmiany lub zamknięcie PR.
   - Pogorszenie: napraw, zawęź zakres lub zatrzymaj prace.

## Treść PR

Gdy dostępne są przydatne dowody, przekaż `/make-pr-easy-to-review`:

```md
## Proven impact

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| <direct metric> | <base> | <candidate> | <absolute and %> |

**Value proven:** <product or codebase benefit>

Method: `<exact command, fixture, run count, environment>`.
```

Jeśli nie ma możliwości zebrania istotnych dowodów, użyj zwykłego podsumowania wartości; nie dodawaj pustej tabeli.
