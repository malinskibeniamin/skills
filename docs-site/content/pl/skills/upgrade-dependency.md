---
title: /upgrade-dependency
description: >-
  Uaktualnij zależność i dostosuj wszystkie miejsca jej użycia. Używaj przy
  aktualizacjach pakietów lub modułów, usuwaniu luk w zabezpieczeniach, zmianach
  niezgodnych wstecznie, codemodach i wdrażaniu nowych interfejsów API.
type: skill
sidebar:
  label: /upgrade-dependency
---
![Diagram umiejętności /upgrade-dependency](/diagrams/skills/upgrade-dependency.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/upgrade-dependency.excalidraw)


Przejdź do żądanej stabilnej wersji; jeśli jej nie podano, użyj najnowszej stabilnej. Przestrzegaj żądanego punktu końcowego: `plan` działa tylko do odczytu; budowanie lub naprawianie respektuje zamiar pracy lokalnej, utworzenia commitu lub wypchnięcia zmian; PR tylko na żądanie. [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/upgrade-dependency/REFERENCE.md) zawiera kontrole łańcucha dostaw i szablony publikacji. `$ARGUMENTS`: pakiet/moduł, manifest, wersja, opis w języku naturalnym lub `plan`.

## Przebieg [#flow]

1. **Zakres:** wykryj manifesty/pliki blokad/obszary robocze. Zmapuj drzewo zależności: zależności bezpośrednie/przechodnie, nadrzędne/zależne, równorzędne/wtyczki/adaptery/ekosystem. Używaj `/quantify-impact` tylko w celu uzyskania bezpośredniej miary.
2. **Badanie:** opracuj ścieżkę aktualizacji obejmującą każdą opublikowaną stabilną wersję wraz z uwagami do poszczególnych wersji. Czytaj ogłoszenia wersji głównych, informacje o wydaniu, przewodniki migracji, codemody i `/read-the-damn-docs`; pobieżnie sprawdzaj uwagi do wersji pobocznych i poprawek. Nie instaluj każdej wersji; zainstaluj wersję docelową jeden raz. Zbierz zmiany interfejsu API, składni, stylu i zachowania. Sklasyfikuj wersję według SemVer jako główną/poboczną/poprawkę; przy braku SemVer lub dziennika zmian oceń zakres zmian, częstotliwość wydań, rozmiar różnic, nakład pracy/zagrożenia/zasięg wpływu. Sprawdź komunikaty bezpieczeństwa: GHSA/OSV/Socket/Snyk.
3. **Brama decyzyjna:** pewną poprawkę/wersję poboczną można zastosować. Udokumentowaną wersję główną stosuj po jednym przeskoku wersji głównej naraz. Niejasności, wysokie ryzyko lub niepewność dotycząca bezpieczeństwa wymagają zatrzymania, przedstawienia dowodów i wskazania decyzji. Plan obejmuje tylko raportowanie. Przetwarzaj sekwencyjnie; użycie subagentów/swarm lub przypisanie jednego pakietu na agenta wymaga jawnego delegowania.
4. **Łańcuch dostaw:** minimalny wiek wydania 7–30 dni; wyłącz skrypty/przejrzyj `trustedDependencies`; odrzuć zależności git, git+, tarball, surowy URL; użyj Socket/npq; przejrzyj plik blokady; wykonaj czystą instalację/sprawdzenie bez zmian pliku blokady.
5. **Zastosowanie:** zachowaj zweryfikowane commity, chyba że użytkownik zażądał wcześniejszego zatrzymania.
   - **Aktualizacja wersji:** `bun update <pkg>@<v>` -> `bun install` -> `bun install --yarn`, jeśli jest to wymagane. Go: `go get -u <module>@<v>` -> `go mod tidy`. Nigdy nie edytuj ręcznie plików blokad.
   - **Migracja:** oficjalne codemody; dostosuj każde objęte zmianą miejsce użycia. Ostrzeżenia o wycofaniu są naprawiane TERAZ, a nie wyciszane.
   - **Korzyść:** wdrażaj sprawdzone interfejsy API upraszczające kod; usuwaj obejścia/polyfille; nigdy nie rozbudowuj kodu spekulacyjnie.
   - **Budżet zmian manifestu:** nie dodawaj zależności bezpośrednich, nie edytuj głównego manifestu ani nie dodawaj nadpisań/rozwiązań/łatek, chyba że bez nich aktualizacja się nie powiedzie; uzasadnij każdą taką zmianę w PR. Usuń istniejące elementy, które aktualizacja czyni zbędnymi. Przed utworzeniem commitu przejrzyj różnice w manifestach.
   - **Weryfikacja:** `bun run lint:fix`, `bun run type:check`, `bun test`; Go: `go build ./...`, `go test ./...`, `go vet ./...`. Aktualizuj powiązane pakiety razem.
6. **Bezpieczeństwo:** wykaż możliwość wykorzystania luki/osiągalność; zależność bezpośrednia -> zależność nadrzędna -> nadpisanie/rozwiązanie/zastąpienie. Nigdy nie uruchamiaj kodu z komunikatów bezpieczeństwa. Zapisz identyfikatory i wersje zawierające poprawki; `/snyk-ux-security` odpowiada za analizę osiągalności.
7. **Dostarczenie:** jeden PR zawiera aktualizację wersji, migrację, korzyść oraz zapis wyników weryfikacji. Zablokowana brama ryzyka powoduje utworzenie zgłoszenia tylko na żądanie.

Dowody umieszczaj na czacie lub w żądanym PR; lokalny plik Markdown twórz tylko na żądanie. Przed wprowadzeniem zmian podaj ścieżkę aktualizacji. Ukończenie oznacza dostosowanie każdego objętego zmianą miejsca użycia.

## Doktryna migracji [#migration-doctrine]

Na zakończenie zablokuj stary wzorzec za pomocą linta/hooka. Migracja jednorazowa dla routerów/warstw frameworka; migracja dusząca dla warstw danych z budżetem na współistnienie. PR-y migracyjne zachowują zgodność 1:1 i dostosowują testy w TYM SAMYM PR; refaktoryzacje strukturalne rejestruj jako zgłoszenia. Usuń martwe style, warstwy zgodności i jednorazowe rozwiązania.
