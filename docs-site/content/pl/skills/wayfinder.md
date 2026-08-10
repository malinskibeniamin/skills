---
title: /wayfinder
description: >-
  Mapuj pracę obejmującą wiele sesji za pomocą zgłoszeń decyzyjnych w systemie
  śledzenia problemów.
type: skill
sidebar:
  label: /wayfinder
---
![Diagram umiejętności /wayfinder](/diagrams/skills/wayfinder.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/wayfinder.excalidraw)

Użyj, gdy cel jest zbyt obszerny na jedno okno kontekstu, a droga do **celu** pozostaje niejasna. Wayfinder wyznacza trasę za pomocą **zgłoszeń decyzyjnych** — pytań, których rozstrzygnięciem jest decyzja, a nie fragment implementacji do wykonania. Celem może być specyfikacja, decyzja lub zmiana, do której droga jest niejasna.

## Planuj, nie wykonuj
Wayfinder służy wyłącznie do planowania. Każde zgłoszenie rozstrzyga decyzję, a mapa jest gotowa, gdy przed rozpoczęciem realizacji nie pozostało już nic do rozstrzygnięcia. Potrzeba przejścia do wykonania oznacza, że osiągnięto krawędź mapy. W Notatkach zapisuj preferencje dotyczące planowania i prace wspierające podejmowanie decyzji; Notatki nie upoważniają do implementacji ani dostarczenia rozwiązania.

## Niezmienniki
- Odwołuj się do map i zgłoszeń za pomocą **nazwy** (ich tytułu), a nie samego identyfikatora lub sluga. W razie potrzeby dodaj link do nazwy.
- Mapa jest **indeksem**, nie magazynem: decyzje znajdują się w swoich zgłoszeniach; mapa zawiera tylko jednozdaniowe podsumowanie i odnośnik.
- Najpierw przeczytaj `CLAUDE.md`, jeśli istnieje; w przeciwnym razie przeczytaj `AGENTS.md`. Skorzystaj ze wskazania **Issue tracker** w tym pliku, a następnie przeczytaj **Wayfinding operations**. Nigdy nie zakładaj ścieżki do dokumentu. Jeśli nie istnieje ani plik, ani wskazanie, użyj lokalnego rozwiązania awaryjnego opartego na Markdown.
- Przed rozpoczęciem pracy przypisz zgłoszenie prowadzącemu programiście; musi to być pierwszy zapis w sesji. Otwarte i nieprzypisane zgłoszenie jest nieprzejęte.
- Używaj natywnej funkcji blokowania lub zależności systemu śledzenia, jeśli jest dostępna; jawnego wiersza `Blocked by:` używaj tylko wtedy, gdy natywne blokowanie jest niedostępne.
- W kontekście głównym rozstrzygaj najwyżej jedno zgłoszenie na sesję. Jawne delegowanie lub
  `/swarm` może zezwolić na równoległą realizację gotowych zgłoszeń badawczych; samo wywołanie wayfindera nie daje takiego upoważnienia.
- W przypadku autoryzowanej mapy równoległej stosuj `/efficient-frontier` między seriami zgłoszeń
  i pozostaw syntezę koordynatorowi.
- Używaj `/agent-watchdog`, gdy przed zaufaniem mapie sprawdzasz rozstrzygnięte zgłoszenie, przypisanie, gałąź lub podsumowanie frontu z innej sesji.

## Struktura mapy
Mapa to jedno zgłoszenie lub plik z etykietą lub oznaczeniem `wayfinder:map`.

```markdown
## Destination
<what reaching the end of this map looks like -- the spec, decision, or change this effort is finding its way to>
## Notes
<domain; skills every session should consult; standing planning preferences for this effort>
## Decisions so far
- [<closed ticket title>](link) -- <one-line gist of the answer>
## Not yet specified
<in-scope future questions or risks not sharp enough to ticket yet>
## Out of scope
<work ruled beyond this destination>
```

Otwarte zgłoszenia nie są wymieniane w treści mapy; wyszukaj w systemie śledzenia otwarte zgłoszenia podrzędne lub zgłoszenia frontu.

## Zgłoszenia
Każde zgłoszenie decyzyjne jest zgłoszeniem lub plikiem podrzędnym ze ściśle określonym pytaniem, którego zakres odpowiada jednej sesji agenta obejmującej 100 tys. tokenów:

```markdown
## Question

<the decision or investigation this ticket resolves>
```

Każde zgłoszenie jest typu **HITL** — z udziałem człowieka, opracowywane z osobą wypowiadającą się we własnym imieniu — albo **AFK**, realizowane samodzielnie przez agenta. Zgłoszenie HITL można rozstrzygnąć wyłącznie w ramach tej bezpośredniej wymiany; agent nie może sam odpowiadać na własne pytania sondujące.

Typy zgłoszeń:

- **Badanie** (AFK): zapoznaj się z dokumentacją, interfejsami API, specyfikacjami, kodem źródłowym lub innymi źródłami pierwotnymi za pomocą
  `/research` w kontekście głównym. Dodaj link do cytowanego podsumowania w Markdown. Używaj osobnego toru badawczego
  dopiero po jawnym delegowaniu lub wywołaniu `/swarm`.
- **Prototyp** (HITL): utwórz prosty artefakt do oceny, w tym prototyp interfejsu lub logiki za pomocą `/prototype`. Dodaj link do artefaktu.
- **Sondowanie** (HITL): rozmowa. Zawsze wywołuj `/grilling` i `/domain-modeling`. Jest to domyślny typ, gdy pytanie dotyczy głównie oceny.
- **Zadanie** (HITL lub AFK): ręczna praca wymagana, zanim będzie można kontynuować podejmowanie decyzji. Automatyzuj tam, gdzie jest to bezpieczne; w przeciwnym razie przekaż człowiekowi listę kontrolną. Takie zadanie jest uzasadnione, gdy odblokowuje decyzję, a nie gdy dostarcza rozwiązanie docelowe.

