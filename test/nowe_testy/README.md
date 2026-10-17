# Nowe testy — etapy 0–8

Etapy 0–7 zostały zaakceptowane i zapisane przez użytkownika: `dc6e454`, `b4048fb`, `553198c`, `f8e45e1`, `5762f4f`, `0f2fd43`, `5598811`, `6e9cea2` oraz etap 7 w `8293be2`. R04 etapu 8 zapisano w `d010cec`, R05 w `c567d39`, R06 w `4677f98`, R07 w `1fd485b`, R08 w `eef0c73`, R09 w `5cacf87`, R10 w `e6ee6aa`, R11 w `a454528`, R12 w `14d5906`. **R13 (repozytorium zapisów) jest ukończone i gotowe do review.** Zrealizowano podziały R04–R13 etapu 8; zmiany R13 pozostają bez commita. Etap 9 nie został rozpoczęty. Wyniki wcześniejszych grup/etapów poniżej są historycznym punktem odniesienia.

## Etap 8 — R13: repozytorium zapisów — 17 października 2026

Punkt wyjścia: `14d5906` (R12), czyste repozytorium. Wydzielono **19 metod do dwóch prywatnych miksinów** w `lib/data/`, połączonych z dotychczasową biblioteką przez `part`/`part of`. Publiczne operacje pozostają metodami instancji `SaveRepository`, dostępnymi przez dotychczasowy import i możliwymi do nadpisania. Nie wykonano commitów.

### Podział

- **`save_repository.dart`: 836 → 375 linii.** Pozostają konstruktor, konfiguracja i wszystkie pola, statyczny licznik/alias schematu/inicjalizacja koordynatora, diagnostyka sztabu, rozwiązywanie ścieżek, list/inspect/dostępność ID/load/save/delete oraz całe `_withAccess` (34 dotychczasowe elementy). W tym samym pliku znajduje się kontrakt `_SaveRepositoryShared`.
- **`save_repository_raw_operations.dart` (291):** dziewięć metod: `readRawSave`, `duplicateRaw`, `_duplicateLocked`, `_duplicateRaw`, `renameRaw`, `_renameLocked`, `_renameRaw`, `_readRawSaveJson`, `_validateRawSaveJson`. Przeniesiono całe ścieżki odczytu, przejścia do izolatu, walidacji, publikacji i odzyskiwania po błędzie, bez nowych wrapperów.
- **`save_repository_transaction.dart` (239):** dziesięć metod: `_recoverAfterFailure`, `_prepareTwoFileTransaction`, `_writeTemporary`, `_writeJsonTemporary`, `_commitPreparedFiles`, `_publish`, `_readCommittedJson`, `_verifyRawCommit`, `_verifyCommittedSave`, `_jsonValuesEqual`. Zapis UTF-8 pozostawiono razem z transakcją zgodnie z opcją S14; nie tworzono krótkiego osobnego pliku encodera.

Istniejące `save_directory_coordinator.dart`, `save_recovery.dart` i `save_repository_types.dart` pozostały **identyczne bajtowo**. Nie przenoszono ponownie typów z R05 ani nie rozbijano gotowej implementacji odzyskiwania.

### Jeden właściciel dostępu i ten sam protokół

Kontrakt `_SaveRepositoryShared` zawiera **15 deklaracji abstrakcyjnych**: cztery gettery i 11 metod, bez stanu ani implementacji. Oba miksiny mają `on _SaveRepositoryShared`; dodano **15 adnotacji `@override`**. Nie dodano nowego repozytorium, kolejki, koordynatora ani warstwy transportu. Zależności, hooki, diagnostyka i wszystkie inicjalizatory pozostają w jednej instancji.

`_transactionSequence` nadal jest jednym statycznym polem `SaveRepository`. W przeniesionym `_prepareTwoFileTransaction` zapisano jego dotychczasowe użycie jako `SaveRepository._transactionSequence++`; zachowano wartość początkową, moment inkrementacji i konstrukcję ID z pid/czasu. Nie dodano kopii licznika w miksinie.

Całe `_withAccess` pozostaje w głównym pliku: wywołuje ten sam koordynator i recovery przed operacją. Obszar blokady, dostęp z izolatu i ścieżki `saveInIsolate` pozostają takie same. Przeniesione operacje workerów nadal korzystają z istniejących prywatnych metod, bez ponownego wchodzenia w zewnętrzną blokadę. Hooki nadal wymuszają pracę w izolacie wywołującym.

Zachowano kolejność: przygotowanie journalu, zabezpieczenie obu oryginałów, publikacja game/index, weryfikacja, commit marker, checkpoint i cleanup. Windows nadal korzysta z tej samej ścieżki displaced. Całe zakresy try/catch/finally, błędy, rollback i reguły zachowywania artefaktów pozostały bez zmian. Obsługa `SaveAmbiguousWriteException`, fingerprinty i blokady są nadal w tych samych istniejących implementacjach.

`_writeJsonTemporary` zachowuje compact UTF-8, chunk 64 KiB, zliczanie bajtów, flush i close w finally. `verifyTypedCommit` nadal domyślnie false, `saveInIsolate` true. Nie optymalizowano encodera, nie zmieniano schematu, formatu plików ani datowania metadanych. Rename/duplicate nadal zachowują nieznane pola raw i używają tej samej transakcji dwóch plików.

### Weryfikacja

- **Przed podziałem 50/50:** `save_transaction_recovery_test.dart`, `save_recovery_integrity_test.dart`, `save_directory_lock_test.dart`, `save_coordinator_startup_test.dart`, `save_management_boundary_test.dart`, `save_repository_baseline_test.dart`, `save_recovery_screen_test.dart`, `stage_six_persistence_test.dart`, `contract_boundary_save_test.dart`.
- Macierz obejmuje save/rename/duplicate, wyjątki I/O, przerwanie procesu w fazach prepared/publikacji/commit i displaced na Windows, pierwszy zapis, uszkodzony/niejednoznaczny journal lub parę plików, ponowienie odzyskiwania, wiele instancji/workerów i zwalnianie blokad, raw payload, diagnostykę sztabu, tryby z/bez izolatu i granice kontraktów po load.
- Jednorazowe porównanie SHA-256 z `14d5906`: **53/53 elementy klasy zachowały implementacje** — 19 przeniesionych, 34 pozostawione. Obejmuje sygnatury, ciała, komentarze i inicjalizatory; normalizacja dotyczy wyłącznie końców/zewnętrznych pustych linii, 15 nowych adnotacji oraz jednej kwalifikacji statycznego licznika.
- Sprawdzono kompletność, unikalność i kolejność elementów, importy, istniejące i nowe części, połączenia miksinów oraz brak implementacji/stanu w kontrakcie. Trzy dotychczasowe części zweryfikowano osobno SHA-256 plików, bez normalizacji bajtów.
- Nie dodano testów ani helperów; użyto istniejących scenariuszy zachowania w `test/nowe_testy/`. Nie dodano trwałych testów układu źródeł ani narzędzi w aplikacji. Manifest i wynik porównania znajdują się wyłącznie w ignorowanym folderze raportów.
- Formatowanie trzech plików Dart: bez dalszych zmian. Analiza `lib/app`, `lib/data` i `test/nowe_testy`: **bez uwag**.
- **Po podziale 221/221:** cały folder `test/nowe_testy/`, w tym wszystkie 50 scenariuszy bazowych. Nie uruchamiano starych testów.
- `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany kernel bundle; odbiór debug bez podłączonego urządzenia. `git diff --check`: bez uwag.
- Test odświeżeń nadal wskazuje Home: 5, Squad: 0, Standings: 0 przy pięciu zmianach daty. Organizacyjny podział nie stanowi nowej optymalizacji wykonania.

Schemat zapisu nadal **27**, bez migracji. Testy awarii modyfikują wyłącznie własne katalogi tymczasowe; nie używano rzeczywistych zapisów gracza. Nie analizowano ani nie zmieniano wyłączonych AI/simulation, plików generowanych, assets ani starych testów. Zamrożony raport audytu pozostał bez zmian.

Logi w `reports/lib-audit-2026-10-13/`: `stage-8-r13-before-tests.txt`, `stage-8-r13-repository-analyze.txt`, `stage-8-r13-all-tests.txt`, `stage-8-r13-analyze.txt`, `stage-8-r13-build.txt`, `stage-8-r13-movement-baseline.json`, `stage-8-r13-movement-check.txt`.

### Ręczne review R13

1. **Zapis i load:** w karierze zmień datę lub wykonaj operację, zapisz ręcznie, wróć do menu i wczytaj. Sprawdź aktualną datę i stan kariery; lista zapisów ma pokazywać odpowiadające metadane.
2. **Rename i duplicate:** zmień nazwę zapisu i utwórz kopię. Oryginał i kopia powinny być osobno widoczne i wczytywalne; zmiana nazwy nie powinna zmieniać danych gry. Można wykonać te operacje blisko siebie.
3. **Świeża kariera:** utwórz nową karierę, zapisz ją i ponownie wczytaj. Sprawdź również powrót do menu po autosave; dotychczasowe bariery zapisu nadal obowiązują.
4. **Review diffu:** jeden licznik i właściciel dostępu pozostają w `SaveRepository`, a recovery/koordynator/typy są nietknięte. Nie trzeba celowo przerywać aplikacji ani uszkadzać zapisów — pełną macierz awarii odtwarzają automatyczne testy na danych tymczasowych.

Grupa **R13** jest ukończona i gotowa do review. Zrealizowano wszystkie grupy organizacyjne R04–R13 etapu 8; zatrzymano pracę na tej granicy, bez commitów. Nie rozpoczęto etapu 9 (odbioru całego zakresu).

## Etap 8 — R12: duże klasy State ekranów i poprawka dialogów — 17 października 2026

Punkt wyjścia: `a454528` (R11). Prace wznowiono z dziesięcioma nowymi testami i opisem błędu z poprzedniego podejścia, bez wcześniejszych zmian produkcyjnych R12. Użytkownik polecił naprawić dialogi i dokończyć całą grupę. Wykonano kolejno FA, sztab, kontrakty, kalendarz i opcjonalną tabelę prospektów. Nie wykonano commitów.

### Poprawka cyklu życia kontrpropozycji

Przed podziałem oba `_counterDialog` kończyły `await showDialog(...)` i od razu zwalniały kontrolery w `finally`, chociaż animacja zamykania nadal używała pól tekstowych. Dwa izolowane testy odtwarzały `A TextEditingController was used after being disposed.`. Po autoryzowanej poprawce każdy dialog ma własny prywatny `StatefulWidget`/`State`: kontrolery są inicjalizowane w `initState` i zwalniane w `dispose` zawartości dialogu.

Zachowano osobne implementacje zawodnika i sztabu, treści, wartości domyślne i walidację: zawodnik nadal wymaga co najmniej jednego roku, sztab od jednego do czterech; nie zmieniano dodatkowo dopuszczalnych kwot. `ContractOffer` nadal przenosi `exception` i `rookiePickSlot`. Anulowanie zwraca null, zapis ten sam typ oferty. Nie dodano wspólnego formularza, opóźnień czasowych ani wyciszania wyjątków.

Nowy State dotyczy wyłącznie obu naprawianych dialogów. Właściciele głównych formularzy, zaznaczeń, kontrolerów ekranów i ich dispose pozostają bez zmian. Klasy dialogów są prywatne i znajdują się w częściach swoich ekranów.

### Podział

- **`free_agency_screen.dart`: 1146 → 587 linii.** Pozostają widget/State, wszystkie 12 pól, dispose/build, komendy i predykaty dostępności. `free_agency_market_sections.dart` (311) zawiera pięć sekcji rynku/podsumowania/sztabu/praw draftowych/finalizacji; `free_agency_rfa_section.dart` (139) dwie metody RFA/offer sheet; `free_agency_player_sections.dart` (258) cztery metody filtrów, sortowania, kafelka i formularza zawodnika.
- **`staff_screen.dart`: 1140 → 612 linii.** Pozostają osiem pól, główny build/dispose, status rynku, wybór osoby, walidacja i komendy. `staff_screen_slots.dart` (208) zawiera trzy metody slotów/atrybutów/etykiet; `staff_screen_offer_editor.dart` (248) edytor i wywołanie dialogu oraz dwie klasy naprawionego dialogu; `staff_screen_negotiations.dart` (217) siedem metod listy/kart/statusów/opisu i terminów.
- **`contract_screen.dart`: 884 → 500 linii.** Pozostają osiem pól, główny build/dispose, wybór celu, walidacja i komendy. `contract_screen_offer_sections.dart` (133) zawiera status rynku i podgląd oferty; `contract_screen_negotiations.dart` (240) siedem metod listy/kart/etykiet/opisu i terminów; `contract_screen_counter_dialog.dart` (107) wywołanie dialogu i dwie klasy jego zawartości.
- **`calendar_screen.dart`: 804 → 373 linie.** Pozostają providery, widget/State, wszystkie siedem pól instancji, czas feedbacku, dispose, timery, completer, generacje i cały przepływ symulacji/anulowania. `calendar_screen_body.dart` (452) zawiera całe niezmienione build i trzy stałe kluczy UI. Przeniesiono renderowanie wraz z lokalnymi danymi i funkcją dayInfo; nie rozbijano domknięć ani nie dodawano modelu dat.
- **`prospects_screen.dart`: 765 → 573 linie.** Pozostają watchlista/Combine, 12 pól instancji, init/dependencies/dispose, `_persistOnExit`, scroll/keye i wyróżnienie oraz sterowanie ekranem. `prospects_table.dart` (233) zawiera trzy metody renderowania tabeli, `_tableWidth` i 13 stałych szerokości. Wcześniejszy `prospect_detail_content.dart` pozostał bez zmian.

Łącznie wydzielono **38 metod i 16 stałych do 11 części** w dotychczasowym folderze `lib/app/screens/`. Wszystkie tworzą istniejące biblioteki przez `part`/`part of`. Główne State nadal dziedziczą po tych samych `ConsumerState<Screen>` i zachowują ten sam obiekt widgetu, ref, context, setState oraz lifecycle. Podział nie wprowadza dodatkowego State sekcji ekranu.

Każda biblioteka ma prywatny kontrakt dostępu bez stanu i implementacji, a miksiny mają ograniczenia `on ConsumerState<Screen>, Shared`. Pięć kontraktów zawiera łącznie **83 deklaracje abstrakcyjne**; dodano **80 adnotacji `@override`**. Gettery/settery udostępniają istniejące pola tego samego State; nie tworzą kopii kontrolerów, zaznaczeń, timerów ani providerów. Dla zapisywanych wyłącznie pól FA wystawiono tylko setter. Publiczne widgety i dotychczasowe importy pozostały takie same.

### Weryfikacja

- Przed poprawką: **34/34** scenariusze poza dwoma dialogami; oba dialogi odtwarzały błąd w osobnych procesach. Historyczne czerwone logi są dowodem regresji sprzed poprawki.
- Po poprawce, jeszcze przed podziałami: **36/36** z `state_screen_split_interaction_test.dart`, `calendar_screen_test.dart`, `game_controller_lifecycle_test.dart`, `calendar_pacing_phases_test.dart`. Dodatkowo **2/2** testy dialogów po rozszerzeniu sprawdzenia o zapis po ponownym otwarciu.
- Po kolejnych podziałach: FA **2/2**, sztab **3/3**, kontrakty **3/3**, kalendarz/lifecycle/pacing **26/26**, tabela prospektów i wiedza skautingu **4/4**. Każda biblioteka przechodziła osobną analizę przed przejściem do następnego ekranu.
- Nowy `test/nowe_testy/state_screen_split_interaction_test.dart` zawiera dziesięć scenariuszy: sześć formularzy FA/sztab/kontrakty w PL/EN (filtr, wybór, tożsamość kontrolerów i wartości po zmianie języka), dwa dialogi (walidacja, anulowanie, ponowne otwarcie, zapis bez błędu) oraz dwa scenariusze zapisu watchlisty i Combine przy wyjściu. Fixture'y/helpery są prywatne w tym samym pliku; repozytorium zapisów działa w pamięci.
- Porównanie źródeł z `a454528` potwierdza, że jedynymi celowo zmienionymi metodami dawnych State są dwa `_counterDialog`; dodano cztery klasy zawartości dialogów. Pozostałe **191/193** elementy zachowały treść.
- Następnie porównanie SHA-256 z zapisanym stanem po poprawce i przed podziałem potwierdziło **193/193** elementy State oraz całe cztery klasy dialogów: 54 elementy State przeniesiono, 139 pozostawiono. Obejmuje sygnatury, ciała, komentarze, stałe i inicjalizatory, z normalizacją tylko końców/zewnętrznych pustych linii i wskazanych nowych adnotacji. Połączenia miksinów, kompletność, unikalność, kolejność, importy i abstrakcyjne kontrakty sprawdzono osobno; formatter może usuwać końcowe przecinki w nowych abstrakcyjnych sygnaturach.
- Nie dodano trwałych testów układu źródeł ani narzędzi do aplikacji. Manifesty i jednorazowe porównania są wyłącznie w ignorowanym folderze raportów.
- Formatowanie **17 plików Dart**: bez dalszych zmian. Analiza całego `lib/app` i `test/nowe_testy`: **bez uwag**.
- **Po pełnym podziale 221/221:** cały folder `test/nowe_testy/`, w tym wszystkie dziesięć nowych scenariuszy i oba wcześniej czerwone testy. Nie uruchamiano starych testów.
- `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany kernel bundle; sprawdzenie debug bez podłączonego urządzenia. `git diff --check`: bez uwag.
- Test odświeżeń zachowuje Home: 5, Squad: 0, Standings: 0 przy pięciu zmianach daty. Podział nie stanowi nowej optymalizacji wykonania.

