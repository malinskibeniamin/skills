---
description: >-
  Twórz, oceniaj lub planuj celowy ruch w interfejsie WWW. Używaj do przejść,
  krzywych przyspieszenia, sprężyn, gestów, audytów ruchu i szukania okazji do
  animacji; nie do produkcji wideo ani aplikacji natywnych.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - animate
sidebar:
  label: /animate
title: /animate
type: skill
---
![Diagram umiejętności /animate](/diagrams/skills/animate.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/animate.excalidraw)

Przepisy na animację powierzchni i ikon: przeczytaj [zgodność interfejsów](https://github.com/malinskibeniamin/skills/blob/main/shared/INTERFACES.md#better-ui), a potem [better-ui](https://github.com/malinskibeniamin/skills/blob/main/jakubkrehel-skills/better-ui/SKILL.md). Stałe wartości źródła nie zastępują tokenów projektu ani natychmiastowej informacji zwrotnej.

Wybieraj ruch, który wyjaśnia zmianę stanu, nie opóźniając zadania użytkownika.
Adaptacja umiejętności Emila Kowalskiego; [źródło i wybór](https://github.com/malinskibeniamin/skills/blob/main/shared/EMIL-SKILLS-CREDITS.md).
Nagrywane prezentacje produktu korzystają ze [stosu nagrywania demo](https://github.com/malinskibeniamin/skills/blob/main/demo/RECORDING.md),
nie z animacji UI. `/demo` nadal wymaga wywołania przez użytkownika; ten odnośnik nie upoważnia do publikacji.

## Zakres działania [#endpoint]

- Tworzenie/poprawka: wdrażaj żądany ruch przez TDD i bramki dostarczania projektu.
- Przegląd: zgłoś usterki poparte dowodami; pozostaw źródła bez zmian.
- Audyt/plan/okazje: uszereguj ulepszenia lub uzasadnione dodatki; pozostaw źródła bez zmian.
  Zapisuj plany tylko na żądanie. Audyt nie rozpoczyna fali wdrożeń.

## Kolejność decyzji [#decision-sequence]

1. Sprawdź komponent, istniejące tokeny ruchu, zainstalowaną bibliotekę i wersję, sposoby obsługi wejścia
   oraz kontekst produktu. Użyj obecnych elementów UI, zanim wymyślisz nowy komponent.
2. Nazwij cel: informacja zwrotna, ciągłość przestrzenna, sygnalizacja stanu, wyjaśnienie
   lub rzadki element przyjemności. Powtarzana nawigacja, palety poleceń i ekrany odczytu danych
   przemawiają za natychmiastowymi zmianami. Częstotliwość to heurystyka, nie wymyślony wskaźnik dziennego użycia.
   Osoby korzystające z klawiatury otrzymują równoważną informację zwrotną bez oczekiwania.
3. Wybierz najtańszy mechanizm zachowujący znaczenie: przejścia CSS dla zmian stanu;
   `@starting-style` dla obsługiwanych przejść wejścia; WAAPI do sterowania imperatywnego;
   zainstalowaną bibliotekę sprężyn/ruchu do gestów, układu lub cykli wyjścia.
   Przed użyciem API biblioteki przeczytaj zainstalowane typy i aktualną oficjalną dokumentację.
4. Preferuj jawne przejścia `transform`/`opacity`. Zmieniaj cel od bieżącej wartości;
   utrzymuj stan wyjścia do zakończenia i sprzątaj po przerwaniu lub odmontowaniu.
   Skaluj zakotwiczone powierzchnie względem ich wyzwalacza; wyśrodkowane dialogi pozostają wyśrodkowane.
5. Wykorzystuj tokeny ponownie. Dla nowych tokenów i punktów wyjścia właściwych komponentom przeczytaj
   [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/animate/REFERENCE.md); profiluj zamiast zakładać akcelerację sprzętową.
6. Od początku uwzględniaj ograniczony ruch, obsługę hover, fokus i anulowanie.
   Usuń nieistotny ruch; natychmiastowa zmiana stanu jest poprawnym rozwiązaniem. Zachowaj istotne
   znaczenie bez animacji. Ogranicz hover przez `(hover: hover) and (pointer: fine)`.
7. W rzeczywistym punkcie wejścia sprawdź wejście/wyjście, szybkie odwrócenie, wielokrotne uruchomienie,
   klawiaturę, ograniczony ruch i dotyk. Zapisz obserwacje i to, co wymaga urządzenia.

## Przegląd i planowanie [#review-and-planning]

Sprawdź cel/częstotliwość, krzywą/czas, punkt początkowy, przerwania, koszt klatek, dostępność
oraz spójność. Przytocz `plik:wiersz` i dowód wizualny lub ślad; odróżniaj sugestie jakościowe
od odtwarzalnych usterek. Istniejące świadome kompromisy stanowią kontekst, nie automatyczne zgłoszenia.

Szukając okazji, pokaż odpowiednie miejsce, cel, oczekiwaną częstotliwość, przepis i odrzucone
kandydatury. Brak uzasadnionych okazji jest poprawnym wynikiem.
W planie rozwoju uszereguj potwierdzone ustalenia według wpływu na użytkownika i nakładu pracy;
każdy zamówiony plan ma dokładne wartości docelowe, istniejące tokeny, zakres, sposób wycofania
oraz rzeczywistą ocenę odczuwalnego efektu.

Krótko przedstaw decyzję, składniki, weryfikację i ograniczenia. Przegląd samego kodu
nie potwierdza odczuwalnego efektu ani zmierzonej płynności. Przy zmierzonych problemach z klatkami
wczytaj [animation-performance](https://github.com/malinskibeniamin/skills/blob/main/animation-performance/SKILL.md); przy ogólnej krytyce wizualnej
wczytaj [visual-review](https://github.com/malinskibeniamin/skills/blob/main/visual-review/SKILL.md) zgodnie z
[zasadami ładowania zależności](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
