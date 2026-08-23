---
title: /stay-within-limits
description: >-
  Sprawdź dane dotyczące okna subskrypcji Claude dla jawnie wskazanej fali
  agentów.
type: skill
sidebar:
  label: /stay-within-limits
---
![Diagram umiejętności /stay-within-limits](/diagrams/skills/stay-within-limits.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/stay-within-limits.excalidraw)

Ta umiejętność zgodności, używana wyłącznie na wyraźne żądanie, zachowuje procedurę pomiaru limitów hosta. Wybór modelu,
kryteria jakości i kierowanie fal należą teraz do `/efficient-frontier` oraz
`config/model-routing.json`.

Używaj `select-review-profile.sh` tylko wtedy, gdy host udostępnia aktualny zrzut limitu
Claude Code. `ccusage` przedstawia historię kosztów, a nie dane o dostępnej pojemności subskrypcji. Brakujące lub nieaktualne
dane oznaczają, że dostępna pojemność Claude jest nieznana; nie zgaduj czasu resetowania limitu.

Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/stay-within-limits/REFERENCE.md), aby poznać mechanizm przechwytywania zrzutów i działania selektora. Zwróć
zaobserwowane okna i informacje o ich aktualności, a następnie pozwól `/efficient-frontier` wybrać trasę
spełniającą kryteria jakości. Wyraźne użycie nigdy nie oznacza zgody na delegowanie.

W tym repozytorium uruchom `bash stay-within-limits/select-review-profile.sh`.
