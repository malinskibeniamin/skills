---
title: /brain-dump
description: >-
  Przekształcaj nieuporządkowane myśli, monologi, notatki, artykuły, pliki lub
  linki w oparty na dowodach brief z wieloma możliwościami przed grillowaniem.
  Używaj, gdy użytkownik zna ogólny obszar, ale nie ma stabilnego celu,
  konkretnego problemu ani precyzyjnego pytania.
type: skill
sidebar:
  label: /brain-dump
---
![Diagram umiejętności /brain-dump](/diagrams/skills/brain-dump.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/brain-dump.excalidraw)

Przekształć surowe sygnały w opcjonalny pakiet odkrywania, który skraca i
precyzuje późniejszą sesję `/grilling`. Zachowaj szeroki zakres: jeden brain dump
może ujawnić kilka niezależnych problemów, zadań, zgłoszeń lub kierunków badań.
Nie sprowadzaj go na siłę do jednego celu.

Pozostań na etapie odkrywania. Zwróć brief na czacie, chyba że użytkownik poprosi
o jego zapisanie lub opublikowanie. Nie implementuj, nie twórz zgłoszeń ani nie
zamieniaj potencjalnych możliwości w zobowiązania.

## 1. Najpierw przyswój, potem porządkuj

Traktuj całą rozmowę, wklejone notatki, załączniki, pliki i linki jako jeden
brain dump. Jeśli użytkownik wyraźnie mówi, że jeszcze nie skończył, krótko to
potwierdź i poczekaj. W przeciwnym razie przejdź dalej bez ceremonialnego pytania.

Przeczytaj dostarczone materiały i istotne dowody z repozytorium. W przypadku
artykułu lub linku bez pytania wyodrębnij główną tezę, wniosek, ograniczenia,
ramy czasowe i konsekwencje. Gdy znaczenie mają aktualne standardy, protokoły,
API lub roadmaps, dotrzyj do źródeł pierwotnych przez `/read-the-damn-docs` lub
`/research`.

Rozdziel:

- fakty ze źródeł i repozytorium;
- obserwacje, preferencje i ograniczenia użytkownika;
- rozsądne wnioski, wyraźnie oznaczone jako wnioski;
- sprzeczności i informacje rzeczywiście nieznane.

Nigdy nie proś użytkownika o powtórzenie odpowiedzi, która już znajduje się w
brain dumpie lub dowodach.

## 2. Odtwórz obszar problemowy

Wyodrębnij aktorów, trudności, pożądane rezultaty, systemy objęte zmianą,
wyzwalacze, ograniczenia, istniejące pomysły, odrzucone kierunki, pilność i
sygnały sukcesu. Zapisz domyślne odpowiedzi w **Rejestrze odpowiedzi** z jednym
z trzech stanów:

- **Rozstrzygnięte** -- wyrażone wprost lub bezpośrednio poparte dowodami;
- **Wstępne** -- wywnioskowane i bezpieczne do zakwestionowania;
- **Nieznane** -- brakujące i mogące zmienić kierunek.

Nazwij szeroki obszar, zanim zaproponujesz pracę. Oddziel podstawową potrzebę
od rozwiązania, o którym akurat wspomniano w brain dumpie.

## 3. Rozwiń mapę możliwości

Wygeneruj każdy istotnie odmienny kierunek poparty dowodami; grupuj duplikaty
zamiast sztucznie wydłużać listę. Zwykle pokaż 2-5 kierunków, ale zachowaj więcej,
gdy brain dump rzeczywiście obejmuje szerszy zakres prac. Uwzględniaj produkt,
UX, funkcje, błędy, testy, odporność, dokumentację, architekturę, doświadczenie
programistów, CI, wydajność, migrację i badania tylko wtedy, gdy są uzasadnione.

Dla każdej możliwości podaj:

1. rezultat i aktora, którego dotyczy;
2. stojący za nią dowód lub sygnał;
3. prawdopodobne produkty pracy;
4. zależności, ryzyka i otwarte decyzje;
5. najtańszy następny dowód: wyszukanie, prototyp, pomiar lub odwracalny fragment.

Zarekomenduj kierunek początkowy lub zgodny pakiet na podstawie wartości,
dowodów, pilności i odwracalności. Zachowaj widoczność alternatyw. Mapa
możliwości nie jest obietnicą, że każdy element powinien trafić do backlogu.

## 4. Zwróć artefakt

Użyj poniższej struktury, usuwając puste sekcje:

```markdown
## Brief z brain dumpu

### Orientacja
<obszar, główne napięcie i zalecany kierunek początkowy lub pakiet>

### Synteza źródeł
<ważne wnioski, fakty, konsekwencje, sprzeczności oraz cytowania lub ścieżki>

## Rejestr odpowiedzi
| Prawdopodobne pytanie podczas grillowania | Wyodrębniona odpowiedź | Stan | Dowód |
|---|---|---|---|
| ... | ... | Rozstrzygnięte / Wstępne / Nieznane | ... |

## Mapa możliwości
### <Możliwość>
- Rezultat:
- Dlaczego jest prawdopodobna:
- Produkty pracy:
- Ryzyka i zależności:
- Najtańszy następny dowód:

## Przekazanie do grillowania
- Rozstrzygnięty kontekst do zachowania:
- Wstępne założenia do zakwestionowania:
- Istotne decyzje użytkownika, które pozostają otwarte:
- Fakty do wyszukania bez pytania użytkownika:
- Potencjalne prototypy lub pomiary:
```

Artefakt powinien być wystarczająco samodzielny dla kolejnego etapu, ale zamiast
kopiowania materiałów źródłowych podawaj do nich linki lub cytowania.

## 5. Przekaż do grillowania

Kontynuuj przez `/grilling`, gdy pozostają istotne decyzje użytkownika. Przekaż
cały brief wraz ze wszystkimi ścieżkami możliwości. Pytaj tylko o **Nieznane**
elementy, które mogą unieważnić ścieżkę lub zmienić jej priorytet; kwestionuj
**Wstępne** elementy, gdy ryzyko ma znaczenie. Traktuj **Rozstrzygnięte** elementy
jako już wyjaśnione, chyba że nowe dowody im przeczą.

Jeśli nie pozostała żadna istotna decyzja użytkownika, zakończ po briefie i
zarekomenduj odpowiednią umiejętność wyszukiwania, prototypowania, specyfikacji,
planowania lub wykonania zamiast wymyślać pytania do grillowania.
