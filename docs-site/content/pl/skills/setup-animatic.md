---
description: "Wybierz i przetestuj głos, renderer, styl i narzędzie łączenia animatików, a następnie zapisz konfigurację repozytorium docelowego. Uruchamiaj jawnie, aby skonfigurować lub zmienić narzędzia."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["setup animatic"]}
sidebar: {"label":"/setup-animatic"}
title: "/setup-animatic"
type: "skill"
---
![Diagram umiejętności /setup-animatic](/diagrams/skills/setup-animatic.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/setup-animatic.excalidraw)

Przeczytaj [zasady zgodności z hostem](https://github.com/malinskibeniamin/skills/blob/main/shared/MATT-POCOCK.md) i [granice hosta animatic](https://github.com/malinskibeniamin/skills/blob/main/animatic/SKILL.md), a następnie wykonaj pełną [konfigurację źródłową](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/in-progress/setup-animatic/SKILL.md). Odnośniki względne rozwiązuj względem tego katalogu źródła; `<animatic>` oznacza jego vendored katalog sąsiedni, nie lokalny adapter. Zachowaj etapowy wywiad, próbki głosu, budowanie jednego momentu i wymóg przetestowanej konfiguracji.

## Zakres wykonania

- Przed pytaniami o narzędzia sprawdź rzeczywistą maszynę. Zalecaj istniejące działające opcje, wyjaśniaj zachowanie online/offline i koszty, a następnie czekaj na wybory użytkownika. Obecność klucza nie upoważnia do płatnej mowy ani ujawniania danych. Pokaż błędy poleceń; zamiennik wybiera użytkownik.
- Przed zmianami ustal maszynę i zakres instalacji oraz pamięci podręcznej. Zdalna konfiguracja wymaga wyraźnie wskazanego celu i autoryzowanego dostępu. Wykonuj rozpoznanie i testy tam, nie zastępuj ich testami lokalnymi. Używaj bezpiecznego przepływu poświadczeń hosta; brak dostępu blokuje pracę, nie uzasadnia tworzenia maszyny, kopiowania sekretów ani zmiany SSH lub ustawień globalnych.
- Używaj narzędzi projektu i zatwierdzonych lokalizacji zależności. Skrypt źródłowy instaluje własne zależności npm w `ANIMATIC_HOME`; wyjaśnij to przed konfiguracją. Dla jednorazowego testu użyj tymczasowej pamięci podręcznej.
- Po pokazaniu proponowanej treści zapisuj tylko przetestowane flagi i nazwy zmiennych środowiskowych w `docs/agents/animatic.md` repozytorium docelowego. Zachowaj istniejące wybory; wartości sekretów pozostają w środowisku lub menedżerze sekretów hosta.
- Odnośnik do konfiguracji dodawaj przez kanoniczne źródło generowanych instrukcji, potem je wygeneruj ponownie. Instrukcje autorskie edytuj bezpośrednio tylko tam, gdzie wolno. W tym harnessie `AGENTS.md` powstaje z `CLAUDE.md` i `.agents/codex-appendix.md`. Nie twórz żadnego z plików instrukcji tylko dla tego odnośnika.

Na koniec podaj przetestowaną maszynę, ścieżkę konfiguracji, wybrane narzędzia, ścieżki próbki głosu i testowego MP4 oraz pozostałe ograniczenia. Samo dodanie tych umiejętności do repozytorium nie uruchamia konfiguracji.
