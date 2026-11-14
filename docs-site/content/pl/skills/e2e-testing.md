---
description: >-
  Używaj podczas pisania lub naprawiania testów Playwright E2E, fixture’ów,
  testów przeglądarkowych albo niestabilnych testów.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - e2e testing
sidebar:
  label: /e2e-testing
title: /e2e-testing
type: skill
---
![Diagram umiejętności /e2e-testing](/diagrams/skills/e2e-testing.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/e2e-testing.excalidraw)

Przed wyborem aktualnych API Playwright, Testcontainers, axe-core lub przeglądarki użyj
`/read-the-damn-docs`. Konfiguracja należy do [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SETUP.md).

## Konwencje [#conventions]

- Testy E2E umieszczaj w `e2e/*.spec.ts`; nazwy plików pochodzą od funkcji.
- Selektory: `getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS.
- Test IDs mają postać `{feature}-{element}` z opcjonalnym indeksem lub stanem.
- Hook testów sąsiadujących z trasą uruchamia pobliskie testy przeglądarkowe lub integracyjne po edycji trasy.
- Hook refaktoryzacji strukturalnej wymaga testu dla nowych stron lub wydzielonych komponentów.

## Dostępność i przeglądarki [#accessibility-and-browsers]

Uruchamiaj axe na każdej stronie, ale automatyczne testy dostępności wykrywają tylko część problemów.
Sam axe nie potwierdza poprawnej kolejności nawigacji klawiaturą, fokusu, nazw, zoomu ani działania technologii asystujących.

W PR-ach uruchamiaj pełny zestaw w Chromium. Oznacz krytyczne ścieżki i wiarygodne ryzyka silnika
tagiem `@cross-browser`; uruchom je w Firefox i WebKit. Pełną macierz zostaw na nocne
uruchomienia lub bramkę wydania. Emulacja nie pozwala zweryfikować działania w każdej przeglądarce konkretnej marki ani na każdym fizycznym urządzeniu.

## Determinizm [#determinism]

- Czekaj na przyczyny, nie czas. Rejestruj obietnice żądania, odpowiedzi i renderu przed
  akcją. Po `waitForURL` sprawdź punkt orientacyjny strony docelowej. Zakazane są `waitForTimeout` i
  `expect.soft` wewnątrz `toPass`.
- Wyścig nawigacji testuj przez opóźnienie A, rozpoczęcie A, przejście do B i potwierdzenie stanu
  i skutków B oraz braku A.
- Terminy debounce i anulowanie udowadniaj przez fake timers poniżej E2E; E2E sprawdza widoczny
  wynik bez uśpienia.
- Nie używaj `force: true`; napraw przeszkodę spotykaną przez użytkownika.
- Dopasuj trasę RPC po `Service/Method`, bez prefiksu wersji.
- Otaczaj logiczne akcje `test.step()`, aby CI wskazało nieudany krok.
- W trybie testowym utrzymuj ulotny interfejs, ale sprawdzaj trwałe skutki zamiast tekstu toasta.
- Specyfikacje schowka i uprawnień uruchamiaj w Chromium; gdzie indziej pokryj równoważny wynik.
- Buforuj logi backendu lub kontenera przez teardown i przechwytuj awarie startu. Maskuj sekrety.
- Jedno ponowienie w CI jest tylko tymczasowe, celem jest zero. Lokalnie preferuj zwięzły reporter.
- Usuń testy samego renderu; każda ścieżka sprawdza skutek działania użytkownika.

## Eksploracja generowana i długotrwała [#generated-and-long-lived-exploration]

Dla kombinatorycznych kontraktów klienta, których nie można taniej udowodnić, użyj wąskich generowanych
sekwencji akcji lub właściwości stanowej. Stosuj
[PROPERTY-BASED-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/tdd/PROPERTY-BASED-TESTING.md): zachowaj niezależne orakulum i
ziarno odtworzenia, a prawdziwe znaleziska przekształcaj w deterministyczne testy regresji. To uzupełnia stałe
ścieżki, testy między przeglądarkami, dostępność, przegląd wizualny i dogfood.

Dla wzrostu listenerów, DOM, timerów, subskrypcji lub sterty w jednym kontekście przeglądarki użyj
[SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SOAK-TESTING.md). Izolowane E2E nie dowodzą czasu życia zasobów.

## Dowody i narzędzia [#evidence-and-tools]

Monitoruj `bun run test:e2e`; reaguj na awarie przed zakończeniem.

Przy wyborze narzędzia do interaktywnej automatyzacji stosuj [wytyczne dotyczące przeglądarki i danych](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md#browser-and-data-tasks).
Agent-browser jest domyślnym interaktywnym CLI, gdy jego użycie jest dozwolone, a nie narzędziem uruchamiającym testy Playwright Test w CI.
Zapisane przepływy nie zastępują asercji UI; zachowaj pokrycie testami przeglądarkowymi, dostępności i między przeglądarkami.

| Potrzeba | Narzędzie |
|---|---|
| CI/zestaw testów | Playwright Test |
| Selektor lub inspekcja AI | `agent-browser snapshot` |
| Dowody z wizualnego smoke testu | `agent-browser screenshot --annotate` |
| Interaktywne debugowanie | Tryb UI Playwright |

W przypadku eksperymentów z Browser Use zleconych przez użytkownika przeczytaj
[BROWSER-USE.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/BROWSER-USE.md).
Wymagania projektu i środowiska dotyczące przeglądarki nadal mają pierwszeństwo.
