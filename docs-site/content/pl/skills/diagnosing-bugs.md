---
title: /diagnosing-bugs
description: >-
  Pętla diagnostyczna dla trudnych błędów i regresji wydajności. Używaj na
  prośbę o diagnozę lub debugowanie albo gdy trudny błąd wymaga powtarzalnej
  pętli informacji zwrotnej.
type: skill
sidebar:
  label: /diagnosing-bugs
---
![Diagram umiejętności /diagnosing-bugs](/diagrams/skills/diagnosing-bugs.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/diagnosing-bugs.excalidraw)

Metodyczne podejście do trudnych błędów. Pomijaj fazę tylko z uzasadnieniem. Korzystaj z glosariusza domenowego i ADR-ów;
w przypadku rozbieżności dotyczących zewnętrznych zależności, API lub wersji uruchom `/read-the-damn-docs` przed uszeregowaniem hipotez.

## Usuń dane wrażliwe
Ta umiejętność pokazuje polecenia, dane wyjściowe i przechwycone artefakty. **Najpierw usuń każdy sekret** --
zastąp go znacznikiem `<REDACTED>`. Buduj pętle w oparciu o zmienne środowiskowe, aby dane uwierzytelniające nie trafiały
do plików ani cytowanych danych wyjściowych. Przechwycone artefakty mogą zawierać nagłówki uwierzytelniania; cytuj tylko
wiersze zawierające istotny sygnał. Jeśli dowody po usunięciu danych wrażliwych są niewystarczające, poproś użytkownika o bezpieczniejsze źródło.

## Faza 1 -- Zbuduj pętlę informacji zwrotnej
**Pętla informacji zwrotnej jest istotą tej umiejętności.** Reszta to działania mechaniczne. Zbuduj szybki, deterministyczny
i możliwy do uruchomienia przez agenta sygnał powodzenia lub niepowodzenia dla zgłoszonego błędu; bisekcja, testy hipotez i
instrumentacja korzystają z tego sygnału. Poświęć temu większość wysiłku diagnostycznego.

### Strategie (wypróbuj mniej więcej w tej kolejności)
1. **Nieudany test** na najwyższym poziomie integracji, który obejmuje błąd -- jednostkowy, integracyjny lub e2e.
2. **Skrypt Curl / HTTP** uruchamiany względem działającego serwera deweloperskiego.
3. **Wywołanie CLI** z danymi testowymi; porównaj stdout ze znanym poprawnym snapshotem.
4. **Skrypt przeglądarki bez interfejsu** (Playwright / Puppeteer) -- steruj interfejsem, sprawdzaj DOM, konsolę i sieć.
5. **Odtworzenie przechwyconego śladu.** Zapisz na dysku rzeczywiste żądanie sieciowe, payload lub dziennik zdarzeń; odtwórz je w odizolowanej ścieżce kodu.
6. **Jednorazowe środowisko testowe.** Uruchom najmniejszy fragment systemu, który dociera do błędu, za pomocą jednego wywołania.
7. **Pętla testów właściwości / fuzzingu.** Jeśli błąd polega na „czasami nieprawidłowym wyniku”, uruchom 1000 losowych danych wejściowych i obserwuj sposób występowania awarii.
8. **Środowisko do bisekcji.** Jeśli błąd pojawił się między dwoma znanymi stanami, zautomatyzuj
   „uruchom stan X, sprawdź, powtórz”, aby działało `git bisect run`.
9. **Pętla różnicowa.** Przetwórz te same dane wejściowe w starej i nowej wersji (lub dwóch konfiguracjach), a następnie porównaj wyniki.
10. **Skrypt bash z udziałem człowieka.** Ostateczność. Jeśli człowiek musi wykonać kliknięcie, poprowadź go za pomocą
    `scripts/hitl-loop.template.sh`; przekaż przechwycone dane wyjściowe z powrotem do pętli.

### Ulepszaj samą pętlę
Traktuj pętlę jak produkt: przyspieszaj ją, doprecyzowuj sprawdzany objaw i eliminuj
niedeterminizm przez ustalenie czasu, ziaren losowości, stanu systemu plików i danych wejściowych z sieci.

### Błędy niedeterministyczne
Dąż do **wyższej częstotliwości reprodukcji**. Uruchamiaj pętlę wielokrotnie, dodawaj kontrolowane obciążenie i
zawężaj okno czasowe, aż błąd będzie występował wystarczająco często, aby można było rozróżnić hipotezy.

### Gdy naprawdę nie możesz zbudować pętli
Zatrzymaj się, opisz wypróbowane pętle i poproś o brakujące dane: dostęp do środowiska,
w którym można odtworzyć błąd, przechwycony artefakt lub zgodę na tymczasową instrumentację produkcji.

Przejdź do fazy 2, gdy pętla niezawodnie sygnalizuje zgłoszoną awarię.

Nie przechodź do formułowania hipotez bez działającej pętli.

### Kryterium ukończenia: ciasna pętla, która przechodzi na czerwono

Faza 1 kończy się dopiero wtedy, gdy potrafisz wskazać jedno polecenie, uruchomione już co najmniej raz, wraz z ocenzurowanym wywołaniem i wynikiem, które jest:

