# Pomiary gotowych operacji rynku godzinowego — 30 października 2026

Status: wykonana pozostała lokalna część pomiarów etapu 3. Profil Android nadal wymaga urządzenia. Punkt odniesienia: `5b296a9` wraz z niezatwierdzonymi jeszcze zestawami pomiarów symulacji i rynku. [Surowe rekordy](contract-market-baseline-2026-10-30.json) zachowują próbki i wynik procesu.

## Środowisko i dane

Windows x64, Dart 3.11.1, Flutter 3.41.4, Flutter test/JIT, seed 123. Dwa rozmiary: 1 i 30 zespołów. Klub gracza ma 12 zawodników i limit płac 1 mld, aby kontrolowany kontrakt nie był odrzucony z powodu zapełnienia składu lub cap. Pozostałe kluby zachowują wygenerowane składy. W puli jest 200 wolnych agentów, a wybrany cel znajduje się na końcu listy. To fixture obciążeniowy, nie skalibrowany stan prawdziwego rynku.

Konfiguracje AI wszystkich klubów są `null`; brak arkuszy RFA i ofert rywali. Publiczne rozstrzygnięcie godziny przechodzi przez zwykłą orkiestrację rynku, ale nie ma klubów, dla których można wygenerować decyzje AI. Nie reaktywowano testów odroczonych.

## Ręczne operacje

Tydzień 47, wtorek, FA-I. Każda z sześciu serii (0 oraz 1–5) zawiera 20 niezależnych powtórzeń na tym samym stanie wejściowym:

1. `submit-offer`: rzeczywiste złożenie oferty 60 mln na dwa lata przez `submitPlayerOffer`; wynik musi istnieć i mieć score co najmniej 70.
2. `resolve-waiting-hour`: poza stoperem negocjacja z tej oferty jest ustawiana jako zapisany stan `waiting`, z terminem godziny 2. Pomiar obejmuje publiczne `resolveHour` dla godziny 2. Wynik musi mieć `pendingFinalization`.
3. `finalize-offer`: publiczna finalizacja, zakończona podpisaniem wskazanego gracza, kontraktem 60 mln/dwa lata, usunięciem gracza z FA i statusem `completed`.

Stan waiting jest celowo przygotowany, a nie uzyskany reakcją na tę wysoko ocenioną ofertę. Scenariusz mierzy gotową gałąź rozstrzygania zapisanej negocjacji. Nie jest symulacją autonomicznego rynku ani dziesięciu następujących po sobie godzin. Między powtórzeniami wracamy do tego samego fixture’u; nie podpisujemy kolejno 20 graczy.

Asercje i przygotowanie waiting są poza stoperami. Test sprawdza również nienaruszone pozostałe kluby i wejściowy roster/pulę/negocjacje. Nie mierzymy tu kontrolera, dysku ani UI. Komunikaty domenowe i walidacja ich tekstu w trybie test/debug wchodzą w koszt operacji, ponieważ należą do rzeczywistego wywołania usługi.

## Osobna próba lookupów

Dwa warianty po 100 wywołań na serię: ten sam snapshot oraz nowy snapshot przy każdym wywołaniu. Użyto istniejącego publicznego wejścia `submitQualifyingOffer` z nieistniejącym właścicielem. To celowa próba diagnostyczna: kod wykonuje lookup gracza, a następnie odrzuca operację przed negocjacją. Nie przedstawiamy jej jako udanej oferty QO ani kosztu podpisywania kontraktu.

Listy składów i FA są osłonięte licznikiem odczytów elementów. W tej konkretnej ścieżce po lookupie nie ma dalszych odczytów tych populacji. Pełna przebudowa indeksu odczytuje każdą pozycję raz, więc liczba odczytów podzielona przez rozmiar populacji daje liczbę przebudów. Prawa draftowe są puste. Test wymaga dokładnie **1 przebudowy na 100 lookupów tego samego stanu** i **100 przebudów dla 100 nowych snapshotów**. Licznik nie jest dodawany do kodu produkcyjnego.

To pomiar obecnego kontraktu cache. Zmiana Inbox, która tworzy nowy snapshot ligi, nadal unieważnia indeks. Próba nie porównuje starej implementacji z nową; nie wyciągamy z niej procentowego przyspieszenia aplikacji. Wariant nowego snapshotu obejmuje również płytkie `copyWith`.

