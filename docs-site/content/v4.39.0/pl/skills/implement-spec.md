---
title: "/implement-spec"
description: "Zaimplementuj całą specyfikację i jej zgłoszenia na jednej gałęzi integracyjnej za pomocą równoległych subagentów implementujących."
type: skill
sidebar:
  label: "/implement-spec"
---
![Diagram umiejętności /implement-spec](/diagrams/skills/implement-spec.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/implement-spec.excalidraw)


Otrzymujesz specyfikację. Powinny być z nią powiązane zgłoszenia opisujące, jak ją zaimplementować.

Wywołanie tej umiejętności jest wyraźną prośbą użytkownika o delegowanie i równoległych agentów.

Jeśli istnieje `CLAUDE.md`, najpierw przeczytaj `CLAUDE.md`; w przeciwnym razie przeczytaj `AGENTS.md`. Postępuj zgodnie ze wskazaniem na system zgłoszeń. Jeśli go brak, poproś użytkownika o uruchomienie `/work-automation-kit`.

Celem jest cała specyfikacja zaimplementowana na jednej **gałęzi integracyjnej**, z każdym zgłoszeniem zamkniętym w sposób, w jaki system zgłoszeń zamyka pracę.

Zgłoszenia nie są listą kroków. Tworzą **graf zadań** z relacjami blokowania. Oznacza to, że zawsze istnieje **front** zgłoszeń gotowych do podjęcia.

Komunikacja z subagentami i od nich powinna być oszczędna. Komunikuj się głównie przez **wskaźniki kontekstu**: do specyfikacji, zgłoszeń, notatek z badań i wcześniejszych commitów. Nie powielaj informacji dostępnych przez wskaźniki.

**Subagentów implementujących** uruchamiaj w tle, gdy to możliwe, aby uzyskać **maksymalną współbieżność**.

## Kroki

1. Przeczytaj specyfikację i zgłoszenia. Przeczytaj tyle, by zrozumieć graf zadań.

2. (opcjonalnie) Użyj **subagenta eksplorującego** do przeprowadzenia eksploracji wymaganej przez zgłoszenia – odpowiednich plików kodu lub zewnętrznej dokumentacji. Upewnij się, że subagent eksplorujący może zapisywać pliki – powinien zapisać notatki Markdown w katalogu poza repozytorium, dostępnym dla wszystkich przyszłych subagentów. Dzięki temu **subagenci implementujący** mogą skupić się na implementacji, a nie na eksploracji.

3. Utwórz gałąź integracyjną. Jeśli system zgłoszeń zamyka pracę przez PR-y lub użytkownik o to prosi, otwórz szkic PR po pierwszym scaleniu w kroku 5 (gałęzi bez commitów wyprzedzających main nie da się otworzyć), oznaczony jako zamykający specyfikację i zgłoszenia.

4. Użyj **subagentów implementujących** do zaimplementowania każdego zgłoszenia, każdy we własnym worktree na własnej gałęzi. Każdy subagent implementujący:
   - przed rozpoczęciem potwierdza, że jego worktree bazuje na gałęzi integracyjnej, a jeśli nie, przestawia się na nią;
   - buduje zgłoszenie za pomocą `/tdd`;
   - przed zgłoszeniem ukończenia scala najnowszy stan gałęzi integracyjnej do własnej gałęzi, aby krok 5 był przewinięciem (fast-forward).

5. Gdy **subagent implementujący** skończy, scal jego pracę do gałęzi integracyjnej za pomocą **subagenta scalającego**.

6. Jeśli zmienia to **front** dostępnych zgłoszeń, uruchom kolejnych **subagentów implementujących** dla nowych zgłoszeń. Pozwala to osiągnąć maksymalną współbieżność.

7. Gdy wszystkie zgłoszenia są ukończone, uruchom `/review` na gałęzi integracyjnej. Napraw wszystkie problemy zgłoszone w przeglądzie kodu w jednym **subagencie implementującym**.

8. Jeśli istnieje szkic PR, oznacz go jako gotowy do przeglądu. W przeciwnym razie zamknij każde zgłoszenie w sposób, w jaki system zgłoszeń zamyka pracę, i podaj gałąź integracyjną.

9. Usuń wszystkie worktree **subagentów implementujących**.
