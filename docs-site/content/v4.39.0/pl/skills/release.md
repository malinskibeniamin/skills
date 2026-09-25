---
title: /release
description: >-
  Opublikuj niezmienne wydanie frontend-skills obejmujące manifesty, PR, tag,
  GitHub, Claude i Codex.
type: skill
sidebar:
  label: /release
---
![Diagram umiejętności /release](/diagrams/skills/release.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/release.excalidraw)

Opublikuj to repozytorium, nie dopuszczając do rozbieżności metadanych, tagów ani pamięci podręcznych środowiska uruchomieniowego. Argument wersji musi wskazywać dokładną, stabilną wersję SemVer, taką jak `4.34.0`.

## 1. Ustal punkt wydania

1. Pobierz `origin/main`; wymagaj czystego drzewa roboczego na gałęzi funkcjonalnej opartej na najnowszej gałęzi main.
2. Przejrzyj commity i scalone PR-y od najnowszego tagu `v*`. Określ zakres wydania na podstawie dowodów.
3. Wymagaj poprawnego CI dla `origin/main`; odtwórz i napraw każdą awarię przed rozpoczęciem prac nad wersją.
4. Potwierdź, że lokalny tag, zdalny tag i wydanie GitHub nie istnieją. Każda kolizja zatrzymuje proces.
5. Potwierdź, że żądanie obejmuje uprawnienia do scalenia i publikacji. Jawne polecenie
   `/release <version>` lub „utwórz/opublikuj <version>” je zapewnia; planowanie lub omawianie wydania — nie.

## 2. Przygotuj podejście test-first

1. Najpierw zmień wersję docelową w `evals/test-improve-release-metadata.sh`.
2. Uruchom skrypt i zapisz oczekiwane błędy RED dotyczące metadanych wydania.
3. Zaktualizuj razem `skill-manifest.json`, oba manifesty wtyczek, oba marketplace’y, ich datowane
   wpisy dziennika zmian, `CHANGELOG.md` oraz przypiętą wersję instalacyjną w README.
4. Jeśli powierzchnia umiejętności uległa zmianie, uruchom generatory hooków, katalogu i plików AGENTS. Nigdy nie edytuj ręcznie
   wygenerowanych proxy Codex.
5. Zamroź dokumentację wydania poleceniem `bun run docs:version v<version>`. Zacommituj wygenerowaną
   migawkę i jej nowy wpis `versions.archived`; nigdy nie edytuj istniejącej migawki.
6. Ponownie uruchom ukierunkowane testy ewaluacyjne metadanych wydania i pakowania, aż osiągną stan GREEN.

## 3. Zweryfikuj pakiet

Uruchom bramkę jakości repozytorium, testy pakietu, pełny zestaw testów ewaluacyjnych powłoki, testy behawioralne hooków,
kontrole rozbieżności generatorów, analizę JSON oraz `git diff --check`. Wymagaj obu rzeczywistych, izolowanych instalatorów CLI:

```bash
bash scripts/test-claude-plugin-install.sh
bash scripts/test-codex-plugin-install.sh
```

Uruchom `/dogfood` dla obu spakowanych powierzchni umiejętności. Pomiń przegląd wizualny, jeśli diff
nie obejmuje renderowanej powierzchni widocznej dla użytkownika. Przejrzyj ustabilizowany diff pod kątem standardów, wartości, odporności,
pakowania i zagrożeń dla niezmienności wydania.

## 4. Scal przed utworzeniem tagu

1. Utwórz commit, wypchnij zmiany i otwórz PR wydania za pomocą `/go`; dołącz potwierdzenie dogfoodingu i wyniki liczbowe.
2. Monitoruj wszystkie wymagane kontrole PR i rozwiąż każdy istniejący wątek przeglądu.
3. Scalaj wyłącznie na podstawie uprawnienia do scalenia ustalonego w kroku 1.
4. Pobierz main i poczekaj na poprawne CI gałęzi main dla commitu scalającego.
5. Utwórz i wypchnij opisany tag `v<version>` wskazujący ten commit scalający, nigdy commit gałęzi funkcjonalnej.

## 5. Opublikuj i sprawdź ponownie

1. Uruchom `gh release create v<version> --verify-tag --latest` z odpowiednio zawężonymi informacjami o wydaniu i linkiem do porównania.
2. Sprawdź, czy zdalny tag wskazuje commit scalający, jego drzewo jest zgodne z wydaną gałęzią main, a
   najnowsze wydanie repozytorium ma nowy tag.
3. W świeżej, izolowanej konfiguracji Claude dodaj zdalny marketplace, zainstaluj wtyczkę
   i zweryfikuj jej wersję oraz nowo wydaną powierzchnię umiejętności.
4. W świeżej, izolowanej konfiguracji Codex dodaj zdalny marketplace przypięty do nowego tagu,
   zainstaluj wtyczkę i wykonaj taką samą weryfikację. Świeże, izolowane instalacje Claude i Codex muszą przejść pomyślnie.
5. Uaktualnij aktywne instalacje użytkownika tylko na jego żądanie; oba klienty wymagają ponownego uruchomienia lub przeładowania.

Na koniec podaj adresy URL PR-u i wydania, tożsamość tagu i scalenia, wyniki CI, dowody z instalatorów oraz jeden
widoczny status terminala.
