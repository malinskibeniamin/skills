---
title: /setup-routines
description: >-
  Skonfiguruj procedury Claude Code do przeglądu PR-ów, monitorowania kondycji
  bazy kodu, klasyfikowania zgłoszeń i wykrywania nieaktualnej dokumentacji.
type: skill
sidebar:
  label: /setup-routines
---
![Diagram umiejętności /setup-routines](/diagrams/skills/setup-routines.svg)

[Otwórz edytowalny plik źródłowy Excalidraw](/diagrams/skills/setup-routines.excalidraw)

Skonfiguruj [procedury Claude Code](https://claude.ai/code/routines) — automatyczne sesje hostowane w chmurze, uruchamiane zgodnie z harmonogramem, przez zdarzenia GitHub lub API. Procedury klonują repozytorium i działają jako pełne sesje Claude Code. Hooki i reguły CLAUDE.md automatycznie egzekwują wymagania.

## Jak to działa

```
Routine fires -> clones repo -> SessionStart hooks -> CLAUDE.md loads
-> routine prompt executes -> PostToolUse hooks enforce on every edit
-> Stop hooks run quality gates -> session ends
```

### Model egzekwowania

Hooki stanowią warstwę egzekwowania, a prompty procedur — warstwę zadań. Standardy rozwijają się
w repozytorium (hooki i CLAUDE.md), natomiast prompty procedur pozostają stabilne. Każda sesja
procedury przechodzi te same bramki PostToolUse/Stop co interaktywna sesja programistyczna,
więc procedura nie może wdrożyć kodu, którego programista nie mógłby wdrożyć lokalnie.
W przypadku wyników procedur dodaj kroki audytu `/agent-watchdog`. Dodaj `/visual-recap` tylko wtedy, gdy
żądanie procedury wyraźnie obejmuje ten artefakt.


Procedury są sesjami hostowanymi w chmurze, uruchamianymi zgodnie z harmonogramem, przez webhook lub API —
to cykliczna automatyzacja, która musi działać również po zamknięciu laptopa.

## Dostępne szablony

| Szablon | Wyzwalacz | Działanie |
|---|---|---|
| [pr-review](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/routines/pr-review.md) | `pull_request.opened` | Sprawdza PR pod kątem standardów i publikuje komentarze w kodzie |
| [pr-feedback-resolve](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/routines/pr-feedback-resolve.md) | `pull_request.review_submitted` | Odczytuje nierozwiązane wątki, poprawia kod, odpowiada i oznacza je jako rozwiązane |
| [issue-triage](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/routines/issue-triage.md) | `issues.opened` | Analizuje bazę kodu, klasyfikuje zgłoszenie, dodaje etykiety i publikuje wyniki analizy |
| [weekly-health](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/routines/weekly-health.md) | Harmonogram: co tydzień | Uruchamia kontrole jakości, mierzy odstępstwa i tworzy zgłoszenie z raportem o kondycji projektu |
| [docs-drift](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/routines/docs-drift.md) | Harmonogram: co tydzień | Wykrywa dokumentację zdezaktualizowaną przez ostatnie zmiany i tworzy PR z poprawkami lub zgłoszenie |

## Konfiguracja

### 1. Wymagania wstępne

- Claude Code z dostępem do internetu ([claude.ai/code](https://claude.ai/code))
- Połączone konto GitHub (`/web-setup` w CLI)
- Plan Pro, Max, Team lub Enterprise

### 2. Wybierz procedury

| Jeśli masz | Zalecane procedury |
|---|---|
| Zainstalowane dowolne hooki | pr-review |
| Umiejętność resolve-pr-feedback | pr-feedback-resolve |
| Umiejętność triage | issue-triage |
| Hooki lub skrypty bramek jakości | weekly-health |
| REFERENCE.md lub inną dokumentację | docs-drift |

### 3. Utwórz przez interfejs internetowy (zalecane)

1. [claude.ai/code/routines](https://claude.ai/code/routines) -> **Nowa procedura**
2. Podaj nazwę (na przykład „Przegląd PR — [nazwa repozytorium]”)
3. Wklej szablon z `routines/*.md` — dostosuj symbole zastępcze `OWNER`/`REPO`
4. Wybierz repozytorium i środowisko
5. Dodaj wyzwalacz (zdarzenie GitHub | harmonogram | API)
6. Sprawdź konektory — usuń zbędne
7. Utwórz

### 4. Utwórz przez CLI

```bash
/schedule daily codebase health check at 9am
```

CLI obsługuje wyłącznie procedury zaplanowane. W przypadku wyzwalaczy GitHub lub API użyj interfejsu internetowego.

### 5. Dostosuj prompty

Szablony są punktem wyjścia. Dostosuj:

- **Kontrole specyficzne dla projektu**: wskaż wzorce egzekwowane przez hooki
- **Etykiety**: dopasuj je do systematyki etykiet zgłoszeń
- **Granice zakresu**: „przeglądaj tylko `src/`” lub „pomiń wygenerowane pliki”
- **Działania konektorów**: „opublikuj podsumowanie na kanale #engineering w Slacku”

Przykłady dostosowania i konfigurację wyzwalaczy API znajdziesz w pliku [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/REFERENCE.md).

### 6. Przetestuj

Przed włączeniem wyzwalaczy uruchom procedurę raz ręcznie:

1. Interfejs internetowy: **Uruchom teraz** na stronie szczegółów procedury
2. CLI: `/schedule run`
3. Obserwuj sesję na żywo pod zwróconym adresem URL
4. Sprawdź wynik — jeśli procedura odbiegła od zadania, popraw prompt
Więcej informacji o modelu egzekwowania, konfiguracji wyzwalaczy, API i dostosowywaniu oraz rozwiązywaniu problemów znajdziesz w pliku [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/REFERENCE.md).
