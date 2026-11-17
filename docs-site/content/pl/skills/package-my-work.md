---
description: "Przygotowuj dopracowane nagrania po każdej zmianie UI: rozdzielczość, wskaźniki wejścia, zbliżenia i tempo. Także do zamówionych demonstracji; nie do pakietów npm."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["package my work"]}
sidebar: {"label":"/package-my-work"}
title: "/package-my-work"
type: "skill"
---
![Diagram of the /package-my-work skill](/diagrams/skills/package-my-work.svg)

[Open the editable Excalidraw source](/diagrams/skills/package-my-work.excalidraw)

Każda tworzona zmiana UI widoczna dla odbiorcy lub użytkownika końcowego w każdym repozytorium korzystającym z mechanizmu wymaga przygotowanego nagrania dla danego PR-a. Obejmuje to mieszane PR-y i kolejne aktualizacje; wykorzystuj nadal aktualne ujęcia. [Zakres i bramka zakończenia](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PACKAGING.md#per-pr-delivery).


Przy dostarczaniu każdej tworzonej zmiany UI przygotuj dopracowane nagranie; wykorzystuj aktualne ujęcia między iteracjami. Ułatwiaj zobaczenie pracy, nie upiększaj jej możliwości. Przeczytaj [PACKAGING.md](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PACKAGING.md).
To lokalna adaptacja [opisu Emila Kowalskiego](https://x.com/emilkowalski/status/2122704498334339368), a nie kopia nieopublikowanej umiejętności z kursu; [pochodzenie](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PROVENANCE.md).

## Kontrakt rezultatu [#outcome-contract]

Ustal funkcję i rewizję, rzeczywisty punkt wejścia, odbiorcę i kanał, proporcje oraz zamówiony punkt końcowy. Najpierw sprawdź istniejące źródła demonstracji. Pytaj tylko o istotne brakujące decyzje; pozostałe założenia powinny być jawne i odwracalne. Pakowanie nie upoważnia do wysyłania plików, tworzenia PR-a, instalowania renderera, płatnych usług ani zmieniania produktu. Zachowaj ograniczenia local/no-commit/no-push i repozytoryjną politykę dostarczania zmian źródłowych.

## Nagraj -> skup uwagę -> opakuj -> sprawdź [#capture-focus-package-inspect]

1. Wybierz jedną historię: stan początkowy -> działanie -> korzyść. Użyj oczyszczonych danych i izolowanej przeglądarki; zachowaj rzeczywisty błąd i odzyskiwanie, jeśli są istotne.
2. Świadomie dobierz viewport CSS, piksele nagrania i rozmiar eksportu. Sprawdź tekst w docelowym rozmiarze oglądania; większy eksport nie naprawi rozmytego źródła.
3. Dopasuj oznaczenia do wejścia: strzałka w miejscu myszy, kontakt dla dotyku/pióra, fokus dla klawiatury. Pokaż ruch przed aktywacją, śledź przeciąganie bez opóźnień, nie zasłaniaj kontrolek. Klawiatura nie generuje pozornych kliknięć myszy.
4. Najpierw pokaż kontekst, potem przybliż lub wykadruj nieczytelny szczegół. Zachowaj działanie i wynik w kadrze. Użyj istniejącego kompozytora, nie zmieniaj zoomu aplikacji ani przeglądarki.
5. Wykorzystaj [przepisy nagrywania i narracji](https://github.com/malinskibeniamin/skills/blob/main/demo/RECORDING.md) oraz [pipeline wideo PR](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/VIDEO.md). Wytnij przygotowanie i przestoje, dopasuj napisy i audio, pozostaw czas na odczyt wyniku. Oszczędne kadrowanie jest lepsze od dekoracyjnych przejść.
6. Obejrzyj reprezentatywne klatki i cały eksport w rozmiarze docelowym, także bez dźwięku. Sprawdź wymiary, czas, klatkaż, kodek, wielkość pliku, zgodność wskaźników, zbliżenia, napisy, redakcję danych i audio. Napraw, odtwórz ponownie i jawnie podaj niewykonane kontrole.

## Przekazanie odpowiedzialności [#handoffs]

- `/demo` odpowiada za historię klienta, źródła i wyniki w `demos/<slug>/`, narrację, przewodnik, diagram zastępczy i zamówioną publikację. Wywołuje go tylko użytkownik; jego wspólne przepisy można stosować bez wywołania umiejętności.
- Każdy PR ze zmianą UI, również mieszany lub aktualizowany, wymaga opublikowanego nagrania i jawnej deklaracji zgodnie z [dostarczaniem dla każdego PR-a](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PACKAGING.md#per-pr-delivery).
- Dowody interakcji w PR korzystają z `commit-push-pr/VIDEO.md` i tego samego rzeczywistego ujęcia. Każda tworzona zmiana UI wymaga dopracowanego klipu; sam przegląd pozostaje tylko do odczytu.
- Animacje produktu należą do `/animate` lub `/gestures`. Pakowanie zmienia prezentację, nie dostarczane zachowanie. Powtórki terminala pozostają przy przepisach asciinema w `/demo`.

## Gotowe [#done]

Zwróć bezwzględną ścieżkę artefaktu, historię, ustawienia nagrania i eksportu, kontrole odtwarzania oraz istotne edycje i ograniczenia. Linkuj pliki MP4/PNG bezpośrednio; publikuj wyłącznie przez już autoryzowany proces. Brak dostępu do źródła blokuje wierne nagranie, nie upoważnia do rekonstrukcji pozornego sukcesu. Wymagany klip UI pozostaje zablokowany do nagrania lub jawnego odstąpienia przez właściciela. Opcjonalne braki estetyczne nie blokują niepowiązanych zmian poza UI. Zachowaj wymagany końcowy klip oraz tylko zamówione lub wielokrotnie używane materiały pomocnicze.
