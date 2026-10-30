# Pomiary komend i normalizacji — 30 października 2026

Status: odebrana lokalna część pomiarów Inbox i ścieżki aktualizacji ligi. Punkt odniesienia: `02891a2` z dodanym zestawem long. Kod produkcyjny pozostaje bez zmian. [Surowe rekordy i wynik procesu](controller-normalization-baseline-2026-10-30.json) zachowują wszystkie próbki, w tym przebieg 0.

## Środowisko i scenariusze

Windows x64, Dart 3.11.1, Flutter 3.41.4, Flutter test/JIT, seed 123. Fixture początkowej ligi ma 30 zespołów i 780 zawodników; mniejszy wariant zachowuje pierwszy zespół. Oba warianty mają 100 zwykłych, nieprzeczytanych wiadomości o stałych ID. Przed pomiarem kontrakty i składy są normalizowane, aby oddzielić stały koszt sprawdzenia inwariantów od jednorazowej naprawy danych po wczytaniu.

- `inbox-mark-read`: 100 kolejnych, różnych wiadomości zostaje oznaczonych jako przeczytane przez publiczne `markMessageRead` kontrolera.
- `date-mutation`: 100 aktualizacji samego pola dnia, cyklicznie od 2 do 6, przez `updateLeague`. To mutacja daty, nie symulacja kolejnych dni, przejście tygodnia ani test kontraktów na granicy sezonu.

Dla każdej pary scenariusz/rozmiar wykonano przebieg 0 oraz pięć kolejnych przebiegów 1–5. Przebieg 0 jest raportowany osobno. Nie oznacza zimnego procesu/dysku; scenariusze korzystają z jednej rozgrzewającej się VM. Podsumowania używają mediany/min/max pięciu próbek, bez p95.

## Co dokładnie mierzymy

Każdy etap ma własny stoper. Przygotowanie danych, pojemnika providerów, wczytanie zapisu i asercje są poza pomiarem. Stany wejściowe i wynik końcowy są kontrolowane przez test.

- `transform-only`: seria 100 zmian samego Inbox/daty, bez normalizacji.
- `contract-normalization-only`: 100 wywołań normalizacji kontraktów na wcześniej przygotowanych stanach; same wejścia powstają poza pomiarem.
- `lineup-reconciliation-only`: 100 wywołań uzgadniania składów na tych samych przygotowanych, już poprawnych stanach.
- `transform-and-normalization`: 100 kolejnych transformacji oraz obu normalizacji w kolejności używanej przez kontroler, bez providerów i zapisu.
- `controller-publication`: 100 wywołań rzeczywistego kontrolera, z kolejką, rewizjami, publikacją i autosave do repozytorium pamięciowego. Odnotowano 100 zapisów pamięciowych na serię.
- `memory-save-barrier`: **jedno** końcowe `flushPendingSave`, mierzone osobno po publikacji całej serii. Nie dzielimy tego wyniku przez 100 i nie traktujemy go jako kosztu zapisu na dysk.

Repozytorium pamięciowe usuwa z tego porównania koszt systemu plików i kodowania JSON; po barierze utrwalony w nim payload musi być zgodny z wynikiem kontrolera. Test nie instaluje listenerów UI, nie pompuje widgetów, nie mierzy klatek, RSS ani alokacji. Zmiana stanu nie oznacza więc tutaj pomiaru kosztu odrysowania ekranu.

Pomiary komponentów są osobnymi seriami, wykonanymi w określonej kolejności. Nie należy sumować ich median ani odejmować median od wyniku kontrolera i przedstawiać różnicy jako dokładnego udziału przyczynowego. Narzut asynchroniczności, JIT i GC wpływa na pomiary. Sekwencja `transform-and-normalization` jest osobnym, bezpośrednim pomiarem całego fragmentu.

## Wyniki

Poniżej mediana oraz min–max, w milisekundach **dla całej serii 100 operacji**; wyjątkiem jest jedno wywołanie bariery. Plik JSON zawiera mikrosekundy i jawne pole `iterations`.

### inbox-mark-read, zespoły: 1

- `transform-only`: **0.333 ms**, zakres 0.314–0.417 ms.
- `contract-normalization-only`: **0.251 ms**, zakres 0.147–0.455 ms.
- `lineup-reconciliation-only`: **1.321 ms**, zakres 0.760–2.310 ms.
- `transform-and-normalization`: **2.065 ms**, zakres 1.567–3.996 ms.
- `controller-publication`: **29.535 ms**, zakres 22.844–33.982 ms.
- `memory-save-barrier`: **0.064 ms**, zakres 0.053–0.071 ms.

### date-mutation, zespoły: 1

