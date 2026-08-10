---
title: /registry-workflow
description: >-
  Utrzymuj rejestry komponentów dzięki spójnej taksonomii i zdyscyplinowanej
  synchronizacji. Używaj podczas modyfikowania rejestru shadcn lub systemu
  projektowego, synchronizowania komponentów albo analizowania rozbieżności u
  konsumentów.
type: skill
sidebar:
  label: /registry-workflow
---
![Diagram umiejętności /registry-workflow](/diagrams/skills/registry-workflow.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/registry-workflow.excalidraw)

Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/registry-workflow/REFERENCE.md), aby poznać przykłady taksonomii, polecenia do wykrywania rozbieżności, filtrowanie i
zasady zarządzania.

## Tryby

### Klasyfikowanie komponentów

Przypisz najwyższy pasujący poziom i na jego podstawie określ zakres testów.

| Poziom | Cechy | Testy |
|---|---|---|
| Atom | jeden prymityw, 0–1 stanów, bez niestandardowej obsługi klawiatury ani portalu | 3–4 |
| Cząsteczka | 2–3 atomy, maksymalnie 2 wartości stanu, prosty moduł obsługi, opcjonalny portal | 5–8 |
| Organizm | co najmniej 3 wartości stanu, co najmniej 3 importy z rejestru, niestandardowa obsługa klawiatury, portal | 8–15 |

Nawigacja klawiaturą zapewniana przez Radix nie jest uznawana za kod niestandardowy.

### Analizowanie rozbieżności u konsumentów

1. Dopasuj komponenty rejestru do plików konsumentów.
2. Uruchom `git diff --no-index --ignore-all-space`.
3. Odfiltruj aliasy importów, dyrektywy klienta, komentarze i białe znaki.
4. Sklasyfikuj każdy pozostały komponent:
   - `Upstream`: funkcjonalna zmiana wielokrotnego użytku.
   - `Skip-Import-Only`: różnice dotyczące wyłącznie ścieżki lub dyrektywy.
   - `Skip-Outdated`: konsument pozostaje w tyle za rejestrem; zsynchronizuj zmiany w dół.
   - `Skip-Business-Logic`: trasy, punkty końcowe, analityka, flagi funkcji lub wartości domenowe.
5. Zgłoś jeden stan dla każdego komponentu. Mieszane poprawki wielokrotnego użytku zaimplementuj ponownie w przejrzysty sposób w źródle nadrzędnym.

### Utrzymywanie rejestru

- Dostarczaj synchronizacje rejestru oddzielnie od prac nad funkcjami.
- Zachowuj zachowanie specyficzne dla konsumenta poza zarządzanymi plikami.
- Zmiany niezgodne wstecznie wymagają skryptu codemod, wpisu w dzienniku zmian, przykładu migracji i
  testów dymnych konsumentów.
- Komponenty rejestru nie powinny zależeć od routera ani frameworka.
- Powtarzające się przypadki nieprawidłowego użycia przez konsumentów naprawiaj w API komponentu.
- Opisuj zestawy zmian jako decyzje dotyczące aktualizacji: komponenty objęte zmianą, stan przed i po oraz uzasadnienie.

## Konfiguracja hooków

Skopiuj `scripts/ui-registry-warn.sh` i `scripts/registry-check.sh` do `.claude/hooks/`,
nadaj im uprawnienia do wykonywania, a następnie zarejestruj:

- PostToolUse `Edit|Write`: `ui-registry-warn.sh`
- Stop: `registry-check.sh`
- Zachowaj wspólną konwencję podziału plików: strony tras używają `*.page.tsx`; elementy wielokrotnego użytku
  znajdują się w katalogu `components/`.

## Kryteria ukończenia

- Oba hooki są wykonywane.
- Edytowanie katalogów komponentów powoduje wyświetlenie ostrzeżenia.
- Zmiana `redpanda-ui/` bez zmiany `registry.json` blokuje operację.
- Aktualizacja `registry.json` bez zestawu zmian blokuje operację.
