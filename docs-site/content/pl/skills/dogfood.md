---
title: /dogfood
description: >-
  Testuj działające zmiany w rzeczywistym punkcie wejścia użytkownika. Stosuj po
  każdym istotnym fragmencie zachowania oraz przed przekazaniem lub wydaniem
  funkcji, poprawek, demonstracji, prototypów, hooków, umiejętności, CLI, API
  lub interfejsu użytkownika.
type: skill
sidebar:
  label: /dogfood
---
![Diagram umiejętności /dogfood](/diagrams/skills/dogfood.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/dogfood.excalidraw)

**Istotny działający przyrost** to fragment zachowania, który można sprawdzić przez rzeczywisty punkt wejścia użytkownika lub publiczny punkt wejścia. Przetestuj go samodzielnie przed rozpoczęciem kolejnego fragmentu i ponownie przed przekazaniem lub wydaniem. Testy nie są dogfoodingiem: potwierdzają asercje, a nie rzeczywiste doświadczenie.

## Sporządź wykaz działających zmian

Przed użyciem implementacji określ pełny wykaz zachowań:

1. Ustal cel za pomocą
   `BASE=$(PR_BASE_REF="${DOGFOOD_BASE_REF:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`.
   Najpierw wybierze to gałąź nadrzędną bieżącego skumulowanego PR, a następnie, w razie potrzeby, domyślną gałąź zdalną.
2. Sprawdź cały diff PR od jego bazy scalenia, uwzględniając zmiany zatwierdzone, przygotowane, nieprzygotowane i nieśledzone. Nie ograniczaj zakresu do plików zmienionych w bieżącej sesji.
3. Przypisz każdy działający artefakt do zmienionego zachowania i rzeczywistego punktu wejścia. Umiejętność obejmuje `SKILL.md` wraz z przywoływanymi wytycznymi, zasobami i skryptami; hooki i automatyzacje uruchamiaj przez ich rzeczywiste zdarzenia. Wyklucz samodzielną dokumentację, testy i ewaluacje z wymaganej weryfikacji praktycznej.

W zwykłej lokalnej turze wykonaj dogfooding, jeśli zmieniła ona działające zachowanie. Przed ukończeniem PR lub wydania przetestuj w ten sposób każde działające zachowanie w całym PR, nawet jeśli zaimplementowano je we wcześniejszej sesji.

## Pętla

Wykonaj cykl **użyj -> nadużyj -> napraw -> powtórz** na bieżącej implementacji.

### 1. Użyj

Określ każde zmienione zachowanie i jego rzeczywisty punkt wejścia użytkownika. Uruchom właściwą implementację i samodzielnie przejdź zamierzoną ścieżkę. Sprawdź widoczne dane wyjściowe, przejścia stanów, skutki uboczne, logi i konsolę, zamiast wnioskować o powodzeniu na podstawie kodu lub testów.

Użyj reprezentatywnych danych o skali odpowiadającej środowisku produkcyjnemu, zgodnych z nim pod względem struktury i liczności. Porównaj oczekiwane i zaobserwowane liczby, kolejność, czasy, stan oraz skutki uboczne; powtarzaj próbę wystarczająco długo, aby ujawnić zachowanie w stanie ustalonym lub skutki akumulacji.

W przypadku błędu najpierw wykonaj dokładne kroki zgłaszającego na niepoprawionej wersji i zarejestruj dokładny objaw. Jeśli nie możesz go odtworzyć, przerwij diagnozę, opisz wykonane próby i poproś o brakujące środowisko lub dowody. Nie naprawiaj błędu opartego na przypuszczeniach.

**Ukończono, gdy:** każde zmienione zachowanie ma bezpośrednio zaobserwowany stan bazowy na swojej publicznej granicy.

### 2. Nadużyj

Spróbuj zepsuć każde zmienione zachowanie tak, jak mógłby to zrobić rzeczywisty użytkownik:

