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

Przeczytaj `config/model-routing.json`. Jest to wiążące źródło reguł routingu; nie powielaj
subiektywnych ocen modeli w promptach ani umiejętnościach.

Jakość jest najważniejsza:

1. Wybierz głównego właściciela, który najlepiej odpowiada zadaniu i dostępnym możliwościom środowiska uruchomieniowego.
2. Domyślny właściciel: Claude Opus 5.5 z ustawieniem `high` dla interfejsu użytkownika, kodu i planów.
3. Druga ścieżka: GPT-6 Sol z ustawieniem `medium` przez `/codex` do wykonania według jasnej specyfikacji, obsługi
   komputera i analizy problemów. Jeśli Sol jest niedostępny, użyj Astra `high` i wskaż zapas; nigdy tańszego modelu GPT.
3a. Przeglądy PR: Astra `high`, a w razie potrzeby dodatkowo Opus 5.5 `high`; `xhigh` tylko przy co najmniej 50% pozostałego limitu Codex.
4. Praca widoczna dla użytkowników (interfejs, teksty, projekt API) wymaga oceny gustu (taste >= 8) i właściciela Claude;
   Astra jest wskazanym zapasem tylko wtedy, gdy żaden właściciel Claude nie jest dostępny.
5. Drobne prace trafiają do GPT-6 Luna z ustawieniem `high`: małe zmiany, czyste rebase, mechaniczne poprawki CI,
   odczyt lub wylistowanie danych tylko do odczytu. Przy konfliktach, diagnozie lub decyzjach przekaż zadanie do Sol.
6. Fable 5.1 (maksymalnie `high`) tylko na wyraźną prośbę użytkownika przy wyjątkowej pracy. Używaj `xhigh`/`max`
   wyłącznie wtedy, gdy ablacja kontekstu potwierdza korzyść lub użytkownik wyraźnie wybierze to ustawienie.
7. Przegląd pozostaw głównemu właścicielowi, chyba że użytkownik wyraźnie zatwierdzi przebieg z użyciem innej rodziny modeli.
8. `ultra` oznacza zespół wielu agentów i wymaga wyraźnej delegacji lub `/swarm`.
   Tryb Pro, utrwalone rozumowanie, programowe wywoływanie narzędzi i jawna kontrola pamięci podręcznej
   są dostępne tylko przez API, chyba że aktywne środowisko je udostępnia.

Implementację prowadzi jeden właściciel. Bez wyraźnej delegacji wykonuj wszystkie przydatne ścieżki samodzielnie.
W przypadku delegacji każdej ścieżce przypisz jeden ograniczony cel, dane wejściowe, wyłączenia, wymagane
dowody i warunek zakończenia. Architektura, priorytetyzacja, ryzyko, synteza i
ostateczna akceptacja pozostają po stronie koordynatora.

## Limity

Limity subskrypcji Claude można sprawdzić za pomocą jawnej procedury pomiarowej hosta
`/stay-within-limits`. Nieznany limit należy zgłosić jako nieznany.
Nigdy nie szacuj go na podstawie lokalnych tokenów ani kosztu. Limit może wykluczyć daną ścieżkę, ale nie może obniżyć
wymagań jakościowych.

## Zatwierdzanie

Uruchom `agent-evals/context-ablation/` przed zmianą ustawień domyślnych. Porównuj jedną grupę kontekstu
naraz, zachowuj te same zadania i kryteria oceny oraz wybieraj niższy koszt tylko spośród
wyników o równoważnej jakości. Zapisz zwycięską politykę w `config/model-routing.json`.

Przeczytaj [references/builder-upstream.md](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md) tylko podczas tworzenia
zatwierdzonego pakietu delegacji.
