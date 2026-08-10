---
title: /prototype
description: >-
  Twórz tymczasowe dowody rozstrzygające nierozwiązane kwestie dotyczące logiki,
  interakcji lub warstwy wizualnej. Użyj, gdy działający przykład pozwoli
  wyjaśnić zachowanie lub niepewność dotyczącą interfejsu przed podjęciem
  decyzji.
type: skill
sidebar:
  label: /prototype
---
![Diagram umiejętności /prototype](/diagrams/skills/prototype.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/prototype.excalidraw)

Prototyp odpowiada na jedno konkretnie określone pytanie. Jest dowodem, a nie wczesną gałęzią produkcyjną.

Wybierz najprostszy wariant, który wiernie odwzorowuje problem:

- Niepewność dotycząca logiki lub stanu -> mały wykonywalny model stanu; zobacz [LOGIC.md](https://github.com/malinskibeniamin/skills/blob/main/prototype/LOGIC.md).
- Niepewność dotycząca interfejsu lub interakcji -> kilka istotnie różniących się wariantów; zobacz
  [UI.md](https://github.com/malinskibeniamin/skills/blob/main/prototype/UI.md).
- Niepewność dotycząca API lub narzędzia -> minimalne wywołanie w środowisku testowym lub z użyciem fixtury.

Jeśli to możliwe, umieść działające artefakty w `.context/prototypes/<question>/`, a obok
docelowego kodu tylko wtedy, gdy muszą zostać załadowane przez rzeczywiste środowisko uruchomieniowe. Wyraźnie oznacz każdy artefakt znajdujący się w drzewie projektu.

## Przechowywanie

Zachowaj ukończony prototyp jako wykonywalne **źródło pierwotne**, ale nigdy nie scalaj kodu
przeznaczonego wyłącznie do prototypowania z główną gałęzią:

- Gdy wskazany punkt końcowy zezwala na zatwierdzanie zmian, zapisz artefakt na odizolowanej
  gałęzi `prototype/<name>` i pozostaw odnośnik kontekstowy w zgłoszeniu lub rejestrze decyzji.
- W przeciwnym razie zachowaj go w `.context/prototypes/<question>/` i podaj ścieżkę. Przed
  oczyszczeniem zmian przeznaczonych do wydania przenieś lub skopiuj tam każdy artefakt znajdujący się w drzewie projektu. Nie usuwaj go.

Zapisz pytanie, dowody i werdykt w zgłoszeniu, ADR, notatkach implementacyjnych lub
zatwierdzeniu implementującym zmianę. W głównej gałęzi pozostaje wyłącznie zweryfikowana decyzja produkcyjna.

## Ograniczenia

1. Najpierw używaj biblioteki standardowej i istniejących zależności; bez tworzenia szkieletu niezwiązanego z
   pytaniem.
2. Jedno polecenie do uruchomienia.
3. Wyłącznie trwałość w pamięci lub w danych tymczasowych.
4. Pokaż istotny stan i obserwacje.
5. Zanim oprzesz się na werdykcie, uruchom `/dogfood` jeden raz dla ścieżki rozstrzygającej i prawdopodobnego
   przypadku brzegowego; nie testuj w ten sposób każdej pośredniej zmiany.
6. Gdy ścieżka rozstrzygająca odpowie na pytanie, zastosuj powyższe zasady przechowywania.

Jeśli prototyp przeczy planowi, ponownie przeanalizuj odpowiednią decyzję przed rozpoczęciem
implementacji produkcyjnej.
