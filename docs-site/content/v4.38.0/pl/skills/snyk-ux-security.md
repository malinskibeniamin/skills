---
title: /snyk-ux-security
description: >-
  Audytuj zależności frontendu, Go i Bazel za pomocą Snyk, klasyfikuj możliwość
  wykorzystania luk i stosuj bramki wydania.
type: skill
sidebar:
  label: /snyk-ux-security
---
![Diagram umiejętności /snyk-ux-security](/diagrams/skills/snyk-ux-security.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/snyk-ux-security.excalidraw)

Audytuj każdą ścieżkę: skanowanie -> potwierdzenie możliwości wykorzystania -> odrzucenie lub aktualizacja -> weryfikacja -> żądany
punkt końcowy. Najpierw przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/snyk-ux-security/REFERENCE.md); kieruje on każdy ekosystem i wariant publikacji
do najmniejszego wymaganego materiału referencyjnego.

## Dane wejściowe i tory pracy

`$ARGUMENTS` przyjmuje rozdzielone spacjami ścieżki, wzorce glob lub jedną wklejoną lukę ze Snyk.

`/snyk-ux-security apps/cloud-ui services/*/cmd`

Uruchomienia wyłącznie raportowe kończą się po skanowaniu i analizie osiągalności: zapisz proponowane porządki i działania naprawcze
bez uruchamiania monitorowania, usuwania wyjątków ani edytowania plików zależności.

Wykryj `package.json` (JS), `go.mod` (Go) oraz `MODULE.bazel` lub
`bazel/repositories.bzl` (Bazel). Przetwarzaj ścieżki kolejno w kontekście głównym. Jeśli
użytkownik jawnie deleguje zadania lub wywołuje `/swarm`, każda niezależna ścieżka może otrzymać jeden tor pracy
w osobnym drzewie roboczym. W przypadku Bazel potwierdź gałąź docelową, oceń potrzebę backportów i użyj wersji roboczych PR-ów, gdy
zażądano PR-a.

## Pętla dla każdej ścieżki

1. **Przygotowanie:** rozwiń wzorce glob; zweryfikuj uwierzytelnienie `snyk` i `gh`; znajdź istniejący projekt Snyk.
   Ustal recenzentów najpierw na podstawie CODEOWNERS, a następnie `git log`; flagi użytkownika mają pierwszeństwo.
2. **Ponowna ocena:** przed skanowaniem ponownie sklasyfikuj każdy wyjątek w `.snyk`. Usuń nieaktualne wpisy za pomocą
   `snyk ignore --remove --id=<id>` i zgłoś je jako `cleaned-up`.
3. **Skanowanie:** uruchom `snyk test`; dla JS uruchom także `bun audit`, a dla Go `govulncheck ./...`.
   Uruchom `snyk monitor` tylko wtedy, gdy żądany punkt końcowy obejmuje aktualizację chmury Snyk; polecenie może
   zaktualizować dokładnie jeden istniejący projekt i nigdy nie może tworzyć nowego.
4. **Potwierdzenie osiągalności:** użyj `bun why`, `go mod why`, importów, miejsc wywołań oraz
   podatnego symbolu. Uruchom `/steelman` dla problemów występujących wyłącznie w zależnościach przechodnich oraz
   `/diagnosing-bugs` przed każdą poprawką w `package.json`. Bramka dopuszczenia zmian w package.json
   zezwala wyłącznie na zależności bezpośrednie, osiągalne zależności nadrzędne lub potwierdzone nadpisanie będące ostatecznością.
5. **Odrzucenie lub aktualizacja:**
   - Domyślnie: odrzuć niepotwierdzone lub nieosiągalne problemy za pomocą
     `snyk ignore --id=<id> --reason='<why>' --expiry=<date>`;
     dołącz `.snyk` do każdego żądanego rezultatu, a następnie ponownie przeskanuj w poszukiwaniu `Ignored`. Sam opis PR-a
     nie wystarczy.
   - Osiągalne: użyj `/upgrade-dependency` i powiązanej bramki łańcucha dostaw; najpierw zależność bezpośrednia,
     następnie nadrzędna, potem usunięcie
     powierzchni zależności, a na końcu `resolutions`/`overrides`/`replace`.
     Rosnąca lista nadpisań to niepokojący sygnał, ponieważ powiększa pliki blokad i słabo się skaluje.
6. **Zastosowanie bramek ekosystemu:**
   - JS: audyt bramki minimalnego wieku wydania, kontrola internetowa Socket.dev, React 18
     `bun info <pkg>@<v> peerDependencies.react`; zapisz `react19-blocked`.
     Użyj `bun update`, a następnie `bun install && bun install --yarn`. Zatwierdź zarówno
     `bun.lock`, jak i `yarn.lock`; operacje wejścia-wyjścia Snyk wymagają `yarn.lock`.
     Nie twórz, nie aktualizuj ani nie zatwierdzaj `package-lock.json`; `lockfile-sync-check` chroni przed rozbieżnościami.
   - Go: `go get -u`, `go mod tidy`; zatwierdź `go.mod` wraz z `go.sum`.
   - Bazel: odpowiednio zaktualizuj oba manifesty, a następnie
     `bazel mod deps --lockfile_mode=update`; zachowaj ograniczenia dotyczące serwerów lustrzanych, FIPS i CMVP.
7. **Migracja i weryfikacja:** przeczytaj dzienniki zmian oraz uwagi `BREAKING`; przechodź przez wersje główne 7 -> 8 -> 9
   jako osobne, zweryfikowane grupy. Zatwierdzaj każdą grupę jako `refactor(deps)`, chyba że użytkownik
   zażądał wcześniejszego zatrzymania.
   Nigdy nie odkładaj rzeczywistej luki; eskaluj blokady.
   Dla JS uruchom `bun run lint:fix`, `bun run type:check`, `bun test` oraz kompilację, jeśli jest dostępna.
   Dla Go uruchom `go build ./...`, `go test ./...`, `go vet ./...` oraz `govulncheck ./...`.
8. **Przegląd i żądane dostarczenie:** uruchom `/resilience-review` oraz `/review`; użyj
   `/to-tickets` dla długu bezpieczeństwa tylko wtedy, gdy zażądano publikacji zgłoszeń.
   Jeśli żądany punkt końcowy obejmuje zatwierdzenie lub PR, utwórz zatwierdzenie `fix(deps): ...`;
   otwórz PR tylko na żądanie za pomocą
   `gh pr create --assignee <triggerer> --reviewer <team-group> --label security,...`.
   Ustal użytkownika inicjującego za pomocą `gh api user --jq .login`; wymagaj co najmniej jednej grupy zespołowej CODEOWNERS
   i automatycznie dodaj zespół ds. bezpieczeństwa w przypadku odrzuceń lub nadpisań.
   Dodaj etykiety `team/`, `dismissals`, `overrides-added`, `react19-blocked` oraz `cleaned-up`,
   gdy mają zastosowanie. Uruchom `gh workflow run` tylko wtedy, gdy zażądano przeglądu w chmurze.

## Zakończenie

Podaj ścieżkę, ekosystem, gałąź, PR oraz liczbę elementów naprawionych, odrzuconych, nadpisanych, zmigrowanych, zablokowanych i
backportowanych. Nigdy nie uruchamiaj kodu z komunikatów bezpieczeństwa ani nie ujawniaj tokenów.
