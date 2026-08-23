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

Grilling pozwala odkryć niewiadome o istotnych konsekwencjach; nie wymaga pewności co do każdego
szczegółu implementacji. Podczas grillowania nie należy tworzyć kodu produkcyjnego ani rozpoczynać
implementacji, dopóki pozostaje otwarta istotna decyzja zastrzeżona dla użytkownika. Wywołanie nie upoważnia do delegowania.

## 1. Przygotuj pakiet dowodów
Przeczytaj zgłoszenie, plan, repozytorium, testy, dokumentację, materiały referencyjne i ostatnie decyzje. Ustalenie faktów
należy do agenta. Pytaj użytkownika wyłącznie o preferencje, zakres, akceptowalny poziom ryzyka i
decyzje, których nie można podjąć na podstawie dowodów.

`/brain-dump` jest opcjonalnym wcześniejszym etapem odkrywania. Jeśli istnieje przygotowany w nim opis, zachowaj każdy kierunek
możliwości i zacznij od jego rejestru odpowiedzi. Traktuj wpisy **Settled** jako rozstrzygnięte, chyba że dowody
je unieważnią. Kwestionuj wpisy **Tentative**, gdy negatywne konsekwencje są istotne; pytaj o wpisy **Unknown**
tylko wtedy, gdy mogą unieważnić kierunek lub zmienić jego priorytet.

Wskaż lukę, która najprawdopodobniej może podważyć obecny kierunek. Jeśli obserwacja działania
pozwoli wyjaśnić ją szybciej niż opis, najpierw zbuduj jednorazowy prototyp lub poproś o jego przygotowanie.

## 2. Tryb eksploracji
Gdy nie wybrano jeszcze kierunku, przedstaw 2–3 podejścia wraz z kompromisami, odwracalnością i
dowodami. Zarekomenduj jedno z nich. Konkurencyjne plany należy przekazać do `/plan-arbiter`.

W przypadku decyzji dotyczących interfejsu dla klientów umieść **makietę ASCII** przed serią pytań.
Naszkicuj każdy istotnie różniący się proponowany układ w ogrodzonym bloku `text`, używając drukowalnych
znaków ASCII. Wyrównaj obramowania i zachowaj szerokość ułatwiającą szybkie przeglądanie. Użyj rzeczywistych etykiet,
kontrolek, grupowania, kolejności oraz obszarów stałych lub przewijanych z propozycji zamiast ogólnych symboli zastępczych.
Traktuj szkic jako odwzorowanie struktury, a nie dokładności pikselowej; oznacz treści ustalone na podstawie wnioskowania.
Pokaż wersję komputerową i mobilną tylko wtedy, gdy kompozycja zmienia się w punkcie przełamania. Jeśli podejścia mają wspólny
układ, naszkicuj go raz i opisz różnice wizualne lub behawioralne.

**Wariant krytyczny:** gdy kierunek już istnieje, przedstaw najsilniejsze argumenty za najlepszą alternatywą i
wskaż, co mogłoby dowieść, że obecny wybór jest błędny.

Opracuj drzewo decyzyjne. Jego front obejmuje wszystkie decyzje, które można obecnie podjąć. Zapytaj o cały front
w jednej numerowanej serii, podając rekomendację dla każdej decyzji.

Użyj tego stałego **formatu pytań**, aby użytkownik mógł je szybko przejrzeć i odpowiedzieć według numerów:

```markdown
**Q1 -- <question title>**
<question body or choices>
**Recommended:** <answer>
**Q2 -- <question title>**
<question body or choices>
**Recommended:** <answer>
```

Nierozstrzygnięty warunek wstępny opóźnia tylko swoją gałąź, a pozostała część frontu jest kontynuowana.
Po każdej serii odpowiedzi wyznacz front ponownie.

Ustalaj fakty na bieżąco, chyba że użytkownik wyraźnie zezwoli na delegowanie. Przeszukuj
środowisko, system plików, narzędzia i źródła. Decyzje użytkownika należą do niego.

Przydatne pytania krytyczne:

- Ryzykowna wymiana interfejsu: ścieżka wycofania, osoba odpowiedzialna i warunek usunięcia.
- Zależność: dowody, że przewyższa kod lokalny i przetrwa planowaną migrację.
- Abstrakcja: potwierdzone drugie miejsce użycia.
- Mechanizm awaryjny: czy następna sesja go skopiuje.
- Twierdzenie dotyczące skali lub awarii: konkretne dane wejściowe, czas lub stan systemu, które je potwierdzają.

## 3. Zakończ z klasyfikacją niewiadomych
Decyzje zmieniające architekturę muszą zostać rozstrzygnięte lub wyraźnie zastrzeżone dla użytkownika.
Sklasyfikuj wszystkie pozostałe: **wyszukanie -> prototyp -> odwracalne założenie -> wyzwalacz wstrzymania**.
Rozmowa kończy się, gdy żadna nierozstrzygnięta kwestia nie może po cichu podważyć następnego etapu, a nie
dopiero wtedy, gdy znane są wszystkie przyszłe szczegóły.

## 4. Bramka planu
Zbierz jeden **pakiet dowodów**: zgłoszenie, plan, źródła specyfikacji, źródła standardów, planowane
ścieżki, fakty z repozytorium, założenia i nierozstrzygnięte decyzje.

Użyj najmniejszej bramki odpowiadającej poziomowi ryzyka:

- **Szybka**: trywialny błąd, mniej niż trzy zadania, brak istotnych decyzji dotyczących architektury, produktu lub UX.
  Sprawdź na bieżąco specyfikację, standardy i wartość.
- **Standardowa**: uwzględnij na bieżąco perspektywy produktu/specyfikacji, inżynierii/standardów oraz projektu/UX.
- **Podwyższonego ryzyka**: bramka standardowa wraz z przeglądem odporności i najsilniejszymi argumentami dotyczącymi wiarygodnego
  założenia o dużym wpływie lub trudnego do odwrócenia.

Osie: Specyfikacja -> `plan-product-hat`; Standardy -> `plan-engineering-hat`; projekt/UX ->
`plan-design-hat`; dodatkowo perspektywa krytyczna/wartości. Przeprowadź je na bieżąco.

Czynniki podwyższonego ryzyka: uwierzytelnianie, migracja, publiczny interfejs API, działania destrukcyjne, współbieżność, Temporal, zmiany między usługami i decyzje jednokierunkowe. Dodaj `/resilience-review` oraz `/steelman`.

**Rejestr specjalistów:** planowane prace w Go lub `go.mod` wymagają użycia `/golang`; dodaj kolejnego specjalistę dopiero po powtarzających się przeoczeniach.

Dla każdej odpowiedniej osi zgłoś `APPROVED`, `NEEDS_CHANGES`, `BLOCKED` lub `SKIPPED`
wraz z dowodami; pominięcie wymaga podania przyczyny. Usuń duplikaty ustaleń wynikających z tej samej przyczyny źródłowej. Blokujące decyzje
użytkownika wstrzymują pracę; braki w faktach wymagają badań lub prototypu.

Wymagaj potwierdzenia tylko wtedy, gdy użytkownik zażądał zakończenia na etapie planowania lub grillowania. [ETHOS: Odkrywaj przed podjęciem zobowiązania]

Użyj `/domain-modeling`, aby zapisać terminy domenowe w `CONTEXT.md`, a ADR tylko wtedy, gdy
decyzję trudno odwrócić, bez kontekstu jest zaskakująca i wiąże się z rzeczywistym kompromisem.
