---
title: /frontend-invariants
description: >-
  Stosuj niezależne od stosu niezmienniki frontendu. Używaj podczas pisania lub
  przeglądania kodu React, TypeScript lub interfejsu użytkownika w obszarach
  routingu, stanu, danych i systemów projektowych.
type: skill
sidebar:
  label: /frontend-invariants
---
![Diagram umiejętności /frontend-invariants](/diagrams/skills/frontend-invariants.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/frontend-invariants.excalidraw)

Te zasady przetrwały każdą migrację stosu (zestawy UI, routery, warstwy danych oraz biblioteki formularzy i zarządzania stanem odchodziły; one pozostały). Gdy niezmiennik jest sprzeczny z regułą właściwą dla stosu, pierwszeństwo ma niezmiennik; mechanizmy stosu znajdują się w `/stack-registry`.

## Zasada amplifikacji
Każdy tolerowany antywzorzec, mechanizm obejścia lub wyciszenie to przykład, który kolejna sesja LLM naśladuje i rozpowszechnia. Naprawiaj u źródła; wyciszaj tylko z uzasadnieniem w tym samym wierszu; nigdy nie dopuszczaj „tylko ten jeden raz”.

## Uczciwość renderowania
1. **Nigdy nie przekłamuj renderowanego obrazu.** Bez fałszywych wartości domyślnych, stratnego upiększania danych, których nie można zdekodować, ani ukrywania prawidłowych zer (`value == null`, nigdy sprawdzanie prawdziwości, przy wyświetlaniu liczb). Stany ograniczonej funkcjonalności wskazują możliwe przyczyny, przytaczają zgłoszony powód dosłownie i umożliwiają ponowienie próby.
2. **Dane maszynowe obok etykiet dla ludzi** -- pokazuj identyfikator lub surową wartość tam, gdzie potrzebują ich operatorzy; twórz teksty do wyświetlenia na podstawie danych, nigdy nie wyświetlaj kluczy maszynowych jako etykiet.
3. **Nie pokazuj niczego, zanim nie będzie gotowe** -- niegotowe funkcje są ukryte, a nie zapowiadane; stan ładowania rezerwuje miejsce w układzie (bez CLS).
4. **Każdy widok obsługuje pełną macierz stanów**: ładowanie / brak danych / błąd / brak uprawnień / wyłączony / zablokowany -- nie tylko pomyślną ścieżkę.

## Umiejscowienie stanu
5. **URL = stan, który można udostępnić** (karty, filtry, sortowanie, strona); **pamięć lokalna lub sesyjna = osobiste preferencje** (gęstość, zwinięte panele); **pamięć podręczna serwera = dane serwera**; stan komponentu tylko dla danych, które znikają wraz z komponentem. Nigdy nie zamieniaj tych ról.
6. **Nawigacja wewnątrz sekcji zastępuje historię; wejście do sekcji dodaje wpis** -- przycisk Wstecz opuszcza sekcję, zamiast odtwarzać każdą kartę.
7. **Powtarzający się asynchroniczny metabłąd**: stan rozwiązany asynchronicznie, odczytany zbyt wcześnie lub zbyt szeroko określony -- kluczuj pamięci podręczne według ich pełnego zakresu (środowisko/organizacja/użytkownik), zaczekaj na zakończenie sprzątania przed nawigacją, anuluj nieaktualne odpowiedzi lub stosuj zasadę ostatniego zapisu, nie odczytuj domyślnych wartości flag lub konfiguracji przed rozwiązaniem dostawcy.

## Relacja z systemem projektowym
8. **Tokeny zamiast doraźnych wartości** -- kolor, odstępy i typografia pochodzą ze skali; jednorazowe wartości projektanta zaokrąglaj do najbliższego stopnia; nigdy nie wpisuj na stałe wartości hex/px, jeśli istnieje token.
9. **Naprawiaj współdzielone komponenty u źródła** -- nigdy nie twórz odgałęzień, nie zmieniaj stylów lokalnie ani nie używaj głębokich selektorów wobec współdzielonego komponentu; odgałęzienie jest dopuszczalne tylko dla nazwanego defektu i z zadaniem naprawy w źródle.
10. **Przeszukaj system przed rozpoczęciem budowy** -- potrzebny komponent prawdopodobnie już istnieje; gdy użytkownicy interfejsu API wielokrotnie używają go nieprawidłowo, napraw interfejs API, a nie jego użytkowników.

## Interakcja
11. **Przyciski wykonują działania, linki służą do nawigacji** -- wszystko, co zmienia URL, jest prawdziwym linkiem (cmd-click działa); działania są przyciskami; wyłączone kontrolki mają dostrzegalne uzasadnienie.
12. **Przepływy destrukcyjne domyślnie blokują działanie** -- potwierdzenie staje się aktywne dopiero po świeżym, pomyślnym sprawdzeniu, które wykazało brak odwołań; każda metoda zamknięcia (X/ESC/Enter/wstecz) uwzględnia operacje w toku i niezapisane zmiany.
13. **Domyślnie oszczędny ruch** -- animacja tylko wtedy, gdy wyjaśnia zmianę stanu; respektuj `prefers-reduced-motion`; usuwaj animacje utrudniające korzystanie.

## Proces
14. **Mockuj na granicy integracji i jak najmniej**; mockuj tylko niepomyślne ścieżki; fabryki testowe tworzą rzeczywiste typy (przypisuj, nigdy nie wykonuj głębokiego scalania).
15. **Testy potwierdzają skutki uboczne, które może wywołać użytkownik** -- usuwaj testy sprawdzające wyłącznie renderowanie; czekaj na przyczyny, nigdy przez określony czas.
16. **Migracja kończy się mechanicznym zablokowaniem** starego wzorca; usunięcie flagi funkcji jest częścią jej kryteriów ukończenia.
17. **Dyscyplina zakresu**: PR-y o jednym celu; migracje tylko migrują; odroczenia zawierają linki do zadań; aktualizacje zależności i synchronizacje rejestru są dostarczane osobno.
18. **Rozbudowane, precyzyjne nazewnictwo encji** -- bez akronimów w trasach/plikach/etykietach; nazwy wartości logicznych mają formę predykatów; precyzja chroni również przed halucynacjami LLM.
19. **Prawda domenowa pochodzi od właściciela domeny** -- łańcuchy dziedziczenia, jednostki (GiB a GB), standardy nazewnictwa i SLA pochodzą ze wskazanych źródeł i są cytowane, nigdy nie zakłada się ich w interfejsie użytkownika.
20. **Przegląd frontendu obejmuje kontrolę bezpieczeństwa** -- bez sekretów w historii git, redaguj logi/powtórki/zrzuty błędów, domyślnie odmawiaj przy autoryzacji, odczyty nigdy nie modyfikują danych, sprawdzaj, jakie informacje ujawnia utrwalanie stanu w URL.
