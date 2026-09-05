---
title: /research
description: >-
  Badaj źródła pierwotne i zapisuj ustalenia z cytowaniami. Używaj do trwałych
  raportów, przeglądów dokumentacji, zestawów faktów o API, lektury materiałów
  lub archeologii uzasadnień projektowych.
type: skill
sidebar:
  label: /research
---
![Diagram umiejętności /research](/diagrams/skills/research.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/research.excalidraw)

Domyślnie prowadź badania bezpośrednio w bieżącym kontekście. Agent działający w tle wymaga jawnego delegowania lub użycia `/swarm`.

Jego zadania:

1. Zbadaj zagadnienie na podstawie **źródeł pierwotnych** — oficjalnej dokumentacji, kodu źródłowego, specyfikacji i własnych API dostawców — a nie ich wtórnych opracowań. Prześledź każde twierdzenie do źródła, które jest za nie odpowiedzialne.
2. Zapisz ustalenia w jednym pliku Markdown, podając źródło każdego twierdzenia.
3. Zapisz plik tam, gdzie repozytorium przechowuje już takie notatki. Zachowaj istniejącą konwencję, a jeśli jej nie ma, wybierz rozsądne miejsce i wskaż je. W tym repozytorium umiejętności przeglądy eksploracyjne pozostają w katalogu roboczym lub pamięci — do `docs/` trafiają wyłącznie ustalenia gotowe do wykorzystania przy podejmowaniu decyzji.

## Wybór ścieżki

- Potrzebujesz faktu **od razu**, aby kontynuować programowanie (kształt API, bieżąca flaga, zachowanie wersji) -> użyj bezpośrednio `/read-the-damn-docs`; bez agenta działającego w tle i bez tworzenia artefaktu.
- Chcesz ustalić, dlaczego istnieje dany kod lub projekt -> przeczytaj [DESIGN-RATIONALE.md](https://github.com/malinskibeniamin/skills/blob/main/research/DESIGN-RATIONALE.md); prześledź historię źródła i dowody decyzji bez wymyślania intencji.
- Adres URL filmu lub załącznik -> najpierw użyj `/video-research`; potraktuj transkrypcję ze znacznikami czasu, OCR i klatki jako materiał źródłowy.
- Sprawdzony w wielu źródłach **raport** z rygorystyczną weryfikacją -> użyj narzędzia do pogłębionych badań.
- Ta umiejętność stanowi rozwiązanie pośrednie: ukierunkowana analiza materiałów zakończona utworzeniem pliku Markdown z cytowaniami.
