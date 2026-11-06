---
description: Optymalizuj określony wynik w ograniczonych pętlach oceny. Użyj dla hill-climb lub powtarzalnego doskonalenia według wykonywalnej ewaluacji, benchmarku albo porównania wizualnego, nie dla jednorazowej recenzji.
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["hill climb"]}
sidebar: {"label":"/hill-climb"}
title: "/hill-climb"
type: "skill"
---
![Diagram umiejętności /hill-climb](/diagrams/skills/hill-climb.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/hill-climb.excalidraw)

Optymalizuj artefakt, nie jego sędziego. Preferuj wykonywalne dowody; kalibruj ocenę wizualną.

## Współpracuj z istniejącymi właścicielami [#compose-with-existing-owners]

Załaduj poniższych [właścicieli](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies); zachowaj jedną pętlę i wspólny budżet:

- [Cykl rozwoju](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/SKILL.md) odpowiada za implementację i dostarczenie. Raporty, plany i recenzje nie zmieniają źródeł, poza zamówionymi artefaktami planu; [improve](https://github.com/malinskibeniamin/skills/blob/main/improve/SKILL.md) może zalecić wspinaczkę bez jej rozpoczynania.
- [Quantify impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md) odpowiada za metryki, minimalne wartościowe różnice i szum.
- Dla UI [przegląd wizualny](https://github.com/malinskibeniamin/skills/blob/main/visual-review/SKILL.md) odpowiada za dowody z renderowania i dobór specjalistycznych wskazówek; [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md) sprawdza rzeczywiste zachowanie oraz awarię i odzyskiwanie.
- Tylko po wyraźnym upoważnieniu [council](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/council/SKILL.md) lub [sol-loop](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/sol-loop/SKILL.md) dostarcza rundy recenzji tylko do odczytu zgodnie ze [zgodnością z hostem](https://github.com/malinskibeniamin/skills/blob/main/shared/TSTACK.md#review-evidence-for-council-and-sol-loop). Samo załadowanie hill-climb nie daje zgody na delegowanie. Bez niej oceniaj w głównym kontekście i tak oznacz ocenę. [Efficient frontier](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/SKILL.md) odpowiada za upoważniony dobór modeli i dostępną pojemność.

## Zdefiniuj cel wspinaczki przed edycją [#define-the-hill-before-editing]

Użyj istniejącego kontraktu zadania lub krótkiej notatki w bieżącym kontekście:

- **Cel:** beneficjent, oczekiwany rezultat, główna metryka lub nazwane kategorie oceny, warunek akceptacji i minimalna wartościowa poprawa. Sama liczba nie stanowi wartości.
- **Ograniczenia:** chronione zachowanie, dostępność, bezpieczeństwo, dozwolony zakres edycji i limity zasobów. Zachowaj niezwiązane zmiany oraz pierwotny punkt końcowy użytkownika.
- **Weryfikacja:** polecenie ewaluatora lub protokół wizualny, dane testowe, środowisko, pierwotna rewizja i najlepszy zaakceptowany kandydat, czyli bieżący wariant odniesienia. Zachowaj oba punkty odniesienia.
- **Koniec:** żądany punkt końcowy, budżet ewaluacji i reguła zatrzymania przy braku postępu. Bez podanego budżetu wykonaj najwyżej trzy iteracje kandydatów; zarezerwuj w nim potwierdzenie. Nadal obowiązują ciaśniejsze limity recenzentów, czasu, użycia lub kosztu; pomocnicze mechanizmy dzielą ten budżet.

Jeżeli nie istnieje wiarygodny ewaluator, utwórz najmniejszy weryfikator w dozwolonym zakresie albo wskaż brakujący warunek. Nie zastępuj oczekiwanego rezultatu łatwym wskaźnikiem zastępczym. Jeżeli baza już spełnia cel, potwierdź to i zakończ bez spekulacyjnych edycji.

## Skalibruj ewaluator [#calibrate-the-evaluator]

Wybierz właściwą ścieżkę. Zachowaj stałe wejścia w porównywalnych rundach:

| Ścieżka | Baza i dowód |
|---|---|
| Wykonywalna poprawność/ewaluacja | Odtwórz reprezentatywne błędy i zachowaj prawidłowe przypadki kontrolne. Zamroź asercje, oczekiwane odpowiedzi i obsługiwane trasy. W miarę możliwości zachowaj wydzielone przypadki do potwierdzenia. |
| Wydajność/zasoby | Zastosuj [protokół eksperymentów optymalizacyjnych](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/REFERENCE.md#optimization-experiments): identyczne obciążenie i środowisko, pomiary parami, szum oraz ograniczenia zgodności względem oryginału i bieżącego wariantu odniesienia. |
| Jakość wizualna | Zarejestruj oryginał, kandydata i przydatne produkty referencyjne w porównywalnym widoku, danych, obszarze widocznym, powiększeniu, motywie i stanie interakcji. Wybierz kategorie istotne dla zadania, takie jak hierarchia, czytelność i informacja zwrotna. Zachowaj bramki zachowania i dostępności. |

Dla upoważnionych niezależnych recenzji wizualnych użyj świeżych kontekstów z tymi samymi artefaktami, kryteriami, intencją, ograniczeniami, wynikami kontroli i otwartymi ustaleniami. Nie ujawniaj pożądanej oceny liczbowej, wcześniejszych ocen ani preferowanego zwycięzcy. W miarę możliwości używaj neutralnych etykiet kandydatów. Żądaj porównań opartych na dowodach i konkretnych usterek. Oceny liczbowe podawaj wyłącznie na żądanie i traktuj je zawsze jako pomocnicze. Samoocena w głównym kontekście nie jest ani ślepa, ani niezależna.

Oceń ponownie niezmieniony punkt odniesienia, aby wykryć dryf sędziego. Jeśli niezmienione wejścia otrzymują istotnie różne oceny, zbadaj to lub zgłoś niepewność zamiast ogłaszać zwycięstwo. Naprawa ewaluatora albo zmiana kryteriów, danych testowych, modelu lub środowiska rozpoczyna porównanie z nową bazą. Nie łącz jego ocen ze starym trendem i nie osłabiaj testów, aby uzyskać wynik pozytywny.

## Wspinaj się [#climb]

1. **Postaw hipotezę:** wybierz jedno potwierdzone wąskie gardło lub konkretną wadę jakości. Przewidź, jak mała odwracalna zmiana poprawi cel bez naruszenia ograniczeń.
2. **Zmień:** wykonaj wyłącznie tę interwencję we właściwym przepływie pracy. Zachowaj możliwość odzyskania bieżącego wariantu odniesienia. Nie edytuj wejść objętych oceną podczas pracy recenzentów.
3. **Oceń:** uruchom właściwe kontrole i zamrożony ewaluator dla dokładnie tego kandydata. Wykorzystuj ważne dowody. Uczciwie zapisuj nieważne próbki, błędy i niedostępny zakres oceny.
4. **Zachowaj albo wycofaj:** zaakceptuj tylko wartościową, udowodnioną poprawę z zachowaniem ograniczeń względem oryginału i bieżącego wariantu odniesienia. Wycofuj tylko własne zmiany przegranego eksperymentu. Zachowaj wcześniejsze udowodnione poprawy i cudzą pracę. Remis, zaszumione oceny i brak wyników nie oznaczają poprawy.
5. **Zapisz:** prowadź zwięzły rejestr rund: tożsamość kandydata, hipoteza, dowody/różnica, wynik ograniczeń, zachowanie/wycofanie i otwarte ustalenia. Użyj ignorowanego lub tymczasowego miejsca tylko wtedy, gdy przebieg tego wymaga. Nie twórz rutynowych zrzutów audytu ani osobnych PR-ów dla każdej rundy.

Zakończ wcześniej po potwierdzonej akceptacji, wyczerpaniu budżetu, dwóch kolejnych kandydatach bez poprawy albo przy zewnętrznej blokadzie lub decyzji zastrzeżonej dla właściciela. Wyższa ocena sama nie rozwiązuje istotnej usterki. Zastój lub wyczerpanie budżetu oznacza nieosiągnięty cel, nie akceptację. Zachowaj i opisz najlepszego zweryfikowanego kandydata, zamiast po cichu rozszerzać zakres lub podnosić cel.

Dla optymalizacji promptów lub opisów narzędzi najpierw potwierdź poprawność zachowania we wszystkich zadeklarowanych trasach. Następnie zamroź przechodzący zestaw testów jako ograniczenie i stopniowo zmniejszaj kontekst. Ponawiaj przypadki kontrolne i wydzielone. Oddziel te etapy; krótsze instrukcje pogarszające wybór narzędzi przegrywają. Użyj [pisania dla agentów](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL.md). Zmiany trasowania modeli lub kontekstu zachowują [bramkę ewaluacji efficient frontier](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/SKILL.md#promotion).

## Potwierdź i przekaż wynik [#confirm-and-hand-off]

Potwierdź wynik nową, z góry ustaloną partią ewaluacji, a nie wyłącznie zwycięskimi próbkami eksploracyjnymi. Powtórz odpowiednie kontrole funkcjonalne i wizualne oraz porównaj z oryginałem. Jawnie wskaż brak niezależnego pokrycia. Konsensus lub docelowa ocena nie zastępuje weryfikacji ani zgody człowieka.

Podaj wynik i stan celu, dowody od oryginału do końcowego wariantu, zachowane i wycofane eksperymenty, pozostałe ograniczenia oraz powód zakończenia pętli. Kontynuuj do punktu końcowego użytkownika poprzez istniejącego właściciela dostarczenia. Sam hill-climb nie daje zgody na PR, scalanie, wdrożenie ani monitoring.

Źródło: [omówienie Theo](https://x.com/theo/status/2118465321032106235), 13:04–20:44 (porównania i dryf ocen), 26:21–30:27 (najpierw ewaluacja, potem kompresja).
