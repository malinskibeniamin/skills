---
title: /read-the-damn-docs
description: >-
  Sprawdź bieżące działanie w dokumentacji źródłowej. Używaj w przypadku
  zewnętrznych API, bibliotek, narzędzi CLI, usług chmurowych, zmian API,
  uwierzytelniania, rozliczeń, bezpieczeństwa, migracji lub wdrożeń.
type: skill
sidebar:
  label: /read-the-damn-docs
---
![Diagram umiejętności /read-the-damn-docs](/diagrams/skills/read-the-damn-docs.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/read-the-damn-docs.excalidraw)

Przeczytaj `references/builder-upstream.md`, aby poznać pełną listę warunków uruchomienia podejścia opartego najpierw na dokumentacji.

Nie zgaduj, jeśli odpowiedź można znaleźć w wiarygodnej dokumentacji. To szybka ścieżka weryfikacji oficjalnych informacji, zazwyczaj bez tworzenia materiału badawczego. Gdy użytkownik potrzebuje trwałego raportu z cytowaniami lub syntezy wielu źródeł, przekaż zadanie wbudowanej umiejętności deep-research, a następnie zapisz ustalenia w pliku Markdown w miejscu, w którym repozytorium przechowuje już takie notatki (lub w sensownej lokalizacji, wskazując ją).

## Wymagany proces

1. Określ dokładny obszar: pakiet, wersję, punkt końcowy, CLI, konfigurację, lokalną funkcję pomocniczą, schemat lub działanie produktu.
2. Najpierw przeczytaj lokalną dokumentację repozytorium, specyfikacje, ADR-y i wygenerowane typy, jeśli definiują kontrakt.
3. W przypadku zewnętrznych lub szybko zmieniających się rozwiązań przeszukaj aktualną oficjalną dokumentację i otwórz odpowiednią dokumentację API, przewodnik migracji, dziennik zmian, informacje o wydaniu, kod źródłowy SDK lub definicje typów.
4. Wyodrębnij tylko potrzebne informacje: nazwy opcji, importy, reguły cyklu życia, wartości domyślne, zmiany niezgodne wstecznie, limity, uprawnienia i przykłady.
5. Zastosuj dokumentację do kodu. Nie kopiuj bezrefleksyjnie przykładów sprzecznych ze wzorcami repozytorium.
6. Cytuj źródła w notatkach badawczych lub odpowiedzi końcowej, gdy istotne są informacje z dokumentacji.

## Wyraźne warunki uruchomienia

- Użytkownik mówi: najnowsze, aktualne, oficjalne, obsługiwane, najlepsza praktyka, dzisiaj, teraz lub sprawdź to.
- Dodawanie, aktualizowanie, konfigurowanie lub importowanie pakietów, SDK, modeli, dostawców, wtyczek lub narzędzi CLI.
- Błędy wskazują na wycofane funkcje, nieznane opcje, brakujące eksporty, nieprawidłową konfigurację, nieobsługiwane pola lub niezgodność wersji.
- Decyzje są kosztowne do odwrócenia: publiczne formaty komunikacji, schemat bazy danych, trwałe identyfikatory, nazwy zdarzeń, działanie widoczne dla klientów, zewnętrzna automatyzacja.
- Zadanie dotyczy uwierzytelniania, zakresów OAuth, sekretów, webhooków, danych osobowych, szyfrowania, przechowywania danych, migracji, ponownych prób, limitów częstotliwości, przydziałów, rozliczeń lub działania wdrożeń.
