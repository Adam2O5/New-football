# Testy — profile i wyłączenia

Wymagania: Flutter **3.41.4**, PowerShell **7+**, wcześniej wykonane `flutter pub get`.

## Uruchamianie

```powershell
pwsh -File scripts/test.ps1
pwsh -File scripts/test.ps1 -Area search
pwsh -File scripts/test.ps1 -Profile fast
pwsh -File scripts/test.ps1 -Profile standard -DryRun
pwsh -File scripts/test.ps1 -Profile long -Area data
```

- **standard**: wszystkie aktywne `*_test.dart`, w tym krótkie integracje; bez długich i wyłączonych plików. Domyślny limit całego procesu: 600 s.
- **fast** lub **-Fast**: ten sam wybór plików, z wykluczeniem tagów `slow`, `benchmark`, `integration`. Filtr tagów ogranicza wykonywane przypadki; nie zastępuje fizycznego wydzielenia long/disabled.
- **long**: wyłącznie jawnie wybrane `test/<obszar>/long/*_long.dart`, każdy plik w osobnym procesie. Domyślny limit 900 s na plik. Profil jest odrzucany przy `CI=true` i nie jest uruchamiany przez CI/CD.
- **-DryRun**: walidacja blacklisty, liczby plików oraz dokładna lista wyboru bez uruchamiania Fluttera. Pusty wybór jest widoczny w dry run; próba jego wykonania kończy się błędem, bez przejścia do całego katalogu.
- **-TimeoutSeconds N**: jawny zewnętrzny budżet procesu, w long osobno dla każdego pliku. Runner Fluttera otrzymuje dodatkowo timeout 30 s na przypadek; lokalne dłuższe deklaracje w testach nadal obowiązują.
- Obsługiwane są również `-Tags`, `-ExcludeTags` i `-Coverage`. Coverage dotyczy aktywnych testów; `long -Coverage` jest odrzucane.

`-Area` obsługuje: `ai`, `app`, `balance`, `branding`, `calendar`, `core`, `data`, `integration`, `l10n`, `market`, `match`, `messages`, `nowe_testy`, `performance`, `search`, `staff`, `ui`. `helpers` zawiera wyłącznie kod pomocniczy. `nowe_testy` pozostaje obszarem tymczasowym do kolejnych etapów refaktoru.

Zwykłe `flutter test` także pomija long/disabled dzięki nazwom plików. **Twardy limit całego procesu i zakończenie jego drzewa zapewnia wrapper**, dlatego jest zalecanym wejściem lokalnie i w CI.

## Struktura

Zachowujemy obszary dotychczasowych podfolderów. Aktywne testy kończą się `_test.dart`; długie testy w podfolderach `long/` kończą się `_long.dart`. Workery mają inne nazwy i nie są samodzielnie odkrywane.

W etapie 0 wydzielono:

- `data/long`: procesowe crash/recovery, integralność po przerwaniu zapisu, blokadę OS do śmierci writera oraz replay w niezależnych procesach;
- `performance/long`: powtarzane pomiary persystencji i pamięci oraz duży guard rozmiaru zapisu;
- `calendar/long`: kosztowne przebiegi rzeczywistej symulacji przez UI i macierze feedbacku;
- `messages/long`: historyczną macierz exploration wielokliku; w etapie 5 zastąpiono ją aktywnymi testami kontrolowanych barier, bez rzeczywistych opóźnień 300 ms.

Krótkie checkpointy wyjątków, walidacja uszkodzonych danych, blokady między instancjami/izolatami oraz szybka generacja pozostają aktywne. Wydzielenie nie zmienia ich asercji ani modelu gry. Kolejne etapy zmniejszą koszt i konsolidują scenariusze.

## Tymczasowa blacklista AI i silnika

Jedynym rejestrem jest [blacklist.json](blacklist.json). Pliki `*.dart.disabled` nie biorą udziału w discovery ani analizie Dart. Taki plik musi mieć dokładny wpis z pierwotną ścieżką, powodem oraz warunkiem reaktywacji. Wrapper odrzuca brak pliku, duplikat, ścieżkę poza obszarem, brak wpisu i nazwę testu omijającą izolację.

- Wszystkie testy `ai/` są odroczone. Task 38 i benchmark Task 35 pozostają w `ai/long/` jako wyłączone źródła; profil long ich nie uruchamia.
- W `match/` odroczono testy docelowej mechaniki silnika. Test generatora terminarza odzyskano w `data/schedule_generator_test.dart`.
- W prostych plikach mieszanych usunięto z aktywnej rejestracji wyłącznie przypadki AI/silnika, zachowując pozostałe testy domeny i Squad UI. Kopia całego oryginału w `disabled/` stanowi kontekst; **przy reaktywacji należy odzyskać tylko `deferredCases` z manifestu**, bez ponownego dodawania nadal aktywnych scenariuszy.
- Z większych mieszanych archiwów odzyskano niezależne przypadki sztabu w etapie 6 oraz UI Task 23 w etapie 8. Manifest wskazuje aktywnych właścicieli i opisuje wyłącznie nadal odroczone wymagania AI/silnika; nie pozostały wpisy `recoverInStage`.
- Zakomentowany harness Task 24 oraz smoke całego sezonu oparty na silniku zachowano jako odroczone źródła `balance/long/`. Pustego `main` nie liczymy jako testu.

Nie istnieje opcja automatycznie włączająca blacklistę. Reaktywacja wymaga przywrócenia odpowiednich źródeł/importów i asercji po wdrożeniu mechaniki, bounded run oraz usunięcia wpisu w tej samej zmianie. Blacklista nie wyłącza produkcyjnego `lib/` z analizy i nie służy do ukrywania innych czerwonych testów.

## Wyniki, logi i kontrola wrappera

Każde rzeczywiste uruchomienie zapisuje `selected-files.txt`, `summary.json` oraz `run-N/stdout.log`, `stderr.log`, `result.json` pod `build/test-results/<czas>-<PID>/`. Logi procesu można czytać podczas wykonania, np. `Get-Content <ścieżka>/stdout.log -Wait`. Konsola pokazuje wybór, lokalizację logów, wynik i końcówkę wyjścia.

- `PASS` — proces zwrócił 0; `FAIL` — zachowano jego niezerowy exit code.
- `TIMEOUT` — przekroczono budżet; zakończono uruchomione drzewo, wrapper zwraca **124**.
- Błąd konfiguracji/manifestu/brak testów — kod **2**.
- `LONG_NOT_RUN` i `BLACKLISTED` opisują pliki poza wykonaniem, nie udane lub pominięte przypadki runnera. Platformowe SKIP są widoczne w logu Fluttera.

Kontrole wrappera nie wymagają Pester ani pełnej symulacji:

```powershell
pwsh -File scripts/verify/test_runner_dry_run.Tests.ps1
pwsh -File scripts/verify/test_runner_exit_codes.Tests.ps1
```

Pierwsza sprawdza selekcję, walidację manifestu, discovery, parametry i blokadę CI. Druga sprawdza exit codes, argumenty ze spacjami, stdout/stderr i timeout na kontrolowanym procesie z dzieckiem. Nie uruchamia Task 38.

## Stan po etapie 0

159 aktywnych plików testowych, 10 plików long i 40 wpisów blacklisty. Wpisy mogą przechowywać kontekst pliku mieszanego; te liczby nie są liczbą zarejestrowanych przypadków.

Znane błędy typu `SaveRepository` → `SaveManagementRepository` w pięciu plikach oraz nieaktualne oczekiwania autosave/pacingu pozostają jawne. Ich naprawa jest zaplanowana na kolejne etapy. Etap 0 nie oznacza zielonego całego zestawu ani CI.

