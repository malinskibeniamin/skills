---
title: /resilience-review
description: >-
  Przeprowadź uporządkowany według ryzyka przegląd Murphy’ego, gdy wiarygodna
  awaria może spowodować utratę danych, naruszenie bezpieczeństwa lub
  prywatności, nieodwracalne działanie, złamanie kontraktów albo prawdopodobną
  sytuację bez wyjścia dla użytkownika.
type: skill
sidebar:
  label: /resilience-review
---
![Diagram umiejętności /resilience-review](/diagrams/skills/resilience-review.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/resilience-review.excalidraw)

Przegląd Murphy’ego pod kątem wiarygodnych ryzyk, a nie wyczerpujące wyszukiwanie przypadków brzegowych.

## Najpierw dowody

Ryzyko jest wiarygodne, gdy potwierdza je granica zaufania, nieodwracalny skutek,
określony kontrakt, zaobserwowany incydent, potwierdzona skala lub prawdopodobna ścieżka użytkownika.
„Może się zdarzyć” to za mało. Pomijaj prace o niskim ryzyku bez zbędnych formalności.

Rozpisz działanie, zmianę stanu, skutki uboczne, zależności i bieżącą skalę.
Sprawdzaj tylko istotne kategorie. Natywne uruchomienia Codex wykonują je bezpośrednio, chyba że użytkownik
wyraźnie poprosi o agentów lub wywoła `/swarm`.
- **Dane wejściowe:** nieprawidłowe lub nieaktualne dane przekraczające granicę zaufania.
- **Czas:** zduplikowane lub wykonane w niewłaściwej kolejności zadania, które mogą uszkodzić dane lub wprowadzić w błąd.
- **System:** awaria zależności, która narusza wymagany kontrakt.
- **Stan:** niemożliwy stan, do którego prowadzi prawdopodobna ścieżka.
- **Odzyskiwanie:** zwykły użytkownik może utknąć lub otrzymać fałszywe potwierdzenie sukcesu.

Dla każdego wiarygodnego problemu podaj dowody, warunek wyzwalający, oczekiwane zachowanie, najmniejsze
zabezpieczenie i najmniejszy test publicznego kontraktu. Brak dowodów oznacza brak problemu.

W przypadku bezpieczeństwa, prywatności, utraty danych i działań destrukcyjnych stosuj zasadę bezpiecznej odmowy. W pozostałych przypadkach
preferuj jasny błąd zamiast spekulacyjnych ponowień, mechanizmów zastępczych, pamięci podręcznych, flag lub
obserwowalności.

Użyj `/read-the-damn-docs`, gdy zachowanie zewnętrzne określa ryzyko. Potwierdź rzeczywiste
usterki za pomocą `/diagnosing-bugs`, a następnie dodaj jeden niezaliczony test regresji. Użyj
`/visual-review` tylko dla widocznego dla klienta procesu odzyskiwania.
## Wynik
```md
## Resilience review
Risk surface:
- ...
Evidence:
- ...
Credible findings:
| Scenario | Evidence | Smallest guard | Contract test |
Verdict: PASS | NEEDS_GUARDS | BLOCKED
```

Zasady: wskazuj pliki/trasy/formularze/API. Uporządkuj problemy według ważności; nie premiuj ich liczby. Prawdziwa
luka o dużym wpływie blokuje dalsze działania. Hipotetyczny przypadek brzegowy nie staje się zadaniem.

Zobacz [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/resilience-review/REFERENCE.md).
