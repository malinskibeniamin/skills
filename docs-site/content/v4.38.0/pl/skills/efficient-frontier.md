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
2. Domyślnie używaj GPT-5.6 Sol z ustawieniem `xhigh`; Sol może odpowiadać za interfejs użytkownika, implementację, plany,
   przegląd i obsługę komputera.
3. Używaj `max` wyłącznie do trudnych zadań, w których jakość jest priorytetem, gdy ablacja kontekstu potwierdza
   korzyść lub użytkownik wyraźnie wybierze to ustawienie.
4. Traktuj Terra i Luna jako modele dopuszczane na podstawie ewaluacji. Nie kieruj do nich kodu produktu ani przeglądu, dopóki
   wersjonowana ewaluacja zachowania nie zatwierdzi takiego zastosowania.
5. Fable lub Opus mogą odpowiadać za pracę, gdy są dostępne i spełniają wymagania jakościowe. Przegląd pozostaw
   głównemu właścicielowi, chyba że użytkownik wyraźnie zatwierdzi przebieg z użyciem innej rodziny modeli.
6. `ultra` oznacza zespół wielu agentów i wymaga wyraźnej delegacji lub `/swarm`.
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

Przeczytaj [references/builder-upstream.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/efficient-frontier/references/builder-upstream.md) tylko podczas tworzenia
zatwierdzonego pakietu delegacji.