Schemat zapisu nadal **27**, bez migracji; bez zmian balansu, modeli danych i protokołu zapisu. Nie analizowano ani nie zmieniano wyłączonych AI/simulation, plików generowanych, assets ani starych testów. Zamrożony raport audytu pozostał bez zmian.

Logi w `reports/lib-audit-2026-10-13/`: `stage-8-r12-after-dialog-fix-tests.txt`, `stage-8-r12-dialog-save-tests.txt`, pliki `stage-8-r12-{free-agency,staff,contract,calendar,prospects}-tests.txt` i odpowiadające analizy, `stage-8-r12-movement-check.txt`, pięć manifestów `*-movement-baseline.json`, `stage-8-r12-post-fix-baseline.json`, `stage-8-r12-all-tests.txt`, `stage-8-r12-analyze.txt`, `stage-8-r12-build.txt`. Wcześniejsze logi izolowanych repro dotyczą kodu sprzed naprawy.

### Ręczne review R12

1. **Dialogi counter:** przy dostępnej kontrpropozycji zawodnika lub sztabu otwórz edycję, wpisz nieprawidłowe lata, anuluj i otwórz ponownie. Wartości powinny wrócić do aktualnej oferty. Zapisz prawidłową edycję. Zamknięcie ma przebiegać bez błędu kontrolera. Testy odtwarzają te przypadki bez potrzeby czekania na losowy counter.
2. **FA, sztab, kontrakty:** wybierz podmiot i zmień kwotę/lata; sprawdź filtr FA, podgląd i dostępność akcji. Przebudowa ekranu lub zmiana języka ma zachować wybór i wpisane wartości. W dostępnym oknie można sprawdzić wysłanie/finalizację oferty; reguły rynku nie zostały zmienione.
3. **Kalendarz:** wybierz dzień i zmień miesiąc, rozpocznij symulację oraz anuluj ją; sprawdź wynik/feedback i powrót do ekranu po wyjściu. Nie powinny pozostawać nakładka ani działający timer starego przebiegu.
4. **Prospekty:** zaznacz watchlistę lub Combine, wyjdź i wróć; wybór powinien być zapisany. Otwórz szczegóły oraz, jeśli korzystasz z wejścia z wyszukiwarki, sprawdź przewinięcie i wyróżnienie wiersza.

Grupa **R12** jest ukończona i gotowa do review; prace zatrzymano na tej granicy. Nie wykonano commitów ani R13.

## Etap 8 — R11: generacja danych — 17 października 2026

Punkt wyjścia: `e6ee6aa` (R10), czyste repozytorium. Wydzielono **20 metod i pięć tabel stałych do czterech prywatnych miksinów**. Wszystkie części pozostają w `lib/core/models/`, połączone przez `part`/`part of`. Publiczne metody nadal są metodami instancji `SeedDataGenerator`, dostępnymi przez dotychczasowy import. Odbiór następuje po całej grupie; agent nie wykonuje commitów.

### Podział

- **`seed_data_generator.dart`: 818 → 184 linie.** Pozostają konstruktor, `_random`, `balance`, `_mockDraftService`, całe `generateLeague`, `_staffCounter` i `_generateName` (siedem dotychczasowych elementów). W tym samym pliku znajduje się kontrakt `_SeedGenerationShared`.
- **`seed_team_generation.dart` (138):** pięć metod generacji drużyny, przyszłych picków, rosteru i pozycji dla formacji oraz `_seedRosterOvrAgeTable`.
- **`seed_player_generation.dart` (340):** 11 metod generacji zawodnika klubowego i FA, atrybutów/OVR, potencjału, pensji, wzrostu i roli; tabele `_attrOffsetRangeForWeight` i `_potentialTable`.
- **`seed_draft_generation.dart` (83):** całe `generateDraftClass` i `_draftClassOvrTable`, z dotychczasowym tasowaniem, kolejnością losowań, ID i sortowaniem prospektów.
- **`seed_staff_generation.dart` (132):** całe `generateStaffMember`, `generateStaffMemberAtStars`, `generateStaffPool` i `_staffStarWeights`. Licznik sztabu nadal jest polem głównego generatora.

### Wspólny stan i zachowanie

Każdy miksin ma `on _SeedGenerationShared`. Wspólny kontrakt zawiera **osiem deklaracji abstrakcyjnych**: dwa gettery, setter licznika i pięć metod, bez własnego stanu ani implementacji. Dopisano **siedem adnotacji `@override`** do istniejących pól/metod realizujących kontrakt. Nie dodano klasy bazowej, wrapperów, extension zastępujących API, dodatkowych generatorów ani RNG.

`_random`, `_mockDraftService` i `_staffCounter` mają tego samego właściciela, inicjalizatory i zakres życia. Reset licznika pozostaje w `generateLeague`. Pięć prywatnych tabel statycznych przeniesiono w całości do części, które ich używają; nie są stanem instancji. Wspólne generowanie nazw pozostaje w głównej klasie.

Zachowano kolejność klubów, składów i wywołań RNG, wartości tabel, generowanie ID, picków i kontraktów oraz rozróżnienie jawnego seeda, wstrzykniętego RNG i RNG podawanego do metod. `generateFreeAgentPlayers` i trzy publiczne metody sztabu zachowują dotychczasowe sygnatury. Nie zmieniono implementacji `GameFactory`, katalogu klubów, rozkładów danych, balansu ani serializacji.

### Weryfikacja

- **Przed podziałem 29/29:** `seeded_generation_test.dart`, `game_fixtures_test.dart`, `staff_season_messages_test.dart`, `declaration_split_test.dart`, `stage_six_persistence_test.dart`.
- Istniejące scenariusze obejmują wybór jednego klubu gracza, odrzucenie nieznanego ID, zgodność katalogu, powtarzalność po preview i ponownym użyciu fabryki, unikalność ID sztabu, bieżącą/kolejną klasę draftu oraz niezależne procesy Dart i save/load.
- Jednorazowe porównanie SHA-256 z `e6ee6aa`: **32/32 elementy zachowały treść** — 25 przeniesionych (20 metod i pięć tabel), siedem pozostawionych. Porównanie obejmuje pełne sygnatury, ciała, komentarze, tabele i inicjalizatory; normalizuje tylko końce/zewnętrzne puste linie oraz siedem wskazanych nowych adnotacji.
- Sprawdzono kompletność, unikalność i kolejność elementów w każdej części, importy, dyrektywy `part`, kolejność miksinów i brak implementacji/stanu w kontrakcie. Nie dodano trwałych testów układu źródeł.
- Jednorazowe porównanie danych sprzed i po podziale: **cztery zestawy wejść, po 12 sekcji**. Seedy 0 i 987654 sprawdzono dla 2026, 1 i 123 dla 2032. Porównano ligę, draft, FA, wszystkie role sztabu, pulę sztabu z własnym/zewnętrznym RNG, reset ID po kolejnej lidze oraz pełne ligi z `GameFactory` i ich ponowienia po preview. Sekwencje **87 326 wywołań wstrzykniętych RNG i 2626 wywołań zewnętrznych RNG**, wraz z argumentami i wynikami, są identyczne.
- Ograniczenie jednorazowego porównania: tylko w wywołaniu `generateLeague` **bez seeda** pominięto `mockDraftBoard`, ponieważ użyty domyślny `MockDraftService` ma własny niewstrzyknięty RNG. Dla ligi z seedem i obu wyników fabryki porównano komplet danych, również mock board. Nie zmieniano tej istniejącej semantyki. Z metadanych save'a nie porównywano UUID/czasu; przedmiotem porównania był stan ligi.
- Formatowanie pięciu plików Dart: bez dalszych zmian. Analiza `lib/app`, pięciu plików biblioteki generatora i `test/nowe_testy/`: **bez uwag**.
- **Po podziale 211/211:** pełny folder `test/nowe_testy/`, w tym wszystkie 29 scenariuszy bazowych. Starych testów nie uruchamiano.
- `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany kernel bundle, weryfikacja debug bez podłączonego urządzenia. `git diff --check`: bez uwag.
- Test odświeżeń nadal wskazuje Home: 5, Squad: 0, Standings: 0 przy pięciu zmianach daty. Ten organizacyjny podział nie stanowi nowej optymalizacji wykonania.

Nie dodano nowych testów ani stałych helperów; wykorzystano istniejące testy zachowania w `test/nowe_testy/`. Jednorazowy skrypt porównania i duże surowe snapshoty znajdowały się wyłącznie w ignorowanym folderze raportów i zostały usunięte po sprawdzeniu; pozostawiono podsumowanie/hash poszczególnych sekcji i logi.

Schemat zapisu nadal **27**, bez migracji. Nie analizowano ani nie zmieniano wyłączonych AI/simulation, plików generowanych, assets ani starych testów. Istniejąca integracja fabryki z placeholderem AI była tylko wykonywana przez testy; kod modułu AI pozostał poza analizą. Zamrożony raport audytu pozostał bez zmian.

Logi w `reports/lib-audit-2026-10-13/`: `stage-8-r11-before-tests.txt`, `stage-8-r11-generator-analyze.txt`, `stage-8-r11-all-tests.txt`, `stage-8-r11-analyze.txt`, `stage-8-r11-build.txt`, `stage-8-r11-movement-baseline.json`, `stage-8-r11-movement-check.txt`, `stage-8-r11-domain-check.json` i `stage-8-r11-domain-check.txt`.

### Ręczne review R11

1. **Nowa kariera:** utwórz ją dla wybranego klubu. Sprawdź, czy to jedyny klub gracza, a lista klubów i wybór drużyny działają. Obejrzyj skład, pozycje/formację i startowe picki.
2. **Zawodnicy i sztab:** sprawdź pulę FA, zatrudniony sztab i kandydatów oraz bieżącą klasę draftu/mock board. Dane i dostępne akcje powinny wyglądać tak jak przed podziałem.
3. **Zapis/wczytanie:** zapisz nową karierę, wróć do menu i wczytaj ją. Wybrany klub, skład, FA, sztab i draft mają pozostać. Powtarzalność konkretnych seedów i wielokrotne użycie generatora są sprawdzone automatycznie — nie trzeba ręcznie odtwarzać tych samych losowań w UI.
4. **Review diffu:** konstruktor, cztery pola instancji, `generateLeague` i `_generateName` pozostają w głównym pliku; cztery nowe części zawierają przeniesione metody i ich tabele. Nie powinno być zmian wartości balansu, algorytmów, serializacji ani kodu fabryki.

Grupa **R11** jest gotowa do review; prace zatrzymano na tej granicy. R12 (duże stany ekranów) wymaga kolejnej zgody. Nie wykonano commitów ani dalszych grup.

## Etap 8 — R10: zdarzenia drużyn i zawodników — 17 października 2026

Punkt wyjścia: `5cacf87` (R09), czyste repozytorium. Najpierw podzielono `TeamEventService` i sprawdzono testy, następnie `PlayerEventService`. Wydzielono łącznie **69 metod do dziewięciu prywatnych miksinów**. Wszystkie części pozostają w `lib/core/services/` i tworzą dotychczasowe biblioteki przez `part`/`part of`. Publiczne metody nadal są metodami instancji serwisów, dostępnymi przez stare importy. Odbiór następuje po całej grupie; agent nie wykonuje commitów.

### Podział TeamEventService

- **`team_event_service.dart`: 1543 → 446 linii.** Pozostają konstruktor, cztery zależności, dwa pola cache, `afterMatch`, zapis minut, tick tygodnia, obsługa końca playoffów, publiczne aliasy, rozstrzygnięcie/wygaśnięcie decyzji i data logiczna (17 dotychczasowych elementów). W tym samym pliku jest kontrakt `_TeamEventShared`.
- **`team_event_triggers.dart` (316):** pięć metod kwalifikacji i uruchamiania próśb o minuty/transfer, konfliktu, wsparcia lidera i publicznej krytyki.
- **`team_event_promises.dart` (170):** dwie metody rozliczania obietnic i sytuacji transferowych.
- **`team_event_decisions.dart` (247):** całe `_applyDecision`, ze wszystkimi wariantami i efektami.
- **`team_event_messages.dart` (244):** osiem metod kolejki próśb/decyzji, odmowy przedłużenia, komunikatów automatycznych oraz istniejącego wyboru opcji dla pozostałych klubów.
- **`team_event_helpers.dart` (331):** 21 metod delt/stanu, cooldownów, modyfikatorów, wyceny, minut i rankingów, losowań, wyszukiwania i klucza tygodnia. `_eventOverall` przeniesiono w całości wraz z dotychczasową obsługą typu atrybutów.

Wszystkie miksiny mają `on _TeamEventShared`. Kontrakt zawiera **32 deklaracje abstrakcyjne**: sześć getterów, dwa settery cache i 24 metody; dodano 30 adnotacji `@override`. Nie ma własnego stanu ani implementacji. `_valueThresholdCache` i `_valueThresholdReady` nadal należą do jednej instancji serwisu, z identycznymi inicjalizatorami i resetami przed oraz w `finally` po obsłudze meczu. W abstrakcyjnej deklaracji `_random` wystawiono tylko argumenty używane między częściami; oryginalna implementacja zachowuje opcjonalny `salt = 0`.

### Podział PlayerEventService

- **`player_event_service.dart`: 1426 → 443 linie.** Pozostają konstruktor/zależności, trzy pola robocze, publiczne ticki i aliasy, powołanie do reprezentacji, dispatch/wygaśnięcie decyzji, data logiczna, całe `_tickPlayer` oraz statyczny `_pendingKey` (17 elementów). W tym samym pliku jest kontrakt `_PlayerEventShared`.
- **`player_event_triggers.dart` (472):** dziewięć dotychczasowych metod od breakthrough do plateau.
- **`player_event_decisions.dart` (296):** sześć resolverów decyzji wraz z ich pełnymi efektami.
- **`player_event_messages.dart` (143):** trzy metody emitowania decyzji/wiadomości i istniejącego automatycznego wyboru.
- **`player_event_helpers.dart` (196):** 14 metod losowań, indeksów decyzji i dolnej połowy tabeli, wyszukiwania, publikacji składów i podmiany zawodnika.

Kontrakt `_PlayerEventShared` zawiera **19 deklaracji abstrakcyjnych**: pięć getterów i 14 metod; dodano 19 adnotacji `@override`. Miksiny tylko odczytują referencje pól roboczych; przypisania i czyszczenie pozostają w głównej klasie. Nie dodano setterów ani dodatkowych map. Abstrakcyjne `_emit` i `_roll` wystawiają tylko argumenty używane między częściami; pełne dotychczasowe sygnatury implementacji zachowano.

`_pendingKey` pozostaje prywatną metodą statyczną klasy. Trzy wywołania w przeniesionych metodach zapisano jako `PlayerEventService._pendingKey(...)`. Formatter rozwinął jedno z nich, a przy drugim dodano klamry wokół istniejącego wczesnego `return`, zgodnie z lintem dla wielowierszowego `if`. Ponadto formatter skompaktował istniejący literał zbioru w `_indexBottomHalf` i wyrażenie logiczne w `weeklyTick`. Są to jawnie uwzględnione różnice struktury/zapisu.

### Zachowanie i nowe testy

Nie zmieniono kolejności skanowania zawodników i wywoływania eventów, warunków kwalifikacji, prawdopodobieństw, seedów i kolejności losowań, terminów decyzji ani deduplikacji. `_tickTeams`, `_pendingDecisionKeys` i `_bottomHalfTeamIds` nadal mają tego samego właściciela i zakres życia, a publikacja rosterów następuje w tych samych miejscach. Całe `try/finally` pozostają w głównych serwisach. Nie dodano wrapperów, extension zastępujących metody instancji, nowych zależności ani pomocniczych serwisów ze stanem.

Dodano tylko **`test/nowe_testy/event_services_test.dart`**, z czterema scenariuszami zachowania:

1. Akceptacja prośby o minuty nie powiela obietnicy/modyfikatora; tick rozlicza niedotrzymaną obietnicę i nie nalicza jej ponownie.
2. Zmiany kolejnych zawodników są opublikowane przed dostarczeniem wiadomości; ponowienie na tych samych wejściach daje te same efekty, oczekujące decyzje nie generują kolejnych komunikatów, a akceptacja plateau aktualizuje bieżący roster.
3. Błąd wysyłania wiadomości podczas ticka zwalnia mapę roboczą: powołanie na innym wejściu używa nowego stanu, a ponowiony tick odpowiada świeżej instancji.
4. Istniejąca automatyczna decyzja dla klubu bez gracza aktualizuje współdzielony roster i nie trafia do inboxu menedżera.

Fixture wymusza plateau i wyłącza pozostałe losowe eventy **wyłącznie w teście**. Porównanie wiadomości normalizuje tylko losowy UUID. Helper przechwytujący wiadomości jest prywatny i znajduje się w tym samym pliku testu; nie dodano osobnych probes ani narzędzi do aplikacji.

### Weryfikacja

- **Przed podziałem 20/20:** nowy `event_services_test.dart` i istniejące `people_lifecycle_test.dart`, `postseason_finalization_test.dart`, `season_randomness_test.dart`.
- **Po podziale serwisu drużyn 20/20** tych samych scenariuszy; analiza sześciu plików biblioteki bez uwag.
- Jednorazowe porównanie z `5cacf87`: **54/54** elementy `TeamEventService` (37 przeniesionych, 17 pozostawionych) i **49/49** elementów `PlayerEventService` (32 przeniesione, 17 pozostawionych) zachowały implementacje. Porównanie SHA-256 obejmuje sygnatury, ciała, komentarze i inicjalizatory; normalizuje tylko końce/zewnętrzne puste linie, 49 nowych adnotacji oraz jawnie wymienione powyżej kwalifikacje/zmiany formatowania.
- Sprawdzono kompletność, unikalność i kolejność elementów w każdej części, zachowanie importów/komentarzy klas i brak dodatkowych implementacji/stanu w kontraktach. Manifesty i wynik są wyłącznie w ignorowanym folderze raportów; nie dodano trwałych testów układu źródeł ani skryptów w aplikacji.
- Formatowanie 12 zmienionych/nowych plików Dart: bez dalszych zmian. Analiza `lib/app`, obu bibliotek eventów i `test/nowe_testy/`: **bez uwag**.
- **Po podziale 211/211:** pełny folder `test/nowe_testy/`, w tym cztery nowe scenariusze eventów. Nie uruchamiano starych testów.
- `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany kernel bundle; weryfikacja debug bez podłączonego urządzenia. `git diff --check`: bez uwag.
- Test odświeżeń nadal wskazuje Home: 5, Squad: 0, Standings: 0 przy pięciu zmianach daty. Organizacyjny podział nie stanowi nowej optymalizacji wykonania.

