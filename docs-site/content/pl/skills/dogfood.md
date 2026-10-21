---
title: /dogfood
description: >-
  Używaj po każdym istotnym wycinku zachowania i przed przekazaniem lub wysyłką,
  aby sprawdzić uruchamialną pracę przez prawdziwy punkt wejścia.
type: skill
sidebar:
  label: /dogfood
---
![Diagram umiejętności /dogfood](/diagrams/skills/dogfood.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/dogfood.excalidraw)

Istotny uruchamialny wycinek zmienia zachowanie w prawdziwym punkcie wejścia lub publicznym punkcie styku.
Wykonuj dogfood po każdym wycinku i dla całego PR-a. Testy nie są dogfoodem.

## Inwentaryzacja

1. Ustal bazę porównania przez
   `BASE=$(PR_BASE_REF="${DOGFOOD_BASE_REF:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`.
2. Sprawdź pełny PR od merge-base, łącznie z pracą zatwierdzoną, staged, unstaged i untracked.
3. Przypisz zmienione zachowanie do jego prawdziwego punktu wejścia. Umiejętność obejmuje powiązane instrukcje, zasoby i
   skrypty; hook uruchamiaj przez rzeczywiste zdarzenie. Samodzielna dokumentacja, testy i ewaluacje nie wymagają
   pokrycia doświadczeniem.

Dla pracy lokalnej pokryj zachowanie zmienione w tej turze. Przed PR-em lub wysyłką pokryj każde uruchamialne zachowanie na gałęzi.

## Pętla

Uruchom **użyj -> nadużyj -> napraw -> odtwórz ponownie** na bieżącej implementacji.

### Użyj

Wykonaj każdą zamierzoną ścieżkę przez rzeczywistą implementację. Obserwuj widoczny wynik,
przejścia stanu, skutki uboczne, konsolę, sieć i logi zamiast wnioskować z kodu.

Użyj reprezentatywnych danych o rzeczywistej skali, produkcyjnym kształcie i liczności. Porównaj
oczekiwane i zaobserwowane liczby, kolejność, czas, stan oraz skutki uboczne; uruchom wystarczająco długo, aby
ujawnić akumulację.

Dla błędu najpierw odtwórz dokładne kroki zgłaszającego na wersji bez poprawki. Jeśli nie możesz go odtworzyć,
przerwij diagnozę i poproś o brakujące środowisko lub dowód.

### Nadużyj

Zastosuj każdy właściwy punkt widzenia i co najmniej jedną wiarygodną próbę uszkodzenia:

- Niedbałość: puste, nieprawidłowe, zbyt duże, zduplikowane lub przestawione wejście.
- Niecierpliwość: powtórzenie, podwójne wysłanie, przeładowanie, odejście, anulowanie lub przerwanie.
- Pech: nieaktualne lub brakujące dane, wolna albo uszkodzona zależność, częściowe zakończenie.
- Dane rzeczywiste: rzadkie pola, duplikaty ID, mieszane wersje lub tenanty, długi tekst, Unicode,
  granice stref czasowych i realistyczna liczność.
- Wydajność: zmierz czas odpowiedzi, sieć, renderowanie, CPU i pamięć względem bazy lub budżetu.

Preferuj wiarygodne zachowanie użytkownika zamiast arbitralnych przypadków. Obserwuj błąd i odzyskiwanie bezpośrednio.

Ryzyka treści/układu UI: wywołaj narzędzie Skill z "break-ui". Wykorzystuj ponownie dane zgodne ze schematem
i dowody przy odtwarzaniu oraz w potwierdzeniu; testuj tylko niepokryte przypadki. Walidację niepoprawnych danych sprawdzaj osobno.

### Napraw

Zaobserwowany defekt oblewa checkpoint. Gdy można go zautomatyzować, dodaj RED test publicznego kontraktu,
popraw przez `/tdd` i uruchom ponownie powiązane kontrole. Każda zmiana zachowania unieważnia wcześniejszy dowód.

### Odtwórz ponownie

Uruchom ponownie rzeczywisty punkt wejścia; powtórz zamierzone użycie i każdą próbę uszkodzenia. Dla błędów odtwórz identyczne pierwotne kroki i sąsiednie zachowanie. Dla błędów zależnych od stanu lub powtarzających się luk reprodukcji użyj [pakietów odtwarzania](https://github.com/malinskibeniamin/skills/blob/main/shared/verification-replay.md). PASS dotyczy bieżącego stanu uruchamialnego.

## Punkty wejścia

| Zmiana | Sprawdzenie |
|---|---|
| Web/UI | Uruchom, nawiguj, działaj, przeładuj, sprawdź konsolę i sieć |
| CLI/TUI | Wywołaj realistyczny, nieprawidłowy i przerwany przepływ |
| API/worker | Wyślij prawdziwe żądania lub zdarzenia; sprawdź odpowiedź i skutki uboczne |
| Biblioteka | Wywołaj publiczne API z minimalnego konsumenta |
| Hook/automatyzacja | Wyzwól rzeczywiste zdarzenie na reprezentatywnych fixture'ach |
| Umiejętność/agent | Użyj w świeżym realistycznym zadaniu i sprawdź zachowanie |
| Demo/prototyp | Używaj do uzyskania zaobserwowanego dowodu rozstrzygającego pytanie |

Używaj narzędzi projektu. Świeży agent wymaga jawnej delegacji.

W checkoucie T3 ustal [kontekst natywny](https://github.com/malinskibeniamin/skills/blob/main/shared/T3CODE-NATIVE.md#resolve-context) z punktem wejścia `dogfood` i zmienianymi powierzchniami; załaduj wybrane umiejętności weryfikacji bez kolejnego wywołania przez człowieka. Brak narzędzi natywnych pozostaje luką, nie dowodem pokrycia przeglądarki lub aplikacji natywnej.

Jeśli istnieje lokalna dla projektu umiejętność `verify-*`, użyj jej mechanizmów doctor, drive, evidence i cleanup.
Podczas weryfikacji UI w checkoutcie T3 Code załaduj [weryfikację web/desktop](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/test-t3-app/SKILL.md)
lub [weryfikację natywnej aplikacji mobilnej](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/test-t3-mobile/SKILL.md), zależnie od obszaru.
Wymagaj odpowiednich narzędzi Browser lub Device; ich brak oznacza weryfikację BLOCKED,
a nie instalację ani przejście na inny harness. Inne repozytoria zachowują własne punkty wejścia.
Rozbieżność weryfikatora kieruj do `/maintain-verification-skill`; powtarzający się brak ścieżki kieruj do
`/create-verification-skill` po uzyskaniu dowodu.

## Potwierdzenie

Podaj bieżący punkt wejścia, działania i obserwacje: `Verdict: PASS | FAIL | BLOCKED`, a następnie:

- **Entrypoint:** dokładne polecenie, URL, zdarzenie lub konsument.
- **Actions:** zamierzona ścieżka i próby uszkodzenia.
- **Observations:** dane, wyniki, stan, skutki, konsola, sieć, logi i czas.
- **Repairs:** defekty, testy RED, poprawki i wynik ponownego odtworzenia.
- **Limits:** niesprawdzone zachowanie i powód.

PASS wymaga bezpośredniego dowodu dla każdego zmienionego zachowania. FAIL pozostawia zaobserwowany defekt.
BLOCKED nazywa brakujący dostęp, środowisko, sprzęt lub warunek bezpieczeństwa.
