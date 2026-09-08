---
title: /hook-audit
description: >-
  Analizuj skuteczność hooków i telemetrię sesji. Używaj podczas audytu opóźnień
  hooków, naruszeń, reguł bez uruchomień, poziomów istotności, rozbieżności
  manifestu, uruchomień umiejętności, trendów sesji lub retrospektyw.
type: skill
sidebar:
  label: /hook-audit
---
![Diagram umiejętności /hook-audit](/diagrams/skills/hook-audit.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/hook-audit.excalidraw)


Audytuj `~/.claude/hook-metrics/`, korzystając z [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/hook-audit/REFERENCE.md) w zakresie metryk, kohort i braków danych.

Tryby: domyślny/`--hooks` — aktywność; `--retro` dodaje przebieg sesji i wnioski dotyczące środowiska; `--all` obejmuje retrospektywę, opóźnienia, uruchomienia umiejętności i rozbieżności.

## Przebieg

1. Sporządź wykaz hooków i zakresu dat; oddziel ewaluacje od rzeczywistych uruchomień. Grupuj według wersji środowiska i modelu; rozdziel lub wyklucz sesje z wieloma modelami na podstawie `model-switches.jsonl`.
2. Zagreguj blokady, ostrzeżenia, sugestie, odmowy, sesje i trend; na żądanie oblicz P50/P95 oraz łączny czas rzeczywisty.
3. Porównaj skrypty, zaobserwowane klucze i egzekwowanie reguł; odróżnij rzeczywistych kandydatów bez uruchomień, nieprzetestowane hooki i reguły doradcze.
4. Retrospektywa: zastosuj [retrospektywę środowiska sesji](https://github.com/malinskibeniamin/skills/blob/main/hook-audit/REFERENCE.md#session-environment-retrospective); dodaj dostępne metryki retrospektywy. Brak telemetrii nie blokuje wniosków z transkrypcji.
5. Tryb pełny: sprawdź `skill-fires.jsonl`; uruchom `bash scripts/generate-hook-configs.sh --check`.
6. Zasady przełączania modeli: użyj `/quantify-impact`; powodzenie zadania lub ilość poprawek jest główną miarą, a koszt zapisu pamięci podręcznej — ograniczeniem.
7. Uszereguj według wpływu maksymalnie pięć działań łącznie z telemetrii i wniosków z sesji. Przedstaw tylko rekomendacje, chyba że zlecono wdrożenie.

Przed usunięciem uruchom regułę w trybie obserwacyjnym za pomocą `HOOK_SHADOW_RULES` w reprezentatywnej próbie z określoną wersją; porównaj wyniki i naruszenia. Nigdy nie uruchamiaj w trybie obserwacyjnym rygorystycznych reguł bezpieczeństwa ani uprawnień.

## Zakończenie

Podaj dostępne metryki i wartości, wielkość próby, trend z 7 dni i następne działanie; oznacz braki jako niedostępne. Przy mniej niż pięciu porównywalnych rzeczywistych sesjach oznacz wnioski jako wstępne. Dla rekomendacji usunięcia lub zmiany poziomu istotności wskaż pliki źródłowe oraz dokładną kohortę `harness_version` + `model`.
