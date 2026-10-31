---
description: >-
  Buduj, testuj i diagnozuj monorepo Bazel obejmujące Go, C++, TypeScript i
  React. Używaj do BUILD/Starlark, Bzlmod, toolchainów, pamięci podręcznej,
  pętli programistycznych, CI dla dotkniętych celów i artefaktów wydania.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - bazel
sidebar:
  label: /bazel
title: /bazel
type: skill
---
![Diagram umiejętności /bazel](/diagrams/skills/bazel.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/bazel.excalidraw)

Doprowadź do tego, by zadeklarowany graf kompilacji odtwarzał żądane zachowanie.
Wrappery, makra, przypięte wersje i reguły CI z repozytorium mają pierwszeństwo
przed tymi ogólnymi wskazówkami.

## Ustal kontrakt kompilacji [#establish-the-build-contract]

- Ustal katalog główny obszaru Bazel, `.bazelversion`, główny `MODULE.bazel`,
  właściwe importy `.bazelrc`, instrukcje komponentu i rzeczywisty punkt wejścia CI.
  Korzystaj z przypiętej wersji Bazel przez Bazelisk lub wrapper repozytorium,
  a nie z globalnie zaktualizowanego programu. Ustawienia konkretnego komputera
  trzymaj w istniejącym, ignorowanym pliku rc użytkownika.
  Sprawdzaj nowsze flagi, składnię adnotacji Starlark i reguły względem tych wersji;
  demonstracje konferencyjne i plany rozwoju nie są kontraktami wydanego API.
