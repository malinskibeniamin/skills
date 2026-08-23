---
title: /domain-modeling
description: >-
  Buduj i dopracowuj model domeny projektu. Używaj podczas omawiania
  terminologii bazy kodu, pisania lub edytowania pliku CONTEXT.md albo
  rejestrowania lub edytowania ADR-u.
type: skill
sidebar:
  label: /domain-modeling
---
![Diagram umiejętności /domain-modeling](/diagrams/skills/domain-modeling.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/domain-modeling.excalidraw)

Podczas projektowania aktywnie buduj i precyzuj model domeny projektu. To *aktywna* praktyka — kwestionowanie terminów, tworzenie scenariuszy przypadków brzegowych oraz zapisywanie glosariusza i decyzji, gdy tylko nabiorą ostatecznego kształtu. (Samo *czytanie* `CONTEXT.md`, aby poznać słownictwo, nie jest tą umiejętnością — to prosty nawyk, który można stosować przy każdej umiejętności. Ta umiejętność służy do zmieniania modelu, a nie tylko korzystania z niego).

## Struktura plików

Większość repozytoriów ma jeden kontekst:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

Jeśli w katalogu głównym istnieje plik `CONTEXT-MAP.md`, repozytorium ma wiele kontekstów. Mapa wskazuje lokalizację każdego z nich:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          <- system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 <- context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Twórz pliki dopiero wtedy, gdy są potrzebne — tylko gdy masz coś do zapisania. Jeśli `CONTEXT.md` nie istnieje, utwórz go po uzgodnieniu pierwszego terminu. Jeśli `docs/adr/` nie istnieje, utwórz ten katalog, gdy potrzebny będzie pierwszy ADR.

## Podczas sesji

### Konfrontuj z glosariuszem

Gdy użytkownik używa terminu sprzecznego z językiem zapisanym w `CONTEXT.md`, od razu zwróć na to uwagę. „Glosariusz definiuje «anulowanie» jako X, ale wygląda na to, że masz na myśli Y — o które znaczenie chodzi?”

### Precyzuj niejasny język

Gdy użytkownik używa niejasnych lub wieloznacznych terminów, zaproponuj precyzyjny termin kanoniczny. „Mówisz «konto» — masz na myśli Klienta czy Użytkownika? To dwa różne pojęcia.”

### Omawiaj konkretne scenariusze

Podczas omawiania relacji w domenie sprawdzaj je za pomocą konkretnych scenariuszy. Twórz scenariusze badające przypadki brzegowe i wymagające od użytkownika precyzyjnego określenia granic między pojęciami.

### Porównuj z kodem

Gdy użytkownik opisuje sposób działania czegoś, sprawdź, czy kod jest z tym zgodny. Jeśli znajdziesz sprzeczność, wskaż ją: „Kod anuluje całe Zamówienia, ale przed chwilą była mowa o możliwości częściowego anulowania — która wersja jest prawidłowa?”

### Aktualizuj CONTEXT.md na bieżąco

Po uzgodnieniu terminu od razu zaktualizuj `CONTEXT.md`. Nie odkładaj takich zmian na później — zapisuj je na bieżąco. Użyj formatu opisanego w [CONTEXT-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/domain-modeling/CONTEXT-FORMAT.md).

Plik `CONTEXT.md` nie powinien zawierać żadnych szczegółów implementacyjnych. Nie traktuj `CONTEXT.md` jako specyfikacji, notatnika roboczego ani miejsca do przechowywania decyzji implementacyjnych. To wyłącznie glosariusz.

### Proponuj ADR-y oszczędnie

Zaproponuj utworzenie ADR-u tylko wtedy, gdy spełnione są wszystkie trzy warunki:

1. **Trudna do odwrócenia** — koszt późniejszej zmiany decyzji jest znaczący
2. **Zaskakująca bez kontekstu** — przyszły czytelnik będzie się zastanawiać: „dlaczego zrobiono to w ten sposób?”
3. **Wynika z rzeczywistego kompromisu** — istniały realne alternatywy, a jedną z nich wybrano z konkretnych powodów

Jeśli którykolwiek z tych warunków nie jest spełniony, pomiń ADR. Użyj formatu opisanego w [ADR-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/domain-modeling/ADR-FORMAT.md).
