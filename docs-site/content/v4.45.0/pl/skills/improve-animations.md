---
description: "Audytuj istniejący ruch w interfejsie WWW i ustal priorytety konkretnych ulepszeń lub samodzielnych planów wdrożenia. Plan rozwoju ruchu; animate odpowiada za wdrożenie i przegląd diffu."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["improve animations"]}
sidebar: {"label":"/improve-animations"}
title: "/improve-animations"
type: "skill"
---
![Schemat umiejętności /improve-animations](/diagrams/skills/improve-animations.svg)

[Otwórz edytowalny plik źródłowy Excalidraw](/diagrams/skills/improve-animations.excalidraw)

Znajdź najbardziej wartościowe poprawki ruchu, który powinien pozostać. Adaptacja materiałów Emila Kowalskiego;
[źródło i zgodność](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/EMIL-SKILLS-CREDITS.md).
Audyt i planowanie zwracają ustalenia bez edycji źródeł. Zapisuj plany tylko na żądanie.
Jawne żądania wdrożenia realizuj przez [animate](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/SKILL.md)
i bramki dostarczania projektu w bieżącym kontekście; bez automatycznych wykonawców, agentów i worktree.

## Audyt [#audit]

1. Opisz żądany obszar, zainstalowaną bibliotekę ruchu i wersję, prymitywy komponentów,
   istniejące tokeny, ścieżki wejścia i kontekst produktu. Ustal oczekiwaną częstotliwość bez
   wymyślania liczby użyć. Uszanuj udokumentowane kompromisy i sprawdź każde wskazane miejsce.
2. Wczytaj [animate](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/SKILL.md) oraz
   [przewodnik wykonania](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/REFERENCE.md).
   Audytuj cel/częstotliwość, krzywe/czas, fizyczność/punkt początkowy, przerywalność,
   koszt renderowania, dostępność, spójność tokenów i rzeczywiste pominięte okazje.
   Przeprowadź te osie w bieżącym kontekście. Zbędny ruch kieruj do
   [remove-animations](https://github.com/malinskibeniamin/skills/blob/v4.45.0/remove-animations/SKILL.md), zamiast go dopracowywać.
3. Zweryfikuj ustalenia względem rzeczywistych zmian stanu i istniejących decyzji. Odróżniaj
   odtwarzalne błędy od sugestii wykonania i niezmierzonych podejrzeń wydajnościowych.
   Ustal kolejność według wpływu na użytkownika i nakładu pracy; podaj wagę, kategorię, `file:line`,
   dowód i poprawkę. Pusty wynik jest poprawny; nie narzucaj dodatków ani stałej liczby ustaleń.
4. Na żądanie planów przygotuj każdy do samodzielnego wykonania: bieżąca rewizja,
   problem i aktualny fragment, dokładne cele i wartości tokenów, wzorzec repozytorium,
   uporządkowane edycje, zakres/zależności, wycofanie i precyzyjne polecenia weryfikacji.
   Uwzględnij szybkie odwrócenie, klawiaturę/dotyk, ograniczony ruch i rzeczywistą ocenę efektu;
   wskaż brakujące dowody z urządzeń. Sprawdzaj nieaktualne plany względem bieżącego kodu.

W sekwencji `remove-animations -> improve-animations -> animation-performance` najpierw odejmuj,
następnie oceń zachowany ruch, a na końcu profiluj pozostałe problemy z klatkami.
Sekwencja zachowuje żądany punkt końcowy; audyt nie upoważnia do poprawek.

Dla wąskich gardeł klatek wczytaj [animation-performance](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animation-performance/SKILL.md);
statyczna analiza kodu nie dowodzi płynności. Wczytuj zależności zgodnie z
[zasadami ładowania zależności](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
