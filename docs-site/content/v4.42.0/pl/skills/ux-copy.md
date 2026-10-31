---
title: /ux-copy
description: Pisz lub recenzuj teksty interfejsu produktu. Używaj przy zmianie nagłówków, etykiet, przycisków, pomocy, komunikatów, nawigacji, tłumaczeń lub terminologii produktu.
type: skill
sidebar:
  label: /ux-copy
---
![Diagram umiejętności /ux-copy](/diagrams/skills/ux-copy.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/ux-copy.excalidraw)

Pisząc tekst w zakresie zadania, przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#writing).

Dla słownictwa produktu, lokalizacji całych komunikatów, pustych stanów i działań destrukcyjnych wczytaj [better-writing](https://github.com/malinskibeniamin/skills/blob/v4.42.0/jakubkrehel-skills/better-writing/SKILL.md). Zachowaj słownik, punkt zakończenia i wymagania rzetelnego tekstu tej umiejętności.


Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/ux-copy/REFERENCE.md), aby poznać wzorce, zapis wielkich liter, limity elementów i przykłady.
Każde zdanie ma przekazywać jedną przydatną informację wprost. Usuń zbędne słowa i powtórzenia.
Zachowaj informacje o bezpieczeństwie, limitach i niepewności oraz dostępne etykiety.
Stosuj glosariusz projektu i kanoniczne nazwy produktów; [GLOSSARY.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/ux-copy/GLOSSARY.md) dotyczy konkretnego produktu.

## Pisanie

Przygotuj najkrótszy poprawny tekst dla każdego elementu. Sprawdź cały widok wraz z sąsiednimi elementami.
Zwróć lub wprowadź tylko zamówione zmiany. Wskaż niezweryfikowane fakty; nie wymyślaj zachowania,
uprawnień, przyczyn ani sposobów naprawy. Nie sugeruj zatwierdzenia przez człowieka.

## Recenzja

Czytaj zmienione teksty w kontekście. Podaj lokalizację, dokładny cytat, nazwę wzorca i poprawkę lub usunięcie.
Przenieś przydatne fakty. Recenzja bez uwag wymienia przeczytane pliki i liczbę sprawdzonych odrębnych tekstów UI.
Zgłoś brakujący kontekst; kod źródłowy nie dowodzi sprawdzenia wyglądu. Recenzja nie zmienia plików.

## Zakres i kontrole

Obejmuje TSX/JSX, nawigację, i18n oraz UI otaczający czat. Nie obejmuje prozy dokumentacji,
generowanych opisów referencyjnych ani odpowiedzi konwersacyjnych. Jawne zasady projektu mają pierwszeństwo.

Zainstaluj wykonywalne hooki PostToolUse `Edit|Write` z `scripts/`: `ux-copy-check.sh`,
`prose-style-check.sh`, `_hook-lib.sh`. Zachowaj konfigurację hosta. Kontrole UX ostrzegają tylko o
wybranych wzorcach TS/TSX; JSX/i18n wymagają recenzji. Sprawdź aktywację w hoście.
Wyjątki wymagają uzasadnienia: `// allow: ux-copy [reason]`, `<!-- allow: prose-style [reason] -->`.

Do oceny tonu umiejętności użyj [evals/RUBRIC.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/ux-copy/evals/RUBRIC.md). Zaliczone kontrole hooków nie dowodzą jakości tonu.
