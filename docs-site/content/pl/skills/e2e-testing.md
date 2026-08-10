---
title: /e2e-testing
description: >-
  Wzorce E2E z użyciem Playwright, Testcontainers i axe-core dla formularzy,
  tabel oraz przepływów pracy. Używaj podczas pisania lub naprawiania
  specyfikacji E2E, fixture’ów i testów przeglądarkowych oraz debugowania
  niestabilnych uruchomień Playwright.
type: skill
sidebar:
  label: /e2e-testing
---
![Diagram umiejętności /e2e-testing](/diagrams/skills/e2e-testing.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/e2e-testing.excalidraw)

Uruchom `/read-the-damn-docs` przed przypięciem bieżących interfejsów API Playwright, Testcontainers, axe-core lub narzędzi przeglądarkowych.
## Konwencje

- `e2e/*.spec.ts` -- wszystkie testy E2E używają rozszerzenia `.spec.ts`
- Nazywaj według funkcji: `login.spec.ts`, `create-topic.spec.ts`
- Selektory: `getByRole` > `getByLabel` > `getByText` > `getByTestId` > CSS
- Identyfikatory testowe: `{feature}-{element}`, `{feature}-{element}-{index}`, `{feature}-{state}`

## Hooki podczas edycji

- **test powiązany z trasą**: gdy zmienia się trasa lub plik `*.page.tsx`, uruchom powiązany test `*.browser.test.*` lub `*.integration.test.*`; zablokuj zmianę, jeśli test się nie powiedzie.
- **przypomnienie o teście przy refaktoryzacji strukturalnej**: nowy plik `*.page.tsx` lub wydzielony plik komponentu wymaga dołączenia testu `.test`, `.integration.test` lub `.browser.test`.

## Dostępność -- axe na każdej stronie

```ts
import { test, expect } from '../fixtures/base'
test('page is accessible', async ({ page, makeAxeBuilder }) => {
  await page.goto('/topics/create')
  const results = await makeAxeBuilder().analyze()
  expect(results.violations).toEqual([])
})
```

## Zasady deterministyczności (wypracowane przez lata naprawiania niestabilnych testów)

- **Czekaj na przyczynę, nigdy przez określony czas**: `waitForURL()` po kliknięciach powodujących nawigację, `waitForResponse()`/`waitForRequest()` przed sprawdzaniem interfejsu sterowanego przez RPC, a w pozostałych przypadkach oczekiwanie na stan elementu. Bez `waitForTimeout`; bez `expect.soft` wewnątrz `toPass` (miękkie błędy nigdy nie powodują ponowienia bloku).
- **Zachowania czasowe należy testować poniżej poziomu E2E**: terminy debounce/opóźnień i anulowanie sprawdzaj za pomocą fałszywych timerów w testach jednostkowych lub integracyjnych; E2E sprawdza widoczny rezultat bez usypiania.
- **Bez kliknięć z `force: true`** -- jeśli element wymaga wymuszenia, coś go zasłania, a użytkownicy napotkają tę samą przeszkodę; usuń ją.
- **Dopasowuj trasy RPC wyłącznie na podstawie `Service/Method`**, nigdy według przypiętej wersji (`v1alpha1` w regule dopasowania przestanie działać po kolejnym podniesieniu wersji API).
- **Obejmuj każdą logiczną czynność blokiem `test.step()`** -- wynik błędu w CI wskaże wtedy dokładny krok; im mniejszy krok, tym szybsza diagnoza.
- **Efemeryczny interfejs**: uruchamiaj zestaw z flagą trybu testowego, która zapobiega automatycznemu znikaniu powiadomień; sprawdzaj skutki uboczne (wysłano żądanie, pojawił się wiersz), a nie tekst powiadomienia.
- **Specyfikacje zależne od schowka lub uprawnień uruchamiaj wyłącznie w Chromium** (modele uprawnień w Firefox i WebKit są inne).
- **Możliwość debugowania jest częścią testu**: buforuj logi backendu lub kontenera, aby przetrwały sprzątanie; w razie błędu `start()` przechwyć logi przed przerwaniem. Usuwaj sekrety i tokeny ze zrzutów błędów.
- Ponowienia: 1 w CI jako rozwiązanie tymczasowe, docelowo 0; specyfikacja wymagająca ponowień zawiera błąd oczekiwania. Lokalnie preferuj reporter Markdown (oszczędny pod względem tokenów LLM).
- Jakość ponad ilość: usuwaj specyfikacje sprawdzające wyłącznie renderowanie; każda specyfikacja musi wykonywać działanie ze skutkiem ubocznym, które może wywołać użytkownik.

## Generowana eksploracja w przeglądarce

Gdy istotny kontrakt z klientem obejmuje kombinatoryczne przejścia między stanami i nie można go
udowodnić na tańszym poziomie, użyj wąskich, generowanych sekwencji działań lub właściwości stanowej.
Postępuj zgodnie z niezależnym od runnera [przewodnikiem po testowaniu opartym na właściwościach](https://github.com/malinskibeniamin/skills/blob/main/tdd/PROPERTY-BASED-TESTING.md):
utrzymuj niezależną wyrocznię graniczną, zachowuj dane umożliwiające odtworzenie i przekształcaj każde rzeczywiste odkrycie
w deterministyczny test regresyjny. Generowana eksploracja uzupełnia stałe ścieżki,
testy międzyprzeglądarkowe, testy dostępności, przegląd wizualny i wewnętrzne użycie produktu; nie zastępuje żadnego z nich.

## Długotrwałe zasoby SPA

W przypadku listenerów, odłączonych elementów DOM, timerów, subskrypcji lub wzrostu sterty, które kumulują się
w ramach jednego kontekstu przeglądarki, przeczytaj [SOAK-TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SOAK-TESTING.md). Traktuj powtarzany
pełny cykl jako kontrakt czasu życia zasobów; zwykłe izolowane testy E2E nie mogą go udowodnić.

## Monitorowanie E2E
`Monitor: bun run test:e2e` -- przesyłaj wyniki na bieżąco i reaguj na błąd przed zakończeniem zestawu.

## Agent-Browser a Playwright

| Zadanie | Narzędzie |
|------|------|
| Zestawy testów | Playwright przez `Monitor: bun run test:e2e` |
| Generowanie selektorów | `agent-browser snapshot` (drzewo a11y) |
| Wizualny test dymny | `agent-browser screenshot --annotate` |
| Interaktywne debugowanie | Tryb UI Playwright |
| CI | Playwright |
| Inspekcja strony przez AI | agent-browser |

Konfiguracja (instalacja, konfiguracja, fixture’y, Testcontainers): zobacz [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/e2e-testing/SETUP.md).
