---
description: >-
  Twórz i poprawiaj gesty przeciągania, przesuwania, arkuszy, zmiany kolejności
  i przytrzymania w aplikacjach WWW: bezpośrednie śledzenie, sprężysty opór,
  prędkość puszczenia, bezwładność, punkty przyciągania i przerwania. Nie
  dotyczy React Native ani Swift.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - gestures
sidebar:
  label: /gestures
title: /gestures
type: skill
---
![Diagram umiejętności /gestures](/diagrams/skills/gestures.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/gestures.excalidraw)

Bezpośrednia manipulacja ma podążać za wskaźnikiem, a po puszczeniu przewidywalnie się zatrzymać.
Adaptacja wskazówek Emila Kowalskiego; [źródło i zgodność](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/EMIL-SKILLS-CREDITS.md).
Pytania i przeglądy kończą się poradą lub ustaleniami bez edycji; tworzenie i poprawki podlegają TDD,
weryfikacji i zasadom dostarczania projektu. Wczytanie skilla nie upoważnia do instalacji ani dostępu do urządzeń.

## Wybierz właściciela [#choose-the-owner]

Sprawdź komponent, sposoby obsługi wejścia, zainstalowaną bibliotekę i wersję oraz istniejącą nakładkę UI.
Zanim napiszesz własną fizykę, wykorzystaj istniejący prymityw szuflady, dialogu, powiadomień lub zmiany kolejności.
Rozważ Vaul tylko wtedy, gdy pasuje do stosu i zamówionego zakresu; zachowaj pułapkę fokusu,
Escape, przywracanie fokusu, blokadę przewijania i zamykanie. Gest nie jest powodem do wymiany działającej
biblioteki. Sprawdź typy zainstalowanej wersji i aktualną oficjalną dokumentację API.

## Pętla gestu [#gesture-loop]

1. **Określ zamiar.** Wskaż oś, uchwyt, granice i punkty przyciągania, zatwierdzaną akcję,
   sposób anulowania i alternatywę bez przeciągania. Preferuj natywne przewijanie i przyciąganie, gdy pasują.
   Oddziel informację zwrotną po naciśnięciu od aktywacji; zachowaj dostępne kontrolki click/submit.
2. **Rozstrzygnij obsługę wejścia.** Zachowaj natywne przewijanie, zaznaczanie tekstu i obsługę interaktywnych dzieci.
   We własnej obsłudze wskaźnika śledź jego aktywny identyfikator, przechwytuj tylko obsługiwane przeciąganie
   i uwzględnij `pointercancel`, `lostpointercapture`, dodatkowe wskaźniki oraz odmontowanie.
   Anulowanie nie może zatwierdzać zamknięcia, usunięcia ani zmiany kolejności.
   Ustaw lokalne `touch-action` przed gestem; zachowaj powiększanie dwoma palcami. Przy problemach telefonu
   lub przeglądarki wczytaj [mobile-native](https://github.com/malinskibeniamin/skills/blob/v4.45.0/mobile-native/SKILL.md).
3. **Śledź bezpośrednio.** W granicach odwzoruj ruch wskaźnika 1:1 względem bieżącej pozycji wizualnej elementu.
   Użyj wartości ruchu biblioteki lub bezpośredniego transform, bez sprężyny lub przejścia podczas śledzenia
   i bez renderowania Reacta przy każdym ruchu. Dodaj opór dopiero poza dozwoloną granicą.
   Nie steruj dużym drzewem potomków przez dziedziczoną zmienną CSS aktualizowaną co klatkę;
   profiluj rzeczywistą ścieżkę aktualizacji.
4. **Obsłuż puszczenie.** Odczytaj bieżące przesunięcie i niedawną prędkość ze znakiem na obsługiwanej osi.
   Wybierz cel przyciągnięcia lub zamknięcie na podstawie odległości LUB zamierzonego szybkiego ruchu
   w dozwolonym kierunku; zachowaj spójne jednostki. Zwykłe przesunięcie może zatrzymywać się po puszczeniu.
   Rzut może używać bezwładności; sprężyna przy zatrzymywaniu może odziedziczyć prędkość.
   Zachowaj jeden mechanizm po puszczeniu: bezwładność biblioteki i własna sprężyna nie mogą rywalizować.
5. **Pozwól ponownie chwycić.** Przy ponownym chwyceniu zatrzymaj mechanizm ruchu po puszczeniu,
   odczytaj bieżącą pozycję i ustaw ją jako nowy początek przeciągania. Gdy to obsługiwane, zmieniaj cel
   od bieżącej wartości i prędkości. Ani sprężyna, ani CSS nie gwarantują automatycznie płynnego przekazania.
   Wyprowadzaj powiązane wartości nakładki i skali z tego samego postępu przeciągania; nie pozwól,
   aby nieaktualne callbacki zakończenia odmontowały element lub zatwierdziły akcję po przerwaniu.
6. **Zatrzymuj dostępnie.** Przy ograniczonym ruchu zachowaj niezbędne bezpośrednie śledzenie,
   lecz usuń ozdobne odbicia i długą bezwładność; zatrzymuj szybko albo natychmiast.
   Udostępnij ten sam rezultat przez przyciski, klawiaturę i ścieżkę wskaźnika bez przeciągania.
   Przytrzymanie pokazuje upływ czasu liniowo, anuluje się po wcześniejszym puszczeniu, Escape lub utracie
   przechwycenia i zatwierdza dokładnie raz. Nie może być jedyną drogą do akcji ani zastępować potwierdzenia.

Jednostki progów, opór oraz kontrole właściwe arkuszom i przytrzymaniom opisuje
[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/gestures/REFERENCE.md). Liczby traktuj jako punkty wyjścia do strojenia, nie sztywne reguły.
Dla synchronizacji wielu elementów i jakości przejść wczytaj [animate](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/SKILL.md);
dla zmierzonego zacinania przeciągania — [animation-performance](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animation-performance/SKILL.md).
Stosuj [zasady ładowania zależności](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## Zweryfikuj i przekaż [#verify-and-hand-off]

Sprawdź wolne przeciąganie, krótki szybki ruch, odwrócenie kierunku, opór granicy, powrót,
ponowne chwycenie podczas zatrzymywania, zagnieżdżone przewijanie, aktywację dzieci, anulowanie,
wiele wskaźników, zmianę rozmiaru, odmontowanie i ograniczony ruch. Sprawdź równoważność klawiatury
oraz obsługi bez przeciągania i zachowanie fokusu. Używaj rzeczywistego komponentu; nagrywaj interakcję
w normalnym tempie i analizuj klatki tylko wtedy, gdy trzeba wyjaśnić ciągłość.
Sam kod nie dowodzi odczuwalnej jakości, liczby klatek ani działania na telefonie.
Testy fizycznego urządzenia wymagają dostępnego, autoryzowanego sprzętu; zgłaszaj brak pokrycia
bez udostępniania serwera deweloperskiego lub instalowania narzędzi tylko na potrzeby tego skilla.

Podaj wybór mechanizmów śledzenia i puszczenia, progi i jednostki, anulowanie i alternatywy,
zaobserwowane wyniki oraz pozostałe ograniczenia urządzeń. Oddziel usterki od preferencji estetycznych.
