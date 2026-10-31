---
description: >-
  Podsumowuje commity Git utworzone w określonym przedziale czasu w formie
  zwięzłej aktualizacji statusu. Używaj podczas przygotowywania przeglądów
  tygodniowych, retrospektyw, podsumowań wdrożonych prac lub zestawień dla
  dowolnego wskazanego zakresu dat.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - what did i get done
sidebar:
  label: /what-did-i-get-done
title: /what-did-i-get-done
type: skill
---
![Diagram umiejętności /what-did-i-get-done](/diagrams/skills/what-did-i-get-done.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/what-did-i-get-done.excalidraw)

Odczytaj commity utworzone w danym zakresie dat przez użytkownika o adresie e-mail
skonfigurowanym obecnie w Git; jeśli znasz datę ostatniej aktualizacji, użyj jej jako
początku zakresu. Pomiń commity scalające i niezatwierdzone zmiany. Priorytetowo
traktuj wdrożone zmiany zachowania lub architektury; pomijaj formatowanie, importy
i drobne zmiany nazw. Opisuj funkcjonalność, nie motywację.

## Wynik [#output]

Zawsze używaj wyłącznie tych dwóch dokładnych nagłówków:

- `What did you work on since the last update?`
- `What are you going to work on next?`

W każdej sekcji użyj maksymalnie pięciu zwięzłych punktów. Pierwsza sekcja: rzeczywisty
zakres dat oraz, przy przeglądach tygodniowych lub retrospektywach, prawdopodobna
klasyfikacja (poprawki błędów / dług techniczny / nowe funkcje). Dalsza praca: wyłącznie
podane plany lub zobowiązania; w przeciwnym razie napisz "Next work not specified.".
