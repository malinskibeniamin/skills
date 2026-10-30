---
description: >-
  Udowadniaj reguły biznesowe za pomocą praw Bend i porównuj wdrożony kod TypeScript lub Go z udowodnionym modelem. Używaj do dowodów formalnych, LAWS.bend lub PROOF.bend albo kryteriów akceptacji, które muszą obowiązywać dla każdego wejścia.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - bend laws
sidebar:
  label: /bend-laws
title: /bend-laws
type: skill
---
![Diagram umiejętności /bend-laws](/diagrams/skills/bend-laws.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/bend-laws.excalidraw)

Przy weryfikowaniu zmienionego zachowania lub utrzymaniu weryfikacji przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#verification).

Prawo to kryterium akceptacji, które dowód musi spełnić dla każdego wejścia. [Bend](https://bend-lang.com) sprawdza dowody względem modelu referencyjnego reguły. Tabela wygenerowana z tego modelu wiąże wdrożony kod z prawami.

## Zastosowanie [#fit]

Używaj praw dla reguł, które decydują o pieniądzach, dostępie lub bezpieczeństwie i są skończone albo opierają się na arytmetyce liczb całkowitych: trybów, uprawnień, statusów, progów, okien czasowych i zaokrągleń. Ciągi znaków, parsery, JSON, liczby zmiennoprzecinkowe (F32 w Bend jest aksjomatyczny i nie ma F64) oraz UI kieruj zamiast tego do testów opartych na właściwościach (fast-check, rapid); ich dowodzenie kosztuje więcej, niż wykrywa.

## Własność [#ownership]

| Plik w `laws/<rule>/` | Właściciel |
|---|---|
| `LAWS.bend` | Człowiek. Hook `bend-laws-guard` blokuje zapisy agenta; człowiek dopuszcza sesję za pomocą `BEND_LAWS_AUTHOR=1`. |
| `policy.bend` (model), `PROOF.bend`, `oracle.bend` | Agent |
| `decisions.txt` | Generowany przez `laws/check.sh --write` |

## Przebieg pracy [#workflow]

1. Przeczytaj wdrożoną regułę i jej testy. Wypisz każde wejście i decyzję, którą zwraca. Gotowe, gdy dziedzina wejść jest wyliczona (skończona) albo jej granice są nazwane.
2. Napisz szkic praw w katalogu roboczym jako `LAWS_draft.bend` (ścieżki importu dopuszczają tylko litery, cyfry, `_` i `-`) i tam je udowodnij. Każdemu prawu nadaj jeden komentarz prostym językiem. Gotowe, gdy człowiek przejrzał szkic i zatwierdził go jako `LAWS.bend`.
   - Wywołuj tylko testowane funkcje. Każdą funkcję pomocniczą, której używa prawo, zdefiniuj w `LAWS.bend`, aby model nie mógł osłabić prawa, przedefiniowując jego słownictwo.
   - Określaj, co musi zachodzić. Wszystko, czego prawo nie przesądza, jest tym, co robi model, więc łącz każdy zakaz („nigdy nie uruchamia X”) z wymaganiem („uruchamia tylko to, co deklaruje Y”).
   - Importowane konstruktory zapisuj z kwalifikatorem i nawiasami klamrowymi: `case P.Yes{}:`. Goły `case Yes:` na importowanym typie wiąże każdą wartość, a prawo przechodzi trywialnie (bendlang/bend#1328); `check.sh` i hook to odrzucają.
3. Zamodeluj regułę w `policy.bend`, odwzorowując kolejność gałęzi wdrożonego kodu, i udowodnij każde prawo w `PROOF.bend` jako `def Laws.<law>(...)`. Gotowe, gdy `bend PROOF.bend` wypisuje `ALL PROOFS CHECK`.
4. Zmutuj model raz dla każdego prawa: zmień gałąź, której pilnuje prawo, i potwierdź, że `bend PROOF.bend` wypisuje `SOME PROOFS FAIL` przy tym prawie; potem cofnij zmianę. Gotowe, gdy każde prawo odrzuciło mutanta. Prawo, którego żaden mutant nie łamie, jest puste.
5. Napisz `oracle.bend`, którego `main` wypisuje nagłówek `# @generated` i jedną linię `<inputs> <decision>` dla każdego wejścia, a następnie uruchom `laws/check.sh --write`.
6. Porównaj wdrożony kod: test jednostkowy parsuje `decisions.txt` i sprawdza, że wdrożona funkcja zwraca każdy wiersz. Dla skończonej dziedziny sprawdź też, że każde wejście występuje dokładnie raz, a dziedzinę wyprowadź z typów kodu, aby nowa wartość psuła build. Dla nieograniczonej dziedziny generuj wejścia testami opartymi na właściwościach, dodaj granice praw jako wartości startowe i porównuj z modelem skompilowanym przez `bend -o model.mjs`. Gotowe, gdy mutant we wdrożonym kodzie oblewa test.
7. Skopiuj [templates/install-bend.sh](https://github.com/malinskibeniamin/skills/blob/main/bend-laws/templates/install-bend.sh) i [templates/check.sh](https://github.com/malinskibeniamin/skills/blob/main/bend-laws/templates/check.sh) do `laws/`, a potem dodaj wymagane zadanie CI, które uruchamia oba skrypty. Dodaj CODEOWNERS dla `laws/**/LAWS.bend` i `laws/**/decisions.txt`. Gotowe, gdy zadanie oblewa przy braku `LAWS.bend` i przechodzi po jego dodaniu.

Aby zmienić regułę: człowiek edytuje prawo, agent aktualizuje model i dowody, uruchamia `check.sh --write`, a następnie zmienia wdrożony kod, aż jego test jednostkowy się zgadza. Każdy diff `decisions.txt` przeglądaj jako zmianę zachowania.

Przed pisaniem w Bend uruchom `bend guide`; przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/bend-laws/REFERENCE.md), aby poznać pułapki składni, wzorce dowodów, konfigurację `--verdict` i aktualizacje.

## Zabezpieczenia [#guardrails]

- Proponuj zmiany praw człowiekowi; nigdy nie edytuj `LAWS.bend` ani nie obchodź hooka.
- Trzymaj `@unsafe`, `def f?` i kod obcy z dala od katalogów praw: wyłączają poprawność, na której opiera się dowód. Odrzucają je zarówno bramka Bend, jak i `check.sh`.
- Utrzymuj wersję Bend przypiętą w `install-bend.sh`; aktualizuj świadomie i dowodź ponownie.
- Trzymaj kod źródłowy na maszynie: wysyłanie kodu do BendAI lub publikowanie w hubie Bend wymaga wyraźnej zgody.
