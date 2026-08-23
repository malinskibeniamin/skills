---
title: /to-tickets
description: >-
  Podziel plan lub specyfikację na zgłoszenia typu tracer bullet z zależnościami
  blokującymi.
type: skill
sidebar:
  label: /to-tickets
---
![Diagram umiejętności /to-tickets](/diagrams/skills/to-tickets.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/to-tickets.excalidraw)

Podziel plan, specyfikację lub rozmowę na zestaw **zgłoszeń** — pionowych przekrojów typu tracer bullet, z których każdy wskazuje blokujące go zgłoszenia.
Najpierw odczytaj `CLAUDE.md`, jeśli istnieje; w przeciwnym razie odczytaj `AGENTS.md`. Instrukcje dotyczące systemu śledzenia zgłoszeń znajdź przez odnośnik **Issue tracker** w tym pliku; nigdy nie zakładaj ścieżki do dokumentu. Jeśli nie istnieje ani plik, ani odnośnik, uruchom `/work-automation-kit` lub użyj jego lokalnego wariantu opartego na plikach Markdown.
## Proces
### 1. Zbierz kontekst
Pracuj na podstawie informacji dostępnych już w kontekście rozmowy. Jeśli użytkownik przekaże jako argument odwołanie (ścieżkę do specyfikacji, numer zgłoszenia lub adres URL), pobierz je i przeczytaj całą treść wraz z komentarzami.
### 2. Przeanalizuj bazę kodu (opcjonalnie)
Jeśli baza kodu nie została jeszcze przeanalizowana, zrób to, aby poznać jej obecny stan. Tytuły i opisy zgłoszeń powinny używać słownictwa z glosariusza domenowego projektu oraz uwzględniać dokumenty ADR dotyczące modyfikowanego obszaru.
Szukaj możliwości wstępnej refaktoryzacji kodu, która ułatwi implementację. „Najpierw ułatw zmianę, a potem wprowadź łatwą zmianę”.
### 3. Przygotuj pionowe przekroje
Podziel pracę na zgłoszenia typu **tracer bullet**.
<vertical-slice-rules>
- Każdy przekrój obejmuje wąską, ale kompletną ścieżkę przez wszystkie warstwy (schemat, API, interfejs użytkownika, testy) — jest pionowy, a nie poziomy w obrębie jednej warstwy
- Ukończony przekrój można niezależnie zademonstrować lub zweryfikować
- Każdy przekrój mieści się w jednym nowym oknie kontekstu
- Wszelką wstępną refaktoryzację należy wykonać najpierw
</vertical-slice-rules>
Określ **zależności blokujące** każdego zgłoszenia — inne zgłoszenia, które muszą zostać ukończone, zanim będzie można rozpocząć to zgłoszenie. Zgłoszenie bez blokad można rozpocząć natychmiast.
**Rozległe refaktoryzacje stanowią wyjątek** od pionowego podziału. Gdy jedna mechaniczna zmiana obejmuje całą bazę kodu i żaden wąski przekrój nie może samodzielnie zachować poprawności, zastosuj sekwencję expand-contract: **rozszerz**, dodając nową postać obok starej, **zmigruj** wywołania w niezależnie poprawnych partiach, a następnie **zredukuj**, usuwając starą postać po zakończeniu wszystkich migracji. Każda partia migracji jest blokowana przez rozszerzenie; redukcja jest blokowana przez wszystkie partie migracji. Jeśli partie migracji nie mogą samodzielnie zachować poprawności, użyj gałęzi integracyjnej i ustaw je wszystkie jako blokujące końcowe zgłoszenie integracji i weryfikacji.
Jeśli po przeglądzie nadal istnieją konkurencyjne grafy zgłoszeń lub strategie podziału, uruchom `/plan-arbiter`; w przypadku dużego grafu zależności opublikuj `/visual-plan`, aby można było przeanalizować blokady i front prac.
### 4. Skonsultuj podział z użytkownikiem
Przedstaw proponowany podział jako listę numerowaną. Dla każdego zgłoszenia podaj:
- **Tytuł**: krótka, opisowa nazwa
- **Blokowane przez**: które inne zgłoszenia (jeśli istnieją) muszą zostać ukończone jako pierwsze
- **Co dostarcza**: kompleksowe zachowanie uruchamiane przez to zgłoszenie
Zapytaj użytkownika:
- Czy poziom szczegółowości jest odpowiedni? (zbyt ogólny / zbyt szczegółowy)
- Czy zależności blokujące są poprawne — czy każde zgłoszenie zależy wyłącznie od zgłoszeń, które rzeczywiście je warunkują?
- Czy należy połączyć któreś zgłoszenia lub podzielić je bardziej szczegółowo?
Powtarzaj ten proces, aż użytkownik zatwierdzi podział.
### 5. Opublikuj zgłoszenia w skonfigurowanym systemie śledzenia
Opublikuj zatwierdzone zgłoszenia. **Sposób** zależy od systemu śledzenia wskazanego przez odnośnik w instrukcjach agenta — zgłoszenia pozostają takie same, zmienia się jedynie forma zależności blokujących:
- **Pliki lokalne** → zapisz osobny plik dla każdego zgłoszenia w `.scratch/<feature-slug>/tickets/<NN>-<slug>.md`, numerując od `01` w kolejności zależności (najpierw blokady). Pole „Blokowane przez” w każdym pliku zawiera numery i tytuły zgłoszeń, od których zależy dane zgłoszenie. Użyj poniższego szablonu dla każdego zgłoszenia; nigdy nie łącz wielu zgłoszeń w jednym pliku.
- **Rzeczywisty system śledzenia zgłoszeń (GitHub, Linear, ...)** → opublikuj osobne zgłoszenie dla każdego elementu w kolejności zależności (najpierw blokady), aby zależności blokujące mogły odwoływać się do rzeczywistych identyfikatorów. Użyj natywnej relacji podzgłoszeń danej platformy dla zgłoszenia nadrzędnego oraz natywnej relacji blokowania dla blokad, jeśli są dostępne; w przeciwnym razie w polu „Blokowane przez” każdego zgłoszenia wskaż zgłoszenia blokujące. Zastosuj etykietę klasyfikacyjną `ready-for-agent`, o ile instrukcje nie stanowią inaczej — zgłoszenia z założenia mogą być podejmowane przez agentów.
Nie zamykaj ani nie modyfikuj żadnego zgłoszenia nadrzędnego.
Realizuj **front prac**: każde zgłoszenie, którego wszystkie blokady zostały ukończone. W przypadku całkowicie liniowego łańcucha oznacza to pracę od góry do dołu.
<local-ticket-template>
# <NN> — <Tytuł zgłoszenia>
**Co zbudować:** kompleksowe zachowanie uruchamiane przez to zgłoszenie z perspektywy użytkownika — nie lista implementacji według warstw.
**Blokowane przez:** numery i tytuły zgłoszeń, które warunkują rozpoczęcie tego zgłoszenia, lub „Brak — można rozpocząć natychmiast”.
**Status:** ready-for-agent
- [ ] Kryterium akceptacji 1
- [ ] Kryterium akceptacji 2
</local-ticket-template>
<issue-template>
## Zgłoszenie nadrzędne
Odwołanie do zgłoszenia nadrzędnego w systemie śledzenia (jeśli źródłem było istniejące zgłoszenie; w przeciwnym razie pomiń tę sekcję).
## Co zbudować
Kompleksowe zachowanie uruchamiane przez to zgłoszenie z perspektywy użytkownika — nie implementacja opisana warstwa po warstwie.
## Kryteria akceptacji
- [ ] Kryterium 1
- [ ] Kryterium 2
## Blokowane przez
- Odwołanie do każdego zgłoszenia blokującego lub „Brak — można rozpocząć natychmiast”.
</issue-template>
W obu formach unikaj konkretnych ścieżek do plików i fragmentów kodu — szybko stają się nieaktualne. Wyjątek: jeśli umiejętność `/prototype` utworzyła kod, który opisuje decyzję precyzyjniej niż proza (maszyna stanów, reduktor, schemat, kształt typu), dodaj odwołanie kontekstowe do lokalizacji tego kodu zamiast umieszczać go bezpośrednio w treści.
