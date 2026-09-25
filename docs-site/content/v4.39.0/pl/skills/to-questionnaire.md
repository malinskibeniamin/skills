---
title: /to-questionnaire
description: >-
  Przekształć decyzję, której nie możesz w pełni podjąć samodzielnie, w
  kwestionariusz dla innej osoby.
type: skill
sidebar:
  label: /to-questionnaire
---
![Diagram umiejętności /to-questionnaire](/diagrams/skills/to-questionnaire.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/to-questionnaire.excalidraw)

Przekształć kwestię, której użytkownik nie może rozstrzygnąć samodzielnie, w kwestionariusz Markdown do wypełnienia przez jedną osobę asynchronicznie lub podczas spotkania. Odbiorca ma wiedzę, której brakuje użytkownikowi; kwestionariusz pomaga ją wydobyć.

**Dopytuj o wysyłkę, nie o temat.** Pytaj użytkownika tylko o to, na co może odpowiedzieć: kto otrzyma kwestionariusz i jakich informacji zwrotnych potrzebuje. Dokument powinien następnie wypełnić lukę między wiedzą odbiorcy a decyzją użytkownika.

1. **Kto go otrzyma?** W jednym kroku zapytaj o rolę i wiedzę specjalistyczną odbiorcy oraz jego relację z użytkownikiem. Pozwoli to ustalić ton i wymagany kontekst. Ten krok jest zakończony, gdy odbiorca i jego unikalna wiedza są jasno określone.
2. **Co musi wrócić?** Zapytaj o konkretne fakty lub decyzje, których użytkownik nie może ustalić samodzielnie. Ten krok jest zakończony, gdy istnieje konkretna lista tego, co użytkownik musi móc później zdecydować lub zrobić.
3. **Napisz dokument.** Utwórz `to-questionnaire-<topic-slug>.md` w bieżącym katalogu, korzystając z poniższej struktury. Ten krok jest zakończony, gdy każdy oczekiwany rezultat ma odpowiadające mu pytanie, a ścieżka została podana.

## Struktura dokumentu

Przedstaw go jako **kwestionariusz rozpoznawczy**. Uporządkuj pytania od najważniejszego, ponieważ w przypadku próśb asynchronicznych może być tylko jedna szansa na odpowiedź. Gdy pytań jest więcej niż kilka, użyj nagłówków tematycznych `##`.

```markdown
# <Questionnaire title>

**Purpose:** <why this exists and the decision riding on it>

**From:** <user> -- **To:** <recipient> -- **How answers will be used:** <destination>

## Context

<One paragraph orienting someone who was not in the original conversation.>

## How to answer

<Deadline and rough effort. Say partial answers and "I don't know" are useful.>

## <Theme>

### <One focused question>

_Why this matters: <only when needed to prevent a shallow or misread answer>_

>

## Anything else?

What did we not ask that we should know?
```

Każde pytanie dotyczy jednej kwestii, ma bezpośrednio pod sobą miejsce na odpowiedź i zawiera uzasadnienie tylko wtedy, gdy mogłoby zostać błędnie zrozumiane.
