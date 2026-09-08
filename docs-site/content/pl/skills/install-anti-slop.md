---
title: "/install-anti-slop"
description: "Instaluj wybrane kontrole anti-slop w repozytoriach TypeScript lub JavaScript korzystających z Oxlint albo Biome, w tym Ultracite z backendem Biome. Używaj, gdy trzeba dodać anti-slop, zapobiec zacieraniu dowodów typów lub zaktualizować istniejący lokalny profil anti-slop."
type: skill
sidebar:
  label: "/install-anti-slop"
---
![Diagram umiejętności /install-anti-slop](/diagrams/skills/install-anti-slop.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/install-anti-slop.excalidraw)

Dodaj profil za pomocą lintera już używanego w repozytorium. Zachowaj menedżer pakietów,
właściciela lintingu, styl konfiguracji i niepowiązane zmiany. Nigdy nie wprowadzaj drugiego
lintera wyłącznie na potrzeby anti-slop.

## Wybór profilu

1. Przeczytaj instrukcje repozytorium i sprawdź `git status`. Zbadaj bezpośrednie zależności,
   plik blokady oraz istniejącą konfigurację Biome, Ultracite, Oxlint lub Vite+.
2. Wybierz dokładnie jeden używany backend:
   - **Oxlint:** zainstaluj wybrany profil trzech reguł semantycznych.
   - **Biome lub Ultracite z Biome:** zainstaluj profil dwóch reguł strukturalnych. Wtyczki
     [GritQL](https://biomejs.dev/linter/plugins/) w Biome nie udostępniają analizy symboli
     ani zakresów, dlatego profil celowo pomija `no-widen-then-assert`; kontrola aliasów
     unknown obejmuje bezpośrednie `unknown` i bezpośrednie elementy unii, ale nie łańcuchy aliasów.
3. Jeśli repozytorium nie używa żadnego obsługiwanego lintera, pozostaw je bez zmian i wyjaśnij przyczynę.

## Oxlint

1. Odczytaj z menedżera pakietów lub pliku blokady zainstalowaną wersję `oxlint`. Dodaj
   `@oxlint/plugins` w dokładnie tej samej wersji jako zależność deweloperską.
2. Skopiuj do repozytorium dołączoną wtyczkę:

   ```bash
   node <skill-directory>/scripts/install.mjs
   ```

   Domyślna ścieżka docelowa to `tools/oxlint/anti-slop/`.
3. Połącz wtyczkę z istniejącą konfiguracją, nie zastępując innych wpisów:

   ```ts
   {
     ignorePatterns: ["tools/oxlint/anti-slop/**"],
     jsPlugins: [
       { name: "anti-slop", specifier: "./tools/oxlint/anti-slop/index.ts" },
     ],
     rules: {
       "anti-slop/no-chained-type-assertions": "error",
       "anti-slop/no-unknown-type-aliases": "error",
       "anti-slop/no-widen-then-assert": "error",
     },
   }
   ```

   W Vite+ połącz te same wpisy w sekcji `lint` i dodaj ścieżkę dostarczonych plików do
   `fmt.ignorePatterns`.

## Biome

1. Wymagaj Biome w wersji 2.5.9 lub nowszej. Konfiguracja Ultracite rozszerzająca
   `ultracite/biome/*` spełnia ten warunek.
2. Skopiuj wtyczki GritQL:

   ```bash
   node <skill-directory>/scripts/install.mjs --biome
   ```

   Domyślna ścieżka docelowa to `tools/biome/anti-slop/`.
3. Dodaj obie ścieżki do istniejącej tablicy `plugins`:

   ```json
   {
     "plugins": [
       {
         "path": "./tools/biome/anti-slop/no-chained-type-assertions.grit",
         "includes": ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"]
       },
       {
         "path": "./tools/biome/anti-slop/no-direct-unknown-type-aliases.grit",
         "includes": ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"]
       }
     ]
   }
   ```

## Zakończenie

Instalator odrzuca wyjścia poza dozwoloną ścieżkę i istniejące miejsca docelowe. W razie potrzeby
podaj inną ścieżkę względną wobec repozytorium. Użyj `--force` dopiero po utworzeniu kopii
zapasowej i sprawdzeniu istniejącej instalacji anti-slop.

Uruchom polecenia lintingu i sprawdzania typów używane w repozytorium. Traktuj żądanie instalacji
jako zakres migracji i napraw wynikające z niej problemy we własnym kodzie, chyba że użytkownik
wyraźnie zażądał tylko konfiguracji. Nigdy nie osłabiaj kontroli ani nie dodawaj wyciszeń tylko po to,
aby testy przeszły. Zgłoś profil, skopiowaną ścieżkę, zmiany zależności i konfiguracji, wyniki
weryfikacji oraz nierozwiązane problemy.

## Własność

Rdzeń Oxlint jest lokalnym forkiem
[`dmmulroy/anti-slop` v0.1.2](https://github.com/dmmulroy/anti-slop/tree/e8c4880471b23ab7f216fba7b27d173a6ef07d4c).
Skopiowany plik `LICENSE` zachowuje licencję MIT projektu źródłowego. Profil Biome GritQL jest
adaptacją strukturalną o węższym kontrakcie opisanym powyżej. Traktuj zainstalowane pliki jako
własność projektu i przejrzyj zmiany źródłowe lub Biome przed ich przeniesieniem.