Weryfikacja podziału: 21/21 zachowanych testów persystencji i generacji, 79/79 testów `search`, wybrane replay i crash smoke przeszły. W zachowanej starej domenie: 64 PASS, 17 FAIL i 1 SKIP; wszystkie 17 porażek odtworzono na kopiach oryginalnych źródeł. Obejmują m.in. wersję schematu 23 zamiast 27, stare fixture'y/oczekiwania oraz teardown ścigający się z autosave. Nie dopisano tych problemów do blacklisty AI/silnika. Analizator zgłasza te same 21 błędów typów i jedną informację stylistyczną co w audycie, bez nowych ostrzeżeń.

## Etap 1 — zaakceptowany zakres

Naprawiono 21 błędów typów. Analiza aktywnych i długich źródeł nie zgłasza błędów ani ostrzeżeń; pozostaje wcześniejsza informacja stylistyczna w `task26_team_events_test.dart`.

Helpery znajdują się obecnie w:

- `helpers/fixtures/` — wspólne save'y i snapshot podziału deklaracji;
- `helpers/persistence/` — rzeczywiste kontrolowane repozytorium, pamięciowy fake oraz baza `NoDiskSaveRepository`, która odrzuca niewspierane operacje bez dostępu do dysku;
- `helpers/simulation/` — kontrolowany krok dnia;
- `helpers/widgets/` — harness aplikacji i dubler preferencji;
- `helpers/processes/` — workery, replay, probe core i ograniczone czasowo zarządzanie procesami;
- `helpers/staff/` — części biblioteki danych sztabu: fixture'y, niezależny oracle, negocjacje i JSON. Dotychczasowy import `staff_role_ratings_test_helpers.dart` pozostaje wejściem do biblioteki;
- `helpers/barrier_cleanup.dart` — jawna rejestracja zwolnienia bariery przed teardown.

Ścieżki importów, workery i odczyt snapshotu w aktywnych źródłach zostały zaktualizowane. Zamrożone `.disabled` pozostają bez zmian; podczas reaktywacji należy dostosować ich stare importy helperów do powyższych katalogów.

Wybór po etapie 1: **161 aktywnych plików, 11 long, 40 wpisów blacklisty**. Nowy ręczny `data/long/process_cleanup_long.dart` sprawdza timeout oraz sprzątanie drzewa po błędzie; pomocniczy `waiting_worker.dart` jest celowo bezczynny i nie jest samodzielnie odkrywany.

Etap 1 zaakceptowano w zakresie API i helperów (commit użytkownika `7a77b65`). Po przywróceniu kompilacji `save_management_flow_test` ujawnił dwa niezgodne oczekiwania: ambiguous recovery pozostaje do etapu 2, błąd `loadGame` do etapu 3. Macierz 120 operacji indeksu przekroczyła próbny limit 25 s; jej koszt zostanie uporządkowany w etapie 2. Nie zmieniano tych oczekiwań, kodu gry ani globalnych limitów. Akceptacja etapu nie oznacza zielonego wyniku całego zestawu.

## Etap 2 — persystencja i zarządzanie zapisami, zaakceptowany w `348cf27`

Wybór po etapie 2: **165 aktywnych plików, 11 long, 40 wpisów blacklisty**. Kod `lib/`, blacklista i globalne limity pozostały bez zmian.

- `data/save_repository_test.dart` używa małego wspólnego fixture'a do zwykłych operacji. Pełny większy payload przechodzi dokładny save/load/rename/duplicate w `data/save_repository_payload_test.dart`. Trzykrotne pomiary nadal są wyłącznie w `performance/long/save_repository_baseline_long.dart`.
- `data/save_repository_management_test.dart` przejął unikalne walidacje z dawnych `save_repository_duplicate_raw_test` i `save_repository_rename_raw_test`. Ich powtórzone kontrole payloadu i rollbacku usunięto; pozostają odpowiedniki w tym pliku, property tests i macierzy checkpointów.
- Krótkie `save_coordinator_startup`, `save_directory_lock`, `save_recovery_integrity` i `save_transaction_recovery` przeniesiono z `nowe_testy` do `data`. Macierz transakcji obejmuje pierwszy zapis, nadpisanie, rename i duplicate: 21 właściwych kombinacji checkpointów w Windows, 16 na platformach bez Windows displacement. Niewystępujące punkty bez poprzedniego pliku nie są rejestrowane. Delete zachowuje osobny test pliku i indeksu; nie jest operacją dwuplikowego protokołu checkpointów.
- `data/save_recovery_integrity_test.dart` sprawdza także brak poprawnego oryginału oraz uszkodzenie zatwierdzonego payloadu o niezmienionej długości, wstrzykiwane przez publiczny hook. Dowody pozostają nienaruszone przy kolejnych odmowach recovery. Procesowe odpowiedniki nadal są ręczne w `data/long/`.
- Błąd niejednoznacznego zapisu oznacza zachowanie opublikowanej kopii, staged index i dziennika, jeśli przywrócenie indeksu jest zablokowane. Test repozytorium sprawdza odmowę kolejnej operacji, a po usunięciu kontrolowanej przeszkody — przywrócenie starej pary i cleanup. Oczekiwanie tego samego przepływu poprawiono w `integration/save_management_flow_test.dart`.
- Dawną bibliotekę `save_management_property_test.dart` (2158 linii) rozbito na `core/services/save_name_policy_property_test.dart`, `save_copy_name_property_test.dart`, `save_size_formatter_property_test.dart` oraz `data/save_raw_operations_property_test.dart` i `save_index_property_test.dart`. Niezależne generatory/oracle znajdują się w `helpers/persistence/save_management_property_cases.dart` i sześciu częściach `properties/`; nie rejestrują testów i nie otwierają katalogu zapisów.
- Property 5 zachowuje 120 przypadków w 12 deterministycznych partiach po 10, z seedami 5–16 i zakresami rozmiaru od 8 do 127. Każdy przypadek nadal sprawdza pełne raw JSON i indeks przed duplicate, po duplicate oraz po rename. Pozostałe pięć properties zachowuje po 120 przypadków. Schematy generatora ograniczono do bieżącego oraz sąsiednich niezgodnych wersji; nie wymagamy migracji historycznych formatów.
- Z mieszanego `stage_six_persistence_test.dart` wydzielono `data/save_repository_workers_test.dart` (wspólny indeks, kompaktowy JSON, izolaty i diagnostyka sztabu) oraz `core/services/game_factory_preview_test.dart` (katalog klubów bez generowania ludzi).

Weryfikacja: **119/119** testów w 17 plikach persystencji i bezpośrednich usług. Osobno **1/1** poprawionego przepływu integration i **1/1** ręcznego smoke restartu po zabiciu writera. Property 5 wykonał wszystkie 120 wejść bez timeoutu, około 16 s w lokalnym przebiegu; nie jest to gwarancja czasu na innych maszynach. Analiza całego `test/`: 0 błędów i ostrzeżeń; pozostaje wcześniejsza informacja stylistyczna w `task26_team_events_test.dart`. Discovery/walidacja wrappera przechodzą. Pełnego standard ani całego long nie uruchamiano.

Logi są w `build/test-results/stage-two-*`. Znane oczekiwanie obsługi błędu `loadGame` w integration pozostaje do etapu 3; ten etap nie deklaruje zielonego wyniku całej kolekcji. Szczegółowa mapa zachowanych scenariuszy i ograniczenia odbioru znajdują się w `reports/test-audit-2026-10-21/etap-2-wdrozenie.md` (katalog raportów jest ignorowany przez Git).

