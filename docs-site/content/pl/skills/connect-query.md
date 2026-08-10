---
title: /connect-query
description: >-
  Twórz typowane przepływy danych ConnectRPC za pomocą Connect Query i Protobuf
  v2. Używaj do wywołań API, mutacji, hooków zapytań, transportów, unieważniania
  pamięci podręcznej i wygenerowanych klientów.
type: skill
sidebar:
  label: /connect-query
---
![Diagram umiejętności /connect-query](/diagrams/skills/connect-query.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/connect-query.excalidraw)

Uruchom `/read-the-damn-docs`, zanim przyjmiesz aktualne zalecenia dotyczące interfejsów API ConnectRPC, Connect Query lub Protobuf.
## Co to wykrywa

- **Zakazuje bezpośredniego używania `useQuery`/`useMutation`** z `@tanstack/react-query`, gdy plik korzysta z ConnectRPC — użyj Connect Query (wyjątek: wzorzec `useTransport`/`callUnaryMethod`)
- **Zakazuje `invalidateQueries()`** bez argumentów — należy podać klucz zapytania
- **Ostrzega przed `axios`/`fetch()`** — preferowany jest transport ConnectRPC
- **Protobuf v2**: Zakazuje `new Message()` -> użyj `create(Schema)`. Zakazuje `PlainMessage`/`PartialMessage` -> użyj `MessageShape`/`MessageInitShape`. Zakazuje ręcznie zapisanych literałów `$typeName`.

Wyjątek: `// allow: direct-query [reason]`

## Dyscyplina warstwy zapytań (wypracowana na podstawie 4 lat historii przeglądów)

- **Poziomy pamięci podręcznej zamiast magicznych liczb**: 2–3 semantyczne stałe (`SHORT/MEDIUM/LONG_LIVED_CACHE_STALE_TIME`) w jednym pliku; `Infinity` tylko dla danych, które zmieniają się wyłącznie przez własne unieważnianie. Zasady ponawiania są zdefiniowane raz w QueryClient (ponawiaj po błędach 5xx/błędach sieci, nigdy po 4xx).
- **`transform`/`select` w hooku, nigdy przetwarzanie w komponentach** — komponent otrzymuje dane gotowe do wyświetlenia; rozmiary stron są wymuszane przez hook, a nie przetwarzane w miejscach wywołania.
- **Unieważniaj zamiast ponownie pobierać; zawsze czekaj na zakończenie** — unieważnianie uruchomione bez oczekiwania konkuruje z nawigacją, przez co następny ekran renderuje nieaktualną pamięć podręczną. Klucze: ogólne według usługi/metody (z uwzględnieniem liczby wariantów dla zapytań nieskończonych), nigdy nadmiernie szczegółowe.
- **Zgodność kluczy zapytań loadera i hooka** — loader trasy, który wstępnie pobiera dane z nieco innym kluczem, po cichu wykonuje podwójne pobranie. Sprawdź równość kluczy w teście.
- **Jeden hook na RPC; rozdzielaj strony korzystające z wielu RPC** na jeden hook danych dla każdego wywołania usługi. Nazwy hooków mutacji kończą się na `Mutation` (`WithToast`, gdy zarządzają powiadomieniami).
- **Kierunek walidacji**: walidacja proto po stronie klienta (protovalidate) dotyczy danych, które WYSYŁASZ. Odpowiedzi są już zweryfikowane przez serwer — nie weryfikuj ponownie odczytywanych danych.
- **Opcjonalne pola proto mają wartość `undefined`, nigdy `null`**; nieograniczone listy korzystają z zapytania nieskończonego i opcji „wczytaj więcej”; odpytywanie okresowe używa wbudowanego `refetchInterval`, a nie własnych liczników czasu.

Pułapki Protobuf (Timestamp, Duration, Any, wzorce pamięci podręcznej): [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/connect-query/REFERENCE.md). Konfiguracja: [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/connect-query/SETUP.md).
