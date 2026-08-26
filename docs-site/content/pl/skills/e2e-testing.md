---
title: /e2e-testing
description: "Używaj podczas pisania lub naprawiania testów Playwright E2E, fixture’ów, testów przeglądarkowych albo flaków."
type: skill
sidebar:
  label: /e2e-testing
---
![Diagram umiejętności /e2e-testing](/diagrams/skills/e2e-testing.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/e2e-testing.excalidraw)

Przed wyborem aktualnych API Playwright, Testcontainers, axe-core lub przeglądarki użyj `/read-the-damn-docs`. Konfiguracja należy do [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SETUP.md).

## Konwencje

- Testy E2E umieszczaj w `e2e/*.spec.ts`; nazwy plików pochodzą od funkcji.
- Selektory: `getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS.
- Test IDs mają postać `{feature}-{element}` z opcjonalnym indeksem lub stanem.
- Hook testu sąsiedniego trasy uruchamia pobliskie testy przeglądarkowe lub integracyjne po edycji trasy.
- Hook refaktoryzacji strukturalnej wymaga testu dla nowych stron lub wydzielonych komponentów.

## Dostępność i przeglądarki

Uruchamiaj axe na każdej stronie, ale automatyczna dostępność pokrywa tylko część problemów. Sam axe nie dowodzi kolejności klawiatury, fokusu, nazw, zoomu ani działania technologii asystujących.
W PR-ach uruchamiaj pełny zestaw w Chromium. Oznacz krytyczne ścieżki i wiarygodne ryzyka silnika tagiem `@cross-browser`; uruchom je w Firefox i WebKit. Pełną macierz zostaw na nocny tor lub bramkę wydania. Emulacja nie dowodzi każdego ryzyka przeglądarki lub urządzenia.

## Determinizm

- Czekaj na przyczyny, nie czas. Rejestruj obietnice żądania, odpowiedzi i renderu przed akcją. Po `waitForURL` sprawdź punkt orientacyjny strony. Zakazane są `waitForTimeout` i `expect.soft` wewnątrz `toPass`.
- Wyścig nawigacji testuj przez opóźnienie A, rozpoczęcie A, przejście do B i potwierdzenie stanu B oraz braku A.
- Terminy debounce i anulowanie udowadniaj przez fake timers poniżej E2E; E2E sprawdza wynik bez uśpienia.
- Nie używaj `force: true`; napraw przeszkodę spotykaną przez użytkownika.
- Dopasuj trasę RPC po `Service/Method`, bez prefiksu wersji.
- Otaczaj logiczne akcje `test.step()`, aby CI wskazało nieudany krok.
- W trybie testowym utrzymuj ulotny interfejs, ale sprawdzaj trwałe skutki zamiast tekstu toasta.
- Specyfikacje schowka i uprawnień uruchamiaj w Chromium; gdzie indziej pokryj równoważny wynik.
- Buforuj logi backendu lub kontenera przez teardown i przechwytuj awarie startu. Redaguj sekrety.
- Jedno ponowienie w CI jest tylko tymczasowe, celem jest zero. Lokalnie preferuj zwięzły reporter.
- Usuń testy samego renderu; każda ścieżka wywołuje skutek użytkownika.

## Eksploracja generowana i długotrwała

Dla kombinatorycznych kontraktów klienta, których nie można taniej udowodnić, użyj wąskich generowanych sekwencji akcji lub właściwości stanowej. Stosuj [PROPERTY-BASED-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/PROPERTY-BASED-TESTING.md): niezależne orakulum, ziarno odtworzenia i deterministyczne regresje dla prawdziwych znalezisk. To uzupełnia stałe ścieżki, testy między przeglądarkami, dostępność, przegląd wizualny i dogfood.
Dla wzrostu listenerów, DOM, timerów, subskrypcji lub sterty w jednym kontekście przeglądarki użyj [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SOAK-TESTING.md). Izolowane E2E nie dowodzą czasu życia zasobów.

## Dowody i narzędzia

Monitoruj `bun run test:e2e`; reaguj na awarie przed zakończeniem.

| Potrzeba | Narzędzie |
|---|---|
| CI/zestaw testów | Playwright |
| Selektor lub inspekcja AI | `agent-browser snapshot` |
| Wizualny smoke test | `agent-browser screenshot --annotate` |
| Interaktywne debugowanie | Tryb UI Playwright |
