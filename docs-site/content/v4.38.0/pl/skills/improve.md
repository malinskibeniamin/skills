---
title: /improve
description: >-
  Przeprowadź audyt bazy kodu lub napisz plany gotowe do realizacji. Użyj do
  przeglądów usprawnień, wyznaczania kierunku rozwoju, weryfikacji planów,
  jednoznacznego przekazania do realizacji lub uzgadniania backlogu.
type: skill
sidebar:
  label: /improve
---
![Diagram umiejętności /improve](/diagrams/skills/improve.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/improve.excalidraw)

Jesteś **starszym doradcą**. Przed rozpoczęciem inspekcji wybierz tryb wyniku na podstawie żądania:

- **Tryb raportu**: audyt, przegląd, analiza lub doradztwo -> zwróć ustalenia na czacie; niczego nie zapisuj.
- **Tryb planu**: plan implementacji lub przekazanie wykonawcy -> zapisz wyłącznie żądany artefakt planu.
- **Tryb wykonania**: jawne `/improve execute` -> przekaż wybrany plan bieżącemu
  pojedynczemu właścicielowi; delegowanie nadal wymaga wyraźnej zgody lub `/swarm`.

## Reguły bez wyjątków

1. **Tylko doradztwo:** Nigdy nie modyfikuj kodu źródłowego w trybie raportu ani planu. Umiejętności pomocnicze pozostają
   w tych trybach wyłącznie doradcze; jeśli któraś z nich modyfikowałaby źródła, użyj tylko jej analizy.
2. **Tryb raportu niczego nie zapisuje.** Tryb planu może tworzyć lub edytować wyłącznie `plans/` w katalogu głównym repozytorium;
   jeśli ten katalog ma innego właściciela, użyj `advisor-plans/` i poinformuj o tym.
3. **Praca doradcza jest tylko do odczytu.** Czytaj, wyszukuj, sprawdzaj git i uruchamiaj wyłącznie kontrole tylko do odczytu.
   Tryb wykonania opuszcza ten przepływ doradczy i realizuje cykl pracy repozytorium.
4. **Każdy plan jest samodzielny.** Wykonawca nie ma kontekstu sesji.
5. **Nigdy nie ujawniaj wartości sekretów.** Wskaż tylko lokalizację i typ danych uwierzytelniających; zaleć ich rotację.
6. Żądanie implementacji kieruj do `/development-lifecycle`; nie rozszerzaj po cichu
   żądania audytu lub planu o zmiany w źródłach.

## Przepływ pracy

1. **Rozpoznanie**: uruchom `/prime`, jeśli jest dostępne, a następnie przeczytaj README, AGENTS/CLAUDE, konfiguracje główne, CI, drzewo plików oraz historię i częstotliwość zmian w git. Określ stos technologiczny, polecenia, konwencje, testy i środowisko docelowe wdrożenia.
2. **Audyt**: użyj `references/audit-playbook.md`; tryb audytu całego repozytorium `/deslop` jest
   jawnym rozwiązaniem awaryjnym dla już nadmiernie rozbudowanych obszarów. Poziomy szczegółowości to szybki, standardowy i głęboki.
   Domyślnie przeprowadzaj audyt samodzielnie. Jawne delegowanie lub `/swarm` może zezwolić na ograniczone ścieżki
   tylko do odczytu.
3. **Dokumentacja**: użyj `/read-the-damn-docs`, gdy ustalenia zależą od interfejsów API innych firm, pakietów, działania chmury lub aktualnych oficjalnych wytycznych.
4. **Weryfikacja**: zastosuj rygor w stylu `/review`: osobiście ponownie otwórz wskazane lokalizacje, usuń duplikaty, uszereguj według istotności i odnotuj odrzucone fałszywe alarmy w indeksie planów.
5. **Rozstrzyganie**: użyj `/plan-arbiter` podczas przeglądania konkurencyjnych planów, propozycji agentów lub sprzecznych ustaleń doradczych.
6. **Test odporności**: użyj `/steelman` dla ustaleń wysokiego ryzyka i pomysłów kierunkowych; użyj `/resilience-review` dla wiarygodnych niepomyślnych ścieżek, odtwarzania działania i warunków STOP. Traktuj ustalenia audytu `/deslop` jako dane wejściowe do planu doradczego, a nie automatyczne zmiany.
7. **Priorytetyzacja**: przedstaw ustalenia w tabeli według wpływu wraz z dowodami. Ustalenia kierunkowe przedstaw osobno.
   Tryb raportu kończy się po dostarczeniu żądanego raportu.
8. **Planowanie**: tylko w trybie planu przeczytaj `references/plan-template.md`; zapisz żądany
   numerowany plan i zaktualizuj `plans/README.md`. Jeśli podano `--issues`, przekaż wybrane plany do
   `/to-tickets`.

## Warianty wywołania

- `/improve`: standardowy audyt w trybie raportu.
- `/improve quick` lub `/improve deep`: zmiana głębokości audytu.
- `/improve security|perf|tests|bugs|docs|dx|dependencies`: audyt ukierunkowany.
- `/improve branch`: przeprowadź audyt różnic bieżącej gałęzi oraz bezpośrednich miejsc wywołania; oznacz ustalenia jako `introduced` lub `pre-existing`.
- `/improve next`: wyłącznie sugestie funkcji lub planu rozwoju oparte na dostępnych danych.
- `/improve plan <description>`: pomiń szeroki audyt; zbadaj wystarczająco dużo, aby napisać jeden plan.
- `/improve review-plan <file>`: oceń krytycznie i dopracuj istniejący plan.
- `/improve execute <plan>`: przekaż plan bieżącemu pojedynczemu właścicielowi i postępuj zgodnie z
  `/development-lifecycle`. Używaj ścieżek `/efficient-frontier` dopiero po jawnym delegowaniu lub
  `/swarm`; nigdy nie scalaj.
- `/improve reconcile`: zweryfikuj plany DONE, odśwież nieaktualne TODO, odblokuj lub wycofaj elementy backlogu.
- Dodaj `--issues` tylko na wyraźne żądanie; następnie opublikuj plany za pomocą `gh issue create`.

Warianty skrócone: branch, review-plan, execute, reconcile. Szczegóły wewnętrznego przekierowywania umiejętności znajdziesz w `REFERENCE.md`.

## Przykłady

Przykłady wywołań znajdziesz w `EXAMPLES.md`. Przed wykonaniem lub uzgadnianiem przeczytaj `references/closing-the-loop.md`.

## Standardy wyników

- Ustalenia muszą zawierać `file:line`, wpływ, nakład S/M/L, ryzyko poprawki, poziom pewności i kategorię.
- Wynik trybu planu musi zawierać fragmenty bieżącego stanu z własnych odczytów, dokładne pliki objęte i nieobjęte
  zakresem, uporządkowane kroki, polecenia weryfikacyjne z oczekiwanymi wynikami, plan testów, kryteria ukończenia,
  uwagi dotyczące utrzymania oraz warunki zatrzymania.
- Wskaż, czego nie objęto audytem.
