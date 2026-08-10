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

Audytuj pliki sesji w `~/.claude/hook-metrics/`. Rekordy tur Codex są uwzględniane w przebiegu sesji, ale ich puste mapy hooków nie oznaczają, że hooki są nieaktywne. Definicje metryk i progi znajdziesz w pliku [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/hook-audit/REFERENCE.md).

Tryby:

- domyślny lub `--hooks`: aktywność hooków, brak uruchomień, poziom istotności, egzekwowanie.
- `--retro`: dodaje metryki przebiegu sesji.
- `--all`: uwzględnia opóźnienia, uruchomienia umiejętności i rozbieżności manifestu.

## Przebieg

1. Sporządź wykaz zainstalowanych hooków i zakres dat metryk. Oddziel rzeczywiste uruchomienia od ewaluacji i przed porównaniem pogrupuj dane według wersji środowiska testowego i modelu.
2. Zagreguj dla każdego hooka: blokady, ostrzeżenia, sugestie, odmowy, sesje i trend.
3. Na żądanie oblicz opóźnienia P50/P95 oraz łączny czas rzeczywisty.
4. Porównaj zainstalowane skrypty z zaobserwowanymi kluczami; oznacz rzeczywistych kandydatów bez uruchomień.
5. Porównaj reguły agentów z mechanizmami egzekwowania; odróżnij nieprzetestowane hooki od reguł doradczych.
6. W trybie retrospektywy zmierz opóźnienie PR, odsetek CI zakończonych powodzeniem za pierwszym razem, liczbę rund przeglądu, czas oczekiwania na informacje zwrotne od człowieka oraz liczbę drzew roboczych.
7. W trybie pełnym sprawdź `skill-fires.jsonl` i uruchom:

```bash
bash scripts/generate-hook-configs.sh --check
```

8. Zaproponuj maksymalnie pięć działań:
   - `Prune`: reguła nigdy się nie uruchamia i nie ma uzasadnienia popartego danymi.
   - `Soften`: reguła blokuje zbyt często.
   - `Harden`: częste ostrzeżenia potwierdzają ryzyko błędów.
   - `Add`: brakuje egzekwowania deterministycznej reguły o wysokiej wartości.

W przypadku reguły przeznaczonej do usunięcia uruchom ją w trybie obserwacyjnym za pomocą `HOOK_SHADOW_RULES` w reprezentatywnej próbie z określoną wersją. Przed usunięciem mechanizmu egzekwowania porównaj wyniki zadań i naruszenia. Nigdy nie uruchamiaj w trybie obserwacyjnym rygorystycznych reguł bezpieczeństwa ani uprawnień.

## Zakończenie

Dla każdej metryki podaj wartość, wielkość próby, trend z 7 dni i następne działanie. Przy mniej niż pięciu porównywalnych rzeczywistych sesjach oznacz wnioski jako wstępne. Dla każdej rekomendacji usunięcia lub zmiany poziomu istotności wskaż pliki źródłowe oraz dokładną kohortę `harness_version` + `model`.
