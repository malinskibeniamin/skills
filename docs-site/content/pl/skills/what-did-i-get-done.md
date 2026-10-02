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

## Przebieg pracy [#workflow]

1. Ustal konkretny zakres dat; jeśli znasz datę ostatniej aktualizacji, użyj jej jako początku zakresu.
2. Odczytaj commity utworzone w tym okresie przez użytkownika o adresie e-mail skonfigurowanym obecnie w Git.
3. Pomiń commity scalające i niezatwierdzone zmiany.
4. Zbierz najważniejsze wdrożone zmiany w zwięzłą aktualizację statusu.
5. Oprzyj dalszą pracę na podanych planach lub wyraźnych zobowiązaniach; jeśli żadnych nie znasz, napisz „Next work not specified.”.

- Pisz wyjątkowo zwięźle i treściwie.
- Priorytetowo traktuj istotne zmiany zachowania lub architektury.
- Pomijaj zmiany wyłącznie kosmetyczne (formatowanie, importy, drobne zmiany nazw).
- Nie wyciągaj wniosków o intencjach ani motywacji. Opisuj zmiany pod kątem funkcjonalnym.

## Wynik [#output]

Zawsze odpowiadaj w dwóch sekcjach, używając dokładnie tych nagłówków:

- `What did you work on since the last update?`
- `What are you going to work on next?`

W każdej sekcji użyj maksymalnie pięciu zwięzłych punktów. Umieść całą treść w tych dwóch sekcjach; wybierz najważniejsze informacje zamiast zapełniać limit. W pierwszej sekcji podaj rzeczywisty zakres dat. W przeglądach tygodniowych i retrospektywach dodaj krótką klasyfikację (prawdopodobne poprawki błędów / dług techniczny / nowe funkcje) w punktach dotyczących wykonanej pracy.
