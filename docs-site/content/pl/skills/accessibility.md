---
title: /accessibility
description: "Używaj, gdy React wymaga ARIA, obsługi klawiatury, fokusu, formularzy lub zagnieżdżonych kontrolek."
type: skill
sidebar:
  label: /accessibility
---
![Diagram umiejętności /accessibility](/diagrams/skills/accessibility.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/accessibility.excalidraw)

Każda reguła ma jednego właściciela:

- **Biome** odpowiada za semantykę elementów: `alt` obrazów, obsługę klawiatury dla kontrolek niestandardowych, ARIA pola kombi i powiązanie etykiet.
- **React Doctor** odpowiada za strukturę i nazewnictwo: okna dialogowe, zagnieżdżone kontrolki, dostępne nazwy, trwałe etykiety i opisane nieprawidłowe pola.
- **Lokalny hook** tylko łączy `tablist` z rolami potomnymi `tab` oraz `data-invalid` z `aria-invalid`.

Nie powielaj kontroli. Wyłączenie: `// allow: a11y-skip [reason]`.

## Kontrakty interakcji

- Preferuj natywne kontrolki i widoczny tekst. Niestandardowy klikalny element wymaga roli, `tabIndex` i równoważnej obsługi klawiatury.
- Użyj klikalnego kontenera bez interaktywnych elementów potomnych albo pasywnego kontenera z interaktywnymi elementami potomnymi. Nie zagnieżdżaj elementów klikalnych.
- Pola kombi udostępniają `aria-expanded` i `aria-controls`; listy kart zawierają karty.
- Używaj `aria-label` tylko bez widocznej nazwy; ono lub `aria-labelledby` może zastąpić tekst potomny. Pomijaj zbędne słowa, takie jak `icon` i `button`.
- Kontrolki formularzy mają trwałe etykiety. Łącz błędy przez `aria-invalid` i aktualne `aria-describedby`; usuwaj nieaktualne identyfikatory błędów po poprawnej walidacji.
- Gdy nazewnictwo jest niejasne, sprawdź drzewo dostępności. Stosuj [wytyczne WAI-ARIA dotyczące nazw](https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/).

## Kontrole wizualne i fokusu

- Zachowaj kontrastowy wskaźnik fokusu o grubości 2 px; udostępnij działania hover klawiaturze i urządzeniom dotykowym.
- Kolejność DOM odpowiada kolejności czytania i przechodzenia klawiszem Tab. Zmieniony układ wymaga dowodu z klawiatury i czytnika ekranu.
- Powierzchnie modalne zatrzymują i przywracają fokus oraz wyłączają interakcję z tłem.
- Nie używaj wyłącznie koloru do oznaczania stanu; dodaj tekst, ikonę lub kształt i obsłuż wymuszone kolory przez `currentcolor`.
- Cele dotykowe mają co najmniej 44 na 44 piksele CSS. Ogranicz efekty hover przez `@media (hover: hover) and (pointer: fine)`.
- Przy ograniczonym ruchu zachowaj informację zwrotną przez krycie, kolor, tekst lub natychmiastową zmianę stanu.
- Obsłuż powiększenie tekstu do 200% bez utraty treści.
- Nakładki mobilne wysokiego ryzyka weryfikuj na urządzeniu lub symulatorze, w tym `visualViewport`, obszary bezpieczne, fokus i wyłączenie tła.

Konfiguracja początkowa: [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/accessibility/SETUP.md).
