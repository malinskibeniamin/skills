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


Natychmiast pokaż wartość, bez pozorowanych testów porównawczych. Każde utworzenie lub zaktualizowanie PR automatycznie uruchamia tę ocenę za pośrednictwem `/commit-push-pr` lub `/stacked-prs`; zakres pomiarów pozostaje proporcjonalny.

## Przebieg

1. **Ocena możliwości zebrania dowodów:** przeprowadzaj test porównawczy tylko wtedy, gdy tania bezpośrednia metryka może przekroczyć zadeklarowaną wcześniej minimalną wartościową różnicę i normalną zmienność. Drobne zmiany dotyczące wyłącznie treści, stylu lub testów wymagają zdania o wartości. Bez pozorowanych testów porównawczych.
2. **Ustal tezę przed rozpoczęciem kodowania:** określ tezę, główną metrykę, kryterium ochronne, scenariusz oraz minimalną wartościową różnicę. Nie wybieraj zwycięskiej metryki po fakcie.
3. **Obszar produktu + obszar bazy kodu:** jeden musi się poprawić, a drugi nie może ulec istotnemu pogorszeniu.
   - Produkt: możliwości, powodzenie zadania, odtworzenie błędu, błędy, liczba kroków, opóźnienie, zasoby.
   - Baza kodu: zakres utrzymania, złożoność, zależności, ostrzeżenia, wycieki, rozmiar pakietu, koszt kompilacji lub testów, testowalność.
4. **Proporcjonalny rygor:** zdanie w przypadku oczywistej wartości; deterministyczne odtworzenie lub zliczenie w przypadku poprawności; kontrolowany test porównawczy par według [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/REFERENCE.md) w przypadku czasu działania; jawne deklaracje poprawy wydajności zawsze wymagają pomiaru.
5. **Dane bazowe:** wykonaj pomiar przed rozpoczęciem kodowania lub odtwórz stan punktu wspólnego scalania. Użyj tego samego scenariusza, zestawu danych, konfiguracji i tej samej maszyny dla wersji bazowej i kandydującej.
6. **Porównanie:** tylko metryki przekraczające próg obejmują surowe wartości przed zmianą i po niej, różnicę bezwzględną i procentową, metodę, środowisko oraz poziom szumu. Pomiń liczby poniżej progu lub mieszczące się w granicach normalnej zmienności. Testy niezmienników ani wskaźniki zastępcze nie są dowodami poprawy wydajności.
7. **Decyzja:**
   - Wartościowa poprawa: `Value proven`.
   - Niejednoznaczna lub pomijalna jawna deklaracja poprawy wydajności: `Value not proven`; bez minimalnych różnic ani dobierania metryk pod oczekiwany wynik. Dopuść jedną korektę opartą na dowodach, a następnie porzuć zmiany lub zamknij PR.
   - Brak przydatnej metryki i brak deklaracji poprawy wydajności: zwykłe podsumowanie wartości, bez artefaktu wpływu.
   - Pogorszenie: napraw, zawęź zakres lub zatrzymaj prace.

Zastosuj ten sam filtr do kryteriów ochronnych; pomiń pomijalne zmiany.

## Treść PR

Zawsze podaj zwięzły punkt dotyczący wpływu: co poprawiło się dla użytkownika lub osoby utrzymującej kod oraz jakie są na to dowody. Drobne zmiany dotyczące treści lub stylu wymagają zdania o wartości powiązanego z wizualnymi dowodami stanu przed zmianą i po niej, a nie wymyślonej metryki. Tylko gdy dowody przekraczają próg, zastąp ten punkt następującą treścią:

```md
## Proven impact
| Metric | Before | After | Delta |
|---|---:|---:|---:|
| <direct metric> | <base> | <candidate> | <absolute and %> |
**Value proven:** <product or codebase benefit>
Method: `<command, fixture, runs, environment>`.
```

Przekaż ją bezpośrednio do treści PR za pośrednictwem `/commit-push-pr` lub `/stacked-prs`; osobna prośba o ułatwienie przeglądu nie jest potrzebna. `/make-pr-easy-to-review` wykorzystuje ją ponownie, gdy zostanie jawnie wywołana. Pominięte surowe dane zachowaj wyłącznie w lokalnym artefakcie dowodowym, jeśli są potrzebne do zapewnienia powtarzalności. Nigdy nie dodawaj pustej tabeli; w przypadku jawnych, niepotwierdzonych deklaracji poprawy wydajności podaj `Value not proven` bez pomijalnych liczb.
