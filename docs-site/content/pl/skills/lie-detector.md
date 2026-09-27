---
title: /lie-detector
description: >-
  Wykrywaj rozbieżności między deklaracjami a działaniem zmiany: testy, które
  nie mogą zawieść, zmyślone API, niezamówione zmiany i antywzorce, które łatwo
  powielić. Stosuj przy zmianach widocznych dla użytkowników i przed uznaniem PR
  za gotowy do scalenia.
type: skill
sidebar:
  label: /lie-detector
---
![Diagram umiejętności /lie-detector](/diagrams/skills/lie-detector.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/lie-detector.excalidraw)


Traktuj zmianę jako nieudowodnioną. Przedstaw najmocniejsze argumenty za tym, że „tego nie należy scalać”, a następnie pozwól, by diff obalił je
dowodami. Działa samodzielnie lub jako **rola wykrywacza kłamstw** w `/review` przy każdej
zmianie widocznej dla użytkowników (interfejs, treści, wyniki CLI, publiczne API, raport). Błędy kodu pozostają w
`/review`; wartość — w `/jb`.

Pracuj na drzewie zapisanym w commicie; ustaw `BASE` na wspólnego przodka scalanych gałęzi.

## 1. Testy, które nie mogą zawieść [#1-tests-that-cannot-fail]

Dla każdego dodanego lub zmienionego testu obejmującego zachowanie widoczne dla użytkownika:

1. Zepsuj zachowanie, które test ma chronić: `git diff "$BASE" -- <src> | git apply -R`,
   odwróć zmieniony warunek, usuń renderowany element lub zmień wartość widoczną dla
   użytkownika (treść, liczbę, stan); psucie samych połączeń między elementami nie wykrywa tautologii. Uruchom test, a następnie
   `git checkout HEAD -- <src>`. Nadal przechodzi mimo zepsutego kodu? Test kłamie. Niepowodzenie musi
   wynikać z asercji, a nie z błędu importu, kompilacji lub przygotowania testu. Zapisz polecenie i
   komunikat o niepowodzeniu testu.
2. Sprawdź testy, które przeszły tę weryfikację, pod kątem [bezwartościowych wzorców z test-audit](https://github.com/malinskibeniamin/skills/blob/main/test-audit/SKILL.md#junk-patterns).
3. Zmiana zachowania widocznego dla użytkownika bez testu, który zakończył się niepowodzeniem, i bez odtworzenia
   przez rzeczywisty punkt wejścia (`/dogfood`) pozostaje nieudowodniona.

## 2. Twierdzenia bez dowodów [#2-claims-without-evidence]

Wypisz każde twierdzenie z tytułu i opisu PR, commitów, komentarzy w kodzie, dokumentacji i podsumowania agenta.
Każde wymaga wiersza diffu, wyniku polecenia lub dokumentacji źródłowej:

- Nieistniejący element: importowany symbol, prop, hook, flaga CLI, klucz konfiguracji, zmienna środowiskowa, token
  projektowy, trasa lub opcja, których nie ma w zainstalowanej wersji. Sprawdź plik blokady zależności,
  typy w `node_modules` lub dokumentację źródłową, zamiast polegać na pamięci.
- „Przetestowano”, „zweryfikowano”, „bez zmiany zachowania”, „naprawia X”: wymagają polecenia i jego wyniku albo
  pary wyników testu: najpierw niepowodzenie, potem powodzenie.
- Przywołany plik i wiersz, zgłoszenie lub dokumentacja, które nie potwierdzają twierdzenia.

## 3. Zmiany, o które nikt nie prosił [#3-changes-nobody-asked-for]

Porównaj każdy fragment diffu z zadeklarowanym zakresem. Zgłoś każdy niewyjaśniony fragment, który zmienia obserwowalne
zachowanie lub osłabia zabezpieczenie: usunięte, pominięte lub złagodzone testy; ponownie wygenerowane migawki; rzutowania,
`@ts-ignore`, wyciszenia lintera; zmienione wartości domyślne, treści, trasy, flagi, obsługę błędów,
ponowienia lub limity czasu; zbędne zmiany w pliku blokady zależności lub konfiguracji; ręcznie edytowane pliki generowane; zmianę wizualną
bez zrzutu ekranu.

## 4. Wzorce, które będą powielane [#4-patterns-that-will-spread]

Ludzie i agenci kopiują najbliższy przykład. Dla każdego wzorca wprowadzanego przez diff:

- Znajdź wcześniejsze przykłady za pomocą `rg`; porównaj z głównymi i lokalnymi plikami `CLAUDE.md`/`AGENTS.md`,
  `exemplars/` oraz rejestrem stosu technologicznego.
- Sprzeczność z udokumentowaną regułą lub dominującym wzorcem w repozytorium: zgłoś problem. Waga zależy od zasięgu
  kopiowania: współdzielony komponent, hook, fixture, pomocnicza funkcja testowa, szablon, generator, wzorcowy przykład lub
  umiejętność to P1; kod końcowy to P2.
- Napraw u źródła: zastosuj zatwierdzony wzorzec lub zaktualizuj regułę w tym samym PR i wyjaśnij,
  dlaczego nowa jest lepsza. Współistnienie dwóch stylów jest błędem.

## 5. Weryfikacja najmocniejszych kontrargumentów [#5-steelman-gate]

Postępuj zgodnie z [steelman/SKILL.md](https://github.com/malinskibeniamin/skills/blob/main/steelman/SKILL.md), przyjmując tezę „ten PR należy scalić”.
Przedstaw najmocniejsze argumenty przeciw niej na podstawie werdyktu [jb](https://github.com/malinskibeniamin/skills/blob/main/jb/SKILL.md), powyższych
ustaleń i ustaleń `/review`. **Gotowy do scalenia** tylko wtedy, gdy spełnione są wszystkie trzy warunki:

- wartość: werdykt `jb:` to `justified`;
- prawdziwość: brak P1 w tej analizie, a każde zachowanie widoczne dla użytkownika ma test, który najpierw zawiódł, a potem przeszedł, lub
  zostało odtworzone przez rzeczywisty punkt wejścia;
- implementacja: `/review` nie zgłasza P0/P1.

W każdym innym przypadku wynik to **nieudowodnione**; wskaż jeden dowód, który zmieniłby werdykt. Odrzuć każdy
kontrargument bez wskazania pliku i wiersza lub wyniku polecenia. Nigdy nie blokuj scalenia z powodu preferencji.

## Waga problemów [#severity]

- **P1**: test przechodzący mimo zepsutego zachowania; twierdzenie sprzeczne z kodem lub dokumentacją; nieistniejące
  API; niewyjaśniona zmiana zachowania lub osłabione zabezpieczenie; antywzorzec w miejscu, z którego łatwo go skopiować.
- **P2**: niezweryfikowane, ale wiarygodne twierdzenie; antywzorzec w kodzie końcowym; tautologiczna asercja
  obok rzeczywistych.
- **P3**: tylko w podsumowaniu.

Zgłoś najwyżej pięć problemów, zaczynając od tych, które decydują o scaleniu.

## Format wyniku [#output]

Zawsze zaczynaj od jednego wiersza z werdyktem:

`lie-detector: <truthful|suspect|lying> -- merge <ready|not proven> -- <evidence, at most 20 words>`

`truthful`: brak problemów. `suspect`: tylko P2. `lying`: dowolny P1. Następnie
`[P1|P2|P3] <file:line> <section> -- <lie and proof>; <smallest fix>`. Jeśli nie wykryto problemów, podaj tylko
wiersz z werdyktem.
