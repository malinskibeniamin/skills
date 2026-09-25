---
title: /steelman
description: >-
  Przedstaw najsilniejsze, poparte dowodami argumenty przeciwko założeniu.
  Używaj, gdy użytkownik prosi o steelman, krytyczną ocenę lub drugą opinię albo
  gdy decyzja wysokiego ryzyka zależy od niepewnego założenia.
type: skill
sidebar:
  label: /steelman
---
![Diagram umiejętności /steelman](/diagrams/skills/steelman.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/steelman.excalidraw)

Przeciwdziałanie bezkrytycznemu przytakiwaniu. Modele LLM domyślnie się zgadzają. Ta umiejętność wymusza przedstawienie przeciwnego stanowiska.
Pomiń preferencje, cele, trywialne operacje, twierdzenia udowodnione przez użytkownika i prace implementacyjne,
chyba że sprzeciw jest konieczny ze względu na bezpieczeństwo, utratę danych lub nieodwracalność.

## Procedura

### Krok 1: Określ twierdzenie

Przeformułuj twierdzenie użytkownika w jednym zdaniu. Oznacz jego typ:
- **Faktyczne** (możliwe do zweryfikowania: grep, dokumentacja, uruchomienie) -> najpierw zweryfikuj
- **Przyczynowe** ("X nie działa z powodu Y") -> przetestuj mechanizm
- **Architektoniczne** ("wzorzec Z nie będzie się skalować") -> sprawdź istniejące użycia
- **Preferencja/cel/zakres** -> odmów zastosowania steelman. Zarejestruj `noise`. Zakończ.

Preferencje i cele należą do decyzji użytkownika. Nie stosuj steelman.

### Krok 2: Zbierz dowody

Przeprowadź równolegle kontrole *przed* rozpoczęciem argumentacji:
- Wyszukaj wymienione symbole / wzorce za pomocą grep
- Przeczytaj wskazane pliki
- Uruchom testy/polecenia, jeśli jest to niedrogie
- Sprawdź dokumentację/internet w przypadku twierdzeń dotyczących wersji lub narzędzi

NIE argumentuj na podstawie ogólników ("wzorzec wygląda podejrzanie"). Opieraj argumenty na dowodach z repozytorium.

### Krok 3: Przedstaw najsilniejszą wersję przeciwnego stanowiska

Napisz najsilniejszy kontrargument z konkretnymi odniesieniami:
- Co musiałoby być prawdą, aby użytkownik się mylił?
- Jakie dowody w repozytorium wspierają tezę, że użytkownik się myli?
- Jakiego scenariusza awarii użytkownik nie bierze pod uwagę?
- Jaki precedens temu przeczy (git blame, wcześniejsze commity, powiązane pliki)?

Format: 2–4 punkty. Każdy zawiera odwołanie do pliku i wiersza lub wyniku polecenia.

### Krok 4: Werdykt

Trzy możliwe wyniki:
- **Potwierdzone**: dowody potwierdzają stanowisko użytkownika. Powiedz to, podając odniesienia. Kontynuuj zgodnie z planem użytkownika.
- **Obalone**: dowody przeczą stanowisku użytkownika. Przedstaw je wraz z odniesieniami. Pozwól użytkownikowi zdecydować (pozostać przy swoim lub zmienić stanowisko). NIE blokuj.
- **Mieszane**: częściowe potwierdzenie. Wskaż, które elementy są trafne, a które nie.

## Antywzorzec

Nie:
- Pytaj "czy na pewno?" -- zweryfikuj bez informowania o tym, przedstaw tylko dowody
- Wcielaj się w adwokata diabła bez odniesień -- opieraj się wyłącznie na repozytorium
- Blokuj użytkownika. Przedstawiaj, nie ograniczaj.
- Stosuj steelman przy każdej turze -- sygnał traci na wartości. Zachowaj tę metodę dla decyzji wysokiego ryzyka i wyraźnych próśb.

[ETOS: Użytkownik może się mylić. Weryfikuj przed działaniem. Przedstawiaj dowody, nie wątpliwości.]
