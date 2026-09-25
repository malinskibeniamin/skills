---
title: /grilling
description: >-
  Analizuj i poddawaj próbie plany, decyzje, pomysły, metody burzy mózgów oraz
  układy interfejsu, gdy istotna kwestia pozostaje otwarta.
type: skill
sidebar:
  label: /grilling
---
![Diagram umiejętności /grilling](/diagrams/skills/grilling.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/grilling.excalidraw)


Grilling pozwala wyjaśnić niewiadome o istotnych konsekwencjach, a nie każdy szczegół. Nie należy tworzyć kodu produkcyjnego ani rozpoczynać implementacji, dopóki pozostaje otwarta istotna decyzja zastrzeżona dla użytkownika. Wywołanie nie upoważnia do delegowania.

## 1. Przygotuj pakiet dowodów [#1-build-evidence]

Przeczytaj zgłoszenie, plan, repozytorium, testy, dokumentację, materiały referencyjne i decyzje. Ustalenie faktów należy do agenta; pytaj wyłącznie o preferencje, zakres, akceptowalny poziom ryzyka i decyzje, których nie można podjąć na podstawie dowodów. Wskaż lukę, która najprawdopodobniej może podważyć obecny kierunek. Zbuduj prototyp, gdy obserwacja działania pozwoli wyjaśnić ją szybciej niż opis.

`/brain-dump` jest opcjonalny. Zachowaj wszystkie ścieżki możliwości i zacznij od jego **Rejestru odpowiedzi**: nigdy nie pytaj ponownie o wpisy **Rozstrzygnięte**; kwestionuj wpisy **Wstępne** tylko wtedy, gdy ryzyko ma znaczenie; pytaj o **Nieznane** wyłącznie wtedy, gdy mogą unieważnić ścieżkę lub zmienić jej priorytet.

## 2. Tryb eksploracji [#2-explore-mode]

Gdy nie wybrano jeszcze kierunku, przedstaw 2–3 podejścia wraz z kompromisami, odwracalnością, dowodami i rekomendacją. Konkurencyjne plany należy przekazać do `/plan-arbiter`. **Wariant krytyczny:** gdy kierunek już istnieje, przedstaw najsilniejsze argumenty za najlepszą alternatywą i wskaż, co mogłoby dowieść, że obecny wybór jest błędny.

W przypadku interfejsu dla klientów umieść **makietę ASCII** przed pytaniami. Naszkicuj każdy istotnie różniący się układ w ogrodzonym bloku `text`, używając rzeczywistych etykiet, kontrolek, grupowania, kolejności oraz obszarów stałych lub przewijanych. Wyrównaj obramowania; traktuj szkic jako odwzorowanie struktury, a nie dokładności pikselowej. Pokaż wersję komputerową i mobilną tylko wtedy, gdy kompozycja się zmienia. Wspólne układy wymagają jednego szkicu i opisu różnic.

Opracuj drzewo decyzyjne i wyznacz jego front obejmujący decyzje, które można obecnie podjąć. Zapytaj o cały front w jednej numerowanej serii, używając tego **formatu pytań**:

```markdown
**Q1 -- <question title>**
<question or choices>

**Recommended:** <answer>

---

**Q2 -- <question title>**
<question or choices>
```

Nierozstrzygnięty warunek wstępny opóźnia tylko swoją gałąź, a pozostała część frontu jest kontynuowana. Po każdej serii odpowiedzi wyznacz front ponownie. Ustalaj fakty na bieżąco, chyba że użytkownik wyraźnie zezwoli na delegowanie; przeszukuj środowisko, system plików, narzędzia i źródła. Decyzje użytkownika należą do niego.

## 3. Zakończ [#3-exit]

Rozstrzygnij decyzje zmieniające architekturę lub zastrzeż je dla użytkownika. Sklasyfikuj pozostałe jako **wyszukanie -> prototyp -> odwracalne założenie -> wyzwalacz wstrzymania**. Zakończ, gdy żadna nierozstrzygnięta kwestia nie może po cichu podważyć następnego etapu.

## 4. Bramka planu [#4-plan-gate]

Zbierz jeden **pakiet dowodów**: zgłoszenie, plan, źródła specyfikacji i standardów, planowane ścieżki, fakty z repozytorium, założenia i nierozstrzygnięte decyzje.

- **Szybka**: mniej niż trzy zadania i brak istotnych decyzji dotyczących architektury, produktu lub UX; sprawdź na bieżąco specyfikację, standardy i wartość.
- **Standardowa**: uwzględnij na bieżąco perspektywy produktu/specyfikacji, inżynierii/standardów oraz projektu/UX.
- **Podwyższonego ryzyka**: bramka standardowa wraz z `/resilience-review` oraz `/steelman` dla wiarygodnego założenia o dużym wpływie lub trudnego do odwrócenia.

Osie: Specyfikacja -> `plan-product-hat`; Standardy -> `plan-engineering-hat`; projekt/UX -> `plan-design-hat`; dodatkowo perspektywa krytyczna/wartości. Czynniki podwyższonego ryzyka: uwierzytelnianie, migracja, publiczny interfejs API, działania destrukcyjne, współbieżność, Temporal, zmiany między usługami i decyzje jednokierunkowe.

**Rejestr specjalistów:** ocena wartości wymaga użycia `/av`; planowane prace w Go lub `go.mod` wymagają użycia `/golang`; dodawaj specjalistów dopiero po powtarzających się przeoczeniach. Dla każdej osi zgłoś `APPROVED`, `NEEDS_CHANGES`, `BLOCKED` lub `SKIPPED` wraz z dowodami i przyczyną ewentualnego pominięcia. Usuń duplikaty ustaleń wynikających z tej samej przyczyny źródłowej; ustalaj fakty i wstrzymaj pracę przy blokujących decyzjach użytkownika.

Wymagaj potwierdzenia tylko wtedy, gdy użytkownik zażądał zakończenia na etapie planowania lub grillowania. [ETHOS: Odkrywaj przed podjęciem zobowiązania]

Użyj `/domain-modeling`, aby zapisać terminy domenowe w `CONTEXT.md`; dodaj ADR tylko dla trudnego do odwrócenia, zaskakującego kompromisu.
