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

Załaduj tylko właściwych [właścicieli](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies); zachowaj jedną pętlę i wspólny budżet:

- [Cykl rozwoju](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/SKILL.md) odpowiada za implementację i dostarczenie. Raporty, plany i recenzje nie zmieniają źródeł, poza zamówionymi artefaktami planu; [improve](https://github.com/malinskibeniamin/skills/blob/main/improve/SKILL.md) może zalecić wspinaczkę bez jej rozpoczynania.
- [Quantify impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md) odpowiada za metryki, minimalne wartościowe różnice i szum.
- Dla UI [przegląd wizualny](https://github.com/malinskibeniamin/skills/blob/main/visual-review/SKILL.md) odpowiada za dowody z renderowania i dobór specjalistycznych wskazówek; [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md) sprawdza rzeczywiste zachowanie oraz awarię i odzyskiwanie.
- Tylko po wyraźnym upoważnieniu [council](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/council/SKILL.md) lub [sol-loop](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/sol-loop/SKILL.md) dostarcza rundy recenzji tylko do odczytu zgodnie ze [zgodnością z hostem](https://github.com/malinskibeniamin/skills/blob/main/shared/TSTACK.md#review-evidence-for-council-and-sol-loop). Samo załadowanie hill-climb nie daje zgody na delegowanie. Bez niej oceniaj w głównym kontekście i tak oznacz ocenę. [Efficient frontier](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/SKILL.md) odpowiada za upoważniony dobór modeli i dostępną pojemność.

## Zdefiniuj cel wspinaczki przed edycją [#define-the-hill-before-editing]

Użyj istniejącego kontraktu zadania lub krótkiej notatki w bieżącym kontekście:

- **Cel:** beneficjent, oczekiwany rezultat, główna metryka lub nazwane kategorie oceny, warunek akceptacji i minimalna wartościowa poprawa. Sama liczba nie stanowi wartości.
- **Ograniczenia:** chronione zachowanie, dostępność, bezpieczeństwo, dozwolony zakres edycji i limity zasobów. Zachowaj niezwiązane zmiany oraz pierwotny punkt końcowy użytkownika.
- **Weryfikacja:** polecenie ewaluatora lub protokół wizualny, dane testowe, środowisko, pierwotna rewizja i najlepszy potwierdzony kandydat, czyli bieżący wariant odniesienia. Zachowaj oba punkty odniesienia.
- **Koniec:** punkt końcowy, skończony budżet ewaluacji i zasobów oraz reguła zatrzymania przy braku postępu. Domyślnie wykonaj najwyżej trzy próby kandydatów, zaakceptowane lub nie; jedna interwencja liczy się raz niezależnie od liczby plików. Pomiary bazy, ponowienia i potwierdzenie zużywają budżet ewaluacji i zasobów. Przed każdą próbą zarezerwuj środki na potwierdzenie; jeśli ich nie wystarczy, zakończ poszukiwanie. Ciaśniejsze limity użytkownika, recenzentów i hosta nadal obowiązują. Nowa baza nie zeruje liczników.

Jeżeli nie istnieje wiarygodny ewaluator, utwórz najmniejszy weryfikator w dozwolonym zakresie albo wskaż brakujący warunek. Nie zastępuj oczekiwanego rezultatu łatwym wskaźnikiem zastępczym. Jeżeli baza już spełnia cel, potwierdź to i zakończ bez spekulacyjnych edycji.

## Skalibruj ewaluator [#calibrate-the-evaluator]

Wybierz właściwą ścieżkę. Zachowaj stałe wejścia w porównywalnych rundach:

| Ścieżka | Baza i dowód |
|---|---|
| Wykonywalna poprawność/ewaluacja | Odtwórz reprezentatywne błędy i zachowaj prawidłowe przypadki kontrolne. Zamroź asercje, oczekiwane odpowiedzi i obsługiwane trasy. W miarę możliwości zachowaj wydzielone przypadki do potwierdzenia. |
| Wydajność/zasoby | Zastosuj [protokół eksperymentów optymalizacyjnych](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/REFERENCE.md#optimization-experiments): identyczne obciążenie i środowisko, pomiary parami, szum oraz ograniczenia zgodności względem oryginału i bieżącego wariantu odniesienia. |
| Jakość wizualna | Zastosuj [kalibrację wizualną](https://github.com/malinskibeniamin/skills/blob/main/visual-review/REFERENCE.md#review-calibration). Zarejestruj oryginał, kandydata i żądane produkty referencyjne w porównywalnych stanach; zachowaj intencję projektu oraz bramki zachowania i dostępności. |

Dla upoważnionych niezależnych recenzji wizualnych użyj świeżych kontekstów z tymi samymi artefaktami, kryteriami, intencją, ograniczeniami, wynikami kontroli i otwartymi ustaleniami. Nie ujawniaj pożądanej oceny liczbowej, wcześniejszych ocen ani preferowanego zwycięzcy. W miarę możliwości używaj neutralnych etykiet kandydatów. Żądaj porównań opartych na dowodach i konkretnych usterek. Oceny liczbowe podawaj wyłącznie na żądanie i traktuj je zawsze jako pomocnicze. Samoocena w głównym kontekście nie jest ani ślepa, ani niezależna.

Tylko gdy żądana polityka przeglądu dopuszcza etapowanie, użyj upoważnionego sędziego do wstępnej oceny przed pełnym panelem. Zarezerwuj środki dla każdego wymaganego recenzenta końcowego na tym samym kandydacie. Jawnie oznacz wyniki niewykonane, niedostępne lub nieaktualne; nie traktuj ich jako zgody. Etapowanie nie upoważnia do zmiany dostawców ani osłabienia końcowego zakresu oceny.

Oceń ponownie niezmieniony punkt odniesienia, aby wykryć dryf sędziego. Jeśli niezmienione wejścia otrzymują istotnie różne oceny, zbadaj to lub zgłoś niepewność zamiast ogłaszać zwycięstwo. Naprawa ewaluatora albo zmiana kryteriów, danych testowych, modelu lub środowiska rozpoczyna porównanie z nową bazą. Nie łącz jego ocen ze starym trendem i nie osłabiaj testów, aby uzyskać wynik pozytywny. Skalibruj nowego lub zastępującego, upoważnionego sędziego na niezmienionych punktach odniesienia; przechowuj wyniki każdego sędziego oddzielnie.

## Wspinaj się [#climb]

1. **Postaw hipotezę:** wybierz jedno potwierdzone wąskie gardło lub konkretną wadę jakości. Przewidź, jak mała odwracalna zmiana poprawi cel bez naruszenia ograniczeń.
2. **Zmień:** wykonaj wyłącznie tę interwencję we właściwym przepływie pracy. Zachowaj możliwość odzyskania bieżącego wariantu odniesienia. Nie edytuj wejść objętych oceną podczas pracy recenzentów.
3. **Oceń:** uruchom właściwe kontrole i zamrożony ewaluator dla dokładnie tego kandydata. Wykorzystuj ważne dowody. Uczciwie zapisuj nieważne próbki, błędy i niedostępny zakres oceny.
4. **Potwierdź, potem zachowaj:** wartościowa poprawa przekraczająca szum i spełniająca ograniczenia względem oryginału i bieżącego wariantu odniesienia jest prowizoryczna, dopóki nie potwierdzi jej świeża, z góry ustalona partia ewaluacji. Dopiero wtedy zaktualizuj bieżący wariant odniesienia. Nieudane lub niejednoznaczne potwierdzenie odrzuca próbę; wycofuj tylko jej własne zmiany, zachowując potwierdzony wariant odniesienia i cudzą pracę. Remis i brak wyników nie oznaczają poprawy.
5. **Zapisz:** prowadź zwięzły rejestr rund: tożsamość kandydata, hipoteza, dowody/różnica, wynik ograniczeń, zachowanie/wycofanie, pozostały budżet i otwarte ustalenia. Użyj ignorowanego lub tymczasowego miejsca tylko wtedy, gdy przebieg tego wymaga. Nie twórz rutynowych zrzutów audytu ani osobnych PR-ów dla każdej rundy.

Zakończ po potwierdzonej akceptacji, wyczerpaniu budżetu, dwóch kolejnych kandydatach bez poprawy albo przy zewnętrznej blokadzie lub decyzji zastrzeżonej dla właściciela.

Podniesienie celu przez właściciela wymaga nowego, jawnego kontraktu. Zachowaj wcześniejszy wynik i zapis budżetu zamiast po cichu zwiększać wymagania albo tworzyć kolejny PR lub worktree.

| Dowód przy zakończeniu | Raport |
|---|---|
| Aktualne potwierdzenie spełnia cel i wszystkie ograniczenia | `met`; zachowaj potwierdzony wariant odniesienia. |
| Prawidłowe ewaluacje nie osiągają celu przed limitem lub zastojem | `unmet`; zachowaj najlepszy potwierdzony wariant, nie ostatnią próbę. |
| Brakujący lub nieprawidłowy ewaluator, dryf albo niedostępny wymagany zakres oceny | `unverified`; zachowaj wariant odniesienia i wskaż brakujący dowód. |

Wyższa ocena nie rozwiązuje istotnej usterki. Każdy żądany cel dla kategorii i rankingu względem referencji oceniaj oddzielnie; średnia ogólna nie może ukryć niespełnionego celu. Zachowaj pierwotny zakres i cel; diagnozuj nieważne ewaluacje zamiast powtarzać ocenę niezmienionego kandydata aż do uzyskania pozytywnego wyniku.

Dla optymalizacji promptów lub opisów narzędzi załaduj [protokół eksperymentu](https://github.com/malinskibeniamin/skills/blob/main/hill-climb/references/tool-description-optimization.md). Potwierdź poprawność przed kompresją; zachowaj zadeklarowaną macierz i zestaw regresji.

## Potwierdź i przekaż wynik [#confirm-and-hand-off]

Wykorzystuj istniejące potwierdzenie tylko dla niezmienionych wejść. Powtórz unieważnione kontrole funkcjonalne i wizualne względem oryginału. Jawnie wskaż brak niezależnego pokrycia; konsensus lub oceny nie zastępują weryfikacji ani zgody człowieka.

Podaj wynik i stan celu, dowody od oryginału do końcowego wariantu, zachowane i wycofane eksperymenty, pozostałe ograniczenia oraz powód zakończenia pętli. Kontynuuj do punktu końcowego użytkownika poprzez istniejącego właściciela dostarczenia. Sam hill-climb nie daje zgody na PR, scalanie, wdrożenie ani monitoring.

Przykłady:
- `/hill-climb improve sidebar readability against the supplied screenshots; preserve keyboard flows; 3 candidates; local only; no delegates`
- `/hill-climb reduce tool-description tokens while preserving the existing tool-choice eval across supported routes; 3 candidates; local only; no delegates`

Źródło: [omówienie Theo](https://x.com/theo/status/2118465321032106235), 06:18-08:09 (pętla recenzji), 11:39-20:44 (porównania wizualne, etapowanie recenzji, dryf ocen), 26:37-30:27 (ewaluacje z rzeczywistych błędów, poprawność przed kompresją). Budżety i granice uprawnień to adaptacje harnessu.
