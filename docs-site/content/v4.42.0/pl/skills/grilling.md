---
description: >-
  Analizuj i poddawaj próbie plany, decyzje, pomysły, metody burzy mózgów oraz
  układy interfejsu, gdy istotna kwestia pozostaje otwarta.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - grilling
sidebar:
  label: /grilling
title: /grilling
type: skill
---
![Diagram umiejętności /grilling](/diagrams/skills/grilling.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/grilling.excalidraw)

Przy jawnej zgodzie na delegowanie używaj świeżych kontekstów agentów i samodzielnych opisów dowodów; w przeciwnym razie zbieraj fakty w bieżącym kontekście.

Przy istotnym wyborze dotyczącym produktu lub projektu przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#product-and-planning).


Wyjaśniaj niewiadome o istotnych konsekwencjach, a nie każdy szczegół: nie twórz kodu produkcyjnego ani nie rozpoczynaj implementacji, dopóki pozostaje otwarta istotna decyzja zastrzeżona dla użytkownika. Wywołanie nie upoważnia do delegowania.

W przypadku planów, RFC i odpowiedzi przeczytaj [zasady komunikacji](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/communication.md).
Ładuj umiejętności zgodnie z [zasadami ładowania zależności](https://github.com/malinskibeniamin/skills/blob/v4.42.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).

## 1. Przygotuj pakiet dowodów [#1-build-evidence]

Przeczytaj zgłoszenie, plan, repozytorium, testy, dokumentację, materiały referencyjne i decyzje. Pytaj wyłącznie o preferencje, zakres, akceptowalny poziom ryzyka i decyzje należące do użytkownika, których nie można rozstrzygnąć na podstawie dowodów. Wskaż największą lukę w wiedzy. Zbuduj prototyp, gdy obserwacja działania pozwoli wyjaśnić ją szybciej niż opis.

`/brain-dump` jest opcjonalny. Zachowaj wszystkie ścieżki możliwości i zacznij od jego **Rejestru odpowiedzi**: nigdy nie pytaj ponownie o wpisy **Rozstrzygnięte**; kwestionuj wpisy **Wstępne** tylko wtedy, gdy ryzyko ma znaczenie; pytaj o **Nieznane** wyłącznie wtedy, gdy mogą unieważnić ścieżkę lub zmienić jej priorytet.

## 2. Tryb eksploracji [#2-explore-mode]

Gdy decyzja dotyczy interfejsu lub własności stanu, załaduj "codebase-design" i oprzyj alternatywy na szkicu od strony wywołującego. Zachowaj je jako materiały decyzyjne, nie kod produkcyjny.

Gdy nie wybrano jeszcze kierunku, przedstaw 2–3 podejścia wraz z kompromisami, odwracalnością, dowodami i rekomendacją. W przypadku konkurencyjnych planów wywołaj narzędzie Skill z "plan-arbiter". **Wariant krytyczny:** gdy kierunek już istnieje, przedstaw najsilniejsze argumenty za najlepszą alternatywą i wskaż, co mogłoby dowieść, że jest błędna.

W przypadku interfejsu dla klientów umieść **makietę ASCII** przed pytaniami: każdy istotnie różniący się układ w ogrodzonym bloku `text`, z rzeczywistymi etykietami, kontrolkami, grupowaniem, kolejnością oraz obszarami stałymi lub przewijanymi. Wyrównaj obramowania; pokaż strukturę, a nie dokładność pikselową. Pokaż wersję komputerową i mobilną tylko wtedy, gdy kompozycja się zmienia; wspólne układy wymagają jednego szkicu i opisu różnic.

Opracuj drzewo decyzyjne i wyznacz jego front obejmujący decyzje, które można obecnie podjąć. Zapytaj o cały front w jednej numerowanej serii, używając tego **formatu pytań**:

```markdown
**Q1 -- <question title>**
<question or choices>

**Recommended:** <answer>

---

**Q2 -- <question title>**
<question or choices>
```

Odpowiedź **Rekomendacja:**, co do której masz pewność i którą można odwrócić, jest założeniem, a nie pytaniem: przedstaw ją w jednym wierszu i kontynuuj. Pytaj wyłącznie o kwestie, których nie można rozstrzygnąć na podstawie dowodów i które należą do użytkownika.

**Sygnał zakończenia pytań:** „koniec pytań”, „po prostu zrób to”, „nie pytaj” lub samo wskazanie punktu końcowego („szkic PR”) kończy zadawanie pytań do końca sesji. Przyjmij wszystkie nierozstrzygnięte rekomendacje, wymień je jako założenia i kontynuuj aż do wskazanego punktu; wstrzymaj pracę tylko przy decyzji nieodwracalnej lub zastrzeżonej dla użytkownika.

Formułuj pytania tak, aby odpowiedź „tak” oznaczała przyjęcie rekomendacji.

Nierozstrzygnięty warunek wstępny opóźnia tylko swoją gałąź. Po każdej serii odpowiedzi wyznacz front ponownie. Ustalaj fakty na bieżąco, chyba że użytkownik wyraźnie zezwoli na delegowanie; przeszukuj środowisko, system plików, narzędzia i źródła. Decyzje użytkownika należą do niego.

## 3. Zakończ [#3-exit]

Rozstrzygnij decyzje zmieniające architekturę lub zastrzeż je dla użytkownika. Sklasyfikuj pozostałe jako **wyszukanie -> prototyp -> odwracalne założenie -> wyzwalacz wstrzymania**. Zakończ, gdy żadna nierozstrzygnięta kwestia nie może po cichu podważyć następnego etapu.

## 4. Bramka planu [#4-plan-gate]

Zbierz jeden **pakiet dowodów**: zgłoszenie, plan, źródła specyfikacji i standardów, ścieżki, fakty z repozytorium, założenia i nierozstrzygnięte decyzje.

- **Szybka**: mniej niż trzy zadania i brak istotnych decyzji dotyczących architektury, produktu lub UX; sprawdź na bieżąco specyfikację, standardy i wartość.
- **Standardowa**: uwzględnij na bieżąco perspektywy produktu/specyfikacji, inżynierii/standardów oraz projektu/UX.
- **Podwyższonego ryzyka**: bramka standardowa wraz z osobnymi wywołaniami narzędzia Skill z "resilience-review" oraz "steelman" dla wiarygodnego założenia o dużym wpływie lub trudnego do odwrócenia.

Osie: Specyfikacja -> `plan-product-hat`; Standardy -> `plan-engineering-hat`; projekt/UX -> `plan-design-hat`; dodatkowo perspektywa krytyczna/wartości. Czynniki podwyższonego ryzyka: uwierzytelnianie, migracja, publiczny interfejs API, działania destrukcyjne, współbieżność, Temporal, zmiany między usługami i decyzje jednokierunkowe.

**Rejestr specjalistów:** wywołaj narzędzie Skill osobno z "product" do oceny wartości oraz z "golang" dla planowanych prac w Go lub `go.mod`; dodawaj specjalistów dopiero po powtarzających się przeoczeniach. Dla każdej osi zgłoś `APPROVED`, `NEEDS_CHANGES`, `BLOCKED` lub `SKIPPED` wraz z dowodami i przyczyną ewentualnego pominięcia. Usuń duplikaty ustaleń wynikających z tej samej przyczyny źródłowej; ustalaj fakty i wstrzymaj pracę przy blokujących decyzjach użytkownika.

Wymagaj potwierdzenia tylko wtedy, gdy użytkownik zażądał zakończenia na etapie planowania lub grillowania. [ETHOS: Odkrywaj przed podjęciem zobowiązania]

Wywołaj narzędzie Skill z "domain-modeling", aby zapisać terminy domenowe w `GLOSSARY.md`; dodaj ADR tylko dla trudnego do odwrócenia, zaskakującego kompromisu.
