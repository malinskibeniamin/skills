---
title: /tanstack-router
description: >-
  Stosuj wzorce TanStack Router dotyczące własności Query i typowanego
  wyszukiwania. Używaj podczas modyfikowania tras, loaderów, nawigacji, drzew
  tras lub parametrów wyszukiwania.
type: skill
sidebar:
  label: /tanstack-router
---
![Diagram umiejętności /tanstack-router](/diagrams/skills/tanstack-router.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/tanstack-router.excalidraw)

Najpierw zastosuj `/tanstack-intent` i wczytaj odpowiednie wytyczne dostarczone z zainstalowanym
pakietem Router. Intent określa aktualną składnię API i zachowanie wersji. Ta umiejętność dodaje lokalne
zasady własności i stanu adresu URL. Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/tanstack-router/REFERENCE.md), aby poznać lokalne wzorce kodu, oraz
[SETUP.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/tanstack-router/SETUP.md), aby poznać instrukcję instalacji.

## Router + Query

- Loadery Routera rozpoczynają pobieranie danych z serwera po zainicjowaniu nawigacji.
- TanStack Query odpowiada za pamięć podręczną, ponowne pobieranie, unieważnianie i usuwanie nieużywanych danych.
- Komponenty obserwują Query za pomocą `useQuery` lub `useSuspenseQuery`.

Dane wejściowe Query znane trasie mają jeden potok: `validateSearch` -> `loaderDeps` -> jeden
konstruktor `queryOptions` -> loader i obserwator komponentu. Zwracaj wyłącznie pola wyszukiwania używane przez
zapytanie. Komponenty korzystają z `useLoaderDeps`, a nie z równoległego odczytu parametrów wyszukiwania
sterujących zapytaniem. Jeśli wytyczne zainstalowanego Routera obsługują tworzenie opcji w `context`
trasy, współdziel dokładnie tę samą wartość opcji; nigdy nie stosuj nieudokumentowanej składni z przykładu.

- Kluczowe dane strony: oczekuj na `ensureQueryData`; obserwuj za pomocą `useSuspenseQuery`.
- Odroczone dane znane trasie: rozpocznij ich pobieranie w loaderze; obserwuj za pomocą `useQuery` z widocznymi
  stanami ładowania, braku danych i błędu.
- Dane potrzebne wyłącznie do interakcji mogą być pobierane z komponentu.

Loadery korzystające z Query ustawiają `defaultPreloadStaleTime: 0` i używają
`createRootRouteWithContext`.

## Cykle życia nawigacji

Oddziel własność zasobu, nawigacji, wyniku i renderowania:

- Zastąpiona nawigacja traci prawo do publikowania; współdzielona praca loadera lub Query może
  nadal być użyteczna.
- `beforeLoad` służy do bezpiecznego przy ponownym wykonaniu uwierzytelniania, przekierowania lub tworzenia kontekstu. Wstępne ładowanie
  i nawigacja mogą uruchamiać je niezależnie; nie umieszczaj tam obserwowalnych efektów ubocznych ani zwykłego pobierania danych,
  aby loadery zachowały równoległość.
- Bezpośrednie żądania loadera przekazują `abortController.signal`. Funkcje Query przekazują
  sygnał należący do Query. Nie anuluj globalnie współdzielonej pracy przy każdej nawigacji.
- Przekierowania z `beforeLoad` lub loaderów używają `throw redirect(...)`, a nie imperatywnej
  nawigacji.
- Używaj `onResolved` do analityki i czyszczenia niezwiązanego z DOM. Używaj `onRendered` do zarządzania fokusem,
  przewijania, pomiarów lub innych działań wymagających zatwierdzonej zawartości trasy.
- Używaj interfejsu oczekiwania Routera i jego opcji czasowych zamiast własnych liczników czasu nawigacji.

## Reguły tras

- Ogranicz zakres `useParams`, `useSearch`, `useLoaderData` i `useRouteContext` za pomocą `{ from }` lub
  API trasy; nie używaj `strict: false`.
- Komponenty korzystające z Query odczytują dane z Query, a nie z `Route.useLoaderData`.
- Pliki tras eksportują wyłącznie konfigurację tras; komponenty wielokrotnego użytku znajdują się w innych plikach.
- Nawigacja używa API routera, a nie `window.location`.
- `react-router-dom`, `URLSearchParams` i nuqs stanowią dług migracyjny.
- Zmiany drzewa tras uruchamiają generowanie.

## Parametry wyszukiwania

Router odpowiada za typowanie parametrów wyszukiwania za pomocą `validateSearch`.

- Adres URL: udostępniane karty, filtry, sortowanie i strona.
- Pamięć lokalna: osobiste ustawienia gęstości, rozmiaru strony i zwinięcia.
- Waliduj wartości wyliczeniowe, daty i liczby z ograniczonym zakresem; koryguj nieaktualne indeksy stron do dozwolonego zakresu.
- Scalaj aktualizacje z poprzednim stanem wyszukiwania.
- Używaj `replace: true` wewnątrz sekcji, aby przycisk Wstecz opuszczał sekcję.

## Ukończenie

- Typy potwierdzają zakres trasy i wyszukiwania.
- Loader i obserwator używają tego samego konstruktora opcji Query oraz danych wejściowych należących do loadera.
- Dane Query mają aktywnego obserwatora oraz kompletne, widoczne stany.
- Szybka lub wstępnie załadowana nawigacja nie może opublikować nieaktualnego interfejsu trasy ani powielać pracy należącej do aplikacji.
- Testy nawigacji sprawdzają wyróżnik wyrenderowanej trasy po zmianie adresu URL.
- Nawigacja zachowuje semantykę historii przeglądarki.
- Adresy URL wyszukiwania obsługują nieprawidłowe, nieaktualne i udostępnione wartości.
- Drzewo tras, testy ukierunkowane, sprawdzanie typów i lintowanie przechodzą pomyślnie.