Odpowiedź nie należy do treści zgłoszenia. Zapisz ją podczas rozstrzygania. Do zasobów dodawaj linki zamiast wklejać ich zawartość.

## Mgła wojny
Nie wyznaczaj obszarów, których jeszcze nie widzisz. Sekcja **Jeszcze nieokreślone** służy do zapisywania przypuszczalnych pytań lub ryzyk objętych zakresem, które nie są jeszcze na tyle precyzyjne, by utworzyć dla nich zgłoszenie. Zgłoszenie służy do precyzyjnego pytania, nawet jeśli jest zablokowane. Sekcja Jeszcze nieokreślone nie obejmuje tego, co już rozstrzygnięto, co ma już zgłoszenie ani co znajduje się poza zakresem.

## Poza zakresem

Mgła gromadzi się tylko w kierunku celu. Prace wykraczające poza cel są **Poza zakresem**: nie stanowią mgły i nigdy nie stają się zgłoszeniami, chyba że cel zostanie wyznaczony na nowo. Jeśli okaże się, że zgłoszenie wykracza poza cel, zamknij je, dodaj w sekcji Poza zakresem jeden wiersz z uzasadnieniem i nie zapisuj go jako decyzji na trasie.

## Sporządź mapę

1. Nazwij Cel. Uruchom `/grilling` i `/domain-modeling`, aby precyzyjnie określić, do czego prowadzi ta mapa.
2. Zmapuj front. Przeprowadź wszerz sondowanie całej przestrzeni, ujawniając otwarte decyzje i pierwsze kroki. **Jeśli nie ujawni to żadnej mgły**, mapa nie jest potrzebna; zatrzymaj się i zapytaj użytkownika, jak kontynuować.
3. Utwórz mapę zawierającą Cel, Notatki, pustą sekcję Dotychczasowe decyzje, Jeszcze nieokreślone oraz Poza zakresem.
4. Utwórz tylko te zgłoszenia, które możesz teraz precyzyjnie określić. Powiąż każde z nich za pomocą natywnej relacji podrzędnego zgłoszenia w systemie śledzenia, jeśli jest dostępna; linku w treści lub na liście zadań używaj tylko wtedy, gdy natywna hierarchia jest niedostępna. Ponownie przeczytaj mapę i sprawdź, czy każde zgłoszenie jest widoczne jako podrzędne, a następnie w drugim przebiegu skonfiguruj zależności blokujące.
5. Rozstrzygnij bezpośrednio w kontekście głównym jedno gotowe zgłoszenie badawcze AFK. Jeśli użytkownik jawnie
   zezwolił na delegowanie lub wywołał `/swarm`, uruchom odrębne, gotowe tory badawcze; każdy tor
   najpierw przejmuje swoje zgłoszenie, używa lokalizacji artefaktu określonej przez `/research` i nie tworzy własnego pliku
   głównego ani gałęzi.
6. Zatrzymaj się po tym jednym gotowym zgłoszeniu badawczym; nie rozstrzygaj kolejnego zgłoszenia w tej sesji.

## Pracuj z mapą

1. Wczytaj mapę w niskiej rozdzielczości; nie wczytuj treści wszystkich zgłoszeń.
2. Wybierz zgłoszenie: użyj wskazanego zgłoszenia albo wybierz pierwsze otwarte, nieblokowane i nieprzejęte zgłoszenie frontu. Najpierw je przejmij.
3. Rozstrzygnij je, zagłębiając się w powiązane lub zamknięte zgłoszenia tylko w razie potrzeby. Wywołaj umiejętności wskazane w Notatkach; w razie wątpliwości użyj `/grilling` i `/domain-modeling`.
4. Zapisz odpowiedź jako komentarz rozstrzygający lub sekcję odpowiedzi, zamknij lub rozstrzygnij zgłoszenie, a następnie dodaj odnośnik kontekstowy do sekcji Dotychczasowe decyzje.
5. Dodaj nowo ujawnione zgłoszenia i zależności blokujące; usuń z sekcji Jeszcze nieokreślone wpisy, które stały się zgłoszeniami, aby każdy fakt znajdował się tylko w jednym miejscu. Jeśli zgłoszenie wykracza poza Cel, oznacz je jako Poza zakresem zamiast rozstrzygać je na trasie.

Zakładaj, że inne sesje mogą równocześnie edytować system śledzenia; przed zapisem odczytaj jego bieżący stan.

## Przekazanie

Gdy mapa jest przejrzysta, przekaż ją do `/to-spec`, aby scalić powiązane decyzje w jeden plan możliwy do wdrożenia, a następnie do `/to-tickets`. Pomiń to scalanie tylko wtedy, gdy praca okazała się rzeczywiście niewielka.

Najpierw ponownie sprawdź przejęte zgłoszenia. Przed pokazaniem frontu jeszcze raz przeczytaj odpowiedź rozstrzygającą, podsumowanie w sekcji Dotychczasowe decyzje, powiązane zasoby i stan systemu śledzenia. Popraw wszelkie nieaktualne lub niepotwierdzone stwierdzenia, zanim poprosisz człowieka o podjęcie działań dotyczących kolejnych zgłoszeń.

Na końcu podaj kroki możliwe do skopiowania i wklejenia: jedno polecenie dla następnego zalecanego zgłoszenia oraz po jednym przypiętym poleceniu dla każdego otwartego, nieblokowanego i nieprzejętego zgłoszenia frontu, jeśli równoległe sesje są bezpieczne.
