---
title: /writing-for-agents
description: >-
  Pisanie dokumentów dla agentów. Używaj podczas tworzenia lub edytowania
  umiejętności albo modyfikowania plików AGENTS.md lub CLAUDE.md.
type: skill
sidebar:
  label: /writing-for-agents
---
![Diagram umiejętności /writing-for-agents](/diagrams/skills/writing-for-agents.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/writing-for-agents.excalidraw)

Materiał referencyjny dotyczący każdego dokumentu używanego przez agenta: umiejętności, `AGENTS.md`, `CLAUDE.md` lub dokumentu wskazanego przez odnośnik. Sposób pakowania jest różny, ale zasady pisania pozostają takie same. Celem jest przewidywalny proces, a nie identyczny rezultat.

Podczas pisania umiejętności przeczytaj [SKILL-MECHANICS.md](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md), aby poznać zasady frontmatter, wyboru sposobu wywołania i routerów.

## Wskaźniki kontekstu

**Wskaźnik kontekstu** to wczytywany tekst, który wskazuje materiał spoza kontekstu i określa, kiedy należy do niego sięgnąć. Opis umiejętności i wiersz w `AGENTS.md` wskazujący inny dokument są tym samym obiektem. To sformułowanie, a nie cel, decyduje o tym, czy agent będzie niezawodnie korzystać ze wskazanego materiału.

Wskaźnik określa, czym jest materiał, oraz wskazuje odrębne **gałęzie**, które powodują jego wczytanie. Ponieważ zawsze wczytywany wskaźnik zużywa tokeny i uwagę w każdej turze:

- Zacznij od mocnego słowa przewodniego.
- Zachowaj jeden wyzwalacz na gałąź; synonimy dotyczące jednej gałęzi są powtórzeniem.
- Usuń informacje identyfikacyjne zawarte już w dokumencie docelowym.

Doprecyzuj słaby wskaźnik, zanim umieścisz jego cel bezpośrednio w dokumencie.

## Dwa rodzaje obciążenia

- **Obciążenie kontekstu** -- zawsze wczytywany materiał, który zużywa tokeny i uwagę w każdej turze.
- **Obciążenie poznawcze** -- to, o czym człowiek musi pamiętać: co istnieje i kiedy należy to wywołać.

Materiał za wskaźnikiem nie powoduje obciążenia kontekstu na poziomie treści dokumentu, ale kosztem jest wiersz wskaźnika. Materiał bez wskaźnika opiera się całkowicie na ludzkiej pamięci. Obciążenie poznawcze jest ceną ludzkiej sprawczości, a nie wartością, którą należy bezrefleksyjnie minimalizować.

## Hierarchia informacji

Dokumenty łączą dwa typy treści: **kroki**, czyli uporządkowane działania wykonywane przez agenta, oraz **materiały referencyjne**, czyli reguły i fakty, z których korzysta. Umieść każdy element na najpłytszym uzasadnionym poziomie:

1. **Krok w pliku** -- podstawowe uporządkowane działanie.
2. **Materiał referencyjny w pliku** -- bezpośrednio przydatny materiał pomocniczy.
3. **Udostępniony materiał referencyjny** -- inny plik wczytywany przez wskaźnik kontekstu.

**Stopniowe ujawnianie** przenosi materiał w dół tej drabiny. Umieść bezpośrednio to, czego potrzebuje każda gałąź; udostępniaj przez wskaźniki to, czego potrzebują tylko niektóre gałęzie. Materiał referencyjny, który ukrywa obowiązkowe kroki, jest źródłem rozbieżności, a nie tylko długim dokumentem.

**Kolokacja** utrzymuje definicję pojęcia, jego reguły i zastrzeżenia razem po wybraniu odpowiedniego poziomu. Rozproszenie rozbija jedno znaczenie na fragmenty; duplikacja je powtarza.

## Kroki i kryteria ukończenia

Każdy krok kończy się **kryterium ukończenia**:

- **Jasność** -- czy agent potrafi odróżnić stan ukończony od nieukończonego? Niejasne granice sprzyjają przedwczesnemu zakończeniu.
- **Wymaganie** -- czy kryterium wymaga uwzględnienia każdego istotnego elementu, czy jedynie prosi o listę?

Najpierw doprecyzuj granicę. Jeśli krok, którego nie da się precyzyjnie określić, nadal jest wykonywany zbyt pospiesznie, podziel sekwencję w rzeczywistym miejscu zmiany kontekstu, aby późniejsze kroki przestały odciągać uwagę do przodu. Wymaganie określa nakład pracy agenta bez potrzeby dodawania osobnej instrukcji „pracuj dokładnie”.

## Kiedy dzielić

Podziel sekwencję tylko wtedy, gdy widoczne kroki następujące po ukończeniu powodują przedwczesne kończenie pracy. Podziały wywołań specyficzne dla umiejętności opisano w [SKILL-MECHANICS.md](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md).

## Słowa przewodnie

**Słowo przewodnie** to zwarte, wstępnie wyuczone pojęcie, którym agent się posługuje, takie jak _tracer bullet_, _frontier_ lub _red_. Zastępuje ono powtarzające się objaśnienia i stanowi punkt odniesienia zarówno dla wykonania opisanego w treści, jak i wywołania przez wskaźnik. Preferuj istniejące słowo zamiast nowego terminu, który wymagałby własnej definicji.

Wyszukuj powtarzające się frazy, które można zastąpić jednym mocnym słowem. Zyskiem jest mniejsza liczba tokenów i precyzyjniejszy mechanizm wyszukiwania.

**Negacja** jest powiązanym źródłem błędów: zakaz aktywuje zachowanie, które nazywa. Zamiast tego wskaż **pozytywny** cel. Zachowaj zakaz tylko wtedy, gdy jest bezwzględnym zabezpieczeniem, którego nie da się sformułować pozytywnie, i połącz go ze wskazaniem właściwego działania.

## Przycinanie

- Zachowaj każde znaczenie w jednym źródle prawdy. Duplikacja zwiększa jego eksponowanie i koszt utrzymania.
- Traktuj środowisko jako źródło prawdy: skrypty, konfiguracja, układ i `--help` już odpowiadają na proste pytania. Dokument jest pamięcią podręczną; zachowuj go tylko dla kosztownych wyszukiwań, niepisanych konwencji, uzasadnień i ukrytych pułapek.
- Sprawdzaj każdy wiersz pod kątem istotności. Nieprzycinane dokumenty gromadzą nieaktualne osady.
- Wyszukuj instrukcje bez efektu, zdanie po zdaniu. Jeśli instrukcja nie zmienia domyślnego zachowania modelu, usuń zdanie zamiast je dopracowywać.
- Traktuj rozrost jako błąd hierarchii informacji: ujawniaj treść według gałęzi lub podziel rzeczywiście pospiesznie wykonywaną sekwencję.