- `transform-only`: **0.071 ms**, zakres 0.009–0.087 ms.
- `contract-normalization-only`: **0.140 ms**, zakres 0.129–0.200 ms.
- `lineup-reconciliation-only`: **0.843 ms**, zakres 0.766–1.338 ms.
- `transform-and-normalization`: **1.114 ms**, zakres 0.821–1.176 ms.
- `controller-publication`: **20.176 ms**, zakres 17.821–21.184 ms.
- `memory-save-barrier`: **0.046 ms**, zakres 0.044–0.088 ms.

### inbox-mark-read, zespoły: 30

- `transform-only`: **0.193 ms**, zakres 0.183–0.278 ms.
- `contract-normalization-only`: **2.618 ms**, zakres 2.408–2.977 ms.
- `lineup-reconciliation-only`: **26.718 ms**, zakres 26.017–28.046 ms.
- `transform-and-normalization`: **32.108 ms**, zakres 29.967–34.830 ms.
- `controller-publication`: **51.434 ms**, zakres 49.292–51.859 ms.
- `memory-save-barrier`: **0.048 ms**, zakres 0.040–0.117 ms.

### date-mutation, zespoły: 30

- `transform-only`: **0.007 ms**, zakres 0.006–0.009 ms.
- `contract-normalization-only`: **2.565 ms**, zakres 2.382–2.914 ms.
- `lineup-reconciliation-only`: **26.686 ms**, zakres 25.578–27.901 ms.
- `transform-and-normalization`: **30.100 ms**, zakres 28.667–31.380 ms.
- `controller-publication`: **46.008 ms**, zakres 44.410–47.916 ms.
- `memory-save-barrier`: **0.047 ms**, zakres 0.038–0.058 ms.

## Decyzja dotycząca optymalizacji

Dla tych fixture’ów wzrost liczby zespołów zwiększa koszt uzgadniania składów wyraźniej niż koszt normalizacji kontraktów. Wyniki są zgodne ze skanowaniem składów po każdej mutacji. Nie dowodzą jednak, że normalizacja jest problemem płynności: w tym przebiegu średni koszt pojedynczej operacji pełnego kontrolera pozostaje poniżej 1 ms (czas serii podzielony przez 100).

**Nie rozpoczynamy na tej podstawie warunkowego zawężania normalizacji z etapu 4.** Brak danych z urządzenia i ustalonego na nim budżetu nie uzasadnia osłabienia inwariantów ścieżki ogólnej. Gdy pomiar aplikacji na Androidzie wykaże istotny udział tych operacji w opóźnieniach, punktem do sprawdzenia jest uzgadnianie składów dla komend dotyczących wyłącznie Inbox. Obecny baseline pozwoli porównać przyszłą zmianę przy zachowaniu tych samych warunków.

Do pełnego odbioru etapu 3 pozostają pomiary dnia/serii dni i gotowych operacji rynku godzinowego oraz profil na urządzeniu. Zestaw nie uruchamia AI, silnika meczowego ani testów disabled. Nie deklaruje zakończenia całego etapu 3.

## Powtórzenie przebiegu

Z katalogu repozytorium w PowerShell 7, po pobraniu zależności:

```powershell
. ./scripts/test_support.ps1
$normalizationBin = Split-Path -Parent (Get-Command flutter -CommandType Application | Select-Object -First 1).Source
$normalizationDart = Join-Path $normalizationBin 'cache/dart-sdk/bin/dart.exe'
$normalizationSnapshot = Join-Path $normalizationBin 'cache/flutter_tools.snapshot'
$normalizationResult = Invoke-BoundedTestProcess -Executable $normalizationDart -Arguments @($normalizationSnapshot, 'test', '--no-pub', '--reporter', 'expanded', 'test/performance/long/controller_normalization_measurements_long.dart') -WorkingDirectory (Get-Location).Path -LogDirectory ((Get-Location).Path + '/build/normalization-measurements-local') -TimeoutSeconds 240
$normalizationResult
```

Przykład dotyczy Windows; na systemach uniksowych użyć pliku wykonywalnego `dart`. Każdy zachowywany przebieg powinien mieć osobny katalog logów. Surowe rekordy JSON trafiają do `stdout.log` synchronicznie, aby buforowanie `debugPrint` nie zgubiło końcowych próbek przy zakończeniu VM.

## Weryfikacja

- **4/4 PASS**, kod 0, 6,15 s wraz z uruchomieniem procesu; zewnętrzny limit 240 s i lokalny timeout 2 min na scenariusz.
- Sprawdzono kompletność 24 podsumowań (6 etapów × 4 scenariusze), po pięć próbek; mediany i min/max przeliczono niezależnie z surowych rekordów.
- W trakcie testu każda ścieżka komponentów i wynik kontrolera musi zachować oczekiwany stan, a oryginalny fixture pozostaje niezmieniony.
- Pełny standard aplikacji nie wymaga ponownego wykonania po zmianie wyłącznie izolowanego long i dokumentacji. Ostatni odebrany standard: 1677 PASS, 1 istniejący SKIP. Pozostałe long pozostają poza wykonaniem.