## Wyniki

Podsumowania obejmują pięć próbek 1–5; przebieg 0 jest osobno w JSON i nie oznacza zimnego startu VM. Poniżej mediana oraz min–max w ms **na całą serię**, z liczbą operacji w nazwie. Nie raportujemy p95. Tryby są wykonywane w stałej kolejności, a pomiary podlegają JIT/GC i rozrzutowi hosta.

### Zespoły: 1

- `submit-offer` (20 operacji): **2.581 ms**, zakres 2.199–3.284 ms.
- `resolve-waiting-hour` (20 operacji): **2.763 ms**, zakres 2.574–4.052 ms.
- `finalize-offer` (20 operacji): **3.587 ms**, zakres 3.350–5.118 ms.
- `lookup-same-snapshot` (100 operacji): **0.384 ms**, zakres 0.366–0.543 ms.
- `lookup-new-snapshot` (100 operacji): **2.306 ms**, zakres 1.972–3.536 ms.

### Zespoły: 30

- `submit-offer` (20 operacji): **2.461 ms**, zakres 2.207–2.872 ms.
- `resolve-waiting-hour` (20 operacji): **4.446 ms**, zakres 3.859–5.154 ms.
- `finalize-offer` (20 operacji): **4.800 ms**, zakres 4.477–5.830 ms.
- `lookup-same-snapshot` (100 operacji): **0.651 ms**, zakres 0.388–0.919 ms.
- `lookup-new-snapshot` (100 operacji): **13.315 ms**, zakres 12.577–13.746 ms.

## Decyzja po pomiarach desktopowych

Próba potwierdza skuteczność cache dla powtórzeń na tym samym snapshotcie oraz jego świadome unieważnianie po zmianie snapshotu. Koszt przebudowy rośnie wraz z liczbą zawodników. Same te dane nie uzasadniają nowego mechanizmu współdzielenia indeksu między różnymi stanami ligi: poprawność po zmianie zawodnika nadal ma pierwszeństwo.

Zakończono lokalne baseline’y zapisu, komend/normalizacji, ograniczonego pipeline’u dnia i ręcznych operacji rynku. **Nie rozpoczynamy etapu 4**, dopóki profil na docelowym urządzeniu nie wykaże istotnego kosztu i nie pozwoli ustalić budżetu. To cztery odrębne scenariusze, nie całościowy pomiar gry ani odbiór odroczonych mechanik.

## Powtórzenie przebiegu

Z katalogu repozytorium, PowerShell 7, Windows, po pobraniu zależności:

```powershell
. ./scripts/test_support.ps1
$marketBin = Split-Path -Parent (Get-Command flutter -CommandType Application | Select-Object -First 1).Source
$marketDart = Join-Path $marketBin 'cache/dart-sdk/bin/dart.exe'
$marketSnapshot = Join-Path $marketBin 'cache/flutter_tools.snapshot'
$marketResult = Invoke-BoundedTestProcess -Executable $marketDart -Arguments @($marketSnapshot, 'test', '--no-pub', '--reporter', 'expanded', 'test/performance/long/contract_market_measurements_long.dart') -WorkingDirectory (Get-Location).Path -LogDirectory ((Get-Location).Path + '/build/market-measurements-local') -TimeoutSeconds 240
$marketResult
```

Na systemach uniksowych użyć pliku `dart`. Stosować osobne katalogi logów dla zachowywanych przebiegów. Standard nadal pomija pliki long.

## Weryfikacja

- Rynek: 4 testy; symulacja: 4 testy. **Wspólny końcowy przebieg 8/8 PASS**, kod 0, 5,73 s wraz z uruchomieniem procesu, zewnętrzny limit 240 s. Log: `build/remaining-measurements-final/`.
- Sprawdzono kompletność 10 podsumowań rynku, po pięć próbek. Mediany/min/max przeliczono niezależnie z rekordów, a liczby przebudów są asercjami testu.
- Analiza obu zmienionych long: bez uwag. Standard aplikacji nie był powtarzany po samych zmianach pomiarowych; ostatni odebrany wynik: 1677 PASS, 1 istniejący SKIP. Pozostałe long i `.disabled` pozostają poza tym wykonaniem.