## Etap 3 — kolejki i cykl życia kontrolera, zaakceptowany w `a88b32b`

Obecny wybór: **165 aktywnych plików, 11 long, 40 wpisów blacklisty**. Nie zmieniono kodu `lib/`, konfiguracji CI ani globalnych limitów. Krótkie integracje pozostają w standard, długie testy nadal wymagają jawnego uruchomienia.

- `game_controller_mutations_test.dart`, `game_controller_persistence_test.dart` i `game_controller_lifecycle_test.dart` przeniesiono z `nowe_testy/` do `app/providers/`. Zachowano wszystkie ich scenariusze, dodano jawne kontrole publikacji przed I/O, złożenia dwóch zmian, oczekiwania manualnego zapisu na autosave i odrzucenia starych metadata po reload tego samego ID.
- Usunięto stare `data/game_controller_mutation_queue_test.dart` i `messages/game_controller_message_operations_test.dart` po scaleniu z powyższymi testami oraz `app/providers/game_controller_message_commands_test.dart`. Komendy publikują stan przed zapisem; błąd autosave jest widoczny na barierze i nie cofa zastosowanej komendy. Retry zapisu wykonuje `persist`, a ponowienie już zastosowanego potwierdzenia jest no-op. Osobno sprawdzamy deduplikację, pierwszą opcję decyzji, efekt przed ack, błąd transformacji i ponowienie, bieżący snapshot oraz brak zmian dla nieprawidłowych komend.
- `integration/save_management_flow_test.dart` zmniejszono z 1112 do 214 linii. Zawiera trzy przepływy przez prawdziwy provider/coordinator/service/adapter/repository: rename → persist → duplicate → reload → delete, odrzucenie niezgodnego load z zachowaniem kariery oraz rollback i udane ponowienie. Dawne macierze nazw, rozmiaru i awarii mają odpowiedniki w testach `core/services`, `data` i szczegółowych testach providera; lokalizowane etykiety przeniesiono do `l10n/save_management_labels_test.dart`.
- Przy nieudanym `loadGame` sprawdzamy odrzucony Future oraz zachowanie poprzedniej aktywnej kariery i jej trwałego stanu. Początkowy load bez kariery nadal ma osobną kontrolę stanu błędu i późniejszego udanego load. Wszystkie wywołania `clear()` w przeniesionej macierzy są oczekiwane przez `await`.
- Dawne `nowe_testy/save_management_boundary_test.dart` usunięto po potwierdzeniu odpowiedników: interfejs i neutralne błędy w `core/services/save_management_service_test.dart`, mapowanie pięciu operacji w `data/save_management_adapter_test.dart`, rzeczywisty zapis/rename/duplicate w integracji i `data/save_repository_payload_test.dart`. Nie pozostawiono drugiej kopii tej samej macierzy adaptera.
- `integration/urgent_message_simulation_save_regression_test.dart` zawiera teraz dwa rzeczywiste przebiegi ustawienia true/false, zmiany kariery, read/ack, zapisu i ponownego utworzenia providerów/repozytorium. Globalna preferencja nie trafia do żadnego z zapisów, a read nie zastępuje ack.
- Duża macierz tej preferencji jest w `app/providers/urgent_preference_save_lifecycle_test.dart` i działa w pamięci. Dawne 128 indeksów dawało 60 unikalnych kombinacji i wiązało wartość bool z lifecycle. Obecne **120 kombinacji = 5 stanów odczytu × 3 wyniki zapisu preferencji × 4 lifecycle × 2 wartości bool** obejmuje wszystkie stare kombinacje i 60 dodatkowych, z osobnym wynikiem każdego testu. Osobny przypadek zachowuje JSON round-trip domeny.
- `app/providers/save_management_provider_test.dart` zachowuje dziewięć szczegółowych przypadków kolejki i invalidacji. Używa jednego mniejszego fixture'a na bibliotekę; dubler listowania nie może przypadkowo sięgnąć do dysku. Ze względu na rzeczywiste repozytorium plik ma tag `integration`, więc nie wchodzi do fast.

Weryfikacja: **223/223 testów w 13 plikach**, w tym pełny dotychczasowy new-game/branding flow (6 przypadków), szczegółowe zarządzanie zapisami (9), usługa i adapter oraz większy payload z etapu 2. Analiza całego `test/`: 0 błędów i ostrzeżeń; pozostaje wcześniejsza informacja stylistyczna w `task26_team_events_test.dart`. Formatter, `git diff --check` i walidacja discovery przechodzą. Logi: `build/test-results/stage-three-*`.

Nie uruchamiano pełnego standard, long ani testów z blacklisty. Etap nie deklaruje naprawy pozostałych historycznych testów kalendarza/domeny/UI. Szczegółowa mapa scenariuszy: `reports/test-audit-2026-10-21/etap-3-wdrozenie.md` (ignorowany przez Git). Kolejny etap wymaga review i osobnej zgody.

## Etap 4 — kalendarz, do review

Obecny wybór: **167 aktywnych plików, 13 long, 41 wpisów blacklisty**. Nie zmieniono `lib/`, ustawień systemowych ani CI.

- Nowe daty i wybór dnia przeniesiono z `nowe_testy/calendar_screen_test.dart` do `calendar/calendar_dates_test.dart` i `calendar_date_selection_test.dart`. Zachowano pełne cykle czterech sezonów, rok przestępny, daty przy zmianie czasu, kolumny miesięcy i wybór we wszystkich tygodniach. Zgodnie z decyzją użytkownika nie wymagamy osobnych uruchomień runtime’u w UTC/WSL; nie wymuszamy `TZ` i nie sprawdzamy godzinowego offsetu systemu.
- `calendar_pacing_phases_test.dart` przeniesiono do `calendar`. Kontrolowany runner i zegar mierzą dzień, observer, dodatnią resztę pacingu i końcowy zapis. Usunięto stary pomiar przez override `advanceOneDay`, którego batch nie wywołuje. Stałe pacera są nadal sprawdzane bez mierzenia rzeczywistego czasu hosta.
- `calendar_service_test.dart` rozróżnia stałe daty play-in i zmienne daty playoffów. Zachowuje niezależny przykład: seed 0, tydzień 32 — czwartek/niedziela; sprawdza też sloty i dni wolne w każdej rundzie dla trzech seedów.
- `game_controller_simulate_until_test.dart` używa repozytorium w pamięci, jednego mniejszego świata i sześciu klubów z pełnymi rosterami. Zachowuje kontrolę feedbacku, kolejności wyników, anulowania, zastąpienia sesji, braku zapisu i nieukończonego meczu. Wiele tygodni rzeczywistej symulacji wydzielono do `calendar/long/season_progression_long.dart`. Snapshot niezmienności rosteru zależny od placeholdera AI jest jedynym nowym `deferredCases` na blackliście; archiwum pełnego źródła nie służy do ponownego dodawania aktywnych przypadków.
- Popup jest sprawdzany zgodnie z obecnym kontraktem: tylko mecz drużyny gracza, pełne dane dostępności PL/EN, brak karty bez własnego meczu, kolory wyniku z obu perspektyw i długie nazwy na małym ekranie. Pełne dane pozostałych meczów nadal są w feedbacku kontrolera. Testy ekranu potwierdzają dialog przed przejściem do draftu.
- `calendar_preservation`, `calendar_simulation_bug_condition` i `calendar_tile_bug_condition` mają trwałe nazwy: `calendar_baseline`, `calendar_result_flow`, `calendar_tile_layout`. Pełna macierz 160 konfiguracji pozostaje przy samym kafelku, dodatkowa próbka 24 stanów sprawdza własności; cały ekran ma pięć reprezentatywnych konfiguracji zamiast ponawiania 160 kombinacji.
- Ustawienie urgent nadal obejmuje oba tryby, pending i dostarczenie następnego dnia, zwykły cel, mecz/draft/zdarzenie, snapshot batcha, udane i nieudane zapisy preferencji oraz przejścia ręczne/godzinowe. Powtarzane przebiegi ograniczono do rzeczywiście różnych parametrów. Helper `helpers/fixtures/calendar_fixtures.dart` ma dwa kompletne kluby i jeden mecz zamiast pełnej ligi w każdej iteracji.
- Poprawiono stare fixture’y: Combine jest automatyczny, więc test zatrzymania Home używa raportu skauta; `GameMessage` nie planuje dostarczenia na konkretną godzinę, więc test ostatniej godziny zaczyna się bezpośrednio o godzinie 10. Dziesięć ręcznych kliknięć nadal ma osobny test. Anulowanie z observera nie wymaga zbędnej przerwy pacera.
- Dawną integrację 1173 linii rozdzielono na dwa aktywne smoke w `calendar_pipeline_smoke_test.dart`, ręczne `long/calendar_popup_flow_long.dart` i `calendar_navigation_flow_long.dart` oraz wspólny `helpers/calendar/real_calendar_harness.dart`. Wszystkie siedem dotychczasowych scenariuszy ma swoje miejsce. Helper domyka rozpoczęte operacje przed usunięciem katalogu tymczasowego. Duble no-op w aktywnych testach nie dziedziczą domyślnego dostępu do zapisów aplikacji.

