---
title: "/pr"
description: "Używaj podczas pisania opisu PR."
type: skill
sidebar:
  label: "/pr"
---
![Diagram umiejętności /pr](/diagrams/skills/pr.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/pr.excalidraw)


Użyj tego szablonu do napisania opisu PR:

```markdown
## Summary

<diagram, diff-sketch, or tree>

## Evidence

- **Before:** <screenshot/output/failing test run>
  **After:** <screenshot/output/passing test run>

## Merge Danger

**Door:** <one-way or two-way>

<optional: description>

**Blast Radius:** <one-word description>

<optional: potential ramifications of merge>
```

## Sekcje

Pomiń wszelkie wstępy i ogranicz opis do minimum. Używaj języka domeny użytkownika z `CONTEXT.md`.

### Podsumowanie

Wybierz najmniejszą wizualizację, która jasno przedstawia najważniejszą kwestię.

Wybierz spośród widoków w [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md): pseudokod, drzewa wywołań, drzewa komponentów, drzewa plików, Mermaid, diffy lub cały blok.

#### Wskazówki

Umieść każdą wizualizację obok krótkiego tekstu, który wspiera. Uwzględnij tylko wywołania, pliki, właściwości, stany i granice niezbędne do udzielenia odpowiedzi na bieżące pytanie użytkownika lub przedstawienia opcji rozwiązania omawianej kwestii.

Możesz użyć jednego z tych sposobów albo kilku; najprawdopodobniej nie użyjesz wszystkich. Kieruj się własnym osądem i nie przytłaczaj użytkownika.

### Dowody

Konkretne dowody, że zmiana działa. Pokaż stan przed i po.

Zrzuty ekranu to najwyższa klasa dowodów, gdy środowisko jest do tego przygotowane, a zmiana jest wizualna.

Dowody z wykonania to klasa tuż za nimi: wyniki testów, dane wyjściowe konsoli. Pokaż w pseudokodzie dokładny test, który wcześniej nie przechodził, a teraz przechodzi.

### Ryzyko scalenia

Określ, czy to drzwi jednokierunkowe, czy dwukierunkowe. Przez drzwi dwukierunkowe można się wycofać, przez jednokierunkowe nie. PR, który łatwo wycofać, niesie mniejsze ryzyko. Zmiany obejmujące działania destrukcyjne lub trudne do odwrócenia decyzje to drzwi jednokierunkowe.

Zasięg skutków to potencjalny wpływ lub zakres zmian wprowadzanych przez ten PR. Rozważ wszystkie możliwości, na przykład przesunięcia układu, awarie u odbiorców czy działanie na urządzeniach mobilnych.
