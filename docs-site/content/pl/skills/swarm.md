---
title: /swarm
description: "Równoległy wykonawca niezależnej pracy masowej w odizolowanych torach drzewa roboczego."
type: skill
sidebar:
  label: /swarm
---
![Diagram umiejętności /swarm](/diagrams/skills/swarm.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/swarm.excalidraw)

Podziel niezależną pracę masową na tory, zweryfikuj każdy i zintegruj wyniki. Swarm wykonuje istniejący cel; nie zastępuje planowania ani nie jest właścicielem dostarczenia. Równoległość wymaga jawnej zgody przez `/swarm` albo bezpośrednie żądanie użytkownika; żadna inna umiejętność jej nie daje.

`/work` jest właścicielem cyklu, `/grilling` rozstrzyga wybory, a `/go` dostarcza.

## Uruchomienie

1. Sprawdź zasady repozytorium, stan, gałąź lub PR, dokumentację i aktywny cel.
2. Dla długich lub kosztownych fal użyj `/efficient-frontier` przed startem i między falami. Domyślnie uruchamiaj najwyżej trzech agentów równolegle.
3. Orkiestrację, ścieżkę krytyczną, integrację i ocenę zachowaj u koordynatora. Deleguj tylko ograniczone wyszukiwanie, implementację, testy lub redukcję dowodów.
4. Wybierz politykę przestrzeni:
   - Domyślnie: ta sama gałąź, worktree i PR.
   - Żądana izolacja: opisowy worktree i gałąź dla każdego toru.
   - Wysokie ryzyko konfliktu: osobne zakresy albo serializacja zapisów.
5. Pokaż krótki manifest swarm, potem uruchom:

   ```text
   Swarm manifest
   Policy: shared | worktrees | hybrid
   - swarm-<tor>: <misja> | scope: <ścieżki> | skills: </umiejętność...>
   ```

6. Uruchamiaj tylko różne tory. Koordynator integruje wyniki, rozstrzyga sprzeczne znaleziska, wykonuje końcową weryfikację i zamyka agentów.

## Pakiet zadania

Każdy tor otrzymuje:

```yaml
agent_name: swarm-<obszar>-<misja>
role: explorer | worker | reviewer | teacher
mission: jeden konkretny wynik
skills: [tylko potrzebne umiejętności]
context: zasady, decyzje, gałąź lub PR, ścieżki
workspace_policy: shared | worktree | hybrid
write_scope: dokładne ścieżki lub report-only
forbidden: duplikaty, niepowiązane pliki, commity i push bez żądania
termination: artefakt i warunek zakończenia
model_policy: dziedzicz, chyba że dowód lub użytkownik wymaga zmiany
output schema: status, summary, changed_files, tests_run, findings, blockers, next_action
```

Agenci zapisują tylko w swoim zakresie. Wspólne tory wymagają rozłącznej własności; tory worktree używają opisowych gałęzi. Agenci potomni wymagają osobnej autoryzacji.

## Zasady torów

- Użyj `config/model-routing.json`; nie duplikuj jednej implementacji między parami modeli.
- Przypisz jednego właściciela implementacji do zakresu zapisu i właściciela pasujących ewaluacji dla każdej zmienionej umiejętności lub hooka.
- Tory TDD zwracają RED -> GREEN albo dowód nieudanego testu przed dowodem implementacji.
- Architekturę dziel według modułu lub punktu styku; testy według niezależnego zachowania publicznego.
- `/visual-review` i `/ux-copy` rozdzielaj tylko przy niepokrywających się zakresach.
- Tory przeglądu mogą rozdzielać specyfikację, standardy, odporność, bezpieczeństwo, wydajność, testy i UX.
- Tory diagnozy mogą rozdzielać reprodukcję, hipotezy, instrumentację i dowód regresji.
- Syntezę i decyzje zastrzeżone dla użytkownika zachowaj u koordynatora.

## Protokół scalania

Czytaj artefakty i zmienione pliki, nie tylko podsumowania. Odrzucaj lub świadomie uzgadniaj nakładanie. Przy sprzecznych rekomendacjach pokaż dowody, opcje i wybór koordynatora. Po integracji uruchom kontrole; TDD wymaga dowodu RED przed GREEN.
Zgłoś manifest, przyjętą i odrzuconą pracę, testy, blokery i następną akcję.

## Zgodność

Codex i Claude Code muszą działać z jawnych promptów i artefaktów. Bez natywnych subagentów wygeneruj pakiety zadań do ręcznego uruchomienia.
