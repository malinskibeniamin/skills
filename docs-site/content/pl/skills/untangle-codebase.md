---
description: "Uporządkuj nieszczelne abstrakcje, powieloną logikę, tymczasowe obejścia i zbędne opakowania w bazie kodu lub wskazanym obszarze, zachowując zamierzone zachowanie."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["untangle codebase"]}
sidebar: {"label":"/untangle-codebase"}
title: "/untangle-codebase"
type: "skill"
---
![Diagram umiejętności /untangle-codebase](/diagrams/skills/untangle-codebase.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/untangle-codebase.excalidraw)

Adaptacja [caldoai/skills](https://github.com/malinskibeniamin/skills/blob/main/vendor/caldoai/skills/untangle-codebase/SKILL.md);
[pochodzenie i aktualizacja](https://github.com/malinskibeniamin/skills/blob/main/untangle-codebase/CREDITS.md). Ten proces zastępuje automatycznych podagentów,
nieograniczoną pętlę pracy i zgodę na przygodne poprawki błędów z wersji źródłowej.

## Zakres i punkt odniesienia

Ustal kontrakt wyniku: obszar docelowy (domyślnie cały kod własny projektu), ograniczenia
zachowujące zachowanie, weryfikację i żądany punkt końcowy. Zachowaj niezwiązane zmiany
i publiczne kontrakty. Plan lub przegląd pozostaje tylko do odczytu; implementacja podlega
[kontraktowi dostarczania](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md), w tym jawnym ograniczeniom
pracy lokalnej lub zakazowi wypychania. Importowanie lub omawianie umiejętności jej nie uruchamia.

Zaproponuj te opcjonalne dodatki raz, respektując wybory podane już w prośbie:

| Dodatek | Działanie |
| --- | --- |
| Komentarze | Usuń komentarze, które jedynie powtarzają kod. |
| Testy | Usuń testy, które nie wykryłyby rzeczywistego błędu, i popraw te, które zawodzą bez błędu. |

Jeśli wyboru nie podano, zapytaj; do czasu wyboru kontynuuj pracę strukturalną bez obu dodatków.
Niezbędne aktualizacje testów zachowujące pokrycie podczas refaktoryzacji nie są opcjonalnym przycinaniem.

Użyj [nawigacji po repozytorium](https://github.com/malinskibeniamin/skills/blob/main/shared/repo-navigation.md), aby ustalić punkty wejścia,
konsumentów, reguły domenowe i istniejące kontrole. Zapisz punkt odniesienia przez publiczny
interfejs oraz wiarygodny przypadek awarii i odzyskiwania. Generowane i zewnętrzne pliki pozostaw ich właścicielom.

## Diagnoza przed edycją

Zapytaj: **czy te elementy powinny zmieniać się razem?** Zbierz udokumentowane problemy w zakresie:

- **Ukryte powiązania:** powielona wiedza, niejawny współdzielony stan, konwencje kolejności wywołań i logika funkcji rozproszona po warstwach technicznych.
- **Zbędne powiązania:** dostęp do wnętrza modułów, zależność stabilnych domen od zmiennych implementacji, parametry dla jednego wywołującego i płytkie abstrakcje przenoszące zmiany na zewnątrz.
- **Nadmiar:** opakowania przekazujące wywołania, spekulacyjne punkty rozszerzeń lub konfiguracja i pozornie nieużywany kod.
- **Przypadki szczególne:** gałęzie dla jednej wartości, wyjątki dla wywołujących, połykane błędy, uśpienia, ponowienia, wyłączone testy i tymczasowe obejścia. Prześledź chronione wymaganie lub ograniczenie zewnętrzne; sama obecność nie oznacza wady.

Dla każdego problemu zachowaj lokalizację, dotkniętych wywołujących, konkretny scenariusz zmiany
lub awarii i kontrolę wykrywającą błędną poprawkę. W razie potrzeby użyj historii wspólnych zmian
w Git i dowodów zależności; brak krawędzi grafu nie dowodzi martwego kodu. Przed usuwaniem lub
współdzieleniem zastosuj [diagnozę martwego kodu i duplikacji](https://github.com/malinskibeniamin/skills/blob/main/shared/verifiability.md#dead-code-and-duplication).
Decyzje zapisuj w istniejących notatkach zadania lub tymczasowym katalogu, nie w nowym raporcie repozytorium.

## Przeprojektowanie wokół wymagań

Grupuj powiązane problemy pod najmniejszą poprawką przyczyny źródłowej. Wiedzę zmieniającą się
razem umieść u jej właściciela; rozdziel niezależne powody zmian. Preferuj stabilne interfejsy
domenowe zamiast szczegółów zmiennej implementacji. Przy wyborze granic modułów użyj
[projektowania bazy kodu](https://github.com/malinskibeniamin/skills/blob/main/codebase-design/SKILL.md).

Porównaj propozycję z pozostawieniem kodu: nazwij usuwany koszt koordynacji lub awarię
oraz kontrakty do zachowania. Opakowanie może odpowiadać za walidację, autoryzację,
obserwowalność lub zgodność; podobny kod może reprezentować różne reguły domenowe.
Zachowaj te obowiązki, chyba że dowody uzasadniają ich przeniesienie. Więcej funkcji pomocniczych,
mniej wierszy lub przypadków szczególnych nie dowodzi lepszego projektu.

Przykładowo arbitralne opóźnienie fokusu okna dialogowego i globalna flaga pomijania jego
przywracania mogą wynikać z braku jednego właściciela przywracania fokusu. Przed zastąpieniem
obu sprawdź zagnieżdżone dialogi i obsługę klawiatury, zamiast usuwać każde obejście osobno.

## Implementacja i weryfikacja etapów

1. Przed każdą zmianą strukturalną ustal kontrolę właściwego zachowania; najpierw wykorzystaj istniejące testy, a dla niepokrytego ryzyka zastosuj [TDD](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md).
2. Przenieś dotkniętych wywołujących, a następnie usuń zastąpione wnętrza i obejścia wymagań spełnionych już przez nowy projekt. Zachowaj wymaganą zgodność zewnętrzną.
3. Po każdym etapie odtwórz ścieżki zamierzone i awaryjne zgodnie z [proporcjonalną weryfikacją](https://github.com/malinskibeniamin/skills/blob/main/shared/verifiability.md#proportionate-verification). Nowo odkryte błędy zgłoś oddzielnie; zmiany zachowania wymagają jawnego zakresu, nie przemycania w refaktoryzacji zachowującej zachowanie.
4. Jeśli wybrano Komentarze, usuń powtórzenia implementacji, zachowaj ograniczenia zewnętrzne i użyteczne niezmienniki, a wyjaśnienia obejść usuwaj tylko razem z nieaktualnym obejściem.
5. Jeśli wybrano Testy, wczytaj [audyt testów](https://github.com/malinskibeniamin/skills/blob/main/test-audit/SKILL.md) i przycinaj na końcu. Zachowaj pokrycie regresji, aż przejdą zastępcze kontrole zachowania. Wykaż, dlaczego usuwany test nie wykrywa odrębnej regresji; kruche asercje wnętrza przepisz na publiczny interfejs zamiast usuwać potrzebne pokrycie.

## Przegląd i zakończenie

Sprawdź ukryte i zbędne powiązania, nadmiar oraz przypadki szczególne w głównym kontekście.
Podagentów używaj wyłącznie po jawnej zgodzie na delegowanie, zgodnie z zasadami modelu
i izolacji hosta; wczytanie tej umiejętności nie daje zgody. Sprawdź działające zachowanie
przez [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md), a następnie zastosuj [przegląd](https://github.com/malinskibeniamin/skills/blob/main/review/SKILL.md) do pełnego diffu.

Napraw potwierdzone problemy w zakresie i zakończ po pierwszym czystym przeglądzie tego zakresu,
z zachowanym zachowaniem bazowym i przechodzącymi wymaganymi kontrolami. Zachowaj uzasadnione
wyjątki; zgłoś niewiadome, luki pokrycia i możliwości poza zakresem bez rozszerzania zadania.
Podsumuj poprawki przyczyn źródłowych, zachowane ograniczenia, weryfikację i pozostałe limity,
a następnie osiągnij wyłącznie żądany punkt dostarczenia. Bez pomiarów nie deklaruj poprawy
szybkości, zużycia tokenów ani liczby błędów.
