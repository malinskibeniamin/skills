---
title: /test-audit
description: >-
  Oceniaj wartość testów. Używaj podczas przeglądów, przeszukiwania lub usuwania
  testów o niskiej wartości, powielających inne testy lub zależnych od
  implementacji oraz punktów dostępu w kodzie produkcyjnym istniejących
  wyłącznie na potrzeby testów, a także przy kwalifikowaniu nowych testów.
type: skill
sidebar:
  label: /test-audit
---
![Diagram umiejętności /test-audit](/diagrams/skills/test-audit.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/test-audit.excalidraw)


Trzy tryby, jeden próg wartości. Tryb tworzenia weryfikuje każdy nowy lub zmieniany test podczas jego pisania; `/tdd` kieruje tutaj. Tryb audytu obejmuje ukierunkowane przeglądy testów, które odtwarzają treść kodu źródłowego, powielają silniejsze dowody, wiążą zachowanie z implementacją lub podtrzymują punkty dostępu w kodzie produkcyjnym istniejące wyłącznie na potrzeby testów. Szerokie audyty kontynuuj w osobnych, spójnych PR-ach; priorytetem jest pewność działania, a nie liczba usunięć. Tryb kampanii ogranicza zestaw testów całego podsystemu (wszystkie pliki testowe należące do pakietu, aplikacji lub obszaru rdzenia); przed rozpoczęciem przeczytaj [CAMPAIGN.md](https://github.com/malinskibeniamin/skills/blob/main/test-audit/CAMPAIGN.md).

## Kwalifikacja nowych testów [#authoring-gate]

Przed dodaniem testu odpowiedz na cztery pytania; brak odpowiedzi oznacza, że nie należy go jeszcze dodawać:

1. Jakie obserwowalne zachowanie, niezmiennik lub niezależny kontrakt chroni?
2. Jaka realna regresja spowoduje jego niepowodzenie?
3. Dlaczego istniejące testy nie wykrywają już tego błędu? Każdy kontrakt ma jeden główny test na granicy zapewniającej najsilniejszą weryfikację; kolejna warstwa wymaga odrębnego ryzyka, na przykład błędu transportu lub cyklu życia, którego główny test nie może objąć. Preferuj rozszerzenie przypadku w teście opartym na tabeli lub współdzielonej fixtury zamiast dodawania niemal identycznego testu; w tej samej zmianie ujednolić powielane przygotowanie testów.
4. Czy wymaga punktu dostępu w kodzie produkcyjnym (eksportu, flagi, wrappera, punktu wstrzykiwania), którego nie potrzebuje żaden kod produkcyjny? Jeśli tak, przenieś test na rzeczywistą granicę.

Następnie sprawdź test pod kątem każdego [antywzorca](#junk-patterns); dopasowanie oznacza odrzucenie testu, chyba że [kryteria zachowania](#retention-bar) wskazują kontrakt, którego test niezależnie strzeże. Test, który przestałby przechodzić po refaktoryzacji zachowującej zachowanie, sprawdza implementację, a nie zachowanie; przed włączeniem zmian przepisz go tak, aby działał na granicy komponentu odpowiedzialnego za kontrakt.

Testy regresyjne błędów muszą nie przechodzić na kodzie sprzed poprawki z zamierzonego powodu i przechodzić po naprawie na granicy odpowiedzialnego komponentu. Test regresyjny, którego niepowodzenia nigdy nie wykazano, potwierdza działanie atrapy, a nie poprawki. Jeden test regresyjny na granicy odpowiedzialnego komponentu obejmuje błąd; nie odtwarzaj tego samego scenariusza w każdej warstwie, przez którą przechodzi.

## Antywzorce [#junk-patterns]

Wspólna lista kontrolna dla wszystkich trybów: kwalifikacja odrzuca nowe testy pasujące do któregokolwiek wzorca, a audyty wyszukują takie testy w istniejącym zestawie.

- sondy pokrycia bez asercji;
- porównywanie wartości z samą sobą i kopiowanie wartości bez zmian;
- skopiowane fixtury, inwentarze, manifesty lub listy eksportów;
- wyszukiwanie dokładnej treści kodu, importów lub ciągów znaków;
- testy prywatnych predykatów lub postaci wywołań powielane na rzeczywistych granicach;
- wielokrotne sprawdzanie tego samego kontraktu;
- odtwarzanie testów współdzielonych funkcji pomocniczych wewnątrz pakietu;
- testy służące wyłącznie zachowaniu eksportów, zmiennych globalnych lub wrapperów istniejących tylko na potrzeby testów;
- martwy kod produkcyjny wywoływany wyłącznie przez testy;
- oczekiwane wartości generowane przez testowaną funkcję pomocniczą lub renderer;
- atrapy implementujące sprawdzane zachowanie lub jedna identyczna atrapa zastępująca różne API;
- fixtury dostarczające potwierdzenie odbioru, decyzję o dopuszczeniu lub kolejność wywołań zwrotnych, które powinien wytworzyć odpowiedzialny komponent, albo asercje zapisu danych sprawdzające magazyn, do którego dana ścieżka nigdy nie zapisuje;
- testy możliwości, które powtarzają zadeklarowane flagi, zamiast sprawdzać dostarczenie lub potwierdzenie obiecane przez flagę;
- kontrole negatywne przechodzące z niezwiązanego powodu, na przykład odmowy ze strony innego zabezpieczenia lub odrzucenia, do którego ścieżka produkcyjna nigdy nie dociera;
- nazwy lub fixtury obiecujące więcej, niż sprawdzają dane wejściowe, na przykład test „wycofuje okno” sprawdzający, że okno nie zostało wyczyszczone.

## Próg wartości [#value-bar]

Testy uzasadniają koszt utrzymania, chroniąc zachowanie, zapobiegając realnej regresji lub strzegąc kontraktu o niezależnym znaczeniu. Podczas audytu istniejący test wymagający zmiany po reorganizacji kodu zachowującej zachowanie budzi podejrzenia, ale nie kwalifikuje się automatycznie do usunięcia; kwalifikacja nowych testów nadal odrzuca takie przypadki.

Przed oceną kandydata przeczytaj cały test i odpowiedzialny kod produkcyjny, jego punkt wejścia, kod wywołujący i wywoływany, pokrewne implementacje, nakładające się testy, reguły uruchamiania w CI i istotną historię zmian. Najpierw przeczytaj pliki `AGENTS.md` lub `CLAUDE.md` z katalogu głównego i odpowiednich podkatalogów. Jeśli test deklaruje sprawdzanie zachowania opartego na zależności, bezpośrednio zbadaj kod źródłowy lub typy tej zależności.

## Rozpoznanie [#discovery]

Podczas rozpoznania nie wprowadzaj zmian i przedstaw dowody przed edycją. Przy szerokim zakresie podziel rozpoznanie na obszary: rdzeń i pakiety; aplikacje i interfejs użytkownika; skrypty i narzędzia; jeden przekrojowy przegląd wzorców. Pracuj nad obszarami równolegle tylko wtedy, gdy użytkownik wyraźnie poprosił o delegowanie lub `/swarm`; w przeciwnym razie pracuj kolejno.

Poza trybem kampanii preferuj kilku kandydatów o wysokiej pewności zamiast obszernej listy przypuszczeń. Szukaj [antywzorców](#junk-patterns).

## Kryteria zachowania [#retention-bar]

Zachowaj test, gdy niezależnie egzekwuje kontrakt dotyczący publicznego API, SDK, protokołu, konfiguracji, migracji, przechowywania danych, bezpieczeństwa, platformy, wartości domyślnych, dokładnych bajtów promptu, kodu generowanego dla różnych języków, pakietu, wydania lub architektury. Zachowaj również:

- sprawdzanie kolejności wywołań, gdy kolejność jest obserwowalnym zachowaniem;
- testy regresyjne z realnym scenariuszem awarii;
- inspekcję kodu źródłowego, gdy jest najtańszym niezależnym zabezpieczeniem: test nie przechodzi po zmianie kontraktu (klucza, bajtu lub ścieżki widocznych dla użytkownika), ale przechodzi po refaktoryzacji zmieniającej wyłącznie identyfikatory;
- zachowany test, który nie przechodzi na wersji bazowej: potraktuj to jako możliwy błąd produktu, odtwórz go za pomocą `/diagnosing-bugs` i napraw odpowiedzialny komponent, zamiast usuwać test.

Statyczny charakter lub długi czas działania nie są powodem do usunięcia. Test przypominający implementację nadal może stanowić niezależny kontrakt; przed usunięciem udowodnij, że jest inaczej.

## Dowody dotyczące kandydata [#candidate-evidence]

Przed edycją zapisz wszystkie poniższe informacje. Brak którejkolwiek oznacza, że kandydat nie jest gotowy do usunięcia:

- dokładna nazwa i lokalizacja testu;
- jaki błąd rzeczywiście może wykryć;
- kod poza testami korzystający z objętego testem punktu dostępu w kodzie produkcyjnym lub pomocniczym;
- silniejszy dowód pozostający na granicy odpowiedzialnego komponentu albo powód, dla którego dowód nie jest potrzebny;
- istotna historia zmian i powód istnienia testu lub punktu dostępu;
- kod produkcyjny lub pomocniczy kod testowy, który można dzięki temu usunąć;
- ryzyko i polecenie ukierunkowanej weryfikacji.

## Zakres zmian [#edit-shape]

Wybierz jedną spójną partię zmian na granicy odpowiedzialnego komponentu. Usuń zbędne eksporty, zmienne globalne i wrappery istniejące tylko na potrzeby testów oraz martwe ścieżki produkcyjne, zamiast zachowywać aliasy. Przenieś zachowane testy regresyjne do właściwych komponentów. Połącz powtarzające się asercje dotyczące pakietów lub zależności w jeden ogólny kontrakt.

Preferuj zmniejszenie łącznej liczby wierszy kodu produkcyjnego. Nie dodawaj testów zastępczych odtwarzających tę samą implementację i nie traktuj niepewnych kandydatów jako porządków tylko po to, aby zwiększyć liczbę usunięć.

## Weryfikacja [#validation]

1. Zatrzymaj procesy obserwujące zmiany i uruchamiające testy przed usunięciem lub przeniesieniem testów; ich wyniki podczas usuwania nie stanowią dowodu.
2. Uruchom minimalny zestaw testów odpowiedzialnego komponentu i komponentów pokrewnych za pomocą ukierunkowanego polecenia repozytorium, takiego jak `bunx vitest run <path>` lub `go test ./<pkg>`.
3. W przypadku usuniętych wyszukiwań w kodzie lub asercji dotyczących planu uruchom skrypt wykonywalny albo przebieg próbny odpowiadający za rzeczywisty kontrakt.
4. Uruchom `bun run lint:fix`, `bun run type:check`, `git diff --check` oraz kontrolę zmienionych plików uruchamianą przez CI.
5. Sprawdź `git diff --numstat`; raportuj kod produkcyjny i narzędzia osobno od testów i ich kodu pomocniczego.
6. Po końcowych zmianach audytowych uruchom `/review`.

## Włączanie zmian i kontynuacja [#landing-and-continuation]

Dostarczaj zmiany przez `/commit-push-pr` do etapu wskazanego w zleceniu; scalenie wymaga wyraźnej zgody. Włączaj po jednym spójnym PR-ze; po jego scaleniu zaktualizuj kod z gałęzi domyślnej i ponownie przeprowadź rozpoznanie bez wprowadzania zmian, aby wybrać kolejną partię o wysokiej pewności.

## Przekazanie wyników [#handoff]

Przedstaw przyczynę źródłową i usunięte kategorie o niskiej wartości; uproszczenia odpowiedzialnego kodu produkcyjnego; zachowane testy błędnie wskazane jako zbędne i powody ich wartości; faktycznie przeprowadzoną weryfikację ukierunkowaną i pełną; liczbę wierszy kodu produkcyjnego i testowego; stan PR-a i scalenia; nazwane zadania do dalszej realizacji.
