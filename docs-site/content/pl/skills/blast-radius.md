---
title: /blast-radius
description: >-
  Znajdź skutki zmiany wykraczające poza jej lokalny zakres i potwierdź kluczowy
  niezmiennik bezpieczeństwa za pomocą wykonywalnych dowodów. Użyj do analizy
  promienia rażenia, pytania „co może się przez to zepsuć?” lub podejrzanie
  małej różnicy.
type: skill
sidebar:
  label: /blast-radius
---
![Diagram umiejętności /blast-radius](/diagrams/skills/blast-radius.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/blast-radius.excalidraw)

Znajdź, co zmiana może zepsuć poza zakresem różnicy. Lista miejsc wywołania to rozpoznanie, a nie wynik. Wynikiem jest jeden fakt, dzięki któremu zmiana jest bezpieczna, potwierdzony tak bezpośrednio, jak to praktycznie możliwe.

## Kontrakt

- **Punkt odniesienia:** przeglądaj od wskazanej bazy do bieżącego stanu roboczego, chyba że wywołujący poda inny punkt.
- **Granice:** sprawdzaj kontrakty nielokalne i uruchamiaj weryfikację; nie edytuj kodu produktu.
- **Pytanie:** jaki ukryty konsument, cykl życia, format danych przesyłanych, współdzielony stan lub kontrakt zewnętrzny może sprawić, że ta zmiana spowoduje defekt?

## Drabina dowodowa

Przesuwaj każdy fakt dotyczący bezpieczeństwa w dół tej drabiny możliwie najmniejszym kosztem: wiersz kodu źródłowego -> przeanalizowany kontrprzykład -> wykonywalny skrypt lub test -> rzeczywisty uruchomiony punkt wejścia. Twierdzenie bez wykonywalnego dowodu jest **nieudowodnione**, a nie bezpieczne dzięki przekonaniu.

## Przebieg

1. Przeczytaj całą zmianę, zmienione symbole, miejsca wywołania, producentów, konsumentów, schematy i powierzchnie publiczne. Określ, jakie zachowanie się zmienia, w tym niejawne zmiany czasu wykonania i cyklu życia.
2. Wskaż kluczowy niezmiennik bezpieczeństwa. Preferuj jeden fakt, który eliminuje kilka hipotetycznych zagrożeń, na przykład „operacja usuwa wyłącznie wygasłe wpisy, a w pozostałych przypadkach nie ma żadnego skutku”.
3. Szukaj tam, gdzie kończy się wyszukiwanie symboli: w danych serializowanych, kolumnach bazy danych, flagach funkcji, innym języku, kodzie biblioteki w przypiętej wersji, kolejności zwalniania zasobów, ponowieniach, współbieżności oraz miejscach wywołania osiąganych przez konfigurację.
4. Zbuduj najmniejszą wiarygodną ścieżkę awarii. Oddziel potwierdzone zagrożenia od sprawdzonych i wykluczonych ścieżek. Cytuj dokładne dowody; wyszukiwanie, które niczego nie znajduje, jest dowodem tylko wtedy, gdy przeszukany zakres jest kompletny.
5. Udowodnij niezmiennik w rzeczywistym kodzie. Dodaj jednorazowy skrypt lub ukierunkowany test kontraktu publicznego, jeśli jest to najtańsza wykonywalna weryfikacja. Nie zachowuj testu, który jedynie powtarza treść kodu źródłowego.
6. Jeśli dostępna jest uruchomiona ścieżka użytkownika, sprawdź ją za pomocą `/dogfood`. Zapisz, na którym szczeblu drabiny dowodowej zatrzymał się każdy fakt.

## Wynik

- **Zmiana:** obserwowalna różnica semantyczna.
- **Niezmiennik bezpieczeństwa:** dokładny fakt, szczebel dowodu, polecenie i obserwacja; w przeciwnym razie `unproven`.
- **Zagrożenia:** ścieżka awarii, prawdopodobieństwo, wpływ, dowody i najtańsza weryfikacja.
- **Wykluczone:** sprawdzone ścieżki i dowody, które je wykluczają.
- **Przed scaleniem:** najmniejsze polecenie lub odtworzenie błędu, które zakończy się niepowodzeniem, jeśli niezmiennik jest fałszywy.

Zagrożenia muszą być poparte dowodami i ściśle określone. Nie rozbudowuj listy możliwości po udowodnieniu kluczowego niezmiennika.
