---
title: /efficient-frontier
description: >-
  Stosuj routing modeli oparty na ewaluacjach i planuj budżet wyraźnie
  zatwierdzonych fal agentów bez odbierania właścicielowi prawa do podejmowania
  decyzji.
type: skill
sidebar:
  label: /efficient-frontier
---
![Diagram umiejętności /efficient-frontier](/diagrams/skills/efficient-frontier.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/efficient-frontier.excalidraw)

Przed wyborem modelu przeczytaj [zasady wyboru narzędzi](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#protect-attention-while-working).

`config/model-routing.json` określa routing; nigdy nie kopiuj subiektywnych ocen do promptów.

1. Właściciel: Opus 5.5 `xhigh` do codziennej pracy, planów, kodu i UI.
2. Sol `xhigh` przegląda PR-y przez `/codex`; jeśli jest niedostępny, użyj oznaczonego przeglądu Opus `xhigh` z czystym kontekstem i ujawnij brak sprawdzenia przez inną rodzinę modeli.
3. UI, teksty i projekt API należą do Opus, z taste >= 8. Jeśli jest niedostępny, zgłoś blokadę zamiast potajemnie zmieniać model.
4. Drobne prace wykonuj samodzielnie na codziennym modelu Opus. Sol `xhigh` wykonuje zadania, obsługę komputera i analizę po wyborze Codex przez użytkownika.
5. Wybieraj tylko parę Opus/Sol; nigdy `max`. Jeśli żaden z modeli nie jest dostępny, zgłoś blokadę. Historyczne oceny nie zmieniają preferencji właściciela.
6. Sprawdzenie przez inną rodzinę wymaga wyraźnego upoważnienia; preferencja modelu nie upoważnia do uruchamiania agentów.
7. `ultra` wymaga wyraźnej delegacji lub `/swarm`. Tryb Pro, utrwalone rozumowanie, narzędzia programowe i jawny cache: tylko API, chyba że środowisko je udostępnia.

Implementację prowadzi jeden właściciel; bez delegacji wykonuj ścieżki samodzielnie. Zatwierdzone ścieżki otrzymują ograniczony cel, dane wejściowe, wyłączenia, dowody i warunek zakończenia. Właściciel zachowuje odpowiedzialność za architekturę, priorytety, ryzyko, syntezę i akceptację.

## Limity

Pomiar hosta `/stay-within-limits` określa limit; w przeciwnym razie jest nieznany. Nigdy nie szacuj go na podstawie tokenów ani kosztu. Limit wyklucza ścieżki, nigdy nie obniża jakości.

## Zatwierdzanie

Obecne ustawienia `xhigh` są jawnym wyborem właściciela, nie wynikiem awansu na podstawie benchmarków.
Przed niezamówioną zmianą ustawień domyślnych uruchom `agent-evals/context-ablation/`: porównuj jedną grupę kontekstu naraz, zachowuj te same zadania i kryteria oceny oraz wybieraj niższy koszt tylko spośród wyników o równoważnej jakości. Zapisz zwycięską politykę w `config/model-routing.json`.

Przeczytaj [references/builder-upstream.md](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md) tylko podczas tworzenia
zatwierdzonego pakietu delegacji.