Schemat zapisu nadal **27**, bez migracji. Nie analizowano ani nie zmieniano wyłączonych AI/simulation, plików generowanych, assets i starych testów. Istniejące automatyczne decyzje eventów przeniesiono bez zmian; test nie wprowadza implementacji AI przeciwnika. Zamrożony raport audytu pozostał bez zmian.

Logi w `reports/lib-audit-2026-10-13/`: `stage-8-r10-before-tests.txt`, `stage-8-r10-team-tests.txt`, `stage-8-r10-team-analyze.txt`, `stage-8-r10-player-analyze.txt`, `stage-8-r10-all-tests.txt`, `stage-8-r10-analyze.txt`, `stage-8-r10-build.txt`, dwa `stage-8-r10-*-movement-baseline.json` i `stage-8-r10-movement-check.txt`.

### Ręczne review R10

1. **Granica tygodnia:** w karierze z grubsza znanej z poprzedniej wersji przejdź kalendarzem przez koniec tygodnia. Sprawdź aktualny roster, formę/kondycję, modyfikatory i inbox. Losowy event nie musi się pojawić w danym tygodniu — nie trzeba wymuszać go wielokrotną symulacją.
2. **Decyzja eventu:** jeśli masz aktywną wiadomość zdarzenia zawodnika/drużyny, wybierz opcję i sprawdź jej efekt w aktualnych danych. Zapisz, wróć do menu i wczytaj; wiadomość oraz skutki decyzji mają pozostać. Scenariusze wymuszone i błędy wysyłania pokrywają testy w pamięci.
3. **Obietnica minut:** jeśli pojawi się prośba i ją przyjmiesz, sprawdź obietnicę/bonus, a przy późniejszym rozliczeniu — pojedynczy skutek. Test automatyczny pokrywa rozliczenie bez potrzeby ręcznego przechodzenia kilku tygodni.
4. **Review diffu:** główne przepływy, pola i `try/finally` pozostają w obu serwisach; dziewięć nowych plików zawiera przeniesione grupy metod. Nie powinno być zmian balansu, serializacji ani kodu poza zakresem R10.

Grupa **R10** jest gotowa do review; prace zatrzymano na tej granicy. R11 (generacja danych) wymaga kolejnej zgody. Nie wykonano commitów ani dalszych grup.

## Etap 8 — R09: rynek kontraktów — 17 października 2026

Punkt wyjścia: `eef0c73` (R08), czyste repozytorium. Wydzielono 46 metod `ContractMarketService` do dziewięciu prywatnych miksinów. Wszystkie części pozostają w `lib/core/services/`, połączone przez `part`/`part of`. Dotychczasowe publiczne metody nadal są metodami instancji serwisu, dostępnymi przez stary import. Odbiór następuje po całej grupie; agent nie wykonuje commitów.

### Podział

- **`contract_market_service.dart`: 2646 → 265 linii.** Pozostają `ContractMarketWindow`, konstruktor, dziewięć pól zależności, `windowAt`, `phaseAt` i cztery pola indeksu zawodników (16 dotychczasowych elementów klasy). W tym samym pliku znajduje się kontrakt `_ContractMarketShared`.
- **`contract_market_player_offers.dart` (231):** całe `submitPlayerOffer`, łącznie z walidacją i tworzeniem rekordu/odpowiedzi.
- **`contract_market_staff_offers.dart` (206):** całe `submitStaffOffer`, łącznie z walidacją podmiotu i tworzeniem negocjacji sztabu.
- **`contract_market_finalization.dart` (335):** całe `finalizeNegotiation` i `resolveCounterResponse`, bez zmiany walidacji terminu, kontraktu, obsługi odpowiedzi czy przeniesienia podmiotu do właściwej kolekcji.
- **`contract_market_resolution.dart` (392):** pięć metod `resolveHour`, `resolveDay`, `_resolveSlot`, `_resolveWaiting`, `_resolveSubjectOffers`. Nadal jest to jedna implementacja resolvera godziny/dnia, z tą samą kolejnością dodawania ofert, waiting, odpowiedzi na counter, wyboru ofert i wygaśnięć. Zbiór `resolvedWaitingIds` pozostaje lokalny i zachowuje zakres życia.
- **`contract_market_rfa.dart` (284):** siedem metod minimum i złożenia/odmowy QO, offer sheet, match/decline oraz wygaśnięcia arkuszy.
- **`contract_market_draft_rights.dart` (300):** siedem metod ticka tygodniowego, odroczonych praw, ofert dla świeżych niedraftowanych, liczników/limitów i `signDraftedRight`.
- **`contract_market_signing.dart` (191):** trzy metody podpisu awaryjnego, zabezpieczenia rosteru i `_finalizeAi`. Nadal używają tych samych `ContractService` i `StaffService`.
- **`contract_market_ai_bridge.dart` (408):** osiem istniejących bloków integracji polityki ofert, planów przedłużeń, rekordów zawodnika/sztabu, deduplikacji, RFA i odpowiedzi na counter. To mechaniczne przeniesienie obecnego kodu integracji; nie jest analizą wyłączonego `lib/core/ai/`.
- **`contract_market_helpers.dart` (246):** dwanaście metod counter/score, upsert, porównań terminu, usuwania oznaczenia niedraftowanego, wyszukiwania zawodnika/sztabu i seedowania. `_findPlayer` nadal odświeża indeks na podstawie tożsamości tych samych trzech list.

### Jedna instancja i resolver

Każdy miksin ma `on _ContractMarketShared`. Wspólny kontrakt nie przechowuje stanu ani implementacji; zawiera **37 deklaracji abstrakcyjnych**: 12 getterów, cztery settery cache i 21 metod. Dopisano **33 adnotacje `@override`** do istniejących pól/metod realizujących ten kontrakt. Nie dodano klasy bazowej, wrapperów, extension ani drugiego serwisu/zbioru negocjacji.

Pola `_indexedTeams`, `_indexedFreeAgents`, `_indexedDraftedRights` i `_playerIndex` pozostają w jednym `ContractMarketService` z dotychczasowymi inicjalizatorami. Kod budowania/odczytu indeksu przeniesiono w całości; abstrakcyjne gettery/settery wskazują na te same pola, bez kopiowania i dodatkowego resetowania cache. Wszystkie zależności, argumenty i inicjalizatory konstruktora zachowano, łącznie z dotychczasowym sposobem tworzenia domyślnej polityki AI.

Nie zmieniono limitów godzinowych/tygodniowych, znaczenia godziny 0 w FA II, dat ofert i podpisów, kolejności rozstrzygnięć ani warunków wygaśnięcia. Nie przeniesiono żadnej operacji do nowej kolejki. Nie zmieniano modeli negocjacji, ich serializacji ani reguł balansu.

### Weryfikacja

- **Przed podziałem 48/48:** `contract_messages_test.dart`, `contract_period_test.dart`, `contract_market_period_test.dart`, `phase_two_window_test.dart`, `contract_boundary_save_test.dart`, `game_controller_mutations_test.dart`, `signing_valuation_test.dart`.
- Scenariusze obejmują accept/reject/counter i finalizację zawodnika/sztabu, wiadomości PL/EN, QO/RFA, daty podpisu, prawa draftowe/podpis awaryjny, końcowy slot FA II, granice 46/47 i 52/1, payroll/wycenę oraz bliskie operacje w jednej kolejce.
- Jednorazowe porównanie SHA-256 z `eef0c73`: **62/62 elementy klasy oraz cały enum `ContractMarketWindow` zachowały implementację** — 46 metod przeniesiono, 16 elementów pozostawiono. Porównanie obejmuje sygnatury, ciała, komentarze i inicjalizatory; normalizuje tylko końce linii/zewnętrzne puste linie oraz 33 jawnie wskazane nowe adnotacje `@override`.
- Sprawdzono kompletność/unikalność, kolejność w każdej części, brak dodatkowych implementacji i stanów w miksinach/kontrakcie, importy i enum. Manifest i wynik porównania znajdują się w folderze raportów. Nie dodano trwałych testów układu źródeł ani skryptów w aplikacji.
- Analiza `lib/app`, dziesięciu plików biblioteki rynku i `test/nowe_testy/`: **bez uwag**. Formatowanie sprawdzono, zachowanie implementacji potwierdza porównanie źródeł. `git diff --check`: bez uwag.
- **Po podziale 207/207:** pełny folder `test/nowe_testy/`, w tym wszystkie 48 scenariuszy bazowych. Użyto istniejących testów zachowania; nie dodano nowych testów ani helperów.
- `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany kernel bundle. Odbiór lokalny debug bez podłączonego urządzenia.
- Test odświeżeń zachowuje Home: 5, Squad: 0, Standings: 0 przy pięciu zmianach daty. Ten organizacyjny podział nie stanowi nowej optymalizacji wykonania.

Schemat zapisu nadal **27**, bez migracji. Nie analizowano ani nie zmieniano wyłączonych AI/simulation, generatorów, assets i starych testów. Integracje placeholderów przeniesiono bez oceniania lub zmiany ich decyzji. Oryginalny raport audytu pozostał bez zmian.

Logi w `reports/lib-audit-2026-10-13/`: `stage-8-r09-before-tests.txt`, `stage-8-r09-market-analyze.txt`, `stage-8-r09-all-tests.txt`, `stage-8-r09-analyze.txt`, `stage-8-r09-build.txt`, `stage-8-r09-movement-baseline.json`, `stage-8-r09-movement-check.txt`.

### Ręczne review R09

1. **Oferty zawodnika i sztabu:** w dostępnym oknie złóż ofertę FA/przedłużenia i ofertę sztabu. Sprawdź reakcję, wiadomość, oczekującą finalizację/counter oraz jawne zatwierdzenie podpisu. Zapisz i wczytaj; negocjacje oraz podpisy mają pozostać.
2. **Godzina/dzień rynku:** wykonaj dwie różne operacje blisko siebie, przesuń godzinę albo dzień i sprawdź oba rekordy. Zweryfikuj działanie kolejnego slotu oraz ograniczeń; dzień/roster nie powinny się cofać. Zachowanie ma odpowiadać wersji sprzed podziału.
3. **RFA i prawa draftowe:** jeżeli kariera jest już w odpowiedniej fazie, sprawdź dostępne QO, offer sheet i match/decline albo podpis prawa draftowego. Automatyczne fixture'y odtwarzają granice faz/terminów; nie trzeba ręcznie przechodzić całego sezonu dla każdego wariantu.
4. **Podpis i aktualność danych:** po finalizacji sprawdź właściwy roster/listę FA/sztab, payroll i wycenę oraz ponowny odczyt ekranu negocjacji po load. Testy I/O używają własnych katalogów tymczasowych, bez celowego uszkadzania zapisów użytkownika.

Grupa **R09** jest gotowa do review; prace zatrzymano na tej granicy. R10 (eventy drużyn i zawodników) wymaga kolejnej zgody. Nie wykonano commitów ani dalszych grup.

## Etap 8 — R08: organizacja sezonu — 17 października 2026

Punkt wyjścia: `1fd485b` (R07), czyste repozytorium. Wydzielono 70 metod do dziesięciu prywatnych miksinów i przeniesiono trzy istniejące klasy pomocnicze nagród. Wszystkie części znajdują się w `lib/core/services/` i tworzą jedną bibliotekę przez `part`/`part of`. Publiczne metody są nadal metodami instancji `SeasonService`, dostępnymi przez dotychczasowy import. Odbiór następuje po całej grupie; agent nie wykonuje commitów.

### Podział

- **`season_service.dart`: 3971 → 373 linie.** Pozostają 28 dotychczasowych elementów: konstruktor, wszystkie 19 pól, `finalizeRegularSeason`, publiczne `stakeForPendingMatch` oraz wspólne `_winnerId`, `_series`, `_placeholderToken`, `_stakeForSeries`, `_teamName`, `_msg`. W tym samym pliku znajduje się prywatny kontrakt `_SeasonServiceShared`.
- **`season_fixtures.dart` (413):** osiem metod tworzenia i uzupełniania fixtures postseason, ujawniania placeholderów, kalendarza slotów, zapisu wyniku i planowania kolejnych rund.
- **`season_play_in.dart` (444):** siedem metod datowanego play-in, wznowienia meczu, budowania wyniku, seedów, dotychczasowego atomowego `setupPlayIn` i wiadomości.
- **`season_playoffs.dart` (407):** dziesięć metod setupu i awansu rund, wznowienia, zapisu/uzgadniania serii, `_playOneGame` i koronacji mistrza.
- **`season_post_match.dart` (524):** siedem metod `_sim`/`_simPostseason`, określania stawki fazy, zmęczenia, rozstrzygnięcia remisu/dogrywki i dyscypliny postseason. Integracje AI/silnika przeniesiono jako całe, niezmienione bloki; nie analizowano ich wnętrza.
- **`season_offseason_events.dart` (222):** cztery obecne zdarzenia: cap/TV, rozwój/emerytury sztabu, emerytury zawodników i otwarcie FA.
- **`season_lottery.dart` (164):** trzy metody losowania i materializacji kolejności picków. Źródłem wag pozostaje zaakceptowany wcześniej `DraftBalance`.
- **`season_scouting.dart` (145):** trzy metody Scout Report, Combine i finalnego mocka.
- **`season_draft.dart` (520):** dziesięć metod generacji klasy, wyborów draftowych, finalizacji FA i istniejących integracji wyborów/wymian AI. Nie zmieniono ich decyzji, liczników ani kolejności wywołań.
- **`season_rollover.dart` (361):** trzy metody wygasania kontraktów, rolloveru i ustalania kwalifikacji playoff dla historii/awards.
- **`season_awards.dart` (595):** piętnaście metod nagród, rankingów, XI sezonu, trenera roku, etykiet i podsumowania oraz całe `_AwardCandidate`, `_AwardStats`, `_TeamOfSeasonOption`.

### Wspólne zależności i zachowanie

Postseason ma wzajemne wywołania między fixtures, play-in i post-match. Każdy miksin ma `on _SeasonServiceShared`, a serwis łączy kontrakt i dziesięć miksinów. Ten jeden wspólny kontrakt zawiera **32 deklaracje abstrakcyjne** (16 getterów zależności i 16 metod), bez pól, konstruktorów i implementacji. Pozwala zachować dotychczasowe wzajemne wywołania bez tworzenia cyklicznej hierarchii części, nowych serwisów lub delegowania przez kopię stanu. Dodano **32 wymagane adnotacje `@override`** do istniejących implementacji kontraktu.

Cały stan pozostaje w jednym `SeasonService`: te same pola `_random`, `_uuid` i wstrzyknięte zależności, z tymi samymi inicjalizatorami i kolejnością deklaracji. Miksiny nie dodają instancji RNG, kopii ligi ani własnego lifecycle. Nie dodano wrapperów ani extension zastępujących publiczne metody. Zachowano daty, kolejność operacji i losowań, pełne zakresy `try/finally` oraz rozróżnienie lokalnych pełnych wyników i zapisanych projekcji.

**Nagrody zachowują obecne ograniczenia.** `_AwardStats` nadal bazuje na istniejących przybliżeniach; cały komentarz TODO oraz obliczenia przeniesiono bez zmian. Ten zakres nie wprowadza akumulatorów statystyk ani nie poprawia ocen bramkarzy/minut na pozycji.

### Weryfikacja

- **Przed podziałem 26/26:** `postseason_finalization_test.dart`, `season_randomness_test.dart`, `people_lifecycle_test.dart`, `stage_seven_balance_test.dart`, `staff_season_messages_test.dart`, `scouting_tier_five_test.dart`, `contract_boundary_save_test.dart`.
- Najpierw wydzielono cztery części postseason. Po tym kroku ponownie przeszło **8/8** testów finalizacji, rozstawienia i wznowienia. Następnie przeniesiono offseason, loterię, skauting, draft, rollover i awards.
- Jednorazowe porównanie SHA-256 z `1fd485b`: **98/98 elementów klasy i 3/3 klasy pomocnicze zachowały implementacje** — 70 metod przeniesionych, 28 elementów pozostawionych. Porównanie obejmuje sygnatury, ciała, komentarze i inicjalizatory; normalizacja dotyczy tylko końców linii/zewnętrznych pustych linii oraz 32 jawnie wskazanych nowych adnotacji `@override`.
- Sprawdzono kompletność/unikalność, kolejność elementów każdej części, zachowanie importów i komentarza serwisu oraz brak nowego stanu/logiki w kontrakcie/miksinach. Wynik i manifest znajdują się w katalogu raportów. Nie dodano trwałych testów porównujących źródła ani skryptów w aplikacji.
- Analiza `lib/app`, jedenastu plików biblioteki sezonu i `test/nowe_testy/`: **bez uwag**. Formatter nie zmienił żadnego z jedenastu plików. `git diff --check`: bez uwag.
- **Po podziale 207/207:** pełny folder `test/nowe_testy/`, w tym wszystkie 26 scenariuszy bazowych. Użyto istniejących testów zachowania; nie dodano nowych testów ani helperów.
- `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany kernel bundle. Odbiór lokalny debug bez podłączonego urządzenia.
- Test odświeżeń nadal wskazuje Home: 5, Squad: 0, Standings: 0 przy pięciu zmianach daty. Czasy debug nie są dowodem przyspieszenia tego organizacyjnego podziału.

