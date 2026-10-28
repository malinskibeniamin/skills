---
title: /go
description: "Preset dostarczania pracy do lokalnie zweryfikowanej publikacji PR, bez czekania i scalania."
type: skill
sidebar:
  label: /go
---
![Diagram umiejętności /go](/diagrams/skills/go.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/go.excalidraw)

Przeczytaj i wykonaj [przepływ dostarczania autora](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md) na bieżącym diffie/PR należącym do użytkownika. Ten preset wybiera ship: weryfikację, dogfood, samodzielny przegląd, dowody, publikację i podsumowanie bieżącego stanu CI, a następnie kończy pracę bez czekania na CI, przeglądy ani zatwierdzenia. Naprawa CI, obsługa uwag i monitorowanie wymagają jawnego żądania. Zachowaj jednego właściciela.

Wcześniejsze jawne zatrzymanie lokalnie, po commicie, pushu lub szkicu PR ma pierwszeństwo. `/go` nie upoważnia do scalenia, publikacji całego stosu, porządkowania historii, delegowania, zmiany modelu ani harmonogramu bez nadzoru. Przy niedokończonej implementacji załaduj [development-lifecycle](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/SKILL.md).
