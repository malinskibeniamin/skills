---
description: "Twórz szkielety ładowania dla treści asynchronicznych, oczekujących tras i migoczących elementów zastępczych. Używaj, aby dopasować układ lub zapobiec przesunięciom podczas pobierania danych."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["skeleton loaders"]}
sidebar: {"label":"/skeleton-loaders"}
title: "/skeleton-loaders"
type: "skill"
---
![Diagram umiejętności /skeleton-loaders](/diagrams/skills/skeleton-loaders.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/skeleton-loaders.excalidraw)

## Dopasuj treść

Traktuj poniższe fragmenty jako szablony. Sprawdź rzeczywisty komponent i zainstalowane
narzędzia stylowania; dostosuj importy, tokeny, tłumaczenia i ścieżki do repozytorium.

1. Wykorzystaj istniejący komponent szkieletu i konwencje ładowania, jeśli pasują.
2. Skopiuj kontenery, odstępy, breakpointy, obramowania i typografię gotowego widoku.
   Zachowaj typy elementów, wysokość linii, rozmiar i grubość fontu, zawijanie i ucinanie tekstu.
3. W przezroczystych elementach tekstowych używaj tych samych wartości `t()` dla stałych
   etykiet. Dla nieznanych danych użyj reprezentatywnych tekstów i realistycznej liczby linii.
   Typografia odtwarza znaną geometrię; szerokość i zawijanie nieznanego tekstu są przybliżone.
   Elementy blokowe nadal wypełniają kontener, chyba że gotowy układ określa inaczej.
4. Zarezerwuj miejsce na obrazy, ikony i awatary według rzeczywistych wymiarów lub proporcji.
   Jawne rozmiary stosuj do tych miejsc, nie do zgadywanych prostokątów tekstowych `h-*` / `w-*`.

## Zdefiniuj shimmer raz

Wykorzystaj istniejącą animację, zanim dodasz nową. Dla **Tailwind v4** znajdź arkusz
właściciela motywu i dodaj brakujący token oraz klatki do jego istniejącego bloku `@theme`:

```css
@theme {
  --animate-shimmer: shimmer 2s linear infinite;
  @keyframes shimmer {
    from { background-position: 100% 0; }
    to { background-position: -100% 0; }
  }
}
```

`animate-shimmer` jest klasą niestandardową, nie wbudowaną. Dla innych wersji użyj konfiguracji
animacji projektu; sprawdź wygenerowany CSS i lintowanie klas. Przy ograniczonym ruchu
zachowaj statyczne, stonowane tło. Współdziel ciąg klas wewnątrz komponentu:

```tsx
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

const shimmer =
  "motion-safe:animate-shimmer rounded-sm bg-muted bg-linear-to-r from-muted via-accent to-muted bg-size-[200%_100%] text-transparent select-none";

export function ProfileSkeleton({ heading, actionLabel }: {
  heading: string;
  actionLabel: string;
}) {
  return (
    <div aria-hidden="true" className="border border-border bg-card p-3">
      <h2 className={cn("text-lg font-bold", shimmer)}>{heading}</h2>
      <div className="flex items-center gap-3">
        <div className={cn("size-14 shrink-0", shimmer)} />
        <div className="min-w-0 flex-1">
          <p className={cn("truncate text-sm font-semibold", shimmer)}>Name</p>
          <p className={cn("truncate text-xs", shimmer)}>Example value</p>
        </div>
      </div>
      <Button disabled type="button" className={cn("w-full", shimmer)}>
        {actionLabel}
      </Button>
    </div>
  );
}
```

Przekaż przetłumaczony nagłówek i etykietę akcji gotowego komponentu. Dopasuj rzeczywisty
wariant, rozmiar i klasy Button; usuń klasy koloru tekstu nadpisujące przezroczystość.
Kontrolki zastępcze muszą być wyłączone, bez obsługi zdarzeń ani celów nawigacji;
samo `tabIndex={-1}` nie zapobiega aktywacji. Ukryj korzeń szkieletu przed technologiami
asystującymi. Na trwałym regionie treści ustaw `aria-busy` podczas oczekiwania i wyczyść
je po sukcesie lub błędzie. Jeśli ogłaszasz ładowanie, umieść jeden zlokalizowany
`role="status"` poza ukrytym/zajętym poddrzewem, aby komunikat nie został wstrzymany.

## Opóźnienie bez przesunięcia układu

Preferuj istniejący mechanizm opóźnienia stanu oczekiwania routera lub zapytania. Około
**200 ms** to punkt wyjścia, nie obowiązkowe czekanie: pokazuj dostępne dane natychmiast,
a podczas odświeżania w tle zachowuj poprzednią treść. Gdy danych brak, rezerwuj geometrię
gotowego regionu przez całe opóźnienie zamiast zwracać `null` bez zarezerwowanego miejsca.

Jeśli potrzebny jest lokalny timer, montuj komponent opóźnienia tylko dla danej operacji;
użyj nazwanego efektu i wyczyść timer przy odmontowaniu. Montuj ponownie lub resetuj dla
każdej nowej operacji, także gdy zmienia się tożsamość żądania podczas oczekiwania.
Anuluj zaplanowane pokazanie przy zakończeniu, anulowaniu lub błędzie; pokaż błąd albo
pusty stan zamiast nieskończonego ładowania.

## Zweryfikuj podmianę

Porównaj widoki ładowania i gotowej treści przy tym samym rozmiarze okna, foncie, języku
i motywie, także z długim tekstem i wąskim układem. Sprawdź granice regionu podczas
opóźnienia i podmiany; deklaruj idealne dopasowanie tylko dla rzeczywiście porównanej
geometrii. Sprawdź szybkie i wolne ładowanie, powtarzaną nawigację, anulowanie/odmontowanie,
odświeżanie w tle, powrót z pustego stanu i błędu, fokus klawiatury oraz ograniczony ruch.
W testach opóźnienia używaj sztucznych timerów, nie rzeczywistego czekania.

Szczegóły składni: [animacje Tailwind](https://tailwindcss.com/docs/animation).
Sprzątanie timerów: [efekty React](https://react.dev/reference/react/useEffect).
Semantyka ładowania: [ARIA busy](https://www.w3.org/TR/wai-aria-1.2/#aria-busy).
