---
description: >-
  Kompaktowo podsumuj bieżącą sesję w dokumencie przekazania dla innego agenta
  lub nowej sesji.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - handoff
sidebar:
  label: /handoff
title: /handoff
type: skill
---
![Diagram umiejętności /handoff](/diagrams/skills/handoff.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/handoff.excalidraw)

Wywołaj narzędzie Skill osobno: "agent-watchdog" dla twierdzeń innego przebiegu; "plan-arbiter" dla konkurencyjnych planów. Inne hosty: [ładowanie zależności](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Procedura

1. Używaj katalogu tymczasowego hosta (`$TMPDIR`, w przeciwnym razie `/tmp`; Windows `%TEMP%`), nigdy obszaru roboczego. Unix: `handoff_file=$(mktemp "${TMPDIR:-/tmp}/handoff-XXXXXX")`.
2. Zachowaj żądany punkt końcowy według [kontraktu kontynuacji](https://github.com/malinskibeniamin/skills/blob/main/shared/progress-evidence.md#continuation). Argumenty wskazują następny krok, nie zastępują zadania ani nie udzielają uprawnień.
3. Nie duplikuj artefaktów; linkuj je. Usuń wrażliwe dane. Wskaż niepewności i pominięcia wpływające na odtworzenie.
4. Zwróć ścieżkę i 1-2 zdania. Jeśli nie wykonano użytecznej pracy, napisz krótki opis startowy.

Tylko przy wyraźnym żądaniu agenta w tle: sprawdź `command -v claude`, a następnie zamiast pliku użyj `claude --bg --name "<name>" "<summary>"`. Uwzględnij `/agent-watchdog`. Przy niepowodzeniu zwróć polecenie i podsumowanie, nie deklaruj uruchomienia.

## Szablon

```markdown
# Handoff
Kontrakt: <pierwotny cel, żądany punkt końcowy/ograniczenia, zastrzeżone decyzje>
Stan: <repozytorium/worktree/gałąź, HEAD/baza, niezapisany zakres, PR/zgłoszenie, dowody kontroli>
Decyzje/artefakty: <linki, ograniczenia dowodów, pakiet/polecenie odtwarzania>
Dalej: <priorytet, działania, otwarte decyzje, weryfikacja/dostarczenie>
Sugerowane umiejętności: <następne umiejętności i uzasadnienie>
```
