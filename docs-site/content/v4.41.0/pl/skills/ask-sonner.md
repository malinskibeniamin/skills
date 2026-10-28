---
description: "Konfiguruj, stylizuj lub diagnozuj powiadomienia Sonner w React: położenie Toastera, cykle promise/loading, duplikaty, motyw, portale i własną treść."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["ask sonner"]}
sidebar: {"label":"/ask-sonner"}
title: "/ask-sonner"
type: "skill"
---
![Diagram umiejętności /ask-sonner](/diagrams/skills/ask-sonner.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/ask-sonner.excalidraw)

Używaj zainstalowanej wersji Sonner i obecnej nakładki systemu projektowego.
Adaptacja umiejętności Emila Kowalskiego; [pochodzenie](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/EMIL-SKILLS-CREDITS.md).
Przed użyciem właściwości lub wartości zwracanych zależnych od wersji przeczytaj zainstalowane typy
oraz aktualną [oficjalną dokumentację](https://sonner.emilkowal.ski); to wskazówki, nie zamrożona specyfikacja API.

## Integracja

- Użyj nakładki Toaster projektu, zwykle w `@/components/ui/`. Zamontuj ją raz w stabilnym
  korzeniu aplikacji, poza przodkami przycinającymi lub tworzącymi kontekst warstw. Dodatkowe Toastery
  wymagają obsługiwanego, jawnego sposobu adresowania; nie zakładaj istnienia właściwości multi-toaster.
- Wywołuj `toast` po stronie klienta na granicy operacji. Kod serwera zwraca wynik;
  klient go ogłasza. Preferuj wyniki zdarzeń/mutacji zamiast efektów ubocznych renderowania lub efektów Reacta.
- Dla wyników używaj success/error/info/warning; do ręcznego cyklu życia `toast.loading`
  ze stałym id, a dla faktycznie kończącego się promise używaj `toast.promise`.
  Wzorce aktualizacji, zamykania i obsługi błędów znajdziesz w [RECIPES.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/ask-sonner/RECIPES.md).
- Ważny stan błędu i odzyskiwania pokazuj również stale w interfejsie, nie tylko w chwilowym powiadomieniu.
  Ładowanie, optymistyczny start i połknięte odrzucenie nie oznaczają sukcesu.

## Diagnoza

| Objaw | Co sprawdzić przed zmianą |
|---|---|
| Brak powiadomienia | Czas życia Toastera, wywołanie klienta, docelowe id, jeśli obsługiwane |
| Duplikaty | Wiele Toasterów lub powtarzane efekty; stałe id operacji |
| Wieczne ładowanie | Nierozstrzygnięty promise, pominięte catch/finally, nieskończony czas wyświetlania |
| Niewłaściwy motyw | Rozwiązany motyw przekazany przez istniejącego dostawcę/nakładkę |
| Za dialogiem/przycięte | Umieszczenie portalu, transform/filter/overflow przodka, warstwy |
| Brak stylów | Eksport CSS zainstalowanego pakietu i cykl arkuszy stylów frameworka |
| Ignorowane klasy | Kaskada/warstwy i konfiguracja nakładki; poprawka w jej właścicielu |
| Nakładanie na telefonie | Obsługiwane przesunięcia, bezpieczny obszar, klawiatura i położenie |

## Styl i weryfikacja

Najpierw używaj wariantów/tokenów nakładki; poprawiaj specyficzność u źródła zamiast rozrzucać
`!important`. Rozważ `unstyled` lub `toast.custom` tylko wtedy, gdy zainstalowane API obsługuje
potrzebne zachowanie. Własne kontrolki używają Button/Link projektu i dostępnych etykiet;
treść headless nie zapewnia automatycznie semantyki.

Sprawdź, że jedna operacja daje jedno powiadomienie, poprawnie kończy się sukcesem/odrzuceniem,
pozwala się zamknąć i pozostaje użyteczna z klawiaturą, komunikatami czytnika ekranu, ograniczonym ruchem,
motywami i dialogami. Sprawdź też trwałą ścieżkę błędu. Wyjaśnienie/przegląd kończy się ustaleniami;
tworzenie/poprawka prowadzi przez testy projektu i bramki dostarczania.