Schemat zapisu nadal **27**, bez migracji. Nie analizowano ani nie zmieniano `lib/core/ai/`, `lib/core/simulation/`, generatorów, assets ani starego zestawu testów. Nie zmieniono balansu ani implementacji pozostałych serwisów. Oryginalny raport audytu pozostał bez zmian.

Logi w `reports/lib-audit-2026-10-13/`: `stage-8-r08-before-tests.txt`, `stage-8-r08-postseason-tests.txt`, `stage-8-r08-season-analyze.txt`, `stage-8-r08-all-tests.txt`, `stage-8-r08-analyze.txt`, `stage-8-r08-build.txt`, `stage-8-r08-movement-baseline.json`, `stage-8-r08-movement-check.txt`.

### Ręczne review R08

1. **Postseason:** na dostępnej karierze testowej dokończ sezon zasadniczy i sprawdź utworzenie fixtures/seedów. Przejdź przez play-in oraz mecz playoff gracza, a potem sprawdź uzupełnienie terminarza i awans serii. Zapisz i wczytaj przed wznowieniem; ukończone wyniki powinny pozostać.
2. **Nagrody i offseason:** w odpowiedniej fazie sprawdź nagrody, wiadomości, zmiany cap/TV i emerytury. Oczekiwane zachowanie jest takie samo jak przed podziałem, włącznie z obecnymi przybliżeniami nagród.
3. **Loteria/skauting/draft:** uruchom dostępne zdarzenia, sprawdź kolejność picków, Scout Report/Combine/finalny mock oraz wybór gracza i symulację wyborów do kolejnej tury. Sprawdź roster i przypisane prawa po zapisie/wczytaniu.
4. **Rollover:** na końcu cyklu sprawdź nowy rok, historię, wiek i kontrakty, a następnie zapis/wczytanie. Nie trzeba ręcznie tworzyć wszystkich faz od zera — kontrolowane fixture'y testów odtwarzają granice umów i roku.

R08 został następnie zapisany przez użytkownika w `eef0c73`, a użytkownik pozwolił kontynuować R09. Powyższe wyniki dokumentują odbiór R08; bieżący postęp opisano na początku pliku. Agent nie wykonywał commitów.

## Etap 8 — R07: organizacja dnia — 17 października 2026

Punkt wyjścia: `4677f98` (R06), czyste repozytorium. Dziesięć istniejących prywatnych metod `DaySimulator` przeniesiono do czterech miksinów we wspólnej bibliotece. Publiczne API i import pozostają te same. Odbiór następuje po całej grupie; agent nie wykonuje commitów.

### Podział i kolejność wykonania

- **`lib/core/services/day_simulator.dart`: 1263 → 475 linii.** Pozostają konstruktor, wszystkie 16 pól zależności oraz całe `resolveCalendarEvent`, `simulateDay` i `applyPlayerMatchResult` (20 dotychczasowych elementów). Do biblioteki dodano cztery dyrektywy `part`, a do klasy cztery miksiny. Główne ścieżki dnia i wznowienia po meczu nadal są widoczne razem.
- **`day_weekly_boundary.dart` (226):** `_DayWeeklyBoundary`, całe `_runWeeklyBoundary`. Zachowano kolejność: wskaźniki drużyn/atmosfera, eventy drużynowe, rozwój, eventy zawodników, skauting, wygasanie kontraktów po drafcie, tick rynku, integracja wymian, wiadomość i rollover.
- **`day_round_resolution.dart` (106):** `_DayRoundResolution`, całe `_resolveRound`, w tym wybór fixtures, przekazanie meczu gracza, istniejące wywołania symulacji i przygotowanie kontekstu/walidacji. Miksin ma `on _DayMatchResultApplication` i korzysta z tej samej metody `_applyResult`, bez nowej ścieżki post-match.
- **`day_match_result_application.dart` (417):** `_DayMatchResultApplication`, pięć metod: `_applyResult`, `_applyFatigue`, `_recoverTeam`, `_notifyStrengthTableChanges`, `_notifyWalkover`. Pełny wynik pozostaje lokalnym wejściem post-match, a zapis dostaje dotychczasowe `slimForStorage()`. Nie usuwano ani nie zmieniano istniejącego `_recoverTeam`.
- **`day_world_updates.dart` (116):** `_DayWorldUpdates`, całe `_dailyRecovery`, `_isMonthlyScoutingReport` i `_runMonthlyScoutingReport`. Zachowano kolejność odzyskiwania kondycji/kontuzji, obsługę FA i wykluczeń administracyjnych, sortowanie prospektów oraz grupowanie/deduplikację raportu.

Miksiny nie tworzą nowych obiektów ani nie przechowują pól. Łącznie **21 abstrakcyjnych getterów** udostępnia dotychczasowe zależności; **14 adnotacji `@override`** wskazuje ich implementację przez niezmienione finalne pola w `DaySimulator`. Konstruktor zachowuje wszystkie parametry, wartości domyślne, inicjalizatory i kolejność tworzenia zależności. Nie zmieniono `SeasonService`, pipeline'u dnia, balansu ani istniejących wywołań AI/silnika.

Przesunięcia daty i wywołania granicy niedziela → poniedziałek pozostają w dotychczasowych publicznych metodach. Nie przeniesiono żadnej operacji pomiędzy dniem meczu, końcem dnia, granicą tygodnia i rolloverem. Nie dodano drugiej implementacji post-match ani innego pipeline'u.

### Weryfikacja

- Jednorazowe porównanie SHA-256 z `4677f98`: **30/30 dotychczasowych elementów bez zmiany implementacji** — 10 przeniesionych metod oraz 20 pozostawionych elementów. Obejmuje ciała, sygnatury, komentarze i inicjalizatory, z normalizacją końców linii/zewnętrznych pustych linii oraz pominięciem wyłącznie 14 jawnie wskazanych nowych adnotacji `@override`.
- Sprawdzono kompletność, brak powielenia implementacji, kolejność w każdej grupie, brak nowych pól/logiki w miksinach, importy i komentarz klasy. `day_simulation_result.dart` pozostał identyczny. Manifest i wynik znajdują się w katalogu raportów; nie dodano trwałych testów porównujących źródła ani skryptów w aplikacji.
- **Przed podziałem 33/33:** `match_date_replay_test.dart`, `people_lifecycle_test.dart`, `postseason_finalization_test.dart`, `contract_market_period_test.dart`, `phase_two_window_test.dart`, `contract_boundary_save_test.dart`, `scouting_tier_five_test.dart`.
- Te scenariusze obejmują wznowienie na dacie meczu, zwykły dzień wobec powrotu po meczu, pojedynczy tick FA, rozwój/zdrowie, kontrakty i RFA, końcową datę FA II, granice 46/47 i 52/1, rollover oraz rozstawienie/idempotencję postseason. Testy skautingu sprawdzają zachowanie poziomu wiedzy i serializacji.
- Analiza `lib/app`, pięciu plików biblioteki dnia i `test/nowe_testy/`: **bez uwag**. Formatowanie sprawdzono; porównanie źródeł potwierdza niezmienione implementacje. `git diff --check`: bez uwag.
- **Po podziale 207/207:** pełny folder `test/nowe_testy/`, w tym wszystkie 33 scenariusze bazowe. Użyto istniejących testów aktualnego zachowania; nie dodano nowych testów ani helperów.
- `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany kernel bundle. Odbiór lokalny debug bez podłączonego urządzenia.
- Test odświeżeń nadal wskazuje Home: 5, Squad: 0, Standings: 0 przy pięciu zmianach daty. Ten podział zachowuje zachowanie; czasy debug nie są dowodem optymalizacji.

Schemat zapisu nadal **27**, bez migracji. Stare testy, assets, generatory, `lib/core/ai/` i `lib/core/simulation/` pozostają poza zakresem analizy i zmian. Integracje wyłączonych placeholderów przeniesiono w całości; nie oceniano ich implementacji ani balansu. Oryginalny raport audytu pozostał bez zmian.

Logi w `reports/lib-audit-2026-10-13/`: `stage-8-r07-before-tests.txt`, `stage-8-r07-all-tests.txt`, `stage-8-r07-day-analyze.txt`, `stage-8-r07-analyze.txt`, `stage-8-r07-build.txt`, `stage-8-r07-movement-baseline.json`, `stage-8-r07-movement-check.txt`.

### Ręczne review R07

1. **Dzień meczu:** zapisz przed meczem, wczytaj i przejdź do spotkania. Zakończ je, sprawdź wynik, wiadomości oraz datę następnego dnia. Porównaj z symulacją z kalendarza na oddzielnym zapisie testowym. Zachowanie powinno odpowiadać wersji sprzed podziału.
2. **Koniec tygodnia:** przejdź przez niedzielę do poniedziałku — zwykłą symulacją oraz, jeżeli terminarz pozwala, kończąc własny mecz w niedzielę. Sprawdź wiadomość nowego tygodnia, aktualizacje rozwoju i skautingu. Nie powinny pojawić się podwójne skutki tego samego tygodnia.
3. **Granice sezonu/rynku:** na dostępnych karierach testowych sprawdź koniec draftu i tydzień 47 oraz rollover 52 → 1: datę, kontrakty, wiek i wiadomości. Automatyczne testy odtwarzają te granice w kontrolowanych fixture'ach; nie trzeba ręcznie przygotowywać każdej fazy, aby powtórzyć wszystkie scenariusze.
4. **Kalendarz i zapis:** zasymuluj kilka dni z meczami, zapisz ręcznie i wczytaj. Sprawdź zachowanie wyników i daty. Testy persystencji używają pamięci/katalogów tymczasowych, bez celowego uszkadzania zapisów użytkownika.

R07 został następnie zapisany przez użytkownika w `1fd485b`, a użytkownik pozwolił kontynuować R08. Powyższe wyniki dokumentują odbiór R07; bieżący postęp opisano na początku pliku. Agent nie wykonywał commitów.

## Etap 8 — R06: metody GameController — 17 października 2026

Punkt wyjścia: `c567d39` (R05), czyste repozytorium. Wydzielono 56 istniejących metod do pięciu prywatnych miksinów we wspólnej bibliotece `game_provider.dart`. Nie dodano klasy bazowej, instancji serwisów, extension ani osobnego obiektu koordynatora. `GameController` zachowuje konstruktor, dziedziczenie po `StateNotifier` i wszystkie pola; metody miksinów są jego metodami instancji. Odbiór następuje po całej grupie. Agent nie wykonuje commitów.

### Podział i współdzielony stan

- **`lib/app/providers/game_provider.dart`: 1872 → 517 linii.** Pozostają 52 dotychczasowe elementy: konstruktor, wszystkie pola i gettery zależności, kolejka, generacja/rewizje, autosave, load/create/persist/clear, operacje zarządzania save'ami oraz cztery dotychczasowe polecenia wymian. Providery na końcu pliku zachowały treść. Cztery nowe dyrektywy `part` i pięć wpisów `with` łączą bibliotekę.
- **`game_controller_simulation.dart` (779 linii):** `_GameControllerSimulation`, 26 metod sesji/anulowania, dnia/godziny, następnej akcji, zdarzeń kalendarza, zastosowania meczu i batcha. Zachowano całe `_simulateUntil` i `_simulateUntilInternal`, ich `try/finally`, sprawdzanie generacji i kolejność awaitów.
- **`game_controller_calendar_feedback.dart` (190):** `_GameControllerCalendarFeedback`, cztery metody publikowania dnia, scalania wyników, budowania feedbacku i wyboru meczów z daty. Symulacja ma ograniczenie `on _GameControllerCalendarFeedback`, więc korzysta z tej samej implementacji feedbacku. Obie części odwołują się do jednej sesji kontrolera.
- **`game_controller_messages.dart` (19 → 214):** zachowano wcześniejsze typy klucza/rodzaju operacji i dodano `_GameControllerMessages` z siedmioma metodami deduplikacji, wyszukiwania wiadomości, markRead/acknowledge/decision oraz dispatchera. Mapa operacji nadal jest jednym polem kontrolera; blok integracji wymian w dispatcherze przeniesiono bez zmiany.
- **`game_controller_contracts.dart` (230):** `_GameControllerContracts`, 14 metod ofert, counterów, finalizacji, QO/RFA, praw draftowych i zatrudniania/zwalniania sztabu. Nadal korzystają z tych samych `_mutateSave` i `_publishLeagueInQueue`.
- **`game_controller_draft_scouting.dart` (108):** `_GameControllerDraftScouting`, pięć metod draftu, watchlisty i przypisań Combine. Nadal korzystają z tej samej aktualizacji ligi, kolejki, generacji i metody symulacji dnia.

Miksiny nie mają pól z przechowywanym stanem ani własnych konstruktorów. Zawierają łącznie **38 deklaracji abstrakcyjnych** potrzebnych do dostępu do istniejących pól/metod kontrolera (w tym gettery/settery dwóch pól sesji). Nie są to dodatkowe implementacje ani magazyny danych. Kontrakty prywatnych metod deklarują tylko parametry potrzebne danej grupie; wszystkie oryginalne sygnatury i wartości domyślne konkretnych metod zachowano. Dopisano **23 adnotacje `@override`** przy implementacjach tych kontraktów, zgodnie z analizatorem.

Wszystkie pola — `_mutationQueue`, `_saveGeneration`, rewizje, `_pendingAutosave`, błędy zapisu, `_careerTransition`, `_activeSimulationSession`, `_nextSimulationRunId` oraz `_inFlightMessageOperations` — pozostają w jednym `GameController`, z dotychczasowymi inicjalizatorami i kolejnością deklaracji. Nie ma przekazywania skopiowanych snapshotów do nowych obiektów.

### Weryfikacja

- Jednorazowe porównanie SHA-256 z `c567d39`: **108/108 dotychczasowych elementów klasy bez zmiany implementacji** — 56 przeniesionych metod i 52 pozostawione elementy. Uwzględniono ciała, sygnatury, komentarze i inicjalizatory; normalizowano końce linii/zewnętrzne puste linie i usunięto z porównania wyłącznie 23 jawnie wskazane nowe adnotacje `@override`.
- Porównanie sprawdza kompletność, brak powielonych implementacji, kolejność elementów w każdej grupie, brak nowej logiki/pól w miksinach oraz zgodność importów, providerów i wcześniej wydzielonych typów. Nowe elementy poza oryginalnymi implementacjami to deklaracje miksinów, kontrakty abstrakcyjne i połączenia biblioteki. Wynik i manifest znajdują się w folderze raportów; nie dodano trwałych testów kodu źródłowego ani dodatkowych skryptów w aplikacji.
- **43/43 testy przed i po podziale:** `game_controller_lifecycle_test.dart`, `game_controller_mutations_test.dart`, `game_controller_persistence_test.dart`, `career_navigation_test.dart`, `calendar_screen_test.dart`, `calendar_pacing_phases_test.dart`.
- Obejmują I01–I03: kolejkę ofert i symulacji, zachowanie metadata, oczekiwanie na autosave, ponawianie po błędzie I/O, menu i wejście do meczu, zmianę kariery podczas kroku oraz anulowanie observera/pacera. Pacing na kontrolowanym zegarze pozostaje 550/850 ms w wariantach bez/z popupem.
- Analiza `lib/app` i `test/nowe_testy/`: **bez uwag**. Formatter: żaden z sześciu plików nie wymagał zmian. `git diff --check`: bez uwag.
- Pełny odbiór `test/nowe_testy/`: **207/207**. Użyto istniejących testów aktualnego zachowania; nie dodano nowych testów ani helperów. Test odświeżeń zachowuje Home: 5, Squad: 0, Standings: 0 przy pięciu zmianach daty. Czasy debug nie są podstawą twierdzeń o przyspieszeniu.
- `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany kernel bundle. Weryfikacja lokalna bez podłączonego urządzenia.