- [ ] **Zdolne do czerwieni:** wykonuje rzeczywistą ścieżkę błędu i sprawdza dokładny objaw użytkownika.
- [ ] **Deterministyczne:** zwraca ten sam werdykt lub ustaloną wysoką częstość reprodukcji.
- [ ] **Szybkie:** trwa sekundy, nie minuty.
- [ ] **Uruchamialne przez agenta:** działa bez nadzoru, z wyjątkiem ustrukturyzowanego skryptu HITL.

Bez polecenia zdolnego do czerwieni nie ma fazy 2.

## Faza 2 -- Odtwórz i zminimalizuj
Uruchom pętlę, a następnie `/dogfood` dla rzeczywistego punktu wejścia używanego przez zgłaszającego. Zaobserwuj ten sam błąd.

- [ ] Pętla wywołuje tryb awarii opisany przez **użytkownika**, a nie podobną awarię.
- [ ] Awaria powtarza się w wielu uruchomieniach lub wystarczająco często, aby ją debugować.
- [ ] Pętla przechwytuje dokładny objaw, aby faza 5 mogła wykazać, że poprawka go usuwa.

### Minimalizuj

Gdy pętla jest czerwona, usuwaj po jednym elemencie danych wejściowych, wywołań, konfiguracji, danych i kroków. Po każdym usunięciu ponownie uruchom pętlę. Zachowaj wyłącznie elementy niezbędne dla awarii i późniejszego testu regresji.

Zakończ, gdy każdy pozostały element jest niezbędny: usunięcie któregokolwiek zmienia wynik pętli na zielony. Nie przechodź dalej, dopóki błąd nie zostanie odtworzony i zminimalizowany.

## Faza 3 -- Postaw hipotezy
Przed rozpoczęciem testów sformułuj **3–5 uszeregowanych, falsyfikowalnych hipotez**; praca z jedną hipotezą
powoduje zakotwiczenie na pierwszym wiarygodnym pomyśle.

> Format: „Jeśli przyczyną jest <X>, to <zmiana Y> sprawi, że błąd zniknie / <zmiana Z> go pogorszy”.

Odrzuć lub doprecyzuj każdą hipotezę, która nie zawiera testowalnej prognozy.

Przed testowaniem pokaż uszeregowaną listę, aby dostępna wiedza domenowa mogła zmienić kolejność. Jeśli użytkownik
jest niedostępny, kontynuuj zgodnie z kolejnością opartą na dowodach.

## Faza 4 -- Dodaj instrumentację
Każda sonda musi odpowiadać konkretnej prognozie z fazy 3. **Zmieniaj jedną zmienną naraz.**

1. **Inspekcja w debuggerze / REPL**, jeśli środowisko ją obsługuje. Jeden punkt przerwania może zastąpić dziesięć logów.
2. **Ukierunkowane logi** na granicach pozwalających rozróżnić hipotezy.
3. Nigdy nie „loguj wszystkiego i nie przeszukuj wyników”.

Oznacz każdy log debugowania unikatowym prefiksem, takim jak `[DEBUG-a4f2]`, a następnie usuń wszystkie jego wystąpienia.

**Ścieżka wydajnościowa.** Ustal zmierzony poziom bazowy za pomocą środowiska do pomiaru czasu, profilera lub planu zapytania,
a następnie wykonaj bisekcję. Najpierw zmierz, potem naprawiaj.

## Faza 5 -- Poprawka + test regresji

Napisz test regresji **przed poprawką** -- ale tylko wtedy, gdy istnieje dla niego **właściwy punkt testowania**.

Właściwy punkt testowania odtwarza **rzeczywisty wzorzec błędu** występujący w miejscu wywołania. Powierzchowny
test jednostkowy, który nie potrafi odtworzyć łańcucha wyzwalającego, daje fałszywe poczucie bezpieczeństwa. Jeśli odpowiedni punkt
nie istnieje, udokumentuj tę lukę architektoniczną na potrzeby fazy 6. W przeciwnym razie:

1. Przekształć zminimalizowany przypadek reprodukcji w nieudany test w tym punkcie.
2. Zaobserwuj jego niepowodzenie.
3. Zastosuj poprawkę.
4. Zaobserwuj jego powodzenie.
5. Uruchom `/dogfood`, aby odtworzyć identyczny scenariusz użytkownika, a następnie ponownie uruchom pierwotną, niezminimalizowaną pętlę z fazy 1.

## Faza 6 -- Porządki + analiza po incydencie
Wykonaj wszystkie punkty przed uznaniem diagnozy za zakończoną:

- [ ] `/dogfood` potwierdza, że dokładnego scenariusza użytkownika nie można już odtworzyć; pętla z fazy 1 również kończy się powodzeniem
- [ ] Test regresji przechodzi (lub udokumentowano brak odpowiedniego punktu testowania)
- [ ] Usunięto całą instrumentację `[DEBUG-...]` (`grep` prefiksu)
- [ ] Usunięto jednorazowe prototypy (lub przeniesiono je do wyraźnie oznaczonej lokalizacji debugowania)
- [ ] Hipoteza, która okazała się prawidłowa, została podana w komunikacie commita / PR -- aby pomóc kolejnej osobie debugującej

Następnie zapytaj, co zapobiegłoby ponownemu wystąpieniu problemu. Jeśli odpowiedzią jest zmiana architektoniczna, przekaż
konkretny problem dotyczący punktu testowania lub powiązań do `/improve-codebase-architecture`. Zarekomenduj ją po usunięciu pierwotnej
przyczyny, gdy dowody są najsilniejsze.
