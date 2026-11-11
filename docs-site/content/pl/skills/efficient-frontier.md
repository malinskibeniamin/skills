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

Delegowanie: przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#delegation).
Stosuj [zasady wyboru narzędzi](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#protect-attention-while-working).

Role: `config/model-routing.json`; pomijaj subiektywne oceny w promptach.

1. Opus 5.5 `xhigh`: codzienna praca, plany, kod i UI. Fable 5.2 `xhigh`: `quality_first.hard`. Najpierw uzupełnij kontekst, narzędzia i kontrole; sama długość zadania lub nieudany test nie uzasadniają eskalacji.
2. Sol `xhigh` przegląda przez `/codex`; jeśli jest niedostępny, użyj oznaczonego przeglądu Opus `xhigh` z czystym kontekstem i ujawnij brak sprawdzenia przez inną rodzinę modeli.
3. UI, teksty i projekt API należą do Opus (taste >= 8); jeśli jest niedostępny, zgłoś blokadę.
4. Drobne prace: samodzielnie na Opus; wykonanie, obsługa komputera i analiza po wyborze Codex przez użytkownika: Sol.
5. Tylko Opus/Fable/Sol; nigdy `max`. Zgłaszaj niedostępność Fable; zastępuj go Opus tylko na życzenie właściciela.
6. Sprawdzenie przez inną rodzinę wymaga wyraźnego upoważnienia użytkownika; routing nie upoważnia do uruchamiania agentów.
7. `ultra`: wyraźna delegacja lub `/swarm`; funkcje dostępne tylko przez API: [referencja](https://github.com/malinskibeniamin/skills/blob/main/codex/REFERENCE.md#routing-notes).

Zachowaj wybrany model i punkt końcowy; sprawdź identyfikatory i dostęp u hosta. Routing nie upoważnia do rekurencji, nowych wątków, płatnych kredytów ani cichych zmian modelu. Bez delegacji pracuj samodzielnie. Instrukcje określają cel, dane wejściowe, wyłączenia, dowody i warunek zakończenia; akceptacja pozostaje po stronie właściciela.
Przy pracy z Fable, przekazywaniu zadania lub zmianach promptów przeczytaj [wskazówki dotyczące promptów modeli](https://github.com/malinskibeniamin/skills/blob/main/shared/model-prompting.md).

## Limity [#capacity]

`/stay-within-limits`: pomiar hosta, w przeciwnym razie limit jest nieznany; nigdy nie szacuj go z tokenów lub kosztu ani nie obniżaj jakości.

## Zatwierdzanie [#promotion]

Wybrane przez właściciela `xhigh` nie oznacza zwycięstwa w ewaluacji. Niezamówione zmiany: `agent-evals/context-ablation/`; zmieniaj jedną grupę kontekstu, zachowuj stałe zadania i ocenianie, wybieraj niższy koszt tylko przy równej jakości; zapisz zwycięzcę w konfiguracji routingu.

[Pakiet do delegowania](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md).
