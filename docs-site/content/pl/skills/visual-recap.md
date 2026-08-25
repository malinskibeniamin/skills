---
title: /visual-recap
description: Utwórz interaktywne podsumowanie wizualne dla PR, gałęzi, commita lub diffu.
type: skill
sidebar:
  label: /visual-recap
---
![Diagram umiejętności /visual-recap](/diagrams/skills/visual-recap.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/visual-recap.excalidraw)

Lokalne nadpisanie: zamień przykłady z nadrzędnego źródła używające `npx @agent-native/core` na `bunx @agent-native/core`.

## Wymagane materiały referencyjne

Przed utworzeniem podsumowania przeczytaj `references/agent-native-recap.md`. Ten dokument określa pełny kontrakt tworzenia podsumowania wizualnego, regułę never-inline, reguły adresów URL Plan MCP, mapowanie diffów na bloki, anonimizację, widoczność kwestii bezpieczeństwa, tryb prywatności plików lokalnych oraz pętlę informacji zwrotnej z przeglądu.

Poniższe dokumenty czytaj tylko wtedy, gdy są istotne:

- `references/connection.md` -- wykrywanie konektora, kroki ponownego łączenia i procedura awaryjna never-inline.
- `references/local-files.md` -- lokalny tryb podsumowania bez hostowanej bazy danych.
- `references/wireframe.md` -- reguły makiet interfejsu dla widocznych diffów.

## Lokalne rozszerzenie środowiska testowego

- Stosuj [`../shared/intent-map.md`](https://github.com/malinskibeniamin/skills/blob/main/shared/intent-map.md), gdy diff ma istotną strukturę przyczynową. Oprzyj każdy węzeł i każdą krawędź na rzeczywistej zmianie, oznacz wnioski i użyj istniejącej powierzchni diagramu podsumowania zamiast tworzyć drugi artefakt.
- Gdy użytkownik jawnie wywoła `/visual-recap`, utwórz podsumowanie lub połącz je ze wskazanym PR, gałęzią,
  commitem albo diffem.
- Utworzenie podsumowania jest dodatkową pracą nad artefaktem; `/commit-push-pr` i `/go` nie wywołują go
  automatycznie.
- W przypadku istotnej zmiany architektury lub przepływu danych użyj `/excalidraw-diagram`, aby utworzyć
  źródło `.excalidraw` oraz plik PNG lub SVG. Zachowaj podsumowanie Agent-Native jako główną
  przestrzeń przeglądu: osadź wyrenderowany zasób tylko wtedy, gdy bieżący katalog bloków obsługuje multimedia;
  w przeciwnym razie użyj bloku `diagram` i podaj ścieżki do źródła oraz eksportu w przekazaniu wyników.
  W przypadku prostego grafu lub gdy kanwa jest niedostępna preferuj wbudowaną ścieżkę Mermaid.
- Opieraj podsumowania na rzeczywistym diffie. Ukrywaj dane poufne i nie wyciągaj wniosków, których nie potwierdzają zmienione wiersze.
- Jeśli jawnie wskazany cel nie ma istotnej struktury wizualnej, zwróć potwierdzające to dane
  zamiast tworzyć sztuczne podsumowanie.