- **Nieostrożny:** puste, nieprawidłowe, zbyt duże, zduplikowane lub podane w niewłaściwej kolejności dane wejściowe.
- **Niecierpliwy:** powtórzenie, podwójne wysłanie, opuszczenie strony, ponowne wczytanie, anulowanie lub przerwanie.
- **Pechowy:** nieaktualny stan, brakujące dane, awaria zależności, powolna odpowiedź lub częściowe ukończenie.
- **Rzeczywiste dane:** brakujące pola, zduplikowane identyfikatory, różni dzierżawcy lub wersje, długi tekst, Unicode, granice stref czasowych i realistyczna liczność.
- **Wydajność:** zmierz czas odpowiedzi, sieć, renderowanie, procesor i pamięć, gdy ma to znaczenie; porównaj wyniki z jawnym budżetem lub stanem bazowym.

Zastosuj każdą odpowiednią perspektywę i co najmniej jedną wiarygodną próbę wywołania awarii dla każdego zmienionego zachowania. Preferuj prawdopodobne zachowania użytkowników zamiast arbitralnych przypadków.

**Ukończono, gdy:** zamierzone użycie oraz odpowiednie zachowanie w razie awarii lub podczas odzyskiwania zostały bezpośrednio zaobserwowane.

### 3. Napraw

Traktuj każdą wykrytą usterkę jako niezaliczony punkt kontrolny. Jeśli można ją zautomatyzować, przekształć ją w regresyjny test RED, napraw przez `/tdd` i ponownie uruchom ukierunkowane kontrole automatyczne. Zmiana kodu unieważnia wcześniejsze dowody z dogfoodingu.

**Ukończono, gdy:** żadna zaobserwowana usterka nie pozostaje nierozwiązana ani nie została po cichu odłożona.

### 4. Powtórz

Uruchom ponownie od rzeczywistego punktu wejścia i powtórz zamierzoną ścieżkę oraz każdą próbę wywołania awarii na bieżącej implementacji. W przypadku poprawki błędu powtórz identyczną procedurę odtworzenia sprzed poprawki i potwierdź, że zgłoszony objaw zniknął bez naruszenia sąsiednich zachowań.

**Ukończono, gdy:** bieżący działający stan, a nie wcześniejsza kompilacja, przechodzi pełny cykl.

## Wybierz rzeczywisty punkt wejścia

| Zmiana | Sposób sprawdzenia |
|---|---|
| Aplikacja internetowa lub panel | Uruchom aplikację; nawiguj, klikaj, wpisuj, przeładowuj i sprawdzaj konsolę oraz sieć |
| CLI lub TUI | Wywołaj zbudowane polecenie z realistycznymi, nieprawidłowymi i przerwanymi danymi wejściowymi |
| API lub proces roboczy | Wyślij rzeczywiste żądania lub zdarzenia i sprawdź odpowiedź oraz skutki uboczne |
| Biblioteka | Użyj jej publicznego API w minimalnym rzeczywistym kliencie |
| Hook lub automatyzacja | Wyzwól rzeczywiste zdarzenie na reprezentatywnej próbce |
| Umiejętność lub instrukcja agenta | Użyj jej w nowym, realistycznym zadaniu; sprawdź zachowanie, a nie treść |
| Demonstracja lub prototyp | Korzystaj z działającego artefaktu, aż uzyskasz zaobserwowaną odpowiedź na badane pytanie |

Najpierw użyj narzędzi właściwych dla projektu. Używaj nowych agentów tylko wtedy, gdy użytkownik zezwolił na delegowanie.

## Protokół

Powiąż punkt wejścia, działania i obserwacje z bieżącą implementacją. Zgłoś:

`Verdict: PASS | FAIL | BLOCKED`

- **Punkt wejścia:** dokładne polecenie, adres URL, zdarzenie lub klient
- **Działania:** zamierzona ścieżka i próby wywołania awarii
- **Obserwacje:** struktura i skala danych, liczby, kolejność i czasy, dane wyjściowe, stan, skutki uboczne, konsola, sieć i logi
- **Naprawy:** znalezione usterki, dodane testy, wprowadzone poprawki i wynik powtórzenia
- **Ograniczenia:** niesprawdzone zachowania i przyczyny

Dołącz kompletny ustrukturyzowany protokół w końcowej odpowiedzi. PASS wymaga praktycznych dowodów dla każdego zmienionego zachowania w bieżącej implementacji. FAIL oznacza, że zaobserwowana usterka pozostaje nierozwiązana. BLOCKED wskazuje brakujący dostęp, środowisko, sprzęt lub ograniczenie bezpieczeństwa oraz dowody potrzebne w następnym kroku.
