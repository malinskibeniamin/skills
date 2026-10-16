---
description: >-
  Utwórz lokalną dla projektu umiejętność, która uruchamia rzeczywistą
  aplikację, steruje nią, obserwuje ją i po sobie sprząta. Użyj, gdy
  repozytorium nie zapewnia powtarzalnego sposobu weryfikacji działania
  interfejsu użytkownika, CLI, API lub usługi.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - create verification skill
sidebar:
  label: /create-verification-skill
title: /create-verification-skill
type: skill
---
![Diagram umiejętności /create-verification-skill](/diagrams/skills/create-verification-skill.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/create-verification-skill.excalidraw)

Wygeneruj jeden lokalny dla projektu weryfikator, który następny agent będzie mógł uruchomić bez wcześniejszego kontekstu. Użyj istniejącego w repozytorium kanonicznego katalogu głównego umiejętności; w przeciwnym razie użyj domyślnie `.agents/skills/verify-<app>/`. Nigdy nie kopiuj umiejętności do kilku katalogów głównych przeznaczonych dla konkretnych hostów.

## Zbadaj repozytorium [#interview-the-repository]

Najpierw zbadaj, potem pytaj:

- **Powierzchnia:** główny punkt wejścia użytkownika oraz wszelkie dodatkowe powierzchnie: interfejs użytkownika, CLI, API, aplikacja mobilna, aplikacja komputerowa lub biblioteka.
- **Uruchamianie:** natywne dla repozytorium polecenie, sygnał gotowości, porty, środowisko, dane początkowe i uwierzytelnianie.
- **Sterowanie:** istniejący harness Playwright, PTY, HTTP, debugowania lub aplikacji przed użyciem narzędzia ogólnego przeznaczenia.
- **Obserwacja:** zrzuty ekranu, migawki dostępności, transkrypcje, odpowiedzi, dzienniki, kody zakończenia i trwałe skutki uboczne.
- **Izolacja:** osobne dla każdego uruchomienia porty, profile, katalogi danych i dane testowe. Odmów sterowania współdzieloną instancją używaną przez człowieka.

Jeśli kopii roboczej nie można uruchomić, zgłoś niespełniony warunek wstępny zamiast wymyślać instrukcje uruchamiania.

W przypadku ergonomii pracy agentów lub konfiguracji worktree użyj [kontroli brakujących możliwości i zimnego startu](https://github.com/malinskibeniamin/skills/blob/main/create-verification-skill/references/agent-dx.md).

## Wygeneruj [#generate]

Utwórz `SKILL.md` z frontmatter zawierającym pasujące `name: verify-<app>` oraz konkretne sekcje **Uruchamianie**, **Diagnostyka**, **Sterowanie**, **Dowody** i **Czyszczenie**:

- **Uruchamianie:** dokładne polecenia uruchamiania i zamykania, które prowadzą od pustych danych do użytecznej aplikacji, wraz z migracjami i danymi początkowymi. Sam nasłuchujący port lub sprawna baza danych nie oznaczają gotowości.
- **Diagnostyka:** jedna kontrola tylko do odczytu obejmująca tożsamość aplikacji, kompilację, właściciela procesu lub portu, izolację danych i uwierzytelnianie.
- **Sterowanie:** dosłowne polecenia i stabilne uchwyty z tego repozytorium. Preferuj role, dostępne nazwy, trasy, teksty monitów i publiczne interfejsy API zamiast współrzędnych lub elementów wewnętrznych.
- **Dowody:** zarejestruj działanie i wynikowy stan. Zweryfikuj skutki uboczne za pomocą drugiego publicznego widoku. Atrapy są dozwolone wyłącznie na istniejącej granicy produkcyjnej.
- **Czyszczenie:** zatrzymaj tylko procesy i usuń tylko dane tymczasowe utworzone w tym uruchomieniu. Nigdy nie kończ procesów na podstawie ich nazwy. Dowody muszą przetrwać czyszczenie.

Nadaj narzędziom pomocniczym uprawnienia do wykonywania; opisz użycie. Dla błędów zależnych od stanu lub powtarzających się luk reprodukcji udowodnij [zapis i odtwarzanie](https://github.com/malinskibeniamin/skills/blob/main/shared/verification-replay.md) przez natywne interfejsy danych testowych i debugowania.

## Przygotuj mapę funkcji [#seed-the-feature-map]

Utwórz `features/README.md` oraz po jednym pliku dla każdej z 3–5 najważniejszych funkcji dostępnych dla użytkownika. Zacznij od [przykładu mapy funkcji](https://github.com/malinskibeniamin/skills/blob/main/create-verification-skill/references/feature-map-example/README.md), a następnie zastąp każdy przykład dowodami z repozytorium. Każda funkcja zawiera:

1. `Podfunkcje`
2. `Jak do niej dotrzeć (z perspektywy użytkownika)`
3. `Sterowanie za pomocą <harness>`
4. `Pułapki`

Mapuj każdy punkt wejścia. Brak wymaganych danych początkowych oblewa ścieżkę: zapisz go w `Pułapkach`, nigdy nie osłabiaj ścieżki.

## Udowodnij działanie wygenerowanej umiejętności [#prove-the-generated-skill]

Wykonaj wygenerowaną umiejętność: uruchamianie, diagnostykę, jedną zmapowaną rzeczywistą ścieżkę użytkownika, dowody i czyszczenie. Potwierdź, że dowody przetrwały, a utworzone procesy i stan nie pozostały. Posprzątaj po nieudanych próbach, popraw instrukcje i odtwórz ścieżkę. Niewykonany weryfikator jest wersją roboczą.

Wymień luki konfiguracji środowiska zastępczego; pozostają niezweryfikowane do odtworzenia w środowisku docelowym.

Kieruj audyty rozbieżności do `/maintain-verification-skill`, a pracę nad funkcjami do `/dogfood`.
