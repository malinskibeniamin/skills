---
title: /ux-copy
description: >-
  Twórz jasne i inkluzywne teksty interfejsu. Używaj podczas zmiany tekstów
  interfejsu, etykiet, działań, pustych stanów, błędów, treści dokumentacji lub
  terminologii produktu.
type: skill
sidebar:
  label: /ux-copy
---
![Diagram umiejętności /ux-copy](/diagrams/skills/ux-copy.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/ux-copy.excalidraw)


<!-- allow: prose-style ten plik dokumentuje reguły i przedstawia przykłady naruszeń -->

# Teksty interfejsu

Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/ux-copy/REFERENCE.md), aby poznać reguły dotyczące wielkości liter, elementów sterujących, błędów, pustych stanów,
języka inkluzywnego i stylu tekstu.

## Teksty produktu

- Stosuj zapis zdaniowy i umieszczaj obiekt lub rezultat na początku.
- Przyciski powinny określać działanie i obiekt; unikaj słów Tak, Nie, Prześlij, OK i Gotowe.
- Komunikaty o błędach powinny podawać przyczynę, ograniczenie i sposób rozwiązania problemu.
- Puste stany powinny wyjaśniać przyczynę i wskazywać jeden kolejny krok.
- Etykiety powinny być stale widoczne; teksty zastępcze służą wyłącznie do podawania przykładów.
- Ostrzeżenia o działaniach destrukcyjnych powinny bezpośrednio informować o trwałej utracie danych.
- Wyrażenia regularne i komunikaty walidacji umieszczaj obok siebie.
- Testuj długie tłumaczenia, duże liczby, stany offline i błędów, obcinanie tekstu oraz możliwość odzyskania danych.

Używaj przyjętych w projekcie nazw produktów i glosariusza, jeśli są dostępne.
Wyjątek dla tekstu w kodzie: `// allow: ux-copy [reason]`.

## Styl tekstu

- Preferuj bezpośrednie zdania i konkretne czasowniki.
- Usuwaj szablonowe wstępy, słowa charakterystyczne dla treści generowanych przez AI, rozbudowane przejścia, łacińskie skróty, potrójne
  pochwały i półpauzy.
- Stosuj opisowe teksty linków i umieszczaj je w miejscu podejmowania decyzji.

Wyjątek dla stylu tekstu: `<!-- allow: prose-style [reason] -->`.

## Konfiguracja hooków

Skopiuj i zarejestruj następujące hooki PostToolUse `Edit|Write`:

- `scripts/ux-copy-check.sh`
- `scripts/prose-style-check.sh`
- `scripts/_hook-lib.sh`

Nadaj im uprawnienia do wykonywania. Wspólną terminologię produktu przechowuj w dokumentacji projektu.

## Zakończenie

Sprawdź, czy `ux-copy-check.sh` wykrywa wykrzykniki, `successfully`, język obwiniający,
ogólne nazwy działań i nieprecyzyjne błędy. Sprawdź, czy `prose-style-check.sh` wykrywa szablonowy styl tekstów AI,
półpauzy i bezwzględnie zabronione słowa. Sprawdź poprawność zapisu przyjętych nazw produktów, jeśli
zdefiniowano je w projekcie.
