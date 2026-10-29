# Zestawy izolowane od standard i CI

14 aktywnych plików long jest dostępnych wyłącznie przez jawny profil long. 42 pliki wyłączone są rejestrowane osobno w [blacklist.json](../../test/blacklist.json). Task 38 nie jest aktywnym long i nie był uruchamiany w refaktorze.

## Aktywne long

- [test/calendar/long/calendar_navigation_flow_long.dart](../../test/calendar/long/calendar_navigation_flow_long.dart)
- [test/calendar/long/calendar_popup_flow_long.dart](../../test/calendar/long/calendar_popup_flow_long.dart)
- [test/calendar/long/calendar_simulation_property_long.dart](../../test/calendar/long/calendar_simulation_property_long.dart)
- [test/calendar/long/season_progression_long.dart](../../test/calendar/long/season_progression_long.dart)
- [test/data/long/initial_roster_distribution_long.dart](../../test/data/long/initial_roster_distribution_long.dart)
- [test/data/long/process_cleanup_long.dart](../../test/data/long/process_cleanup_long.dart)
- [test/data/long/save_directory_lock_long.dart](../../test/data/long/save_directory_lock_long.dart)
- [test/data/long/save_recovery_integrity_long.dart](../../test/data/long/save_recovery_integrity_long.dart)
- [test/data/long/save_transaction_recovery_long.dart](../../test/data/long/save_transaction_recovery_long.dart)
- [test/data/long/seeded_generation_long.dart](../../test/data/long/seeded_generation_long.dart)
- [test/performance/long/save_pipeline_measurements_long.dart](../../test/performance/long/save_pipeline_measurements_long.dart)
- [test/performance/long/save_repository_baseline_long.dart](../../test/performance/long/save_repository_baseline_long.dart)
- [test/performance/long/save_size_guard_long.dart](../../test/performance/long/save_size_guard_long.dart)
- [test/performance/long/simulation_worker_long.dart](../../test/performance/long/simulation_worker_long.dart)

Wyniki ręcznych, wybranych przebiegów znajdują się w raporcie etapu 9. Brak wykonania pozostałych plików oznacza LONG_NOT_RUN, nie PASS. Limity są zabezpieczeniem przed zawieszeniem, nie progami wydajności sprzętu.

## Blacklista

### ai: 12 plików

- [test/ai/disabled/staff_ai_contract_market_integration_test.dart.disabled](../../test/ai/disabled/staff_ai_contract_market_integration_test.dart.disabled)
- [test/ai/disabled/staff_ai_raw_property_test.dart.disabled](../../test/ai/disabled/staff_ai_raw_property_test.dart.disabled)
- [test/ai/disabled/staff_ai_raw_rating_test.dart.disabled](../../test/ai/disabled/staff_ai_raw_rating_test.dart.disabled)
- [test/ai/disabled/task32_ai_evaluation_test.dart.disabled](../../test/ai/disabled/task32_ai_evaluation_test.dart.disabled)
- [test/ai/disabled/task33_ai_matchday_test.dart.disabled](../../test/ai/disabled/task33_ai_matchday_test.dart.disabled)
- [test/ai/disabled/task34_ai_trade_test.dart.disabled](../../test/ai/disabled/task34_ai_trade_test.dart.disabled)
- [test/ai/disabled/task35_ai_contract_market_test.dart.disabled](../../test/ai/disabled/task35_ai_contract_market_test.dart.disabled)
- [test/ai/disabled/task36_ai_draft_test.dart.disabled](../../test/ai/disabled/task36_ai_draft_test.dart.disabled)
- [test/ai/disabled/task37_ai_events_test.dart.disabled](../../test/ai/disabled/task37_ai_events_test.dart.disabled)
- [test/ai/disabled/task37_ai_roster_test.dart.disabled](../../test/ai/disabled/task37_ai_roster_test.dart.disabled)
- [test/ai/long/task35_ai_contract_market_benchmark_long.dart.disabled](../../test/ai/long/task35_ai_contract_market_benchmark_long.dart.disabled)
- [test/ai/long/task38_ai_season_calibration_long.dart.disabled](../../test/ai/long/task38_ai_season_calibration_long.dart.disabled)

### balance: 2 plików

- [test/balance/long/balance_season_long.dart.disabled](../../test/balance/long/balance_season_long.dart.disabled)
- [test/balance/long/task24_calibration_long.dart.disabled](../../test/balance/long/task24_calibration_long.dart.disabled)

### calendar: 3 plików

- [test/calendar/disabled/task39_season_service_test_deferred.dart.disabled](../../test/calendar/disabled/task39_season_service_test_deferred.dart.disabled)
- [test/calendar/disabled/task6_hourly_flow_test_deferred.dart.disabled](../../test/calendar/disabled/task6_hourly_flow_test_deferred.dart.disabled)
- [test/calendar/disabled/game_controller_simulation_deferred.dart.disabled](../../test/calendar/disabled/game_controller_simulation_deferred.dart.disabled)

