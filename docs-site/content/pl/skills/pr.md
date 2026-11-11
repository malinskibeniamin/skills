---
description: >-
  Używaj przy pisaniu opisu PR lub aktualizowaniu zakresu, wartości biznesowej i
  dowodów w otwartym PR-ze tej sesji.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - pr
sidebar:
  label: /pr
title: /pr
type: skill
---
![Diagram umiejętności /pr](/diagrams/skills/pr.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/pr.excalidraw)

Pełne [źródło Matta Pococka](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/engineering/pr/SKILL.md) i [oryginalne podziękowania](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/engineering/pr/CREDITS.md) są przypięte wraz z całym zestawem umiejętności. Lokalna adaptacja zachowuje poniższe reguły opisu PR, dowodów i własności PR-a bieżącej sesji.


Przeczytaj [kontrakt ochrony uwagi czytelnika](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md).

## Istniejący PR [#existing-pr]

Na początku lub po wznowieniu sesji, po istotnych zmianach zakresu, implementacji lub dowodów i przed przekazaniem pracy:

1. Znajdź otwarte PR-y jawnie powiązane z tą rozmową, sesją lub czatem; w przeciwnym razie sprawdź bieżącą gałąź przez `gh pr view`. Zweryfikuj stan otwarty, repozytorium, gałąź źródłową, bazę i własność. Nie wybieraj niepowiązanego ostatniego PR-a. Brak otwartego PR-a oznacza brak aktualizacji i nie daje zgody na jego utworzenie.
2. Porównaj opublikowany opis z **pełną różnicą PR-a**, pierwotnym celem i aktualną weryfikacją, nie tylko ostatnią turą lub commitem. W stosach oceniaj każdą zmienioną warstwę względem jej rodzica. Sprawdź aktualność zrzutów, oznaczeń i legendy zgodnie z [adnotacjami wizualnymi](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations).
3. Osobno załaduj [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md). Ponownie oceń wartość biznesową i wpływ na produkt lub bazę kodu; wykorzystaj nadal aktualne dowody, powtórz unieważnione porównania i usuń niepoparte twierdzenia. Gdy wartość jest nieznana, napisz `not established`.
4. Przy autoryzowanej pracy obejmującej zmiany lub dostarczenie odświeżaj razem zmienione zrzuty, oznaczenia i legendę; zaktualizuj pierwsze zdanie tak, aby obejmowało całą aktualną zmianę. Zastępuj nieaktualne punkty zwięzłą informacją o odbiorcy, wartości, rozstrzygających dowodach i istotnych ryzykach. Zachowaj intencję autora i wymagane dowody; podlinkuj szczegóły, pomiń poprawne opisy i nie dodawaj dziennika sesji.
5. Po edycji ponownie odczytaj opis z serwera i sprawdź, czy opisuje opublikowany stan gałęzi źródłowej. Żądania tylko do odczytu zgłaszają rozbieżności bez edycji. Wyraźny zakaz wypychania lub zakres lokalny odracza publikację; nie opisuj nieopublikowanej pracy jako dostarczonej.

## Szablon opisu [#body-template]

Użyj tego szablonu do napisania opisu PR:

```markdown
<one sentence capturing the entire change and why it matters>

- Review: <optional focus or decision; omit if none>
- Testing: <decisive checks and observed results; before -> after; gaps>
- Risk: <affected contracts, failure modes, rollout limits, and how to revert>
```

## Sekcje [#sections]

