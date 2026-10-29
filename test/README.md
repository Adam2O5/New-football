# Testy — uruchamianie i podział

Wymagania: Flutter **3.41.4**, PowerShell **7+**, wykonane `flutter pub get`.

```powershell
pwsh -NoProfile -File scripts/test.ps1
pwsh -NoProfile -File scripts/test.ps1 -Profile fast
pwsh -NoProfile -File scripts/test.ps1 -Area search
pwsh -NoProfile -File scripts/test.ps1 -Profile standard -DryRun
pwsh -NoProfile -File scripts/test.ps1 -Profile long -Area performance -DryRun
```

- **standard** uruchamia wszystkie aktywne `*_test.dart`, także krótkie integracje. Domyślny twardy limit procesu to 600 s.
- **fast** / **-Fast** wybiera te same pliki i wyklucza przypadki z tagami `slow`, `benchmark`, `integration`. Nie jest synonimem wyłącznie testów jednostkowych; zawiera też szybkie widgety i assety.
- **long** wybiera wyłącznie `test/<obszar>/long/*_long.dart`, każdy plik w osobnym procesie z domyślnym limitem 900 s. Wymaga jawnego uruchomienia. Jest odrzucany przy `CI=true`; CI/CD go nie uruchamia.
- **-DryRun** waliduje wybór i blacklistę bez uruchamiania Fluttera. **-TimeoutSeconds N** ustala zewnętrzny budżet procesu, w long osobno dla każdego pliku. Runner przekazuje też timeout 30 s na przypadek; deklaracje lokalne testów mogą go nadpisywać.
- Dostępne są **-Tags**, **-ExcludeTags** i **-Coverage**. Coverage jest dozwolone dla aktywnych zestawów; `long -Coverage` jest odrzucane.

`-Area`: `ai`, `app`, `balance`, `branding`, `calendar`, `core`, `data`, `integration`, `l10n`, `market`, `match`, `messages`, `performance`, `search`, `staff`, `ui`. `helpers/` zawiera fixture’y, oracles, workery i harnessy. Przejściowy folder `nowe_testy` został usunięty po migracji scenariuszy.

Zwykłe `flutter test` również pomija long/disabled dzięki nazwom plików. Twardy limit procesu, logi i zakończenie jego drzewa zapewnia wrapper, dlatego jest zalecanym wejściem lokalnie i w CI.

## Długie i odroczone zestawy

Bieżący wykaz: [isolated_suites.md](../docs/testing/isolated_suites.md). Długie aktywne pliki i blacklista są osobnymi grupami; żadnej z nich nie należy raportować jako zaliczonej bez wykonania.

- `performance/long`: duże save/load/rename/duplicate, próbki JIT/RSS i luk event loop, projekcja wielkości sezonu oraz pełna integracja workera. Metryki JIT/debug nie są profilem urządzenia. Wielosezonowe historie w fixture’ach są syntetyczne, nie symulowane.
- `data/long`: replay w osobnych VM, crash/recovery i blokady między procesami, sprzątanie procesów oraz ograniczony rozkład formacji.
- `calendar/long`: rzeczywiste przebiegi kalendarza i kosztowne interakcje/pacing. Mają parametry, postęp i zewnętrzny limit; nie są codziennym smoke.

Jedyny rejestr wyłączeń AI/silnika to [blacklist.json](blacklist.json): pliki `*.dart.disabled`, powód i warunki reaktywacji. Archiwa mieszane wskazują aktywnych właścicieli odzyskanych przypadków; przy przyszłej reaktywacji należy odzyskać wyłącznie odroczone scenariusze. Task 38 pozostaje wyłączony, bez zmian jego logiki. Reaktywacja wymaga implementacji mechaniki, kontroli źródła i ograniczonego uruchomienia, a następnie usunięcia wpisu manifestu.

Osobno pozostaje **jeden jawny SKIP wyliczania liderów nagród** w `calendar/task39_season_service_test.dart`: system nagród jest do przebudowy po redukcji danych meczowych. Użytkownik zatwierdził pozostawienie tego SKIP 29 października 2026. Nie dopisano go do blacklisty AI. Aktywne kontrole Coach of the Year, progów i rollover pozostają wykonywane.

## Logi i weryfikacja runnera

Rzeczywiste uruchomienia zapisują `selected-files.txt`, `summary.json`, `run-N/stdout.log`, `stderr.log` i `result.json` pod `build/test-results/<czas>-<PID>/`. `PASS` / `FAIL` zachowują kod dziecka; `TIMEOUT` ma kod **124** i kończy drzewo procesu. Błąd konfiguracji lub brak testów ma kod **2**. `LONG_NOT_RUN` i `BLACKLISTED` oznaczają zakres poza wykonaniem. Platformowe i jawne SKIP pozostają widoczne w logu Fluttera.

```powershell
pwsh -NoProfile -File scripts/verify/test_runner_dry_run.Tests.ps1
pwsh -NoProfile -File scripts/verify/test_runner_exit_codes.Tests.ps1
```

Pierwsza kontroluje discovery, manifest, opcje i blokadę long w CI. Druga sprawdza stdout/stderr, argumenty ze spacjami, kody wyjścia i zabijanie kontrolowanego rodzica z dzieckiem. Obie są niezależne od symulacji gry.

Fixture’y I/O używają własnych katalogów tymczasowych; duble bez dysku odrzucają niewspierane operacje. Testy UI rozróżniają fałszywy czas animacji od rzeczywistego I/O. Kontrole źródeł w `core/source_boundaries_test.dart` są heurystykami z jawnymi wyjątkami legacy, a nie pełnym audytem AST; zasoby tłumaczeń PL/EN mają osobne testy katalogów.

Historia i wyniki wcześniejszych etapów: [test_refactor_history.md](../docs/testing/test_refactor_history.md). Pierwotne regresje i pomiary: [new_tests_history.md](../docs/testing/new_tests_history.md). Końcowy odbiór, zakres i wyniki etapu 9: [stage_9_verification.md](../docs/testing/stage_9_verification.md).
