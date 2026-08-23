---
title: /review
description: >-
  Przegląd różnic pod kątem potwierdzonych dowodami defektów produktu i
  inżynierii wprowadzonych przez te różnice. Używaj dla gałęzi, PR-ów, wersji
  roboczych lub szczegółowych audytów wydań.
type: skill
sidebar:
  label: /review
---
![Diagram umiejętności /review](/diagrams/skills/review.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/review.excalidraw)

Utwórz artefakt diagnostyczny od stałego punktu do `HEAD`. Nie edytuj, nie zatwierdzaj, nie wysyłaj,
nie odpowiadaj, nie rozwiązuj ani nie publikuj komentarzy, chyba że użytkownik wyraźnie poprosi o publikację.
Zachowaj jednego właściciela w głównym kontekście; agenci wymagają jawnego delegowania.
## Kontrakt przeglądu
- **Cel**: ustalić, czy różnice osiągają oczekiwany rezultat bez
  wiarygodnego defektu.
- **Zasady ochronne**: zgłaszaj tylko praktyczne ustalenia dotyczące problemów wprowadzonych przez różnice; oddzielaj udokumentowane
  standardy od braków produktu lub specyfikacji; traktuj wygenerowane pliki jako dowody, a nie cele
  edycji.
- **Weryfikacja**: powiąż twierdzenia ze źródłem. Samodzielnie przetestuj każdą możliwą do uruchomienia zmianę przez jej
  rzeczywisty punkt wejścia; testy automatyczne są dowodami pomocniczymi, a nie dowodami wynikającymi z praktycznego użycia.
- **Warunek zakończenia**: każda właściwa powierzchnia została uwzględniona, a każde ustalenie ma dowody,
  konsekwencje, priorytet i konkretną poprawkę.
Jeśli brakuje stałego punktu, zapytaj, względem czego przeprowadzić przegląd. W przeciwnym razie najpierw określ bieżącą warstwę PR-u; dla stosu PR-ów wybiera to element nadrzędny przed zdalną gałęzią główną:
```bash
BASE=$(PR_BASE_REF="${REVIEW_BASE:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")
git diff "$BASE"...HEAD
git log "$BASE"..HEAD --oneline
```
## Pętla dowodowa
**zbadaj -> zweryfikuj -> sklasyfikuj -> podsumuj.**
### Zbadaj
1. Przeczytaj żądanie lub specyfikację, instrukcje repozytorium, pełne różnice i odpowiednie
   miejsca wywołań. Nie ufaj podsumowaniu PR-u bardziej niż kodowi.
2. Dla każdego zmienionego założenia prześledź je wstecz do wiarygodnych źródeł w odpowiednich
   producentach, typach lub schematach, pamięci, odbiorcach i powierzchniach publicznych. Wyszukuj według pojęcia domenowego,
   pola danych i emitowanej wartości, a nie tylko zmienionego symbolu.
3. Sprawdzaj zaskakujące twierdzenia na podstawie niezależnych artefaktów w odpowiednim niezmienionym kodzie, bieżącej bazie,
   najnowszej historii, danych testowych lub wynikach działania. Traktuj komentarze w różnicach jako hipotezy, a nie dowody.
4. Porównaj dane testowe z kształtem danych produkcyjnych i skonstruuj jeden kontrprzykład behawioralny, który
   odróżnia zamierzone pole lub stan od prawdopodobnej kolizji w innym miejscu.
   Zmapuj uprawnienia i widoczne powierzchnie; pomijaj styl kontrolowany przez program formatujący i istniejące wcześniej defekty.
5. Zapytaj, co nadal może być nieprawidłowe, jeśli testy przechodzą, a kod wydaje się zgodny z żądaniem.
### Zweryfikuj
- Odtwórz twierdzenia na podstawie źródła, schematu, bieżącej podstawowej dokumentacji lub najmniejszego
  możliwego do wykonania sprawdzenia.
- Na reprezentatywnych danych o skali produkcyjnej wykonaj zamierzoną ścieżkę oraz jedną wiarygodną ścieżkę błędu lub odzyskiwania.
  Samodzielnie obserwuj konsolę, sieć, logi i czas odpowiedzi; testy nigdy nie zastępują użycia.
- Gdy nie istnieje bezpieczne środowisko uruchomieniowe, wskaż blokadę i potrzebne dowody; pozostaw
  zachowanie jako niezweryfikowane, zamiast wnioskować o powodzeniu.
- Sprawdź rzetelność testów: zachowanie publiczne, prawidłowe niepowodzenie przed poprawką, znaczące
  asercje, brak osłabionego pokrycia oraz brak niestabilnego oczekiwania przez określony czas.