Schemat zapisu nadal **27**. Nie analizowano ani nie zmieniano wyłączonych modułów AI/simulation, generatorów, assets ani starych testów. Nie zmieniano implementacji rynku, silnika, pipeline'u dnia ani reguł balansu. Oryginalny raport audytu pozostał bez zmian.

Logi w `reports/lib-audit-2026-10-13/`: `stage-8-r06-before-tests.txt`, `stage-8-r06-after-tests.txt`, `stage-8-r06-all-tests.txt`, `stage-8-r06-controller-analyze.txt`, `stage-8-r06-analyze.txt`, `stage-8-r06-build.txt`, `stage-8-r06-movement-baseline.json`, `stage-8-r06-movement-check.txt`.

### Ręczne review R06

1. **Symulacja i menu:** uruchom dłuższy przebieg kalendarza, anuluj go albo wyjdź do menu w trakcie. Wczytaj ponownie tę samą karierę i sprawdź zachowanie ostatniej zakończonej daty. Kalendarz powinien pozostać responsywny, a ukończone dni nie powinny znikać po load.
2. **Kolejka operacji rynku:** wykonaj dwie różne oferty blisko siebie; sprawdź obie negocjacje, datę i skład po zakończeniu operacji. Zapisz ręcznie, wyjdź do menu i wczytaj karierę. Testy w pamięci kontrolują równoczesne operacje i błędy bez uszkadzania rzeczywistych zapisów.
3. **Wiadomości:** otwórz pilną wiadomość, oznacz jako przeczytaną/potwierdź lub podejmij dostępną decyzję. Powtórne kliknięcie nie powinno powielać efektu, a potwierdzenie ma zwolnić odpowiednią pauzę symulacji.
4. **Draft/skauting i mecz:** w odpowiedniej fazie zmień watchlistę lub przypisania Combine, wykonaj wybór draftowy; sprawdź ich zachowanie po ponownym load. Wejdź do meczu z zapisanej kariery. Widoki i wywołania nadal korzystają z publicznego `GameController` przez dotychczasowy import.

R06 został następnie zapisany przez użytkownika w `4677f98`, a użytkownik pozwolił kontynuować R07. Powyższe wyniki dokumentują odbiór R06; bieżący postęp opisano na początku pliku. Agent nie wykonywał commitów.

## Etap 8 — R05: samodzielne deklaracje w plikach mieszanych — 17 października 2026

Punkt wyjścia: `d010cec` (R04), czyste repozytorium. Zakres obejmuje wyłącznie samodzielne deklaracje części A. Wszystkie nowe pliki pozostają w folderach swoich bibliotek i używają `part of`; publiczne typy/providery są nadal dostępne przez dotychczasowe importy. Odbiór następuje po całej grupie. Agent nie wykonuje commitów.

### Mechaniczny podział

- **S03 — `lib/app/providers/game_provider.dart`: 2078 → 1872 linie.** `GameController` pozostał w całości, wraz z jedną kolejką, autosave, generacją i sesją. Przy nim pozostają `gameControllerProvider`, `activeLeagueProvider`, `nextGameEventProvider`. `game_service_providers.dart` (113) zawiera 23 istniejące deklaracje zależności i listy zapisów, w ich dotychczasowej kolejności. `game_simulation_types.dart` (81) zawiera `SimulationStopReason`, `BatchSimulationResult`, `UpcomingAction` i `_SimulationSession`. `game_controller_messages.dart` (19) zawiera na razie wyłącznie `_MessageOperationKind` i `_MessageOperationKey`; metody wiadomości są częścią R06. Nie utworzono drugich instancji providerów ani nowego kontrolera.
- **S08 — `lib/core/services/day_simulator.dart`: 1297 → 1263 linie.** Cały `DaySimulator` pozostał bez zmian. `day_simulation_result.dart` (37) zawiera `DaySimulationStopReason`, `DaySimulationMoment` i `DaySimulationResult`. Przebieg dnia, granice tygodnia i zastosowanie meczu nie były dzielone (R07).
- **S14 — `lib/data/save_repository.dart`: 963 → 835 linii.** `save_repository_types.dart` (131) zawiera istniejące wyjątki, etapy/checkpointy zapisu, dwa typedefy hooków i trzy prywatne rekordy transakcji. `SaveRepository` pozostało w całości. Dotychczasowe `save_directory_coordinator.dart` oraz `save_recovery.dart` nie zmieniły treści. Protokół publikacji, kolejność i zakresy `try/catch/finally` nie były modyfikowane (pozostałe wydzielenia w R13).
- **S15 — `lib/app/screens/prospects_screen.dart`: 906 → 765 linii.** `prospect_detail_content.dart` (144) zawiera cały `_ProspectDetailContent`, łącznie z `_detailRow`. Ekran i jego State, kontroler przewijania, klucze, `_persistOnExit`, Combine, watchlista i funkcje formatowania pozostają w pliku wejściowym. Nie wykonywano opcjonalnej części B z tabelą.
- **S16 — `lib/app/screens/calendar_screen.dart`: 879 → 804 linie.** `calendar_screen_helpers.dart` (79) zawiera siedem istniejących funkcji: mapowanie dat/miesiąca, rozmiar komórki, format wyniku i sprawdzenie konferencji play-in. Providery kursora/wyboru i cały ekran/State pozostają w pliku wejściowym, wraz z timerami, anulowaniem, `runId` i `_feedbackDismissalCompleter`. Nie dzielono renderowania (R12).

Jednorazowe porównanie SHA-256 z `d010cec` potwierdza **71/71 deklaracji bez zmian**: S03 33, S08 4, S14 13, S15 10 i S16 11. Obejmuje całe duże klasy, przeniesione deklaracje, komentarze i adnotacje; normalizacja dotyczy tylko końców linii i zewnętrznych pustych linii. Sprawdzono kompletność/unikalność deklaracji, ich docelowe pliki, zachowanie importów i dwóch wcześniejszych części repozytorium. Formatter nie zmienił żadnego z **12 plików aplikacji**. Manifest i wynik porównania znajdują się w katalogu raportów; nie dodano skryptów ani trwałych testów porównujących źródła.

### Weryfikacja

- **Przed podziałem: 51/51 testów** w `game_controller_lifecycle_test.dart`, `game_controller_mutations_test.dart`, `game_controller_persistence_test.dart`, `calendar_screen_test.dart`, `postseason_finalization_test.dart`, `save_management_boundary_test.dart` i `scouting_tier_five_test.dart`.
- **Po podziale: 207/207 testów**, pełny folder `test/nowe_testy/`, w tym wszystkie 51 scenariuszy sprzed podziału. Nie dodano nowych testów.
- Analiza `lib/app`, `lib/core/services/day_simulator.dart`, `lib/core/services/day_simulation_result.dart`, `lib/data` oraz `test/nowe_testy/`: **bez uwag**.
- `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany kernel bundle. Kompilacja lokalna debug, bez odbioru na urządzeniu.
- `git diff --check`: **bez uwag**.
- Wykorzystano istniejące testy aktualnego zachowania, bez dokładania testów odtwarzających układ deklaracji. Stary zestaw testów pozostaje poza zakresem.

Schemat zapisu nadal **27**, bez migracji. Nie analizowano ani nie zmieniano `lib/core/ai/`, `lib/core/simulation/`, generatorów ani assets. Deklaracje providerów integrujących placeholdery przeniesiono w całości, bez zmiany ich wywołań i bez oceny implementacji wyłączonych modułów. Oryginalny raport audytu pozostaje bez zmian.

Logi w `reports/lib-audit-2026-10-13/`: `stage-8-r05-before-tests.txt`, `stage-8-r05-all-tests.txt`, `stage-8-r05-analyze.txt`, `stage-8-r05-build.txt`, `stage-8-r05-movement-baseline.json`, `stage-8-r05-movement-check.txt`.

### Ręczne review R05

1. **Kalendarz:** wybierz przyszły dzień, uruchom symulację, sprawdź odświeżenie daty i wyników oraz anulowanie. Przełącz miesiąc i sprawdź zachowanie zaznaczenia. UI powinno działać jak przed podziałem.
2. **Kontroler/zapis:** zapisz ręcznie, wyjdź do menu i ponownie wczytaj karierę. Sprawdź ostatnią datę i zmiany w składzie; typy i providery pozostają dostępne przez stare importy. Testy I/O używają własnych katalogów tymczasowych, a nie zapisów użytkownika.
3. **Prospekci:** otwórz szczegóły zawodnika bez rozpoznania i z rozpoznaniem, przewiń arkusz i zamknij go; sprawdź powrót do tej samej pozycji listy. Sprawdź watchlistę oraz dostępne dane Combine. Nie powinny pojawić się nowe dane, których skaut wcześniej nie znał.

R05 został następnie zapisany przez użytkownika w `c567d39`, a użytkownik pozwolił kontynuować R06. Powyższe wyniki dokumentują odbiór R05; bieżący postęp opisano na początku pliku. Agent nie wykonywał commitów.

## Etap 8 — R04: samodzielne widgety i funkcje — 17 października 2026

Punkt wyjścia: `8293be2`, czyste repozytorium. Zgodnie z decyzją użytkownika przerwa do review następuje **po całej grupie R04**. Każdy źródłowy plik zachowuje osobny zakres przeniesień, co pozwala użytkownikowi utworzyć osobne commity. Agent nie wykonuje commitów.

### Mechaniczny podział

Wszystkie nowe części znajdują się w folderze swojego pliku wejściowego. Każdy z sześciu podziałów tworzy jedną bibliotekę Dart przez `part`/`part of`, więc dotychczasowe importy udostępniają te same publiczne deklaracje. Nie dodano nowych właścicieli stanu ani parametrów widgetów. Przeniesiono całe deklaracje, zachowując klucze, kolejność drzewa, callbacki i lifecycle.

- **S04 — `lib/app/screens/matchday_screen.dart`: 1843 → 704 linie.** Pozostają ekran i cały jego State (start, timer, pauza/prędkość, akcje, zakończenie, główny build) oraz pięć krótkich wspólnych funkcji. Części: `matchday_status_widgets.dart` (369), `matchday_lineup_widgets.dart` (175), `matchday_action_sheets.dart` (307), `matchday_auto_pause_sheet.dart` (98), `matchday_summary_dialog.dart` (201). Arkusze przeniesiono razem z ich dotychczasowymi State.
- **S11 — `lib/app/screens/home_screen.dart`: 1047 → 438 linii.** Pozostaje cały `HomeScreen`. `home_calendar_actions.dart` (388) zawiera istniejące funkcje dat, nawigacji, symulacji i prezentacji wyniku; `home_action_widgets.dart` (227) zawiera `_buildNextActionSection` oraz `_HomeDashboardHeader`. Nie łączono helperów dat z kalendarzem.
- **S12 — `lib/app/screens/inbox_screen.dart`: 1051 → 681 linii.** Pozostają cały ekran/State, otwieranie szczegółów, sortowanie, filtracja, ustawienia i lokalizacja. `inbox_message_details.dart` (373) zawiera enumy fazy/operacji oraz cały widget szczegółów i jego State, wraz z retry. Tokeny rodzica i `closeSheetOnce` pozostają przy dotychczasowych właścicielach.
- **S18 — `lib/app/screens/search_filters_screen.dart`: 855 → 188 linii.** Pozostają ekran/State, `_groupOrder`, TabController i reset. Części: `search_filter_controls.dart` (302), `search_filter_dropdowns.dart` (92), `search_filter_tabs.dart` (280, wraz z `_formatMoney`). Nie zmieniono powiązań filtrów, kroków suwaków ani opcji lokalizacji.
- **S19 — `lib/app/widgets/tactics/player_list_tile.dart`: 852 → 323 linie.** Pozostają cały `PlayerListTile` i `_NameAndForm`. `player_tile_badges.dart` (278) zawiera ramkę, odznaki, potencjał, rolę i `_zoneLabel`; `player_tile_metrics.dart` (171) zawiera wskaźniki, podpis i formatowanie formy/kondycji; `player_tile_status_icons.dart` (87) zawiera cały `StatusIcons` z etykietami. Publiczne komponenty nadal dostępne przez dotychczasowy import.
- **S21 — `lib/app/utils/squad_presentation.dart`: 661 → 222 linie.** Pozostają `PlayerPresentation`, `PlayerSemanticSnapshot`, składanie projekcji i formatowanie semantycznej formy. Części: `squad_roster_presentation.dart` (154), `squad_name_presentation.dart` (54), `squad_status_presentation.dart` (125), `squad_position_assignment.dart` (115). Przypisania pozycji, kolory, niezmienność kolekcji i semantyka zachowane.

Jednorazowe porównanie SHA-256 z `8293be2` potwierdza identyczną treść **123/123 deklaracji**: odpowiednio 28, 17, 10, 16, 14 i 38. Porównano również zachowane importy oraz kompletność/unikalność deklaracji i przypisanie nowych części do bibliotek. Normalizowano tylko końce linii oraz zewnętrzne puste linie; komentarze i adnotacje są uwzględnione. Formatter nie zmienił żadnego z **24 plików aplikacji**. Wyniki zapisano w `stage-8-r04-movement-check.txt`, a manifest pięciu późniejszych podziałów w `stage-8-r04-movement-baseline.json`. To jednorazowe artefakty weryfikacji w katalogu raportów; nie dodawano trwałych testów porównujących kod źródłowy ani skryptów typu probes poza nim.

### Weryfikacja

- **S04: 6/6 przed i po podziale** — trzy nowe scenariusze meczu oraz trzy testy nawigacji/bariery zapisu z `career_navigation_test.dart`.
- **Pozostałe R04: 13/13 przed i po podziale** — `search_filters_interaction_test.dart`, `search_filter_boundaries_test.dart`, `stage_six_rebuilds_test.dart`, `message_locale_switch_test.dart`, `squad_slot_interaction_test.dart`.
- `matchday_split_interaction_test.dart` sprawdza autopauzę PL/EN (zapis i ponowne otwarcie), zachowanie elementu ekranu i zegara zatrzymanego na 0', wybór graczy i reset arkusza oraz zastosowanie/odczyt tempa taktyki. Używa istniejących API uruchomienia meczu, bez symulowania minut i oceniania implementacji silnika/AI; zapis odbywa się w pamięci.
- `search_filters_interaction_test.dart` sprawdza PL/EN: anulowanie tymczasowego wyboru klubu, zatwierdzenie wyboru, aktualizację pozycji i zakresu, zmianę rundy na innej zakładce, anulowanie i zatwierdzenie resetu, zachowanie elementu ekranu/TabControllera i wyjście przyciskiem wyszukiwania.
- Test odświeżeń zachowuje przed i po podziale **Home: 5, Squad: 0, Standings: 0** przy pięciu zmianach samej daty. Czasy debug nie są podstawą twierdzenia o przyspieszeniu; ten zakres nie optymalizuje wykonania.
- Pełny odbiór `test/nowe_testy/`: **207/207**, czyli 202 wcześniejsze i 5 nowych scenariuszy.
- Analiza `lib/app` i `test/nowe_testy/`: **bez uwag**. `git diff --check`: bez uwag.
- `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany kernel bundle. To kompilacja lokalna debug, bez odbioru na telefonie.