### data: 2 plików

- [test/data/disabled/initial_roster_generation_test_deferred.dart.disabled](../../test/data/disabled/initial_roster_generation_test_deferred.dart.disabled)
- [test/data/disabled/staff_data_compatibility_integration_test_deferred.dart.disabled](../../test/data/disabled/staff_data_compatibility_integration_test_deferred.dart.disabled)

### market: 4 plików

- [test/market/disabled/free_agency_ai_acquisition_test.dart.disabled](../../test/market/disabled/free_agency_ai_acquisition_test.dart.disabled)
- [test/market/disabled/staff_negotiation_property_test.dart.disabled](../../test/market/disabled/staff_negotiation_property_test.dart.disabled)
- [test/market/disabled/services_test_deferred.dart.disabled](../../test/market/disabled/services_test_deferred.dart.disabled)
- [test/market/disabled/task36_contract_lifecycle_test_deferred.dart.disabled](../../test/market/disabled/task36_contract_lifecycle_test_deferred.dart.disabled)

### match: 15 plików

- [test/match/disabled/match_engine_test.dart.disabled](../../test/match/disabled/match_engine_test.dart.disabled)
- [test/match/disabled/task10_injury_test_deferred.dart.disabled](../../test/match/disabled/task10_injury_test_deferred.dart.disabled)
- [test/match/disabled/task11_discipline_test_deferred.dart.disabled](../../test/match/disabled/task11_discipline_test_deferred.dart.disabled)
- [test/match/disabled/task12_form_stamina_test_deferred.dart.disabled](../../test/match/disabled/task12_form_stamina_test_deferred.dart.disabled)
- [test/match/disabled/task14_team_management_test_deferred.dart.disabled](../../test/match/disabled/task14_team_management_test_deferred.dart.disabled)
- [test/match/disabled/task15_pre_match_simulation_test.dart.disabled](../../test/match/disabled/task15_pre_match_simulation_test.dart.disabled)
- [test/match/disabled/task16_team_shape_test.dart.disabled](../../test/match/disabled/task16_team_shape_test.dart.disabled)
- [test/match/disabled/task17_match_loop_test.dart.disabled](../../test/match/disabled/task17_match_loop_test.dart.disabled)
- [test/match/disabled/task18_shot_pipeline_test.dart.disabled](../../test/match/disabled/task18_shot_pipeline_test.dart.disabled)
- [test/match/disabled/task19_live_match_test.dart.disabled](../../test/match/disabled/task19_live_match_test.dart.disabled)
- [test/match/disabled/task20_incidents_test.dart.disabled](../../test/match/disabled/task20_incidents_test.dart.disabled)
- [test/match/disabled/task21_momentum_context_test.dart.disabled](../../test/match/disabled/task21_momentum_context_test.dart.disabled)
- [test/match/disabled/task22_match_result_test.dart.disabled](../../test/match/disabled/task22_match_result_test.dart.disabled)
- [test/match/disabled/task23_matchday_test.dart.disabled](../../test/match/disabled/task23_matchday_test.dart.disabled)
- [test/match/disabled/task41_matchday_squad_ui_test_deferred.dart.disabled](../../test/match/disabled/task41_matchday_squad_ui_test_deferred.dart.disabled)

### staff: 4 plików

- [test/staff/disabled/staff_empty_slot_property_test.dart.disabled](../../test/staff/disabled/staff_empty_slot_property_test.dart.disabled)
- [test/staff/disabled/staff_raw_display_separation_property_test.dart.disabled](../../test/staff/disabled/staff_raw_display_separation_property_test.dart.disabled)
- [test/staff/disabled/staff_attribute_effect_preservation_test_deferred.dart.disabled](../../test/staff/disabled/staff_attribute_effect_preservation_test_deferred.dart.disabled)
- [test/staff/disabled/staff_regression_suite_test_deferred.dart.disabled](../../test/staff/disabled/staff_regression_suite_test_deferred.dart.disabled)

Manifest zawiera powody, warunki reaktywacji, przypadki odroczone i aktywnych właścicieli archiwów mieszanych. Nie pozostały przejściowe wpisy recoverInStage. Cztery pliki *.dart.disabled w podfolderach long należą do powyższej blacklisty; profil long ich nie uruchamia.

## Jawny SKIP nagród

Jeden przypadek w [task39_season_service_test.dart](../../test/calendar/task39_season_service_test.dart) pozostaje aktywnie zarejestrowany jako SKIP do przebudowy systemu nagród. To osobna, zaakceptowana przez użytkownika zaległość, nie wpis blacklisty AI.
