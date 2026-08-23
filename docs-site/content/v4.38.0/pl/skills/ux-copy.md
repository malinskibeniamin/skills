---
title: /ux-copy
description: >-
  Twórz jasne, zwięzłe i inkluzywne teksty interfejsu. Używaj podczas zmiany
  tekstów interfejsu, etykiet, przycisków, pustych stanów, błędów, powiadomień,
  tekstów pomocy lub terminologii produktu.
type: skill
sidebar:
  label: /ux-copy
---
![Diagram umiejętności /ux-copy](/diagrams/skills/ux-copy.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/ux-copy.excalidraw)


<!-- allow: prose-style ten plik dokumentuje reguły i przedstawia przykłady naruszeń -->

# Teksty interfejsu

Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/ux-copy/REFERENCE.md), aby poznać reguły dotyczące wielkości liter, elementów sterujących, komunikatów, linków,
tekstów zastępczych i języka inkluzywnego.

## Teksty interfejsu

- Stosuj zapis zdaniowy i umieszczaj obiekt lub rezultat na początku.
- Każda etykieta, podpowiedź, tekst zastępczy, etykietka i błąd powinny pełnić inną funkcję.
- Przyciski powinny określać działanie i obiekt; unikaj słów Tak, Nie, Prześlij, OK i Gotowe.
- Komunikaty o błędach powinny podawać przyczynę, ograniczenie i sposób rozwiązania problemu.
- Puste stany powinny wyjaśniać przyczynę i wskazywać jeden kolejny krok.
- Etykiety powinny być stale widoczne; teksty zastępcze służą wyłącznie do podawania przykładów.
- Powiadomienia o zakończeniu używają podmiotu i czasownika w czasie przeszłym.
- Słów proszę, przepraszam i dziękuję używaj tylko przy rzeczywistej niedogodności.
- Ostrzeżenia o działaniach destrukcyjnych powinny bezpośrednio informować o trwałej utracie danych.
- Wyrażenia regularne i komunikaty walidacji umieszczaj obok siebie.
- Testuj długie tłumaczenia, duże liczby, stany offline i błędów, obcinanie tekstu oraz możliwość odzyskania danych.

Używaj przyjętych w projekcie nazw produktów i glosariusza, jeśli są dostępne.
Wyjątek dla tekstu w kodzie: `// allow: ux-copy [reason]`.

## Kontrola Markdown

`prose-style-check.sh` zapewnia wąskie kontrole Markdown w repozytorium dotyczące
zbędnych treści, linków, terminów inkluzywnych i zapisu nagłówków. Standardy
dokumentacji projektu pozostają źródłem prawdy.

Wyjątek dla stylu tekstu: `<!-- allow: prose-style [reason] -->`.

## Konfiguracja hooków

Skopiuj i zarejestruj następujące hooki PostToolUse `Edit|Write`:

- `scripts/ux-copy-check.sh`
- `scripts/prose-style-check.sh`
- `scripts/_hook-lib.sh`

Nadaj im uprawnienia do wykonywania. Wspólną terminologię produktu przechowuj w dokumentacji projektu.

## Zakończenie

Sprawdź, czy `ux-copy-check.sh` wykrywa wykrzykniki, `successfully`, język obwiniający,
ogólne nazwy działań, nieprecyzyjne błędy, rozwlekłe powiadomienia i błędne teksty
zastępcze. Sprawdź, czy `prose-style-check.sh` wykrywa szablonowy styl tekstów AI,
półpauzy, nieopisowe linki, terminy nieinkluzywne i nagłówki zapisane jak tytuły.
Sprawdź poprawność zapisu przyjętych nazw produktów, jeśli zdefiniowano je w projekcie.
