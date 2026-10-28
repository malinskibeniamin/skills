---
title: /revamp
description: >-
  Przeprowadź dużą przebudowę, port lub migrację, korzystając z pomiarów
  bazowych i najpierw wykonując mechaniczną translację.
type: skill
sidebar:
  label: /revamp
---
![Diagram umiejętności /revamp](/diagrams/skills/revamp.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/revamp.excalidraw)

Duże przebudowy zachowują zachowanie przez oddzielenie mechanicznego przeniesienia od przeprojektowania. Źródło: https://bun.com/blog/bun-in-rust. Wykonawca przestrzega reguł doboru modeli repozytorium; samo wywołanie nie upoważnia do uruchamiania agentów.

## 1. Pomiary bazowe przed napisaniem kodu

- Zamroź znane usterki, aby odróżnić regresje od wcześniejszych błędów.
- Zmierz przepustowość, pamięć, rozmiar artefaktu i opóźnienie przy tym samym obciążeniu i sprzęcie.
- Policz asercje; na końcu żadna nie może być pominięta, osłabiona ani usunięta.
- Zamroź [asercje zgodności funkcji](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/verification-replay.md); zachowaj zamierzony branding, ruch, interakcje i semantykę danych.

## 2. Testy są niezależne od implementacji

Testy sprawdzają niezależną od języka granicę CLI/API, a nie zastępowaną implementację; w razie potrzeby najpierw usuń zależności. Dodaj reprezentatywne aplikacje lub projekty spoza znanego korpusu testowego. Zgodność ze znanym korpusem dowodzi zgodności z tym korpusem, nie pełnej kompatybilności.

## 3. Najpierw mechanicznie, później idiomatycznie

Przenoś 1:1, zachowując architekturę, nazwy i strukturę. Refaktoryzuj dopiero po potwierdzeniu zgodności. Jednoczesne przeniesienie i przeprojektowanie utrudnia wyjaśnienie błędów. Wybierz i zapisz pełne przełączenie, gdy mosty zgodności pozostałyby zbyt długo; migrację stopniową, gdy system musi być stale wydawany.

## 4. Próba przed rozszerzeniem zakresu

Przenieś trzy reprezentatywne pliki: przeniesienie -> kompilacja -> krytyczny przegląd -> testy. Skalibruj prompt, kontrole i kolejkę przed skalowaniem.

## 5. Kolejka pracy mechanicznej

Uporządkuj błędy `cargo check`, `tsc` lub odpowiednika. Bez zgody na delegowanie pracuj kolejno jako jeden właściciel. Za zgodą na delegowanie lub `/swarm` izoluj niezależne worktree; każda ścieżka commituje tylko własny zakres i nie wykonuje stash, reset ani edycji cudzej ścieżki.

## 6. Krytyczny przegląd ze świeżym kontekstem

Sprawdź diff i kontrakt, zakładając możliwość dryfu semantycznego. Na istotnym etapie PR lub dostarczenia używaj tylko dozwolonego przez repozytorium przeglądu między modelami na pierwszym planie; w innych przypadkach wykonaj świeży przegląd dowodów samodzielnie.

## 7. Pułapki równoważności semantycznej

Sprawdź asercje i efekty uboczne znikające w wydaniu, przepełnienia i granice liczb, domyślne kopiowanie zamiast referencji, rekursję i stos przy głęboko zagnieżdżonych danych oraz ustawienia języka i kodowania. Każda wykryta pułapka staje się danymi testowymi.

## 8. Napraw proces

Gdy wykonawca zawodzi, popraw prompt, listę kontroli lub kolejkę i powtórz, zamiast ręcznie poprawiać wynik. Ludzie sprawdzają walidację i próbki, pilnują zachowania testów CI i decydują o scaleniu.

## Zakończenie

- Wszystkie wcześniejsze testy przechodzą; zero pominiętych lub usuniętych; liczba asercji uzgodniona.
- Pomiar przy tym samym obciążeniu i sprzęcie spełnia zapisany poziom bazowy.
- Rejestr błędów odróżnia wcześniejsze usterki od regresji.
- Każdy diff otrzymuje krytyczny przegląd zgodny z polityką repozytorium.
- Wycofanie jest udokumentowane; stara implementacja pozostaje gotowa do wydania do zakończenia.
