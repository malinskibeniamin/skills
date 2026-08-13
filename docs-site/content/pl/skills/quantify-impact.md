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

1. **Ocena możliwości zebrania dowodów**: sprawdź, czy istnieje bezpośrednia metryka przydatna przy podejmowaniu decyzji i czy jej uzyskanie jest wystarczająco tanie dla danej zmiany. Metryka jest przydatna przy podejmowaniu decyzji tylko wtedy, gdy może przekroczyć zadeklarowaną wcześniej minimalną wartościową różnicę, a w przypadku pomiarów obarczonych szumem również normalną zmienność. Przeprowadzaj test porównawczy tylko wtedy, gdy odpowiedź brzmi „tak”. Drobne zmiany dotyczące wyłącznie treści, stylu lub testów wymagają jednego jasnego zdania o wartości, a nie wymuszonych liczb. Bez pozorowanych testów porównawczych.
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
6. **Porównuj rzetelnie**: w przypadku metryk, które przekraczają zadeklarowany wcześniej próg, podaj surowe wartości przed zmianą i po niej, różnicę bezwzględną i procentową, metodę, środowisko oraz poziom szumu. Pomiń metryki poniżej tego progu lub mieszczące się w granicach normalnej zmienności; sam pomiar liczby nie czyni jej istotną. Nigdy nie przedstawiaj testu niezmienników ani wskaźnika zastępczego jako dowodu poprawy wydajności.
7. **Podejmij decyzję**:
   - Wyraźna, wartościowa poprawa: `Value proven`.
   - Jawna deklaracja poprawy wydajności z niejednoznacznym, pomijalnym wynikiem lub bez poprawy: `Value not proven`; pomiń minimalne różnice i nie dobieraj metryk pod oczekiwany wynik.
   - Brak jawnej deklaracji poprawy wydajności i brak wartościowej metryki: pomiń ilościowe zestawienie wpływu i użyj zwykłego podsumowania wartości.
   - Pogorszenie: napraw, zawęź zakres lub zatrzymaj prace.

Zastosuj ten sam filtr do kryteriów ochronnych. Całkowicie pomiń pomijalne zmiany kryteriów ochronnych; nie pokazuj ich surowych wartości ani nie dodawaj wiersza `Guardrail held` tylko po to, aby je uwzględnić.

## Treść PR

Gdy przydatne dowody przekraczają zadeklarowany wcześniej próg, przekaż `/make-pr-easy-to-review`:

```md
## Proven impact

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| <direct metric> | <base> | <candidate> | <absolute and %> |

**Value proven:** <product or codebase benefit>

Method: `<exact command, fixture, run count, environment>`.
```

Filtruj poszczególne wiersze: uwzględniaj tylko różnice przydatne przy podejmowaniu decyzji. Surowe wyniki pominiętych pomiarów zachowaj w lokalnym artefakcie dowodowym, jeśli są przydatne dla powtarzalności, a nie w treści PR.

Brak możliwości zebrania istotnych dowodów lub brak metryki powyżej progu: użyj zwykłego podsumowania wartości; nie dodawaj pustej tabeli. W przypadku jawnej deklaracji poprawy wydajności podaj `Value not proven` bez publikowania pomijalnych liczb.
