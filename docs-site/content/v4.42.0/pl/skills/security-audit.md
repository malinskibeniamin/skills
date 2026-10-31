---
description: Używaj do pytań o bezpieczeństwo opartych na kodzie źródłowym, badania podatności, ukierunkowanych przeglądów bezpieczeństwa oraz jawnie zamówionych audytów kodu i testów penetracyjnych. Nie służy do skanowania zależności ani jako obowiązkowy etap ogólnego przeglądu.
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - security audit
sidebar:
  label: /security-audit
title: /security-audit
type: skill
---
![Diagram umiejętności /security-audit](/diagrams/skills/security-audit.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/security-audit.excalidraw)

Zastosuj poniższe reguły środowiska, a następnie przeczytaj całą [umiejętność upstream](https://github.com/malinskibeniamin/skills/blob/v4.42.0/vendor/cloudflare-security-audit/skills/security-audit/SKILL.md).

- Jako **katalog umiejętności** przyjmij katalog nadrzędny pliku upstream, a nie
  tego adaptera ani proxy Codex. Względem niego ustalaj ścieżki do przewodników,
  schematu i walidatorów.
- Domyślnie udzielaj wskazówek do konkretnych pytań i przeglądów. Jawne zlecenia
  audytu kodu, testów penetracyjnych, kompleksowego przeglądu lub raportu wymagają
  sześciofazowego procesu i zachowania jego artefaktów.
- Delegowanie wymaga jawnej zgody użytkownika; samo zlecenie audytu jej nie oznacza.
  Bez zgody lub narzędzi do delegowania udzielaj wskazówek bezpośrednio, wyłącznie
  na podstawie źródeł. Ujawnij częściowy zakres analizy; nie przedstawiaj go jako
  pełnego audytu ani niezależnej weryfikacji. Uzyskaj zgodę przed pełnym przebiegiem.
  Zachowaj wybór modelu i budżety środowiska.
- Zachowaj zabezpieczenia piaskownicy upstream, wyłącznie lokalny zakres, dane
  fikcyjne, izolację zapisów, bramki dowodowe i walidatory. Brak zabezpieczeń
  wykonania oznacza analizę źródeł i blokadę wymagającą weryfikacji, a nie wykonanie
  badanego kodu poza piaskownicą ani sondowanie działających systemów. Audyt opisuje
  poprawki; wdrażaj je tylko na żądanie.

[Pochodzenie i aktualizacja](https://github.com/malinskibeniamin/skills/blob/v4.42.0/security-audit/CREDITS.md). Instalacja nie włącza hooka audytu,
pracy w tle ani automatycznej ścieżki przeglądu bezpieczeństwa.