- Oceń każdy mechanizm pomocniczy, gałąź, zależność, opcję i plik pod kątem wymaganego zachowania,
  gęstości semantycznej, przejrzystości domenowej, wiarygodnego ryzyka i wykazanej skali.
Preferuj sprzeczności między granicami systemu ponad lokalne dopracowanie.
Nigdy nie optymalizuj liczby wierszy kodu ani nie nagradzaj nadmiernie skróconego kodu; zachowaj przejrzystość przez ograniczanie liczby pojęć.

Stosuj kontrolę właściwą dla danej powierzchni tylko wtedy, gdy różnice dostarczają ku temu dowodów:
| Powierzchnia | Sprawdzenie |
|---|---|
| Interfejs użytkownika, CLI lub raport dla klienta | Wyrenderowane zachowanie, kluczowe stany, treść, klawiatura i dostępność, konsola, odpowiedni obszar roboczy |
| Bezpieczeństwo, prywatność lub utrata danych | Granica zaufania, autoryzacja, dane poufne, wstrzykiwanie, ścieżki nieodwracalne i odzyskiwania |
| API, schemat, SQL lub PostgreSQL | Zgodność, semantyka zasobów, bezpieczeństwo migracji, wygenerowane dane wyjściowe, rzeczywisty dialekt |
| Go, współbieżność lub przepływy pracy | Własność, anulowanie, błędy, wyścigi, ponowienia, idempotencja |
| Zależność lub zewnętrzne API | Bieżąca podstawowa dokumentacja, zgodność wersji, plik blokady, ostrzeżenia |

### Sklasyfikuj

Każde ustalenie musi być wprowadzone przez różnice; wpływać na użytkownika lub naruszać kontrakt;
być odtwarzalne albo poparte konkretną ścieżką; umieszczone przy najbardziej precyzyjnym zmienionym wierszu; oraz
powiązane z najmniejszą bezpieczną poprawką i poleceniem weryfikacyjnym.

- **P0**: ekspozycja blokująca scalanie, utrata danych, awaria, niemożliwy do wykonania główny przepływ lub brak
  wymaganego zachowania.
- **P1**: defekt dotykający typowego użytkownika, regresja, naruszony kontrakt lub specyfikacja, fałszywy sukces albo poważny
  problem z dostępnością.
- **P2**: użyteczna, ograniczona poprawka o mniejszym wpływie.
- **P3**: opcjonalna przyszła zmiana lub dopracowanie; domyślnie pomijaj w komentarzach wbudowanych.

Nie zgłaszaj problemu z wydajnością bez pomiaru lub ograniczenia strukturalnego. Nie zgłaszaj przypadku brzegowego
bez wiarygodnego ryzyka. Uzasadnione odrzucenie poparte dowodami jest prawidłowym wynikiem.

### Podsumuj

Zacznij od ustaleń. Usuwaj duplikaty według głównej przyczyny i zachowuj najwyższy
uzasadniony priorytet. Każde ustalenie zawiera tylko konkretną ścieżkę, wpływ, najmniejszą
poprawkę i sposób weryfikacji. Nie powtarzaj różnic ani kodu, nie chwal autora i nie
opisuj przebiegu przeglądu. Przy ponownym przeglądzie oznacz wcześniejsze ustalenia jako
naprawione, otwarte lub już niemające zastosowania.

## Tryb szczegółowy

Dla `/review --deep` lub audytu wydania o wysokiej wadze użyj tej samej pętli z kompletnym rejestrem zastosowania.
Dodaj granice strukturalne, narzędzia bezpieczeństwa i zależności, każdą
zmienioną powierzchnię publiczną oraz dokładne dowody weryfikacji. Przeczytaj
[DEEP-AUDIT.md](https://github.com/malinskibeniamin/skills/blob/main/review/DEEP-AUDIT.md); nie dodawaj automatycznych agentów, paneli modeli ani łańcuchów umiejętności.

## Wynik

Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/review/REFERENCE.md), aby poznać słownictwo priorytetów i schemat gotowy do użycia w komentarzu.
Zgłoś `[P0|P1|P2] <file:line> <title> - <evidence, consequence, correction, verify command>`.
Następnie dodaj `entrypoint, data, actions, observations, timing, limits`, stały punkt,
tryb, liczbę ustaleń, werdykt i pozostałe ograniczenia.

Przy czystym przeglądzie zwróć tylko werdykt i pozostałe ograniczenia.
Publikowanie komentarzy wymaga wyraźnej intencji użytkownika; w przeciwnym razie zwróć
tekst gotowy do użycia w komentarzu.
