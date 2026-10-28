---
description: "Diagnozuj i naprawiaj wolne lub niestabilne CI, nieefektywne zadania oraz testy o niskiej wartości. Używaj do optymalizacji czasu, cache, shardów, wyboru zależnych testów, maszyn i narzędzi."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["ci fixes"]}
sidebar: {"label":"/ci-fixes"}
title: "/ci-fixes"
type: "skill"
---
![Diagram umiejętności /ci-fixes](/diagrams/skills/ci-fixes.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/ci-fixes.excalidraw)

Skróć czas do miarodajnego zielonego CI, zużywając mniej zasobów i zachowując ochronę przed regresjami.
Optymalizuj czas od commita do ostatniej wymaganej kontroli, nie tylko czas testów.
Zachowaj żądany punkt końcowy: audyty i plany są tylko do odczytu; wdrażaj zmiany wyłącznie na prośbę.
Nie twórz przy okazji harmonogramów, nie kupuj maszyn, nie zmieniaj ochrony gałęzi ani nie uruchamiaj agentów.

## Ustal punkt odniesienia

1. Ustal docelowe repozytorium, gałąź, workflow, akcje wielokrotnego użytku i złożone, skrypty,
   konfigurację testów, wymagane kontrole oraz właściwe instrukcje. Sprawdź rzeczywiste polecenia.
2. Zbierz porównywalne ostatnie wykonania, także błędne i ponowione: adresy commitów i wykonań,
   czas kolejki, zależności zadań, czas przygotowania, budowania, testów i przesyłania, stan cache,
   zasoby maszyn, liczbę workerów, czasy shardów, liczbę testów i błędy pierwszych prób.
   Korzystaj z raportów dostawcy; brak historii oznacza niewiedzę, nie dowód szybkości ani niezawodności.
3. Rozrysuj ścieżkę krytyczną od przygotowań do końcowego wymaganego wyniku. Oddziel czas
   rzeczywisty od sumy minut pracy maszyn i kosztu; zapisz liczbę próbek oraz środowisko.

## Wybierz najmniejszą użyteczną zmianę

Przeczytaj cały [audyt z 21 kontrolami](https://github.com/malinskibeniamin/skills/blob/main/ci-fixes/REFERENCE.md).
Oceń każdą kontrolę; dla właściwych zadań zapisz decyzję **przyjmij**, **odrzuć**,
**odrocz** albo **nie dotyczy**, wraz z dowodami. Nie stosuj każdej dostępnej optymalizacji.
Ustal priorytety według zmierzonych oszczędności na ścieżce krytycznej i zasobach, pewności
oraz ryzyka wdrożenia i utrzymania. Niewiadome wymagają małego eksperymentu, nie zmyślonych
szacunków. Nigdy nie opóźniaj szybkich zadań tylko po to, by kończyły się równocześnie.

Wczytuj dodatkowe instrukcje tylko dla wykonywanej pracy:

- Zmiany workflow: [utrzymanie CI](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/ci-maintenance/SKILL.md),
  w tym źródło kanoniczne i granice zaufania. Chroń poświadczenia, cache, artefakty i forki.
- Usuwanie testów: [audyt testów](https://github.com/malinskibeniamin/skills/blob/main/test-audit/SKILL.md).
  Przed usunięciem wskaż zachowane kontrakty i główny test każdego z nich; szybkość i samo pokrycie linii nie wystarczą.
- Niestabilne testy: [diagnozowanie błędów](https://github.com/malinskibeniamin/skills/blob/main/diagnosing-bugs/SKILL.md).
  Odtwórz błędy pierwszej próby i napraw właściciela zachowania albo narzędzia; udane ponowienie nie jest naprawą.
- Aktualizacje: [aktualizacja zależności](https://github.com/malinskibeniamin/skills/blob/main/upgrade-dependency/SKILL.md).
  Sprawdź aktualne stabilne wydania, migracje i zgodność maszyn w źródłach pierwotnych podczas wykonywania zadania.

Podczas wdrażania zmieniaj jedno spójne wąskie gardło naraz. Nowe zachowanie i naprawy
zaczynaj od niedziałającego testu publicznego kontraktu; konfigurację i dokumentację
sprawdzaj wykonywalnymi narzędziami, nie testami wyszukującymi tekst instrukcji. Zachowaj cudze zmiany.

## Udowodnij poprawę

- Uruchom kontrole składni workflow, kontrole repozytorium oraz właściwe testy. Sprawdź brak,
  trafienie i unieważnienie cache; po zmianie wyboru testów porównaj go z pełnym zestawem.
  Zweryfikuj propagację błędów, brakujące shardy i ukończenie wymaganych kontroli.
- Porównuj ten sam zakres pracy, maszynę, wersje narzędzi, liczbę workerów i stan cache,
  z wyjątkiem badanej zmiennej. Powtórz pomiary; podaj surowe czasy, liczbę próbek, medianę
  i ogon rozkładu, gdy mają sens, a także osobno minuty pracy maszyn i czas kolejki.
- Po zmianie workerów, izolacji lub podziału uruchamiaj testy wielokrotnie i w zmienionej
  kolejności przy docelowej współbieżności. Sprawdź pamięć, CPU, niestabilność i wyścigi stanu.
- Po usuwaniu porównaj pokrycie linii i gałęzi pełnego zachowanego zestawu z taką samą
  instrumentacją, progami, wykluczeniami i zakresem kodu. Zachowaj wykrywanie unikalnych błędów
  oraz krytyczne ścieżki, nie tylko procenty; stosuj celowane kontrole negatywne lub mutacje.
- Uruchom pełne kontrole regresji właściwe dla zmienionych kontraktów. Jawnie wymień
  weryfikację dostępną tylko na hostowanych maszynach lub niedostępną; lokalny sukces nie dowodzi sukcesu CI na GitHubie.

Zielony wynik oznacza, że właściwa praca naprawdę się wykonała. Zachowaj widoczność błędów:
bez ukrywania kodów wyjścia, `continue-on-error`, osłabiania asercji i pokrycia, trwałych
pominięć lub kwarantanny ani ponowień maskujących niestabilność. Nigdy nie przenoś uszkodzonego testu na noc, by ogłosić naprawę.

## Przekazanie

Zacznij od wyniku i jego ograniczeń. Podaj wąskie gardło, decyzje dla wszystkich 21 kontroli,
dowody przed i po wraz z próbkami i stanem cache, zmienione przypisanie kontraktów do testów,
powody usunięć, daty weryfikacji wersji i źródeł, rzeczywiste polecenia i adresy wykonań,
nierozwiązane ryzyka oraz sposób wycofania. Oddziel zmierzone zyski od proponowanych eksperymentów.
Szczegółowe dowody przechowuj w istniejącym miejscu repozytorium; podsumuj je zamiast wklejać logi.
