---
description: "Diagnozuj zmierzone zacięcia animacji WWW, utracone klatki, ruch przy zajętym wątku, pracę Reacta w każdej klatce, unieważnianie zmiennych CSS i koszt warstw GPU."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["animation performance"]}
sidebar: {"label":"/animation-performance"}
title: "/animation-performance"
type: "skill"
---
![Diagram umiejętności /animation-performance](/diagrams/skills/animation-performance.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/animation-performance.excalidraw)

Znajdź wąskie gardło klatek, zanim zmienisz ruch. Adaptacja umiejętności Emila Kowalskiego;
[pochodzenie](https://github.com/malinskibeniamin/skills/blob/main/shared/EMIL-SKILLS-CREDITS.md). Audyt kończy się raportem; jawne żądanie poprawki
prowadzi przez weryfikację i bramki dostarczania projektu.

## Pętla

1. Zarejestruj wadliwą interakcję: trasę, wielkość danych, mechanizm i właściwości animacji,
   przeglądarkę/urządzenie, odświeżanie i równoczesną nawigację/ładowanie. Zapisz bazowy ślad
   Performance w `.context/`; podejrzenie na podstawie kodu nie jest zmierzonym zacięciem.
2. Zlokalizuj pracę opóźniającą klatkę: JavaScript/React, unieważnianie stylów, układ, malowanie,
   kompozycję lub nadmierną pamięć warstw. Budżet klatki to około 16,7 ms przy 60 Hz
   i 8,3 ms przy 120 Hz; płynny przebieg na komputerze nie dowodzi wydajności telefonu.
3. Sprawdź jedną przyczynę najmniejszą równoważną zmianą:

   | Dowód | Możliwa zmiana |
   |---|---|
   | Układ w każdej klatce | Transformuj dekorację; zachowaj wymaganą geometrię przepływu |
   | Kosztowne malowanie cienia/rozmycia | Zmniejsz malowany obszar lub uprość efekt; porównaj znaczenie wizualne |
   | Zajęty JS podczas ruchu | Odpowiednia ścieżka CSS/WAAPI; potwierdź rzeczywiste wykonanie w kompozytorze |
   | Render Reacta w każdej klatce | Wartości ruchu lub ograniczone aktualizacje ref; zachowaj semantyczny stan Reacta |
   | Koszt rośnie z potomkami | Ogranicz zapisy dziedziczonych zmiennych CSS do poruszającego się elementu |
   | Osobne transformacje Motion nie korzystają z akceleracji | Sprawdź pełny `transform` po ustaleniu zainstalowanej wersji |
   | Tworzenie warstwy powoduje zaobserwowane przycięcie | Lokalne, tymczasowe `will-change`; usuń, gdy zysk nie został dowiedziony |

4. Odtwórz identyczne warunki bazy i kandydata; porównaj opóźnione klatki, układ/malowanie
   i pamięć. Ponownie sprawdź szybkie odwrócenie, anulowanie, ograniczony ruch, fokus i zgodność
   wizualną. Odrzuć przeniesiony koszt oraz zmiany mniejsze od zmienności między przebiegami.
5. Podaj przyczynę, `plik:wiersz`, ścieżkę śladu, pomiary przed/po i ograniczenia urządzeń.
   Brak dostępu do urządzenia oznacza niezweryfikowany wynik sprzętowy, a nie zgodę na jego wymyślenie.

## Ograniczenia

- Wymieniaj właściwości przejścia zamiast `all`; domyślnie używaj `transform`/`opacity`.
- Akceleracja sprzętowa jest stopniowym ulepszeniem. CSS, WAAPI i Motion nie dają ogólnej gwarancji;
  sprawdź [aktualne wskazówki Motion](https://motion.dev/docs/performance) oraz zainstalowaną ścieżkę biblioteki.
  Ograniczanie CPU nie emuluje GPU ani pamięci telefonu.
- Skalowanie nie zastępuje zawsze wysokości lub paddingu: skaluje tekst i nie zmienia przepływu.
  Zachowaj poprawność, zanim wybierzesz tańszą ścieżkę renderowania.
- Profiluj blur/filter/clip-path w obsługiwanych przeglądarkach; stała granica pikseli niczego nie dowodzi.
- Anuluj pętle klatek, obserwatory i animacje przy odmontowaniu; zwalniaj tymczasowe wskazówki warstw.
  React Compiler odpowiada za memoizację; opakowania memo nie zastępują diagnozy.

Gdy dominuje ładowanie trasy, koszt bundla lub backend, a nie klatki, wczytaj
[ux-performance](https://github.com/malinskibeniamin/skills/blob/main/ux-performance/SKILL.md) zgodnie z
[zasadami ładowania zależności](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
