# Pomiary pipeline’u dnia i workera — 30 października 2026

Status: wykonany kontrolowany pomiar jednego dnia i serii pięciu dni bez meczów oraz decyzji AI. Punkt odniesienia: `5b296a9` z dodanym testem long. Kod produkcyjny pozostaje bez zmian. [Surowe rekordy](simulation-pipeline-baseline-2026-10-30.json) zawierają wszystkie próbki i wynik ograniczonego procesu.

## Środowisko i fixture

Windows x64, Dart 3.11.1, Flutter 3.41.4, Flutter test/JIT. Seed 123. Warianty: pierwszy zespół wygenerowanej ligi albo wszystkie 30 drużyn (780 zawodników). Stan przygotowany jest poza pomiarem:

- tydzień 2, wtorek (dzień 2), faza regularna; seria pięciu dni wykonuje dni 2–6 i kończy się na dniu 7;
- pusty terminarz, brak wskazanego zespołu gracza, konfiguracja AI każdego klubu ustawiona na `null`;
- rynek kontraktowy pominięty przez `resolveContractMarket: false`;
- brak kontuzji; początkowa stamina 40, aby sprawdzać rzeczywistą regenerację;
- wcześniej wyliczona tabela siły oraz uzgodnione kontrakty i składy.

W teście jest wykonywany prawdziwy `DayPipeline`: obsługa początku dnia, istniejące kontrole kalendarza, regeneracja, przesunięcie daty i normalizacja wyniku. Pusty terminarz nie pozwala wejść do silnika, a brak konfiguracji AI powoduje pominięcie zarządzania składami AI. Seria nie wykonuje niedzieli, zatem nie uruchamia tygodniowego rozwoju i eventów. Nie jest to reprezentatywny pomiar całego sezonu ani dnia meczowego.

## Tryby i metoda

- `inline`: obliczenia na izolacie wywołującym przez istniejący `InlineSimulationRunner`.
- `worker-cached`: istniejący `IsolateSimulationRunner`; pierwszy dzień serii dostaje pełny fixture, następne dni dostają dokładnie zwrócony obiekt ligi. Pozwala to wykorzystać istniejącą pamięć stanu po stronie workera.
- `worker-full`: klient przekazuje `league.copyWith()` przy każdym kroku, wymuszając ponowny transport ligi. Ten wariant występuje tylko dla pięciu dni, ponieważ dla jednego dnia pierwszy pełny payload byłby taki sam jak w `worker-cached`.

Każdy tryb wykonuje przebieg 0 oraz pięć kolejnych próbek 1–5. Między próbkami wraca do tego samego wejścia, więc w każdym początku serii worker ponownie otrzymuje pełny stan. Worker żyje przez wszystkie próbki danego trybu; jest zamykany w `finally`. Nie trzymamy workera pomiędzy różnymi trybami.

Przebieg 0 workera obejmuje jego uruchomienie i konstrukcję pipeline’u. Późniejsze próbki korzystają z działającego izolatu. Dla inline konstrukcja runnera jest poza stoperem. Pierwszych przebiegów nie porównujemy więc jako równoważnych pomiarów inicjalizacji. Ponadto przed pomiarami istnieje nieczasowana referencja inline; żadnego przebiegu nie nazywamy zimnym startem VM.

Czas obejmuje całą serię wywołań `advanceDay`, oczekiwanie na odpowiedzi, transport i zaplanowanie kontynuacji; w `worker-full` także utworzenie płytkiej kopii na wejściu. Asercje, generowanie fixture’u, wyliczenie referencji, logowanie i sprzątanie są poza stoperem. Wynik nie jest pomiarem samego czasu kopiowania danych między izolatami.

Nie mierzymy zapisu, odrysowania UI, pacingu kalendarza, klatek, RSS ani alokacji. W testach wyłączono rynek i nie reaktywowano żadnego `.disabled`. Nie zmieniono zasad wykonania aplikacji.

## Kontrola poprawności

Każdy przebieg musi dać pełny stan ligi równy referencji inline, a nie tylko identyczną datę. Dodatkowo test sprawdza dzień po każdym kroku, brak meczu/eventu/urgent pause, pusty terminarz i Inbox, wzrost staminy oraz niezmieniony stan wejściowy. W tak ograniczonym scenariuszu nie powstają losowe UUID wiadomości, więc pełne porównanie nie wymaga usuwania pól z wyniku.

