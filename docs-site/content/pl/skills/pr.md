---
title: /pr
description: Używaj podczas pisania opisu PR.
type: skill
sidebar:
  label: /pr
---
![Diagram umiejętności /pr](/diagrams/skills/pr.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/pr.excalidraw)


Przeczytaj [kontrakt ochrony uwagi czytelnika](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md). Użyj tego szablonu do napisania opisu PR:

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

Zacznij od wartości i kwestii wymagających uwagi recenzenta, a nie od listy zmian. Oddziel zaobserwowane wyniki od oczekiwań.
Następnie wybierz najmniejszy widok wyjaśniający sedno; pomiń wizualizację, która niczego nie wyjaśnia.

Wybierz najmniejszy widok z [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md).

#### Wskazówki [#guidance]

Umieść wizualizacje obok tekstu, który wspierają. Pokaż tylko kluczowe wywołania, pliki, właściwości, stany i granice.

Używaj wyłącznie widoków, które pomagają zrozumieć zmianę.

### Dowody [#evidence]

Konkretne dowody, że zmiana działa. Pokaż stan przed i po. Wymień niewykonane kontrole i pozostałe niewiadome; przechodzące testy nie dowodzą przeglądu ani zgody ludzi.

Przy każdej zmianie we frontendzie nagranie rzeczywistego przebiegu interakcji z interfejsem przed zmianą i po niej (kliknięcia, wpisywanie tekstu, stan wynikowy; nigdy nieruchoma strona), odtwarzane bezpośrednio w opisie, wraz ze zrzutami ekranu stanowi najwyższą klasę dowodów i jest wymagane. Umieść je tuż po podsumowaniu, aby osoby przeglądające PR zobaczyły zmianę, zanim o niej przeczytają. Nagraj, zmontuj i udostępnij je zgodnie z [instrukcjami dotyczącymi dowodów wizualnych w commit-push-pr](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5).

Dowody z wykonania to klasa tuż za nimi: wyniki testów, dane wyjściowe konsoli. Pokaż w pseudokodzie dokładny test, który wcześniej nie przechodził, a teraz przechodzi.

### Ryzyko scalenia [#merge-danger]

Wskaż sposób wycofania zmiany. Drzwi dwukierunkowe pozwalają tanio się wycofać; decyzje destrukcyjne lub trudne do odwrócenia są jednokierunkowe.

Wymień dotkniętych użytkowników, wywołujących, kontrakty i wiarygodne scenariusze awarii, w tym współdzielonych odbiorców.
