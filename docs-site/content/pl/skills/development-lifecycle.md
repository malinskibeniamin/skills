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


Weź odpowiedzialność za jeden rezultat i pracuj, dopóki dowody go nie potwierdzą lub nie pojawi się rzeczywista przeszkoda.

## Kontrakt rezultatu

Przed rozpoczęciem edycji określ:

- **Cel** -- ogólny stan końcowy.
- **Ograniczenia** -- ograniczenia, których nie można wywnioskować, decyzje zastrzeżone dla użytkownika oraz nieodwracalne granice.
- **Weryfikacja** -- kontrole lub obserwowalne zachowanie, które odróżniają ukończone rozwiązanie od rozwiązania jedynie pozornie poprawnego.
- **Zatrzymanie** -- żądany punkt końcowy i warunki, które rzeczywiście wymagają udziału użytkownika.

Żądanie utworzenia, naprawy lub implementacji upoważnia do działania: przedstaw kontrakt i od razu kontynuuj.

## Pętla

**sprawdź -> działaj -> zweryfikuj -> powtórz**

### Sprawdź

Rozstrzygnij niewiadomą lub zmienną kwestię, która może podważyć przyjęte podejście, korzystając z kodu, testów, logów, dokumentacji i przykładów. Pozostałe zaklasyfikuj jako wyszukanie, prototyp, odwracalne założenie lub przesłankę do wstrzymania pracy. Dopasuj się do istniejących wzorców i sprawdzonej skali; korzystaj z odpowiednich wskazówek.

Przed rozpoczęciem edycji sprawdź `/quantify-impact`. W przypadku każdej widocznej zmiany zarejestruj stan wyjściowy i zinwentaryzuj obszary za pomocą [wizualnych dowodów PR](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5). Dotyczy to również drobnych zmian tekstu lub stylu oraz wpływu na współdzielony interfejs użytkownika.

### Działaj

Jeden model główny jest jedynym właścicielem zadania; delegowanie i praca w tle wymagają wyraźnej zgody. Zacznij od najmniejszej oczywistej zmiany; najpierw usuwaj lub wykorzystuj ponownie, zanim dodasz nowe mechanizmy. W przypadku istotnego zachowania stosuj TDD na poziomie publicznego kontraktu: RED -> najmniejsze GREEN -> REFACTOR; statyczne okablowanie lub usuwanie, które nie zmienia zachowania, może wymagać tylko ukierunkowanej weryfikacji. Gdy ustalenia się zmienią, ponownie zaplanuj odpowiedni fragment. Poboczne porządki zgłoś, chyba że blokują weryfikację.

### Zweryfikuj

Uruchom odpowiednie dla repozytorium testy, sprawdzanie typów, lintowanie, kompilację i kontrole statyczne. Sprawdź istotne zachowanie przez jego rzeczywisty punkt wejścia oraz jedną wiarygodną ścieżkę błędu lub odzyskiwania. Oceń rezultat względem celu, ograniczeń i wiarygodnego ryzyka. Każde niepowodzenie wyznacza kolejne działanie; naprawiaj i powtarzaj.

Jeśli brakuje powtarzalnego punktu wejścia, potwierdź działanie za pomocą tymczasowego środowiska testowego, a następnie skieruj trwałą lukę do `/create-verification-skill`.

## Granice

Pytaj tylko o istotną decyzję zastrzeżoną dla użytkownika albo nieodwracalne działanie dotyczące środowiska produkcyjnego, prawa lub prywatności, usuwania danych bądź wysokiego poziomu bezpieczeństwa. Na bieżącej, należącej do użytkownika gałęzi wykonuj commity, wypychaj zmiany, wykonuj rebase i używaj `--force-with-lease` bez ponownego pytania. Nigdy nie scalaj, nie używaj zwykłego wymuszenia, nie twórz dodatkowych PR-ów ani nie przepisuj gałęzi domyślnych, współdzielonych, należących do kogoś innego lub równolegle używanych bez wyraźnej zgody.

Przed zmianą kodu na gałęzi main/master/develop utwórz odizolowane drzewo robocze za pomocą `scripts/mux-worktree.sh <type>/<branch-name>`. [ETHOS: Izolacja drzewa roboczego]

Dowody z dłuższych prac i przesłanki do wstrzymania zapisuj w ignorowanym przez Git pliku `.context/implementation-notes.md`; krótkie zadania pozostają w rozmowie.

## Zakończenie

Zatrzymaj się w żądanym punkcie końcowym — odpowiedź, zmiana lokalna, commit, wypchnięcie zmian, PR lub pełne wdrożenie — gdy wszystkie kryteria zakończenia zostaną spełnione, a nie po ukończeniu kroku planu. Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/REFERENCE.md) wyłącznie dla aktywnej ścieżki weryfikacji lub dostarczenia.
