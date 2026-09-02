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


Audytuj `~/.claude/hook-metrics/`. Tury Codex są uwzględniane w przebiegu sesji, ale puste mapy hooków nie świadczą o braku aktywności. Plik [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/hook-audit/REFERENCE.md) definiuje metryki i progi.

Tryby: domyślny/`--hooks` — aktywność; `--retro` dodaje przebieg sesji; `--all` dodaje opóźnienia, uruchomienia umiejętności i rozbieżności.

## Przebieg

1. Sporządź wykaz hooków i zakresu dat; oddziel ewaluacje od rzeczywistych uruchomień i pogrupuj dane według wersji środowiska testowego i modelu. Rozdziel lub wyklucz sesje wymienione w `model-switches.jsonl`, zamiast przypisywać sesję z wieloma modelami do jednego modelu.
2. Zagreguj blokady, ostrzeżenia, sugestie, odmowy, sesje i trend.
3. Na żądanie oblicz P50/P95 oraz łączny czas rzeczywisty.
4. Porównaj skrypty z zaobserwowanymi kluczami; oznacz rzeczywistych kandydatów bez uruchomień.
5. Porównaj reguły z mechanizmami egzekwowania; odróżnij nieprzetestowane hooki od reguł doradczych.
6. Retrospektywa: opóźnienie PR, odsetek CI zakończonych powodzeniem za pierwszym razem, liczba rund przeglądu, czas oczekiwania na informacje zwrotne i liczba drzew roboczych.
7. Tryb pełny: sprawdź `skill-fires.jsonl` i `model-switches.jsonl`; uruchom `bash scripts/generate-hook-configs.sh --check`.
8. Zaproponuj maksymalnie pięć działań: `Prune` — pozbawiona uzasadnienia reguła bez uruchomień; `Soften` — zbyt częste blokady; `Harden` — ryzykowne ostrzeżenia; `Add` — brakująca reguła deterministyczna.

Przed usunięciem uruchom regułę w trybie obserwacyjnym za pomocą `HOOK_SHADOW_RULES` w reprezentatywnej próbie z określoną wersją; porównaj wyniki i naruszenia. Nigdy nie uruchamiaj w trybie obserwacyjnym rygorystycznych reguł bezpieczeństwa ani uprawnień.

## Zakończenie

Podaj metrykę, wartość, wielkość próby, trend z 7 dni i następne działanie. Przy mniej niż pięciu porównywalnych rzeczywistych sesjach oznacz wnioski jako wstępne. Dla rekomendacji usunięcia lub zmiany poziomu istotności wskaż pliki źródłowe oraz dokładną kohortę `harness_version` + `model`.
