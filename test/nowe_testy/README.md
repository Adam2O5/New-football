# Nowe testy — etap 0

Etap I00 przygotowany do review, 15 października 2026. Kod aplikacji nie został zmieniony. Etap 1 wymaga osobnej zgody po review i commicie użytkownika.

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
