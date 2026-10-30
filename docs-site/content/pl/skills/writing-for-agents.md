---
description: >-
  Pisanie dokumentów dla agentów. Używaj podczas tworzenia lub edytowania
  umiejętności albo modyfikowania plików AGENTS.md lub CLAUDE.md.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - writing for agents
sidebar:
  label: /writing-for-agents
title: /writing-for-agents
type: skill
---
![Diagram umiejętności /writing-for-agents](/diagrams/skills/writing-for-agents.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/writing-for-agents.excalidraw)

Gdy poprawka się powtarza lub umiejętność wymaga ulepszenia, przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#harness-improvement).

Pisząc tekst w zakresie zadania, przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#writing).

Pisz instrukcje dla agentów, które zmieniają zachowanie przy minimalnym użyciu kontekstu.
Dotyczy to umiejętności, plików `AGENTS.md`, `CLAUDE.md` i wskazanych materiałów.

Podczas pisania umiejętności przeczytaj [SKILL-MECHANICS.md](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md), aby poznać zasady frontmatter, wyboru sposobu wywołania i routerów.

## Umieszczaj informacje na właściwym poziomie [#depth]

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

## Pisz instrukcje wykonywalne [#executable-instructions]

- Używaj trybu rozkazującego i terminów repozytorium.
- Kończ każdy krok obserwowalnym kryterium ukończenia.
- Umieszczaj reguły deterministyczne w istniejących kontrolach formatowania, lintowania, typów lub testów; przed edycją kieruj dokumentację agentów do właściwego polecenia lub konfiguracji. W tekście zachowaj intencje i wyjątki, których nie da się wywnioskować, zamiast powielać katalog reguł. Same instrukcje nie egzekwują zasad.
- Definiuj słowo przewodnie tylko wtedy, gdy zastępuje powtarzane wyjaśnienie i ułatwia zapamiętanie.
- Negacja aktywuje nazwane zachowanie. Wskazuj pozytywny cel; zakaz zachowuj tylko dla bezwzględnej zasady ochronnej i podaj bezpieczne działanie.
- Dziel sekwencję tylko wtedy, gdy widoczne późniejsze kroki powodują przedwczesne ukończenie.

## Ewaluacje behawioralne [#behavioral-evaluations]

Każde polecenie skierowane do kandydata formułuj jako naturalne żądanie: ukryj reguły
oceniającego, oczekiwaną odpowiedź, tożsamość oceniającego/modelu i wyniki bazowe. Podawaj
rezultaty i publiczną ścieżkę weryfikacji, nie instrukcję implementacji. Przed płatnymi
ewaluacjami uruchom kontrolę zaślepienia poleceń.

## Skróć przed publikacją [#compress]

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
