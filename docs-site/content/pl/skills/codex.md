---
title: /codex
description: >-
  Deleguj zadania do GPT-6 Sol za pomocą Codex CLI. Używaj do implementacji na
  podstawie jasnej specyfikacji, niezależnych przeglądów, obsługi komputera,
  analizy problemów i danych oraz mechanicznych prac wymagających dużej liczby
  tokenów.
type: skill
sidebar:
  label: /codex
---
![Diagram umiejętności /codex](/diagrams/skills/codex.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/codex.excalidraw)

**Ograniczenie hosta:** ta ścieżka działa w środowisku Claude. W natywnym środowisku Codex pracuj bezpośrednio, chyba że użytkownik
wyraźnie poprosi o delegowanie lub równoległych agentów. Nie uruchamiaj rekurencyjnie `codex exec`;
zachowaj wybrany model i poziom wnioskowania; nie zmieniaj konfiguracji Codex.

Sprawdź dostępność funkcji raz na sesję: `codex exec -m gpt-6-sol "reply OK"`. Jeśli model jest niedostępny, przejdź na Astra `high` i wskaż to w wyniku; jeśli oba zawiodą, zgłoś blokadę tej ścieżki. Nigdy nie zastępuj go tańszym modelem GPT.

## Warianty routingu

| Wariant | Poziom | Zastosowanie |
|---|---|---|
| Sol | `medium`; `high` i wyżej, gdy wybór jest oparty na ewaluacji lub został dokonany jawnie | kod na podstawie jasnej specyfikacji, obsługa komputera, analiza problemów |
| Astra | `high` (zapas dla Sol); nigdy `max` | najpierw przegląd PR; kod, planowanie, obsługa komputera; interfejs użytkownika tylko bez właściciela Claude |
| Luna (`gpt-6-luna`) | `high` | drobne prace: małe zmiany, czyste rebase, mechaniczne poprawki CI, odczyt lub wylistowanie danych; przy decyzjach przekaż do Sol |

Przed wyborem przeczytaj `config/model-routing.json`. Nie oceniaj jakości wariantu na podstawie ceny
ani nazwy. Informacje o mechanizmach CLI i warunkach użycia między dostawcami znajdziesz w dokumencie [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/codex/REFERENCE.md).

## Kontrakt promptu

Codex nie widzi tej rozmowy. Każdy prompt określa repozytorium i gałąź, cel,
zakres i wyłączenia, kryteria akceptacji, obowiązujące reguły umiejętności i wzorzec, dokładne
polecenia weryfikacyjne, format dowodów oraz warunki zatrzymania. Przekazuj wyłącznie różnice i
kontekst związany z zadaniem; pomijaj dane poufne i niepowiązane pliki.

**Pakiet instrukcji:** w przypadku prac implementacyjnych dołącz bezpośrednio dopasowane reguły właściwe dla ścieżki oraz odpowiedni plik z katalogu `exemplars/`.

## Tryby

- **Implementacja:** `codex exec -m gpt-6-sol -c 'model_reasoning_effort="medium"'`;
  izoluj równoległe zapisy w osobnych drzewach roboczych.
- **Przegląd:** Astra `high` (`xhigh` przy co najmniej 50% pozostałego limitu Codex). Używaj
  trybu `-s read-only` i dowodów P0–P3.
- **Wymiana kontradyktoryjna (automatyczna w przepływach pracy hostowanych przez Claude):** jeśli jest to dozwolone, użyj innej rodziny
  modeli; traktuj wynik jako jedną ze ścieżek, a nie ostateczny werdykt.
- **Obsługa komputera:** określ adres URL lub aplikację, stany i dowody.
- **Badanie/analiza:** użyj `-s read-only` i przygotuj zwięzły raport.

## Przepływ pracy

1. Przejdź weryfikację hosta i uprawnień.
2. Wybierz trasę spełniającą wymagania jakościowe z pliku `config/model-routing.json`.
3. Napisz samodzielny kontrakt promptu.
4. Uruchom zadanie z jawnym limitem czasu lub zgodnie z referencyjnym wzorcem działania w tle.
5. Przed integracją zweryfikuj wskazane pliki, polecenia i wnioski wysokiego ryzyka.

Decyzje architektoniczne wymagające znacznego osądu, synteza, kwestie produktowe i bezpieczeństwa oraz końcowy przegląd pozostają po stronie
koordynatora klasy frontier. Modele Codex nie odpowiadają za interfejs użytkownika, teksty ani projekt API, gdy dostępny jest właściciel Claude; zapasowy przebieg Astra musi spełniać te same
wymagania dotyczące dowodów wizualnych.
