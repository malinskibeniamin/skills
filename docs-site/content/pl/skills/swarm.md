---
title: /swarm
description: >-
  Równoległe wykonywanie niezależnych zadań masowych w odizolowanych obszarach
  drzewa roboczego.
type: skill
sidebar:
  label: /swarm
---
![Diagram umiejętności /swarm](/diagrams/skills/swarm.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/swarm.excalidraw)

Podziel niezależne zadania masowe między odizolowane obszary, zweryfikuj każdy z nich, a następnie scal wyniki. Swarm
realizuje istniejący cel; nie zastępuje planowania ani nie odpowiada za końcowy etap dostarczenia.

Użyj `/swarm <free-form goal>`. Wyznacz obszary na podstawie tekstu użytkownika. Nie proś o zgodę przed uruchomieniem, chyba że brakuje niezbędnego kontekstu.
Wywołanie `/swarm` lub wyraźne zażądanie agentów równoległych oznacza zgodę na użycie natywnych
subagentów Codex. Aktywacja żadnej innej umiejętności nie udziela takiej zgody.

## Pozycja

- `/work` odpowiada za cykl życia.
- `/grilling` uzgadnia plan i dokumentację.
- `/swarm` przyspiesza wykonywanie niezależnych obszarów.
- `/go` weryfikuje i dostarcza.

## Przebieg uruchamiania

1. Szybko zbierz kontekst: sprawdź bieżący stan repozytorium, reguły, dokumentację, gałąź, PR oraz aktywny cel, jeśli jest dostępny. Wewnętrznie zastosuj zwięzły format w stylu `/prime`.
2. W przypadku długich lub kosztownych rojów zastosuj budżetowanie limitów użycia `/efficient-frontier` przed pierwszą falą i między falami. Domyślne ograniczenie: maksymalnie 3 agentów równolegle, chyba że użytkownik wskaże inaczej.
3. Używaj `/efficient-frontier` wewnętrznie: koordynator odpowiada za orkiestrację, integrację i końcowy przegląd; deleguj ograniczone zadania obejmujące przeszukiwanie repozytorium, implementację, testy i analizę logów.
4. Wybierz zasady przestrzeni roboczej na podstawie tekstu:
   - Domyślnie: ta sama gałąź, drzewo robocze i PR.
   - Jeśli użytkownik prosi o oddzielne, odizolowane lub osobne dla każdego agenta drzewa robocze: utwórz po jednym drzewie roboczym i jednej gałęzi na obszar.
   - Jeśli ryzyko konfliktów jest wysokie: podziel lub wykonuj zapisy sekwencyjnie; wyjaśnij przyczynę w manifeście.
5. Przygotuj krótki manifest roju, a następnie natychmiast go uruchom:
   ```txt
   Swarm manifest
   Policy: shared | worktrees | hybrid
   - swarm-<lane-name>: <mission> | scope: <paths> | skills: </skill...>
   ```
6. Uruchamiaj tylko odrębne obszary. Nie twórz zduplikowanych ani nieprecyzyjnych agentów.
7. Koordynator zachowuje lokalnie ścieżkę krytyczną, scala wyniki, rozstrzyga sprzeczne ustalenia, weryfikuje rezultat i zamyka agentów.

## Projektowanie obszarów

Każdy obszar otrzymuje pakiet zadania:

```yaml
agent_name: swarm-<area>-<mission>
role: explorer | worker | reviewer | teacher
mission: one concrete outcome
skills: [/prime, /tdd, /review]
context: docs, decisions, branch or PR, relevant paths
workspace_policy: shared | worktree | hybrid
write_scope: exact paths or "report-only"
forbidden: duplicate lanes, unrelated files, commits, pushes unless asked
termination: concrete deliverable and stop condition for this lane
model_policy: inherit by default; override only when useful or user asks
output schema: status, summary, changed_files, tests_run, findings, blockers, next_action
```

