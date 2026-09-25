---
title: /work-automation-kit
description: >-
  Instalowanie przepływów planowania i zarządzania projektami: specyfikacji,
  podziału na zgłoszenia, dokumentacji trackera i triage.
type: skill
sidebar:
  label: /work-automation-kit
---
![Diagram umiejętności /work-automation-kit](/diagrams/skills/work-automation-kit.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/work-automation-kit.excalidraw)

Instaluje umiejętności obsługujące przepływy pracy i tworzy kontekst dla każdego repozytorium:

- Tracker zgłoszeń: GitHub, GitLab, lokalne pliki Markdown, Jira/Atlassian lub inne rozwiązanie.
- Etykiety triage: ciągi znaków projektu odpowiadające standardowym rolom.
- Dokumentacja domeny: `CONTEXT.md`, `CONTEXT-MAP.md`, układ ADR.

Sterowanie za pomocą promptów. Analiza -> prezentacja -> potwierdzenie -> zapis.

## Dostępne przepływy pracy

Zainstaluj po jednym egzemplarzu każdego elementu zestawu do planowania: `grilling`, `domain-modeling`, `triage`,
`diagnosing-bugs`, `prototype`, `to-questionnaire`, `to-spec`, `to-tickets`, `handoff`,
`writing-for-agents`, `visual-plan`, `visual-recap`, `plan-arbiter`, `agent-watchdog`,
`read-the-damn-docs` i `efficient-frontier`.

`setup-atlassian-workflow` jest opcjonalny dla systemu Jira obsługiwanego przez `acli`.

## Instalacja

```bash
for skill in \
  grilling domain-modeling triage diagnosing-bugs prototype to-questionnaire to-spec \
  to-tickets handoff writing-for-agents visual-plan visual-recap plan-arbiter \
  agent-watchdog read-the-damn-docs efficient-frontier
do
  bunx skills@latest add "malinskibeniamin/skills/$skill" --agent claude-code -y
done
```

## Opcjonalnie: Atlassian/Jira
Uruchom `setup-atlassian-workflow`, jeśli zespół korzysta z systemu Jira.

## Konfiguracja kontekstu projektu

Szczegółowe informacje znajdziesz w `REFERENCE.md`.

1. Sprawdź `git remote -v`, instrukcje dla agentów, istniejący katalog `docs/agents/`, dokumentację kontekstu, ADR-y, dostępność umiejętności `triage` oraz oznaki monorepozytorium (`pnpm-workspace.yaml`, obszary robocze pakietów lub wypełnione katalogi `packages/*/src`).
2. Najpierw przedstaw zalecany tracker; pytaj tylko wtedy, gdy wybór faktycznie prowadzi do różnych ścieżek.
3. Jeśli umiejętność `triage` jest zainstalowana, zadaj jedno pytanie: „Zachować domyślne etykiety triage?” (zalecana odpowiedź: **tak**). Jeśli użytkownik odpowie twierdząco, użyj pięciu standardowych nazw ról. Tylko jeśli odpowie przecząco, poproś o własne wartości. Jeśli umiejętność `triage` nie jest zainstalowana, pomiń konfigurację etykiet.
4. Jeśli nie ma oznak monorepozytorium, wybierz **pojedynczy kontekst bez pytania**. Zaoferuj **wiele kontekstów tylko dla monorepozytorium**, a następnie potwierdź układ.
5. Przed zapisem potwierdź wersje robocze dokumentów. Użyj ponownie `templates/`.
6. Wybierz plik instrukcji dla agentów w sposób deterministyczny: jeśli istnieje `CLAUDE.md`, edytuj go w pierwszej kolejności; w przeciwnym razie edytuj `AGENTS.md`. Jeśli nie istnieje żaden z nich, zapytaj, który utworzyć. Zaktualizuj tylko wybrany plik, a następnie zapisz zatwierdzone dokumenty:
   - `docs/agents/issue-tracker.md` z sekcją `## Wayfinding operations`, gdy umiejętność `/wayfinder` jest zainstalowana
   - `docs/agents/triage-labels.md` tylko wtedy, gdy umiejętność `triage` jest zainstalowana
   - `docs/agents/domain.md`
   - blok `## Agent skills` w wybranym pliku instrukcji dla agentów; musi zawierać sekcję `### Issue tracker` z jednowierszowym podsumowaniem i linkiem do `docs/agents/issue-tracker.md`, a także warunkowe odwołania do etykiet triage i dokumentacji domeny
7. Sprawdź, czy sekcja `### Issue tracker` istnieje w bloku instrukcji dla agentów i zawiera link do dokumentu wybranego trackera. Sprawdź również wszystkie wymagane etykiety, operacje Wayfinding i układ domeny.