Pierwsze zdanie jest wymaganym skrótem, a nie zbędnym wstępem; przestrzegaj [budżetu uwagi dla PR](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#match-the-artifact). Poniżej zostaw tylko potrzebne szczegóły. Poniższe tematy to wskazówki dla autora, nie obowiązkowe nagłówki PR. Długie raporty podlinkuj lub zwiń; wymagane materiały wizualne umieść bezpośrednio po pierwszym zdaniu. Używaj języka domeny użytkownika z `GLOSSARY.md`.

### Podsumowanie [#summary]

Wskaż kwestie wymagające uwagi recenzenta tylko wtedy, gdy to przydatne; nie powtarzaj pierwszego zdania. Oddziel zmiany główne od plików generowanych lub mechanicznych; wskaż przydatne punkty wejścia do przeglądu bez inwentarza wszystkich plików. Oddziel zaobserwowane wyniki od oczekiwań.

Opis PR ma być zwięzłym podsumowaniem dla operatora: zachowanie i wartość, rozstrzygające dowody, decyzje domenowe, pozostałe ryzyko i sposób odzyskiwania oraz następne działanie; szczegóły podlinkuj, aby ułatwić wznowienie pracy. Osobne podsumowania HTML lub wizualne wymagają wyraźnej prośby; zachowaj przegląd pełnego diffu i wymagane dowody wizualne.

Wybierz najmniejszy widok z [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md).

#### Zmienione decyzje [#changed-decisions]

Opisz istotne odstępstwa od zapisanego planu lub kontraktu rezultatu, jeśli zmieniają zakres, kontrakty, weryfikację lub ryzyko wdrożenia. Wykorzystaj istniejące notatki lub mapy intencji:
poprzedni wybór -> nowe dowody -> obecny wybór -> konsekwencje dla przeglądu.
W przypadku istotnych wyborów agenta nierozstrzygniętych w żądaniu lub planie zastosuj [audyt nowych decyzji](https://github.com/malinskibeniamin/skills/blob/main/shared/decision-deltas.md), również przy bezpośrednim wywołaniu tworzenia PR.
Opis PR musi być samowystarczalny; pomijaj puste historie zmian i nigdy nie wymyślaj wcześniejszego planu ani uzgodnień.

Fragmenty sesji są opcjonalnym kontekstem. Używaj tylko istotnych fragmentów, dopuszczonych do udostępnienia, z usuniętymi danymi wrażliwymi i dostępnych dla recenzentów; w przeciwnym razie podaj bezpieczne, samodzielne uzasadnienie.
Nie rozszerzaj zakresu udostępniania ani uprawnień do wykonywania działań tylko po to, by podać link. Długość sesji lub liczba tur nie dowodzi poprawności ani staranności; sprawdzaj twierdzenia na podstawie bieżącego diffu i dowodów z wykonania.

Umieść wizualizacje obok tekstu, który wspierają. Pokaż tylko kluczowe wywołania, pliki, właściwości, stany i granice.

Pomiń widoki, które nie pomagają zrozumieć zmiany.

### Dowody [#evidence]

Konkretne dowody, że zmiana działa. Preferuj krótkie polecenie i wynik; pokazuj porównanie przed i po, gdy wyjaśnia zmianę, nie jako automatyczny wymóg multimediów. Wymień niewykonane kontrole i pozostałe niewiadome; przechodzące testy nie dowodzą przeglądu ani zgody ludzi.

Używaj [adnotacji wizualnych](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations) tylko wtedy, gdy trudno znaleźć różnicę. Przy szerokich zmianach UI korzystaj z [map zmian interfejsu](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md#ui-change-maps), gdy ułatwiają zrozumienie; unikaj powielonych zrzutów i osobnych podsumowań.

Przy zmianach backendu, API, Protobuf, kontraktów, architektury, przepływu danych lub procesów, których nie wyjaśniają zrzuty ani nagranie, dołącz [diagram backendowy](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md) bezpośrednio po zdaniu otwierającym; aktualizuj nieaktualne utrzymywane diagramy. Preferuj Excalidraw, a gdy renderowanie lub publikacja zawiedzie, użyj Mermaid bezpośrednio w opisie. Zachowaj wyniki testów: diagram wyjaśnia, ale nie dowodzi poprawności. [Kontrakt dowodów wizualnych](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5) określa dopuszczalne wyjątki i bramkę sprawdzającą opublikowany opis przed zakończeniem.

Dobieraj materiały według [dowodów wizualnych commit-push-pr](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5). Nagrywaj rzeczywisty przebieg tylko wtedy, gdy wymaga tego interakcja lub ruch albo gdy o to poproszono; w pozostałych przypadkach wystarczą obrazy i wyniki poleceń. Dowód jest przydatny ze względu na pytanie, na które odpowiada, a nie klasę medium. Podawaj zwięzłe, rzeczywiste wyniki testów, nie rekonstrukcje.

### Ryzyko scalenia [#merge-danger]

Wskaż sposób wycofania zmiany i określ, czy są to drzwi jednokierunkowe, czy dwukierunkowe. Drzwi dwukierunkowe pozwalają tanio się wycofać; decyzje destrukcyjne lub trudne do odwrócenia są jednokierunkowe.

Wymień dotkniętych użytkowników, wywołujących, kontrakty i wiarygodne scenariusze awarii, w tym współdzielonych odbiorców.
