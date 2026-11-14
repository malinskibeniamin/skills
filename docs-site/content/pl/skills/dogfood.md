---
description: >-
  Używaj po każdym istotnym wycinku zachowania i przed przekazaniem lub wysyłką,
  aby sprawdzić uruchamialną pracę przez prawdziwy punkt wejścia.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - dogfood
sidebar:
  label: /dogfood
title: /dogfood
type: skill
---
![Diagram umiejętności /dogfood](/diagrams/skills/dogfood.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/dogfood.excalidraw)


Przy weryfikowaniu zachowania lub weryfikatora przeczytaj [Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#verification).

Wykonuj dogfood dla każdego istotnego uruchamialnego wycinka i końcowego PR-a w publicznych punktach styku. Testy nie są dogfoodem.

## Inwentaryzacja [#inventory]

1. Ustal bazę porównania przez
   `BASE=$(PR_BASE_REF="${DOGFOOD_BASE_REF:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`.
2. Sprawdź pełny PR: od merge-base po pracę zatwierdzoną, staged, unstaged i untracked.
3. Pokryj zmienione uruchamialne ścieżki w rzeczywistych punktach wejścia, w tym zasoby/skrypty umiejętności i zdarzenia hooków.
   Samodzielna dokumentacja, testy i ewaluacje nie wymagają weryfikacji w praktyce.

## Pętla [#loop]

Uruchom użyj -> nadużyj -> napraw -> odtwórz ponownie.

### Użyj [#use]

Wykonaj zamierzone ścieżki; sprawdź wynik, przejścia stanu, skutki uboczne, konsolę, sieć i logi.

Użyj reprezentatywnych danych o rzeczywistej skali (kształcie i liczności zbliżonych do produkcyjnych); porównaj oczekiwane i zaobserwowane
liczby, kolejność, czas, stan i skutki uboczne; ujawnij akumulację.

Dla błędów odtwórz dokładne kroki zgłaszającego na wersji bez poprawki. Jeśli nie możesz odtworzyć błędu,
poproś o brakujące środowisko lub dowód przed rozpoczęciem diagnozy.

### Nadużyj [#abuse]

Podejmij jedną wiarygodną próbę uszkodzenia:

- Niedbałość: puste, nieprawidłowe, zbyt duże, zduplikowane lub przestawione wejście.
- Niecierpliwość: powtórzenie, podwójne wysłanie, przeładowanie, odejście, anulowanie lub przerwanie.
- Pech: nieaktualne lub brakujące dane, wolna albo uszkodzona zależność, częściowe zakończenie.
- Dane rzeczywiste: rzadkie pola, duplikaty ID, mieszane wersje lub tenanty, długi tekst, Unicode,
  granice stref czasowych i realistyczna liczność.
- Wydajność: zmierz czas odpowiedzi, sieć, renderowanie, CPU i pamięć względem bazy lub budżetu.

Obserwuj błąd i powrót do prawidłowego działania.

Ryzyka treści/układu UI: wywołaj narzędzie Skill z "break-ui". Wykorzystuj ponownie dane zgodne ze schematem
i dowody przy odtwarzaniu oraz w potwierdzeniu; testuj tylko niepokryte przypadki. Walidację niepoprawnych danych sprawdzaj osobno.

### Napraw [#repair]

Defekty oznaczają FAIL. Gdy można je wykryć automatycznie, dodaj test RED publicznego kontraktu,
popraw przez `/tdd` i uruchom ponownie powiązane kontrole. Zmiany unieważniają dowody.

### Odtwórz ponownie [#replay]

W rzeczywistym punkcie wejścia powtórz zamierzone użycie i każdą próbę uszkodzenia. Dla błędów odtwórz identyczne
kroki i sąsiednie zachowanie. Użyj [pakietów odtwarzania](https://github.com/malinskibeniamin/skills/blob/main/shared/verification-replay.md) w przypadku
błędów zależnych od stanu lub powtarzających się problemów z reprodukcją. PASS dotyczy bieżącego stanu uruchamialnego.

## Punkty wejścia [#entrypoints]

| Zmiana | Sprawdzenie |
|---|---|
| Web/UI | Uruchom, nawiguj, działaj, przeładuj, sprawdź konsolę i sieć |
| CLI/TUI | Wywołaj realistyczne, nieprawidłowe i przerwane przepływy |
| API/worker | Wyślij prawdziwe żądania lub zdarzenia; sprawdź odpowiedź i skutki uboczne |
| Biblioteka | Wywołaj publiczne API z minimalnego konsumenta |
| Hook/automatyzacja | Wyzwól rzeczywiste zdarzenie na reprezentatywnych fixture'ach |
| Umiejętność/agent | Użyj w świeżym realistycznym zadaniu i sprawdź zachowanie |
| Demo/prototyp | Używaj do uzyskania zaobserwowanego dowodu rozstrzygającego pytanie |

Uruchamianie nowych agentów wymaga jawnej delegacji.

Jeśli istnieje lokalna dla projektu umiejętność `verify-*`, użyj jej mechanizmów doctor, drive, evidence i cleanup.
Tylko UI w checkoutcie T3 Code: ustal [kontekst natywny](https://github.com/malinskibeniamin/skills/blob/main/shared/T3CODE-NATIVE.md#resolve-context), a następnie załaduj [weryfikację web/desktop](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/test-t3-app/SKILL.md) lub
[weryfikację natywnej aplikacji mobilnej](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/test-t3-mobile/SKILL.md). Brak narzędzi Browser/Device oznacza
BLOCKED, a nie instalację ani przejście na inny harness.
Rozbieżność weryfikatora kieruj do `/maintain-verification-skill`; powtarzający się brak ścieżki kieruj do
`/create-verification-skill` po uzyskaniu dowodu.

React: [inspekcja w czasie działania](https://github.com/malinskibeniamin/skills/blob/main/shared/react-devtools.md).

## Zadania w przeglądarce i praca z danymi [#browser-and-data-tasks]

Domyślnie używaj agent-browser, jeśli jest to dozwolone; pobieranie przez HTTP lub pobieranie danych nie potwierdza działania UI.
Przy wyborze narzędzia lub korzystaniu z zapisanych przepływów przeczytaj [odtwarzanie zadań w przeglądarce i pracy z danymi](https://github.com/malinskibeniamin/skills/blob/main/shared/verification-replay.md#browser-and-data-tasks).
Przestrzegaj wymagań użytkownika/hosta dotyczących przeglądarki oraz zasad weryfikatora projektu.

## Potwierdzenie [#receipt]

`Verdict: PASS | FAIL | BLOCKED`; punkt wejścia/działania/obserwacje:

- **Entrypoint:** dokładne polecenie/URL/zdarzenie/konsument.
- **Actions:** ścieżka i próby uszkodzenia.
- **Observations:** dane, wyniki, stan, skutki, konsola/sieć/logi, czas.
- **Repairs:** defekty, testy RED, poprawki i wynik ponownego odtworzenia.
- **Limits:** niesprawdzone zachowanie i powód.

PASS: bezpośredni dowód dla każdego zachowania; FAIL: zaobserwowany defekt; BLOCKED: brak dostępu,
środowiska lub sprzętu albo niespełniony warunek bezpieczeństwa.
