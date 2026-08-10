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
zasady własności i stanu adresu URL. Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/tanstack-router/REFERENCE.md), aby poznać lokalne wzorce kodu, oraz
[SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/tanstack-router/SETUP.md), aby poznać instrukcję instalacji.

## Własność

- Loadery Routera rozpoczynają pobieranie danych z serwera po zainicjowaniu nawigacji.
- TanStack Query odpowiada za pamięć podręczną, ponowne pobieranie, unieważnianie i usuwanie nieużywanych danych.
- Komponenty obserwują Query za pomocą `useQuery` lub `useSuspenseQuery`.

Używaj suspense dla kluczowych danych strony, które blokują jej wyświetlenie; dla danych odroczonych używaj zwykłych zapytań z
lokalnymi stanami ładowania, braku danych i błędu. Loadery korzystające z Query ustawiają
`defaultPreloadStaleTime: 0` i używają `createRootRouteWithContext`.

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
- Dane Query mają aktywnego obserwatora oraz kompletne, widoczne stany.
- Nawigacja zachowuje semantykę historii przeglądarki.
- Adresy URL wyszukiwania obsługują nieprawidłowe, nieaktualne i udostępnione wartości.
- Drzewo tras, testy ukierunkowane, sprawdzanie typów i lintowanie przechodzą pomyślnie.
