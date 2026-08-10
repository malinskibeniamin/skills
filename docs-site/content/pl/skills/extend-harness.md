---
title: /extend-harness
description: >-
  Rozszerzaj i debuguj infrastrukturę hooków frontend-skills, reguły, poziomy
  istotności oraz analitykę.
type: skill
sidebar:
  label: /extend-harness
---
![Diagram umiejętności /extend-harness](/diagrams/skills/extend-harness.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/extend-harness.excalidraw)

Edytuj manifesty i biblioteki źródłowe, nigdy wygenerowane konfiguracje. Przeczytaj
[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/extend-harness/REFERENCE.md), aby poznać poziomy istotności, opcje manifestu, kontrakty parserów oraz
sposoby debugowania.

## Dodawanie reguły

1. Sprawdź, czy można ją wyrazić za pomocą Biome lub Ultracite. Używaj hooków tylko do reguł obejmujących wiele elementów,
   plików lub przepływów pracy oraz reguł zachowania agentów.
2. Zacznij od sąsiedniego pliku `.claude/hooks/checks/*.lib.sh`. Udostępnij jedną funkcję `run_*`
   i dodaj odpowiadający jej prosty skrypt opakowujący `.claude/hooks/*.sh`.
3. Zarejestruj skrypt opakowujący w `skill-manifest.json`, zwykle w sekcji
   `PostToolUse.Edit|Write`.
4. Dodaj ukierunkowaną próbkę testową w katalogu `evals/`; zarejestruj najpierw wynik negatywny, a następnie pozytywny.
5. Wygeneruj ponownie konfigurację i przetestuj:

```bash
bash scripts/generate-hook-configs.sh --apply
echo '{"hook_event_name":"PostToolUse","tool_name":"Edit","tool_input":{"file_path":"/tmp/x.ts"}}' |
  bash .claude/hooks/my-check.sh
```

Używaj `hook_warn` dla reguł stylistycznych, `hook_block` dla poprawności, `hook_block_strict` dla
reguł krytycznych dla bezpieczeństwa, a `hook_info` do obserwacji. Preferuj hooki ograniczone do umiejętności, gdy
reguła jest potrzebna tylko w jednym obszarze funkcjonalnym.

## Wybór implementacji

- Wpisy filtrowane według uprawnień lub asynchroniczne definiuj jako obiekty manifestu; zachowaj kontrolę standardowego wejścia
  w każdym skrypcie, ponieważ Codex pomija filtry przeznaczone wyłącznie dla Claude.
- Strukturę, którą można mechanicznie zweryfikować, sprawdzaj w Biome lub za pomocą reguły AST. Niejednoznaczną
  ocenę strukturalną pozostaw do przeglądu; unikaj zawodnego wielowierszowego wyszukiwania za pomocą grep.
- Synchronizuj zakazy dotyczące narzędzi z `hooks/frontend-skills.rules`.

## Audyt lub debugowanie

- Uruchom `/hook-audit --all`, aby sprawdzić opóźnienia, uruchamianie hooków i kandydatów z zerową liczbą uruchomień.
- W przypadku brakującego hooka uruchom `HOOK_DEBUG=1 HOOKS_FAIL_CLOSED=1 claude`.
- Użyj `claude --safe-mode`, aby odizolować rozszerzenia.
- Uznawaj wykryte przez `/doctor` opóźnienia za przekroczenia budżetu P95.

## Kryteria ukończenia

- `skill-manifest.json` definiuje regułę i mechanizm dopasowania.
- Skrypt jest wykonywalny, ładuje `_hook-lib.sh`, analizuje standardowe wejście, filtruje ścieżki oraz
  dokumentuje sposób wyłączenia reguły.
- Ukierunkowana próbka testowa potwierdza przejście RED -> GREEN.
- Polecenie `bash scripts/generate-hook-configs.sh --check` kończy się powodzeniem.
- Polecenie `bash evals/run.sh` kończy się powodzeniem.
