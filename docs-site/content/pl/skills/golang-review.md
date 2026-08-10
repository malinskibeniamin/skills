---
title: /golang-review
description: >-
  Weryfikuje kod Go według reguł opartych na dowodach, dotyczących ograniczeń,
  API, współbieżności, błędów, bezpieczeństwa, testów i wdrażania. Używaj do
  różnic, PR-ów, gałęzi, modułów i prototypów backendu w Go.
type: skill
sidebar:
  label: /golang-review
---
![Diagram umiejętności /golang-review](/diagrams/skills/golang-review.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/golang-review.excalidraw)

Jedna oś przeglądu: czy ta różnica w kodzie Go jest zgodna z konwencjami opartymi na dowodach zawartymi w
[RULES.md](https://github.com/malinskibeniamin/skills/blob/main/golang-review/RULES.md)? Każda reguła w katalogu zawiera anonimową, zagregowaną liczbę potwierdzeń,
dlatego uwagi wskazują identyfikator reguły i wyjaśniają wpływ widoczny w repozytorium, zamiast opierać się
na preferencjach recenzenta.

Działa samodzielnie dla dowolnej różnicy w kodzie Go lub jako **rola golang** w ramach `/review`. Jawne
delegowanie lub `/swarm` może używać tej umiejętności jako kontraktu dla ograniczonej ścieżki przeglądu.

## Poza zakresem

- Wszystko, co `golangci-lint` już wymusza w docelowym repozytorium — najpierw przeczytaj jego konfigurację i pomiń takie kwestie.
- Ogólny styl Go (gofmt, nazewnictwo, gramatyka komentarzy), który nie ma podstawy w RULES.md.
- Frontend, wygenerowane pliki (`*.pb.go`, `*_pb.go`, `*.connect.go`, `@generated`/`DO NOT EDIT`), kod dostawców.
- Ponowne rozstrzyganie zasad katalogu: reguła, z którą się nie zgadzasz, jest informacją zwrotną dotyczącą katalogu, a nie podstawą do sformułowania przeciwnej uwagi.

## Procedura

1. **Zakres**: różnica od ustalonego punktu do HEAD, wyłącznie pliki Go i proto. Zanotuj
   lintery włączone w `.golangci.yml` repozytorium; wszystko, co wymuszają, jest poza zakresem.
2. **Sklasyfikuj** różnicę według obszarów: powierzchnia proto/API, procedury obsługi usług, przepływy pracy
   i aktywności Temporal, kontrolery Kubernetes, testy, konfiguracja i wdrażanie, ścieżki bezpieczeństwa
   dotyczące dzierżawców, współbieżność i cykl życia.
3. **Wczytaj** odpowiednie sekcje pliku [RULES.md](https://github.com/malinskibeniamin/skills/blob/main/golang-review/RULES.md) oraz pasujące pliki obszarów `/golang`
   (PROTO-API, CONCURRENCY, ERRORS, TESTING, TEMPORAL, SECURITY, ROLLOUT,
   STRUCTURE, CONTROLLERS). Zastosuj każdą regułę S/A w zakresie; B przy wyraźnym naruszeniu; C/D
   tylko wtedy, gdy różnica jednoznacznie narusza treść reguły.
4. **Sprawdź listę napięć** w RULES.md i `/golang` SKILL.md przed zapisaniem
   uwagi — dodatnie wartości logiczne a domyślna odmowa, instrukcje switch dla podzbiorów enumów, keepalive,
   obiekty filtrów a ciągi znaków zależą od kontekstu i nie są automatycznie naruszeniami.
5. **Zgłoś** uwagi, podając dla każdej: identyfikator reguły, plik:wiersz, działanie różnicy, wymaganą
   zmianę i priorytet. Maksymalnie 400 słów w roli panelowej; samodzielne uruchomienia mogą być dłuższe,
   ale muszą opierać się na katalogu.

## Poziomy ważności

- **P0**: predykat bezpieczeństwa domyślnie zezwalający, ruch wychodzący dzierżawcy omijający safedial, zapisanie/zwrócenie/zarejestrowanie
  sekretu jawnym tekstem, zatwierdzenie postępu przed trwałym przetworzeniem,
  niewersjonowana zmiana naruszająca aktywne historie Temporal.
- **P1**: każde inne naruszenie S/A — nieograniczony wzrost kontrolowany przez dzierżawcę, nieprzetworzone błędy wewnętrzne
  na publicznej powierzchni, brak etapowego usuwania, twierdzenie o integracji oparte na atrapach.
- **P2**: naruszenia B; przypadki S/A wymagające decyzji autora.
- **P3**: sformułowania i dopracowanie w regułach C/D.

Potwierdzone błędy zachowują poziom P0/P1 niezależnie od rozmiaru poprawki.

## Wynik

Standardowy kontrakt roli: uwagi muszą dotyczyć zmian wprowadzonych przez różnicę, wpływać na użytkownika, umożliwiać podjęcie działania
i być gotowe do opublikowania jako komentarz do PR-a (Co, Dlaczego w odniesieniu do reguły katalogu, Sugerowana poprawka, Jednorazowy prompt).
Gdy żadna reguła w zakresie nie została naruszona: `APPROVED -- <sprawdzone obszary>, brak naruszeń katalogu.`