Dodano łącznie **5 scenariuszy** w dwóch plikach testowych. Starych testów, wyłączonych modułów, generatorów i assets nie analizowano ani nie zmieniano. Schemat zapisu nadal **27**, bez migracji. Oryginalny raport audytu pozostał bez zmian.

Logi bieżącej grupy w `reports/lib-audit-2026-10-13/`: `stage-8-r04-before-tests.txt`, `stage-8-r04-after-tests.txt`, `stage-8-r04-all-tests.txt`, `stage-8-r04-movement-check.txt`, `stage-8-r04-movement-baseline.json`, `stage-8-r04-analyze.txt`, `stage-8-r04-build.txt`. Wcześniejsze logi S04 zachowano pod prefiksem `stage-8-r04-s04-`.

### Ręczne review R04

1. **Home:** sprawdź datę, nagłówek i kolejną akcję; przejdź do wydarzenia lub przesuń dzień, sprawdź aktualizację Home oraz kalendarza. Zachowanie powinno odpowiadać wersji sprzed podziału.
2. **Inbox:** otwórz wiadomość, zamknij szczegóły, zmień zakładkę i ustawienia; sprawdź tekst po zmianie PL ↔ EN. Dla dostępnej akcji/decyzji sprawdź potwierdzenie i zamknięcie szczegółów.
3. **Filtry:** zmień pozycję, klub, zakres i zakładkę; zamknij wybór klubu bez zapisu i sprawdź brak zmiany, potem zatwierdź. Anuluj reset, następnie wykonaj reset. Wybrana zakładka powinna pozostać aktywna.
4. **Skład:** sprawdź nazwiska, strefy XI/ławka/rezerwy, OVR, formę/kondycję i statusy dostępnych zawodników. Przeciągnij zawodnika między slotami i otwórz profil; sprawdź zachowanie po powrocie.
5. **Mecz:** sprawdź nagłówek, składy i statystyki, zapis/ponowne otwarcie autopauzy, arkusze zmian/taktyki (formacja przed przerwą zablokowana), wznowienie/pauzę, prędkość oraz zakończenie/podsumowanie. To odbiór zachowania UI przy istniejącym placeholderze silnika.

R04 został następnie zapisany przez użytkownika w `d010cec`, a użytkownik pozwolił kontynuować R05. Powyższe wyniki dokumentują odbiór R04; dalszy postęp opisano na początku pliku. Agent nie wykonywał commitów.

## Wynik etapu 7 — 17 października 2026

Punkt wyjścia: `6e9cea2`, czyste repozytorium. Użytkownik rozstrzygnął konflikt wag loterii: wspólnym źródłem jest **`DraftBalance.lotteryWeights`**, czyli `[140, 140, 140, 125, 105, 90, 75, 60, 45, 30]`. To jawnie zaakceptowana zmiana dotychczasowego balansu losowania kariery, które wcześniej używało `[140, 120, 100, 90, 80, 70, 60, 50, 40, 30]`. Pozostałe przeniesione wartości zachowują dotychczasowe domyślne liczby.

- **202 scenariusze przechodzą:** pełny odbiór `test/nowe_testy/` 202/202; po doprecyzowaniu zgodności porównania zbiorów dodatkowy odbiór filtrów 5/5. To 185 wcześniejszych i 17 nowych scenariuszy.
- Analiza statyczna dozwolonych obszarów aplikacji, modeli filtrów, balansu i nowych testów: **bez uwag**.
- Zwykły Dart CLI: **exit code 0**, oba serwisy core działają bez Fluttera.
- `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany kernel bundle. `git diff --check`: bez uwag.
- Zmiany pozostają bez commita, etap 8 nie został rozpoczęty.

### I24 — neutralne filtry

`SearchGroup`, `RangeFilter` i cztery stany filtrów są w `lib/core/models/search_filters.dart`. Dotychczasowy provider eksportuje te same typy, zachowuje notifier, rodzinę według saveSeed i komendy. Matcher importuje tylko modele core. Porównanie zbiorów jest lokalne i niezależne od kolejności, bez Flutterowego `setEquals`; hash i kontrakt `copyWith` pozostają takie same. Testy sprawdzają równość/hash wszystkich stanów, granice zakresów i zaokrąglenia wyświetlanych wartości, FA, nieznane dane prospektów, picki oraz stan Riverpoda.

### I25 — granica zarządzania zapisami

`SaveManagementRepository` w core ma tylko pięć potrzebnych operacji: list, inspect, dostępność ID, rename i duplicate. W tym samym neutralnym pliku jest dotychczasowy kontrakt `SaveManagementException`; serwis eksportuje go zgodnie ze starym importem. Serwis wymaga interfejsu przez konstruktor i korzysta z `SaveSchema.currentVersion`, bez importowania lub tworzenia konkretnego repozytorium.

`SaveManagementRepositoryAdapter` w data deleguje do istniejącego repozytorium i mapuje jego wyjątki na dotychczasowe kody domenowe, zachowując przyczynę. Provider app wstrzykuje adapter z `saveRepositoryProvider`. Właścicielem kolejki nadal jest kontroler; transakcje, blokady i odzyskiwanie pozostają w repozytorium. Niejednoznacznego odzyskiwania nie wolno zamienić na niedostępny rozmiar wiersza. Jeden wcześniejszy nowy test otrzymał adapter w miejscu bezpośredniego przekazywania konkretnego repozytorium.

Testy obejmują nazwy i kolizje ID, zegar, projekcję listy, walidację nazw, macierz pięciu operacji × pięciu rodzajów błędów oraz rzeczywisty rename/duplicate w katalogu tymczasowym. Dodatkowy helper `support/stage_seven_core_probe.dart`, uruchamiany jawnie zwykłym Dartem, importuje oba serwisy core i wykonuje ich podstawowy przebieg. Potwierdza, że nie wymagają Fluttera; nie należy do aplikacji ani do automatycznie odkrywanego zestawu testów.

### I26 — reguły i lokalizacja

- Losowanie sezonu deleguje do istniejącego `LotteryService.computeResults`, używanego także przez ceremonię. Dla trzech seedów wynik, kolejność picków i zapisane prawdopodobieństwa są zgodne z `DraftBalance`. Zachowano dotychczasowe sortowanie tabel przed losowaniem.
- Zduplikowane progi minut nagród i `58 * 90` korzystają z istniejącego `AwardsBalance`; okno ostatnich ośmiu wyników ma jedną stałą w `ChemistryBalance`, a limit tygodni historii pochodzi z `CalendarBalance.seasonCycleWeeks`. Test zachowuje wyniki domyślnego balansu i sprawdza, że wstrzyknięte progi nagród faktycznie działają. Król strzelców/asyst nadal korzysta z dotychczasowej reguły bez nowego progu minut.
- Inbox najpierw próbuje kompletnego katalogu w aktualnym języku. `tryResolve` zwraca brak wyniku dla nieznanego klucza lub niepełnych argumentów; wtedy działają legacy, inline i ogólny fallback. Ścisłe `resolve`, używane do walidacji komunikatów w debug, nadal zgłasza błąd brakującego argumentu.
- Uzupełniono argumenty komunikatu loterii i wyboru draftowego. Dla otwarcia FA, raportu przed Combine, zakończenia Combine i wybranego gracza dodano cztery konkretne warianty w obecnym katalogu oraz ręcznych szablonach PL/EN. Finalny mock korzysta z istniejącego wariantu `final`. Dzięki temu obecne zdarzenia nie muszą pokazywać zapisanych polskich tekstów; nowy komunikat wyboru zachowuje też pozycję gracza. Testy tych zdarzeń używają kontrolowanego stanu bez rozgrywania meczu i bez oceny AI.
- Widget test przełącza PL → EN przy otwartych szczegółach wiadomości. Tytuł listy i treść szczegółów aktualizują się bez zmiany zapisanych argumentów, a nieznany i niekompletny historyczny komunikat zachowują treść legacy.

Pierwszy test loterii ujawnił również brak `teamName`/`pickNumber` w wiadomości, który przerywał `runLottery` w debug. Uzupełnienie argumentów zamyka ten problem w ramach I26. Cztery nowe warianty tekstów powstały w istniejącym mechanizmie `message_templates_pl/en.dart`; nie ma migracji całego katalogu do ARB ani ręcznych zmian wygenerowanych lokalizacji.

### I27 — rzeczywisty status nagród

**Nagrody są obecnie przybliżeniem, a nie ukończonym modelem oceny występów.** Podpięcie `AwardsBalance` nie naprawia jakości danych `_AwardStats`:

- Wszystkie minuty sezonu są przypisywane naturalnej pozycji gracza, bez akumulacji rzeczywistego czasu w poszczególnych slotach. Minuty bramkarza zależą od naturalnej pozycji GK.
- `goalsPrevented` jest nadal wyliczane z `shotsFaced - własne gole gracza`, z dotychczasowym ograniczeniem zakresu. To zastępnik, nie wiarygodna miara obronionych goli ani goli straconych podczas gry.
- Brakuje udziału w punktach drużyny podczas przebywania na boisku i bonusu za postseason, wskazanych w komentarzach obecnych formuł.

Formuły i źródła tych metryk pozostają bez zmian. Docelowe akumulatory należy zaprojektować wraz z wiarygodnymi zdarzeniami silnika. Nie przywracano pełnych snapshotów zawodników do wyników. To ograniczenie opisano tutaj; aktualizacja szerszych materiałów projektu pozostaje późniejszym krokiem redakcyjnym.

### Odbiór i review

Schemat zapisu nadal **27** — zmieniły się zależności, wybór tekstu i zaakceptowane wagi, nie deklaracje persystowanych modeli. Starszych save'ów nie migrowano ani nie usuwano. Wyłączone moduły, generowane pliki, assets i stary zestaw testów pozostają poza analizą i zmianami. Oryginalny raport audytu pozostał bez zmian.

Nowe testy: `search_filter_boundaries_test.dart` (5), `save_management_boundary_test.dart` (4), `stage_seven_balance_test.dart` (5), `message_locale_switch_test.dart` (3). Razem 17 nowych scenariuszy. Logi odbioru: `stage-7-before-balance.txt`, `stage-7-balance-tests.txt`, `stage-7-boundary-locale-tests.txt`, `stage-7-core-dart.txt`, `stage-7-final-tests.txt`, `stage-7-final-filter-tests.txt`, `stage-7-final-analyze.txt`, `stage-7-final-build.txt`.

Ręczne review:

1. W wyszukiwarce ustaw klub/FA, zakres OVR, filtry prospektów i picków. Wyjdź z ekranu i wróć; ustawienia powinny pozostać. Przywrócenie domyślnych czyści je jak wcześniej.
2. Zmień nazwę save'a i utwórz kopię; sprawdź nazwy, listę i stan po wczytaniu. Kolejka i bariera wyjścia do menu nadal mają obowiązywać.
3. Sprawdź nowe wiadomości loterii, Combine i otwarcia FA po przełączeniu PL ↔ EN, również z otwartymi szczegółami. Niekompletne dawne wiadomości mogą nadal używać legacy.
4. Dla jeszcze nierozstrzygniętej loterii porównaj wynik ceremonii z kolejnością draftu zapisaną w karierze. Obie ścieżki używają teraz wag `DraftBalance`; wcześniej zapisane wyniki nie są automatycznie przeliczane.

## Wynik etapu 6 — 16 października 2026

Punkt wyjścia: `5598811`, czyste repozytorium. Użytkownik zatwierdził lokalne pomiary w testach bez urządzenia oraz retencję zakończonych negocjacji przez jeden sezon. Nie zmieniano zamkniętego raportu audytu ani starych testów.

- **185 scenariuszy przechodzi:** pełny przebieg 185/185; po uzupełnieniu optymalizacji motywu i selekcji danych tabeli ponownie przeszedł rozszerzony test UI (1/1). To 168 wcześniejszych i 17 nowych scenariuszy, wyłącznie w `test/nowe_testy/`.
- Analiza statyczna dozwolonych obszarów aplikacji, zmienionych modeli i nowych testów: **bez uwag**.
- `flutter build bundle --debug --no-pub`: **exit code 0**; to debug bundle, bez profilowania lub uruchamiania na telefonie.
- `git diff --check`: bez uwag. Zmiany pozostają bez commita, etap 7 nie został rozpoczęty.

### Implementacja i rozstrzygnięcia I17–I23

- **I17:** stały, niemutowalny katalog 30 klubów w `seed_clubs.dart`; `previewTeams` nie uruchamia generatora ligi, osób ani draftu. Generator i katalog współdzielą `seedTeamId`; offset drugiej konferencji wynika z długości pierwszej. Kolejność i ID są zgodne z dotychczasowym światem, co potwierdza także historyczny snapshot etapu 4.
- **I18:** save, rename i duplicate używają tego samego kompaktowego kodowania UTF-8. Rename i duplicate nadal operują na surowej mapie i weryfikują kompletny payload oraz metadane indeksu, bez drugiego grafu modeli domenowych. Odczyt, kodowanie, zapis i weryfikacja tych dwóch operacji działają w izolacie. Uprawnienie do katalogu i blokadę systemową trzyma wywołujący do końca workera; procedura odzyskiwania z etapu 5 pozostaje wspólna. Test równoległych workerów zachowuje wszystkie trzy wpisy indeksu.
- **I19:** sanitizer kopiuje korzeń, ligę, listę drużyn oraz modyfikowane mapy drużyny/sztabu. Nie kopiuje rosterów, terminarza ani historii. Publiczna operacja nie zmienia wejścia; współdzielone, niezmienione gałęzie wyniku należy traktować jako read-only. Load wykonuje odczyt, decode, walidację obu wersji schematu, sanityzację i jedną budowę modelu w izolacie. Wracają model i diagnostyka; typ `SaveSchemaMismatchException` oraz diagnostyka sprzed ewentualnego błędu dekodera pozostają dostępne.
- **I20 — pozostawiono implementację strumieniowania:** dla fixture'a 4,87 MB pomiar obejmuje przekazanie modelu do izolaty, wywołanie `toJson` korzenia, kodowanie z zagnieżdżonymi `toJson`, kolejkowanie i opróżnienie sinka. 75 fragmentów po najwyżej 64 KiB, opróżnienie około 6 ms; w samodzielnym przebiegu RSS wzrósł podczas kodowania/kolejkowania o około 5,8 MB. RSS nie pozwala oddzielić kolejki od przejściowych map, a GC istotnie zmienia wynik kolejnych pomiarów. Nie wykazano tu istotnego wąskiego gardła uzasadniającego dodatkowy backpressure lub flush każdego fragmentu. Komentarz repozytorium nie obiecuje już stałej pamięci całego pipeline'u. Wynik nie dowodzi odporności dowolnie dużych karier na brak pamięci w telefonie.
- **I21:** model negocjacji ma `terminalSeasonYear`, zapisywany przy zakończeniu przez oba miejsca upsert oraz przy wygaśnięciu. Retencja oznacza sezon zakończenia + cały następny sezon; np. rekord zakończony w 2026 można usunąć od 2028. Pole nie jest przesuwane przy późniejszym przeglądzie. Aktywne/waiting/counter/pending-finalization nigdy nie są usuwane. Odwołanie `negotiationId` w inboxie, archiwum lub zaplanowanej wiadomości oraz niezakończona offer sheet RFA chronią rekord dłużej. Modele historii sezonu i wymian nie przechowują odwołań ID do negocjacji; nie zmieniano implementacji wymian. Zakończony przegrany rekord z `selectedByRival` nie stanowi sam w sobie oczekującej finalizacji. Blokada pozostaje do włącznie z ostatnią obowiązującą godziną, potem jest usuwana. Przegląd działa przy `expireAt` i rolloverze sezonu. Pełne delty transportu workera nie zostały dodane bez potwierdzonego wąskiego gardła.
- **I22:** shell obserwuje nazwę/ID klubu i liczniki inboxa, skład — drużynę gracza, tabela — standings/play-in/brackets/championa, ID gracza i wartości ID/nazw klubów. Zmiany innych pól sezonu nie przebudowują tabeli. Motyw shella jest ponownie używany, dopóki nie zmienią się kolory klubu, więc aktualizacja licznika inboxa nie unieważnia motywu wszystkich zakładek. Własne porównanie danych tabeli uwzględnia zawartość listy, także po otrzymaniu nowego grafu z workera. `IndexedStack` pozostaje; test zachowuje elementy obu zakładek i wybraną zakładkę taktyki, a zmiana nazwy klubu odświeża ukryte widoki. Home nadal reaguje na datę, którą wyświetla; nie dodawano indeksów ani cache'y bez pomiaru ich konkretnego kosztu.
- **I23 — zachowano pacing i popup 500 ms:** observer ekranu czeka na zamknięcie popupu, a pacer odlicza jedynie pozostały czas cyklu. Kontrolowany zegar: dzień 300 ms + reszta pacera 200 ms + końcowy zapis batcha 50 ms = 550 ms; z wynikiem dzień 300 ms + observer 500 ms + końcowy zapis 50 ms = 850 ms, bez kolejnego oczekiwania pacera. Anulowanie przerywa oczekiwanie observera. To weryfikacja kolejności na sztucznym zegarze, nie pomiar rzeczywistej prędkości silnika.

**Schemat zapisu: 27** (wcześniej 26), zgodnie z kontraktem wersjonowania zmienionego modelu negocjacji. Regenerowano wyłącznie jego `.freezed.dart` i `.g.dart`, bez ręcznej analizy lub edycji generatorów. Nie ma migracji ani automatycznego usuwania starszych save'ów. Test historycznego podziału deklaracji otrzymał jedynie aktualny oczekiwany numer schematu; jego snapshot JSON pozostał bez zmian.

### Pomiary porównawcze i ich ograniczenia

Flutter 3.41.4 / Dart 3.11.1, Windows, `flutter test` JIT/debug, seed 123, ta sama syntetyczna kariera: 30 klubów, 780 zawodników, 870 fixtures i pięć sezonów historii. To uzgodniony odbiór bez telefonu. Poniższe czasy są wall-clock, nie odczyt licznika czasu CPU. Trzy powtórzenia; mediana pozwala ograniczyć wpływ pierwszej kompilacji JIT, ale nie zastępuje profilowania urządzenia.

- Dziesięć wywołań preview: mediana **48,2 ms → 0,217 ms**. Pierwsze wywołanie nowego katalogu zawiera jego inicjalizację.
- Load: mediana **181,7 ms → 137,7 ms**; najdłuższa przerwa pętli zdarzeń podczas load **175–242 ms → 8,5–9,5 ms**. Powrót pełnego modelu z izolaty i wznowienie odbiorcy w osobnym rozbiciu faz: **7,5–9,7 ms** — transfer nadal kosztuje.
- Staff normalization w rozbiciu faz: **41,9–52,8 ms → 0,279–0,314 ms**. Po zmianie odczyt wyniósł 16,6–24,2 ms, decode 71,7–95,0 ms, budowa modelu 22,5–31,6 ms.
- Rename: mediana **762,0 ms → 518,0 ms**; duplicate **643,3 ms → 389,4 ms**. Plik po rename **9 951 624 → 4 865 691 bajtów**; kompaktowy oryginał ma 4 865 690 bajtów. Różnica jednego bajta odpowiada zmianie nazwy.
- RSS całego procesu jest próbkowany co 2 ms z osobnej izolaty, również podczas blokady głównej. Rename: szczyty **274,1–278,1 MB → 229,2–268,3 MB**, duplicate **304,7–309,0 MB → 240,4–266,1 MB**. To próbki pamięci całego procesu z Flutterem/JIT i poprzednimi operacjami, zależne od GC; nie jest to precyzyjna alokacja pojedynczej operacji ani gwarantowany limit pamięci Androida. Pełny save zachowuje dotychczasową ścieżkę; nie przypisujemy jej nowej poprawy na podstawie rozrzutu JIT.
- Pięć aktualizacji samej daty przy widocznym kalendarzu: przebudowy składu **5 → 0**, tabeli **5 → 0**. Test sprawdza również nowy, równoważny graf po serializacji oraz faktyczną zmianę danych. Pomocniczy czas pięciu aktualizacji/pump spadł z około 1,02 s do 0,35–0,40 s; punkt odniesienia obejmował pierwsze wyrównanie lineupów, dlatego porównanie czasu jest orientacyjne. To nie pomiar klatek GPU/telefonu.
- Kontrolowany rynek: co sezon 100 odrębnych terminalnych rekordów i blokad, bez wiadomości, AI i silnika. Po 1 sezonie: **100 → 100 negocjacji**, **100 → 0 blokad**, payload 96 617 → 83 528 B. Po 5: **500 → 200**, **500 → 0**, 386 897 → 143 008 B. Po 10: **1000 → 200**, **1000 → 0**, 749 747 → 143 008 B. To izolowany scenariusz wzrostu rynku, nie symulacja dziesięciu pełnych karier. Rekordy referencjonowane mogą pozostać dłużej; nie ma twardego globalnego limitu ich liczby.

Logi odniesienia: `stage-6-before-save.txt`, `stage-6-before-measurements.txt`, `stage-6-before-rebuilds.txt`. Logi po zmianach: `stage-6-after-measurements.txt`, `stage-6-final-targeted-tests.txt`, `stage-6-final-tests.txt`, `stage-6-inbox-rebuilds.txt`, `stage-6-final-analyze.txt`, `stage-6-final-build.txt`. Wynik pierwszego pełnego odbioru: 184/184; po dodaniu testu współbieżnych workerów końcowy pełny odbiór: 185/185. Po ostatnim uzupełnieniu shella/tabeli: rozszerzony test UI 1/1 oraz ponowny analyzer i build.

### Nowe testy i review

- `stage_six_persistence_test.dart` — 7 scenariuszy: katalog bez generacji, selektywne kopiowanie i niezmienione wejście, kompaktowe operacje raw, diagnostyka/błędy load w obu trybach oraz współbieżność workerów.
- `negotiation_retention_test.dart` — 5: prawdziwy sezon zakończenia i round-trip, wszystkie trzy kolekcje wiadomości/RFA/aktywny stan, dokładna godzina blokady, nieprzesuwanie daty po expiry i kontrolowany wzrost 1/5/10.
- `calendar_pacing_phases_test.dart` — 3: zwykły dzień, dzień z observerem 500 ms i anulowanie. Istniejące nowe testy nadal sprawdzają cele kalendarza, urgent, bariery i lifecycle.
- `stage_six_rebuilds_test.dart` — 1: rzeczywisty shell z ukrytymi widokami, liczniki rebuildów, zmiana inboxa bez unieważniania motywu, pominięcie nieużywanego pola sezonu, równość po transferze, świeże dane i zachowanie kontrolera zakładki.
- `stage_six_measurements_test.dart` — 1: pomiary czasów, przerw pętli zdarzeń, RSS i rozmiarów wyłącznie w katalogu tymczasowym. Test nie stawia progów szybkości zależnych od maszyny. Nie jest częścią aplikacji.

Ręczny odbiór (nowa kariera schematu 27):

1. Otwórz tworzenie nowej gry oraz listę zapisów kilka razy; kluby, ich nazwy i konferencje powinny być takie same.
2. Utwórz karierę, zapisz ją, zmień nazwę i zduplikuj. Sprawdź podobny rozmiar obu plików oraz tę samą datę/roster po wczytaniu każdego.
3. W składzie wybierz zakładkę taktyki, w tabeli zmień zakładkę konferencji. Przejdź do kalendarza, zasymuluj kilka dni, wróć do obu widoków. Zakładki mają zachować wybór, a dane odzwierciedlać rozegrane mecze i zmiany w drużynie.
4. Sprawdź popup wyniku oraz anulowanie batcha i wyjście do menu. Nadal wymagany jest skuteczny zapis przy zamknięciu kariery; testy przerwań procesu używają wyłącznie katalogów tymczasowych.

## Wynik etapu 5 — 16 października 2026

- **168 scenariuszy przechodzi:** pełny przebieg `test/nowe_testy/` zakończył się wynikiem 166/166; uzupełniający odbiór komunikatu ekranu listy zakończył się wynikiem 2/2 (PL/EN). Łącznie to 131 wcześniejszych i 37 nowych scenariuszy. Starych testów nie uruchamiano.
- Analiza `lib/app`, `lib/data`, `lib/core/services`, `lib/main.dart` i nowych testów: **bez uwag**.
- Kompilacja `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany `build/flutter_assets/kernel_blob.bin`. To lokalny debug bundle; wynik w `stage-5-final-build.txt`.
- Schemat zapisu nadal **26**. Diff pozostaje bez commita; etap 6 nie został rozpoczęty.

