---
title: /codex
description: >-
  Deleguj zadania do GPT-6 Astra za pomocą Codex CLI. Używaj do implementacji na
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

Sprawdź dostępność funkcji raz na sesję:

```bash
codex exec -m gpt-6-astra "reply OK"
```

Jeśli model jest niedostępny, zgłoś blokadę tej ścieżki; nie zastępuj go innym modelem GPT.

## Warianty routingu

| Wariant | Poziom | Zastosowanie |
|---|---|---|
| Astra | `high`; `max`, gdy wybór jest oparty na ewaluacji lub został dokonany jawnie | kod, interfejs użytkownika, przegląd, planowanie, obsługa komputera |

Przed wyborem przeczytaj `config/model-routing.json`. Nie oceniaj jakości wariantu na podstawie ceny
ani nazwy. Informacje o mechanizmach CLI i warunkach użycia między dostawcami znajdziesz w dokumencie [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/codex/REFERENCE.md).

## Kontrakt promptu

Codex nie widzi tej rozmowy. Każdy prompt określa repozytorium i gałąź, cel,
zakres i wyłączenia, kryteria akceptacji, obowiązujące reguły umiejętności i wzorzec, dokładne
polecenia weryfikacyjne, format dowodów oraz warunki zatrzymania. Przekazuj wyłącznie różnice i
kontekst związany z zadaniem; pomijaj dane poufne i niepowiązane pliki.

**Pakiet instrukcji:** w przypadku prac implementacyjnych dołącz bezpośrednio dopasowane reguły właściwe dla ścieżki oraz odpowiedni plik z katalogu `exemplars/`.

## Tryby

- **Implementacja:** `codex exec -m gpt-6-astra -c 'model_reasoning_effort="high"'`;
  izoluj równoległe zapisy w osobnych drzewach roboczych.
- **Przegląd:** preferuj inną rodzinę modeli niż ta użyta przez autora. Prace utworzone przez Astra mogą
  zostać sprawdzone przez wysokiej jakości alternatywę Claude; rozwiązaniem zapasowym jest oznaczony przebieg Astra z czystym kontekstem. Używaj
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
koordynatora klasy frontier. Astra może odpowiadać za treści przeznaczone dla użytkowników i musi spełniać te same
wymagania dotyczące dowodów wizualnych.
