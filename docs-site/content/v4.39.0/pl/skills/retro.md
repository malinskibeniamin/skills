---
title: "/retro"
description: "Przeprowadź retrospektywę sesji programistycznej."
type: skill
sidebar:
  label: "/retro"
---
![Diagram umiejętności /retro](/diagrams/skills/retro.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/retro.excalidraw)


Użytkownik poprosił o **retrospektywę**. Proponujesz ulepszenia **środowiska** agenta programistycznego, aby usprawnić przyszłe przebiegi.

## Kroki

1. Użyj `/writing-for-agents` jako przewodnika stylu pisania. Aby uzyskać telemetrię hooków obok sesji, użyj `/hook-audit --retro`.

2. Przeczytaj źródła pierwotne sesji wskazanej przez użytkownika. Może to oznaczać przeszukanie logów sesji na tym komputerze. Jeśli użytkownik nie wskaże sesji, domyślnie użyj bieżącej.

3. Szukaj kandydatów do ulepszenia w tych kategoriach.

- **Nawigacja**: jak łatwo agent znajdował właściwe pliki? Czy istnieją ukryte zależności między plikami? Czy **wskaźnik nawigacyjny** by to ułatwił? _Użyj, gdy_ znalezienie informacji zajęło sesji dużo czasu.
- **Automatyczne kontrole**: czy istnieją automatyczne kontrole, które mogłyby wychwycić błędy agenta? Linting, typowanie, testy, lintery systemu plików? Najpierw przeczytaj własne polecenie kontroli repozytorium (skrypty `lint`/`check` w `package.json` lub narzędziu budowania, workflow CI), aby kontrola, która już istnieje, ale nie jest podłączona lub po cichu nie działa, była ustaleniem, a nie wymyślaniem od nowa. Repozytorium bez żadnego **zabezpieczenia** (bez hooka pre-commit i bez zadania CI uruchamiającego lint/typecheck/testy) samo w sobie jest ustaleniem: repozytorium bez lintingu to stale niewykorzystana okazja, a nie neutralny stan domyślny. _Użyj, gdy_ agent popełnił błąd, który mogłaby wychwycić automatyczna kontrola, lub repozytorium nie ma żadnego zabezpieczenia.
- **Standardy kodowania**: czy **agent przeglądający** powinien dostać nową regułę do egzekwowania? Czy istniejącą regułę należy usunąć lub doprecyzować? Najpierw sklasyfikuj naruszenie: **mechaniczne** (stały wzorzec składniowy, zakazane API, kształt importu, reguła lokalizacji pliku) dostaje deterministyczną kontrolę, bez wyjątków: własną regułę w linterze repozytorium, nowy hook pre-commit lub nowe zadanie CI, zależnie od tego, co język repozytorium i istniejące zabezpieczenia czynią najtańszym. Domyślnie buduj kontrolę zamiast pisać regułę. `CODING_STANDARDS.md` zostaw dla rzeczywistych **kwestii osądu** (spójność między plikami, „pasuje do otaczającego stylu”, wszystko, czego żadne zabezpieczenie nigdy nie zastąpi). _Użyj, gdy_ agent przeglądający nie wychwycił błędu.
- **Globalny AGENTS.md**: czy są instrukcje sterujące, które należy przenieść do standardów kodowania (lub automatycznych kontroli)? _Użyj, gdy_ plik AGENTS.md jest szczególnie duży – w repozytorium LUB w zakresie globalnym użytkownika.
- **Ekonomia narzędzi**: czy agent wykonywał kosztowne wywołania narzędzi, które można usprawnić? Czy jakieś niestandardowe narzędzia (CLI, MCP) są szczególnie nieefektywne pod względem tokenów? _Użyj, gdy_ agent wykonał kosztowne wywołanie narzędzia.
- **Instrukcje bez efektu**: szukaj w plikach sterujących instrukcji, które nie zmieniają zachowania agenta. _Użyj, gdy_ pliki sterujące są duże i nieporęczne.
- **Dostęp do informacji**: szukaj okazji do zwiększenia dostępu agenta do informacji. Przekierowanie logów serwera deweloperskiego, dostęp tylko do odczytu do usług zewnętrznych. _Użyj, gdy_ kluczowa informacja była dla agenta niedostępna.

4. Przedstaw tych kandydatów użytkownikowi w kolejności od najpoważniejszych.

## Materiały referencyjne

### Implementacja a przegląd

Pamiętaj, że cała praca przechodzi przez dwa etapy: implementację i przegląd. Agent implementujący ma największą **presję kontekstu**. Odpowiada za eksplorację, pisanie kodu i debugowanie niepowodzeń.

Agent przeglądający ma najmniejszą presję kontekstu – otrzymuje diff, więc nie potrzebuje eksploracji. Często nie musi pisać kodu ani debugować.

Oznacza to, że to agent przeglądający, a nie implementujący, powinien odpowiadać za egzekwowanie standardów kodowania.

### Pliki

Masz dostęp do kilku plików w repozytorium:

- `CLAUDE.md`/`AGENTS.md`: te pliki trafiają do okna kontekstu każdego agenta pracującego w tym repozytorium. Należy ich używać niezwykle oszczędnie, zwykle tylko na **wskaźniki nawigacyjne** do innych plików.
- `CODING_STANDARDS.md`: ten plik jest czytany podczas przeglądu, nie implementacji. Dodaj **wskaźniki nawigacyjne** do folderów dokumentacji, jeśli plik standardów przekroczy 1000 linii.
- Dokumentacja: używaj dokumentacji jako plików referencyjnych, na które wskazują inne pliki. Zanim napiszesz nową, poszukaj istniejącej.
- Umiejętności: używaj umiejętności do dokumentacji (ponieważ ich opis trafia do okna kontekstu agenta) lub do poleceń wywoływanych przez użytkownika. Stosuj się do rad z umiejętności `writing-for-agents`.
