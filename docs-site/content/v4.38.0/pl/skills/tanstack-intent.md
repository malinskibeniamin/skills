---
title: /tanstack-intent
description: >-
  Używaj TanStack Intent, gdy pakiet TanStack jest wspomniany, przywołany lub
  używany. Przed udzieleniem odpowiedzi albo zmianą kodu Routera, Query, Table
  lub innego kodu TanStack wczytaj wskazówki zgodne z używaną wersją.
type: skill
sidebar:
  label: /tanstack-intent
---
![Diagram umiejętności /tanstack-intent](/diagrams/skills/tanstack-intent.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/tanstack-intent.excalidraw)

Przed udzieleniem odpowiedzi, planowaniem, przeglądem lub edycją zapytaj TanStack Intent, która dokumentacja zainstalowanych pakietów ma zastosowanie. Dotyczy to każdego przypadku, gdy pakiet TanStack jest wspomniany, przywołany lub używany, nawet jeśli zadanie nie wskazuje lokalnej umiejętności TanStack.

## Wczytaj wskazówki dotyczące pakietów

1. Zidentyfikuj wszystkie istotne pakiety `@tanstack/*` na podstawie żądania, importów i najbliższego pliku `package.json`. Użyj zainstalowanej zależności, a nie zapamiętanej wersji głównej.
2. W katalogu głównym pakietu znajdź dostarczane z nim umiejętności:

   ```bash
   bunx @tanstack/intent@latest list --json
   ```

3. Dopasuj każde zadanie do zwróconych pól `skills[].packageName`, `description` i `use`.
   Wczytaj każdy pasujący identyfikator `use` dokładnie w zwróconej postaci:

   ```bash
   bunx @tanstack/intent@latest load "$use_id"
   ```

4. Przed zastosowaniem umiejętności wczytaj wszystkie wskazane przez nią elementy `requires`. W przypadku kompozycji wczytaj wskazówki dla każdego zaangażowanego właściciela, na przykład Table wraz z Query albo Router wraz z Query.

Jeśli repozytorium nie używa Bun, skorzystaj z używanego w nim narzędzia do uruchamiania poleceń. Nie zgaduj identyfikatorów umiejętności ani nie wybieraj pakietu platformy o podobnej nazwie.

## Źródła rozstrzygające

- Zainstalowane, zgodne z wersją wskazówki Intent są rozstrzygające w kwestiach składni API TanStack, statusu wersji, kroków migracji i zachowania specyficznego dla platformy.
- Lokalne wskazówki `/tanstack-router` i `/tanstack-table` uzupełniają zasady repozytorium i deterministyczne kontrole dopiero po wczytaniu Intent.
- Jeśli lokalne wskazówki lub hook są sprzeczne z zainstalowaną umiejętnością Intent, uznaj to za wadę infrastruktury testowej. Postępuj zgodnie ze wskazówkami pakietu i napraw infrastrukturę zamiast obchodzić konflikt w kodzie.
- Jeśli pakiet nie jest zainstalowany lub nie udostępnia pasującej umiejętności, poinformuj, że Intent nie mógł dostarczyć wskazówek zgodnych z wersją, a następnie użyj `/read-the-damn-docs` z oficjalnymi źródłami TanStack. Nigdy nie uzupełniaj tej luki po cichu z pamięci.

Informacje o konfiguracji projektu znajdziesz w pliku [SETUP.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/tanstack-intent/SETUP.md). Dowody ukończenia powinny wskazywać wczytane wartości `package@version` i identyfikatory `use`.
