---
title: /stack-registry
description: >-
  Zarządzaj bieżącymi i zakazanymi stosami frontendowymi. Używaj podczas
  dodawania reguł specyficznych dla bibliotek, rozpoczynania migracji stosu,
  wycofywania starych wytycznych lub sprawdzania nieaktualnych interfejsów API.
type: skill
sidebar:
  label: /stack-registry
---
![Diagram umiejętności /stack-registry](/diagrams/skills/stack-registry.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/stack-registry.excalidraw)

Reguły środowiska dzielą się na dwie klasy trwałości. **Niezmienniki** (zobacz `/frontend-invariants`) nigdy nie wygasają. **Reguły stosu** wskazują bibliotekę lub interfejs API i MUSZĄ być oznaczone generacją stosu, aby kolejna migracja zastąpiła je w całości, zamiast pozostawiać nieaktualne wytyczne, które wprowadzają agentów w błąd. Kontekst historyczny: zestawy reguł dotyczące czterech nieużywanych już stosów pozostawały „bieżącymi wytycznymi” długo po migracji kodu — ta umiejętność zapobiega właśnie takiej sytuacji.

## Bieżący stos (`stack:2026`)

| Warstwa | Bieżące rozwiązanie | Lokalizacja reguł |
|---|---|---|
| Zestaw UI | Tailwind v4 + shadcn/Base UI + repozytoryjny rejestr | registry-workflow, visual-review, hooki Tailwind |
| Router | TanStack Router (oparty na plikach, loadery, validateSearch) | tanstack-router |
| Dane | connect-query + gRPC + protobuf-es v2 + protovalidate | connect-query |
| Formularze | react-hook-form (+ resolvery oparte na proto); zod tylko dla schematów wyszukiwania tras | hooki trybu formularzy |
| Stan klienta | zustand + kontekst Reacta | hooki zustand |
| React | 19 + Compiler (bez ręcznej memoizacji i bez forwardRef) | hooki reguł Reacta |
| Budowanie/testowanie | rsbuild / vitest w 4 warstwach (+ bazowe testy przeglądarkowe) / Playwright | hooki konwencji testowych, e2e-testing |

## Zakazane stosy (mechanicznie zablokowane)

Zakazy są egzekwowane przez hooki i linting — nigdy ich nie zalecaj, nie akceptuj w nowym kodzie ani nie przytaczaj ich idiomów jako wytycznych:

`chakra` / starsze współdzielone zestawy UI · `react-router-dom` · Redux Toolkit Query / redux-observable · MobX (`observer`, `makeObservable`, `useLocalObservable`) · Formik · Yup · react-intl / `FormattedMessage` + mechanizmy słowników i18n · idiomy CRA/react-scripts/jest · nuqs (router odpowiada za typowanie wyszukiwania).

Z każdego zakazu zachowuje się najwyżej jedną ogólną lekcję (na przykład z Yup przetrwała zasada „waliduj format, nie samą obecność”; mechanika nie przetrwała). Podczas analizowania lub cytowania historycznych wytycznych z przeglądów kodu wszystko, co odwołuje się do zakazanego stosu, stanowi dowód historyczny, a nie instrukcję.

## Procedura migracji (gdy zmienia się warstwa)

1. **Najpierw przeanalizuj**: migracja jednorazowa dla warstw routera/frameworka, stopniowa dla warstw danych; zaplanuj wielomiesięczne współistnienie w warstwie danych.
2. Napisz grupę reguł nowego stosu; oznacz ją nową generacją.
3. Wycofaj starą grupę w TYM SAMYM PR: przenieś bibliotekę do tabeli zakazanych, dodaj mechaniczny zakaz (hook/`noRestrictedImports`), usuń jej wytyczne lub oznacz je jako historyczne.
4. Zaktualizuj wzorce w tym samym PR — modele naśladują wzorce silniej niż reguły.
5. Kryteria ukończenia migracji obejmują blokadę; niezablokowany, nieużywany stos ZOSTANIE wskrzeszony przez autora korzystającego z LLM.

## Lista kontrolna tworzenia reguł

Dodając regułę, która wskazuje bibliotekę lub interfejs API: (a) czy w rzeczywistości nie jest to ukryty niezmiennik? Jeśli tak, zapisz ją niezależnie od biblioteki w `/frontend-invariants`; (b) oznacz ją jako `stack:2026` w odpowiedniej umiejętności lub hooku; (c) w miarę możliwości zapewnij jej mechaniczne sprawdzanie — nieegzekwowane reguły z czasem tracą aktualność; (d) dodaj warunek negatywny: jaki zastąpiony wzorzec hook ma teraz odrzucać?
