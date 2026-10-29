---
description: >-
  Projektuj i przeglądaj kontrakty Protobuf: schematy .proto, Buf i generowanie
  kodu, ewolucję, Protovalidate/CEL, deskryptory i odbiorców środowiska.
  Konwencje zasobów Google należą do aip.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - protobuf
sidebar:
  label: /protobuf
title: /protobuf
type: skill
---
![Protobuf](/diagrams/skills/protobuf.svg)

[Excalidraw](/diagrams/skills/protobuf.excalidraw)

Traktuj schemat jako kontrakt serializacji, generowanego kodu, walidacji i odbiorców korzystających z deskryptorów, nie tylko jako transportowy DTO. Stosuj wyłącznie warstwy używane w repozytorium. Wczytanie umiejętności nie upoważnia do delegowania ani migracji.

## Zbadaj kontrakt [#inspect-the-contract]

1. Ustal bazę i HEAD przeglądu, uwzględniając zmiany robocze, jeśli tego zażądano. Obejmij usunięte i przemianowane schematy, importy, opcje niestandardowe, konfigurację generowania oraz wynik.
2. Ustal składnię lub edycję, kompilator i wtyczki, wersje środowisk, moduły i pliki blokad Buf, polecenia generowania, politykę zgodności, zapisane komunikaty i wdrożonych odbiorców. Oddziel zgodność binarną, ProtoJSON, kodu źródłowego i zachowania.
3. Przy zmianie schematu lub generowania przeczytaj [zgodność](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/compatibility.md). Prześledź deskryptory i komunikaty przez producentów, adaptery, magazyny oraz klientów. Generowany kod jest dowodem, nie celem ręcznych edycji.
4. Wczytaj wyłącznie potrzebne szczegóły:
   - Walidacja, wymagalność lub CEL: [walidacja](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/validation.md).
   - Środowiska TS/Python lub odbiorcy RPC: [środowiska](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/runtimes.md).
   - Refleksja, opcje niestandardowe, formularze lub powielane fakty o schemacie: [możliwości oparte na schemacie](https://github.com/malinskibeniamin/skills/blob/main/protobuf/references/schema-driven.md).
   - API przyjmujące konwencje zasobów Google: cały [aip](https://github.com/malinskibeniamin/skills/blob/main/aip/SKILL.md). Rozszerzenie `.proto` nie oznacza zastosowania wszystkich ogólnych AIP.
   - Przepływy React Connect Query: [connect-query](https://github.com/malinskibeniamin/skills/blob/main/connect-query/SKILL.md).

## Zweryfikuj zachowanie [#verify-behavior]

Używaj poleceń repozytorium i przypiętych narzędzi. Jeśli są skonfigurowane, uruchom formatowanie, budowanie i lint Buf, wykrywanie zmian niezgodnych względem rzeczywistej bazy przeglądu lub wdrożenia, generowanie kodu i kontrole odbiorców. Zachowaj katalogi modułów i kategorie reguł. Zgłaszaj osłabione kontrole i luki polityki zamiast po cichu ją zmieniać.

Przegląd pozostaje tylko do odczytu: w razie potrzeby generuj do tymczasowego katalogu lub migawki. Wskaż niedostępne narzędzia, brakujące bazy i niesprawdzone języki. Sam lint lub kontrola formatu binarnego nie dowodzi zgodności semantycznej ani walidacji podczas działania.

Dla zmienionego kontraktu szukaj kontrprzykładu na publicznym interfejsie: stare dane i nowy czytnik, nowe dane i stary czytnik, brak wartości wobec jawnej wartości domyślnej, nieprawidłowe żądanie docierające do serwera lub adapter edycji tracący informacje. Przy implementacji najpierw potwierdź niepowodzenie testu dla tego przykładu, potem napraw i odtwórz go przez rzeczywistego odbiorcę.

## Raportuj dwa odrębne wyniki [#report-two-distinct-results]

- **Usterki:** błędy wprowadzone przez różnice, ze wskazaniem odbiorcy lub scenariusza, dowodów, skutków, najmniejszej zgodnej poprawki i weryfikacji. Wpływają na werdykt.
- **Możliwości:** opcjonalne usprawnienia oparte na schemacie i rzeczywistym powielaniu lub istniejącym odbiorcy deskryptorów. Wskaż korzyść, koszt wdrożenia i najmniejszy eksperyment. Nie umieszczaj ich w komentarzach do usterek ani w blokujących uwagach. Brak Protovalidate, opcji niestandardowych, konwencji AIP czy nowszego środowiska sam w sobie nie jest błędem.

Zachowaj schemat usterek nadrzędnego przeglądu. W przeglądach z bramkami wpisuj możliwości doradcze do `simplification_opportunities`, nie do `findings` ani `testing_gaps`. Raportuj ograniczenia weryfikacji i ryzyko wdrożenia. Nie wymyślaj niezależnego przeglądu, równoważności między językami ani wyników zgodności.
