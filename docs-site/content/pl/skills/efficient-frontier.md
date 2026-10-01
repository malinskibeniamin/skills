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

1. Właściciel: Opus 5.5 `high` (UI, kod, plany).
2. Druga ścieżka: Sol `medium` przez `/codex` (wykonanie według jasnej specyfikacji, obsługa komputera, analiza); niedostępny -> wskazany Astra `high`, nigdy tańszy GPT.
3. Astra `high` przegląda PR-y, w razie potrzeby Opus 5.5 `high`; `xhigh`, gdy pozostało co najmniej 50% limitu Codex.
4. UI, teksty, projekt API: taste >= 8 i właściciel Claude; w przeciwnym razie wskazany Astra jako zapas.
5. Drobne prace: Luna `high` (małe edycje, czyste rebase, mechaniczne poprawki CI, listy tylko do odczytu); konflikty, diagnoza, ocena -> Sol.
6. Fable 5.1 (maksymalnie `high`): wyraźna prośba, tylko wyjątkowa praca. `xhigh`: dowody z ablacji kontekstu lub wybór użytkownika; nigdy `max`.
7. Użytkownik wyraźnie upoważnia do sprawdzenia przez inną rodzinę modeli.
8. `ultra` wymaga wyraźnej delegacji lub `/swarm`. Tryb Pro, utrwalone rozumowanie, narzędzia programowe i jawny cache: tylko API, chyba że środowisko je udostępnia.

Implementację prowadzi jeden właściciel; bez delegacji wykonuj ścieżki samodzielnie. Zatwierdzone ścieżki otrzymują ograniczony cel, dane wejściowe, wyłączenia, dowody i warunek zakończenia. Właściciel zachowuje odpowiedzialność za architekturę, priorytety, ryzyko, syntezę i akceptację.

## Limity

Pomiar hosta `/stay-within-limits` określa limit; w przeciwnym razie jest nieznany. Nigdy nie szacuj go na podstawie tokenów ani kosztu. Limit wyklucza ścieżki, nigdy nie obniża jakości.

## Zatwierdzanie

Uruchom `agent-evals/context-ablation/` przed zmianą ustawień domyślnych. Porównuj jedną grupę kontekstu
naraz, zachowuj te same zadania i kryteria oceny oraz wybieraj niższy koszt tylko spośród
wyników o równoważnej jakości. Zapisz zwycięską politykę w `config/model-routing.json`.

Przeczytaj [references/builder-upstream.md](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md) tylko podczas tworzenia
zatwierdzonego pakietu delegacji.
