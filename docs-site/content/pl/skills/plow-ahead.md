---
title: /plow-ahead
description: >-
  Kontynuuj pracę pomimo typowych niejasności, przyjmując odwracalne założenia.
  Użyj, gdy użytkownik mówi: działaj dalej, kontynuuj, zdaj się na własny osąd
  lub nie zatrzymuj się, dopóki zadanie nie zostanie ukończone.
type: skill
sidebar:
  label: /plow-ahead
---
![Diagram umiejętności /plow-ahead](/diagrams/skills/plow-ahead.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/plow-ahead.excalidraw)

Przeczytaj `references/builder-upstream.md`, aby poznać zasady autonomicznego działania.

Traktuj instrukcję użytkownika jako zgodę na kontynuowanie pracy pomimo typowych niejasności.

## Zasady podejmowania decyzji

1. Zanim opracujesz nowe rozwiązanie, wykorzystaj wzorce już istniejące w repozytorium.
2. Preferuj lokalne, odwracalne zmiany o niewielkim zasięgu oddziaływania.
3. Ogranicz zakres ściśle do żądania.
4. Przedkładaj poprawność i łatwość utrzymania nad pomysłowość.
5. Zacznij weryfikację od najmniejszego miarodajnego testu, a następnie rozszerz ją, jeśli uzasadnia to ryzyko.
6. Jeśli opcje są porównywalne, wybierz tę, która będzie łatwiejsza do zrozumienia dla osoby dokonującej przeglądu.

## Zatrzymaj się tylko w przypadku rzeczywistych przeszkód

- Brak wymaganych danych uwierzytelniających, sekretów, płatnych usług, prywatnych danych lub dostępu do konta.
- Niejawnie zażądane działanie, które jest destrukcyjne, nieodwracalne, modyfikuje środowisko produkcyjne lub przepisuje historię.
- Wysokie ryzyko prawne albo związane z prywatnością, bezpieczeństwem lub zgodnością z przepisami, którego nie można ograniczyć lokalnie.
- Decyzja, którą użytkownik wyraźnie zastrzegł dla siebie.
- Powtarzający się błąd weryfikacji, gdy kolejna poprawka wymagałaby spekulatywnych lub rozległych zmian.

## Cykl pracy

1. Określ kryteria akceptacji i założenia.
2. Sprawdź rzeczywiste pliki, dokumentację, zgłoszenie, żądanie ściągnięcia, zrzut ekranu lub działanie środowiska uruchomieniowego.
3. Wprowadzaj zmiany w małych, spójnych krokach.
4. Przeprowadź ukierunkowaną weryfikację i popraw wykryte problemy.
5. Przed końcowym podsumowaniem porównaj różnice z pierwotnym żądaniem.
6. Na koniec przedstaw podjęte decyzje, wprowadzone zmiany, wyniki weryfikacji, pozostałe ryzyko i kolejne działanie.
