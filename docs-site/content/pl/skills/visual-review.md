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

Przeglądaj powierzchnie widoczne dla klientów z perspektywy produktu, projektowania, inżynierii i QA.
Najczęściej przegląd dotyczy interfejsów przeglądarkowych, ale obejmuje też ekrany mobilne, CLI/TUI, aplikacje komputerowe i generowane
raporty. Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/visual-review/REFERENCE.md), aby poznać macierz materiałów, język
projektowy, kontrole platformowe, format raportu i przyjęte zasady estetyczne.

Tryby: `plan`, `implemented`, `regression`, `release`. Można uruchamiać samodzielnie.

## Przebieg

1. **Znajdź powierzchnie:** użyj wskazówek lub `git diff --name-only HEAD`; przypisz trasy i komponenty do
   adresów URL, a zmiany CLI i raportów do poleceń. Uwzględnij shadcn/ui lub `@/components/ui`.
2. **Zbuduj kontekst:** odczytaj tokeny i motyw oraz jedną reprezentatywną powierzchnię. Przed oceną określ,
   czy interfejs posługuje się językiem marki, czy produktu.
3. **Zbierz materiały:** użyj narzędzi repozytorium, `scripts/skills-browser.sh`, Playwright, danych testowych,
   zrzutów ekranu i wyników poleceń. Uruchom `/quantify-impact`, gdy istnieje bezpośrednia wartość UI lub
   metryka wydajności; pomiń formalne pomiary przy drobnych zmianach.
4. **Przeprowadź ścieżki przeglądu:** krytyka (hierarchia i przebieg zadania), audyt (dostępność,
   responsywność, wydajność), dopracowanie (jakość przed wydaniem i zgodność z systemem).
5. **Zastosuj perspektywy:** Produkt: wartość dla użytkownika i przeszkody. Projektowanie: hierarchia, wskazówki użycia, teksty,
   stany, estetyka. Inżynieria: odporność, synchronizacja, platforma, wydajność.
   QA: odtwarzalne materiały, scenariusze błędów, regresja, automatyzacja.
6. **Prześledź cykl życia UI:** bezczynny/bez żądania -> oczekiwanie/ładowanie/wysyłanie -> sukces/błąd -> zakończony/odrzucony.
   Sprawdź, czy sukces efektu ubocznego został potwierdzony, a nieudane efekty uboczne pozostają widoczne.
7. **Przetestuj macierz skrajnych przypadków:** Chromium na komputerze i urządzeniu mobilnym; klawiatura Tab, Shift+Tab, Enter,
   Space, Escape; ładowanie, brak danych, błąd, duża ilość danych; ścieżka wysyłania formularza; ścieżka powiadomienia/toastu;
   konsola/sieć. Gdy ryzyko tego wymaga, dodaj Firefox na komputerze, WebKit, ograniczenie ruchu, wymuszone kolory, powiększenie
   tekstu, RTL/zlokalizowany długi tekst, wolną sieć/ograniczenie przepustowości multimediów oraz tryb ciemny/jasny.
8. **Zaraportuj i zamknij:** przytocz materiały, nazwij uchwyty projektowe, napraw P0/P1 lub odnotuj akceptację
   oraz zapisz deterministycznie powtarzalne przypadki jako kandydatów do automatyzacji.

Skorzystaj z listy kontrolnej w materiale referencyjnym dotyczącej bezpiecznego obszaru i zachowania klawiatury wirtualnej, kierunku pisania,
tabel, skrótowych właściwości CSS/złożonych układów, ARIA tylko w razie potrzeby, elementów statycznych/ogólnych,
menedżerów haseł/autouzupełniania, `aria-disabled`, fokusu, zagnieżdżonych przycisków/linków, `requestSubmit`,
toastów, multimediów, WebView, bfcache, przewijania, zachowania natywnych kontrolek, wykrywania funkcji,
responsywnych obrazów/wideo, proporcji obrazu, INP/długich interakcji, ładowania czcionek oraz osadzonych elementów/skryptów
zewnętrznych.

Heurystyki: najpierw HTML. Cykl życia jest ważniejszy niż zrzut ekranu. Stan jest ważniejszy niż ścieżka sukcesu. Ruch jest interakcją.
Testowanie treścią wygrywa. Automatyzacja dostępności jest częściowa. Wydajność jest widoczna. Jeśli coś wystąpiło dwa razy, zautomatyzuj to.

## Mapy przepływu

Gdy zrzuty ekranu nie wystarczają do wyjaśnienia złożonego przebiegu stanów, granicy UI/systemu lub
struktury przed zmianą i po niej, użyj `/excalidraw-diagram`, aby utworzyć jedną zwięzłą mapę przepływu. Zachowaj
zrzuty ekranu jako główny materiał; mapa wyjaśnia relacje, nie piksele. Osadź
jej SVG w treści lub PNG zakodowany jako dane w raporcie HTML i podaj ścieżkę do sąsiadującego edytowalnego
pliku `.excalidraw`.
W przypadku prostego grafu lub niedostępnego obszaru roboczego użyj Mermaid jako rozwiązania zapasowego i odnotuj ograniczenie.

## Wynik

Napisz zwięzły raport. W przypadku złożonego przeglądu lub przeglądu wydania utwórz
`$TMPDIR/visual-review-<timestamp>.html`.

```markdown
## Visual review
Status: ready | needs fixes | blocked
Changed UI: <surfaces>
Checked: <browser/viewport/state/terminal evidence>
State trace: | Surface | Trigger | Pending | Success | Error | Persistence/dismissal | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Why it matters | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Screenshots: | View | Browser | Path | Notes |
Impact: <Proven impact table + verdict, or why measurement was not useful>
Automation candidates: <deterministic hook/eval/test candidates>
```

P0 uniemożliwia użycie, narusza bezpieczeństwo, powoduje utratę danych lub nieskończoną pętlę. P1 blokuje PR. Zakończ, gdy P0/P1 zostaną naprawione lub
zaakceptowane, materiały zostaną zebrane albo jawnie pominięte, a powtarzalne braki zostaną zarejestrowane.
