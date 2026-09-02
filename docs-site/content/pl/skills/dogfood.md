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

### Napraw

Zaobserwowany defekt oblewa checkpoint. Gdy można go zautomatyzować, dodaj RED test publicznego kontraktu,
popraw przez `/tdd` i uruchom ponownie powiązane kontrole. Każda zmiana zachowania unieważnia wcześniejszy dowód.

### Odtwórz ponownie

Uruchom ponownie prawdziwy punkt wejścia i powtórz zamierzone użycie oraz wszystkie próby uszkodzenia. Dla błędu
powtórz identyczną pierwotną reprodukcję i sprawdź sąsiednie zachowanie. PASS dotyczy tylko
bieżącego stanu uruchamialnego.

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

Jeśli istnieje lokalna dla projektu umiejętność `verify-*`, użyj jej mechanizmów doctor, drive, evidence i cleanup.
Rozbieżność weryfikatora kieruj do `/maintain-verification-skill`; powtarzający się brak ścieżki kieruj do
`/create-verification-skill` po uzyskaniu dowodu.

## Potwierdzenie

Powiąż punkt wejścia, działania i obserwacje z bieżącą implementacją.
Podaj `Verdict: PASS | FAIL | BLOCKED`, a następnie:

- **Entrypoint:** dokładne polecenie, URL, zdarzenie lub konsument.
- **Actions:** zamierzona ścieżka i próby uszkodzenia.
- **Observations:** dane, wyniki, stan, skutki, konsola, sieć, logi i czas.
- **Repairs:** defekty, testy RED, poprawki i wynik ponownego odtworzenia.
- **Limits:** niesprawdzone zachowanie i powód.

PASS wymaga bezpośredniego dowodu dla każdego zmienionego zachowania. FAIL pozostawia zaobserwowany defekt.
BLOCKED nazywa brakujący dostęp, środowisko, sprzęt lub warunek bezpieczeństwa.
