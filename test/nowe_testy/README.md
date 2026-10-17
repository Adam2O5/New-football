# Nowe testy — etapy 0–8

Etapy 0–7 zostały zaakceptowane i zapisane przez użytkownika: `dc6e454`, `b4048fb`, `553198c`, `f8e45e1`, `5762f4f`, `0f2fd43`, `5598811`, `6e9cea2` oraz etap 7 w `8293be2`. R04 etapu 8 został zapisany w `d010cec`, R05 w `c567d39`. **Etap 8 jest w toku: R06 (metody kontrolera) jest ukończone i gotowe do review.** Zmiany R06 pozostają bez commita. R07–R13 nie zostały rozpoczęte. Wyniki wcześniejszych grup/etapów poniżej są historycznym punktem odniesienia.

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

Grupa **R06** jest gotowa do review użytkownika; prace zatrzymano na tej granicy. R07 (organizacja dnia) wymaga kolejnej zgody. Nie wykonano commitów ani dalszych grup.

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
