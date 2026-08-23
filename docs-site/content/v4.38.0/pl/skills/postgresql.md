---
title: /postgresql
description: >-
  Projektuj PostgreSQL na podstawie danych z obciążenia. Używaj do pull
  requestów SQL, schematów, indeksów, transakcji, migracji, wydajności,
  bezpieczeństwa/RLS, kopii zapasowych/PITR, raportów oraz generowanego kodu
  Drizzle lub Jet SQL.
type: skill
sidebar:
  label: /postgresql
---
![Diagram umiejętności /postgresql](/diagrams/skills/postgresql.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/postgresql.excalidraw)

Traktuj „najlepszy SQL” jako rozwiązanie dopasowane na podstawie pomiarów do konkretnego obciążenia, wersji, dostawcy i założeń dotyczących odtwarzania. Surowa semantyka PostgreSQL i faktycznie generowany SQL mają pierwszeństwo przed ORM, konstruktorem zapytań, abstrakcją dostawcy lub deklaracjami producenta.

## Przepływ pracy

1. **Wybierz tryb:** tworzenie/przegląd SQL; modelowanie schematu/indeksów; koordynowanie
   transakcji/kolejek; migracja; diagnostyka/optymalizacja; obsługa/odtwarzanie; bezpieczeństwo/wielodostępność;
   raportowanie; lub integracja z Jet.
2. **Ustal założenia:** wersja główna/pomocnicza PostgreSQL i dostawca/odmiana;
   rozszerzenia/topologia/pooler; charakterystyka obciążenia; ilość/rozkład/wzrost danych;
   współbieżność; SLO opóźnień/przepustowości; RPO/RTO; bezpieczeństwo; okno zmian.
   Oznacz niewiadome. Nigdy nie zmyślaj faktów dotyczących środowiska produkcyjnego.
3. **Zbierz dane źródłowe:** rzeczywisty SQL i postać parametrów, granice
   transakcji, stan schematu/katalogu, reprezentatywne dane, plan/statystyki, oczekiwania,
   blokady, telemetrię zasobów oraz istotną historię wdrożeń/konfiguracji.
4. **Zaproponuj najmniejszą odwracalną zmianę:** przedstaw dane, hipotezę,
   oczekiwany efekt, koszt zapisu/pamięci/blokad/WAL, ścieżki błędów, zastrzeżenia
   dotyczące wersji/dostawcy, wycofanie lub poprawkę naprzód, kryteria przerwania i weryfikację.
5. **Kontroluj skutki na żywo:** diagnostyka produkcji jest domyślnie tylko do odczytu, ograniczona zakresem i
   czasem. Uzyskaj wyraźną zgodę przed zapisem, DDL,
   anulowaniem, zmianami ról/polityk/konfiguracji, przełączeniem awaryjnym, odtwarzaniem lub destrukcyjnymi
   poleceniami. Ponownie potwierdź cel.
6. **Wykonaj jedną mierzalną zmianę:** zachowaj dokładny SQL i granice
   transakcji. Obserwuj wdrożenie; zatrzymaj je po spełnieniu kryteriów przerwania.
7. **Zakończ na podstawie danych:** zweryfikuj wyniki po stronie bazy danych i użytkowników, zapisz
   okno przed/po zmianie, sprawdź odtwarzanie i wskaż pozostałe niewiadome.

## Nawigacja

| Zadanie | Przeczytaj |
|---|---|
| Przegląd pull requestu SQL lub różnic w bazie danych | [SQL-PR-REVIEW.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SQL-PR-REVIEW.md) oraz wszystkie odwołania do domen objętych różnicami |
| Semantyka zapytań, złączenia, stronicowanie, DML | [SQL-AUTHORING.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SQL-AUTHORING.md) |
| Typy, ograniczenia, indeksy, partycjonowanie | [SCHEMA-INDEXES.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SCHEMA-INDEXES.md) |
| Izolacja, ponowienia, blokady, kolejki, limity | [TRANSACTIONS-ORCHESTRATION.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/TRANSACTIONS-ORCHESTRATION.md) |
| DDL online, uzupełnianie danych, generowane migracje | [MIGRATIONS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/MIGRATIONS.md) |
| Plany, statystyki, testy wydajności, regresje | [PERFORMANCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/PERFORMANCE.md) |
| Pooling, vacuum, WAL, replikacja, HA, PITR | [OPERATIONS-RECOVERY.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/OPERATIONS-RECOVERY.md) |
| Role, RLS, izolacja dzierżawców, kopie danych wrażliwych | [SECURITY-TENANCY.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SECURITY-TENANCY.md) |
| Podsumowanie operacyjne lub raport o stanie bazy danych | [WEEKLY-REPORT.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/WEEKLY-REPORT.md) |
| Obsługiwane funkcje, ograniczenia dostawców zarządzanych usług | [VERSIONS-PROVIDERS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/VERSIONS-PROVIDERS.md) |
| SQL lub migracje generowane przez Drizzle | [SQL-AUTHORING.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/SQL-AUTHORING.md), [MIGRATIONS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/MIGRATIONS.md) oraz [VERSIONS-PROVIDERS.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/VERSIONS-PROVIDERS.md) |
| Kod Go korzystający z `go-jet/jet` | [GO-JET.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/GO-JET.md) |
| Siła dowodów lub aktualizacja korpusu | [EVIDENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/postgresql/references/EVIDENCE.md) |

Traktuj PostgreSQL 19 jako wersję zapoznawczą. Przed użyciem zachowań zależnych od
wersji, rozszerzenia, dostawcy, Drizzle lub Jet ponownie sprawdź aktualną dokumentację.

## Wymagany format wyniku

Zwróć: **kontekst -> dane -> rekomendacja -> dokładny SQL/kod -> wpływ i
ryzyka -> wdrożenie/bramka zatwierdzenia -> wycofanie/poprawka naprzód -> weryfikacja**. W przypadku
przeglądu zgłoś ustalenia dotyczące poprawności i bezpieczeństwa przed uwagami o stylu. Jeśli brakuje danych
ze środowiska produkcyjnego, podaj ograniczone zapytania do ich zebrania i zakończ na hipotezie.
