---
title: /revamp
description: >-
  Przeprowadź dużą przebudowę, port lub migrację, korzystając z pomiarów
  bazowych i najpierw wykonując mechaniczną translację.
type: skill
sidebar:
  label: /revamp
---
![Diagram umiejętności /revamp](/diagrams/skills/revamp.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/revamp.excalidraw)

Wnioski z przepisania Bun 1.4 z Zig na Rust (https://bun.com/blog/bun-in-rust): 1448 plików, 64 równolegle działających agentów, 11 dni, jedna osoba koordynująca, zero usuniętych testów. Zasady są niezależne od języka i modelu — działa dowolny model wykonawczy (wybieraj zgodnie z regułami doboru modeli w CLAUDE.md; przegląd między modelami obowiązuje jak wszędzie).

## 1. Pomiary bazowe przed napisaniem kodu

- **Zamroź rejestr błędów**: najpierw wyszczególnij znane usterki obecnego systemu. Klasyfikacja problemów po przebudowie musi odróżniać „regresję” od „to zawsze było zepsute”.
- **Zmierz wydajność obecnego rozwiązania**: przepustowość, pamięć, rozmiar pliku binarnego lub pakietu, opóźnienia — identyczne obciążenie, identyczny sprzęt, zapisane wyniki. „Wydaje się szybsze” nie jest dowodem.
- **Policz testy**: zapisz obecną łączną liczbę asercji; warunek zakończenia przebudowy musi potwierdzać, że żadnej nie pominięto, nie osłabiono ani nie usunięto.

## 2. Testy są kontraktem — zachowaj ich niezależność od implementacji

Zestaw testów NIE może być napisany w zastępowanym rozwiązaniu ani z nim ściśle powiązany. Testy niezależne od języka (na przykład testy TypeScript korzystające z interfejsu CLI/API) pozwalają bezpiecznie wymienić silnik działający pod spodem. Jeśli zestaw jest ściśle powiązany, NAJPIERW go rozdziel — to faza 0, a nie zbędny narzut.

## 3. Najpierw mechanicznie, później idiomatycznie

Tłumacz 1:1 — „jak po transpilacji” — zachowując architekturę, nazwy i strukturę. Refaktoryzuj w kierunku idiomatycznych wzorców dopiero PO potwierdzeniu równoważności. Dwie transformacje naraz (portowanie i przeprojektowanie) sprawiają, że przyczyna każdej awarii jest niejednoznaczna. Jednorazowa pełna migracja jest lepsza od stopniowej, gdy tymczasowy kod pomostowy pozostałby zbyt długo; migracja stopniowa jest lepsza, gdy system musi być wydawany co tydzień — wybierz świadomie i zapisz decyzję.

## 4. Próba przed uruchomieniem na dużą skalę

Przeportuj od początku do końca 3 reprezentatywne pliki, wykonując PEŁNY cykl (tłumaczenie -> kompilacja -> krytyczny przegląd -> testy), zanim przejdziesz do setek. Próba pozwala skalibrować polecenia, listy kontrolne przeglądu i kolejkę pracy; skalowanie wadliwego procesu skaluje liczbę błędów.

## 5. Kompilator lub kontroler typów jako kolejka pracy

Kieruj pracą na podstawie uszeregowanych sygnałów mechanicznych, takich jak błędy `cargo check` lub `tsc`.
Bez delegowania pracuj sekwencyjnie pod nadzorem jednej osoby. Po jawnym delegowaniu lub
`/swarm` wydziel niezależne ścieżki w osobnych drzewach roboczych; każda ścieżka zatwierdza wyłącznie przypisany jej zakres
i nigdy nie odkłada zmian na stos, nie resetuje ani nie edytuje innej ścieżki.

## 6. Krytyczny przegląd ze świeżym kontekstem

Osoba wdrażająca korzysta z pełnego kontekstu bazy kodu; przegląd rozpoczyna się od różnic i ich
kontraktu, przy założeniu, że translacja może być błędna. W przypadku nietrywialnego PR-u lub końcowego etapu wydania użyj
dozwolonego w repozytorium przeglądu między modelami na pierwszym planie. W przeciwnym razie wykonaj przegląd bezpośrednio,
ponownie zbierając dowody od początku.

## 7. Pułapki równoważności semantycznej

Konstrukcje wyglądające identycznie różnią się między stosami technologicznymi. Celowo szukaj: konstrukcji asercji i debugowania, które usuwają efekty uboczne w kompilacjach produkcyjnych, różnic w przepełnieniu liczb całkowitych i sprawdzaniu granic, domyślnej semantyki kopiowania względem referencji, limitów rekurencji i stosu (testuj patologicznie zagnieżdżone dane wejściowe o głębokości tysięcy poziomów) oraz domyślnych ustawień regionalnych i kodowania. Każda znaleziona pułapka staje się przypadkiem testowym, a nie notatką.

## 8. Naprawiaj proces, nie wynik

Gdy wykonawca tworzy wadliwy kod, nie poprawiaj go ręcznie — popraw polecenie, listę kontrolną lub kolejkę, które do tego doprowadziły, i uruchom proces ponownie. Ręczne poprawki przestają się skalować po dziesiątym pliku; poprawki procesu pomagają przy pozostałym tysiącu. Rola człowieka: czytać raporty walidacji, wykonywać kontrole wyrywkowe, sprawdzać, czy testy nie zostały pominięte w CI, i zatwierdzić scalenie.

## Warunki zakończenia

- [ ] Wszystkie testy sprzed przebudowy przechodzą, zero pominiętych lub usuniętych (porównaj liczbę asercji)
- [ ] Wyniki testów wydajności dorównują zapisanym pomiarom bazowym lub je przewyższają przy tym samym obciążeniu i sprzęcie
- [ ] Rejestr błędów został sklasyfikowany: każda istniejąca wcześniej usterka jest nadal śledzona, brak nowych klas regresji
- [ ] Każda różnica przeszła krytyczny przegląd (między modelami zgodnie z CLAUDE.md)
- [ ] Procedura wycofania jest udokumentowana: stara implementacja pozostaje gotowa do wydania do czasu spełnienia warunków
