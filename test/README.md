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
- `messages/long`: historyczną macierz exploration wielokliku.

Krótkie checkpointy wyjątków, walidacja uszkodzonych danych, blokady między instancjami/izolatami oraz szybka generacja pozostają aktywne. Wydzielenie nie zmienia ich asercji ani modelu gry. Kolejne etapy zmniejszą koszt i konsolidują scenariusze.

## Tymczasowa blacklista AI i silnika

Jedynym rejestrem jest [blacklist.json](blacklist.json). Pliki `*.dart.disabled` nie biorą udziału w discovery ani analizie Dart. Taki plik musi mieć dokładny wpis z pierwotną ścieżką, powodem oraz warunkiem reaktywacji. Wrapper odrzuca brak pliku, duplikat, ścieżkę poza obszarem, brak wpisu i nazwę testu omijającą izolację.

- Wszystkie testy `ai/` są odroczone. Task 38 i benchmark Task 35 pozostają w `ai/long/` jako wyłączone źródła; profil long ich nie uruchamia.
- W `match/` odroczono testy docelowej mechaniki silnika. Test generatora terminarza odzyskano w `data/schedule_generator_test.dart`.
- W prostych plikach mieszanych usunięto z aktywnej rejestracji wyłącznie przypadki AI/silnika, zachowując pozostałe testy domeny i Squad UI. Kopia całego oryginału w `disabled/` stanowi kontekst; **przy reaktywacji należy odzyskać tylko `deferredCases` z manifestu**, bez ponownego dodawania nadal aktywnych scenariuszy.
- Cztery większe pliki mieszane wymagają późniejszego odzyskania niezależnych przypadków: `staff_empty_slot_property`, `staff_raw_display_separation_property`, `staff_negotiation_property` — etap 6; `task23_matchday` — etap 8. Manifest zawiera `recoverInStage` i wymagany zakres. To przejściowe odroczenia, które nie mogą pozostać po końcowym odbiorze niezależnej domeny/UI.
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

## Etap 3 — kolejki i cykl życia kontrolera, do review

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
