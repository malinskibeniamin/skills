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
4. Przy autoryzowanych zmianach odświeżaj razem zrzuty, oznaczenia i legendę. Zachowaj pierwsze zdanie człowieka (zgłoś nieaktualną intencję do edycji przez autora); aktualizuj otwarcia napisane przez agenta i zastępuj jego nieaktualne punkty zwięzłą informacją o odbiorcy, wartości, dowodach i istotnych ryzykach. Odśwież [materiał do przeglądu przez człowieka](https://github.com/malinskibeniamin/skills/blob/main/shared/review-contract.md#human-review-handoff), w tym dobór recenzentów, odzyskiwanie i luki wykrywania. Zachowaj intencję człowieka i wymagane dowody; podlinkuj szczegóły, pomiń poprawne opisy i dziennik sesji.
5. Po edycji ponownie odczytaj opis z serwera i sprawdź, czy opisuje opublikowany stan gałęzi źródłowej. Żądania tylko do odczytu zgłaszają rozbieżności bez edycji. Wyraźny zakaz wypychania lub zakres lokalny odracza publikację; nie opisuj nieopublikowanej pracy jako dostarczonej.

## Szablon opisu [#body-template]

Użyj zwięzłego tytułu opisującego rezultat, zgodnego z konwencjami repozytorium. Tytuł i pierwsze zdanie należą do autora-człowieka: zachowaj dostarczone brzmienie. Jeśli tworzy je agent, oznacz je jako szkic do edycji przez człowieka; nie przypisuj mu autorstwa ani akceptacji. Autoryzowany szkic PR można opublikować. Przy aktualizacji zachowaj tekst człowieka i zgłoś zmianę intencji zamiast po cichu go przepisywać.

Kolejność: jedno zdanie o zmianie i jej celu -> tabela zrzutów przed/po dla UI -> klikalny prototyp, gdy przydatny -> opis agenta w jednym zwiniętym `<details>`. Link do prototypu może też poprzedzać tabelę. Pomijaj nieadekwatne sekcje zamiast publikować puste pola. Stosuj ten układ:

```markdown
<one human-authored line about the change and why, or an explicitly labeled agent draft>

| Before | After |
| --- | --- |
| ![Previous state](<hosted-before-image>) | ![New state](<hosted-after-image>) |

[Try the prototype](<reviewer-accessible-url>) — <states/variants; access requirement>

<details>
<summary>Agent-generated description</summary>

- Lane / Review: <beneficiary, scope, closest-review paths and owner routing/gaps>
- Testing: <commands, observed results, real-entrypoint evidence and gaps>
- Risk / Rollback: <failure modes, blast radius, recovery, detection and gaps>

<verified model/harness attribution when required>

</details>
```

Przed szczegółami umieść krótkie **widoczne ostrzeżenie** o nieudanej lub zablokowanej weryfikacji, istotnych ryzykach, kosztownym wycofaniu lub lukach wykrywania. Zwijaj rutynowe dowody, nie blokery. W opisie agenta oceń wszystkie pięć kryteriów [przekazania do przeglądu](https://github.com/malinskibeniamin/skills/blob/main/shared/review-contract.md#human-review-handoff), bez pięciu szablonowych nagłówków. Zachowaj wymagane odnośniki, kryteria akceptacji i pola repozytorium.

Dla zmian UI używaj porównywalnych rzeczywistych zrzutów bazy i kandydata zgodnie z [kontraktem dowodów wizualnych](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5). Wyjaśnij brak lub nieadekwatność porównania; nie wymyślaj stanu „przed” ani nie przedstawiaj zastępczych URL-i jako dowodów. Dla zmian poza UI pomiń tabelę i zachowaj wymagane diagramy. Prototyp uzupełnia, a nie zastępuje zrzuty i testy.

### Klikalne prototypy do przeglądu [#clickable-review-prototypes]

Gdy interakcje, trudno dostępne stany lub alternatywne podejścia warto wypróbować, podlinkuj [prototyp UI](https://github.com/malinskibeniamin/skills/blob/main/prototype/UI.md#shareable-review-prototype). Użyj rzeczywistych komponentów, fontów, tokenów i dostawców motywu aplikacji w lekkiej witrynie; granice Electron, kodu natywnego i backendu izoluj oznaczonymi fixturami. Recenzent powinien trafić do właściwego stanu bez pobierania gałęzi i konfiguracji pełnego środowiska. Dla otwartego pytania projektowego udostępnij istotnie różne podejścia z bezpośrednimi URL-ami wariantów i stanów. Ustalona mała zmiana nie wymaga wariantów ani nowego prototypu.

Wdrażaj wyłącznie przez udokumentowany, zatwierdzony proces Quick Site z SSO lub równoważny prywatny podgląd w docelowym repozytorium. Odszukaj jego polecenie i konfigurację. [Quick Shopify](https://shopify.engineering/quick) jest inspiracją, nie dostępem do infrastruktury ani przenośnym poleceniem wdrożenia. Gdy hosting lub SSO są niedostępne, zachowaj działający artefakt, zgłoś lukę i użyj zrzutów; nie publikuj po cichu publicznie ani nie dodawaj infrastruktury hostingu lub uwierzytelniania. Sprawdź dostęp recenzenta, docelowy stan linku i ładowanie zasobów; zanim nazwiesz witrynę chronioną SSO, potwierdź odmowę dostępu po wylogowaniu. Oznacz symulacje i niezweryfikowany dostęp. Powiąż URL i artefakt z przeglądaną rewizją; po istotnej zmianie odśwież je lub oznacz jako nieaktualne. Stosuj [zasady przechowywania prototypów](https://github.com/malinskibeniamin/skills/blob/main/prototype/SKILL.md#retention).


## Sekcje [#sections]

Pierwsze zdanie to wymagany skrót, nie wstęp; przestrzegaj [budżetu uwagi dla PR](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#match-the-artifact). Poniżej zostaw tylko potrzebne szczegóły. Poniższe tematy to wskazówki dla autora, nie obowiązkowe nagłówki. Zwijaj szczegóły agenta zgodnie z szablonem; wymagane materiały wizualne umieść po pierwszym zdaniu i ewentualnym istotnym ostrzeżeniu. Używaj języka domeny użytkownika z `GLOSSARY.md`.

### Podsumowanie [#summary]

Wskaż kwestie wymagające uwagi recenzenta tylko wtedy, gdy to przydatne; nie powtarzaj pierwszego zdania. Oddziel zmiany główne od plików generowanych lub mechanicznych; wskaż przydatne punkty wejścia do przeglądu bez inwentarza wszystkich plików. Oddziel zaobserwowane wyniki od oczekiwań.

Opis PR ma być zwięzłym podsumowaniem dla operatora: zachowanie i wartość, rozstrzygające dowody, decyzje domenowe, pozostałe ryzyko i sposób odzyskiwania oraz następne działanie; szczegóły podlinkuj, aby ułatwić wznowienie pracy. Osobne podsumowania HTML lub wizualne wymagają wyraźnej prośby; zachowaj przegląd pełnego diffu i wymagane dowody wizualne.

Wybierz najmniejszy widok z [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md).

#### Zmienione decyzje [#changed-decisions]

Opisz istotne odstępstwa od zapisanego planu lub kontraktu rezultatu, jeśli zmieniają zakres, kontrakty, weryfikację lub ryzyko wdrożenia. Wykorzystaj istniejące notatki lub mapy intencji:
poprzedni wybór -> nowe dowody -> obecny wybór -> konsekwencje dla przeglądu.
Opis PR musi być samowystarczalny; pomijaj puste historie zmian i nigdy nie wymyślaj wcześniejszego planu ani uzgodnień.

Fragmenty sesji są opcjonalnym kontekstem. Używaj tylko istotnych fragmentów, dopuszczonych do udostępnienia, z usuniętymi danymi wrażliwymi i dostępnych dla recenzentów; w przeciwnym razie podaj bezpieczne, samodzielne uzasadnienie.
Nie rozszerzaj zakresu udostępniania ani uprawnień do wykonywania działań tylko po to, by podać link. Długość sesji lub liczba tur nie dowodzi poprawności ani staranności; sprawdzaj twierdzenia na podstawie bieżącego diffu i dowodów z wykonania.

Umieść wizualizacje obok tekstu, który wspierają. Pokaż tylko kluczowe wywołania, pliki, właściwości, stany i granice.

Pomiń widoki, które nie pomagają zrozumieć zmiany.

### Dowody [#evidence]

Konkretne dowody, że zmiana działa. Preferuj krótkie polecenie i wynik; dla UI pokazuj porównanie przed/po zgodnie z szablonem, a dla innych zmian tylko przydatne media. Wymień niewykonane kontrole i niewiadome; przechodzące testy nie dowodzą przeglądu ani zgody ludzi.

Używaj [adnotacji wizualnych](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations) tylko wtedy, gdy trudno znaleźć różnicę. Przy szerokich zmianach UI korzystaj z [map zmian interfejsu](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md#ui-change-maps), gdy ułatwiają zrozumienie; unikaj powielonych zrzutów i osobnych podsumowań.

Przy zmianach backendu, API, Protobuf, kontraktów, architektury, przepływu danych lub procesów, których nie wyjaśniają zrzuty ani nagranie, dołącz [diagram backendowy](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md) bezpośrednio po zdaniu otwierającym; aktualizuj nieaktualne utrzymywane diagramy. Preferuj Excalidraw, a gdy renderowanie lub publikacja zawiedzie, użyj Mermaid bezpośrednio w opisie. Zachowaj wyniki testów: diagram wyjaśnia, ale nie dowodzi poprawności. [Kontrakt dowodów wizualnych](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5) określa dopuszczalne wyjątki i bramkę sprawdzającą opublikowany opis przed zakończeniem.

Dobieraj materiały według [dowodów wizualnych commit-push-pr](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5). Nagrywaj rzeczywisty przebieg tylko wtedy, gdy wymaga tego interakcja lub ruch albo gdy o to poproszono; w pozostałych przypadkach wystarczą obrazy i wyniki poleceń. Dowód jest przydatny ze względu na pytanie, na które odpowiada, a nie klasę medium. Podawaj zwięzłe, rzeczywiste wyniki testów, nie rekonstrukcje.

### Ryzyko scalenia [#merge-danger]

Wskaż sposób wycofania zmiany i określ, czy są to drzwi jednokierunkowe, czy dwukierunkowe. Drzwi dwukierunkowe pozwalają tanio się wycofać; decyzje destrukcyjne lub trudne do odwrócenia są jednokierunkowe.

Wymień dotkniętych użytkowników, wywołujących, kontrakty i wiarygodne scenariusze awarii, w tym współdzielonych odbiorców.
Obok odzyskiwania oceń wykrywanie błędów zgodnie z kryteriami przekazania do przeglądu. Jawnie wskaż istotne luki w widoczności awarii; przechodzące testy ani plan wycofania zmiany nie zastępują wykrywania błędów.
