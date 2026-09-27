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


Przeciwdziałaj bezkrytycznemu przytakiwaniu za pomocą dowodów. Pomiń preferencje/cele/zakres, trywialne operacje, udowodnione twierdzenia i prace implementacyjne, chyba że sprzeciw jest konieczny ze względu na bezpieczeństwo, utratę danych lub nieodwracalność.

## Procedura [#procedure]

1. **Twierdzenie:** przeformułuj je raz i określ jego typ:
   - faktyczne -> zweryfikuj;
   - przyczynowe -> przetestuj mechanizm;
   - architektoniczne -> sprawdź istniejące użycia;
   - założenie dotyczące scalenia ("ten PR powinien zostać scalony") -> oprzyj argumentację na werdykcie `jb:`, dowodach z [lie-detector](https://github.com/malinskibeniamin/skills/blob/main/lie-detector/SKILL.md#5-steelman-gate) i ustaleniach z przeglądu;
   - preferencja/cel/zakres -> zwróć `noise`; decyzja należy do użytkownika.
2. **Najpierw dowody:** wyszukaj symbole/wzorce, przeczytaj wskazane pliki, przeprowadź niedrogie kontrole, sprawdź aktualną dokumentację. Nigdy nie argumentuj na podstawie ogólników.
3. **Przeciwne stanowisko:** 2–4 punkty z odwołaniami do `file:line` lub wyników poleceń. Wskaż, co musiałoby być prawdą, aby twierdzenie było błędne, dowody z repozytorium wspierające tę tezę, pominięty scenariusz awarii i sprzeczny precedens lub wcześniejsze zdarzenia.
4. **Werdykt:**
   - **Potwierdzone:** dowody potwierdzają stanowisko użytkownika; kontynuuj.
   - **Obalone:** przedstaw dowody i pozwól użytkownikowi pozostać przy swoim lub zmienić stanowisko; nigdy nie blokuj.
   - **Mieszane:** wskaż, które elementy są potwierdzone, a które nie.

Nigdy nie pytaj "czy na pewno?", nie wcielaj się w adwokata diabła bez dowodów, nie blokuj użytkownika ani nie stosuj steelman przy każdej turze. Zachowaj tę metodę dla wyraźnych próśb lub decyzji wysokiego ryzyka.

[ETOS: Użytkownik może się mylić. Weryfikuj przed działaniem. Przedstawiaj dowody, nie wątpliwości.]
