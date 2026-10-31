---
description: >-
  Używaj do opartego na dowodach przeglądu defektów wprowadzonych przez diff w
  gałęziach, PR-ach, WIP lub wydaniach.
related:
  - /skills/development-lifecycle
  - /skills/tdd
search:
  boost: 3
  keywords:
    - review
    - code review
    - pull request
    - pr
sidebar:
  label: /review
title: /review
type: skill
---
![Diagram umiejętności /review](/diagrams/skills/review.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/review.excalidraw)

Przy przeglądzie zmian przeczytaj [adaptację Poteto](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#review-and-diagnosis).

Dla zmian interfejsu stosuj [reguły zgodności](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/INTERFACES.md#interface-review) oraz zwykły [wykaz usuniętych sygnałów](https://github.com/malinskibeniamin/skills/blob/v4.42.0/vendor/jakubkrehel/skills/interface-review/removed-signals.md), aby sprawdzić utracone możliwości po obu stronach różnicy. Wczytaj `visual-review` dla dowodów renderowania. Nie wywołuj automatycznie osobnego `interface-review` ani nie twórz drugiego raportu.

Przeglądaj ustalony zakres. Zachowaj jednego właściciela; delegowanie wymaga jawnej zgody. Nie edytuj, nie commituj, nie wypychaj ani nie publikuj bez jawnej intencji. Żądane naprawy przechodzą do [dostarczania autora](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/delivery-workflow.md) w nazwanym zakresie.

Dobierz głębokość i zasady zbieżności według [modelu przeglądu](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/OPERATING-MODEL.md); ryzyko zmienia zakres kontroli, nie uprawnienia. Przeczytaj też [kontrakt dwóch rodzajów przeglądu](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/review-contract.md).

## Kontrakt przeglądu [#review-contract]

- **Cel**: ustal, czy diff osiąga oczekiwany wynik bez wiarygodnego defektu.
- **Ograniczenia**: zgłaszaj tylko problemy wprowadzone przez diff; oddziel standardy od luk produktu/specyfikacji;
  pliki generowane są dowodem.
- **Weryfikacja**: prześledź źródło. Samodzielnie użyj każdej uruchamialnej zmiany przez prawdziwy punkt wejścia;
  testy nie zastępują doświadczenia.
- **Stop**: uwzględnij każdą powierzchnię; znaleziska wymagają dowodu, konsekwencji, priorytetu, poprawki i weryfikacji.

Zapytaj tylko, jeśli brakuje ustalonego punktu. W przeciwnym razie wyznacz
`BASE=$(PR_BASE_REF="${REVIEW_BASE:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`,
przypnij SHA końca i wspólnego przodka, a następnie sprawdź pełny diff i log tych rewizji.
Dla WIP uwzględnij zmiany w indeksie, poza indeksem i istotne pliki nieśledzone; nazwij wyłączenia.
Przed testami mutacyjnymi lub równoległym odczytem użyj [migawek źródła](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/REFERENCE.md#source-snapshots-and-mutation-tests).
Przed werdyktem sprawdź tożsamość migawki; zmiana wejścia unieważnia odpowiednie dowody.

## Pętla dowodowa [#evidence-loop]

**sprawdź -> zweryfikuj -> sklasyfikuj -> zsyntetyzuj.**

### Sprawdź [#inspect]

1. Przeczytaj żądanie/specyfikację, zasady, pełny diff, miejsca użycia i zachowanie. Nie ufaj opisowi PR bardziej niż kodowi. Uwzględnij obowiązujące `REVIEW.md`, `CODING_STANDARDS.md` i `CONTRIBUTING.md`, jeśli istnieją.
2. Dla każdej zmienionej przesłanki prześledź ją wstecz do autorytatywnych producentów, schematów,
   zapisu, konsumentów i powierzchni publicznych. Szukaj po pojęciu domenowym, polu i emitowanej
   wartości, nie tylko zmienionym symbolu.
3. Załaduj właściwych właścicieli z [dowodów zmiany](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/change-evidence.md); wykorzystaj aktualne artefakty.
4. Sprawdź zaskakujące wyniki w niezależnych artefaktach odpowiedniego niezmienionego kodu, bazie,
   najnowszej historii, dowodach ze środowiska uruchomieniowego i fixture'ach. Porównaj fixture'y z produkcyjnym kształtem danych.
5. Zbuduj jeden behawioralny kontrprzykład dla prawdopodobnej kolizji. Zmapuj uprawnienia i widoczne
   powierzchnie; pomiń styl należący do formatera i wcześniejsze defekty.
6. Zapytaj, co nadal może być błędne, jeśli testy przechodzą.

### Zweryfikuj [#verify]

- Odtwórz problem na podstawie źródła, schematu, dokumentacji pierwotnej albo wykonywalnej kontroli.
- Gdy bezpieczeństwo zależy od jednego nielokalnego faktu, użyj `/blast-radius`; przekaż dowód, nie opis.
- Na reprezentatywnych danych o rzeczywistej skali wykonaj ścieżkę poprawną i jedną wiarygodną ścieżkę błędu lub odzyskiwania.
  Obserwuj konsolę, sieć, logi i czas odpowiedzi; gdy jest to niebezpieczne lub niemożliwe, nazwij blokadę.
- Sprawdź integralność testów: zachowanie publiczne, RED, asercje, pokrycie i brak oczekiwania przez czas.
  Kontrole tekstu źródłowego nie zapewniają pokrycia, chyba że tekst jest publicznym wynikiem; usuń je lub zastąp testem przez
  publiczny punkt styku. Do składni używaj analizy statycznej.

Dodaj kontrolę powierzchni tylko wtedy, gdy diff daje ku temu dowód:

| Powierzchnia | Kontrola |
|---|---|
| UI/CLI/raport dla klienta | Render, stany, tekst, klawiatura/a11y, konsola, viewport |
| Bezpieczeństwo/prywatność/utrata danych | Atakujący/dostęp, granica zaufania, przepływ poświadczeń od źródła do ujścia, osiągalny wpływ, odzyskiwanie |
| Dokumentacja/zachowanie publiczne | Wykrywalność, wartości domyślne, pominięcie, migracja/informacje o wydaniu; zmiany wyłącznie wewnętrzne nie wymagają wpisu o wydaniu |
| API/schemat/SQL/PostgreSQL | Zgodność, migracje, wynik generowany, rzeczywisty dialekt |
| Go/współbieżność/workflow | Własność, anulowanie, wyścigi, ponowienia, idempotencja |
| Zależność/zewnętrzne API | Dokumentacja pierwotna, wersje, lockfile, ostrzeżenia |

Jeśli różnice obejmują pliki `.proto` (również usunięcia i zmiany nazw), konfigurację Buf lub kontrakty generowania kodu i środowiska protobuf, wczytaj cały [protobuf](https://github.com/malinskibeniamin/skills/blob/v4.42.0/protobuf/SKILL.md). Prześledź wygenerowany kod i odbiorców, nawet jeśli sam schemat się nie zmienił. Możliwości rozwoju pozostają doradcze i oddzielone od usterek. W [przeglądach z bramkami](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/GATES.md) wykluczenie semantyczne nie może pominąć dopasowanej ścieżki protobuf. Zwykły przegląd bezpośredni używa tej samej umiejętności bez włączania bramek ani delegowania.

Ładuj umiejętności zgodnie z [zasadami ładowania zależności](https://github.com/malinskibeniamin/skills/blob/v4.42.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
Wywołaj narzędzie Skill osobno dla „product” i „lie-detector”; zastosuj ich perspektywy bezpośrednio w ramach przeglądu.
Autoryzowane osie przeglądu uruchamiaj na pierwszym planie, w świeżych kontekstach ze wskaźnikami do ustalonego zakresu; zbierz wszystkie raporty. Bez zgody na delegowanie pracuj w bieżącym kontekście.
Specjaliści: [zasady doboru](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/REVIEWERS.md).

### Sklasyfikuj [#classify]

Znalezisko jest wprowadzone przez diff, ma wpływ, jest odtwarzalne lub konkretne, wskazuje najściślejszą zmienioną linię
i jest połączone z najmniejszą bezpieczną poprawką.

- **P0**: ekspozycja, utrata danych, awaria lub niemożliwy przepływ podstawowy.
- **P1**: regresja użytkownika, złamany kontrakt, fałszywy sukces lub poważny problem a11y.
- **P2**: użyteczna, ograniczona poprawka o mniejszym wpływie.
- Pomijaj opcjonalną przyszłą pracę i kosmetykę w komentarzach liniowych.

Nie zgłaszaj wydajności bez pomiaru lub granicy strukturalnej. Nie zgłaszaj przypadku brzegowego
bez wiarygodnego ryzyka. Dowód może uzasadniać odrzucenie uwagi.

### Zsyntetyzuj [#synthesize]

Przeczytaj [zasady komunikacji](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/communication.md); zachowaj schemat wyniku.
Zacznij od liczby znalezisk, w tym jawnego zera. Deduplikuj według przyczyny źródłowej; nazwij klasę błędu i dotknięte przypadki. Przy ponownym przeglądzie, po pełnym przeglądzie początkowym, sprawdź diff napraw i wcześniejsze znaleziska; rozszerz zakres, gdy zmieniają się założenia. Oznacz stan każdej uwagi dowodem. Pomiń pochwały i szukanie niezwiązanych błędów; oddziel wartość od defektów.

## Tryb głęboki [#deep-mode]

Dla `--deep` użyj tej samej pętli z pełnym rejestrem zastosowania. Przeczytaj
[DEEP-AUDIT.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/DEEP-AUDIT.md); uwzględnij wszystkie powierzchnie i nie dodawaj automatycznych agentów.

## Wynik [#output]

Przeczytaj [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/REFERENCE.md), aby poznać słownictwo i schemat. Zgłaszaj
`[P0|P1|P2] <file:line> <title> - <evidence, consequence, correction, verify command>`.
Dodaj `entrypoint, data, actions, observations, timing, limits`, ustalony punkt, tryb, liczby,
wiersze `product:` i `lie-detector:`, werdykt i pozostałe ograniczenia. Czysty przegląd zwraca tylko te wiersze, werdykt i pozostałe ograniczenia.
Gdy zakres przeglądu protobuf obejmuje konkretne możliwości rozwoju, dodaj osobną, nieblokującą sekcję doradczą; pomiń pustą. Ustrukturyzowane przeglądy z bramkami zachowują schemat usterek i używają jego pola możliwości doradczych.
