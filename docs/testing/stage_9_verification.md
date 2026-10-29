# Etap 9 — końcowy odbiór refaktoru testów

Stan roboczy z 29 października 2026, po `e77884c` (zaakceptowany etap 8). Agent nie wykonuje commitów. Wyniki dotyczą Windows, Flutter 3.41.4 i Dart 3.11.1, bez podłączonego urządzenia.

## Zakres zmian

- Ostatnie testy z `nowe_testy` mają właścicieli domenowych: `postseason_finalization` i `season_randomness` w `calendar`, a zdarzenia zawodników i obietnice zespołu w `messages`. Wspólny fixture jest w `helpers/fixtures/event_service_fixtures.dart`. Zachowano odpowiednio 8, 3, 3 i 1 przypadek.
- `performance/match_payload_test.dart` sprawdza treść i rozmiar zwartego wyniku, zachowanie rezultatu, roundtrip, idempotencję i brak mutowania źródła. Używa kontrolowanych danych bez silnika meczowego.
- Pięć krótkich testów workera używa małej ligi bez meczów: transport, cache, zastąpienie payloadu, zgodność daty i zamknięcie workera. Oryginalne cztery kosztowne integracje zachowano w `performance/long/simulation_worker_long.dart`.
- Usunięto duplikat `data/save_repository_payload_test.dart`: te same kontrole treści oraz save/load/rename/duplicate pozostają w `performance/long/save_repository_baseline_long.dart`. Duża syntetyczna historia nie obciąża standardu.
- Pomiary JIT/RSS/luk event loop mają nazwę `save_pipeline_measurements_long.dart`. Dodano komunikaty rozpoczęcia operacji i postęp do aktywnych long oraz kontrolowanych procesów. Nie dodano progów czasu zależnych od szybkości hosta.
- Task 42 rozdzielono na `core/source_boundaries_test.dart` i `l10n/catalog_parity_test.dart`. Heurystyczne kontrole źródeł rozpoznają właściciela `part of`, istniejące wyjątki biblioteki i właściwe zasoby PL/EN. Kontrola zgodności kluczy/placeholderów wszystkich ARB pozostaje aktywna.
- Integracja Inbox uruchamia callback zapisujący w `tester.runAsync`. Oczekiwanie rozróżnia czas animacji od czasu rzeczywistego I/O: pierwotne 120 iteracji dawało tylko około 0,6 s jawnego czasu na dysk. Diagnostyka retry wykazała publikację obu plików i zakończenie zapisu już podczas teardown po przekroczeniu pośredniego limitu 10 s. Oczekiwanie ma teraz limit 30 s, cały przypadek 2 min oraz diagnostykę prób, zakończonych zapisów i ostatniego checkpointu. Zachowano asercje błędu, braku zapisu po nieudanej próbie i pojedynczego udanego retry; nie ukryto przypadku tagiem ani SKIP.
- Usunięto pusty już `nowe_testy` oraz jego wpis w wyborze obszarów runnera. Historię zachowano w `new_tests_history.md` i `test_refactor_history.md`; `test/README.md` opisuje bieżące użycie.

## Wyłączenia i granice odbioru

Discovery obejmuje **217 aktywnych plików**, **14 aktywnych long** i **42 pliki blacklisty**. Szczegółowy wykaz: [isolated_suites.md](isolated_suites.md). Nie dodano nowych pozycji blacklisty. Task 38 pozostaje wyłączony i nie był uruchamiany.

Jeden istniejący SKIP wyliczania liderów nagród w `calendar/task39_season_service_test.dart` pozostaje na wyraźną decyzję użytkownika: system nagród wymaga przebudowy. Jest odrębny od blacklisty AI/silnika. Nie oznacza zaliczenia tego scenariusza.

Nie zmieniano kodu produkcyjnego, systemowej strefy czasowej ani konfiguracji CI. Odbiór dat dotyczy lokalnej strefy Windows i istniejących testów obejmujących granice DST; dodatkowy odbiór UTC nie był uzgodniony. Pomiary debug/JIT nie są pomiarami wydajności urządzenia.

## Weryfikacja

- **Standard: PASS**, 1665 zaliczonych przypadków, 1 zaakceptowany SKIP nagród, 0 FAIL, 0 TIMEOUT. 217 plików; 253,34 s wraz z uruchomieniem procesu. Logi: `build/test-results/20261029-183711-933-35836/`.
- **Fast: PASS**, 1585 zaliczonych przypadków, 1 SKIP nagród, 0 FAIL, 0 TIMEOUT; 240,40 s. Profil wykluczył 80 przypadków według tagów, nie przenosił ich do blacklisty. Logi: `build/test-results/20261029-184152-105-25536/`.
- **Wybrane long: 3/3 PASS**, 14,80 s łącznie z uruchomieniem procesu. Jawnie wykonano tylko `performance/long/save_pipeline_measurements_long.dart` (trzy próbki pomiarowe) i `data/long/process_cleanup_long.dart` (zakończenie rodzica/dziecka po przerwanym teście i timeout workera). Logi: `build/test-results/stage-nine-selected-long/`. Pozostałe **12 plików LONG_NOT_RUN**; wszystkie **42 pliki BLACKLISTED** pozostały poza wykonaniem. W standard/fast wszystkie 14 long są LONG_NOT_RUN.
- Kontrola discovery/blacklisty/opcji/blokady CI: `scripts/verify/test_runner_dry_run.Tests.ps1` — PASS.
- Kontrola kodów wyjścia, przekazywania argumentów/logów i zabijania drzewa procesu po timeout: `scripts/verify/test_runner_exit_codes.Tests.ps1` — PASS.
- Podzbiór migracji i krótkiego performance: 21/21 PASS (`build/test-results/stage-nine-targeted/`).

Próby wstępne ujawniły nieaktualne heurystyki Task 42 i zbyt krótkie oczekiwanie I/O w Inbox. Powyższe wyniki standard/fast pochodzą z pełnych przebiegów po ich korekcie; wcześniejszych FAIL nie traktujemy jako końcowego odbioru.

- `dart analyze test` — kod 0, bez błędów i ostrzeżeń. Pozostaje wcześniejsza informacja stylistyczna `use_null_aware_elements` w `messages/task26_team_events_test.dart:185`; nie zmieniano tego niezwiązanego fragmentu.
- `dart format --output=none --set-exit-if-changed` dla 25 zmienionych/dodanych źródeł Dart — kod 0, 0 plików wymagających formatowania.
- `git diff --check` — kod 0. W `lib/` i `.github/` nie ma zmian tego etapu.

Etap 9 jest gotowy do review. Nie wykonano commitów ani nie rozpoczęto przebudowy nagród, AI czy silnika meczowego.
