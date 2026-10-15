---
description: >-
  Sprawdzaj flagi LaunchDarkly przez ldcli: istnienie, odbiorcy, zasięg zmian i
  kandydaci do usunięcia w Integration i Production.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - launchdarkly
sidebar:
  label: /launchdarkly
title: /launchdarkly
type: skill
---
![Diagram of the /launchdarkly skill](/diagrams/skills/launchdarkly.svg)

[Open the editable Excalidraw source](/diagrams/skills/launchdarkly.excalidraw)


Używaj wyłącznie oficjalnego `ldcli` do operacji w LaunchDarkly. Przeczytaj
[kontrolę wstępną CLI](https://github.com/malinskibeniamin/skills/blob/main/shared/ldcli.md); korzystaj z istniejącego uwierzytelnienia bez wypisywania tokenów ani konfiguracji. Audyt jest tylko do odczytu: pytanie „czy możemy usunąć flagę?” nie zezwala na zmianę targetowania, wycofanie, archiwizację, usunięcie flagi ani kodu.

## Zakres [#scope]

Ustal projekt na podstawie prośby lub konfiguracji repozytorium. W przeciwnym razie sprawdź `ldcli projects list --help`, wyświetl projekty i zapytaj o wybór; nie zakładaj `default`. Przed podaniem wyniku dla całego konta przejdź przez wszystkie strony.

**Uwzględniaj tylko Integration (`integration`) i Production (`production`).** Potwierdź klucze przez `ldcli environments list`. Brak lub niedostępność wymaganego środowiska oznacza wynik nieznany, nie pusty ani wyłączony. W heurystyce pomijaj testy, staging, preproduction, development i inne nieużywane środowiska. Jeśli projekt ma inne klucze, ustal mapowanie przed dostosowaniem polecenia; nie podstawiaj innego środowiska bez wyjaśnienia.

## Sprawdź flagę [#inspect-a-flag]

Przeczytaj `ldcli flags get --help`, następnie pobierz pełną konfigurację dla obu środowisk. Podaj istnienie, datę utworzenia, stan archiwizacji/wycofania, włączenie targetowania i faktycznie zwracane wartości. Odróżniaj brak flagi od błędów uwierzytelnienia, uprawnień, projektu i środowiska. Brak nie upoważnia do tworzenia; [procedurę zmian CLI](https://github.com/malinskibeniamin/skills/blob/main/shared/ldcli.md#change) stosuj tylko na wyraźne żądanie.

Aby ustalić odbiorców, przeanalizuj wariant domyślny, wskazane konteksty, uporządkowane reguły, segmenty, wdrożenia procentowe/eksperymentalne i zależności wstępne. Samo `on: true` nie oznacza dostępności funkcji dla wszystkich. Indeksy rozstrzygaj przez `variations[].value`; indeks zero nie musi oznaczać włączenia. Nie ujawniaj niepotrzebnie identyfikatorów kontekstów. Oddziel odbiorców funkcji od uprawnień do panelu i opiekunów flagi. Dla flag wielowariantowych ustal wartość oznaczającą włączenie albo zgłoś wynik nieznany.

Przy analizie zależności, odwołań w kodzie lub archiwizacji przeczytaj [cykl życia i dowody](https://github.com/malinskibeniamin/skills/blob/main/launchdarkly/references/lifecycle.md).

## Policz kandydatów do usunięcia [#count-long-enabled-cleanup-candidates]

Z katalogu instalacji tej umiejętności uruchom polecenie przy dostępnym Bun:

```bash
bun run scripts/audit.ts --project <project-key>
```

Polecenie przechodzi przez strony inwentarza, pobiera pełne targetowanie z `--summary 0` i sprawdza historię przez `ldcli`. Nie zapisuje zmian w LaunchDarkly. Surowe wyniki zachowaj lokalnie, poza commitami i publicznymi PR.

Policz każdą niezarchiwizowaną flagę raz, jeśli w czasie UTC `auditedAt` spełnia wszystkie warunki:

- Utworzona **ściśle ponad 30 × 24 godziny temu**.
- Targetowanie włączone w **Integration i Production**, a wszystkie możliwe wyniki domyślne, reguły, wskazania i warianty wdrożeń o dodatniej wadze zwracają logiczne `true`.
- Brak zmian w wybranych konfiguracjach i historii flagi przez **ostatnie 14 × 24 godziny**. Zmiana dokładnie na granicy wyklucza flagę. Używaj specyfikatorów wybranych środowisk, aby nie odrzucać flag przez zmiany w nieużywanych środowiskach. Zmiany wspólnych metadanych wpływające na wybrany zakres też się liczą.

Nierozstrzygnięte zależności wstępne, wartości włączenia inne niż logiczne, brak lub nieprawidłowe targetowanie i niedostępna historia oznaczają **wynik nieznany**, nie potwierdzonego kandydata. Wyjaśnij je przed podaniem dokładnej sumy. Kandydat oznacza **usunięcie sprawdzenia flagi przy zachowaniu udostępnionej funkcji**, nie wyłączenie funkcji ani natychmiastową bezpieczną archiwizację.

## Przedstaw dowody [#return-evidence]

Zacznij od `candidateCount`, projektu, obu kluczy środowisk, czasu UTC i `scannedCount`. Podaj klucze kandydatów z `createdAt` i `lastTargetingChangeAt`; ostatnie pole nie jest globalnym czasem ostatniej zmiany. Wymień pominięte środowiska i niewiadome. `exactCount: null` / kod wyjścia 2 oznacza dolną granicę; kod 1 oznacza nieudany odczyt inwentarza, bez potwierdzonej liczby. Sumuj tylko kompletne raporty projektów; ograniczony token nie dowodzi pokrycia całego konta.

Blokady archiwizacji podaj osobno. Odczyty nie są atomowe; powtórz audyt przed działaniem. Zakończ po raporcie, chyba że użytkownik wyraźnie poprosi o zmianę.
