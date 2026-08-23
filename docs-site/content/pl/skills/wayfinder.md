---
title: /wayfinder
description: "Używaj do mapowania pracy wielosesyjnej za pomocą zgłoszeń decyzyjnych w systemie śledzenia."
type: skill
sidebar:
  label: /wayfinder
---
![Diagram umiejętności /wayfinder](/diagrams/skills/wayfinder.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/wayfinder.excalidraw)

Używaj, gdy cel przekracza jedno okno kontekstu, a droga jest niejasna. **Zgłoszenie decyzyjne** rozstrzyga pytanie, a nie implementuje wycinek produktu.

## Planuj, nie wykonuj

Wayfinder kończy pracę, gdy nie pozostała żadna decyzja. Notes przechowuje preferencje planistyczne i nie upoważnia do implementacji ani dostarczenia.

## Niezmienniki

- Odwołuj się do map i zgłoszeń **nazwą**, nie samym identyfikatorem.
- Mapa jest **indeksem**, nie magazynem. Odpowiedzi są w zgłoszeniach; mapa zawiera skrót i link.
- Jeśli istnieje `CLAUDE.md`, przeczytaj go przed `AGENTS.md`; w przeciwnym razie przeczytaj `AGENTS.md`. Użyj wskaźnika **Issue tracker** i instrukcji Wayfinding. Gdy ich brak, użyj lokalnego rozwiązania Markdown.
- Zgłoś roszczenie przez przypisanie przed pracą; musi to być pierwszy zapis. Otwarte i nieprzypisane oznacza wolne.
- Preferuj natywne blokady trackera. `Blocked by:` stosuj tylko bez natywnych zależności.
- Rozwiązuj najwyżej jedno zgłoszenie na sesję w głównym kontekście. Jawna delegacja lub wywołane `/swarm` może zrównoleglić gotowe badania; w innym przypadku nie rozwiązuj kolejnego zgłoszenia.
- Przy zatwierdzonych falach `/efficient-frontier` ustala budżet, a koordynator syntetyzuje.
- Roszczenia lub wyniki innej sesji audytuj przez `/agent-watchdog`.

## Kształt mapy

Utwórz jedno zgłoszenie lub plik oznaczony `wayfinder:map`:

```markdown
## Cel
<specyfikacja, decyzja lub zmiana, do której prowadzi mapa>
## Notes
<domena, wymagane umiejętności, stałe preferencje planistyczne>
## Dotychczasowe decyzje
- [<nazwa zamkniętego zgłoszenia>](link) -- <jednozdaniowy skrót odpowiedzi>
## Jeszcze nieokreślone
<niejasności w zakresie, których nie można jeszcze przypisać>
## Poza zakresem
<praca poza celem>
```

Otwarte elementy potomne pobieraj z trackera; nie kopiuj ich do treści mapy.

## Zgłoszenia

Każde zgłoszenie potomne zawiera jedno pytanie na jedną sesję agenta o budżecie 100 tys. tokenów. Oznacz je **HITL** (ocena człowieka na żywo) lub **AFK** (prowadzi agent):

- **Research (AFK):** użyj `/research` na źródłach pierwotnych. Zachowaj wskazaną lokalizację artefaktu; równoległe tory wymagają zgody i nie wymyślają pliku głównego ani gałęzi.
- **Prototype (HITL):** utwórz tani artefakt `/prototype` i podaj link.
- **Grilling (HITL):** zawsze użyj `/grilling` i `/domain-modeling`.
- **Task:** praca ręczna odblokowująca decyzję, nie dostarczenie samo w sobie.

Odpowiedź nie należy do treści zgłoszenia; zapisz ją przy rozwiązaniu. Artefakty linkuj, nie wklejaj.

## Niejasność i zakres

Nie mapuj tego, czego jeszcze nie widać. „Jeszcze nieokreślone” wyklucza elementy już rozstrzygnięte, istniejące zgłoszenia i pracę poza zakresem. Ostre, ale zablokowane pytanie jest zgłoszeniem.
Niejasność prowadzi do Celu. Zamknij zgłoszenie odkryte poza nim, dopisz powód do „Poza zakresem” i nie zapisuj go jako decyzji trasy.

## Tworzenie mapy

1. Nazwij Cel przez `/grilling` i `/domain-modeling`.
2. Przejdź wszerz po decyzjach i pierwszych krokach. Jeśli nie ma niejasności, zatrzymaj się i zapytaj, czy kontynuować bez mapy.
3. Utwórz mapę, a następnie tylko zgłoszenia możliwe teraz do określenia.
4. Dołącz każde zgłoszenie natywną relacją potomną, jeśli jest dostępna; w przeciwnym razie linkiem. Przeczytaj ponownie i sprawdź wszystkie elementy potomne, potem dodaj blokady.
5. Rozwiąż jedno gotowe zgłoszenie Research w głównym kontekście. Zatwierdzone tory najpierw przypisują pracę, stosują `/research` i zwracają cytowane artefakty.
6. Zatrzymaj się po tym zgłoszeniu.

## Praca z mapą

1. Przeczytaj mapę ogólnie; wybierz nazwane albo pierwsze otwarte, odblokowane i nieprzypisane zgłoszenie.
2. Najpierw je przypisz, potem rozwiąż, używając tylko potrzebnych powiązań i umiejętności z Notes.
3. Zapisz odpowiedź, zamknij zgłoszenie i dodaj jego skrót oraz link do decyzji.
4. Dodaj nowe zgłoszenia i blokady; usuń doprecyzowane niejasności. Pracę poza celem oznacz jako poza zakresem.
5. Przed zapisem ponownie odczytaj tracker, bo inne sesje mogą go zmieniać.

## Przekazanie

Gdy mapa jest jasna, przekaż ją do `/to-spec`, aby powstał jeden wykonalny plan, a potem do `/to-tickets`.
Najpierw ponownie sprawdź roszczenia: odpowiedzi, skróty, artefakty i aktualny stan trackera.
Zakończ jednym poleceniem dla zalecanego zgłoszenia i po jednym dla każdego bezpiecznego równoległego elementu granicznego.
