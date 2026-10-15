---
description: >-
  Generuj, udoskonalaj i eksportuj edytowalne diagramy Excalidraw na podstawie
  poleceń lub Mermaid. Używaj do odręcznie stylizowanych diagramów architektury,
  anatomii komponentów, przepływów i technicznych ilustracji z adnotacjami.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - excalidraw diagram
sidebar:
  label: /excalidraw-diagram
title: /excalidraw-diagram
type: skill
---
![Diagram umiejętności /excalidraw-diagram](/diagrams/skills/excalidraw-diagram.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/excalidraw-diagram.excalidraw)

Twórz edytowalne elementy w natywnym formacie. Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/REFERENCE.md), aby poznać format sceny, obszar roboczy/SVG i język wizualny, oraz [PR-WORKFLOW.md](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md) dla PR-ów backendowych i utrzymywanych diagramów dokumentacji.

## Domyślnie lokalnie [#local-default]

Utwórz lub zaktualizuj natywny plik `.excalidraw`, a następnie wyrenderuj go oficjalnym CLI w przypiętej wersji:

```bash
EXCALIDRAW_NO_UPDATE_NOTIFIER=1 bunx @excalidraw/cli@0.2.0 render diagram.excalidraw --out diagram.png
```

Node 22 lub nowszy, zainstalowany Chrome/Chromium/Edge/Firefox; tymczasowy profil przeglądarki, bez konta i klucza API. Tylko PNG, bez układania elementów. Używaj pamięci podręcznej `bunx`, nie zależności repozytorium korzystającego z CLI. Mermaid, edycja na żywo i SVG korzystają z opcjonalnego obszaru roboczego opisanego w materiale referencyjnym.

## Przebieg pracy [#workflow]

1. Wybierz miejsce docelowe: tymczasowe `.context/excalidraw/<slug>/` lub wskazaną trwałą ścieżkę. Nigdy nie nadpisuj plików bez uprzedzenia.
2. Zachowaj źródło przed zastąpieniem. W obszarze roboczym użyj `snapshot save <name>` lub `export --out <file>` przed wyczyszczeniem lub zastąpieniem.
3. Wybierz źródło nadrzędne: `.mmd` dla wyników Mermaid, `.excalidraw` po bezpośredniej edycji. Sprawdź Mermaid w docelowym mechanizmie renderującym.
4. Mermaid obsługuje standardowe przepływy, sekwencje, stany i relacje; bezpośrednie elementy obsługują dokładne rozmieszczenie, anatomię komponentów, logo, strefy i objaśnienia.
5. Nadaj zmienianym elementom stabilne ID. Twórz natywne elementy lokalnie. Skrócony schemat obszaru roboczego używa jednego wywołania `mermaid`, `add` lub `apply` dla pierwszego wariantu.
6. Po Mermaid wykonaj `describe` przed eksportem lub korektą. Jeśli zrzut ekranu jest renderowany, ale scena pozostaje pusta, zachowaj `.mmd` jako źródło nadrzędne lub odtwórz ją bezpośrednio; nigdy nie przedstawiaj pustego `.excalidraw` jako edytowalnego.
7. Wyrenderuj PNG albo w obszarze roboczym wykonaj `describe`, następnie `screenshot` -> obejrzyj obraz -> popraw kolizje, przycięcia, kontrast i krzyżujące się strzałki. Powtarzaj do uzyskania poprawnego wyniku.
8. Sprawdź, czy istnieją natywne elementy i widoczne etykiety; zachowaj `.excalidraw` oraz PNG lub SVG razem. Wariant zastępczy oparty tylko na Mermaid pozostaje `.mmd` wraz z renderem, a nie deklaracją edytowalnego Excalidraw.
9. Podaj ścieżki, tryb, źródło kanoniczne, opis dostępności i ręczne czynności w przeglądarce.

## Bezpieczeństwo [#safety]

- `clear --yes`, `import --replace` i przywracanie są destrukcyjne; najpierw zachowaj źródło.
- `share` przesyła scenę; używaj tylko na prośbę o publiczny link.
- Synchronizacja Excalidraw+ wymaga świadomego włączenia; Git pozostaje źródłem nadrzędnym. Błędy diagramów backendowych nie blokują pracy; zgłoś brakujące dowody i kontynuuj dostarczenie.
- Używaj SVG lub importowanych zasobów marki do dokładnych logo; nigdy nie twórz przybliżonych wersji chronionych znaków.
- Zatrzymuj tylko serwery obszaru roboczego uruchomione przez siebie.
