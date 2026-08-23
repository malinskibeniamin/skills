---
title: /eli5
description: >-
  Wyjaśnij temat zupełnie początkującej osobie za pomocą samodzielnej ilustracji
  w HTML. Używaj dla /eli5, działania modułu, kompromisów, przyczyn incydentów
  lub dowolnych wyjaśnień opartych na dużych elementach wizualnych i niewielkiej
  ilości tekstu.
type: skill
sidebar:
  label: /eli5
---
![Diagram umiejętności /eli5](/diagrams/skills/eli5.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/eli5.excalidraw)

Wyjaśnij temat osobie, która nic o nim nie wie. Użyj żądania jako tematu;
w przypadku jawnego wywołania uznaj `$ARGUMENTS` za rozstrzygające.

## Zasady

1. Zanim uprościsz wyjaśnienie, oprzyj je na dowodach. Sprawdź odpowiednie materiały źródłowe
   dotyczące modułu, kompromisu lub incydentu. W przypadku faktów zewnętrznych preferuj aktualne
   źródła pierwotne. Nigdy nie wymyślaj ogniwa przyczynowego, aby uprościć historię. Oznaczaj fakty
   i wnioski oddzielnie, w tym istotne obszary niepewności.
2. Wybierz jeden model myślowy, który zachowuje istotę prawdy. W miarę możliwości usuń żargon;
   nieunikniony żargon wyjaśnij przy ilustracji zwykłymi słowami.
3. Utwórz jeden samodzielny artefakt HTML: duże ilustracje, mało słów i bez eseju ozdobionego
   ikonami.
4. Zweryfikuj wyjaśnienie na podstawie dowodów, a następnie sprawdź wyrenderowany artefakt
   przy szerokim i wąskim obszarze wyświetlania.

## Odbiorcy

Załóż brak wcześniejszej wiedzy na dany temat, a nie niski poziom inteligencji. Używaj znanych
przedmiotów, konkretnych czasowników i spokojnego, dorosłego tonu. Nigdy nie pisz dziecinnie ani
protekcjonalnie. Jeśli pominięcie szczegółu zmieniłoby wniosek na przeciwny, zachowaj go; w innym
przypadku przenieś go do uwag o źródłach.

Zadaj jedno krótkie pytanie tylko wtedy, gdy wybór niewłaściwego zakresu uczyniłby wyjaśnienie
mylącym. W przeciwnym razie wybierz najmniejszy użyteczny zakres, dyskretnie podaj założenie
i kontynuuj.

## Gramatyka wizualna

- Preferuj od trzech do sześciu scen. Każdej scenie lub panelowi przypisz jeden pomysł i wyraźną
  kolejność czytania.
- Używaj dużych diagramów, relacji przestrzennych, ścieżek ruchu, osi czasu, skal lub stanów
  przed i po. Obrazy dekoracyjne się nie liczą.
- Ogranicz główną historię do krótkich nagłówków i etykiet. Unikaj akapitów. Niech elementy
  wizualne przekazują kolejność, ilość, odpowiedzialność i przyczynę.
- W przypadku modułu pokaż wejście -> przekształcenie -> wyjście. W przypadku kompromisu pokaż,
  co zyskano i co utracono. W przypadku incydentu pokaż wyzwalacz -> propagację -> wpływ ->
  przywrócenie działania, odmiennie oznaczając fakty i wnioski.
- Zakończ jednym obrazem i jednym zdaniem, które ponownie przedstawiają główny model myślowy.

## Artefakt HTML

- Używaj semantycznego HTML z wbudowanymi CSS i SVG. Umieść w pliku wszystkie wymagane style,
  ilustracje i skrypty; nie korzystaj z CDN-ów, zdalnych fontów, bezpośrednio osadzonych zdalnych
  obrazów ani etapu budowania.
- Stosuj znaki ucieczki w niezaufanym tekście źródłowym zamiast wstawiać nieprzetworzony HTML.
- Zadbaj, aby układ był responsywny, miał wysoki kontrast i pozostawał czytelny bez animacji.
  Uwzględniaj `prefers-reduced-motion`; nie wyłączaj powiększania przez użytkownika ani nie
  polegaj wyłącznie na kolorze.
- Przy małej szerokości przekształcaj poziome diagramy w ułożone pionowo sceny, zamiast zmniejszać
  etykiety do nieczytelnego rozmiaru.
- Zapewnij tekst alternatywny lub dostępny opis każdemu istotnemu elementowi wizualnemu. Używaj
  zwięzłych, widocznych etykiet oraz `aria-labelledby`, `<figcaption>` lub równoważnej semantyki.
- Umieść cytowania, lokalizacje plików, założenia i niezbędne niuanse w zwięzłej sekcji
  `<details>` o nazwie „Źródła i założenia”, aby opowieść wizualna pozostała zwięzła.
- Dodawaj wbudowany JavaScript tylko wtedy, gdy interakcja znacząco ułatwia zrozumienie.
  Statyczny artefakt nadal musi przekazywać istotę wyjaśnienia.

Użyj natywnego mechanizmu hosta do obsługi artefaktów HTML, jeśli jest dostępny. W przeciwnym
razie zapisz plik w natywnym katalogu tymczasowym hosta, na przykład utworzonym za pomocą
`mktemp -d "${TMPDIR:-/tmp}/eli5.XXXXXX"`; nie dodawaj jednorazowych wyjaśnień do repozytorium.

## Weryfikacja i zwrot wyniku

Otwórz wynik w odizolowanej przeglądarce lub podglądzie hosta, nigdy w przeglądarce należącej
do użytkownika. Sprawdź, czy pierwszy widok przedstawia temat, etykiety nie są przycięte,
elementy wizualne pozostają czytelne na wąskim ekranie, a każde stwierdzenie faktyczne lub
przyczynowe jest zgodne z materiałem źródłowym. Przed zwróceniem wyniku popraw usterki.

Zwróć artefakt lub jego ścieżkę bezwzględną, jednozdaniowe podsumowanie oraz wszelkie istotne
obszary niepewności. Nie powtarzaj pełnego wyjaśnienia na czacie.