Weryfikacja: **158/158 testów w 22 plikach**, około 81 s całego ograniczonego procesu. Analiza całego `test/`: zero błędów i ostrzeżeń, pozostaje wcześniejsza informacja stylistyczna w `task26_team_events_test.dart`. Formatter, `git diff --check` i walidacja wyboru przechodzą. Logi: `build/test-results/stage-four-*`.

Nie uruchamiano pełnego standard ani long. `calendar/task39_season_service_test.dart` pozostaje aktywny, lecz nie był częścią tego odbioru: dotyczy nagród/rollover i znanego problemu oczekiwania okresu kontraktu, zaplanowanego w domenie etapu 6. Nie dodano go do blacklisty. Szczegółowa mapa i odroczenia: `reports/test-audit-2026-10-21/etap-4-wdrozenie.md` (ignorowany przez Git). Etap zatrzymany do review, bez commita.


## Etap 5 — poprawka trwałości Inbox, część pośrednia do review

Na bazie `e05a995` rozpoczęto etap 5. Użytkownik osobno zatwierdził naprawę produkcyjnego kontraktu potwierdzania wiadomości. Etap refaktoru testów nie jest jeszcze zakończony. Obecny wybór: **170 aktywnych plików, 13 long, 41 wpisów blacklisty**.

- Inbox zamyka potwierdzenie/decyzję dopiero po zakończeniu zapisu. Stan gry nadal jest publikowany przed I/O; błąd zapisu nie cofa efektu domenowego.
- Jedna operacja potwierdzania zachowuje pierwszą opcję i współdzieli Future podczas wielokliku. Błąd domenowy pozwala ponowić komendę; błąd persystencji wyświetla osobny komunikat PL/EN i przycisk „Ponów zapis”, który wykonuje `persist` bieżącego stanu bez powtarzania efektu.
- Operacja wiąże się z sesją kariery z chwili otwarcia arkusza. Reload tego samego ID, zmiana kariery i trwające przejście uniemożliwiają użycie starego potwierdzenia. Spóźnione zamknięcie usuwa wyłącznie własny arkusz, także gdy nad nim otwarto inną trasę.
- Nowe regresje mają docelowe miejsca: `app/providers/message_confirmation_test.dart`, `messages/inbox_persistence_boundary_test.dart` oraz `integration/message_confirmation_save_test.dart`. Nie wracamy do przejściowego `nowe_testy` podczas jego migracji.
- Weryfikacja: **57/57 testów w 7 plikach** (nowy kontrakt oraz dotychczasowe komendy, persystencja, lifecycle i mutacje kontrolera). Wśród nowych przypadków: blokowane I/O, PL/EN, niejednoznaczny zapis, wieloklik, błąd domenowy, powtarzany błąd zapisu, nowsza mutacja przed retry, zmiana kariery, unmount i trasa nad arkuszem. Integracja wykonuje rzeczywisty rollback po publikacji pliku i odczyt po restarcie providera; efekt decyzji pozostaje pojedynczy.
- Dodatkowo **4/4** istniejących przypadków preservation potwierdza mark-read zwykłej wiadomości, stan już odczytany/potwierdzony, dostępność zakładek oraz sześć tras przycisków nawigacyjnych. Analiza zmienionych źródeł: **0 problemów**. Logi w `build/test-results/stage-five-confirmation-*`. Testy używają wyłącznie repozytoriów w pamięci i własnych katalogów tymczasowych, bez urządzenia i bez zapisów użytkownika. Nie uruchomiono całego standard ani long.

Wstępny przebieg etapu 5 przed poprawką (11 plików): 168 zaliczeń i 13 niepowodzeń. Dziewięć dotyczy ogólnych wpisów `MessageCatalog` bez szablonów PL/EN; pozostałe obejmują ich pokrycie ARB oraz stare fixture’y/brakujące argumenty i numer schematu. Nie usunięto ani nie osłabiono tych testów. Osobną decyzję o uzupełnieniu ogólnych szablonów przedstawiono użytkownikowi; konsolidacja starych testów Inbox, przeniesienia i ustawienia nadal należą do dalszej części etapu 5. Nie wykonano commita.


### Uzupełnienie dziewięciu ogólnych szablonów PL/EN

Po zgodzie użytkownika dodano brakujące wpisy w `MessageTemplatesPl` i `MessageTemplatesEn`: playerEvent, teamEvent, retirementLeagueDigest, contractExpiring, contractLostToRival, contractExpired, tradeWindowEvent, draftPickLeague i ovrDigest. Użyto istniejących tekstów z ARB, bez nowych wymagań dotyczących danych ani zmian w dispatcherze/katalogu. Wzorce kontraktowe nadal wymagają swoich argumentów. Szczegółowe raporty digest zachowują pierwszeństwo przy resolve; ogólne klucze tych raportów również można bezpośrednio odczytać.

`l10n/message_template_fallbacks_test.dart` obejmuje 18 przypadków (9 wzorców × PL/EN): zgodność tekstów z ARB, interpolację, brak nierozwiniętych placeholderów, brakujące argumenty, domyślny/nieznany kind i pierwszeństwo digest. Przed poprawką wszystkie 18 odtwarzały brak wpisów. Po poprawce **171/171** testów w 7 plikach: nowa regresja, pełna spójność katalogu, MessageTextService, przełączenie języka w otwartym Inbox, komunikaty kontraktowe/sztabu i granica trwałości Inbox. Logi: `build/test-results/stage-five-template-fallbacks-*`. Pełny etap 5 nadal nie jest zakończony; nie uruchamiano całego standard ani long i nie wykonano commita.

