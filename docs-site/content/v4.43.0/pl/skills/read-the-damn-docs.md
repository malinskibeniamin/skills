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


Przeczytaj `references/builder-upstream.md`, aby poznać pełną listę warunków uruchomienia. To szybka ścieżka weryfikacji oficjalnych informacji bez tworzenia materiału badawczego. Do trwałych raportów opartych na wielu źródłach używaj wbudowanej umiejętności deep-research i zapisuj Markdown z cytowaniami w miejscu, w którym repozytorium przechowuje takie notatki.

## Proces [#workflow]

1. Określ dokładny pakiet, wersję, punkt końcowy, CLI, konfigurację, funkcję pomocniczą, schemat lub obszar produktu.
2. Najpierw przeczytaj lokalną dokumentację, specyfikacje, ADR-y i wygenerowane typy, jeśli definiują kontrakt.
3. W przypadku zewnętrznych lub szybko zmieniających się rozwiązań przeszukaj aktualną oficjalną dokumentację; otwórz dokumentację API, przewodnik migracji, informacje o wydaniu, dziennik zmian, kod źródłowy SDK lub definicje typów.
4. Wyodrębnij importy, opcje, wartości domyślne, zmiany niezgodne wstecznie, limity, uprawnienia i przykłady.
5. Zastosuj ustalenia zgodnie ze wzorcami repozytorium; nigdy nie kopiuj bezrefleksyjnie przykładów.
6. Cytuj źródła informacji wpływających na notatki lub odpowiedzi. Oznacz wszystko, czego nie udało się potwierdzić, i wskaż, gdzie szukano.

## Wyraźne warunki uruchomienia [#strong-triggers]

- Najnowsze, aktualne, oficjalne, obsługiwane, najlepsza praktyka, dzisiaj, sprawdź to.
- Instalowanie, aktualizowanie, konfigurowanie lub importowanie pakietów, SDK, modeli, dostawców, wtyczek lub narzędzi CLI.
- Wycofane funkcje, nieznana opcja, brakujący eksport, nieprawidłowa konfiguracja, nieobsługiwane pole, niezgodność wersji.
- Trudne do zmiany formaty komunikacji, schematy, trwałe identyfikatory, zdarzenia, działanie widoczne dla klientów, automatyzacja.
- Uwierzytelnianie/OAuth, sekrety, webhooki, dane osobowe, szyfrowanie, przechowywanie danych, migracje, ponowne próby, limity częstotliwości i przydziały, rozliczenia, wdrożenia.
