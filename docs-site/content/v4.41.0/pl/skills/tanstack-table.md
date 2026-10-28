---
title: /tanstack-table
description: >-
  Zastosuj reguły TanStack Table właściwe dla repozytorium po wczytaniu
  wskazówek dotyczących zainstalowanego pakietu za pomocą TanStack Intent.
  Używaj podczas tworzenia, przeglądania lub migrowania tabel i siatek danych.
type: skill
sidebar:
  label: /tanstack-table
---
![Diagram umiejętności /tanstack-table](/diagrams/skills/tanstack-table.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/tanstack-table.excalidraw)

Najpierw wykonaj `/tanstack-intent`. Wykryj zainstalowany adapter Table i pakiety podstawowe,
a następnie wczytaj każdy identyfikator `use` pasujący do zadania. Intent jest źródłem aktualnej składni API, statusu wersji,
wskazówek dotyczących migracji, semantyki stanu i wzorców właściwych dla frameworka.

## Reguły lokalne

Hook `tanstack-table-check` stanowi zależny od wersji minimalny poziom ochrony przed regresjami, a nie dokumentację
API. Ustala najbliższą zadeklarowaną lub zainstalowaną wersję pakietu i stosuje
kontrole V9 wyłącznie do projektów V9. Wskazówki dotyczące zainstalowanego pakietu wczytane przez Intent pozostają nadrzędne.

Jeśli hook jest sprzeczny z wczytanymi wskazówkami dotyczącymi pakietu, zatrzymaj się i popraw środowisko testowe oraz jego ewaluacje.
Nie omijaj oficjalnego API ani nie zachowuj nieaktualnej lokalnej treści tylko po to, aby spełnić wymagania hooka.

Dowody ukończenia obejmują wersję zainstalowanego pakietu, wczytane identyfikatory `use` z Intent,
ukierunkowane testy Table, kontrolę typów i lintowanie.
