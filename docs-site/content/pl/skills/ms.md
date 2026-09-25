---
title: /ms
description: >-
  Oceń, czy PR, plan lub zgłoszenie uzasadnia poświęcony czas: jedna kategoria,
  wskazany beneficjent, wpływ na koszty lub przychody, kryteria akceptacji i
  mały, odwracalny zakres zmian.
type: skill
sidebar:
  label: /ms
---
![Diagram umiejętności /ms](/diagrams/skills/ms.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/ms.excalidraw)


Oceń jeden aspekt: czy warto teraz wdrożyć tę zmianę, dla kogo i czy jej zakres jest najmniejszy,
odwracalny i wystarczający, by wykazać wartość. Reguły znajdziesz w [RULES.md](https://github.com/malinskibeniamin/skills/blob/main/ms/RULES.md).

Uruchamiaj samodzielnie dla PR-a, gałęzi, planu lub zgłoszenia albo jako **rolę ms** w `/review`
przy każdym przeglądzie PR-a. Nie uruchamia agentów.

## Kategorie [#lanes]

Każdy PR służy jednej kategorii. Odczytaj wiersz `Lane:` w opisie PR-a; jeśli go brakuje, wywnioskuj kategorię.

| Kategoria | Uzasadnia poświęcony czas, gdy | Wymagane dowody |
|---|---|---|
| Utrzymanie działania | eliminuje żmudną pracę, ryzyko lub wydatki | eliminowany incydent, alert lub koszt; sposób wycofania zmiany |
| Komfort pracy | odblokowuje ludzi lub chroni reputację | wynik liczbowy przed i po zmianie lub odtworzenie błędu; kto odczuwa skutki |
| Nowa wartość | przybliża określony segment do zapłaty lub pozostania | beneficjent, droga do przychodu, najmniejszy zakres możliwy do wdrożenia, funkcja domyślnie wyłączona przy wdrożeniu |
| Wyczucie projektowe | pozwala uniknąć kosztownej, nieodwracalnej decyzji lub usuwa zbędne pojęcie | uniknięty przyszły koszt; dlaczego teraz jest taniej niż później |

Rozdziel zmiany z różnych kategorii, chyba że jedna jest niezbędna do realizacji drugiej.

## Procedura [#procedure]

1. **Ustal zakres:** tytuł i opis PR-a, powiązane zgłoszenie, commity, diff. Ufaj diffowi bardziej niż deklaracjom.
2. **Sklasyfikuj:** kategoria i obszary: przepływ pieniędzy, funkcje dla klientów, kontrakt/API, utrzymanie,
   dokumentacja, CI lub cykl pracy programisty, platforma agentów.
3. **Zapytaj:** Kogo ten problem dotyka dzisiaj i ile go kosztuje? Co w obserwowalny sposób potwierdzi ukończenie?
   Jaki jest najmniejszy odwracalny zakres i co świadomie z niego wyłączono?
4. **Wczytaj:** odpowiednie sekcje [RULES.md](https://github.com/malinskibeniamin/skills/blob/main/ms/RULES.md). Stosuj reguły S/A, jednoznaczne naruszenia B
   i tylko oczywiste naruszenia C.
5. **Oceń prawdopodobieństwo przychodu:** wysokie, średnie, niskie lub żadne, z jednym uzasadnieniem. Brak jest dopuszczalny
   przy utrzymaniu, komforcie pracy lub wyczuciu projektowym, jeśli istnieją dowody ich wartości. Niewiadome pozostają niewiadomymi;
   nigdy nie wymyślaj liczb.

## Waga problemów [#severity]

- **P1:** fałszywa informacja o powodzeniu, stanie działania lub cenie; nieznane zużycie rozliczane jako bezpłatne; użytkownicy darmowej wersji pozbawieni
  dostępu lub objęci błędnymi ograniczeniami; wykorzystanie danych klientów wykraczające poza oczekiwania; naruszenie kontraktu bez stopniowego wdrożenia.
- **P2:** brak beneficjenta lub kategorii; mieszanie kategorii; twierdzenia o wydajności lub CI bez pomiarów;
  uogólnienia na zapas; brak obserwowalnych kryteriów ukończenia; dokumentacja sprzeczna z zachowaniem.
- **P3:** sformułowania, nazewnictwo lub brak wskazania oczywistej kategorii.

Uwagi dotyczące wartości nigdy nie blokują potwierdzonej poprawki błędu działania lub bezpieczeństwa.

## Wyłączenia [#exclude]

- Poprawność, bezpieczeństwo i styl, za które odpowiadają inne role `/review`.
- Weto strategiczne: kwestionuj dopasowanie i wskazuj brakujące dowody; decyzję podejmuje właściciel.
- Pliki generowane.

## Wynik [#output]

`Lane: <lane> | Beneficiary: <who> | Revenue likelihood: <level> - <reason>`, a następnie
`[P1|P2|P3] <rule-id> <file:line or PR body> <missing evidence> - <smallest fix>`.
Limit dla roli: 250 słów. Jeśli nie ma zastrzeżeń:
`APPROVED -- <lane>, <beneficiary>, value evidenced.`
