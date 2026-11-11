---
description: >-
  Wybieraj Opus do codziennej pracy, Fable do wymagających zadań technicznych, a
  Sol do przeglądów; zachowuj wybrane modele i wymóg wyraźnej zgody na
  delegowanie.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - efficient frontier
sidebar:
  label: /efficient-frontier
title: /efficient-frontier
type: skill
---
![Diagram umiejętności /efficient-frontier](/diagrams/skills/efficient-frontier.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/efficient-frontier.excalidraw)

Tylko przy wyraźnie zażądanej delegacji przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#delegation).

Przed wyborem modelu przeczytaj [zasady wyboru narzędzi](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#protect-attention-while-working).

`config/model-routing.json` określa routing; nigdy nie kopiuj subiektywnych ocen do promptów.

1. Właściciel: Opus 5.5 `xhigh` do codziennej pracy, planów, kodu i UI.
   Używaj Fable 5.2 `xhigh` dla trudnych zadań określonych w `quality_first.hard`: dużych migracji lub refaktoryzacji, wymagającej architektury lub badań, długotrwałej pracy technicznej albo potwierdzonego braku możliwości Opus. Najpierw uzupełnij kontekst, narzędzia i kontrole; sama długość zadania lub nieudany test nie uzasadniają eskalacji.
2. Sol `xhigh` przegląda PR-y przez `/codex`; jeśli jest niedostępny, użyj oznaczonego przeglądu Opus `xhigh` z czystym kontekstem i ujawnij brak sprawdzenia przez inną rodzinę modeli.
3. UI, teksty i projekt API należą do Opus, z taste >= 8. Jeśli jest niedostępny, zgłoś blokadę zamiast potajemnie zmieniać model.
4. Drobne prace wykonuj samodzielnie na codziennym modelu Opus. Sol `xhigh` wykonuje zadania, obsługę komputera i analizę po wyborze Codex przez użytkownika.
5. Używaj wyłącznie Opus/Fable/Sol; nigdy `max`. Zgłaszaj niedostępność Fable dla trudnych zadań; zastępuj go Opus w tej roli tylko na wyraźne życzenie właściciela. Preferencja właściciela ma pierwszeństwo przed historycznymi ocenami.
6. Sprawdzenie przez inną rodzinę wymaga wyraźnego upoważnienia; preferencja modelu nie upoważnia do uruchamiania agentów.
7. `ultra` wymaga wyraźnej delegacji lub `/swarm`. Tryb Pro, utrwalone rozumowanie, narzędzia programowe i jawny cache: tylko API, chyba że środowisko je udostępnia.

Implementację prowadzi jeden właściciel; bez delegacji wykonuj ścieżki samodzielnie. Zatwierdzone ścieżki otrzymują ograniczony cel, dane wejściowe, wyłączenia, dowody i warunek zakończenia. Właściciel zachowuje odpowiedzialność za architekturę, priorytety, ryzyko, syntezę i akceptację.

Zachowaj model wyraźnie wybrany w sesji. Rozpoznanie trudnego zadania wybiera rolę Fable tam, gdzie host umożliwia wybór; nie upoważnia do wywołania rekurencyjnego, nowego wątku, płatnych kredytów ani cichej zmiany modelu. Sprawdź dostępność modeli i ich dokładne identyfikatory u hosta; zgłoś brak ścieżki zamiast używać aliasu prowadzącego do innego modelu.
Przy pracy z Fable, przekazywaniu zadania między modelami lub zmianach promptów Claude przeczytaj [wskazówki dotyczące promptów modeli](https://github.com/malinskibeniamin/skills/blob/main/shared/model-prompting.md).

## Limity [#capacity]

Pomiar hosta `/stay-within-limits` określa limit; w przeciwnym razie jest nieznany. Nigdy nie szacuj go na podstawie tokenów ani kosztu. Limit wyklucza ścieżki, nigdy nie obniża jakości.

## Zatwierdzanie [#promotion]

Obecne ustawienia `xhigh` są jawnym wyborem właściciela, nie wynikiem awansu na podstawie benchmarków.
Przed niezamówioną zmianą ustawień domyślnych uruchom `agent-evals/context-ablation/`: porównuj jedną grupę kontekstu naraz, zachowuj te same zadania i kryteria oceny oraz wybieraj niższy koszt tylko spośród wyników o równoważnej jakości. Zapisz zwycięską politykę w `config/model-routing.json`.

[Pakiet i źródła](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md): wyłącznie autoryzowane delegowanie.
