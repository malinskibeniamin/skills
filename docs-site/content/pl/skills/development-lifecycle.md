---
title: /development-lifecycle
description: >-
  Prowadź implementację w React, TypeScript i interfejsie użytkownika od
  ogólnego celu aż po samodzielną weryfikację.
type: skill
sidebar:
  label: /development-lifecycle
---
![Diagram umiejętności /development-lifecycle](/diagrams/skills/development-lifecycle.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/development-lifecycle.excalidraw)

Weź odpowiedzialność za jeden rezultat. Korzystaj z [zasad komunikacji](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md) i [zasad ładowania zależności](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Kontrakt rezultatu [#outcome-contract]

Przed rozpoczęciem edycji określ:

- **Cel** -- ogólny stan końcowy.
- **Ograniczenia** -- ograniczenia, których nie można wywnioskować, decyzje zastrzeżone dla użytkownika oraz nieodwracalne granice.
- **Weryfikacja** -- kontrole lub obserwowalne zachowanie, które odróżniają ukończone rozwiązanie od rozwiązania jedynie pozornie poprawnego.
- **Zatrzymanie** -- żądany punkt końcowy i warunki, które rzeczywiście wymagają udziału użytkownika.

Przedstaw kontrakt; przy tworzeniu, naprawie lub implementacji od razu kontynuuj.

## Pętla [#loop]

**sprawdź -> działaj -> zweryfikuj -> powtórz**

### Sprawdź [#inspect]

Rozstrzygnij przeoczony obszar lub zmienną niewiadomą na podstawie dowodów źródłowych. Dopasuj się do istniejących wzorców i sprawdzonej skali; zaklasyfikuj kwestie jako wyszukanie, prototyp, odwracalne założenie lub przesłankę do wstrzymania pracy.

Przed edycją załaduj [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md) i sprawdź, jakie dowody będą użyteczne. Dla każdej widocznej zmiany zarejestruj stan wyjściowy i zinwentaryzuj obszary za pomocą [wizualnych dowodów PR](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5). Dotyczy to również drobnych zmian tekstu lub stylu oraz wpływu na współdzielony interfejs użytkownika.

### Działaj [#act]

Jeden właściciel zadania; delegowanie i praca w tle wymagają wyraźnej zgody. Wprowadź najmniejszą oczywistą zmianę; najpierw usuwaj lub wykorzystuj ponownie, zanim dodasz nowe mechanizmy. Dla istotnego zachowania załaduj [tdd](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md) i pracuj na poziomie publicznego kontraktu: RED -> najmniejsze GREEN -> REFACTOR; statyczne okablowanie lub usuwanie, które nie zmienia zachowania, może wymagać tylko ukierunkowanej weryfikacji. Gdy ustalenia się zmienią, ponownie zaplanuj odpowiedni fragment. Poboczne porządki zgłoś, chyba że blokują weryfikację.

### Zweryfikuj [#verify]

Uruchom odpowiednie dla repozytorium testy, sprawdzanie typów, lintowanie, kompilację i kontrole statyczne. Dla istotnego, uruchamialnego zachowania załaduj [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md); sprawdź rzeczywisty punkt wejścia oraz jedną wiarygodną ścieżkę błędu lub odzyskiwania. Oceń rezultat względem celu, ograniczeń i wiarygodnego ryzyka. Niepowodzenie wyznacza następne działanie; naprawiaj i powtarzaj.

Jeśli brakuje powtarzalnego punktu wejścia, potwierdź działanie za pomocą tymczasowego środowiska testowego, a następnie skieruj trwałą lukę do `/create-verification-skill`.

## Granice [#boundaries]

Pytaj tylko o decyzje zastrzeżone dla użytkownika albo nieodwracalne działanie dotyczące środowiska produkcyjnego, prawa lub prywatności, usuwania danych bądź wysokiego poziomu bezpieczeństwa. Na bieżącej, należącej do użytkownika gałęzi wykonuj commity, wypychaj zmiany, wykonuj rebase i używaj `--force-with-lease` bez ponownego pytania. Nigdy nie scalaj, nie używaj zwykłego wymuszenia, nie twórz dodatkowych PR-ów ani nie przepisuj gałęzi domyślnych, współdzielonych, należących do kogoś innego lub równolegle używanych bez wyraźnej zgody.

Przed zmianą kodu na gałęzi main/master/develop utwórz odizolowane drzewo robocze za pomocą `scripts/mux-worktree.sh <type>/<branch-name>`. [ETHOS: Izolacja drzewa roboczego]

Dowody z dłuższych prac i przesłanki do wstrzymania zapisuj w ignorowanym przez Git pliku `.context/implementation-notes.md`.

## Zakończenie [#completion]

Zatrzymaj się w żądanym punkcie końcowym gdy wszystkie kryteria zakończenia są spełnione. Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/REFERENCE.md) dla weryfikacji lub dostarczenia; dla żądanego dostarczenia przez Git załaduj [commit-push-pr](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/SKILL.md).
