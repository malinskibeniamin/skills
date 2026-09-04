---
title: /create-verification-skill
description: >-
  Utwórz lokalną dla projektu umiejętność, która uruchamia rzeczywistą
  aplikację, steruje nią, obserwuje ją i po sobie sprząta. Użyj, gdy
  repozytorium nie zapewnia powtarzalnego sposobu weryfikacji działania
  interfejsu użytkownika, CLI, API lub usługi.
type: skill
sidebar:
  label: /create-verification-skill
---
![Diagram umiejętności /create-verification-skill](/diagrams/skills/create-verification-skill.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/create-verification-skill.excalidraw)

Wygeneruj jeden lokalny dla projektu weryfikator, który następny agent będzie mógł uruchomić bez wcześniejszego kontekstu. Użyj istniejącego w repozytorium kanonicznego katalogu głównego umiejętności; w przeciwnym razie użyj domyślnie `.agents/skills/verify-<app>/`. Nigdy nie kopiuj umiejętności do kilku katalogów głównych przeznaczonych dla konkretnych hostów.

## Zbadaj repozytorium

Najpierw zbadaj, potem pytaj:

- **Powierzchnia:** główny punkt wejścia użytkownika oraz wszelkie dodatkowe powierzchnie: interfejs użytkownika, CLI, API, aplikacja mobilna, aplikacja komputerowa lub biblioteka.
- **Uruchamianie:** natywne dla repozytorium polecenie, sygnał gotowości, porty, środowisko, dane początkowe i uwierzytelnianie.
- **Sterowanie:** istniejący harness Playwright, PTY, HTTP, debugowania lub aplikacji przed użyciem narzędzia ogólnego przeznaczenia.
- **Obserwacja:** zrzuty ekranu, migawki dostępności, transkrypcje, odpowiedzi, dzienniki, kody zakończenia i trwałe skutki uboczne.
- **Izolacja:** osobne dla każdego uruchomienia porty, profile, katalogi danych i dane testowe. Odmów sterowania współdzieloną instancją używaną przez człowieka.

Kopia robocza, której nie można uruchomić, jest przeszkodą, a nie podstawą do wymyślania instrukcji. Zgłoś dokładny niespełniony warunek wstępny.

## Wygeneruj

Utwórz `SKILL.md` z frontmatter zawierającym pasujące `name: verify-<app>` oraz konkretne sekcje **Uruchamianie**, **Diagnostyka**, **Sterowanie**, **Dowody** i **Czyszczenie**:

- **Uruchamianie:** dokładne polecenia uruchamiania i zamykania oraz możliwy do zaobserwowania warunek gotowości.
- **Diagnostyka:** jedna kontrola tylko do odczytu obejmująca tożsamość aplikacji, kompilację, właściciela procesu lub portu, izolację danych i uwierzytelnianie.
- **Sterowanie:** dosłowne polecenia i stabilne uchwyty z tego repozytorium. Preferuj role, dostępne nazwy, trasy, teksty monitów i publiczne interfejsy API zamiast współrzędnych lub elementów wewnętrznych.
- **Dowody:** zarejestruj działanie i wynikowy stan. Zweryfikuj skutki uboczne za pomocą drugiego publicznego widoku. Atrapy są dozwolone wyłącznie na istniejącej granicy produkcyjnej.
- **Czyszczenie:** zatrzymaj tylko procesy i usuń tylko dane tymczasowe utworzone w tym uruchomieniu. Nigdy nie kończ procesów na podstawie ich nazwy. Dowody muszą przetrwać czyszczenie.

Udokumentuj sposób uruchamiania każdego dołączonego narzędzia pomocniczego i nadaj wykonywalnym narzędziom pomocniczym uprawnienia do wykonywania.

## Przygotuj mapę funkcji

Utwórz `features/README.md` oraz po jednym pliku dla każdej z 3–5 najważniejszych funkcji dostępnych dla użytkownika. Zacznij od [przykładu mapy funkcji](https://github.com/malinskibeniamin/skills/blob/main/create-verification-skill/references/feature-map-example/README.md), a następnie zastąp każdy przykład dowodami z repozytorium. Każda funkcja zawiera:

1. `Podfunkcje`
2. `Jak do niej dotrzeć (z perspektywy użytkownika)`
3. `Sterowanie za pomocą <harness>`
4. `Pułapki`

Mapuj każdy rzeczywisty punkt wejścia osobno; zweryfikowanie wygodnej ścieżki nie obejmuje innej ścieżki.

## Udowodnij działanie wygenerowanej umiejętności

Wykonaj wygenerowaną umiejętność od początku do końca: uruchom aplikację, przeprowadź diagnostykę, przetestuj jedną zmapowaną funkcję przez rzeczywistą ścieżkę użytkownika, zbierz dowody i posprzątaj. Po wyczyszczeniu potwierdź, że dowody nadal istnieją oraz że nie pozostał żaden utworzony proces ani stan. Popraw niedziałające instrukcje i powtórz całą ścieżkę. Niewykonany weryfikator jest jedynie wersją roboczą.

W przypadku późniejszych audytów rozbieżności wskaż `/maintain-verification-skill`, a w przypadku zwykłej pracy nad funkcjami — `/dogfood`.
