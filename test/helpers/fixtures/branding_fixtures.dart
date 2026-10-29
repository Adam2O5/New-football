import 'package:new_football/core/models/game_save.dart';

import 'game_fixtures.dart';

// The complete ID registry is needed; repeated UI layouts reuse immutable data.
final GameSave _brandingFixture = saveForLeague(seededLeague());

GameSave brandingFixture() => _brandingFixture;
