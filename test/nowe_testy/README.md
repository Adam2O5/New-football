# Nowe testy — etapy 0, 1 i rozpoczęty etap 2

Etapy 0 i 1 zostały zaakceptowane i zapisane przez użytkownika w commitach `dc6e454` i `b4048fb`. **Etap 2 jest rozpoczęty i zatrzymany do decyzji użytkownika z powodu dodatkowego błędu wiadomości sztabu.** Nie wykonano automatycznego commita. Poniższe wyniki etapów 0 i 1 pozostają historycznym punktem odniesienia.

## Etap 2 — stan częściowy, 15 października 2026

- Pełny nowy zestaw: **51 testów przechodzi, 2 nie przechodzą**. Analiza zmienionego zakresu i nowych testów nie zgłasza uwag. Nie wykonywano jeszcze kompilacji bundle ani końcowego odbioru etapu.
- Dwa nieprzechodzące scenariusze w `staff_season_messages_test.dart` odtwarzają istniejący błąd: `StaffService._msg` przesyła tylko `_legacyTitle`/`_legacyBody`, podczas gdy szablony `msg_staffGrowth_title` oraz `msg_retirementStaff_title` wymagają danych domenowych. Pierwszy zgłasza brak `subjectName`, drugi brak `staffName`. Nie zmieniono tego nadawcy ani tych szablonów w rozpoczętym wdrożeniu.
- Proponowane rozszerzenie I04: przekazać rzeczywiste dane członka sztabu i zmiany atrybutów; dopasować PL/EN do faktycznego momentu emerytury. Zachować walidację tekstu. Naprawa czeka na decyzję użytkownika, zgodnie z jego poleceniem zatrzymania przy nieprzewidzianych komplikacjach.
- `phase_two_window_test.dart`: 11 scenariuszy dostępności tygodni, początku w 48/52/1/45, indywidualnego deadline i zamknięcia pomimo waiting. `postseason_finalization_test.dart`: 3 scenariusze końcowego wyniku gracza, nieukończonego sezonu i idempotencji/walidacji stanu częściowego. Te 14 scenariuszy przechodzi.
- Rozpoczęty diff obejmuje I04–I10: treść wiadomości kontraktowych i QO, stabilny seed terminarza, wybór klubu, część strumieni RNG, granicę FA II, finalizację postseason i mapowanie 52 tygodni. **Nie oznacza to zakończenia żadnego pełnego odbioru etapu.** W szczególności pozostają: testy generatorów i dwóch osobnych procesów, referencyjne daty, odtwarzalność zdarzeń sezonowych, pełne scenariusze wiadomości/rynku, miejsce 10/11 i porównanie ścieżek postseason oraz testy przycisków kalendarza.
- Rozpoczęte I05 podnosi schemat z 24 do **25**. Po wznowieniu i ukończeniu etapu review wymaga nowych karier, zgodnie z przyjętą polityką braku migracji. Dotychczasowych zapisów nie usunięto.
- Logi diagnostyczne: `reports/lib-audit-2026-10-13/stage-2-staff-blocker.txt`, `stage-2-partial-analyze.txt`, `stage-2-partial-tests.txt`. Kod wszystkich nowych testów pozostaje w `test/nowe_testy/`.

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
