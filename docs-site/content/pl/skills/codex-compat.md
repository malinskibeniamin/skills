---
title: /codex-compat
description: >-
  Generuj powierzchnie zgodności Codex hooks.json i AGENTS.md na podstawie
  manifestu hooków Claude.
type: skill
sidebar:
  label: /codex-compat
---
![Diagram umiejętności /codex-compat](/diagrams/skills/codex-compat.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/codex-compat.excalidraw)

Codex obsługuje hooki cyklu życia w stylu Claude dla zdarzeń `SessionStart`, `SubagentStart`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PreCompact`, `PostCompact`, `UserPromptSubmit`, `SubagentStop` i `Stop` (https://developers.openai.com/codex/hooks). Zdarzenia dostępne wyłącznie w Claude, które nie mają odpowiednika w Codex -- `FileChanged`, `WorktreeCreate`, `SessionEnd`, `PostToolUseFailure` (włączone do `PostToolUse` w Codex) -- korzystają z mechanizmu awaryjnego Stop-batch lub są celowo pomijane. Matchery `PreToolUse`/`PostToolUse` obsługują `Bash`, nazwy narzędzi MCP, `apply_patch` oraz aliasy `Edit|Write`. Gdy to możliwe, mapuj hooki `Edit|Write` bezpośrednio. Uruchom `/read-the-damn-docs`, aby sprawdzić aktualne działanie hooków; użyj `/plan-arbiter`, gdy wybór między mapowaniem bezpośrednim a mechanizmem awaryjnym jest niejednoznaczny.

## Co zostanie utworzone

- **`.codex/hooks.json`** -- bezpośrednie tłumaczenie obsługiwanych hooków Claude
- **`.codex/hooks/codex-batch-check.sh`** -- mechanizm awaryjny tylko dla kontroli, których nie można uruchamiać dla poszczególnych zdarzeń narzędzi
- **`AGENTS.md`** + **`CLAUDE.md`** -- wspólne reguły projektu (Codex odczytuje AGENTS.md, a Claude Code odczytuje CLAUDE.md)
- **macierz zgodności** -- klasyfikuje hooki jako `direct`, `direct with shim`, `fallback only` lub `unsupported`

## Kroki

1. Odczytaj `.claude/settings.json` i sklasyfikuj każdy hook zgodnie z macierzą zgodności w pliku [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/codex-compat/REFERENCE.md).
2. Wygeneruj `.codex/hooks.json`:
   - `SessionStart`, `UserPromptSubmit`, `Stop` -> bezpośrednio
   - `PreToolUse` / `PostToolUse` z `Bash`, `Edit|Write`, `apply_patch`, `mcp__.*` -> bezpośrednio
   - `PermissionRequest` dla `Bash` / MCP / `apply_patch` -> bezpośrednio, jeśli skrypty obsługują dane wejściowe Codex
   - Nieobsługiwane zdarzenia lub typy procedur obsługi Claude -> pomiń, udokumentuj lub skieruj wyłącznie do mechanizmu awaryjnego, jeśli zachowuje to bezpieczną semantykę
3. Skopiuj `scripts/codex-batch-check.sh` -> `.codex/hooks/` tylko wtedy, gdy potrzebne są hooki awaryjne. `chmod +x`.
4. Skopiuj `hooks/frontend-skills.rules` -> `.codex/rules/` (podstawowa polityka execpolicy; działa bez flagi funkcji hooków).
5. Wygeneruj `AGENTS.md` + `CLAUDE.md` na podstawie szablonu z pliku [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/codex-compat/REFERENCE.md).
6. Włącz i oznacz jako zaufane: ustaw `[features] hooks = true` w `config.toml`, następnie uruchom `/hooks` w interfejsie TUI Codex i oznacz definicje jako zaufane (zrób to ponownie po każdej zmianie hooka; CI używa `--dangerously-bypass-hook-trust` lub zarządzanego katalogu hooków). Opcjonalnie skonfiguruj `notify = ["bash", "<repo>/.claude/hooks/codex-notify.sh"]` na potrzeby telemetrii zakończenia tury.

## Weryfikacja

- [ ] `.codex/hooks.json` zawiera bezpośrednie hooki PostToolUse `Edit|Write`, jeśli występują w źródle
- [ ] Skrypt kontroli wsadowej nie istnieje, chyba że wymaga go rzeczywisty hook obsługiwany wyłącznie przez mechanizm awaryjny
- [ ] Plik `.codex/rules/frontend-skills.rules` istnieje i jest identyczny z `hooks/frontend-skills.rules`
- [ ] Flaga funkcji hooków jest włączona, a definicje są zaufane (`/hooks` pokazuje je jako aktywne, a nie oczekujące)
- [ ] `AGENTS.md` + `CLAUDE.md` znajdują się w katalogu głównym repozytorium
- [ ] `.claude/settings.json` pozostaje bez zmian