Doprecyzowanie wcześniejszej diagnostyki: dziewięć ogólnych wzorców już miało teksty w ARB — brakowało ich tylko w katalogach MessageTextService. Osobne niepowodzenie `task8_message_l10n_test` dotyczy ośmiu kluczy ARB dla czterech wariantów szczegółowych (`calendar/freeAgencyOpen`, `scoutReport/preCombine`, `combine/completed`, `draftPick/selected`), których teksty są już w MessageTextService. Tej odrębnej niespójności nie zmieniono w poprawce dziewięciu wzorców. Nowy plik daje obecnie 171 aktywnych plików; 13 long i 41 wpisów blacklisty pozostaje bez zmian.

Weryfikacja uzupełnienia szablonów: analyzer trzech zmienionych źródeł — **0 problemów**; formatter i `git diff --check` przechodzą.


### Synchronizacja czterech szczegółowych wariantów z ARB

Po kolejnej zgodzie użytkownika uzupełniono po osiem kluczy title/body w PL i EN dla `calendar/freeAgencyOpen`, `scoutReport/preCombine`, `combine/completed` i `draftPick/selected`. Treści są identyczne z istniejącymi katalogami MessageTextService; dla draftu dodano typy placeholderów (playerName/position/teamName: String, pickNumber: int). Lokalizacje wygenerowano przez gen-l10n, bez ręcznej edycji wygenerowanych plików.

Weryfikacja: **151/151 testów w 4 plikach** — pokrycie MessageCatalog przez obie wersje ARB i zgodność placeholderów (`task8_message_l10n_test`), pełna spójność katalogów tekstowych, regresje dziewięciu ogólnych wzorców i przełączanie języka Inbox. Dodatkowe porównanie potwierdza zgodność wszystkich ośmiu dodanych tekstów z katalogiem w każdym języku. Gen-l10n i `git diff --check` przechodzą. Logi: `build/test-results/stage-five-arb-sync-*`.

Obie zgłoszone niespójności katalogów są rozwiązane. Pozostała konsolidacja i migracja testów etapu 5; cały etap nadal nie jest zakończony. Bez commita, pełnego standard ani long. Wybór testów pozostaje bez zmian: 171 aktywnych plików, 13 long, 41 wpisów blacklisty.


## Etap 5 — wiadomości, lokalizacje i ustawienia, do review

29 października 2026. Baza: commit użytkownika `8a18e10` (zaakceptowane poprawki trwałości Inbox i katalogów PL/EN). Obecna część zmienia **wyłącznie testy i dokumentację**, bez `lib/`, CI, ustawień systemowych ani commitów agenta. Wybór: **171 aktywnych plików, 12 long, 41 wpisów blacklisty**.

- `contract_messages`, `staff_season_messages` i `message_locale_switch` są teraz w `messages/`. Spójność katalogu przeniesiono do `l10n/message_catalog_consistency_test.dart`, a dawne Task 8 do `l10n/message_resources_test.dart`. Usunięto historyczne numery z nazw porządkowanych testów wiadomości.
- `messages/inbox_confirmation_controls_test.dart` zastępuje stare widget/property/exploration: 18 osobnych przypadków wielokliku (ack/decyzja × 2–10 kliknięć) z trzymanym zapisem, blokadą przycisków i pojedynczym pop; dodatkowo retry domeny, rezerwacja pierwszej karty, nieudany autosave odczytu, zewnętrzne zamknięcie arkusza oraz Home/Calendar po sukcesie. Osobno pozostają `inbox_persistence_boundary` (PL/EN, błąd zapisu zwykły/niejednoznaczny, save-only retry, lifecycle) i testy komend/potwierdzania w `app/providers`. Seedy i rzeczywiste opóźnienia starych kopii nie stanowiły dodatkowych oracles; długą macierz exploration usunięto po scaleniu jej scenariuszy.
- Efekt decyzji i kolejność/read/sort są w `messages/inbox_order_and_decisions_test.dart` oraz `message_service_test.dart`; UI sekcji, digest i archiwum w `inbox_sections_test.dart`, a odczyt/ordinary/już potwierdzone, puste stany, zakładki i sześć tras akcji w `inbox_behavior_test.dart`. Nie ma już testu przypinającego historyczny schemat 23; aktualny format zapisu sprawdzają istniejące testy repozytorium/serializacji i integracja. Fixture’y walkowera zawierają wymagane reason/opponentName.
- `integration/inbox_flow_test.dart` zachowuje pięć pełnych przepływów produkcyjnego routera/repozytorium: ack → decyzja → reload → wznowienie, błąd I/O i save-only retry, nawigacja podczas zapisu, rzeczywiste skutki zespołu/zawodnika oraz wymiana i counter z query parametrem. Pozostałe światy mają dwa kompletne kluby, a wymiana zachowuje pełne dane. Test czeka osobno na operację, trwałość i animację; sprzątanie zwalnia bariery i kończy kolejkę przed usunięciem własnego katalogu tymczasowego.
- Semantyka batcha i przekazanie do Inbox są w `calendar/urgent_message_inbox_handoff_test.dart`: **36 przypadków lifecycle = 2 ustawienia × 3 wyniki × 3 miejsca dostarczenia × 2 liczby wiadomości**, **24 przypadki UI = 2 ustawienia × 2 języki × Home/Calendar × 3 wyniki** oraz jeden manualny read/ack. Usunięto zależność liczby wiadomości od ustawienia. Test draftu potwierdza istniejący dialog przed nawigacją/CTA. Home fake obsługuje aktualne API `completeEventAtCurrentDay`, bez uruchamiania prawdziwej symulacji przez przypadkowy brak override.
- Provider preferencji ma **22 osobne przypadki odczyt → zapis → odtworzenie** (11 stanów, w tym sześć niepoprawnych typów, × obie zapisywane wartości), a także błędy, barierę publikacji i kolejność szybkich zapisów. `ui/urgent_setting_state_test.dart` ma **36 przypadków**: 6 stanów odczytu × 3 wyniki zapisu × PL/EN, z remountem i różnymi stanami kariery. Dawne 120 iteracji dawało 18 kombinacji. `ui/urgent_setting_accessibility_test.dart` ma **16 reprezentatywnych konfiguracji** obu języków, obu wartości i skal 1.0/1.3/1.5/2.0, z flagami dostępności, testem layoutu, prawdziwą akcją semantyczną i klawiaturą. Zwykłe testy ekranu zachowują też ponowny odczyt w tym samym języku. Wszystkie korzystają z jednego `PreferencesTestDouble`; dużą macierz lifecycle zapisu z etapu 3 pozostawiono.

Odbiór: **556/556 testów w 35 plikach**, około 126 s w jednym ograniczonym procesie. To całe `messages/` i `l10n/`, wskazane integracje, providery, ustawienia oraz sześć testów kalendarzowej polityki/handoff. Po doprecyzowaniu zachowania wszystkich ID w sortowaniu powtórzono jego 3/3 przypadki. Analiza całego `test/`: **0 błędów i ostrzeżeń**, pozostaje wcześniejsza informacja stylistyczna `task26_team_events_test.dart:185`. Formatter, `git diff --check`, discovery/walidacja wrappera i odrzucenie long w CI przechodzą. Logi: `build/test-results/stage-five-acceptance/` (również dokładna lista 35 plików), `stage-five-order-final` i `stage-five-analyze-final`.

Nie uruchamiano całego standard, long, Task 38 ani blacklisty. Testy zdarzeń Task 25/26 przeszły i zachowują dotychczasowe oracles; ich algorytmów nie zmieniono. Historyczne nieudane próby w `stage-five-*` dotyczą wcześniejszych wersji fixture’ów, oczekiwania na zapis/animację i sprzątania; wynikiem odbioru jest wskazany końcowy zestaw. Etap zakończony do review. Kolejny etap wymaga osobnej zgody.

