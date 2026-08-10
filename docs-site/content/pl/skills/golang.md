---
title: /golang
description: >-
  Stosuj oparte na dowodach reguły Go dotyczące ograniczeń, API, błędów,
  współbieżności, Temporal, testów, wdrażania i kontrolerów. Używaj podczas
  modyfikowania usług, procedur obsługi, przepływów pracy lub testów w Go.
type: skill
sidebar:
  label: /golang
---
![Diagram umiejętności /golang](/diagrams/skills/golang.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/golang.excalidraw)

Konwencje opracowane na podstawie dwóch lat przeglądów wielu repozytoriów: 102 reguły, każda
poparta co najmniej trzema niezależnymi przykładami. Ten plik zawiera podstawy; pliki domenowe
zawierają praktyczne wytyczne; anonimowe dane zbiorcze znajdują się w `/golang-review`
[katalogu reguł](https://github.com/malinskibeniamin/skills/blob/main/golang-review/RULES.md). `/aip` odpowiada za *projektowanie* zasobów proto; ta
umiejętność odpowiada za otaczającą je *implementację* w Go.

## Zasady bez wyjątków (ocena S)

- **Ograniczaj wszystko, co jest kontrolowane przez obciążenie lub dzierżawcę**: pamięć, kardynalność, rozgałęzienie, współbieżność i rozmiar odpowiedzi. Nieograniczone dane wejściowe prowadzą do wyczerpania pamięci i problemów z kardynalnością.
- **Przechodź przez proto za pomocą wygenerowanych getterów** — `a.GetB().GetC()`, nigdy za pomocą kaskad sprawdzających nil.
- **Adnotacje proto definiują kontrakty pól** (zachowanie, wymagalność, ograniczenia); nigdy nie powielaj walidacji w procedurach obsługi.
- **Używaj `optional` tylko dla semantycznej obecności**: jeśli zero jest prawidłową wartością, nie używaj `optional`; zamiar aktualizacji określa maska.
- **Kolekcje obsługuje `List`** — ze stronicowaniem i filtrowaniem; `Get` zwraca dokładnie jeden zasób.
- **Tłumacz błędy na granicy API**: zapisuj wewnętrzną przyczynę w logach, a zwracaj ustrukturyzowane błędy Connect/gRPC ze stabilnymi przyczynami i publicznymi ścieżkami pól. Po drodze zachowuj szczegółowość protokołu nadrzędnego (Kafka: dla każdej partycji i każdego elementu).
- **Predykaty bezpieczeństwa domyślnie odmawiają dostępu**: brak konfiguracji, błąd usługi licencji lub autoryzacji oraz niepełny stan zasad oznaczają odmowę — nigdy domyślne zezwolenie.
- **Sekrety są referencjami**: nigdy nie przyjmuj, nie przechowuj, nie zwracaj ani nie zapisuj w logach jawnej treści sekretów.
- **Ponawianie i opóźnienia muszą mieścić się w czasie życia operacji**: stosuj jitter, ograniczone maksimum i łączny horyzont mieszczący się w nadrzędnym limicie czasu.
- **Konfiguracja używa typów semantycznych**: wykorzystuj struktury konfiguracyjne repozytorium (`config.TLS`, czasy trwania, typy wyliczeniowe), nigdy samych ciągów znaków ani zestawów wartości logicznych.
- **Ryzykowne wdrożenia z mieszanymi wersjami zabezpieczaj flagami funkcji**; flagi są narzędziami migracji i należy je usunąć po ujednoliceniu całej floty.
- **Pliki serwera i inicjalizacji łączą elementy, a pakiety definiują zachowanie** — w `server.go` umieszczaj wyłącznie tworzenie i łączenie zależności.
- **Testy integracyjne przekraczają rzeczywistą granicę**; makiety nigdy nie potwierdzają zgodności z dostawcą, rozliczeniami ani serializacją.
- **Testy sprawdzają stabilne, obserwowalne zachowanie**, a nie wykonanie konkretnej ścieżki ani przypadkowe brzmienie komunikatów.

## Napięcia — decyduje kontekst, nie upraszczaj

- Dodatnie pola logiczne konfiguracji poprawiają czytelność — **z wyjątkiem** sytuacji, gdy wartość zerowa Go musi
  powodować odmowę na ścieżce bezpieczeństwa; wtedy ujemne pole `disabled` jest właściwe.
- Instrukcje switch dla typów wyliczeniowych zgłaszają błąd dla nieznanych wartości tylko wtedy, gdy deklarują obsługę całej domeny; celowy
  podzbiór dokumentuje i ignoruje pozostałe wartości.
- Utrzymywanie połączenia gRPC zależy od jego obsługi przez każdy element pośredniczący; nie istnieje ustawienie uniwersalne.
- Interfejsy zgodne z AIP używają ograniczonych ciągów filtrów; istniejące API z typowanymi filtrami
  zachowują kształt swoich obiektów ze względu na zgodność.
- Testy jednostkowe mogą swobodnie imitować zależności; gdy tylko test deklaruje zgodność na granicy,
  musi używać rzeczywistego protokołu, roli, dostawcy lub kontenera.

## Pliki domenowe

| Obszar pracy | Przeczytaj |
|---|---|
| Proto, procedury obsługi, interfejs Connect/gRPC, błędy publiczne | [PROTO-API.md](https://github.com/malinskibeniamin/skills/blob/main/golang/PROTO-API.md) |
| Goroutines, kanały, pamięci podręczne, zamykanie, stan współdzielony | [CONCURRENCY.md](https://github.com/malinskibeniamin/skills/blob/main/golang/CONCURRENCY.md) |
| Opakowywanie i klasyfikacja błędów, logowanie, metryki | [ERRORS.md](https://github.com/malinskibeniamin/skills/blob/main/golang/ERRORS.md) |
| Dowolny plik `_test.go`, dane testowe, zachowanie CI | [TESTING.md](https://github.com/malinskibeniamin/skills/blob/main/golang/TESTING.md) |
| Przepływy pracy Temporal, aktywności, sygnały | [TEMPORAL.md](https://github.com/malinskibeniamin/skills/blob/main/golang/TEMPORAL.md) |
| Dane wejściowe dzierżawcy, ruch wychodzący, autoryzacja, sekrety, operacje destrukcyjne | [SECURITY.md](https://github.com/malinskibeniamin/skills/blob/main/golang/SECURITY.md) |
| Interfejsy konfiguracji, flagi, wycofywanie, usuwanie schematów i pól | [ROLLOUT.md](https://github.com/malinskibeniamin/skills/blob/main/golang/ROLLOUT.md) |
| Granice pakietów, warstwy pamięci masowej, interfejsy | [STRUCTURE.md](https://github.com/malinskibeniamin/skills/blob/main/golang/STRUCTURE.md) |
| Operatory i mechanizmy uzgadniania Kubernetes | [CONTROLLERS.md](https://github.com/malinskibeniamin/skills/blob/main/golang/CONTROLLERS.md) |

## Hooki

Przy edycji uruchamiane są dwie kontrole mechaniczne; obie ostrzegają, ale nigdy nie blokują:

- `go-proto-reserved`: usunięcie opublikowanego pola proto wymaga dodania `reserved N;` oraz
  `reserved "name";`; zmiana numeracji nigdy nie jest bezpieczna. Wyjątek: `// allow: proto-unshipped [reason]`.
- `go-test-image-pin`: obrazy testowe i kontenerowe muszą wskazywać obsługiwany znacznik wydania, nigdy
  `:latest`/`:main`/`:master`. Wyjątek: `// allow: floating-image [reason]`.

Przeglądasz diff zamiast pisać kod? Do tego służy `/golang-review`.
