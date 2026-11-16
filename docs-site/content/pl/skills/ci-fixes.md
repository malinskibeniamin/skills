---
description: >-
  Diagnozuj i naprawiaj wolne lub niestabilne CI, nieefektywne zadania oraz
  testy o niskiej wartości. Używaj do optymalizacji czasu, cache, shardów,
  wyboru zależnych testów, maszyn i narzędzi.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - ci fixes
sidebar:
  label: /ci-fixes
title: /ci-fixes
type: skill
---
![Diagram umiejętności /ci-fixes](/diagrams/skills/ci-fixes.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/ci-fixes.excalidraw)

Przyspiesz CI bez fałszywie zielonych wyników, niezależnie od stosu. Optymalizuj czas od commita
do wymaganego wyniku, nie tylko testy; zasoby licz osobno. Audyty i plany są tylko do odczytu.
Wdrażaj wyłącznie na prośbę; nie instaluj przy okazji narzędzi audytowych, nie twórz maszyn,
nie zmieniaj polityki hostingu, nie twórz harmonogramów i nie uruchamiaj agentów.

## Chroń granicę scalania [#protect-the-merge-boundary]

- Pełny zestaw testów regresji musi przejść przed scaleniem na kandydacie połączonym z aktualną
  gałęzią docelową. Selekcja zawęża tylko informację zwrotną w PR; testy nocne ani po scaleniu
  nie zastępują tej ochrony. Preferuj kolejkę scalania, a bez niej wymagaj równoważnego,
  aktualnego dowodu przed scaleniem. Zgłoś brak ochrony; zmiana ustawień wymaga upoważnienia.