## Etap 6 — domena rynku, sztabu i modeli, do review

29 października 2026. Baza: commit użytkownika d441013 (etap 5). Zmiany dotyczą testów, fixture’ów i dokumentacji. Bez zmian w lib/, CI i globalnych limitach, bez commita agenta. Wybór: **174 aktywne pliki, 12 long, 42 wpisy blacklisty**.

- Z nowe_testy do market przeniesiono contract_period, contract_market_period, contract_boundary_save, negotiation_retention, phase_two_window, scouting_tier_five i signing_valuation; do match — people_lifecycle, lineup_slots i match_date_replay; do balance/gameplay_rules — stage_seven_balance. Zachowano roczną retencję z ochroną nadal używanych rekordów, granice dat/FA II, wycenę raw/display i naturalny tier 5.
- Monolit staff_contract_property (925 linii) rozdzielono na staff_negotiation_service, staff_offer_boundaries oraz helpers/market/staff_contract_oracle. Zachowano 24 scenariusze dla każdej z sześciu ról, statusy/CFO, progi raw 3.25/3.5/3.75, wynagrodzenia, długości, reakcje i rundy kontr. Oracles ratingu nadal są przepisane z dokumentacji, nie wyprowadzone z implementacji.
- Z mieszanego archiwum staff_negotiation_property odzyskano staff_negotiation_market: sześć ról po 18 scenariuszy faz/statusów, przeliczenie starego score, waiting/counter, ignorowanie nieistotnych atrybutów, replay i kolizja raw 3.25/3.30 przy tych samych gwiazdkach. Helpery fixture’ów, kontroli rynku i oracles są rozdzielone. AI pozostaje odroczone.
- staff_empty_slot_guards sprawdza sześć ról: zajęty slot, kandydata spoza stanu, ofertę do pustego slotu bez przedwczesnego zatrudnienia, brak członka przy finalizacji i niezmieniony payroll. Dla trzech mieszanych archiwów zastąpiono ogólne „recover in stage 6” zakresem AI i listą aktywnych właścicieli. Pozostałe części mają odpowiedniki w testach ratingu, prezentacji, payroll i zgodności danych.
- Zachowano szczegółowe macierze sześciu ról, clamp/precision, nieistotnych pól, snapshotów, sortowania, payroll, pustych slotów i obu ekranów. Usunięto staff_regression_suite — pięć zbiorczych smoke powielało istniejące kontrole. Pełne obliczenia pozostają w testach funkcji/modeli, bez ponawiania ich przez całe ekrany.
- declaration_split zastąpił core/models/draft_season_serialization: 11 modeli, domyślne pola, tożsamość picków/board/lottery, osadzenie w save oraz konwersja prospekta i zapisane zużycie RNG. model_examples.json zachowuje reprezentatywne dane i niezależny wynik konwersji. Usunięto generator snapshotu i fingerprinty całych lig/defaults; reorganizacja pełnej generacji pozostaje w etapie 7.
- Pliki Task w market/match mają nazwy domenowe. task41_core_coverage rozdzielono na match/cohesion i market/trade_asset_values. Kalibracja Task 24 nadal jest wyłączona; usunięto pusty main, aby przyszłe przywrócenie wymagało rzeczywistego testu.

Korekty fixture’ów i oczekiwań: historyczne piny schematu 23; spadek rozwoju z przewinięciem postępu do 99 i obniżeniem OVR; identyfikacja zawodnika po ID po rollover; spójność pozycji i typu atrybutów; kanoniczne firstSeason/lastSeason; QO przed wygaśnięciem, offer sheet w FA I; aktywny ostatni slot FA II i zamknięcie następnego ranka; progi scoutingu 20/30/40/50 tygodni; generacja pełnej klasy i wycinek do UI; brak kontuzjowanego/zawieszonego w XI/bench; zapis Combine przy opuszczeniu ekranu, z zachowanym ProviderScope. Test Squad używa rzeczywistych tapnięć. Finalizacja draftu ma 89 przygotowanych picków i jeden jawny wybór, bez wykonywania 90 decyzji AI.

Jedyny nowy wpis blacklisty to dawny test oczekujący, że autonomiczne AI zatrudni wolnego agenta w tydzień. Jest w market/disabled/free_agency_ai_acquisition_test.dart.disabled; finalizacja draftu i wygaśnięcie kontraktu pozostają aktywne. To wyłączenie AI zgodne z zakresem użytkownika.

Odbiór: **451 zaliczonych, 0 niepowodzeń i 1 wcześniejszy SKIP w 55 plikach**, około 117 s procesu. Zakres: całe aktywne market, staff, match, balance, core/models, dwie kolekcje zgodności danych sztabu i calendar/task39_season_service. SKIP dotyczy pełnego scoringu nagród po redukcji zapisanych statystyk; istniał przed etapem i nadal wymaga uwagi przy końcowym odbiorze wyłączeń. Nie zmieniono oczekiwanych zwycięzców, aby go reaktywować. Aktywne progi nagród, Coach of the Year i historia/rollover przeszły.

Analiza całego test/: **0 błędów i ostrzeżeń**, jedna wcześniejsza informacja stylistyczna w messages/task26_team_events_test.dart:185. Formatter, git diff --check, discovery/blacklista i ochrona long przed CI przechodzą. Log i lista 55 plików: build/test-results/stage-six-acceptance; analiza: stage-six-analysis-acceptance. Nie uruchomiono pełnego standard, long, Task 38 ani blacklisty. Etap zakończony do review; etap 7 wymaga osobnej zgody.

## Etap 7 — generacja, filtry i prezentacja, do review

29 października 2026. Baza: commit użytkownika `b5727d9` (etap 6). Etap zakończony; bez commita agenta. Jedyną zmianą produkcyjną jest zatwierdzona przez użytkownika poprawka kontrastu `ZoneFrame`. Discovery: **197 aktywnych plików, 13 long i 42 wpisy blacklisty**. Nie zmieniono CI ani limitów runnera.

