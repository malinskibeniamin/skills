---
title: /improve-codebase-architecture
description: >-
  Przeprojektuj granice modułów, własność i stan, aby uniemożliwić powtarzające
  się klasy błędów.
type: skill
sidebar:
  label: /improve-codebase-architecture
---
![Diagram umiejętności /improve-codebase-architecture](/diagrams/skills/improve-codebase-architecture.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/improve-codebase-architecture.excalidraw)

Znajduj zmiany architektoniczne, które uniemożliwiają całą klasę błędów. Pogłębiaj projekt; nie dodawaj jedynie kolejnej kontroli ani testu regresji.

Ta umiejętność dotyczy wyłącznie architektury. Ogólny audyt, backlog, poprawność, bezpieczeństwo, wydajność, zależności lub dokumentacja należą do `/improve`. Implementacja należy do `/development-lifecycle`; ten przepływ pozostaje tylko do odczytu.

## Słownictwo i standard

Uruchom `/codebase-design`. Używaj terminów **moduł**, **interfejs**, **implementacja**, **głębokość**, **głęboki**, **płytki**, **granica**, **adapter**, **dźwignia** i **lokalność** w ich precyzyjnym znaczeniu.

- **Test usunięcia:** usunięcie głębokiego modułu rozprasza ukrytą w nim złożoność między wywołujących.
- **Interfejs jest powierzchnią testową:** testy weryfikują projekt przez jego stabilny interfejs.
- **Dwa adaptery uzasadniają granicę:** jeden adapter jest hipotetyczną abstrakcją.
- **Jedno źródło prawdy:** zachowanie pochodne wynika z reprezentacji należącej do właściciela, a nie z równoległej listy, flagi, rejestru, walidatora ani cyklu życia.
- **Niezmiennik strukturalny:** konstrukcja i przejścia sprawiają, że nieprawidłowe stany są niemożliwe lub niereprezentowalne w dalszej części systemu.

Przeczytaj `CONTEXT.md` i odpowiednie ADR-y, jeśli istnieją. Język domeny nazywa dobre moduły i granice; ADR-y zapobiegają ponownemu rozstrzyganiu trwałych decyzji bez nowych dowodów.

## 1. Określ zakres i zbadaj

**Określ zakres przed skanowaniem -- YAGNI.** Jeśli użytkownik wskazał moduł, wzorzec błędu lub bolesny obszar, przyjmij ten zakres. W przeciwnym razie użyj `git log --name-only --format=`, aby znaleźć często zmieniane miejsca; rozszerz zakres tylko wtedy, gdy historia jest rozproszona.

Domyślnie badaj bezpośrednio w bieżącym procesie. Delegowanie wymaga wyraźnej zgody użytkownika. Preferuj narzędzia grafowe właściwe dla repozytorium. Zmapuj interfejsy modułów, graf zależności lub wywołań, własność danych, konkurujących autorów zmian, przejścia stanów, ścieżki awarii oraz testy bieżącego interfejsu.

## 2. Znajdź możliwości strukturalne

Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/improve-codebase-architecture/REFERENCE.md), aby poznać perspektywy architektoniczne i reguły odrzucania kandydatów. Preferuj projekty, które zastępują równoległe rejestrowanie jednym źródłem prawdy, powtarzaną walidację konstrukcją z walidacją, niedozwolone kombinacje flag jawnymi stanami, a orkiestrację należącą do wywołujących jednym interfejsem głębokiego modułu.

Dla każdego podejrzanego miejsca nazwij **klasę błędu**, obecną zbyt liberalną reprezentację, proponowany niezmiennik oraz powód, dla którego inny wywołujący nie może odtworzyć pomyłki. Sam test regresji nie jest architekturą; testy weryfikują projekt po ustanowieniu docelowego niezmiennika.

## 3. Przedstaw kandydatów

Zapisz samodzielny raport HTML w katalogu tymczasowym systemu operacyjnego: `$TMPDIR/architecture-review-<timestamp>.html`, z użyciem `/tmp` lub `%TEMP%` jako rozwiązania zapasowego. Otwórz go i zwróć ścieżkę bezwzględną. Przeczytaj [HTML-REPORT.md](https://github.com/malinskibeniamin/skills/blob/main/improve-codebase-architecture/HTML-REPORT.md); użyj `/excalidraw-diagram`, gdy edytowalny widok przed/po wzmacnia argumentację.

Każdy kandydat musi zawierać pliki i dowody, klasę błędu, obecny i proponowany niezmiennik, zmianę własności, zmianę modułu/interfejsu/granicy, wizualizację przed/po, korzyści w zakresie lokalności/dźwigni/testowania, etap migracji, wycofanie, ryzyko zgodności oraz poziom pewności `Strong|Worth exploring|Speculative`.

Zakończ sekcją **Najważniejsza rekomendacja**. Nie proponuj jeszcze ostatecznych interfejsów. Zapytaj, którego kandydata zbadać.

## 4. Rygorystycznie sprawdź wybrany projekt

Uruchom `/grilling`. Rozstrzygnij własność, niezmiennik, kształt modułu, granicę, adaptery, kierunek zależności, stany przejściowe, migrację, wycofanie i obserwowalne testy.

- Nowy lub doprecyzowany termin domenowy -> `/domain-modeling` aktualizuje `CONTEXT.md`.
- Trwałe odrzucenie -> zaproponuj ADR.
- Konkurencyjne interfejsy -> zastosuj projektowanie dwóch wariantów z `/codebase-design`.
- Propozycja wizualna gotowa do przeglądu -> `/visual-plan`; konkurencyjne propozycje -> `/plan-arbiter`.
- Żądanie implementacji -> odwracalna sekwencja migracji przekazana do `/development-lifecycle`.

Praca jest ukończona, gdy wybrany niezmiennik wyjaśnia, dlaczego klasa błędu nie może powrócić przez niezmodyfikowaną ścieżkę wywołania, a testy weryfikują ten publiczny kontrakt.
