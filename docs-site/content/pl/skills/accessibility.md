---
title: /accessibility
description: >-
  Dostępność w React: ARIA, obsługa klawiatury, fokus, formularze i zagnieżdżone
  kontrolki. Używaj podczas tworzenia interaktywnych komponentów lub usuwania
  problemów z dostępnością.
type: skill
sidebar:
  label: /accessibility
---
![Diagram umiejętności /accessibility](/diagrams/skills/accessibility.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/accessibility.excalidraw)

## Co jest wykrywane

Egzekwowanie reguł jest podzielone między trzy mechanizmy — każda reguła ma jednego właściciela:

- **Biome (preset ultracite)** — reguły dotyczące pojedynczych elementów: tekst alternatywny `<img>` (`a11y/useAltText`), obsługa klawiatury dla klikalnych elementów `<div>`/`<span>` (`a11y/useKeyWithClickEvents` i pokrewne), wymagane atrybuty ARIA dla pola kombi (`a11y/useAriaPropsForRole`), powiązanie etykiety (`a11y/noLabelWithoutControl`)
- **React Doctor (hook Stop)** — reguły strukturalne: dostępna nazwa okna dialogowego (`react-doctor/dialog-has-accessible-name`), zagnieżdżone elementy interaktywne (`react-doctor/html-no-nested-interactive`), zbędne określenia w nazwach, takie jak `Search icon` (`react-doctor/img-redundant-alt`), użycie symbolu zastępczego jako etykiety (`react-doctor/label-has-associated-control`) oraz nieprawidłowe kontrolki bez opisu błędu (`react-doctor/no-aria-invalid-without-description`)
- **Ten hook** — tylko powiązania między atrybutami, których nie obsługuje żaden z pozostałych mechanizmów: `role="tablist"` wymaga elementu potomnego z `role="tab"`; `data-invalid` (wyłącznie CSS) wymaga `aria-invalid`

Wyłączenie reguły: `// allow: a11y-skip [reason]`

## Bez zagnieżdżonych elementów klikalnych

Dla komponentów interaktywnych stosuj JEDEN wzorzec — nigdy oba:

**Wzorzec A: Klikalny kontener** — bez interaktywnych elementów potomnych.
```tsx
<ListCard onClick={handleSelect}>
  <Avatar src={user.avatar} />
  <Text>{user.name}</Text>
  <ChevronRightIcon /> {/* visual indicator only, not a button */}
</ListCard>
```

**Wzorzec B: Interaktywne elementy potomne** — kontener nie jest klikalny.
```tsx
<ListCard>
  <Avatar src={user.avatar} />
  <Text>{user.name}</Text>
  <DropdownMenu>
    <DropdownMenuTrigger asChild>
      <Button variant="ghost" size="icon"><MoreVerticalIcon /></Button>
    </DropdownMenuTrigger>
  </DropdownMenu>
</ListCard>
```

Dlaczego: niejednoznaczne cele kliknięć, błędy propagacji zdarzeń, brak możliwości przekazania modelu interakcji przez czytniki ekranu oraz nakładające się obszary dotykowe na urządzeniach mobilnych.

## Dostępne nazwy i opisy

- Preferuj widoczny tekst i natywne mechanizmy nadawania nazw (`<label>`, treść przycisku lub linku, podpisy) zamiast
  ARIA. Używaj `aria-label` tylko wtedy, gdy nie ma widocznej nazwy, na przykład w przycisku zawierającym wyłącznie ikonę;
  `aria-label` lub `aria-labelledby` mogą zastąpić tekst elementów potomnych w drzewie dostępności.
- Dbaj o aktualność odwołań `aria-describedby`. Usuń nieaktualny identyfikator błędu po pomyślnym
  przejściu walidacji; ukryta treść wskazywana przez odwołanie nadal może stać się dostępnym opisem.
- Sprawdź obliczone drzewo dostępności, gdy zachowanie nazw lub opisów jest niejasne.
  Postępuj zgodnie z [wytycznymi WAI-ARIA dotyczącymi nadawania nazw](https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/).

## Lista kontrolna warstwy wizualnej

- [ ] Wskaźniki fokusu są widoczne na wszystkich elementach interaktywnych (minimum 2 px, kontrastowy kolor)
- [ ] Style najechania i fokusu są spójne (brak wskazówek dostępnych tylko dla myszy)
- [ ] Kolor nie jest jedynym sposobem przekazywania informacji
- [ ] Kolejność w DOM odpowiada kolejności czytania i przechodzenia klawiszem Tab; wizualna zmiana kolejności za pomocą CSS jest poparta testami klawiatury i czytnika ekranu
- [ ] Dostępne nazwy odpowiadają widocznemu celowi i działaniu; bez nazw „ikona”, „przycisk” ani „obraz”
- [ ] Pola formularzy mają trwałe etykiety; symbol zastępczy zawiera tylko przykłady lub wskazówki dotyczące formatu
- [ ] Okna dialogowe, panele i wyskakujące elementy zatrzymują fokus, przywracają go po zamknięciu oraz wyłączają interakcję z tłem w trybie modalnym
- [ ] Stany błędu, zaznaczenia, ostrzeżenia i sukcesu nigdy nie opierają się wyłącznie na kolorze; kolor jest uzupełniony tekstem, ikoną lub kształtem
- [ ] Obszary dotykowe mają co najmniej 44 × 44 piksele CSS
- [ ] Animacje respektują `prefers-reduced-motion`
- [ ] Przy ograniczonym ruchu kluczowe informacje zwrotne są przekazywane przez krycie, kolor, tekst lub natychmiastowe zmiany stanu zamiast dużych przemieszczeń
- [ ] Efekty dostępne tylko po najechaniu są ograniczone na urządzeniach dotykowych za pomocą `@media (hover: hover) and (pointer: fine)`
- [ ] Mobilne szuflady i panele obsługują klawiatury wirtualne za pomocą `visualViewport`, odstępy obszaru bezpiecznego, pułapkę fokusu, przywracanie fokusu i wyłączenie interakcji z tłem
- [ ] Interakcje mobilne wysokiego ryzyka są przetestowane na urządzeniu fizycznym lub w symulatorze, zwłaszcza szuflady, panele, gesty przesunięcia i przytrzymanie uruchamiające działania destrukcyjne
- [ ] Tryb `forced-colors` / wysokiego kontrastu: wypełnienia SVG używają `currentcolor`
- [ ] Tekst można powiększyć do 200% bez utraty treści

Konfiguracja początkowa (instalacja, fixture AXE, konfiguracja hooka): zobacz [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/accessibility/SETUP.md).
