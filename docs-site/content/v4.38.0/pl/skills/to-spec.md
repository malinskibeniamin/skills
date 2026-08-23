---
title: /to-spec
description: >-
  Przekształć bieżącą rozmowę w specyfikację gotową do umieszczenia w systemie
  śledzenia zadań.
type: skill
sidebar:
  label: /to-spec
---
![Diagram umiejętności /to-spec](/diagrams/skills/to-spec.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/to-spec.excalidraw)

Ta umiejętność tworzy specyfikację (czasem nazywaną PRD) na podstawie uzgodnionego kontekstu rozmowy i informacji z bazy kodu. Syntetyzuj informacje bez ponownego otwierania rozstrzygniętych decyzji. Każdą istotną brakującą decyzję oznacz w sekcji Dalsze uwagi zamiast przyjmować ją bez wyjaśnienia.

Używaj słownictwa systemu śledzenia zadań i etykiet klasyfikacji z `docs/agents/`, jeśli jest dostępne. Jeśli go brakuje, zwróć specyfikację na czacie i wskaż `/work-automation-kit` jako opcjonalny kolejny krok konfiguracji.

## Proces

1. Zapoznaj się z repozytorium, aby zrozumieć bieżący stan bazy kodu, jeśli nie zostało to jeszcze zrobione. W całej specyfikacji używaj słownictwa ze słownika domenowego projektu i przestrzegaj dokumentów ADR dotyczących modyfikowanego obszaru.

2. Naszkicuj punkty styku, na których przetestujesz funkcję. Preferuj istniejące punkty styku zamiast nowych. Użyj najwyższego możliwego punktu styku. Jeśli potrzebne są nowe, zaproponuj je na najwyższym możliwym poziomie. Im mniej punktów styku w bazie kodu, tym lepiej — idealnie powinien być jeden.

Jeśli specyfikacja zależy od bieżącego zachowania zewnętrznej usługi lub API, uruchom `/read-the-damn-docs`. Jeśli możliwych jest kilka planów rozwiązania lub punktów styku, uruchom `/plan-arbiter`. Użyj `/visual-plan` tylko wtedy, gdy użytkownik poprosił o ten dodatkowy artefakt przeglądu.

3. Napisz specyfikację, korzystając z poniższego szablonu. Domyślnie zwróć ją na czacie; opublikuj ją w systemie śledzenia zadań projektu i zastosuj `ready-for-agent` tylko wtedy, gdy użytkownik poprosił o publikację.

4. Jeśli użytkownik chce następnie podzielić prace implementacyjne, przekaż zatwierdzoną specyfikację do `/to-tickets`.

<spec-template>

## Opis problemu

Problem, z którym mierzy się użytkownik, przedstawiony z jego perspektywy.

## Rozwiązanie

Rozwiązanie problemu przedstawione z perspektywy użytkownika.

## Historie użytkownika

Numerowana lista zawierająca jedną historię dla każdego odrębnego rezultatu aktora objętego zakresem:

1. Jako <aktor> chcę <funkcja>, aby <korzyść>

<user-story-example>
1. Jako klient bankowości mobilnej chcę widzieć saldo swoich rachunków, aby podejmować bardziej świadome decyzje dotyczące wydatków
</user-story-example>

**Warunek ukończenia:** każde zachowanie, ograniczenie i działanie naprawcze objęte zakresem odpowiada jednej historii; nie występują powtórzenia, szczegóły implementacyjne ani zachowania poza zakresem.

## Decyzje implementacyjne

Lista podjętych decyzji implementacyjnych. Może obejmować:

- Moduły, które zostaną utworzone lub zmodyfikowane
- Interfejsy tych modułów, które zostaną zmodyfikowane
- Wyjaśnienia techniczne od dewelopera
- Decyzje architektoniczne
- Zmiany schematu
- Kontrakty API
- Konkretne interakcje

Nie podawaj konkretnych ścieżek plików ani fragmentów kodu. Mogą bardzo szybko stać się nieaktualne.

Wyjątek: jeśli prototyp zawiera fragment, który wyraża decyzję precyzyjniej niż opis (maszyna stanów, reduktor, schemat, struktura typu), umieść go bezpośrednio przy odpowiedniej decyzji i krótko zaznacz, że pochodzi z prototypu. Ogranicz go do części istotnych dla decyzji — nie zamieszczaj działającej demonstracji, tylko najważniejsze elementy.

## Decyzje dotyczące testowania

Lista podjętych decyzji dotyczących testowania. Uwzględnij:

- Opis dobrego testu (testuj wyłącznie zachowanie zewnętrzne, a nie szczegóły implementacyjne)
- Moduły, które będą testowane
- Istniejące wzorce testów (czyli podobne rodzaje testów w bazie kodu)

## Poza zakresem

Opis elementów, które nie są objęte tą specyfikacją.

## Dalsze uwagi

Wszelkie dodatkowe uwagi dotyczące funkcji.

</spec-template>
