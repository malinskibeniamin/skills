---
title: /visual-review
description: >-
  Przeglądaj powierzchnie widoczne dla klientów na podstawie materiałów
  wizualnych. Używaj, gdy zmieniają się widoczne elementy lub zachowania stron
  internetowych, aplikacji mobilnych, CLI, TUI, aplikacji komputerowych,
  raportów, wdrażania użytkowników, formularzy lub innych interfejsów.
type: skill
sidebar:
  label: /visual-review
---
![Diagram umiejętności /visual-review](/diagrams/skills/visual-review.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/visual-review.excalidraw)


Przeglądaj powierzchnie widoczne dla klientów z perspektywy produktu, projektowania, inżynierii i QA. Najczęściej przegląd dotyczy interfejsów przeglądarkowych, ale obejmuje też ekrany mobilne, CLI/TUI, aplikacje komputerowe i generowane raporty. Dokument [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/visual-review/REFERENCE.md) definiuje **uchwyty języka projektowego** i szczegóły. Tryby: `plan`, `implemented`, `regression`, `release`. Można uruchamiać samodzielnie.

## Przebieg

1. **Znajdź:** ustal bazę PR (w stosie — rodzica, jeśli dotyczy) i sprawdź zmiany od wspólnego przodka do HEAD oraz zmiany przygotowane, nieprzygotowane i istotne nieśledzone pliki; samo `git diff --name-only HEAD` pomija zatwierdzone zmiany. Przypisz trasy i komponenty do adresów URL, a zmiany CLI i raportów do poleceń. Uwzględnij shadcn/ui lub `@/components/ui`, współdzielonych odbiorców, teksty, style, zasoby oraz pośrednie skutki zmian danych i konfiguracji. Żadna widoczna zmiana nie jest zbyt mała.
2. **Zbuduj kontekst:** odczytaj tokeny i motyw oraz jedną powierzchnię; określ, czy interfejs posługuje się językiem marki, czy produktu.
3. **Zbierz materiały:** użyj narzędzi repozytorium, `scripts/skills-browser.sh`, Playwright, danych testowych, zrzutów ekranu i wyników poleceń. Użyj `/quantify-impact` tylko dla bezpośrednich metryk.
4. Przeprowadź **ścieżki przeglądu:** krytyka hierarchii i przebiegu zadania; audyt dostępności i wydajności; dopracowanie jakości przed wydaniem i zgodności z systemem.
5. **Perspektywy:** Produkt: wartość dla użytkownika; Projektowanie: hierarchia, teksty i stany; Inżynieria: odporność i platforma; QA: odtwarzalne materiały i scenariusze błędów.
6. **Prześledź cykl życia UI:** bezczynny/bez żądania -> oczekiwanie/ładowanie/wysyłanie -> sukces/błąd -> zakończony/odrzucony. Wymagaj potwierdzenia sukcesu efektu ubocznego i trwałej widoczności nieudanych efektów ubocznych.
7. **Przetestuj skrajne przypadki:** Chromium na komputerze i urządzeniu mobilnym; `Tab, Shift+Tab, Enter, Space, Escape`; ładowanie, brak danych, błąd, duża ilość danych; ścieżka wysyłania formularza; ścieżka powiadomienia/toastu; konsola/sieć. Gdy ryzyko tego wymaga, dodaj Firefox na komputerze, WebKit, ograniczenie ruchu, wymuszone kolory, powiększenie tekstu, RTL/zlokalizowany długi tekst, wolną sieć/ograniczenie przepustowości multimediów oraz motywy.
8. **Zamknij:** przytocz materiały, nazwij uchwyty projektowe, napraw lub zaakceptuj P0–P1 oraz zapisz deterministycznych kandydatów do automatyzacji.

W trybach implementacji i wydania postępuj zgodnie z dokumentem [materiały wizualne PR](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5): zestaw każdą zmienioną powierzchnię i każdy stan ze zrzutami oraz testami wizualnymi, sprawdź różnice migawek przed aktualizacją zamierzonych wartości bazowych, ponownie uruchom testy w zwykłym trybie i odśwież materiały po edycjach. Zrzuty ekranu nie są testami wizualnymi; zaliczone testy nie są osadzonym materiałem „przed” i „po”.

Najpierw HTML. Cykl życia jest ważniejszy niż zrzut ekranu. Stan jest ważniejszy niż ścieżka sukcesu. Ruch jest interakcją. Testowanie treścią wygrywa. Automatyzacja dostępności jest częściowa. Wydajność jest widoczna. Jeśli coś wystąpiło dwa razy, zautomatyzuj to.

W razie potrzeby użyj `/excalidraw-diagram`; zrzuty ekranu są głównym materiałem, a Mermaid rozwiązaniem zapasowym.

## Wynik

Napisz zwięzły raport w Markdown. W przypadku przeglądu wydania lub złożonego przeglądu utwórz `$TMPDIR/visual-review-<timestamp>.html`.

```markdown
## Visual review
State trace: | Surface | Trigger | Pending | Success | Error | Persistence | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Impact | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Automation candidates: <hook/eval/test>
```

P0 uniemożliwia użycie, narusza bezpieczeństwo, powoduje utratę danych lub nieskończoną pętlę; P1 blokuje PR. Zakończ po rozwiązaniu lub zaakceptowaniu problemów, zebraniu materiałów i zarejestrowaniu powtarzalnych braków.
