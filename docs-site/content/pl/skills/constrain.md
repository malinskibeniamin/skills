---
description: "Ogranicz API i importy listami dozwolonych elementów, kontrolami i malejącą bazą naruszeń."
related: ["/skills/development-lifecycle", "/skills/tdd", "/skills/review"]
sidebar: {"label": "/constrain"}
title: "/constrain"
type: "skill"
---
![Diagram umiejętności /constrain](/diagrams/skills/constrain.svg)

[Excalidraw](/diagrams/skills/constrain.excalidraw)

Przed wyborem sposobu egzekwowania przeczytaj [usprawnianie harnessu](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#harness-improvement).

Przeczytaj [zgodność z hostem](https://github.com/malinskibeniamin/skills/blob/main/shared/MATT-POCOCK.md), a następnie pełną [umiejętność źródłową](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/in-progress/constrain/SKILL.md). Rozwiązuj jej odnośniki względem katalogu źródła. Zachowaj etapy: eksploracja, zebranie danych, wywiad, budowa, mechanizm malejącej bazy, weryfikacja i zapis. Ten eksperymentalny szkic nie ustanawia domyślnej polityki React/stanu ani piaskownicy bezpieczeństwa.

## Granice hosta

- Ogranicz jedno narzędzie wybrane przez użytkownika w docelowym repozytorium. Zanim zaproponujesz listy dozwolonych elementów, sprawdź zainstalowaną wersję, kontrole, CI i istniejące ograniczenia. Samo wczytanie lub skopiowanie umiejętności nie aktywuje reguł, hooków ani zależności.
- Zbadaj osie Community i Usage samodzielnie, chyba że użytkownik jawnie zezwoli na delegowanie. Po zgodzie użyj świeżych kontekstów i ograniczonych zadań zgodnie z [routingiem modeli](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/SKILL.md); źródło nie udziela zgody. Oddziel zaobserwowane użycie od niepełnego spisu i wywnioskowanych zagrożeń.
- Do wywiadu wczytaj [grilling](https://github.com/malinskibeniamin/skills/blob/main/grilling/SKILL.md) przez [ładowanie zależności](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies). Pokaż każdą listę, wyjątek dla ścieżki, zalecaną alternatywę oraz luki dopasowania po nazwie lub typie. Przed zmianą reguł lub bazy poczekaj na potwierdzenie użytkownika. Przykład ograniczenia nie jest decyzją.
- Zachowaj istniejący checker i komendę kontroli. Dla funkcji zależnych od wersji wczytaj [badanie dokumentacji pierwotnej](https://github.com/malinskibeniamin/skills/blob/main/read-the-damn-docs/SKILL.md). W projekcie Biome zachowaj Biome i najpierw wykorzystaj odpowiednią istniejącą regułę. Brak funkcji nie upoważnia do cichej zmiany silnika lintowania ani dodania drugiego checkera. Wyjaśnij potrzebną zależność lokalną i jej zakres.
- Bazą obejmij tylko istniejące naruszenia nowo uzgodnionych reguł, według reguły i pliku, a dla grafu według krawędzi. Zachowaj wcześniejsze błędy, bazy, kontrole wyciszeń i ostrzejsze zasady; nie wyciszaj całego projektu przez `--suppress-all`. Jeśli projekt zabrania baz, zgłoś konflikt i uzgodnij zgodną migrację zamiast wyłączać bramkę. CI musi odrzucać nowe i rosnące naruszenia oraz nieaktualne wpisy. Zawężenie listy nie może ponownie bazować obcego długu. To mechanizm migracji, nie obejście.
- Udowodnij, że poprawny kod przechodzi, każda zakazana operacja z uzgodnionego zakresu zawodzi w nowym pliku, dodatkowe naruszenie w pliku objętym bazą zawodzi, a usunięty dług nie może wrócić. W odpowiednich przypadkach sprawdź aliasy, reeksporty i przestrzenie nazw; ujawnij braki. Uruchom rzeczywistą komendę zbiorczą, usuń celowe naruszenia i powtórz czystą kontrolę. Przykłady źródłowe nie dowodzą zachowania zainstalowanego narzędzia.
- Zapisz narzędzie i komendę kontroli w instrukcjach utrzymywanych przez projekt. Jeśli `AGENTS.md` jest generowany, zmień źródło kanoniczne i wygeneruj go ponownie. Listy pozostają w wykonywalnej konfiguracji, nie w kolejnym katalogu prozy.

Na koniec podaj uzgodnione ograniczenia, ścieżki reguł i bazy, rzeczywiste dowody przejścia, błędu i zmniejszenia bazy oraz ograniczenia pokrycia. Zachowaj żądany punkt dostarczenia; wywołanie nie upoważnia do instalacji globalnych, zmian polityk hostowanych ani niezwiązanych refaktoryzacji.