Punkt wyjścia: `0f2fd43`, czyste repozytorium. Przed zmianami odtworzono różnicę między obsługiwanym wyjątkiem a śmiercią procesu: zwykły wyjątek przy publikacji indeksu przywracał poprzednią parę, natomiast zabicie procesu pozostawiało nowy payload i stare metadane indeksu. Worker zapisuje własny PID przy barierze; test kończy rzeczywisty proces i sprawdza, że jego `finally` nie wykonało się.

Użytkownik zaakceptował uzupełnienie I16 o wspólny koordynator, ponieważ na Linuxie/Androidzie standardowa blokada pliku Dart działa na poziomie procesu i sama nie wyklucza drugiej izolaty tego samego procesu. Reguła odzyskiwania: bez trwałego potwierdzenia transakcji przywracamy poprzednią parę; po potwierdzeniu zachowujemy zweryfikowaną nową parę. Niejednoznaczność kończy się błędem i zachowaniem plików.

### Implementacja I16

- `lib/data/save_directory_coordinator.dart` jest częścią biblioteki repozytorium. Główna izolata utrzymuje wspólny koordynator uprawnień do katalogu, dostępny przez `IsolateNameServer`. Klucz pochodzi z rozwiązanego katalogu, z normalizacją wielkości liter na Windows. Dopiero właściciel uprawnienia otwiera `.save.lock` i uzyskuje wyłączną blokadę systemową. To zapobiega równoległemu odzyskiwaniu/zapisowi między instancjami, izolatami i procesami korzystającymi z repozytorium.
- `lib/main.dart` inicjalizuje koordynator przed uruchomieniem klientów w tle. Nowa główna izolata zastępuje nieaktualną rejestrację portu po poprzedniej instancji. Zwykły zapis nadal wykonuje serializację i operacje transakcji w `Isolate.run`; uprawnienie i blokadę utrzymuje jego wywołujący. Kolejka mutacji `GameController` pozostaje zachowana.
- `lib/data/save_recovery.dart` zawiera dziennik i odzyskiwanie. Dziennik `.save-transaction-v1.json` powstaje przed zapisem plików tymczasowych i zmianą plików kanonicznych. Zapisuje ID transakcji, ID save'a, istnienie oryginałów, rozmiary i SHA-256. Nazwy `.tmp-*`, `.bak-*`, `.old-*`, `.restore-*` są jednoznacznie wyprowadzane z tej transakcji i roli pliku, bez używania `hashCode` ścieżki lub czasu modyfikacji do wyboru kopii.
- Najpierw zabezpieczane i sprawdzane są oba oryginały, następnie publikowany jest payload i indeks. Na Windows istniejący plik jest jawnie odsuwany przed publikacją; ten przedział jest objęty dziennikiem i testami przerwania. Potwierdzenie `.save-transaction-v1.json.commit` powstaje po dotychczasowej weryfikacji publikacji i zawiera skróty nowej pary. Dopiero wtedy sprzątane są kopie, dziennik i potwierdzenie.
- Jedna procedura odzyskiwania działa przed `listSaves`, `load`, odczytem raw, inspekcją, sprawdzaniem dostępności ID oraz operacjami zapisu, rename, duplicate i delete. Wewnętrzne wywołania pozostają pod już uzyskaną blokadą i nie próbują ponownie wejść do koordynatora.
- Przy cofnięciu procedura najpierw odnajduje i sprawdza oba oryginały, a dopiero potem przywraca pliki. Kopia źródłowa pozostaje do końca odzyskiwania, dzięki czemu ponowienie częściowo wykonanej naprawy jest możliwe. Przy potwierdzeniu sprawdzana jest nowa para. Pozostawione samo potwierdzenie po usunięciu dziennika również jest weryfikowane przed sprzątaniem.
- Brak zweryfikowanego oryginału, uszkodzony dziennik, niewłaściwe potwierdzenie lub uszkodzona potwierdzona para powodują `SaveAmbiguousWriteException`. Repozytorium zachowuje artefakty. `SaveManagementService` mapuje to na istniejące `ambiguousWrite`; inspekcja listy nie ukrywa tego stanu jako niedostępnego rozmiaru. Istniejący provider przekazuje ten typ błędu; ekran listy otrzymał brakującą obsługę `ambiguousWrite` i korzysta z istniejącego komunikatu PL/EN.
- `crypto ^3.0.7` jest teraz bezpośrednią zależnością dla strumieniowego SHA-256. Ta sama wersja była już obecna w lokalnym cache i grafie zależności; wykonano `pub get --offline`, bez aktualizacji pozostałych pakietów.

### Granice zakresu

Schemat payloadu pozostaje **26**; dziennik ma własną wersję 1. Dotychczasowe poprawne zapisy schematu 26 nadal działają. Odzyskiwanie dotyczy transakcji tworzonych przez nową procedurę. Historyczne kopie bez dziennika nie są zgadywane ani usuwane. Nie zmieniano kodowania rename/duplicate, modelu gry, implementacji AI/silnika, generowanych modeli, assets ani starych testów.

Delete uzyskuje ten sam wyłączny dostęp i uruchamia odzyskiwanie wcześniejszej transakcji, ale nie został przebudowany na osobną transakcję odporną na przerwanie. Obsługa awarii pojedynczej, ręcznie zabitej izolaty będącej samodzielnym klientem repozytorium pozostaje poza odbiorem; zwykły zapis aplikacji trzyma uprawnienie w wywołującym i zwalnia je po błędzie workera.

Testy przerwania procesu wykonano na Windows. Test ponowienia odzyskiwania dodatkowo odtwarza stan częściowo przywróconych plików. Fizyczna utrata zasilania i testy na Androidzie/Linuxie pozostają niezweryfikowane. Nie wprowadzano celowych awarii do zapisów użytkownika.

### Nowe testy i helpery

- `save_transaction_recovery_test.dart` — 23 scenariusze na Windows: zwykły wyjątek przed publikacją indeksu; rzeczywiste przerwania save/rename/duplicate przed publikacją, pomiędzy plikami, po publikacji obu i po potwierdzeniu; odsunięcie pliku gry/indeksu; wyjątki w sześciu checkpointach; pierwszy zapis w pustym katalogu.
- `save_directory_lock_test.dart` — 3: drugi obiekt repozytorium nie odzyskuje aktywnego zapisu; dwie niezależne izolaty zachowują oba wpisy indeksu; drugi proces czeka na blokadę do śmierci zapisującego, po czym odzyskuje poprzednią parę.
- `save_recovery_integrity_test.dart` — 8: zachowanie wszystkich plików przy niejednoznaczności, propagacja do dostawcy listy, brak oryginału indeksu, uszkodzenie o identycznym rozmiarze, zweryfikowana kopia odsunięta zamiast nowszego uszkodzonego backupu, powtórzenie częściowej naprawy, sprzątanie pozostałego potwierdzenia i rozróżnienie niedokończonego dziennika od historycznych kopii.
- `save_recovery_screen_test.dart` — 2: rzeczywisty ekran listy wyświetla istniejący komunikat `ambiguousWrite` po polsku i angielsku; oba testy odtwarzały brak obsługi przed zmianą.
- `save_coordinator_startup_test.dart` — 1: zastąpienie martwej rejestracji koordynatora przy uruchomieniu oraz idempotencja inicjalizacji.
- `support/save_crash_worker.dart` — pomocniczy test uruchamiany w osobnym procesie, z kontrolowanym zatrzymaniem w checkpointach. Nie jest automatycznie odkrywanym plikiem `*_test.dart` i nie należy do aplikacji.
- `support/save_process_control.dart` — uruchamia worker, odbiera jego PID i kończy wyłącznie ten proces. Współdzielony helper pozostaje w folderze nowych testów; wszystkie operacje na zapisach dotyczą katalogów tymczasowych.

Checkpointy i dotychczasowy hook publikacji są wyłącznie punktami kontrolnymi odbioru. Aplikacja nie instaluje tych callbacków. Przy testowym callbacku operacja odbywa się w wywołującej izolacie, aby nie przesyłać callbacku do workera.

Logi w `reports/lib-audit-2026-10-13/`: `stage-5-before-tests.txt`, `stage-5-dependencies.txt`, `stage-5-recovery-tests.txt`, `stage-5-integrity-tests.txt`, `stage-5-coordinator-tests.txt`, `stage-5-final-analyze.txt`, `stage-5-final-tests.txt`, `stage-5-ui-before-tests.txt`, `stage-5-ui-tests.txt`, `stage-5-final-build.txt`.

### Ręczne review etapu 5

