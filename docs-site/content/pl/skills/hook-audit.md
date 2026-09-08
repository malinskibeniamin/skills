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

Tryby: domyślny/`--hooks` — aktywność; `--retro` dodaje przebieg sesji i wnioski dotyczące środowiska; `--all` obejmuje retrospektywę oraz opóźnienia, uruchomienia umiejętności i rozbieżności.

## Przebieg

1. Sporządź wykaz hooków i zakresu dat; oddziel ewaluacje od rzeczywistych uruchomień i pogrupuj dane według wersji środowiska testowego i modelu. Rozdziel lub wyklucz sesje wymienione w `model-switches.jsonl`, zamiast przypisywać sesję z wieloma modelami do jednego modelu.
2. Zagreguj blokady, ostrzeżenia, sugestie, odmowy, sesje i trend.
3. Na żądanie oblicz P50/P95 oraz łączny czas rzeczywisty.
4. Porównaj skrypty z zaobserwowanymi kluczami; oznacz rzeczywistych kandydatów bez uruchomień.
5. Porównaj reguły z mechanizmami egzekwowania; odróżnij nieprzetestowane hooki od reguł doradczych.
6. Retrospektywa: zastosuj [retrospektywę środowiska sesji](https://github.com/malinskibeniamin/skills/blob/main/hook-audit/REFERENCE.md#session-environment-retrospective) do wskazanej sesji, a domyślnie do bieżącej. Dodaj dostępne metryki opóźnienia PR, odsetka CI zakończonych powodzeniem za pierwszym razem, rund przeglądu, czasu oczekiwania na informacje zwrotne i drzew roboczych; brak telemetrii nie blokuje wniosków opartych na transkrypcji.
7. Tryb pełny: sprawdź `skill-fires.jsonl` i `model-switches.jsonl`; uruchom `bash scripts/generate-hook-configs.sh --check`.
8. Zasady przełączania modeli: użyj `/quantify-impact`; powodzenie zadania lub ilość poprawek jest główną miarą, a koszt zapisu pamięci podręcznej — ograniczeniem.
9. Uszereguj według wpływu maksymalnie pięć działań łącznie z telemetrii i wniosków z sesji. Dla działań dotyczących egzekwowania reguł: `Prune` — pozbawiona uzasadnienia reguła bez uruchomień; `Soften` — zbyt częste blokady; `Harden` — ryzykowne ostrzeżenia; `Add` — brakująca reguła deterministyczna. Przedstaw tylko rekomendacje, chyba że zlecono wdrożenie.

Przed usunięciem uruchom regułę w trybie obserwacyjnym za pomocą `HOOK_SHADOW_RULES` w reprezentatywnej próbie z określoną wersją; porównaj wyniki i naruszenia. Nigdy nie uruchamiaj w trybie obserwacyjnym rygorystycznych reguł bezpieczeństwa ani uprawnień.

## Zakończenie

Dla dostępnej telemetrii podaj metrykę, wartość, wielkość próby, trend z 7 dni i następne działanie; oznacz braki jako niedostępne. Wnioski z retrospektywy przedstaw w formacie dowodów z pliku referencyjnego. Przy mniej niż pięciu porównywalnych rzeczywistych sesjach oznacz wnioski jako wstępne. Dla rekomendacji usunięcia lub zmiany poziomu istotności wskaż pliki źródłowe oraz dokładną kohortę `harness_version` + `model`.