## Wyniki

Poniżej mediana i zakres min–max z pięciu kolejnych próbek, w milisekundach **na całą serię**. JSON zachowuje mikrosekundy oraz liczbę dni. Nie wyliczamy p95 z pięciu próbek.

### Zespoły: 1, dni w serii: 1

- `inline`: **0.279 ms**, zakres 0.274–0.448 ms.
- `worker-cached`: **0.968 ms**, zakres 0.648–1.666 ms.

### Zespoły: 1, dni w serii: 5

- `inline`: **1.159 ms**, zakres 1.117–1.403 ms.
- `worker-cached`: **2.528 ms**, zakres 2.355–3.340 ms.
- `worker-full`: **2.398 ms**, zakres 2.049–2.591 ms.

### Zespoły: 30, dni w serii: 1

- `inline`: **1.797 ms**, zakres 1.478–1.985 ms.
- `worker-cached`: **4.753 ms**, zakres 3.420–6.077 ms.

### Zespoły: 30, dni w serii: 5

- `inline`: **3.416 ms**, zakres 2.805–6.683 ms.
- `worker-cached`: **9.499 ms**, zakres 6.511–11.160 ms.
- `worker-full`: **10.795 ms**, zakres 8.071–15.782 ms.

## Interpretacja i dalsza decyzja

Na tak lekkim scenariuszu narzut transportu i obsługi izolatu może stanowić znaczną część całego czasu. Umieszczenie obliczeń poza UI nie musi skracać czasu zakończenia operacji: jego rolą jest także zachowanie responsywności aplikacji, której ten test nie mierzy. Nie proponujemy na tej podstawie przenoszenia symulacji na izolat UI ani zmiany protokołu workera.

Dla pięciodniowej serii 30 drużyn w zapisanym przebiegu mediana jest niższa dla `worker-cached` niż `worker-full`. To punkt odniesienia dla istniejącej optymalizacji transportu, nie statystyczny dowód stałego procentowego przyspieszenia. Pięć próbek, rozrzut, GC/JIT i kolejność wykonywania trybów ograniczają wniosek. Przy potrzebie rozstrzygnięcia małej różnicy należy zwiększyć próbę i zmieniać kolejność trybów.

Odbiór obejmuje wyłącznie kontrolowany pipeline bez meczów, rynku i granicy tygodnia. Do zakończenia etapu 3 nadal potrzebne są pomiary gotowych operacji rynku godzinowego i profil aplikacji na urządzeniu. Nie rozpoczynamy warunkowej optymalizacji normalizacji ligi z etapu 4.

## Powtórzenie przebiegu

Z katalogu repozytorium w PowerShell 7, po pobraniu zależności:

```powershell
. ./scripts/test_support.ps1
$simulationBin = Split-Path -Parent (Get-Command flutter -CommandType Application | Select-Object -First 1).Source
$simulationDart = Join-Path $simulationBin 'cache/dart-sdk/bin/dart.exe'
$simulationSnapshot = Join-Path $simulationBin 'cache/flutter_tools.snapshot'
$simulationResult = Invoke-BoundedTestProcess -Executable $simulationDart -Arguments @($simulationSnapshot, 'test', '--no-pub', '--reporter', 'expanded', 'test/performance/long/simulation_pipeline_measurements_long.dart') -WorkingDirectory (Get-Location).Path -LogDirectory ((Get-Location).Path + '/build/simulation-measurements-local') -TimeoutSeconds 240
$simulationResult
```

Przykład dla Windows; na systemach uniksowych użyć pliku `dart`. Stosować osobny katalog logów dla przebiegów do zachowania. Log lokalnego odbioru: `build/simulation-measurements-final/`. Rekordy są wypisywane synchronicznie, aby nie tracić końca logu przy zamknięciu VM.

## Weryfikacja

- **4/4 PASS**, kod 0, 4,73 s wraz z uruchomieniem procesu; limit zewnętrzny 240 s, timeout 2 min na przypadek.
- Sprawdzono kompletność 10 podsumowań, po pięć próbek; mediany/min/max przeliczono niezależnie z surowych rekordów.
- Zmiana dotyczy wyłącznie nowego long i dokumentacji. Standard aplikacji pozostaje poza ponownym wykonaniem; ostatni odebrany wynik to 1677 PASS, 1 istniejący SKIP. Pozostałe long i wszystkie `.disabled` poza wykonaniem.
