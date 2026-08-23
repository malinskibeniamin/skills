---
title: /wizard
description: >-
  Wygeneruj interaktywny kreator bash dla infrastruktury wymagającej udziału
  człowieka, poświadczeń lub sekretów CI, zewnętrznych paneli, migracji i
  przełączeń. Nie używaj go do zadań, które agent może wykonać samodzielnie.
type: skill
sidebar:
  label: /wizard
---
![Diagram umiejętności /wizard](/diagrams/skills/wizard.svg)

[Otwórz edytowalne źródło Excalidraw](/diagrams/skills/wizard.excalidraw)

**Kreator** to skrypt bash, który prowadzi człowieka krok po kroku przez ręczną procedurę, uciążliwą zarówno do samodzielnego wykonania, jak i do ponownego wyjaśniania AI za każdym razem. Otwiera każdy adres URL, precyzyjnie wskazuje, co kliknąć i skopiować, przechwytuje wartości, zapisuje je we właściwych miejscach (`.env`, sekrety GitHub), prosi o potwierdzenie na każdym etapie i pokazuje, ile etapów pozostało. Może konfigurować usługi zewnętrzne, wykonywać jednorazową migrację lub przenosić projekt z jednego stanu do drugiego.

Dopracowany UX zapewnia już [template.sh](https://github.com/malinskibeniamin/skills/blob/v4.38.0/wizard/template.sh) — postęp etap po etapie, punkty potwierdzenia, otwieranie adresów URL na różnych platformach (w tym WSL), ukryte wprowadzanie sekretów, idempotentne aktualizacje `.env`, zapisy przez `gh secret`/`gh variable` oraz podsumowanie końcowe. **Twoim jedynym zadaniem jest określenie zakresu procedury i przygotowanie jej etapów.** Biblioteka powyżej znacznika `STAGES` jest identyczna w każdym kreatorze — ta spójność jest zamierzona, dlatego nigdy nie edytuj jej ręcznie.

Domyślnie kreator jest tymczasowy — tworzony do jednorazowego uruchomienia, zapisywany w katalogu roboczym lub `scripts/` i usuwany po zakończeniu zadania. Zatwierdź go w repozytorium tylko wtedy, gdy użytkownik chce powtarzalnej ścieżki konfiguracji, która powinna pozostać w projekcie.

## Proces

### 1. Określ zakres procedury

Ustal wszystkie ręczne czynności, które musi wykonać człowiek, oraz każdą wartość przechwytywaną po drodze. Najpierw zapoznaj się z repozytorium — nie pytaj bez przygotowania. W przypadku konfiguracji usług zewnętrznych uruchom `/read-the-damn-docs`, zanim wskażesz kliknięcia w panelu, adresy URL, zakresy uprawnień, sekrety lub polecenia CLI:

- W przypadku konfiguracji: `.env`, `.env.example`, `.env.*`, `README`, `docker-compose*`, konfiguracja frameworka oraz `.github/workflows/*` (każde odwołanie `secrets.*` / `vars.*` jest wartością, którą kreator musi utworzyć).
- W przypadku migracji lub przejścia: stan bieżący, stan docelowy oraz nieodwracalne działania między nimi.

Następnie pokaż użytkownikowi uporządkowaną listę etapów i wartości tworzonych przez każdy z nich oraz poproś o potwierdzenie — użytkownik może dodać, usunąć lub zmienić ich kolejność.

**Gotowe, gdy:** każdy etap ma nazwę i określone miejsce w kolejności, a dla każdej przechwytywanej wartości wiadomo: (a) skąd człowiek ją uzyskuje, (b) gdzie jest zapisywana (`.env`, sekret GitHub, oba miejsca lub nigdzie — niektóre etapy obejmują wyłącznie działania) oraz (c) czy jest sekretem (ukryte wprowadzanie), czy wartością publiczną.

### 2. Wyznacz przebieg każdego etapu

Dla każdego etapu opisz dokładną ścieżkę postępowania: który adres URL otworzyć, co tam zrobić, gdzie wyświetlana jest wartość i którą zmienną wypełnia — na przykład: „Panel -> Developers -> API keys -> Reveal test key -> skopiuj”. Jeśli nie znasz aktualnego interfejsu lub dokładnego polecenia, powiedz o tym i zapytaj użytkownika albo sprawdź dokumentację — nigdy nie wymyślaj kroków, które mogą nie istnieć.

**Gotowe, gdy:** każdy etap prowadzi przez konkretne instrukcje, które może wykonać osoba nieznająca projektu.

### 3. Utwórz kreator

Skopiuj `template.sh` do ścieżki docelowej. Zastąp przykładowy etap jednym `stage` dla każdego kroku, zachowując kolejność zależności. Używaj funkcji pomocniczych biblioteki — `stage`, `say`/`step`, `open_url`, `ask`/`ask_secret`, `write_env`, `set_secret`/`set_var`, `pause`/`confirm` — i ustaw `TOTAL_STAGES` na liczbę napisanych etapów.

Zachowaj standard wyznaczony przez szablon: otwieraj adres URL przed poproszeniem o jego wartość, używaj `ask_secret` dla wszystkich sekretów, zapisuj każdą utrwalaną wartość za pomocą `write_env`, a `set_secret` stosuj tylko do wartości rzeczywiście potrzebnych CI. Przed każdym nieodwracalnym działaniem używaj `confirm`. Każdy `stage` czyści ekran, aby widoczny był tylko bieżący krok — ogranicz etap do jednego konkretnego zadania, aby potrzebne informacje nie zniknęły poza ekranem. Nie modyfikuj biblioteki powyżej znacznika.

### 4. Zweryfikuj i przekaż

- `bash -n <script>`; uruchom `shellcheck`, jeśli jest dostępny.
- `chmod +x <script>`.
- Nie uruchamiaj całego skryptu samodzielnie — otwiera przeglądarki i czeka na działania człowieka. Zamiast tego przeanalizuj go statycznie: każda wartość z kroku 1 jest przechwytywana i trafia do wskazanego tam miejsca, a każda nazwa w `set_secret` dokładnie odpowiada odwołaniu `secrets.*` w CI.
- Powiedz użytkownikowi, jak go uruchomić. Jeśli jest to powtarzalna ścieżka konfiguracji, zatwierdź ją w repozytorium i dodaj odnośnik w README, aby kolejna osoba uruchomiła skrypt zamiast pytać AI.
