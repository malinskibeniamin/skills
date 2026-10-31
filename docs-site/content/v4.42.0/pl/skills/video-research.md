---
title: /video-research
description: >-
  Przekształca adresy URL filmów, załączniki wideo lub pliki lokalne w
  transkrypcje ze znacznikami czasu, wyniki OCR i materiały gotowe do analizy.
  Używaj podczas analizowania, streszczania, cytowania lub pozyskiwania dowodów
  z filmów.
type: skill
sidebar:
  label: /video-research
---
![Diagram umiejętności /video-research](/diagrams/skills/video-research.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/video-research.excalidraw)

Przed analizą tez filmu przekształć go w materiał, który można przeszukiwać. Jeśli użytkownik podał już film jako źródło do analizy, rozpocznij bez dodatkowego potwierdzenia.

## Pozyskiwanie

1. Ustal dostępny adres URL źródła lub bezwzględną ścieżkę lokalnego załącznika. Korzystaj wyłącznie z multimediów, do których użytkownik ma dostęp. Poproś o zgodę przed odczytaniem plików cookie przeglądarki lub przekroczeniem innej granicy uwierzytelniania.
2. Wybierz nieśledzony katalog wyjściowy. Preferuj `.context/video-research/<slug>/`, jeśli `.context` jest ignorowany przez Git. W przeciwnym razie pozwól skryptowi utworzyć katalog tymczasowy.
3. Uruchom dołączony punkt wejścia z bezwzględnego katalogu tej umiejętności:

```bash
bash <skill-dir>/scripts/analyze-video.sh \
  --output-dir <untracked-output-dir> \
  <video-url-or-path>
```

Punkt wejścia w pierwszej kolejności korzysta z natywnych napisów, następnie używa lokalnego Whispera, pobiera kluczowe klatki, wykonuje OCR tekstu widocznego na ekranie oraz zapisuje pliki `analysis.json`, `transcript.txt` i `research.md`. Używa przypiętych wersji narzędzi uruchamianych jednorazowo i przy pierwszym użyciu może pobrać model lokalny. Informuj użytkownika o postępie. Nie dodawaj tych środowisk wykonawczych do plików zależności docelowego projektu.

Jeśli język jest znany, przekaż `--language <code>`. W przypadku trudnego nagrania użyj `--model medium`, a dla nieangielskiego tekstu widocznego na ekranie — `--ocr-language <codes>`. Domyślnie transkrypcja odbywa się wyłącznie lokalnie. Usługa transkrypcji w chmurze wymaga wyraźnej zgody, ponieważ przesyła dźwięk i może generować koszty.

## Analiza

Najpierw przeczytaj `research.md`, a następnie przejrzyj `analysis.json` i wskazane klatki, aby poznać kontekst. Traktuj wyniki ASR i OCR jako dowody pochodne. Przed zacytowaniem istotnego fragmentu zweryfikuj jego brzmienie na podstawie znacznika czasu i klatki. Łącz transkrypcję, tekst widoczny na ekranie, materiały wizualne, opis, rozdziały i podlinkowane źródła pierwotne. Sama wypowiedź może pomijać najważniejsze dowody przedstawione w filmie.

Trwałe ustalenia pochodzące z wielu źródeł przekazuj z powrotem przez `/research`, cytując oryginalny film ze znacznikami czasu, zamiast traktować wygenerowaną transkrypcję jako niezależne źródło.

## Zasady obsługi błędów

Wyświetl każde ostrzeżenie analizatora. Brak transkrypcji spowodowany niedostępnością mechanizmu rozpoznawania mowy jest błędem, a nie pustą treścią. Zainstaluj brakujące środowisko wykonawcze w tymczasowej pamięci podręcznej i uruchom analizę ponownie. Odróżnij taki przypadek od filmu rzeczywiście pozbawionego dźwięku, a następnie użyj OCR i klatek. W przypadku multimediów prywatnych, usuniętych, chronionych przez DRM lub niedostępnych zgłoś ograniczenie dostępu i poproś o dostępny plik. Nie omijaj zabezpieczeń.