- Zachowaj błędy pierwszej próby. Napraw przyczynę zamiast dodawać ponowienia testów,
  zwiększać limity czasu, pomijać lub izolować testy albo osłabiać asercje i pokrycie dla szybkości.
  Ograniczone, idempotentne odzyskiwanie infrastruktury to [osobny przypadek](https://github.com/malinskibeniamin/skills/blob/main/ci-fixes/references/operations.md#29-infrastructure-outage-containment).

## Ustal punkt odniesienia [#establish-the-baseline]

1. Ustal repozytorium, gałąź, workflow i wywołujących, rzeczywiste skrypty i konfiguracje testów,
   wymagane kontrole, politykę scalania oraz lokalne instrukcje. Wskaż pełny przebieg przed scaleniem.
2. Zbierz porównywalne ostatnie wykonania, także nieudane i ponowione: adresy commitów i wykonań,
   kolejki, zależności, przygotowanie, budowanie, testy, wysyłanie, cache, zasoby, workery,
   shardy, liczbę wykonanych testów i błędy pierwszych prób. Preferuj istniejące raporty dostawcy;
   brak historii oznacza niewiedzę, nie dowód szybkości ani niezawodności.
3. Prześledź ścieżkę krytyczną do ostatniego wymaganego wyniku. Zanim uznasz testy za wolne,
   znajdź największe usuwalne oczekiwanie lub powtarzaną pracę. Zapisz obciążenie i liczbę próbek.
   Stosuj [protokół pomiarów i budżety początkowe](https://github.com/malinskibeniamin/skills/blob/main/ci-fixes/references/measurement.md):
   wynik PR poniżej 2 minut mediany i 3 minut p95, chyba że właściciel ustali inny cel.
   Cele nie są gwarancją ani zgodą na osłabienie ochrony; nieudowodnione ogony rozkładu pozostają nieznane.

## Wybierz najmniejszą użyteczną zmianę [#choose-the-smallest-useful-change]

Użyj [indeksu audytu CI](https://github.com/malinskibeniamin/skills/blob/main/ci-fixes/REFERENCE.md),
aby znaleźć instrukcje dla zaobserwowanego wąskiego gardła, nie obowiązkową listę migracji.
Pełny audyt ocenia każdy punkt; naprawa celowana bada tylko wąskie gardło i powiązane kontrakty
bezpieczeństwa, oznaczając resztę jako poza zakresem. Dla ocenionych punktów zapisz **przyjmij**,
**odrzuć**, **odrocz** lub **nie dotyczy** z dowodem; niewiadome nie oznacza nie dotyczy.
Porządkuj według zmierzonych zysków na ścieżce krytycznej, zasobów, pewności i ryzyka utrzymania.
Najpierw napraw największe potwierdzone wąskie gardło, potem zmierz ponownie.

Rozszerz indeks tylko o odrębny chroniony kontrakt z falsyfikowalnym eksperymentem, sygnałem
akceptacji i właścicielem; łącz nakładające się punkty odsyłaczami. Szersza diagnoza nie uprawnia
do tworzenia usług, ujawniania danych ani zmiany polityki bezpieczeństwa lub dostarczania.

Wczytuj dodatkowe instrukcje tylko dla wykonywanej pracy:

- Zmiany workflow: [utrzymanie CI](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/ci-maintenance/SKILL.md),
  wraz ze źródłem kanonicznym i granicami zaufania. Chroń poświadczenia, cache, artefakty i forki.
- Usuwanie testów: [audyt testów](https://github.com/malinskibeniamin/skills/blob/main/test-audit/SKILL.md).
  Przed usunięciem wskaż zachowany kontrakt i główny test; szybkość i procent pokrycia nie wystarczą.
- Niestabilność: [diagnozowanie błędów](https://github.com/malinskibeniamin/skills/blob/main/diagnosing-bugs/SKILL.md).
  Odtwórz błędy pierwszej próby i napraw właściciela lub harness; udane ponowienie nie jest naprawą.
- Zmiany narzędzi: [aktualizacja zależności](https://github.com/malinskibeniamin/skills/blob/main/upgrade-dependency/SKILL.md).
  Sprawdź wsparcie wersji, migrację i zgodność maszyn w źródłach pierwotnych. Porównaj alternatywę
  z obecną bramką przed zastąpieniem; nazwani dostawcy i narzędzia to kandydaci, nie domyślne wybory.

Zmieniaj jedno spójne wąskie gardło naraz. Gdy żądane są PR-y, każda optymalizacja ma być mała
i mierzalna osobno; nie dziel istniejącego własnego PR bez prośby. Dodaj niedziałający test
publicznego kontraktu tylko dla nieobjętego ryzyka behawioralnego; konfigurację i dokumentację
sprawdzaj wykonywalnymi narzędziami, nie testami wyszukującymi tekst instrukcji.

## Udowodnij poprawę [#prove-the-improvement]

- Uruchom bramki workflow i repozytorium oraz właściwe testy. Sprawdź brak, trafienie i unieważnienie
  cache, kompletność shardów, propagację błędów oraz ukończenie wymaganych kontroli.
- Dla selekcji porównaj wynik z pełnym zestawem. Zmiany lockfile lub konfiguracji CI i niepewne
  wejścia wymuszają pełne wykonanie. W jednorazowym eksperymencie celowo pomiń istotną zmianę:
  pełna bramka przed scaleniem musi ją wykryć. Przywróć stan i potwierdź zielony wynik.
- Porównuj dopasowane obciążenie, maszynę, wersje, workery i cache, poza badaną zmienną. Powtarzaj
  rzeczywiste wykonania; raportuj próbki, medianę, uzasadnione ogony, kolejkę i minuty maszyn osobno.
  Pomiar lokalny nie dowodzi zachowania hostowanego CI.
- Dla workerów, izolacji i dystrybucji powtarzaj i zmieniaj kolejność przy proponowanej współbieżności;
  sprawdź pamięć, CPU, wyścigi współdzielonego stanu i błędy pierwszej próby.
- Przy usuwaniu testów zachowaj unikalne wykrywanie błędów i krytyczne ścieżki, używając kontroli
  negatywnych. Porównuj pokrycie linii i gałęzi przy tej samej instrumentacji, wykluczeniach i mianowniku.
- Sprawdź zdarzenie i ref pełnego zestawu przed scaleniem oraz unieważnienie dowodu po zmianie bazy.
  Brak dostępu lub wykonań na hostingu jest luką, nie dowodem bezpieczeństwa. Nie opóźniaj szybkich zadań dla symetrii.

## Przekazanie [#handoff]

Zacznij od wyniku i ograniczeń: wąskie gardło, ocenione decyzje, rzeczywisty łączny czas CI
oraz zasoby przed i po, próbki i cache, polecenia i adresy wykonań, dowód ochrony, ryzyka oraz
wycofanie. Gdy istotne, dodaj właścicieli testów, uzasadnienie usunięć i daty sprawdzenia wersji
oraz źródeł. Oddziel zmierzone zyski od propozycji; niedostępne sumy pozostają nieznane.
Najpierw zakończ odwracalną pracę w zakresie; zbierz potrzeby kont, sekretów, płatnych zasobów
i zmian polityki w jedną listę dla właściciela. Dowody zachowaj w istniejącym miejscu;
podsumuj je zamiast wklejać logi.
