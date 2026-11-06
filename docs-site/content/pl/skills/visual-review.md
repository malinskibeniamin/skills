---
description: >-
  Przeglądaj powierzchnie widoczne dla klientów na podstawie materiałów
  wizualnych. Używaj, gdy zmieniają się widoczne elementy lub zachowania stron
  internetowych, aplikacji mobilnych, CLI, TUI, aplikacji komputerowych,
  raportów, wdrażania użytkowników, formularzy lub innych interfejsów.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - visual review
sidebar:
  label: /visual-review
title: /visual-review
type: skill
---
![Diagram umiejętności /visual-review](/diagrams/skills/visual-review.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/visual-review.excalidraw)

Dla całościowego przeglądu interfejsu WWW wczytaj [better-interface](https://github.com/malinskibeniamin/skills/blob/main/jakubkrehel-skills/better-interface/SKILL.md) z sześcioma dziedzinami oceny. Kontrakt zgodności zachowuje zakres, dowody i właściciela raportu tej umiejętności. Wykorzystuj aktualne materiały i łącz powtarzające się przyczyny.


Przegląd frontendu w przeglądarce z perspektywy produktu, projektowania, inżynierii i QA. Dokument [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/visual-review/REFERENCE.md) definiuje **uchwyty języka projektowego** i szczegóły. Tryby: `plan`, `implemented`, `regression`, `release`. Można uruchamiać samodzielnie.

## Przebieg [#flow]

Dopasuj przegląd do zmienionej powierzchni i wiarygodnego ryzyka zgodnie z [weryfikacją proporcjonalną do ryzyka](https://github.com/malinskibeniamin/skills/blob/main/shared/verifiability.md#proportionate-verification). Rutynowa zmiana tekstu lub stylu wymaga ukierunkowanego sprawdzenia renderowania, a nie pełnej macierzy urządzeń i stanów ani nowego raportu. Wykorzystuj obserwacje i zrzuty z dogfood; rozszerzaj zakres tylko dla zmienionych założeń.

1. **Znajdź:** ustal bazę PR (w stosie — rodzica, jeśli dotyczy) i sprawdź zmiany od wspólnego przodka do HEAD oraz zmiany przygotowane, nieprzygotowane i istotne nieśledzone pliki; samo `git diff --name-only HEAD` pomija zatwierdzone zmiany. Przypisz trasy i komponenty do adresów URL, a zmiany CLI i raportów do poleceń. Uwzględnij shadcn/ui lub `@/components/ui`, współdzielonych odbiorców, teksty, style, zasoby oraz pośrednie skutki zmian danych i konfiguracji. Żadna widoczna zmiana nie jest zbyt mała.
2. **Zbuduj kontekst:** odczytaj tokeny i motyw oraz jedną powierzchnię; określ, czy interfejs posługuje się językiem marki, czy produktu.
3. **Zbierz materiały:** użyj narzędzi repozytorium, `scripts/skills-browser.sh`, Playwright, danych testowych, zrzutów ekranu i wyników poleceń. Użyj `/quantify-impact` tylko dla bezpośrednich metryk.
4. Przeprowadź **ścieżki przeglądu:** krytyka hierarchii i przebiegu zadania; audyt dostępności i wydajności; dopracowanie jakości przed wydaniem i zgodności z systemem. Przy ocenach punktowych lub powtarzanych porównaniach stosuj [kalibrację przeglądu](https://github.com/malinskibeniamin/skills/blob/main/visual-review/REFERENCE.md#review-calibration).
5. **Perspektywy:** Produkt: wartość dla użytkownika; Projektowanie: hierarchia, teksty i stany; Inżynieria: odporność i platforma; QA: odtwarzalne materiały i scenariusze błędów.
6. **Prześledź cykl życia UI:** bezczynny/bez żądania -> oczekiwanie/ładowanie/wysyłanie -> sukces/błąd -> zakończony/odrzucony. Wymagaj potwierdzenia sukcesu efektu ubocznego i trwałej widoczności nieudanych efektów ubocznych.
7. **Przetestuj skrajne przypadki:** sprawdzaj dotknięte zachowanie odpowiednio do ryzyka: właściwe rozmiary ekranu, klawiaturę i fokus, ładowanie, brak danych, błędy, gęste dane, formularze, toasty i konsolę/sieć. Dodawaj przeglądarki, ograniczenie ruchu, wymuszone kolory, powiększenie, RTL, ograniczenia przepustowości lub motywy tylko dla wiarygodnego ryzyka albo wymagania projektu.
8. **Zamknij:** przytocz materiały, nazwij uchwyty projektowe, napraw lub zaakceptuj P0–P1 oraz zapisz deterministycznych kandydatów do automatyzacji.

Testowanie treści/układu: wywołaj narzędzie Skill z "break-ui". Wykorzystuj bieżące dane i zrzuty z dogfood;
testuj tylko niepokryte przypadki. Zachowaj zakres tylko do odczytu lub jawnie dozwolonych poprawek.

W trybach implementacji i wydania używaj [materiałów wizualnych PR](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5), gdy zrzuty pomagają w przeglądzie lub są wymagane. Sprawdzaj odpowiednie różnice migawek przed zamierzonymi aktualizacjami; uruchamiaj ponownie w normalnym trybie. Dodawaj adnotacje tylko wtedy, gdy pomagają znaleźć różnicę; przegląd tylko do odczytu zgłasza luki. Zrzuty nie są testami; testy nie są dowodem porównania przed i po.

Najpierw wyrenderowane zachowanie. Cykl życia jest ważniejszy niż zrzut. Stan jest ważniejszy niż ścieżka sukcesu. Ruch jest interakcją. Automatyzacja dostępności jest częściowa. Automatyzuj powtarzalne kontrole, gdy ryzyko uzasadnia ich utrzymanie.

W razie potrzeby użyj `/excalidraw-diagram`; zrzuty ekranu są głównym materiałem, a Mermaid rozwiązaniem zapasowym.

## Wynik [#output]

Używaj zwięzłego Markdown w odpowiedzi; pomijaj puste tabele. Osobny raport HTML twórz tylko na prośbę.

```markdown
## Visual review
State trace: | Surface | Trigger | Pending | Success | Error | Persistence | Evidence |
Findings: | Severity | Hat | Surface | Evidence | Impact | Fix | Automate? |
Design findings: | Severity | Surface | Handle | Current read | Desired read | Adjustment |
Automation candidates: <hook/eval/test>
```

P0 uniemożliwia użycie, narusza bezpieczeństwo, powoduje utratę danych lub nieskończoną pętlę; P1 blokuje PR. Zakończ po rozwiązaniu lub zaakceptowaniu problemów, zebraniu materiałów i zarejestrowaniu powtarzalnych braków.
