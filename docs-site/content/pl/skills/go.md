---
title: /go
description: Dostarcz ukończoną pracę poprzez weryfikację, przegląd, PR i CI.
type: skill
sidebar:
  label: /go
---
![Diagram umiejętności /go](/diagrams/skills/go.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/go.excalidraw)

Wywoływany przez użytkownika punkt końcowy pełnego dostarczenia. Kontynuuj pracę, aż żądany artefakt zostanie dostarczony
i pomyślnie przejdzie weryfikację albo zostanie wykazana rzeczywista zewnętrzna blokada.

## Kryteria zakończenia

Ustal poniższe elementy na podstawie żądania i bieżącego stanu repozytorium:

- **Cel**: dostarczone zachowanie lub zmiana.
- **Ograniczenia**: granice dotyczące gałęzi, prywatności, działań destrukcyjnych i obszarów zastrzeżonych przez użytkownika.
- **Weryfikacja**: kontrole repozytorium oraz obserwowalne zachowanie w rzeczywistym punkcie wejścia.
- **Dostarczenie**: stan commita, zdalnej gałęzi, PR-a i CI wymagany przez żądanie.
- **Zatrzymanie**: wszystkie kryteria są spełnione albo zewnętrzna zależność uniemożliwia dalszy postęp.

## Pętla

**Sprawdź -> zweryfikuj -> napraw -> powtórz**, aż weryfikacja zakończy się powodzeniem.

1. Sprawdź pełny diff gałęzi i żądany punkt końcowy. Uwzględnij zmiany zatwierdzone, dodane do obszaru przejściowego,
   niedodane oraz nieśledzone; nie dostarczaj niepowiązanych plików.
2. Uruchom wszystkie mające zastosowanie kontrole zdefiniowane w repozytorium. Prace frontendowe zwykle obejmują ukierunkowane
   testy, `bun run type:check` i `bun run lint:fix`; prace w Go obejmują udokumentowane testy,
   vet i kontrole kompilacji.
3. Sprawdź każdą istotną, uruchamialną zmianę przez jej rzeczywisty punkt wejścia dla użytkownika lub publiczny interfejs.
   Zweryfikuj zamierzone użycie oraz jeden wiarygodny scenariusz awarii lub przywracania działania. Testy tego nie zastępują.
4. W przypadku interfejsu dla klienta sprawdź wyrenderowany wynik lub wynik w terminalu, ważne
   stany, dostępność, konsolę i błędy oraz istotne ryzyka związane z obszarem wyświetlania lub platformą.
5. Przeprowadź jeden przegląd pod kątem celu, ograniczeń, gęstości semantycznej i wiarygodnego ryzyka.
   Napraw konkretne problemy, a następnie unieważnij i ponownie zgromadź dowody, których dotyczą zmiany.
6. Jeśli zmiana deklaruje mierzalny wpływ, powtórz ten sam scenariusz bazowy i porównawczy.
   Nie twórz sztucznego benchmarku, jeśli nie istnieje miara przydatna przy podejmowaniu decyzji.

W przypadku aktualizacji wersji zależności zweryfikuj plik blokady, czystą instalację i kompilację oraz każde
miejsce użycia objęte zmianą na podstawie aktualnej dokumentacji źródłowej.

Nie twórz sztucznie drugiego przeglądu, etapu porządkowania, wywołania umiejętności ani wywołania agenta. Zachowaj
jednego właściciela w głównym kontekście.
Użycie innego modelu lub delegowanego toku pracy wymaga wyraźnej zgody użytkownika.

## Dostarczenie

Postępuj zgodnie z [commit-push-pr/REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md) w zakresie jawnego dodawania zmian do obszaru przejściowego,
formatu commita, wypychania zmian, tworzenia wersji roboczej PR-a, wskazówek dla recenzentów i treści PR-a. Nigdy nie scalaj ani
nie wykonuj wymuszonego wypchnięcia bez zgody.

Jeśli `gh stack view --json` wykryje stos, przejrzyj i zweryfikuj bieżącą warstwę względem jej
elementu nadrzędnego. Dostarcz cały stos tylko wtedy, gdy wyraźnie zażądano tego przez `/stacked-prs`; zwykły
punkt końcowy PR-a nie może publikować innych niewysłanych warstw.

- Powiąż przegląd i weryfikację z bieżącym `HEAD`; późniejsze zmiany unieważniają te dowody.
- Monitoruj CI tylko dlatego, że to polecenie jest jawnym punktem końcowym pełnego dostarczenia. Napraw
  błąd, ponów odpowiednią weryfikację, wypchnij zmiany i kontynuuj.
- Rozwiąż każdy istniejący wątek przeglądu prowadzonego przez człowieka; `pr-feedback-completeness-stop` wymusza
  brak nierozwiązanych wątków. Opinie ludzi nie mają limitu. Nie sprawdzaj nowych opinii
  po rozwiązaniu bieżącego zestawu.
- Zakończ samodzielny przegląd, gdy tylko nie wykaże problemów. Powtarzające się nieistotne uwagi są podstawą do przekazania zadania,
  a nie powodem do wykonywania arbitralnych rund.
- Dodatkowe podsumowanie, porządkowanie historii lub artefakty uzupełniające wymagają wyraźnego żądania.

## Gotowe

- Żądane zachowanie zaobserwowano w jego rzeczywistym punkcie wejścia albo odnotowano powód, dla którego nie można go uruchomić.
- Odpowiednie kontrole przechodzą bez ostrzeżeń na bieżącym `HEAD`.
- Bieżące uwagi ludzi zostały uwzględnione.
- Istnieje żądany commit, wypchnięcie zmian, PR i punkt końcowy CI.
- Żadne niezatwierdzone ani nieśledzone zmiany nie są ukryte.
- Odpowiedź końcowa zawiera dowody i kończy się dokładnie jednym wierszem statusu.

Na domyślnej gałęzi przed dostarczeniem utwórz odizolowane drzewo robocze za pomocą
`scripts/mux-worktree.sh <type>/<name>`. [ETHOS: Izolacja drzewa roboczego]
