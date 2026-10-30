---
description: >-
  Prowadź implementację w React, TypeScript i interfejsie użytkownika od
  ogólnego celu aż po samodzielną weryfikację.
related:
  - /skills/tdd
  - /skills/review
search:
  boost: 3
  keywords:
    - development lifecycle
    - work
    - implementation
    - development workflow
sidebar:
  label: /development-lifecycle
title: /development-lifecycle
type: skill
---
![Diagram umiejętności /development-lifecycle](/diagrams/skills/development-lifecycle.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/development-lifecycle.excalidraw)

Przy wieloetapowej implementacji lub publikacji przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#execution).

Gdy zadanie obejmuje wdrożenie dostarczonego projektu Figma lub obrazu, wczytaj [build-design](https://github.com/malinskibeniamin/skills/blob/main/jakubkrehel-skills/build-design/SKILL.md) dla dowodów źródłowych, mapowania tokenów i porównania szerokości widoku. Zachowaj wymagane stany błędów i zabezpieczenia oraz tę pętlę dostarczania; zgodność z obrazem ich nie uchyla.

Główny punkt wejścia autora: `/work`. Odpowiadaj za jeden rezultat; dobieraj pomocnicze umiejętności automatycznie. Przed edycją przeczytaj [dostarczanie autora](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md) dla własności, izolacji i punktów końcowych. Korzystaj z [komunikacji](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md) i [ładowania zależności](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Kontrakt rezultatu [#outcome-contract]

Przed rozpoczęciem edycji określ:

- **Cel** -- ogólny stan końcowy.
- **Ograniczenia** -- ograniczenia, których nie można wywnioskować, decyzje zastrzeżone dla użytkownika oraz nieodwracalne granice.
- **Weryfikacja** -- kontrole lub obserwowalne zachowanie, które odróżniają ukończone rozwiązanie od rozwiązania jedynie pozornie poprawnego.
- **Zatrzymanie** -- żądany punkt końcowy i warunki, które rzeczywiście wymagają udziału użytkownika.

Przedstaw kontrakt; przy tworzeniu, naprawie lub implementacji od razu kontynuuj.
[Automatycznie uzupełnij zabezpieczenia przeglądu w repozytorium korzystającym z harnessu](https://github.com/malinskibeniamin/skills/blob/main/shared/review-enforcement.md) w granicach tego punktu końcowego.

## Pętla [#loop]

**sprawdź -> działaj -> zweryfikuj -> powtórz**

### Sprawdź [#inspect]

Rozstrzygnij przeoczony obszar lub zmienną niewiadomą na podstawie dowodów źródłowych. Dopasuj się do istniejących wzorców i sprawdzonej skali; zaklasyfikuj kwestie jako wyszukanie, prototyp, odwracalne założenie lub przesłankę do wstrzymania pracy.

Przed pisaniem przeczytaj zasady właściwe dla danego zakresu i ustal natywne polecenia repozytorium do formatowania, lintowania, sprawdzania typów i testów dotkniętych zmianą na podstawie skryptów, konfiguracji i CI. Zapisz istotne błędy stanu wyjściowego; korzystaj z zainstalowanego zestawu narzędzi.

Dla checkoutów T3 lub pracy z Effect ustal [kontekst natywny](https://github.com/malinskibeniamin/skills/blob/main/shared/T3CODE-NATIVE.md#resolve-context) z punktem wejścia `work`; w całej pętli używaj zwróconych wskazówek projektu i kontroli dla zmienionego zakresu.

Przed edycją załaduj [dobór dowodów zmiany](https://github.com/malinskibeniamin/skills/blob/main/shared/change-evidence.md) i właściwych właścicieli. Oceń wpływ proporcjonalnie; przed zmianą widocznego zachowania zarejestruj bazę, także dla drobnego tekstu lub współdzielonego UI.

### Działaj [#act]

Jeden właściciel zadania; delegowanie i praca w tle wymagają wyraźnej zgody. Zaimplementuj wymagane zachowanie zgodnie z lokalnymi konwencjami. Dla istotnego zachowania załaduj [tdd](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md) i pracuj na poziomie publicznego kontraktu: RED -> najmniejsze GREEN -> REFACTOR; statyczne okablowanie lub usuwanie, które nie zmienia zachowania, może wymagać tylko ukierunkowanej weryfikacji. Gdy ustalenia się zmienią, ponownie zaplanuj odpowiedni fragment. Poboczne porządki zgłoś, chyba że blokują weryfikację.

Po każdej spójnej partii zmian uruchom formatowanie lub automatyczne poprawki i lintowanie w odpowiednim zakresie, a następnie właściwe kontrole typów i testy. Wyniki zakończonych hooków wykorzystuj ponownie tylko przy identycznej zawartości plików i zakresie kontroli. Sprawdź diff automatycznych poprawek; napraw błędy i uruchom kontrole ponownie. Zachowaj sprawdzanie typów całego projektu, gdy ograniczenie do plików nie jest poprawne.

### Zweryfikuj [#verify]

Przed zakończeniem tury implementacji uruchom wymagane przez repozytorium kontrole formatowania, lintowania, typów, testów, kompilacji i analizy statycznej dla dotkniętego zakresu; kontrole wąskiego zakresu w wewnętrznej pętli nigdy nie zastępują wymaganych kontroli końcowych. Dla istotnego, uruchamialnego zachowania załaduj [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md); sprawdź rzeczywisty punkt wejścia oraz jedną wiarygodną ścieżkę błędu lub odzyskiwania. Oceń cel, ograniczenia i wiarygodne ryzyko: pomyślne kontrole nie dowodzą, że zbudowano właściwą rzecz. Niepowodzenie wyznacza następne działanie; naprawiaj i powtarzaj. Niezwiązane błędy stanu wyjściowego zgłaszaj osobno, nigdy jako pełne powodzenie.

Naprawiaj przyczynę, nie bramkę. Nigdy nie uzyskuj zielonego wyniku przez obejścia typowania, wyciszenia, pomijanie lub osłabianie testów, rozszerzanie wykluczeń, łagodzenie rygoru ani ukrywanie kodów zakończenia oznaczających błąd. Wadliwa kontrola wymaga dowodów i jawnego uzasadnienia zmiany narzędzia, wraz z przypadkami odrzucanymi i akceptowanymi, które potwierdzają, że poprawiona reguła nadal wykrywa zamierzony defekt.

Jeśli brakuje powtarzalnego punktu wejścia, potwierdź działanie za pomocą tymczasowego środowiska testowego, a następnie skieruj trwałą lukę do `/create-verification-skill`.

## Granice [#boundaries]

Pytaj tylko o decyzje zastrzeżone dla użytkownika albo nieodwracalne działania produkcyjne, prawne, dotyczące prywatności, usuwania danych lub wysokiego bezpieczeństwa. Dowody i przesłanki wstrzymania zapisuj w ignorowanym `.context/implementation-notes.md`.

## Zakończenie [#completion]

Przeczytaj i wykonaj [dostarczanie autora](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md): samodzielny przegląd inline, właściwe dowody, publikacja oraz żądana obsługa CI i uwag. Wykorzystaj aktualną weryfikację; zatrzymaj się w żądanym punkcie końcowym po spełnieniu wszystkich kryteriów. [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/REFERENCE.md) zawiera próby specyficzne dla zadania.
