---
title: /go
description: Dostarcz ukończoną pracę poprzez weryfikację, przegląd, PR i CI.
type: skill
sidebar:
  label: /go
---
![Diagram umiejętności /go](/diagrams/skills/go.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/go.excalidraw)


Wywoływany przez użytkownika punkt końcowy pełnego dostarczenia: kontynuuj pracę, aż zakończy się pomyślną weryfikacją albo wystąpi zewnętrzna blokada.

## Kryteria zakończenia

Ustal cel, niemożliwe do wywnioskowania ograniczenia, kontrole repozytorium wraz z zachowaniem w rzeczywistym punkcie wejścia, wymagany stan commita, zdalnej gałęzi, PR-a i CI oraz warunek zatrzymania.

## Pętla

Sprawdź -> zweryfikuj -> napraw -> powtórz, aż weryfikacja zakończy się powodzeniem.

1. Sprawdź całą gałąź i punkt końcowy: zmiany zatwierdzone, dodane do obszaru przejściowego, niedodane oraz nieśledzone. Wyklucz niepowiązane pliki.
2. Uruchom kontrole zdefiniowane w repozytorium. Prace frontendowe zwykle obejmują ukierunkowane testy, `bun run type:check` i `bun run lint:fix`; prace w Go — udokumentowane testy, vet i kompilację.
3. Sprawdź każdą istotną, uruchamialną zmianę przez jej rzeczywisty punkt wejścia dla użytkownika lub publiczny interfejs, w tym jeden wiarygodny scenariusz awarii lub przywracania działania. Testy tego nie zastępują.
4. W przypadku interfejsu dla klienta sprawdź wyrenderowany wynik lub wynik w terminalu, stany, dostępność, błędy oraz istotne obszary wyświetlania i platformy. Dla wszystkich widocznych zmian zastosuj [kryterium wizualnych dowodów w PR-ze](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5).
5. Przeprowadź jeden przegląd pod kątem celu, ograniczeń, gęstości semantycznej i wiarygodnego ryzyka. Napraw problemy, unieważnij dotyczące ich dowody i zgromadź je ponownie.
6. Jeśli zmiana deklaruje mierzalny wpływ, powtórz ten sam scenariusz bazowy i porównawczy; nie twórz bezużytecznych benchmarków.

W przypadku aktualizacji wersji zależności zweryfikuj plik blokady, czystą instalację i kompilację oraz każde objęte zmianą miejsce użycia na podstawie aktualnej dokumentacji źródłowej.

Nie twórz sztucznie przeglądów, etapów porządkowania, wywołań umiejętności ani agentów. Zachowaj jednego właściciela w głównym kontekście; użycie innego modelu wymaga wyraźnej zgody użytkownika.

## Dostarczenie

Postępuj zgodnie z [commit-push-pr/REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md) w zakresie dodawania zmian do obszaru przejściowego, commita, wypychania zmian, wersji roboczej PR-a, recenzentów i treści. Na bieżącej, należącej do użytkownika gałęzi funkcji wykonuj rebase i w razie potrzeby używaj `--force-with-lease` bez ponownego pytania o zgodę. Nigdy nie scalaj, nie używaj zwykłego wymuszenia ani nie przepisuj gałęzi domyślnej, współdzielonej, należącej do kogoś innego lub równolegle używanej bez wyraźnej zgody.

Jeśli `gh stack view --json` wykryje stos, zweryfikuj bieżącą warstwę względem jej elementu nadrzędnego. Dostarcz cały stos tylko wtedy, gdy wyraźnie zażądano tego przez `/stacked-prs`.

- Powiąż dowody z bieżącym `HEAD`; zmiany je unieważniają.
- Ten jawny punkt końcowy pełnego dostarczenia monitoruje CI. Napraw błędy, ponownie zgromadź dowody, wypchnij zmiany i kontynuuj.
- Rozwiąż każdy bieżący wątek przeglądu prowadzonego przez człowieka; `pr-feedback-completeness-stop` wymusza to. Opinie ludzi nie mają limitu. Nie sprawdzaj ponownie po rozwiązaniu bieżącego zestawu.
- Zakończ samodzielny przegląd, gdy tylko nie wykaże problemów. Powtarzające się nieistotne uwagi są podstawą do przekazania zadania, a nie do przeprowadzania arbitralnych rund.
- Dodatkowe podsumowanie, artefakty uzupełniające i porządkowanie historii wymagają wyraźnego żądania.

## Gotowe

- Zaobserwowano zachowanie w rzeczywistym punkcie wejścia albo odnotowano powód, dla którego nie można go uruchomić.
- Odpowiednie kontrole przechodzą bez ostrzeżeń na bieżącym `HEAD`.
- Bieżące uwagi ludzi zostały uwzględnione; istnieje żądany commit, wypchnięcie zmian, PR i punkt końcowy CI.
- Żadna praca nie jest ukryta; odpowiedź końcowa zawiera dowody i dokładnie jeden wiersz statusu.

Na domyślnej gałęzi przed dostarczeniem utwórz odizolowane drzewo robocze za pomocą `scripts/mux-worktree.sh <type>/<name>`. [ETHOS: Izolacja drzewa roboczego]