- Przy aktualizacji wersji, błędach zaufania w dołączonym JDK lub sprawdzaniu
  zgodności z Bazel 10 przeczytaj [wskazówki dotyczące wydań](https://github.com/malinskibeniamin/skills/blob/v4.42.0/bazel/references/releases.md).
  Oddziel aktualizacje poprawek w tej samej linii od dobrowolnych testów kandydatów do wydania.
- Odróżniaj **elementy mające pliki BUILD** od **elementów obsługiwanych dziś przez
  Bazel**. Wygenerowane cele nie dowodzą użycia w CI. Sprawdzaj scalony kod, nie
  pośredni commit, plan wdrożenia ani poprzednie repozytorium.
- Zachowaj granicę jednego modułu głównego monorepo. Skup deklaracje zależności
  i toolchainów w tym katalogu; nowy zagnieżdżony `MODULE.bazel` może ukryć poddrzewo
  przed wyszukiwaniem przez wzorce. Celowo oddzielny obszar traktuj jako osobną
  kompilację, nie jako okazję do przypadkowej konsolidacji.
- Dla drzewa Go/Task/Gazelle przeczytaj [monorepo Go](https://github.com/malinskibeniamin/skills/blob/v4.42.0/bazel/references/go-monorepo.md).
  Dla C++, kompilacji krzyżowej, akceleratorów lub integracji wybieranej z grafu
  przeczytaj [monorepo C++](https://github.com/malinskibeniamin/skills/blob/v4.42.0/bazel/references/cpp-monorepo.md).
  Dla integracji frontendu lub Node przeczytaj [TypeScript i React](https://github.com/malinskibeniamin/skills/blob/v4.42.0/bazel/references/typescript-react.md).
  Wczytuj tylko potrzebne profile.
- Dla topologii wielu aplikacji, lokalnej orkiestracji, CI dla dotkniętych celów,
  pamięci podręcznej, zdalnego wykonania lub selektywnych wydań przeczytaj
  [skalowanie monorepo](https://github.com/malinskibeniamin/skills/blob/v4.42.0/bazel/references/monorepo-scale.md).
  Przy badaniu możliwości wdrożenia lub wyborze szablonu przeczytaj przypięte
  [przykłady społeczności i ich ograniczenia](https://github.com/malinskibeniamin/skills/blob/v4.42.0/bazel/references/community-examples.md).

## Wybierz pętlę przyrostową [#choose-the-incremental-loop]

Rozdziel ponowne użycie akcji, wybór celów na podstawie Git, HMR przeglądarki
i wdrożenie. Bazel odpowiada za zadeklarowane zależności kompilacji, testów
i artefaktów; narzędzie frontendowe za Fast Refresh, a orkiestracja za cykl życia
usług i wdrożenie. Uruchamiaj tylko zależności potrzebne lokalnej aplikacji, nie
wszystkie aplikacje. Zachowaj istniejące frameworki i menedżery pakietów; sprawdź
jeden przekrojowy wycinek przed standaryzacją. Zmierz zimne, rozgrzane i bezczynne
kompilacje oraz reprezentatywne edycje, zanim obiecasz przyspieszenie; samo dodanie
Bazel nie dowodzi poprawy.

## Znajdź właściciela przed edycją [#find-the-owner-before-editing]

Przeczytaj najbliższy plik BUILD i używane makra. Odszukaj istniejące etykiety,
zamiast zgadywać cel programu, obrazu lub testu. Jawnie deklaruj zależności,
wygenerowane źródła i pliki potrzebne w czasie wykonania; `deps` i testowe `data`
rozwiązują różne problemy.

Dobierz graf do pytania ([semantyka zapytań](https://bazel.build/query/cquery),
[graf akcji](https://bazel.build/query/aquery)):

| Pytanie | Narzędzie |
|---|---|
| Jakie testy lub komponenty korzystające z pliku istnieją albo do niego docierają? | `query`, `tests(...)`, ograniczone `rdeps(...)` |
| Która gałąź `select()`, platforma lub zależność jest aktywna? | `cquery` z konfiguracją błędnej kompilacji |
| Jaki kompilator, flagi, wejścia i wyjścia tworzą akcję? | `aquery` z tą samą konfiguracją |

`query` obejmuje możliwe gałęzie konfiguracji; nie dowodzi wykonania celu.
`aquery` opisuje akcje; nie materializuje ich wygenerowanych wejść. Częściowy wynik
lub błąd oznacza niepełne dowody, nigdy pusty zbiór dotkniętych celów.

## Zmień i zweryfikuj [#change-and-verify]

1. Odtwórz defekt za pomocą błędnego celu lub testu kontraktu publicznego. Dla
   zmian kompilacji etapem RED może być błąd analizy, kompilatora, formatowania
   lub testu reguły.
2. Edytuj właściwe źródło, wejście generatora lub makro. Odśwież pochodne pliki
   BUILD generatorem repozytorium; użyj jego formatowania i sprawdź różnicę.
   Zachowaj celową widoczność, zgodność, tagi i dane.
3. Przy zmianach zależności zaktualizuj właściwy manifest języka lub moduł główny,
   a następnie uruchom ustalone porządkowanie modułów i aktualizację lockfile.
   Zatwierdź powstałe metadane razem. Przestrzegaj trybu lockfile z CI; naprawiaj
   nieaktualne blokady lokalnie zamiast je usuwać lub osłabiać CI. Zobacz
   [tryby lockfile](https://bazel.build/external/lockfile).
4. Zbuduj i przetestuj najmniejszy zmieniony cel we właściwej konfiguracji,
   następnie dotknięte komponenty korzystające z niego. Wspólne makra, główne
   zależności, toolchainy i konfiguracja wymagają szerszej macierzy repozytorium.
   Cele niezgodne z platformą, ręczne i odfiltrowane testy integracyjne nie są
   zaliczeniami; wskaż nieprzetestowane warianty.

## Diagnozuj bez niszczenia dowodów [#diagnose-without-destroying-the-evidence]

- Odtwórz dokładną etykietę, konfiguracje oraz platformy docelowe i wykonawcze.
  Użyj `--announce_rc` i `--verbose_failures`; `--sandbox_debug` dodawaj tylko
  do odtworzenia błędu. Sprawdź połączone opcje rc i wejścia akcji przed zmianą flag.
- Rozróżniaj błędy analizy i etykiet, pobierania repozytoriów i uwierzytelniania,
  toolchainu i platformy, sandboxa i runfiles, transportu pamięci podręcznej
  oraz testów. Napraw właściwą warstwę zamiast globalnie wyłączać sandbox,
  ostrzeżenia, sanitizery lub ograniczenia zgodności.
- Przy wyjściu poza sandbox przez dowiązania symboliczne w macOS, rozwiązywaniu
  ścieżek przez narzędzia natywne, kosztach tworzenia sandboxa lub lokalnym wykonaniu
  w VM przez REAPI przeczytaj [wykonanie lokalne](https://github.com/malinskibeniamin/skills/blob/v4.42.0/bazel/references/local-execution.md).
- Oddziel pamięć pobranych repozytoriów, pamięć akcji i zdalne wykonanie.
  Zdalna pamięć podręczna nie jest zdalnym wykonawcą. Przestrzegaj zapisanej
  w repozytorium polityki pamięci podręcznej i wysyłania wyników; nie zapisuj
  prywatnych endpointów ani poświadczeń w śledzonej konfiguracji.
- Na początku zachowaj rozgrzane pamięci podręczne. `clean`, `expunge`, usuwanie
  lockfile lub nowy katalog wyjściowy nie są pierwszym sposobem naprawy.
  Jeśli potrzebna jest izolacja, określ hipotezę i ogranicz reset do własnej próby.
- Gdy test musi rzeczywiście uruchomić się ponownie, użyj ograniczonego uruchomienia
  z `--nocache_test_results`. W innych przypadkach wyniki z pamięci podręcznej są
  prawidłowymi dowodami dla zadeklarowanych wejść; uczciwie odróżniaj je od
  wykonanych testów. Konsument wyjścia może wymagać jawnej materializacji przy
  minimalnym pobieraniu wyników ([zdalna pamięć podręczna](https://bazel.build/remote/caching)).

Podaj zmieniony kontrakt grafu, dokładne cele, konfiguracje i wyniki kontroli,
w tym pominięte lub zablokowane warianty. Zbudowanie obrazu nie upoważnia do jego
publikacji ani wdrożenia. Pochodzenie i ograniczenia aktualizacji opisuje
[podstawa badawcza](https://github.com/malinskibeniamin/skills/blob/v4.42.0/bazel/references/research-basis.md).
