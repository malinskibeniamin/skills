---
title: /brain-dump
description: >-
  Przekształca nieuporządkowane myśli, notatki, artykuły, pliki lub linki w
  oparty na faktach opis możliwości przed rozpoczęciem analizy. Używaj, gdy
  użytkownik zna ogólny obszar, ale nie ma jeszcze ustalonego celu ani
  precyzyjnego pytania.
type: skill
sidebar:
  label: /brain-dump
---
![Diagram umiejętności /brain-dump](/diagrams/skills/brain-dump.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/brain-dump.excalidraw)

Przekształć surowe informacje w opcjonalny pakiet rozpoznawczy dla późniejszej sesji `/grilling`. Zachowaj
szeroki zakres: jeden zrzut może ujawnić kilka niezależnych problemów, zadań, zgłoszeń lub kierunków badawczych.
Pozostań na etapie rozpoznania. Zwróć opis na czacie, chyba że użytkownik poprosi o jego zapisanie lub opublikowanie; nie
wdrażaj rozwiązań, nie twórz zgłoszeń ani nie przekształcaj możliwości w zobowiązania.

## 1. Najpierw przyswój, potem porządkuj

Traktuj rozmowę, notatki, załączniki, pliki i linki jako jeden zrzut. Jeśli użytkownik zaznaczy,
że jeszcze nie skończył, krótko to potwierdź i zaczekaj. W przeciwnym razie przejdź dalej bez zbędnych formalności.
Przeczytaj dostarczone materiały i dane z repozytorium. W przypadku artykułu lub linku bez pytania
wyodrębnij jego tezę, wniosek, ograniczenia, ramy czasowe i konsekwencje. Gdy znaczenie mają aktualne standardy,
interfejsy API lub plany rozwoju, dotrzyj do źródeł pierwotnych za pomocą `/read-the-damn-docs` lub `/research`.

Oddziel:

- fakty ze źródeł i repozytorium;
- obserwacje, preferencje i ograniczenia użytkownika;
- uzasadnione wnioski, wyraźnie oznaczone jako wnioski;
- sprzeczności i informacje, które rzeczywiście pozostają nieznane.

Nigdy nie proś użytkownika o powtórzenie odpowiedzi, która znajduje się już w zrzucie lub dostępnych danych.

## 2. Odtwórz obszar problemowy

Wyodrębnij uczestników, problemy, rezultaty, systemy, czynniki wyzwalające, ograniczenia, pomysły, odrzucone kierunki,
pilność i kryteria sukcesu. Przekształć domyślne odpowiedzi w **Rejestr odpowiedzi**, używając trzech stanów:

- **Ustalone** -- podane wprost lub bezpośrednio poparte dowodami;
- **Wstępne** -- wywnioskowane i możliwe do bezpiecznego zakwestionowania;
- **Nieznane** -- brakujące i mogące zmienić kierunek.

Nazwij szeroki obszar, zanim zaproponujesz działania; odróżnij potrzebę od sugerowanych rozwiązań.

## 3. Rozbuduj mapę możliwości

Wygeneruj każdy istotnie różny kierunek poparty dowodami; grupuj duplikaty. Zwykle przedstaw 2–5, ale zachowaj
ich więcej, gdy jest to uzasadnione. Uwzględniaj produkt, UX, prace inżynieryjne, dokumentację i badania tylko wtedy, gdy znajdują potwierdzenie w materiale.

Dla każdej możliwości określ:

1. rezultat, uczestnika i dowody, które ją uzasadniają;
2. prawdopodobne rezultaty prac, zależności, ryzyka i otwarte decyzje;
3. najtańszy kolejny sposób weryfikacji: sprawdzenie informacji, prototyp, pomiar lub odwracalny fragment rozwiązania.

Zarekomenduj kierunek lub zgodny zestaw kierunków na podstawie wartości, dowodów, pilności i odwracalności.
Zachowaj widoczność alternatyw; mapa nie oznacza, że każdy element trafi do backlogu.

## 4. Zwróć artefakt

Użyj poniższej struktury, pomijając puste sekcje:

```markdown
## Brain dump brief

### Orientation
<surface, central tension, and recommended starting direction or bundle>

### Source synthesis
<important conclusions, facts, implications, contradictions, and citations or paths>

## Answer ledger
| Likely grilling question | Extracted answer | State | Evidence |
|---|---|---|---|
| ... | ... | Settled / Tentative / Unknown | ... |

## Opportunity map
### <Opportunity>
- Outcome:
- Why this is plausible:
- Work products:
- Risks and dependencies:
- Cheapest next proof:

## Grilling handoff
- Settled context to preserve:
- Tentative assumptions to challenge:
- Material user decisions still open:
- Facts to look up without asking the user:
- Candidate prototypes or measurements:
```

Artefakt powinien być na tyle samodzielny, aby wystarczył w następnym etapie, ale zamiast kopiować źródła, zamieszczaj do nich linki lub odwołania.

## 5. Przekaż do analizy

Przejdź do `/grilling`, gdy pozostają istotne decyzje. Przekaż każdy kierunek możliwości. Pytaj wyłącznie
o elementy **Nieznane**, które mogą unieważnić dany kierunek lub zmienić jego priorytet; kwestionuj elementy **Wstępne**,
gdy potencjalne konsekwencje są istotne. Traktuj elementy **Ustalone** jako już wyjaśnione, chyba że przeczą im nowe dowody.

W przeciwnym razie zakończ na opisie i zarekomenduj kolejny krok: wyszukanie informacji, stworzenie prototypu, specyfikacji, planu lub wykonanie prac.
