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
2. Porównaj opublikowany opis z **pełną różnicą PR-a**, pierwotnym celem i aktualną weryfikacją, nie tylko ostatnią turą lub commitem. W stosach oceniaj każdą zmienioną warstwę względem jej rodzica. Sprawdź [podgląd wdrożenia](#deploy-previews) dla bieżącego commita PR-a. Sprawdź aktualność zrzutów, oznaczeń i legendy zgodnie z [adnotacjami wizualnymi](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations).
3. Osobno załaduj [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md). Ponownie oceń wartość biznesową i wpływ na produkt lub bazę kodu; wykorzystaj nadal aktualne dowody, powtórz unieważnione porównania i usuń niepoparte twierdzenia. Gdy wartość jest nieznana, napisz `not established`.
4. Przy autoryzowanych zmianach odświeżaj razem zrzuty, oznaczenia i legendę. Zachowaj pierwsze zdanie człowieka (zgłoś nieaktualną intencję do edycji przez autora); aktualizuj otwarcia napisane przez agenta i zastępuj jego nieaktualne punkty zwięzłą informacją o odbiorcy, wartości, dowodach i istotnych ryzykach. Odśwież [materiał do przeglądu przez człowieka](https://github.com/malinskibeniamin/skills/blob/main/shared/review-contract.md#human-review-handoff), w tym dobór recenzentów, odzyskiwanie i luki wykrywania. Zachowaj intencję człowieka i wymagane dowody; podlinkuj szczegóły, pomiń poprawne opisy i dziennik sesji.
5. Po edycji ponownie odczytaj opis z serwera i sprawdź, czy opisuje opublikowany stan gałęzi źródłowej. Żądania tylko do odczytu zgłaszają rozbieżności bez edycji. Wyraźny zakaz wypychania lub zakres lokalny odracza publikację; nie opisuj nieopublikowanej pracy jako dostarczonej.

## Podglądy wdrożeń [#deploy-previews]

Przy tworzeniu i aktualizacji PR-a oraz przed przekazaniem pracy sprawdź wyniki wdrożeń, kontroli i statusów lub komentarze bota dostawcy dla bieżącego commita PR-a. Na początku opisu PR-a i przekazania pracy umieść `**Deploy preview (<app/provider>):** <full URL>` z rzeczywistym adresem aplikacji, nie adresem logu wdrożenia, panelu ani localhosta. Jeśli jest kilka podglądów, oznacz je nazwą aplikacji i dostawcy.

Jeśli oczekiwany podgląd jest w toku, nie powiódł się lub jest niedostępny, podaj na początku jego stan i przyczynę. Oznacz adres starszego commita jako nieaktualny do czasu wdrożenia bieżącego. Sprawdzaj stan po wypchnięciu zmian, po zakończeniu wdrożenia i przed przekazaniem pracy. Zastępuj istniejący wpis zamiast dodawać duplikaty. Podaj wymagania dostępu obok adresu; sam adres nie dowodzi, że aplikacja działa. Pomiń ten wiersz tylko wtedy, gdy podglądu nie ma i nie jest oczekiwany.

## Szablon opisu [#body-template]

Użyj zwięzłego tytułu opisującego rezultat, zgodnego z konwencjami repozytorium. Tytuł i zdanie o zmianie oraz jej celu należą do autora-człowieka: zachowaj dostarczone brzmienie. Jeśli tworzy je agent, oznacz je jako szkic do edycji przez człowieka; nie przypisuj mu autorstwa ani akceptacji. Autoryzowany szkic PR można opublikować. Przy aktualizacji zachowaj tekst człowieka i zgłoś zmianę intencji zamiast po cichu go przepisywać.

Kolejność: podgląd wdrożenia, jeśli ma zastosowanie -> jedno zdanie o zmianie i jej celu -> tabela zrzutów przed/po dla UI -> klikalny prototyp, gdy przydatny -> opis agenta w jednym zwiniętym `<details>`. Link do prototypu może też poprzedzać tabelę. Pomijaj nieadekwatne sekcje zamiast publikować puste pola. Stosuj ten układ:

```markdown
**Deploy preview (<app/provider>):** <full URL or explicit state/reason; omit when inapplicable>

<one human-authored line about the change and why, or an explicitly labeled agent draft>

| Before | After |
| --- | --- |
| ![Previous state](<hosted-before-image>) | ![New state](<hosted-after-image>) |

[Try the prototype](<reviewer-accessible-url>) - <states/variants; access requirement>

<details>
<summary>Agent-generated description</summary>

- Lane / Review: <beneficiary, scope, closest-review paths and owner routing/gaps>
UI packaging: <adres opublikowanego nagrania albo jawny powód braku zmian UI/odstąpienie właściciela zgodnie z package-my-work>

- Testing: <commands, observed results, real-entrypoint evidence and gaps>
- Risk / Rollback: <failure modes, blast radius, recovery, detection and gaps>

<verified model/harness attribution when required>

</details>
```

Przed szczegółami umieść krótkie **widoczne ostrzeżenie** o nieudanej lub zablokowanej weryfikacji, istotnych ryzykach, kosztownym wycofaniu lub lukach wykrywania. Zwijaj rutynowe dowody, nie blokery. W opisie agenta oceń wszystkie pięć kryteriów [przekazania do przeglądu](https://github.com/malinskibeniamin/skills/blob/main/shared/review-contract.md#human-review-handoff), bez pięciu szablonowych nagłówków. Zachowaj wymagane odnośniki, kryteria akceptacji i pola repozytorium.

Dla zmian UI używaj porównywalnych rzeczywistych zrzutów bazy i kandydata zgodnie z [kontraktem dowodów wizualnych](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5). Wyjaśnij brak lub nieadekwatność porównania; nie wymyślaj stanu „przed” ani nie przedstawiaj zastępczych URL-i jako dowodów. Dla zmian poza UI pomiń tabelę i zachowaj wymagane diagramy. Prototyp uzupełnia, a nie zastępuje zrzuty i testy.

### Klikalne prototypy do przeglądu [#clickable-review-prototypes]

Jeśli interakcje, trudno dostępne stany lub alternatywy warto wypróbować, postępuj zgodnie z [zasadami hostingu i weryfikacji prototypów](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md#prototype-hosting-and-verification).

## Opis i ryzyko [#description-and-risk]

Przed pisaniem lub aktualizacją opisu przeczytaj [wskazówki do opisu](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md#supporting-description): dowody, zmiany decyzji i ryzyko.
W przypadku istotnych wyborów agenta nierozstrzygniętych w żądaniu lub planie zastosuj [audyt nowych decyzji](https://github.com/malinskibeniamin/skills/blob/main/shared/decision-deltas.md), również przy bezpośrednim wywołaniu tworzenia PR.
Opis PR-a jest zwięzłym podsumowaniem operacyjnym; osobne artefakty podsumowujące wymagają wyraźnego żądania.
Odpowiednie kontrakty poza UI wymagają [diagramów backendowych](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md); nagrania UI pozostają obowiązkowe według `package-my-work`.
Wskaż sposób wycofania zmiany oraz określ, czy decyzja jest jedno- czy dwukierunkowa.
Nazwij dotkniętych użytkowników, wywołujących, kontrakty i wiarygodne awarie, także u współdzielonych odbiorców.
