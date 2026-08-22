# New Football Manager

Offline football manager with NBA-style league structure — built with Flutter.

## Stack

- **Flutter 3.x** — UI (Material 3, Riverpod, go_router)
- **Pure Dart core** (`lib/core/`) — simulation engine, no Flutter imports
- **Freezed + json_serializable** — immutable domain models
- **JSON persistence** — offline saves via `path_provider`

## Project structure

```
lib/
├── core/           # Game engine (testable, Flutter-free)
│   ├── simulation/ # Match & season simulation
│   ├── league/     # Schedule, standings, playoffs
│   ├── draft/      # Lottery & draft
│   ├── finance/    # Salary cap & transfers
│   ├── tactics/    # Formations, roles, counter-tactics
│   └── ai/         # Adaptive manager AI
├── data/           # Save repository
└── app/            # Flutter UI screens
```

## Game rules

See [docs/game_rules.md](docs/game_rules.md) and [docs/zalozenia_projektowe.md](docs/zalozenia_projektowe.md).

## Development

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

### Test commands

| Purpose | PowerShell command |
| --- | --- |
| All tests | `.\scripts\test.ps1` |
| Fast test loop (without `slow` and `benchmark`) | `.\scripts\test.ps1 -Fast` |
| Market area | `.\scripts\test.ps1 -Area market` |
| Calendar area, fast | `.\scripts\test.ps1 -Area calendar -Fast` |
| All widget tests | `.\scripts\test.ps1 -Tags ui` |
| AI area with coverage | `.\scripts\test.ps1 -Area ai -Coverage` |
| Full AI Task 38 benchmark | `flutter test --dart-define=TASK38_RUN_FULL=true test/ai/task38_ai_season_calibration_test.dart` |

### Test areas

Use `-Area` with one of these nine values:

- `match` — match engine, matchday flow, player state, team shape, and results
- `ai` — AI evaluation, matchday, trade, contract, draft, roster, events, and calibration
- `market` — contracts, salary cap, transfers, free agency, draft, and scouting
- `calendar` — calendar, day/season simulation, pacing, hourly flow, and calendar UI
- `staff` — staff services and role ratings
- `messages` — message services, localization, player/team events, inbox, and urgent flows
- `data` — persistence, seeds/RNG, initial roster generation, and repository audits
- `ui` — cross-domain application shell, navigation, and shared formatters
- `balance` — balance configuration and season/calibration harnesses

### Test tags and presets

Available tags are `slow` (suites taking roughly more than 10 seconds), `ui` (widget tests), `property` (property or generator tests), `integration` (real multi-layer flows), `benchmark` (metric/aggregate runs), and `ai` (AI-domain tests).

The `fast` preset excludes `slow` and `benchmark`. `.\scripts\test.ps1 -Fast` reproduces this `fast` preset because `flutter test` does not support a `--preset` option.

## CI

GitHub Actions runs tests, `flutter analyze`, and verifies `lib/core/` has no Flutter imports.
