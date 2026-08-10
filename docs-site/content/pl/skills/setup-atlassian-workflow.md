---
title: /setup-atlassian-workflow
description: >-
  Skonfiguruj opcjonalne przepływy pracy Jira przez acli do obsługi elementów
  pracy, statusów, komentarzy i linków do PR-ów.
type: skill
sidebar:
  label: /setup-atlassian-workflow
---
![Diagram umiejętności /setup-atlassian-workflow](/diagrams/skills/setup-atlassian-workflow.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/setup-atlassian-workflow.excalidraw)

Opcjonalna integracja z Jira przez `acli` (Atlassian CLI). Działa równolegle z `gh`. Jeśli brakuje `acli`, operacje Jira są po cichu pomijane.

Możliwości: tworzenie i przenoszenie elementów pracy, dodawanie komentarzy, łączenie PR-ów oraz wyszukiwanie i wyświetlanie kontekstu.

Wzorce poleceń acli znajdziesz w pliku [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/setup-atlassian-workflow/REFERENCE.md).

## Kroki

### 1. Instalacja i uwierzytelnienie
```bash
# Install: https://developer.atlassian.com/cloud/acli/guides/installation/
acli jira auth login
acli jira auth status  # verify
```

### 2. Konfiguracja session-env.sh
```bash
if command -v acli &>/dev/null; then
  echo "export JIRA_PROJECT=YOUR_PROJECT_KEY" >> "$CLAUDE_ENV_FILE"
  echo "export ISSUE_TRACKER=acli" >> "$CLAUDE_ENV_FILE"
fi
```
Ustaw `ISSUE_TRACKER=both`, aby równolegle używać gh i acli.

### 3. Weryfikacja
- [ ] `acli jira auth status` potwierdza uwierzytelnienie
- [ ] `JIRA_PROJECT` jest ustawiona w środowisku sesji