1. Wczytaj poprawny zapis schematu 26, przejdź kilka dni, zapisz i wróć do menu. Wczytaj ponownie; data i stan drużyny powinny odpowiadać zapisowi.
2. Zmień nazwę zapisu i sprawdź ją na liście oraz po wczytaniu. Utwórz duplikat; oba wpisy powinny być dostępne, a kopia zawierać ten sam stan kariery z odrębnym ID/nazwą.
3. Wykonaj ponowny zapis oraz wyjście do menu w trakcie symulacji kalendarza, jak w odbiorze etapu 1. Zapis w tle i jego bariery nadal mają działać.

Przerwania procesu i niejednoznaczne stany sprawdza zestaw nowych testów, bez ręcznego uszkadzania karier. Odbiór automatyczny:

```powershell
dart analyze lib/app lib/data lib/core/services lib/main.dart test/nowe_testy
flutter test --no-pub test/nowe_testy --concurrency=1 --reporter expanded
flutter build bundle --debug --no-pub
```

## Wynik etapu 4 — 16 października 2026

- **131 testów przechodzi:** 125 wcześniejszych scenariuszy i 6 scenariuszy podziału deklaracji. Uruchamiano wyłącznie `test/nowe_testy/`. Analiza kodu aplikacji w dozwolonym zakresie, przeniesionych deklaracji i nowych testów: **bez uwag**.
- Stan wyjściowy: `5762f4f`, czyste repozytorium. Wzorzec danych utrwalono przed podziałami. Pierwszych pięć scenariuszy przeszło przed zmianami oraz osobno po R01, R02 i R03; końcowy zestaw obejmuje dodatkowo pełny graf zapisu z sekcjami JSON sprzed przeniesienia.
- **Schemat pozostaje 26.** Nazwy typów, konstruktory, metody, wartości domyślne i format JSON nie zmieniły się. Zapis z etapu 3 może być używany dalej; ten etap nie wymaga nowej kariery ani migracji.
- Kompilacja `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany `build/flutter_assets/kernel_blob.bin`. Nie budowano instalatora ani wersji produkcyjnej i nie wykonywano profilu na urządzeniu.
- Zmiany produkcyjne obejmują trzy pierwotne pliki, 20 nowych plików ręcznie pisanych oraz wynik regeneracji modeli. Nie zmieniano implementacji AI/silnika, istniejących osobnych grup balansu, assets ani starych testów. Zamrożony raport audytu pozostaje bez zmian.

### R01 / S22 — modele draftu, postseason i sezonu

- `draft_models.dart` skrócono z 280 do **8 linii** eksportów. Dotychczasowi odbiorcy, w tym eksport przez `core.dart`, zachowują dostęp do wszystkich 11 modeli i `ProspectX`.
- Nowe pliki w `lib/core/models/`: `prospect.dart`, `draft_class.dart`, `draft_state.dart`, `lottery_result.dart`, `play_in_models.dart`, `playoff_bracket.dart`, `season.dart`, `season_history.dart`.
- `ProspectX` pozostaje przy `Prospect`; `MockDraftBoard` przy `DraftClass`; `CompletedDraft` przy `DraftState`; oba typy play-in są razem. Zależności nowych bibliotek wskazują bezpośrednio właściwe modele.
- Zregenerowano po dwa pliki Freezed/JSON dla ośmiu nowych bibliotek. Dwa nieużywane pliki generowane `draft_models.freezed.dart` / `draft_models.g.dart` usunięto. Nie analizowano ich treści ani nie edytowano ręcznie wyników generatora.

### R02 / S13 — grupy balansu

- `balance_config.dart` skrócono z 1016 do **77 linii**. Pozostają agregat, `BalanceConfig.defaults` oraz importy/eksporty grup.
- Nowe pliki w `lib/core/balance/`: `player_balance.dart`, `finance_balance.dart`, `staff_balance.dart`, `draft_awards_balance.dart`, `development_balance.dart`, `contract_neg_balance.dart`, `team_calendar_balance.dart`.
- Przeniesiono 13 całych klas grup; prywatne tabele pozostały przy swoich klasach. Zachowano `const`, sygnatury, pola, wartości i metody. Odbiorcy nadal mogą importować wszystkie grupy z `balance_config.dart`.

### R03 / S07 — katalog klubów i pule nazw

- `seed_data.dart` skrócono z 1335 do **41 linii**. Zachowano publiczne `namePools`, `NamePool` i eksport katalogów klubów.
- `seed_clubs.dart` zawiera obie dotychczasowe listy klubów. Jest osobną biblioteką, dostępną bez generowania świata i bez importowania pul nazw; dalsze wykorzystanie katalogu w I17 pozostaje w późniejszym etapie.
- `seed_name_pools_europe.dart`, `seed_name_pools_americas.dart`, `seed_name_pools_africa.dart`, `seed_name_pools_asia.dart` zawierają regionalne stałe. Są częściami biblioteki `seed_data.dart`, więc współdzielą `NamePool`, bez dodatkowych publicznych typów lub cyklicznych importów. Europejski plik ma **628 linii**; jest największym ręcznie pisanym plikiem powstałym w tym etapie.
- Mapa narodowości odwołuje się do regionalnych stałych w pierwotnej kolejności kluczy. Zachowano teksty, kolejność imion i nazwisk, kolejność klubów oraz stałość danych.

### Weryfikacja i pliki pomocnicze

`declaration_split_test.dart` obejmuje sześć scenariuszy: JSON wszystkich 11 modeli, wynik konwersji prospecta wraz z kolejnym odczytem RNG, reprezentatywne obliczenia balansu, generację świata dla seedów 123/456 i katalog danych, odczyt JSON wszystkich modeli przez dotychczasowy import oraz pełny graf zapisu z utrwalonymi sekcjami modeli.

`support/stage_four_snapshot.dart` buduje dane tych testów. Jego jawny punkt wejścia służy do zapisania wzorca — użyto go przed zmianami. `support/stage_four_baseline.json` zawiera ten wzorzec: JSON modeli, wynik konwersji, dane balansu, katalog klubów i kolejność narodowości oraz skróty dużych zbiorów danych. Zwykłe testy odczytują wzorzec i nie aktualizują go. Są to wyłącznie pliki pomocnicze nowych testów, bez udziału w aplikacji.

Dodatkowe porównanie ze źródłami w `5762f4f` potwierdziło identyczną treść 11 modeli, `ProspectX`, 14 klas balansu z agregatem i klasy `NamePool`; 23 literały pul nazw różnią się tylko wcięciami. Wynik zapisano w `stage-4-mechanical-check.txt`.

Logi w `reports/lib-audit-2026-10-13/`: `stage-4-before-tests.txt`, `stage-4-generation.txt`, `stage-4-r01-tests.txt`, `stage-4-r02-tests.txt`, `stage-4-r03-tests.txt`, `stage-4-mechanical-check.txt`, `stage-4-final-analyze.txt`, `stage-4-final-tests.txt`, `stage-4-final-build.txt`.

### Ręczne review etapu 4

1. Przejrzyj osobno trzy grupy plików opisane powyżej. W deklaracjach powinny występować przeniesienia; zmianami na granicach plików są importy, eksporty i dyrektywy `part`. Nie ma nowych reguł gry.
2. Możesz wczytać zapis z etapu 3 (schemat 26). Otwórz skład, skauting/draft oraz kalendarz. Sprawdź dostępne dane, zapisz, wyjdź do menu i wczytaj ponownie.
3. Utwórz nową karierę i sprawdź katalog klubów, nazwiska zawodników oraz klasę draftu. Dokładną zgodność generacji z ustalonymi seedami sprawdzają testy, bez zależności od ręcznego porównywania losowych karier.

Polecenia odbioru:

```powershell
flutter test --no-pub test/nowe_testy --concurrency=1 --reporter expanded
flutter build bundle --debug --no-pub
```

Analiza obejmowała `lib/app`, `lib/data`, `lib/core/services`, `lib/core/tactics`, 23 ręcznie pisane pliki trzech dzielonych grup oraz `test/nowe_testy`; pełny wykaz wejść znajduje się w `stage-4-final-analyze.txt`.

## Wynik etapu 3 — 16 października 2026

- **125 testów przechodzi:** 93 scenariusze wcześniejszych etapów oraz 32 scenariusze etapu 3. Uruchamiano wyłącznie `test/nowe_testy/`. Dotychczasowy nowy test komunikatu QO dostosowano do zaakceptowanego terminu złożenia oferty; nadal sprawdza te same wymagania komunikatu.
- Analiza zmienionego zakresu `lib` i nowych testów: **bez uwag**. Kompilacja `flutter build bundle --debug --no-pub`: **exit code 0**, zaktualizowany `build/flutter_assets/kernel_blob.bin`. To lokalny debug bundle.
- Schemat zapisu wynosi **26**. Review na nowej karierze; wcześniejsze pliki pozostają na dysku bez migracji. Zregenerowano Freezed/JSON kontraktu zawodnika, kontraktu sztabu i drużyny, bez ręcznych zmian lub analizy treści wygenerowanych plików.
- Nie zmieniano wyłączonych implementacji AI/silnika, assets ani starych testów. Wyniki meczów w testach integracji są dostarczane przez fixture. Zapis na granicach sezonów testowano rzeczywistym `SaveRepository` w katalogu tymczasowym; interakcję boiska z kontrolerem i reload testowano repozytorium w pamięci. Nie wykonano instalacji, wdrożenia ani profilu na urządzeniu.

### Zmiany zachowania I11–I15

1. **I11 / F06:** umowy zawodników i sztabu mają kanoniczne `firstSeason` / `lastSeason`. `yearsRemaining` jest projekcją tych dat, aktualizowaną przez `ContractPeriodService`. Roczny podpis z tygodni 44–52 obejmuje następny sezon i nie wygasa przy najbliższym rolloverze. Podpis z tygodni 1–43 obejmuje bieżący sezon. Początkowe umowy obejmują bieżący sezon. Kontrakty bez dat są dopuszczone na granicy placeholdera, dla niepodpisanych FA i oczekujących praw draftowych; nie stanowi to migracji starych save'ów.
2. **Zaakceptowane reguły I11:** QO składa się w oknie przedłużeń tygodnia 46 dla kończącej się skali rookie, gdy zawodnik nadal jest w klubie. QO zachowuje prawa po wygaśnięciu i nie zastępuje aktywnej umowy. Stare umowy wygasają po zamknięciu przedłużeń, na przejściu 46→47, przed tygodniowym rozstrzyganiem rynku. Nowe podpisy rynku, przedłużenia, rookie, offer sheet i podpis awaryjny otrzymują kontekst daty. Rollover nie odejmuje kolejnego roku.
3. **I12 / F12:** podpis i przedłużenie przeliczają wycenę końcowego obiektu tym samym balansem, a następnie payroll. Konwersja prospecta stosuje przekazany balans do OVR, wyceny i rozwoju. Testy liczą losowania, aby wykryć powtórny roll NTC lub developmentu.
4. **I13 / F11:** rollover zwiększa wiek rosterów, zawodników FA, zatrudnionego sztabu i sztabu FA, raz na ID. FA korzystają z bazowego leczenia i regeneracji, tygodniowego rozwoju bez bonusów klubu i bez przeniesionych minut meczowych oraz sezonowych emerytur. Sztab FA podlega własnym regułom rozwoju i emerytur. Ponowienie zamkniętego eventu sezonowego jest bezczynne. Zwykły dzień i wznowienie po gotowym wyniku naliczają FA ten sam pojedynczy tick.
5. **I14 / F13:** naturalny awans na tier 5 ujawnia flagi i przedziały cech. Wspólna ścieżka zachowuje dokładniejsze zakresy zdobyte wcześniej przez Combine. Nie zmieniano mechaniki na asymetryczne oszacowania.
6. **I15 / F09:** drużyna zapisuje `lineupSlots` (`slot.key → playerId`). Czysty helper zachowuje poprawne ręczne obsadzenie i uzupełnia brakujące sloty dotychczasowym algorytmem. Zamiany są walidowane na aktualnej drużynie w kolejce; XI i ławka pozostają rozłączne, a nieaktualny gest nie przywraca usuniętego gracza. Zmiana formacji zachowuje pasujące sloty, pozostałe obsadza ponownie. Niedostępne i usunięte ID są usuwane z przypisań. Renderer i projekcja pozycji korzystają z zapisanej mapy. Wpływ slotów na algorytm wyniku meczu pozostaje poza zakresem wyłączonego silnika.
7. **Zaakceptowana naprawa konfliktu gestów:** na boisku składu przytrzymanie rozpoczyna przeciąganie. Profil otwiera istniejąca ikona informacji przy zawodniku na liście. W zakładce taktyki, gdzie przeciąganie jest wyłączone, przytrzymanie nadal otwiera profil. Test UI wykonuje rzeczywisty gest, sprawdza feedback przeciągania, zmianę wyświetlonego slotu oraz trwałość po reload.

### Testy dodane w etapie 3

- `contract_period_test.dart` — 11: granice tygodni podpisu, serializacja, projekcja dat, wygaśnięcie i rollover.
- `contract_boundary_save_test.dart` — 1: rzeczywisty zapis/restart przed i po granicach 46→47 oraz 52→1, okresy zawodników i sztabu, sloty oraz kolejność wygaśnięcia przed tygodniowym rynkiem.
- `contract_market_period_test.dart` — 3: QO → wygaśnięcie → offer sheet → match, podpis rookie right i podpis awaryjny.
- `signing_valuation_test.dart` — 3: nowy podpis, przedłużenie oraz konwersja prospecta z niedomyślnym balansem i kontrolą liczby losowań.
- `people_lifecycle_test.dart` — 5: cztery pule wieku, leczenie/regeneracja FA i zachowanie liczników po podpisie, bazowy rozwój FA, emerytury i idempotencja oraz zwykły dzień kontra wznowienie po meczu.
- `scouting_tier_five_test.dart` — 2: naturalny tier 5, serializacja i Combine przed/po awansie.
- `lineup_slots_test.dart` — 5: kolejka z usunięciem zawodnika, LB/RB i JSON, XI/ławka, formacje oraz niedostępny starter.
- `squad_slot_interaction_test.dart` — 2: rzeczywisty drag LB/RB, render i reload oraz zachowanie przytrzymania przy wyłączonym drag.

### Odbiór i ręczne review etapu 3

Polecenia:

```powershell
dart analyze lib/app lib/data lib/core/services lib/core/tactics lib/core/models/contract.dart lib/core/models/staff.dart lib/core/models/team.dart lib/core/models/draft_models.dart lib/core/models/seed_data_generator.dart lib/core/models/game_save.dart test/nowe_testy
flutter test --no-pub test/nowe_testy --concurrency=1 --reporter expanded
flutter build bundle --debug --no-pub
```

Ręcznie, na nowej karierze:

1. W składzie ustaw formację z LB/RB, np. 4-3-3, i obsadź te miejsca. Przytrzymaj marker lewego obrońcy, przeciągnij go na prawego i puść. Markery mają zamienić miejsca, bez otwierania profilu i automatycznego powrotu na naturalne pozycje. Zapisz, wyjdź do menu i wczytaj — zamiana ma pozostać.
2. Zamień zawodnika XI z ławką. Sprawdź, że występuje w jednej grupie. Zmień formację i obejrzyj XI; przypisania mają pasować do dostępnych slotów. Ponownie zapisz i wczytaj.
3. Otwórz profil ikoną informacji na liście składu, wróć i sprawdź przytrzymanie zawodnika w zakładce taktyki — oba wejścia mają otwierać profil.
4. Po dojściu do tygodni 44–45 podpisz roczną umowę z FA, zapisz i wczytaj. Przejdź przez koniec roku do tygodnia 1, rozstrzygając wymagane decyzje. Zawodnik ma pozostać w klubie z jednym rokiem umowy. Analogicznie sprawdź roczny podpis sztabu w końcówce roku.
5. W tygodniu 46 sprawdź kończące się umowy. Nieprzedłużone powinny zwolnić osoby do FA na początku tygodnia 47. Jeśli klub ma rookie w ostatnim roku skali, złóż QO w oknie przedłużeń i sprawdź zachowanie praw RFA po przejściu do FA I. Testy obejmują ten przypadek niezależnie od tego, czy występuje w danej karierze.
6. Przy dostępności odpowiednich osób porównaj leczenie kontuzjowanego FA po kilku dniach i wiek zawodnika/sztabu po zmianie roku. Naturalny awans skautingu do tier 5 ma ujawnić cechy; Combine nie powinien pogarszać wiedzy.

Logi etapu 3: `reports/lib-audit-2026-10-13/stage-3-generation.txt`, `stage-3-final-analyze.txt`, `stage-3-final-tests.txt`, `stage-3-final-build.txt`. Wcześniejsze logi `stage-3-partial-*` dokumentują stan sprzed zaakceptowanej naprawy gestów i nie są wynikiem końcowego odbioru.

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
