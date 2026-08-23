---
title: /excalidraw-diagram
description: >-
  Generuj, udoskonalaj i eksportuj edytowalne diagramy Excalidraw na podstawie
  poleceń lub Mermaid. Używaj do odręcznie stylizowanych diagramów architektury,
  anatomii komponentów, przepływów i technicznych ilustracji z adnotacjami.
type: skill
sidebar:
  label: /excalidraw-diagram
---
![Diagram umiejętności /excalidraw-diagram](/diagrams/skills/excalidraw-diagram.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/excalidraw-diagram.excalidraw)

Generuj rzeczywiste elementy Excalidraw, a nie ich bitmapową imitację. Utrzymuj jedno edytowalne źródło
prawdy i twórz na jego podstawie zasoby prezentacyjne.

Przed konwersją Mermaid, bezpośrednim tworzeniem elementów lub
odwzorowywaniem języka wizualnego w stylu Shadcn przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/excalidraw-diagram/REFERENCE.md).

## Obszar roboczy

Uruchamiaj każde polecenie obszaru roboczego za pomocą CLI w przypiętej wersji:

```bash
export EXPRESS_SERVER_URL="http://127.0.0.1:${CONDUCTOR_PORT:-3000}"
bunx mcp-excalidraw-server@1.1.0 <command>
```

Pozwól, aby `bunx` korzystał ze współdzielonej pamięci podręcznej; nie dodawaj CLI do repozytorium, które z niego korzysta.
Środowisko wybiera przydzielony port Conductor, jeśli jest dostępny, a w przeciwnym razie używa portu 3000.
Uruchom `start`, otwórz `$EXPRESS_SERVER_URL` w izolowanej przeglądarce, pozostaw kartę otwartą, a następnie
potwierdź, że `status` zgłasza klienta przeglądarki. Jeśli automatyzacja izolowanej przeglądarki jest niedostępna,
poproś użytkownika o jednorazowe otwarcie podanego adresu URL.

## Przebieg pracy

1. Wybierz miejsce docelowe. Używaj `.context/excalidraw/<slug>/` do prac tymczasowych, a
   wskazanej ścieżki projektu do trwałych zasobów. Unikaj nadpisywania istniejących plików.
2. Przed wyczyszczeniem istniejącego obszaru roboczego lub importem z użyciem `--replace` zachowaj go za pomocą `snapshot save <name>` albo `export --out <file>`.
3. Wybierz jedno źródło kanoniczne. W przypadku wyniku Mermaid zachowaj `.mmd` jako źródło nadrzędne i
   sprawdź je w docelowym mechanizmie renderującym. W przypadku wyniku Excalidraw Mermaid służy jako szkielet
   importu; po bezpośrednich edycjach źródłem nadrzędnym jest `.excalidraw`.
4. Standardowe przepływy, sekwencje, stany i struktury relacji twórz za pomocą Mermaid; używaj bezpośrednich elementów
   do precyzyjnego rozmieszczania, przedstawiania anatomii komponentów, logo, stref i swobodnych objaśnień.
5. Utwórz cały pierwszy wariant jednym wywołaniem `mermaid`, `add` lub `apply`. Nadaj znaczące
   identyfikatory wszystkim elementom, które prawdopodobnie będą przenoszone lub zmieniane.
6. Po użyciu `mermaid` uruchom `describe` i przed eksportem lub bezpośrednią
   korektą upewnij się, że przekonwertowane elementy istnieją. Jeśli zrzut ekranu jest renderowany, ale opisana scena pozostaje pusta, zachowaj `.mmd`
   jako źródło kanoniczne albo odtwórz diagram za pomocą bezpośrednich elementów; nigdy nie przedstawiaj pustego pliku `.excalidraw` jako edytowalnego.
7. Uruchom `describe`, następnie `screenshot --out <check.png>` -> obejrzyj obraz -> popraw kolizje,
   przycięcia, słaby kontrast i krzyżujące się strzałki za pomocą jednej poprawki `apply`. Powtarzaj, aż wynik będzie poprawny.
8. Dla zsynchronizowanego obszaru roboczego wyeksportuj niepusty plik `.excalidraw` oraz PNG lub SVG. W przeciwnym razie
   wyeksportuj `.mmd` wraz z wyrenderowanym zasobem, zachowując Mermaid jako źródło nadrzędne. W przypadku
   zasobów projektu przechowuj edytowalne źródło obok renderu, chyba że użytkownik poprosi o pojedynczy plik wynikowy.
9. Podaj końcowe ścieżki, tryb diagramu, źródło kanoniczne, lokalizację opisu dostępności oraz
   wszystkie nadal wymagane ręczne edycje w przeglądarce.

## Polecenia

```bash
# Mermaid
bunx mcp-excalidraw-server@1.1.0 mermaid diagram.mmd

# Direct scene or atomic correction
bunx mcp-excalidraw-server@1.1.0 add elements.json
bunx mcp-excalidraw-server@1.1.0 apply patch.json

# Inspect and export
bunx mcp-excalidraw-server@1.1.0 describe
bunx mcp-excalidraw-server@1.1.0 screenshot --out check.png
bunx mcp-excalidraw-server@1.1.0 export --out diagram.excalidraw
bunx mcp-excalidraw-server@1.1.0 screenshot --format svg --out diagram.svg
```

## Bezpieczeństwo

- Traktuj `clear --yes`, `import --replace` i przywracanie migawki jako destrukcyjne operacje na obszarze
  roboczym; najpierw zachowaj bieżącą scenę.
- Używaj `share` tylko wtedy, gdy użytkownik poprosi o publiczny link Excalidraw, ponieważ powoduje to przesłanie
  sceny.
- W przypadku dokładnych logo używaj plików SVG lub importowanych zasobów marki; nie twórz przybliżonych wersji chronionych znaków.
- Po wyeksportowaniu plików zatrzymaj serwer lokalny za pomocą `stop`, jeśli nie przewidujesz dalszych edycji.
