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


Domyślnie prowadź badania bezpośrednio w bieżącym kontekście. Praca w tle wymaga jawnego delegowania lub użycia `/swarm`.

1. Prześledź każde twierdzenie do **źródeł pierwotnych**: oficjalnej dokumentacji, kodu źródłowego, specyfikacji i własnych API dostawców.
2. Zapisz ustalenia w jednym pliku Markdown, podając źródło każdego twierdzenia; oznacz wszystko, czego nie udało się potwierdzić, i wskaż, gdzie szukano.
3. Zachowaj konwencję notatek w repozytorium: przeglądy eksploracyjne pozostają w katalogu roboczym lub pamięci; do `docs/` trafiają wyłącznie ustalenia gotowe do wykorzystania przy podejmowaniu decyzji.

## Wybór ścieżki [#routing]

- Fakt dotyczący API lub wersji potrzebny od razu -> `/read-the-damn-docs` bezpośrednio w bieżącym kontekście, bez tworzenia artefaktu.
- Dlaczego istnieje dany kod lub projekt -> przeczytaj [DESIGN-RATIONALE.md](https://github.com/malinskibeniamin/skills/blob/main/research/DESIGN-RATIONALE.md); prześledź
  historię źródła i dowody decyzji bez wymyślania intencji.
- Film -> `/video-research`; potraktuj transkrypcję ze znacznikami czasu, OCR i klatki jako materiał źródłowy.
- Sprawdzony w wielu źródłach raport z rygorystyczną weryfikacją -> narzędzie do pogłębionych badań.
- Ta umiejętność -> ukierunkowana analiza materiałów zakończona utworzeniem pliku Markdown z cytowaniami.
