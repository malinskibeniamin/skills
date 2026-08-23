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

Przejdź do żądanej stabilnej wersji; jeśli jej nie podano, użyj najnowszej stabilnej. Dostosuj wywołania.
Przestrzegaj żądanego punktu końcowego: `plan` działa tylko do odczytu; budowanie lub naprawianie obejmuje weryfikację,
utworzenie commitu i wypchnięcie zmian, chyba że użytkownik zażąda pracy lokalnej, bez commitu lub bez wypychania. PR tylko na żądanie.
Gdy odpowiednie gałęzie zostaną uruchomione, przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/upgrade-dependency/REFERENCE.md), aby poznać kontrole łańcucha dostaw oraz szablony zgłoszeń i PR.

Dane wejściowe: `$ARGUMENTS` = pakiet/moduł, ścieżka manifestu, wersja docelowa, opis w języku naturalnym lub `plan`.
## Przebieg

1. **Zakres**: wykryj manifesty/pliki blokad (`package.json`, `bun.lock`, `go.mod`) oraz obszary robocze. Zmapuj drzewo zależności: zależności bezpośrednie/przechodnie, nadrzędne/zależne, równorzędne/wtyczki/adaptery. Uruchom `/quantify-impact`, aby uzyskać bezpośrednią miarę.

2. **Zbadaj, co zmienia zachowanie**: opracuj ścieżkę aktualizacji: każda opublikowana stabilna wersja od zainstalowanej do docelowej wraz z uwagami o zmianach zachowania w poszczególnych wersjach; czytaj szczegółowo tylko przy przeskokach między wersjami głównymi lub zmianach niezgodnych wstecznie (przewodniki migracji, codemody, ogłoszenia, `/read-the-damn-docs`); pobieżnie sprawdzaj wersje poboczne, pomijaj analizę historii poprawek; zainstaluj wersję docelową jeden raz, a nie na każdym etapie. Sklasyfikuj SemVer; przy braku SemVer lub dziennika zmian oceń zakres zmian, częstotliwość wydań, rozmiar różnic i zasięg wpływu. Sprawdź komunikaty bezpieczeństwa (Snyk/GHSA/OSV/Socket/CVE).

3. **Brama decyzyjna**: pewna poprawka/wersja poboczna -> zastosuj. Udokumentowana wersja główna -> stosuj po jednym przeskoku wersji głównej naraz. Brak SemVer, niejasna migracja, duży zasięg wpływu lub niepewność dotycząca bezpieczeństwa -> zatrzymaj się, przedstaw dowody i wskaż wymaganą decyzję. `plan` -> przedstaw na czacie ścieżkę i ryzyko. Przetwarzaj pakiety sekwencyjnie; jawne delegowanie lub `/swarm` może przypisać niezależne zakresy prac.

4. **Zastosowanie** -- kontrola wstępna: minimalny wiek wydania 7–30 dni, wyłączenie skryptów / przegląd `trustedDependencies`, brak zależności git/tarball/surowy URL, Socket/npq, jeśli są dostępne, przegląd pliku blokady, czysta instalacja. Zachowaj oddzielne zweryfikowane commity, chyba że użytkownik zażądał wcześniejszego zatrzymania:
   a. **Aktualizacja wersji**: `bun update <pkg>@<v>` -> `bun install` -> `bun install --yarn`, gdy wymaga tego `yarn.lock`/Snyk. Go: `go get -u <module>@<v>` -> `go mod tidy`. Nigdy nie edytuj ręcznie plików blokad.
   b. **Migracja**: oficjalne codemody; ujednolić zmiany interfejsu API/składni/stylu/zachowania we wszystkich objętych nimi miejscach użycia. Ostrzeżenia o wycofaniu związane z tą aktualizacją są naprawiane TERAZ, a nie wyciszane.
   c. **Korzyść**: wdrażaj interfejsy API wyróżnione w dzienniku zmian, jeśli upraszczają istniejący kod -- usuń wymuszone obejścia i przestarzałe polyfille; zmniejszaj lub wzmacniaj kod, nigdy nie rozbudowuj go spekulacyjnie.
   d. **Weryfikacja**: `bun run lint:fix` -> `bun run type:check` -> `bun test`. Go: `go build ./...` -> `go test ./...` -> `go vet ./...`. Aktualizuj powiązane pakiety razem.

5. **Bezpieczeństwo**: zachowaj uzasadnienie możliwości wykorzystania luki; kolejność działań naprawczych: aktualizacja zależności bezpośredniej > aktualizacja zależności nadrzędnej > nadpisanie/rozwiązanie/zastąpienie. Nigdy nie uruchamiaj kodu z komunikatów bezpieczeństwa. Identyfikatory komunikatów + wersje zawierające poprawki umieść w opisie PR. `/snyk-ux-security` odpowiada za analizę osiągalności.

6. **Wymagany sposób dostarczenia**: jeden PR zawiera aktualizację wersji + migrację + korzyść oraz zapis wyników weryfikacji.
   Zablokowana brama ryzyka powoduje utworzenie zgłoszenia tylko na żądanie.

## Reguły

Dowody umieszczaj na czacie lub w żądanym PR; lokalny plik Markdown twórz tylko na żądanie. Przed wprowadzeniem zmian podaj
ścieżkę aktualizacji. Przeczytaj dziennik zmian + informacje o wydaniu dla zmian głównych/niezgodnych z SemVer. Ukończenie
oznacza dostosowanie każdego objętego zmianą miejsca użycia. JS i Go są traktowane równorzędnie.

## Doktryna migracji

Ukończenie = zamrożenie: kończący PR zakazuje starego importu/wzorca (lint/hook), w przeciwnym razie autorzy LLM go przywrócą. Migracja jednorazowa dla routerów/warstw frameworka; migracja dusząca dla warstw danych (stare+nowe współistnieją -- uwzględnij to w budżecie). PR-y migracyjne służą migracji: zgodność 1:1, testy dostosowane w TYM SAMYM PR, refaktoryzacje strukturalne rejestrowane jako zgłoszenia. Przy zakończeniu usuń martwą warstwę (starsze style, warstwy zgodności, jednorazowe rozwiązania).
