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
[RULES.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/golang-review/RULES.md) oraz odpowiednimi wersjonowanymi kontraktami języka? Każda reguła w katalogu
zawiera anonimową, zagregowaną liczbę potwierdzeń. Uwagi dotyczące konkretnych wersji wskazują
oficjalny kontrakt w `/golang`, dlatego żadna z tych podstaw nie opiera się na preferencjach recenzenta.

Działa samodzielnie dla dowolnej różnicy w kodzie Go lub jako **rola golang** w ramach `/review`. Jawne
delegowanie lub `/swarm` może używać tej umiejętności jako kontraktu dla ograniczonej ścieżki przeglądu.

## Poza zakresem

- Wszystko, co `golangci-lint` już wymusza w docelowym repozytorium -- najpierw przeczytaj jego konfigurację i pomiń takie kwestie.
- Ogólny styl Go (gofmt, nazewnictwo, gramatyka komentarzy), który nie ma podstawy w RULES.md ani oficjalnym
  kontrakcie wersji.
- Frontend, wygenerowane pliki (`*.pb.go`, `*_pb.go`, `*.connect.go`, `@generated`/`DO NOT EDIT`), kod dostawców.
- Ponowne rozstrzyganie zasad katalogu: reguła, z którą się nie zgadzasz, jest informacją zwrotną dotyczącą katalogu, a nie podstawą do sformułowania przeciwnej uwagi.

## Procedura

1. **Zakres**: różnica od ustalonego punktu do HEAD; sprawdź pliki Go i proto, a także `go.mod` lub
   `go.work`, gdy może zmienić się wersja języka lub zestawu narzędzi. Zanotuj
   lintery włączone w `.golangci.yml` repozytorium; wszystko, co wymuszają, jest poza zakresem.
2. **Sklasyfikuj** różnicę według obszarów: powierzchnia proto/API, publiczne API SDK/biblioteki,
   procedury obsługi usług, przepływy pracy i aktywności Temporal, kontrolery Kubernetes, testy,
   konfiguracja i wdrażanie, ścieżki bezpieczeństwa dotyczące dzierżawców, współbieżność i cykl życia.
3. **Wczytaj** odpowiednie sekcje pliku [RULES.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/golang-review/RULES.md) oraz pasujące pliki obszarów `/golang`
   (PROTO-API, CONCURRENCY, ERRORS, TESTING, TEMPORAL, SECURITY, ROLLOUT,
   STRUCTURE, CONTROLLERS). W przypadku metod generycznych Go 1.27, zgodności SDK/biblioteki lub
   profilowania wycieków gorutyn wczytaj również [GO-1.27.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/golang/GO-1.27.md). Zastosuj każdą
   regułę S/A w zakresie; B przy wyraźnym naruszeniu; C/D tylko wtedy, gdy różnica jednoznacznie narusza
   treść reguły. Zastosuj kontrakt wydania tylko wtedy, gdy wersja modułu i zmieniana powierzchnia
   obejmują go zakresem.
4. **Sprawdź listę napięć** w RULES.md i `/golang` SKILL.md przed zapisaniem
   uwagi -- dodatnie wartości logiczne a domyślna odmowa, instrukcje switch dla podzbiorów enumów, keepalive,
   obiekty filtrów a ciągi znaków zależą od kontekstu i nie są naruszeniami.
5. **Zgłoś** uwagi, podając dla każdej: identyfikator reguły katalogu lub kontraktu wydania, plik:wiersz,
   działanie różnicy, wymaganą zmianę i priorytet. Maksymalnie 400 słów w roli panelowej;
   samodzielne uruchomienia mogą być dłuższe, ale muszą opierać się na źródłach.

## Poziomy ważności

- **P0**: predykat bezpieczeństwa domyślnie zezwalający, ruch wychodzący dzierżawcy omijający safedial, zapisanie/zwrócenie/zarejestrowanie
  sekretu jawnym tekstem, zatwierdzenie postępu przed trwałym przetworzeniem,
  niewersjonowana zmiana naruszająca aktywne historie Temporal.
- **P1**: każde inne naruszenie S/A -- nieograniczony wzrost kontrolowany przez dzierżawcę, nieprzetworzone błędy wewnętrzne
  na publicznej powierzchni, brak etapowego usuwania, twierdzenie o integracji oparte na atrapach;
  składnia Go 1.27 wykraczająca poza zadeklarowaną lub obsługiwaną minimalną wersję po stronie użytkowników.
- **P2**: naruszenia B; przypadki S/A wymagające decyzji autora;
  metody generyczne kolidujące z wykazaną granicą interfejsu lub refleksji
  albo twierdzenia, że czysty profil wycieków dowodzi braku wycieków.
- **P3**: sformułowania i dopracowanie w regułach C/D.

Potwierdzone błędy zachowują poziom P0/P1 niezależnie od rozmiaru poprawki.

## Wynik

Standardowy kontrakt roli: uwagi muszą dotyczyć zmian wprowadzonych przez różnicę, wpływać na użytkownika, umożliwiać podjęcie działania
i być gotowe do opublikowania jako komentarz do PR-a (Co, Dlaczego w odniesieniu do reguły katalogu lub kontraktu wydania, Sugerowana
poprawka, Jednorazowy prompt).
Gdy żadna reguła ani kontrakt wydania w zakresie nie zostały naruszone:
`APPROVED -- <sprawdzone obszary>, brak naruszeń katalogu lub kontraktu wersji.`