- `squad_presentation_property_test` (3592 linie) zastąpiło 13 plików tematycznych: projekcja formy/statusu/strefy/rosteru, rozmiar kadry, przypisania pozycji, priorytet statusów, nazwiska, kolory OVR/formy, zmiana strefy, sortowanie i dostępne podsumowanie. Zachowano wszystkie 13 właściwości, po 120 przypadków, seedy, shrinkery, diagnostykę oraz niezależne oczekiwania kolorów, kolejności i semantyki. Nowe pliki mają 118–489 linii. Wspólny oracle formy jest w `helpers/presentation/form_color_oracle.dart`.
- `PlayerListTile` (1186 linii) rozbito na content/layout/semantics/gradients/interaction ze wspólnym harness w `helpers/widgets`. Zachowano 14 scenariuszy, rzeczywiste gesty i przekazywane ID, niezależne kliknięcie profilu, skalowanie tekstu i stan zaznaczenia. Widgetowe gradienty mają reprezentatywne próbki, krawędzie i tekst; pełne macierze obliczeń pozostają w utils. Pitch, markery i wskaźnik wielkości kadry przeszły regresję.
- Proste testy prezentacji i kafelka używają małego, jawnego `presentationTeam`, bez tworzenia całej ligi. Fixture ma wszystkie naturalne pozycje, zgodne typy atrybutów/ról, różne OVR i dodatkowych pomocników zapewniających remisy sortowania. Nie zastępuje oracles oczekiwanych wyników. Testy rzeczywistej generacji nadal korzystają z produkcyjnego generatora/fabryki.
- `initial_roster_generation` rozdzielono na invariants/replay/serialization/service_boundaries oraz `data/long/initial_roster_distribution_long.dart`. Jedna kontrola dokładnej liczności pozycji i slotów XI obejmuje także wcześniejsze limity i unikalność/membership; zwykły zestaw sprawdza dziewięć jawnych seedów. Long wykonuje jeden przebieg 64 seedów: 1920 klubów, komplet formacji, częstotliwości z dotychczasową tolerancją ±40% oraz dokładne invarianty każdego klubu; raportuje postęp co osiem seedów. Usunięto osobne powtórzenie tych 64 światów dla samej obecności formacji i historyczny exploration 256 światów, którego oracle powielał dokładny invariant. To jawne zmniejszenie zakresu próbkowania, bez rozszerzania tolerancji.
- Stary pełny snapshot zawodnika sprzed zmian balansu zastąpiono kontrolą udokumentowanych warunków tworzenia graczy (kontrakt i kanoniczne sezony, Bird rights, stamina, forma, rola, staż, hidden/progress i początkowe OVR) dla wszystkich klubów przy seedzie 24680. Nie przepisano aktualnego wyniku do nowego golden. Pełna projekcja nadal jest porównywana między identycznymi żądaniami oraz przed/po rzeczywistym zapisie. Ręczne zmiany formacji/XI/bench/taktyki mają osobno round-trip modelu i repozytorium, bez narzucania im zasad początkowej generacji.
- Test granic usług kończy draft jednym jawnym wyborem z 89 przygotowanymi rekordami, bez 90 decyzji AI. Sprawdza zachowanie pierwotnych wolnych agentów oraz dodanie 30 niewybranych graczy i unikalność ID, zamiast nieaktualnego oczekiwania, że cała pula liczy 30. Wygaszany kontrakt ma spójne `yearsRemaining`, `firstSeason` i `lastSeason`. Odrzucenie wymiany nadal nie może przestawić rosterów. Bootstrap silnika i AI pozostają wyłączone; archiwum ma wskazanych aktualnych właścicieli aktywnych scenariuszy.
- `seeded_generation` i `game_fixtures` przeniesiono z `nowe_testy` do `data`. Kontrole fabryki są w `game_factory_test`, a referencyjne dni meczów i odstępy w `schedule_generator_test`. Usunięto mylący test, który deklarował rozdzielenie strumieni RNG zawodników/sztabu, a sprawdzał wyłącznie niepuste pule. Pozostaje porównanie całego świata przy ponownym użyciu fabryki po preview oraz unikalność ID sztabu.
- Filtry podzielono na range/player/prospect/pick/active oraz provider i interakcje. `search_filter_boundaries` scalono z właścicielami; `search_filters_interaction` przeniesiono z `nowe_testy`. Zachowano wszystkie 52 wcześniejsze przypadki matching, przecięcia wielu wymiarów, granice inclusive, display rounding, nieznane dane scoutingu, nullable setters, wybór bez klubu, pojedynczy rok, izolację providerów i rzeczywiste PL/EN interakcje. Regresja równości setów obejmuje też obie kolejności porównania niestandardowego `SplayTreeSet`.
- Bazowy przebieg miał 171 zaliczonych i 4 niepowodzenia. Trzy wynikały ze starego układu wskaźnika kadry: testy oczekiwały usuniętych endpointów i `FractionallySizedBox`. Teraz kontrolują obecny label/count/state, semantykę PL/EN oraz rzeczywistą szerokość i kolor wypełnienia, również po zmianie liczby zawodników. Czwarty ujawnił kontrast 2,14:1 w `ZoneFrame`. Po zgodzie użytkownika tekst otrzymuje osobny czytelny kolor, a ramka jest wzmacniana w kierunku czerni/bieli z zachowaniem rodziny koloru strefy. Nowe testy sprawdzają tekst ≥4,5:1 i ramkę ≥3:1 dla trzech stref × PL/EN × jasny/ciemny motyw. Nie obniżono progów testów.

Odbiór: pierwszy pełny zestaw etapu **185/185 w 41 plikach**, 63,42 s procesu (`build/test-results/stage-seven-acceptance`, wraz z listą plików). Po dodaniu do małego fixture'a remisów sortowania i końcowym rozdzieleniu mieszanego testu filtrów potwierdzono **66/66 prezentacji i widgetów** (44,09 s, `stage-seven-presentation-final`) oraz **87/87 filtrów** (17,48 s, `stage-seven-search-final`). Razem z niezmienionymi od poprzedniego zielonego przebiegu 33 przypadkami data daje to **186 różnych aktywnych przypadków sprawdzonych w etapie**, bez niepowodzeń i bez SKIP; nie jest to deklaracja jednego ponownego przebiegu 186 testów.

Dwa ręcznie wybrane long przeszły w 21,51 s procesu (`stage-seven-selected-long`): replay w trzech niezależnych VM, także po zapisie/odczycie i z aktualną ścieżką workera, oraz rozkład formacji. Pozostałych long, Task 38 i blacklisty nie uruchamiano. Są nadal wyłączone z normalnego discovery i CI.

Końcowa analiza całego `test/` i biblioteki zmienionego widżetu: **0 błędów i ostrzeżeń**, jedna wcześniejsza informacja stylistyczna w `messages/task26_team_events_test.dart:185`. Format-check, `git diff --check` i kontrola discovery/blacklisty/ochrony CI przechodzą. Logi analizy i formatowania: `stage-seven-analysis-acceptance`, `stage-seven-format-check`. Pełny standard/fast pozostaje odbiorem etapu 9. Etap 8 wymaga osobnej zgody użytkownika.

## Etap 8 — UI i branding: wdrożenie przygotowane, analiza niepotwierdzona

29 października 2026. Baza: commit użytkownika `0cc0cd2` (etap 7). Zmiany kodu i testów są przygotowane do review; etap pozostaje otwarty z powodu powtarzającego się timeoutu analizatora. Bez commita agenta. Discovery: **215 aktywnych plików, 13 long i 42 wpisy blacklisty**. Nie zmieniono CI, globalnych limitów ani ustawień systemowych.

