---
title: /codex
description: >-
  Deleguj zadania do GPT-6.1 Sol za pomocą Codex CLI. Używaj do implementacji na
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

Sprawdź dostępność tylko po zatwierdzeniu delegacji: `codex exec -m gpt-6.1-sol -c 'model_reasoning_effort="xhigh"' "reply OK"`. Jeśli Sol jest niedostępny, użyj wyraźnie oznaczonego przeglądu Opus 5.5 `xhigh` z czystym kontekstem i ujawnij brak sprawdzenia przez inną rodzinę modeli. Wybieraj tylko Opus 5.5 i GPT-6.1 Sol; jeśli oba są niedostępne, zgłoś blokadę tej ścieżki.

## Warianty routingu

| Wariant | Zastosowanie |
|---|---|
| Sol, `xhigh` (`gpt-6.1-sol`; nigdy `max`) | preferowany recenzent PR; wykonanie, obsługa komputera i analiza po jawnym wyborze |
| Opus 5.5, `xhigh` (`claude-opus-5-5`) | codzienna praca, UI, plany, kod, drobne prace; oznaczony przegląd zapasowy z czystym kontekstem |

Przed wyborem przeczytaj `config/model-routing.json`. Nie oceniaj jakości na podstawie ceny ani nazwy. [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/codex/REFERENCE.md) określa warunki użycia między dostawcami i mechanizmy CLI.

## Kontrakt promptu

Codex nie widzi tej rozmowy. Każdy prompt określa repozytorium i gałąź, cel,
zakres i wyłączenia, kryteria akceptacji, obowiązujące reguły umiejętności i wzorzec, dokładne
polecenia weryfikacyjne, format dowodów oraz warunki zatrzymania. Przekazuj wyłącznie różnice i
kontekst związany z zadaniem; pomijaj dane poufne i niepowiązane pliki.

**Pakiet instrukcji:** w przypadku prac implementacyjnych dołącz bezpośrednio dopasowane reguły właściwe dla ścieżki oraz odpowiedni plik z katalogu `exemplars/`.

## Tryby

- **Implementacja:** `codex exec -m gpt-6.1-sol -c 'model_reasoning_effort="xhigh"'`;
  izoluj równoległe zapisy w osobnych drzewach roboczych.
- **Przegląd:** Sol `xhigh`: `codex exec -s read-only -m gpt-6.1-sol -c 'model_reasoning_effort="xhigh"'`; dowody P0–P3. Nie zmieniaj wybranego poziomu na podstawie zgadywanego progu zużycia.
- **Wymiana kontradyktoryjna:** tylko w środowisku Claude i po zatwierdzeniu; jedna ścieżka, nie ostateczny werdykt.
- **Obsługa komputera:** określ adres URL lub aplikację, stany i dowody.
- **Badanie/analiza:** użyj `-s read-only` i przygotuj zwięzły raport.

## Przepływ pracy

1. Przejdź weryfikację hosta i uprawnień.
2. Wybierz trasę spełniającą wymagania jakościowe z pliku `config/model-routing.json`.
3. Napisz samodzielny kontrakt promptu.
4. Uruchom zadanie z jawnym limitem czasu lub zgodnie z referencyjnym wzorcem działania w tle.
5. Przed integracją zweryfikuj wskazane pliki, polecenia i wnioski wysokiego ryzyka.

Architektura, synteza, produkt, bezpieczeństwo i ostateczna ocena pozostają po stronie koordynatora. Domyślnie modele Codex nie odpowiadają za UI, teksty ani projekt API. Te obszary należą do Opus 5.5; jeśli jest niedostępny, zgłoś blokadę tej ścieżki.
