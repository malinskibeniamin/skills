---
title: "/effect-v3-to-v4"
description: "Migracja kodu z Effect v3 do v4 na podstawie materiałów migracyjnych upstream."
type: skill
sidebar:
  label: "/effect-v3-to-v4"
---
![Diagram umiejętności /effect-v3-to-v4](/diagrams/skills/effect-v3-to-v4.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/effect-v3-to-v4.excalidraw)

Ustal zmiany nazw, usunięcia i zmiany sygnatur na podstawie danych migracyjnych upstream, a nie domyślanych zamienników.

## Przebieg pracy

1. Przygotuj i sprawdź lokalne kopie repozytoriów opisane poniżej.
2. Przeczytaj raz `.repos/effect/MIGRATION.md` i wyświetl zawartość `.repos/effect/migration/`.
3. Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/effect-v3-to-v4/REFERENCE.md), a następnie przed pierwszym sprawdzaniem typów zmigruj `package.json`: usuń scalone pakiety i wyrównaj pozostałe wersje.
4. Uruchom sprawdzanie typów projektu, aby sporządzić początkowy wykaz błędów.
5. Rozwiąż każdy błąd według poniższej kolejności czytania, popraw miejsca wywołań i powtarzaj do uzyskania czystego wyniku. Pracuj w głównej sesji, chyba że użytkownik wyraźnie zażąda delegowania.
6. Uruchom testy projektu i bramki jakości; zgłoś wyniki i nierozwiązane braki. Przestrzegaj żądanego punktu końcowego i kontraktu ukończenia repozytorium.

## Lokalne kopie repozytoriów

Użyj dwóch niezależnych płytkich klonów kanonicznego repozytorium Effect:

```sh
git clone --depth 1 --single-branch --branch main https://github.com/Effect-TS/effect .repos/effect
git clone --depth 1 --single-branch --branch v3 https://github.com/Effect-TS/effect .repos/effect-v3
```

- `.repos/effect`: przewodniki migracji v4 i kod źródłowy.
- `.repos/effect-v3`: źródła v3, wyłącznie do wyjaśnienia wcześniejszej semantyki.

Przed ponownym użyciem któregokolwiek katalogu sprawdź jego origin, gałąź, wersję i stan drzewa roboczego. Kopia v4 musi zawierać `MIGRATION.md` i `migration/v3-to-v4.md`:

```sh
git -C .repos/effect remote get-url origin
git -C .repos/effect branch --show-current
git -C .repos/effect status --short
node -p "require('./.repos/effect/packages/effect/package.json').version"
```

Powtórz te sprawdzenia dla `.repos/effect-v3` (gałąź `v3`, wersja `3.x`). Dla v4 wymagaj kanonicznego origin `Effect-TS/effect`, gałęzi `main` i wersji `4.x`. Stara kopia `Effect-TS/effect-smol` nie jest prawidłowym źródłem migracji. Zachowaj istniejące katalogi i zmiany użytkownika; zgłoś niezgodność i wybierz osobny, nieużywany katalog klonowania, aktualizując ścieżki wyszukiwania. Nie usuwaj ani nie resetuj istniejących katalogów.

## Kolejność czytania

1. `.repos/effect/MIGRATION.md`: kontekst migracji i indeks tematów, jeden raz.
2. `.repos/effect/migration/v3-to-v4.md`: pierwszy przystanek dla każdego API. Wyszukuj odpowiednie symbole lub nagłówki modułów i czytaj tylko ograniczony otaczający kontekst. **Nigdy nie czytaj całego wygenerowanego materiału referencyjnego.**
3. `.repos/effect/migration/*.md`: wczytaj przewodnik tematyczny, gdy mapowanie wymaga zmiany strukturalnej, a nie tylko zmiany nazwy.
4. `.repos/effect/packages/*/src/`, w tym `unstable/`: przed użyciem potwierdź rzeczywistą sygnaturę zamiennika.
5. `.repos/effect-v3`: wyłącznie w razie niejasnej wcześniejszej semantyki.

[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/effect-v3-to-v4/REFERENCE.md) zawiera przykłady wyszukiwania i zmiany na poziomie pakietów. Sprawdź Removed Modules i No Counterpart Imports, zanim uznasz mapowanie za brakujące. Zgłaszaj nieopisane braki zamiast wymyślać API.

## Zabezpieczenia

- Migruj miejsca wywołań do v4; nie przywracaj warstwy zgodności naśladującej v3.
- Rozwiązuj błędy typów na podstawie materiałów referencyjnych i źródeł, nie za pomocą `any`, rzutowań ani wyciszania sprawdzania typów.
- Każdy zamiennik musi wynikać z mapowania, przewodnika tematycznego lub źródeł v4.
- Przy wyraźnie zatwierdzonym delegowaniu przydziel każdemu agentowi rozłączne pliki, symbole do rozwiązania, kolejność czytania i te zabezpieczenia. Wymagaj zwrotu zmian i mapowań; zachowaj centralny wykaz błędów. Zagnieżdżone delegowanie wymaga osobnej zgody.

## Warunek ukończenia

Projekt przechodzi sprawdzanie typów dla v4 i wymagane bramki repozytorium. Zgłoś wyniki sprawdzania typów i testów (lub powód, dla którego nie można było uruchomić sprawdzenia), skonstruowane zamienniki i brakujące mapowania. Nie osłabiaj testów i nie ogłaszaj ukończenia, gdy wymagana weryfikacja jest zablokowana.
