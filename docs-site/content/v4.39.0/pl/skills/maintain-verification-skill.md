---
title: /maintain-verification-skill
description: >-
  Przeprowadź audyt lokalnego dla projektu weryfikatora i mapy funkcji względem
  kodu źródłowego i rzeczywistego działania. Użyj, gdy któreś z nich może być
  nieaktualne lub ukrywać regresje.
type: skill
sidebar:
  label: /maintain-verification-skill
---
![Diagram umiejętności /maintain-verification-skill](/diagrams/skills/maintain-verification-skill.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/maintain-verification-skill.excalidraw)

Dbaj o rzetelność weryfikatora i jego mapy funkcji. Sprawdź każdą zmapowaną funkcję na podstawie kodu źródłowego i rzeczywistego działania. Zwróć jeden wynik: **bez zmian**, **zmieniono** lub **zablokowano**.

## Ograniczenia

Edytuj wyłącznie katalog umiejętności weryfikacji: jej plik `SKILL.md`, mapę funkcji i należące do niej narzędzia pomocnicze. Nigdy nie edytuj kodu produktu. Zachowanie, którego aplikacja już nie obsługuje, oznacza nieaktualną dokumentację lub regresję produktu — napraw pierwszą, a drugą zgłoś.

## Przebieg

1. **Znajdź.** Użyj jedynej lokalnej dla projektu umiejętności `verify-*`, która obejmuje uruchamianie, diagnostykę, sterowanie, dowody, porządkowanie i mapę funkcji. Jeśli taka umiejętność nie istnieje, skieruj zadanie do `/create-verification-skill`. Jeśli istnieje kilka, a zakres nie wskazuje jednej z nich, zapytaj, który weryfikator odpowiada za przebieg.
2. **Uzgodnij indeks.** Porównaj plik `features/README.md` z sąsiednimi plikami funkcji. Usuń nieaktualne wpisy i dodaj brakujące, konkretne elementy interfejsu użytkownika znalezione w trasach, poleceniach, menu lub publicznej dokumentacji.
3. **Pokrycie kodu źródłowego.** Dla każdej funkcji prześledź bieżące punkty wejścia, stabilne uchwyty, wymagania wstępne i obserwowalne wyniki. Zapisz prawdopodobne rozbieżności wraz z odwołaniami do kodu źródłowego i jednym scenariuszem testu na żywo. Sprawdzaj sekwencyjnie, chyba że użytkownik wyraźnie zezwoli na delegowanie.
4. **Pokrycie działania na żywo.** Uruchom diagnostykę weryfikatora, a następnie przetestuj każdą funkcję co najmniej raz. Użyj jednej izolowanej, długotrwałej instancji dla interfejsu użytkownika lub usług albo nowej izolowanej sesji dla każdego krótkotrwałego narzędzia CLI, zgodnie ze specyfikacją weryfikatora. Zbierz dowody przed rozpoczęciem porządkowania.
5. **Bezpiecznie przywróć działanie.** Po nieoczekiwanym wyniku testu ponownie uruchom diagnostykę. Jeśli diagnostyka nie wykrywa zablokowanego stanu, zresetuj lub ponownie uruchom środowisko. Usuń pozostałości po nieudanych iteracjach bez usuwania dowodów. Każdą naprawę mechanizmu testowego ponownie sprawdź na żywo.
6. **Sklasyfikuj problem.** Błędny opis dla użytkownika oznacza nieaktualną dokumentację. Działające zachowanie, którego mechanizm testowy nie potrafi uruchomić, oznacza lukę w tym mechanizmie. Niedziałające zachowanie produktu oznacza lukę w produkcie: zgłoś ją i pozostaw kod produktu bez zmian.
7. **Zakończ.** Usuń zasoby utworzone podczas przebiegu i potwierdź, że dowody pozostały dostępne. Ponownie przeczytaj zmienione pliki weryfikatora. Dostarcz wynik przez punkt końcowy wskazany przez wywołującego.

## Potwierdzenie

- **Wynik:** `clean | changed | blocked`.
- **Pokrycie:** każda funkcja wraz z dowodami z kodu źródłowego i działania na żywo.
- **Poprawki:** zmiany mapy, instrukcji lub narzędzi pomocniczych wraz z wynikiem ponownego testu.
- **Luki w produkcie:** konkretny błąd zachowania i sposób jego odtworzenia, bez maskowania go w weryfikatorze.
- **Ograniczenia:** niedostępne wymaganie wstępne, podjęta próba użycia ścieżki oraz pozostałe ryzyko.

Wynik `clean` wymaga pokrycia każdej zmapowanej funkcji w kodzie źródłowym i działaniu na żywo. Wynik `changed` wymaga pomyślnego ponownego przetestowania każdej poprawki. Wynik `blocked` wskazuje dokładnie brakujące wymaganie wstępne.
