---
title: /visual-plan
description: >-
  Twórz interaktywne, natywne dla agentów plany wizualne z diagramami, mapami
  plików, kodem z adnotacjami i przeglądem interfejsu. Używaj podczas planowania
  nietrywialnych produktów, interfejsów, architektury, danych, API lub
  konkurencyjnych opcji.
type: skill
sidebar:
  label: /visual-plan
---
![Diagram umiejętności /visual-plan](/diagrams/skills/visual-plan.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/visual-plan.excalidraw)

Lokalne nadpisanie: zamień przykłady z nadrzędnego źródła zawierające `npx @agent-native/core` na `bunx @agent-native/core`.

## Wymagane materiały referencyjne

Przed utworzeniem lub aktualizacją planu wizualnego przeczytaj `references/agent-native-plan.md`. Plik ten definiuje pełny kontrakt planu natywnego dla agentów, sposób użycia Plan MCP, wymagania dotyczące katalogu bloków, wybór powierzchni wizualnej, cykl komentarzy, tryb prywatności plików lokalnych oraz reguły jakości dokumentu.

Poniższe materiały przeczytaj tylko wtedy, gdy są istotne:

- `references/connection.md` -- wykrywanie konektora, mechanizm awaryjny bez osadzania treści i kroki ponownego połączenia.
- `references/local-files.md` -- lokalny, offline’owy i prywatny tryb planu.
- `references/wireframe.md` -- reguły HTML/CSS dla makiety.
- `references/canvas.md` -- powierzchnia przeglądu kanwy/prototypu.
- `references/document-quality.md` -- kryteria jakości samodzielnego planu.
- `references/exemplar.md` -- przykładowa struktura planu.

## Lokalne rozszerzenie środowiska testowego

- Użyj `/plan-arbiter`, gdy wiele planów lub agentów jest ze sobą sprzecznych.
- Użyj `/grilling` przed implementacją, jeśli decyzje pozostają otwarte.
- Planowanie jest tylko do odczytu, chyba że użytkownik wyraźnie zatwierdzi implementację.
