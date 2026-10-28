---
description: >-
  Preset zgodności dostarczający pracę do autoryzowanego scalenia; full stop lub
  --no-merge pozostawia decyzję o scaleniu użytkownikowi.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - full send
sidebar:
  label: /full-send
title: /full-send
type: skill
---
![Diagram umiejętności /full-send](/diagrams/skills/full-send.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/full-send.excalidraw)

Jawne `full send <task or PR>` wybiera [przepływ dostarczania autora](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md) i upoważnia do napraw, commitów, pushu, PR oraz scalenia tego jednego jednoznacznego rezultatu zgodnie z polityką repozytorium. Nie upoważnia do czekania na CI, przeglądy ani do monitorowania; zgłoś bieżące blokady. Rozmowa o umiejętności nie jest jej wywołaniem.

Wcześniejsze ograniczenia mają pierwszeństwo: lokalnie, bez pushu, tylko szkic, gotowy PR, full stop lub `--no-merge` zawężają punkt końcowy. Sama opieka nad PR nie upoważnia do scalenia. Ustal cel i należące do użytkownika drzewo robocze, wykorzystaj istniejący PR i pozostaw jego gałąź aktywną w Conductor. Pytaj tylko o niejednoznaczny cel lub blokującą decyzję zastrzeżoną dla właściciela.

Przeczytaj i wykonaj wspólny przepływ, zamiast drugiej implementacji full-send. Dla niedokończonego kodu załaduj [development-lifecycle](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/SKILL.md); istniejące PR-y zaczynają od aktualnych dowodów. Używaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/full-send/REFERENCE.md) tylko dla żądanego checkpointu, powiadomienia, wznowienia lub jawnie delegowanego przeglądu. Bez automatycznej zmiany modelu i agentów.

Przeczytaj [integrację tstack](https://github.com/malinskibeniamin/skills/blob/main/shared/TSTACK.md#full-send) i oryginalne wskazówki dotyczące dowodów, bez zmiany właściciela przepływu, dodawania niezamówionych recenzentów ani rozszerzania uprawnień.

Wspólny przepływ wybiera [kontekst natywny](https://github.com/malinskibeniamin/skills/blob/main/shared/T3CODE-NATIVE.md#resolve-context) dla autoryzowanego monitorowania; zachowaj jedną pętlę dostarczania, nie osobny przepływ T3.

Inspiracje i ograniczenia badań: [SOURCES.md](https://github.com/malinskibeniamin/skills/blob/main/full-send/SOURCES.md). Lokalny przepływ dostarczania korzysta z licencjonowanej kopii tstack; nie oznacza to poparcia autorów oryginału.
