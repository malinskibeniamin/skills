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

Zainstaluj umiejętności przepływu pracy i przygotuj etykiety trackera, kontekst domeny oraz układ ADR. Pętla promptu: eksploruj -> przedstaw -> potwierdź -> zapisz.

## Instalacja [#install]

Zainstaluj raz:

```bash
for skill in grilling domain-modeling triage diagnosing-bugs prototype \
  implement-spec pr retro tdd codebase-design review \
  to-questionnaire to-spec to-tickets handoff writing-for-agents visual-plan \
  visual-recap plan-arbiter agent-watchdog read-the-damn-docs efficient-frontier
do
  bunx skills@latest add "malinskibeniamin/skills/$skill" --agent claude-code -y
done
```

Dla Jiry opcjonalnie dodaj `setup-atlassian-workflow` przez `acli`.

## Kontekst projektu [#project-context]

Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/work-automation-kit/REFERENCE.md), a następnie:

1. Sprawdź zdalne repozytoria, reguły agentów, `docs/agents/`, słownik/ADR-y, dostępność triage oraz oznaki monorepozytorium.
2. Najpierw zalecaj tracker; pytaj tylko wtedy, gdy wybór prowadzi do różnych ścieżek.
3. Jeśli triage jest zainstalowane, zapytaj, czy zachować pięć domyślnych etykiet standardowych ról (zalecane: tak); zbieraj własne wartości tylko po odpowiedzi „nie”. W przeciwnym razie pomiń etykiety.
4. Dla repozytoriów innych niż monorepo wybierz pojedynczy kontekst bez pytania. Oferuj wiele kontekstów tylko dla monorepozytorium, a następnie potwierdź układ.
5. Potwierdź dokumenty robocze przed zapisem; wykorzystuj ponownie `templates/`.
6. Wybierz jeden plik instrukcji: edytuj najpierw `CLAUDE.md`, jeśli istnieje, w przeciwnym razie `AGENTS.md`; jeśli nie ma żadnego z nich, zapytaj, który utworzyć. Zapisz zatwierdzone:
   - `docs/agents/issue-tracker.md`, z `## Wayfinding operations`, gdy istnieje `/wayfinder`;
   - `docs/agents/triage-labels.md` tylko z triage;
   - `docs/agents/domain.md`;
   - blok `## Agent skills` w wybranym pliku, z `### Issue tracker`, podsumowaniem/linkiem oraz warunkowymi odwołaniami do etykiet i domeny.
7. Po zapisie sprawdź `### Issue tracker` i jego link, a także etykiety, operacje Wayfinding oraz układ kontekstu.
