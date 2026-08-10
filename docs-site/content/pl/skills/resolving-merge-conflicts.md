---
title: /resolving-merge-conflicts
description: Rozwiąż konflikt trwającego scalania lub rebase w Git.
type: skill
sidebar:
  label: /resolving-merge-conflicts
---
![Diagram umiejętności /resolving-merge-conflicts](/diagrams/skills/resolving-merge-conflicts.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/resolving-merge-conflicts.excalidraw)

Użyj `/agent-watchdog`, gdy kontekst konfliktu dotyczy gałęzi lub deklaracji innego agenta; użyj `/plan-arbiter`, gdy po przejrzeniu źródeł nadal istnieje kilka zasadnych sposobów semantycznego rozwiązania konfliktu.

1. **Sprawdź bieżący stan** scalania lub rebase. Przejrzyj historię Git i pliki zawierające konflikty.

2. **Znajdź źródła pierwotne** dotyczące każdego konfliktu. Dokładnie ustal, dlaczego wprowadzono poszczególne zmiany i jaki był ich pierwotny cel. Przeczytaj komunikaty commitów, sprawdź PR-y oraz pierwotne zgłoszenia lub zadania.

3. **Rozwiąż każdy fragment konfliktu.** W miarę możliwości zachowaj intencje obu zmian. Jeśli są niezgodne, wybierz
   rozwiązanie odpowiadające deklarowanemu celowi scalania i odnotuj kompromis. Jeśli źródła pierwotne wskazują, że
   samo scalanie lub rebase jest błędne albo zamierzony rezultat pozostaje niejednoznaczny, zatrzymaj się, przedstaw dokładny
   konflikt i zapytaj, czy przerwać operację; nigdy nie przerywaj jej bez zgody.

4. Ustal, jakie **automatyczne kontrole** są dostępne w projekcie, i uruchom je -- zazwyczaj najpierw sprawdzanie typów, następnie testy, a na końcu formatowanie. Napraw wszystko, co zostało uszkodzone przez scalanie.

5. **Dokończ scalanie lub rebase.** Dodaj wszystkie zmiany do obszaru przejściowego i utwórz commit. W przypadku rebase kontynuuj proces, aż wszystkie commity zostaną przeniesione.
