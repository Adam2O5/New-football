# Nowe testy — etapy 0, 1 i 2

Etapy 0 i 1 zostały zaakceptowane i zapisane przez użytkownika w commitach `dc6e454` i `b4048fb`. Część pośrednia etapu 2 została zapisana przez użytkownika w `553198c`. **Etap 2 (I04–I10) jest ukończony i przygotowany do review.** Uzupełniający diff nie został zacommitowany. Wyniki wcześniejszych etapów poniżej zachowują historyczny punkt odniesienia.

## Wynik etapu 2 — 16 października 2026

- **93 testy przechodzą**: 37 wcześniejszych nowych testów i 56 scenariuszy etapu 2. Uruchamiano wyłącznie `test/nowe_testy/`.
- Analiza zmienionego zakresu `lib` oraz nowych testów: **bez uwag**. Kompilacja `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany `build/flutter_assets/kernel_blob.bin`. To lokalny debug bundle; nie wykonywano instalacji, wdrożenia, budowania APK ani pomiarów profilu na urządzeniu.
- `SaveSchema.currentVersion` wynosi **25**, podniesiony w części pośredniej ze względu na stabilny kontrakt odtwarzania dat. Review wykonujemy na nowych karierach. Starych zapisów nie usunięto ani nie migrowano.
- Nie zmieniano implementacji w `core/ai` i `core/simulation`, plików generowanych, assets ani starych testów. Testy integracji dostarczają gotowe wyniki zamiast uruchamiać silnik meczu.

### Zmiany zachowania I04–I10

1. **I04 / F15:** odpowiedzi kontraktowe pokazują warunki rzeczywistej kontroferty. Usunięto wymaganie dodatkowych warunków i uzasadnienia odmowy, których model nie przechowuje; zapewniono rolę sztabu w odpowiedziach. QO potwierdza już złożoną ofertę i nie tworzy ponownej decyzji z fikcyjnym terminem. Walidacja PL/EN pozostaje aktywna.
2. **Zaakceptowane rozszerzenie I04:** wiadomości rozwoju i emerytur sztabu otrzymują rzeczywiste dane osoby, klubu i oceny; payload rozwoju zawiera zmienione atrybuty. Tekst emerytury opisuje wykonane odejście. Analogiczny brak argumentu w wiadomości emerytury zawodnika uzupełniono rokiem rozstrzyganego sezonu.
3. **I05 / F04:** dni spotkań pochodzą ze stabilnego hasha, z osobnym znacznikiem kalendarza. Publiczny helper i wspólne źródło dat pozostają zachowane. Obecni odbiorcy kalendarza nadal używają dotychczasowego domyślnego seeda `0`; nie zmieniano tego na osobny terminarz każdej kariery. Referencyjne daty dla kilku seedów chronią regułę odtwarzania.
4. **I06 / F08:** dokładnie jeden wybrany klub otrzymuje `ai: null`; nieznane ID jest odrzucane. Ponowne tworzenie kariery i wyświetlenie podglądu klubów nie zmieniają deterministycznych ID sztabu.
5. **I07 / F10:** oddzielne strumienie generacji rosterów, klasy draftu, początkowego sztabu i wolnych agentów; klasa i istniejący mock są odtwarzalne. Interaktywna loteria otrzymuje seed kariery. Rozwój/emerytury sztabu i emerytury zawodników korzystają z seeda sezonu, rodzaju zdarzenia i ID osoby; przestawienie osób nie przesuwa ich niezależnych losowań. Zachowano wstrzykiwanie RNG i dotychczasowe prawdopodobieństwa.
6. **I08 / F05:** FA II rozpoczęta pod koniec roku kończy się w kolejnym roku. Ostatni slot dzienny tygodnia 45 działa; pierwszą zamkniętą chwilą jest początek tygodnia 46. Waiting ani pominięcie indywidualnego deadline nie omija zamknięcia okna. Porównania rozróżniają godzinę 10 od godziny 0 następnego dnia. Po meczu gracza rynek rozstrzygany jest na dacie meczu, przed przesunięciem daty.
7. **I09 / F07:** postseason powstaje po wszystkich wynikach sezonu regularnego, także po ostatnim wyniku gracza. Ponowienie zachowuje istniejące mecze i rozstawienie; niekompletna inicjalizacja zgłasza jawny błąd. Walidacja uwzględnia zarówno trwający play-in, jak i jego zakończony wynik. Nie dodano flagi do save'a.
8. **I10 / F14:** wspólne mapowanie dat obejmuje 52 tygodnie w kalendarzu i jego widoku na Home. Przeszłe i niesupportowane daty mają wyłączoną symulację.

### Scenariusze etapu 2

- `contract_messages_test.dart` — 11: counter/reject/accept, finalizacja gracza i sztabu, QO oraz odpowiedzi po waiting; rzeczywiste serwisy ofert i teksty PL/EN.
- `staff_season_messages_test.dart` — 2: rozwój i emerytura, teksty obu języków i rzeczywista zmiana oceny/atrybutów.
- `seeded_generation_test.dart` — 9: wybór klubu, nieznane ID, ponowne użycie fabryki i podglądu, klasy draftu niezależne od historii serwisu, referencyjne dni i odstęp meczów, osobne procesy Dart przed i po save/load.
- `support/determinism_process.dart` — pomocniczy punkt wejścia osobnej VM używany przez powyższy test. Zwraca dane domenowe; nie jest plikiem aplikacji ani próbą poza folderem nowych testów.
- `season_randomness_test.dart` — 3: rozwój/emerytury sztabu oraz emerytury zawodników po save/restart i zmianie kolejności, seeded loteria i możliwość wstrzyknięcia RNG.
- `phase_two_window_test.dart` — 13: tygodnie 45/46/47/48/52/1, finalny slot i waiting, początek nowego roku, indywidualne expiry i rekord terminalny.
- `postseason_finalization_test.dart` — 8: wynik zmieniający miejsca 6/7 i 10/11, równoważność pauzy/wznowienia i ścieżki automatycznej z podanym wynikiem, niepełny sezon, idempotencja, stan częściowy, zakończony play-in jednej/obu konferencji i data rozstrzygania rynku po meczu.
- `calendar_screen_test.dart` — 9: mapowanie, wybór tygodni 47–52, stany rzeczywistego przycisku oraz kliknięcie uruchamiające kontrolowany krok symulacji do przyszłej daty.
- `match_date_replay_test.dart` — 1: rzeczywisty zapis do katalogu tymczasowego dzień przed spotkaniem, load i zatrzymanie obu ścieżek na tym samym meczu bez pominięcia kolejki.

### Odbiór i ręczne review

Polecenia:

```powershell
dart analyze lib/app lib/data lib/core/services lib/core/random/seeds.dart lib/core/models/seed_data_generator.dart lib/core/models/game_save.dart lib/core/balance/message_catalog.dart lib/core/balance/message_templates_pl.dart lib/core/balance/message_templates_en.dart lib/main.dart test/nowe_testy
flutter test --no-pub test/nowe_testy --concurrency=1 --reporter expanded
flutter build bundle --debug --no-pub
```

Ręcznie, na nowej karierze:

1. Wybierz inny klub europejski niż pierwszy albo klub drugiej konferencji. Sprawdź nazwę swojego klubu w grze i skład po utworzeniu kariery.
2. W kalendarzu zanotuj datę najbliższego meczu swojego zespołu. Zapisz dzień przed nim, wyjdź do menu i wczytaj. Data i rywal mają pozostać takie same; symulacja ma doprowadzić do tego spotkania.
3. Na rynku złóż ofertę, odczytaj odpowiedź w skrzynce i — przy akceptacji — sfinalizuj umowę. Sprawdź także wiadomość kontroferty, jeśli ją otrzymasz. Przełącz PL/EN: szczegóły mają być widoczne bez tekstu zastępczego. Rozwój i emerytury są dodatkowo sprawdzane automatycznie, bez potrzeby ręcznego rozgrywania całego sezonu.
4. W kalendarzu przejdź do dat końca cyklu (tygodnie 48–52); wybierz przyszły dzień. Wybór i przycisk symulacji mają działać. Sprawdź też datę sprzed aktualnego dnia — symulacja ma być wyłączona. Pełne wykonanie symulacji przez te tygodnie oraz granice FA II/play-in sprawdzają nowe testy.

Logi: `reports/lib-audit-2026-10-13/stage-2-final-analyze.txt`, `stage-2-final-tests.txt`, `stage-2-final-build.txt`. Raport audytu pozostaje zamknięty; aktualny status wykonania jest w planie i tym README.
## Wynik etapu 1

- **37 testów przechodzi**, w tym wszystkie trzy wcześniejsze regresje F01–F03.
- Analiza `lib/app`, `lib/data`, `lib/core/services`, `lib/main.dart` i `test/nowe_testy` nie zgłasza uwag.
- Kompilacja `flutter build bundle --debug --no-pub` zakończyła się powodzeniem. To lokalny debug bundle, bez instalacji ani wdrożenia; nie wykonywano kompilacji APK ani profilu na urządzeniu.
- Schemat save'a pozostaje 24. Nie zmieniono modeli, formatu persystencji, generatorów ani wyłączonych implementacji AI/silnika/wymian. Wywołania wymian w kontrolerze objęto wspólną kolejką bez zmiany algorytmu placeholderów; bezpośrednie przepływy placeholderowego `trade_screen.dart` pozostają poza zakresem.
- Stare testy pozostają nieanalizowane i nieuruchamiane. Wszystkie nowe testy i helpery są w tym folderze.

### Zmiany zachowania

1. **I01 / F02:** bariera obejmuje trwający zapis i mutacje zlecone przed nią, nawet jeśli ich autosave został dopisany później. Niepotrzebne snapshoty są scalane. Błąd niezapisanej wersji jest dostępny do skutecznego ponowienia; nowszy udany zapis usuwa poprzedni błąd. Autosave pobiera najnowszy stan w kolejce, zachowując również metadane zmienione przez zarządzanie zapisami.
2. **I02 / F01:** odczyt, walidacja i publikacja ofert, finalizacji, counterów, RFA/QO, praw draftowych, sztabu i Combine odbywają się w jednym wpisie kolejki. Polecenia używają aktualnych osób/drużyn. Zmiana roli i zamiana miejsc w UI składu nie podmieniają rosteru starszą migawką. Jawne sloty XI (F09) pozostają zadaniem późniejszego etapu.
3. **I03 / F03:** asynchroniczne `clear()` zatrzymuje batch, czeka na zaczęty krok i zapisuje najnowszy stan przed wyjściem. Powtórne wyjście współdzieli tę samą operację. Nowe polecenia gry są blokowane podczas zmiany kariery. Load/create respektują tę samą granicę; spóźniony load A nie publikuje się po żądaniu B. Nieudany zapis lub load zachowuje wcześniejszą aktywną karierę i pozwala ponowić operację.
4. Menu czeka na zakończenie wyjścia i pokazuje istniejący lokalizowany komunikat błędu zapisu. Manualny save obsługuje błąd. Matchday przy nieudanym zapisie pokazuje błąd oraz ponowienie/powrót, zamiast rozpoczynać mecz. Lifecycle obsługuje wyjątek, a kontroler zachowuje możliwość ponowienia. Usunięcie aktywnego save'a korzysta z osobnej, ograniczonej do kolejki zarządzania ścieżki czyszczenia, aby nie odtworzyć usuniętego pliku.

### Nowe scenariusze etapu 1

- `game_controller_persistence_test.dart` — 8 testów: manualny zapis, F01–F03, bariera przed powstaniem autosave, trwałość informacji o błędzie, nowszy udany zapis i manualne ponowienie.
- `game_controller_lifecycle_test.dart` — 14 testów: wyjście podczas zapisu/kroku symulacji, powtórne kliknięcie, blokowanie nowych poleceń, anulowanie observera/pacera, load A → B, zapis przed przełączeniem/utworzeniem kariery, nieudane load/create, odzyskanie działania po błędzie i usunięcie aktywnego save'a.
- `game_controller_mutations_test.dart` — 6 testów: dwie oferty, aktualny roster przy usuwaniu sztabu z wygasłą umową, usunięty kandydat, zakończone Combine, błąd polecenia i metadane zmienione przed autosave.
- `career_navigation_test.dart` — 3 testy widgetowe: oczekiwanie menu na zapis, błąd i ponowienie wyjścia, błąd zapisu przed startem matchday. Bariery synchronizują rzeczywistą strefę async kontrolera z zegarem widgetów Fluttera.
- `support/controlled_simulation_runner.dart` — kontrolowany krok zmieniający datę; bez uruchamiania AI i silnika meczu.
- Istniejące 5 kontroli fixture'ów oraz test bazowych operacji repozytorium także przechodzą.

Polecenia odbioru:

```powershell
dart analyze lib/app lib/data lib/core/services lib/main.dart test/nowe_testy
flutter test --no-pub test/nowe_testy --concurrency=1 --reporter expanded
flutter build bundle --debug --no-pub
```

Do ręcznego review: wyjście do menu w czasie symulacji kalendarza i ponowne wczytanie daty; dwie operacje rynku wykonywane blisko siebie; manualny zapis i wejście do meczu. Awarię I/O oraz trzymane bariery sprawdzają nowe testy w pamięci, bez celowego uszkadzania zapisów użytkownika.

Wyniki pełnego uruchomienia są w [etap-1-test-results.txt](C:/Users/dadam/New-football/reports/lib-audit-2026-10-13/etap-1-test-results.txt). Folder `reports/` jest ignorowany przez Git; opis odbioru i wynik 37/37 pozostają w tym wersjonowanym README.

## Etap 0 — historyczny punkt odniesienia

## Punkt odniesienia

- Commit aplikacji: `7adf73e8fdeafd6fbc54a7c402b04a3da63ccefa` (`cleaning`). Katalog roboczy przed rozpoczęciem prac był czysty.
- Windows x64, Flutter **3.41.4 stable**, Dart **3.11.1**.
- Testy Flutter na komputerze, bez `pub get`, uruchamiane kolejno przez `--concurrency=1`. Pomiary nie są profilem wydajności Androida ani obietnicą takich samych czasów na telefonie.
- Dane mają seed **123**, aktualny schemat **24** i stałą datę utworzenia. Fixture'y wstrzykują RNG również do generatora klasy draftowej; ich powtarzalność nie oznacza naprawienia F10 w aplikacji.
- Repozytorium pamięciowe nie dotyka dysku. Test persystencji korzysta z nowego `Directory.systemTemp.createTemp` dla każdej próby i usuwa wyłącznie własny katalog w `finally`. Zapisy użytkownika nie są otwierane.
- Istniejące testy spoza `test/nowe_testy/` nie były analizowane ani uruchamiane.

## Zawartość

- `game_controller_persistence_test.dart` — kontrola manualnego zapisu oraz trzy regresje F01–F03 oczekujące poprawnego zachowania.
- `game_fixtures_test.dart` — sprawdzenie powtarzalności i przygotowania scenariuszy domenowych.
- `save_repository_baseline_test.dart` — trzy próby save/load/rename/duplicate na tym samym większym stanie, z kontrolą zachowania danych.
- `support/game_fixtures.dart` — jeden klub i FA do testów kolejki, FA II w tygodniu 48, roczny kontrakt przed rolloverem, zatrudniony i niezatrudniony sztab, kontuzjowany FA, końcówka sezonu z ręcznym wynikiem 3:0, para LB/RB oraz większy stan do pomiarów.
- `support/memory_save_repository.dart` — repozytorium z kontrolowanymi barierami rozpoczęcia i zakończenia zapisu.

W większym stanie jest **30 klubów, 780 zawodników, 870 zakończonych fixtures i 5 lat syntetycznej historii/statystyk**. Dane wyników i historii przygotowano bez symulowania pięciu sezonów. Mniejsze fixture'y dla dalszych etapów przygotowują wejścia; nie dowodzą jeszcze poprawności reguł kontraktów, skautingu, kalendarza ani leczenia.

## Uruchomienie i wynik odbioru

Z katalogu głównego projektu:

```powershell
flutter test --no-pub test/nowe_testy --concurrency=1 --reporter expanded
dart analyze lib/app lib/data lib/core/services test/nowe_testy
```

Wynik przed naprawami: **7 passed, 3 failed**. Kod wyjścia zestawu testowego wynosi **1** i na etapie 0 jest oczekiwany. Testów F01–F03 nie pominięto ani nie odwrócono ich oczekiwań:

- **F01:** po zleceniu zmiany dnia i oferty oczekiwany dzień to 2, rzeczywisty to 1.
- **F02:** flush nie powinien zakończyć się przed zwolnieniem bariery zapisu; obecnie kończy się wcześniej.
- **F03:** opuszczenie kariery przez obecne publiczne `clear`, wywoływane także przez menu, powinno zachować opublikowany dzień 2; repozytorium zachowuje dzień 1. Jeżeli etap 1 wprowadzi dedykowaną metodę wyjścia, test należy podłączyć do tego publicznego przepływu. Test interakcji menu i obsługi błędu powstanie przy naprawie I03.

Po etapie 1 powyższe regresje mają przechodzić. Kolejne scenariusze i testy błędów powstają bezpośrednio przed właściwymi naprawami; etap 0 nie deklaruje kompletnego pokrycia całego planu.

Test save/load uwzględnia zamierzoną aktualizację `meta.updatedAt`: sprawdza, że znacznik mieści się między rozpoczęciem i zakończeniem zapisu, a pozostały obiekt jest identyczny. Rename i duplicate są następnie porównywane z wczytanym stanem i oczekiwanymi metadanymi. Wszystkie trzy próby przeszły te porównania.

## Bazowe pomiary persystencji

Czasy obejmują całe wywołanie publicznej operacji, wraz z jej obecną weryfikacją i transportem. Zwykły save korzysta z domyślnego izolatu; rename/duplicate zachowują obecną implementację. Przygotowanie fixture'a, dodatkowe asercje po operacji i sprzątanie katalogu nie są wliczone w jej czas. Nie wykonywano osobnej rozgrzewki, dlatego podano wszystkie próbki oraz mediany. Nie mierzono jeszcze szczytu pamięci ani czasu klatek.

- **Save:** 188,969 / 118,767 / 111,910 ms; mediana **118,767 ms**.
- **Load:** 237,567 / 165,384 / 162,415 ms; mediana **165,384 ms**.
- **Rename:** 568,596 / 504,068 / 503,829 ms; mediana **504,068 ms**.
- **Duplicate:** 463,108 / 580,877 / 441,025 ms; mediana **463,108 ms**.
- Plik po save: **4 836 444 B** we wszystkich próbach.
- Plik po rename: **9 897 118 B** we wszystkich próbach.
- Duplikat: **9 897 123 B** we wszystkich próbach.

Wzrost rozmiaru po rename/duplicate potwierdza punkt O03 dla tego wejścia. Pomiary zachowujemy do porównania z późniejszą implementacją; nie są progami czasowymi, których zwykły test ma bezwzględnie wymagać.

Pełny wynik uruchomienia zapisano w [etap-0-test-results.txt](C:/Users/dadam/New-football/reports/lib-audit-2026-10-13/etap-0-test-results.txt). Folder `reports/` jest ignorowany przez Git; to README zawiera komplet najważniejszych wyników potrzebnych do review i commita.