- `team_selection_menu_test` (1541 linii) rozdzielono na flow/layout/accessibility/localization/assets. Zachowano 16 scenariuszy: pełne 30 preview, wyłączny wybór, walidację, tworzenie kariery, stan zapisu i błąd, semantyczną aktywację, język, resize i decode/fallback assetu. Wspólny `helpers/widgets/team_selection_harness.dart` jest używany także przez integrację tworzenia kariery; testy nie importują już innego pliku testowego. Double repozytorium dziedziczy po `NoDiskSaveRepository`.
- `squad_screen_redesign_test` (1265 linii) rozdzielono na presentation/selection/unavailable/navigation/drag_drop. Zachowano wszystkie 10 scenariuszy oraz dołączono dotychczasowy smoke Squad z Task 40 do prezentacji. `squad_slot_interaction` jest teraz w `ui/`, a niezależne testy domeny slotów pozostają w `match/`. Zachowano callbacki, rzeczywisty drag/drop, aktualizację providera, trzy tryby metryk, profile, puste stany i przełączanie Tactics.
- Oczekiwania zamian odpowiadają obecnemu kontraktowi: zastąpienie gracza w tym samym indeksie XI/bench, zamiast usuwania i dopisywania na koniec. Fixture z kontuzją jest normalizowany przed zapisaniem stanu porównawczego, tak jak przy rzeczywistym load. Test arkusza bramkarza niezależnie oczekuje wyłącznie GK spoza XI; wybiera kafelek po ID zamiast szukać pełnego nazwiska renderowanego w dwóch liniach. Nie poluzowano porównań list ani kontroli odmowy wystawienia kontuzjowanego gracza.
- `load_game_screen_save_management_test` (1052 linie) rozdzielono na list/semantics/operations/pending/rename. Zachowano metadane i rozmiary, zgodność schematu, dostępność pliku, load/delete/duplicate/rename, potwierdzenia, blokady, błędy i retry oraz PL/EN. `save_recovery_screen` scalono z listą. Osobny istniejący test dostępności nadal sprawdza starszy i nowszy schemat.
- `state_screen_split_interaction` rozprowadzono do `free_agency_form_state`, `contract_form_state`, `staff_form_state` i `prospects_selection_persistence`; wspólny harness obejmuje przygotowanie sesji i tę samą interakcję dla trzech ekranów. Zachowano tożsamość kontrolerów i wartości po zmianie języka, wyszukiwanie FA, walidację/anulowanie/ponowne otwarcie kontr i zapis selekcji watchlist/Combine przy wyjściu.
- `career_navigation`, `matchday_split_interaction` i `stage_six_rebuilds` przeniesiono do `ui/` jako `career_navigation`, `matchday_interaction` i `career_screen_rebuilds`. Matchday pozostaje zatrzymany, bez oceny jakości silnika. Z Task 23 odzyskano niezależną kontrolę zegara, przycisku pauzy i prędkości; odroczone są nadal wyniki symulacji, wpływ zmian na runtime i postęp zegara silnika. Manifest wskazuje aktywnych właścicieli zamiast `recoverInStage: 8`. Rebuild test nadal sprawdza brak przebudów Squad/table po zmianie samej daty oraz reakcję na rzeczywistą zmianę zespołu.
- Pozostałe Task 40 podzielono na finance_dashboard/home_dashboard/tactics_autosave/shell_actions ze wspólnym harness. Test finansów nie oczekuje już nieobecnych w ekranie sekcji gotówki i skrótów; sprawdza obecny cap/payroll, aprony, kondycję finansową i ostrzeżenie po przekroczeniu capu. Nie dodawano tych historycznych sekcji do implementacji.
- Zachowano wszystkie istniejące testy rejestru brandingu, pełne mapowanie 30 ID, fallback, rzeczywisty decode assetów, Home/Shell i responsywność. UI brandingu używa jednej niemutowalnej ligi zamiast wielokrotnego generowania światów. Tworzenie kariery i preview nadal korzystają z rzeczywistego `GameFactory`. Wspólna jawna macierz obejmuje sześć konfiguracji: mały portrait, rozmiar pośredni i landscape; skale 1.0/1.3/2.0; PL/EN, w tym oba języki przy 320×568 i 200%. Squad sprawdza pełny przepływ w tych sześciu konfiguracjach. Macierz statusów/semantyki zachowuje wszystkie cztery stany w obu językach, z przypisanymi reprezentatywnymi skalami zamiast pełnego iloczynu 24 kombinacji.

**Zatwierdzona poprawka produkcyjna:** pierwotny test responsywności wykrył przepełnienie arkusza zmian o 148 px przy 320×568 i skali tekstu 200%. Po zgodzie użytkownika `SubstituteSheet` używa jednego `CustomScrollView` z przewijanym nagłówkiem i listą sliverów. Zachowano limit wysokości, leniwe budowanie kandydatów i callbacki. Nowe cztery testy PL/EN × lista/pusty stan sprawdzają brak wyjątku, przewijanie i wybór ostatniego kandydata. Jest to jedyny zmieniony plik produkcyjny w etapie.

**Zakres weryfikacji:** 138 różnych aktywnych przypadków w 39 końcowych plikach ma zielony wynik w ograniczonych przebiegach i powtórzeniach. Nie jest to jeden wspólny przebieg 138 testów. Końcowa lista plików: `build/test-results/stage-eight-acceptance/selected-files.txt`. Nie uruchomiono pełnego standard/fast, long, Task 38 ani blacklisty.

- `stage-eight-sheet`: 4/4 regresje arkusza; 14,45 s całego procesu.
- `stage-eight-selection-saves`: 34/34, 12 plików; 93,93 s procesu, w tym sześć integracji tworzenia kariery.
- `stage-eight-branding-dashboard`: 70 zaliczonych i jeden historyczny błąd oczekiwania usuniętej sekcji gotówki. Wszystkie 60 przypadków brandingu, nawigacja, przebudowy, taktyka i Shell przeszły. Po aktualizacji oczekiwania oba przypadki finansów przeszły w `stage-eight-squad-final`. Po przeniesieniu jednego przypadku Squad do właściwego właściciela końcowy obszar branding/dashboard/career obejmuje 70 różnych przypadków.
- `stage-eight-interactions-first`: przed zewnętrznym limitem 170 s przeszło 15 przypadków; dwa niepowodzenia dotyczyły normalizacji kontuzjowanej ławki i szukania pełnego nazwiska w kafelku. W tym przebiegu przeszły wszystkie sześć konfiguracji responsywności Squad, sloty drag/load i long press, cztery interakcje Matchday oraz dwa zapisy selekcji prospektów. Obydwa niepowodzenia poprawiono i potwierdzono w następnym przebiegu.
- `stage-eight-forms`: 8/8 dla FA/kontraktów/sztabu; 62,24 s procesu.
- `stage-eight-squad-final`: 10 zaliczonych przypadków w sześciu plikach; błąd kompilacji siódmego pliku dotyczył dwóch importów po przeniesieniu smoke Squad. Importy uzupełniono. `stage-eight-presentation-final` potwierdza jego 5/5 przypadków (21,17 s procesu). `stage-eight-home-final` potwierdza pozostały test Home po uzupełnieniu importu rozszerzenia: 1/1, 30,92 s procesu.

Pierwszy bazowy przebieg osiągnął 52 zaliczone i 5 niepowodzeń przed limitem 180 s; nie był kompletnym wynikiem etapu. Cztery niepowodzenia były starymi oczekiwaniami Squad, piąte rzeczywistym przepełnieniem arkusza. Wczesne logi analiz i testów dotyczą wersji pośrednich, nie aktualnego wyniku poszczególnych przypadków.

**Niezakończona kontrola:** analiza całego `test/` w `stage-eight-analysis-four` nie miała błędów ani ostrzeżeń; zawierała dwie nowe uwagi stylistyczne (następnie poprawione) oraz wcześniejsze `messages/task26_team_events_test.dart:185`. Kolejna analiza wykryła brak importu rozszerzenia w wydzielonym teście Home; import uzupełniono i test skompilował się/przeszedł. Końcowe próby `stage-eight-analysis-final` oraz `stage-eight-analysis-verified` przekroczyły po 90 s bez diagnostyki. Nie można na tej podstawie potwierdzić końcowej analizy ani przypisać zawieszania konkretnemu błędowi projektu lub SDK. Dalsze próby zatrzymano zgodnie z instrukcją użytkownika dotyczącą nieprzewidzianych komplikacji. Decyzji wymaga dalsza diagnoza analizatora albo przyjęcie tej kontroli jako jawnie niezakończonej.

Kontrola discovery, blacklisty i wykluczenia long w CI przechodzi (`scripts/verify/test_runner_dry_run.Tests.ps1`); liczba long i wyłączeń nie zmieniła się. Formatowanie i `git diff --check` sprawdzono. W `nowe_testy` pozostają tylko event_services/postseason_finalization/season_randomness do końcowego rozliczenia w etapie 9. Nie rozpoczęto etapu 9 i nie wykonano commita.
