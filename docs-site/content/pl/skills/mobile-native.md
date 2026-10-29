---
description: "Naprawiaj mobilne problemy WWW z viewportem, dotykiem, bezpiecznym obszarem, klawiaturą, przewijaniem i interfejsem przeglądarki/PWA. Dotyczy zachowań WWW na telefonie, nie React Native ani Swift."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["mobile native"]}
sidebar: {"label":"/mobile-native"}
title: "/mobile-native"
type: "skill"
---
![Diagram umiejętności /mobile-native](/diagrams/skills/mobile-native.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/mobile-native.excalidraw)

Dla responsywnego grupowania, RTL i obszarów bezpiecznych przeczytaj [zgodność interfejsów](https://github.com/malinskibeniamin/skills/blob/main/shared/INTERFACES.md#better-layout), a potem [better-layout](https://github.com/malinskibeniamin/skills/blob/main/jakubkrehel-skills/better-layout/SKILL.md). Dla renderowania fontów lub powiększania pól użyj [better-typography](https://github.com/malinskibeniamin/skills/blob/main/jakubkrehel-skills/better-typography/SKILL.md), bez wyłączania skalowania użytkownika ani zastępowania kontroli na urządzeniu.

Usuwaj tarcie przeglądarki/platformy bez wyłączania dostępności. Adaptacja umiejętności
Emila Kowalskiego; [pochodzenie](https://github.com/malinskibeniamin/skills/blob/main/shared/EMIL-SKILLS-CREDITS.md).
Przegląd pozostaje tylko do odczytu; poprawki przechodzą przez TDD i bramki dostarczania projektu.

## Diagnoza i zakres

Ustal zgłoszony telefon/przeglądarkę, układ, sposób wprowadzania danych, tryb klawiatury/PWA i obsługiwane
urządzenia. Odtwórz problem przed zmianą domyślnych ustawień. Używaj zapytań o możliwości zamiast rozpoznawania
user-agenta; dotyk i mysz mogą współistnieć. Istniejące elementy UI i tokeny pozostają właścicielami zachowania.

| Objaw | Wąska poprawka |
|---|---|
| Hover pozostaje po dotknięciu | Ogranicz dekoracyjny hover przez `(hover: hover) and (pointer: fine)`; zachowaj fokus/naciśnięcie |
| Podświetlenie dotknięcia konkuruje z zaprojektowaną reakcją | Przezroczyste podświetlenie tylko na kontrolkach i dopiero po zapewnieniu równoważnej reakcji |
| Dolne działanie pod interfejsem przeglądarki | `100dvh` dla powłoki aplikacji; `100svh` dla stabilnej sekcji hero |
| Fokus pola powoduje zoom | Obliczony tekst pola ma co najmniej 16 pikseli CSS; zachowaj skalowanie użytkownika |
| Naciśnięcie reaguje późno | Reakcja CSS `:active`/pointer-down; aktywacja nadal przez dostępne click/submit |
| Przewijanie przechodzi za panel | `overscroll-behavior: contain` na faktycznie przewijanym elemencie |
| Wycięcie/znacznik ekranu głównego zasłania treść | `viewport-fit=cover`, potem padding z `env(safe-area-inset-*, 0px)` |
| Etykieta kontrolki zaznacza się podczas przeciągania | `user-select: none` tylko dla tej kontrolki; zachowaj zaznaczanie czytelnej treści |
| Własny gest poziomy walczy z przewijaniem | Lokalne `touch-action: pan-y pinch-zoom`; zachowaj pionowe przewijanie i pinch zoom |
| Motyw interfejsu przeglądarki nie pasuje | Metadane motywu zgodne z faktycznie rozwiązanym motywem aplikacji |

Przeczytaj [PLATFORM.md](https://github.com/malinskibeniamin/skills/blob/main/mobile-native/PLATFORM.md) o klawiaturze, gestach, overscroll i PWA.
Przed opcjonalnymi funkcjami viewport/meta sprawdź bieżące wsparcie przeglądarek.

## Zachowaj funkcje

- Zachowaj `width=device-width, initial-scale=1`, pinch zoom i duży tekst.
  Nie ustawiaj `user-scalable=no` ani limitu `maximum-scale=1`.
- Ogranicz własność gestu do uchwytu/powierzchni. Zachowaj pinch zoom przy ustawianiu
  `touch-action`; `none` nie jest ogólną poprawką przeciągania. Preferuj natywne przewijanie/snap.
- Nie zastępuj `click` aktywacją `pointerdown`: reakcja na naciśnięcie różni się od wykonania
  działania. Aktywacja klawiaturą, odsunięcie podczas przewijania i `pointercancel` muszą działać.
- Zmiany overscroll korzenia zależą od produktu. Zachowaj odświeżanie/przewijanie przeglądarki
  w dokumentach; ograniczaj tylko obszar aplikacji, który jest właścicielem gestu.
- Zachowaj kopiowanie/zaznaczanie, menu kontekstowe linków, pierścienie fokusu i semantyczne role kontrolek.
  Nasłuchiwanie pozostaje pasywne, chyba że wąsko uzasadnione anulowanie wymaga inaczej.

## Weryfikacja

Odtwórz ścieżki dotyku i klawiatury, pinch zoom/tekst 200%, pion/poziom, otwartą klawiaturę,
rozwijanie/zwijanie paska adresu, zagnieżdżone przewijanie i obsługiwane tryby jasny/ciemny/PWA.
Emulacja przeglądarki sprawdza układ; zapisz, które zachowania potwierdzono na fizycznym sprzęcie.
Bez sprzętu podaj dowody z kodu/emulacji i pozostałe próby telefoniczne.
Nie udostępniaj serwera deweloperskiego w sieci tylko po to, by spełnić tę umiejętność.

Podaj objaw -> zmienioną deklarację -> zaobserwowane zachowanie i niezweryfikowane ścieżki urządzeń.
