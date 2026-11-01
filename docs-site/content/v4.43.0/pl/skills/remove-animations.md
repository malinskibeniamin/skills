---
description: "Usuń lub ogranicz zbędny ruch w interfejsie WWW: powtarzane odsłonięcia, dekoracyjne pętle, opóźnione działania klawiatury i ponowne animowanie danych. Tylko odejmowanie; zachowany ruch obsługuje animate."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["remove animations"]}
sidebar: {"label":"/remove-animations"}
title: "/remove-animations"
type: "skill"
---
![Schemat umiejętności /remove-animations](/diagrams/skills/remove-animations.svg)

[Otwórz edytowalny plik źródłowy Excalidraw](/diagrams/skills/remove-animations.excalidraw)

Usuń ruch, który opóźnia zadanie, nie wyjaśniając istotnej zmiany.
Adaptacja materiałów Emila Kowalskiego; [źródło i zgodność](https://github.com/malinskibeniamin/skills/blob/v4.43.0/shared/EMIL-SKILLS-CREDITS.md).
Audyt lub pytanie kończy się ustaleniami bez zmian; żądanie usunięcia prowadzi do wdrożenia
przez TDD i bramki dostarczania projektu. Wczytanie nie nadaje szerszych uprawnień.

## Pętla usuwania [#removal-loop]

1. Opisz ruch w żądanym zakresie: komponent, wyzwalacz, mechanizm, właściwości, tokeny,
   cel oraz obserwowaną lub oczekiwaną częstotliwość. Uszanuj udokumentowane decyzje projektowe.
   Częstotliwość to heurystyka, nie wymyślona analityka dziennego użycia.
2. Zachowaj ruch przekazujący informację zwrotną, ciągłość przestrzenną, stan lub wyjaśnienie.
   Oceń rzadkie efekty budzące przyjemność w kontekście. Najpierw usuwaj powtarzane odsłonięcia
   przy przewijaniu, dekoracyjne pętle, rysowanie wykresów i liczenie od zera przy każdym montowaniu,
   kaskadowe wejścia list oraz oczekiwanie podczas obsługi klawiatury lub częstej nawigacji.
   Zachowaj równoważną informację dla klawiatury, wskaźniki ładowania i istotne znaczenie stanu;
   natychmiastowe zmiany stanu są poprawne.
3. Wybierz usunięcie, ograniczenie lub zachowanie, podając `file:line` i powód.
   Ograniczaj wyłącznie istniejący efekt: usuń ruch przestrzenny lub kaskadę, skróć nadmierne
   opóźnienie albo zatrzymaj dekoracyjną pętlę. Używaj istniejących tokenów; nie dodawaj animacji
   ani krzywych. Grupa podpowiedzi nie powinna ponawiać początkowego opóźnienia przy przechodzeniu między nimi.
4. Przed edycją prześledź ukryte stany początkowe, tryby wypełnienia, obserwatory, wywołania po
   zakończeniu animacji, timery zależne od czasu trwania, cykl wyjścia/odmontowania i odroczony fokus.
   Usuwaj ukryty stan początkowy razem z odsłonięciem. Przenieś zakończenie i fokus do rzeczywistej
   zmiany stanu, dokładnie raz, zamiast czekać na usunięte zdarzenie.
   Jeśli animacja układu maskuje skok, zachowaj ją i zgłoś problem układu.
5. Usuń tylko potwierdzone nieużywane elementy: klatki kluczowe, warianty, importy ruchu, wrappery i tokeny.
   Zachowaj wrapper z innym zachowaniem. Usuwanie zależności nie należy do tego porządkowania ruchu;
   zgłoś nieużywane biblioteki bez zmiany manifestu lub pliku blokady.
6. W rzeczywistym punkcie wejścia sprawdź widoczną treść, natychmiastowe zamknięcie/odmontowanie,
   przywrócenie fokusu, klawiaturę/dotyk, szybkie odwrócenie i ograniczony ruch. Uruchom odpowiednie testy
   i kontrole repozytorium; potwierdź brak odwołań do usuniętych nazw.

## Przekazanie [#handoff]

Podaj zmienione miejsca w układzie przed -> decyzja -> powód, cel świadomie zachowanego ruchu,
usunięty nieużywany kod i ograniczenia weryfikacji. Nie wymyślaj zachowanych przykładów dla wypełnienia
limitu ani nie twierdź, że sam przegląd kodu dowodzi odczuwalnej szybkości lub lepszej liczby klatek.

Dla poprawek wykonania zachowanego ruchu wczytaj [animate](https://github.com/malinskibeniamin/skills/blob/v4.43.0/animate/SKILL.md);
dla audytu lub planu rozwoju wczytaj [improve-animations](https://github.com/malinskibeniamin/skills/blob/v4.43.0/improve-animations/SKILL.md).
Przy zmierzonej utracie płynności wczytaj [animation-performance](https://github.com/malinskibeniamin/skills/blob/v4.43.0/animation-performance/SKILL.md).
Stosuj [zasady ładowania zależności](https://github.com/malinskibeniamin/skills/blob/v4.43.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
