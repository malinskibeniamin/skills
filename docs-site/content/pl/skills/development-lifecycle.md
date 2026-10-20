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

Przed edycją załaduj [dobór dowodów zmiany](https://github.com/malinskibeniamin/skills/blob/main/shared/change-evidence.md) i właściwych właścicieli. Oceń wpływ proporcjonalnie; przed zmianą widocznego zachowania zarejestruj bazę, także dla drobnego tekstu lub współdzielonego UI.

### Działaj [#act]

Jeden właściciel zadania; delegowanie i praca w tle wymagają wyraźnej zgody. Wprowadź najmniejszą oczywistą zmianę; najpierw usuwaj lub wykorzystuj ponownie, zanim dodasz nowe mechanizmy. Dla istotnego zachowania załaduj [tdd](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md) i pracuj na poziomie publicznego kontraktu: RED -> najmniejsze GREEN -> REFACTOR; statyczne okablowanie lub usuwanie, które nie zmienia zachowania, może wymagać tylko ukierunkowanej weryfikacji. Gdy ustalenia się zmienią, ponownie zaplanuj odpowiedni fragment. Poboczne porządki zgłoś, chyba że blokują weryfikację.

### Zweryfikuj [#verify]

Uruchom odpowiednie dla repozytorium testy, sprawdzanie typów, lintowanie, kompilację i kontrole statyczne. Dla istotnego, uruchamialnego zachowania załaduj [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md); sprawdź rzeczywisty punkt wejścia oraz jedną wiarygodną ścieżkę błędu lub odzyskiwania. Oceń rezultat względem celu, ograniczeń i wiarygodnego ryzyka. Niepowodzenie wyznacza następne działanie; naprawiaj i powtarzaj.

Jeśli brakuje powtarzalnego punktu wejścia, potwierdź działanie za pomocą tymczasowego środowiska testowego, a następnie skieruj trwałą lukę do `/create-verification-skill`.

## Granice [#boundaries]

Pytaj tylko o decyzje zastrzeżone dla użytkownika albo nieodwracalne działania produkcyjne, prawne, dotyczące prywatności, usuwania danych lub wysokiego bezpieczeństwa. Dowody i przesłanki wstrzymania zapisuj w ignorowanym `.context/implementation-notes.md`.

## Zakończenie [#completion]

Przeczytaj i wykonaj [dostarczanie autora](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md): samodzielny przegląd inline, właściwe dowody, publikacja oraz żądana obsługa CI i uwag. Wykorzystaj aktualną weryfikację; zatrzymaj się w żądanym punkcie końcowym po spełnieniu wszystkich kryteriów. [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/REFERENCE.md) zawiera próby specyficzne dla zadania.
