---
title: /writing-for-agents
description: >-
  Pisanie dokumentów dla agentów. Używaj podczas tworzenia lub edytowania
  umiejętności albo modyfikowania plików AGENTS.md lub CLAUDE.md.
type: skill
sidebar:
  label: /writing-for-agents
---
![Diagram umiejętności /writing-for-agents](/diagrams/skills/writing-for-agents.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/writing-for-agents.excalidraw)

Pisz instrukcje dla agentów, które zmieniają zachowanie przy minimalnym użyciu kontekstu.
Dotyczy to umiejętności, plików `AGENTS.md`, `CLAUDE.md` i wskazanych materiałów.

Podczas pisania umiejętności przeczytaj [SKILL-MECHANICS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/writing-for-agents/SKILL-MECHANICS.md), aby poznać zasady frontmatter, wyboru sposobu wywołania i routerów.

## Umieszczaj informacje na właściwym poziomie

**Wskaźnik kontekstu** nazywa materiał poza wczytanym dokumentem i określa, kiedy go
przeczytać. Wskaźnik zużywa obciążenie kontekstu; jego brak obciąża pamięć człowieka.

**Stopniowe ujawnianie** używa najpłytszego uzasadnionego poziomu:

1. Umieszczaj bezpośrednio kroki potrzebne w każdym wykonaniu.
2. Umieszczaj bezpośrednio materiały potrzebne podczas tych kroków.
3. Łącz materiały dotyczące wybranych gałęzi przez precyzyjny wskaźnik kontekstu.
4. Traktuj środowisko jako źródło prawdy; zapisuj w dokumencie tylko kosztowne wyszukiwania.
   Fakty pozostaw konfiguracji, układowi lub `--help`.

Zacznij każdy wskaźnik od mocnego wyzwalacza. Nazwij każdą gałąź raz. Nie ukrywaj
obowiązkowego kroku w materiale referencyjnym.

## Pisz instrukcje wykonywalne

- Używaj trybu rozkazującego i terminów repozytorium.
- Kończ każdy krok obserwowalnym kryterium ukończenia.
- Definiuj słowo przewodnie tylko wtedy, gdy zastępuje powtarzane wyjaśnienie i ułatwia zapamiętanie.
- Negacja aktywuje nazwane zachowanie. Wskazuj pozytywny cel; zakaz zachowuj tylko dla bezwzględnej zasady ochronnej i podaj bezpieczne działanie.
- Dziel sekwencję tylko wtedy, gdy widoczne późniejsze kroki powodują przedwczesne ukończenie.

## Skróć przed publikacją

Szukaj instrukcji bez efektu: przy każdym wierszu zapytaj, jakie zachowanie zmieni się po
jego usunięciu. Jeśli żadne, usuń wiersz.

- Zachowaj każde znaczenie w jednym źródle prawdy.
- Usuń informacje identyfikacyjne zawarte już w pliku, celu lub nagłówku.
- Usuń powtórzenia żądania, pochwały, opis procesu i powtórzone wnioski.
- Zastąp wyjaśnienie precyzyjną regułą lub jednym rozstrzygającym przykładem.
- Zachowaj uzasadnienie tylko wtedy, gdy zapobiega prawdopodobnemu błędnemu działaniu.
- Uprość niejasny kod lub konfigurację zamiast opisywać oczywisty mechanizm.
- Przenieś szczegóły gałęzi za wskaźnik; definicję, regułę i zastrzeżenia trzymaj razem.

Zakończ, gdy najkrótsza wersja nadal wybiera właściwą gałąź, zachowuje każdą zasadę
ochronną i umożliwia sprawdzenie ukończenia.
