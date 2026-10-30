# Pomiary pipeline’u zapisu — 30 października 2026

Status: wykonana część pomiarowa dotycząca save/load/rename/duplicate. Pozostałe scenariusze etapu 3 (komendy Inbox, normalizacja ligi, rynek godzinowy i dzień symulacji) wymagają osobnego odbioru. Nie wdrożono optymalizacji kodu produkcyjnego.

## Środowisko i zakres

Punkt odniesienia: `dafbf71` wraz ze zmianą testu pomiarowego przygotowaną w tym commicie. Flutter 3.41.4, Dart 3.11.1, Windows x64, Flutter test/JIT. Nie jest to pomiar profile/release na Androidzie. Surowe rekordy i kod zakończenia zapisano w [pliku JSON](save-pipeline-baseline-2026-10-30.json); lokalny pełny log: `build/save-measurements-review-final/`.

Wykorzystano istniejący `save_pipeline_measurements_long.dart`, repozytorium zapisów z izolatami oraz dotychczasowe fixture’y z seedem 123, schematem 27, 30 zespołami i 780 zawodnikami:

- `initial`: początkowy stan ligi bez historii sezonów.
- `synthetic-history`: pięć syntetycznych sezonów historii i statystyk zawodników oraz zapisane zwarte wyniki terminarza. To większy wolumen danych, nie rezultat zasymulowania pięciu sezonów.

## Metoda

Każdy fixture wykonuje przebieg 0 oraz pięć kolejnych przebiegów 1–5. Podsumowanie obejmuje wyłącznie przebiegi 1–5: medianę, minimum i maksimum czasu w mikrosekundach. Przy pięciu próbkach nie wyliczamy p95.

Przebieg 0 jest pierwszym przebiegiem danego fixture’u w tej VM, nie „zimnym” startem procesu ani dysku. Drugi fixture korzysta z już uruchomionej VM. Pierwszy save tworzy plik; kolejne go nadpisują. Czasów pierwszego i kolejnych zapisów nie należy interpretować jako porównania identycznych operacji przed i po optymalizacji.

Kolejność w próbce: podgląd zespołów ×10, zapis, odczyt, osobny diagnostyczny odczyt faz, zmiana nazwy i duplikacja. Kopia jest usuwana po próbce poza pomiarem, dzięki czemu nie zwiększamy liczebności indeksu w kolejnych próbkach. Czas utworzenia fixture’u i katalogu, asercje poprawności, podsumowanie i sprzątanie nie wchodzą do czasów operacji.

Każdy odczyt sprawdza pełny payload ligi, seed i metadane z uwzględnieniem prawidłowego stemplowania `updatedAt` przy zapisie. Zmiana nazwy ma rzeczywiście inną nazwę w każdym przebiegu. Nie dodano progów czasu zależnych od hosta.

Zachowano dotychczasowe rekordy RSS procesu oraz największej zaobserwowanej luki pętli zdarzeń, a także diagnostyczne fazy odczytu i kodowania zapisu. RSS obejmuje całą VM i izolaty; nie jest stertą Dart. Próbkowanie co 2 ms może pominąć krótki szczyt, a JIT i GC wpływają na wyniki. Luka timera w teście nie jest czasem klatki aplikacji.

## Wyniki

Wartości poniżej to mediana oraz zakres min–max z pięciu próbek, w milisekundach. Rekordy JSON zachowują oryginalne mikrosekundy.

### initial

- `preview-10`: **0.119 ms**, zakres 0.114–0.156 ms.
- `save`: **97.769 ms**, zakres 92.767–106.609 ms.
- `load`: **34.378 ms**, zakres 27.821–40.014 ms.
- `isolated-load-phases`: **30.359 ms**, zakres 27.862–37.131 ms.
- `rename`: **150.090 ms**, zakres 146.435–156.268 ms.
- `duplicate`: **119.107 ms**, zakres 107.106–124.336 ms.

### synthetic-history

- `preview-10`: **0.133 ms**, zakres 0.106–0.167 ms.
- `save`: **279.658 ms**, zakres 273.885–291.262 ms.
- `load`: **129.339 ms**, zakres 116.837–136.944 ms.
- `isolated-load-phases`: **138.988 ms**, zakres 125.847–143.533 ms.
- `rename`: **495.737 ms**, zakres 481.997–497.582 ms.
- `duplicate`: **371.653 ms**, zakres 353.790–380.073 ms.

## Wniosek i granice odbioru

Uzyskano odtwarzalny lokalny punkt odniesienia dla operacji zapisu, z oddzielnym pierwszym przebiegiem i pięcioma próbkami w każdej serii. Dłuższe operacje dla większego fixture’u wskazują koszt większego wolumenu, ale nie dowodzą regresji ani konkretnego wąskiego gardła. Brak pomiaru na urządzeniu uniemożliwia ocenę płynności mobilnej i ustalenie jej budżetu.

Na podstawie tych wyników nie ma uzasadnienia dla zmiany normalizacji ligi z etapu 4: ten zestaw jej nie mierzy. Decyzja pozostaje odroczona do pomiarów komend i symulacji. Dane stanowią baseline do przyszłych porównań na tym samym hoście, z tym samym scenariuszem i trybem wykonania.

## Uruchamianie

Standard nadal pomija ten plik. `scripts/test.ps1 -Profile long -Area performance` uruchamia cały obszar, także inne kosztowne testy. Aby powtórzyć wyłącznie ten zestaw z istniejącym ograniczeniem procesu, wykonać z katalogu repozytorium w PowerShell 7:

```powershell
. ./scripts/test_support.ps1
$measurementBin = Split-Path -Parent (Get-Command flutter -CommandType Application | Select-Object -First 1).Source
$measurementDart = Join-Path $measurementBin 'cache/dart-sdk/bin/dart.exe'
$measurementSnapshot = Join-Path $measurementBin 'cache/flutter_tools.snapshot'
$measurementResult = Invoke-BoundedTestProcess -Executable $measurementDart -Arguments @($measurementSnapshot, 'test', '--no-pub', '--reporter', 'expanded', 'test/performance/long/save_pipeline_measurements_long.dart') -WorkingDirectory (Get-Location).Path -LogDirectory ((Get-Location).Path + '/build/save-measurements-local') -TimeoutSeconds 240
$measurementResult
```

Powyższy przykład jest dla Windows; na systemach uniksowych plik wykonywalny SDK nazywa się `dart`. Wymagane są uprzednio pobrane zależności projektu. Wynik `ExitCode = 0` i `PASS` oznacza zakończenie obu testów; timeout jest błędem, nie wynikiem pomiaru. Surowe rekordy JSON są wypisywane w `stdout.log`. Używać oddzielnego katalogu logów dla przebiegów, które mają zostać zachowane.

## Weryfikacja zmiany

- Wybrane long: **2/2 PASS**, kod 0, 15,70 s wraz z uruchomieniem procesu; zewnętrzny limit 240 s.
- Pozostałe long i testy `.disabled` nie były uruchamiane w tym odbiorze.
- Nie powtarzano standardu aplikacji: zmiana dotyczy wyłącznie izolowanego zestawu long i jego dokumentacji; ostatni odebrany standard wynosił 1677 PASS i 1 istniejący SKIP.