Agenci mogą odczytywać i zapisywać dane, chyba że pakiet zawiera `report-only`. Przy współdzielonych zasadach przypisz własność plików lub wykonuj sekwencyjnie obszary intensywnie zapisujące dane. Przy zasadach opartych na drzewach roboczych nazwy gałęzi powinny być opisowe i podczas tworzenia drzew roboczych mogą mieć format `<owner>/<ticket>/<lane-desc>`.
Uruchomione obszary nie mogą tworzyć potomków bez osobnej zgody na zagnieżdżoną delegację.

## Łączenie umiejętności

- Kontrola długich lub kosztownych fal: `/efficient-frontier` odpowiada za sprawdzanie użycia oraz przekazywanie zadań przy wstrzymywaniu i wznawianiu.
- Przed uruchomieniem obszarów i między falami: `/efficient-frontier`; używaj
  `/stay-within-limits` tylko wtedy, gdy dostępny jest aktualny obraz limitu hosta.
- Wybór modelu dla obszaru: używaj `config/model-routing.json`. Przypisz jednego
  właściciela implementacji do każdego zakresu zapisu; nie duplikuj implementacji jako pary modeli. Warianty
  wymagające akceptacji na podstawie ewaluacji pozostają niedostępne do czasu zatwierdzenia przez zestaw testów ablacyjnych.
- Dyscyplina użycia tokenów modelu frontier: `/efficient-frontier` określa, co delegować, a co pozostawić koordynatorowi.
- Obszary wykonawcze od początku tworzą najmniejsze przejrzyste rozwiązanie; obszary przeglądowe bezpośrednio oceniają gęstość semantyczną.
- Architektura: rozdziel `/improve architecture` według kontekstu, modułu, granicy lub adaptera.
- TDD: podziel zakres testów według niezależnych zachowań lub publicznych interfejsów. RED przed zmianami w kodzie produkcyjnym; wynik musi zawierać dowód RED->GREEN lub niezaliczonego testu.
- Praca nad umiejętnościami lub mechanizmem testowym: przypisz odpowiedzialność za ewaluację w każdym obszarze. Każda zmieniona umiejętność lub hook wymaga odpowiednich ewaluacji w zakresie, za które odpowiada obszar lub koordynator.
- Projektowanie i treści: wydzielaj obszary `/visual-review`, `/ux-copy`, dostępności i artykulacji tylko wtedy, gdy ich zakresy zapisu się nie pokrywają.
- Przegląd: podziel według standardów, specyfikacji, odporności, bezpieczeństwa, wydajności, testów, UX i najlepszej możliwej interpretacji.
- Diagnozowanie: rozdziel pętle odtwarzania, hipotezy, instrumentację i testy regresji.
- Produkt: połącz obszary trybu eksploracji `/grilling`, `/prototype` i `/steelman`, aby opracować warianty i kontrargumenty.
- Przekazanie: po etapie grilling utwórz zwarte pakiety, aby każdy agent rozpoczynał pracę z aktualnymi decyzjami.
- Nauka: podziel temat na teorię, przykłady, zastosowanie w repozytorium, kompromisy i pułapki.

## Protokół scalania

- Przeczytaj każdy wynik; w przypadku obszarów zapisujących dane nie ufaj bezkrytycznie podsumowaniom.
- Świadomie zastosuj lub zachowaj zmiany; nigdy nie akceptuj bezkrytycznie nakładających się edycji.
- Sprzeczne zalecenia: przedstaw warianty, dowody i rekomendację koordynatora.
- Po scaleniu uruchom ukierunkowane kontrole. W przypadku obszarów TDD wymagaj dowodu niezaliczonego testu przed dowodem implementacji.
- Wynik końcowy: podsumowanie manifestu, wdrożone zmiany, odrzucone lub odłożone prace, testy, blokery i następne działanie.

## Zgodność

Codex i Claude Code muszą działać na podstawie promptów i artefaktów, a nie ukrytych hooków. Używaj natywnych subagentów, gdy są dostępni. Jeśli narzędzie subagentów nie istnieje, wygeneruj pakiety zadań jako pliki przekazania lub polecenia do ręcznego uruchomienia.
