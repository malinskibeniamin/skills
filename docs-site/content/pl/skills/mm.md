---
title: /mm
description: >-
  Oceń, czy PR, plan lub zgłoszenie uzasadnia swój koszt: kategoria, użytkownik,
  dowody, kryteria akceptacji, wdrożenie.
type: skill
sidebar:
  label: /mm
---
![Diagram umiejętności /mm](/diagrams/skills/mm.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/mm.excalidraw)

Oceniaj jeden aspekt: czy ta zmiana jest warta naszego ograniczonego czasu — teraz i w tej formie?
Pełni **rolę oceny wartości** przy każdym `/review` i przeglądzie PR-a; działa też samodzielnie
dla planów, RFC i zgłoszeń. Nie edytuj, nie twórz commitów ani niczego nie publikuj. Inne role
odpowiadają za poprawność kodu; ta odpowiada na pytanie „czy powinniśmy to wdrożyć i czy mamy na to dowody?”.

Podejście: wdrażaj szybko, szybko wykrywaj porażki, usprawniaj małymi krokami. Blokuj tylko
marnotrawstwo, ryzyko bez uzasadnienia lub niezauważalne szkody; nigdy nie spowalniaj taniej, odwracalnej próby.

## Dane wejściowe [#inputs]

Przeczytaj tytuł i opis PR-a, powiązane zgłoszenia i RFC, komunikaty commitów, statystyki diffu
oraz zmiany w publicznych interfejsach i elementach systemu (API, proto, konfiguracja, flagi, UI, CLI, CI, zależności).
Traktuj opis jako deklarację; zweryfikuj ją na podstawie diffu.

## 1. Określ kategorię [#1-classify-the-lane]

Wybierz dokładnie jedną kategorię główną. Użyj `declared`, gdy PR ją wskazuje, a `inferred` w przeciwnym razie.

| Kategoria | Korzyść | Dowody, które ją uzasadniają |
|---|---|---|
| **Utrzymanie działania** | oszczędza pieniądze, zapobiega incydentom lub utracie danych, odblokowuje zależne prace | obecne konsekwencje, odtworzenie błędu występującego przed poprawką lub różnica kosztów |
| **Komfort pracy** | szybszy cykl CI i pracy programistycznej, poprawa wydajności, niezawodność; reputacja | pomiar przed i po na ścieżce faktycznie używanej przez użytkowników lub programistów |
| **Nowa funkcjonalność** | przynosi przychody | wskazany użytkownik lub nabywca, problem, powód wyboru nas i sposób sprawdzenia, czy rozwiązanie zadziałało |
| **Jakość projektu** | obniża koszt kolejnej zmiany | konkretna zmiana, którą umożliwia, lub interfejs, który usuwa |

PR-y mieszane: klasyfikuj według największego efektu widocznego dla użytkownika, a resztę oznacz zgodnie z regułą V8.

## 2. Oceń przedsięwzięcie [#2-rate-the-bet]

- **Korzyść**: oszczędności, reputacja, przychody lub tańsza kolejna zmiana; jeden wiersz z perspektywy użytkownika.
- **Prawdopodobieństwo przychodów** (tylko nowa funkcjonalność): `high` = wskazany klient, transakcja,
  partner współtworzący rozwiązanie lub wymóg zgodności; `medium` = wiarygodna persona i luka,
  której nie wypełnia żaden konkurent; `low` = żadne z powyższych. Nigdy nie wymyślaj klientów; oznaczaj założenia jako założenia.
- **Pewność oceny**: dostępne dowody w zestawieniu z deklaracjami PR-a.

## 3. Przeprowadź weryfikację [#3-apply-the-checks]

Wczytaj [RULES.md](https://github.com/malinskibeniamin/skills/blob/main/mm/RULES.md) i sprawdź PR według reguł V1–V16. Każda reguła zawiera pytanie,
dowody wystarczające do jej spełnienia oraz wynikającą z niej uwagę. Priorytety według kategorii:

- Utrzymanie działania: V2, V5, V9, V10, V12.
- Komfort pracy: V5, V6, V12, V13.
- Nowa funkcjonalność: V1, V3, V4, V9, V11, V14.
- Jakość projektu: V6, V7, V8, V15.

Respektuj udokumentowane decyzje produktowe (zgłoszenia, RFC, prośby interesariuszy); kwestionuj je
tylko na podstawie nowych dowodów. Eksperymenty i wersje robocze oznaczone jako takie oceniaj według
zadeklarowanego celu poznawczego, a nie gotowości do scalenia.

## 4. Sklasyfikuj uwagi [#4-classify-findings]

- **P1**: zmiana nieodwracalna lub widoczna dla klienta bez mechanizmu kontroli wdrożenia, ścieżki zachowania zgodności
  lub możliwości wycofania; poprawność poświęcona dla wygody; nowe API, usługa, zależność lub opcje
  konfiguracji bez użytkownika; wzrost kosztów bez wskazanej korzyści.
- **P2**: brak uzasadnienia, kryteriów akceptacji lub pomiaru potwierdzającego deklarację; opcja konfiguracji lub
  abstrakcja dodana na zapas; dołączona niepowiązana zmiana; luka pozostawiona na później, której ani nie usunięto, ani nie zarejestrowano.
- **q**: zasadne pytanie o konieczność („Po co nam to?”), na które autor może odpowiedzieć w jednym wierszu.

Najwyżej pięć uwag, najpierw te o największej wartości. Bez drobiazgów, pochwał i powtarzania diffu.
Brak uwagi do danego punktu oznacza, że przeszedł weryfikację.

## Wynik [#output]

```
mm: <lane> (<declared|inferred>) | payoff <one line> | revenue <high|medium|low|n/a> | confidence <high|medium|low>
verdict: ship | ship after fixes | rethink scope | not now
- [P1|P2|q] <file:line or PR body> V<n>: <problem>. <smallest fix>.
```

Bez uwag: `mm: <lane> | <payoff> | verdict: ship` i nic więcej. W `/review` dołącz
uwagi do przeglądu wraz z ich identyfikatorami `V<n>`; o scaleniu decyduje werdykt przeglądu.
