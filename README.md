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

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

## CI

GitHub Actions runs tests, `flutter analyze`, and verifies `lib/core/` has no Flutter imports.
