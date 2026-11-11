---
title: "/implement-spec"
description: "Zaimplementuj całą specyfikację i jej zgłoszenia na jednej gałęzi integracyjnej za pomocą równoległych subagentów implementujących."
type: skill
sidebar:
  label: "/implement-spec"
---
![Diagram umiejętności /implement-spec](/diagrams/skills/implement-spec.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/implement-spec.excalidraw)

Każdego autoryzowanego subagenta uruchamiaj ze świeżym oknem kontekstu i samodzielnym opisem zadania; nie kopiuj rozmowy koordynatora. Dla każdego zgłoszenia używaj nowego agenta implementującego, a do poprawek po przeglądzie — osobnego nowego agenta.

Gdy poniższy przepływ wymaga umiejętności wywoływanej przez model, wywołaj narzędzie Skill osobno dla każdej z nich. Na hostach bez tego narzędzia przeczytaj pełny kanoniczny `SKILL.md`, zgodnie z [zasadami ładowania zależności](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies). Umiejętności wywoływane tylko przez użytkownika polecaj człowiekowi; nie uruchamiaj ich automatycznie.

Otrzymujesz specyfikację. Powinny być z nią powiązane zgłoszenia opisujące, jak ją zaimplementować.

Wybierz tę umiejętność dla zatwierdzonej specyfikacji z rzeczywistymi zależnościami blokującymi i zgłoszeniami, które można niezależnie zweryfikować, nie dla zwykłego pojedynczego zgłoszenia. Wywołanie tej umiejętności jest wyraźną prośbą użytkownika o delegowanie i równoległych agentów; jej załadowanie lub wspomnienie nie oznacza zgody.

Jeśli istnieje `CLAUDE.md`, najpierw przeczytaj `CLAUDE.md`; w przeciwnym razie przeczytaj `AGENTS.md`. Postępuj zgodnie ze wskazaniem na system zgłoszeń. Jeśli go brak, poproś użytkownika o uruchomienie `/work-automation-kit`.

Celem jest cała specyfikacja zaimplementowana na jednej **gałęzi integracyjnej**, z każdym zgłoszeniem zamkniętym w sposób, w jaki system zgłoszeń zamyka pracę.

Zgłoszenia nie są listą kroków. Tworzą **graf zadań** z relacjami blokowania. Oznacza to, że zawsze istnieje **front** zgłoszeń gotowych do podjęcia.

Komunikacja z subagentami i od nich powinna być oszczędna. Komunikuj się głównie przez **wskaźniki kontekstu**: do specyfikacji, zgłoszeń, notatek z badań i wcześniejszych commitów. Nie powielaj informacji dostępnych przez wskaźniki.

Używaj tylko delegowania obsługiwanego przez hosta i objętego zgodą. Ogranicz współbieżność według niezależnej własności i możliwości koordynatora w zakresie integracji i weryfikacji, nie według wielkości frontu. Brak obsługi delegowania zgłoś jako ograniczenie; nie zmieniaj dostawcy bez zgody.

## Kroki

1. Przeczytaj specyfikację, pełną treść zgłoszeń i relacje blokowania. Przed delegowaniem zastosuj [kontrakt grafu zgłoszeń implementacyjnych](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/ticket-graph.md). Brakujące odwołania, cykle oraz pusty front przy nieukończonej pracy nie oznaczają ukończenia.

2. (opcjonalnie) Użyj **subagenta eksplorującego** do przeprowadzenia eksploracji wymaganej przez zgłoszenia – odpowiednich plików kodu lub zewnętrznej dokumentacji. Upewnij się, że subagent eksplorujący może zapisywać pliki – powinien zapisać notatki Markdown w katalogu poza repozytorium, dostępnym dla wszystkich przyszłych subagentów. Dzięki temu **subagenci implementujący** mogą skupić się na implementacji, a nie na eksploracji.

3. Utwórz gałąź integracyjną. Jeśli system zgłoszeń zamyka pracę przez PR-y lub użytkownik o to prosi, otwórz szkic PR po pierwszym scaleniu w kroku 5 (gałęzi bez commitów wyprzedzających main nie da się otworzyć), oznaczony jako zamykający specyfikację i zgłoszenia.

4. Dla każdego zgłoszenia użyj nowego **subagenta implementującego**, każdy we własnym worktree na własnej gałęzi. Każdy subagent implementujący:
   - przed rozpoczęciem potwierdza, że jego czysty, należący do agenta worktree bazuje na przypiętym końcu gałęzi integracyjnej; błędną bazę poprawia bez resetowania cudzej, niezacommitowanej lub równoległej pracy;
   - wywołuje narzędzie Skill z "tdd", aby zbudować zgłoszenie;
   - przed zgłoszeniem ukończenia scala najnowszy stan gałęzi integracyjnej do własnej gałęzi, aby krok 5 był przewinięciem (fast-forward).

5. Gdy **subagent implementujący** skończy, scal jego pracę do gałęzi integracyjnej za pomocą **subagenta scalającego**.

6. Zweryfikuj zintegrowany wycinek według kryteriów akceptacji, odśwież stan zgłoszeń i ponownie wyznacz **front**. Uruchamiaj nowo gotową pracę w granicach zgody; samo zgłoszenie ukończenia przez agenta nie odblokowuje zależnych zadań.

7. Gdy wszystkie zgłoszenia są ukończone, wywołaj narzędzie Skill z "review" na gałęzi integracyjnej. Napraw wszystkie problemy zgłoszone w przeglądzie kodu w jednym nowym **subagencie implementującym**.

8. Jeśli istnieje szkic PR, pozostaw go szkicem, gdy taki jest żądany etap końcowy; w przeciwnym razie oznacz go jako gotowy do przeglądu. Bez PR zamknij każde zgłoszenie zgodnie z zasadami systemu zgłoszeń i podaj gałąź integracyjną.

9. Usuń tylko własne worktree agentów implementujących, których wyniki zintegrowano, a użyteczne artefakty zachowano. Zachowaj cudzą, niezacommitowaną i niewypchniętą pracę; zgłoś, co pozostaje.
