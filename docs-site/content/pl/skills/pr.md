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
2. Porównaj opublikowany opis z **pełną różnicą PR-a**, pierwotnym celem i aktualną weryfikacją, nie tylko ostatnią turą lub commitem. W stosach oceniaj każdą zmienioną warstwę względem jej rodzica.
3. Osobno załaduj [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md). Ponownie oceń wartość biznesową i wpływ na produkt lub bazę kodu; wykorzystaj nadal aktualne dowody, powtórz unieważnione porównania i usuń niepoparte twierdzenia. Gdy wartość jest nieznana, napisz `not established`.
4. Przy autoryzowanej pracy obejmującej zmiany lub dostarczenie zaktualizuj nieaktualny opis w miejscu. Pisz zwięźle: co się zmienia, kto korzysta, dlaczego to ważne, rozstrzygające dowody i istotne ryzyka. Zastępuj nieaktualne punkty; zamiast dopisywać dziennik sesji, podawaj odnośniki do szczegółów. Zachowaj intencję autora i wymagane dowody; pomiń edycję, jeśli opis jest już poprawny.
5. Po edycji ponownie odczytaj opis z serwera i sprawdź, czy opisuje opublikowany stan gałęzi źródłowej. Żądania tylko do odczytu zgłaszają rozbieżności bez edycji. Wyraźny zakaz wypychania lub zakres lokalny odracza publikację; nie opisuj nieopublikowanej pracy jako dostarczonej.

## Szablon opisu [#body-template]

Użyj tego szablonu do napisania opisu PR:

```markdown
## Summary

<outcome and why it matters to the affected user or caller>
<reviewer focus or specific question; say if no special input is needed>
<smallest useful diagram, diff-sketch, or tree>

## Evidence

<frontend: before/after flow video playing inline (user-attachments URL), then screenshot table>

- **Before:** <screenshot/output/failing test run>
  **After:** <screenshot/output/passing test run>

## Merge Danger

**Door:** <one-way or two-way>

<optional: description>

**Blast Radius:** <affected users, callers, or contracts>

<rollback path and unresolved risks, when applicable>
```

## Sekcje [#sections]

Pomiń wszelkie wstępy i ogranicz opis do minimum. Używaj języka domeny użytkownika z `GLOSSARY.md`.

### Podsumowanie [#summary]

Oddziel zmiany główne od plików generowanych lub mechanicznych; wskaż przydatne punkty wejścia do przeglądu bez inwentarza wszystkich plików.

Zacznij od wartości i kwestii wymagających uwagi recenzenta, a nie od listy zmian. Oddziel zaobserwowane wyniki od oczekiwań.
Następnie wybierz najmniejszy widok wyjaśniający sedno; pomiń wizualizację, która niczego nie wyjaśnia.

Wybierz najmniejszy widok z [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md).

#### Zmienione decyzje [#changed-decisions]

Opisz istotne odstępstwa od zapisanego planu lub kontraktu rezultatu, jeśli zmieniają zakres, kontrakty, weryfikację lub ryzyko wdrożenia. Wykorzystaj istniejące notatki lub mapy intencji:
poprzedni wybór -> nowe dowody -> obecny wybór -> konsekwencje dla przeglądu.
Opis PR musi być samowystarczalny; pomijaj puste historie zmian i nigdy nie wymyślaj wcześniejszego planu ani uzgodnień.

Fragmenty sesji są opcjonalnym kontekstem. Używaj tylko istotnych fragmentów, dopuszczonych do udostępnienia, z usuniętymi danymi wrażliwymi i dostępnych dla recenzentów; w przeciwnym razie podaj bezpieczne, samodzielne uzasadnienie.
Nie rozszerzaj zakresu udostępniania ani uprawnień do wykonywania działań tylko po to, by podać link. Długość sesji lub liczba tur nie dowodzi poprawności ani staranności; sprawdzaj twierdzenia na podstawie bieżącego diffu i dowodów z wykonania.

#### Wskazówki [#guidance]

Umieść wizualizacje obok tekstu, który wspierają. Pokaż tylko kluczowe wywołania, pliki, właściwości, stany i granice.

Używaj wyłącznie widoków, które pomagają zrozumieć zmianę.

### Dowody [#evidence]

Konkretne dowody, że zmiana działa. Pokaż stan przed i po. Wymień niewykonane kontrole i pozostałe niewiadome; przechodzące testy nie dowodzą przeglądu ani zgody ludzi.

Przy szerokich zmianach interfejsu powiąż problem użytkownika -> zmianę widocznego obszaru -> dowody -> kryterium akceptacji, korzystając z [map zmian interfejsu](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md#ui-change-maps).

Przy zmianach architektury backendu, przepływu danych, kontraktów API lub przebiegu pracy postępuj zgodnie z [diagramami backendowymi](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md) i wywołaj `excalidraw-diagram`. Dodaj zwięzłe porównanie stanu przed i po oraz link do edytowalnego źródła; odśwież odpowiednie utrzymywane diagramy. Błędy diagramów zgłaszaj i kontynuuj pracę; nigdy nie blokują PR ani nie zastępują dowodów z testów.

Przy każdej zmianie we frontendzie nagranie rzeczywistego przebiegu interakcji z interfejsem przed zmianą i po niej (kliknięcia, wpisywanie tekstu, stan wynikowy; nigdy nieruchoma strona), odtwarzane bezpośrednio w opisie, wraz ze zrzutami ekranu stanowi najwyższą klasę dowodów i jest wymagane. Umieść je tuż po podsumowaniu, aby osoby przeglądające PR zobaczyły zmianę, zanim o niej przeczytają. Nagraj, zmontuj i udostępnij je zgodnie z [instrukcjami dotyczącymi dowodów wizualnych w commit-push-pr](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5).

Dowody z wykonania to klasa tuż za nimi: wyniki testów, dane wyjściowe konsoli. Pokaż w pseudokodzie dokładny test, który wcześniej nie przechodził, a teraz przechodzi.

### Ryzyko scalenia [#merge-danger]

Wskaż sposób wycofania zmiany. Drzwi dwukierunkowe pozwalają tanio się wycofać; decyzje destrukcyjne lub trudne do odwrócenia są jednokierunkowe.

Wymień dotkniętych użytkowników, wywołujących, kontrakty i wiarygodne scenariusze awarii, w tym współdzielonych odbiorców.
